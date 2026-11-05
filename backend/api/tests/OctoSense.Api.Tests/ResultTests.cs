using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class ResultTests
{
    [Fact]
    public void Success_ShouldExposeValue_WhenCreated()
    {
        var result = Result<int>.Success(7);

        Assert.True(result.IsSuccess);
        Assert.False(result.IsFailure);
        Assert.Equal(7, result.Value);
        Assert.Empty(result.Errors);
    }

    [Fact]
    public void Failure_ShouldExposeErrors_WhenCreated()
    {
        var error = Error.Failure("Invalid health reading data");
        var result = Result<HealthReading>.Failure(error);

        Assert.True(result.IsFailure);
        Assert.Null(result.Value);
        Assert.Contains(error, result.Errors);
    }

    [Fact]
    public void Match_ShouldInvokeSuccess_WhenResultSucceeded()
    {
        var mapped = Result<string>.Success("ok").Match(value => value.ToUpperInvariant(), _ => "fail");

        Assert.Equal("OK", mapped);
    }

    [Fact]
    public void Match_ShouldInvokeFailure_WhenResultFailed()
    {
        var mapped = Result<string>.Failure(Error.Validation("Name", "Name is required."))
            .Match(_ => "ok", errors => errors[0].Message);

        Assert.Equal("Name is required.", mapped);
    }
}
