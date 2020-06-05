package ch.uzh.seal.antipattern.writers;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.List;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

public class CIAntiPatternWriter {

	PrintWriter printWriter;

	public CIAntiPatternWriter(String outputPath) {
		printWriter = getWriter(outputPath);
	}

	private PrintWriter getWriter(String path) {

		try {
			File f = new File(path);
			if (f.exists()) {
				f.delete();
			}
			FileOutputStream fos = new FileOutputStream(path);
			return new PrintWriter(fos);
		} catch (FileNotFoundException e) {
			throw new RuntimeException(e);
		}
	}

	public void write(CIAntiPattern antiPattern) {
		printWriter.println("***********************************");
		printWriter.println("Project: " + antiPattern.getProject());
		printWriter.println("Category: " + antiPattern.getCategory());
		printWriter.println("Entity: " + antiPattern.getEntity());
		printWriter.println("Message: " + antiPattern.getMessage());
		printWriter.println("Context:\n" + antiPattern.getContext());
		printWriter.println("***********************************\n");

		printWriter.flush();
	}

	public void write(List<CIAntiPattern> antiPatternList) {
		for (CIAntiPattern antiPattern : antiPatternList) {
			write(antiPattern);
		}
	}

	public void close() {
		printWriter.close();
	}
}
