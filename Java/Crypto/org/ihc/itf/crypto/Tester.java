package org.ihc.itf.crypto;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;

public class Tester {
	

	private void testEncryptFile() throws Exception {
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strInpDirectory = "c:\\Temp\\";
		String strInpFileName = "IHCEncTest.txt";
		String strOutDirectory = "c:\\Temp\\";
		String strOutFileName = "IHCEncTest.txt.encrypt";
		String strPublicKeyName = "KeyBank PGP <steven_j_wood@keybank>";
		String strPassPhrase = "Rick";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		
		IHCCrypto.EncryptFile( strInpDirectory,  strInpFileName,
				 strOutDirectory,  strOutFileName,
				 strIHCPublicKeyRingFile,  strIHCSecretKeyRingFile,
				 strPublicKeyName, strPassPhrase);
	}
	
	private void testEncryptFileStream() throws Exception {
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strInpDirectory = "c:\\Temp\\";
		String strInpFileName = "IHCEncTest.txt";
		String strOutDirectory = "c:\\Temp\\";
		String strOutFileName = "IHCEncTest.txt.encrypt";
		String strPublicKeyName = "KeyBank PGP <steven_j_wood@keybank>";
		String strPassPhrase = "Rick";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		FileOutputStream fos = new FileOutputStream(strOutDirectory +  strOutFileName);
		FileInputStream fin = new FileInputStream(strInpDirectory +  strInpFileName);
		
		IHCCrypto.EncryptFileStream(fin, fos,
				 strIHCPublicKeyRingFile,  strIHCSecretKeyRingFile,
				 strPublicKeyName, strPassPhrase);
	}
	
	private void testEncryptByteStream(byte[] buf) throws Exception {
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
	
		String strPublicKeyName = "KeyBank PGP <steven_j_wood@keybank>";
		String strPassPhrase = "Rick";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		 ByteArrayOutputStream encOut = new ByteArrayOutputStream();
		 
		ByteArrayInputStream bIn = new ByteArrayInputStream(buf);
		
		IHCCrypto.EncryptByteStream(bIn, encOut,
				 strIHCPublicKeyRingFile,  strIHCSecretKeyRingFile,
				 strPublicKeyName, strPassPhrase);
		IHCCryptoUtils.printOut( "Output: " + new String( encOut.toByteArray()));
	}
	
	private void testProviderEft_Sh_IN() throws Exception {

		String secretKeyRingPwd = "dguser@ihc.com(default process id)";
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		
		String strEncryptedDir = "C:\\Temp\\";
		String strEncryptedFileName = "DecryptText.txt";
		String strDecryptedDir = "c:\\Temp\\";
		String strDecryptedFileName = "ProviderEft_Sh_IN.encrypt09302014115255";
		IHCCrypto.DecryptFile(strDecryptedDir, strDecryptedFileName, strEncryptedDir, strEncryptedFileName,
				strIHCPublicKeyRingFile,   strIHCSecretKeyRingFile,
				 secretKeyRingPwd);
	}
	
	private void testProviderEft_Sh_IN_Stream() throws Exception {

		String secretKeyRingPwd = "dguser@ihc.com(default process id)";
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		
		String strEncryptedDir = "C:\\Temp\\";
		String strEncryptedFileName = "DecryptText.txt";
		String strDecryptedDir = "c:\\Temp\\";
		String strDecryptedFileName = "ProviderEft_Sh_IN.encrypt09302014115255";
		
		FileInputStream streamIn = new FileInputStream(strDecryptedDir + strDecryptedFileName);
		FileOutputStream streamOut = new FileOutputStream(strEncryptedDir + strEncryptedFileName);
		
		IHCCrypto.DecryptFileStream(streamIn, streamOut,
				strIHCPublicKeyRingFile,   strIHCSecretKeyRingFile,
				 secretKeyRingPwd);
	}
	
	private void Enroll_MedicareSecondaryPayer() throws Exception {

		String secretKeyRingPwd = "shuserhpv-appmcs01";
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		
		String strEncryptedDir = "C:\\Temp\\";
		String strEncryptedFileName = "Enroll_MedicareSecondaryPayerDecryptText.txt";
		String strDecryptedDir = "c:\\Temp\\";
		String strDecryptedFileName = "Enroll_MedicareSecondaryPayerQueryOnly_IN_SCHED.encrypt20150407231623962";
		
		FileInputStream streamIn = new FileInputStream(strDecryptedDir + strDecryptedFileName);
		FileOutputStream streamOut = new FileOutputStream(strEncryptedDir + strEncryptedFileName);
		
		IHCCrypto.DecryptFileStream(streamIn, streamOut,
				strIHCPublicKeyRingFile,   strIHCSecretKeyRingFile,
				 secretKeyRingPwd);
	}
	

	
	private void testProviderEft_Sh_IN_ByteStream() throws Exception {

		String secretKeyRingPwd = "dguser@ihc.com(default process id)";
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		
		String strEncryptedDir = "C:\\Temp\\";
		String strEncryptedFileName = "DecryptText.txt";
		String strDecryptedDir = "c:\\Temp\\";
		String strDecryptedFileName = "ProviderEft_Sh_IN.encrypt09302014115255";
		
		FileInputStream streamIn = new FileInputStream(strDecryptedDir + strDecryptedFileName);
		
		 
		System.out.println("Total file size to read (in bytes) : "	+ streamIn.available());

		byte []buffer = new byte[(int) streamIn.getChannel().size()];
		
		 if ( streamIn.read(buffer) == -1 ) {
	            throw new Exception("EOF reached while trying to read the whole file");
	        }  
		 ByteArrayInputStream is = new ByteArrayInputStream(buffer);
		 
		 ByteArrayOutputStream out = new ByteArrayOutputStream();
		 
		IHCCrypto.DecryptByteStream(is, out,
				strIHCPublicKeyRingFile,   strIHCSecretKeyRingFile,
				 secretKeyRingPwd);
		System.out.println("Output length: " + out.size() + "\n" + out.toString());
	}
	
	private void test_PositivePayToKeyBank() throws Exception
	{
		
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
	
		IHCCrypto.DecryptFile("C:\\Temp\\", "Reconciliation_KeyBank_IN_Sh_OUT_Decrypt-20140930.log",
				"C:\\Temp\\", "PositivePay_Sh_IN_KeyBank_OUT_Encrypt.txt",
				strIHCPublicKeyRingFile,   strIHCSecretKeyRingFile, "IHC-PGP-Encp-Data");
		
	}
	
	private void test_PositivePayToKeyBankStream() throws Exception
	{
		
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
		
		FileInputStream streamIn = new FileInputStream("C:\\Temp\\Reconciliation_KeyBank_IN_Sh_OUT_Decrypt-20140930.log");
		FileOutputStream	streamOut = new FileOutputStream("C:\\Temp\\PositivePay_Sh_IN_KeyBank_OUT_Encrypt.txt");
		
		IHCCrypto.DecryptFileStream(streamIn, streamOut,
				strIHCPublicKeyRingFile,   strIHCSecretKeyRingFile, "IHC-PGP-Encp-Data");
		System.out.println(streamOut.getChannel().size());
	}
	
	public static void main(String[] args) {
		Tester tst = new Tester();
		try {
			byte[] original = "Hello world test ITF team".getBytes();
			IHCCryptoUtils.setDebugSet(true);
			
			// tst.testEncryptFile();
			// tst.testEncryptByteStream(original);
			
			 // tst.testProviderEft_Sh_IN();
			// tst.testProviderEft_Sh_IN_Stream();
			// tst.testProviderEft_Sh_IN_ByteStream();
			
			// tst.test_PositivePayToKeyBank();
			// tst.test_PositivePayToKeyBankStream();
			
			tst.Enroll_MedicareSecondaryPayer();
			
			
		} catch (Exception e) {
			
			e.printStackTrace();
		}
	}
	
}
