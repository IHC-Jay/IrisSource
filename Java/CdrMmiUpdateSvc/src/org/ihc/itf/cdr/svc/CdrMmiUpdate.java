package org.ihc.itf.cdr.svc;

import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.SimpleTimeZone;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.ihc.itf.cdr.CdrTuxServices;
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

public class CdrMmiUpdate extends CdrTuxServices {
	/* Get actual class name to be printed on */
	private static Logger log ;
	private static String CERNER_FAC_NCID="525935320";
	private static String CB_FAC_NCID="2000000341";
	
	private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");

	private String UnlockServiceName;
	private int maxRetries;
	private int retryTimeoutSeconds;
	private LockCdrService lockService =null;
	private UnlockCdrService unlockService = null;
	private UpdateCdrService updateService = null;
	private HapiContext hapiContext;
	
	public CdrMmiUpdate(String applicationAddress, String serviceName, String lockServiceName, String unlockServiceName, int maxRetries, int retryTimeoutSeconds, String fileName, int debug) throws Exception	{
		super(applicationAddress, serviceName);
		log = ItfLoggerHash.setLoggerProperties("CdrMmiUpdate", fileName, (debug == 1) ? true : false) ;
		cdrMmiUpdate(applicationAddress, serviceName, lockServiceName, unlockServiceName, maxRetries, retryTimeoutSeconds);
	}
	
	public CdrMmiUpdate(String applicationAddress, String serviceName, String lockServiceName, String unlockServiceName, int maxRetries, int retryTimeoutSeconds) throws Exception	{
		super(applicationAddress, serviceName);
		log = Logger.getLogger(CdrMmiUpdate.class);
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
		cdrMmiUpdate(applicationAddress, serviceName, lockServiceName, unlockServiceName, maxRetries, retryTimeoutSeconds);
	}
	
	private void cdrMmiUpdate(String applicationAddress, String serviceName, String lockServiceName, String unlockServiceName, int maxRetries, int retryTimeoutSeconds) throws Exception {
		log = ItfLoggerHash.getInstance("CdrMmiUpdate");

		this.UnlockServiceName = unlockServiceName;		
		this.maxRetries = maxRetries;
		this.retryTimeoutSeconds = retryTimeoutSeconds;
		this.dateFormat.setTimeZone(new SimpleTimeZone(0, "UTC"));
		lockService = new LockCdrService(applicationAddress, lockServiceName);
		unlockService = new UnlockCdrService(applicationAddress, UnlockServiceName);
		updateService = new UpdateCdrService(applicationAddress, serviceName);
	}
	
	public String updateMMI(String hl7Msg) throws Exception{
		boolean lockedFlg = false;
		String returnValue = "0";
		MmiFlags mmiFlags = new MmiFlags();
		
		RequesterInfo m_requesterInfo = new RequesterInfo();
		MemberInfo m_memberInfo = new MemberInfo();
		DataRecord m_DataRecord = new DataRecord();
		MmiRecord m_mmiRec = new MmiRecord();
		MmiRecord m_mmiRecs[] = new MmiRecord[1];	
		
		DataRecord dataRecord = new DataRecord();
		MmiInfo m_MmiInfo = new MmiInfo();			
        MmiRecord mmiRecs[] = new MmiRecord[1];
        
		
		try {
			log.debug("Start updateMMI");
			hapiContext = new DefaultHapiContext();
			hapiContext.setValidationContext(new NoValidation());
			PipeParser pipeParser = hapiContext.getPipeParser();
			
			Message message = pipeParser.parse(hl7Msg);
			//GenericParser parser = context.getGenericParser();
			//Message message = parser.parse(hl7Msg);
			ADT_A01 msg = (ADT_A01) message;
			
			// Populate information from HL7Msg
			
			// EmployeeID
			m_requesterInfo.setRequesterEmployeeId(new Coded(new BigInteger(msg.getEVN().getEvn5_OperatorID().getIDNumber().getValue())));
			// FacilityCid
			m_requesterInfo.setRequesterFacilityCid(new Coded(new BigInteger(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue())));
			// Version ID
			m_requesterInfo.setVersionCode(msg.getMSH().getMsh12_VersionID().getValue());
			// Application name
			m_requesterInfo.setApplicationName(msg.getMSH().getMsh3_SendingApplication().getNamespaceID().getValue());
			// Unit Number
			m_mmiRec.setUnitNumber(new BigInteger(msg.getPID().getPatientIDInternalID(0).getID().getValue()));			
			// Populate Names			
			int nmCnt = msg.getPID().getPatientNameReps();
            Names nNames = new Names();
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
            		nNames.add(name);
            	}
            }
			m_memberInfo.setNamesList(nNames);
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
			// Populate Phones
            int hPhnCnt = msg.getPID().getPhoneNumberHomeReps();
            int wPhnCnt = msg.getPID().getPhoneNumberBusinessReps();
            
            
            Phones pPhones = new Phones();
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
            		pPhones.add(phone);            		
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
            		pPhones.add(phone);
            	}            	
            	
            }
			m_memberInfo.setPhonesList(pPhones);
			// Populate SSN
			if(!isNOE(msg.getPID().getSSNNumberPatient().getValue())) {
				m_memberInfo.setSsn(msg.getPID().getSSNNumberPatient().getValue());
            }
			
			// Populate Gender
			if(!isNOE(msg.getPID().getSex().getValue())) {
				m_memberInfo.setSex(msg.getPID().getSex().getValue());
            }
			
			// Populate DataOfBirth
			if(!isNOE(msg.getPID().getDateOfBirth().getTimeOfAnEvent().getValue())) {
            	DateOfBirth dob = new DateOfBirth();
                dob.setBirthDate(dateFormat.parse(msg.getPID().getDateOfBirth().getTimeOfAnEvent().getValue()));
                m_memberInfo.setDateOfBirth(dob);                
            }
			
			// Populate Race
			if(!isNOE(msg.getPID().getRace().getValue()) && isNumeric(msg.getPID().getRace().getValue())) {
				m_memberInfo.setRaceCid(new Coded(new BigInteger(msg.getPID().getRace().getValue())));
            }
						
			// Populate Religion
			if(!isNOE(msg.getPID().getReligion().getValue()) && isNumeric(msg.getPID().getReligion().getValue())) {
				m_memberInfo.setReligionCid(new Coded(new BigInteger(msg.getPID().getReligion().getValue())));
			}
						
			// Populate Language
			if(!isNOE(msg.getPID().getPrimaryLanguage().getIdentifier().getValue())) {    
				m_memberInfo.setPassPort(msg.getPID().getPrimaryLanguage().getIdentifier().getValue());
            }
			
			// Populate MaritialStatus
			if(!isNOE(msg.getPID().getMaritalStatus(0).getValue())) {
				m_memberInfo.setMaritalStatusCid(new Coded(new BigInteger(msg.getPID().getMaritalStatus(0).getValue())));
            }
			
			// Populate EthnicGroup			
			if(!isNOE(msg.getPID().getEthnicGroup().getValue())) {				
				m_memberInfo.setGovtHealthNumber(msg.getPID().getEthnicGroup().getValue());
			}
			// Populate DateOfDeath
			if(!isNOE(msg.getPID().getPatientDeathDateAndTime().getTimeOfAnEvent().getValue())) {
				m_memberInfo.setDateOfDeath(dateFormat.parse(msg.getPID().getPatientDeathDateAndTime().getTimeOfAnEvent().getValue()));            	            	
            }
			
			// Populate ExpiredFlag
			MmiFlags m_mmiFlags = new MmiFlags();
			if(!isNOE(msg.getPID().getPatientDeathIndicator().getValue())) {
				m_mmiFlags.setExpiredFlag(msg.getPID().getPatientDeathIndicator().getValue());
			}			
			m_mmiRec.setMmiFlags(m_mmiFlags);
			
			// MedRecNumber
			String medRecNumber = ""; 
			//if(msg.getPID().getPatientIDInternalID(0).getID().getValue().equals(CERNER_FAC_NCID)){
			if(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue().equals(CERNER_FAC_NCID)){
				medRecNumber =msg.getPID().getPatientIDInternalID(0).getID().getValue();
			}			
			if(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue().equals(CB_FAC_NCID)){
				medRecNumber =msg.getPID().getPatientIDExternalID().getCx1_ID().getValue();			
			}
			
			//Populate Facilities
			Facility[] facilities = new Facility[1];
			Facility facility = new Facility();
			facility.setMedRecNumber(medRecNumber);
			facilities[0]=facility;
			m_memberInfo.setFacilities(facilities);
			// FacilityNcid
			m_memberInfo.getFacilities()[0].setMmiFacilityCid(new Coded(new BigInteger(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue())));
			// MotherName
			if (!isNOE(msg.getPID().getMotherSMaidenName().getFamilyName().getValue())){				
				Name name = new Name();				
				name.setLastName(msg.getPID().getMotherSMaidenName().getFamilyName().getValue());
				
				if (!isNOE(msg.getPID().getMotherSMaidenName().getGivenName().getValue())){
					name.setFirstName(msg.getPID().getMotherSMaidenName().getGivenName().getValue());
				}
				m_mmiRec.setMotherName(name);
			}
			m_mmiRec.setMemberInfo(m_memberInfo);
			m_mmiRecs[0] = m_mmiRec;
			m_DataRecord.setMmiRecords(m_mmiRecs);
			
			/////// Filling ended /////////
			
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
            log.debug("Encoding MmiInfo. call LockCdrService..");
            //Lock Request
            
            mmiRecs = lockService.callLockCdrService(m_MmiInfo, maxRetries, retryTimeoutSeconds);
            
                       
            lockedFlg = true;
            log.debug("Setting MemberInfo...");
            MemberInfo memberInfo = mmiRecs[0].getMemberInfo();            
            Name retNames[] = memberInfo.getNames();
            nmCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames().length;
            if(nmCnt == 1 && m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames()[0].getNameTypeCid() == null) {
            	m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames()[0].setNameTypeCid(new Coded(BigInteger.valueOf(187L)));
            }
            int retNmCnt = 0;
            if(retNames != null) {
                retNmCnt = retNames.length;
            }
            log.debug("Ret Names Length: " + retNmCnt);
            log.debug("Current Record Names Length: " + nmCnt);
            String lastName187 = "";
            String firstName187 = "";
            for(int j = 0; j < nmCnt; j++) {
                Name curRecName = m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames()[j];
                String curRecordNameTypeNcid = curRecName.getNameTypeCid().toString();
                if(curRecordNameTypeNcid.equals("187"))
                {
                    lastName187 = curRecName.getLastName();
                    firstName187 = curRecName.getFirstName();
                }
            }
            log.debug("lastName187:" + lastName187);
            log.debug("firstName187:" + firstName187);
            for(int i = 0; i < retNmCnt; i++) {
                BigInteger nt = retNames[i].getNameTypeCid().getNcid();
                boolean existFlg = false;
                for(int j = 0; j < nmCnt; j++) {
                    Name nm = m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames()[j];
                    if(nt.compareTo(nm.getNameTypeCid().getNcid()) != 0)
                        continue;
                    existFlg = true;                    
                    //log.debug("First Name ..." + nm.getFirstName() + " " + nm.getFirstName().length());
                    if(nm.getLastName().length() == 0) {
                        log.debug("Keep Last Name ..." + nt.toString());
                        m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames()[j].setLastName(retNames[i].getLastName());
                    }
                    //if(nm.getFirstName().length() == 0) {
                    if(!isNOE(nm.getFirstName()) && (nm.getFirstName().length() == 0 )) { 
                        log.debug("updateMmi, Keep First Name ..." + nt.toString());
                        m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames()[j].setFirstName(retNames[i].getFirstName());
                    }
                    break;
                }

                if(!existFlg) {
                    log.debug("Add Name ..." + retNames[i].getFirstName() + " " + i);
                    Name[] names = m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames();
                    Name[] newNames = new Name[names.length+1];
                    System.arraycopy( names, 0, newNames, 0, names.length );
                    newNames[names.length] = retNames[i];
                    m_DataRecord.getMmiRecords()[0].getMemberInfo().setNames(newNames);
                }
            }
            
            nmCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames().length;
            log.debug("Mem Names Length: " + nmCnt);
            Name[] names = new Name[nmCnt];
            log.debug("Setting Names...");
            int nmIndx = 0;
            for(nmIndx = 0; nmIndx < nmCnt; nmIndx++) {
                names[nmIndx] = m_DataRecord.getMmiRecords()[0].getMemberInfo().getNames()[nmIndx];
                String memLastName = names[nmIndx].getLastName();
                String memFirstName = names[nmIndx].getFirstName();
                log.debug(nmIndx + "..names[nmIndx].getLastName() ..." + memLastName);
                log.debug(nmIndx + "..names[nmIndx].getFirstName() ..." + memFirstName);                
                if(memLastName == null)
                    names[nmIndx].setLastName(lastName187);
                else
            	if(memLastName.length() == 0)
            		names[nmIndx].setLastName(lastName187);
            	if(memFirstName == null)
            		names[nmIndx].setFirstName(firstName187);
            	else
            	if(memFirstName.length() == 0)
            		names[nmIndx].setFirstName(firstName187);                		
            	log.debug("Setting LAST Name: " + names[nmIndx].getLastName() + " *** " + nmIndx);
            	log.debug("Setting FIRST Name: " + names[nmIndx].getFirstName());            	
            	log.debug("Setting MIDDLE Name: " + names[nmIndx].getMiddleName());
            	log.debug("Setting Name Type: " + names[nmIndx].getNameTypeCid().getNcid());
            }
            
            memberInfo.setNames(names);
            log.debug("Setting Requestor's Facilities ...");
            Facility retFacilities[] = memberInfo.getFacilities();
            int fcCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getFacilities().length;
            int retFCnt = 0;
            if(retFacilities != null)
                retFCnt = retFacilities.length;
            String mrnNumber = "";
            String radNumber = "";
            boolean hasMatch = false;
            for(int i = 0; i < retFCnt; i++) {
                boolean existFlg = false;
                log.debug(" Outer Loop Index: " + i);
                for(int j = 0; j < fcCnt; j++) {
                	log.debug(" Inner Loop Index: " + j);
                    Facility fc = m_DataRecord.getMmiRecords()[0].getMemberInfo().getFacilities()[j];
                    log.debug("Facility Ncid(From CDR): " + retFacilities[i].getMmiFacilityCid().getNcid());
                    log.debug("FacilityNcid(From current record) " + fc.getMmiFacilityCid().getNcid());
                    log.debug("mrn# (From CDR): [" + retFacilities[i].getMedRecNumber() + "] mrn#(From current record): [" + fc.getMedRecNumber() + "]");
                    log.debug("$$$$ " + retFacilities[i].getMmiFacilityCid().getNcid().compareTo(fc.getMmiFacilityCid().getNcid()));
                    if(retFacilities[i].getMmiFacilityCid().getNcid().compareTo(fc.getMmiFacilityCid().getNcid()) != 0 || hasMatch)                    	
                        continue;                    
                    existFlg = true;
                    if(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue().equals(CERNER_FAC_NCID)){
                    	mrnNumber = msg.getPID().getPatientIDInternalID(0).getID().getValue();
        			}else if(msg.getMSH().getMsh4_SendingFacility().getNamespaceID().getValue().equals(CB_FAC_NCID)){
        				mrnNumber =msg.getPID().getPatientIDExternalID().getCx1_ID().getValue();        				
        			} else{
                    	mrnNumber = retFacilities[i].getMedRecNumber();
                    }                    
                    radNumber = retFacilities[i].getRadiologyNumber();
                    log.debug(" Setting mrnNumber " + mrnNumber);
                    m_DataRecord.getMmiRecords()[0].getMemberInfo().getFacilities()[0].setMedRecNumber(mrnNumber);
                    m_DataRecord.getMmiRecords()[0].getMemberInfo().getFacilities()[0].setRadiologyNumber(radNumber);
                    hasMatch = true;
                    break;
                }
                log.debug(" Outer Loop - existFlg: " + existFlg);

                if(!existFlg){
                	Facility[] facilties = m_DataRecord.getMmiRecords()[0].getMemberInfo().getFacilities();
                	Facility[] newFacilities = new Facility[facilties.length+1];
                    System.arraycopy( facilties, 0, newFacilities, 0, facilties.length );
                    newFacilities[facilties.length] = retFacilities[i];
                    m_DataRecord.getMmiRecords()[0].getMemberInfo().setFacilities(newFacilities);
                }
            }
            
            fcCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getFacilities().length;
            log.debug(" Fac COunt: " + fcCnt);
            int fcIndx = 0;
            facilities = new Facility[fcCnt];
            for(fcIndx = 0; fcIndx < fcCnt; fcIndx++)
                facilities[fcIndx] = m_DataRecord.getMmiRecords()[0].getMemberInfo().getFacilities()[fcIndx];
            memberInfo.setFacilities(facilities);
            
            log.debug("Setting Addresses...");
            Address retAddresses[] = memberInfo.getAddresses();
            addrCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses().length;
            if(addrCnt == 1 && m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].getAddressTypeCid() == null)
            	m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0].setAddressTypeCid(new Coded(BigInteger.valueOf(199L)));
            int retAddrCnt = 0;
            if(retAddresses != null)
                retAddrCnt = retAddresses.length;
            for(int i = 0; i < retAddrCnt; i++) {
                boolean existFlg = false;
                BigInteger at = retAddresses[i].getAddressTypeCid().getNcid();
                for(int j = 0; j < addrCnt; j++) {
                    Address addr = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[j];
                    if(at.compareTo(addr.getAddressTypeCid().getNcid()) != 0)
                        continue;
                    existFlg = true;
                    if(addr.getStreet1().length() == 0 && addr.getCity().length() == 0 && addr.getPostCode().length() == 0 && addr.getState().length() == 0) {
                    	Address[] addresses = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses();
                    	addresses[j] = retAddresses[i];
                    	dataRecord.getMmiRecords()[0].getMemberInfo().setAddresses(addresses);                    	
                    }
                    break;
                }

                if(!existFlg && at.intValue() != 0x301d0e9){
                	Address[] addresses = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses();
                	Address[] newAddresses = new Address[addresses.length+1];
                    System.arraycopy( addresses, 0, newAddresses, 0, addresses.length );
                    newAddresses[addresses.length] =retAddresses[i];
                    m_DataRecord.getMmiRecords()[0].getMemberInfo().setAddresses(newAddresses);
                }
            }
            
            addrCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses().length;
            int addrIndx = 0;
            Address addrs[] = new Address[addrCnt];
            for(addrIndx = 0; addrIndx < addrCnt; addrIndx++)
            {
                addrs[addrIndx] = m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[addrIndx];
                log.debug("Setting Address 1: " + addrs[addrIndx].getStreet1());
            }

            memberInfo.setAddresses(addrs);
            
            log.debug("Setting Phones...");
            Phone retPhones[] = memberInfo.getPhones();
            int phCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones().length;
            if(phCnt == 1 && m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones() != null && m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones()[0].getPhoneTypeCid() == null)
            	m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones()[0].setPhoneTypeCid(new Coded(BigInteger.valueOf(193L)));
            boolean isCurPrefPhFlag = false;
            log.debug("Current Record Phone Count  : " + phCnt);
            for(int phIndx = 0; phIndx < phCnt; phIndx++)
            {
                String phNcidCurRecord = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones()[phIndx].getPhoneTypeCid().getNcid().toString();
                String phNumCurRecord = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones()[phIndx].getLocalNumber();
                String phAreaCurRecord = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones()[phIndx].getAreaCode();
                log.debug("Phone From Record : " + phAreaCurRecord + phNumCurRecord + " " + phNcidCurRecord);
                if(phNcidCurRecord.equals("521363181")){
                    isCurPrefPhFlag = true;
                }
            }
            
            
            int retPhCnt = 0;
            if(retPhones != null)
                retPhCnt = retPhones.length;
            log.debug("Current Phone Count in CDR : " + retPhCnt);
            for(int i = 0; i < retPhCnt; i++)
            {
                String phcid = retPhones[i].getPhoneTypeCid().getNcid().toString();
                log.debug("Current Phone : " + retPhones[i].getAreaCode()+retPhones[i].getLocalNumber() + " " + retPhones[i].getPhoneTypeCid().getNcid().toString());
                if(phcid.equals("817") || !isCurPrefPhFlag && phcid.equals("521363181"))
                {
                    log.debug("Keep Phone : " + retPhones[i].getLocalNumber());
                    Phone[] Phones = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones();
                    Phone[] newPhones = new Phone[Phones.length+1];
                    System.arraycopy( Phones, 0, newPhones, 0, Phones.length );
                    newPhones[Phones.length] = retPhones[i];
                    m_DataRecord.getMmiRecords()[0].getMemberInfo().setPhones(newPhones);                    
                }
            }
            
            int phIndx = 0;
            phCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones().length;
            Phone[] phones = new Phone[phCnt];
            for(phIndx = 0; phIndx < phCnt; phIndx++)
            {
                phones[phIndx] = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPhones()[phIndx];
                log.debug("Setting Phone : " + phones[phIndx].getAreaCode() + phones[phIndx].getLocalNumber() + " " + phones[phIndx].getPhoneTypeCid().getNcid().toString());
            }            
            
            memberInfo.setPhones(phones);
            String ssn = m_DataRecord.getMmiRecords()[0].getMemberInfo().getSsn();
            if(ssn != null && ssn.length() > 0) {
                log.debug("Setting SSN...");
                memberInfo.setSsn(ssn);                
                log.debug("SSN : " + ssn.toString());
            } else {
                memberInfo.setSsn(null);
            }
            
            Coded mstatus = m_DataRecord.getMmiRecords()[0].getMemberInfo().getMaritalStatusCid();            
            if(mstatus != null) {
                log.debug("Setting Marital Status...");
                memberInfo.setMaritalStatusCid(mstatus);                
                log.debug("Marital Status : " + mstatus.getNcid());
            }
            
            Coded rc = m_DataRecord.getMmiRecords()[0].getMemberInfo().getRaceCid();
            if(rc != null){
                log.debug("Setting Race ...");
                memberInfo.setRaceCid(rc);                
                log.debug("Race : " + rc.getNcid());
            }
            
            String language = m_DataRecord.getMmiRecords()[0].getMemberInfo().getPassPort();
            if(language != null) {
                log.debug("Setting Language ...");
                memberInfo.setPassPort(language);                
                log.debug("Language : "+ language);
            }
            
            String ethnicity = m_DataRecord.getMmiRecords()[0].getMemberInfo().getGovtHealthNumber();            
            if(ethnicity != null) {
                log.debug("Setting Ethnicity ...");
                memberInfo.setGovtHealthNumber(ethnicity);                
                log.debug("Ethnicity : "+ ethnicity);
            }
            
            Coded relgn = m_DataRecord.getMmiRecords()[0].getMemberInfo().getReligionCid();
            if(relgn != null) {
                log.debug("Setting Religion ...");
                memberInfo.setReligionCid(relgn);                
                log.debug("Religion : "+ relgn.getNcid());
            }
            
            String sex = m_DataRecord.getMmiRecords()[0].getMemberInfo().getSex();
            if(!isNOE(sex)) {
                memberInfo.setSex(sex);
            }
            DateOfBirth dtb = m_DataRecord.getMmiRecords()[0].getMemberInfo().getDateOfBirth();
            if(dtb != null && dtb.getBirthDate() != null) {                
                log.debug("Filling Birthday: "+ dateFormat.format(dtb.getBirthDate()));                
                memberInfo.setDateOfBirth(dtb);
                memberInfo.setBirthDateResolution(new Coded(BigInteger.valueOf(0x35105L)));
            }
            
            mmiFlags = m_DataRecord.getMmiRecords()[0].getMmiFlags();
            MmiFlags mmiFlgs = mmiRecs[0].getMmiFlags();
            Date dtd = m_DataRecord.getMmiRecords()[0].getMemberInfo().getDateOfDeath();
        	if(mmiFlags!=null && mmiFlags.getExpiredFlag() != null && mmiFlags.getExpiredFlag().equals("Y")) {
        		if(dtd != null) {
        			log.debug("Filling DateOfDeath: "+ dateFormat.format(dtd));
        			memberInfo.setDateOfDeath(dtd);
        			memberInfo.setDeathDateResolution(new Coded(BigInteger.valueOf(0x35106L)));
        		}
            }else {
                memberInfo.setDateOfDeath(null);
                mmiFlgs.setExpiredFlag("");
            }
            
            boolean setFlgs = false;
            String expFlg = mmiFlags.getExpiredFlag();
            if(expFlg != null && expFlg.length() > 0) {
                mmiFlgs.setExpiredFlag(expFlg);
                setFlgs = true;
            }
            String adpFlg = mmiFlags.getAdoptionFlag();
            if(adpFlg != null && adpFlg.length() > 0) {
                mmiFlgs.setExpiredFlag(adpFlg);
                setFlgs = true;
            }
            String deactFlg = mmiFlags.getDeactivateFlag();
            if(deactFlg != null && deactFlg.length() > 0) {
                mmiFlgs.setExpiredFlag(deactFlg);
                setFlgs = true;
            }
            String grntFlg = mmiFlags.getGuarantorFlag();
            if(grntFlg != null && grntFlg.length() > 0) {
                mmiFlgs.setExpiredFlag(grntFlg);
                setFlgs = true;
            }
            String insFlg = mmiFlags.getInstitutionalFlag();
            if(insFlg != null && insFlg.length() > 0) {
                mmiFlgs.setExpiredFlag(insFlg);
                setFlgs = true;
            }
            String ordFlg = mmiFlags.getOrganDonorFlag();
            if(ordFlg != null && ordFlg.length() > 0) {
                mmiFlgs.setExpiredFlag(ordFlg);
                setFlgs = true;
            }
            String patFlg = mmiFlags.getPatientFlag();
            if(patFlg != null && patFlg.length() > 0) {
                mmiFlgs.setExpiredFlag(patFlg);
                setFlgs = true;
            }
            
            if(setFlgs) {
                mmiRecs[0].setMmiFlags(mmiFlgs);
            }
            mmiRecs[0].setMemberInfo(memberInfo);
            log.debug("Filling DataRecord...");
            dataRecord.setMmiRecords(mmiRecs);
            log.debug("Filling MmiInfo...");
            m_MmiInfo.setDataRecord(dataRecord);
            log.debug("Encoding MmiInfo...");
            //Update Request
            returnValue = updateService.callUpdateCdrService(m_MmiInfo) ;
			return returnValue;
		} catch (Exception ex){
			throw ex;
			//return exceptionToString(ex);
		} finally {
			if(lockedFlg && !returnValue.equals("1")) {
                log.debug("Encoding MmiInfo...");
                //Unlock Request

                unlockService.callUnlockCdrService(mmiRecs);
 
            }
		}
	}
	
	// Check if a given value is Null or Empty
	private boolean isNOE(String stringValue){
    	  return ((stringValue == null || stringValue.trim().length()==0) ? true : false);
    }
	
	private boolean isNumeric(String str){  
	  try{  
		  Double.parseDouble(str);  
	  }catch(NumberFormatException nfe){  
	    return false;  
	  }  
	  return true;  
	}
	
	
}