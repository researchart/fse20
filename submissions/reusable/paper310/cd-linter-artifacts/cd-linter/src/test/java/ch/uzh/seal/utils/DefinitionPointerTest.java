package ch.uzh.seal.utils;

import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.parsers.GitLabYAMLParser;
import ch.uzh.seal.project.entities.LintProject;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

public class DefinitionPointerTest {

    @Test
    public void getPointers() {
        LintProject project = new LintProject();
        project.setLocalPath("src/test/resources/gitlabyaml/merge_key");
        String content = project.getFileContent(".gitlab-ci.yml");
        GitLabYAMLParser gitLabYAMLParser = new GitLabYAMLParser();
        GitLabYAML gitLabYAML = gitLabYAMLParser.parse(content);

        DefinitionPointer pointer = new DefinitionPointer(gitLabYAML);
        Map<String, List<String>> pointers = pointer.getPointers();

        assert pointers.get("test:postgres").equals(List.of(".job_template", ".job_template2")) &&
                pointers.get("test:mysql").equals(List.of(".job_template"));
    }
}