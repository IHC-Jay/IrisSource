package org.ihc.itf.cdr.mmi;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLoggerHash;

import cdr.asn1.dsql.DSqlColumn;
import cdr.asn1.dsql.DSqlColumns;
import cdr.asn1.dsql.DSqlRow;
import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;


public class CdrMmiEvents extends CdrTuxServices {
	
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = null;
		
	public CdrMmiEvents(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("CdrMmiEvents", fileName, (debug == 1) ? true : false) ;
		super.setLogger("CdrMmiEvents");
	}	
	
	public CdrMmiEvents(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.getInstance("CdrMmiEvents");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}

	public String loadMmiEvents(String mmiNum) throws Exception {	
		
		log.debug("Begin :: loadMmiEvents");
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(LOAD_MMI_STATEMENT, mmiNum);		
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService(); //call service
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);
		}
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();
		log.debug("# rows: " + tmpRows.size());
		StringBuffer output = new StringBuffer();
		
		for (int rowNum = 0; rowNum < tmpRows.size(); rowNum++) { // add rows
			DSqlColumns tmpColumns = ((DSqlRow) tmpRows.get(rowNum)).getColumnsList();
			for (int columnNum = 0; columnNum < tmpColumns.size(); columnNum++) { // add columns
				String sResult = ((DSqlColumn) tmpColumns.get(columnNum)).getValue().getTextString();
				output = output.append(sResult);
				if(columnNum != tmpColumns.size()-1) {
					output = output.append(COLUMN_BREAK);
				}
			}				
			if(rowNum != tmpRows.size()-1) {
				output = output.append(LINE_BREAK);
			}
		}		
		log.debug("loadMmiEvents output: <" + output +">");
		log.debug("End :: loadMmiEvents");
		return output.toString();
	}

	public boolean checkMmiEvents(String unitNum, String auditNum) throws Exception {			
		
		log.debug("Begin :: checkMmiEvents");
		
		boolean retVal = false;
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(CHECK_MMI_STATEMENT, unitNum, auditNum);
		
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
		log.debug("checkMmiEvents output: <" + retVal +">");
		log.debug("End :: checkMmiEvents");
		return retVal;
	}
	
	public boolean unloadMmiEvents(String unitNum, String auditNum) throws Exception {			
		
		log.debug("Begin :: unloadMmiEvents");
		
		boolean retVal = false;
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(UNLOAD_MMI_STATEMENT, unitNum, auditNum);
		
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
		log.debug("unloadMmiEvents output: <" + retVal +">");
		log.debug("End :: unloadMmiEvents");
		return retVal;
	}
	
	public String checkMergeMmi(String unitNum, String auditNum) throws Exception {			
		
		log.debug("Begin :: checkMergeMmi");
		
		String retVal = "false";
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(CHECK_MERGE_MMI_STATEMENT, unitNum, auditNum);
		
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);
		}
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();
		log.debug("# rows: " + tmpRows.size());
		if(tmpRows.size() > 0){
			DSqlColumns tmpColumns = ((DSqlRow) tmpRows.get(0)).getColumnsList();
			if(tmpColumns.size() > 0){
				retVal = ((DSqlColumn) tmpColumns.get(0)).getValue().getTextString();
			}
		}		
		
		log.debug("checkMergeMmi output: <" + retVal +">");
		log.debug("End :: checkMergeMmi");
		return retVal;
	}
	
	
	private static final String LINE_BREAK = ";";
	
	private static final String COLUMN_BREAK = "|";	
	
	private static final String LOAD_MMI_STATEMENT = "select unit_number,audit_num," +
											         "tx_type_cid, to_char(tx_time,'YYYYMMDDHH24MI')," +
											         "employee,application, application_version," +
											         "mmi_version,facility_cid" +
											         " from mmi.mmi_itf_event_queue" +
											         " where rownum < :X0" +
											         " order by tx_time";
		
	private static final String	CHECK_MMI_STATEMENT = "select unit_number from mmi.mmi_site_audit" + 
											          " WHERE unit_number = :X0 and ROW_DELETE_AUDIT_NUM = :X1";
		
	private static final String	UNLOAD_MMI_STATEMENT = "delete mmi.mmi_itf_event_queue" +
													   " WHERE unit_number = :X0 and audit_num = :X1 ";
	
	private static final String	CHECK_MERGE_MMI_STATEMENT = "select PRESERVE_UNIT_NUMBER from  mmi.mmi_merge_log" +
			   										   		" WHERE DROP_UNIT_NUMBER = :X0 AND MERGE_AUDIT_NUMBER = :X1";
}
