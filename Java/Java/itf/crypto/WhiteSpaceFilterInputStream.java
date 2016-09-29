package org.ihc.itf.crypto;

import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;

public class WhiteSpaceFilterInputStream extends FilterInputStream {
	 public WhiteSpaceFilterInputStream(InputStream pInStream)
	    {
	        super(pInStream);
	     

	    }

	    /**
	     * Read typically reads a character.  In this case if that character is a
	     *   space or a tab, it skips it and reads the next character instead.  In
	     *   effect this removes all spaces and tabs from the data being read.
	     *
	     * @see java.io.InputStream#read()
	     */
	 
	 public int read()
	        throws IOException
	    {
	       
	        int tmp = 0;
	        do {
	            tmp = in.read();
	        } while (tmp == 32 || tmp == 9);


	        return tmp;
	    }

	    /**
	     * Read typically reads a character and puts it into the buffer at the
	     *   appropriate offset position.  In this case if that character is a
	     *   space or a tab, it skips it and reads the next character instead.  In
	     *   effect this removes all spaces and tabs from the data being read.
	     *
	     * @see java.io.InputStream#read(byte[], int, int)
	     */
	    public int read(byte[] b, int off, int len)
	        throws IOException
	    {
	        
	        int count = 0;
	        int tmp = 0;
	        do {
	            do {
	                tmp = in.read();
	            } while (tmp == 32 || tmp == 9);
	            if (-1 != tmp) {
	                b[off + count] = (byte) tmp;
	                count++;
	            } else {
	                break;
	            }
	        } while (count < len);

	     
	        return count;
	    }
	  
}
