package solved;

import library.*;

public class Task6 {

	/**
	 * Please write this method to return a Table object containing the columns
	 * id, firstname, lastname, clubname of all students. 
	 * You will have to use data from clubmap to complete these requirements.
	 * 
	 * Table information:
	 * 
	 * - students -
	 * 
	 * id (int) | firstname (String) | lastname (String) | grade (String) | year
	 * (int) | birthyear (int)
	 * 
	 * - clubmap -
	 * 
	 * cid (int) | studentid (int) | clubname (String)
	 * 
	 * 
	 * Use the technique shown to you in the samples given
	 *
	 */
	public Table query(Table students, Table clubmap) throws Exception {
		Query q = new Query();

		q.Prepare("SELECT id, firstname, lastname, clubname "+
			"FROM students JOIN clubmap ON students.id = clubmap.studentid");

		Table r = students.Search(q, clubmap);

		return r;
	}

	public Table queryA(Table students, Table clubmap) throws Exception {
		Query q = new Query();

		q.AddFields("id, firstname, lastname, clubname");
		
		q.Combine(students, "id", clubmap, "studentid");
		
		Table r = students.Search(q);

		return r;
	}
	
	public Table queryC(Table students, Table clubmap) throws Exception {
		Query q = new Query();

		q.AddField("id")
			.AddField("firstname")
			.AddField("lastname")
			.AddField("clubname");
			
		q.Combine(students, "id", clubmap, "studentid");
		
		Table r = students.Search(q);

		return r;
	}

}