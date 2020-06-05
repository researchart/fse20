package ch.uzh.seal.detectors.gitlabyaml.entities;

public enum RetryWhen
{
    always,
    unknown_failure,
    script_failure,
    api_failure,
    stuck_or_timeout_failure,
    runner_system_failure,
    missing_dependency_failure,
    runner_unsupported
    ;
}
