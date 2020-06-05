package ch.uzh.seal.detectors.python.versioning.parsers;

import ch.uzh.seal.detectors.python.versioning.entities.Dependency;
import ch.uzh.seal.detectors.python.versioning.entities.RequirementsTXT;

import java.io.*;
import java.util.Scanner;

public class RequirementsTXTParser {

    /**
     * Parse the content of a requirements.txt file.
     * @param content The content of a requirements.txt file.
     * @return The requirementsTXT instance.
     */
    public RequirementsTXT parse(String content) throws IOException {
        RequirementsTXT requirementsTXT = new RequirementsTXT();
        BufferedReader reader = new BufferedReader(new StringReader(content));

        String line;
        while((line = reader.readLine()) != null ){

            line = removeRedundantWhitespaces(line);

            if (isDependencyLine(line)) {
                Dependency dependency = new DependencyParser().parse(line);
                requirementsTXT.addDependency(dependency);
            }
        }

        return requirementsTXT;
    }

    /**
     * Parse the requirements.txt file.
     * @param filePath Path of the requirements.txt file.
     * @return A requirmentsTXT instance.
     * @throws FileNotFoundException
     */
    public RequirementsTXT parseFromPath(String filePath) throws FileNotFoundException {

        RequirementsTXT requirementsTXT = new RequirementsTXT();
        File file = new File(filePath);
        Scanner scanner = new Scanner(file);

        while (scanner.hasNextLine()){

            String line = scanner.nextLine();

            line = removeRedundantWhitespaces(line);

            if (isDependencyLine(line)) {
                Dependency dependency = new DependencyParser().parse(line);
                requirementsTXT.addDependency(dependency);
            }
        }

        return requirementsTXT;
    }

    public Boolean isDependencyLine(String line){
        // ignore comments and empty lines
        return !line.startsWith("#") && !line.equals("");
    }

    public String removeRedundantWhitespaces(String line) {
        line = line.replaceAll("\\s+", "");
        line = line.strip();

        return line;
    }
}
