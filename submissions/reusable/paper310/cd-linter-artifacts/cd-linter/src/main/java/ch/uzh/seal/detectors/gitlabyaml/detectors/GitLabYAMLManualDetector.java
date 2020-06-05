package ch.uzh.seal.detectors.gitlabyaml.detectors;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.detectors.gitlabyaml.entities.When;
import ch.uzh.seal.detectors.gitlabyaml.utils.ManualLineNumberExtractor;
import ch.uzh.seal.project.entities.LintProject;

public class GitLabYAMLManualDetector extends GitLabYAMLDetector {

    private String category = "Manual-Job";

    public GitLabYAMLManualDetector(LintProject project) {
        super(project);
    }

    private Map<String, Job> filterByManual(Map<String, Job> jobs) {
        Map<String, Job> filteredJobs = new HashMap<>();

        for (String name : jobs.keySet()) {
            Job job = jobs.get(name);
            String stage = job.getStage();
            String jobName = job.getName();
            
            if(jobName.equalsIgnoreCase("test_e2e_manual")) {
            System.out.println(jobName + " " + job.getWhen() + " " + job.getStage());
            System.out.println(!inBlackList(stage));
            System.out.println(!inBlackList(jobName));
            System.out.println(!hasEnvironmentStop(job));
            }
            
			if (job.getWhen() == When.manual && !inBlackList(stage) &&
            		!inBlackList(jobName) && !hasEnvironmentStop(job)) {
                filteredJobs.put(name, job);
                System.out.println("in");
			}
        }

        return filteredJobs;
    }

    private Boolean hasEnvironmentStop(Job job) {
        return job.getEnvironment().getAction().equals("stop");
    }

    private Boolean inBlackList(String stage) {
        List<String> stages = List.of(
        		"staging",
        		"deploy",
                "release",
                "publish",
                "manual",
                "install",
                "docker",
                "container",
                "production",
                "image",
                "environment",
                "install",
                "prod",
                "canary",
                "triage",
                "bundle" // previously it was review
        );

        stage = stage.toLowerCase();

        for (String blackListedStage : stages) {
            if (stage.contains(blackListedStage)) {
                return true;
            }
        }

        return false;
    }

    public List<CIAntiPattern> lint() {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        GitLabYAML gitLabYAML = getGitLabYAML(project);

        ManualLineNumberExtractor lineNumberExtractor = new ManualLineNumberExtractor(gitLabYAML);

        Map<String, Job> jobs = gitLabYAML.getJobs();

        Map<String, Job> filteredJobs = filterByManual(jobs);

        String cfgFileName = ".gitlab-ci.yml";
        String projectName = project.getName();
        String remoteRepoPath = project.getRemotePath();
        String remoteCfgLink = project.getFullRemotePath(cfgFileName, true);
        String localCfgLink = project.getFullLocalPath(cfgFileName);

        for (String jobName : filteredJobs.keySet()) {
        	
        	if(jobName.startsWith("."))
        		continue;
        	
            CIAntiPattern antiPattern = new CIAntiPattern();

            String stage = jobs.get(jobName).getStage();
            String lineNumber = lineNumberExtractor.getLineNumber(jobs.get(jobName));
            //String lineNumberPath = LineNumberPathConstructor.getPath(remoteCfgLink, lineNumber);

            antiPattern.setId(generateID(projectName, jobName));
            antiPattern.setProject(projectName);
            antiPattern.setRemoteRepoLink(remoteRepoPath);
            antiPattern.setRemoteCfgLink(remoteCfgLink);
            antiPattern.setLocalCfgLink(localCfgLink);
            antiPattern.setStage(stage);
            antiPattern.setCategory(category);
            antiPattern.setEntity(jobName);
            antiPattern.setMessage("Manual job `"+jobName+"` at stage `"+stage+"`");
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
