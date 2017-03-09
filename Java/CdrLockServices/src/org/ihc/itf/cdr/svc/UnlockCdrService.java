package org.ihc.itf.cdr.svc;


import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLogger;

import cdr.asn1.hems.DataRecord;
import cdr.asn1.hems.MmiInfo;
import cdr.asn1.hems.MmiRecord;

public class UnlockCdrService  extends CdrTuxServices {
	
	private static Logger log = null;

	private String m_serviceName;
	
	public UnlockCdrService(String applicationAddress, String serviceName)
			throws Exception {
		super(applicationAddress, serviceName);
		m_serviceName = serviceName;
		log = ItfLogger.getInstance();
	}

	public void callUnlockCdrService(MmiRecord mmiRecs[]) throws Exception
	{
		MmiInfo m_MmiInfo = new MmiInfo();		
		DataRecord dataRecord = new DataRecord();
		
		 dataRecord.setMmiRecords(mmiRecs);
         m_MmiInfo.setDataRecord(dataRecord);
         log.debug("Encoding MmiInfo...");
         //Unlock Request
         // CdrTuxService unlockService = new CdrTuxService(applicationAddress, UnlockServiceName);
         byte serializedASN1Request3[] = EncodeUtil.encode(m_MmiInfo);
         log.debug("UnLock Request..." + new String(serializedASN1Request3));            
         log.debug("Calling Unlock Service..." + m_serviceName);            
         setRequestBytes(serializedASN1Request3);
         callService();
         byte serializedASN1Response3[] = getResponseBytes();                
         m_MmiInfo = (MmiInfo)EncodeUtil.decode(serializedASN1Response3);
	}
	
}
