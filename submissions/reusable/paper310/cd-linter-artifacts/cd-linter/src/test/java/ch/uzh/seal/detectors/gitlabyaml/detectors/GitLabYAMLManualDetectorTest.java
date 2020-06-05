package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import org.junit.BeforeClass;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class GitLabYAMLManualDetectorTest {

    private static LintProject project;
    private static List<CIAntiPattern> antiPatterns;

    @BeforeClass
    public static void setBeforeClass() throws Exception {
        project = new LintProject();
        project.setLocalPath("src/test/resources/gitlabyaml/manual");
        //project.setLocalPath("src/test/resources/gitlabyaml/retry2");
        antiPatterns = new GitLabYAMLManualDetector(project).lint();
    }

    @Test
    public void numberOfAntiPatterns() {
        assertEquals(2, antiPatterns.size());
    }
}