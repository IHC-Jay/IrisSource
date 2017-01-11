package org.ihc.itf.cdr;

import org.apache.log4j.Logger;  
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

import cdr.asn1.BaseDecoder;
import cdr.asn1.BaseEncoder;
import cdr.asn1.DecodingException;
import cdr.asn1.EncodingException;
import cdr.asn1.base.Coded;
import cdr.asn1.base.VisibleString;
import cdr.asn1.dsql.DSqlArguments;
import cdr.asn1.dsql.DSqlColumn;
import cdr.asn1.dsql.DSqlColumns;
import cdr.asn1.dsql.DSqlRow;
import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;
import cdr.asn1.hems.Facility;
import cdr.asn1.hems.MemberInfo;
import cdr.asn1.hems.MmiFlags;
import cdr.asn1.hems.Name;


public class CdrMmiEvents extends CdrTuxServices {
	
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = Logger.getLogger(CdrMmiEvents.class.getName());
		
	public CdrMmiEvents(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
	}	

	public String loadMmiEvents(String mmiNum) throws Exception {	
		
		log.debug("Begin :: loadMmiEvents");
		
		m_requestDSqlTable = prepareDSqlRequest(LOAD_MMI_STATEMENT, mmiNum);		
		byte[] encodedASN1Request = dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService(); //call service
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) dsqlDecode(serializedASN1Response);
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
		
		m_requestDSqlTable = prepareDSqlRequest(CHECK_MMI_STATEMENT, unitNum, auditNum);
		
		byte[] encodedASN1Request = dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) dsqlDecode(serializedASN1Response);
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
		
		m_requestDSqlTable = prepareDSqlRequest(UNLOAD_MMI_STATEMENT, unitNum, auditNum);
		
		byte[] encodedASN1Request = dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) dsqlDecode(serializedASN1Response);
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
		
		m_requestDSqlTable = prepareDSqlRequest(CHECK_MERGE_MMI_STATEMENT, unitNum, auditNum);
		
		byte[] encodedASN1Request = dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) dsqlDecode(serializedASN1Response);
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
	
	// Magic value for the Dsql service
	private static final Coded MAGIC_SQL_NCID   = new Coded( BigInteger.valueOf( 1450582 ) );
		

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
