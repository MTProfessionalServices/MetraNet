package com.metratech.sdk.base;

import java.io.*;

/**
 * {internal}
 */

class MSIXSessionStatus implements MSIXObject
{
  protected MSIXSessionStatus()
  {
  }

  protected MSIXStatusCode getCode()
  {
    return this.mCode;
  }
	
  protected synchronized void setCode (MSIXStatusCode code)
  {
    this.mCode = code;
  }
	
  protected MSIXString getMessage()
  {
    return this.mStrMessage;
  }
	
  protected synchronized void setMessage (MSIXString s)
  {
    this.mStrMessage = s;
  }
	
  protected synchronized void setSession (MTMeterMSIXSession session)
  {
    this.mSession = session;
  }
	
  protected MTMeterMSIXSession getSession ()
  {
    return this.mSession;
  }

  protected synchronized void setUID (MSIXUID uid)
  {
    this.mUID = uid;
  }
	
  protected MSIXUID getUID ()
  {
    return this.mUID;
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
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_BEGINSESSION))
    {
      MTMeterMSIXSession anInt = new MTMeterMSIXSession();
      obj = (MSIXObject)anInt;
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
    //System.out.println("Inside MSIXSessionStatus.complete");
    if (obj instanceof MSIXStatusCode)
    {
      MSIXStatusCode aCode = (MSIXStatusCode)obj;
      setCode (aCode);
    }
    else if (obj instanceof MSIXString)
    {
      MSIXString strMesg = (MSIXString)obj;
      setMessage (strMesg);
    }
    else if (obj instanceof MTMeterMSIXSession)
    {
      MTMeterMSIXSession aSess = (MTMeterMSIXSession)obj;
      setSession (aSess);
    }
    else if (obj instanceof MSIXUID)
    {
      MSIXUID aUID = (MSIXUID)obj;
      setUID (aUID);
    }		
    //System.out.println("End of MSIXSessionStatus.complete");
  }

  public void toStream (OutputStream stream) throws IOException
  {
    MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_STATUS);
    mCode.toStream (stream);
    MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_STATUS);
  }
		
  private MSIXStatusCode mCode;
  private MSIXString mStrMessage;
  private MTMeterMSIXSession mSession;
  private MSIXUID mUID;
}
