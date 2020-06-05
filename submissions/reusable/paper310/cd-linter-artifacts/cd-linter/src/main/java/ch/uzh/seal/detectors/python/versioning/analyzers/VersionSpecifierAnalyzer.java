package ch.uzh.seal.detectors.python.versioning.analyzers;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class VersionSpecifierAnalyzer {

    private String raw;
    private String match;
    private String lowerInclusive;
    private String lowerExclusive;
    private String upperInclusive;
    private String upperExclusive;

    public VersionSpecifierAnalyzer(VersionSpecifier versionSpecifier) {
        match = versionSpecifier.getMatch();
        raw = versionSpecifier.getRaw();
        lowerInclusive = versionSpecifier.getLowerBoundInclusive();
        lowerExclusive = versionSpecifier.getLowerBoundExclusive();
        upperInclusive = versionSpecifier.getUpperBoundInclusive();
        upperExclusive = versionSpecifier.getUpperBoundExclusive();
    }

    public Boolean hasNoVersionSpecifier(){
        return raw != null && raw.equals("");
    }

    public Boolean hasOnlyMajorRelease() {
        for (String num : Arrays.asList(match, lowerInclusive, lowerExclusive, upperInclusive, upperExclusive)) {
            if (num != null && num.matches("^\\d+$"))
                return true;
        }

        return false;
    }

    public Boolean hasStarInMinorRelease() {
        for (String num : Arrays.asList(match, lowerInclusive, lowerExclusive, upperInclusive, upperExclusive)) {
            if (num != null && num.matches("^\\d+\\.\\*$"))
                return true;
        }

        return false;
    }

    public Boolean hasNoUpperBoundary() {
        if (lowerInclusive != null || lowerExclusive != null) {
            if (upperInclusive == null && upperExclusive == null) {
                return true;
            }
        }

        return false;
    }

    public List<CIAntiPattern> analyze() {

        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        if (hasNoVersionSpecifier()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setSubCategory("missing");
            antiPattern.setMessage("version specifier is missing");
            antiPatterns.add(antiPattern);
        }

        if (hasOnlyMajorRelease()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setSubCategory("only-major-number");
            antiPattern.setMessage("version specifier `"+raw+"` only refers to a major release, concrete minor versions might be incompatible");
            antiPatterns.add(antiPattern);
        }

        if (hasStarInMinorRelease()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setSubCategory("any-minor-number");
            antiPattern.setMessage("version specifier `"+raw+"` matches any minor release, even future versions that might become incompatible");
            antiPatterns.add(antiPattern);
        }

        if (hasNoUpperBoundary()) {
            CIAntiPattern antiPattern = new CIAntiPattern();
            antiPattern.setSubCategory("any-upper-version");
            antiPattern.setMessage("version specifier `"+raw+"` matches future versions that might become incompatible");
            antiPatterns.add(antiPattern);
        }

        return antiPatterns;
    }
}
