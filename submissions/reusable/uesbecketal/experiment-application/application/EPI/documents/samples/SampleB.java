package sample;

import library.*;

public class SampleB {

/**
 * Results of print commands are in the comments and
 * formatted for better readability.
 * 
 * The format of the tables in this sample:
 * 
 * - cars -
 * 
 * id (int) | make (String) | model (String) | year (int) |
 * licenseplatenumber (String) | registrationyear (int)
 *
 * - ticketlist -
 * 
 * tid (int) | carid (int) | tickettype (String) | description (String)
 * 
 * 
 */
public void sample(Table cars, Table ticketlist) throws Exception {

 cars.outputTable();
 /*
   Citroen,  Berlingo,  255 FAD,  41,  2003,  2005,  
   Renault,  Laguna,  322 SKO,  80,  2014,  2015,  
   Mercedes,  C250,  660 OLK,  56,  2015,  2016,  
   Ford,  Fusion,  910 GRE,  12,  2017,  2017,  
  */

 ticketlist.outputTable();
 /*
   Parking,  3,  41,  no time on parking meter,  
   Parking,  5,  56,  student in staff space,  
   Speeding,  8,  56,  20mph too fast in 30mph zone,  
   Parking,  10,  41,  double parked,  
   Speeding,  11,  56,  10mph too fast in 65mph zone,  
   Speeding,  23,  41,  15mph too fast in 45mph zone,  
   Speeding,  43,  12,  drove faster than police car,  
   Parking,  44,  41,  parked in street,  
   Red light,  51,  56,  Ran red light 10 sec after red,  
   Speeding,  56,  12,  10mph too fast in 35mph construction zone, 
  */

 Query allCarInfoQuery = new Query();
 
 allCarInfoQuery.Prepare("SELECT * FROM cars");
 
 Table allCarInfo = cars.Search(allCarInfoQuery);
 
 allCarInfo.outputTable();
 /*
   Citroen,  Berlingo,  255 FAD,  41,  2003,  2005,  
   Renault,  Laguna,  322 SKO,  80,  2014,  2015,  
   Mercedes,  C250,  660 OLK,  56,  2015,  2016,  
   Ford,  Fusion,  910 GRE,  12,  2017,  2017,  
  */
 
 
 Query insertCarsQuery = new Query();

 insertCarsQuery.Prepare(
     "INSERT INTO cars "
     + "(id, make, model, year, licenseplatenumber, registrationyear) "
     + "VALUES (2345, 'Toyota', 'Verso', 2016, '326 NEB', 2017)");
 
 Table carsInserted = cars.Search(insertCarsQuery);
 
 carsInserted.outputTable();
 /*
   Citroen,  Berlingo,  255 FAD,  41,  2003,  2005,  
   Renault,  Laguna,  322 SKO,  80,  2014,  2015,  
   Mercedes,  C250,  660 OLK,  56,  2015,  2016,  
   Ford,  Fusion,  910 GRE,  12,  2017,  2017,  
   Toyota,  Verso,  326NEB,  2345,  2016,  2017,  
  */
 
 Query carsNotMercedesQuery = new Query();
 
 carsNotMercedesQuery.Prepare("SELECT make, model, year"
     + "FROM cars WHERE make != 'Mercedes' ORDER BY year DESC");
 
 Table carsNotMercedes = cars.Search(carsNotMercedesQuery);

 carsNotMercedes.outputTable();
 /*
   Ford,  Fusion,  2017,  
   Renault,  Laguna,  2014,  
   Citroen,  Berlingo,  2003, 
  */

 Query carTicketQuery = new Query();

 carTicketQuery.Prepare("SELECT id, make, model, description "
     + "FROM cars JOIN ticketlist ON cars.id = ticketlist.carid");
 
 Table ticketsForCars = cars.Search(carTicketQuery, ticketlist);
 
 ticketsForCars.outputTable();
 /*
   41,  Citroen,  Berlingo,  no time on parking meter,  
   41,  Citroen,  Berlingo,  double parked,  
   41,  Citroen,  Berlingo,  15mph too fast in 45mph zone,  
   41,  Citroen,  Berlingo,  parked in street,  
   56,  Mercedes,  C250,  student in staff space,  
   56,  Mercedes,  C250,  20mph too fast in 30mph zone,  
   56,  Mercedes,  C250,  10mph too fast in 65mph zone,  
   56,  Mercedes,  C250,  Ran red light 10 sec after red,  
   12,  Ford,  Fusion,  drove faster than police car,  
   12,  Ford,  Fusion,  10mph too fast in 35mph construction zone,  
   */
 
 Query carsOlderQuery = new Query();
 
 carsOlderQuery.Prepare("SELECT make, model, year, licenseplatenumber, registrationyear "
     + "FROM cars WHERE year < 2015 ORDER BY year ASC");
 
 Table carsOlderThan2015 = cars.Search(carsOlderQuery);

 carsOlderThan2015.outputTable();
 /*
   Citroen,  Berlingo,  2003,  255 FAD,  2005,  
   Renault,  Laguna,  2014,  322 SKO,  2015,  
  */

 
 Query updateQuery = new Query();

 updateQuery.Prepare("UPDATE cars SET licenseplatenumber = 'none' "
     + "WHERE make = 'Mercedes' and model = 'CS250'");
     
 Table updatedYear = cars.Search(updateQuery);
 
 updatedYear.outputTable();
 /*
   Citroen,  Berlingo,  255 FAD,  41,  2003,  2005,  
   Renault,  Laguna,  322 SKO,  80,  2014,  2015,  
   Mercedes,  C250,  none,  56,  2015,  2016,  
   Ford,  Fusion,  910 GRE,  12,  2017,  2017,  
  */
  }

}
