package ch.uzh.seal.utils;

import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class TCIDateFormatter {

	public static Date convertToDate(String date_str) throws ParseException{
		
		/*
		 * 		SimpleDateFormat simpleDF = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
		Date date1 = simpleDF.parse("2017-02-14T11:27:38+0200");
		Calendar cal = Calendar.getInstance();
		cal.setTime(date1);
		int month = cal.get(Calendar.YEAR);
		System.out.println(month);
		System.exit(0);
		 */
		
		
		SimpleDateFormat simpleDF = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
		Date date = simpleDF.parse(date_str);
		return date;
	}
	
	public static Date cvtToGmt( Date date )
	{
	   TimeZone tz = TimeZone.getDefault();
	   Date ret = new Date( date.getTime() - tz.getRawOffset() );
	   // if we are now in DST, back off by the delta.  Note that we are checking the GMT date, this is the KEY.
	   if ( tz.inDaylightTime( ret ))
	   {
	      Date dstDate = new Date( ret.getTime() - tz.getDSTSavings() );
	      // check to make sure we have not crossed back into standard time
	      // this happens when we are on the cusp of DST (7pm the day before the change for PDT)
	      if ( tz.inDaylightTime( dstDate ))
	      {
	         ret = dstDate;
	      }
	   }
	   return ret;
	}
	
	public static Date stringToDate(String date_str, String pattern) throws ParseException {
		SimpleDateFormat simpleDF = new SimpleDateFormat(pattern, Locale.US); //
		Date date = simpleDF.parse(date_str);
		return date;
	}
	
	public static Date gitlabStringToDate(String date_str) throws ParseException {
		String pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSX";
		return stringToDate(date_str, pattern);
	}
	
	//""
/*	public static Date gitlabIssueStringToDate(String date_str) throws ParseException {
		SimpleDateFormat simpleDF = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US); //'+'HH:mm
		Date date = simpleDF.parse(date_str);
		return date;
	}*/
	
	public static long timeBetweenDates(Date date1, Date date2) {
		long diff = date2.getTime() - date1.getTime();
		return diff;
	}
	
	
	public static void main(String [] args) throws ParseException{
	
		BigDecimal m1 = new BigDecimal("5000");
		System.out.println(m1);
		
		Long num = new Long(5000);
		Long num2 = new Long(46);
		double n = (double) num/ (double) num2;
		System.out.println(n);
		
		int n_int = Integer.parseInt(""+num);

		System.out.println(n_int);
		
		SimpleDateFormat simpleDF = new SimpleDateFormat("MMM dd, yyyy hh:mm:ss a");//"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
	//	simpleDF.setTimeZone(TimeZone.getTimeZone("GMT"));
		Date date1 = simpleDF.parse("Jan 1, 2018 1:22:12 AM"); // "2019-01-16T08:21:33.079Z");//2017-03-29T03:48:59Z");//2017-02-14T11:27:38+0200");
		Calendar cal1 = Calendar.getInstance();
		cal1.setTime(date1);
		int month = cal1.get(Calendar.YEAR);
		int i = cal1.get(Calendar.WEEK_OF_YEAR);
		System.out.println(i);
		Date d = new Date(date1.getTime());
		System.out.println(d.toString());
		System.out.println(date1.toString());
		
		Date date2 = simpleDF.parse("Dec 6, 2018 1:22:12 PM");
		
		System.out.println(date1.compareTo(date2));
		
	}
}
