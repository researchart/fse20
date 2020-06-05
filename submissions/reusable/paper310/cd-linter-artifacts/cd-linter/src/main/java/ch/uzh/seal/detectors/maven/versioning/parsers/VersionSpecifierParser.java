package ch.uzh.seal.detectors.maven.versioning.parsers;

import ch.uzh.seal.detectors.maven.versioning.entities.VersionSpecifier;

public class VersionSpecifierParser {

    public VersionSpecifier parse(String versionSpecifierString) {
        VersionSpecifier versionSpecifier = new VersionSpecifier();

        versionSpecifier.setRaw(versionSpecifierString);

        if (versionSpecifierString.equals(""))
            return versionSpecifier;

        String[] versionClauses = versionSpecifierString.split("(?<!\\d),(?!\\d)");

        for (String clause : versionClauses){

            // soft requirement, e.g. 1.0
            if (clause.matches("^[^()\\[\\]]+$")){
                versionSpecifier.setMatch(clause);
            }
            // hard requirement, e.g. [1.0]
            else if (clause.matches("\\[[^,]+]")){
                String match = clause.substring(1, clause.length()-1);
                versionSpecifier.setMatch(match);
            }
            // greater and smaller than version specifiers
            else {
                String[] nums = clause.split(",");
                String low = nums[0];
                String high = nums[1];

                String lowOp = low.substring(0, 1);
                String lowNum = low.substring(1);

                String highOp = high.substring(high.length()-1);
                String highNum = high.substring(0, high.length()-1);

                if (!lowNum.equals("")) {
                    if (lowOp.equals("["))
                        versionSpecifier.setLowerBoundInclusive(lowNum);
                    else
                        versionSpecifier.setLowerBoundExclusive(lowNum);
                }

                if (!highNum.equals("")) {
                    if (highOp.equals("]"))
                        versionSpecifier.setUpperBoundInclusive(highNum);
                    else
                        versionSpecifier.setUpperBoundExclusive(highNum);
                }
            }
        }

        return versionSpecifier;
    }
}
