package ch.uzh.seal.detectors.python.versioning.parsers;

import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;
import ch.uzh.seal.detectors.python.versioning.entities.Dependency;

import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class DependencyParser {

    /**
     *
     * @param dependencyString The dependency string in the format: [package-name][version-specifier].
     * @return A dependency instance.
     */
    public Dependency parse(String dependencyString){

        String[] parts = new DependencyParser().getParts(dependencyString);

        VersionSpecifier versionSpecifier = new VersionSpecifierParser().parse(parts[1]);

        return new Dependency(parts[0], versionSpecifier);
    }

    /**
     *
     * @param dependencyString The dependency string in the format: [package-name][version-specifier].
     * @return An array [package-name, version-specifier].
     */
     String[] getParts(String dependencyString) {
        String patternString = "(\\S+?)((===|<=|>=|==|<|>|~=|!=).+)?";

        Pattern pattern = Pattern.compile(patternString);
        Matcher matcher = pattern.matcher(dependencyString);

        String name, versionSpecifierString;

        if (matcher.matches()) {
            name = matcher.group(1);

            if (matcher.group(2) != null) {
                versionSpecifierString = matcher.group(2);
            }
            else {
                versionSpecifierString = "";
            }

        }
        else {
            name = "";
            versionSpecifierString = "";
        }

        return new String[] {name, versionSpecifierString};
    }
}
