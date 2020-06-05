package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.gitlabyaml.utils.RetryLineNumberExtractor;
import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.utils.LineNumberExtractor;
import ch.uzh.seal.utils.LineNumberPathConstructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GitLabYAMLRetryDetector extends GitLabYAMLDetector {

    private String category = "Job-Retry";

    public GitLabYAMLRetryDetector(LintProject project) {
        super(project);
    }

    private Map<String, Job> filterByRetry(Map<String, Job> jobs) {
        Map<String, Job> filteredJobs = new HashMap<>();

        for (String name : jobs.keySet()) {
            Job job = jobs.get(name);
            if (job.getRetry().getMax() > 0)
                filteredJobs.put(name, job);
        }

        return filteredJobs;
    }

    public List<CIAntiPattern> lint() {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        GitLabYAML gitLabYAML = getGitLabYAML(project);

        RetryLineNumberExtractor lineNumberExtractor = new RetryLineNumberExtractor(gitLabYAML);

        Map<String, Job> jobs = gitLabYAML.getJobs();

        Map<String, Job> filteredJobs = filterByRetry(jobs);

        String cfgFileName = ".gitlab-ci.yml";
        String projectName = project.getName();
        String remoteRepoPath = project.getRemotePath();
        String remoteCfgLink = project.getFullRemotePath(cfgFileName, true);
        String localCfgLink = project.getFullLocalPath(cfgFileName);

        for (String jobName : filteredJobs.keySet()) {
        	
        	if(jobName.startsWith("."))
        		continue;
        	
            CIAntiPattern antiPattern = new CIAntiPattern();

            Job job = jobs.get(jobName);
            String stage = job.getStage();
            String subcategory = job.getRetry().getWhen().toString();
            String lineNumber = lineNumberExtractor.getLineNumber(job);
            String retries = Integer.toString(job.getRetry().getMax());

            antiPattern.setId(generateID(projectName, jobName));
            antiPattern.setProject(projectName);
            antiPattern.setRemoteRepoLink(remoteRepoPath);
            antiPattern.setRemoteCfgLink(remoteCfgLink);
            antiPattern.setLocalCfgLink(localCfgLink);
            antiPattern.setStage(stage);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory(subcategory);
            antiPattern.setEntity(jobName);
            antiPattern.setMessage(retries);
            antiPattern.setContext(gitLabYAML.getRaw());
            antiPattern.setLineNumber(lineNumber);
            antiPattern.setCfgFileName(cfgFileName);
            antiPatterns.add(antiPattern);
        }

        return antiPatterns;
    }

    public String generateID(String projectName, String jobName) {
        return removeIllegalCharsInID(projectName + "__" + category + "__" + jobName);
    }
}
