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
package ch.uzh.seal.antipattern.readers;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

public class CIAntiPatternCSVReaderTest {

	private CIAntiPatternCSVReader reader;

	@Before
	public void setUp() throws Exception {
		String input = "src/test/resources/occurrences.csv";
		reader = new CIAntiPatternCSVReader(input);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testRead() {
		Set<CIAntiPattern> antipatterns = reader.read();
		
		assertEquals(10, antipatterns.size());
		Set<CIAntiPattern> expectedAntipatterns = generateAntipatterns();
		assertEquals(expectedAntipatterns,antipatterns);
	}

	private Set<CIAntiPattern> generateAntipatterns(){

		Set<CIAntiPattern> antipatterns = new HashSet<>();

		for(int i = 0; i < 10; i++) {
			String id = "anti-" + i;
			String remoteRepoLink = "https://gitlab.com/psono/psono-server";
			String localCfgLink = "psono/psono-server";
			String remoteCfgLink = "https://gitlab.com/psono/psono-server/.gitlab-ci.yml";
			String project = "psono/psono-server";
			String stage = "test";
			String category = "versioning";
			String subCategory = "missing";
			String entity = "bla";
			String message = "look at this smell";
			String context = "";
			String cfgFileName = ".gitlab-ci.yml";
			String lineNumber = "34";
			CIAntiPattern antiPattern = new CIAntiPattern(id, remoteRepoLink, remoteCfgLink, localCfgLink, 
					project, stage, category, subCategory, entity, message, context, lineNumber, 
					cfgFileName);
			antipatterns.add(antiPattern);
		}

		return antipatterns;
	}

}
