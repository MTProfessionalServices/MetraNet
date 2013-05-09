package com.metratech.sdk.base;

import java.io.*;

/**
 * {internal}
 */

class MSIXStatus implements MSIXObject
{
  protected MSIXStatus()
  {
  }

  protected MSIXStatusCode getCode()
  {
    return this.mCode;
  }

  protected MSIXString getMessage()
  {
    return this.mMessage;
  }
	
  protected MSIXUID getUID()
  {
    return this.mUID;
  }

  protected synchronized void setCode (MSIXStatusCode code)
  {
    this.mCode = code;
  }

  protected synchronized void setMessage (MSIXString msg)
  {
    this.mMessage = msg;
  }
  
  protected synchronized void setUID (MSIXUID aUID)
  {
    this.mUID = aUID;
  }
	
  public MSIXObject create (String type) throws MTException
  {
    MSIXObject obj = null;
    if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_CODE))
    {
      MSIXStatusCode anInt = new MSIXStatusCode();
      obj = (MSIXObject)anInt;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_STATUSMESSAGE))
    {
      MSIXString aString = new MSIXString(type);
      obj = (MSIXObject)aString;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_UID))
    {
      MSIXUID UID = new MSIXUID();
      obj = (MSIXObject)UID;
    }
			
    return obj;
  }
	
  public void parse (String type) throws MTParseException
  {
    throw new MTParseException ("Unexpected data in aggregate");		
  }

  public void complete (MSIXObject obj)
  {
    if (obj instanceof MSIXStatusCode)
    {
      MSIXStatusCode aCode = (MSIXStatusCode)obj;
      setCode (aCode);
    }
    else if (obj instanceof MSIXString)
    {
      MSIXString aMsg = (MSIXString)obj;
      setMessage (aMsg);
    }			
    else if (obj instanceof MSIXUID)
    {
      MSIXUID UID = (MSIXUID)obj;
      setUID (UID);
    }
  }

  public void toStream (OutputStream stream) throws IOException
  {
    MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_STATUS);
    this.mCode.toStream (stream);
    MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_STATUS);
  }
		
  private MSIXStatusCode	mCode;
  private MSIXString		mMessage;
  private MSIXUID               mUID;
}

