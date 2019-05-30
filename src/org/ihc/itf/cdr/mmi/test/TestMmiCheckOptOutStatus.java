package org.ihc.itf.cdr.mmi.test;

import org.ihc.itf.cdr.mmi.MmiCheckOptOutStatus;

public class TestMmiCheckOptOutStatus {
	
	/** TestApplication Address for testing */	
	
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	//working
	//private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";
	//private static final String ApplicationAddress = "//svtst01:54210";
	private static final String ApplicationAddress = "//tltst01:41210";
	
	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("CheckMmi!");
		MmiCheckOptOutStatus objMmi = new MmiCheckOptOutStatus(ApplicationAddress, "DSQL");
		
		//Step1: Check MMI
		System.out.println("CheckMmi Reply: " + objMmi.checkOptOutStatus("269720367"));
	}
	
}