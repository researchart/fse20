import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.Test;

import library.Column;
import library.IntegerColumn;
import library.Query;
import library.SelectArg;
import library.SortOrder;
import library.StringColumn;
import library.Table;
import library.Task1;

public class Test1 {

	@Test
	public void test() throws Exception {
		Table prof = new Table();
		setUpProf(prof);
		Table query = new Task1().query(prof);

		if (query == null) {
			System.out.println("Null returned instead of table object");
		}
		
		Table result = altQuery2(prof);
		query.outputTable();
		
		System.out.println();
		System.out.println("Assertion Test results:");
		assertTrue(equals(result, query));
	}
	
	private boolean equals(Table result, Table query) {
		if (query == null ) {
			System.out.println("Returned table was null");
			return false;
		}
		List<Column<?>> columns = result.getColumns();
		List<Column<?>> columns2 = query.getColumns();
		
		for (int i = 0; i < columns.size(); i++) {
			Column<?> column = columns.get(i);
			String columnname = column.getName();
			
			Column<?> column2 = findColumnByName(columnname, columns2);
			if (column2 == null) {
				System.out.println("Could not find column: \"" + columnname + "\" in the returned table.");
				return false;
			}
			for (int j = 0; j < column.size(); j++) {
				Object x = column.get(j);
				if (column2.size() > j) { 
					Object y = column2.get(j);
					System.out.println("expected: " + x + " actual: " + y);
					if (!x.equals(y)) {
						System.out.println("Mismatch between items from returned table and solution!");
						return false;
					}
				} else {
					System.out.println("Fewer entries in returned table than necessary!");
					return false;
				}
				
			}
		}
		
		return true;
	}
	
	private Column findColumnByName(String name, List<Column<?>> columns) {
		for (int i = 0; i < columns.size(); i++) {
			Column<?> column = columns.get(i);
			if (column.getName().equals(name)) {
				return column;
			}
		}
		return null;
	}
	
	private Table altQuery2(Table professor) throws Exception {
		Query q = new Query();

		q.SortHighToLow("salary");
		q.Filter(q.Where("id").LessThan(32));
		
		Table r = professor.Search(q);

		return r;
	}


	private void setUpProf(Table prof) {
		StringColumn firstname = new StringColumn();
		firstname.setName("firstname");
		firstname.add("Abdrew");
		firstname.add("Moses");
		firstname.add("Sally");
		firstname.add("Laverne");
		firstname.add("Florence");
		firstname.add("Tracy");
		firstname.add("Alvin");
		prof.addColumn(firstname);

		StringColumn lastname = new StringColumn();
		lastname.setName("lastname");
		lastname.add("Ortiz");
		lastname.add("Zimmerman");
		lastname.add("Johnston");
		lastname.add("Swanson");
		lastname.add("Blake");
		lastname.add("Pratt");
		lastname.add("Munoz");
		prof.addColumn(lastname);

		IntegerColumn id = new IntegerColumn();
		id.setName("id");
		id.add(56);
		id.add(3);
		id.add(99);
		id.add(78);
		id.add(65);
		id.add(101);
		id.add(90);
		prof.addColumn(id);

		IntegerColumn salary = new IntegerColumn();
		salary.setName("salary");
		salary.add(101000);
		salary.add(90002);
		salary.add(123204);
		salary.add(98301);
		salary.add(89241);
		salary.add(91092);
		salary.add(102500);
		prof.addColumn(salary);
	}

}
