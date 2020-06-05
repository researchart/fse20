package ch.uzh.seal.detectors.maven.versioning.parsers;

import ch.uzh.seal.detectors.maven.versioning.entities.VersionSpecifier;

import org.junit.Test;

import static org.junit.Assert.*;

public class VersionSpecifierParserTest {

    @Test
    public void softMatch() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("1.0");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("1.0");
        expectedSpecifier.setMatch("1.0");
        assertEquals(expectedSpecifier, actualSpecifier);
    }

    @Test
    public void hardMatch() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("[1.0]");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("[1.0]");
        expectedSpecifier.setMatch("1.0");
        assertEquals(expectedSpecifier, actualSpecifier);
    }

    @Test
    public void upperBoundInclusive() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("(,1.0]");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("(,1.0]");
        expectedSpecifier.setUpperBoundInclusive("1.0");
        assertEquals(expectedSpecifier, actualSpecifier);
    }

    @Test
    public void upperBoundExclusive() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("(,1.0)");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("(,1.0)");
        expectedSpecifier.setUpperBoundExclusive("1.0");
        assertEquals(expectedSpecifier, actualSpecifier);
    }

    @Test
    public void lowerBoundInclusive() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("[1.0,)");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("[1.0,)");
        expectedSpecifier.setLowerBoundInclusive("1.0");
        assertEquals(expectedSpecifier, actualSpecifier);
    }

    @Test
    public void lowerBoundExclusive() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("(1.0,)");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("(1.0,)");
        expectedSpecifier.setLowerBoundExclusive("1.0");
        assertEquals(expectedSpecifier, actualSpecifier);
    }

    @Test
    public void lowerBoundExclusiveAndUpperBoundInclusive() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("(1.0,2.0]");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("(1.0,2.0]");
        expectedSpecifier.setLowerBoundExclusive("1.0");
        expectedSpecifier.setUpperBoundInclusive("2.0");
        assertEquals(expectedSpecifier, actualSpecifier);
    }

    @Test
    public void empty() {
        VersionSpecifier actualSpecifier = new VersionSpecifierParser().parse("");
        VersionSpecifier expectedSpecifier = new VersionSpecifier();
        expectedSpecifier.setRaw("");
        assertEquals(expectedSpecifier, actualSpecifier);
    }
}