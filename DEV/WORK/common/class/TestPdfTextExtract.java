package org.apache.pdfbox.util;

import org.apache.pdfbox.util.ExtractPdfText;
//import org.ihc.itf.util.ItfLoggerHash;

import java.io.FileInputStream;
import java.io.InputStream;

//import org.apache.log4j.Level;
//import org.apache.log4j.Logger;
//import org.json.*;


public class TestPdfTextExtract {
	//static Logger log = null;
    private TestPdfTextExtract()
    {
        // example class should not be instantiated
    }
    
	public void main(String[] args) throws Exception {
		//log = ItfLoggerHash.getInstance("convertXmlToJson");
		//log.setLevel(Level.ERROR);

		System.out.println("TestdfTextxtract!");
		System.out.println("File: "+args[0]);
		InputStream in = new FileInputStream(args[0]);
		ExtractPdfText xpdf = new ExtractPdfText();	
		
		String dob = xpdf.getText(in);
		
		System.out.println("PDF String: "+dob);
	}

}