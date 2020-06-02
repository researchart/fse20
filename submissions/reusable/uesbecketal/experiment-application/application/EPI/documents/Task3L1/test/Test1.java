import static org.junit.Assert.*;

import java.util.List;

import org.junit.Test;

import library.Column;
import library.IntegerColumn;
import library.Query;
import library.StringColumn;
import library.Table;
import library.Task3;

public class Test1{

	@Test
	public void test() throws Exception {
		Table charts = new Table();
		setUpCharts(charts);
		Table query = new Task3().query(charts);

		if (query == null) {
			System.out.println("Null returned instead of table object");
		}
		
		Table result = altQuery1(charts);
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

	private Table altQuery1(Table charts) throws Exception {

		Query q = new Query();
		
		q.AddFields("songname, artist, timesplayed");

		q.Filter("rating > 3 and year > 2009 and genre = 'pop' or artist = 'Dude'");
		q.SortHighToLow("timesplayed");

		Table r = charts.Search(q);
		
		return r;
	}

	private void setUpCharts(Table charts) {
		StringColumn songname = new StringColumn();
		songname.setName("songname");
		songname.add("Singing Songs");
		songname.add("La La La La");
		songname.add("The Greatest Singsong in the World");
		songname.add("Situations");
		songname.add("Rock me Brahms!");
		songname.add("Something Something Love");
		songname.add("Ukulele Storm");
		songname.add("Just piano.");
		charts.addColumn(songname);

		StringColumn artist = new StringColumn();
		artist.setName("artist");
		artist.add("Dude");
		artist.add("Dude");
		artist.add("Guitar Fiends");
		artist.add("Happy Go Lucky");
		artist.add("Chopin");
		artist.add("Breadloaf");
		artist.add("Ukulele Guy");
		artist.add("Piano Cat");
		charts.addColumn(artist);

		StringColumn genre = new StringColumn();
		genre.setName("genre");
		genre.add("pop");
		genre.add("pop");
		genre.add("rock");
		genre.add("pop");
		genre.add("classical");
		genre.add("pop");
		genre.add("pop");
		genre.add("pop");
		charts.addColumn(genre);

		IntegerColumn id = new IntegerColumn();
		id.setName("id");
		id.add(45);
		id.add(89);
		id.add(4);
		id.add(32);
		id.add(90);
		id.add(10);
		id.add(22);
		id.add(46);
		charts.addColumn(id);

		IntegerColumn year = new IntegerColumn();
		year.setName("year");
		year.add(2003);
		year.add(2005);
		year.add(2011);
		year.add(2014);
		year.add(1902);
		year.add(2009);
		year.add(2016);
		year.add(2017);
		charts.addColumn(year);
		
		IntegerColumn rating = new IntegerColumn();
		rating.setName("rating");
		rating.add(1);
		rating.add(1);
		rating.add(4);
		rating.add(5);
		rating.add(5);
		rating.add(4);
		rating.add(3);
		rating.add(4);
		charts.addColumn(rating);
		
		IntegerColumn timesplayed = new IntegerColumn();
		timesplayed.setName("timesplayed");
		timesplayed.add(100500);
		timesplayed.add(130023);
		timesplayed.add(103673);
		timesplayed.add(203043);
		timesplayed.add(189021);
		timesplayed.add(390190);
		timesplayed.add(408905);
		timesplayed.add(918391);
		charts.addColumn(timesplayed);
	}

}
