package org.ihc.itf.cdr;

public class TestCdrReadFullName {
	
	private static final String ApplicationAddress = "//svtst01:54210";

	
	public static void main(String[] args) throws Exception {

		System.out.println("TestCdrReadFullName!");
		CdrReadFullName objMmi = new CdrReadFullName(ApplicationAddress, "DSQL");		
		String name = objMmi.GetLastAndFirstName("549717231");
		System.out.println("Name: "+name);
	}
	
}
