package org.ihc.itf.cdr.mmi;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLoggerHash;

import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;

public class MmiCheckOptOutStatus extends CdrTuxServices {
	
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = null;
		
	public MmiCheckOptOutStatus(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.getInstance("MmiCheckOptOutStatus");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}	
	
	public MmiCheckOptOutStatus(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("MmiCheckOptOutStatus", fileName, (debug == 1) ? true : false) ;
		super.setLogger("MmiCheckOptOutStatus");
	}
	
	public boolean checkOptOutStatus(String unitNum) throws Exception {			
		
		log.debug("Begin :: checkOptOutStatus");
		
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
		
		log.debug("checkOptOutStatus output: <" + retVal +">");
		log.debug("End :: checkOptOutStatus");
		
		return retVal;
	}
	
		
	private static final String	CHECK_MMI_STATEMENT = "SELECT * FROM mmi.data_access WHERE person1_id = :X0" +
			        " AND target_sys_ncid = 1450530" + 
			        " AND action_ncid = 10482111" + 
			        " AND (expiration_date IS NULL OR expiration_date > Sysdate)";
}
