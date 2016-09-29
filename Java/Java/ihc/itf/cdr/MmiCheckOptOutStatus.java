package org.ihc.itf.cdr;

import org.apache.log4j.Logger;   

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

import cdr.asn1.BaseDecoder;
import cdr.asn1.BaseEncoder;
import cdr.asn1.DecodingException;
import cdr.asn1.EncodingException;
import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;

public class MmiCheckOptOutStatus extends CdrTuxServices {
	
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = Logger.getLogger(MmiCheckOptOutStatus.class.getName());
		
	public MmiCheckOptOutStatus(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
	}	

	public boolean checkOptOutStatus(String unitNum) throws Exception {			
		
		log.debug("Begin :: checkOptOutStatus");
		
		boolean retVal = false;
		
		m_requestDSqlTable = prepareDSqlRequest(CHECK_MMI_STATEMENT, unitNum);
		
		byte[] encodedASN1Request = this.dsqlEncode();			
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
		
		log.debug("checkOptOutStatus output: <" + retVal +">");
		log.debug("End :: checkOptOutStatus");
		
		return retVal;
	}
	
	
    protected byte[] dsqlEncode() throws Exception{
		BaseEncoder dsqlTransEncoder = new BaseEncoder(new ByteArrayOutputStream());
		byte[] encodedASN1Request = null;
		try {
			dsqlTransEncoder.encodeObject(m_requestDSqlTable);
			encodedASN1Request = ((ByteArrayOutputStream) dsqlTransEncoder.getOutputStream()).toByteArray();
		} catch (EncodingException encEx) {
			throw encEx;
		} finally {
			//
		}
		return encodedASN1Request;
	}

	protected Object dsqlDecode(byte[] encodedASN1Response) throws Exception{
		Object responseDSqlTable = null;

		try {
			BaseDecoder asn1Decoder = new BaseDecoder(new ByteArrayInputStream(encodedASN1Response));
			responseDSqlTable = (DSqlTable) asn1Decoder.decodeObject(DSqlTable.class);
		} catch (DecodingException decEx) {			
			throw decEx;
		}
		return responseDSqlTable;
	}
	
	private static final String	CHECK_MMI_STATEMENT = "SELECT * FROM mmi.data_access WHERE person1_id = :X0" +
			        " AND target_sys_ncid = 1450530" + 
			        " AND action_ncid = 10482111" + 
			        " AND (expiration_date IS NULL OR expiration_date > Sysdate)";
}
