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
package ch.uzh.seal.app;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FileUtils;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.readers.CIAntiPatternCSVReader;
import ch.uzh.seal.templates.TemplateGeneration;

public class TemplateGenerator {

	public static final String JOB_NAME = "JOB_NAME";
	public static final String STAGE_NAME = "STAGE_NAME";
	public static final String FILE_NAME = "FILE_NAME";
	public static final String LINK_TO_FILE = "LINK_TO_FILE";
	public static final String LINE_NUMBER = "LINE_NUMBER";
	public static final String LINE_TEXT = "LINE_TEXT";
	public static final String RETRIES_NUMBER = "RETRIES_NUMBER";

	public static final String DEP_NAME = "DEP_LIST";
	public static final String SUB_CATEGORY_MSG = "SUB_CATEGORY_MSG";
	public static final String SUB_CATEGORY_ONLY_EXCEPT_MSG = "SUB_CATEGORY_ONLY_EXCEPT_MSG";

	public static final String VERSIONING_ONLY_MAJOR = "only-major-number";
	public static final String VERSIONING_MISSING = "missing-number";
	public static final String VERSIONING_ANY_MINOR = "any-minor-number";
	public static final String VERSIONING_ANY_UPPER = "any-upper-version";
	public static final String VERSIONING_ONLY_MAJOR_MSG = "only the major release is specified in the version number";
	public static final String VERSIONING_MISSING_MSG = "the version is not specified";
	public static final String VERSIONING_ANY_MINOR_MSG = "the minor release is not specified in the version number";
	public static final String VERSIONING_ANY_UPPER_MSG = "TODO";

	public static void main(String[] args) throws IOException {

		String dataFolder = args[0]; // <paper repository>/resources/anti-patterns-validation/
		String datasetFile = dataFolder + "/CI-anti-patterns-report.csv";

		CIAntiPatternCSVReader reader = new CIAntiPatternCSVReader(datasetFile);

		Set<CIAntiPattern> cias = reader.read();

		TemplateGeneration gen = new TemplateGeneration();

		List<String> coveredCats = new LinkedList<>();

		for (CIAntiPattern cia : cias) {

			String category = cia.getCategory();

			if (TemplateGeneration.JOB_CREATION_POLICY.equals(category)) {
				continue;
			}

			String[] titleDesc = gen.generateReport(cia);

			if (!coveredCats.contains(cia.getCategory())) {
				coveredCats.add(cia.getCategory());

				System.out.println("--------\n");
				System.out.printf("TITLE: '%s'\n", titleDesc[0]);
				System.out.printf("DESC: '%s'\n", titleDesc[1]);
			}
		}

	}

	public static Set<CIAntiPattern> readReport(File file) throws IOException {
		List<String> readLines = FileUtils.readLines(file, Charset.defaultCharset());

		Set<CIAntiPattern> cias = new HashSet<CIAntiPattern>();

		System.out.println(readLines.size());

		for (int i = 1; i < readLines.size(); i++) {
			String line = readLines.get(i);
			CIAntiPattern cia = parseLine(line);
			cias.add(cia);
		}
		return cias;
	}

	public static Set<CIAntiPattern> readCIAntipatternsFromIssues(File issuesFile) throws IOException {
		List<String> readLines = FileUtils.readLines(issuesFile, Charset.defaultCharset());

		Set<CIAntiPattern> cias = new HashSet<CIAntiPattern>();
		for (int i = 1; i < readLines.size(); i++) {
			String line = readLines.get(i);
			String[] splitLine = line.split(",");

			String id = splitLine[0];
			String category = splitLine[1];

			String[] splittedId = id.split("__");
			String owner = splittedId[0];
			String project = splittedId[1];

			String remoteRepoLink = "https://gitlab.com/" + owner + "/" + project;
			String remoteCfgLink = remoteRepoLink + "/blob/master/.gitlab-ci.yml";
			String localCfgLink = null;
			String projectName = owner + "/" + project;
			String stage = null;
			String subCategory = null;
			String entity = null;
			String message = null;
			String context = null;
			String lineNumber = null;
			String cfgFileName = ".gitlab-ci.yml";

			if (category.equalsIgnoreCase(TemplateGeneration.VULNERABILITY)) {
				entity = splittedId[3];
				message = splittedId[4];
			} else if (category.equalsIgnoreCase(TemplateGeneration.VERSIONING)) {
				cfgFileName = splittedId[3]; // in case of job we have a problem

				if (cfgFileName.equalsIgnoreCase("requirementstxt")) {
					remoteCfgLink = remoteRepoLink + "/blob/master/requirements.txt";
				}

				entity = splittedId[4]; // modify
				subCategory = splittedId[5];
			} else {
				entity = splittedId[3];
			}

			CIAntiPattern cia = new CIAntiPattern(id, remoteRepoLink, remoteCfgLink, localCfgLink, projectName, stage,
					category, subCategory, entity, message, context, lineNumber, cfgFileName);
			cias.add(cia);
		}
		return cias;
	}

	private static CIAntiPattern parseLine(String line) {
		String[] splitLine = line.split(",");

		String id = splitLine[0];
		String remoteRepoLink = splitLine[1];
		String remoteCfgLink = splitLine[2];
		String localCfgLink = splitLine[3];
		String project = splitLine[4];
		String stage = splitLine[5];
		String category = splitLine[6];
		String subCategory = splitLine[7];
		String entity = splitLine[8];
		String message = splitLine[9];
		String context = splitLine[10];
		String lineNumber = splitLine[11];
		String cfgFileName = splitLine[12];

		CIAntiPattern ci = new CIAntiPattern(id, remoteRepoLink, remoteCfgLink, localCfgLink, project, stage, category,
				subCategory, entity, message, context, lineNumber, cfgFileName);
		return ci;
	}

	public static String buildHeaderForProjects() {
		String header = "id,remoteRepoLink,remoteCfgLink,project,stage,category,subCategory,entity,message,lineNumber,cfgFileName,stars,forks";
		return header;
	}
}
