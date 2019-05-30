package org.ihc.itf.cdr.test;

import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLogger;

import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;

public class TestCdrService extends CdrTuxServices {
private static final String ApplicationAddress = "//tltst01:41210";
private static final String	CHECK_MMI_STATEMENT = "SELECT unit_number FROM mmi_id" +
		  " WHERE unit_number = :X0";
private static Logger log = null;

public TestCdrService(String applicationAddress, String serviceName) throws Exception	
{
	super(applicationAddress, serviceName);
}

	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("Test CdrTuxServices using DSQL!");
		log = ItfLogger.setLoggerProperties( "c:\\Temp\\TestCdrService.log",  true ) ;
		
		TestCdrService objMmi = new TestCdrService(ApplicationAddress, "DSQL");
		DSqlTable m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(CHECK_MMI_STATEMENT, "269720367");
		
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		objMmi.setRequestBytes(encodedASN1Request);
		objMmi.callService();
		byte[] serializedASN1Response = objMmi.getResponseBytes();
		DSqlTable m_responseDSqlTable = null;
		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);
		}
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();		
		log.debug("# rows: " + tmpRows.size());	
		
		if(tmpRows.size() > 0) {		
			
			log.debug("checkMmi output: <" + tmpRows.size() +">");
			log.debug("End :: checkMmi");
		}
		
		// System.out.println("12345690: CheckMmi Reply: " + objMmi.checkMmi("12345690"));
		// System.out.println("269720367: CheckMmi Reply: " + objMmi.checkMmi("269720367"));
	}
	
}
