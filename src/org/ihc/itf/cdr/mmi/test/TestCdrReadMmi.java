package org.ihc.itf.cdr.mmi.test;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.ihc.itf.cdr.mmi.CdrReadMmi;

public class TestCdrReadMmi {
	
	/* PROD Addresses */
	////lptlcdr301:40210,//lptlcdr302:40210,//mktlcdr301:40210,//mktlcdr302:40210
	//private static final String ApplicationAddress = "//lptlcdr301:40210";
	//private static final String ApplicationAddress = "//lptlcdr302:40210";
	//private static final String ApplicationAddress = "//mktlcdr301:40210";
	//private static final String ApplicationAddress = "//mktlcdr302:40210";

	/* TEST Addresses */
	//private static final String ApplicationAddress = "//svtst01:54210";
 private static final String ApplicationAddress = "//tltst01:41210";
	
	
	// CAREFUL - PROD ADDRESS
		//private static final String ApplicationAddress = "//lptlcdr302:40210";
		
	
	public static void main(String[] args) throws Exception {
		// Testing check MMI
		System.out.println("Begin TestCdrReadMmi!");		
		CdrReadMmi objMmi = new CdrReadMmi(ApplicationAddress, "MMIREAD", "c:\\Temp\\MMIREAD", 1);
		//Step1: Do readMMI		
		//cdr.asn1.hems.MmiInfo mmiInfo = objMmi.getMMInfo("586101038"); // 403135941"); // "550046663");
		cdr.asn1.hems.MmiInfo mmiInfo = objMmi.getMMInfo("980031115"); // 403135941"); // "550046663");
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
		
		System.out.println("Sex : " + memberInfo.getSex());
		System.out.println("Race: "+memberInfo.getRaceCid());
		System.out.println("Marital Status: "+memberInfo.getMaritalStatusCid());
		System.out.println("Religion : "+memberInfo.getReligionCid());
		
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
		System.out.println("\n");
		if (memberInfo.getFacilities()!=null){
		for (int i = 0; i < memberInfo.getFacilities().length;i++){
			System.out.println("\n");
			System.out.println("Facility MmiFacilityCid at: " + i + " : " + memberInfo.getFacilities()[i].getMmiFacilityCid().getNcid());
			System.out.println("Facility MedRecNumber at: " + i + " : " + memberInfo.getFacilities()[i].getMedRecNumber());
		}
		}else{
			System.out.println("Facilities null");		
		}
		
		for (int i = 0; i < memberInfo.getNames().length; i++){
		//	if(memberInfo.getNames()[i] != null){
				System.out.println("\n");
				System.out.println("Names NType at: " + i + " : " + memberInfo.getNames()[i].getNameTypeCid().getNcid().intValue());
				System.out.println("Names LName at: " + i + " : " + memberInfo.getNames()[i].getLastName());
				System.out.println("Names FName at: " + i + " : " + memberInfo.getNames()[i].getFirstName());
				System.out.println("Names MName at: " + i + " : " + memberInfo.getNames()[i].getMiddleName());
				System.out.println("Names Suffix at: " + i + " : " + memberInfo.getNames()[i].getSuffix());	
				System.out.println("Names FullName at: " + i + " : " + memberInfo.getNames()[i].getFullName());
				
			//}
		}
		
		System.out.println("\n");
		if(mmiRecord.getMotherName() != null){
			System.out.println("\n");
			System.out.println("MotherName NType : " + mmiRecord.getMotherName().getNameTypeCid());
			System.out.println("MotherName LName : " + mmiRecord.getMotherName().getLastName());
			System.out.println("MotherName FName : " + mmiRecord.getMotherName().getFirstName());
			System.out.println("MotherName MName : " + mmiRecord.getMotherName().getMiddleName());
			System.out.println("MotherName Suffix : " + mmiRecord.getMotherName().getSuffix());				
		}else{
			System.out.println("MotherName is null");
		}
		System.out.println("\n");
		if (memberInfo.getAddresses()!=null){
		for (int i = 0; i < memberInfo.getAddresses().length; i++){
			if(memberInfo.getAddresses()[i] != null){
				System.out.println("\n");
				System.out.println("Address Street1 at: " + i + " : " + memberInfo.getAddresses()[i].getStreet1());
				System.out.println("Address Street2 at: " + i + " : " + memberInfo.getAddresses()[i].getStreet2());
				System.out.println("Address City at: " + i + " : " + memberInfo.getAddresses()[i].getCity());
				System.out.println("Address State at: " + i + " : " + memberInfo.getAddresses()[i].getState());
				System.out.println("Address Zip at: " + i + " : " + memberInfo.getAddresses()[i].getPostCode());
				System.out.println("Address Country at: " + i + " : " + memberInfo.getAddresses()[i].getCountry());
				System.out.println("Address address type ncid at: " + i + " : " + memberInfo.getAddresses()[i].getAddressTypeCid());
				System.out.println("Address FULL Address at: " + i + " : " + memberInfo.getAddresses()[i].getFullAddress());
			}else{
				System.out.println("Address index "+i + " is null.");
			}
		}
		}else{
			System.out.println("Address is null");
		}
		System.out.println("\n");
		if (memberInfo.getPhones()!=null){
		for (int i = 0; i < memberInfo.getPhones().length; i++){
			//if(memberInfo.getPhones()[i] != null){
				System.out.println("\n");
				System.out.println("PhoneTypeCid at: " + i + " : " + memberInfo.getPhones()[i].getPhoneTypeCid().getNcid().intValue());
				System.out.println("AreaCode at: " + i + " : " + memberInfo.getPhones()[i].getAreaCode());
				System.out.println("LocalNumber at: " + i + " : " + memberInfo.getPhones()[i].getLocalNumber());
				System.out.println("Extension at: " + i + " : " + memberInfo.getPhones()[i].getExtension());
				System.out.println("CountryCode at: " + i + " : " + memberInfo.getPhones()[i].getCountryCode());
			//}
	    }	
		}else{
			System.out.println("Phones null");
		}
		System.out.println("Language : " + memberInfo.getPassPort());
		System.out.println("Ethinicity : " + memberInfo.getGovtHealthNumber());
		System.out.println("DeactivateFlag : " + mmiFlags.getDeactivateFlag());
		
		
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
