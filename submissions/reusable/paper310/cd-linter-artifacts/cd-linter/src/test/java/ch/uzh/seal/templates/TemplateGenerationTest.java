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
package ch.uzh.seal.templates;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

public class TemplateGenerationTest {

	private TemplateGeneration templateGeneration;
	private CIAntiPattern cia;

	@Before
	public void setUp() throws Exception {
		templateGeneration = new TemplateGeneration();
		String id = "id1";
		String remoteRepoLink = "https://blabla.com";
		String remoteCfgLink = "https://blabla.com/config.yml";
		String localCfgLink = "target/config.yml";
		String project = "contino";
		String stage = "test";
		String category = TemplateGeneration.VULNERABILITY;
		String subCategory = "a";
		String entity = "dep_name";
		String message = "blabla";
		String context = "bla bla";
		String lineNumber = "12";
		String cfgFileName = "config.yml";
		
		cia = new CIAntiPattern(id , remoteRepoLink, remoteCfgLink, localCfgLink, project, stage, category, subCategory, entity, message, context, lineNumber, cfgFileName);
		
		
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testGeneration() {
		
		String[] report = templateGeneration.generateReport(cia);
		
		String title = report[0];
		String desc = report[1];
		
		System.out.println(desc);
	}

}
