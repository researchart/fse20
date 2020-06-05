package ch.uzh.seal.detectors.gitlabyaml.parsers;

import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.detectors.gitlabyaml.entities.RetryWhen;
import org.junit.BeforeClass;
import org.junit.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

public class GitLabYAMLParserTest {

    private static GitLabYAML yaml;

    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        String pomPath = "src/test/resources/gitlabyaml/retryallowfailure/.gitlab-ci2.yml";
        byte[] encoded = Files.readAllBytes(Paths.get(pomPath));
        String content = new String(encoded, StandardCharsets.UTF_8);
        GitLabYAMLParser parser = new GitLabYAMLParser();
        yaml = parser.parse(content);
    }
    
    @Test
    public void testIncludeStatements() {
    	ArrayList<String> include = yaml.getInclude();
    	
    	ArrayList<String> expected = new ArrayList<>();
    	expected.add("/templates/.gitlab-ci-template.yml");
    	expected.add("hello");
    	expected.add("halo");
    	
    	assertEquals(3, include.size());
    	assertEquals(expected, include);
    }
    

    @Test
    public void cleanCompileSet() {
        Map<String, Job> jobs = yaml.getJobs();
        Job job = jobs.get("clean-compile");

        Boolean oracle = job.getStage().equals("build")
                && job.getBefore_script().equals(List.of("mvn clean"))
                && job.getScript().equals(List.of("git checkout master", "mvn compile"))
                && !job.getAllow_failure()
                && job.getRetry().getMax() == 1
                && job.getRetry().getWhen().equals(RetryWhen.always);

        assertEquals(oracle, true);
    }

    
    @Test
    public void extractStagesTest() {
    	List<String> stages = yaml.getStages();
    	
    	List<String> oracle = new ArrayList<>();
    	oracle.add("build");
    	oracle.add("test");
    	
    	assertEquals(oracle, stages);
    }
    
    

    @Test
    public void testSet() {
        Map<String, Job> jobs = yaml.getJobs();
        Job job = jobs.get("test");

        Boolean oracle = job.getStage().equals("test")
                && job.getBefore_script().equals(List.of())
                && job.getScript().equals(List.of("mvn test"))
                && job.getAllow_failure()
                && job.getRetry().getMax() == 0
                && job.getRetry().getWhen().equals(RetryWhen.always);

        assertEquals(oracle, true);
    }

    @Test
    public void verifySet() {
        Map<String, Job> jobs = yaml.getJobs();
        Job job = jobs.get("verify");

        Boolean oracle = job.getStage().equals("test")
                && job.getBefore_script().equals(List.of())
                && job.getScript().equals(List.of("mvn verify"))
                && !job.getAllow_failure()
                && job.getRetry().getMax() == 2
                && job.getRetry().getWhen().equals(RetryWhen.stuck_or_timeout_failure);

        assertEquals(oracle, true);
    }

    @Test
    public void emptyParse() {
        GitLabYAMLParser parser = new GitLabYAMLParser();
        GitLabYAML yml = parser.parse("");

        assert yml.getJobs().size() == 0;
    }

    @Test
    public void testOnly() throws Exception{
        String pomPath = "src/test/resources/gitlabyaml/only/.gitlab-ci.yml";
        byte[] encoded = Files.readAllBytes(Paths.get(pomPath));
        String content = new String(encoded, StandardCharsets.UTF_8);
        GitLabYAMLParser parser = new GitLabYAMLParser();
        GitLabYAML onlyYaml = parser.parse(content);
    }

    @Test
    public void testExcept() throws Exception{
        String pomPath = "src/test/resources/gitlabyaml/except/.gitlab-ci.yml";
        byte[] encoded = Files.readAllBytes(Paths.get(pomPath));
        String content = new String(encoded, StandardCharsets.UTF_8);
        GitLabYAMLParser parser = new GitLabYAMLParser();
        GitLabYAML exceptYaml = parser.parse(content);
    }

}