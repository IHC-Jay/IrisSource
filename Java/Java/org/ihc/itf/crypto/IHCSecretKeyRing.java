package org.ihc.itf.crypto;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;

import org.bouncycastle.openpgp.PGPException;
import org.bouncycastle.openpgp.PGPSecretKey;
import org.bouncycastle.openpgp.PGPSecretKeyRing;
import org.bouncycastle.openpgp.bc.BcPGPSecretKeyRing;
import org.bouncycastle.openpgp.bc.BcPGPSecretKeyRingCollection;

public class IHCSecretKeyRing extends BcPGPSecretKeyRingCollection {

	public IHCSecretKeyRing(InputStream pSecretKeyRingStream)
	        throws IOException, PGPException
	    {
	        super(pSecretKeyRingStream);
	    }
	
	public IHCSecretKeyRing(String pStringSecretKeyRing)
	        throws IOException, PGPException
	    {
	        this(new FileInputStream(pStringSecretKeyRing));
	    }
	
	 public PGPSecretKey getSecretEncryptionKeyByID(long plKey)
	    {
	       
	        final Long longKey = new Long(plKey);

	        return getSecretEncryptionKey(longKey);
	    }
	 
	 public PGPSecretKey getSecretEncryptionKeyByName(String pStrKeyName)
	    {
	      
	        //  validate parameter keyid
	        if (null == pStrKeyName) {
	            throw new IllegalArgumentException("keyid can't not be null");
	        }

	        return getSecretEncryptionKey(pStrKeyName);
	    }

	    private PGPSecretKey getSecretEncryptionKey(final Object keyid) {
	      
	        PGPSecretKey returnKey = null;

	        Iterator<BcPGPSecretKeyRing> secretRingIterator = this.getKeyRings();
	        int ringCounter = 0;
	        IHCCryptoUtils.printOut("BcPGPSecretKeyRing next: " + secretRingIterator.hasNext());

	        CollectionLabel:
	        while (secretRingIterator.hasNext()) {
	        	PGPSecretKeyRing secretKeyRing =  secretRingIterator.next();

	            IHCCryptoUtils.printOut("getSecretEncryptionKey: Looking at ring <" + ringCounter + ">");

	            boolean foundMatch = false;
	            int keyCounter = 0;
	            Iterator<PGPSecretKey> secretKeyIterator = secretKeyRing.getSecretKeys();
	            PGPSecretKey secretKey = null;
	            while (secretKeyIterator.hasNext()) {

	                secretKey = (PGPSecretKey) secretKeyIterator.next();

	                IHCCryptoUtils.printOut("Looking at key <" + keyCounter + "> of Ring <" + ringCounter + ">");

	                if (! foundMatch) {
	                    foundMatch = doesKeyHaveKey(secretKey, keyid);
	                    if (foundMatch) {
	                        returnKey = secretKey;
	                        IHCCryptoUtils.printOut("Found match in key <" + keyCounter + "> of Ring <" + ringCounter + ">");
	                        break CollectionLabel;
	                    }
	                ++keyCounter;
	                }
	            }
	            IHCCryptoUtils.printOut("Number of searched Keys in Ring <" + ringCounter + "> is " + keyCounter);
	            ++ringCounter;
	        }
	        IHCCryptoUtils.printOut("Number of searched Rings in Collection is " + ringCounter);

	        if (null == returnKey) {
	            IHCCryptoUtils.printOut("Search for SecretEncryptionKey <" + keyid + "> was UN-successful");
	        } else {
	           
	                IHCCryptoUtils.printOut( IHCCryptoUtils.printKeyAttributes(returnKey.getPublicKey()));
	            
	        }

	        return returnKey;
	    }

	    private boolean doesKeyHaveKey(PGPSecretKey sk, Object keyid) {
	      
	        boolean bReturn = false;

	        if (keyid instanceof String) {
	            String castedKeyid = (String) keyid;
	            String tmpString = null;
	            Iterator<String> nameIterator = sk.getUserIDs();
	            while (nameIterator.hasNext()) {
	                tmpString = (String) nameIterator.next();
	                IHCCryptoUtils.printOut("String Keys: " + tmpString + " == " + castedKeyid);
	                if (tmpString.indexOf(castedKeyid) != -1) {
	                    bReturn = true;
	                    IHCCryptoUtils.printOut("Matched on name <" + castedKeyid + ">");
	                }
	            }
	        } else if (keyid instanceof Long) {
	            long castedKeyid = ((Long) keyid).longValue();
	            long tmp = sk.getKeyID();
	            IHCCryptoUtils.printOut("Long Keys: " + tmp + " == " + castedKeyid);
	            if (castedKeyid == tmp) {
	                bReturn = true;
	                IHCCryptoUtils.printOut("Matched on ID <" + castedKeyid + ">");
	            }
	        } else {
	            IHCCryptoUtils.printOut("Unrecognized parameter <" + keyid +">");
	            throw new IllegalArgumentException("Unrecognized parameter <" + keyid +">");
	        }
	        return bReturn;
	    }


}
