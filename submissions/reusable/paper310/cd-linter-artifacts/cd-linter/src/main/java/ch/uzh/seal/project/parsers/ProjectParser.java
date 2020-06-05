package ch.uzh.seal.project.parsers;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import ch.uzh.seal.project.entities.LintProject;

public class ProjectParser {


	private String gitLabToken;

	public ProjectParser(String gitLabToken) {
		this.gitLabToken = gitLabToken;

	}

	/**
	 * Get the projects from the CSV sheet.
	 * 
	 * @param path
	 *            The path to the CSV sheet.
	 * @return A list of projects.
	 */
	public List<LintProject> getProjectsFromCSVSheet(String path) {
		CSVParser parser = null;
		
		try {
			FileReader reader = new FileReader(new File(path));
			parser = CSVParser.parse(reader, CSVFormat.DEFAULT.withHeader());
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		
		List<LintProject> projects = new ArrayList<>();
		
		try {
		List<CSVRecord> records = parser.getRecords();
		
		for(CSVRecord record: records) {
			LintProject project = getProject(record);
			projects.add(project);
		}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		

		return projects;
	}

	/**
	 * Get a project.
	 * 
	 * @param fields
	 *            The fields of the CSV sheet from which the `Project` instance is
	 *            constructed.
	 * @return The project.
	 */
	private LintProject getProject(CSVRecord csvRecord) {
		
		
		String domain = "https://gitlab.com/";
		String repoNameSpace = csvRecord.get("project");
		String name = repoNameSpace.replace("/", "__");
		String remotePath = domain + repoNameSpace;
		String language = csvRecord.get("language");
		String token = getGitLabToken();
		String owner = csvRecord.get("owner");
		String repository = csvRecord.get("project");
		String numCommitsInLastThreeMonths = "10000";
		String numIssuesOpenedInLastThreeMonths = "10000";

		LintProject lintProject = new LintProject();
		lintProject.setRemotePath(remotePath);
		lintProject.setName(name);
		lintProject.setLanguage(language);
		lintProject.setAccessToken(token);
		lintProject.setOwner(owner);
		lintProject.setRepository(repository);
		lintProject.setNumCommitsInLastThreeMonths(Integer.parseInt(numCommitsInLastThreeMonths));
		lintProject.setNumIssuesOpenedInLastThreeMonths(Integer.parseInt(numIssuesOpenedInLastThreeMonths));

		return lintProject;
	}

	private String getGitLabToken() {
		return gitLabToken;
	}
}
