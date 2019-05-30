package org.ihc.itf.cdr;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

import cdr.asn1.BaseEncoder;
import cdr.asn1.hirs.HIRSInfo;
import cdr.asn1.hirs.TalkInfo;
import cdr.asn1.hirs.TransMessage;

public class CdrHl7AddUpdate extends CdrTuxServices {
	
	public CdrHl7AddUpdate(String applicationAddress, String serviceName) throws Exception
	{
		super(applicationAddress, serviceName);
	}
	
	public String callAddUpdate(String data) throws Exception{		
		byte[] responseEvent = null;
		
		byte[] m_requestBytes = data.getBytes();	
		byte[] encData = encodeRequest(m_requestBytes);
		String resp = null;
		
		setRequestBytes(encData);
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			responseEvent = decodeResponse(serializedASN1Response);			
			resp = new String(responseEvent);			
		}
		return resp;
    }
	
	
	private static byte[] encodeRequest(byte[] requestEvent) throws Exception{
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

	private static byte[] decodeResponse(byte[] encodedASN1Response) throws Exception{

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
