package org.ihc.itf.util;

import org.ihc.itf.util.convertXmlToJson;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
//import org.json.*;


public class TestXml2Json {
	static Logger log = null;

	public static void main(String[] args) throws Exception {

		String txml="<immunizations><patientInfo><empi>269447676</empi></patientInfo><immunizationList><immunizationDetail><drugIdentifierNcid>521116217</drugIdentifierNcid><dosage>1</dosage><dosageUnitNcid>1671</dosageUnitNcid><administeredRouteNcid>67590</administeredRouteNcid><administeredSiteNcid>1831</administeredSiteNcid><administeredDtTm>20180430000000</administeredDtTm><administeredNoteNcids>521107193</administeredNoteNcids><substanceManufacturerNcid>162052</substanceManufacturerNcid><substanceLotNumber>3HG77</substanceLotNumber><fundSource>V01</fundSource><informationStatements><publishedDtTm>20151105000000</publishedDtTm><givenOnDtTm>20180430000000</givenOnDtTm></informationStatements></immunizationDetail><immunizationDetail><drugIdentifierNcid>521116217</drugIdentifierNcid><dosage>1</dosage><dosageUnitNcid>1671</dosageUnitNcid><administeredRouteNcid>67590</administeredRouteNcid><administeredSiteNcid>1831</administeredSiteNcid><administeredDtTm>20180430000000</administeredDtTm><administeredNoteNcids>521107193</administeredNoteNcids><substanceManufacturerNcid>162052</substanceManufacturerNcid><substanceLotNumber>3HG77</substanceLotNumber><fundSource>V01</fundSource><informationStatements><publishedDtTm>20151105000000</publishedDtTm><givenOnDtTm>20180430000000</givenOnDtTm></informationStatements></immunizationDetail><immunizationDetail><drugIdentifierNcid>521116217</drugIdentifierNcid><dosage>1</dosage><dosageUnitNcid>1671</dosageUnitNcid><administeredRouteNcid>67590</administeredRouteNcid><administeredSiteNcid>1831</administeredSiteNcid><administeredDtTm>20180330000000</administeredDtTm><administeredNoteNcids>521107193</administeredNoteNcids><substanceManufacturerNcid>162052</substanceManufacturerNcid><substanceLotNumber>3HG77</substanceLotNumber><fundSource>V01</fundSource><informationStatements><publishedDtTm>20151105000000</publishedDtTm><givenOnDtTm>20180330000000</givenOnDtTm></informationStatements></immunizationDetail><immunizationDetail><drugIdentifierNcid>521116217</drugIdentifierNcid><dosage>1</dosage><dosageUnitNcid>1671</dosageUnitNcid><administeredRouteNcid>67590</administeredRouteNcid><administeredSiteNcid>1831</administeredSiteNcid><administeredDtTm>20180330000000</administeredDtTm><administeredNoteNcids>521107193</administeredNoteNcids><substanceManufacturerNcid>162052</substanceManufacturerNcid><substanceLotNumber>3HG77</substanceLotNumber><fundSource>V01</fundSource><informationStatements><publishedDtTm>20151105000000</publishedDtTm><givenOnDtTm>20180330000000</givenOnDtTm></informationStatements></immunizationDetail><immunizationDetail><drugIdentifierNcid>529478140</drugIdentifierNcid><dosage>0.5</dosage><dosageUnitNcid>1671</dosageUnitNcid><administeredRouteNcid>67590</administeredRouteNcid><administeredSiteNcid>1832</administeredSiteNcid><administeredDtTm>20180117000000</administeredDtTm><administeredNoteNcids>521107193</administeredNoteNcids><substanceManufacturerNcid>162053</substanceManufacturerNcid><substanceLotNumber>S74423</substanceLotNumber><fundSource>V01</fundSource><informationStatements><publishedDtTm>20151105000000</publishedDtTm><givenOnDtTm>20180117000000</givenOnDtTm></informationStatements></immunizationDetail><immunizationDetail><drugIdentifierNcid>520730796</drugIdentifierNcid><dosage>0.5</dosage><dosageUnitNcid>1671</dosageUnitNcid><administeredRouteNcid>67590</administeredRouteNcid><administeredSiteNcid>1831</administeredSiteNcid><administeredDtTm>20180117000000</administeredDtTm><administeredNoteNcids>521107193</administeredNoteNcids><substanceManufacturerNcid>162052</substanceManufacturerNcid><substanceLotNumber>TF422</substanceLotNumber><fundSource>V01</fundSource><informationStatements><publishedDtTm>20120123000000</publishedDtTm><givenOnDtTm>20180117000000</givenOnDtTm></informationStatements></immunizationDetail><immunizationDetail><drugIdentifierNcid>50450318</drugIdentifierNcid><administeredDtTm>20171001000000</administeredDtTm><administeredNoteNcids>521107194</administeredNoteNcids><fundSource>V01</fundSource></immunizationDetail></immunizationList></immunizations>";
		log = ItfLoggerHash.getInstance("convertXmlToJson");
		log.setLevel(Level.ERROR);
		System.out.println("TestXml2Json!");
		convertXmlToJson x2j = new convertXmlToJson();		
		String dob = x2j.xml2Json(txml);
		
		System.out.println("JSON String: "+dob);
	}

}

