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

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Response;

import org.apache.commons.codec.Charsets;
import org.apache.commons.io.FileUtils;

public class run_import_ratings_and_linksToIssues {

	// private static final String URL_VAMPIRE = "http://build.kave.cc/vampire/";
	private static final String URL_VAMPIRE = "http://localhost:8080/";
	private static final String PATH_TO_RATINGS = "/Users/seb/Downloads/ratings_190816-173146.txt";

	public static void main(String[] args) {
		Set<String> invalids = new HashSet<>();
		invalids.add(null);
		invalids.add("null");
		invalids.add("NULL");
		invalids.add("");

		Map<String, String> links = IoUtil.readPushedIdsAndLinksToIssues();
		for (String id : links.keySet()) {
			String link = links.get(id);

			if (invalids.contains(id) || invalids.contains(link)) {
				// System.err.printf("skipping invalid (%s -> %s)\n", id, link);
				continue;
			}

			push("api/import/linkToIssue?id=%s&linkToIssue=%s", id, link);
		}

		// List<Rating> ratings = readRatings();
		// for (Rating r : ratings) {
		// push("api/import/rating?id=%s&name=%s&isValid=%b", r.id, r.name, r.isValid);
		// }
	}

	private static void push(String raw, Object... args) {
		String url = String.format(raw, args);
		System.out.println(url);
		WebTarget wt = VampirePusher.getWebTarget(URL_VAMPIRE + url);
		Response r = wt.request().get();
		if (r.getStatus() != 200) {
			String content = r.readEntity(String.class);
			if (!"link to issue did already exist".equals(content)) {
				System.err.println("ERROR: " + content);
			}
		}
	}

	private static List<Rating> readRatings() {
		List<Rating> ratings = new LinkedList<>();
		try {
			List<String> lines = FileUtils.readLines(new File(PATH_TO_RATINGS), Charsets.UTF_8);
			boolean isFirst = true;
			for (String line : lines) {
				if (isFirst) { // header
					isFirst = false;
					continue;
				}
				String[] parts = line.split("\t");
				Rating r = new Rating();
				r.id = parts[0];
				r.name = parts[1];
				r.isValid = Boolean.parseBoolean(parts[2]);
				ratings.add(r);
			}
			return ratings;
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private static class Rating {
		public String id;
		public String name;
		public boolean isValid;
	}
}