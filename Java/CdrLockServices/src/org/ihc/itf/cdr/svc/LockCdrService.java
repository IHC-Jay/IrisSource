package org.ihc.itf.cdr.svc;


import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLogger;

import cdr.asn1.hems.DataRecord;
import cdr.asn1.hems.MmiInfo;
import cdr.asn1.hems.MmiRecord;

public class LockCdrService extends CdrTuxServices {
	private static Logger log = null;
	private String m_serviceName;
	
	public LockCdrService(String applicationAddress,
			String serviceName) throws Exception {
		super(applicationAddress, serviceName);
		m_serviceName = serviceName;
		log = ItfLogger.getInstance();
	}
	
	public MmiRecord[] callLockCdrService(MmiInfo m_MmiInfo, int maxRetries, int retryTimeoutSeconds) throws Exception{
		
		// DataRecord m_DataRecord = new DataRecord();		
		DataRecord dataRecord = new DataRecord();	
        MmiRecord mmiRecs[] = new MmiRecord[1];

		byte serializedASN1Request[] = EncodeUtil.encode(m_MmiInfo);
		
		 
         log.debug("Lock Request..." + new String(serializedASN1Request));            
         log.debug("Calling Lock Service..." + m_serviceName);            
         setRequestBytes(serializedASN1Request);
         byte serializedASN1Response[] = (byte[])null;
         int tryCnt = 0;
         for(boolean done = false; !done;){
         	callService();
         	serializedASN1Response = getResponseBytes();            	
             log.debug("Lock Response size: " + serializedASN1Response.length);                
             m_MmiInfo = (MmiInfo)EncodeUtil.decode(serializedASN1Response);
             log.debug("Getting DataRecord...");
             dataRecord = m_MmiInfo.getDataRecord();
             
             log.debug("Getting MmiRecords...");
             
             try {
                 mmiRecs = dataRecord.getMmiRecords();                    
                 log.debug("Got lock for Unit Number: " + mmiRecs[0].getUnitNumber());
                 done = true;
             }catch(NullPointerException ne) {
            	 log.error("Exception in " + m_serviceName + ": " + ne.getMessage());
                 tryCnt++;
                 log.info("Record is locked ..., Try # " + tryCnt);
                 if(tryCnt >= maxRetries){
                 	throw new Exception("Record is locked.");
                 }
                 try {
                     Thread.sleep(retryTimeoutSeconds * 1000);
                 }
                 catch(InterruptedException exception) { }
             }
         }
         return mmiRecs;
	}
	
	
}
