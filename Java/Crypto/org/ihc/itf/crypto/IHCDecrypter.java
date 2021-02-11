package org.ihc.itf.crypto;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.util.Iterator;

import org.bouncycastle.bcpg.BCPGInputStream;
import org.bouncycastle.openpgp.PGPCompressedData;
import org.bouncycastle.openpgp.PGPEncryptedData;
import org.bouncycastle.openpgp.PGPEncryptedDataList;
import org.bouncycastle.openpgp.PGPException;
import org.bouncycastle.openpgp.PGPKeyFlags;
import org.bouncycastle.openpgp.PGPKeyPair;
import org.bouncycastle.openpgp.PGPLiteralData;
import org.bouncycastle.openpgp.PGPMarker;
import org.bouncycastle.openpgp.PGPObjectFactory;
import org.bouncycastle.openpgp.PGPOnePassSignature;
import org.bouncycastle.openpgp.PGPOnePassSignatureList;
import org.bouncycastle.openpgp.PGPPBEEncryptedData;
import org.bouncycastle.openpgp.PGPPrivateKey;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPPublicKeyEncryptedData;
import org.bouncycastle.openpgp.PGPSecretKey;
import org.bouncycastle.openpgp.PGPSignature;
import org.bouncycastle.openpgp.PGPSignatureList;
import org.bouncycastle.openpgp.PGPSignatureSubpacketVector;
import org.bouncycastle.openpgp.PGPUserAttributeSubpacketVector;
import org.bouncycastle.openpgp.PGPUtil;
import org.bouncycastle.openpgp.bc.BcPGPObjectFactory;
import org.bouncycastle.openpgp.operator.PBESecretKeyDecryptor;
import org.bouncycastle.openpgp.operator.bc.BcPBESecretKeyDecryptorBuilder;
import org.bouncycastle.openpgp.operator.bc.BcPGPContentVerifierBuilderProvider;
import org.bouncycastle.openpgp.operator.bc.BcPGPDigestCalculatorProvider;
import org.bouncycastle.openpgp.operator.bc.BcPublicKeyDataDecryptorFactory;

public class IHCDecrypter {
	private final String strProvider = "BC";

	private IHCPublicKeyRing publicKeyRing = null;

	private IHCSecretKeyRing secretKeyRing = null;

	private char[] cArrayPass = null;

	public IHCDecrypter(IHCPublicKeyRing pPublicKeyRing,
			IHCSecretKeyRing pSecretKeyRing, String pStrPassword) {

		if (pPublicKeyRing != null) {
			this.publicKeyRing = pPublicKeyRing;
		}
		if (pSecretKeyRing != null) {
			this.secretKeyRing = pSecretKeyRing;
		}
		if (pStrPassword != null) {
			this.cArrayPass = pStrPassword.toCharArray();
		}

	}
	

	public void decrypt(File inFile, File outFile)
			throws FileNotFoundException, IOException, Exception {

		FileInputStream streamIn = null;
		FileOutputStream streamOut = null;

		try {
			streamIn = new FileInputStream(inFile);
			streamOut = new FileOutputStream(outFile);

			String message = "Encrypted file is: " + inFile.getName();
			message = message + "\nDecrypted file is: " + outFile.getName();
			message = message + "\nNow calling decrypt(InputStream, OutputStream)";

			IHCCryptoUtils.printOut(message);

			this.decrypt(streamIn, streamOut);

		} catch (FileNotFoundException fnfEx) {
			System.err.println("Received file not found exception: " + fnfEx);
			throw fnfEx;
		} finally {
			streamOut.close();
			streamIn.close();

		}
	}

	public void decrypt(File inFile, OutputStream streamOut)
			throws FileNotFoundException, IOException, Exception {

		try {
			FileInputStream streamIn = new FileInputStream(inFile);

			String message = "Encrypted file is: " + inFile.getName();
			message = message
					+ "\nDecrypted data will be returned as outStream";
			message = message
					+ "\nNow calling decrypt(InputStream, OutputStream)";

			IHCCryptoUtils.printOut(message);

			this.decrypt(streamIn, streamOut);

			streamOut.close();
			streamIn.close();

			IHCCryptoUtils.printOut("Both streams closed successfully");

		} catch (FileNotFoundException fnfEx) {
			System.err.println("Received file not found exception: " + fnfEx);
			throw fnfEx;
		} catch (IOException ioEx) {
			System.err.println("Received io exception: " + ioEx);
			throw ioEx;
		}
	}

	public void decrypt(InputStream streamIn, OutputStream streamOut)
			throws Exception {

		try {
			streamIn = new BufferedInputStream(streamIn);
			
			if (isStreamArmored(streamIn)) {
				streamIn = new WhiteSpaceFilterInputStream(streamIn);
			}
			InputStream streamDecoder = PGPUtil.getDecoderStream(streamIn);
			
			

			try {

				// Create a decoder stream (to decrypt the data)?
				BcPGPObjectFactory outerPgpFactory = new BcPGPObjectFactory(new BCPGInputStream(streamDecoder));

				// Get the encrypted data packet list.
				// This gets into a list all publicly AND all symmetrically
				// encrypted packets
				// and labels them appropriately for later processing.
				PGPEncryptedDataList encryptedDataList = null;
				Object o = outerPgpFactory.nextObject();
			
				printObjType(o);
				/*
				 * Request for Comment (rfc) 2441 which defines open PGP
				 * standards says to ignore any marker packet...the if below
				 * checks for a marker packet
				 */
				if (o instanceof PGPEncryptedDataList) {
					encryptedDataList = (PGPEncryptedDataList) o;
				} else if (o instanceof  PGPCompressedData) {
		            PGPCompressedData cData = (PGPCompressedData) o;
		            BcPGPObjectFactory pgpFact = new BcPGPObjectFactory(cData.getDataStream());

		            encryptedDataList = (PGPEncryptedDataList) pgpFact.nextObject();
		        }
				else {
					encryptedDataList = (PGPEncryptedDataList) outerPgpFactory.nextObject();
				}
		      
				
				if (encryptedDataList == null)
				{
					String message = "Create BCPGInputStream because encryptedDataList is null";
					IHCCryptoUtils.printOut(message);
					BCPGInputStream pgInStr = new BCPGInputStream(streamIn);

					encryptedDataList = new PGPEncryptedDataList(pgInStr);
				}
				

				/*
				 * find the secret key from the key ID of the public key that
				 * was used to encrypt the data.
				 */
				Iterator encDataObjIterator = encryptedDataList.getEncryptedDataObjects();
				PGPPrivateKey privateKey = null;
				PGPPublicKeyEncryptedData publicEncryptedData = null;

				String message = "Looking for secret key from given key id in encDataObjIterator: " + encDataObjIterator.hasNext();
				IHCCryptoUtils.printOut(message);

				while (encDataObjIterator != null && encDataObjIterator.hasNext() && privateKey == null) {
					publicEncryptedData = (PGPPublicKeyEncryptedData) encDataObjIterator.next();

					try {

						message = "encrypted data object has key id of: " + publicEncryptedData;
						IHCCryptoUtils.printOut(message);

						PGPSecretKey secretKey = secretKeyRing
								.getSecretEncryptionKeyByID(publicEncryptedData.getKeyID());

						if (secretKey == null) {
							privateKey = null;

							message = "secret key *not* found";
							IHCCryptoUtils.printOut(message);

						} else {
							PBESecretKeyDecryptor keyDecrypt = new BcPBESecretKeyDecryptorBuilder(
									new BcPGPDigestCalculatorProvider())
									.build(cArrayPass);

							privateKey = secretKey.extractPrivateKey(keyDecrypt);

							message = "private key id found: "
									+ privateKey.getKeyID();
							IHCCryptoUtils.printOut(message);

							break;
						}
					} catch (Exception nspEx) {
						message = "The jce/openpgp provider could not be found."
								+ " This must be corrected before the com.ihc.itf.crypto.openpgp package can be used.";
						System.err.println(message + ": " + nspEx);
						throw new IllegalStateException(message);
					}
				}

				if (privateKey == null) {
					System.out
							.println("no matching secret key or password wrong, throwing error");

					throw new Exception(
							"secret key for message not found (or password wrong)");
				}

				message = "Starting decryption routines...";
				IHCCryptoUtils.printOut(message);

				// This is where the decryption actually takes place...

				// Get a clearText stream out of the encrypted data
				InputStream clearText = publicEncryptedData
						.getDataStream(new BcPublicKeyDataDecryptorFactory(
								privateKey));

				BcPGPObjectFactory plainFactory = new BcPGPObjectFactory(
						clearText);

				// Get the compressed data packet
				PGPCompressedData compressedData = (PGPCompressedData) plainFactory
						.nextObject();

				// Get the message out of the compressed data packet
				BcPGPObjectFactory pgpFact = new BcPGPObjectFactory(
						compressedData.getDataStream());
				Object pgpMessage = pgpFact.nextObject();

				if (pgpMessage instanceof PGPLiteralData) {

					String log_message = "this is a literal data packet";
					IHCCryptoUtils.printOut(log_message);

					// Get the literal data packet out of the message data
					PGPLiteralData literalData = (PGPLiteralData) pgpMessage;
					InputStream literalDataInStream = literalData
							.getInputStream();

					log_message = "PGPLiteralData: Original file name: "
							+ literalData.getFileName();
					IHCCryptoUtils.printOut(log_message);

					int ch;

					while ((ch = literalDataInStream.read()) >= 0) {
						streamOut.write(ch);
					}
				} else if (pgpMessage instanceof PGPOnePassSignatureList) {

					String log_message = "this is a one pass signature list packet";
					IHCCryptoUtils.printOut(log_message);

					PGPOnePassSignatureList onePassSignatureList = (PGPOnePassSignatureList) pgpMessage;

					// Get the signature out of the one pass signature list
					// object
					PGPOnePassSignature onePassSignature = onePassSignatureList
							.get(0);

					// The next object in the compressed data should be literal
					// data
					PGPLiteralData literalData = (PGPLiteralData) pgpFact
							.nextObject();

					// Create a stream to read the literal data in
					InputStream literalDataInStream = literalData
							.getInputStream();
					int ch;

					// Get the actual key (who's ID is indicated in the
					// one-pass-signature packet)
					PGPPublicKey key = publicKeyRing
							.getPublicEncryptionKeyByID(onePassSignature
									.getKeyID());

					if (null == key) {
						System.out
								.println("Did not find a public key - skipping OnePassSignature verification");

						while ((ch = literalDataInStream.read()) >= 0) {
							streamOut.write(ch);
						}

						// streamOut.close();

					} else {
						// Initialize the process that will check the signature

						onePassSignature.init(
								new BcPGPContentVerifierBuilderProvider(), key);

						log_message = "PGPOnePassSignatureList: Original file name: "
								+ literalData.getFileName();
						IHCCryptoUtils.printOut(log_message);

						while ((ch = literalDataInStream.read()) >= 0) {
							// Update the signature hash
							onePassSignature.update((byte) ch);

							// I'm honestly unclear on why this works, but it
							// appears to write the unsigned data out to the
							// output file.
							streamOut.write(ch);
						}

						// streamOut.close();
						// IHCCryptoUtils.printOut("Closing the stream");

						// The third object in the compressed data should be the
						// signed hash(es) or signature packets
						PGPSignatureList pgpSignatureList = (PGPSignatureList) pgpFact
								.nextObject();

						// Verify the hash/signature you've made against the
						// hash/signature provided
						// in the data.
						if (onePassSignature.verify(pgpSignatureList.get(0))) {
							log_message = "signature verified";
							IHCCryptoUtils.printOut(log_message);

						} else {
							log_message = "signature verification *failed*";
							IHCCryptoUtils.printOut(log_message);
							throw new Exception(log_message);

						}
					}
				} else {
					System.out
							.println("message type unknown, unable to decrypt - throwing exception");

					throw new Exception(
							"Message type unknown, unable to decrypt.");
				}

				if (publicEncryptedData.isIntegrityProtected()) {
					if (!publicEncryptedData.verify()) {
						IHCCryptoUtils.printOut("message *failed* integrity check");
					} else {
						IHCCryptoUtils.printOut("message passed integrity check");
					}
				} else {
					IHCCryptoUtils.printOut("no message integrity check");
				}
			} catch (SignatureException sigEx) {
				System.err.println("Signature exception: " + sigEx);
				throw new Exception(sigEx.getMessage());
			} catch (NoSuchProviderException nspEx) {
				String message = "The jce/openpgp provider could not be found."
						+ " This must be corrected before the com.ihc.itf.crypto.openpgp package can be used.";
				System.err.println(message + ": " + nspEx);
				throw new Exception(message);
			} catch (PGPException pgpEx) {
				// check for nosuchprovider underneath pgpexception because
				// still need to catch nosuchprovider separately
				if (pgpEx.getUnderlyingException() instanceof NoSuchProviderException) {
					String message = "The jce/openpgp provider could not be found."
							+ " This must be corrected before the com.ihc.itf.crypto.openpgp package can be used.";
					System.err.println(message + ": "
							+ pgpEx.getUnderlyingException().toString());
					throw new Exception(message);
				}

				System.err.println("A PGPException occurred: "
						+ pgpEx.getUnderlyingException());
			}
		} catch (IOException ioEx) {
			System.err
					.println("Error getting decoder stream (file may not be encrypted): "
							+ ioEx);
			throw new IOException(ioEx.getMessage());
		}
	}
	
	private void printObjType(Object o)
	{
		String message;
		if (o == null) {
			System.out
					.println("outerPgpFactory.nextObject returned null");
			return;
		}

		if (o instanceof PGPCompressedData) {
			message = "It's PGPCompressedData";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPEncryptedData) {
			message = "It's PGPEncryptedData";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPEncryptedDataList) {
			message = "It's PGPEncryptedDataList";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPKeyFlags) {
			message = "It's PGPKeyFlags";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPKeyPair) {
			message = "It's PGPKeyPair";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPLiteralData) {
			message = "It's PGPLiteralData";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPMarker) {
			message = "It's PGPMarker";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPOnePassSignature) {
			message = "It's PGPOnePassSignature";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPOnePassSignatureList) {
			message = "It's PGPOnePassSignatureList";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPPBEEncryptedData) {
			message = "It's PGPPBEEncryptedData";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPPrivateKey) {
			message = "It's PGPPrivateKey";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPPublicKey) {
			message = "It's PGPPublicKey";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPPublicKeyEncryptedData) {
			message = "It's PGPPublicKeyEncryptedData";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPSecretKey) {
			message = "It's PGPSecretKey";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPSignature) {
			message = "It's PGPSignature";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPSignatureList) {
			message = "It's PGPSignatureList";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPSignatureSubpacketVector) {
			message = "It's PGPSignatureSubpacketVector";
			IHCCryptoUtils.printOut(message);
		}
		if (o instanceof PGPUserAttributeSubpacketVector) {
			message = "It's PGPUserAttributeSubpacketVector";
			IHCCryptoUtils.printOut(message);
		}
	}

	private boolean isStreamArmored(InputStream in) throws IOException {

		final int READ_AHEAD = 60;

		IHCCryptoUtils.printOut("Read ahead is set to: " + READ_AHEAD);

		in.mark(READ_AHEAD);

		int ch = in.read();

		boolean returnArmored = false;
		if ((ch & 0x80) != 0) {
			in.reset();
			returnArmored = false;
			IHCCryptoUtils.printOut("Encrypted message is *not* armored, resetting to beginning of stream");

		} else {
			in.reset();
			returnArmored = true;
			IHCCryptoUtils.printOut("Encrypted message is armored, resetting to beginning of stream");

		}

		return returnArmored;
	}

}
