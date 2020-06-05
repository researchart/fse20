package ch.uzh.seal.detectors.maven.versioning;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import org.junit.BeforeClass;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.assertEquals;

public class MavenVerssionAntiPatternDetectorTest2 {
    private static List<CIAntiPattern> antiPatternList;

    @BeforeClass
    public static void setBeforeClass() throws Exception {
        String path = "src/test/resources/maven/versioning/example3";
        LintProject project = new LintProject();
        project.setLocalPath(path);
        antiPatternList = new MavenVersionAntiPatternDetector(project).lint();
    }

    @Test
    public void correctNumberOfAntiPatterns() {
        assertEquals(0, antiPatternList.size());
    }
}
