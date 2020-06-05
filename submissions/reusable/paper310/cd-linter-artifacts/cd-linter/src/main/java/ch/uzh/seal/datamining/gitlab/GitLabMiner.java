/**
 * Copyright 2018 University of Zurich
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package ch.uzh.seal.datamining.gitlab;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.nio.charset.Charset;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import com.google.gson.Gson;

import ch.uzh.seal.datamining.gitlab.entities.Branch;
import ch.uzh.seal.datamining.gitlab.entities.Commit;
import ch.uzh.seal.datamining.gitlab.entities.Contributor;
import ch.uzh.seal.datamining.gitlab.entities.Issue;
import ch.uzh.seal.datamining.gitlab.entities.Job;
import ch.uzh.seal.datamining.gitlab.entities.Language;
import ch.uzh.seal.datamining.gitlab.entities.MergeRequest;
import ch.uzh.seal.datamining.gitlab.entities.Pipeline;
import ch.uzh.seal.datamining.gitlab.entities.Project;
import ch.uzh.seal.datamining.gitlab.entities.ProjectItem;
import ch.uzh.seal.datamining.gitlab.entities.Tag;
import ch.uzh.seal.utils.HTTPConnector;
import ch.uzh.seal.utils.TCIDateFormatter;


public class GitLabMiner {

	public static final String GITLAB_ACCESSPOINT = "https://gitlab.com/api/v4";
	private String privateToken;
	private Gson gson;
	private Map<String,String> requests_header = new HashMap<>();

	public GitLabMiner(String privateToken) {
		gson = new Gson();
		this.privateToken = privateToken;
	}

	public static void main(String[] args) throws ParseException, IOException {
		String pvtToken = args[0];
		String demo = args[2];
		GitLabMiner gm = new GitLabMiner(pvtToken);
		List<Project> projects = gm.getProjects(Integer.parseInt(demo));

		String fileName = args[1];

		CSVPrinter printer = new CSVPrinter(new FileWriter(fileName), CSVFormat.DEFAULT);
		printer.printRecord("id","projectName","creationDate","lastUpdate","stars","forks","languages");

		for(Project p: projects){
			printer.printRecord(p.getId(),p.getPathWithNamespace(),p.getCreatedAt(),p.getLastActivityAt(),p.getStarsCount(),
					p.getForksCount(),p.getLanguages());
		}

		printer.close();
	}

	public static void main2(String[] args) throws Exception {
	/*	long yourmilliseconds = System.currentTimeMillis();
		SimpleDateFormat sdf = new SimpleDateFormat("YYMMdd-HHmmss");    
		Date resultdate = new Date(yourmilliseconds);
		String currentTime = sdf.format(resultdate);
*/
		String pvtToken = "null";
		GitLabMiner gm = new GitLabMiner(pvtToken);
		
		String name = "issues_200205-180807";
		String input = "/Users/carminevassallo/Documents/CI-Linter/cd-linter-paper/resources/gitlab-issue-monitoring/"+ name +".csv";
		FileReader reader = new FileReader(input);
		String output = "/Users/carminevassallo/Documents/CI-Linter/cd-linter-paper/resources/gitlab-issue-monitoring/"+ name +"_upd.csv";
		FileWriter writer = new FileWriter(output);
		gm.updateFixingCommitStats(reader, writer);
	}

	public static void main3(String[] args) throws Exception {
		String pvtToken = args[0];
		GitLabMiner gm = new GitLabMiner(pvtToken);

		String input = args[1];
		FileReader reader = new FileReader(input);
		String output = args[2];
		FileWriter writer = new FileWriter(output);
		gm.mineForkedProjects(reader, writer);
	}

	public void mineForkedProjects(Reader inputFile, Writer outputFile) throws Exception {
		CSVParser parser = CSVParser.parse(inputFile, CSVFormat.DEFAULT.withHeader());
		CSVPrinter printer = new CSVPrinter(outputFile, CSVFormat.DEFAULT);
		List<String> headerNames = new ArrayList<>(parser.getHeaderNames());
		headerNames.add("isForked");
		printer.printRecord(headerNames); // print the new header

		int index = 1;
		for (CSVRecord csvRecord : parser) {
			String projectName = csvRecord.get("projectName");
			index++;
			System.out.println("Evaluating " + projectName + " (" + index + ")");

			String id = csvRecord.get("id");
			String creationDate = csvRecord.get("creationDate");
			String lastUpdate = csvRecord.get("lastUpdate");
			String stars = csvRecord.get("stars");
			String forks = csvRecord.get("forks");
			String languages = csvRecord.get("languages");

			String checkForkedFrom = checkForkedFrom(id);

			printer.printRecord(id,projectName,creationDate,lastUpdate,stars,forks,languages,checkForkedFrom);
		}

		parser.close();
		printer.close();
	}

	/**
	 * As input the following header "id	category	reviewTag*	title	desc	linkToRepository	
	 * linkToOpenedIssue	fixed (y/n/m)	fixingCommit	cd-linter-bug	
	 * comment-labels	fix-labels	notes (e.g., how they fix it,)	reaction	
	 * lastChecked	state	isAssigned	numUpvotes	numDownvotes	
	 * numComments	label*	monitoringTag*	monitoringComment	
	 * contributors	contributorsSinceIssue	commitsSinceIssue"
	 * @param inputFile
	 * @param outputFile
	 * @throws Exception
	 */
	public void updateFixingCommitStats(Reader inputFile, Writer outputFile) throws Exception {

		CSVParser parser = CSVParser.parse(inputFile, CSVFormat.DEFAULT.withHeader());
		CSVPrinter printer = new CSVPrinter(outputFile, CSVFormat.DEFAULT);
		List<String> headerNames = new ArrayList<>(parser.getHeaderNames());
		headerNames.add("fixingCommit-message");
		headerNames.add("resolution-time");

		printer.printRecord(headerNames); // print the new header

		for (CSVRecord csvRecord : parser) {

			//take the commit id
			String commitId = csvRecord.get("fixingCommit");

			Map<String, String> values = csvRecord.toMap(); // get previous values

			if(!commitId.equalsIgnoreCase("")) {

				//retrieve issue date
				String linkToIssue = csvRecord.get("linkToOpenedIssue"); // ex. https://gitlab.com/vuedoc/parser/issues/54
				String[] splittedIssueLink = linkToIssue.substring(19).split("/");
				String projectEncName = splittedIssueLink[0] + "%2F" + splittedIssueLink[1];
				String issueId = splittedIssueLink[3];
				String fullIssueId = projectEncName + "_" + issueId;
				System.out.println("Evaluating... "+ fullIssueId);
				Issue issue = getIssueById(projectEncName, issueId);
				String issueCreationDateStr = issue.getCreated_at();
				Date issueCreationDate = TCIDateFormatter.gitlabStringToDate(issueCreationDateStr);

				//retrieve commit date
				System.out.println(projectEncName + " " + commitId);
				Commit commit = getCommit(projectEncName, commitId);
				String commitDateStr = commit.getCreated_at();
				String commitMessage = commit.getMessage();
				Date commitDate = TCIDateFormatter.gitlabStringToDate(commitDateStr);

				//compute the diff between the two dates (in ms)
				long timeBetweenDates = TCIDateFormatter.timeBetweenDates(issueCreationDate, commitDate);
				values.put("resolution-time", ""+timeBetweenDates);
				values.put("fixingCommit-message", commitMessage);
			}
			else {
				values.put("resolution-time", "");
				values.put("fixingCommit-message", "");
			}

			printer.printRecord(values.get("id"), values.get("category"), values.get("reviewTag*"), values.get("title"),
					values.get("desc"), values.get("linkToRepository"), values.get("linkToOpenedIssue"), values.get("fixed (y/n/m)"), 
					values.get("fixingCommit"), values.get("cd-linter-bug"), values.get("comment-labels"), values.get("fix-labels"),
					values.get("notes (e.g., how they fix it,)"), values.get("reaction"), values.get("lastChecked"),
					values.get("state"), values.get("isAssigned"), values.get("numUpvotes"), values.get("numDownvotes"),
					values.get("numComments"), values.get("label*"), values.get("monitoringTag*"), values.get("monitoringComment"),
					values.get("contributors"), values.get("contributorsSinceIssue"), values.get("commitsSinceIssue"),
					values.get("fixingCommit-message"), values.get("resolution-time"));

		}
		
		parser.close();
		printer.close();
	}


	/**
	 * The file accepted as input has the following header "id	category	reviewTag*	title	desc	linkToRepository	
		linkToOpenedIssue	lastChecked	state	isAssigned	numUpvotes	numDownvotes	 
		numComments	label*	monitoringTag*	monitoringComment"
	 * @param inputFile
	 * @throws Exception 
	 */
	public void updateIssueStats(Reader inputFile, Writer outputFile) throws Exception {
		// id	category	reviewTag*	title	desc	linkToRepository	
		//linkToOpenedIssue	lastChecked	state	isAssigned	numUpvotes	numDownvotes	 
		//numComments	label*	monitoringTag*	monitoringComment

		CSVParser parser = CSVParser.parse(inputFile, CSVFormat.DEFAULT.withHeader());
		CSVPrinter printer = new CSVPrinter(outputFile, CSVFormat.DEFAULT);
		List<String> headerNames = new ArrayList<>(parser.getHeaderNames());
		headerNames.add("contributors");
		headerNames.add("contributorsSinceIssue");
		headerNames.add("commitsSinceIssue");

		printer.printRecord(headerNames); // print the new header

		Set<String> analyzedIssues = new HashSet<>();

		for (CSVRecord csvRecord : parser) {
			String linkToIssue = csvRecord.get("linkToOpenedIssue"); // ex. https://gitlab.com/vuedoc/parser/issues/54

			if(linkToIssue.equalsIgnoreCase("null"))
				continue; // skip the null links

			String[] splittedIssueLink = linkToIssue.substring(19).split("/");
			String projectEncName = splittedIssueLink[0] + "%2F" + splittedIssueLink[1];
			String issueId = splittedIssueLink[3];
			String fullIssueId = projectEncName + "_" + issueId;

			if(analyzedIssues.contains(fullIssueId)) {
				continue; // skip because it was already analyzed
			}
			else {
				analyzedIssues.add(fullIssueId);
			}

			System.out.println("Evaluating... "+ fullIssueId);

			Issue issue = getIssueById(projectEncName, issueId);
			Map<String, String> values = csvRecord.toMap();

			long yourmilliseconds = System.currentTimeMillis();
			SimpleDateFormat sdf = new SimpleDateFormat("YYMMdd-HHmmss");    
			Date resultdate = new Date(yourmilliseconds);
			String currentTime = sdf.format(resultdate);
			values.put("lastChecked", currentTime);

			if(issue == null) {
				values.put("state", "deleted");
				values.put("contributors", "-1");
				values.put("contributorsSinceIssue", "-1");
				values.put("commitsSinceIssue", "-1");
			}
			else {

				// tot contributors
				int contributors = getContributors(projectEncName).size();
				//contributors and commits from issue creation
				String created_at = issue.getCreated_at();
				List<Commit> commitsSince = getCommits(projectEncName, created_at);
				Set<Contributor> contributorsSince = getContributorsFromCommits(commitsSince);
				int contributorsSinceIssue = contributorsSince.size();
				int commitsSinceIssue = commitsSince.size();

				values.put("contributors", ""+contributors);
				values.put("contributorsSinceIssue", ""+contributorsSinceIssue);
				values.put("commitsSinceIssue", ""+commitsSinceIssue);

				values.put("state", issue.getState());
				values.put("isAssigned", ""+(issue.getAssignees().length>0));
				values.put("numUpvotes", ""+issue.getUpvotes());
				values.put("numDownvotes", ""+issue.getDownvotes());
				values.put("numComments", ""+issue.getUser_notes_count());
			}

			printer.printRecord(values.get("id"), values.get("category"), values.get("reviewTag*"), values.get("title"),
					values.get("desc"), values.get("linkToRepository"), values.get("linkToOpenedIssue"), values.get("lastChecked"),
					values.get("state"), values.get("isAssigned"), values.get("numUpvotes"), values.get("numDownvotes"),
					values.get("numComments"), values.get("label*"), values.get("monitoringTag*"), values.get("monitoringComment"),
					values.get("contributors"), values.get("contributorsSinceIssue"), values.get("commitsSinceIssue"));
		}

		parser.close();
		printer.close();
	}


	public List<Job> getJobsAtPage(String id, int pageIndex) {

		List<Job> jobs = new ArrayList<>();

		String url = GITLAB_ACCESSPOINT + "/projects/"+id+"/jobs?per_page=100&page="+pageIndex;
		requests_header.put("Private-Token", privateToken);
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode == HTTPConnector.STATUS_OK) {
			Job[] jobsResponse = gson.fromJson(response, Job[].class);

			for(Job j: jobsResponse) {
				jobs.add(j);
			}
		}

		return jobs;
	}

	public Pipeline getPipelineInfo(String projectId, String pipeID) {

		String url = GITLAB_ACCESSPOINT + "/projects/"+projectId+"/pipelines/"+pipeID;
		requests_header.put("Private-Token", privateToken);
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode == HTTPConnector.STATUS_OK) {
			Pipeline pipelineResponse = gson.fromJson(response, Pipeline.class);

			return pipelineResponse;
		}
		return null;
	}

	public ProjectItem getProjectItem(String projectID) {

		String url = GITLAB_ACCESSPOINT + "/projects/"+projectID;
		requests_header.put("Private-Token", privateToken);
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode == HTTPConnector.STATUS_OK) {
			ProjectItem projectItemResponse = gson.fromJson(response, ProjectItem.class);

			return projectItemResponse;
		}
		return null;
	}

	public String checkForkedFrom(String id) {

		ProjectItem item= getProjectItem(id);

		String result = null;

		if(item != null) {
			if(item.getForked_from_project() == null)
				result = "FALSE";
			else
				result = "TRUE";
		}
		else
			result = "NA";

		return result;
	}


	public List<Job> getJobs(String projectId){
		int page = 1;
		boolean emptyPage = false;

		List<Job> jobs = new ArrayList<>();

		while(!emptyPage){

			List<Job> jobsAtPage = getJobsAtPage(projectId, page);
			if(jobsAtPage.size() == 0) {
				emptyPage = true;
			}
			else {
				//print projects for debugging
				//			for(Job j : jobsAtPage)
				//					System.out.println(page+ ","+ j.getId());

				jobs.addAll(jobsAtPage);
				page++;
			}
		}
		return jobs;
	}


	public List<Project> getProjectsAtPage(int pageIndex) throws ParseException{
		List<Project> projects = new ArrayList<>();

		String url = GITLAB_ACCESSPOINT + "/projects?per_page=100&sort=asc&page="+pageIndex;
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//		System.out.println(pageIndex +",nullproject,"+response); // debug
			Project fakeProj = new Project();
			projects.add(fakeProj);
		}
		else {

			ProjectItem[] projectResponse = gson.fromJson(response, ProjectItem[].class);

			for(ProjectItem p : projectResponse) {

				String id = p.getId();
				String pathWithNamespace = p.getPath_with_namespace();
				Date createdAt = null;
				Date lastActivityAt = null;

				if(p.getCreated_at() != null)
					createdAt = TCIDateFormatter.convertToDate(p.getCreated_at());

				if(p.getLast_activity_at() != null)
					lastActivityAt = TCIDateFormatter.convertToDate(p.getLast_activity_at());

				int starsCount = 0;
				int forksCount = 0;

				if(p.getStar_count() != null)
					starsCount = Integer.parseInt(p.getStar_count());

				if(p.getForks_count() != null)
					forksCount = Integer.parseInt(p.getForks_count());

				Project proj = new Project(id, pathWithNamespace, createdAt, lastActivityAt, starsCount, forksCount);

				getLanguagesForProject(proj); // add languages if any

				projects.add(proj);
			}}

		return projects;
	}


	public void getLanguagesForProject(Project p){
		String id = p.getId();

		String url = GITLAB_ACCESSPOINT + "/projects/"+id+"/languages";
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];


		if(responseCode != HTTPConnector.STATUS_OK) {
			//		System.out.println("nulllanguage,"+response); // debug
		}
		else {
			List<Language> parseLanguages = parseLanguages(response);
			p.setLanguages(parseLanguages);
		}

	}

	public String getDefaultBranchForProject(Project p) {
		int page = 1;
		boolean emptyPage = false;

		String projectId = p.getId();


		while(!emptyPage){

			List<Branch> branchesAtPage = getBranchesForProjectAtPage(projectId, page);

			if(branchesAtPage.size() == 0) {
				emptyPage = true;
			}
			else {
				for (Branch b: branchesAtPage) {
					if(b.getDefault()) {
						return b.getName();
					}
				}

				page++;
			}
		}
		return null;
	}

	public List<Branch> getBranchesForProjectAtPage(String projectId, int pageIndex) {

		List<Branch> branches = new ArrayList<Branch>();

		String url = GITLAB_ACCESSPOINT + "/projects/"+projectId+"/repository/branches?per_page=100&page="+pageIndex;
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			Branch[] branchResponse = gson.fromJson(response, Branch[].class);

			for(Branch branch: branchResponse) {
				branches.add(branch);
			}
		}

		return branches;
	}

	/**
	 * This method enables you to download basic information about all projects hosted on GitLab.
	 * The analysis takes week. Set demo to '0' to start a full analysis. Otherwise, set other values. 
	 * 
	 * @param demo
	 * @return
	 * @throws ParseException
	 */
	public List<Project> getProjects(int demo) throws ParseException{
		int page = 1;
		boolean emptyPage = false;

		List<Project> projects = new ArrayList<>();

		while(!emptyPage){

			List<Project> projectsAtPage = getProjectsAtPage(page);
			if(projectsAtPage.size() == 0) {
				emptyPage = true;
			}
			else {
				//print projects for debugging
				//	for(Project p : projectsAtPage)
				//		System.out.println(page+ ","+ p);

				projects.addAll(projectsAtPage);
				System.out.println("Analyzed " + page + " pages (" + page*100 + " projects)");
				page++;
				
				if(page == 2 && demo == 0) 
					break; // stop the analysis after the first page while in demo mode.
			}
		}
		return projects;
	}


	// get contributors
	//https://gitlab.com/api/v4/projects/13083/repository/contributors?sort=desc
	public List<Contributor> getContributors(String projectId){
		int page = 1;
		boolean emptyPage = false;

		List<Contributor> items = new ArrayList<>();

		while(!emptyPage){

			List<Contributor> itemsAtPage = getContibutorsAtPage(projectId,page);
			if(itemsAtPage.size() == 0) {
				emptyPage = true;
			}
			else {
				items.addAll(itemsAtPage);
				page++;
			}
		}
		return items;
	}


	public List<Contributor> getContibutorsAtPage(String id, int pageIndex){
		List<Contributor> items = new ArrayList<>();


		String url = GITLAB_ACCESSPOINT + "/projects/"+id+ "/repository/contributors?sort=desc&per_page=100&page="+pageIndex;
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			Contributor[] itemResponse = gson.fromJson(response, Contributor[].class);

			for(Contributor item: itemResponse) {
				items.add(item);
			}
		}

		return items;
	}

	// merge-requests

	public List<MergeRequest> getMergeRequests(Project p, String state){
		int page = 1;
		boolean emptyPage = false;

		String id = p.getId();

		List<MergeRequest> items = new ArrayList<>();

		while(!emptyPage){

			List<MergeRequest> itemsAtPage = getMergeRequestsAtPage(id, state, page);
			if(itemsAtPage.size() == 0) {
				emptyPage = true;
			}
			else {

				items.addAll(itemsAtPage);
				page++;
			}
		}
		return items;
	}


	public List<MergeRequest> getMergeRequestsAtPage(String id, String state, int pageIndex){
		List<MergeRequest> items = new ArrayList<>();
		//projects/4921652/merge_requests?per_page=100&page=1&state=closed
		String url = GITLAB_ACCESSPOINT + "/projects/"+id+ 
				"/merge_requests?state="+state+"&per_page=100&page="+pageIndex;


		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			MergeRequest[] itemResponse = gson.fromJson(response, MergeRequest[].class);

			for(MergeRequest item: itemResponse) {
				items.add(item);
			}
		}

		return items;
	}

	// IP8vai5ahv8ia3xaezaj


	public Set<Contributor> getContributorsFromCommits(List<Commit> commits){
		Set<Contributor> contributors = new HashSet<>();

		for(Commit c: commits) {
			String author_name = c.getAuthor_name();
			String author_email = c.getAuthor_email();

			Contributor contributor = new Contributor();
			contributor.setName(author_name);
			contributor.setEmail(author_email);
			contributors.add(contributor);
		}

		return contributors;
	}

	public List<Commit> getCommits(String projectId, String updatedAfter){
		int page = 1;
		boolean emptyPage = false;

		List<Commit> items = new ArrayList<>();

		while(!emptyPage){

			List<Commit> itemsAtPage = getCommitsAtPage(projectId, updatedAfter, page);
			if(itemsAtPage.size() == 0) {
				emptyPage = true;
			}
			else {
				items.addAll(itemsAtPage);
				page++;
			}
		}
		return items;
	}

	public Commit getCommit(String id, String sha) {
		String url = GITLAB_ACCESSPOINT + "/projects/"+id+ 
				"/repository/commits/"+sha;

		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			Commit itemResponse = gson.fromJson(response, Commit.class);

			return itemResponse;
		}

		return null;
	}



	public List<Commit> getCommitsAtPage(String id, String since, int pageIndex){
		List<Commit> items = new ArrayList<>();
		//projects/4921652/merge_requests?per_page=100&page=1&state=closed
		String url = null;

		if(since != null) {
			url = GITLAB_ACCESSPOINT + "/projects/"+id+ 
					"/repository/commits?all=true&per_page=100&page="+pageIndex + 
					"&since=" + since;
		}
		else {
			url = GITLAB_ACCESSPOINT + "/projects/"+id+ 
					"/repository/commits?all=true&per_page=100&page="+pageIndex;
		}

		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			Commit[] itemResponse = gson.fromJson(response, Commit[].class);

			for(Commit item: itemResponse) {
				items.add(item);
			}
		}

		return items;
	}


	// issues

	public List<Issue> getIssues(Project p, String state, String updatedAfter){
		int page = 1;
		boolean emptyPage = false;

		String id = p.getId();

		List<Issue> items = new ArrayList<>();

		while(!emptyPage){

			List<Issue> itemsAtPage = getIssuesAtPage(id, state,updatedAfter, page);
			if(itemsAtPage.size() == 0) {
				emptyPage = true;
			}
			else {

				items.addAll(itemsAtPage);
				page++;
			}
		}
		return items;
	}


	public List<Issue> getIssuesAtPage(String id, String state, String updatedAfter, int pageIndex){
		List<Issue> items = new ArrayList<>();
		//projects/4921652/merge_requests?per_page=100&page=1&state=closed
		String url = GITLAB_ACCESSPOINT + "/projects/"+id+ 
				"/issues?state="+state+"&per_page=100&page="+pageIndex + 
				"&updated_after=" + updatedAfter;


		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			Issue[] itemResponse = gson.fromJson(response, Issue[].class);

			for(Issue item: itemResponse) {
				items.add(item);
			}
		}

		return items;
	}

	/**
	 * This method accepts the project's encoded path as one parameter instead of the usual id.
	 * Ex. "/api/v4/projects/diaspora%2Fdiaspora"
	 * @param projectEncodedPath
	 * @param issueId
	 * @return
	 * @throws Exception 
	 */
	public Issue getIssueById(String projectEncodedPath, String issueId) throws Exception {
		String url = GITLAB_ACCESSPOINT + "/projects/"+projectEncodedPath
				+"/issues?iids[]="+ issueId;

		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		Set<Issue> issues = new HashSet<Issue>();

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			Issue[] itemResponse = gson.fromJson(response, Issue[].class);

			for(Issue item: itemResponse) {
				issues.add(item);
			}
		}

		if(issues.size() == 0)
			return null;
		else if(issues.size() > 1)
			throw new Exception("too many issues");
		else {
			return issues.iterator().next();
		}
	}

	//tags

	public List<Tag> getTags(Project p){
		int page = 1;
		boolean emptyPage = false;

		String id = p.getId();

		List<Tag> items = new ArrayList<>();

		while(!emptyPage){

			List<Tag> itemsAtPage = getTagsAtPage(id,page);
			if(itemsAtPage.size() == 0) {
				emptyPage = true;
			}
			else {

				items.addAll(itemsAtPage);
				page++;
			}
		}
		return items;
	}


	public List<Tag> getTagsAtPage(String id, int pageIndex){
		List<Tag> items = new ArrayList<>();
		//projects/4921652/merge_requests?per_page=100&page=1&state=closed
		String url = GITLAB_ACCESSPOINT + "/projects/"+id+ 
				"/repository/tags?per_page=100&page="+pageIndex;


		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);

		int responseCode = Integer.parseInt(responseResults[0]);
		String response = responseResults[1];

		if(responseCode != HTTPConnector.STATUS_OK) {
			//			System.out.println(projectId +",nullproject,"+response); // debug
		}
		else {
			Tag[] itemResponse = gson.fromJson(response, Tag[].class);

			for(Tag item: itemResponse) {
				items.add(item);
			}
		}

		return items;
	}


	/**
	 * example of file in input available at 
	 * @param input
	 * @return
	 * @throws IOException
	 * @throws ParseException
	 */
	public List<Project> readProjects(File input) throws IOException, ParseException{
		List<String> lines = FileUtils.readLines(input, Charset.defaultCharset());

		List<Project> projects = new ArrayList<>();

		for(int i = 1; i < lines.size(); i++) {
			String l = lines.get(i);
			Project p = parseLine(l);
			projects.add(p);
		}

		return projects;

	}

	/**
	 * example of file in input available at 
	 * @param input
	 * @return
	 * @throws IOException
	 * @throws ParseException
	 */
	public Map<Integer,String> readMetrics(File input) throws IOException, ParseException{
		List<String> lines = FileUtils.readLines(input, Charset.defaultCharset());

		Map<Integer,String> metrics = new HashMap<>();

		for(int i = 1; i < lines.size(); i++) {
			String l = lines.get(i);
			String[] fields = StringUtils.split(l, ',');
			metrics.put(Integer.parseInt(fields[0]), fields[1]);
		}
		return metrics;

	}



	private Project parseLine(String line) throws ParseException {
		String[] fields = StringUtils.split(line, ',');
		// id	pathWithNamespace	createdAt	lastActivityAt	starsCount	forksCount	stages	isBuildStageInStages	isBuildStageInJobs	jobNames	isBuildInJobsName	isDeployStageInStages	isDeployStageInJobs	jobNames	isDeployInJobsName	pipelines	language	languages	projectIsAvailable	isFork	default_branch
		String id = fields[0];
		String pathWithNamespace = fields[1];
		Date createdAt = null;
		Date lastActivityAt = null;
		int starsCount = -1;//Integer.parseInt(fields[5]);
		int forksCount = -1;//Integer.parseInt(fields[6]);
		String default_branch = fields[6];

		Project project = new Project(id, pathWithNamespace, createdAt, lastActivityAt, starsCount, forksCount,
				default_branch);

		return project;
	}



	public int getNumberOfPipelines(Project project) {

		String id = project.getId();
		int number = -1;

		String url = GITLAB_ACCESSPOINT + "/projects/"+id+"/pipelines";
		//	https://gitlab.com/gitlab-org/gitlab-ce/raw/master/.gitlab-ci.yml
		//		System.out.println(url);
		Map<String, String> requests_header =new HashMap<String, String>();
		requests_header.put("Private-Token", privateToken);
		requests_header .put("Content-Type", "application/yaml; charset=utf-8");
		String[] responseResults = HTTPConnector.connectAndGetResponseHeader(url, requests_header, "x-total");

		int responseCode = Integer.parseInt(responseResults[0]);
		String responseHeader = responseResults[1];

		if(responseCode == HTTPConnector.STATUS_OK)
			number = Integer.parseInt(responseHeader);

		return number;
	}






	// other methods


	/**
	 * [warning] it might work on for the specific instance of log10...(differences might be in the size of the header)
	 * @param path
	 * @param logName
	 */
	public static void cleanLog(String path, String logName) {
		try {
			//"/Users/carminevassallo/Desktop/log10.txt"
			File file = new File(path + "/" + logName + ".txt");

			List<String> readLines = FileUtils.readLines(file, Charset.defaultCharset());

			List<String> filteredLines = new ArrayList<>();
			//		String header = "page,id,pathWithNamespace,createdAt,lastActivityAt,starsCount,forksCount";
			//		String header = "";
			//		filteredLines.add(header);
			for(int i = 0; i < readLines.size(); i++) {
				String line = readLines.get(i);
				//	if(line.contains(",nullproject,") || line.contains(",-4,")) {
				if(line.contains("nulllanguage")) {
					//		System.out.println(line);
					continue;
				}

				filteredLines.add(line);
			}


			File output = new File(path + "/" + logName + "_filtered.csv");
			FileUtils.writeLines(output, filteredLines);

			System.out.println(readLines.size());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}


	private List<Language> parseLanguages(String rawLine){
		List<Language> languages = new ArrayList<>();

		if(rawLine == null)
			return languages;

		rawLine = rawLine.replaceAll("\\s", "");
		String content = rawLine.substring(1, rawLine.length() - 1);

		//	System.out.println(content);

		StringTokenizer tokenizer = new StringTokenizer(content, ",");

		while(tokenizer.hasMoreTokens()) {
			String langItem = tokenizer.nextToken();
			StringTokenizer tokenizer2 = new StringTokenizer(langItem, ":");

			String lang = tokenizer2.nextToken();
			double percentage = Double.parseDouble(tokenizer2.nextToken());

			String name = lang.substring(1, lang.length() - 1);
			Language l = new Language(name, percentage);
			languages.add(l);
		}
		return languages;
	}





}
