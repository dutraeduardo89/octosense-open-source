class HealthReading {
	const HealthReading({
		required this.recordedAt,
		required this.metrics,
	});

	factory HealthReading.fromJson(Map<String, dynamic> json) {
		final metricsJson = json['metrics'];
		return HealthReading(
			recordedAt: DateTime.parse(json['recordedAt'] as String),
			metrics: metricsJson is Map<String, dynamic>
					? HealthReadingMetrics.fromJson(metricsJson)
					: const HealthReadingMetrics(),
		);
	}

	final DateTime recordedAt;
	final HealthReadingMetrics metrics;
}

class HealthReadingMetrics {
	const HealthReadingMetrics({
		this.heartRateBpm,
		this.steps,
		this.sleepDuration,
		this.oxygenSaturationPercent,
		this.totalCaloriesKcal,
	});

	factory HealthReadingMetrics.fromJson(Map<String, dynamic> json) {
		return HealthReadingMetrics(
			heartRateBpm: (json['heartRateBpm'] as num?)?.toDouble(),
			steps: (json['steps'] as num?)?.toInt(),
			sleepDuration: _parseDuration(json['sleepDuration']),
			oxygenSaturationPercent:
					(json['oxygenSaturationPercent'] as num?)?.toDouble(),
			totalCaloriesKcal: (json['totalCaloriesKcal'] as num?)?.toDouble(),
		);
	}

	final double? heartRateBpm;
	final int? steps;
	final Duration? sleepDuration;
	final double? oxygenSaturationPercent;
	final double? totalCaloriesKcal;

	static Duration? _parseDuration(Object? value) {
		if (value is! String) return null;
		final parts = value.split(':').map(int.parse).toList();
		if (parts.length != 3) return null;
		return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
	}
}
