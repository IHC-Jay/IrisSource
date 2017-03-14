package org.ihc.itf.cdr.svc;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.math.BigInteger;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.ihc.itf.util.ItfLogger;

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

public class UpdateAddressCdrService {

	
	public static Logger log = null;

	private int maxRetries;
	private int retryTimeoutSeconds;
	private LockCdrService lckService;
	private UpdateCdrService updService;
	private UnlockCdrService uncService;
	
	public UpdateAddressCdrService(String applicationAddress,
			String updServiceName, String lockServiceName,
			String unlockServiceName, int maxRetries, int retryTimeoutSeconds, String fileName, int debug) throws Exception {
		
		log = ItfLogger.setLoggerProperties(fileName, (debug == 1) ? true : false) ;

		createUpdateAddressCdrService( applicationAddress,
				 updServiceName,  lockServiceName,
				 unlockServiceName,  maxRetries,  retryTimeoutSeconds);
	}
	
	public UpdateAddressCdrService(String applicationAddress,
			String updServiceName, String lockServiceName,
			String unlockServiceName, int maxRetries, int retryTimeoutSeconds) throws Exception {
		
		log = Logger.getLogger(UpdateAddressCdrService.class);
		BasicConfigurator.configure();
		log.setLevel(Level.ERROR);
		createUpdateAddressCdrService( applicationAddress,
				 updServiceName,  lockServiceName,
				 unlockServiceName,  maxRetries,  retryTimeoutSeconds);
	}
	
	
	public boolean Exists()
	{
		return true;
	}
	
	private void createUpdateAddressCdrService(String applicationAddress,
				String updServiceName, String lockServiceName,
				String unlockServiceName, int maxRetries, int retryTimeoutSeconds) throws Exception {
			
		this.maxRetries = maxRetries;
		this.retryTimeoutSeconds = retryTimeoutSeconds;
		log.debug("In  UpdateAddressCdrService constructor");
	
		lckService = new LockCdrService(applicationAddress, lockServiceName);
		log.debug("Created LockCdrService");
		uncService = new UnlockCdrService(applicationAddress, unlockServiceName);
		log.debug("Created UnlockCdrService");
		updService = new UpdateCdrService(applicationAddress, updServiceName);
		log.debug("Created UpdateCdrService");
	}
	
	public void shutdownTuxService() throws Exception
	{
		log.debug("In  UpdateAddressCdrService shutdownTuxService, shutdown all three services");
		lckService.shutdownTuxService();
		uncService.shutdownTuxService();
		updService.shutdownTuxService();
		log = null;
	}
	
	public String addressUpdateMMI(String hl7Msg) throws Exception {

		boolean lockedFlg = false;
		String returnValue = "0";
		
		
			MemberInfo m_memberInfo = new MemberInfo();
			DataRecord m_DataRecord = new DataRecord();
			MmiRecord m_mmiRec = new MmiRecord();
			MmiRecord m_mmiRecs[] = new MmiRecord[1];
	
			DataRecord dataRecord = new DataRecord();
			MmiInfo m_MmiInfo = new MmiInfo();
			MmiRecord mmiRecs[] = new MmiRecord[1];
			HapiContext hapiContext = new DefaultHapiContext();
			
			try {
					

			log.debug("Start addressUpdateMMI");
								
			hapiContext.setValidationContext(new NoValidation());
			PipeParser pipeParser = hapiContext.getPipeParser();
			
			// log.debug("pipeParser created");
			Message message = pipeParser.parse(hl7Msg);
			
			// GenericParser parser = context.getGenericParser();
			// Message message = parser.parse(hl7Msg);
			ADT_A01 msg = (ADT_A01) message;
			// log.debug("Message:" + msg);
			// ***** Populate messages from Hl7 record ************************
			// Unit Number
			// log.debug("Unit #: " + msg.getPID().getPatientIDInternalID(0).getID());
			if(msg.getPID().getPatientIDInternalID(0).getID() == null)
			{
				throw new Exception("HL7 data does not have an unit number");
			}
		
			m_mmiRec.setUnitNumber(new BigInteger(msg.getPID()
					.getPatientIDInternalID(0).getID().getValue()));

			// Populate Addresses
			int addrCnt = msg.getPID().getPatientAddressReps();
			Addresses aAddresses = new Addresses();
			for (int addrIndx = 0; addrIndx < addrCnt; addrIndx++) {
				Address address = new Address();
				// set Street1
				log.debug("set Street1");
				if (!isNOE(msg.getPID().getPatientAddress(addrIndx)
						.getStreetAddress().getValue())) {
					address.setStreet1(msg.getPID().getPatientAddress(addrIndx)
							.getStreetAddress().getValue());

					// set Street2
					if (!isNOE(msg.getPID().getPatientAddress(addrIndx)
							.getOtherDesignation().getValue())) {
						address.setStreet2(msg.getPID()
								.getPatientAddress(addrIndx)
								.getOtherDesignation().getValue());
					}
					// set City
					if (!isNOE(msg.getPID().getPatientAddress(addrIndx)
							.getCity().getValue())) {
						address.setCity(msg.getPID()
								.getPatientAddress(addrIndx).getCity()
								.getValue());
					}
					// set State
					if (!isNOE(msg.getPID().getPatientAddress(addrIndx)
							.getStateOrProvince().getValue())) {
						address.setState(msg.getPID()
								.getPatientAddress(addrIndx)
								.getStateOrProvince().getValue());
					}
					// set Zip
					if (!isNOE(msg.getPID().getPatientAddress(addrIndx)
							.getZipOrPostalCode().getValue())) {
						address.setPostCode(msg.getPID()
								.getPatientAddress(addrIndx)
								.getZipOrPostalCode().getValue());
					}
					// set Country
					if (!isNOE(msg.getPID().getPatientAddress(addrIndx)
							.getCountry().getValue())) {
						address.setCountry(msg.getPID()
								.getPatientAddress(addrIndx).getCountry()
								.getValue());
					}
					// set AddressType Ncid
					if (!isNOE(msg.getPID().getPatientAddress(addrIndx)
							.getAddressType().getValue())) {
						address.setAddressTypeCid(new Coded(new BigInteger(msg
								.getPID().getPatientAddress(addrIndx)
								.getAddressType().getValue())));
					} else {
						address.setAddressTypeCid(new Coded(BigInteger
								.valueOf(199L)));
					}
					
					aAddresses.add(address);
				}
			}
			m_memberInfo.setAddressesList(aAddresses);
			log.debug("setMemberInfo");
			m_mmiRec.setMemberInfo(m_memberInfo);
			m_mmiRecs[0] = m_mmiRec;
			m_DataRecord.setMmiRecords(m_mmiRecs);

			mmiRecs[0] = new MmiRecord();
			log.debug("Filling Unit Number ..."
					+ m_DataRecord.getMmiRecords()[0].getUnitNumber());
			mmiRecs[0].setUnitNumber(m_DataRecord.getMmiRecords()[0]
					.getUnitNumber());

			log.debug("Filling DataRecord...");
			dataRecord.setMmiRecords(mmiRecs);
			log.debug("Filling MmiInfo...");
			m_MmiInfo.setDataRecord(dataRecord);

			log.debug("Filling UserSecurityTicket...");
			UserSecurityTicket secTicket = new UserSecurityTicket();
			secTicket.setSTicket(null);

			log.debug("Filling RequestorInfo...");
			RequesterInfo requesterInfo = new RequesterInfo();
			requesterInfo.setRequesterEmployeeId(new Coded(new BigInteger(msg
					.getEVN().getEvn5_OperatorID().getIDNumber().getValue())));
			requesterInfo.setVersionCode(msg.getMSH().getMsh12_VersionID()
					.getValue());
			requesterInfo.setApplicationName(msg.getMSH()
					.getMsh3_SendingApplication().getNamespaceID().getValue());
			requesterInfo.setRequesterFacilityCid(new Coded(new BigInteger(msg
					.getMSH().getMsh4_SendingFacility().getNamespaceID()
					.getValue())));

			log.debug("FillingHemsInfo...");
			HemsInfo hemsInfo = new HemsInfo();
			hemsInfo.setUserSecurityTicket(secTicket);
			hemsInfo.setRequesterInfo(requesterInfo);
			hemsInfo.setContext(new Context());
			m_MmiInfo.setHemsInfo(hemsInfo);

			log.debug("Encoding MmiInfo. Call lock...");

			mmiRecs = lckService.callLockCdrService(m_MmiInfo, maxRetries, retryTimeoutSeconds);

			lockedFlg = true;
			log.debug("Setting MemberInfo...");
			MemberInfo memberInfo = mmiRecs[0].getMemberInfo();

			log.debug("Setting Addresses...");
			Address retAddresses[] = memberInfo.getAddresses();
			addrCnt = m_DataRecord.getMmiRecords()[0].getMemberInfo()
					.getAddresses().length;
			if (addrCnt == 1
					&& m_DataRecord.getMmiRecords()[0].getMemberInfo()
							.getAddresses()[0].getAddressTypeCid() == null) {
				m_DataRecord.getMmiRecords()[0].getMemberInfo().getAddresses()[0]
						.setAddressTypeCid(new Coded(BigInteger.valueOf(199L)));
			}

			// Updating the Cdr Address with the values being passed from the
			// collaboration
			String inAdd1 = m_DataRecord.getMmiRecords()[0].getMemberInfo()
					.getAddresses()[0].getStreet1();
			String inAdd2 = m_DataRecord.getMmiRecords()[0].getMemberInfo()
					.getAddresses()[0].getStreet2();
			String inCity = m_DataRecord.getMmiRecords()[0].getMemberInfo()
					.getAddresses()[0].getCity();
			String inSt = m_DataRecord.getMmiRecords()[0].getMemberInfo()
					.getAddresses()[0].getState();
			String inZip = m_DataRecord.getMmiRecords()[0].getMemberInfo()
					.getAddresses()[0].getPostCode();
			String inCountry = m_DataRecord.getMmiRecords()[0].getMemberInfo()
					.getAddresses()[0].getCountry();

			log.debug("Input Address. inAdd1: " + inAdd1 + " inAdd2: "
					+ inAdd2 + " inCity: " + inCity + " inSt: " + inSt
					+ " inZip: " + inZip + " inCountry" + inCountry);

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
			log.debug("Encoding MmiInfo., call UpdateService.." + m_MmiInfo);

			returnValue = updService.callUpdateCdrService(m_MmiInfo);
			log.debug("Return value from addressUpdateMMI: " + returnValue);

			return returnValue;

		} catch (Exception ex) {
			throw ex;
			// return exceptionToString(ex);
		} finally {
			
			 hapiContext = null;
			 log.debug("call UnlockCdrService based on condition from callUpdateCdrService: lockedFlg && returnValue " + lockedFlg + ", " + returnValue);
			if (lockedFlg && !returnValue.equals("1")) {
				log.debug("callUnlockCdrService");
				uncService.callUnlockCdrService(mmiRecs);
			}
			
		}
		

	}

	private boolean isNOE(String stringValue) {
		return ((stringValue == null || stringValue.trim().length() == 0) ? true
				: false);
	}
}
