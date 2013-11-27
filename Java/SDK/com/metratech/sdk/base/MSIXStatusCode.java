package com.metratech.sdk.base;

import java.io.*;

/**
 * {internal}
 */
class MSIXStatusCode implements MSIXObject
{
  protected MSIXStatusCode ()
  {
    this.mValue = new Long(0);
  }
	
  protected String getName ()
  {
    return this.mName;
  }

  protected long getValue ()
  {
    return this.mValue.longValue();
  }
	
  protected Long getLongValue ()
  {
    return this.mValue;
  }
	
  public MSIXObject create (String type)
  {
    return null;
  }
	
  public void parse (String data) throws MTException
  {
    try 
    {		
      this.mValue = Long.valueOf(data,16);
    }
    catch (NumberFormatException ex)
    {
      throw new MTException ("Error parsing status code " + ex);
    }
  }
	
  public void complete (MSIXObject obj)
  {
  }
		
  public void toStream (OutputStream stream) throws IOException
	
  {
    MSIXWriter.outputOpeningTag (stream, mName);
    MSIXWriter.outputValue (stream, this.mValue.toString());
    MSIXWriter.outputClosingTag (stream, mName);
  }

	
  private String mName;	
  private Long	 mValue;
}
