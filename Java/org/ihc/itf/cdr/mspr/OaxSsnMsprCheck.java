package org.ihc.itf.cdr.mspr;

///import org.apache.log4j.BasicConfigurator;
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
 * Returns user ssn in mspr_id table
 *  
 */
public class OaxSsnMsprCheck extends CdrTuxServices {
	
	private static Logger log = null;
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	public OaxSsnMsprCheck(String applicationAddress, String serviceName) throws Exception
	{
		super(applicationAddress, serviceName);
		System.out.println("Initiate logger!");
		log = ItfLoggerHash.getInstance("OaxSsnMsprCheck");
	//	BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}

	public OaxSsnMsprCheck(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		System.out.println("Initiate logger2!");
		log = ItfLoggerHash.setLoggerProperties("OaxSsnMsprCheck", fileName, (debug == 1) ? true : false) ;
		System.out.println("Initiate logger3!");
		///super.setLogger("OaxSsnMsprCheck");
	}
	
	public String getSSN(String id, String idType) throws Exception {
		log.debug(" In GetSSN: Id: " + id + " Type: "+idType);
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(SQL_STATEMENT, id, idType);
		m_responseDSqlTable = null;
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService(); 
		byte[] serializedASN1Response = getResponseBytes();
		m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);		
		
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();
		log.debug("# rows: " + tmpRows.size());
		
		String ssnTmp = "";
        for (int rowNum= 0; rowNum < tmpRows.size() ; rowNum++) {
            DSqlColumns tmpColumns  = ((DSqlRow)tmpRows.get(rowNum)).getColumnsList();
            if(tmpColumns!=null) {
              ssnTmp = ((DSqlColumn)tmpColumns.get( 0 )).getValue().getTextString();
            }
        }
        

		return ssnTmp;     
		
	}
	
	private static final String	SQL_STATEMENT = 
		"SELECT ssn from mspr.mspr_generic_id a,mspr.mspr_id b "
		+ "where a.UNIT_NUMBER = b.UNIT_NUMBER and "
		+ "b.DEACTIVATE_FLAG is null and "
		+ "a.id_value = :X0 and a.ID_TYPE_NCID= :X1";
}
