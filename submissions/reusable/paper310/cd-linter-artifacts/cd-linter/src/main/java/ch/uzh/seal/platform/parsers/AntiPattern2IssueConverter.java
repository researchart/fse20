package ch.uzh.seal.platform.parsers;

import java.net.MalformedURLException;
import java.net.URL;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.platform.entities.Issue;
import ch.uzh.seal.templates.TemplateGeneration;

public class AntiPattern2IssueConverter {

	public static final TemplateGeneration gen = new TemplateGeneration();

	public static Issue convert(CIAntiPattern cia) {
		Issue issue = new Issue();

		issue.id = cia.getId();

		try {
			issue.linkToRepository = new URL(cia.getRemoteRepoLink());
		} catch (MalformedURLException e) {
			throw new RuntimeException(e);
		}

		issue.category = cia.getCategory();
		if (!cia.getSubCategory().isEmpty()) {
			issue.tags.add(cia.getSubCategory().trim());
		}

		String[] titleAndDesc = gen.generateReport(cia);

		issue.title = titleAndDesc[0];
		issue.desc = titleAndDesc[1];

		return issue;
	}
}
