package org.ihc.itf.cdr;

import org.apache.log4j.Logger;
import org.ihc.itf.util.ItfLoggerHash;


public class CdrTuxStringAddUpdate extends CdrTuxServices {

	private static Logger log = null;
	private String m_serviceName = null;

	
	public CdrTuxStringAddUpdate(String applicationAddress, String serviceName) throws Exception
	{
		
		super(applicationAddress, serviceName);
		m_serviceName = serviceName;
	}
	
	public CdrTuxStringAddUpdate(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		m_serviceName = serviceName;
		log = ItfLoggerHash.setLoggerProperties("CdrTuxStringAddUpdate", fileName, (debug == 1) ? true : false) ;
		super.setLogger("CdrTuxStringAddUpdate");
		log.debug("Created the service: " + m_serviceName);
	}
	
	public String callAddUpdate(String data) throws Exception {
	
		byte[] responseEvent = null;

		byte[] m_requestBytes = data.getBytes();	
		byte[] encData = EncodeUtil.encodeRequest(m_requestBytes);
		String resp = null;
		
		setRequestBytes(encData);
		log.debug("Call Service");
		callService();
		byte[] serializedASN1Response = getResponseBytes();

		if (null != serializedASN1Response) {
			log.debug("Got ASN1 string");
			responseEvent = EncodeUtil.decodeResponse(serializedASN1Response);			
			resp = new String(responseEvent);	
			log.debug("Resp from the service: " + resp);
		}
		return resp;
				
	}
	
}
