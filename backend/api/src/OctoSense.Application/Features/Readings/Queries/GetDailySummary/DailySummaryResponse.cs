namespace OctoSense.Application.Features.Readings.Queries.GetDailySummary;

/// <summary>
/// Resumo agregado de um único dia para um usuário.
/// </summary>
/// <param name="Date">Data civil (UTC) do resumo.</param>
/// <param name="TotalSteps">Soma dos passos do dia.</param>
/// <param name="ActiveCaloriesKcal">Soma das calorias ativas do dia (exercício).</param>
/// <param name="TotalCaloriesKcal">Soma das calorias totais do dia (ativas + basal).</param>
/// <param name="AvgHeartRateBpm">Média de FC, quando houver.</param>
/// <param name="TotalSleepDuration">Soma da duração de sono, quando houver.</param>
/// <param name="AvgOxygenSaturation">Média de SpO2, quando houver.</param>
/// <param name="ReadingCount">Quantidade de leituras brutas do dia.</param>
public sealed record DailySummaryResponse(
    DateOnly Date,
    int TotalSteps,
    double ActiveCaloriesKcal,
    double TotalCaloriesKcal,
    double? AvgHeartRateBpm,
    TimeSpan? TotalSleepDuration,
    double? AvgOxygenSaturation,
    int ReadingCount
);

/// <summary>
/// Envelope com resumos por dia em um período.
/// </summary>
/// <param name="UserId">Usuário consultado.</param>
/// <param name="From">Data inicial inclusiva.</param>
/// <param name="To">Data final inclusiva.</param>
/// <param name="Summaries">Lista de resumos diários.</param>
public sealed record PeriodSummaryResponse(
    string UserId,
    DateOnly From,
    DateOnly To,
    IReadOnlyList<DailySummaryResponse> Summaries
);
