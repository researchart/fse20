package ch.uzh.seal.detectors.maven.versioning;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import org.junit.BeforeClass;
import org.junit.Test;
import java.util.List;

import static org.junit.Assert.*;

public class MavenVersionAntiPatternDetectorTest {

    private static List<CIAntiPattern> antiPatternList;

    @BeforeClass
    public static void setBeforeClass() throws Exception {
        String path = "src/test/resources/maven/versioning/example2";
        LintProject project = new LintProject();
        project.setLocalPath(path);
        antiPatternList = new MavenVersionAntiPatternDetector(project).lint();
    }

    @Test
    public void firstAntiPatternSet() {
        CIAntiPattern actualAntiPattern = antiPatternList.get(0);
        assertEquals("kuku/bla", actualAntiPattern.getEntity());
    }

    @Test
    public void secondAntiPatternSet() {
        CIAntiPattern actualAntiPattern = antiPatternList.get(1);
        assertEquals("banana/banana", actualAntiPattern.getEntity());
    }

    @Test
    public void thirdAntiPatternSet() {
        CIAntiPattern actualAntiPattern = antiPatternList.get(2);
        assertEquals("buh/buh", actualAntiPattern.getEntity());
    }

    @Test
    public void correctNumberOfAntiPatterns() {
        assertEquals(3, antiPatternList.size());
    }

}