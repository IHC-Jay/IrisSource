package org.ihc.itf.iris;
import java.io.Console;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

import com.intersystems.jdbc.IRIS;
import com.intersystems.jdbc.IRISConnection;

public final class StartStopStatus {

	
	public static void main(String[] args) {
		
	
		String ip = "lpv-itfiris01.co.ihc.com"; // "10.51.236.49";
		int port = 1972;
		String namespace = "ITFCOMMON";
		String username = "test";
		
		String compFl = "";
		
		Options options = new Options();
		try {
						
			username = System.getProperty("user.name");
		    System.out.println("StartStopStatus - username = " + username);
		    
	        Option host = new Option("h", "host", true, "host address");
	        host.setRequired(true);
	        
	        Option portArg = new Option("p", "port", true, "host port #");
	        portArg.setRequired(true);
	        
	        Option startArg = new Option("t", "start", true, "Components File");
	        Option stopArg = new Option("o", "stop", true, "Components File");
	        Option statArg = new Option("s", "status", true, "Components File");
	        
	        	        
	        options.addOption(host).addOption(portArg).addOption(startArg).addOption(stopArg).addOption(statArg);
	        
	        //parse the options passed as command line arguments
	        CommandLineParser parser = new DefaultParser();
	        CommandLine cmd = parser.parse( options, args);
	        String cmdStr = "";
	        // has the logFile argument been passed?
	        if(cmd.hasOption("host")) {
	           //get the logFile argument passed
	        	ip = cmd.getOptionValue( "host" );
	           System.out.println("host: "+ ip );
	        }
	        if(cmd.hasOption("port")) {
		           //get the logFile argument passed
		        	port = Integer.parseInt(cmd.getOptionValue( "port" ));
		           System.out.println( "port: " + port );
		        }
	        
	        if(cmd.hasOption("start")) {
		           //get the logFile argument passed
	        	compFl = cmd.getOptionValue( "start" );
		           System.out.println("start file: " + compFl );
		           cmdStr = "start";
		        }
	        	
	        else if(cmd.hasOption("stop")) {
		           //get the logFile argument passed
	        	compFl = cmd.getOptionValue( "stop" );
		           System.out.println("stop file: " + compFl );
		           cmdStr = "stop";
		        }
	        else if(cmd.hasOption("status")) {
		           //get the logFile argument passed
	        	compFl = cmd.getOptionValue( "status" );
		           System.out.println("status file: " + compFl );
		           cmdStr = "status";
		        }
	        
	        if(compFl == null || compFl.isEmpty() )	   
	        {
	        	System.out.println("Component file (with NmSp and component Name) is required for status, start, stop (s/t/o) command");
	            return;
	        }
			
	     /** Create the console object **/
	        Console console = System.console();
	  
	        if (console == null) {
	            System.out.println("No console available, can't continue");
	            return;
	            
	        }
	        
	        	console.printf("Please enter your password: ");
	        	char[] passwordChars = console.readPassword();
	        	String passwordString =  new String(passwordChars);
	        
	   
	  			
			// Using IRISDataSource to connect
						
			System.out.println("Making connection");
		
			IRISConnection conn = (IRISConnection) DriverManager.getConnection("jdbc:IRIS://" + ip+":"+port+"/"+namespace,username,passwordString);

			IRIS iris = IRIS.createIRIS(conn);
			System.out.println("Hello World! You have successfully connected to InterSystems IRIS.");
	
    		Object[] objects = new Object[] {compFl, cmdStr};
    		String retStr = iris.classMethodString("IHC.ITF.ITFCOMMON.Util.Monitor", "ProcessFile", objects);
    		System.out.println("IHC.ITF.ITFCOMMON.Util.Monitor ProcessFile returned\n " + retStr.replaceAll(";", "\n"));  // get the method result

					    	
			    		    		  
					
		} catch ( SQLException e) 
					{ 
						System.out.println(ip +"/" + port + ": " + e.getMessage());
					} 
					catch (RuntimeException e) {
						System.out.println("Call returned RuntimeException:");
						System.out.println(e.getMessage());
				  }
		catch (ParseException e) {
		    System.out.println(e.getMessage());
		    System.out.println("Usage:" + options);
		    System.exit(0);
		}
		catch (Exception e) {
			System.out.println("Call returned Exception:");
			System.out.println(e.getMessage());
	  }
		}


}
