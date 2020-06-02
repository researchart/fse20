package solved;

import library.*;

public class Task2 {

	/**
	 * Please write this method to return a Table object containing the columns
	 * id, year, and grade for all entries with lastname "Schmidt" who do not
	 * have a grade "F"
	 * 
	 * Table information:
	 * 
	 * - student - 
	 * 
	 * id (int) | firstname (String) | lastname (String) | grade
	 * (String) | year (int) | class (String)
	 * 
	 * Use the technique shown to you in the samples given
	 * 
	 */
	public Table queryB(Table students) throws Exception {
		Query q = new Query();
		
		q.Prepare("SELECT id, year, grade "+
			"FROM students " +
			"WHERE lastname = 'Schmidt' and grade != 'F'");
		
		Table r = students.Search(q);
				
		return r;
	}

	public Table queryA(Table students) throws Exception {
		Query q = new Query();
		
		q.AddFields("id, year, grade");

		q.Filter("lastname = 'Schmidt' and grade != 'F'");

		Table r = students.Search(q);
		
		return r;
	}
	
	public Table queryC(Table students) throws Exception {
		Query q = new Query();
	
		q.AddField("id")
			.AddField("year")
			.AddField("grade");
		
		q.Filter(q.Where("lastname").Equals("Schmidt").And("grade").NotEquals("F"));
		
		Table r = students.Search(q);
		
		return r;
	}

}