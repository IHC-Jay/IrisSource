package org.ihc.itf.cdr.mmi.test;

import org.ihc.itf.cdr.mmi.CdrMmiEvents;

public class TestCdrMmiEvents {
	
	/** TestApplication Address for testing */	
	
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	//working
	// private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";
	//private static final String ApplicationAddress = "//svtst01:54210";
	private static final String ApplicationAddress = "//tltst01:41210";
	
	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("CdrLoadMmiEvents!");
		String logFile = "c:\\Temp\\CdrLoadMmiEvents.log";
		
		CdrMmiEvents objMmi = new CdrMmiEvents(ApplicationAddress, "DSQL", logFile, 1);		
		//Step1: Load MMI Events
		objMmi.loadMmiEvents("526");
		objMmi.unloadMmiEvents("980020636", "260134588");
		//Step2: Check MMI Events
		System.out.println("\n");
		//objMmi.checkMmiEvents("269720367", "1542329006");
		
		//Step3: Unload MMI Events
		System.out.println("\n");
		//objMmi.unloadMmiEvents("unit_number", "audit_num");
		
		//Step3: Check Merge MMI Events
		System.out.println("\n");
		//objMmi.checkMergeMmi("269720367", "1542329006");
		
		//Step4: Do readMMI
		System.out.println("\n");
		//cdr.asn1.hems.DataRecord dataRecord = objMmi.readMMI("269720367", "Datagate", 100, 50450829, "1.0");
		System.out.println("dataRecord accessed");
	}
	
}
