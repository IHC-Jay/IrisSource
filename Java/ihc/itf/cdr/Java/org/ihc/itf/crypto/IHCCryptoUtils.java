package org.ihc.itf.crypto;

import java.util.Iterator;

import org.bouncycastle.bcpg.CompressionAlgorithmTags;
import org.bouncycastle.bcpg.HashAlgorithmTags;
import org.bouncycastle.bcpg.SymmetricKeyAlgorithmTags;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPSignature;
import org.bouncycastle.openpgp.PGPSignatureSubpacketVector;

public class IHCCryptoUtils {

	private static Boolean debugSet = false;

	public Boolean getDebugSet() {
		return debugSet;
	}

	public static void setDebugSet(Boolean debugSet) {
		IHCCryptoUtils.debugSet = debugSet;
	}

	public static final String printKeyAttributes(final PGPPublicKey pk) {
		final String METHOD_NAME = "printKeyAttributes(pk, mk)";

		Iterator<String> userIdsIterator = null;
		StringBuffer uids = new StringBuffer();
		StringBuffer sb = null;
		StringBuffer pkPrefs = null;

		if ((null == pk)) {
			sb = new StringBuffer("No public key found");
		} else {
			if ((null != pk.getUserIDs()) && (pk.getUserIDs().hasNext())) {
				userIdsIterator = pk.getUserIDs();
			} else {
				uids = new StringBuffer("[None Found]");
			}

			Iterator<PGPSignature> psIt = null;
			boolean firstId = true;
			while ((null != userIdsIterator) && (userIdsIterator.hasNext())) {
				final String userid = (String) userIdsIterator.next();
				if (firstId) {
					psIt = pk.getSignatures(); // ForID(userid);
					firstId = false;
				}
				uids.append("[");
				uids.append(userid);
				uids.append("]");
			}

			pkPrefs = new StringBuffer();

			// get public key preferences for first userid returned above
			int signatureCount = 0;
			while ((null != psIt) && (psIt.hasNext())) {
				final PGPSignature ps = (PGPSignature) psIt.next();
				final PGPSignatureSubpacketVector psv = ps
						.getHashedSubPackets();

				pkPrefs.append("\nSignature <");
				pkPrefs.append(signatureCount);
				pkPrefs.append("> ");
				if (psv != null) {
					pkPrefs.append("has the following preferences ::");
					pkPrefs.append("\nCompression Preferences: ");
					int[] prefs = null;
					try {
						prefs = psv.getPreferredCompressionAlgorithms();
					} catch (NullPointerException npEx) {
						pkPrefs.append("No preferred comression algorithm...probably RSA key");
					}
					if (null == prefs) {
						pkPrefs.append("None specified - default to ZIP");
					} else {
						for (int index = 0; index < prefs.length; index++) {
							final int alg = prefs[index];
							pkPrefs.append(getCompressionAlgorithmAsString(alg));
							pkPrefs.append(" [");
							pkPrefs.append(alg);
							pkPrefs.append("]");
						}
					}

					pkPrefs.append("\nSymmetric Preferences: ");
					prefs = null;
					try {
						prefs = psv.getPreferredSymmetricAlgorithms();
					} catch (NullPointerException npEx) {
						pkPrefs.append("No symmetric algorithm...probably RSA key");
					}
					if (null == prefs) {
						pkPrefs.append("None specified - default to 3-DES");
					} else {
						for (int index = 0; index < prefs.length; index++) {
							final int alg = prefs[index];
							pkPrefs.append(getSymmetricAlgorithmAsString(alg));
							pkPrefs.append(" [");
							pkPrefs.append(alg);
							pkPrefs.append("]");
						}
					}

					pkPrefs.append("\nHash Preferences: ");
					prefs = null;
					try {
						prefs = psv.getPreferredHashAlgorithms();
					} catch (NullPointerException npEx) {
						pkPrefs.append("No Hash Algorithm...probably RSA key");
					}
					if (null == prefs) {
						pkPrefs.append("None specified - default is SHA-1, but may be MD5");
					} else {
						for (int index = 0; index < prefs.length; index++) {
							final int alg = prefs[index];
							pkPrefs.append(getHashAlgorithmAsString(alg));
							pkPrefs.append(" [");
							pkPrefs.append(alg);
							pkPrefs.append("]");
						}
					}
				}
			}
		}
		sb = new StringBuffer();
		sb.append("\n--Attributes of matching key\n");
		sb.append("\nKeyid (hex): ");
		sb.append(Long.toHexString(pk.getKeyID()));
		sb.append("\nKeyid (long): ");
		sb.append(pk.getKeyID());
		sb.append("\nUserid: ");
		sb.append(uids.toString());
		sb.append("\nVersion: ");
		sb.append(pk.getVersion());
		sb.append("\nCreation time: ");
		sb.append(pk.getCreationTime());
		sb.append("\nEncryption Algorithm: ");
		sb.append(getEncryptionAlgorithmAsString(pk.getAlgorithm()));
		sb.append(" [");
		sb.append(pk.getAlgorithm());
		sb.append("]");
		sb.append(pkPrefs.toString());
		sb.append("\nBit strength: ");
		sb.append(pk.getBitStrength());
		sb.append("\nFingerprint: ");
		sb.append(pk.getFingerprint());
		sb.append("\nValid days: ");
		sb.append(pk.getValidDays());
		sb.append("\nIs encryption key: ");
		sb.append(pk.isEncryptionKey());
		sb.append("\nIs master key: ");
		sb.append(pk.isMasterKey());
		sb.append("\n\nend--\n");

		return sb.toString();
	}

	public static final String getSymmetricAlgorithmAsString(final int algorithm) {
		final String strAlgorithm;

		switch (algorithm) {
		case SymmetricKeyAlgorithmTags.AES_128:
			strAlgorithm = "AES-128";
			break;
		case SymmetricKeyAlgorithmTags.AES_192:
			strAlgorithm = "AES-192";
			break;
		case SymmetricKeyAlgorithmTags.AES_256:
			strAlgorithm = "AES-256";
			break;
		case SymmetricKeyAlgorithmTags.BLOWFISH:
			strAlgorithm = "BLOWFISH";
			break;
		case SymmetricKeyAlgorithmTags.CAST5:
			strAlgorithm = "CAST5";
			break;
		case SymmetricKeyAlgorithmTags.DES:
			strAlgorithm = "DES";
			break;
		case SymmetricKeyAlgorithmTags.IDEA:
			strAlgorithm = "IDEA";
			break;
		case SymmetricKeyAlgorithmTags.NULL:
			strAlgorithm = "NULL";
			break;
		case SymmetricKeyAlgorithmTags.TRIPLE_DES:
			strAlgorithm = "TRIPLE-DES";
			break;
		case SymmetricKeyAlgorithmTags.TWOFISH:
			strAlgorithm = "TWOFISH";
			break;
		default:
			strAlgorithm = "Unknown";
			break;
		}
		return strAlgorithm;
	}

	public static final String getCompressionAlgorithmAsString(
			final int algorithm) {
		final String strAlgorithm;

		switch (algorithm) {
		case CompressionAlgorithmTags.UNCOMPRESSED:
			strAlgorithm = "Un-compressed";
			break;
		case CompressionAlgorithmTags.ZIP:
			strAlgorithm = "ZIP";
			break;
		case CompressionAlgorithmTags.ZLIB:
			strAlgorithm = "ZLIB";
			break;
		default:
			strAlgorithm = "Unknown";
			break;
		}
		return strAlgorithm;
	}

	public static final String getHashAlgorithmAsString(final int algorithm) {
		final String strAlgorithm;
		switch (algorithm) {
		case HashAlgorithmTags.DOUBLE_SHA:
			strAlgorithm = "Double-SHA";
			break;
		case HashAlgorithmTags.HAVAL_5_160:
			strAlgorithm = "Haval-5-160";
			break;
		case HashAlgorithmTags.MD2:
			strAlgorithm = "MD2";
			break;
		case HashAlgorithmTags.MD5:
			strAlgorithm = "MD5";
			break;
		case HashAlgorithmTags.RIPEMD160:
			strAlgorithm = "RIPEMD160";
			break;
		case HashAlgorithmTags.SHA1:
			strAlgorithm = "SHA-1";
			break;
		case HashAlgorithmTags.TIGER_192:
			strAlgorithm = "Tiger-192";
			break;
		default:
			strAlgorithm = "Unknown";
			break;
		}
		return strAlgorithm;
	}

	public static final String getEncryptionAlgorithmAsString(
			final int algorithm) {
		final String strAlgorithm;
		switch (algorithm) {
		case PGPPublicKey.DIFFIE_HELLMAN:
			strAlgorithm = "DIFFIE-HELLMAN";
			break;
		case PGPPublicKey.DSA:
			strAlgorithm = "DSA";
			break;
		case PGPPublicKey.EC:
			strAlgorithm = "EC";
			break;
		case PGPPublicKey.ECDSA:
			strAlgorithm = "ECDSA";
			break;
		case PGPPublicKey.ELGAMAL_ENCRYPT:
			strAlgorithm = "Elgamal-Encrypt";
			break;
		case PGPPublicKey.ELGAMAL_GENERAL:
			strAlgorithm = "Elgamal-General";
			break;
		case PGPPublicKey.RSA_ENCRYPT:
			strAlgorithm = "RSA-Encrypt";
			break;
		case PGPPublicKey.RSA_GENERAL:
			strAlgorithm = "RSA-General";
			break;
		case PGPPublicKey.RSA_SIGN:
			strAlgorithm = "RSA-Sign";
			break;
		default:
			strAlgorithm = "Unknown";
			break;
		}
		return strAlgorithm;
	}

	public static void printOut(String msg) {
		if (debugSet) {
			System.out.println(msg);
		}

	}

}
