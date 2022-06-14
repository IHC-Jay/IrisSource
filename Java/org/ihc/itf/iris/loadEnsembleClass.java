package org.ihc.itf.iris;
import java.io.ByteArrayOutputStream;
import java.io.Console;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Date;

import com.intersystems.jdbc.IRIS;
import com.intersystems.jdbc.IRISConnection;
import com.intersystems.jdbc.IRISDataSource;
import com.intersystems.jdbc.IRISObject;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public final class loadEnsembleClass {

	
	public static void main(String[] args) {
		
	
		String ip = "lpv-itfiris01.co.ihc.com"; // "10.51.236.49";
		int port = 1972;
		String namespace = "ITFCOMMON";
		String username = "test";
		
		String svnFlNm = "cls/IHC/ITF/ITFCOMMON/Utility.xml";
		
		svnRevision svnRevObj = new svnRevision();
		svnRevObj.setRevNum(-1);
		Options options = new Options();
		try {
							    
	        Option userOpt = new Option("u", "user", true, "user");
	        // userOpt.setRequired(true);
	        
	        Option host = new Option("h", "host", true, "host address");
	        host.setRequired(true);
	        
	        Option portArg = new Option("p", "port", true, "host port #");
	        portArg.setRequired(true);
	        
	        Option fileArg = new Option("f", "file", true, "Class File");
	        fileArg.setRequired(true);
	        
	        Option ver = new Option("r", "revision", true, "Revision #");
	        	        
	        options.addOption(userOpt).addOption(host).addOption(portArg).addOption(fileArg).addOption(ver);
	        
	        //parse the options passed as command line arguments
	        CommandLineParser parser = new DefaultParser();
	        CommandLine cmd = parser.parse( options, args);
	        // has the logFile argument been passed?
	        if(cmd.hasOption("host")) {
	           //get the logFile argument passed
	        	ip = cmd.getOptionValue( "host" );
	           System.out.println("Host: "+ ip );
	        }
	        if(cmd.hasOption("port")) {
		           //get the logFile argument passed
		        	port = Integer.parseInt(cmd.getOptionValue( "port" ));
		           System.out.println( "Port: " + port );
		        }
	        if(cmd.hasOption("file")) {
		           //get the logFile argument passed
	        	svnFlNm = cmd.getOptionValue( "file" );
		           System.out.println("File: " + svnFlNm );
		        }
	        
	        if(cmd.hasOption("revision")) {
		        //get the logFile argument passed
	        	svnRevObj.setRevNum(Integer.parseInt(cmd.getOptionValue( "revision" )));
		        System.out.println("Revision: " + svnRevObj.getRevNum() );
		    }
	        if(cmd.hasOption("user")) {
	        	username = cmd.getOptionValue( "user" );
		           
	        }
	        else
	        {
	        	username = System.getProperty("user.name");
	        }
	        System.out.println("User: " + username );
	        String flNm = "/tmp/" + username + "/svnImportFile";
	        
	        
			
	     /** Create the console object **/
	        Console console = System.console();
	  
	        if (console == null) {
	            System.out.println("No console available");
	            return;
	        }
	        console.printf("Please enter your password for " + username + ": ", null);
	        char[] passwordChars = console.readPassword();
	        String passwordString = new String(passwordChars);

	        System.out.println("Get file from SVN: " + svnFlNm + ", Rev: " + svnRevObj.getRevNum());
			SvnFile svnObj = new SvnFile();
			ByteArrayOutputStream bstr = svnObj.getFileStream("eai_chef", "tzghty6n4L2S", svnFlNm, flNm, svnRevObj);
			
			// System.out.println("Get file: " + bstr.size());
			
			// Using IRISDataSource to connect
						
						System.out.println("Making connection " + ip+":"+port+"/"+namespace +", User:"+username);
					
						// IRISConnection conn = (IRISConnection) DriverManager.getConnection("jdbc:IRIS://" + ip+":"+port+"/"+namespace,username,passwordString);
						
						IRISDataSource ds = new IRISDataSource();
					    ds.setURL("jdbc:IRIS://" + ip+":"+port+"/"+namespace);
					    ds.setUser(username);
					    ds.setPassword(passwordString);
					    IRISConnection conn = (IRISConnection) ds.getConnection();

						IRIS iris = IRIS.createIRIS(conn);
						System.out.println("Hello World! You have successfully connected to InterSystems IRIS." + ds.getServerName());

						Object[] objects = new Object[] {"TEST"};
						System.out.println("System info:" + iris.classMethodString("IHC.ITF.ITFCOMMON.SystemUtil", "getSysInfo", objects));
						
			    		String opt = "cukd"; // ldck";
			    		
			    		objects = new Object[] {flNm};
			    		Boolean ext = iris.classMethodBoolean("%Library.File", "Exists", objects);
			    		System.out.println("File Exists returned: " + ext);  // get the method result
			    		if(ext.booleanValue())
			    		{
			    			System.out.println("File size: " + iris.classMethodLong("%Library.File", "GetFileSize", objects));
			    		}
			    		else
			    		{
			    			System.out.println(flNm + " - File does not exist");
			    			System.exit(0);
			    		}
			    		
			    		objects = new Object[] {bstr, flNm, opt};
			    		String retStr = iris.classMethodString("IHC.ITF.ITFCOMMON.SystemUtil", "Import", objects);
			    		System.out.println("Import returned: " + retStr);  // get the method result
			    		
			    		objects = new Object[] {};
			    		IRISObject test = (IRISObject)iris.classMethodObject("IHC.ITF.SrcCtrlPkg.ITFCOMMONClasses", "%New", objects);
			    		test.set("FileName", svnFlNm);
			    		test.set("UserName", username);
			    		test.set("Revision", "" + svnRevObj.getRevNum());
			    		test.set("Description", "Import from Java");
			    		test.set("ImplDtTm", new Date().toString());
			    		test.set("Instance", ip+":"+port+"/"+namespace);
			    		System.out.println("SAVE: " + test.invokeBoolean("%Save", objects));
			    		  
					}
					catch ( SQLException e) 
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
