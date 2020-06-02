package library;

public class SQLTasks {

	public static void main(String[] args) {
		new SQLTasks().run();
	}

	private void run() {
		Table student = new Table();
		Table prof = new Table();
		setUpStudent(student);
		setUpProf(prof);
		System.out.println("____ initial _____");
		student.outputTable();
		prof.outputTable();

		try {

			Table query1 = query1(student);
			Table query2 = query2(prof);
			Table query3 = query3(student);
			Table query4 = query4(student);
			Table altQuery1 = altQuery1(student);
			Table altQuery2 = altQuery2(prof);
			Table altQuery3 = altQuery3(student);
			Table altQuery4 = altQuery4(student);

			System.out.println("____ tables _____");
			student.outputTable();
			prof.outputTable();

			System.out.println("____ results _____");
			System.out.println("SELECT 1");
			query1.outputTable();
			System.out.println("SELECT 2");
			query2.outputTable();
			System.out.println("UPDATE 1");
			query3.outputTable();
			System.out.println("INSERT 1");
			query4.outputTable();
			System.out.println("ALT SELECT 1");
			altQuery1.outputTable();
			System.out.println("ALT SELECT 2");
			altQuery2.outputTable();
			System.out.println("ALT UPDATE 1");
			altQuery3.outputTable();
			System.out.println("ALT INSERT 1");
			altQuery4.outputTable();
		} catch (Exception e) {
			e.printStackTrace();
		}

		System.out.println("Tada! done!");
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

		StringColumn grade = new StringColumn();
		grade.setName("grade");
		grade.add("A");
		grade.add("D");
		grade.add("C");
		grade.add("D");
		grade.add("F");
		grade.add("A");
		grade.add("B+");
		prof.addColumn(grade);

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

	private void sampleAlt(Table cars) throws Exception {

		QueryT q1 = new QueryT();

		q1.insert("make", "model", "year", "licenseplatenumber", "registrationyear");
		q1.values("Toyota", "Verso", 2016, "326 NEB", 2017);

		Table result1 = cars.perform(q1);

		QueryT q2 = new QueryT();

		Predicate p2 = new Predicate();

		q2.set("model", "Berlingo");
		q2.where(p2.And(p2.Equals("make", "Citroen"), p2.Equals("registrationyear", 2001)));

		Table result2 = cars.perform(q2);

		QueryT q3 = new QueryT();

		q3.columns(SelectArg.ALL);
		q3.orderby("model", SortOrder.ASCENDING);

		Table result3 = cars.perform(q3);

		QueryT q4 = new QueryT();

		Predicate p4 = new Predicate();

		q4.columns("make", "model", "year", "licenseplatenumber", "registrationyear");
		q4.where(p4.LessThan("year", 1990));

		Table result4 = cars.perform(q4);

	}

	private void sample(Table cars) throws Exception {

		QueryT q1 = new QueryT();

		q1.prepare(
				"INSERT (make, model, year, licenseplatenumber, registrationyear) VALUES ('Toyota', 'Verso', 2016, '326 NEB', 2017)");

		Table result1 = cars.perform(q1);

		QueryT q2 = new QueryT();

		Predicate p2 = new Predicate();

		q2.prepare("UPDATE SET model = 'Berlingo' WHERE make = 'Citroen' AND registrationyear = 2001 ");

		Table result2 = cars.perform(q2);

		QueryT q3 = new QueryT();

		q3.prepare("SELECT * ORDER BY model ASCENDING");

		Table result3 = cars.perform(q3);

		QueryT q4 = new QueryT();

		q4.prepare("SELECT make, model, year, licenseplatenumber, registrationyear WHERE year < 1990");

		Table result4 = cars.perform(q4);

	}

	private Table altQuery1(Table student) throws Exception {
		System.out.println("~~~~~~ Alt Query 1");
		QueryT q = new QueryT();

		Predicate p = new Predicate();

		q.columns("id", "year", "grade");
		q.where(p.LessThan("id", 32));

		System.out.println("!!!!!! end Alt Query 1");
		return student.perform(q);
	}

	private Table altQuery2(Table professor) throws Exception {
		System.out.println("~~~~~~ Alt Query 2");
		QueryT q = new QueryT();

		q.columns(SelectArg.ALL);
		q.orderby("salary", SortOrder.DESCENDING);

		System.out.println("!!!!!! end Alt Query 2");
		return professor.perform(q);
	}

	private Table altQuery3(Table student) throws Exception {
		System.out.println("~~~~~~ Alt Query 3");
		QueryT q = new QueryT();

		Predicate p = new Predicate();

		q.set("grade", "A");
		q.where(p.And(p.Equals("firstname", "Herbert"), p.Equals("lastname", "Hauser")));

		System.out.println("!!!!!! end Alt Query 3");
		return student.perform(q);
	}

	private Table altQuery4(Table student) throws Exception {
		System.out.println("~~~~~~ Alt Query 4");
		QueryT q = new QueryT();

		q.insert("id", "firstname", "lastname", "year", "grade");

		q.values(23, "Tom", "Young", 3, "C");

		System.out.println("!!!!!! end Alt Query 4");
		return student.perform(q);
	}

	private Table query1(Table student) throws Exception {
		System.out.println("~~~~~~ Query 1");
		QueryT q = new QueryT();

		q.prepare("SELECT id, year, grade WHERE id < 32");

		System.out.println("!!!!!! end Query 1");
		return student.perform(q);
	}

	private Table query2(Table prof) throws Exception {
		System.out.println("~~~~~~ Query 2");
		QueryT q = new QueryT();

		q.prepare("SELECT * ORDER BY salary DESC");

		System.out.println("!!!!!! end Query 2");
		return prof.perform(q);
	}

	private Table query3(Table student) throws Exception {
		System.out.println("~~~~~~ Query 3");
		QueryT q = new QueryT();

		q.prepare("UPDATE SET grade = 'A' WHERE firstname = 'Herbert' AND lastname = 'Hauser' ");

		System.out.println("!!!!!! end Query 3");
		return student.perform(q);
	}

	private Table query4(Table student) throws Exception {
		System.out.println("~~~~~~ Query 4");
		QueryT q = new QueryT();

		q.prepare("INSERT (id, firstname, lastname, year, grade) VALUES (23, 'Tom', 'Young', 3, 'C')");

		System.out.println("!!!!!! end Query 4");
		return student.perform(q);
	}

}
