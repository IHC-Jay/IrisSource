using System;
using System.Data;

public class OracleDataRetriever
{
    public static void GetDataFromOracle()
    {
        // Define your connection string
        string connectionString = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=lp-itforatst01.co.ihc.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=ediqa02.co.ihc.com)));User ID=gbdrepo_sh;Password=manager;Connection Timeout=60";
        
        // string connectionString = "DATA SOURCE=jdbc:oracle:thin:@ldap://oracleldapvip.co.ihc.com:389/cn=OracleContext,dc=co,dc=ihc,dc=com/ediprd_itf_sh;User Id=gbdrepo_sh;Password=manager;";
         

        //oracleldapvip.co.ihc.com:389/cn=OracleContext,dc=co,dc=ihc,dc=com/ediprd_itf_sh;USER ID=gbdrepo_sh;PASSWORD=manager;";
        // "Data Source=(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = oracleldapvip.co.ihc.com)(PORT = 389))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = orcl)));UID=gbdrepo_sh;PWD=manager";
        // "Data Source=jdbc:oracle:thin:@ldap://oracleldapvip.co.ihc.com:389/cn=OracleContext,dc=co,dc=ihc,dc=com/ediprd_itf_sh;User Id=gbdrepo_sh;Password=manager;"; // Example
        // Consider using a connection string builder for more complex scenarios
        Console.WriteLine("Connect to " + connectionString);

    }
}
