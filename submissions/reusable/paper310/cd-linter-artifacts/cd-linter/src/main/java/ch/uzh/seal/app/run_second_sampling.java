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

import static java.lang.String.format;

import java.io.IOException;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.function.Function;
import java.util.stream.Collector;
import java.util.stream.Collectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.readers.CIAntiPatternCSVReader;
import ch.uzh.seal.antipattern.writers.CIAntiPatternCSVWriter;

public class run_second_sampling {

	private static Set<CIAntiPattern> CIAS_RAW = new CIAntiPatternCSVReader("target/CI-anti-patterns.csv").read();
	private static Set<CIAntiPattern> CIAS_ALL = null;//new CIAntiPatternCSVReader(run_sampling2.PATH_CIA_ALL).read();
	private static Set<CIAntiPattern> CIAS_SAMPLED = new CIAntiPatternCSVReader(run_sampling2.PATH_CIA_SAMPLED).read();

	private static Map<String, Integer> SAMPLE_SIZES = new LinkedHashMap<String, Integer>();

	public static void main(String[] args) throws IOException {

		SAMPLE_SIZES.put("Job-Allow-Failure", 87);
		SAMPLE_SIZES.put("Job-Retry/always", 19);
		SAMPLE_SIZES.put("Job-Retry/script_failure", 1);
		SAMPLE_SIZES.put("Job-Retry/stuck_or_timeout_failure", 1);
		SAMPLE_SIZES.put("Manual-Job", 21);
		SAMPLE_SIZES.put("Versioning/any-minor-number", 2);
		SAMPLE_SIZES.put("Versioning/any-upper-version", 43);
		SAMPLE_SIZES.put("Versioning/missing", 204);
		SAMPLE_SIZES.put("Versioning/only-major-number", 9);
		SAMPLE_SIZES.put("Vulnerability", 41);

		Set<CIAntiPattern> noOverlapWithSample = CIAS_RAW.stream().//
				filter(cia -> !CIAS_SAMPLED.contains(cia)).//
				collect(Collectors.toSet());
		Set<CIAntiPattern> uniqueOwnerTypeSubcategory = reduceToUniqueOwnerTypeSubcategory(noOverlapWithSample);

		System.out.printf("#CIAs in 'all' (ungrouped): %d\n", CIAS_RAW.size());
		System.out.printf("#CIAs in 'sample': %d\n", CIAS_SAMPLED.size());
		System.out.printf("#CIAs remaining: %d\n\n", noOverlapWithSample.size());
		System.out.printf("#CIAs uniqueOwnerTypeSubcategory: %d\n\n", uniqueOwnerTypeSubcategory.size());

		printStatsAboutGrouping(CIAS_RAW, "raw");
		printStatsAboutGrouping(CIAS_SAMPLED, "sample");
		printStatsAboutGrouping(noOverlapWithSample, "noOverlapWithSample");
		printStatsAboutGrouping(uniqueOwnerTypeSubcategory, "uniqueOwnerTypeSubcategory");

		reportCategoryCounts(CIAS_RAW, "raw");
		reportCategoryCounts(noOverlapWithSample, "noOverlapWithSample");
		reportCategoryCounts(uniqueOwnerTypeSubcategory, "uniqueOwnerTypeSubcategory");

		printSampleSize(SAMPLE_SIZES, "orig");
		Map<String, Integer> sampleSizeExclSample = reduce(SAMPLE_SIZES, CIAS_SAMPLED);
		printSampleSize(sampleSizeExclSample, "orig\\{sample}");

		Set<CIAntiPattern> sample = sample(uniqueOwnerTypeSubcategory, sampleSizeExclSample);

		reportCategoryCounts(CIAS_SAMPLED, "sampled");
		reportCategoryCounts(sample, "final");

		// decide which sample to upload...
		// it is either 'uniqueOwnerTypeSubcategory' or 'sample'
		new CIAntiPatternCSVWriter(run_sampling2.PATH_CIA_SAMPLED_INTERNAL).write(uniqueOwnerTypeSubcategory);
		// new
		// CIAntiPatternCSVWriter(run_sampling2.PATH_CIA_SAMPLED_INTERNAL).write(sample);
	}

	private static Set<CIAntiPattern> sample(Set<CIAntiPattern> in, Map<String, Integer> sampleSizes) {
		HashSet<CIAntiPattern> out = new HashSet<CIAntiPattern>();

		Map<String, List<CIAntiPattern>> groups = in.stream()
				.collect(Collectors.groupingBy(cia -> typeSubcategory(cia)));

		for (String cat : groups.keySet()) {
			List<CIAntiPattern> list = groups.get(cat);
			list.stream().//
					limit(sampleSizes.get(cat)).//
					forEach(cia -> out.add(cia));
		}

		return out;
	}

	private static Set<CIAntiPattern> reduceToUniqueOwnerTypeSubcategory(Set<CIAntiPattern> tmp) {
		Map<String, List<CIAntiPattern>> categories = tmp.stream().//
				collect(Collectors.groupingBy(cia -> ownerTypeSubcategory(cia)));
		Set<CIAntiPattern> tmp2 = categories.values().stream().map(cias -> cias.get(0)).collect(Collectors.toSet());
		return tmp2;
	}

	private static Set<CIAntiPattern> subtract(Set<CIAntiPattern> all, Set<CIAntiPattern> sample,
			Function<? super CIAntiPattern, ? extends String> mapping) {

		Collector<CIAntiPattern, ?, Map<String, List<CIAntiPattern>>> grp = Collectors.groupingBy(mapping);

		Set<String> mappingInSample = sample.stream().collect(grp).keySet();

		Set<CIAntiPattern> noOverlapForMapping = all.stream().//
				filter(cia -> !mappingInSample.contains(mapping.apply(cia))).//
				collect(Collectors.toSet());

		return noOverlapForMapping;
	}

	private static Map<String, Integer> reduce(Map<String, Integer> sampleSizes, Set<CIAntiPattern> cias) {
		Map<String, Integer> res = new LinkedHashMap<>();

		Map<String, List<CIAntiPattern>> cats = cias.stream().//
				collect(Collectors.groupingBy(cia -> typeSubcategory(cia)));

		for (String key : sampleSizes.keySet()) {
			int numOrig = sampleSizes.get(key);
			int numCias = cats.containsKey(key) ? cats.get(key).size() : 0;
			if (numCias > numOrig) {
				System.err.printf("Category '%s' is overfilled!\n", key);
			}
			res.put(key, Math.max(0, numOrig - numCias));
		}

		Set<String> sampleKeys = sampleSizes.keySet();
		for (String key : cats.keySet()) {
			if (!sampleKeys.contains(key)) {
				String msg = format("CIAs added new category '%s', which is unknown in original sample sizes", key);
				throw new RuntimeException(msg);
			}
		}

		return res;
	}

	private static String typeSubcategory(CIAntiPattern cia) {
		return cia.getSubCategory() == null || cia.getSubCategory().isEmpty() ? cia.getCategory()
				: cia.getCategory() + "/" + cia.getSubCategory();
	}

	private static String ownerTypeSubcategory(CIAntiPattern cia) {
		return cia.getOwner() + cia.getCategory() + cia.getSubCategory();
	}

	private static String owner(CIAntiPattern cia) {
		return cia.getOwner();
	}

	private static String ownerType(CIAntiPattern cia) {
		return cia.getOwner() + cia.getCategory();
	}

	private static void printStatsAboutGrouping(Set<CIAntiPattern> cias, String qualifier) {

		Set<String> byOwner = cias.stream().//
				collect(Collectors.groupingBy(cia -> owner(cia))).keySet();

		Set<String> byOwnerType = cias.stream().//
				collect(Collectors.groupingBy(cia -> ownerType(cia))).keySet();

		Set<String> byOwnerTypesSubcat = cias.stream().//
				collect(Collectors.groupingBy(cia -> ownerTypeSubcategory(cia))).keySet();

		Set<String> byTypesSubcat = cias.stream().//
				collect(Collectors.groupingBy(cia -> typeSubcategory(cia))).keySet();

		System.out.printf("Grouping info for '%s':\n", qualifier);
		System.out.printf("\t%d  \tGROUP BY (owner)\n", byOwner.size());
		System.out.printf("\t%d  \tGROUP BY (owner+type)\n", byOwnerType.size());
		System.out.printf("\t%d  \tGROUP BY (owner+type+subcat)\n", byOwnerTypesSubcat.size());
		System.out.printf("\t%d  \tGROUP BY (type+subcat)\n", byTypesSubcat.size());
		System.out.println();
	}

	private static void reportCategoryCounts(Set<CIAntiPattern> allButSample, String qualifier) {
		Map<String, List<CIAntiPattern>> categories = allButSample.stream().//
				collect(Collectors.groupingBy(cia -> typeSubcategory(cia)));

		System.out.printf("Category counts for '%s':\n", qualifier);
		int total = 0;
		for (String category : new TreeSet<String>(categories.keySet())) {
			int size = categories.get(category).size();
			total += size;
			System.out.printf("- %dx\t%s\n", size, category);
		}
		System.out.printf("-> %dx\tTotal\n", total);
		System.out.println();
	}

	private static void printSampleSize(Map<String, Integer> sampleSizes, String qualifier) {
		System.out.printf("Sample Sizes (%s):\n", qualifier);
		for (String key : sampleSizes.keySet()) {
			Integer val = sampleSizes.get(key);
			System.out.printf(" - %sx\t%s\n", val, key);
		}
		System.out.println();
	}
}