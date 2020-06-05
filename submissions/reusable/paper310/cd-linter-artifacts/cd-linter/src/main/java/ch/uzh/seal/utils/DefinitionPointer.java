package ch.uzh.seal.utils;

import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


/**
 * Extract pointers where jobs are pointing to other job definitions (Merge key).
 */
public class DefinitionPointer {

    private GitLabYAML gitLabYAML;

    public DefinitionPointer(GitLabYAML gitLabYAML) {
        this.gitLabYAML = gitLabYAML;
    }

    public Map<String, List<String>> getPointers() {
        Map<String, List<String>> pointers = new HashMap<>();

        String content = gitLabYAML.getRaw();

        Pattern pattern1 = Pattern.compile("^([^\\s#].*):");
        Pattern pattern2 = Pattern.compile("\\s+<<: \\*(.*)");
        Pattern pattern3 = Pattern.compile(".*: ?&(.*)");
        Map<String, String> defName2JobName = new HashMap<>();

        String currentJob = null;
        for (String line : content.split("\n")) {
            Matcher matcher1 = pattern1.matcher(line);
            Matcher matcher2 = pattern2.matcher(line);
            if (matcher1.find())
            {
                currentJob = matcher1.group(1);

                Matcher matcher3 = pattern3.matcher(line);
                if (matcher3.find()) {
                    String def = matcher3.group(1);
                    defName2JobName.put(def, currentJob);
                }
            }
            else if (matcher2.find()) {
                String jobDefinition = matcher2.group(1);

                if (!pointers.containsKey(currentJob)) {
                    List<String> defs = new ArrayList<>();
                    pointers.put(currentJob, defs);
                }
                String defJob = defName2JobName.get(jobDefinition);
                pointers.get(currentJob).add(defJob);
            }
        }
        return pointers;
    }
}
