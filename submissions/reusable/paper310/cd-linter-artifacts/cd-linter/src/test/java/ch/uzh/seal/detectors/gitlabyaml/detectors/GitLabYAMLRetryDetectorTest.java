package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class GitLabYAMLRetryDetectorTest {

    private static LintProject project;

    @BeforeClass
    public static void setBeforeClass() {
        project = new LintProject();
        project.setLocalPath("src/test/resources/gitlabyaml/retryallowfailure");
    }

    @Ignore
    @Test
    public void lint() throws Exception {
        List<CIAntiPattern> antiPatterns = new GitLabYAMLRetryDetector(project).lint();
        Boolean oracle = antiPatterns.size() == 2
                && antiPatterns.get(0).getProject().equals(project.getName())
                && antiPatterns.get(0).getEntity().equals("clean-compile")
                && antiPatterns.get(0).getCategory().equals("Job-Retry")
                && antiPatterns.get(1).getProject().equals(project.getName())
                && antiPatterns.get(1).getEntity().equals("verify")
                && antiPatterns.get(1).getCategory().equals("Job-Retry")
                ;

        assertEquals(oracle, true);
    }
}