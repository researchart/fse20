package ch.uzh.seal.detectors.python.versioning.parsers;

import ch.uzh.seal.detectors.python.versioning.entities.Dependency;
import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;

import org.junit.Test;

import static org.junit.Assert.*;

public class DependencyParserTest {


    @Test
    public void getPartsMatch() {
        String dependencyString = "package-name==1.0.0";
        String[] actual = new DependencyParser().getParts(dependencyString);
        String[] expected = {"package-name", "==1.0.0"};

        assertArrayEquals(expected, actual);
    }

    @Test
    public void getPartsEmpty() {
        String dependencyString = "package-name";
        String[] actual = new DependencyParser().getParts(dependencyString);
        String[] expected = {"package-name", ""};

        assertArrayEquals(expected, actual);
    }

    @Test
    public void getPartsUpperBoundExclusive() {
        String dependencyString = "package-name<1.0.0";
        String[] actual = new DependencyParser().getParts(dependencyString);
        String[] expected = {"package-name", "<1.0.0"};

        assertArrayEquals(expected, actual);
    }

    @Test
    public void parseMatch() {
        String dependencyString = "package-name==1.0.0";
        Dependency actualDependency = new DependencyParser().parse(dependencyString);

        String name = "package-name";
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setRaw("==1.0.0");
        versionSpecifier.setMatch("1.0.0");
        Dependency expectedDependency = new Dependency(name, versionSpecifier);

        assertEquals(expectedDependency, actualDependency);
    }

    @Test
    public void parseEmpty() {
        String dependencyString = "package-name";
        Dependency actualDependency = new DependencyParser().parse(dependencyString);

        String name = "package-name";
        VersionSpecifier versionSpecifier = new VersionSpecifier();
        versionSpecifier.setRaw("");
        Dependency expectedDependency = new Dependency(name, versionSpecifier);

        assertEquals(expectedDependency, actualDependency);
    }

}