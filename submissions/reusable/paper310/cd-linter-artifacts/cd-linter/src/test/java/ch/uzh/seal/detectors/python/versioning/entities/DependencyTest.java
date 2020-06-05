package ch.uzh.seal.detectors.python.versioning.entities;

import org.junit.Test;

import static org.junit.Assert.*;

public class DependencyTest {

    @Test
    public void equals() {
        String name = "Package1";
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setMatch("1.0.0");
        Dependency dependency1 = new Dependency(name, versionSpecifier);
        Dependency dependency2 = new Dependency(name, versionSpecifier);

        assertEquals(dependency1, dependency2);

    }
}