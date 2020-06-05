package ch.uzh.seal.detectors.maven.versioning.entities;

import java.util.ArrayList;
import java.util.Objects;

public class VersionSpecifier {

    private String raw;

    private String lowerBoundExclusive;

    private String lowerBoundInclusive;

    private String upperBoundExclusive;

    private String upperBoundInclusive;

    private String match;

    private ArrayList<String> exclusives = new ArrayList<>();

    public String getRaw() {
        return raw;
    }

    public void setRaw(String raw) {
        this.raw = raw;
    }

    public String getLowerBoundExclusive() {
        return lowerBoundExclusive;
    }

    public void setLowerBoundExclusive(String lowerBoundExclusive) {
        this.lowerBoundExclusive = lowerBoundExclusive;
    }

    public String getLowerBoundInclusive() {
        return lowerBoundInclusive;
    }

    public void setLowerBoundInclusive(String lowerBoundInclusive) {
        this.lowerBoundInclusive = lowerBoundInclusive;
    }

    public String getUpperBoundExclusive() {
        return upperBoundExclusive;
    }

    public void setUpperBoundExclusive(String upperBoundExclusive) {
        this.upperBoundExclusive = upperBoundExclusive;
    }

    public String getUpperBoundInclusive() {
        return upperBoundInclusive;
    }

    public void setUpperBoundInclusive(String upperBoundInclusive) {
        this.upperBoundInclusive = upperBoundInclusive;
    }

    public String getMatch() {
        return match;
    }

    public void setMatch(String match) {
        this.match = match;
    }

    public ArrayList<String> getExclusives() {
        return exclusives;
    }

    public void addExclusive(String exclusive) {
        exclusives.add(exclusive);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        VersionSpecifier that = (VersionSpecifier) o;
        return Objects.equals(raw, that.raw) &&
                Objects.equals(lowerBoundExclusive, that.lowerBoundExclusive) &&
                Objects.equals(lowerBoundInclusive, that.lowerBoundInclusive) &&
                Objects.equals(upperBoundExclusive, that.upperBoundExclusive) &&
                Objects.equals(upperBoundInclusive, that.upperBoundInclusive) &&
                Objects.equals(match, that.match) &&
                Objects.equals(exclusives, that.exclusives);
    }

    @Override
    public int hashCode() {
        return Objects.hash(raw, lowerBoundExclusive, lowerBoundInclusive, upperBoundExclusive, upperBoundInclusive, match, exclusives);
    }

    @Override
    public String toString() {
        return raw;
    }
}
