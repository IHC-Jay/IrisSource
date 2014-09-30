package org.ihc.itf;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.math.BigInteger;

import bea.jolt.JoltRemoteService;
import bea.jolt.JoltSession;
import bea.jolt.JoltSessionAttributes;
import cdr.asn1.BaseDecoder;
import cdr.asn1.BaseEncoder;
import cdr.asn1.DecodingException;
import cdr.asn1.EncodingException;
import cdr.asn1.base.Coded;
import cdr.asn1.base.VisibleString;
import cdr.asn1.dsql.DSqlArguments;
import cdr.asn1.dsql.DSqlColumn;
import cdr.asn1.dsql.DSqlColumns;
import cdr.asn1.dsql.DSqlRow;
import cdr.asn1.dsql.DSqlRows;
import cdr.asn1.dsql.DSqlTable;


public class CheckMmi {

	private JoltSession m_joltSession = null;
	private static final String TestApplicationAddress = "//tltst01:41210";
	private JoltRemoteService m_joltService = null;
	private DSqlTable   m_responseDSqlTable;
	
	private DSqlTable m_requestDSqlTable = null;
	
	private static final String	SQL_STATEMENT = 
			"SELECT unit_number  FROM mmi_id"
				+ " WHERE unit_number = :X0"
				;
	
	public static void main(String[] args) {
		// Testing check MMI
		try {
		System.out.println("CheckMMI!");
		CheckMmi cm = new CheckMmi(TestApplicationAddress);
		cm.MMiexists("541046498");
		cm.MMiexists("567127283");
		cm.MMiexists("403329198");
		cm.CloseSession();
		} catch (Exception ex)
		{
		  System.err.println("Exception :" + ex.getMessage());
		}
	}

public CheckMmi(String applicationAddress)
{
	JoltSessionAttributes sessionAttributes = new JoltSessionAttributes();
	sessionAttributes.setString(JoltSessionAttributes.APPADDRESS,
			applicationAddress);

	m_joltSession = new JoltSession(sessionAttributes, "ITF", "", "", null);

	m_joltService = new JoltRemoteService("DSQL",
			this.m_joltSession);
	
	 m_requestDSqlTable  = new DSqlTable();
	 Coded MAGIC_SQL_NCID   = new Coded( BigInteger.valueOf( 1450582 ) );
		
	 m_requestDSqlTable.setSqlId( MAGIC_SQL_NCID );
	
	 DSqlArguments argumentList = new DSqlArguments();
     argumentList.add( 0, (Object) ( new VisibleString( SQL_STATEMENT )) );
     argumentList.add( 1, new VisibleString("") );
     
     m_requestDSqlTable.setArgumentsList( argumentList );
}

public void CloseSession()
{
     m_joltService.done();
     m_joltSession.endSession();
     
}

	public Boolean MMiexists(String mmiNum) throws Exception
	{
		 m_responseDSqlTable = null;
		 
		Boolean retVal = false;             
        m_requestDSqlTable.getArgumentsList().set(1, new VisibleString(mmiNum) );
        
		byte[] encodedASN1Request = this.dsqlEncode();
			
		m_joltService.setBytes("CARRAY", encodedASN1Request,
				encodedASN1Request.length);
		m_joltService.call(null);
		byte[] encodedASN1Response = m_joltService.getBytesDef("CARRAY", null);

		m_responseDSqlTable = (DSqlTable) dsqlDecode(encodedASN1Response);

		DSqlRows    tmpRows     = m_responseDSqlTable.getRowsList();
		System.out.println("# rows: " + tmpRows.size());
        for (int rowNum= 0; rowNum < tmpRows.size() ; rowNum++) {
            DSqlColumns tmpColumns  = ((DSqlRow)tmpRows.get(rowNum)).getColumnsList();
            for (int columnNum =0; columnNum < tmpColumns.size(); columnNum++ ) {
                String sResult = ((DSqlColumn)tmpColumns.get( columnNum )).getValue().getTextString();
                System.out.println("Val:" + sResult + "; MMi match: " + sResult.equals(mmiNum));
                retVal = true;
            }
        }
			
		return retVal;
	}


	 protected byte[] dsqlEncode() throws Exception
	            
	    {
		 BaseEncoder dsqlTransEncoder = new BaseEncoder(new ByteArrayOutputStream());

	        byte[] encodedASN1Request = null;

	        try {
	            dsqlTransEncoder.encodeObject(m_requestDSqlTable);

	            encodedASN1Request = ((ByteArrayOutputStream) dsqlTransEncoder.getOutputStream()).toByteArray();
	        } catch (EncodingException encEx) {
	           
	           throw encEx;
	        } finally {
	            
	        }

	   
	        return encodedASN1Request;
	    }
	 

	 protected Object dsqlDecode( byte[] encodedASN1Response ) throws Exception
	           
	    {
	       Object  responseDSqlTable = null;
	       
	        try {
	           

	            BaseDecoder asn1Decoder = new BaseDecoder( new ByteArrayInputStream(encodedASN1Response) );
	            responseDSqlTable = (DSqlTable)asn1Decoder.decodeObject(DSqlTable.class);
	        } catch (DecodingException decodeEx) {
	            throw decodeEx;
	           
	        }

	    
	        return responseDSqlTable;
	    }
	 
}
