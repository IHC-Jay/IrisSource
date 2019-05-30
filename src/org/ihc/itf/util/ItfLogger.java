package org.ihc.itf.util;

import java.io.IOException;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.RollingFileAppender;

public class ItfLogger {
	final static Logger itfLogger = Logger.getLogger(Thread.currentThread()
			.getStackTrace()[2].getClassName());

	private ItfLogger()
	{
		
	}
	
	public static Logger getInstance() {
	      return itfLogger;
	}
	
	public static Logger setLoggerProperties(String fileName, boolean debug) throws IOException
	{
		return setLoggerProperties(fileName,  debug, 1024 * 1024, 10) ;
	}
	
	public static Logger setLoggerProperties(String fileName, boolean debug, int fileSize, int numFiles) throws IOException {
		// String log4jConfPath = "c:\\Temp\\log4j.properties";
		// PropertyConfigurator.configure(log4jConfPath);
	
		
			String PATTERN = "[%d,%p] [%c{1}.%M:%L] %m%n"; //$NON-NLS-1$
			PatternLayout patternLayout = new PatternLayout(PATTERN);
			RollingFileAppender rolapp = new RollingFileAppender(patternLayout,
					fileName, true);
			rolapp.setMaximumFileSize(fileSize);
			rolapp.setMaxBackupIndex(numFiles);
			itfLogger.addAppender(rolapp);
			if (debug) {
				itfLogger.setLevel(Level.DEBUG);
			} else {
				itfLogger.setLevel(Level.ERROR);
			}
			itfLogger.debug("Initialized the logger: " + fileName);
		
		return itfLogger;
	}

}
