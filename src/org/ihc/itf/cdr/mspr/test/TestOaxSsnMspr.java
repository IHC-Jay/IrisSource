package org.ihc.itf.cdr.mspr.test;


import org.ihc.itf.cdr.mspr.OaxSsnMsprCheck;

public class TestOaxSsnMspr {
	
	private static final String ApplicationAddress = "//svtst01:54210";

	
	public static void main(String[] args) throws Exception {

		System.out.println("TestOaxSsnMspr!");
		OaxSsnMsprCheck objMmi = new OaxSsnMsprCheck(ApplicationAddress, "DSQL", "c:\\Temp\\TestCdrReadDOB.txt", 1);		
//		OaxSsnMsprCheck objMmi = new OaxSsnMsprCheck(ApplicationAddress, "DSQL");		
		String dob = objMmi.getSSN("4136", "520490951");
		
		System.out.println("DOB: "+dob);
	}
	
}