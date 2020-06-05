package ch.uzh.seal.detectors.python.versioning.parsers;

// https://www.python.org/dev/peps/pep-0440/#id53

import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;

public class VersionSpecifierParser {

    /**
     *
     * @param versionSpecifierString The version specifier string consisting of version
     *                               clauses of the format: [op][version-number].
     * @return A VersionSpecifier instance.
     */
    public VersionSpecifier parse(String versionSpecifierString) {
        VersionSpecifier versionSpecifier = new VersionSpecifier();

        versionSpecifier.setRaw(versionSpecifierString);

        String[] versionClauses = versionSpecifierString.split(",");

        for (String clause : versionClauses){

            if (clause.startsWith("==")){
                String match = clause.substring(2);
                versionSpecifier.setMatch(match);
            }
            else if (clause.startsWith("!=")){
                String exclusive = clause.substring(2);
                versionSpecifier.addExclusive(exclusive);
            }
            else if (clause.startsWith(">=")){
                String upperBoundInclusive = clause.substring(2);
                versionSpecifier.setLowerBoundInclusive(upperBoundInclusive);
            }
            else if (clause.startsWith("<=")){
                String lowerBoundInclusive = clause.substring(2);
                versionSpecifier.setUpperBoundInclusive(lowerBoundInclusive);
            }
            else if (clause.startsWith(">")){
                String upperBoundExclusive = clause.substring(1);
                versionSpecifier.setLowerBoundExclusive(upperBoundExclusive);
            }
            else if (clause.startsWith("<")){
                String lowerBoundExclusive = clause.substring(1);
                versionSpecifier.setUpperBoundExclusive(lowerBoundExclusive);
            }
        }

        return versionSpecifier;
    }
}
