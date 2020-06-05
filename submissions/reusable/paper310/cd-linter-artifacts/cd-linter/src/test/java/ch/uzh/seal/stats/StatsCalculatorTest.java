package ch.uzh.seal.stats;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.readers.CIAntiPatternCSVReader;
import org.junit.BeforeClass;
import org.junit.Test;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import static org.junit.Assert.*;

public class StatsCalculatorTest {

    private static StatsCalculator statsCalculator;

    @BeforeClass
    public static void setUp() throws IOException {
        CIAntiPatternCSVReader ciAntiPatternCSVReader = new CIAntiPatternCSVReader("src/test/resources/stats/test.csv");
        Set<CIAntiPattern> ciAntiPatternSet = ciAntiPatternCSVReader.read();
        statsCalculator = new StatsCalculator(ciAntiPatternSet);
    }

    @Test
    public void getNumberOfViolations() {
        assertEquals(11, statsCalculator.getNumberOfViolations());
    }

    @Test
    public void getNumberOfViolationsPerCategory() {
        Map<String, Long> expected = new HashMap<>();
        expected.put("Job-Allow-Failure", Integer.toUnsignedLong(3));
        expected.put("Vulnerability", Integer.toUnsignedLong(7));
        expected.put("Manual-Job", Integer.toUnsignedLong(1));
        assertEquals(expected, statsCalculator.getNumberOfViolationsPerCategory());
    }

    @Test
    public void getNumberOfProjects() {
        assertEquals(7, statsCalculator.getNumberOfProjects());
    }

    @Test
    public void getNumberOfProjectsPerCategory() {
        Map<String, Integer> expected = new HashMap<>();
        expected.put("Job-Allow-Failure", 2);
        expected.put("Vulnerability", 4);
        expected.put("Manual-Job", 1);
        assertEquals(expected, statsCalculator.getNumberOfProjectsPerCategory());
    }

    @Test
    public void getNumberOfOwners() {
        assertEquals(6, statsCalculator.getNumberOfOwners());
    }

    @Test
    public void getNumberOfOwnersPerCategory() {
        Map<String, Integer> expected = new HashMap<>();
        expected.put("Job-Allow-Failure", 2);
        expected.put("Vulnerability", 3);
        expected.put("Manual-Job", 1);
        assertEquals(expected, statsCalculator.getNumberOfOwnersPerCategory());
    }
}