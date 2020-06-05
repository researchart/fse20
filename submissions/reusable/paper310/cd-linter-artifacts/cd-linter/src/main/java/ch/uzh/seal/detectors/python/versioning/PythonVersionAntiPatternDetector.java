package ch.uzh.seal.detectors.python.versioning;

import ch.uzh.seal.detectors.Detector;
import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.detectors.python.versioning.analyzers.VersionSpecifierAnalyzer;
import ch.uzh.seal.detectors.python.versioning.entities.Dependency;
import ch.uzh.seal.detectors.python.versioning.entities.RequirementsTXT;
import ch.uzh.seal.detectors.python.versioning.entities.VersionSpecifier;
import ch.uzh.seal.detectors.python.versioning.parsers.GitLabYAMLDependencyParser;
import ch.uzh.seal.detectors.python.versioning.parsers.RequirementsTXTParser;
import ch.uzh.seal.utils.LineNumberExtractor;
import ch.uzh.seal.utils.LineNumberPathConstructor;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class PythonVersionAntiPatternDetector extends Detector {

    public PythonVersionAntiPatternDetector(LintProject project) {
        super(project);
    }

    private String category = "Versioning";

    public List<CIAntiPattern> lint() throws Exception {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();

        antiPatterns.addAll(getAntiPatternsFromRequirementsTXT(project));
        antiPatterns.addAll(getAntiPatternsFromGitLabYAML(project));

        return antiPatterns;
    }

    private List<CIAntiPattern> getAntiPatternsFromRequirementsTXT(LintProject project) throws IOException {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();
        String requirementsTXTContent = project.getFileContent("requirements.txt");
        RequirementsTXT requirementsTXT = new RequirementsTXTParser().parse(requirementsTXTContent);
        LineNumberExtractor lineNumberExtractor = new LineNumberExtractor(requirementsTXTContent);

        String projectName = project.getName();
        String cfgFileName = "requirements.txt";
        String remoteRepoPath = project.getRemotePath();
        String remoteCfgLink = project.getFullRemotePath(cfgFileName, true);
        String localCfgLink = project.getFullLocalPath(cfgFileName);

        List<Dependency> dependencies = requirementsTXT.getDependencies();
        for (Dependency dep : dependencies) {

            String name = dep.getName();

            if (inBlackList(name)) {
                continue;
            }

            List<CIAntiPattern> depAntiPatterns = analyzeDependency(dep);

            String lineNumber = lineNumberExtractor.getLineNumber(dep.getName());
            //String lineNumberPath = LineNumberPathConstructor.getPath(remoteCfgLink, lineNumber);

            for (CIAntiPattern depAntiPattern : depAntiPatterns) {
                depAntiPattern.setId(
                        generateID(
                                projectName,
                                "requirementstxt",
                                depAntiPattern.getEntity(),
                                depAntiPattern.getSubCategory()
                        ));
                depAntiPattern.setProject(projectName);
                depAntiPattern.setRemoteRepoLink(remoteRepoPath);
                depAntiPattern.setRemoteCfgLink(remoteCfgLink);
                depAntiPattern.setLocalCfgLink(localCfgLink);
                depAntiPattern.setCategory(category);
                depAntiPattern.setContext("requirements.txt");
                depAntiPattern.setLineNumber(lineNumber);
                depAntiPattern.setCfgFileName(cfgFileName);
                antiPatterns.add(depAntiPattern);
            }
        }

        return antiPatterns;
    }

    private List<CIAntiPattern> getAntiPatternsFromGitLabYAML(LintProject project) {
        List<CIAntiPattern> antiPatterns = new ArrayList<>();
        String yamlContent = project.getFileContent(".gitlab-ci.yml");

        LineNumberExtractor lineNumberExtractor = new LineNumberExtractor(yamlContent);

        GitLabYAMLDependencyParser parser = new GitLabYAMLDependencyParser();

        String projectName = project.getName();
        String cfgFileName = ".gitlab-ci.yml";
        String remoteRepoPath = project.getRemotePath();
        String remoteCfgLink = project.getFullRemotePath(cfgFileName, true);
        String localCfgLink = project.getFullLocalPath(cfgFileName);

        List<Dependency> dependencies = parser.parse(yamlContent);
        for (Dependency dep : dependencies) {

            String name = dep.getName();

            if (inBlackList(name)) {
                continue;
            }
        	
            List<CIAntiPattern> depAntiPatterns = analyzeDependency(dep);
            
     //       if(name.contains(" ; ") || name.equals("."))
     //       	continue;
            
			String lineNumber = lineNumberExtractor.getLineNumber(name);
            //String lineNumberPath = LineNumberPathConstructor.getPath(remoteCfgLink, lineNumber);

            for (CIAntiPattern depAntiPattern : depAntiPatterns) {
                depAntiPattern.setId(
                        generateID(
                                projectName,
                                "gitlabyaml",
                                depAntiPattern.getEntity(),
                                depAntiPattern.getSubCategory()
                        ));
                depAntiPattern.setProject(projectName);
                depAntiPattern.setRemoteRepoLink(remoteRepoPath);
                depAntiPattern.setRemoteCfgLink(remoteCfgLink);
                depAntiPattern.setLocalCfgLink(localCfgLink);
                depAntiPattern.setCategory(category);
                depAntiPattern.setContext(yamlContent);
                depAntiPattern.setLineNumber(lineNumber);
                depAntiPattern.setCfgFileName(cfgFileName);
                antiPatterns.add(depAntiPattern);
            }
        }

        return antiPatterns;
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

    public String generateID(String projectName, String cfg, String depName, String subcategory) {
        return removeIllegalCharsInID(projectName + "__" + category + "__" + cfg + "__" + depName + "__" + subcategory);
    }

    private Boolean inBlackList(String dep) {
    	
    	if(dep.length() > 50) // check on unrealistic dependency name's lenght
    		return true;
    	
        List<String> deps = List.of(
        		".",
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
