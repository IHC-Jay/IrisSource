 package edifecs;
import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.SQLException;
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
	    printWriter.print("TP partners");

            Class.forName("oracle.jdbc.OracleDriver");
 
            String dbURL2 = "jdbc:oracle:thin:@ldap://oracleldapvip.co.ihc.com:389/cn=OracleContext,dc=co,dc=ihc,dc=com/ediprd_itf_sh";
            String username = "EcEnablement_sh";
            String password = "manager";
            con = DriverManager.getConnection(dbURL2, username, password);
            if (con != null) {
                System.out.println("Connected with connection #2");
		String query = "select p.name as name,b.name as type, DECODE( nvl(p.primaryemail,''), '', '-', p.primaryemail) as email, DECODE(nvl(p.primarytelephonenumber,''), '', '-', p.primarytelephonenumber ) as tele from ECENABLEMENT_SH.BIZROLEDEF b, ECENABLEMENT_SH.PARTY  p where p.BIZROLEDEFSID = b.bizroledefsid";
    		Statement stmt = con.createStatement();
      		ResultSet rs = stmt.executeQuery(query);
      		while (rs.next()) {
        		String pName = rs.getString("name");
        		String type = rs.getString("type");
        		String tele = rs.getString("tele");
        		String em = rs.getString("email");
        		System.out.println(pName + ", " + type);
    			printWriter.printf(pName + "~! " + type + "~! " + tele + "~! " + em + "\n");
      		}
		rs.close();
		printWriter.close();
		fileWriter.close();

                fileWriter = new FileWriter(direc + "/TpIds.txt");
    	        printWriter = new PrintWriter(fileWriter);

		query = "select  ind.identifiersid, ind.value as TPID, DECODE(nvl(ref.name, 'X12Identifier'), 'X12Identifier', 'BOTH', 'X12Identifier-GS','GS') as Type, p.name from identifier ind, PARTY  p, identifierdef ref where ind.partysid = p.partysid and ind.value is not null and ind.identifierdefsid = ref.identifierdefsid order by p.name";
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

		query = "SELECT  rsh.TRADERELATIONSHIPSID, REPLACE(rsh.Name ||'-' || pt1.name ||'-' || pt2.name, ' ', '_') as lnkName, pt1.partysid as sender,   pt2.partysid as receiver, regexp_replace(trn.NAME, 'OutRT|OutB|InRT|InB', '') as TPMTRANSACTIONSID, ag.Name ||'-'|| bz.caption ||'-'|| fmt.name ||'-'|| pm.name as longNm, ar.RESOLVEDCONFIGURATIONXML as xml, pm.name as rtbt FROM traderelationship rsh, TPMTRANSACTION trn, agreement ag, BIZDOCUMENTDEF bz, FORMAT fmt, PROCESSINGMODE pm, APPLICATIONRESOLUTION ar, party pt1, party pt2, agreementversion av where rsh.tpmtransactionsid = trn.tpmtransactionsid and rsh.isactive = 1 and ar.isvalid = 1 and ag.tpmtransactionsid = trn.tpmtransactionsid and ag.Name like 'IMH%' and ag.Name not like '%Catch%' and ag.Name not like '%Test%' and ag.Name not like '%Custom%' and bz.BIZDOCUMENTDEFSID = trn.BIZDOCUMENTDEFSID and fmt.formatsid = trn.FORMATSID and pm.processingmodesid = trn.processingmodesid and ar.traderelationshipsid = rsh.traderelationshipsid and pt1.partysid = rsh.SENDERPARTYSID and pt2.partysid = rsh.receiverpartysid and ar.agreementversionsid = av.agreementversionsid and ar.applicationresolutionsid  = (select MAX(applicationresolutionsid) from APPLICATIONRESOLUTION ar2 where ar2.traderelationshipsid = rsh.traderelationshipsid) order by rsh.TRADERELATIONSHIPSID";

    		stmt = con.createStatement();
      		rs = stmt.executeQuery(query);
      		while (rs.next()) {
        		String traderelationship = rs.getString("TRADERELATIONSHIPSID");
        		String name = rs.getString("lnkName");
        		String sender = rs.getString("sender");
        		String receiver = rs.getString("receiver");
        		String sid = rs.getString("TPMTRANSACTIONSID");
        		String lNm = rs.getString("longNm");
        		String xmlStr = rs.getString("xml");
        		String mode = rs.getString("rtbt");
        		System.out.println(traderelationship + ", " + name);
    			printWriter.printf(traderelationship + "~! " + name + "~! " + sender + "~! " + receiver + "~! " + sid +"~! " + lNm + "~! " +xmlStr + "~! " +mode + "\n");
      		}
		rs.close();
		printWriter.close();
		fileWriter.close();

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
