package ch.uzh.seal.detectors.python.versioning.parsers;

import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;
import org.junit.Test;
import static org.junit.Assert.*;

public class VersionSpecifierParserTest {

    @Test
    public void parseSingleMatchClause() {
        String versionSpecifierString = "==1.0.0";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw("==1.0.0");
        expectedVersionSpecifier.setMatch("1.0.0");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

    @Test
    public void parseSingleUpperBoundInclusiveClause(){
        String versionSpecifierString = "<=1.0.0";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw("<=1.0.0");
        expectedVersionSpecifier.setUpperBoundInclusive("1.0.0");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

    @Test
    public void parseSingleLowerBoundInclusiveClause(){
        String versionSpecifierString = ">=1.0.0";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw(">=1.0.0");
        expectedVersionSpecifier.setLowerBoundInclusive("1.0.0");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

    @Test
    public void parseSingleLowerBoundExclusiveClause(){
        String versionSpecifierString = ">1.0.0";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw(">1.0.0");
        expectedVersionSpecifier.setLowerBoundExclusive("1.0.0");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

    @Test
    public void parseTwoExclusives(){
        String versionSpecifierString = "!=1.0.0,!=2.0.0";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw("!=1.0.0,!=2.0.0");
        expectedVersionSpecifier.addExclusive("1.0.0");
        expectedVersionSpecifier.addExclusive("2.0.0");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

    @Test
    public void parseLowerBoundExclusiveClauseAndUpperBoundExclusive(){
        String versionSpecifierString = ">1.0.0,<2.0.0";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw(">1.0.0,<2.0.0");
        expectedVersionSpecifier.setLowerBoundExclusive("1.0.0");
        expectedVersionSpecifier.setUpperBoundExclusive("2.0.0");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

    @Test
    public void parseEmpty(){
        String versionSpecifierString = "";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw("");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

    @Test
    public void parseLowerBoundInclusiveClauseAndUpperBoundInclusiveAndExclusiveAndCompatible(){
        String versionSpecifierString = ">=1.0.0,!=1.5.0,~=1.7.0,<=2.0.0";
        VersionSpecifier actualVersionSpecifier = new VersionSpecifierParser().parse(versionSpecifierString);
        VersionSpecifier expectedVersionSpecifier = new VersionSpecifier();
        expectedVersionSpecifier.setRaw(">=1.0.0,!=1.5.0,~=1.7.0,<=2.0.0");
        expectedVersionSpecifier.setLowerBoundInclusive("1.0.0");
        expectedVersionSpecifier.setUpperBoundInclusive("2.0.0");
        expectedVersionSpecifier.addExclusive("1.5.0");

        assertEquals(expectedVersionSpecifier, actualVersionSpecifier);
    }

}
