package ch.uzh.seal.detectors.maven.pom;

import ch.uzh.seal.detectors.maven.versioning.entities.Dependency;
import ch.uzh.seal.detectors.maven.versioning.entities.VersionSpecifier;
import org.junit.BeforeClass;
import org.junit.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;

import static org.junit.Assert.*;

public class POMParserTest {

    private static POM pom;

    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        String pomPath = "src/test/resources/maven/versioning/example1/pom.xml";
        byte[] encoded = Files.readAllBytes(Paths.get(pomPath));
        String content = new String(encoded, StandardCharsets.UTF_8);
        POMParser pomParser = new POMParser();
        pom = pomParser.parse(content);
    }

    @Test
    public void modulesSet() {
        ArrayList<String> modulesActual = pom.getModules();

        ArrayList<String> modulesExpected = new ArrayList<>();
        modulesExpected.add("core");
        modulesExpected.add("metrics");

        assertEquals(modulesExpected, modulesActual);
    }

    @Test
    public void propertiesSet() {

        HashMap<String,String> propertiesActual = pom.getProperties();

        HashMap<String, String> propertiesExpected = new HashMap<>();
        propertiesExpected.put("maven.compiler.source", "1.8");
        propertiesExpected.put("junit.version", "4.4");

        assertEquals(propertiesExpected, propertiesActual);
    }

    @Test
    public void dependenciesSet() {
        ArrayList<Dependency> actualDependencies = pom.getDependencies();

        String name1 = "com.google.code.gson/gson";
        VersionSpecifier versionSpecifier1 = new VersionSpecifier();
        versionSpecifier1.setRaw("2.8.2");
        versionSpecifier1.setMatch("2.8.2");

        String name2 = "junit/junit";
        VersionSpecifier versionSpecifier2 = new VersionSpecifier();
        versionSpecifier2.setRaw("4.4");
        versionSpecifier2.setMatch("4.4");

        ArrayList<Dependency> expectedDependencies = new ArrayList<>();
        Dependency dep1 = new Dependency(name1, versionSpecifier1);
        expectedDependencies.add(dep1);
        Dependency dep2 = new Dependency(name2, versionSpecifier2);
        expectedDependencies.add(dep2);

        assertEquals(expectedDependencies, actualDependencies);
    }
}