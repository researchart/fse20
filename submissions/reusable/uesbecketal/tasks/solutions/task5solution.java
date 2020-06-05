package solved;

import library.*;

public class Task5 {

	/**
	 * Please write this method to return the Table object student with an entry
	 * added. The new entry should have the id "23", the first name "Tom", the
	 * last name "Young", the year "3", and the grade "C"
	 * 
	 * Table information:
	 * 
	 * - students - 
	 * 
	 * id (int) | firstname (String) | lastname (String) | grade | year
	 * (String) | year (int) | class (String)
	 * 
	 * 
	 * Use the technique shown to you in the samples given
	 * 
	 */

	public Table queryB(Table students) throws Exception {
		Query q = new Query();
		
		q.Prepare("INSERT INTO students (id, firstname, lastname, year, grade) "+
			"VALUES ('23', 'Tom', 'Young', 3, C)");
		
		Table r = students.Search(q);
		
		return r;
	}

	public Table queryA(Table students) throws Exception {
		Query q = new Query();

		q.IntoFields("id, firstname, lastname, year, grade");
		q.SetValues("23, 'Tom', 'Young', 3, 'C'");
		
		Table r = students.Insert(q);
		
		return r;
	}
	
	public Table queryC(Table students) throws Exception {
		Query q = new Query();

		q.AddValue("id", 23)
			.AddValue("firstname", "Tom")
			.AddValue("lastname", "Young")
			.AddValue("year", 3)
			.AddValue("grade", "C");

		Table r = students.Insert(q);
	
		return r;
	}

}