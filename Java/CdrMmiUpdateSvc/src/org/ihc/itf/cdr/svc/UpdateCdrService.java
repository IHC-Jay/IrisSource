package org.ihc.itf.cdr.svc;

import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLogger;

import cdr.asn1.hems.MmiInfo;

public class UpdateCdrService extends CdrTuxServices {
	private static Logger log = null;
	private String m_serviceName;
	
	
	public UpdateCdrService(String applicationAddress, String serviceName)
			throws Exception {
		
		super(applicationAddress, serviceName);
		log = ItfLogger.getInstance();
		m_serviceName = serviceName;
		log.debug("In UpdateCdrService");
	}

	public String callUpdateCdrService(MmiInfo m_MmiInfo) throws Exception {
		String returnValue = "0";
		try {
			log.debug("callUpdateCdrService");
			byte serializedASN1Request2[] = EncodeUtil.encode(m_MmiInfo);
			log.debug("Update Request..." + new String(serializedASN1Request2));
			log.debug("Calling Update Service... " + m_serviceName);
			setRequestBytes(serializedASN1Request2);
			callService();
			byte serializedASN1Response2[] = getResponseBytes();
			m_MmiInfo = (MmiInfo) EncodeUtil.decode(serializedASN1Response2);
			log.debug("Is Response NULL: " + (m_MmiInfo == null));
			if (m_MmiInfo != null) {
				returnValue = "1";
			}		
		} catch (Exception ex) {
			log.error("Exception in " + m_serviceName + ": " + ex.getMessage());
			throw ex;

		}
		log.debug("End addressUpdateMMI");

		return returnValue;
	}
}
