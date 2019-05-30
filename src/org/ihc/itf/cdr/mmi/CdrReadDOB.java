package org.ihc.itf.cdr.mmi;

import java.text.SimpleDateFormat;
import java.util.TimeZone;

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

/*
 * Returns patient date of birth in yyyymmdd format
 *  
 */
public class CdrReadDOB extends CdrTuxServices {
	
	private static Logger log = null;
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	public CdrReadDOB(String applicationAddress, String serviceName) throws Exception
	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.getInstance("CdrReadDOB");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}

	public CdrReadDOB(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("CdrReadDOB", fileName, (debug == 1) ? true : false) ;
		super.setLogger("CdrReadDOB");
	}
	
	public String GetDOB(String mmiNum) throws Exception {
		log.debug(" In GetDOB:MmiNum: " + mmiNum);
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(SQL_STATEMENT, mmiNum);
		m_responseDSqlTable = null;
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService(); 
		byte[] serializedASN1Response = getResponseBytes();
		m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);		
		
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();
		log.debug("# rows: " + tmpRows.size());
		
		
		java.util.Date dateTmp = null;
        for (int rowNum= 0; rowNum < tmpRows.size() ; rowNum++) {
            DSqlColumns tmpColumns  = ((DSqlRow)tmpRows.get(rowNum)).getColumnsList();
            
            for (int columnNum =0; columnNum < tmpColumns.size(); columnNum++ ) {
                dateTmp = ((DSqlColumn)tmpColumns.get( columnNum )).getValue().getDate();           
            }
        }
        
        if(dateTmp != null) {
			SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
			formatter.setTimeZone(TimeZone.getTimeZone("GMT"));			
			return formatter.format(dateTmp);
		} else {
			return "";
		}       
		
	}
	
	private static final String	SQL_STATEMENT = 
		"SELECT birth_date FROM mmi_id"
			+ " WHERE unit_number = :X0"
			;
}
