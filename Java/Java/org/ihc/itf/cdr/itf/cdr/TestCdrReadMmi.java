package org.ihc.itf.cdr;

public class TestCdrReadMmi {
	
	/* PROD Addresses */
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";

	/* TEST Addresses */
	//private static final String ApplicationAddress = "//svtst01:54210";
	//private static final String ApplicationAddress = "//tltst01:41210";
	
	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("Begin TestCdrReadMmi!");		
		CdrReadMmi objMmi = new CdrReadMmi(ApplicationAddress, "MMIREAD");
		//Step1: Do readMMI
		System.out.println("\n");
		cdr.asn1.hems.MmiInfo mmiInfo = objMmi.getMMInfo("551095988");
		cdr.asn1.hems.DataRecord dataRecord = mmiInfo.getDataRecord(); 
		cdr.asn1.hems.MmiRecord mmiRecord = dataRecord.getMmiRecords()[0];
		cdr.asn1.hems.MemberInfo memberInfo = dataRecord.getMmiRecords()[0].getMemberInfo();
		cdr.asn1.hems.MmiFlags mmiFlags =  dataRecord.getMmiRecords()[0].getMmiFlags();
		
		System.out.println("dataRecord accessed");
		
		/*System.out.println("DateOfBirth : " + mmiInfo.getDateOfBirth().getBirthDate().toString());
		System.out.println("Sex : " + mmiInfo.getSsn());
		System.out.println("Race: " + mmiInfo.getRaceCid().getNcid());
		System.out.println("MaritialStatus: " + mmiInfo.getMaritalStatusCid().getNcid());
		System.out.println("Religion: " + mmiInfo.getReligionCid().getNcid());
		System.out.println("SSN: " + mmiInfo.getSsn());
		System.out.println("DateOfDeath: " + mmiInfo.getDateOfDeath());
		System.out.println("Expired Flag: " + dataRecord.getMmiRecords()[0].getMmiFlags().getExpiredFlag());
		for (int i = 0; i < mmiInfo.getFacilities().length;i++){
			System.out.println("\n");
			System.out.println("Facility MmiFacilityCid at: " + i + " : " + mmiInfo.getFacilities()[i].getMmiFacilityCid().getNcid());
			System.out.println("Facility MedRecNumber at: " + i + " : " + mmiInfo.getFacilities()[i].getMedRecNumber());
		}
		for (int i = 0; i < mmiInfo.getNames().length; i++){
			if(mmiInfo.getNames()[i] != null){
				System.out.println("\n");
				System.out.println("Names NType at: " + i + " : " + mmiInfo.getNames()[i].getNameTypeCid().getNcid().intValue());
				System.out.println("Names LName at: " + i + " : " + mmiInfo.getNames()[i].getLastName());
				System.out.println("Names FName at: " + i + " : " + mmiInfo.getNames()[i].getFirstName());
				System.out.println("Names MName at: " + i + " : " + mmiInfo.getNames()[i].getMiddleName());
				System.out.println("Names Suffix at: " + i + " : " + mmiInfo.getNames()[i].getSuffix());				
			}
		}
		if(mmiRecord.getMotherName() != null){
			System.out.println("\n");
			System.out.println("MotherName NType : " + mmiRecord.getMotherName().getNameTypeCid().getNcid().intValue());
			System.out.println("MotherName LName : " + mmiRecord.getMotherName().getLastName());
			System.out.println("MotherName FName : " + mmiRecord.getMotherName().getFirstName());
			System.out.println("MotherName MName : " + mmiRecord.getMotherName().getMiddleName());
			System.out.println("MotherName Suffix : " + mmiRecord.getMotherName().getSuffix());				
		}
		for (int i = 0; i < mmiInfo.getAddresses().length; i++){
			if(mmiInfo.getAddresses()[i] != null){
				System.out.println("\n");
				System.out.println("Address Street1 at: " + i + " : " + mmiInfo.getAddresses()[i].getStreet1());
				System.out.println("Address Street2 at: " + i + " : " + mmiInfo.getAddresses()[i].getStreet2());
				System.out.println("Address City at: " + i + " : " + mmiInfo.getAddresses()[i].getCity());
				System.out.println("Address State at: " + i + " : " + mmiInfo.getAddresses()[i].getState());
				System.out.println("Address Zip at: " + i + " : " + mmiInfo.getAddresses()[i].getPostCode());
				System.out.println("Address Country at: " + i + " : " + mmiInfo.getAddresses()[i].getCountry());
			}
		}
		for (int i = 0; i < mmiInfo.getPhones().length; i++){
			if(mmiInfo.getPhones()[i] != null){
				System.out.println("\n");
				System.out.println("PhoneTypeCid at: " + i + " : " + mmiInfo.getPhones()[i].getPhoneTypeCid().getNcid().intValue());
				System.out.println("AreaCode at: " + i + " : " + mmiInfo.getPhones()[i].getAreaCode());
				System.out.println("LocalNumber at: " + i + " : " + mmiInfo.getPhones()[i].getLocalNumber());
				System.out.println("Extension at: " + i + " : " + mmiInfo.getPhones()[i].getExtension());
				System.out.println("CountryCode at: " + i + " : " + mmiInfo.getPhones()[i].getCountryCode());
			}
		}			
		System.out.println("Language : " + mmiInfo.getPassPort());
		System.out.println("Ethinicity : " + mmiInfo.getGovtHealthNumber());
		System.out.println("DeactivateFlag : " + mmiFlags.getDeactivateFlag());
		System.out.println("Race : " + mmiInfo.getRaceCid().getNcid());
		System.out.println("MaritialStatus Cid : " + mmiInfo.getMaritalStatusCid().getNcid());
		System.out.println("Religion Cid : " + mmiInfo.getReligionCid().getNcid());
		System.out.println("InstitutionalFlag : " + mmiFlags.getInstitutionalFlag());
		*/
	}

}
