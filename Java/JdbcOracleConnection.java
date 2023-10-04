 package edifecs;
import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.UnknownFormatConversionException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.Properties;
 
/**
 * This program demonstrates how to make database connection with Oracle
 * database server.
 * @author www.codejava.net
 *
 */
public class JdbcOracleConnection {
 
    public static void main(String[] args) {
 
        Connection con = null;
        String direc = null;
	PrintWriter printWriter = null;

	if (args.length > 0) {
                direc = args[0];
        }
        else
        {
                System.out.println("Filename is expected as parameter");
                System.exit(1);
        }

 
        try {
            FileWriter fileWriter = new FileWriter(direc + "/TradingPartners.txt");
    	    printWriter = new PrintWriter(fileWriter);
	    // printWriter.print("TP partners");

            Class.forName("oracle.jdbc.OracleDriver");
 
            String dbURL2 = "jdbc:oracle:thin:@ldap://oracleldapvip.co.ihc.com:389/cn=OracleContext,dc=co,dc=ihc,dc=com/ediprd_itf_sh";
            String username = "EcEnablement_sh";
            String password = "manager";
            con = DriverManager.getConnection(dbURL2, username, password);
            if (con != null) {
                System.out.println("Connected with connection #2");
		String query = "select p.partysid, p.name as name,b.name as type, DECODE( nvl(p.primaryemail,''), '', '-', p.primaryemail) as email, DECODE(nvl(p.primarytelephonenumber,''), '', '-', p.primarytelephonenumber ) as tele, cs.organizationcustomfieldsid as cid, CustomTextField1	as 	OutConn_270RT_Acks, CustomTextField10	as 	OutConn_820_Acks, CustomTextField11	as 	ElementSeparator, CustomTextField12	as 	ISACompElementSeparator, CustomTextField13	as 	OutConn_271RT, CustomTextField14	as 	OutConn_837D_Acks, CustomTextField15	as 	OutConn_278_Acks, CustomTextField16	as 	OutConn_276RT_Acks, CustomTextField17	as 	OutConn_277RT, CustomTextField18	as 	OutConn_271B, CustomTextField19	as 	OutConn_837P_Acks, CustomTextField2	as 	AckUsage999_RT, CustomTextField20	as 	OutConn_270B_Acks, CustomTextField21	as 	OutConn_835, CustomTextField22	as 	OutConn_277CA, CustomTextField23	as 	OutConn_837I_Acks, CustomTextField24	as 	AckUsage999, CustomTextField25	as 	OutConn_277B, CustomTextField26	as 	AckUsageTA1, CustomTextField27	as 	AckUsageTA1_RT, CustomTextField28	as 	OutConn_276B_Acks, CustomTextField29	as 	BatchingMode835 from ECENABLEMENT_SH.BIZROLEDEF b, ECENABLEMENT_SH.PARTY p, ecuorganizationcustomfields cs where p.BIZROLEDEFSID = b.bizroledefsid and cs.organizationcustomfieldsid = p.customfieldsid ";
    		Statement stmt = con.createStatement();
      		ResultSet rs = stmt.executeQuery(query);
      		while (rs.next()) {
        		String id = rs.getString("partysid");
        		String pName = rs.getString("name");
        		String type = rs.getString("type");
        		String tele = rs.getString("tele");
        		String em = rs.getString("email");
        		System.out.println(pName + ", " + type);
    			printWriter.printf(id + "~! " + pName + "~! " + type + "~! " + tele + "~! " + em );
    			printWriter.printf("~! " + rs.getString("cid"));
printWriter.printf("~! "+ rs.getString("OutConn_270RT_Acks"));
printWriter.printf("~! "+ rs.getString("OutConn_820_Acks"));
printWriter.printf("~! "+ rs.getString("ElementSeparator"));
printWriter.printf("~! "+ rs.getString("ISACompElementSeparator"));
printWriter.printf("~! "+ rs.getString("OutConn_271RT"));
printWriter.printf("~! "+ rs.getString("OutConn_837D_Acks"));
printWriter.printf("~! "+ rs.getString("OutConn_278_Acks"));
printWriter.printf("~! "+ rs.getString("OutConn_276RT_Acks"));
printWriter.printf("~! "+ rs.getString("OutConn_277RT"));
printWriter.printf("~! "+ rs.getString("OutConn_271B"));
printWriter.printf("~! "+ rs.getString("OutConn_837P_Acks"));
printWriter.printf("~! "+ rs.getString("AckUsage999_RT"));
printWriter.printf("~! "+ rs.getString("OutConn_270B_Acks"));
printWriter.printf("~! "+ rs.getString("OutConn_835"));
printWriter.printf("~! "+ rs.getString("OutConn_277CA"));
printWriter.printf("~! "+ rs.getString("OutConn_837I_Acks"));
printWriter.printf("~! "+ rs.getString("AckUsage999"));
printWriter.printf("~! "+ rs.getString("OutConn_277B"));
printWriter.printf("~! "+ rs.getString("AckUsageTA1"));
printWriter.printf("~! "+ rs.getString("AckUsageTA1_RT"));
printWriter.printf("~! "+ rs.getString("OutConn_276B_Acks"));
printWriter.printf("~! "+ rs.getString("BatchingMode835") + "\n");
      		}
		rs.close();
		printWriter.close();
		fileWriter.close();

                fileWriter = new FileWriter(direc + "/TpIds.txt");
    	        printWriter = new PrintWriter(fileWriter);

		query = "select  ind.identifiersid, ind.value as TPID, DECODE(nvl(ind.comments, 'X12Identifier'), 'X12Identifier', 'BOTH', 'X12Identifier-GS','GS') as Type, p.name from identifier ind, PARTY  p, identifierdef ref where ind.partysid = p.partysid and ind.value is not null and ind.identifierdefsid = ref.identifierdefsid order by p.name";
    		stmt = con.createStatement();
      		rs = stmt.executeQuery(query);
      		while (rs.next()) {
        		String pName = rs.getString("name");
        		String type = rs.getString("type");
        		String sid = rs.getString("identifiersid");
        		String tpId = rs.getString("tpid");
        		System.out.println(pName + ", " + type);
    			printWriter.printf(sid + "~! " + tpId + "~! " + pName + "~! " + type + "\n");
      		}
		rs.close();
		printWriter.close();
		fileWriter.close();

                fileWriter = new FileWriter(direc + "/TRANSACTIONTYPES.txt");
    	        printWriter = new PrintWriter(fileWriter);

		query = "SELECT distinct regexp_replace(trn.NAME, 'OutRT|OutB|InRT|InB', '')  as NAME , dir.caption as Direction, trn.CODE as TransactionSetId, trn.version, replace(regexp_replace(trn.description, 'Batch|Real Time',''), '- ','') as DESCRIPTION FROM traderelationship rsh, TPMTRANSACTION trn, agreement ag, BIZDOCUMENTDEF bz,  entransactiondirection dir where rsh.tpmtransactionsid = trn.tpmtransactionsid and ag.tpmtransactionsid = trn.tpmtransactionsid and ag.Name like 'IMH%' and ag.Name not like '%Catch%' and ag.Name not like '%Test%' and ag.Name not like '%Custom%' and bz.BIZDOCUMENTDEFSID = trn.BIZDOCUMENTDEFSID and dir.enumid = TRANSACTIONDIRECTIONID order by  trn.CODE";

    		stmt = con.createStatement();
      		rs = stmt.executeQuery(query);
      		while (rs.next()) {
        		String tName = rs.getString("name");
        		String direction = rs.getString("Direction");
        		String tId = rs.getString("TransactionSetId");
        		String ver = rs.getString("version");
        		String desc = rs.getString("description");
        		System.out.println(tName + ", " + tId);
    			printWriter.printf(tName + "~! " + direction + "~! " + tId + "~! " + ver + "~! " + desc + "\n");
      		}
		rs.close();
		printWriter.close();
		fileWriter.close();

                fileWriter = new FileWriter(direc + "/TpLinks.txt");
    	        printWriter = new PrintWriter(fileWriter);

		query = "SELECT  rsh.TRADERELATIONSHIPSID, REPLACE(rsh.Name ||'-' || pt1.name ||'-' || pt2.name, ' ', '_') as lnkName, pt1.partysid as sender,   pt2.partysid as receiver, regexp_replace(trn.NAME, 'OutRT|OutB|InRT|InB', '') as TPMTRANSACTIONSID, ag.Name ||'-'|| bz.caption ||'-'|| fmt.name ||'-'|| pm.name as longNm, ar.RESOLVEDCONFIGURATIONXML as rcXml, pm.name as rtbt , nvl(apcn.CONFIGURATIONXML, '-') as cXml, CUSFLD1.organizationcustomfieldsid as SENDERcf, CUSFLD2.organizationcustomfieldsid as Receivercf FROM traderelationship rsh, TPMTRANSACTION trn, agreement ag, BIZDOCUMENTDEF bz, FORMAT fmt, PROCESSINGMODE pm, APPLICATIONRESOLUTION ar, party pt1, party pt2, agreementversion av, APPLICATIONCONFIGURATION apcn, ECUORGANIZATIONCUSTOMFIELDS CUSFLD1, ECUORGANIZATIONCUSTOMFIELDS CUSFLD2 where rsh.tpmtransactionsid = trn.tpmtransactionsid and rsh.isactive = 1 and ar.isvalid = 1 and ag.tpmtransactionsid = trn.tpmtransactionsid and ag.Name like 'IMH%' and ag.Name not like '%Catch%' and ag.Name not like '%Test%' and ag.Name not like '%Custom%' and bz.BIZDOCUMENTDEFSID = trn.BIZDOCUMENTDEFSID and fmt.formatsid = trn.FORMATSID and pm.processingmodesid = trn.processingmodesid and ar.traderelationshipsid = rsh.traderelationshipsid and pt1.partysid = rsh.SENDERPARTYSID and pt2.partysid = rsh.receiverpartysid and ar.agreementversionsid = av.agreementversionsid and ar.applicationresolutionsid  = (select MAX(applicationresolutionsid) from APPLICATIONRESOLUTION ar2 where ar2.traderelationshipsid = rsh.traderelationshipsid)  and apcn.agreementversionsid = ar.agreementversionsid AND CUSFLD1.organizationcustomfieldsid = PT1.customfieldsid AND CUSFLD2.organizationcustomfieldsid = PT2.customfieldsid order by rsh.TRADERELATIONSHIPSID";

    		stmt = con.createStatement();
      		rs = stmt.executeQuery(query);
        		String cfgXml = "";
        		String traderelationship = "";
      		while (rs.next()) {
			try {
        		traderelationship = rs.getString("TRADERELATIONSHIPSID");
        		String name = rs.getString("lnkName");
        		String sender = rs.getString("sender");
        		String receiver = rs.getString("receiver");
        		String sid = rs.getString("TPMTRANSACTIONSID");
        		String lNm = rs.getString("longNm");
        		String xmlStr = rs.getString("rcXml");
        		String mode = rs.getString("rtbt");
        		cfgXml = rs.getString("cXml");
        		String ccf = rs.getString("SENDERcf");
        		String rcf = rs.getString("Receivercf");
        		System.out.println(traderelationship + ", " + name);
    			// printWriter.printf(traderelationship + "~! " + name + "~! " + sender + "~! " + receiver + "~! " + sid +"~! " + lNm + "~! " +xmlStr + "~! " +mode + "~! ");  
    			printWriter.printf(traderelationship + "~! " + name + "~! " + sender + "~! " + receiver + "~! " + sid +"~! " + lNm + "~! " +mode + "~! " + ccf   + "~! " + rcf  + "~! " );  
			printWriter.printf("RESOLVEDCONFIGURATIONXML:%s", xmlStr);
			printWriter.printf("APPLICATIONCONFIGURATION:%s", cfgXml);
    			printWriter.printf("\n");
        		} catch (UnknownFormatConversionException ex) {
            			ex.printStackTrace();
				 System.out.println(" -- Exception: " + traderelationship + ", " + cfgXml);
			}
//  "~! " + ccf + "~! " +  rcf + "\n");
      		}
		rs.close();
		printWriter.close();
		fileWriter.close();
 		String cleanCmd = "sed 's/\"//g' " + direc + "TpLinks.txt |  sed 's/&quot;//g' | grep -E \"ID.X12Identifier|ReceiverID|SenderID|ApplicationSettings\" > tpLinks-IRIS.txt";

		stmt.close();
		System.exit(0);
	    }

        } catch (ClassNotFoundException ex) {
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
	}
        catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            try {
                if (con != null && !con.isClosed()) {
                    con.close();
                }
    		printWriter.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
}
