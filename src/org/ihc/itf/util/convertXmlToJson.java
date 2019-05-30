package org.ihc.itf.util;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.json.XML;
import org.json.JSONException;
/*
 * Returns json string
 *  
 */
public class convertXmlToJson {
	
	private static Logger log = null;
    static private final int INDENT_FACTOR=4;
	
	public convertXmlToJson() {
		log = ItfLoggerHash.getInstance("convertXmlToJson");
		log.setLevel(Level.ERROR);
		log.debug("In convertXmlToJson");
	}
	
	public static String xml2Json(String xmlData) throws JSONException {
		String jsonStr="";
		
		log.debug("In xml2Json");
	    JSONObject xmlJSONObj = XML.toJSONObject(xmlData);
	    jsonStr = xmlJSONObj.toString(INDENT_FACTOR);
	    
	    return jsonStr;
	}

}
