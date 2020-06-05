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

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Set;

import ch.uzh.seal.app.IoUtil.OrderBy;

public class run_sampling {

	// SELECT category, COUNT(category) FROM Issue GROUP BY category
	// "Job-Retry",928
	// "Job-Allow-Failure",788
	// "Versioning",683
	// "Manual-Job",269
	// "Vulnerability",100

	private static final String SQLITE_PATH = "/Users/seb/workspaces/sts4/vampire/db.sqlite";
	private static final String ACTIVITY_PATH = "/Users/seb/versioned/documents/paper-vassallo2019-cd-linter/resources/anti-patterns-validation/numIssuesUpdated.csv";
	private static final int MAX_SAMPLING = 60;

	private static Connection conn;

	public static void main(String[] args) throws SQLException {
		conn = DriverManager.getConnection("jdbc:sqlite:" + SQLITE_PATH);

		Set<String> cats = getCategoriesOrderedByFrequency();

		Set<String> activeProjects = IoUtil.getActiveOwners(OrderBy.Issues);

		Set<String> selectedIds = new HashSet<>();
		Set<String> selectedProjects = new HashSet<>();

		for (String cat : cats) {
			System.out.println("## " + cat);
			Set<String> selectedCatIds = new HashSet<>();
			Iterator<String> it = activeProjects.iterator();
			while (it.hasNext() && selectedCatIds.size() < MAX_SAMPLING) {
				String project = it.next();
				String sql = "SELECT id FROM Issue WHERE category = '" + cat + "' AND linkToRepository LIKE '%"
						+ project + "'";
				ResultSet res = conn.createStatement().executeQuery(sql);
				if (res.next() && !selectedProjects.contains(project)) {
					selectedCatIds.add(res.getString("id"));
					selectedProjects.add(project);
					it.remove();
				}
			}

			System.out.printf("%d active projects found\n", selectedCatIds.size());

			String sql = "SELECT id, linkToRepository FROM Issue WHERE category = '" + cat + "'";
			ResultSet res = conn.createStatement().executeQuery(sql);
			while (res.next() && selectedCatIds.size() < MAX_SAMPLING) {
				String id = res.getString("id");
				String project = res.getString("linkToRepository").substring("https://gitlab.com/".length());

				if (!selectedCatIds.contains(id) && !selectedProjects.contains(project)) {
					selectedCatIds.add(id);
					selectedProjects.add(project);
				}
			}

			if (selectedCatIds.size() < MAX_SAMPLING) {
				String msg = String.format("WARN: only %d issues found for category %s", selectedCatIds.size(), cat);
				System.err.println(msg);
			} else {
				String msg = String.format("%d issues found for category %s", selectedCatIds.size(), cat);
				System.out.println(msg);
			}
			selectedIds.addAll(selectedCatIds);
		}

		String sql = "SELECT id FROM Issue";
		ResultSet res = conn.createStatement().executeQuery(sql);
		while (res.next()) {
			String id = res.getString("id");
			if (!selectedIds.contains(id)) {
				exec("DELETE FROM Issue WHERE id = \"" + id + "\"");
				exec("DELETE FROM Issue_tags WHERE Issue_id = \"" + id + "\"");
				exec("DELETE FROM Rating WHERE id = \"" + id + "\"");
			}
		}

	}

	private static void exec(String sql) throws SQLException {
		System.out.println(sql);
		conn.createStatement().execute(sql);
	}

	private static Set<String> getCategoriesOrderedByFrequency() throws SQLException {
		Set<String> cats = new LinkedHashSet<>();
		Statement stmt = conn.createStatement();
		// ResultSet res = stmt
		// .executeQuery("SELECT category, COUNT(category) AS count FROM Issue GROUP BY
		// category ORDER BY count");
		ResultSet res = stmt.executeQuery("SELECT category, COUNT(category) AS count "
				+ "FROM (SELECT DISTINCT linkToRepository, category FROM Issue) "
				+ "GROUP BY category  ORDER BY count");
		System.out.println("<category>\t<count>");
		while (res.next()) {
			String cat = res.getString("category");
			cats.add(cat);
			System.out.printf("%s\t%s\n", cat, res.getString("count"));
		}

		return cats;
	}
}