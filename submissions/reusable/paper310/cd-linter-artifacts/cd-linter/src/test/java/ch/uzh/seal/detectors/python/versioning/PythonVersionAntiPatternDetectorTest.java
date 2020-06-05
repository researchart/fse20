package ch.uzh.seal.detectors.python.versioning;

import ch.uzh.seal.detectors.Detector;
import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class PythonVersionAntiPatternDetectorTest {

    private static List<CIAntiPattern> antiPatternList;

    @Before
    public void setUp() throws Exception {
        LintProject lintProject = new LintProject();
        lintProject.setLocalPath("src/test/resources/python/detectors");
        Detector detector = new PythonVersionAntiPatternDetector(lintProject);
        antiPatternList = detector.lint();
    }
    
    @Test
    public void checkDotCase() throws Exception {
    	 LintProject lintProject = new LintProject();
         lintProject.setLocalPath("src/test/resources/python/detectors2");
         Detector detector = new PythonVersionAntiPatternDetector(lintProject);
         antiPatternList = detector.lint();
         
         assertEquals(0, antiPatternList.size());
    }
    
    @Test
    public void checkUpperCase() throws Exception {
    	 LintProject lintProject = new LintProject();
         lintProject.setLocalPath("src/test/resources/python/detectors3");
         Detector detector = new PythonVersionAntiPatternDetector(lintProject);
         antiPatternList = detector.lint();
         for(CIAntiPattern ap : antiPatternList)
        	 System.out.println(ap.getId());
         System.out.println("stop");
         assertEquals(16, antiPatternList.size());
    }
    
    @Test
    public void checkSkipLine() throws Exception {
    	 LintProject lintProject = new LintProject();
         lintProject.setLocalPath("src/test/resources/python/detectors4");
         Detector detector = new PythonVersionAntiPatternDetector(lintProject);
         antiPatternList = detector.lint();
         System.out.println("stop");
         for(CIAntiPattern ap : antiPatternList)
        	 System.out.println(ap.getId());
         System.out.println("stop");
         assertEquals(0, antiPatternList.size());
    }
    

    @Test
    public void numberOfAntipatterns() {
        assertEquals(4, antiPatternList.size());
    }

    @Test
    public void firstAntipattern() {
        assertEquals("lxml", antiPatternList.get(0).getEntity());
    }

    @Test
    public void secondAntipattern() {
        assertEquals("csv", antiPatternList.get(1).getEntity());
    }

    @Test
    public void thirdAntipattern() {
        assertEquals("tensorflow", antiPatternList.get(2).getEntity());
    }

    @Test
    public void fourthAntipattern() {
        assertEquals("six", antiPatternList.get(3).getEntity());
    }
    
    @Test
    public void checkYamlSmells() throws Exception {
    	LintProject lintProject = new LintProject();
        lintProject.setLocalPath("src/test/resources/gitlabyaml/versioning");
        Detector detector = new PythonVersionAntiPatternDetector(lintProject);
        antiPatternList = detector.lint();
        assertEquals(3, antiPatternList.size());
    }
    
    

}