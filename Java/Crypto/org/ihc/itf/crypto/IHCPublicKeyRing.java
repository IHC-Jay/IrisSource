package org.ihc.itf.crypto;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import java.util.Iterator;

import org.bouncycastle.openpgp.PGPException;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPPublicKeyRing;
import org.bouncycastle.openpgp.bc.BcPGPPublicKeyRingCollection;

public class IHCPublicKeyRing extends BcPGPPublicKeyRingCollection  {

	public IHCPublicKeyRing(InputStream pPublicKeyRingStream)
	        throws IOException, PGPException
	    {
	        super(pPublicKeyRingStream);
	    }
	
	public IHCPublicKeyRing(String pStringPublicKeyRing)
	        throws IOException, PGPException
	    {
	        this(new FileInputStream(pStringPublicKeyRing));
	    }
	
	public PGPPublicKey getPublicEncryptionKeyByName(String pStrKeyName)
    {
        
        //  validate parameter keyid
        if (null == pStrKeyName) {
            throw new IllegalArgumentException("keyid can't not be null");
        }

        return getPublicEncryptionKey(pStrKeyName);
    }

    private boolean doesKeyHaveKey(PGPPublicKey pk, Object keyid) {
   
        boolean bReturn = false;

        if (keyid instanceof String) {
            String castedKeyid = (String) keyid;
            String tmpString = null;
            Iterator<String> nameIterator = pk.getUserIDs();
            while (nameIterator.hasNext()) {
                tmpString = (String) nameIterator.next();
                IHCCryptoUtils.printOut("Key name: " + tmpString);
                if (tmpString.indexOf(castedKeyid) != -1) {
                    bReturn = true;
                    IHCCryptoUtils.printOut("Matched on name <" + castedKeyid + ">");
                }
            }
        } else if (keyid instanceof Long) {
            long castedKeyid = ((Long) keyid).longValue();
            long tmp = pk.getKeyID();
            if (castedKeyid == tmp) {
                bReturn = true;
                IHCCryptoUtils.printOut("Matched on ID <" + castedKeyid + ">");
            }
        } else {
        	IHCCryptoUtils.printOut( "Unrecognized parameter <" + keyid +">");
            throw new IllegalArgumentException("Unrecognized parameter <" + keyid +">");
        }
        return bReturn;
    }

    private PGPPublicKey getPublicEncryptionKey(final Object keyid) {
     
        PGPPublicKey returnKey = null;
        Iterator<PGPPublicKeyRing> publicRingIterator =  this.getKeyRings();
        int ringCounter = 0;
        while (publicRingIterator.hasNext()) {
            PGPPublicKeyRing publicKeyRing = (PGPPublicKeyRing) publicRingIterator.next();

            boolean foundMatch = false;
            boolean inMaster = false;
            int keyCounter = 0;
            Iterator<PGPPublicKey> publicKeyIterator = publicKeyRing.getPublicKeys();
            PGPPublicKey publicKey = null;
            while (publicKeyIterator.hasNext()) {

                // while iterating through subkeys we hit a master key
                // and haven't had a chance to look at the master key
                if(! inMaster) {
                    publicKey = (PGPPublicKey) publicKeyIterator.next();
                } else {
                    inMaster = false;
                }

                IHCCryptoUtils.printOut("getPublicEncryptionKey: Looking at key <" + keyCounter + "> of Ring <" + ringCounter + ">");

                int subKeyCounter = 0;

                if (! foundMatch) {
                    foundMatch = doesKeyHaveKey(publicKey, keyid);
                    if (foundMatch) {
                        if (! publicKey.isEncryptionKey()) {
                            while (publicKeyIterator.hasNext()) {
                                IHCCryptoUtils.printOut("Looking at sub key <" + subKeyCounter + "> of Key <" + keyCounter + "> of Ring <" + ringCounter + ">");
                                PGPPublicKey tmpKey = (PGPPublicKey) publicKeyIterator.next();
                                if (tmpKey.isEncryptionKey()) {
                                    returnKey = tmpKey;
                                    IHCCryptoUtils.printOut("Sub key <" + subKeyCounter + "> of Key <" + keyCounter + "> of Ring <" + ringCounter + "> is an encryption key");
                                } else if(tmpKey.isMasterKey()) {
                                    /*
                                     * If we are a new master key, the flags below will
                                     * ensure that we process this key at the top of the
                                     * publicKeyIterator loop
                                     */
                                    foundMatch = false;
                                    inMaster = true;
                                    publicKey = tmpKey;
                                    IHCCryptoUtils.printOut("Found another master key in Ring <" + ringCounter + ">");
                                    break;
                                } else {
                                    IHCCryptoUtils.printOut("This sub-key is neither an encryption key or master key");
                                }
                                ++subKeyCounter;
                            } // end-while
                            IHCCryptoUtils.printOut("Number of Sub keys in Key <" + keyCounter + "> of Ring <" + ringCounter + "> is " + subKeyCounter);
                        } else {
                            returnKey = publicKey;
                            IHCCryptoUtils.printOut("Key <" + keyCounter + "> is encryption key of Ring <" + ringCounter + ">");
                        }
                    }
                } // end-top-if
                ++keyCounter;
            }
            IHCCryptoUtils.printOut("Number of Keys in Ring <" + ringCounter + "> is " + keyCounter);
            ++ringCounter;
        }
        IHCCryptoUtils.printOut("Number of Rings in Collection is " + ringCounter);

        if (null == returnKey) {
        	IHCCryptoUtils.printOut("Search for PublicEncryptionKey <" + keyid + "> was UN-successful");
        } else {
          
                IHCCryptoUtils.printOut( IHCCryptoUtils.printKeyAttributes(returnKey));
            
        }

        return returnKey;
    }

	public PGPPublicKey getPublicEncryptionKeyByID(long keyID) 
	{
		 final Long longKey = new Long(keyID);

	     return getPublicEncryptionKey(longKey);
	}
	
}
