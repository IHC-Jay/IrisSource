package org.ihc.itf.cdr;

public class TestCdrMmiAddUpdateMerge {
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	//working
	//private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";
	private static final String ApplicationAddress = "//svtst01:54210";
	//private static final String ApplicationAddress = "//tltst01:41210";
	
	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("Begin TestCdrMmiAddUpdate!");
		int i = 13;
		String CR = Character.toString ((char) i);
		String hl7Msg = "MSH|^~\\&|iCENTRA|521488519|ENGINE|IMTN|20160711063253||ADT^A01|Q323204934T419283908X278243||2.3||||||8859/1"+CR+"EVN|A08|20160711063253|||100"+CR+"PID|1|551133404^^^EMPI^MRN^CD:43818093|551133404^^^EMPI|214425^0^^2000000228^Historical MRN^Initiate MPI~551133404^0^^EMPI^Account Number~551133404^0^^EMPI^Account Number~5049717^0^^CONSUMER_MESSAGING^Messaging|FELIX-CASTRO^ANSELA^^^^^187||19851002000000|1211|FELIX^ANSELA^^^^^189~FELIX-CASTRO^ANGELA~FELIX^ANGELA~MONTES^ANGELA~FELIX-CASTRO^ANSELA^^^^^188|CD:23274729|282 S 400 W^^OREM^UT^84058-5329^1800^199^^Utah~angiefelix@live.com^^^^^^50450664~282 S 400 W^^OREM^UT^84058-5329^1800^361^^Utah||(801)928-4105^193~(801)928-4105^195|(801)225-1356^194|42|182|177|1202414753^^^FIN^FIN NBR|618243918|||14676176|||0";
		
		/*
		CdrMmiAdd objMmiAdd = new CdrMmiAdd(ApplicationAddress, "MMIADDXA");
		String sUnitNumber = objMmiAdd.addMMI(hl7Msg);		
		System.out.println("UnitNumber:= " + sUnitNumber);
		System.out.println("\n\n\n");
		*/
		
		CdrMmiUpdate objMmiUpdate = new CdrMmiUpdate(ApplicationAddress, "MMIUPDATE", "MMIREADUPDATE", "MMILOCKREL", "5", "20");
		String retVal = objMmiUpdate.updateMMI(hl7Msg);
		System.out.println("RetValue: " + retVal);
		
		
		
		
	}
}
