package solved;

import library.*;

public class Task3 {

	/**
	 * Please write this method to return a Table object containing the columns
	 * songname and artist for all entries which have a rating above 3,
	 * where written after the year 2009, and belong to the genre pop. Also include
	 * all songs by the artist "Dude". The result should be sorted from high timesplayed
	 * to low timesplayed.
	 * 
	 * 
	 * Table information:
	 * 
	 * - charts - 
	 * 
	 * id (int) | songname (String) | artist (String) | rating
	 * (int) | releaseyear (int) | genre (string) | timesplayed (int)
	 * 
	 * Use the technique shown to you in the samples given
	 * 
	 */
	public Table queryB(Table charts) throws Exception {
		Query q = new Query();
		
		q.Prepare("SELECT songname, artist, timesplayed "+
			"FROM charts "+
			"WHERE rating > 3 AND year > 2009 "+
				"AND genre = 'pop' OR artist = 'Dude' "+
			"ORDER BY timesplayed DESC");
		
		Table r = charts.Search(q);
				
		return r;
	}

	public Table queryA(Table charts) throws Exception {
		Query q = new Query();
		
		q.AddFields("songname, artist, timesplayed");

		q.Filter("rating > 3 and year > 2009 "+
			" and genre = 'pop' or artist = 'Dude'");
		q.SortHighToLow("timesplayed");

		Table r = charts.Search(q);
		
		return r;
	}
	
	public Table queryC(Table charts) throws Exception {
		Query q = new Query();
	
		q.AddField("songname")
			.AddField("artist")
			.AddField("timesplayed");
		
		q.Filter(q.Where("rating").GreaterThan(3)
			.And("year").GreaterThan(2009)
			.And("genre").Equals("pop")
			.Or("artist").Equals("Dude"));
		q.SortHighToLow("timesplayed");
		
		Table r = charts.Search(q);
		
		return r;
	}

}
