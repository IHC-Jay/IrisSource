/*******************************************************************************
 * Copyright (c) 2002, SeeBeyond Technology Corporation, All Rights Reserved * *
 * This program, and all the routines referenced herein, are the proprietary *
 * properties and trade secrets of SEEBEYOND TECHNOLOGY CORPORATION. * * Except
 * as provided for by license agreement, this program shall not be * duplicated,
 * used or disclosed without the written consent, signed by an * officer of
 * SEEBEYOND TECHNOLOGY CORPORATION. * *
 ******************************************************************************/
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


public class ClinImmunizationEventFromEmpi extends CdrTuxServices
{
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = null;
	
	private static final String  SQL_STATEMENT =
    	"SELECT /* eGate Interface - ClinEventFromObservationETD */ EVENT_ID, EDIT_VERSION, to_char(event_start_gmtime, 'YYYYMMDDHH24MI') "
		+ " FROM PATIENT.EVENT " 
		+ " WHERE UNIT_NUMBER = :X0 " 
		+ "  and EVENT_TYPE_NCID = 90782 AND EVENT_SUBTYPE_NCID = 521095464" ;
	
	public ClinImmunizationEventFromEmpi(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.getInstance("ClinImmunizationEventFromEmpi");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}	
	
	public ClinImmunizationEventFromEmpi(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		super.setLogger("ClinImmunizationEventFromEmpi");
	}
	
	/**
	 * ClinEventFromObservationETD constructor
	 */
	public String ClinImmunizationEventFromEmpi(String empi) throws Exception
	{
		String retVal="";
		
		m_requestDSqlTable = EncodeUtil.prepareDSqlRequest(SQL_STATEMENT, empi);
		
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
            DSqlColumns tmpColumns  = ((DSqlRow)tmpRows.get(0)).getColumnsList();
            
            for (int columnNum =0; columnNum < tmpColumns.size(); columnNum++ ) {
                retVal += ((DSqlColumn)tmpColumns.get( columnNum )).getValue().getTextString()+"|";           
            }
			log.debug("row data: " + retVal);
		}
	
		return retVal;
	}

}