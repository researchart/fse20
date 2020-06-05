package ch.uzh.seal.utils;

import static org.apache.commons.codec.Charsets.UTF_8;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FileUtils;

public class ProcessedEntitiesReader {

	/**
	 * Get entities that have been processed already.
	 * 
	 * @param processedEntitiesPath
	 *            Path to the file containing the names of the processed entities.
	 * @return A set of entity names.
	 */
	public static Set<String> getProcessedEntities(String processedEntitiesPath) {

		Set<String> res = new HashSet<>();
		try {
			List<String> lines = FileUtils.readLines(new File(processedEntitiesPath), UTF_8);
			for (String line : lines) {
				line = line.trim();
				if (!line.isEmpty()) {
					res.add(line);
				}
			}
		} catch (IOException e1) {
			throw new RuntimeException(e1);
		}

		return res;
	}
}
