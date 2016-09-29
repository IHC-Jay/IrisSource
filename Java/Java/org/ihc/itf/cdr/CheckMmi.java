package org.ihc.itf.cdr;

import org.apache.log4j.Logger;   

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.math.BigInteger;

import cdr.asn1.BaseDecoder;
import cdr.asn1.BaseEncoder;
import cdr.asn1.DecodingException;
import cdr.asn1.EncodingException;
import cdr.asn1.base.Coded;
import cdr.asn1.base.VisibleString;
import cdr.asn1.dsql.DSqlArguments;
import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;

public class CheckMmi extends CdrTuxServices {
	
	private DSqlTable m_responseDSqlTable;
	private DSqlTable m_requestDSqlTable;
	
	/* Get actual class name to be printed on */
	private static Logger log = Logger.getLogger(CheckMmi.class.getName());
		
	public CheckMmi(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
	}	

	public boolean checkMmi(String unitNum) throws Exception {			
		
		log.debug("Begin :: checkMmi");
		
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
		
		log.debug("checkMmi output: <" + retVal +">");
		log.debug("End :: checkMmi");
		
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
	
	private static final String	CHECK_MMI_STATEMENT = "SELECT unit_number FROM mmi_id" +
													  " WHERE unit_number = :X0";
}
