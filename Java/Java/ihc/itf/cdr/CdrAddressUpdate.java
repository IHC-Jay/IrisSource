package org.ihc.itf.cdr;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.util.SimpleTimeZone;

import org.apache.log4j.Logger;

import ca.uhn.hl7v2.DefaultHapiContext;
import ca.uhn.hl7v2.HapiContext;
import ca.uhn.hl7v2.model.Message;
import ca.uhn.hl7v2.model.v23.message.ADT_A01;
import ca.uhn.hl7v2.parser.PipeParser;
import ca.uhn.hl7v2.validation.impl.NoValidation;
import cdr.asn1.base.Coded;
import cdr.asn1.hems.Address;
import cdr.asn1.hems.Addresses;
import cdr.asn1.hems.Context;
import cdr.asn1.hems.DataRecord;
import cdr.asn1.hems.HemsInfo;
import cdr.asn1.hems.MemberInfo;
import cdr.asn1.hems.MmiInfo;
import cdr.asn1.hems.MmiRecord;
import cdr.asn1.hems.RequesterInfo;
import cdr.asn1.hems.UserSecurityTicket;

public class CdrAddressUpdate {

	private static Logger log = Logger.getLogger(CdrMmiUpdate.class.getName());
	private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
	private String applicationAddress;
	private String serviceName;
	private String lockServiceName;
	private String UnlockServiceName;
	private int maxRetries;
	private int retryTimeoutSeconds;
	
	
	public CdrAddressUpdate(String applicationAddress, String serviceName, String lockServiceName, String unlockServiceName, String maxRetries, String retryTimeoutSeconds) throws Exception	{
		this.applicationAddress = applicationAddress;
		this.serviceName = serviceName;
		this.lockServiceName = lockServiceName;
		this.UnlockServiceName = unlockServiceName;		
		this.maxRetries = Integer.parseInt(maxRetries);
		this.retryTimeoutSeconds = Integer.parseInt(retryTimeoutSeconds);
		this.dateFormat.setTimeZone(new SimpleTimeZone(0, "UTC"));
	}
	

	public String addressUpdateMMI(String hl7Msg) throws Exception{
		
		boolean lockedFlg = false;
		String returnValue = "0";
		
		MemberInfo m_memberInfo = new MemberInfo();
		DataRecord m_DataRecord = new DataRecord();
		MmiRecord m_mmiRec = new MmiRecord();
		MmiRecord m_mmiRecs[] = new MmiRecord[1];	
		
		DataRecord dataRecord = new DataRecord();
		MmiInfo m_MmiInfo = new MmiInfo();			
        MmiRecord mmiRecs[] = new MmiRecord[1];
		
        try {
			log.debug("Start addressUpdateMMI");
			HapiContext hapiContext = new DefaultHapiContext();
			hapiContext.setValidationContext(new NoValidation());
			PipeParser pipeParser = hapiContext.getPipeParser();
			Message message = pipeParser.parse(hl7Msg);
			//GenericParser parser = context.getGenericParser();
			//Message message = parser.parse(hl7Msg);
			ADT_A01 msg = (ADT_A01) message;
		
			// ***** Populate messages from Hl7 record ************************
			// Unit Number
			m_mmiRec.setUnitNumber(new BigInteger(msg.getPID().getPatientIDInternalID(0).getID().getValue()));
			
			
			// Populate Addresses
			int addrCnt = msg.getPID().getPatientAddressReps();
            Addresses aAddresses = new Addresses();
            for(int addrIndx = 0; addrIndx < addrCnt; addrIndx++)
            {
            	Address address = new Address();            	            	
            	//set Street1
            	if(!isNOE(msg.getPID().getPatientAddress(addrIndx).getStreetAddress().getValue())) {
            		address.setStreet1(msg.getPID().getPatientAddress(addrIndx).getStreetAddress().getValue());
            	
	            	//set Street2
	            	if(!isNOE(msg.getPID().getPatientAddress(addrIndx).getOtherDesignation().getValue())) {
	            		address.setStreet2(msg.getPID().getPatientAddress(addrIndx).getOtherDesignation().getValue());
	            	}
	                //set City
	            	if(!isNOE(msg.getPID().getPatientAddress(addrIndx).getCity().getValue())) {
	            		address.setCity(msg.getPID().getPatientAddress(addrIndx).getCity().getValue());
	            	}
	                //set State
	            	if(!isNOE(msg.getPID().getPatientAddress(addrIndx).getStateOrProvince().getValue())) {
	            		address.setState(msg.getPID().getPatientAddress(addrIndx).getStateOrProvince().getValue());	
	            	} 
	            	//set Zip
	            	if(!isNOE(msg.getPID().getPatientAddress(addrIndx).getZipOrPostalCode().getValue())) {
	            		address.setPostCode(msg.getPID().getPatientAddress(addrIndx).getZipOrPostalCode().getValue());	
	            	} 
	            	//set Country
	            	if(!isNOE(msg.getPID().getPatientAddress(addrIndx).getCountry().getValue())) {
	            		address.setCountry(msg.getPID().getPatientAddress(addrIndx).getCountry().getValue());	
	            	} 
	                //set AddressType Ncid
	            	if(!isNOE(msg.getPID().getPatientAddress(addrIndx).getAddressType().getValue())) {
	                	address.setAddressTypeCid(new Coded(new BigInteger(msg.getPID().getPatientAddress(addrIndx).getAddressType().getValue())));
	                } else {
	                	address.setAddressTypeCid(new Coded(BigInteger.valueOf(199L)));
	                }
	            	aAddresses.add(address);
            	}
            }
			m_memberInfo.setAddressesList(aAddresses);
			
			m_mmiRec.setMemberInfo(m_memberInfo);
			m_mmiRecs[0] = m_mmiRec;
			m_DataRecord.setMmiRecords(m_mmiRecs);
						
			mmiRecs[0] = new MmiRecord();  
	        log.debug("Filling Unit Number ..." + m_DataRecord.getMmiRecords()[0].getUnitNumber());
            mmiRecs[0].setUnitNumber(m_DataRecord.getMmiRecords()[0].getUnitNumber());
            
            
            log.debug("Filling DataRecord...");
            dataRecord.setMmiRecords(mmiRecs);
            log.debug("Filling MmiInfo...");
            m_MmiInfo.setDataRecord(dataRecord);
            
            log.debug("Filling UserSecurityTicket...");
            UserSecurityTicket secTicket = new UserSecurityTicket();
            secTicket.setSTicket(null);
            
            log.debug("Filling RequestorInfo...");
            RequesterInfo requesterInfo = new RequesterInfo();
            requesterInfo.setRequesterEmployeeId(new Coded(new BigInteger(msg.getEVN().getEvn5_OperatorID().getIDNumber().getValue())));                        
            requesterInfo.setVersionCode(msg.getMSH().getMsh12_VersionID().getValue());
            requesterInfo.setApplicationName(msg.getMSH().getMsh3_SendingApplication().getNamespaceID().getValue());
            requesterInfo.setRequesterFacilityCid(new Coded(new BigInteger(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue())));
            
            log.debug("FillingHemsInfo...");
            HemsInfo hemsInfo = new HemsInfo();
            hemsInfo.setUserSecurityTicket(secTicket);
            hemsInfo.setRequesterInfo(requesterInfo);
            hemsInfo.setContext(new Context());
            m_MmiInfo.setHemsInfo(hemsInfo);
            
            log.debug("Encoding MmiInfo...");
          //Lock Request
            CdrTuxService lockService = new CdrTuxService(applicationAddress, lockServiceName);
            byte serializedASN1Request[] = lockService.encode(m_MmiInfo);
            log.debug("Lock Request..." + new String(serializedASN1Request));            
            log.debug("Calling Lock Service...");            
            lockService.setRequestBytes(serializedASN1Request);
            byte serializedASN1Response[] = (byte[])null;
            int tryCnt = 0;
            
            for(boolean done = false; !done;){
            	lockService.callService();
            	serializedASN1Response = lockService.getResponseBytes();            	
                log.debug("Lock Response size: " + serializedASN1Response.length);                
                m_MmiInfo = (MmiInfo)lockService.decode(serializedASN1Response);
                log.debug("Getting DataRecord...");
                dataRecord = m_MmiInfo.getDataRecord();
                
                log.debug("Getting MmiRecords...");
                
                try {
                    mmiRecs = dataRecord.getMmiRecords();                    
                    log.debug("Unit Number: " + mmiRecs[0].getUnitNumber());
                    done = true;
                }catch(NullPointerException ne) {
                    tryCnt++;
                    log.debug("Record is locked ..., Try " + tryCnt);
                    if(tryCnt >= maxRetries){
                    	lockService.shutdownTuxService();
                    	returnValue = "Record (" + m_DataRecord.getMmiRecords()[0].getUnitNumber() + ") is locked.";
                    	return returnValue;
                    }
                    try {
                        Thread.sleep(retryTimeoutSeconds * 1000);
                    }
                    catch(Exception exception) { }
                }
                lockService.shutdownTuxService();
                
                lockedFlg = true;
                log.debug("Setting MemberInfo...");
                MemberInfo memberInfo = mmiRecs[0].getMemberInfo();
                
                log.debug("Setting Addresses...");
                Address retAddresses[] = memberInfo.getAddresses();
                addrCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses().length;
                if(addrCnt == 1 && m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getAddressTypeCid() == null){
                	m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].setAddressTypeCid(new Coded(BigInteger.valueOf(199L)));
                }
                
                // Updating the Cdr Address with the values being passed from the collaboration
                String inAdd1 = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getStreet1();
                String inAdd2 = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getStreet2();
                String inCity = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getCity();
                String inSt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getState();
                String inZip = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getPostCode();
                String inCountry = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getCountry();

                  
                log.debug( "Jar Eway Input Address. inAdd1: " + inAdd1 + " inAdd2: " + inAdd2 + " inCity: " + inCity + " inSt: " + inSt + " inZip: " + inZip + " inCountry"+ inCountry);
                
             // Updating Cdr with the given address
    	      	retAddresses[0].setStreet1(inAdd1);
    	      	retAddresses[0].setStreet2(inAdd2);
    	      	retAddresses[0].setCity(inCity);
    	      	retAddresses[0].setState(inSt);
    	      	retAddresses[0].setPostCode(inZip);
    	      	retAddresses[0].setCountry(inCountry);

                mmiRecs[0].setMemberInfo(memberInfo);

                log.debug("Filling DataRecord...");
    		    dataRecord.setMmiRecords(mmiRecs);

    		    log.debug("Filling MmiInfo...");
    		    m_MmiInfo.setDataRecord(dataRecord);
    		    log.debug("Encoding MmiInfo...");
    		    
    		  //Update Request
                CdrTuxService updateService = new CdrTuxService(applicationAddress, serviceName);
                byte serializedASN1Request2[] = updateService.encode(m_MmiInfo);
                log.debug("Update Request..." + new String(serializedASN1Request2));            
                log.debug("Calling Update Service...");            
                updateService.setRequestBytes(serializedASN1Request2);
                updateService.callService();
                byte serializedASN1Response2[] = updateService.getResponseBytes();            
                m_MmiInfo = (MmiInfo)updateService.decode(serializedASN1Response2);
                if(m_MmiInfo != null) {
                	returnValue = "1";            	
                }
                updateService.shutdownTuxService();
                log.debug("End addressUpdateMMI");
                
                return returnValue;
                
                
            }
            
            
			
        } catch (Exception ex){
			//throw ex;
			return exceptionToString(ex);
		} finally {
			if(lockedFlg && !returnValue.equals("1")) {
                dataRecord.setMmiRecords(mmiRecs);
                m_MmiInfo.setDataRecord(dataRecord);
                log.debug("Encoding MmiInfo...");
                //Unlock Request
                CdrTuxService unlockService = new CdrTuxService(applicationAddress, UnlockServiceName);
                byte serializedASN1Request3[] = unlockService.encode(m_MmiInfo);
                log.debug("UnLock Request..." + new String(serializedASN1Request3));            
                log.debug("Calling Unlock Service...");            
                unlockService.setRequestBytes(serializedASN1Request3);
                unlockService.callService();
                byte serializedASN1Response3[] = unlockService.getResponseBytes();                
                m_MmiInfo = (MmiInfo)unlockService.decode(serializedASN1Response3);
                unlockService.shutdownTuxService();
            }
		}
        
        
        return returnValue;
		
	}
	
	private String exceptionToString(Exception e){
	    StringWriter sw = new StringWriter();
	    PrintWriter pw = new PrintWriter(sw);
	    e.printStackTrace(pw);
	    return sw.toString();
	}
	
	private boolean isNOE(String stringValue){
  	  return ((stringValue == null || stringValue.trim().length()==0) ? true : false);
  }
	
	}
	

