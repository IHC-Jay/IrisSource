
package org.ihc.itf.cdr.Immu;
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

public class ClinActionInfoByEventID extends CdrTuxServices
{
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = null;
	private final static String SQL_STATEMENT =  "SELECT CLINICIAN_ID_NCID, " +
        " ACTION_TYPE_NCID, ENTERED_BY_NCID, to_char(ENTERED_TIME, 'YYYYMMDDHH24MISS'),  LOCATION_NCID, " +
        " EDIT_VERSION,   REASON_NCID,  " +
        " LOCATION_TYPE_NCID, POC_LOCATION_TYPE_NCID, POC_LOCATION_NCID, APPLICATION_NCID  " +
        " FROM ACTION_INFO where EVENT_ID =:X0  " +	// eventId +
        " ORDER BY EDIT_VERSION  ";
    

	public ClinActionInfoByEventID(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.getInstance("ClinActionInfoByEventID");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}	
	
	public ClinActionInfoByEventID(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("ClinActionInfoByEventID", fileName, (debug == 1) ? true : false) ;
		super.setLogger("ClinActionInfoByEventID");
	}

	public String ClinActionInfoByEventID(String eid) throws Exception
	{
		String retVal="";
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(SQL_STATEMENT, eid);
		
		byte[] encodedASN1Request = EncodeUtil.dsqlEncode(m_requestDSqlTable);			
		setRequestBytes(encodedASN1Request);
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			m_responseDSqlTable = (DSqlTable) EncodeUtil.dsqlDecode(serializedASN1Response);
		}
		
		DSqlRows tmpRows = m_responseDSqlTable.getRowsList();		
		log.debug("# rows: " + tmpRows.size());
		
		if(tmpRows.size()>0) {
			for (int i=0; i<tmpRows.size();i++) {
               DSqlColumns tmpColumns  = ((DSqlRow)tmpRows.get(i)).getColumnsList();
               if (retVal.length() > 0) {
            	   retVal +="&";
               }
               for (int columnNum =0; columnNum < tmpColumns.size(); columnNum++ ) {
                  retVal += ((DSqlColumn)tmpColumns.get( columnNum )).getValue().getTextString()+"|";           
               }
			}
			log.debug("row data: " + retVal);
		}

		return retVal;
	}

}