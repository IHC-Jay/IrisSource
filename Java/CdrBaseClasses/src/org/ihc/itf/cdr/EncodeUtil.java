package org.ihc.itf.cdr;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.math.BigInteger;

import org.ihc.itf.util.ItfLogger;

import cdr.asn1.BaseDecoder;
import cdr.asn1.BaseEncoder;
import cdr.asn1.DecodingException;
import cdr.asn1.EncodingException;
import cdr.asn1.base.Coded;
import cdr.asn1.base.VisibleString;
import cdr.asn1.dsql.DSqlArguments;
import cdr.asn1.dsql.DSqlTable;
import cdr.asn1.hems.MmiInfo;
import cdr.asn1.hirs.HIRSInfo;
import cdr.asn1.hirs.TalkInfo;
import cdr.asn1.hirs.TransMessage;

public class EncodeUtil {
	private static final Coded MAGIC_SQL_NCID   = new Coded( BigInteger.valueOf( 1450582 ) );
	
	public static byte[] encode(MmiInfo serializedASN1Request) throws Exception{
		BaseEncoder baseEncoder = new BaseEncoder(new ByteArrayOutputStream());
		byte[] encodedASN1Request = null;
		try {
			baseEncoder.encodeObject(serializedASN1Request);
			encodedASN1Request = ((ByteArrayOutputStream) baseEncoder.getOutputStream()).toByteArray();
		} catch (EncodingException encEx) {
			throw encEx;
		} finally {
			//
		}
		return encodedASN1Request;
	}

	
	public static MmiInfo decode(byte[] serializedASN1Response) throws Exception{
		MmiInfo mmiInfo = null;

		try {
			BaseDecoder asn1Decoder = new BaseDecoder(new ByteArrayInputStream(serializedASN1Response));
			mmiInfo = (MmiInfo) asn1Decoder.decodeObject(MmiInfo.class);
		} catch (DecodingException decEx) {			
			throw decEx;
		}
		return mmiInfo;
	}
	
	public static Object dsqlDecode(byte[] encodedASN1Response) throws Exception{
		Object responseDSqlTable = null;
		try {
			BaseDecoder asn1Decoder = new BaseDecoder(new ByteArrayInputStream(encodedASN1Response));
			responseDSqlTable = (DSqlTable) asn1Decoder.decodeObject(DSqlTable.class);
		} catch (DecodingException decEx) {			
			throw new Exception("DECODEEXCEPTION, Error while decoing DSQL response. ");
		}
		return responseDSqlTable;
	}
	
	public static DSqlTable prepareDSqlRequest(String... args){
		DSqlTable m_requestDSqlTable = new DSqlTable();
		m_requestDSqlTable.setSqlId(MAGIC_SQL_NCID);
		
		DSqlArguments argumentList = new DSqlArguments();
		for (int i = 0; i < args.length; i++){
			ItfLogger.getInstance().debug("argumentList: " + args[i]);
			argumentList.add(i, new VisibleString(args[i]));			
	    }
		m_requestDSqlTable.setArgumentsList(argumentList);
		
		return m_requestDSqlTable;
		
	}
	public static  byte[] dsqlEncode( DSqlTable m_requestDSqlTable) throws Exception{
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
	
	public static byte[] encodeRequest(byte[] requestEvent) throws Exception{
		byte[] encodedASN1Request = null;		
		BaseEncoder m_asn1Encoder = new cdr.asn1.BaseEncoder(new ByteArrayOutputStream());
		
		HIRSInfo m_HirsInfo = new HIRSInfo();
		m_HirsInfo.setTalkInfo(new TalkInfo());
		m_HirsInfo.getTalkInfo().setTransMessage(new TransMessage());		
		
		try {
			ByteArrayOutputStream outStream = (ByteArrayOutputStream) m_asn1Encoder.getOutputStream();
			outStream.reset();
			m_HirsInfo.getTalkInfo().getTransMessage().setInfoHL7(requestEvent);
			m_asn1Encoder.encodeObject(m_HirsInfo);

			encodedASN1Request = outStream.toByteArray();
			outStream.reset();
		} catch (Exception encEx) {
			throw encEx;
		}
		return encodedASN1Request;
	}

	public static byte[] decodeResponse(byte[] encodedASN1Response) throws Exception{

		byte[] decodedResponse = null;

		try {
			cdr.asn1.BaseDecoder tmpDecoder = new cdr.asn1.BaseDecoder(new ByteArrayInputStream(encodedASN1Response));
			HIRSInfo responseHirsInfo = (HIRSInfo) tmpDecoder.decodeObject(HIRSInfo.class);
			decodedResponse = responseHirsInfo.getTalkInfo().getTransMessage().getInfoHL7();
		} catch (Exception decEx) {
			throw decEx;
		}
		return decodedResponse;
	}

}
