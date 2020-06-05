package ch.uzh.seal.app;

import java.util.Set;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.readers.CIAntiPatternCSVReader;
import ch.uzh.seal.stats.StatsCalculator;

public class StatsPrinter {

	private static final String PATH_ANTI_PATTERN_CSV = VampirePusher.PATH_ANTI_PATTERN_CSV;;

	public static void main(String[] args) {
		StatsPrinter statsPrinter = new StatsPrinter();
		statsPrinter.print();
	}

	private void print() {
		CIAntiPatternCSVReader ciAntiPatternCSVReader = new CIAntiPatternCSVReader(PATH_ANTI_PATTERN_CSV);

		Set<CIAntiPattern> ciAntiPatternSet = null;
		ciAntiPatternSet = ciAntiPatternCSVReader.read();

		StatsCalculator statsCalculator = new StatsCalculator(ciAntiPatternSet);
		System.out.println("Number of violations: " + statsCalculator.getNumberOfViolations());
		System.out.println("Number of violations per category: " + statsCalculator.getNumberOfViolationsPerCategory());
		System.out.println("Number of projects: " + statsCalculator.getNumberOfProjects());
		System.out.println("Number of projects per category: " + statsCalculator.getNumberOfProjectsPerCategory());
		System.out.println("Number of owners: " + statsCalculator.getNumberOfOwners());
		System.out.println("Number of owners per category: " + statsCalculator.getNumberOfOwnersPerCategory());
	}
}
