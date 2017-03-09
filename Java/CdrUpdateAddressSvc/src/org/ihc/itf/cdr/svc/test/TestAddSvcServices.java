package org.ihc.itf.cdr.svc.test;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Timestamp;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;
import org.ihc.itf.cdr.svc.UpdateAddressCdrService;
import org.ihc.itf.util.ItfLogger;


public class TestAddSvcServices {
	
	final static String ADT_FILE = "c:\\Temp\\addrTest.txt";
	final static String XML_FILE = "c:\\Temp\\msprRec.xml";
	static Logger log = null;
	 
public static void main(String[] args) {
		char CR = 0x0D;
		String hl7Msg = 
				"MSH|^~\\&|PCSAddrUpd|211|ENGINE|IMTN|02282017175222||ADT^A01|Q295826994T380033832X109004||2.3||||||8859"+CR+"EVN|A08||02282017175222||100"+CR+"PID||269757715^^^EMPI^MRN|269757715^^^^EMPI|269757715^0^^EMPI^Account Number|LEFEVRE^BLAINE-TEST^F^^^^187||19800216000000||LEFEVRE^BLAINE-TEST^187|187|WRONG341 E 100 S^^HYRUM^UT^84319-1339^USA^199|||(801)777-7777|42|183||7380621249^^^FIN^FIN NBR|464848484|||14783480|||0"; 

		try {
			String logFile = "c:\\Temp\\TestAddSvcServices.log";
			// PropertyConfigurator.configure(log4jConfPath);
			//log = ItfLogger.setLoggerProperties(logFile, true) ;
			
			System.out.println(" Log file name: " + logFile);
			
			
			
			System.out.println("Call Service!");
			UpdateAddressCdrService hw = new UpdateAddressCdrService(
					"//svtst01:54210", "MMIUPDATE", "MMIREADUPDATE", "MMILOCKREL", 5, 10, logFile, 1);
			
			// UpdateAddressCdrService.initLog("c:\\Temp\\tstServ.txt", 1);


			// String inp = readRec(ADT_FILE);
			Timestamp timestamp = new Timestamp(System.currentTimeMillis());
			System.out.println("UpdateAddressCdrService: " + timestamp);
			String out = hw.addressUpdateMMI(hl7Msg); 
			
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
				fullData += 0x0D + sCurrentLine;
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
