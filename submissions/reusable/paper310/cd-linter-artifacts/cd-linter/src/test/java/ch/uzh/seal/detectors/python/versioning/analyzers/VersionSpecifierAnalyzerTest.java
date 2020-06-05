package ch.uzh.seal.detectors.python.versioning.analyzers;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class VersionSpecifierAnalyzerTest {


    @Test
    public void hasNoVersionSpecifier() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setRaw("");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasNoVersionSpecifier(), true);
    }

    @Test
    public void hasVersionSpecifier() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setRaw("1.0.0");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasNoVersionSpecifier(), false);
    }

    @Test
    public void hasOnlyMajorReleaseInMatch() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setMatch("1");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasOnlyMajorRelease(), true);
    }

    @Test
    public void hasOnlyMajorReleaseInUpperInclusive() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setUpperBoundInclusive("1");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasOnlyMajorRelease(), true);
    }

    @Test
    public void hasAlsoMinorRelease() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setMatch("1.0");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasOnlyMajorRelease(), false);
    }

    @Test
    public void hasStarInMinorReleaseInMatch() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setMatch("1.*");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasStarInMinorRelease(), true);
    }

    @Test
    public void hasStarInMinorReleaseInUpperInclusive() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setUpperBoundInclusive("1.*");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasStarInMinorRelease(), true);
    }

    @Test
    public void hasNoStarInMinorRelease() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setMatch("1.0");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasStarInMinorRelease(), false);
    }

    @Test
    public void hasNoUpperBoundaryLowerExclusive() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setLowerBoundExclusive("1.0");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasNoUpperBoundary(), true);
    }

    @Test
    public void hasNoUpperBoundaryLowerInclusive() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setLowerBoundInclusive("1.0");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasNoUpperBoundary(), true);
    }

    @Test
    public void hasLowerAndUpperBoundaryInclusive() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setLowerBoundInclusive("1.0");
        versionSpecifier.setUpperBoundInclusive("2.0");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasNoUpperBoundary(), false);
    }

    @Test
    public void hasLowerAndUpperBoundaryExclusive() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setLowerBoundInclusive("1.0");
        versionSpecifier.setUpperBoundExclusive("2.0");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);
        assertEquals(analyzer.hasNoUpperBoundary(), false);
    }

    @Test
    public void analyze() {
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setLowerBoundInclusive("1.*");
        versionSpecifier.setUpperBoundExclusive("2");

        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);

        List<CIAntiPattern> antiPatterns = analyzer.analyze();

        assert antiPatterns.get(0).getSubCategory().equals("only-major-number")
                && antiPatterns.get(1).getSubCategory().equals("any-minor-number");
    }
}