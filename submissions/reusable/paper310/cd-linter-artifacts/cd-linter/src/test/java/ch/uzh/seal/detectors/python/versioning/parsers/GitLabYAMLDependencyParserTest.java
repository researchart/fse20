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
package ch.uzh.seal.detectors.python.versioning.parsers;

import static org.junit.Assert.*;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import ch.uzh.seal.detectors.python.versioning.entities.Dependency;
import ch.uzh.seal.project.entities.LintProject;

public class GitLabYAMLDependencyParserTest {

	private LintProject project;

	@Before
	public void setUp() throws Exception {
		project = new LintProject();
        //project.setRepository("gitlab-org/omnibus-gitlab");
        project.setLocalPath("src/test/resources/gitlabyaml/vulnerability2");
	}

	@Ignore
	@Test
	public void testPipInstall() {
		GitLabYAMLDependencyParser parser = new GitLabYAMLDependencyParser();
		String fileContent = project.getFileContent(".gitlab-ci.yml");
		List<Dependency> parse = parser.parse(fileContent);
		assertEquals(3, parse.size());
		
		for(Dependency d: parse) {
			assertEquals("awscli", d.getName());
		}
	}
	
	@Test
	public void testPipInstall2() {
		GitLabYAMLDependencyParser parser = new GitLabYAMLDependencyParser();
		String fileContent = project.getFileContent(".gitlab-ci.yml");
		List<Dependency> parse = parser.parse(fileContent);
		// assertEquals(3, parse.size());
		
		for(Dependency d: parse) {
			System.out.println(d.getName());
		}
	}
	
	
	@After
	public void tearDown() throws Exception {
	}


}
