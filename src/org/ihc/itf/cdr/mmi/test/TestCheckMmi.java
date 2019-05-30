package org.ihc.itf.cdr.mmi.test;

import org.ihc.itf.cdr.mmi.CheckMmi;

public class TestCheckMmi {
	
	/** TestApplication Address for testing */	
	
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	//working
	//private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";
	//private static final String ApplicationAddress = "//svtst01:54210";
	private static final String ApplicationAddress = "//tltst01:41210";
	
	// CAREFUL - PROD ADDRESS
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	
	
	
	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("CheckMmi!");
		CheckMmi objMmi = new CheckMmi(ApplicationAddress, "DSQL", "c:\\Temp\\TestCheckMmi.txt", 1);
		
		//Step1: Check MMI
		System.out.println("123456901: CheckMmi Reply: " + objMmi.checkMmi("585428435"));
		
	}
	
}