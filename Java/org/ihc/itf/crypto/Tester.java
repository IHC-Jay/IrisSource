package org.ihc.itf.crypto;

public class Tester {
	

	private void testEncrypt() throws Exception {
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
	
	private void test_PositivePayToKeyBank() throws Exception
	{
		
		String strIHCPublicKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/pubring.gpg";
		String strIHCSecretKeyRingFile = "C:\\Users\\lpjnaras\\Documents\\bouncyCastle/secring.gpg";
	
		IHCCrypto.DecryptFile("C:\\Temp\\", "Reconciliation_KeyBank_IN_Sh_OUT_Decrypt-20140930.log",
				"C:\\Temp\\", "PositivePay_Sh_IN_KeyBank_OUT_Encrypt.txt",
				strIHCPublicKeyRingFile,   strIHCSecretKeyRingFile, "IHC-PGP-Encp-Data");
	}
	
	
	public static void main(String[] args) {
		Tester tst = new Tester();
		try {
			IHCCryptoUtils.setDebugSet(true);
			// tst.testEncrypt();
			tst.testProviderEft_Sh_IN();
			// tst.test_PositivePayToKeyBank();
		} catch (Exception e) {
			
			e.printStackTrace();
		}
	}
	
}
