package ch.uzh.seal.antipattern.writers;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

public class CIAntiPatternCSVWriter{


	public static String[] headerFields = new String[] { "ID", "Repository Link", "Remote Configuration File Link",
			"Local Configuration File Link", "Project", "Category", "Sub-Category", "Stage", "Entity", "Message",
			"Line-Number", "Configuration File Name", "Owner", "Repository Name" };

	private CSVPrinter printer;


	public CIAntiPatternCSVWriter(String outputPath) throws IOException {
		FileWriter output = new FileWriter(new File(outputPath));
		printer = new CSVPrinter(output, CSVFormat.DEFAULT);
		List<String> headerAsList = Arrays.asList(headerFields);
		printer.printRecord(headerAsList); // print the new header
		
	}

	public void write(CIAntiPattern antiPattern) throws IOException {
		// String row = String.join(delimiter, extractFields(antiPattern));
		
		String remoteRepoLink = antiPattern.getRemoteRepoLink();
		String fullRepoName = remoteRepoLink.substring(19);
		String owner = fullRepoName.split("/")[0];
		
		printer.printRecord(antiPattern.getId(), antiPattern.getRemoteRepoLink(), antiPattern.getRemoteCfgLink(),
				antiPattern.getLocalCfgLink(), antiPattern.getProject(), antiPattern.getCategory(),
				antiPattern.getSubCategory(), antiPattern.getStage(), antiPattern.getEntity(), antiPattern.getMessage(),
				antiPattern.getLineNumber(), antiPattern.getCfgFileName(), owner, fullRepoName);
				
		
	}

	public void write(Collection<CIAntiPattern> antiPatternList) throws IOException {
		for (CIAntiPattern antiPattern : antiPatternList) {

			write(antiPattern);
		}
	}
	
	public void close() throws IOException {
		printer.close();
	}
}