package org.ihc.itf.cdr;

import org.apache.log4j.Logger;
import org.ihc.itf.util.ItfLoggerHash;

import bea.jolt.ApplicationException;
import bea.jolt.JoltException;
import bea.jolt.JoltRemoteService;
import bea.jolt.JoltSession;
import bea.jolt.JoltSessionAttributes;
import bea.jolt.ServiceException;
import bea.jolt.SessionException;

public class CdrTuxServices {
	private  Logger log = null;
	// Jolt Objects
		private JoltSession m_joltSession = null;
		private JoltRemoteService m_joltService = null;
		static String STRING_FIELD_NAME	= "STRING";
		static String CARRAY_FIELD_NAME	= "CARRAY";
	
		
	// Constructor
	protected  CdrTuxServices(String applicationAddress, String serviceName) throws Exception
	{
		createTuxService(applicationAddress, serviceName) ;
	}
	
	protected void setLogger(String nm)
	{
		log = ItfLoggerHash.getInstance(nm) ;
		log.debug("log set");
	}
			
	private void createTuxService(String applicationAddress, String serviceName) throws Exception{	
		
		JoltSessionAttributes sessionAttributes = new JoltSessionAttributes();
		sessionAttributes.setInt(JoltSessionAttributes.IDLETIMEOUT, 500);
		sessionAttributes.setInt(JoltSessionAttributes.SENDTIMEOUT, 100);
		sessionAttributes.setInt(JoltSessionAttributes.RECVTIMEOUT, 200);
		sessionAttributes.setString(JoltSessionAttributes.APPADDRESS, applicationAddress);
		try{
			m_joltSession = new JoltSession(sessionAttributes, "", "","", null);
		}catch(SessionException sesEx){
			throw new Exception("SessionException  creating session for calling Jolt Service.. "+sesEx.getMessage(), sesEx);
		}
		
		try{
			m_joltService = new JoltRemoteService(serviceName,m_joltSession);
		}catch(ServiceException serEx){
			m_joltSession.endSession();
			m_joltSession = null;
			throw new Exception("ServiceException while calling Jolt Remote Service.. "+serEx.getMessage(), serEx);	
		}
	}
	
	public void shutdownTuxService() throws Exception
	{
		if(log != null)
		{
			log.debug("CdrTuxServices shutdownTuxService");
		}
		m_joltService = null;
		if (null != m_joltSession) {
			m_joltSession.endSession();
			m_joltSession = null;
		}
	}

	protected void callService()
			 throws Exception
					
	{
		
		try {
			if(this.m_joltService != null)
			{
				if(log != null)
				{
					log.debug("Calling service: <" + this.m_joltService.getName() + ">");
				}
				this.m_joltService.call(null);
				if(log != null)
				{
					log.debug("Reading response bytes as <" + CARRAY_FIELD_NAME + ">");
				}
			}
			else
			{
				throw new Exception("CONNECTIONERROR, Jolt handle is NULL ");

			}
		} catch (ApplicationException appEx) {
			// Catch this guy and re-throw it so it gets passed the "catch Exception" at the bottom
			log.error("Application exception caught, re-throwing: " + appEx );
				  throw new Exception("DATAERROR: TPESVCFAIL ApplicationException Exception Occured. " + appEx.getApplicationCode() + ", " + appEx.getMessage()+ m_joltService.getName(), appEx);				  

		} catch (JoltException joltEx) {
			Object[] msgArray = {
					"Jolt Exception caught from service call <",
					this.m_joltService.getName(),
					">:",
					joltEx	
				};
			log.error("JoltException: " + msgArray.toString());
			switch ( joltEx.getErrno() ) {
				case JoltException.TPETIME:
					throw new Exception("RESEND A time out occurred. "+joltEx.getMessage()+ m_joltService.getName(), joltEx);
				case JoltException.TPESVCFAIL:
				case JoltException.TPESVCERR:
					throw new Exception("DATAERROR "+joltEx.getMessage()+ m_joltService.getName(), joltEx);
				case JoltException.TPELIMIT:
				case JoltException.TPENOENT:
				case JoltException.TPEOS:
				case JoltException.TPESYSTEM:
					throw new Exception("CONNECTIONERROR "+joltEx.getMessage()+ m_joltService.getName(), joltEx);
				case JoltException.TPEJOLT:
					throw new Exception("CONNECTIONERROR, The session object or message ID is invalid..."+joltEx.getMessage()+ m_joltService.getName(), joltEx);
				default:
					  throw new Exception("SHUTDOWN Unknown Jolt Exception Occured. "+joltEx.getMessage()+ m_joltService.getName(), joltEx);				  

			}

		}	 catch (Exception Ex) {
			log.error("Unknown Exception caught from service call <" + this.m_joltService.getName() + ">: " + Ex);
			throw new Exception("CONNECTIONERROR Jolt Exception caught from service call "+Ex.getMessage()+ m_joltService.getName(), Ex);
		}

		return;
	}
	
	protected void setRequestBytes( byte[] requestBytes )
	{
		if(log != null)
		{
			log.debug("setRequestBytes: " + requestBytes.length);
		}
		this.m_joltService.setBytes(CARRAY_FIELD_NAME, requestBytes, requestBytes.length);
		
		return;
	}
	
	protected byte[] getResponseBytes()
	{
		byte[] responseBytes = this.m_joltService.getBytesDef(CARRAY_FIELD_NAME, null);
		
		return responseBytes;
	}
	
	protected void setRequestString( String requestString )
	{
		this.m_joltService.setString(STRING_FIELD_NAME, requestString);
		
		return;
	}
	
	protected String getResponseString()
	{
		String responseString = this.m_joltService.getStringDef(STRING_FIELD_NAME, null);
		
		return responseString;
	}
	
}
