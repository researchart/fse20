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

import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.writers.CIAntiPatternCSVWriter;
import ch.uzh.seal.app.IoUtil.OrderBy;

public class run_sampling2 {

	public static final int SAMPLE_SIZE = 42;
	public static final String PATH_CIA_SAMPLED = "target/CI-anti-patterns.csv";
	public static final String PATH_CIA_SAMPLED_INTERNAL = "target/ciaSampleForInternalReview.csv";
	public static final String PATH_CIA_ALL = "target/ciaAllByOwnerAndCategory.csv";

	private final Set<CIAntiPattern> cias = IoUtil.readCIAntiPatterns();
	private final Set<String> pushedIds = new HashSet<>();//.readPushedIdsAndLinksToIssues().keySet();
	private final Set<String> activeOwnersByIssues = IoUtil.getActiveOwners(OrderBy.Issues);
	private final Set<String> activeOwnersByCommits = IoUtil.getActiveOwners(OrderBy.Commits);

	public static void main(String[] args) {
		new run_sampling2().run();
	}

	private void run() {
		Set<CIAntiPattern> pushedValidIssues = findValidPushedIssues();
		Set<CIAntiPattern> pushedValidIssuesGroupByOwner = groupValidIssuesByOwner(pushedValidIssues);
		System.out.printf(
				"From %d originally opened issues, %d are still valid, but only %d can be selected due to grouping\n\n",
				pushedIds.size(), pushedValidIssues.size(), pushedValidIssuesGroupByOwner.size());

		Set<CIAntiPattern> noOpenIssues = findCiasForWhichTheOwnersDoNotHaveOpenIssues();
		Set<CIAntiPattern> onePerOwner = findOneIssuePerOwner(noOpenIssues);
		Set<CIAntiPattern> workingSet = new LinkedHashSet<>();
		workingSet.addAll(onePerOwner);
		workingSet.addAll(pushedValidIssuesGroupByOwner);
		Set<CIAntiPattern> allIssuesByOwnerAndType = findAllIssuesByOwnerAndType();

		System.out.printf("The detectors find %d CI Anti-Patterns\n", cias.size());
		System.out.printf("%d remain when filtering owners, for which we have already opened an issue\n",
				noOpenIssues.size());
		System.out.printf("%d remain when we only select one issue per owner\n", onePerOwner.size());
		System.out.printf("Adding the opened issues, we end up with %d CI Anti-Patterns\n\n", workingSet.size());

		printFreqForInvalidOpenedIssues();
		// printTypeFrequency(pushedValidIssues, "\"pushedIssues\"");
		// printTypeFrequency(pushedValidIssuesGroupByOwner,
		// "\"pushedIssues.groupBy(Owner+cat)\"");
		printTypeFrequency(workingSet, "\"workingSet -- groupBy(Owner)\"");
		// printTypeFrequency(findAllIssuesByOwner(), "\"all.groupBy(owner)\"");
		printTypeFrequency(allIssuesByOwnerAndType, "\"all.groupBy(owner+category)\"");

		Set<CIAntiPattern> sampledByOwner = sample(workingSet, pushedValidIssuesGroupByOwner, SAMPLE_SIZE);

		write(allIssuesByOwnerAndType, PATH_CIA_ALL);
		write(sampledByOwner, PATH_CIA_SAMPLED);
	}

	private void write(Collection<CIAntiPattern> x, String path) {
		System.out.printf("Writing %s ... (%d entries)\n", path, x.size());
		try {
			new CIAntiPatternCSVWriter(path).write(x);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private Set<CIAntiPattern> sample(Set<CIAntiPattern> candidates, Set<CIAntiPattern> pushed, int sampleSize) {
		if (candidates.size() < pushed.size()) {
			throw new RuntimeException("#candidates < #pushed... this cannot be!");
		}

		Set<String> categories = candidates.stream().collect(Collectors.groupingBy(cia -> cia.getCategory())).keySet();

		Set<CIAntiPattern> out = new LinkedHashSet<>();
		for (String category : categories) {
			Set<CIAntiPattern> catOut = new LinkedHashSet<>();

			System.out.printf("### %s ###\n", category);

			Set<CIAntiPattern> catCandidates = candidates.stream().//
					filter(cia -> category.equals(cia.getCategory())).//
					collect(Collectors.toSet());
			System.out.printf("%s candidates\n", catCandidates.size());

			Set<CIAntiPattern> byIssue = findActive(category, activeOwnersByIssues, catCandidates);
			Set<CIAntiPattern> byCommits = findActive(category, activeOwnersByCommits, catCandidates);
			System.out.printf("active:\n\t%d by issue\n\t%d by commits\n", byIssue.size(), byCommits.size());

			Set<CIAntiPattern> catPushed = pushed.stream().//
					filter(cia -> category.equals(cia.getCategory())).//
					collect(Collectors.toSet());
			System.out.printf("\nselected %s because they were pushed before\n", catPushed.size());

			catOut.addAll(catPushed);

			int totalByIssue = 0;
			Iterator<CIAntiPattern> it = byIssue.iterator();
			while (catOut.size() < sampleSize && it.hasNext()) {
				CIAntiPattern next = it.next();
				if (!catOut.contains(next)) {
					catOut.add(next);
					totalByIssue++;
				}
			}
			System.out.printf("selected %d by issue activity (%d)\n", totalByIssue, catOut.size());

			int totalByCommits = 0;
			it = byCommits.iterator();
			while (catOut.size() < sampleSize && it.hasNext()) {
				CIAntiPattern next = it.next();
				if (!catOut.contains(next)) {
					catOut.add(next);
					totalByCommits++;
				}
			}
			System.out.printf("selected %d by commit activity (%d)\n", totalByCommits, catOut.size());

			int totalRnd = 0;
			for (CIAntiPattern cia : catCandidates) {
				if (catOut.size() < sampleSize && !catOut.contains(cia)) {
					catOut.add(cia);
					totalRnd++;
				}
			}
			System.out.printf("selected %d randomly (%d)\n", totalRnd, catOut.size());

			System.out.printf("--> %d\n\n", catOut.size());
			out.addAll(catOut);
		}

		return out;
	}

	private Set<CIAntiPattern> findActive(String category, Set<String> activeOwners, Set<CIAntiPattern> candidates) {
		Set<CIAntiPattern> res = new LinkedHashSet<>();
		for (String o : activeOwners) {
			for (CIAntiPattern cia : candidates) {
				if (o.equals(cia.getOwner()) && category.equals(cia.getCategory())) {
					res.add(cia);
				}
			}
		}
		return res;
	}

	private Set<CIAntiPattern> groupValidIssuesByOwner(Set<CIAntiPattern> pushedValidIssues) {

		Map<String, List<CIAntiPattern>> res = pushedValidIssues.stream().//
				collect(Collectors.groupingBy(cia -> cia.getOwner()));

		Set<CIAntiPattern> pushedValidIssuesGroupByOwner = res.values().stream().//
				map(a -> a.get(0)).//
				collect(Collectors.toSet());

		return pushedValidIssuesGroupByOwner;
	}

	private void printFreqForInvalidOpenedIssues() {
		Map<String, Integer> counts = new HashMap<String, Integer>();

		Set<String> currentIds = cias.stream().map(cia -> cia.getId()).collect(Collectors.toSet());

		for (String id : pushedIds) {
			if (!currentIds.contains(id)) {
				for (String type : new String[] { "Job-Allow-Failure", "Versioning", "Job-Retry", "Vulnerability",
						"Manual-Job" }) {
					if (id.contains(type)) {
						if (counts.containsKey(type)) {
							counts.put(type, counts.get(type) + 1);
						} else {
							counts.put(type, 1);
						}
					}
				}
			}
		}
		System.out.printf(
				"Frequency of the various anti-pattern types that have previously been pushed, but that are no longer valid:\n");
		long total = 0;
		for (Object type : counts.keySet()) {
			int count = counts.get(type);
			System.out.printf(" - %s\t%d\n", type, count);
			total += count;
		}
		System.out.printf(" - total\t%d\n\n", total);
	}

	private void printTypeFrequency(Set<CIAntiPattern> cs, String qualifier) {
		Map<Object, Long> typeCounts = countFrequencyOfIssueTypes(cs);
		System.out.printf("Frequency of the various anti-pattern types (%s):\n", qualifier);
		long total = 0;
		for (Object type : typeCounts.keySet()) {
			Long count = typeCounts.get(type);
			System.out.printf(" - %s\t%d\n", type, count);
			total += count;
		}
		System.out.printf(" - total\t%d\n\n", total);
	}

	private Map<Object, Long> countFrequencyOfIssueTypes(Set<CIAntiPattern> in) {
		return in.stream().//
				collect(Collectors.groupingBy(cia -> cia.getCategory(), Collectors.counting()));
	}

	private Set<CIAntiPattern> findAllIssuesByOwner() {
		Map<String, List<CIAntiPattern>> tmp = cias.stream().//
				collect(Collectors.groupingBy(cia -> cia.getOwner()));

		Set<CIAntiPattern> out = tmp.values().stream().//
				map(cias -> cias.get(0)).//
				collect(Collectors.toSet());

		return out;
	}

	private Set<CIAntiPattern> findAllIssuesByOwnerAndType() {
		Map<String, List<CIAntiPattern>> tmp = cias.stream().//
				collect(Collectors.groupingBy(cia -> cia.getOwner() + cia.getCategory()));

		Set<CIAntiPattern> out = tmp.values().stream().//
				map(cias -> cias.get(0)).//
				collect(Collectors.toSet());

		return out;
	}

	private Set<CIAntiPattern> findCiasForWhichTheOwnersDoNotHaveOpenIssues() {
		Set<String> ownersWithPushedIssues = cias.stream().//
				filter(cia -> pushedIds.contains(cia.getId())).//
				map(cia -> cia.getOwner()).//
				collect(Collectors.toSet());
		return cias.stream().//
				filter(cia -> !ownersWithPushedIssues.contains(cia.getOwner())).//
				collect(Collectors.toSet());
	}

	private Set<CIAntiPattern> findOneIssuePerOwner(Set<CIAntiPattern> in) {
		Map<String, List<CIAntiPattern>> tmp = in.stream().//
				collect(Collectors.groupingBy(cia -> cia.getOwner()));

		Set<CIAntiPattern> out = tmp.values().stream().//
				map(cias -> cias.get(0)).//
				collect(Collectors.toSet());

		return out;
	}

	private Set<CIAntiPattern> findValidPushedIssues() {
		return cias.stream().//
				filter(cia -> pushedIds.contains(cia.getId())).//
				collect(Collectors.toSet());
	}
}