package solved;

import library.*;

public class Task4 {

	/**
	 * Please write this method to return the Table object student with an entry
	 * changed. The entry for the student with the first name "Herbert" and the
	 * last name "Hauser" should be changed so that the grade is now "A".
	 * 
	 * Table information:
	 * 
	 * - students - 
	 * 
	 * id (int) | firstname (String) | lastname (String) | grade
	 * (String) | year (int) | class (String)
	 * 
	 * Use the technique shown to you in the samples given
	 * 
	 */
	public Table queryB(Table students) throws Exception {
		Query q = new Query();
		
		q.Prepare("UPDATE students SET grade = 'A' "+
			"WHERE firstname = 'Herbert' AND lastname = 'Hauser'");
		
		Table r = students.Search(q);
		
		return r;
	}

	public Table queryA(Table students) throws Exception {
		Query q = new Query();

		q.Replace("grade", "A");
		q.Filter("firstname = 'Herbert' and lastname = 'Hauser'");

		Table r = students.Update(q);
		
		return r;
	}
	
	public Table queryC(Table students) throws Exception {
		Query q = new Query();

		q.Replace("grade", "A");
		q.Filter(q.Where("firstname").Equals("Herbert")
			.And("lastname").Equals("Hauser"));

		Table r = students.Update(q);
		
		return r;
	}

}