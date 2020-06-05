/**
 * Copyright 2018 University of Zurich
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package ch.uzh.seal.utils;

import static org.junit.Assert.*;

import java.text.ParseException;
import java.util.Calendar;
import java.util.Date;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TCIDateFormatterTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testGitlabStringToDate() throws ParseException {
		// 2019-08-16T14:05:02.000-05:00
		String date_str = "2019-12-09T13:52:24.000+00:00";
		String pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSX";
		Date date = TCIDateFormatter.stringToDate(date_str, pattern);
		System.out.println(date);
		Calendar cal1 = Calendar.getInstance();
		cal1.setTime(date);
		int month = cal1.get(Calendar.MONTH);
		int day = cal1.get(Calendar.DAY_OF_MONTH);
		int year = cal1.get(Calendar.YEAR);
		
		assertEquals(Calendar.DECEMBER, month);
		assertEquals(9, day);
		assertEquals(2019, year);
	}
	
	@Test
	public void testTimeBetweenDates() throws ParseException {
		Date date1 = TCIDateFormatter.gitlabStringToDate("2019-12-06T13:52:24.000+00:00");
		Date date2 = TCIDateFormatter.gitlabStringToDate("2019-12-09T13:52:24.000+00:00");
		long timeBetweenDates = TCIDateFormatter.timeBetweenDates(date1, date2);
		
		int days = (int) (timeBetweenDates / (1000*60*60*24));
		assertEquals(3, days);
		
	}

}
