package org.ihc.itf.crypto;

import java.io.File;
import java.io.FileOutputStream;

public class IHCCrypto {


	
	public static void EncryptFile(String inputDirectory, String inputFileName,
			String outputDir, String outputFile,
			String strIHCPublicKeyRingFile,  String strIHCSecretKeyRingFile,
			String strPublicKeyName, String strPassPhrase) throws Exception
	{
		FileOutputStream fos;
		// encrypt the file
		fos = new FileOutputStream(inputDirectory
				+ inputFileName + "." + "encrypt");
		IHCPublicKeyRing pubKeyRing = new IHCPublicKeyRing(
				strIHCPublicKeyRingFile);

		IHCSecretKeyRing secKeyRing = new IHCSecretKeyRing(
				strIHCSecretKeyRingFile);

		IHCEncrypter encrypter = new IHCEncrypter(
				pubKeyRing.getPublicEncryptionKeyByName(strPublicKeyName),
				secKeyRing.getSecretEncryptionKeyByName(""), strPassPhrase);

		encrypter.setOutputStream(fos);
		// check to see if remote file exists
		File file = new File(inputDirectory + inputFileName);

		if (file.exists()) {
			encrypter.setInputStream(file);
			encrypter.encrypt(outputDir + outputFile);
		}

	}

	
	
	public static void DecryptFile(String inputDirectory, String inputFileName,
			String outputDir, String outputFile,
			String strIHCPublicKeyRingFile,  String strIHCSecretKeyRingFile,
			String secretKeyRingPwd) throws Exception {

		IHCPublicKeyRing pubKeyRing = new IHCPublicKeyRing(
				strIHCPublicKeyRingFile);

		IHCSecretKeyRing secKeyRing = new IHCSecretKeyRing(
				strIHCSecretKeyRingFile);
		IHCDecrypter decrypter = new IHCDecrypter(pubKeyRing, secKeyRing,
				secretKeyRingPwd);
		File decreptedFile = new File(inputDirectory + inputFileName);
		File fot = new File(outputDir + outputFile);

		decrypter.decrypt(decreptedFile, fot);
	}
	
	

}
