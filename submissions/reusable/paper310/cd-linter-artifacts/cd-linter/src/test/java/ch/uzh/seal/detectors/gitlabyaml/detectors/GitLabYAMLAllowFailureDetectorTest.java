package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.project.entities.LintProject;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

public class GitLabYAMLAllowFailureDetectorTest {

    private static LintProject project;

    @BeforeClass
    public static void setBeforeClass() throws Exception {
        project = new LintProject();
        project.setRepository("gitlab-org/omnibus-gitlab");
        project.setLocalPath("src/test/resources/gitlabyaml/retryallowfailure");
        
        
    }

    @Ignore
    @Test
    public void test() {
    	GitLabYAMLAllowFailureDetector det = new GitLabYAMLAllowFailureDetector(project);
    	GitLabYAML gitLabYAML = det.getGitLabYAML(project);
    	Map<String, Job> jobs = gitLabYAML.getJobs();
    	
    	
    	System.out.println("here");
    	for(String name: jobs.keySet()) {
    		System.out.println(name);
    	}
    	
    }
    
    @Ignore
    @Test
    public void lint() throws Exception {
        List<CIAntiPattern> antiPatterns = new GitLabYAMLAllowFailureDetector(project).lint();
        
        System.out.println("Size: " + antiPatterns.size());
        
        for(CIAntiPattern ap: antiPatterns) {
        	System.out.println(ap.getId());
        }
        
        Boolean oracle = antiPatterns.size() == 1
                && antiPatterns.get(0).getProject().equals(project.getName())
                && antiPatterns.get(0).getEntity().equals("test")
                && antiPatterns.get(0).getCategory().equals("Job-Allow-Failure")
                ;

        assertEquals(oracle, true);
    }
    
    @Ignore
    @Test
    public void lint2() throws Exception {
        List<CIAntiPattern> antiPatterns = new GitLabYAMLRetryDetector(project).lint();
        
        System.out.println("Size: " + antiPatterns.size());
        
        for(CIAntiPattern ap: antiPatterns) {
        	System.out.println(ap.getId());
        }
        
        Boolean oracle = antiPatterns.size() == 1
                && antiPatterns.get(0).getProject().equals(project.getName())
                && antiPatterns.get(0).getEntity().equals("test")
                && antiPatterns.get(0).getCategory().equals("Job-Allow-Failure")
                ;

        assertEquals(oracle, true);
    }
    
    
    
    @Ignore
    @Test
    public void checkLineNumber() throws Exception {
    	  List<CIAntiPattern> antiPatterns = new GitLabYAMLAllowFailureDetector(project).lint();
    	  String lineNumber = antiPatterns.get(0).getLineNumber();
    	  
    	  assertEquals("20", lineNumber);
    }
}