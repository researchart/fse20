import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.Test;

import library.Column;
import library.IntegerColumn;
import library.Predicate;
import library.Query;
import library.StringColumn;
import library.Table;
import library.Task4;

public class Test1 {

	@Test
	public void test() throws Exception {
		Table student = new Table();
		setUpStudent(student);
		Table query = new Task4().query(student);

		if (query == null) {
			System.out.println("Null returned instead of table object");
		}

		Table result = altQuery3(student);
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
	
	private Table altQuery3(Table student) throws Exception {
		Query q = new Query();

		q.Replace("grade", "A");
		q.Filter("firstname = 'Herbert' AND lastname = 'Hauser'");

		Table r = student.Update(q);

		return r;
	}

	private void setUpStudent(Table student) {
		StringColumn firstname = new StringColumn();
		firstname.setName("firstname");
		firstname.add("Klaus");
		firstname.add("Grace");
		firstname.add("Bernd");
		firstname.add("Ada");
		firstname.add("Sigmund");
		firstname.add("Herbert");
		firstname.add("Natalie");
		student.addColumn(firstname);

		StringColumn lastname = new StringColumn();
		lastname.setName("lastname");
		lastname.add("Lapowitz");
		lastname.add("Hoppe");
		lastname.add("Broter");
		lastname.add("Lacy");
		lastname.add("Schmidt");
		lastname.add("Hauser");
		lastname.add("Rupert");
		student.addColumn(lastname);

		StringColumn grade = new StringColumn();
		grade.setName("grade");
		grade.add("A");
		grade.add("D");
		grade.add("C");
		grade.add("D");
		grade.add("F");
		grade.add("B");
		grade.add("B+");
		student.addColumn(grade);

		IntegerColumn id = new IntegerColumn();
		id.setName("id");
		id.add(32);
		id.add(45);
		id.add(2);
		id.add(42);
		id.add(4);
		id.add(509);
		id.add(6);
		student.addColumn(id);

		IntegerColumn year = new IntegerColumn();
		year.setName("year");
		year.add(1);
		year.add(3);
		year.add(4);
		year.add(4);
		year.add(2);
		year.add(1);
		year.add(3);
		student.addColumn(year);
	}

}
