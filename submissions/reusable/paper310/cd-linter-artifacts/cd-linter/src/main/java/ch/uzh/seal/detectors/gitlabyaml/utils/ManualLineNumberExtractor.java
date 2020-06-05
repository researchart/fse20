package ch.uzh.seal.detectors.gitlabyaml.utils;

import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.detectors.gitlabyaml.entities.When;

public class ManualLineNumberExtractor extends GitLabYAMLLineNumberExtractor {

    public ManualLineNumberExtractor(GitLabYAML gitLabYAML) {
        super(gitLabYAML);
    }

    @Override
    public Boolean categoryIsNotDefault(Job defJob) {
        return defJob.getWhen() == When.manual;
    }

    @Override
    public Boolean jobSameAsDefJob(Job job, Job defJob) {
        return job.getWhen() == defJob.getWhen();
    }
}
