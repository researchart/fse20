package ch.uzh.seal.stats;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class StatsCalculator {

    private Set<CIAntiPattern> cias;

    public StatsCalculator(Set<CIAntiPattern> cias) {
        this.cias = cias;
    }

    public int getNumberOfViolations() {
        return cias.size();
    }

    public Map<String, Long> getNumberOfViolationsPerCategory() {
        return cias.stream()
                .collect(Collectors.groupingBy(CIAntiPattern::getCategory, Collectors.counting()));
    }

    public int getNumberOfProjects() {
        return cias.stream().collect(Collectors.groupingBy(CIAntiPattern::getProject)).size();
    }

    public Map<String, Integer> getNumberOfProjectsPerCategory() {
        Map<String, Map<String, List<CIAntiPattern>>> catProjectGroupBy = cias.stream()
                .collect(Collectors.groupingBy(CIAntiPattern::getCategory, Collectors.groupingBy(CIAntiPattern::getProject)));

        Map<String, Integer> result = new HashMap<>();
        for (String category : catProjectGroupBy.keySet()) {
            result.put(category, catProjectGroupBy.get(category).size());
        }
        return result;
    }

    public int getNumberOfOwners() {
        return cias.stream().collect(Collectors.groupingBy(CIAntiPattern::getOwner)).size();
    }

    public Map<String, Integer> getNumberOfOwnersPerCategory() {
        Map<String, Map<String, List<CIAntiPattern>>> catOwnerGroupBy = cias.stream()
                .collect(Collectors.groupingBy(CIAntiPattern::getCategory, Collectors.groupingBy(CIAntiPattern::getOwner)));

        Map<String, Integer> result = new HashMap<>();
        for (String category : catOwnerGroupBy.keySet()) {
            result.put(category, catOwnerGroupBy.get(category).size());
        }
        return result;
    }
}
