package org.ihc.itf.util;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
///import org.ihc.itf.util.ItfLogger;


public class TestLogger {
	static Logger logger = null;

	 
public static void main(String[] args) 
{
	callIntLogger("c:\\Temp\\test.txt", 1);
}

public static void callIntLogger(String fileName, int debug)
{
		char CR = 0x0D;
		String hl7Msg = 
				"MSH|^~\\&|PCSAddrUpd|211|ENGINE|IMTN|02282017175222||ADT^A01|Q295826994T380033832X109004||2.3||||||8859"+CR+"EVN|A08||02282017175222||100"+CR+"PID||269757715^^^EMPI^MRN|269757715^^^^EMPI|269757715^0^^EMPI^Account Number|LEFEVRE^BLAINE-TEST^F^^^^187||19800216000000||LEFEVRE^BLAINE-TEST^187|187|WRONG341 E 100 S^^HYRUM^UT^84319-1339^USA^199|||(801)777-7777|42|183||7380621249^^^FIN^FIN NBR|464848484|||14783480|||0"; 
		for(int i=0; i< 3; i++)
		{
		try {
			//String log4jConfPath = "c:\\Temp\\log4j.properties";
			//PropertyConfigurator.configure(log4jConfPath);
			
			logger = ItfLoggerHash.setLoggerProperties("TestLogger", fileName, (debug == 1) ? true : false) ;
			
			 
		
			logger.error("Starting level: " + logger.getLevel());
		
			  logger.error("This is error 1 ");
			System.out.println("level: " + logger.getLevel());
			
			

			
			System.out.println("level: " + logger.getLevel());
			logger.info("level: " + logger.getLevel());
			

		      logger.debug("This is debug 2 : " + hl7Msg);
			

			//logs an error message with parameter
			logger.error("This is error : " );

			//logs an exception thrown from somewhere
			logger.info("This is info");
			
			logger.setLevel(Level.DEBUG);
			System.out.println("level: " + logger.getLevel());
			
			//logs a debug message
			
		      logger.debug("This is debug 3 ");
			

			//logs an error message with parameter
			logger.error("This is error 3 : " );

			//logs an exception thrown from somewhere
			logger.info("This is info 3");
			
			logger.setLevel(Level.ERROR);
			System.out.println("level: " + logger.getLevel() + ", " + i);
			
			//logs a debug message
			
		      logger.debug("This is debug 4 " + hl7Msg);
			

			//logs an error message with parameter
			logger.error("This is error 4: " );

			//logs an exception thrown from somewhere
			logger.info("This is info 4");
			
	
		} catch (Exception ex) {
			System.err.println(ex);
		}
		}
	}




}

