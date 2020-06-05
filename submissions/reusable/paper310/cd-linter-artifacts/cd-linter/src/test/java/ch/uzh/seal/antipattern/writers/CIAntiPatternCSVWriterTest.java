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
package ch.uzh.seal.antipattern.writers;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

public class CIAntiPatternCSVWriterTest {

	private CIAntiPatternCSVWriter ciWriter;
	private String output;
	private CSVParser parser;
	private List<CIAntiPattern> generatedAntipatterns;

	@Before
	public void setUp() throws Exception {
		output = "src/test/resources/occurrences.csv";
		ciWriter = new CIAntiPatternCSVWriter(output);
		generatedAntipatterns = generateAntipatterns();
		ciWriter.write(generatedAntipatterns);
		ciWriter.close();
		FileReader reader = new FileReader(new File(output));
		parser = CSVParser.parse(reader, CSVFormat.DEFAULT.withHeader());
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testSize() throws IOException {
		List<String> headerNames = parser.getHeaderNames();
		List<CSVRecord> records = parser.getRecords();
		assertEquals(10, records.size());
	}
	
	@Test
	public void testHeader() throws IOException {
		List<String> headerNames = parser.getHeaderNames();
		List<CSVRecord> records = parser.getRecords();
		CSVRecord csvRecord = records.get(0);
		List<String> expectedHeader = Arrays.asList(CIAntiPatternCSVWriter.headerFields);
		assertEquals(expectedHeader, headerNames);
	}
	
	@Test
	public void testWrittenAntipatterns() throws IOException {
		List<CSVRecord> records = parser.getRecords();
		List<CIAntiPattern> antipatterns = new ArrayList<>();
		for(CSVRecord csvRecord : records) {
			
			String id = csvRecord.get("ID");
			String remoteRepoLink = csvRecord.get("Repository Link");
			String remoteCfgLink = csvRecord.get("Remote Configuration File Link");
			String localCfgLink = csvRecord.get("Local Configuration File Link");
			String project = csvRecord.get("Project");
			String stage = csvRecord.get("Stage");
			String category = csvRecord.get("Category");
			String subCategory = csvRecord.get("Sub-Category");
			String entity = csvRecord.get("Entity");
			String message = csvRecord.get("Message");
			String context = "";
			String lineNumber = csvRecord.get("Line-Number");
			String cfgFileName = csvRecord.get("Configuration File Name");
			
			CIAntiPattern ca = new CIAntiPattern(id, remoteRepoLink, remoteCfgLink, localCfgLink, project, stage, category,
					subCategory, entity, message, context, lineNumber, cfgFileName);
			antipatterns.add(ca);
			
			//System.out.println(ca);
		}
		
		assertEquals(generatedAntipatterns, antipatterns);
	}
	
	private List<CIAntiPattern> generateAntipatterns(){
		
		List<CIAntiPattern> antipatterns = new ArrayList<>();
		
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
