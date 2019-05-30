package org.ihc.itf.cdr;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.math.BigInteger;
import java.util.Date;
import java.util.TimeZone;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

import org.apache.log4j.Logger;

import cdr.asn1.BaseEncoder;
import cdr.asn1.hems.DataRecord;
import cdr.asn1.hems.DateOfBirth;
import cdr.asn1.hems.Facility;
import cdr.asn1.hems.HemsInfo;
import cdr.asn1.hems.MemberInfo;
import cdr.asn1.hems.MmiInfo;
import cdr.asn1.hems.MmiRecord;
import cdr.asn1.hems.RequesterInfo;
import cdr.asn1.hems.UserSecurityTicket;

public class CdrReadMmi extends CdrTuxServices {
	/* Get actual class name to be printed on */
	private static Logger log = Logger.getLogger(CdrReadMmi.class.getName());
		
	public CdrReadMmi(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
	}
	
	public cdr.asn1.hems.MmiInfo getMMInfo(String unitNum) throws Exception {
		
		log.debug("Start :: readMMI");
		String applicationName = "Datagate";
		int requesterEmployeeId = 100;
		int requesterFacilityCid = 50450829;
		String versionCode = "1.0";
				
		MmiInfo m_MmiInfo = new MmiInfo();
		MmiInfo mmiInfo = new MmiInfo();
		DataRecord dataRecord = new DataRecord();
		MmiRecord[] mmiRecs = new MmiRecord[1];
		MmiRecord mmiRec = new cdr.asn1.hems.MmiRecord();
		RequesterInfo requesterInfo = new RequesterInfo();
		HemsInfo hemsInfo = new HemsInfo();
		
		log.debug("Filling Unit Number ...<" + new BigInteger(unitNum) + ">");	
		mmiRec.setUnitNumber(new BigInteger(unitNum));
		
		log.debug("Filling MmiRecord[] ...");
		mmiRecs[0] = mmiRec; 
		
		log.debug("Filling DataRecord...");
		dataRecord.setMmiRecords(mmiRecs);

		log.debug("Filling MmiInfo...");	
		m_MmiInfo.setDataRecord(dataRecord);
		
		log.debug("Filling UserSecurityTicket...");		
		UserSecurityTicket secTicket = new UserSecurityTicket();
		secTicket.setSTicket(null);
		
		log.debug("Filling RequestorInfo...");		
		requesterInfo.setRequesterEmployeeId(new cdr.asn1.base.Coded(BigInteger.valueOf(requesterEmployeeId)));
		requesterInfo.setVersionCode(versionCode);
		requesterInfo.setApplicationName(applicationName);
		requesterInfo.setRequesterFacilityCid(new cdr.asn1.base.Coded(BigInteger.valueOf(requesterFacilityCid)));
		
		log.debug("Filling HemsInfo...");
		hemsInfo.setUserSecurityTicket(secTicket);
		hemsInfo.setRequesterInfo(requesterInfo);
		hemsInfo.setContext(new cdr.asn1.hems.Context());		
		m_MmiInfo.setHemsInfo(hemsInfo);
		
		log.debug("Encoding MmiInfo...");		
		BaseEncoder mmiInfoEncoder = new BaseEncoder(new ByteArrayOutputStream());
		mmiInfoEncoder.encodeObject(m_MmiInfo);
		byte[] serializedASN1Request = ((ByteArrayOutputStream) mmiInfoEncoder.getOutputStream()).toByteArray();		
		setRequestBytes(serializedASN1Request);
		log.debug("Before calling TUXService...");		
		
		callService();
		
		log.debug("After calling TUXService...");
		byte[] serializedASN1Response = getResponseBytes();
		cdr.asn1.BaseDecoder mmiInfoDecoder = new cdr.asn1.BaseDecoder(new ByteArrayInputStream(serializedASN1Response));
		mmiInfo = (cdr.asn1.hems.MmiInfo) mmiInfoDecoder.decodeObject(cdr.asn1.hems.MmiInfo.class);
		
		if(mmiInfo != null){
			log.debug("Setting DataRecord...");
			DataRecord retDataRecord = mmiInfo.getDataRecord();
			
			log.debug("Setting MmiRecords...");			
			MmiRecord[] retMmiRecs = retDataRecord.getMmiRecords();
			
			log.debug("Setting MmiRecord...");
			MmiRecord retMmiRec = retMmiRecs[0];	
			
			log.debug("Setting MembInfo...");
			MemberInfo retMembInfo = retMmiRec.getMemberInfo();
			
			log.debug("Setting UnitNumber...<" + getVal(retMmiRec.getUnitNumber())+">");
			
			log.debug("Setting ReferenceId...<" + getVal(retMmiRec.getReferenceId())+">");
			
			log.debug("Setting MaidenName...<" + getVal(retMmiRec.getMaidenName())+">");
			
			log.debug("Setting MotherName...<" + getVal(retMmiRec.getMotherName())+">");
            
	        if(retMembInfo != null){	        		        	
		        cdr.asn1.hems.Name[] retNames = retMembInfo.getNames();	
                int nCnt = retNames.length;
               
                for(int i=0; i<nCnt; i++) 
                {
                    if(retNames[i].getNameTypeCid().getNcid().intValue() == 187)
                    {			
                    	retMembInfo.getNames()[0] = retNames[i];
                    }
                    else 
                    {
                    	retMembInfo.getNames()[i] = retNames[i];
                    }
		        }
                log.debug("Setting Names Length...<" + getVal(retMembInfo.getNames().length)+">");
                                
                log.debug("Setting Facilities Length...<" + getVal(retMembInfo.getFacilities().length)+">");
                
                for(int i=0;i<retMembInfo.getFacilities().length;i++){
                	Facility retFacility = retMembInfo.getFacilities()[i];
                	log.debug("Facility... at " + i + " : <" + getVal(retFacility.getMmiFacilityCid().getNcid())+">");
                }
	        
		        log.debug("Setting Address ...");
	            cdr.asn1.hems.Address[] retAddrs = retMembInfo.getAddresses();
	            boolean doneHA = false;
	            if(retAddrs != null) 
	            {
	                int aCnt = retAddrs.length;
	                if(aCnt > 0) 
	                {
	                    log.debug("Set Address ...<" + aCnt+">");
	                    for(int i=0; i<aCnt; i++) 
	                    {
	                        log.debug("Set Address ..." + i + " : " + getVal(retAddrs[i].getAddressTypeCid().getNcid().intValue()));
	                        int atype = retAddrs[i].getAddressTypeCid().getNcid().intValue();
	                        String addr1 = retAddrs[i].getStreet1();
	                        if(aCnt == 1 || !doneHA &&(atype == 199 || (atype == 0 && addr1 != null && addr1.length() > 0))) 
	                        {
	                        	retMembInfo.getAddresses()[0] = retAddrs[i];                            
	                            doneHA = true;
	                        }
	                        else 
	                        {
	                        	retMembInfo.getAddresses()[i] = retAddrs[i];
	                        }
	                    }
	                }
	            }
				
	            log.debug("Setting Phones...");
	            cdr.asn1.hems.Phone[] retPhones = retMembInfo.getPhones();         
	            if(retPhones != null) 
	            {
	                log.debug("Set Phones... ");                
	                int pCnt = retPhones.length;
	                log.debug("Filling Phones... <" + pCnt+">");
	                if(pCnt > 0) 
	                {
	                    boolean doneHP = false;
	                    for (int i = 0; i < pCnt; i++) 
	                    {
	                        String lPh = retPhones[i].getLocalNumber();
	                        log.debug("Phone Type: <" + retPhones[i].getPhoneTypeCid().getNcid().toString()+ " " + lPh+">");
	                        int ptype = retPhones[i].getPhoneTypeCid().getNcid().intValue();
	                       if(pCnt == 1 || !doneHP && (ptype == 193 || (ptype == 0 && lPh != null && lPh.length() > 0))) 
	                       {
	                    	   retMembInfo.getPhones()[0] = retPhones[i];
	                           doneHP = true;
	                       }
	                       else 
	                       {                           
	                    	   retMembInfo.getPhones()[i]= retPhones[i];
	                       }                               
	                   }
	                }
	            }           
	           
	            log.debug("Filling Sex...<" + getVal(retMembInfo.getSex())+">");
	        
		        log.debug("Filling SSN...<" + getVal(retMembInfo.getSsn())+">");
		        
		        if(retMembInfo.getMaritalStatusCid() != null){
		        	log.debug("Filling Marital Status...<" + getVal(retMembInfo.getMaritalStatusCid().getNcid())+">");
	            } else {
	            	log.debug("Filling Marital Status...<NULL>");
	            }
	            
	            
	            if(retMembInfo.getReligionCid() != null){
	            	log.debug("Filling Religion...<" + getVal(retMembInfo.getReligionCid().getNcid())+">");
	            } else {
	            	log.debug("Filling Religion...<NULL>");
	            }
	
	            if(retMembInfo.getRaceCid() != null){
	            	log.debug("Filling Race ...<" + getVal(retMembInfo.getRaceCid().getNcid())+">");
	            } else {
	            	log.debug("Filling Race...<NULL>");
	            }
	            
	            log.debug("Filling Language ...<" + getVal(retMembInfo.getPassPort())+">");
	            
	            log.debug("Filling Ethnicity ...<" + getVal(retMembInfo.getGovtHealthNumber())+">");
	            if(retMembInfo.getGovtHealthNumber()!= null) {
	            	String ethnicity = retMembInfo.getGovtHealthNumber();
	            	
	            	if (ethnicity != null && ethnicity.trim().length() >0 ){
	            		retMembInfo.setGovtHealthNumber(ethnicity);
	            	} else {
	            		retMembInfo.setGovtHealthNumber("");
	            	}
	            }
	                                       
	            if(retMembInfo.getDateOfBirth() != null && retMembInfo.getDateOfBirth().getBirthDate() != null){
	            	log.debug("Filling DOB ...<" + getVal(retMembInfo.getDateOfBirth().getBirthDate())+">");
	           	} else {
				    	log.debug("Filling DOB ... <NULL>");
				   }
	                
	            log.debug("Filling DOD ..." + getVal(retMembInfo.getDateOfDeath()));
	
			    log.debug("Filling dataRecord...");
			}		    
            
		} else {
            log.debug("Member info is null");
            mmiInfo = null;
        }		
		log.debug("End :: readMMI");
		return mmiInfo;
	}
	
	private Object getVal(Object input) {
		if(null != input){
			return input;
		} else {
			return new String("NULL");
		}
	}
	
	public String getDateValue(Date date) {		
		if(date != null) {
			SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddhhmmss");
			return formatter.format(date);
		} else {
			return "NULL";
		}
	}
	
}
