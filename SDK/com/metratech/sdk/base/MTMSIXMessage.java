package com.metratech.sdk.base;

import java.io.*;
import java.net.*;
import java.util.HashMap;

/**
 * {internal}
 */
public class MTMSIXMessage implements MSIXObject
{
  protected MTMSIXMessage() throws MTException
  {
    mVersion = new MSIXString(MSIXObject.MSIX_TAG_VERSION);
    mVersion.setValue(MSIXObject.MSIX_CURRENT_VERSION);
    mEntity = new MSIXString(MSIXObject.MSIX_TAG_ENTITY);
    try
    {
      InetAddress addr = InetAddress.getLocalHost();
      mEntity.setValue (addr.getHostAddress());
    }
    catch (UnknownHostException ex)
    {
      mEntity.setValue ("Unknown");
    }
    mTimeStamp = new MSIXTimeStamp();
    mUID = new MSIXUID();
    mSession = null;
    mSessionSet = null;
    mSessionContext = null;
    mSessionContextUsername = null;
    mSessionContextPassword = null;
    mSessionContextNamespace = null;
    mNumberOfResponses = 0;
    mSessionStatusMap = new HashMap();
  }

  protected synchronized void setTimeStamp (MSIXTimeStamp time)
  {
    this.mTimeStamp = time;
  }
	
  protected  synchronized void setVersion (MSIXString Version)
  {
    this.mVersion = Version;
  }

  protected synchronized void setUID (MSIXUID UID)
  {		
    this.mUID = UID;
  }

  protected synchronized void setEntity (MSIXString entity)
  {
    this.mEntity = entity;
  }
	
  public MSIXStatus getStatus ()
  {
    return mStatus;
  }
	
  protected MTMeterMSIXSession getSession()
  {
    return mSession;	
  }

  protected MTMeterMSIXSessionSet getSessionSet()
  {
    return mSessionSet;	
  }

  protected synchronized void setStatus (MSIXStatus status)
  {
    this.mStatus = status;
  }
	
  protected synchronized void setSession (MTMeterMSIXSession session)
  {
    this.mSession = session;
  }

  protected synchronized void setSessionSet (MTMeterMSIXSessionSet sessionset)
  {
    this.mSessionSet = sessionset;

    // Configure Auth Settings according to session set info

    if (sessionset.getSessionContext() != null)
    {
      this.mSessionContext = new MSIXString(MSIXObject.MSIX_TAG_SESSIONCONTEXT);
      this.mSessionContext.setValue(sessionset.getSessionContext());
    }
    else
    {
      if (sessionset.getSessionContextUsername() != null)
      {
	this.mSessionContextUsername = new MSIXString(MSIXObject.MSIX_TAG_SESSIONCONTEXTUSERNAME);
	this.mSessionContextUsername.setValue(sessionset.getSessionContextUsername());
      }
      
      if (sessionset.getSessionContextPassword() != null)
      {
	this.mSessionContextPassword = new MSIXString(MSIXObject.MSIX_TAG_SESSIONCONTEXTPASSWORD);
	this.mSessionContextPassword.setValue(sessionset.getSessionContextPassword());
      }
      
      if (sessionset.getSessionContextNamespace() != null)
      {
	this.mSessionContextNamespace = new MSIXString(MSIXObject.MSIX_TAG_SESSIONCONTEXTNAMESPACE);
	this.mSessionContextNamespace.setValue(sessionset.getSessionContextNamespace());
      }
    }
  }	
	
  protected MSIXUID getUID ()
  {
    return mUID;
  }
	
  public MSIXObject create (String type) throws MTException
  {
    MSIXObject obj = null;
    if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_VERSION) || 
	type.equalsIgnoreCase(MSIXObject.MSIX_TAG_ENTITY))
    {
      MSIXString msg = new MSIXString(type);
      obj = (MSIXObject)msg;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_TIMESTAMP))
    {
      MSIXTimeStamp ses = new MSIXTimeStamp();
      obj = (MSIXObject)ses;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_STATUS))
    {
      MSIXStatus status = new MSIXStatus();
      obj = (MSIXObject)status;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_SESSIONSTATUS))
    {
      MSIXSessionStatus status = new MSIXSessionStatus();
      obj = (MSIXObject)status;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_UID))
    {
      MSIXUID UID = new MSIXUID();
      obj = (MSIXObject)UID;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_BEGINSESSION))
    {
      MTMeterMSIXSession ses = new MTMeterMSIXSession();
      obj = (MSIXObject)ses;
    }		
    
    return obj;
  }
  
  public void parse (String type)
  {
    
  }

  public void complete (MSIXObject obj)
  {
    //System.out.println("[DEBUG] Inside MTMSIXMessage.complete");
    if (obj instanceof MSIXString)
    {
      MSIXString str = (MSIXString)obj;
      String name = str.getName();
      if (name.equalsIgnoreCase (MSIXObject.MSIX_TAG_VERSION))
	setVersion (str);	
      else if (name.equalsIgnoreCase (MSIXObject.MSIX_TAG_ENTITY))
	setEntity (str);	
    }
    else if (obj instanceof MSIXStatus)
    {
      MSIXStatus status = (MSIXStatus)obj;
      setStatus (status);
    }
    else if (obj instanceof MSIXTimeStamp)
    {
      MSIXTimeStamp ts = (MSIXTimeStamp)obj;
      setTimeStamp (ts);
    }
    else if (obj instanceof MSIXUID)
    {
      MSIXUID UID = (MSIXUID)obj;
      setUID (UID);
    }
    else if (obj instanceof MTMeterMSIXSession)
    {
      MTMeterMSIXSession session = (MTMeterMSIXSession)obj;
      setSession (session);
    }
    else if (obj instanceof MSIXSessionStatus)
    {
      // Grab the current session status object
      MSIXSessionStatus sessionStatus = (MSIXSessionStatus)obj;
      
      // Set the proper variables in the message
      if (mSessionStatusMap.size() == 0) // Only the first status in the response contains the info we want to keep on the top
                                         // level variables, for compatibility with single sessions.
      {
        setSession (sessionStatus.getSession());
        MSIXStatus status = new MSIXStatus();
        status.setCode (sessionStatus.getCode());
        status.setMessage(sessionStatus.getMessage());
        setStatus (status);
        //System.out.println("[DEBUG] SessionSet was null");
      }
      //System.out.println("[DEBUG] About to insert sessionstatus"); // TODO: Eventually remove
      //System.out.println("[DEBUG] Putting session " + sessionStatus.getUID().valueToString() + " in map"); // TODO: Eventually remove
      mSessionStatusMap.put(sessionStatus.getUID().valueToString(), (Object) sessionStatus);
      //System.out.println("[DEBUG] Error Message: " + sessionStatus.getMessage().getValue()); // TODO: Eventually remove
      //System.out.println("[DEBUG] Size of response:" + mSessionStatusMap.size()); // TODO: Eventually remove
    }
    //System.out.println("[DEBUG] End of MTMSIXMessage.complete");
  }

  public void toStream (OutputStream stream) throws IOException
  {
    MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_MESSAGE);
    mTimeStamp.toStream (stream);
    mVersion.toStream (stream);
    mUID.toStream (stream);
    mEntity.toStream (stream);
    
    if (mSessionContext != null)
      mSessionContext.toStream (stream);
    else
    {
      if (mSessionContextUsername != null)
	mSessionContextUsername.toStream (stream);
      if (mSessionContextPassword != null)
	mSessionContextPassword.toStream (stream);
      if (mSessionContextNamespace != null)
	mSessionContextNamespace.toStream (stream);
    }
    
    // New code to support "batch" (set) session submission
    // A message can contain a single session or a session set
    // Here we figure out which case is true, then send the correct structure
    // to the stream
    
    if (mSession != null)
    {
      mSession.toStream(stream);
    }
    else if (mSessionSet != null)
    {
      mSessionSet.toStream(stream);
    }
    else
    {
      // TODO: handle this properly
      //throw new MTException("There are no sessions inside this MSIX message");    
    }
		    
    MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_MESSAGE);
    MSIXWriter.outputNewLine(stream);
  }

  public HashMap getStatusMap()
  {
    return mSessionStatusMap;
  }

  private MSIXString mVersion;
  private MSIXStatus mStatus;
  private MSIXString mEntity;
  private MSIXTimeStamp	mTimeStamp;
  private MSIXString mSessionContext;
  private MSIXString mSessionContextUsername;
  private MSIXString mSessionContextPassword;
  private MSIXString mSessionContextNamespace;
  private MSIXUID	mUID;
  private MTMeterMSIXSession mSession;
  private MTMeterMSIXSessionSet mSessionSet;
  protected HashMap mSessionStatusMap;
  private long mNumberOfResponses;
}
