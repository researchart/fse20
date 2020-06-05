package ch.uzh.seal.detectors.maven.versioning;

import ch.uzh.seal.detectors.Detector;
import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.detectors.maven.pom.POM;
import ch.uzh.seal.detectors.maven.pom.POMParser;
import ch.uzh.seal.detectors.maven.versioning.analyzers.VersionSpecifierAnalyzer;
import ch.uzh.seal.detectors.maven.versioning.entities.Dependency;
import ch.uzh.seal.detectors.maven.versioning.entities.VersionSpecifier;
import ch.uzh.seal.utils.LineNumberExtractor;
import ch.uzh.seal.utils.LineNumberPathConstructor;


import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MavenVersionAntiPatternDetector extends Detector {

    private String category = "Versioning";

    public MavenVersionAntiPatternDetector(LintProject project) {
        super(project);
    }

    private String getHashKey(String groupId, String artifactId, String version) {
        return groupId+":"+artifactId+":"+version;
    }

    private String getHashKey(POM pom) {
        return getHashKey(pom.getGroupId(), pom.getArtifactId(), pom.getVersion());
    }

    public Map<String, POM> getPOMs(LintProject project) throws Exception {
        Map<String, POM> poms = new HashMap<>();
        collectPOMs(null, project, Paths.get(""), poms);
        return poms;
    }

    private void collectPOMs(POM parent, LintProject project, Path path, Map<String, POM> poms) throws Exception{
        String pomPath = Paths.get(path.toString(), "pom.xml").toString();
        String pomContent = project.getFileContent(pomPath);
        POMParser pomParser = new POMParser();
        POM pom = pomParser.parse(pomContent);
        pom.setPath(pomPath);
        // inherit group ID from parent
        if (pom.getGroupId().equals("")) {
            pom.setGroupId(parent.getGroupId());
        }
        String key = getHashKey(pom);
        poms.put(key, pom);

        ArrayList<String> modules = pom.getModules();
        for (String module : modules) {
            Path modulePath = Paths.get(path.toString(), module);
            collectPOMs(pom, project, modulePath, poms);
        }
    }

    private void connectPOMs(Map<String, POM> poms) {
        for (String pomKey : poms.keySet()) {
            POM pom = poms.get(pomKey);
            if (pom.hasParent()) {
                POM parentPOM = pom.getParent();
                String parentPOMkey = getHashKey(parentPOM);
                if (poms.containsKey(parentPOMkey)) {
                    POM newParentPOM = poms.get(parentPOMkey);
                    pom.setParent(newParentPOM);
                }
            }
        }
    }

    private List<CIAntiPattern> analyzeDependency(Dependency dep) {
        String name = dep.getName();
        VersionSpecifier versionSpecifier = dep.getVersionSpecifier();
        VersionSpecifierAnalyzer analyzer = new VersionSpecifierAnalyzer(versionSpecifier);

        List<CIAntiPattern> antiPatterns = analyzer.analyze();

        for (CIAntiPattern antiPattern : antiPatterns){
            antiPattern.setEntity(name);
        }

        return antiPatterns;
    }

    public List<CIAntiPattern> lint() throws Exception {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        String projectName = project.getName();
        String remoteRepoPath = project.getRemotePath();

        Map<String, POM> poms = getPOMs(project);
        connectPOMs(poms);

        for (String pomName : poms.keySet()) {
            POM pom = poms.get(pomName);

            String cfgFileName = pom.getPath();
            String remoteCfgLink = project.getFullRemotePath(cfgFileName, true);
            String localCfgLink = project.getFullLocalPath(cfgFileName);
            LineNumberExtractor lineNumberExtractor = new LineNumberExtractor(pom.getRaw());

            for (Dependency dep : pom.getDependencies()) {

                if (inBlackList(dep.getArtifactID())) {
                    continue;
                }

                List<CIAntiPattern> depAntiPatterns = analyzeDependency(dep);

                // use artifact ID for searching but point to start of dependency node (-2)
                String search = "<artifactId>"+dep.getArtifactID()+"</artifactId>";
                int lineNumberInt = Integer.parseInt(lineNumberExtractor.getLineNumber(search));

                if (lineNumberInt == -1) {
                    search = dep.getArtifactID();
                    lineNumberInt = Integer.parseInt(lineNumberExtractor.getLineNumber(search));
                }

                lineNumberInt -= 2;

                String lineNumber = Integer.toString(lineNumberInt);
                //String lineNumberPath = LineNumberPathConstructor.getPath(remoteCfgLink, lineNumber);

                if (dep.getGroupID().startsWith("org.springframework")) {
                    return new ArrayList<>();
                }

                for (CIAntiPattern depAntiPattern : depAntiPatterns) {
                    depAntiPattern.setId(
                            generateID(
                                    projectName,
                                    pomName,
                                    depAntiPattern.getEntity(),
                                    depAntiPattern.getSubCategory()));
                    depAntiPattern.setProject(projectName);
                    depAntiPattern.setRemoteRepoLink(remoteRepoPath);
                    depAntiPattern.setRemoteCfgLink(remoteCfgLink);
                    depAntiPattern.setLocalCfgLink(localCfgLink);
                    depAntiPattern.setEntity(depAntiPattern.getEntity());
                    depAntiPattern.setCategory(category);
                    depAntiPattern.setLineNumber(lineNumber);
                    depAntiPattern.setCfgFileName(cfgFileName);
                    antiPatterns.add(depAntiPattern);
                }
            }
        }

        return antiPatterns;
    }

    public String generateID(String projectName, String pomName, String depName, String subcategory) {
        return removeIllegalCharsInID(projectName + "__" + category + "__" + pomName + "__" + depName + "__" + subcategory);
    }

    private Boolean inBlackList(String dep) {
        List<String> deps = List.of(
                "pycodestyle",
                "flake8",
                "tox",
                "nose",
                "pylint",
                "pytest",
                "coverage",
                "setuptools",
                "pip",
                "pipenv",
                "ipython",
                "codecov",
                "junit",
                "mypy",
                "pytest-cov",
                "ipython"
        );

        for (String blackListedDep : deps) {
            if (dep.equals(blackListedDep)) {
                return true;
            }
        }

        return false;
    }
}
