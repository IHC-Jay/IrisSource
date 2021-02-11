package org.ihc.itf.crypto;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SecureRandom;
import java.security.SignatureException;
import java.util.Date;
import java.util.Iterator;

import org.bouncycastle.bcpg.ArmoredOutputStream;
import org.bouncycastle.bcpg.HashAlgorithmTags;
import org.bouncycastle.openpgp.PGPCompressedData;
import org.bouncycastle.openpgp.PGPCompressedDataGenerator;
import org.bouncycastle.openpgp.PGPEncryptedData;
import org.bouncycastle.openpgp.PGPEncryptedDataGenerator;
import org.bouncycastle.openpgp.PGPException;
import org.bouncycastle.openpgp.PGPLiteralData;
import org.bouncycastle.openpgp.PGPLiteralDataGenerator;
import org.bouncycastle.openpgp.PGPPrivateKey;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPSecretKey;
import org.bouncycastle.openpgp.PGPSignature;
import org.bouncycastle.openpgp.PGPSignatureGenerator;
import org.bouncycastle.openpgp.PGPSignatureSubpacketGenerator;
import org.bouncycastle.openpgp.operator.PBESecretKeyDecryptor;
import org.bouncycastle.openpgp.operator.PGPContentSignerBuilder;
import org.bouncycastle.openpgp.operator.bc.BcPBESecretKeyDecryptorBuilder;
import org.bouncycastle.openpgp.operator.bc.BcPGPContentSignerBuilder;
import org.bouncycastle.openpgp.operator.bc.BcPGPDataEncryptorBuilder;
import org.bouncycastle.openpgp.operator.bc.BcPGPDigestCalculatorProvider;
import org.bouncycastle.openpgp.operator.bc.BcPublicKeyKeyEncryptionMethodGenerator;

public class IHCEncrypter {
	 private boolean armor = true;
	    private String finalName = PGPLiteralData.CONSOLE;
	    private InputStream inputStream;
	    private boolean integrityCheck = false;
	    private final int iStreamBufferSize = 1 << 16; // 65536
	    private OutputStream outputStream;
	    private char[] passphrase;
	    private final String provider = "BC";
	    private PGPPublicKey publicKey;
	    private PGPSecretKey secretKey;
	    private boolean sign = false;
	    private Long sourceLength;
	    
	    public IHCEncrypter(PGPPublicKey pubKey, PGPSecretKey secKey,
	            String passphrase) throws Exception
	    {
	       
	        if (pubKey != null)
	        {
	            this.publicKey = pubKey;
	        }
	        if (secKey != null)
	        {
	            this.secretKey = secKey;
	        }
	        if (passphrase != null)
	        {
	            this.passphrase = passphrase.toCharArray();
	        }
	    }
	    
	  
	    public void encrypt(final String finalName) throws Exception
    {
        
        // source file or inputstream needs to exist
        if (null == this.inputStream) {
            String msg = "No source setup; Call setInputStream(File |InputStream) to setup source.";
            IHCCryptoUtils.printOut(msg);
            throw new Exception(msg);
        }
        
        // length of source needed for encryption to occur
        if ( (null == sourceLength) || (sourceLength.longValue() <= 0) ) {
            String msg = "Length of source not set or is 0 value";
            IHCCryptoUtils.printOut( msg);
            throw new Exception(msg);
        }
        
        // name of file after decryption needs to be set
        if (null == finalName) {
            String msg = "A name for the decrypted file is required";
            IHCCryptoUtils.printOut( msg);
            throw new Exception(msg);
        }
        
        // a consumer needs to exist
        if (null == this.outputStream) {
            String msg = "No destination setup; Call setOutputStream(File | OutputStream) to setup destination";
            IHCCryptoUtils.printOut( msg);
            throw new Exception(msg);
        }
        
        this.finalName = finalName;
        encrypt();
       
    }
	    public void encrypt()
	            throws Exception
	    {
	        
	        // setup Generators
	    	// Initialize encrypted data generator (the new way)
			BcPGPDataEncryptorBuilder builder = new BcPGPDataEncryptorBuilder(
					PGPEncryptedData.TRIPLE_DES);
			builder.setSecureRandom(new SecureRandom());
			PGPEncryptedDataGenerator encGen = new PGPEncryptedDataGenerator(builder);
			
	      
	        PGPCompressedDataGenerator comGen = new PGPCompressedDataGenerator(PGPCompressedData.ZIP);
	        PGPLiteralDataGenerator litGen = new PGPLiteralDataGenerator();
	        PGPSignatureGenerator sigGen = null;
	        try
	        {
	            sigGen = (this.sign) ? setupSignatureGenerator() : null;
	        } catch (NoSuchProviderException nspe)
	        {
	            System.err.println( "Unable to setup signature generator");
	            throw new Exception(nspe.getMessage());
	        } catch (NoSuchAlgorithmException nsae)
	        {
	            System.err.println( "Unable to setup signature generator");
	            throw new Exception(nsae.getMessage());
	        } catch (PGPException pe)
	        {
	            System.err.println( "Unable to setup signature generator");
	            throw new Exception(pe.getMessage());
	        }
	        IHCCryptoUtils.printOut("Done with setup signature generator: " + sigGen);

	        // setup Streams
	        try
	        {
	        	BcPublicKeyKeyEncryptionMethodGenerator encKeyGen = new BcPublicKeyKeyEncryptionMethodGenerator(
	        			publicKey);
	        	encGen.addMethod(encKeyGen);
	        	IHCCryptoUtils.printOut("open streams to create files, armor: " + this.armor);
	            OutputStream localOs = (this.armor) ? new ArmoredOutputStream(this.outputStream) : this.outputStream;
	            OutputStream encOs = encGen.open(localOs, new byte[iStreamBufferSize]);
	            OutputStream comOs = comGen.open(encOs);
	            
	            // generate onepass signature and attach to stream
	            if (null != sigGen)
	            {
	                sigGen.generateOnePassVersion(false).encode(comOs);
	            }
	            OutputStream litOs = litGen.open(comOs, PGPLiteralData.TEXT, this.finalName, this.sourceLength.longValue(), new Date());
	            
	            IHCCryptoUtils.printOut("execute transfer of streams");
	            
	            // execute transfer of streams
	            transfer(litOs, sigGen);
	            
	            // finally encode signature within stream before closing
	            if (null != sigGen) {
	            	IHCCryptoUtils.printOut("encode");
	                sigGen.generate().encode(comOs);
	            }
	            // close Generators
	            litGen.close();
	            comGen.close();
	            encGen.close();
	            
	            // close Streams
	            localOs.close();
	            IHCCryptoUtils.printOut("closed all streams");
	        } catch (IOException ioe)
	        {
	            System.err.println( "Error setting up output streams for encryption");
	            throw ioe;
	        } catch (PGPException pe)
	        {
	            System.err.println( "Error setting up output streams for encryption");
	            throw pe;
	        } 
	    }
	    private PGPSignatureGenerator setupSignatureGenerator() throws NoSuchProviderException, PGPException, NoSuchAlgorithmException {
	          
	        PGPPrivateKey privateKey;
	        PGPSignatureGenerator sigGen;
	        try
	        {
	        	PBESecretKeyDecryptor decryptor = new BcPBESecretKeyDecryptorBuilder(
	    				new BcPGPDigestCalculatorProvider()).build(passphrase);
	        	privateKey = secretKey.extractPrivateKey(decryptor);
	    		
	            // privateKey = secretKey.extractPrivateKey(passphrase, provider);
        	 PGPContentSignerBuilder signerBuilder = new BcPGPContentSignerBuilder(secretKey.getPublicKey().getAlgorithm(),
	        			         			                 HashAlgorithmTags.SHA1);

	            sigGen = new PGPSignatureGenerator(signerBuilder);
	            sigGen.init(PGPSignature.BINARY_DOCUMENT, privateKey);
	            IHCCryptoUtils.printOut("Created sigGen: " + privateKey);
	        } catch (PGPException e)
	        {
	            System.err.println( "Error generating signature for encryption");
	            throw e;
	        } 
	        
	        Iterator<String> it = secretKey.getPublicKey().getUserIDs();
	        System.err.println( "secretKey.getPublicKey UserIDs: " + it.hasNext());
	        if (it.hasNext())
	        {
	            PGPSignatureSubpacketGenerator sigSubPacketGen = new PGPSignatureSubpacketGenerator();
	            sigSubPacketGen.setSignerUserID(false, (String) it.next());
	            sigGen.setHashedSubpackets(sigSubPacketGen.generate());
	        }
	  
	        return sigGen;
	    }
	    private void transfer(final OutputStream literalOutputStream, final PGPSignatureGenerator sigGen) throws IOException, SignatureException {
	       
	        byte[] buf = new byte[iStreamBufferSize];
	        int len = 0;
	        while ((len = this.inputStream.read(buf)) > 0)
	        {
	            literalOutputStream.write(buf, 0, len);
	            if (null != sigGen) {
	               
	                    sigGen.update(buf, 0, len);
	                
	            }
	        }
	
	    }

		public void setInputStream(File f) throws Exception {
			 
		        final FileInputStream fis;
		        try {
		        	fis = new FileInputStream(f);
		            this.inputStream = fis;
		            sourceLength = new Long(f.length());
		            IHCCryptoUtils.printOut( "setInputStream File " + f.getPath() + "length: " + f.length());
		        } catch (FileNotFoundException fnfe) {
		            System.err.println( "File " + f.getPath() + " not found exception: " + fnfe);
		            throw new Exception(fnfe.getMessage());
		        }
			
		}
		
		public void setInputStream(FileInputStream fis) throws Exception {
			try {	        	
	            this.inputStream = fis;
	            this.sourceLength = fis.getChannel().size();
	            IHCCryptoUtils.printOut( "setInputStream: FileInputStream");	       
			} catch (Exception e) {
	            System.err.println( e);
	            throw new Exception(e.getMessage());
	        }
	  }
		
		public void setInputStream(ByteArrayInputStream fis) throws Exception {
			try {	        	
	            this.inputStream = fis;
	            this.sourceLength = (long) 100;
	            IHCCryptoUtils.printOut( "setInputStream: ByteArrayInputStream");	       
			} catch (Exception e) {
	            System.err.println( e);
	            throw new Exception(e.getMessage());
	        }
	  }
		
	  public void setOutputStream(OutputStream os) {
		        this.outputStream = os;
	    }
	  
	  public void setOutputStream(final File f) throws Exception {
		  final FileOutputStream fos;
	        try {
	            fos = new FileOutputStream(f);
	            this.outputStream = fos;
	        } catch (FileNotFoundException fnfe) {
	        	System.err.println("File " + f.getPath() + " not found exception: " + fnfe);
	            throw new Exception(fnfe.getMessage());
	        }
	    }  
	
	    
}
