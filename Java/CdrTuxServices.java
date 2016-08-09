package org.ihc.itf.cdr;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.math.BigInteger;

import org.apache.log4j.Logger;

import cdr.asn1.BaseDecoder;
import cdr.asn1.BaseEncoder;
import cdr.asn1.DecodingException;
import cdr.asn1.EncodingException;

import bea.jolt.ApplicationException;
import bea.jolt.JoltException;
import bea.jolt.JoltRemoteService;
import bea.jolt.JoltSession;
import bea.jolt.JoltSessionAttributes;
import bea.jolt.ServiceException;
import bea.jolt.SessionException;
import cdr.asn1.base.Coded;
import cdr.asn1.base.VisibleString;
import cdr.asn1.dsql.DSqlArguments;
import cdr.asn1.dsql.DSqlTable;

public class CdrTuxServices {
	
	/* Get actual class name to be printed on */
	private static Logger log = Logger.getLogger(CdrTuxServices.class.getName());

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
			
	private void createTuxService(String applicationAddress, String serviceName) throws Exception{	
		
		JoltSessionAttributes sessionAttributes = new JoltSessionAttributes();
		sessionAttributes.setInt(JoltSessionAttributes.IDLETIMEOUT, 500);
		sessionAttributes.setInt(JoltSessionAttributes.SENDTIMEOUT, 100);
		sessionAttributes.setInt(JoltSessionAttributes.RECVTIMEOUT, 200);
		sessionAttributes.setString(JoltSessionAttributes.APPADDRESS, applicationAddress);
		try{
			m_joltSession = new JoltSession(sessionAttributes, "", "","", null);
		}catch(SessionException sesEx){
			throw new Exception("INITERROR while creating session for calling Jolt Service.. "+sesEx.getMessage(), sesEx);
		}
		log.debug("JoltSession created" );
		
		try{
			m_joltService = new JoltRemoteService(serviceName,m_joltSession);
		}catch(ServiceException serEx){
			throw new Exception("INITERROR while calling Jolt Remote Service.. "+serEx.getMessage(), serEx);	
		}
		log.debug("JoltRemoteService created");		
	}
	
	public void shutdownTuxService() throws Exception
	{
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
				log.debug("Calling service <" + this.m_joltService.getName() + ">");
				this.m_joltService.call(null);
	
				log.debug("Reading response bytes as <" + CARRAY_FIELD_NAME + ">");
			}
			else
			{
				throw new Exception("CONNECTIONERROR, Jolt handle is NULL ");

			}
		} catch (ApplicationException appEx) {
			// Catch this guy and re-throw it so it gets passed the "catch Exception" at the bottom
			log.error("Application exception caught, re-throwing" + appEx );
			throw appEx;
		} catch (JoltException joltEx) {
			Object[] msgArray = {
					"Jolt Exception caught from service call <",
					this.m_joltService.getName(),
					">:",
					joltEx	
				};
			log.debug(msgArray);
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
					throw new Exception("RESEND Junk character returned. Ignore..."+joltEx.getMessage()+ m_joltService.getName(), joltEx);
				default:
					  throw new Exception("SHUTDOWN Unknown Jolt Exception Occured. "+joltEx.getMessage()+ m_joltService.getName(), joltEx);				  

			}

		} catch (Exception Ex) {
			log.error("Unknown Exception caught from service call <" + this.m_joltService.getName() + ">: " + Ex);
			throw new Exception("CONNECTIONERROR Jolt Exception caught from service call "+Ex.getMessage()+ m_joltService.getName(), Ex);
		}

		

		return;
	}
	
	protected void setRequestBytes( byte[] requestBytes )
	{
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
	
protected byte[] dsqlEncode(DSqlTable m_requestDSqlTable) throws Exception {
	 BaseEncoder dsqlTransEncoder = new BaseEncoder(new ByteArrayOutputStream());
        byte[] encodedASN1Request = null;

        try {
            dsqlTransEncoder.encodeObject(m_requestDSqlTable);
            encodedASN1Request = ((ByteArrayOutputStream) dsqlTransEncoder.getOutputStream()).toByteArray();
        } catch (EncodingException encEx) {
            throw new Exception("ENCODEEXCEPTION, Error while encoding DSQL request. ");
        } finally {
            
        }  
        return encodedASN1Request;
    }
	
	protected Object dsqlDecode(byte[] encodedASN1Response) throws Exception{
		Object responseDSqlTable = null;
		try {
			BaseDecoder asn1Decoder = new BaseDecoder(new ByteArrayInputStream(encodedASN1Response));
			responseDSqlTable = (DSqlTable) asn1Decoder.decodeObject(DSqlTable.class);
		} catch (DecodingException decEx) {			
			throw new Exception("DECODEEXCEPTION, Error while decoing DSQL response. ");
		}
		return responseDSqlTable;
	}
	
	protected DSqlTable prepareDSqlRequest(String... args){
		DSqlTable m_requestDSqlTable = new DSqlTable();
		m_requestDSqlTable.setSqlId(MAGIC_SQL_NCID);
		
		DSqlArguments argumentList = new DSqlArguments();
		for (int i = 0; i < args.length; i++){
			argumentList.add(i, new VisibleString(args[i]));			
	    }
		m_requestDSqlTable.setArgumentsList(argumentList);
		
		return m_requestDSqlTable;
		
	}
	private static final Coded MAGIC_SQL_NCID   = new Coded( BigInteger.valueOf( 1450582 ) );
}
