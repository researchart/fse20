package ch.uzh.seal.project.writers;

import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.detectors.maven.pom.POM;
import ch.uzh.seal.detectors.maven.pom.POMParser;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

public class ProjectDownloader {

    private String projectsPath;

    public ProjectDownloader(String projectsPath) {
        this.projectsPath = projectsPath;
    }

    private Boolean createFolder(String path) {
        if (!new File(path).isDirectory()) {
            new File(path).mkdirs();
            return true;
        }
        return false;
    }

    private void createFile(String path, String content) {

        if (!content.equals("")) {
            createFolder(new File(path).getParent());

            PrintWriter writer = null;
            try {
                writer = new PrintWriter(path);
            } catch (FileNotFoundException e) {
            }

            if (writer != null) {
                writer.println(content);
                writer.close();
            }
        }
    }

    private void downloadProjectPoms(LintProject project, Path path, Path cachePath) {
        String pomPath = Paths.get(path.toString(), "pom.xml").toString();
        String pomContent = project.getFileContent(pomPath);

        String CachePomPath = Paths.get(cachePath.toString(), "pom.xml").toString();
        createFile(CachePomPath, pomContent);

        POMParser pomParser = new POMParser();

        POM pom = new POM();
        try {
            pom = pomParser.parse(pomContent);
        }
        catch (Exception e) {}

        ArrayList<String> modules = pom.getModules();
        for (String module : modules) {
            Path modulePath = Paths.get(path.toString(), module);
            Path cacheModulePath = Paths.get(cachePath.toString(), module);
            downloadProjectPoms(project, modulePath, cacheModulePath);
        }
    }

    public void downloadProjectFiles(LintProject project) {
        String projectName = project.getName();
        String projectPath = projectsPath+"/"+projectName;

        // only download if folder does not exist
        if (createFolder(projectPath)) {
            String requirementsTXT = project.getFileContent("requirements.txt");
            createFile(projectPath+"/"+"requirements.txt", requirementsTXT);

            String gitlabYAML = project.getFileContent(".gitlab-ci.yml");
            createFile(projectPath+"/"+".gitlab-ci.yml", gitlabYAML);

            downloadProjectPoms(project, Paths.get(""), Paths.get(projectPath));
        }

        project.setLocalPath(projectPath);
    }
}
