package ch.uzh.seal.detectors.maven.versioning.entities;

import org.junit.Test;
import static org.junit.Assert.*;

public class VersionSpecifierTest {

    @Test
    public void equalsMatch(){
        VersionSpecifier versionSpecifier1 = new VersionSpecifier();
        versionSpecifier1.setMatch("1.0.0");

        VersionSpecifier versionSpecifier2 = new VersionSpecifier();
        versionSpecifier2.setMatch("1.0.0");

        assertEquals(versionSpecifier1, versionSpecifier2);
    }
}
