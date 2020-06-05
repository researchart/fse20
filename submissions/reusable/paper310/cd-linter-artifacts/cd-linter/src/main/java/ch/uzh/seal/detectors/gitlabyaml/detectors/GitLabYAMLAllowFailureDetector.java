package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.gitlabyaml.utils.AllowFailureNumberExtractor;
import ch.uzh.seal.detectors.gitlabyaml.utils.GitLabYAMLLineNumberExtractor;
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


public class GitLabYAMLAllowFailureDetector extends GitLabYAMLDetector{

    private String category = "Job-Allow-Failure";


    public GitLabYAMLAllowFailureDetector(LintProject project) {
        super(project);
    }

    private Map<String, Job> filterByAllowFailure(Map<String, Job> jobs) {
        Map<String, Job> filteredJobs = new HashMap<>();

        for (String name : jobs.keySet()) {
            Job job = jobs.get(name);
            String stage = job.getStage();
            String jobName = job.getName();
            if (job.getAllow_failure() && !inBlackList(stage) &&
            		!inBlackList(jobName))
                filteredJobs.put(name, job);
        }

        return filteredJobs;
    }
    
    private Boolean inBlackList(String stage) {
        List<String> stages = List.of(
        		"dast", // because in the gitlab template
        		"sast"
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

        AllowFailureNumberExtractor lineNumberExtractor = new AllowFailureNumberExtractor(gitLabYAML);

        Map<String, Job> jobs = gitLabYAML.getJobs();

        Map<String, Job> filteredJobs = filterByAllowFailure(jobs);

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

            antiPattern.setId(generateID(projectName, jobName));
            antiPattern.setProject(projectName);
            antiPattern.setRemoteRepoLink(remoteRepoPath);
            antiPattern.setRemoteCfgLink(remoteCfgLink);
            antiPattern.setLocalCfgLink(localCfgLink);
            antiPattern.setStage(stage);
            antiPattern.setCategory(category);
            antiPattern.setEntity(jobName);
            antiPattern.setMessage("Allows failure of job `"+jobName+"` at stage `"+stage+"`");
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
