package org.ihc.itf.cdr;

public class TestCdrReadDOB {
	
	private static final String ApplicationAddress = "//svtst01:54210";

	
	public static void main(String[] args) throws Exception {

		System.out.println("TestCdrReadDOB!");
		CdrReadDOB objMmi = new CdrReadDOB(ApplicationAddress, "DSQL");		
		String dob = objMmi.GetDOB("980015386");
		
		System.out.println("DOB: "+dob);
	}
	
}
