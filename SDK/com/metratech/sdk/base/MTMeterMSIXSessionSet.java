package com.metratech.sdk.base;

import java.util.*;
import java.net.*;
import java.io.*;
import com.metratech.sdk.utils.*;

/**
 * {internal}
 * Description:
 *		MTMeterMSIXSessionSet class provides an MSIX Protocol implementation of the
 *		MTMeterSessionSet class.
 *     {hyperlink:For more information about the MSIX Protocol|http://www.msix.org}.
 */
class MTMeterMSIXSessionSet extends  MTMeterSessionSet implements MSIXObject
{
  protected MTMeterMSIXSessionSet () throws MTException
  {
    Initialize();
  }

  public void setID(MSIXUID val)
  {
    mUID = val;
  }

  public String getID()
  {
    return mUID.toString();
  }

  public void setSessionContext(String SessionContext)
  {
    mSessionContext = SessionContext;
  }

  public String getSessionContext()
  {
    return mSessionContext;
  }

  public void setSessionContextUsername(String Username)
  {
    mSessionContextUsername = Username;
  }

  public String getSessionContextUsername()
  {
    return mSessionContextUsername;
  }

  public void setSessionContextPassword(String Password)
  {
    mSessionContextPassword = Password;
  }

  public String getSessionContextPassword()
  {
    return mSessionContextPassword;
  }

  public void setSessionContextNamespace(String Namespace)
  {
    mSessionContextNamespace = Namespace;
  }

  public String getSessionContextNamespace()
  {
    return mSessionContextNamespace;
  }

  public void SetTransactionID(String val)
  {
    mTransactionID = val;
  }

  public void SetValidate(Boolean val)
  {
    mValidate = val;
  }

  public MTMeterSession createSession (// Service name of this session.
    String name) throws MTException
  {
    MTMeterMSIXSession newSession = new MTMeterMSIXSession(name);
    mSet.addElement(newSession);

    if (mBatch != null)
      newSession.setBatch(mBatch);

    return newSession;
  }

  public void close() throws MTException
  {
    Enumeration serverEntries = super.mMeter.serverEntries();

    if ((serverEntries == null) || (!serverEntries.hasMoreElements()))
    {
      throw new MTException("No server configuration found");
    }

    IOException lastError = null;
    boolean bSuccess = false;
    boolean bConnected = false;
    boolean bFoundOne = false;
    MSIXStatusCode code = null;
    MSIXString stsMsg = null;

    // Loop through the serverEntries
    try
    {
      while (serverEntries.hasMoreElements() && !bSuccess)
      {
	//instantiate a new connection to the current server
	MTServerEntry currentServer = (MTServerEntry) serverEntries.nextElement();

	String webprotocol = "http";
	if (currentServer.getSecure())
	  webprotocol = "https";
	URL url = new URL (webprotocol,
			   currentServer.getServerName(),
			   new Long(currentServer.getPortNumber()).intValue(),
			   MTMeterConnection.DEFAULT_LISTENER);

	MTMeterConnection myConnection; // If auth settings were configured, then use the proper connection constructor
	if ((currentServer.getUserName()).length() == 0)
	  myConnection = (MTMeterConnection) new MTMSIXConnection("javaSDK msix connection", url);
	else
	  myConnection = (MTMeterConnection) new MTMSIXConnection("javaSDK msix connection", url, currentServer.getUserName(), currentServer.getPassword());
      	bFoundOne = true;

	// This function attempts to open a connection by pooling a socket on the server, on the proper port
	// If it returns false, we need to throw an exception because a connection was not possible
	if (!setupConnection(myConnection))
	{
	  throw new MTException("This SDK client was unable to stabilish a connection to the server. Please check your server entry configuration.");
	}

	OutputStream myStream = myConnection.getOutputStream();

	// Create a new message
	MTMSIXMessage message = new MTMSIXMessage();

	// Add our session to it
	message.setSessionSet(this);

	// stream the data to the output stream
	message.toStream(myStream);

	// close the stream
	myStream.close();

	// Comment out this part for now. Deal with this when we decide
	// what to do for Synchronous Batch sessions

	// Get a response
	InputStream Input = myConnection.getInputStream();

	// A MTFileConnection object returns a null (a file won't respond)
	if (Input == null)
	  return;

	// Create the parser
	MTMSIXParser myParser = new MTMSIXParser(Input);

	// Parse the response
	MTMSIXMessage myMessage = myParser.doParse();

	// Pull out the status info
	MSIXStatus sts = myMessage.getStatus();

	code = sts.getCode();
	stsMsg = sts.getMessage();

	// Handle a sychronous response
	// We need to match each sessionstatus in mSessionStatusMap to each session metered that was part of this sessionset
	matchResponses(myMessage.getStatusMap());

	// if (this.getSynchronous())
	//	this.mResultSession = myMessage.getSession();

	Input.close();

	// We're done
	bSuccess = true;
      }
    }
    catch (IOException ioEx)
    {
      System.out.println("IO Exception while sending session: " + ioEx.getMessage());
      lastError = ioEx;
    }

    if (!bFoundOne)
      throw new MTSessionException("No connections defined");

    if (!bSuccess)
      throw new MTSessionException("Could not meter to any server.  Last error: " + lastError.toString());

    if (code.getValue() != 0)
    {
      if ( stsMsg == null )
	throw new MTSessionException(code.getValue(), "Server error : " + code.getValue() + ". No error message.");
      else
	throw new MTSessionException(code.getValue(), "Server error : " + stsMsg.getValue());
    }

    // update the batch metered count
    if (mBatch != null)
      mBatch.updateMeteredCount(mSet.size());

    return;
  }

  private void matchResponses(HashMap aStatusMap) throws MTException
  {
    Iterator it = mSet.iterator();
    while (it.hasNext())
    {
      try
      {
	MTMeterMSIXSession currentSession = (MTMeterMSIXSession) it.next();
	// Let's see if there is a response for this session
	MSIXSessionStatus sessStatus = (MSIXSessionStatus) aStatusMap.get(currentSession.getSessionID());

	if (sessStatus == null)
	{
	  if (currentSession.getSynchronous())
	  {
	    // Ideally we would want to throw here, but the lack of a response for a synchronous session
	    // can also mean that the session set failed listener validation
	    // Eventually we will have to figure out how to distinguish listener validation failures from
	    // pipeline session errors. For now we will have to overlook this.
	  }
	}
	else // ... go ahead as planned, set the result session and the status code and message, if they were returned
	{
	  if (sessStatus.getSession() != null)
	    currentSession.setResultSession(sessStatus.getSession());
	  if (sessStatus.getCode() != null)
	    currentSession.setStatusCode(sessStatus.getCode().getValue());
	  if (sessStatus.getMessage() != null)
	    currentSession.setStatusMessage(sessStatus.getMessage().getValue());
	}
        //Setting the Error object in the child sessions
        Vector mChildSessions = currentSession.getChildSessions();
        Iterator itChild = mChildSessions.iterator();
        while (itChild.hasNext())
        {
          MTMeterMSIXSession currentChildSession = (MTMeterMSIXSession) itChild.next();
	  // Let's see if there is a response for this session
	  MSIXSessionStatus sessChildStatus = (MSIXSessionStatus) aStatusMap.get(currentChildSession.getSessionID());
          if( sessChildStatus != null )
          {
            if (sessChildStatus.getSession() != null)
              currentChildSession.setResultSession(sessChildStatus.getSession());
            if (sessChildStatus.getCode() != null)
              currentChildSession.setStatusCode(sessChildStatus.getCode().getValue());
            if (sessChildStatus.getMessage() != null)
              currentChildSession.setStatusMessage(sessChildStatus.getMessage().getValue());
          }
        }
      }
      catch (NoSuchElementException nse)
      {
	throw nse; // Nothing to do here about handling exception, just propagate
      }
      catch (MTException e)
      {
	throw e; // Nothing to do here about handling exception, just propagate
      }
    }
  }

  public void save () throws MTException
  {
  }

  public boolean getSynchronous ()
  {
    return mSynchronous;
  }

  public synchronized void setSynchronous (boolean doSynch)
  {
    mSynchronous = doSynch;

    if (doSynch)
      mFeedback.setValue ("Y");
    else
      mFeedback.setValue ("N");
  }

  protected synchronized void setInsert (String val)
  {
    mInsert.setValue (val);
  }

  protected synchronized void setCommit (String val)
  {
    mCommit.setValue (val);
  }

  protected synchronized void setFeedback (String val)
  {
    mFeedback.setValue (val);
  }

  protected void Initialize () throws MTException
  {
    setID (new MSIXUID());
    mInsert = new MSIXString (MSIXObject.MSIX_TAG_INSERT);
    mInsert.setValue ("Y");
    mCommit = new MSIXString (MSIXObject.MSIX_TAG_COMMIT);
    mCommit.setValue ("N");
    mFeedback = new MSIXString (MSIXObject.MSIX_TAG_FEEDBACK);
    mFeedback.setValue ("N");
    mSet = new Vector();

    // Auth variables
    mSessionContext = null;
    mSessionContextUsername = null;
    mSessionContextPassword = null;
    mSessionContextNamespace = null;
  }

  // Interface MSIXObject implementation
  public MSIXObject create (String type) throws MTException
  {
    MSIXObject obj = null;
    return obj;
  }

  public void parse (String type)
  {
    //TODO: should probably throw an exception here
  }

  public void complete (MSIXObject obj)
  {
    //TODO: figure out what to do here exactly
  }

  public void toStream (OutputStream stream) throws IOException
  {
    // Session Context Stuff
    Enumeration set = mSet.elements();
    while (set.hasMoreElements())
    {
      MTMeterMSIXSession itersession = (MTMeterMSIXSession) set.nextElement();
      itersession.toStream(stream);
    }
  }

  public MTMeterSessionSet getResultSessionSet()
  {
    return mResultSessionSet;
  }

  public boolean setupConnection(MTMeterConnection basicConnection) throws IOException
  {
    int intRetryCount = 0;
    boolean bConnected = false;
    while ((intRetryCount <= super.mMeter.getNumberofRetries()) && (!bConnected))
    {
      // System.out.println("[DEBUG] Checking connection by pooling, retry = " + intRetryCount);
      try
      {
	URL connectionURL = basicConnection.getMTConnectionURL();
	if ( connectionURL != null )
	{

	  int port = connectionURL.getPort(); // Grab either the port, or default to 80 if not set
	  if (port <= 0)
	    port = 80;

	  Socket s = TimedSocket.getSocket (
	    connectionURL.getHost(),
	    port,
	    super.mMeter.getTimeoutValue());
	  if (s == null)
	    throw new InterruptedIOException("Could not open socket on server. Will attempt " + super.mMeter.getNumberofRetries() + " retries in total.");
	  s.close();
	}
	bConnected = true; // Getting here without and exception throw means we have connected
      }
      catch (InterruptedIOException e) // This means that the attempt to connect to the server timed out or failed.
      {
	intRetryCount++;
	bConnected = false; // not necessary but good for clarification
      }
    }
    return bConnected;
  }

  // private and protected members
  private Boolean  		mValidate;
  private MSIXUID		mUID;
  private String  		mTransactionID;
  private MTMeterMSIXSession	mResultSession;
  private boolean		mSynchronous;
  private MTMeterMSIXSessionSet mResultSessionSet;
  private MSIXString		mInsert;
  private MSIXString		mCommit;
  private MSIXString		mFeedback;
  private String                mSessionContext;
  private String                mSessionContextUsername;
  private String                mSessionContextPassword;
  private String                mSessionContextNamespace;

}
