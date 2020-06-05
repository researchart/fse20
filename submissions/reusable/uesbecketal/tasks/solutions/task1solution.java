package solved;

import library.*;

public class Task1 {

	/**
	 * Please write this method to return a Table object containing all columns
	 * for all entries with an id smaller than 32 and sorted from high salary 
	 * to low salary
	 * 
	 * Table information:
	 * 
	 * - prof -
	 * 
	 * id (int) | firstname (String) | lastname (String) | salary (int) 
	 * | class (String)
	 * 
	 * 
	 * Use the technique shown to you in the samples given
	 * 
	 */
	public Table queryB(Table prof) throws Exception {
		Query q = new Query();

		q.Prepare("SELECT * FROM professors" +
		" WHERE id < 32 ORDER BY salary DESC");
		
		Table r = prof.Search(q);

		return r;
	}

	public Table queryA(Table prof) throws Exception {
		Query q = new Query();

		q.SortHighToLow("salary");
		q.Filter("id < 32");

		Table r = prof.Search(q);

		return r;
	}
	
	public Table queryC(Table prof) throws Exception {
		Query q = new Query();

		q.SortHighToLow("salary");
		q.Filter(q.Where("id").LessThan(32));
		
		Table r = prof.Search(q);

		return r;
	}

}