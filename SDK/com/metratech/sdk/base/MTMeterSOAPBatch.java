package com.metratech.sdk.base;
					
import java.util.*;
import java.net.*;
import java.io.*;
import com.metratech.sdk.utils.*;
			
/**
 * {internal}
 * Description:
 *		MTMeterSOAPBatch class is derived from MTMeterBatch and is used for all Batch CRUD operations
 */
class MTMeterSOAPBatch extends MTMeterBatch
{
  protected MTMeterSOAPBatch () throws MTException
  {
    mID = -1;
    mUID = "";

    Calendar myDate = new GregorianCalendar();
    myDate.set(1970,0,1);

    mCreationDate = myDate.getTime(); // Jan 1, 1970 
    mSource = "";
    mCompletedCount = 0;
    mExpectedCount = 0;
    mFailureCount = 0;
    mSequenceNumber = "";
    mSourceCreationDate = null;
    mCompletionDate = myDate.getTime(); // Jan 1, 1970 
    mMeteredCount = 0;
    mComment = "";

    mName = "";
    mNamespace = "";
    mStatus = "";
  }

  // TODO: use package scope
  public void setID (long ID)
  { this.mID = ID; }
  public long getID ()
  { return mID; }
	
  // TODO: use package scope
  public void setUID (String UID)
  { this.mUID = UID; }
  public String getUID ()
  { return mUID; }

  public void setName (String name)
  { this.mName = name; } 
  public String getName ()
  { return mName; }

  public void setNamespace (String namespace)
  { this.mNamespace = namespace; } 
  public String getNamespace ()
  { return mNamespace; }

  // TODO: use package scope
  public void setStatus (String status)
  { this.mStatus = status; }
  public String getStatus ()
  { return mStatus; }

  // TODO: use package scope
  public void setCompletionDate (Date completionDate)
  { this.mCompletionDate = completionDate; }
  public Date getCompletionDate ()
  { return mCompletionDate; }

  public void setSource (String source)
  { this.mSource = source; } 
  public String getSource ()
  { return mSource; }

  // TODO: use package scope
  public void setCreationDate (Date creationDate)
  { this.mCreationDate = creationDate; }
  public Date getCreationDate ()
  { return mCreationDate; }

  public void setSourceCreationDate (Date sourcecreationdate)
  { this.mSourceCreationDate = sourcecreationdate; } 
  public Date getSourceCreationDate ()
  { return mSourceCreationDate; }

  // TODO: use package scope
  public void setCompletedCount (long completedCount)
  { this.mCompletedCount = completedCount; }
  public long getCompletedCount ()
  { return mCompletedCount; }

  public void setSequenceNumber (String sequencenumber)
  { this.mSequenceNumber = sequencenumber; } 
  public String getSequenceNumber ()
  { return mSequenceNumber; }

  public void setExpectedCount (long expectedcount)
  { this.mExpectedCount = expectedcount; } 
  public long getExpectedCount ()
  { return mExpectedCount; }

  // TODO: use package scope
  public void setFailureCount (long failureCount)
  { this.mFailureCount = failureCount; }
  public long getFailureCount ()
  { return mFailureCount; }

  public void setMeteredCount (long meteredcount)
  { this.mMeteredCount = meteredcount; } 
  public long getMeteredCount ()
  { return mMeteredCount; }

  public void setComment (String comment)
  { this.mComment = comment; } 
  public String getComment ()
  { return mComment; }

  public MTMeterMSIXSession createSession (String name) throws MTException
  {
    MTMeterMSIXSession newSession = new MTMeterMSIXSession();
    newSession.setBatch (this);
    newSession.setOwner (this.mMeter);
    return newSession;
  }

  public MTMeterMSIXSessionSet createSessionSet () throws MTException
  {
    MTMeterMSIXSessionSet newSessionSet = new MTMeterMSIXSessionSet();
    newSessionSet.setBatch (this);
    newSessionSet.setOwner (this.mMeter);
    return newSessionSet;
  }
	
  // need to set the collection id. ie. associate a session set with
  // the batch
  public void save() throws MTException
  {
    Enumeration serverEntries = super.mMeter.serverEntries();
    IOException lastError = null; 
    boolean bSuccess = false;
    SOAPStatusCode code = null;
    SOAPString stsMsg = null;

    // Loop through the connections
    try
    {
      while (serverEntries.hasMoreElements() && !bSuccess)
      {
	MTServerEntry currentServer = (MTServerEntry) serverEntries.nextElement();

	String webprotocol = "http";
	if (currentServer.getSecure())
	  webprotocol = "https";
	URL url = new URL (webprotocol,
			   currentServer.getServerName(), 
			   new Long(currentServer.getPortNumber()).intValue(), 
			   MTMeterConnection.DEFAULT_BATCH_LISTENER);

	// TODO: make literals
	MTMeterConnection myConnection = (MTMeterConnection) new MTSOAPConnection("javaSDK SOAP connection", 
										  url, 
										  "Create", 
										  currentServer.getUserName(), 
										  currentServer.getPassword());

	// This function attempts to open a connection by pooling a socket on the server, on the proper port
	// If it returns false, we need to throw an exception because a connection was not possible
	if (!setupConnection(myConnection))
	{
	  throw new MTException("This SDK client was unable to stabilish a connection to the server. Please check your server entry configuration.");
	}
						
	OutputStream myStream = myConnection.getOutputStream();
    	            	
	// Create a new message
	MTSOAPMessage soapMsg = new MTSOAPMessage();
	
	// Add our batch to it
	soapMsg.setBatch(this);
    					
	// stream the data to the output stream
	soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_CREATE);
	
	// close the stream
	myStream.close();

	// Get a response
	InputStream Input = null;				
	try
	{
	  Input = myConnection.getInputStream();
	  // A MTFileConnection object returns a null (a file won't respond)
	  // we are not doing localmode here.  so throw an exception here 
	  if (Input == null) 
	  {
	    System.out.println ("Input is null"); // This is ok since it is not an exception, but would be good to have a log file for the sdk
	    return;
	  }
	}
	catch (IOException e)
	{
	  // Create the parser
	  MTSOAPParser myParser = new MTSOAPParser();

	  // Parse the exception
	  if (myConnection.getConnection().getResponseCode() == 500)
	  {
	    InputStream exceptionStream = myConnection.getConnection().getErrorStream();
	    // now that the exception is caught, grab the code and the
	    // message and then we are all done handling the exception and
	    // the error
	    MTSOAPMessage errMsg = myParser.parseSOAPException(exceptionStream);
	    throw new MTException (errMsg.getMTErrorCodeString());
	  }
	  
	  Input.close();
	  return;
	}
				    					
	// A MTFileConnection object returns a null (a file won't respond)
	// we are not doing localmode here.  so throw an exception here 
	if (Input == null) 
	  return;    				
	
	// Create the parser
	MTSOAPParser myParser = new MTSOAPParser();
	
	// Parse the response 
	MTSOAPMessage myMessage = myParser.parse(Input, SOAPObject.CREATE_RESULT_TAG);
	
	// CR -- inherit from soap message.  that way soap error messages
	// also could be caught
	this.setUID(myMessage.getUID());

	Input.close();
			
	// We're done
	bSuccess = true;
      }
    }
    catch (IOException ioEx)
    {
      System.out.println("IO Exception (Message): " + ioEx.getMessage());
      lastError = ioEx;
    }
	
    return;
  }

  public void loadByUID() throws MTException
  {
    load("UID");
    return;
  }

  public void loadByName () throws MTException
  {
    load("name");
    return;
  }

  public void refresh ()
  {

  }

  public void markAsActive (String comment) throws MTException
  {
    changeState(comment, "active");
    return;
  }

  public void markAsBackout (String comment) throws MTException
  {
    changeState(comment, "backout");
    return;
  }

  public void markAsFailed (String comment) throws MTException
  {
    changeState(comment, "failed");
    return;
  }

  public void markAsDismissed (String comment) throws MTException
  {
    changeState(comment, "dismissed");
    return;
  }

  public void markAsCompleted (String comment) throws MTException
  {
    changeState(comment, "completed");
    return;
  }

  //
  //
  //
  public void updateMeteredCount (long meteredCount) throws MTException
  {
    Enumeration serverEntries = super.mMeter.serverEntries();
    IOException lastError = null; 
    boolean bSuccess = false;

    SOAPStatusCode code = null;
    SOAPString stsMsg = null;

    // Loop through the connections
    try
    {
      while (serverEntries.hasMoreElements() && !bSuccess)
      {
	MTServerEntry currentServer = (MTServerEntry) serverEntries.nextElement();
				
	String webprotocol = "http";
	if (currentServer.getSecure())
	  webprotocol = "https";
	URL url = new URL (webprotocol,
			   currentServer.getServerName(), 
			   new Long(currentServer.getPortNumber()).intValue(), 
			   MTMeterConnection.DEFAULT_BATCH_LISTENER);

	// set the metered count before constructing the request
	this.setMeteredCount(meteredCount);

	// TODO: make literals
	MTMeterConnection myConnection = (MTMeterConnection) new MTSOAPConnection("javaSDK SOAP connection", 
										  url, 
										  "UpdateMeteredCount",
										  currentServer.getUserName(), 
										  currentServer.getPassword());
	setupConnection(myConnection);
	
	OutputStream myStream = myConnection.getOutputStream();
    	            	
	// Create a new message
	MTSOAPMessage soapMsg = new MTSOAPMessage();
	
	// Add our batch to it
	soapMsg.setBatch(this);
    					
	// stream the data to the output stream
	soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_UPDATEMETEREDCOUNT);

	// close the stream
	myStream.close();
	
	// Get a response
	InputStream Input = null;				
	try
	{
	  Input = myConnection.getInputStream();
	  // A MTFileConnection object returns a null (a file won't respond)
	  // we are not doing localmode here.  so throw an exception here 
	  if (Input == null) 
	  {
	    System.out.println ("Input is null");
	    return;  
	  }
	}
	catch (IOException e)
	{
	  // Create the parser
	  MTSOAPParser myParser = new MTSOAPParser();

	  // Parse the exception
	  if (myConnection.getConnection().getResponseCode() == 500)
	  {
	    InputStream exceptionStream = myConnection.getConnection().getErrorStream();
	    // now that the exception is caught, grab the code and the
	    // message and then we are all done handling the exception and
	    // the error
	    MTSOAPMessage errMsg = myParser.parseSOAPException(exceptionStream);
	    throw new MTException (errMsg.getMTErrorCodeString());
	  }

	  Input.close();
				
	  return;
	}
    					
	// A MTFileConnection object returns a null (a file won't respond)
	// we are not doing localmode here.  so throw an exception here 
	if (Input == null) 
	  return;    				
	
	// Create the parser
	MTSOAPParser myParser = new MTSOAPParser();
	
	// Parse the response 
	MTSOAPMessage myMessage = myParser.parse(Input, 
						 SOAPObject.UPDATEMETEREDCOUNT_RESULT_TAG);

	Input.close();
			
	// We're done
	bSuccess = true;
      }
    }
    catch (IOException ioEx)
    {
      System.out.println(
	"IO Exception while updating metered count: " + ioEx.getMessage());
      lastError = ioEx;
    }
	
    return;
  }

  //
  //
  //
  public void load(String type) throws MTException
  {
    Enumeration serverEntries = super.mMeter.serverEntries();
    IOException lastError = null; 
    boolean bSuccess = false;
    SOAPStatusCode code = null;
    SOAPString stsMsg = null;

    // Loop through the connections
    try
    {
      while (serverEntries.hasMoreElements() && !bSuccess)
      {
	MTServerEntry currentServer = (MTServerEntry) serverEntries.nextElement();

	String webprotocol = "http";
	if (currentServer.getSecure())
	  webprotocol = "https";
	URL url = new URL (webprotocol,
			   currentServer.getServerName(), 
			   new Long(currentServer.getPortNumber()).intValue(), 
			   MTMeterConnection.DEFAULT_BATCH_LISTENER);
					
	String strRequest;
	if (0 == type.compareToIgnoreCase("UID"))
	  strRequest = "LoadByUID";
	else if (0 == type.compareToIgnoreCase("name"))
	  strRequest = "LoadByName";
	else // TODO: return error here
	  throw new MTException ("Load by unknown type " + type + "requested");

	//
	MTMeterConnection myConnection = (MTMeterConnection) new MTSOAPConnection("javaSDK SOAP connection", 
										  url, 
										  strRequest,
										  currentServer.getUserName(), 
										  currentServer.getPassword());
	setupConnection(myConnection);
	
	OutputStream myStream = myConnection.getOutputStream();
    	            	
	// Create a new message
	MTSOAPMessage soapMsg = new MTSOAPMessage();
	
	// Add our batch to it
	soapMsg.setBatch(this);
    					
	// stream the data to the output stream
	if (0 == type.compareToIgnoreCase("UID"))
	  soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_LOADBYUID);
	else if (0 == type.compareToIgnoreCase("name"))
	  soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_LOADBYNAME);
	else // TODO: return error here
	  throw new MTException ("Load by unknown type " + type + "requested");
	
	// close the stream
	myStream.close();
	
	// Get a response
	InputStream Input = null;				
	try
	{
	  Input = myConnection.getInputStream();
	  // A MTFileConnection object returns a null (a file won't respond)
	  // we are not doing localmode here.  so throw an exception here 
	  if (Input == null) 
	  {
	    System.out.println ("Input is null");
	    return;  
	  }
	}
	catch (IOException e)
	{
	  // Create the parser
	  MTSOAPParser myParser = new MTSOAPParser();

	  // Parse the exception
	  if (myConnection.getConnection().getResponseCode() == 500)
	  {
	    InputStream exceptionStream = myConnection.getConnection().getErrorStream();
	    // now that the exception is caught, grab the code and the
	    // message and then we are all done handling the exception and
	    // the error
	    MTSOAPMessage errMsg = myParser.parseSOAPException(exceptionStream);
	    throw new MTException (errMsg.getMTErrorCodeString());
	  }

	  Input.close();
				
	  return;
	}
				
	// A MTFileConnection object returns a null (a file won't respond)
	// we are not doing localmode here.  so throw an exception here 
	if (Input == null) 
	  return;    				
	
	// Create the parser
	MTSOAPParser myParser = new MTSOAPParser();
	
	// Parse the response 
	MTSOAPMessage myMessage;
	if (0 == type.compareToIgnoreCase("UID"))
	  myMessage = myParser.parse(Input, SOAPObject.LOADBYUID_RESULT_TAG);
	else if (0 == type.compareToIgnoreCase("name"))
	  myMessage = myParser.parse(Input, SOAPObject.LOADBYNAME_RESULT_TAG);
	else // TODO: return error here
	  throw new MTException ("Load by unknown type " + type + "requested");
	
	// set all the properties on the batch object
	setUID(myMessage.getUID());
	setID(myMessage.getID());
	setName(myMessage.getName());
	setNamespace(myMessage.getNamespace());
	setStatus(myMessage.getStatus());
	setCreationDate(myMessage.getCreationDate());
	setSource(myMessage.getSource());
	setCompletedCount(myMessage.getCompletedCount());
	setExpectedCount(myMessage.getExpectedCount());
	setFailureCount(myMessage.getFailureCount());
	setSequenceNumber(myMessage.getSequenceNumber());
	setSourceCreationDate(myMessage.getSourceCreationDate());
	setMeteredCount(myMessage.getMeteredCount());
				
	Input.close();
			
	// We're done
	bSuccess = true;
      }
    }
    catch (IOException ioEx)
    {
      System.out.println(
	"MTMeterSOAPBatch::IO Exception while sending session: " + ioEx.getMessage());
      lastError = ioEx;
    }
	
    return;
  }

  //
  //
  //
  public void changeState (String comment, String newState) throws MTException
  {
    Enumeration serverEntries = super.mMeter.serverEntries();
    IOException lastError = null; 
    boolean bSuccess = false;

    SOAPStatusCode code = null;
    SOAPString stsMsg = null;

    // Loop through the connections
    try
    {
      while (serverEntries.hasMoreElements() && !bSuccess)
      {
	MTServerEntry currentServer = (MTServerEntry) serverEntries.nextElement();

	String webprotocol = "http";
	if (currentServer.getSecure())
	  webprotocol = "https";
	URL url = new URL (webprotocol,
			   currentServer.getServerName(), 
			   new Long(currentServer.getPortNumber()).intValue(), 
			   MTMeterConnection.DEFAULT_BATCH_LISTENER);
				
	// set the comment before constructing the request
	this.setComment(comment);

	String strRequest;
	if (0 == newState.compareToIgnoreCase("active"))
	  strRequest = "MarkAsActive";
	else if (0 == newState.compareToIgnoreCase("failed"))
	  strRequest = "MarkAsFailed";
	else if (0 == newState.compareToIgnoreCase("backout"))
	  strRequest = "MarkAsBackout";
	else if (0 == newState.compareToIgnoreCase("completed"))
	  strRequest = "MarkAsCompleted";
	else if (0 == newState.compareToIgnoreCase("dismissed"))
	  strRequest = "MarkAsDismissed";
	else // TODO: return error here
	  throw new MTException ("Transition to unknown state " + newState + "requested");

	// TODO: make literals
	MTMeterConnection myConnection = (MTMeterConnection) new MTSOAPConnection("javaSDK SOAP connection", 
										  url, 
										  strRequest,
										  currentServer.getUserName(), 
										  currentServer.getPassword());
	setupConnection(myConnection);
	
	OutputStream myStream = myConnection.getOutputStream();
    	            	
	// Create a new message
	MTSOAPMessage soapMsg = new MTSOAPMessage();
	
	// Add our batch to it
	soapMsg.setBatch(this);
    					
	// stream the data to the output stream
	if (0 == newState.compareToIgnoreCase("active"))
	  soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_MARKASACTIVE);
	else if (0 == newState.compareToIgnoreCase("failed"))
	  soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_MARKASFAILED);
	else if (0 == newState.compareToIgnoreCase("backout"))
	  soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_MARKASBACKOUT);
	else if (0 == newState.compareToIgnoreCase("completed"))
	  soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_MARKASCOMPLETED);
	else if (0 == newState.compareToIgnoreCase("dismissed"))
	  soapMsg.toStream(myStream, SOAPObject.SOAP_CALL_MARKASDISMISSED);
	else // TODO: return error here
	  throw new MTException ("Transition to unknown state " + newState + "requested");

	// close the stream
	myStream.close();
	
	// Get a response
	InputStream Input = null;				
	try
	{
	  Input = myConnection.getInputStream();
	  // A MTFileConnection object returns a null (a file won't respond)
	  // we are not doing localmode here.  so throw an exception here 
	  if (Input == null) 
	  {
	    System.out.println ("Input is null");
	    return;  
	  }
	}
	catch (IOException e)
	{
	  // Create the parser
	  MTSOAPParser myParser = new MTSOAPParser();

	  // Parse the exception
	  if (myConnection.getConnection().getResponseCode() == 500)
	  {
	    InputStream exceptionStream = myConnection.getConnection().getErrorStream();
	    // now that the exception is caught, grab the code and the
	    // message and then we are all done handling the exception and
	    // the error
	    MTSOAPMessage errMsg = myParser.parseSOAPException(exceptionStream);
	    throw new MTException (errMsg.getMTErrorCodeString());
	  }

	  Input.close();
				
	  return;
	}
							
	// A MTFileConnection object returns a null (a file won't respond)
	// we are not doing localmode here.  so throw an exception here 
	if (Input == null) 
	  return;    				
	
	// Create the parser
	MTSOAPParser myParser = new MTSOAPParser();
	
	// Parse the response 
	MTSOAPMessage myMessage;
	if (0 == newState.compareToIgnoreCase("active"))
	{
	  myMessage = myParser.parse(Input, SOAPObject.MARKASACTIVE_RESULT_TAG);
	  this.setStatus("A");
	}
	else if (0 == newState.compareToIgnoreCase("failed"))
	{
	  myMessage = myParser.parse(Input, SOAPObject.MARKASFAILED_RESULT_TAG);
	  this.setStatus("F");
	}
	else if (0 == newState.compareToIgnoreCase("backout"))
	{
	  myMessage = myParser.parse(Input, SOAPObject.MARKASBACKOUT_RESULT_TAG);
	  this.setStatus("B");
	}
	else if (0 == newState.compareToIgnoreCase("completed"))
	{
	  myMessage = myParser.parse(Input, SOAPObject.MARKASCOMPLETED_RESULT_TAG);
	  this.setStatus("C");
	}
	else if (0 == newState.compareToIgnoreCase("dismissed"))
	{
	  myMessage = myParser.parse(Input, SOAPObject.MARKASDISMISSED_RESULT_TAG);
	  this.setStatus("D");
	}
	else // TODO: return error here
	  throw new MTException ("Transition to unknown state " + newState + "requested");
	
	Input.close();
			
	// We're done
	bSuccess = true;
      }
    }
    catch (IOException ioEx)
    {
      System.out.println(
	"MTMeterSOAPBatch::IO Exception while sending session: " + ioEx.getMessage());
      lastError = ioEx;
    }
	
    return;
  }

  public boolean setupConnection(MTMeterConnection basicConnection) throws IOException
  {
    int intRetryCount = 0;
    boolean bConnected = false;

    while ((intRetryCount <= super.mMeter.getNumberofRetries()) && (!bConnected))
    {
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

  private long mID;
  private String mUID;
  private String mName;
  private String mNamespace;
  private String mStatus;
  private Date mCompletionDate;
  private String mSource;
  private Date mCreationDate;
  private Date mSourceCreationDate;
  private long mCompletedCount;
  private String mSequenceNumber;
  private long mExpectedCount;
  private long mFailureCount;
  private long mMeteredCount;
  private String mComment;
}
