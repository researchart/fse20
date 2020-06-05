package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.detectors.gitlabyaml.entities.Except;
import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.detectors.gitlabyaml.entities.Only;
import ch.uzh.seal.utils.LineNumberExtractor;
import ch.uzh.seal.utils.LineNumberPathConstructor;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class GitLabYAMLOnlyExceptDetector extends GitLabYAMLDetector {

    private String category = "Job-Creation-Policy";

    public GitLabYAMLOnlyExceptDetector(LintProject project) {
        super(project);
    }

    public List<CIAntiPattern> lint() {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        GitLabYAML gitLabYAML = getGitLabYAML(project);

        LineNumberExtractor lineNumberExtractor = new LineNumberExtractor(gitLabYAML.getRaw());

        Map<String, Job> jobs = gitLabYAML.getJobs();

        String cfgFileName = ".gitlab-ci.yml";
        String projectName = project.getName();
        String remoteRepoPath = project.getRemotePath();
        String remoteCfgLink = project.getFullRemotePath(cfgFileName, true);
        String localCfgLink = project.getFullLocalPath(cfgFileName);

        for (String jobName : jobs.keySet()) {
            Job job = jobs.get(jobName);
            String lineNumber = lineNumberExtractor.getLineNumber(jobName+":");
            //String lineNumberPath = LineNumberPathConstructor.getPath(remoteCfgLink, lineNumber);

            List<CIAntiPattern> jobAntiPatterns = getOnlyExceptAntiPatternsFromJob(job);
            for (CIAntiPattern jobAntiPattern : jobAntiPatterns) {
                jobAntiPattern.setId(generateID(projectName, jobName, jobAntiPattern.getSubCategory()));
                jobAntiPattern.setProject(projectName);
                jobAntiPattern.setRemoteRepoLink(remoteRepoPath);
                jobAntiPattern.setRemoteCfgLink(remoteCfgLink);
                jobAntiPattern.setLocalCfgLink(localCfgLink);
                jobAntiPattern.setContext(gitLabYAML.getRaw());
                jobAntiPattern.setLineNumber(lineNumber);
                jobAntiPattern.setCfgFileName(cfgFileName);
            }

            antiPatterns.addAll(jobAntiPatterns);

        }

        return antiPatterns;
    }

    public String generateID(String projectName, String jobName, String subcategory) {
        return removeIllegalCharsInID(projectName + "__" + category + "__" + subcategory + "__" + jobName);
    }

    private List<CIAntiPattern> getOnlyExceptAntiPatternsFromJob(Job job) {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        String jobName = job.getName();
        String stage = job.getStage();

        Only only = job.getOnly();
        if (!only.getRefs().hasBranches() && !only.getRefs().hasPushes()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("only-branches");
            antiPattern.setMessage(
                    "No creation of job `"+jobName
                    +"` for branches at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        if (!only.getRefs().hasTags() && !only.getRefs().hasPushes()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("only-tags");
            antiPattern.setMessage(
                    "No creation of job `"+jobName
                    +"` for tags at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        if (only.getRefs().getNames().size() > 0){
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("only-custom");
            antiPattern.setMessage(
                    "Creation of job `"+jobName
                    +"` only for branches/tags: "+only.getRefs().getNames().toString()
                    +" at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        if (only.getChanges().size() > 0) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("only-changes");
            antiPattern.setMessage(
                    "Creation of job `"+jobName
                    +"`only for changes: "+only.getChanges().toString()
                    +" at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        Except except = job.getExcept();
        if (except.getRefs().hasBranches() && !only.getRefs().hasPushes()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("except-branches");
            antiPattern.setMessage(
                    "No creation of job `"+jobName+"` for branches"+" at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        if (except.getRefs().hasTags() && !only.getRefs().hasPushes()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("except-tags");
            antiPattern.setMessage(
                    "No creation of job `"+jobName+"` for tags at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        if (except.getRefs().getNames().size() > 0){
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("except-custom");
            antiPattern.setMessage(
                    "No creation of job `"+jobName
                    +"` for branches/tags: "+except.getRefs().getNames().toString()
                    +" at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        if (except.getChanges().size() > 0) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setStage(stage);
            antiPattern.setEntity(jobName);
            antiPattern.setCategory(category);
            antiPattern.setSubCategory("except-changes");
            antiPattern.setMessage(
                    "No creation of job `"+jobName
                    +"` for changes: "+except.getChanges().toString()
                    +" at stage `"+stage+"`"
            );
            antiPatterns.add(antiPattern);
        }

        return antiPatterns;
    }
}
