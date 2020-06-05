package ch.uzh.seal.detectors.gitlabyaml.utils;

import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;

public class RetryLineNumberExtractor extends GitLabYAMLLineNumberExtractor {

    public RetryLineNumberExtractor(GitLabYAML gitLabYAML) {
        super(gitLabYAML);
    }

    @Override
    public Boolean categoryIsNotDefault(Job defJob) {
        return defJob.getRetry().getMax() != 0;
    }

    @Override
    public Boolean jobSameAsDefJob(Job job, Job defJob) {
        return job.getRetry().getMax() == defJob.getRetry().getMax();
    }
}
