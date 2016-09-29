package org.ihc.itf.cdr;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;


public class TestServices {
	
	final static String ADT_FILE = "c:\\work\\Ensemble\\AmericalWell\\AmWellToCDR\\a2.log";
	final static String XML_FILE = "c:\\Temp\\msprRec.xml";
	
public static void main(String[] args) {
		
		try {

			System.out.println("Call Service!");
			CdrHl7AddUpdate hw = new CdrHl7AddUpdate(
					"//svtst01:54210", "MAIN_ENC");
				//	"//svtst01:54210,//tltst01:41210", "MAIN_ENC");

			String inp = readRec(ADT_FILE);
			String out = hw.callAddUpdate(inp);
			System.out.println("Output: " + out);
			hw.shutdownTuxService();
			
			/*
			System.out.println("Call Service!");
			
			CdrStringAddUpdate hw2 = new CdrStringAddUpdate("//tltst01:41210", "XMLPROXY");
				

			inp = readRec(XML_FILE);
			out = hw2.callAddUpdate(inp);
			System.out.println("Output: " + out);
			hw2.shutdownTuxService();
			*/
			
		} catch (Exception ex) {
			System.err.println(ex);
		}
	}


static String readRec(String fNm) {

	BufferedReader br = null;
	byte[] m_requestBytes = null;
	String fullData = null;
	
	try {

		String sCurrentLine;
		

		br = new BufferedReader(new FileReader(fNm));

		while ((sCurrentLine = br.readLine()) != null) {
			System.out.println(sCurrentLine);
			if (fullData == null) {
				fullData = sCurrentLine;
			} else {
				//fullData += 0x0D + sCurrentLine;
				fullData += "\r" + sCurrentLine;
			}
		}
		System.out.println("Read from file: " + fullData.length());
		m_requestBytes = fullData.getBytes();

	} catch (IOException e) {
		e.printStackTrace();
	} finally {
		try {
			if (br != null)
				br.close();
		} catch (IOException ex) {
			ex.printStackTrace();
		}
	}
	
	return fullData;
}


}
