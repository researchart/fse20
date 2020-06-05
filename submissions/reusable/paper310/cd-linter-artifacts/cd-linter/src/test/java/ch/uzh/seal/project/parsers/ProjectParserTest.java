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
package ch.uzh.seal.project.parsers;

import static org.junit.Assert.*;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import ch.uzh.seal.project.entities.LintProject;

public class ProjectParserTest {

	private ProjectParser projectParser;
	private String token;

	@Before
	public void setUp() throws Exception {
		token = "fakeToken";
		projectParser = new ProjectParser(token);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testGetProjectsFromCSVSheet() {
		String path = "src/main/resources/sampleDataset.csv";
		List<LintProject> projects = projectParser.getProjectsFromCSVSheet(path);
		
		assertEquals(4, projects.size());
		
		LintProject actualProject = projects.get(3);
		
		String remotePath = "https://gitlab.com/assembl/assembl";
		String name = "assembl__assembl";
		String language = "JavaScript";
		String owner = "assembl";
		String repository = "assembl/assembl";
		String numCommitsInLastThreeMonths = "10000";
		String numIssuesOpenedInLastThreeMonths = "10000";
		LintProject exptectedProject = new LintProject();
		exptectedProject.setRemotePath(remotePath);
		exptectedProject.setName(name);
		exptectedProject.setLanguage(language);
		exptectedProject.setAccessToken(token);
		exptectedProject.setOwner(owner);
		exptectedProject.setRepository(repository);
		exptectedProject.setNumCommitsInLastThreeMonths(Integer.parseInt(numCommitsInLastThreeMonths));
		exptectedProject.setNumIssuesOpenedInLastThreeMonths(Integer.parseInt(numIssuesOpenedInLastThreeMonths));
		
		assertEquals(exptectedProject, actualProject);
	}

}
