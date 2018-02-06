package org.ihc.itf.cdr.mmi;

import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.util.SimpleTimeZone;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
import org.ihc.itf.cdr.EncodeUtil;
import org.ihc.itf.util.ItfLoggerHash;

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
import cdr.asn1.hems.DateOfBirth;
import cdr.asn1.hems.Facility;
import cdr.asn1.hems.HemsInfo;
import cdr.asn1.hems.MemberInfo;
import cdr.asn1.hems.MmiFlags;
import cdr.asn1.hems.MmiInfo;
import cdr.asn1.hems.MmiRecord;
import cdr.asn1.hems.Name;
import cdr.asn1.hems.Names;
import cdr.asn1.hems.Phone;
import cdr.asn1.hems.Phones;
import cdr.asn1.hems.RequesterInfo;
import cdr.asn1.hems.UserSecurityTicket;

public class CdrMmiAdd extends CdrTuxServices {
	/* Get actual class name to be printed on */
	private static Logger log = null;
	private static String CERNER_FAC_NCID = "525935320";
	private static String CB_FAC_NCID="2000000341";
	private static final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
	
	public CdrMmiAdd(String applicationAddress, String serviceName, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("CdrMmiAdd", fileName, (debug == 1) ? true : false) ;
		dateFormat.setTimeZone(new SimpleTimeZone(0, "UTC"));
		super.setLogger("CdrMmiAdd");
	}
	
	public CdrMmiAdd(String applicationAddress, String serviceName) throws Exception	{
		super(applicationAddress, serviceName);
		dateFormat.setTimeZone(new SimpleTimeZone(0, "UTC"));
		log = ItfLoggerHash.getInstance("CdrMmiAdd");
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
	}
	
	public String addMMI(String hl7Msg) throws Exception{
		log.debug("addMMi Entered");
		String retUnitNumber = "";		
		try {
			HapiContext hapiContext = new DefaultHapiContext();			
			hapiContext.setValidationContext(new NoValidation());
			PipeParser pipeParser = hapiContext.getPipeParser();			
			Message message = pipeParser.parse(hl7Msg);
			ADT_A01 msg = (ADT_A01) message;
			
			UserSecurityTicket secTicket = new UserSecurityTicket();			
			RequesterInfo requesterInfo = new RequesterInfo();			
			MemberInfo memberInfo = new MemberInfo();
			DataRecord dataRecord = new DataRecord();			
			MmiFlags mmiFlags = new MmiFlags();
			HemsInfo hemsInfo = new HemsInfo();
			MmiInfo mmiInfo = new MmiInfo();			
			
			//set RequesterInfo			
            requesterInfo.setRequesterEmployeeId(new Coded(new BigInteger(msg.getEVN().getEvn5_OperatorID().getIDNumber().getValue())));                        
            requesterInfo.setVersionCode(msg.getMSH().getMsh12_VersionID().getValue());
            requesterInfo.setApplicationName(msg.getMSH().getMsh3_SendingApplication().getNamespaceID().getValue());
            requesterInfo.setRequesterFacilityCid(new Coded(new BigInteger(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue())));
            
            //set MemberInfo            
            //set Names                        
            int nmCnt = msg.getPID().getPatientNameReps();
            Names names = new Names();
            for(int nameIndx = 0; nameIndx < nmCnt; nameIndx++)
            {
            	Name name = new Name();
            	//set LastName
            	if(!isNOE(msg.getPID().getPatientName(nameIndx).getFamilyName().getValue())) {
            		name.setLastName(msg.getPID().getPatientName(nameIndx).getFamilyName().getValue());
            		
	            	//set FirstName
            		if(!isNOE(msg.getPID().getPatientName(nameIndx).getGivenName().getValue())) {
	            		name.setFirstName(msg.getPID().getPatientName(nameIndx).getGivenName().getValue());
	            	}
	                //set MiddleName
            		if(!isNOE(msg.getPID().getPatientName(nameIndx).getMiddleInitialOrName().getValue())) {
	            		name.setMiddleName(msg.getPID().getPatientName(nameIndx).getMiddleInitialOrName().getValue());
	            	}
	                //set Suffix
            		if(!isNOE(msg.getPID().getPatientName(nameIndx).getSuffixEgJRorIII().getValue())) {
	            		name.setSuffix(msg.getPID().getPatientName(nameIndx).getSuffixEgJRorIII().getValue());	
	            	}                
	                //set NameType Ncid
            		if(!isNOE(msg.getPID().getPatientName(nameIndx).getNameTypeCode().getValue())) {
	                	name.setNameTypeCid(new Coded(new BigInteger(msg.getPID().getPatientName(nameIndx).getNameTypeCode().getValue())));
	                }
	                names.add(name);
            	}
            }
            memberInfo.setNamesList(names);
            
            //set Facilities
            Facility facilities[] = new Facility[1];
            facilities[0] = new Facility();
            String faciltyNcid = msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue();
            if (faciltyNcid.equals(CERNER_FAC_NCID)){            	
            	facilities[0].setMedRecNumber(msg.getPID().getPatientIDInternalID(0).getID().getValue());
            } else if ( faciltyNcid.equals(CB_FAC_NCID)){
            	facilities[0].setMedRecNumber(msg.getPID().getPatientIDExternalID().getID().getValue());
            } else {
            	facilities[0].setMedRecNumber("");
            }
            facilities[0].setMmiFacilityCid(new Coded(new BigInteger(faciltyNcid)));
            memberInfo.setFacilities(facilities);
            
            //set Addresses            
            int addrCnt = msg.getPID().getPatientAddressReps();
            Addresses addrs = new Addresses();
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
	                addrs.add(address);
            	}
            }
            memberInfo.setAddressesList(addrs);
            
            //set Phones            
            int hPhnCnt = msg.getPID().getPhoneNumberHomeReps();
            int wPhnCnt = msg.getPID().getPhoneNumberBusinessReps();
            int cdrPhnCnt = hPhnCnt + wPhnCnt;
            Phones phones = new Phones();
            //PID-13 HomePhone            
            for(int phIndx=0; phIndx<hPhnCnt; phIndx++) {
            	Phone phone = new Phone();            	
            	if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).get9999999X99999CAnyText().getValue())) {
	            	//telecomUseNcid
            		if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).getTelecommunicationUseCode().getValue())) {
	            		phone.setPhoneTypeCid(new Coded(new BigInteger(msg.getPID().getPhoneNumberHome(phIndx).getTelecommunicationUseCode().getValue())));            	
	            	} else {
	            		phone.setPhoneTypeCid(new Coded(BigInteger.valueOf(193L)));
	            	}
	            	
	            	// Country Code
            		if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).getCountryCode().getValue())) {
	            		phone.setCountryCode(msg.getPID().getPhoneNumberHome(phIndx).getCountryCode().getValue());            	
	            	}
	            	
            		// Area Code
            		if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).getAreaCityCode().getValue())) {
	            		phone.setAreaCode(msg.getPID().getPhoneNumberHome(phIndx).getAreaCityCode().getValue());            	
	            	} else if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).get9999999X99999CAnyText().getValue())){
	            		phone.setAreaCode(msg.getPID().getPhoneNumberHome(phIndx).get9999999X99999CAnyText().getValue().replaceAll("[^0-9]", "").substring(0,3));	            		
	            	}
	
	            	// Local Phone Number
            		if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).getPhoneNumber().getValue())) {
	            		phone.setLocalNumber(msg.getPID().getPhoneNumberHome(phIndx).getPhoneNumber().getValue());            	
	            	} else if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).get9999999X99999CAnyText().getValue())){
	            		phone.setLocalNumber(msg.getPID().getPhoneNumberHome(phIndx).get9999999X99999CAnyText().getValue().replaceAll("[^0-9]", "").substring(3));	            		
	            	}    
	            	
	            	// Extension
            		if(!isNOE(msg.getPID().getPhoneNumberHome(phIndx).getExtension().getValue())) {
	            		phone.setExtension(msg.getPID().getPhoneNumberHome(phIndx).getExtension().getValue());            	
	            	}
	            	phones.add(phone);
            	}            	
            	
            }
            //PID-14 BusinessPhone
            for(int phIndx=0; phIndx<wPhnCnt; phIndx++) {
            	Phone phone = new Phone();            	
            	if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).get9999999X99999CAnyText().getValue())) {
	            	//telecomUseNcid
            		if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).getTelecommunicationUseCode().getValue())) {
	            		phone.setPhoneTypeCid(new Coded(new BigInteger(msg.getPID().getPhoneNumberBusiness(phIndx).getTelecommunicationUseCode().getValue())));            	
	            	} else {
	            		phone.setPhoneTypeCid(new Coded(BigInteger.valueOf(193L)));
	            	}
	            	
	            	// Country Code
            		if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).getCountryCode().getValue())) {
	            		phone.setCountryCode(msg.getPID().getPhoneNumberBusiness(phIndx).getCountryCode().getValue());            	
	            	}
	            	
            		// Area Code
            		if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).getAreaCityCode().getValue())) {
	            		phone.setAreaCode(msg.getPID().getPhoneNumberBusiness(phIndx).getAreaCityCode().getValue());            	
	            	} else if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).get9999999X99999CAnyText().getValue())){
	            		phone.setAreaCode(msg.getPID().getPhoneNumberBusiness(phIndx).get9999999X99999CAnyText().getValue().replaceAll("[^0-9]", "").substring(0,3));	            		
	            	}
	
	            	// Local Phone Number
            		if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).getPhoneNumber().getValue())) {
	            		phone.setLocalNumber(msg.getPID().getPhoneNumberBusiness(phIndx).getPhoneNumber().getValue());            	
	            	} else if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).get9999999X99999CAnyText().getValue())){
	            		phone.setLocalNumber(msg.getPID().getPhoneNumberBusiness(phIndx).get9999999X99999CAnyText().getValue().replaceAll("[^0-9]", "").substring(3));	            		
	            	}      
	            	
	            	// Extension
            		if(!isNOE(msg.getPID().getPhoneNumberBusiness(phIndx).getExtension().getValue())) {
	            		phone.setExtension(msg.getPID().getPhoneNumberBusiness(phIndx).getExtension().getValue());            	
	            	}
	            	phones.add(phone);
            	}            	
            	
            }
            memberInfo.setPhonesList(phones);
            
            //set SSN
            if(!isNOE(msg.getPID().getSSNNumberPatient().getValue())) {
            	memberInfo.setSsn(msg.getPID().getSSNNumberPatient().getValue());
            }
            
            //set MaritalStatus
            if(!isNOE(msg.getPID().getMaritalStatus(0).getValue())) {
            	memberInfo.setMaritalStatusCid(new Coded(new BigInteger(msg.getPID().getMaritalStatus(0).getValue())));
            }
            
            //set Race
            if(!isNOE(msg.getPID().getRace().getValue()) && isNumeric(msg.getPID().getRace().getValue())) {            	
            	memberInfo.setRaceCid(new Coded(new BigInteger(msg.getPID().getRace().getValue())));
            }
            
            //set PassPort/Language
            if(!isNOE(msg.getPID().getPrimaryLanguage().getIdentifier().getValue())) {    
            	memberInfo.setPassPort(msg.getPID().getPrimaryLanguage().getIdentifier().getValue());
            }
			
            //set GovtHealthNumber/Ethnicity
            if(!isNOE(msg.getPID().getEthnicGroup().getValue())) {
            	memberInfo.setGovtHealthNumber(msg.getPID().getEthnicGroup().getValue());
            }
            
            //set Religion
            if(!isNOE(msg.getPID().getReligion().getValue())) {
            	memberInfo.setReligionCid(new Coded(new BigInteger(msg.getPID().getReligion().getValue())));
            }
            
            //set Sex
            if(!isNOE(msg.getPID().getSex().getValue())) {
            	memberInfo.setSex(msg.getPID().getSex().getValue());
            }
            
            //set DataofBirth
            if(!isNOE(msg.getPID().getDateOfBirth().getTimeOfAnEvent().getValue())) {
            	DateOfBirth dob = new DateOfBirth();
                dob.setBirthDate(dateFormat.parse(msg.getPID().getDateOfBirth().getTimeOfAnEvent().getValue()));
                memberInfo.setDateOfBirth(dob);
                memberInfo.setBirthDateResolution(new Coded(BigInteger.valueOf(0x35105L)));
            }
            
            //set DataOfDeath
            if(!isNOE(msg.getPID().getPatientDeathDateAndTime().getTimeOfAnEvent().getValue())) {
            	memberInfo.setDateOfDeath(dateFormat.parse(msg.getPID().getPatientDeathDateAndTime().getTimeOfAnEvent().getValue()));
            	mmiFlags.setExpiredFlag("Y");            	
            }
			
            //setting MemberInfo...
            //setting MmiRecord[]...    
            MmiRecord mmiRecs[] = new MmiRecord[1];
            mmiRecs[0] = new MmiRecord();
            mmiRecs[0].setMemberInfo(memberInfo);
            
            //set UnitNumber            
            if (msg.getPID().getPatientIDInternalID(0).getID().getValue()!=null){
             mmiRecs[0].setUnitNumber(new BigInteger(msg.getPID().getPatientIDInternalID(0).getID().getValue()));
            }
            
            //setting Flags ...
            mmiRecs[0].setMmiFlags(mmiFlags);
            
            //setting DataRecord...
            dataRecord.setMmiRecords(mmiRecs);
            mmiInfo.setDataRecord(dataRecord);
            
            //setting UserSecurityTicket
            secTicket.setSTicket(null);
            
            //setting HemsInfo            
            hemsInfo.setUserSecurityTicket(secTicket);
            hemsInfo.setRequesterInfo(requesterInfo);
            hemsInfo.setContext(new Context());
            mmiInfo.setHemsInfo(hemsInfo);
            
            //Calling Service
            byte encodedASN1Request[] = EncodeUtil.encode(mmiInfo); //Encoding MmiInfo...            
            setRequestBytes(encodedASN1Request);
    		callService(); //call service
    		byte[] encodedASN1Response = getResponseBytes();
    		MmiInfo retMmiInfo = EncodeUtil.decode(encodedASN1Response);
    		
    		//Getting DataRecord...
    		DataRecord retDataRecord = retMmiInfo.getDataRecord();    		
    		if(retDataRecord == null){
    			log.debug("Adding MMI failed");
    			retUnitNumber = "Adding MMI failed";
			} else {    		
				//Getting MmiRecords...
				MmiRecord retMmiRecs[] = retDataRecord.getMmiRecords();
				retUnitNumber = retMmiRecs[0].getUnitNumber().toString();
				log.debug("RetUnitNumber: " + retUnitNumber);
			}
    		
    		log.debug("addMMi Exited");
			return retUnitNumber;
		} catch (Exception ex){
			throw ex;
			//return exceptionToString(ex);
		}
	}
	
   
	
	// Check if a given value is Null or Empty
	private boolean isNOE(String stringValue){
  	  return ((stringValue == null || stringValue.trim().length()==0) ? true : false);
    }
	
	private boolean isNumeric(String str){  
		  try{  
		    double d = Double.parseDouble(str);  
		  }catch(NumberFormatException nfe){  
		    return false;  
		  }  
		  return true;  
	}
	
	
}