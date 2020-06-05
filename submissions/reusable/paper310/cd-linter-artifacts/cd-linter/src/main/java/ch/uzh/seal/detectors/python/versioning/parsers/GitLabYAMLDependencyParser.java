package ch.uzh.seal.detectors.python.versioning.parsers;

import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.detectors.gitlabyaml.parsers.GitLabYAMLParser;
import ch.uzh.seal.detectors.python.versioning.entities.Dependency;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GitLabYAMLDependencyParser {

    public List<Dependency> parse(String YAMLContent) {
        List<Dependency> dependencies = new ArrayList<>();

        GitLabYAMLParser parser = new GitLabYAMLParser();
        GitLabYAML gitLabYAML = parser.parse(YAMLContent);

        Map<String, Job> jobs = gitLabYAML.getJobs();

        for (String jobName : jobs.keySet()) {
            Job job = jobs.get(jobName);

            dependencies.addAll(getDependencies(job.getBefore_script()));
            dependencies.addAll(getDependencies(job.getScript()));
            dependencies.addAll(getDependencies(job.getAfter_script()));
        }

        return dependencies;
    }

    private List<Dependency> getDependencies(List<String> script) {
        List<Dependency> dependencies = new ArrayList<>();

        String patternPip = ".*pip install(.*)";
        retrieveDependencies(dependencies,script,patternPip);
        
        String patternPipThree = ".*pip3 install(.*)";
        retrieveDependencies(dependencies,script,patternPipThree);

        return dependencies;
    }
    
    public void retrieveDependencies(List<Dependency> dependencies, List<String> script, String patternString){
    	
    	Pattern pattern = Pattern.compile(patternString);

        for (String line : script) {

            Matcher matcher = pattern.matcher(line);

            if (matcher.matches()) {
                String dependencyPart = matcher.group(1).strip();
                // dependencies are in a file
                if (!dependencyPart.contains("-r")) {

                    dependencyPart = removeOptions(dependencyPart);

                    String[] dependencyStrings = dependencyPart.split(" ");
                    for (String dependencyString : dependencyStrings) {

                        dependencyString = removeQuotes(dependencyString);

                        // ignore paths and archives
                        if (!isPath(dependencyString) && !isArchive(dependencyString)) {
                            Dependency dependency = new DependencyParser().parse(dependencyString);
                            dependencies.add(dependency);
                        }
                    }
                }
            }
        }
    	
    }

    public String removeOptions(String dependency) {
        // remove options
        dependency = dependency.replaceAll("--?\\S+", "");
        // remove redundanct whitespaces
        dependency = dependency.replaceAll("\\s+", " ");
        // strip leading/trailing whitespaces
        dependency = dependency.strip();

        return dependency;
    }

    public String removeQuotes(String dependency) {
        return dependency.replace("\"", "");
    }

    public Boolean isArchive(String dependency) {
        return dependency.endsWith(".zip")
                || dependency.endsWith(".tar")
                || dependency.endsWith(".gz")
                || dependency.endsWith(".bz2");
    }

    public Boolean isPath(String dependency) {
        return dependency.contains("/")
                || dependency.matches("\\.{1,2}(\\[.*])?");
    }
}
