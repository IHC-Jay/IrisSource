

import org.ihc.itf.cdr.svc.CdrMmiUpdate;

public class TestCdrMmiAddUpdateMerge {
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	//working
	//private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";
	//private static final String ApplicationAddress = "//svtst01:54210";
	private static final String ApplicationAddress = "//tltst01:41210";
	
	public static void main(String[] args) {
		// Testing check MMI
		System.out.println("Begin TestCdrMmiAddUpdate!");
		int i = 13;
		String CR = Character.toString ((char) i);		
		String hl7Msg = "MSH|^~\\&|iCentra|2000000234|ENGINE|IMTN|20160817102220||ADT^A01|Q295826994T380033832X109004||2.3||||||8859/1"+CR+"EVN|A08|20160817102211|||100"+CR+"PID|1|980013603^^^EMPI^MRN|980013603^^^EMPI|980013603^0^^EMPI^Account Number|XZTEST^BLAINE-TEST^NICK^^^^187||19800216000000|F|XZTEST^BLAINE-TEST^^^^^188|802|456 Center^^St George^UT^84111^1800^199^^Salt Lake||(801)888-8888^193~(801)111-1111^195|(801)777-7777^194|42|183||7380621249^^^FIN^FIN NBR|464848484|||14783480|||0";
		
			String logFile = "c:\\Temp\\TestCdrMmiAddUpdateMerge.log";
		try {
			
		
			CdrMmiUpdate objMmiUpdate;
		
			objMmiUpdate = new CdrMmiUpdate(ApplicationAddress, "MMIUPDATE", "MMIREADUPDATE", "MMILOCKREL", 5, 20, logFile, 1);
			String retVal = objMmiUpdate.updateMMI(hl7Msg);
			System.out.println("RetValue: " + retVal);
			
			TestCdrReadMmi objMmi = new TestCdrReadMmi(ApplicationAddress);
			objMmi.testReadMMI();
			
			TestAddSvcServices upd = new TestAddSvcServices(ApplicationAddress);
			upd.updateMmi();
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		
		
	}
}
