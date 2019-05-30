package org.ihc.itf.cdr.test;

import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.CdrTuxStringAddUpdate;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLogger;

import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;

public class TestMAIN_ENC extends CdrTuxServices {
private static final String ApplicationAddress = "//tltst01:41210";

private static Logger log = null;

public TestMAIN_ENC(String applicationAddress, String serviceName) throws Exception	
{
	super(applicationAddress, serviceName);
}

	public static void main(String[] args) throws Exception {
		// Testing check MMI
		String requestString = "MSH|^~\\&|PCSAddrUpd|211|ENGINE|IMTN|02282017175222||ADT^A01|Q295826994T380033832X109004||2.3||||||8859" + (char) 13 +
"EVN|A08||02282017175222||100" + (char) 13 +
"PID||269757715^^^EMPI^MRN|269757715^^^^EMPI|269757715^0^^EMPI^Account Number|LEFEVRE^BLAINE-TEST^F^^^^187||19800216000000||LEFEVRE^BLAINE-TEST^187|187|WRONG341 E 100 S^^HYRUM^UT^84319-1339^USA^199|||(801)777-7777|42|183||7380621249^^^FIN^FIN NBR|464848484|||14783480|||0";
		System.out.println("Test CdrTuxServices using MAIN_ENC!");
		CdrTuxStringAddUpdate objMmi = new CdrTuxStringAddUpdate(ApplicationAddress, "MAIN_ENC", "c:\\Temp\\Test_MMI_ENV_CdrService.log", 1);
		

		String resp = objMmi.callAddUpdate(requestString);
		
		System.out.println("Resp " + resp);	
		
	
	}
	
}
