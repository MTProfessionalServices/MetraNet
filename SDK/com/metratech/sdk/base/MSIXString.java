package com.metratech.sdk.base;

import java.io.*;

/**
 * {internal}
 */
class MSIXString implements MSIXObject
{
  protected MSIXString (String name)
  {
    this.mName = name;
  }
	
  protected synchronized void setName(String name)
  {
    this.mName = name;
  }
	
  protected synchronized void setValue(String val)
  {
    this.mValue = val;
  }
	
  protected String getName ()
  {
    return this.mName;
  }

  protected String getValue ()
  {
    return this.mValue;
  }

	
  public MSIXObject create (String type)
  {
    return null;
  }
	
  public void parse (String data)
  {
    this.mValue = data;
  }
	
  public void complete (MSIXObject obj)
  {
  }
	
  public void toStream (OutputStream stream) throws IOException
	
  {
    MSIXWriter.outputOpeningTag (stream, this.mName);
    MSIXWriter.outputValue (stream, this.mValue);
    MSIXWriter.outputClosingTag (stream, this.mName);
  }

  private String mName;	
  private String mValue;
}
