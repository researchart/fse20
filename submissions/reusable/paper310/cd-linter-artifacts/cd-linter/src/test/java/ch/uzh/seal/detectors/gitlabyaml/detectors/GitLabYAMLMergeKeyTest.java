package ch.uzh.seal.detectors.gitlabyaml.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.project.linters.ProjectLinter;
import org.junit.BeforeClass;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.assertEquals;

public class GitLabYAMLMergeKeyTest {

    @Test
    public void lint() throws Exception {
        LintProject project = new LintProject();
        project.setLocalPath("src/test/resources/gitlabyaml/merge_key");
        project.setLanguage("blu");
        List<CIAntiPattern> antiPatterns = ProjectLinter.getCIAntiPatterns(project);
        Boolean oracle = antiPatterns.size() == 4
                && antiPatterns.get(0).getEntity().equals("test:postgres")
                && antiPatterns.get(0).getCategory().equals("Job-Allow-Failure")
                && antiPatterns.get(0).getLineNumber().equals("4")
                && antiPatterns.get(1).getEntity().equals("test:sqlite")
                && antiPatterns.get(1).getCategory().equals("Job-Allow-Failure")
                && antiPatterns.get(1).getLineNumber().equals("32")
                && antiPatterns.get(2).getEntity().equals("test:postgres")
                && antiPatterns.get(2).getCategory().equals("Job-Retry")
                && antiPatterns.get(2).getLineNumber().equals("1")
                && antiPatterns.get(3).getEntity().equals("test:postgres")
                && antiPatterns.get(3).getCategory().equals("Manual-Job")
                && antiPatterns.get(3).getLineNumber().equals("4")
                ;

        assertEquals(true, oracle);
    }
}