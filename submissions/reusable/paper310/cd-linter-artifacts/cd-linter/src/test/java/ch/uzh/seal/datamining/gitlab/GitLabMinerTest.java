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

import static org.junit.Assert.*;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.Reader;
import java.util.List;
import java.util.Set;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import ch.uzh.seal.datamining.gitlab.entities.Commit;
import ch.uzh.seal.datamining.gitlab.entities.Contributor;
import ch.uzh.seal.datamining.gitlab.entities.Issue;

/***
 * 
 * FIXME: There are several tests that are ignored. They require an internet connection that might introduce flakiness
 * and are therefore ignored in the production-ready version of this tool. Fix asap this issue and enable them again in the new release.
 *
 */
public class GitLabMinerTest {

	private GitLabMiner gm;

	@Before
	public void setUp() throws Exception {
		String pvtToken = "null";
		gm = new GitLabMiner(pvtToken);
	}

	@After
	public void tearDown() throws Exception {
	}
	
	@Test
	public void testMineForkedProjects() throws Exception {
		String input = "src/test/resources/platform/projects.csv";
		FileReader reader = new FileReader(input);
		String output = "src/test/resources/platform/projectsWithFork.csv";
		FileWriter writer = new FileWriter(output);
		gm.mineForkedProjects(reader, writer);
	}
	
	@Ignore
	@Test
	public void testUpdateIssueStats() throws Exception {
		
		String input = "src/test/resources/platform/issues_200204-105339.csv";
		FileReader reader = new FileReader(input);
		String output = "src/test/resources/platform/issues_update.csv";
		FileWriter writer = new FileWriter(output);
		gm.updateIssueStats(reader, writer);
		
		CSVParser parser = CSVParser.parse(new FileReader(output), CSVFormat.DEFAULT.withHeader());
		List<CSVRecord> records = parser.getRecords();
		int size = records.size();
		assertEquals(10,size);
		
		CSVRecord csvRecord = records.get(0);
		String linkToIssue = csvRecord.get("linkToOpenedIssue");
		String expectedLink = "https://gitlab.com/mauriciobaeza/empresa-libre/issues/368";
		assertEquals(expectedLink, linkToIssue);
	}
	
	@Ignore
	@Test
	public void testUpdateFixingCommitStats() throws Exception {
		
		String input = "src/test/resources/platform/issues_200205-180807.csv";
		FileReader reader = new FileReader(input);
		String output = "src/test/resources/platform/issues_updateFix.csv";
		FileWriter writer = new FileWriter(output);
		gm.updateFixingCommitStats(reader, writer);
		
		CSVParser parser = CSVParser.parse(new FileReader(output), CSVFormat.DEFAULT.withHeader());
		List<CSVRecord> records = parser.getRecords();
		int size = records.size();
		assertEquals(10,size);
		
		CSVRecord csvRecord = records.get(0);
		String linkToIssue = csvRecord.get("linkToOpenedIssue");
		String expectedLink = "https://gitlab.com/mauriciobaeza/empresa-libre/issues/368";
		assertEquals(expectedLink, linkToIssue);
	}
	
	@Ignore
	@Test
	public void testGetCommits() {
		String projectId = "deltares%2Frtc-tools";
		String updatedAfter = "2019-08-16T06:47:23.067Z";
		List<Commit> commits = gm.getCommits(projectId, updatedAfter);
		
		assertEquals(76, commits.size());
	}
	
	@Ignore
	@Test
	public void testGetCommit() {
		String projectId = "agrumery%2FaGrUM";
		String sha = "52a4c77a6b89a755ed6f51307cd881edd01d911f";
		
		Commit commit = gm.getCommit(projectId, sha);
		
		assertNotNull(commit);
		
		String authored_date = commit.getAuthored_date();
		assertEquals("2019-12-09T13:52:24.000+00:00", authored_date);
		
		sha = "bla";
		commit = gm.getCommit(projectId, sha);
		
		assertNull(commit);
	}
	
	@Ignore
	@Test
	public void testGetContributorsFromCommits() {
		String projectId = "deltares%2Frtc-tools";
		String updatedAfter = "2019-08-16T06:47:23.067Z";
		List<Commit> commits = gm.getCommits(projectId, updatedAfter);
		
		Set<Contributor> contributorsFromCommits = gm.getContributorsFromCommits(commits);
		
		System.out.println("----");
		for(Contributor c: contributorsFromCommits) {
			System.out.println(c.getEmail());
		}
		
		assertEquals(4, contributorsFromCommits.size());
	}
	
	@Ignore
	@Test
	public void testGetContributors() {
		String projectId = "deltares%2Frtc-tools";
		
		List<Contributor> contributors = gm.getContributors(projectId);
		
		System.out.println("----");
		for(Contributor c: contributors) {
			System.out.println(c.getEmail());
		}
		
		assertEquals(12, contributors.size());
	}
	
	@Ignore
	@Test
	public void testCheckForkedFrom() {
		String projectId = "jimmynash%2Fprairiebowmen";
		String checkForkedFrom = gm.checkForkedFrom(projectId);
		assertEquals("TRUE", checkForkedFrom);
		
		projectId = "carminevassallo%2Fgame";
		checkForkedFrom = gm.checkForkedFrom(projectId);
		assertEquals("FALSE", checkForkedFrom);
	}
	
	@Ignore
	@Test
	public void testIssueById() throws Exception {

		String projectId = "deltares%2Frtc-tools";
		String issueId = "1117";
		
		Issue issue = gm.getIssueById(projectId, issueId);
		
		System.out.println(issue.getCreated_at());
		
		assertEquals(issueId, issue.getIid());
		assertEquals("closed", issue.getState());
		assertEquals(0, issue.getDownvotes());
		
		
		String fakeIssueId = "null";
		Issue notExtIssue = gm.getIssueById(projectId, fakeIssueId );
		
		assertEquals(null, notExtIssue);	
	}

}
