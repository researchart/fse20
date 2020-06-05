package ch.uzh.seal.app;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.readers.CIAntiPatternCSVReader;
import ch.uzh.seal.antipattern.writers.CIAntiPatternCSVWriter;
import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.detectors.gitlabyaml.parsers.GitLabYAMLParser;
import ch.uzh.seal.detectors.maven.pom.POM;
import ch.uzh.seal.detectors.maven.versioning.MavenVersionAntiPatternDetector;
import ch.uzh.seal.detectors.python.versioning.entities.Dependency;
import ch.uzh.seal.detectors.python.versioning.entities.RequirementsTXT;
import ch.uzh.seal.detectors.python.versioning.parsers.RequirementsTXTParser;
import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.project.linters.ProjectLinter;
import ch.uzh.seal.utils.ProcessedEntitiesReader;
import ch.uzh.seal.project.parsers.ProjectParser;
import ch.uzh.seal.project.writers.ProjectDownloader;
import ch.uzh.seal.utils.ProcessedEntitiesWriter;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.*;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.io.FileUtils;

public class ConfigurationAnalytics {

	private String projectsCSVSheetPath;
	private String antiPatternCSVPath;
	private String lintedProjectsPath;
	private String projectsDirPath;
	private String gitLabTokenPath;

	public ConfigurationAnalytics(String projectsCSVSheetPath,
			String outputPath,
			String lintedProjectsPath,
			String projectsPath,
			String gitLabTokenPath) {
		this.projectsCSVSheetPath = projectsCSVSheetPath;
		this.antiPatternCSVPath = outputPath;
		this.lintedProjectsPath = lintedProjectsPath;
		this.projectsDirPath = projectsPath;
		this.gitLabTokenPath = gitLabTokenPath;
	}

	
	public static void main3(String [] args) throws IOException {
		
		String projectsCSVSheetPath =  "/Users/carminevassallo/Documents/CI-Linter/cd-linter-paper/resources/anti-patterns-occurrences/fullDataset.csv";
		String projectsSample = "/Users/carminevassallo/Desktop/Rscripts/dataset.csv";
		
		List<String> projects = FileUtils.readLines(new File(projectsSample), Charset.defaultCharset());
		
		List<String> readLines = FileUtils.readLines(new File(projectsCSVSheetPath), Charset.defaultCharset());
		
		List<String> toWrite = new ArrayList<>();
		for(String line : readLines) {
			String[] splittedLine = line.split(",");
			String projectName = splittedLine[1];
			
			if(projects.contains(projectName)) {
				System.out.println(line);
				toWrite.add(line);
			}
		}
		
		File output = new File("/Users/carminevassallo/Desktop/Rscripts/output.csv");
		FileUtils.writeLines(output, toWrite);
	}
	
	/**
	 * antipattern analysis
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {
		
		final long start = System.currentTimeMillis();

		//set some initial parameters
		String projectsCSVSheetPath =  args[0]; // "src/main/resources/sampleDataset.csv"; 
		String lintedProjectsPath = "target/lintedProjects.txt";
		String projectsPath = args[1]; // "src/main/resources/projects" ;// "target/projects"; //args[1]; //
		String outputPath = args[2];
		String gitLabTokenPath = "null"; //args[2];
		String startFrom = "null"; // args[3]; 
		
		ConfigurationAnalytics analytics = new ConfigurationAnalytics(
				projectsCSVSheetPath,
				outputPath,
				lintedProjectsPath,
				projectsPath,
				gitLabTokenPath);
		
		// load projects to analyze
		ProjectParser projectParser = new ProjectParser(gitLabTokenPath);
		List<LintProject> projects = null;
		
		if(!startFrom.equalsIgnoreCase("null")) {
			projects = new ArrayList<>();
			List<LintProject> all = projectParser.getProjectsFromCSVSheet(projectsCSVSheetPath);
			boolean add = false;
			for(LintProject p : all) {
	
				if(p.getName().equalsIgnoreCase(startFrom))
					add = true;
				
				if(add)
					projects.add(p);
				
			}
		}
		else {
			projects =  projectParser.getProjectsFromCSVSheet(projectsCSVSheetPath);
		}
		
		
		// detect anti-patterns
		List<CIAntiPattern> analyze = analytics.analyze(projects);
		System.out.println("Found: " + analyze.size() + " anti-patterns");
		//filter projects (in first sample only)
//		analytics.download(projects, projectsPath);//.getProjectsOfFirstSample(projectsCSVSheetPath, samplePath);
	
		
		final long durationInMilliseconds = System.currentTimeMillis()-start;
		System.out.println("executeLongRunningTask() took " + durationInMilliseconds + "ms.");
		
		
//		System.exit(0);
		
/*		List<CIAntiPattern> resultingCias = analytics.analyze(projects);//.download(projectsCSVSheetPath, projectsPath,sample);
		Set<String> newCiaIds = new HashSet<>();
		for(CIAntiPattern cia: resultingCias) {
			newCiaIds.add(cia.getId());
		}
		
		// compare old and new anti-patterns
		CIAntiPatternCSVReader reader = new CIAntiPatternCSVReader(samplePath);
		Set<CIAntiPattern> oldCias = reader.read();
		Set<String> oldCiaIds = new HashSet<>();
		for(CIAntiPattern cia: oldCias) {
			oldCiaIds.add(cia.getId());
		}
		System.out.println("-------- Results");
		
		for(String oldCiaId: oldCiaIds) {
			if(!newCiaIds.contains(oldCiaId)) {
				System.out.println(oldCiaId);
			}
		}*/
	}
	
	/**
	 * select only projects in the first sample
	 * @param projectsCSVSheetPath
	 * @param pathToFirstSample
	 * @return
	 * @throws IOException
	 */
	public List<LintProject> getProjectsOfFirstSample(String projectsCSVSheetPath, String pathToFirstSample) throws IOException{
		
		ProjectParser projectParser = new ProjectParser(gitLabTokenPath);
		List<LintProject> projects = projectParser.getProjectsFromCSVSheet(projectsCSVSheetPath);
		
		// take all projects in the first sample
		CIAntiPatternCSVReader reader = new CIAntiPatternCSVReader(pathToFirstSample);
		Set<CIAntiPattern> sample = reader.read();
		Set<String> projectNames = new HashSet<>(); // all projects in the sample
		for(CIAntiPattern cia: sample) {
			String projectName = cia.getProject();
			projectNames.add(projectName);
		}	
		
		List<LintProject> resultingProjects = new ArrayList<>(); // take only the lint projects in the sample
		
		for(String pName: projectNames) {
			LintProject p = searchForLintProject(projects,pName);
			resultingProjects.add(p);
		}
			
		return resultingProjects;
	}
	
	private LintProject searchForLintProject(List<LintProject> projects, String projectName) {
		for(LintProject p: projects) {
			if(p.getName().equalsIgnoreCase(projectName))
				return p;
		}
		return null;
	}
	

	public List<CIAntiPattern> analyze(List<LintProject> projects) throws IOException {
		//     Set<String> lintedProjects = ProcessedEntitiesReader.getProcessedEntities(lintedProjectsPath);

		CIAntiPatternCSVWriter antiPatternCSVWriter = new CIAntiPatternCSVWriter(antiPatternCSVPath);
		//    ProcessedEntitiesWriter lintedProjectsWriter = new ProcessedEntitiesWriter(lintedProjectsPath);
		ProjectDownloader projectDownloader = new ProjectDownloader(projectsDirPath);

		List<CIAntiPattern> resultingCias = new ArrayList<>();
		
		int exceptions = 0;
		for (LintProject project : projects) {
			System.out.println("Inspecting... " + project.getName());

			projectDownloader.downloadProjectFiles(project);
			String projectName = project.getName();
			List<CIAntiPattern> antiPatterns;
			
			//if the project contains other files (via include) inspect them online
			
			

			//        if (!lintedProjects.contains(projectName)) {

			try {
				antiPatterns = ProjectLinter.getCIAntiPatterns(project);
			} catch (Exception e) {
				System.err.println("`"+projectName + "` could not be read!");
				System.out.println(e.toString());
				exceptions++;
				continue;
			}
			
			resultingCias.addAll(antiPatterns);
			antiPatternCSVWriter.write(antiPatterns);
		}

		antiPatternCSVWriter.close();
		
		System.out.println("Projects could not be analyzed: " + exceptions);
		
		return resultingCias;
	}
	
	

	public void computeAllStages(String projectsDirPath, String gitLabTokenPath, String projectsCSVSheetPath, String outputFile) throws IOException {
		ProjectParser projectParser = new ProjectParser(gitLabTokenPath);
		List<LintProject> projects = projectParser.getProjectsFromCSVSheet(projectsCSVSheetPath);

	//	Map<String,Integer> stages = new HashMap<String, Integer>();

		ProjectDownloader projectDownloader = new ProjectDownloader(projectsDirPath);

		int numOfProjectsWithYaml = 0;

		int numOfProjectsWithJobs = 0;
		
		int size = projects.size();
		int counter = 0;
			
		File output = new File(outputFile);
		List<String> lines = new ArrayList<>();
		
		lines.add("project,owner,language,hasYaml,hasRequirements,hasPoms,stages,hasBuildStage,hasTestStage,hasDeployStage,hasCustomDeployStage,yml_size");
		
		for(LintProject project: projects) {

			projectDownloader.downloadProjectFiles(project); //check presence of files TODO: fix smelly code
			
	        String language = project.getLanguage();
	        String buildTool = project.getBuildToolName();
			
			counter++;
			System.out.println(counter + "/" + size);

			String projectName = project.getName();
			String owner = projectName.split("__")[0];
			
			// get all yaml files
			String yamlContent = project.getFileContent(".gitlab-ci.yml");
			String[] split = yamlContent.split("\r\n|\r|\n");
			int yamlSize = split.length;
			
			GitLabYAMLParser parser = new GitLabYAMLParser();
			
			GitLabYAML yaml = null;
			try {
				yaml = parser.parse(yamlContent); 
				
			} catch (Exception e) { // if the project is empty
				System.err.println("`"+projectName + "` could not be read!");
				System.out.println(e.toString());
				continue;
			}

			/*			List<String> stagesInYaml = yaml.getStages();


			for(String stage: stagesInYaml) {
				if(stages.containsKey(stage)) 
					stages.put(stage, stages.get(stage) + 1);
				else 
					stages.put(stage, 1);
			}*/

			Map<String, Job> jobs = yaml.getJobs();
			boolean hasYamlFile = (jobs.size()>0); // a project with 0 jobs has no yaml file
			
			
			Set<String> stages = new HashSet<>();
			for(String key: jobs.keySet()) {
				String stage = jobs.get(key).getStage();
				stages.add(stage);
			}
			
			boolean hasRequirements = false;
			
			if (language.equals("Python")) {
			String requirementsTXTContent = project.getFileContent("requirements.txt"); 
				hasRequirements = !requirementsTXTContent.equals("");
			}
			// check for the presence of a requirements.txt
			
			boolean hasPoms = false;
	        if (buildTool.equals("Maven")) {
			MavenVersionAntiPatternDetector detector = new MavenVersionAntiPatternDetector(project);
			
			int poms = 0;
			try {
				poms  = detector.getPOMs(project).size();
				hasPoms = poms>0; //the project has at least one pom
			} catch (Exception e) {
			}
	        }
	        
			
			String line = projectName.replaceAll("__", "/") + "," +
					owner + "," +
					language + "," +
					hasYamlFile + "," +
					hasRequirements + "," +
					hasPoms + "," +
					stages.size() + ","+
					stages.contains(Job.BUILD) + "," +
					stages.contains(Job.TEST) + "," +
					stages.contains(Job.DEPLOY)+ "," +
					hasCustomDeploy(stages) + "," +
					yamlSize
					;
					
			lines.add(line);
			
			if(jobs.size()>0) 
				numOfProjectsWithJobs++;
			
			numOfProjectsWithYaml++;

		}

/*
		for(String stage: stages.keySet()){
			lines.add(stage + "," + stages.get(stage));
		}
*/
		FileUtils.writeLines(output, lines);
		System.out.println(numOfProjectsWithJobs+ "/" + size);
		System.out.println(numOfProjectsWithYaml+ "/" + size);
	}

	/*
	 * TODO: remove from here!
	 */
	private boolean hasCustomDeploy(Set<String> stages) {
		List<String> deployLList = List.of(
				"staging",
				"release",
				"publish",
				"manual",
				"install",
				"docker",
				"container",
				"production",
				"image",
				"environment",
				"install",
				"prod",
				"canary"
				);
		
		for(String stage: stages) {
			if(deployLList.contains(stage))
				return true;
		}

		return false;

	}
	

	public void download(List<LintProject> projects, String projectsDirPath) {
		
		ProjectDownloader projectDownloader = new ProjectDownloader(projectsDirPath);

		for (LintProject project : projects) {
			String projectName = project.getName();
			
			
			projectDownloader.downloadProjectFiles(project);
			System.out.println("`"+projectName+"` downloaded");
		}
	}

}
