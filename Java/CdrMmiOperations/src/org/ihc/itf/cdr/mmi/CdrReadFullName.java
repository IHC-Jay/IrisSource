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

/*
 * Returns patient name in the format (LastName,FirstName,MiddleName)
 * Empty means no name exists
 * 
 */
public class CdrReadFullName extends CdrTuxServices {
	
	private static Logger log = null;
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	public CdrReadFullName(String applicationAddress, String serviceName) throws Exception
	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.getInstance("CdrReadFullName");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}

	public CdrReadFullName(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("CdrReadFullName", fileName, (debug == 1) ? true : false) ;
		super.setLogger("CdrReadFullName");
	}
	
	public String GetLastAndFirstName(String mmiNum) throws Exception {
		log.debug(" In GetLastAndFirstName:MmiNum: " + mmiNum);
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(SQL_STATEMENT, mmiNum);
		m_responseDSqlTable = null;
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService(); 
		byte[] serializedASN1Response = getResponseBytes();
		m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);		
		
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();
		log.debug("# rows: " + tmpRows.size());
		
		
		String fullName = "";
        for (int rowNum= 0; rowNum < tmpRows.size() ; rowNum++) {
            DSqlColumns tmpColumns  = ((DSqlRow)tmpRows.get(rowNum)).getColumnsList();
        
            for (int columnNum =0; columnNum < tmpColumns.size(); columnNum++ ) {
                String sResult = ((DSqlColumn)tmpColumns.get( columnNum )).getValue().getTextString();
                fullName += sResult + ",";                
            }
        }
        if (fullName.trim().length()>0){
        	fullName = fullName.substring(0,fullName.lastIndexOf(","));
        }
        log.debug("Names: (LastName,FirstName,MiddleName) " +fullName );		
		
		return fullName;
		
	}
	
	private static final String	SQL_STATEMENT = "SELECT last_name, first_name, middle_name FROM mmi_name"
			+ " WHERE unit_number = :X0";

}
