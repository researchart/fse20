package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import org.junit.BeforeClass;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class GitLabYAMLOnlyExceptDetectorTest {

    private static LintProject project;
    private static List<CIAntiPattern> antiPatterns;

    @BeforeClass
    public static void setBeforeClass() throws Exception {
        project = new LintProject();
        project.setLocalPath("src/test/resources/gitlabyaml/onlyexcept");
        antiPatterns = new GitLabYAMLOnlyExceptDetector(project).lint();
    }

    @Test
    public void numberOfAntiPatterns() {
        assertEquals(9, antiPatterns.size());
    }
}