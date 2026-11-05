using System.Globalization;
using System.Text.Json;
using OctoSense.Domain.GoogleHealth;

namespace OctoSense.Infrastructure.GoogleHealth;

/// <summary>
/// Maps Google Health API v4 JSON into <see cref="GoogleHealthDataPoint"/>.
/// </summary>
/// <remarks>
/// Field names follow the public REST resource: <c>beatsPerMinute</c> as string, nested intervals, daily rollup <c>kcalSum</c>.
/// </remarks>
public static class GoogleHealthDataPointMapper
{
    /// <summary>
    /// Brazil offset used for civil rollup timestamps.
    /// </summary>
    /// <remarks>
    /// Google Health sends daily rollups with a <c>civilStartTime</c> in the user's
    /// local calendar. Storing them at UTC midnight makes the aggregator (which
    /// groups by UTC-3) shift them one day back. Keeping the BRT offset here
    /// aligns the bucketed day with what the official app shows.
    /// </remarks>
    private static readonly TimeSpan CivilOffset = TimeSpan.FromHours(-3);

    /// <summary>
    /// Maps a <c>dataPoints</c> list item for a given data type.
    /// </summary>
    public static GoogleHealthDataPoint? TryMapListItem(JsonElement point, string dataType)
    {
        // Google Health receives the same measurement from multiple sources
        // (Fitbit and Health Connect both read the phone pedometer).
        // Only Health Connect is the primary source; Fitbit is a duplicate.
        if (!IsPrimarySource(point))
        {
            return null;
        }

        var name = ReadString(point, "name") ?? BuildFallbackExternalId(point, dataType);

        var deviceId = ResolveDeviceId(point);
        var deviceSource = ResolveDeviceSource(point);

        return dataType switch
        {
            "heart-rate" => TryHeartRate(point, name, deviceId, deviceSource),
            "steps" => TrySteps(point, name, deviceId, deviceSource),
            "sleep" => TrySleep(point, name, deviceId, deviceSource),
            "oxygen-saturation" => TryOxygen(point, name, deviceId, deviceSource),
            "active-energy-burned" => TryActiveEnergy(point, name, deviceId, deviceSource),
            _ => null
        };
    }

    /// <summary>
    /// Google Health picks one source per measurement. Health Connect is primary.
    /// </summary>
    private static bool IsPrimarySource(JsonElement point)
    {
        if (!point.TryGetProperty("dataSource", out var dataSource)
            || dataSource.ValueKind != JsonValueKind.Object)
        {
            return true;
        }

        if (!dataSource.TryGetProperty("platform", out var platform)
            || platform.ValueKind != JsonValueKind.String)
        {
            return true;
        }

        var platformName = platform.GetString();
        return string.Equals(platformName, "HEALTH_CONNECT", StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Maps a <c>rollupDataPoints</c> item from <c>total-calories</c> dailyRollUp.
    /// </summary>
    public static GoogleHealthDataPoint? TryMapTotalCaloriesRollup(JsonElement point)
    {
        if (!point.TryGetProperty("totalCalories", out var calories)
            || !TryGetDouble(calories, "kcalSum", out var kcal))
        {
            return null;
        }

        var recordedAt = ReadCivilStart(point) ?? DateTimeOffset.UtcNow;
        var day = recordedAt.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        return new GoogleHealthDataPoint(
            $"users/me/dataTypes/total-calories/daily/{day}",
            "total-calories",
            recordedAt,
            "google-health",
            "google-health",
            TotalCaloriesKcal: kcal);
    }

    private static GoogleHealthDataPoint? TryHeartRate(
        JsonElement point,
        string name,
        string deviceId,
        string deviceSource)
    {
        if (!point.TryGetProperty("heartRate", out var heartRate)
            || !TryGetDouble(heartRate, "beatsPerMinute", out var bpm)
                && !TryGetDouble(heartRate, "bpm", out bpm))
        {
            return null;
        }

        return new GoogleHealthDataPoint(
            name,
            "heart-rate",
            ReadSampleTime(heartRate) ?? DateTimeOffset.UtcNow,
            deviceId,
            deviceSource,
            HeartRateBpm: bpm);
    }

    private static GoogleHealthDataPoint? TrySteps(
        JsonElement point,
        string name,
        string deviceId,
        string deviceSource)
    {
        if (!point.TryGetProperty("steps", out var steps)
            || !TryGetInt(steps, "count", out var count))
        {
            return null;
        }

        return new GoogleHealthDataPoint(
            name,
            "steps",
            ReadIntervalStart(steps) ?? DateTimeOffset.UtcNow,
            deviceId,
            deviceSource,
            Steps: count);
    }

    private static GoogleHealthDataPoint? TrySleep(
        JsonElement point,
        string name,
        string deviceId,
        string deviceSource)
    {
        if (!point.TryGetProperty("sleep", out var sleep)
            || !sleep.TryGetProperty("interval", out var interval)
            || !TryGetTimestamp(interval, "startTime", out var start)
            || !TryGetTimestamp(interval, "endTime", out var end)
            || end <= start)
        {
            return null;
        }

        return new GoogleHealthDataPoint(
            name,
            "sleep",
            start,
            deviceId,
            deviceSource,
            SleepDuration: end - start);
    }

    private static GoogleHealthDataPoint? TryOxygen(
        JsonElement point,
        string name,
        string deviceId,
        string deviceSource)
    {
        if (!point.TryGetProperty("oxygenSaturation", out var oxygen)
            || !TryGetDouble(oxygen, "percentage", out var percent))
        {
            return null;
        }

        return new GoogleHealthDataPoint(
            name,
            "oxygen-saturation",
            ReadSampleTime(oxygen) ?? DateTimeOffset.UtcNow,
            deviceId,
            deviceSource,
            OxygenSaturationPercent: percent);
    }

    private static GoogleHealthDataPoint? TryActiveEnergy(
        JsonElement point,
        string name,
        string deviceId,
        string deviceSource)
    {
        if (!point.TryGetProperty("activeEnergyBurned", out var energy)
            || !TryGetDouble(energy, "kcal", out var kcal))
        {
            return null;
        }

        return new GoogleHealthDataPoint(
            name,
            "active-energy-burned",
            ReadIntervalStart(energy) ?? DateTimeOffset.UtcNow,
            deviceId,
            deviceSource,
            TotalCaloriesKcal: kcal);
    }

    /// <summary>
    /// Builds a stable fallback external id when the Google Health API omits the <c>name</c> field.
    /// </summary>
    private static string BuildFallbackExternalId(JsonElement point, string dataType)
    {
        var platform = "unknown";
        if (point.TryGetProperty("dataSource", out var dataSource)
            && dataSource.ValueKind == JsonValueKind.Object
            && dataSource.TryGetProperty("platform", out var platformValue)
            && platformValue.ValueKind == JsonValueKind.String)
        {
            platform = platformValue.GetString() ?? "unknown";
        }

        var timestamp = ExtractPointTimestamp(point, dataType);

        if (timestamp is null)
        {
            var hash = point.GetRawText().GetHashCode() & 0x7FFFFFFF;
            return $"users/me/dataTypes/{dataType}/{platform}/{DateTimeOffset.UtcNow:yyyy-MM-ddTHH:mm:ssZ}-{hash:X8}";
        }

        return $"users/me/dataTypes/{dataType}/{platform}/{timestamp.Value.UtcDateTime:yyyy-MM-ddTHH:mm:ssZ}";
    }

    /// <summary>
    /// Extracts the timestamp from the correct metric property based on data type.
    /// </summary>
    private static DateTimeOffset? ExtractPointTimestamp(JsonElement point, string dataType)
    {
        var metricName = dataType switch
        {
            "heart-rate" => "heartRate",
            "steps" => "steps",
            "sleep" => "sleep",
            "oxygen-saturation" => "oxygenSaturation",
            "active-energy-burned" => "activeEnergyBurned",
            _ => null
        };

        if (metricName is null || !point.TryGetProperty(metricName, out var metric))
        {
            return null;
        }

        return ReadSampleTime(metric) ?? ReadIntervalStart(metric);
    }

    private static string ResolveDeviceId(JsonElement point)
    {
        if (point.TryGetProperty("dataSourceId", out var sourceId)
            && sourceId.ValueKind == JsonValueKind.String
            && !string.IsNullOrWhiteSpace(sourceId.GetString()))
        {
            return sourceId.GetString()!;
        }

        if (point.TryGetProperty("dataSource", out var source)
            && source.ValueKind == JsonValueKind.Object)
        {
            foreach (var key in new[] { "streamId", "id", "recordingMethod" })
            {
                var value = ReadString(source, key);
                if (!string.IsNullOrWhiteSpace(value))
                {
                    return value;
                }
            }
        }

        return "google-health";
    }

    private static string ResolveDeviceSource(JsonElement point)
    {
        var deviceId = ResolveDeviceId(point);
        return deviceId.Contains("xiaomi", StringComparison.OrdinalIgnoreCase)
            ? "xiaomi-redmi-watch-5-active"
            : "google-health";
    }

    private static DateTimeOffset? ReadSampleTime(JsonElement metric) =>
        metric.TryGetProperty("sampleTime", out var sample)
            ? ReadTimestamp(sample, "physicalTime")
            : null;

    private static DateTimeOffset? ReadIntervalStart(JsonElement metric) =>
        metric.TryGetProperty("interval", out var interval)
            ? ReadTimestamp(interval, "startTime")
            : null;

    private static DateTimeOffset? ReadCivilStart(JsonElement point)
    {
        if (!point.TryGetProperty("civilStartTime", out var civil)
            || civil.ValueKind != JsonValueKind.Object)
        {
            return null;
        }

        if (!TryGetInt(civil, "year", out var year)
            || !TryGetInt(civil, "month", out var month)
            || !TryGetInt(civil, "day", out var day))
        {
            if (!civil.TryGetProperty("date", out var date)
                || !TryGetInt(date, "year", out year)
                || !TryGetInt(date, "month", out month)
                || !TryGetInt(date, "day", out day))
            {
                return null;
            }
        }

        return new DateTimeOffset(year, month, day, 0, 0, 0, CivilOffset);
    }

    private static string? ReadString(JsonElement element, string name) =>
        element.TryGetProperty(name, out var value)
            && value.ValueKind == JsonValueKind.String
                ? value.GetString()
                : null;

    private static DateTimeOffset? ReadTimestamp(JsonElement parent, string name) =>
        TryGetTimestamp(parent, name, out var value) ? value : null;

    private static bool TryGetTimestamp(JsonElement parent, string name, out DateTimeOffset value)
    {
        value = default;
        var text = ReadString(parent, name);
        return !string.IsNullOrWhiteSpace(text) && DateTimeOffset.TryParse(text, out value);
    }

    private static bool TryGetDouble(JsonElement parent, string name, out double value)
    {
        value = 0;
        if (!parent.TryGetProperty(name, out var element))
        {
            return false;
        }

        if (element.ValueKind == JsonValueKind.Number && element.TryGetDouble(out value))
        {
            return true;
        }

        return element.ValueKind == JsonValueKind.String
            && double.TryParse(element.GetString(), NumberStyles.Float, CultureInfo.InvariantCulture, out value);
    }

    private static bool TryGetInt(JsonElement parent, string name, out int value)
    {
        value = 0;
        if (!parent.TryGetProperty(name, out var element))
        {
            return false;
        }

        if (element.ValueKind == JsonValueKind.Number && element.TryGetInt32(out value))
        {
            return true;
        }

        if (element.ValueKind == JsonValueKind.Number
            && element.TryGetInt64(out var asLong)
            && asLong is >= int.MinValue and <= int.MaxValue)
        {
            value = (int)asLong;
            return true;
        }

        return element.ValueKind == JsonValueKind.String
            && int.TryParse(element.GetString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out value);
    }
}