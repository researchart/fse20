package ch.uzh.seal.detectors.python.versioning.parsers;

import ch.uzh.seal.detectors.python.versioning.entities.Dependency;
import ch.uzh.seal.detectors.python.versioning.entities.RequirementsTXT;
import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;
import org.junit.Test;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

import static org.junit.Assert.*;

public class RequirementsTXTParserTest {

    @Test
    public void parseFromPath() throws FileNotFoundException {
        String requirementsTXTPath = "src/test/resources/python/parsers/requirementstxt/requirements.txt";
        RequirementsTXT requirementsTXT = new RequirementsTXTParser().parseFromPath(requirementsTXTPath);
        ArrayList<Dependency> actualDependencies = requirementsTXT.getDependencies();

        String name1 = "Package1";
        String name2 = "Package2";

        VersionSpecifier versionSpecifier1 = new VersionSpecifier();
        versionSpecifier1.setRaw("");
        VersionSpecifier versionSpecifier2 = new VersionSpecifier();
        versionSpecifier2.setRaw("==1.0.0");
        versionSpecifier2.setMatch("1.0.0");

        Dependency dependency1 = new Dependency(name1, versionSpecifier1);
        Dependency dependency2 = new Dependency(name2, versionSpecifier2);
        ArrayList<Dependency> expectedDependencies = new ArrayList<>();
        expectedDependencies.add(dependency1);
        expectedDependencies.add(dependency2);

        assertEquals(expectedDependencies, actualDependencies);
    }

    @Test
    public void parse() throws IOException {
        String requirementsTXTContent = "Package1\nPackage2==1.0.0\n";
        RequirementsTXT requirementsTXT = new RequirementsTXTParser().parse(requirementsTXTContent);

        ArrayList<Dependency> actualDependencies = requirementsTXT.getDependencies();

        String name1 = "Package1";
        String name2 = "Package2";

        VersionSpecifier versionSpecifier1 = new VersionSpecifier();
        versionSpecifier1.setRaw("");
        VersionSpecifier versionSpecifier2 = new VersionSpecifier();
        versionSpecifier2.setRaw("==1.0.0");
        versionSpecifier2.setMatch("1.0.0");

        Dependency dependency1 = new Dependency(name1, versionSpecifier1);
        Dependency dependency2 = new Dependency(name2, versionSpecifier2);
        ArrayList<Dependency> expectedDependencies = new ArrayList<>();
        expectedDependencies.add(dependency1);
        expectedDependencies.add(dependency2);

        assertEquals(expectedDependencies, actualDependencies);
    }
}