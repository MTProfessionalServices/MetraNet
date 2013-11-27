package com.metratech.sdk.base;
					
import java.util.*;
import java.net.*;
import java.io.*;
import java.lang.Object;
import com.metratech.sdk.utils.*;
			
/**
 * {internal}
 * Description:
 *		MTMeterMSIXSession class provides an MSIX Protocol implementation of the 
 *		MTMeterSession class.
 *     {hyperlink:For more information about the MSIX Protocol|http://www.msix.org}.
 */
class MTMeterMSIXSession extends MTMeterSession implements MSIXObject
{
  protected MTMeterMSIXSession () throws MTException
  {
    Initialize();
  }
	
  protected MTMeterMSIXSession (String name)	throws MTException
  { 
    if (name.length() == 0)
      throw new MTSessionException ("Session name is required");

    Initialize();
    setName (name);
  }
	
  public MTMeterSession createChildSession (String name) throws MTException
  {
    MTMeterMSIXSession child = new MTMeterMSIXSession (name);
    mChildren.addElement (child);
    child.setParent (this);
    return child;
  }
	
  public void close() throws MTException
  {
    Enumeration serverEntries = super.mMeter.serverEntries();
    IOException lastError = null; 
    boolean bSuccess = false;
    boolean bFoundOne = false;
				
    // Children get sent with their parent
    if (this.mParent != null)
      return;

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
	message.setSession(this);

	// stream the data to the output stream
	message.toStream(myStream);

	// close the stream
	myStream.close();

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

	// Handle a sychronous response
	if (this.getSynchronous())
	{
	  this.mResultSession = myMessage.getSession();

	  if (sts.getCode() != null)
	    this.setStatusCode(sts.getCode().getValue());
	  if (sts.getMessage() != null)
	    this.setStatusMessage(sts.getMessage().getValue());
	}

	Input.close();

	// We're done
	bSuccess = true;
      }
    }
    catch (IOException ioEx)
    {
      System.out.println("IO Exception while sending session: " + 
			 ioEx.getMessage());
      lastError = ioEx;
    }

    if (!bFoundOne)
      throw new MTSessionException("No serverEntries defined");

    if (!bSuccess)
      throw new MTSessionException("Could not meter to any server.  Last error: " + lastError.toString());

    if (mStatusCode != 0)
    {
      if (mStatusMessage == null)
	throw new MTSessionException(mStatusCode, "Server error : " + mStatusCode + ". No specific error message was found.");
      else
	throw new MTSessionException(mStatusCode, "Server error : " + mStatusMessage);
    }

    // update the batch metered count
    if (mBatch != null)
      mBatch.updateMeteredCount(1);
			
    return;
  }
	
  public void save () throws MTException
  {
  }
	
  public MTMeterSession getResultSession ()
  {
    return mResultSession;
  }

  public void setResultSession(MTMeterMSIXSession aSession)
  {
    this.mResultSession = aSession;
  }
  
  public boolean getSynchronous()
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

  protected synchronized void setUID (MSIXUID uid)
  {
    mUID = uid;
    super.sessionID = mUID.valueToString();
  }
 
  protected synchronized void setProperties (MSIXPropertyList props)
  {
    Enumeration aList = props.properties();
    while (aList.hasMoreElements())
    {
      MSIXProperty aProp = (MSIXProperty)aList.nextElement();
      MSIXString aVal = (MSIXString)aProp.getValue().getValue();
      setProperty (aProp.getName().getValue(), (Object)aVal.getValue());
    }
  }
	
  protected void Initialize () throws MTException
  {
    setUID (new MSIXUID());
    mInsert = new MSIXString (MSIXObject.MSIX_TAG_INSERT);
    mInsert.setValue ("Y");
    mCommit = new MSIXString (MSIXObject.MSIX_TAG_COMMIT);
    mCommit.setValue ("N");
    mFeedback = new MSIXString (MSIXObject.MSIX_TAG_FEEDBACK);
    mFeedback.setValue ("N");
    mChildren = new Vector();
  }

  // Interface MSIXObject implementation
  public MSIXObject create (String type) throws MTException
  {
    MSIXObject obj = null;
    if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_DISTINGUISEDNAME))
    {
      MSIXString msg = new MSIXString(type);
      obj = (MSIXObject)msg;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_UID))
    {
      MSIXUID UID = new MSIXUID();
      obj = (MSIXObject)UID;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_INSERT))
    {
      MSIXString msg = new MSIXString(type);
      obj = (MSIXObject)msg;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_COMMIT))
    {
      MSIXString msg = new MSIXString(type);
      obj = (MSIXObject)msg;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_FEEDBACK))
    {
      MSIXString msg = new MSIXString(type);
      obj = (MSIXObject)msg;
    }
    else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_PROPERTIES))
    {
      MSIXPropertyList props = new MSIXPropertyList();
      obj = (MSIXObject)props;
    }
				
    return obj;
  }
	
  public void parse (String type)
  {
    //TODO: should probably throw an exception here
  }

  public void complete (MSIXObject obj)
  {
    if (obj instanceof MSIXString)
    {
      MSIXString str = (MSIXString)obj;
      String name = str.getName();
      if (name.equalsIgnoreCase (MSIXObject.MSIX_TAG_DISTINGUISEDNAME))
	setName (str.getValue());
      else if (name.equalsIgnoreCase (MSIXObject.MSIX_TAG_INSERT))
	setInsert (str.getValue());
      else if (name.equalsIgnoreCase (MSIXObject.MSIX_TAG_COMMIT))
	setCommit (str.getValue());
      else if (name.equalsIgnoreCase (MSIXObject.MSIX_TAG_FEEDBACK))
	setFeedback (str.getValue());
    }
    else if (obj instanceof MSIXPropertyList)
      setProperties ((MSIXPropertyList)obj);
    else if (obj instanceof MSIXUID)
      setUID ((MSIXUID)obj);
  }
	
  public void toStream (OutputStream stream) throws IOException
  {
    // <BeginSession>
    MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_BEGINSESSION);
		
    // dn
    MSIXString dn = new MSIXString (MSIXObject.MSIX_TAG_DISTINGUISEDNAME);
    dn.setValue (super.mName);
    dn.toStream (stream);
		
    // UID
    mUID.toStream(stream);
		
    // Parent ID
    if (this.mParent != null)
    {
      MSIXString pID = new MSIXString (MSIXObject.MSIX_TAG_PARENTID);
      pID.setValue (mParent.sessionID);
      pID.toStream (stream);
    }
		
    // Commit
    mCommit.toStream (stream);
		
    // Insert
    mInsert.toStream (stream);
		
    // Feedback
    mFeedback.toStream (stream);
		
    // Properties
    MSIXPropertyList aList = new MSIXPropertyList ();
    Enumeration props = super.properties();
    while (props.hasMoreElements())
    {
      MTMeterProperty aProp = (MTMeterProperty)props.nextElement();
      MSIXProperty msixProp = new MSIXProperty (aProp.getName(), aProp.getValue());
      aList.addProperty (msixProp);
    }
    aList.toStream(stream);
		
    // </BeginSession>
    MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_BEGINSESSION);
    Enumeration children = mChildren.elements();
    while (children.hasMoreElements())
    {
      MTMeterMSIXSession child = (MTMeterMSIXSession)children.nextElement();
      child.toStream(stream);
    }
  }

  public boolean setupConnection(MTMeterConnection basicConnection) throws IOException
  {
    int intRetryCount = 0;
    boolean bConnected = false;
    while ((intRetryCount <= super.mMeter.getNumberofRetries()) && (!bConnected))
    {
      //System.out.println("[DEBUG] Checking connection by pooling, retry = " + intRetryCount);
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
	
  private MSIXString		mInsert;
  private MSIXString		mCommit;
  private MSIXString		mFeedback;
  private MSIXUID		mUID;
  private MTMeterMSIXSession	mResultSession;
  private boolean		mSynchronous;
}
