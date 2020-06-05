package ch.uzh.seal.project.linters;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.gitlabyaml.detectors.*;
import ch.uzh.seal.detectors.maven.versioning.MavenVersionAntiPatternDetector;
import ch.uzh.seal.detectors.python.versioning.PythonVersionAntiPatternDetector;
import ch.uzh.seal.project.entities.LintProject;

import java.util.ArrayList;
import java.util.List;

public class ProjectLinter {

    public static List<CIAntiPattern> getCIAntiPatterns(LintProject lintProject) throws Exception {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        String language = lintProject.getLanguage();
        String buildTool = lintProject.getBuildToolName();

        if (buildTool.equals("Maven")) {
            antiPatterns.addAll(new MavenVersionAntiPatternDetector(lintProject).lint());
        }
        else if (language.equals("Python")) {
            antiPatterns.addAll(new PythonVersionAntiPatternDetector(lintProject).lint());
        }
        
        //antiPatterns.addAll(new GitLabYAMLDuplicateLibraries(lintProject).lint());

        antiPatterns.addAll(new GitLabYAMLAllowFailureDetector(lintProject).lint());
        antiPatterns.addAll(new GitLabYAMLRetryDetector(lintProject).lint());
        //antiPatterns.addAll(new GitLabYAMLVulnerabilityDetector(lintProject).lint());
        antiPatterns.addAll(new GitLabYAMLManualDetector(lintProject).lint());
        //antiPatterns.addAll(new GitLabYAMLOnlyExceptDetector(lintProject).lint());

        return antiPatterns;
    }
}
