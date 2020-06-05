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
package ch.uzh.seal.detectors.gitlabyaml.detectors;

import static org.junit.Assert.*;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;

public class GitLabYAMLDuplicateLibrariesTest {

	private static LintProject project;
	
	@Before
	public void setUp() throws Exception {
		project = new LintProject();
        project.setLocalPath("src/test/resources/gitlabyaml/duplicate");
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testLint() throws Exception {
		List<CIAntiPattern> antiPatterns = new GitLabYAMLDuplicateLibraries(project).lint();
	    
		assertEquals(3, antiPatterns.size());
		
		String firstMessage = "mvn install:install-file -Dfile=blabla -DgroupId=hello";
		assertEquals(firstMessage, antiPatterns.get(0).getMessage());
		
		String thirdMessage = "mvn deploy:deploy-file -Dfile=blabla -DgroupId=hello";
		assertEquals(thirdMessage, antiPatterns.get(2).getMessage());
	}

}
