package ch.uzh.seal.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.Map;

public class HTTPConnector {
	
	public static final int STATUS_OK = 200;

	/**
	 * Open a HTTP connection with the given URL and header.
	 * @param url
	 * @param header
	 * @return A HTTP connection.
	 * @throws IOException
	 */
	public static HttpURLConnection connectTo(String url, Map<String,String> header) throws IOException{
		URL u_rl = new URL(url);
		HttpURLConnection con = (HttpURLConnection) u_rl.openConnection();
		con.setRequestMethod("GET");
		con.setRequestProperty("Content-Type", "application/json");
		
		for(String key: header.keySet()){
			con.setRequestProperty(key, header.get(key));
		}
		return con;
	}

	/**
	 * Get the payload from an open HTTP connection.
	 * @param con An HTTP connection.
	 * @return The response.
	 * @throws IOException
	 */
	public static StringBuffer extractResponse(HttpURLConnection con) throws IOException{
		BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream()));
		String inputLine;
		StringBuffer content = new StringBuffer();
		while ((inputLine = in.readLine()) != null) {
			content.append(inputLine + System.getProperty("line.separator"));
		}
		in.close();
		
		con.disconnect();
		
		return content;
	}
	
	
	/**
	 * Fetch resource referred to by URL.
	 * @param url URL pointing to resource.
	 * @param header Header fields to use in the request.
	 * @return The response code (1) and the payload (2)
	 */
	public static String[] connectAndGetResponse(String url,Map<String,String> header){
		String[] results = new String[2];
		
		HttpURLConnection url_conn = null;
		String response = null;
		int responseCode = -1;
		try {
			url_conn = HTTPConnector.connectTo(url,header);	
			responseCode = url_conn.getResponseCode();
			response = new String(HTTPConnector.extractResponse(url_conn));
			
		} catch (IOException e) {
		//	e.printStackTrace();
		}
		url_conn.disconnect();
		
		results[0] = ""+responseCode;
		results[1] = response;
		
		return results;
	}
	
	public static String[] connectAndGetResponseHeader(String url,Map<String,String> header, String responseHeaderKey){
		String[] results = new String[2];
		
		HttpURLConnection url_conn = null;
		String responseHeader = null;
		int responseCode = -1;
		try {
			url_conn = HTTPConnector.connectTo(url,header);	
			responseCode = url_conn.getResponseCode();
			responseHeader = url_conn.getHeaderField(responseHeaderKey);
			
/*			Map<String, List<String>> map = url_conn.getHeaderFields();
			for (Map.Entry<String, List<String>> entry : map.entrySet()) {
				System.out.println("Key : " + entry.getKey() + 
		                 " ,Value : " + entry.getValue());
			}
*/			
			//get header by 'key'
		//	String server = url_conn.getHeaderField("Server");
			
		} catch (IOException e) {
		//	e.printStackTrace();
		}
		url_conn.disconnect();
		
		results[0] = ""+responseCode;
		results[1] = responseHeader;
		
		return results;
	}
	
}
