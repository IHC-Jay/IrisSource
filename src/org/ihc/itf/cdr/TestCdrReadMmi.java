package org.ihc.itf.cdr;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.util.TimeZone;

public class TestCdrReadMmi {
	
	/* PROD Addresses */
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	//private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";

	/* TEST Addresses */
	private static final String ApplicationAddress = "//svtst01:54210";
	//private static final String ApplicationAddress = "//tltst01:41210";
	
	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("Begin TestCdrReadMmi!");		
		CdrReadMmi objMmi = new CdrReadMmi(ApplicationAddress, "MMIREAD");
		//Step1: Do readMMI
		System.out.println("\n");
		cdr.asn1.hems.MmiInfo mmiInfo = objMmi.getMMInfo("980015386");
		cdr.asn1.hems.DataRecord dataRecord = mmiInfo.getDataRecord(); 
		cdr.asn1.hems.MmiRecord mmiRecord = dataRecord.getMmiRecords()[0];
		cdr.asn1.hems.MemberInfo memberInfo = dataRecord.getMmiRecords()[0].getMemberInfo();
		cdr.asn1.hems.MmiFlags mmiFlags =  dataRecord.getMmiRecords()[0].getMmiFlags();
		
		System.out.println("dataRecord accessed");
		
		System.out.println("DateOfBirth : " + memberInfo.getDateOfBirth().getBirthDate().toString());
		
//		String bDate = convertToGMT(memberInfo.getDateOfBirth().getBirthDate().toString());
	//	System.out.println("DateOfBirth after : " + bDate);
		/*
		DateFormat df = new SimpleDateFormat("E MMM dd HH:mm:ss Z yyyy");
		
		try {
		  Date date = df.parse(memberInfo.getDateOfBirth().getBirthDate().toString());		  
		  df.setTimeZone( TimeZone.getTimeZone( "GMT" ) );
		  System.out.println("DOB: "+df.format(date));
		} catch (ParseException e) {
		  e.printStackTrace();
		}
		*/
		
		System.out.println("Sex : " + memberInfo.getSsn());
		System.out.println("Race: " + memberInfo.getRaceCid().getNcid());
		System.out.println("MaritialStatus: " + memberInfo.getMaritalStatusCid().getNcid());
		System.out.println("Religion: " + memberInfo.getReligionCid().getNcid());
		System.out.println("SSN: " + memberInfo.getSsn());
		System.out.println("DateOfDeath: " + memberInfo.getDateOfDeath());
		/*
		if (memberInfo.getDateOfDeath()!=null){
		try {
			  Date date = df.parse(memberInfo.getDateOfDeath().toString());		  
			  df.setTimeZone( TimeZone.getTimeZone( "GMT" ) );
			  System.out.println("DeathDate: "+df.format(date));
			} catch (ParseException e) {
			  e.printStackTrace();
			}
		}
			
			*/
		
		System.out.println("Expired Flag: " + dataRecord.getMmiRecords()[0].getMmiFlags().getExpiredFlag());
		for (int i = 0; i < memberInfo.getFacilities().length;i++){
			System.out.println("\n");
			System.out.println("Facility MmiFacilityCid at: " + i + " : " + memberInfo.getFacilities()[i].getMmiFacilityCid().getNcid());
			System.out.println("Facility MedRecNumber at: " + i + " : " + memberInfo.getFacilities()[i].getMedRecNumber());
		}
		for (int i = 0; i < memberInfo.getNames().length; i++){
			if(memberInfo.getNames()[i] != null){
				System.out.println("\n");
				System.out.println("Names NType at: " + i + " : " + memberInfo.getNames()[i].getNameTypeCid().getNcid().intValue());
				System.out.println("Names LName at: " + i + " : " + memberInfo.getNames()[i].getLastName());
				System.out.println("Names FName at: " + i + " : " + memberInfo.getNames()[i].getFirstName());
				System.out.println("Names MName at: " + i + " : " + memberInfo.getNames()[i].getMiddleName());
				System.out.println("Names Suffix at: " + i + " : " + memberInfo.getNames()[i].getSuffix());				
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
		for (int i = 0; i < memberInfo.getAddresses().length; i++){
			if(memberInfo.getAddresses()[i] != null){
				System.out.println("\n");
				System.out.println("Address Street1 at: " + i + " : " + memberInfo.getAddresses()[i].getStreet1());
				System.out.println("Address Street2 at: " + i + " : " + memberInfo.getAddresses()[i].getStreet2());
				System.out.println("Address City at: " + i + " : " + memberInfo.getAddresses()[i].getCity());
				System.out.println("Address State at: " + i + " : " + memberInfo.getAddresses()[i].getState());
				System.out.println("Address Zip at: " + i + " : " + memberInfo.getAddresses()[i].getPostCode());
				System.out.println("Address Country at: " + i + " : " + memberInfo.getAddresses()[i].getCountry());
			}
		}
		for (int i = 0; i < memberInfo.getPhones().length; i++){
			if(memberInfo.getPhones()[i] != null){
				System.out.println("\n");
				System.out.println("PhoneTypeCid at: " + i + " : " + memberInfo.getPhones()[i].getPhoneTypeCid().getNcid().intValue());
				System.out.println("AreaCode at: " + i + " : " + memberInfo.getPhones()[i].getAreaCode());
				System.out.println("LocalNumber at: " + i + " : " + memberInfo.getPhones()[i].getLocalNumber());
				System.out.println("Extension at: " + i + " : " + memberInfo.getPhones()[i].getExtension());
				System.out.println("CountryCode at: " + i + " : " + memberInfo.getPhones()[i].getCountryCode());
			}
		}			
		System.out.println("Language : " + memberInfo.getPassPort());
		System.out.println("Ethinicity : " + memberInfo.getGovtHealthNumber());
		System.out.println("DeactivateFlag : " + mmiFlags.getDeactivateFlag());
		System.out.println("Race : " + memberInfo.getRaceCid().getNcid());
		System.out.println("MaritialStatus Cid : " + memberInfo.getMaritalStatusCid().getNcid());
		System.out.println("Religion Cid : " + memberInfo.getReligionCid().getNcid());
		System.out.println("InstitutionalFlag : " + mmiFlags.getInstitutionalFlag());
		
	}

	public static String convertToGMT(String datePar) {
		DateFormat srcDtFormat = new SimpleDateFormat("E MMM dd HH:mm:ss Z yyyy");		
		System.out.println(" GMT time: "+datePar);		
		try{	
			Date date = srcDtFormat.parse(datePar);
			srcDtFormat.setTimeZone( TimeZone.getTimeZone( "GMT" ) );
			System.out.println(" GMT time1: "+date);		
			String date1 = srcDtFormat.format(date);
			System.out.println(" GMT time2: "+date1);
			//return(dstDtFormat.parse(date1));
			return(date1);
		}catch(ParseException parEx){
			return null;
		}
	}
	
	  
}
