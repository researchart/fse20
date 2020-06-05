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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.io.FileUtils;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

public class CIAntiPatternCSVReader {

	public static String delimiter = "\t";
	private File inputFile;
	private CSVParser parser;

	public CIAntiPatternCSVReader(String inputPath){
		this.inputFile = new File(inputPath);
		
		try {
			FileReader reader = new FileReader(new File(inputPath));
			parser = CSVParser.parse(reader, CSVFormat.DEFAULT.withHeader());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public Set<CIAntiPattern> read() {
		List<CSVRecord> records = null;
		try {
			records = parser.getRecords();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		Set<CIAntiPattern> antipatterns = new HashSet<>();
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
		}

		return antipatterns; 
	}

	private CIAntiPattern parseLine(String line) {
		String[] splittedLine = line.split(delimiter);

		String id = splittedLine[0];
		String remoteRepoLink = splittedLine[1];
		String remoteCfgLink = splittedLine[2];
		String localCfgLink = splittedLine[3];
		String project = splittedLine[4];
		String stage = splittedLine[7];
		String category = splittedLine[5];
		String subCategory = splittedLine[6];
		String entity = splittedLine[8];
		String message = splittedLine[9];
		String context = "";
		String lineNumber = splittedLine[10];
		String cfgFileName = splittedLine[11];

		CIAntiPattern ca = new CIAntiPattern(id, remoteRepoLink, remoteCfgLink, localCfgLink, project, stage, category,
				subCategory, entity, message, context, lineNumber, cfgFileName);

		return ca;
	}
}
