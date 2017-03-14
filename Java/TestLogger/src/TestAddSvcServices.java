

import java.sql.Timestamp;

import org.apache.log4j.Logger;
import org.ihc.itf.cdr.svc.UpdateAddressCdrService;



public class TestAddSvcServices {
	
	static Logger log = null;
	String logFile = "c:\\Temp\\TestAddSvcServices.log";
	
	UpdateAddressCdrService hw;
	
	public TestAddSvcServices(String ApplicationAddress) throws Exception
	{
		hw = new UpdateAddressCdrService(
				ApplicationAddress, "MMIUPDATE", "MMIREADUPDATE", "MMILOCKREL", 5, 10, logFile, 1);

	}

	
public  void updateMmi() {
		char CR = 0x0D;
		String hl7Msg = 
				"MSH|^~\\&|PCSAddrUpd|211|ENGINE|IMTN|02282017175222||ADT^A01|Q295826994T380033832X109004||2.3||||||8859"+CR+"EVN|A08||02282017175222||100"+CR+"PID||269757715^^^EMPI^MRN|269757715^^^^EMPI|269757715^0^^EMPI^Account Number|LEFEVRE^BLAINE-TEST^F^^^^187||19800216000000||LEFEVRE^BLAINE-TEST^187|187|WRONG341 E 100 S^^HYRUM^UT^84319-1339^USA^199|||(801)777-7777|42|183||7380621249^^^FIN^FIN NBR|464848484|||14783480|||0"; 

		try {
			
			
			System.out.println("Call Service!");
			
			
			// UpdateAddressCdrService.initLog("c:\\Temp\\tstServ.txt", 1);


			// String inp = readRec(ADT_FILE);
			Timestamp timestamp = new Timestamp(System.currentTimeMillis());
			System.out.println("UpdateAddressCdrService: " + timestamp);
			String out = hw.addressUpdateMMI(hl7Msg); 
			
		} catch (Exception ex) {
			System.err.println(ex);
		}
	}




}
