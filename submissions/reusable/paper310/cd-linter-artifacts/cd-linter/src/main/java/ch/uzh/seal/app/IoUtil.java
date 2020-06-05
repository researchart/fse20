/**
 * Copyright 2019 Sebastian Proksch
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package ch.uzh.seal.app;

import static org.apache.commons.codec.Charsets.UTF_8;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.codec.Charsets;
import org.apache.commons.io.FileUtils;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.readers.CIAntiPatternCSVReader;
import ch.uzh.seal.project.entities.LintProject;
import ch.uzh.seal.project.parsers.ProjectParser;

public class IoUtil {

	public enum OrderBy {
		Issues, Commits
	}

	public static final String FOLDER_LINKS_TO_ISSUES = "/Users/seb/Downloads/issue_mappings/";
	public static final String PATH_DATASET = "/Users/carminevassallo/Documents/CI-Linter/cd-linter-paper/resources/anti-patterns-validation/dataset.csv";//"/Users/seb/versioned/documents/paper-vassallo2019-cd-linter/resources/anti-patterns-validation/dataset.csv";
	public static final String PATH_CI_ANTI_PATTERNS = "target/CI-anti-patterns.csv";
	/**
	 * TODO: the token is passed as argument to the main class
	 */
	private static final String PATH_GIT_LAB_TOKEN = null;

	public static Set<String> getActiveOwners(OrderBy orderBy) {
		final Map<String, Integer> counts = readOwnerCounts(orderBy);

		Set<String> set = new TreeSet<String>(new Comparator<String>() {
			@Override
			public int compare(String a, String b) {
				if (!counts.containsKey(a) || !counts.containsKey(b)) {
					throw new RuntimeException("unknown key");
				}
				int numA = counts.get(a);
				int numB = counts.get(b);
				if (numA != numB)
					return numB - numA;
				return b.compareTo(a);
			}
		}) {
			private static final long serialVersionUID = 1L;

			@Override
			public boolean add(String s) {
				if (!counts.containsKey(s)) {
					throw new RuntimeException("unknown key: " + s);
				}
				return super.add(s);
			}
		};
		for (String key : counts.keySet()) {
			int value = counts.get(key);
			if (value > 0) {
				set.add(key);
			}
		}
		return set;
	}

	private static Map<String, Integer> readOwnerCounts(OrderBy orderBy) {
		Map<String, Integer> counts = new HashMap<>();

		List<LintProject> projects = new ProjectParser(PATH_GIT_LAB_TOKEN)
				.getProjectsFromCSVSheet(PATH_DATASET);
		for (LintProject p : projects) {
			int count = 0;

			switch (orderBy) {
			case Commits:
				count = p.getNumCommitsInLastThreeMonths();
				break;
			case Issues:
				count = p.getNumIssuesOpenedInLastThreeMonths();
				break;
			}

			String owner = p.getOwner();
			if (counts.containsKey(owner)) {
				int newCount = counts.get(owner) + count;
				counts.put(owner, newCount);
			} else {
				counts.put(owner, count);
			}
		}

		return counts;
	}

	public static Map<String, String> readPushedIdsAndLinksToIssues() {
		Map<String, String> links = new LinkedHashMap<>();
		try {

			File[] mappingFiles = new File(FOLDER_LINKS_TO_ISSUES).listFiles(new FilenameFilter() {
				public boolean accept(File dir, String name) {
					return name.endsWith(".txt");
				}
			});
			for (File f : mappingFiles) {
				readOneFile(f, links);
			}
			return links;
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private static void readOneFile(File f, Map<String, String> links) throws IOException {
		List<String> lines = FileUtils.readLines(f, Charsets.UTF_8);
		boolean isFirst = true;
		for (String line : lines) {
			if (isFirst) { // header
				isFirst = false;
				continue;
			}
			String[] parts = line.split("\t");
			links.put(parts[0], parts[1]);
		}
	}

	public static Set<CIAntiPattern> readCIAntiPatterns() {
		try {

			String content = FileUtils.readFileToString(new File(PATH_CI_ANTI_PATTERNS), UTF_8);
			if (content.contains("�")) {
				System.err.println("had to fix broken encoding");
				content = content.replaceAll("�", "");
				content = content.replaceAll("\\x00", "");
				FileUtils.writeStringToFile(new File(PATH_CI_ANTI_PATTERNS), content, Charsets.UTF_8);
			}
			return new CIAntiPatternCSVReader(PATH_CI_ANTI_PATTERNS).read();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}
}