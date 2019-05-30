package org.ihc.itf.util;

import java.io.IOException;
import java.util.Hashtable;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.RollingFileAppender;

public class ItfLoggerHash {
	
	final static Hashtable<String, Logger> itfLoggerTable = new Hashtable<String, Logger>();
		
	private ItfLoggerHash()
	{
		;
	}
	
	public static Logger getInstance(String name) {
	      Logger log = itfLoggerTable.get(name);
	      if(log == null)
	      {
	     	log = itfLoggerTable.get(Thread.currentThread().getStackTrace()[2].getClassName());
	      }
	      if(log == null)
	      {
	     	log = Logger.getLogger(name);
	     	itfLoggerTable.put(name, log);
	      }
		return log;
	      
	}
	
	public static Logger setLoggerProperties(String className, String fileName, boolean debug) throws IOException
	{
		return setLoggerProperties(className, fileName,  debug, 1024 * 1024, 10) ;
	}
	
	public static Logger setLoggerProperties(String className, String fileName, boolean debug, int fileSize, int numFiles) throws IOException
	{
			Logger log = itfLoggerTable.get(className);
			if(log != null){
				log.error("Found the logger: " + log);
				log.removeAllAppenders();
				itfLoggerTable.remove(className);
				log = null;
			}
		
			log = Logger.getLogger(className);
		
			String PATTERN = "[%d,%p] [%c{1}.%M:%L] %m%n"; //$NON-NLS-1$
			PatternLayout patternLayout = new PatternLayout(PATTERN);
			RollingFileAppender rolapp = new RollingFileAppender(patternLayout,
					fileName, true);
			rolapp.setMaximumFileSize(fileSize);
			rolapp.setMaxBackupIndex(numFiles);
			rolapp.setFile(fileName);
			log.addAppender(rolapp);
			if (debug) {
				log.setLevel(Level.DEBUG);
			} else {
				log.setLevel(Level.ERROR);
			}
			log.debug("Initialized the logger: " + fileName);
			itfLoggerTable.put(className, log);
		return log;
	}

}
