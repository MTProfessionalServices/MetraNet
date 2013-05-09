package com.metratech.sdk.base;

import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.Exception;
import sun.misc.BASE64Encoder;
import sun.misc.BASE64Decoder;

/**
 * {internal}
 */
class MSIXUID implements MSIXObject 
{
  protected MSIXUID () throws MTException
  {		
    // Grab the local host IP Addr if we don't have one
    if (mIPAddr == null)
    {
      try 
      {
	InetAddress addr = InetAddress.getLocalHost();
	mIPAddr = addr.getAddress();
      } 
      catch (UnknownHostException e)
      {
	throw new MTException ("Unable to obtain local host name " + e);
      }	
    }
    
    // Allocate a byte array for the UID
    this.mValue = new byte[16];
    
    // The ip address
    System.arraycopy (mIPAddr, 0, mValue, 0, 4);
    
    // The current time
    Date aDate = new Date();
    this.copyLong(this.mValue, 4, aDate.getTime());
    
    // A random number
    this.copyLong (this.mValue, 8, mRandomGenerator.nextLong());
    
    // A counter from the next global one
    this.copyLong (this.mValue, 12, this.mGlobalCounter++);  
  }
  
  protected String valueToString ()
  {
    return mEncoder.encode(this.mValue);
  }
  
  public MSIXObject create (String type)
  {
    return null;
  }
	
  public void parse (String data) throws MTException
  {
    try
    {
      this.mValue = mDecoder.decodeBuffer (data);
    }
    catch (IOException e)
    {
      throw new MTException ("Unable to parse UID " + e);
    }
  }
  
  public void complete (MSIXObject obj)
  {
  }
  
  public void toStream (OutputStream stream) throws IOException
  {
    MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_UID);
    MSIXWriter.outputValue (stream, mEncoder.encode(mValue));
    MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_UID);
  }
  
  
  byte [] mValue; 
  
  /**
   * Copies a long value into an array at the specified offset.
   */
  static void copyLong (byte[] byteArray, int start, long val)
  {	
    int hiWord;
    int loWord;
    
    // TODO: OK there has to be a better way to do this
		
    // split the long into words
    hiWord = (int)(val >> 16);
    loWord = (int)val;
    
		//split the word into bytes and copy them
    byteArray[start+1] = (byte)hiWord;
    byteArray[start] = (byte)(hiWord >> 8);
    byteArray[start+3] = (byte)loWord;
    byteArray[start+2] = (byte)(loWord >> 8);		
  }
  
  static byte [] mIPAddr;
  static long mGlobalCounter = 0;
  static Random mRandomGenerator = new Random();
  static BASE64Decoder mDecoder = new BASE64Decoder(); 
  static BASE64Encoder mEncoder = new BASE64Encoder(); 
  
}
