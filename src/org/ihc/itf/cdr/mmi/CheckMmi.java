package org.ihc.itf.cdr.mmi;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLoggerHash;

import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;

public class CheckMmi extends CdrTuxServices {
	
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = null;
		
	public CheckMmi(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.getInstance("CheckMmi");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}	
	
	public CheckMmi(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("CheckMmi", fileName, (debug == 1) ? true : false) ;
		super.setLogger("CheckMmi");
	}
	
	public boolean checkMmi(String unitNum) throws Exception {			
		
		log.debug("Begin :: checkMmi for " + unitNum);
		
		boolean retVal = false;
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(CHECK_MMI_STATEMENT, unitNum);
		
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);
		}
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();		
		log.debug("# rows: " + tmpRows.size());	
		
		if(tmpRows.size() > 0) {		
			retVal = true;
		}
		
		log.debug("checkMmi output: <" + retVal +">");
		log.debug("End :: checkMmi");
		
		return retVal;
	}
	
	
   
	
	private static final String	CHECK_MMI_STATEMENT = "SELECT unit_number FROM mmi_id" +
													  " WHERE unit_number = :X0";
}
