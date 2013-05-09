package com.metratech.sdk.base;

import java.io.*;
import java.util.*;
import java.net.*;

import com.jclark.xml.*;
import com.jclark.xml.parse.*;
import com.jclark.xml.parse.io.*;

/**
 * This class implements the MTMeter interface. It functions as the highest level 
 * entry point into the SDK.
 */
public class MTMeterImpl extends MTMSIXParser implements MTMeter 
{    
  public static final int DEFAULT_TIMEOUTVALUE = 1000;
  public static final int DEFAULT_RETRYNUMBER = 2;

  public MTMeterImpl ()
  {
    this.mServerEntries = new Vector();
    this.msecTimeout = DEFAULT_TIMEOUTVALUE;
    this.mRetries    = DEFAULT_RETRYNUMBER;
  }
    
  public void startup() throws MTException
  {
	
  }
  public void shutdown() throws MTException
  {

  }
    
  public MTMeterSession createSession (// The name of the service.  
    // Must match the name of a service defined on
    // the metering server.
    String name) throws MTException
  {
    MTMeterMSIXSession session = new MTMeterMSIXSession(name);
    session.setOwner (this);
    return session;
  }

  public MTMeterSessionSet createSessionSet () throws MTException
  {
    MTMeterMSIXSessionSet set = new MTMeterMSIXSessionSet();
    set.setOwner (this);
    return set;
  }

  public MTMeterBatch createBatch () throws MTException
  {
    MTMeterSOAPBatch batch = new MTMeterSOAPBatch();
    batch.setOwner (this);
    return batch;
  }		

  public MTMeterBatch openBatchByUID (String UID) throws MTException
  {
    MTMeterSOAPBatch batch = new MTMeterSOAPBatch();
    batch.setOwner (this);
    batch.setUID(UID);
    batch.loadByUID();
    return batch;
  }		

  public MTMeterBatch openBatchByName (String name, String namespace, String sequenceNumber) throws MTException
  {
    MTMeterSOAPBatch batch = new MTMeterSOAPBatch();
    batch.setOwner (this);
    batch.setName(name);
    batch.setNamespace(namespace);
    batch.setSequenceNumber(sequenceNumber);
    batch.loadByName();
    return batch;
  }		

  public void meterStream (// Input stream containing sessions in metered format.
    InputStream stream) throws MTException
  {
    MTMSIXInputStream mis = new MTMSIXInputStream(stream);
    setStream(mis);
	
    while (!mis.getEndOfStream()) 
    {
      try 
      {
	MTMSIXMessage mttemp = doParse();
	mis.NextMsix();
      } 
      catch (NotWellFormedException e) 
      {
	// Warning: MessageId interface not declared
	// public: looking at it's string value instead
	//if (e.getMessage().equals("NO_DOCUMENT_ELEMENT"))
	if (e.getMessage().equals(":1:0: no document element") || e.getMessage().equals(":2:0: no document element")) 
	{
	  // No problem -- end of stream reached
	  break;
	}
	throw new MTParseException("Error parsing session " + e.toString());
      } 
      catch (IOException e) 
      {
	throw new MTParseException("Error parsing session " + e.toString());
      }
    }
  }
	
  public void complete (MSIXObject obj) throws MTException
  {
    MTMeterMSIXSession sess = null;
    MTMSIXMessage msg = null;
    try
    {
      // System.out.println("Getting here -- Murthy");
      // Logic to check whether the session already metered or not.
      // load the jounal file if it is not loaded already
      if ( ! m_bJournalLoaded )
      {
	System.out.println("Loading default journal file");
	setJournal(MTMeterImpl.DEFAULT_JOURNAL_FILE);
      }
      msg = (MTMSIXMessage)obj;
		
      // check if it has already metered.
      if ( mtJournal.hasSent(msg.getUID().valueToString()))
      {
	System.out.println("Skipping the session because it has already been metered.");
	return;
      }
		
      mtJournal.addItem(msg.getUID().valueToString(), MTJournal.STATUS_INPROGRESS);  
		    
      sess = msg.getSession();
      sess.setOwner (this);
      sess.close();
		
      mtJournal.addItem(msg.getUID().valueToString(), MTJournal.STATUS_SENT);
    }
    catch (MTException e)
    {
      String errStr = "Error Processing session ";
      if (msg != null)
	mtJournal.addItem(msg.getUID().valueToString(), MTJournal.STATUS_NOTSENT); 
      if (sess != null)
	errStr = errStr.concat (sess.getSessionID());

      throw new MTException (errStr + " " + e.toString());
    }
  }

  public synchronized void addServer (// The MTServerEntry object that
    // represents the configuration for
    // the server.
    MTServerEntry serverEntry) throws MTException
  {
    this.mServerEntries.addElement (serverEntry);
  }

  public synchronized void removeServer (// The name of the previously added connection.
    String name) throws MTException
  {
    MTMeterConnection temp = new MTFileConnection ();
    temp.setName (name);
    this.mServerEntries.removeElement (temp);
  }
    
  public synchronized void removeAllServerEntries()
  {
    this.mServerEntries.removeAllElements();
  }
    
	
  public synchronized Enumeration serverEntries()
  {
    return this.mServerEntries.elements();
  }
    
  public synchronized void setLoggingLevel (// The new logging level
    int logLevel)
  {
    this.mLoggingLevel = logLevel;
  }
	

  public synchronized int getLoggingLevel ()
  {
    return mLoggingLevel;
  }
    
  public synchronized void setLoggingStream (// The logging stream
    OutputStream logStream)
  {
    mLoggingStream = logStream;
  }
	
  public synchronized OutputStream getLogginStream ()
  {
    return mLoggingStream;
  }

  public synchronized String getJournal()
  {
    if ( mtJournal == null )
      return "";
            
    return mtJournal.getFileName();
  }

    
  public synchronized void setJournal(String strJournal) throws MTException
  {
    mtJournal = new MTJournal(strJournal);
    m_bJournalLoaded = true;
  }
    
  public synchronized void flushJournal()
  {
    mtJournal.writeJournal();
  }
    
  public int getTimeoutValue()
  {
    return msecTimeout;
  }

  public int getNumberofRetries()
  {
    return mRetries;
  }

  public void setTimeoutValue(int msecTimeout)
  {
    this.msecTimeout = msecTimeout;
  }

  public void setNumberofRetries(int mRetries)
  {
    this.mRetries = mRetries;
  }    
    
  private Vector mServerEntries;
  private static int mLoggingLevel = 0;
  private int msecTimeout;
  private int mRetries;
  protected boolean m_bJournalLoaded = false;
  private static OutputStream mLoggingStream;
  protected MTJournal mtJournal;
  protected static final String DEFAULT_JOURNAL_FILE = "sdkjournal.dat";
}
