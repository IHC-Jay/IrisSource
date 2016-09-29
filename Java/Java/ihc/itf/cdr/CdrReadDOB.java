package org.ihc.itf.cdr;

import java.text.SimpleDateFormat;
import java.util.TimeZone;

import org.apache.log4j.Logger;

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
	
	private static Logger log = Logger.getLogger(CdrReadDOB.class.getName());
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	public CdrReadDOB(String applicationAddress, String serviceName) throws Exception
	{
		super(applicationAddress, serviceName);
	}
	
	public String GetDOB(String mmiNum) throws Exception {
		log.debug(" In GetDOB:MmiNum: " + mmiNum);
		
		m_requestDSqlTable = prepareDSqlRequest(SQL_STATEMENT, mmiNum);
		m_responseDSqlTable = null;
		byte[] encodedASN1Request = dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService(); 
		byte[] serializedASN1Response = getResponseBytes();
		m_responseDSqlTable = (DSqlTable) dsqlDecode(serializedASN1Response);		
		
		
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
