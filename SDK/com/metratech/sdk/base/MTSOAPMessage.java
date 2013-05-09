package com.metratech.sdk.base;

import java.util.*;
import java.io.*;
import java.net.*;
import java.text.SimpleDateFormat;

/**
 * {internal}
 */
public class MTSOAPMessage implements SOAPObject
{
  protected MTSOAPMessage() throws MTException
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

    mName = "";
    mNamespace = "";
    mStatus = "";
  }

	void setID (long ID)
	{ this.mID = ID; }
	public long getID ()
	{ return mID; }
	
	// use package scope
	void setUID (String UID)
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

	public void setStatus (String status)
	{ this.mStatus = status; } 
	public String getStatus ()
	{ return mStatus; }

	public void setCompletionDate (Date completiondate)
	{ this.mCompletionDate = completiondate; } 
	public Date getCompletionDate ()
	{ return mCompletionDate; }

	public void setSource (String source)
	{ this.mSource = source; } 
	public String getSource ()
	{ return mSource; }

	public void setCreationDate (Date creationdate)
	{ this.mCreationDate = creationdate; } 
	public Date getCreationDate ()
	{ return mCreationDate; }

	public void setSourceCreationDate (Date sourcecreationdate)
	{ this.mSourceCreationDate = sourcecreationdate; } 
	public Date getSourceCreationDate ()
	{ return mSourceCreationDate; }

	public void setCompletedCount (long completedcount)
	{ this.mCompletedCount = completedcount; } 
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

	public void setFailureCount (long failurecount)
	{ this.mFailureCount = failurecount; } 
	public long getFailureCount ()
	{ return mFailureCount; }

	public void setMeteredCount (long meteredcount)
	{ this.mMeteredCount = meteredcount; } 
	public long getMeteredCount ()
	{ return mMeteredCount; }

	// use package scope
	void setMTErrorCode (String MTErrorCode)
	{ this.mMTErrorCode = MTErrorCode; }
	public String getMTErrorCode ()
	{ return mMTErrorCode; }

	// use package scope
	void setMTErrorMessage (String MTErrorMessage)
	{ this.mMTErrorMessage = MTErrorMessage; }
	public String getMTErrorMessage ()
	{ return mMTErrorMessage; }

	public String getMTErrorCodeString ()
	{ return (mMTErrorCode + " " + mMTErrorMessage); }
	
	//TODO -- Do I need to do anything here?
	public SOAPObject create (String type) throws MTException
	{
    SOAPObject obj = null;    		
    return obj;
	}

  protected synchronized void setBatch (MTMeterSOAPBatch batch)
  {
    this.mBatch = batch;
  }
	
  public void parse (String type)
  {
  }

  public void complete (SOAPObject obj)
  {
  }

  public void toStream (OutputStream stream, int action) throws IOException
  {
		// the following is standard stuff.  part of every soap message
		SOAPWriter.outputValue (stream, SOAPObject.XML_HEADER);
    SOAPWriter.outputValue (stream, SOAPObject.SOAP_ENVELOPE_HEADER);
    SOAPWriter.outputValue (stream, SOAPObject.SOAP_BODY_HEADER);

		if (action == SOAP_CALL_CREATE)
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_CREATE_METHOD);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_BATCH_LISTENER_HEADER);
			StreamObject(stream);
    	SOAPWriter.outputValue (stream, SOAPObject.SOAP_BATCH_LISTENER_TRAILER);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_CREATE_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_LOADBYNAME) 
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_LOADBYNAME_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_LOADBYNAME_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_LOADBYUID) 
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_LOADBYUID_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_LOADBYUID_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_MARKASFAILED)
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASFAILED_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASFAILED_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_MARKASACTIVE)
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASACTIVE_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASACTIVE_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_MARKASCOMPLETED)
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASCOMPLETED_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASCOMPLETED_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_MARKASBACKOUT)
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASBACKOUT_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASBACKOUT_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_MARKASDISMISSED)
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASDISMISSED_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_MARKASDISMISSED_METHOD_TRAILER);
		}
		else if (action == SOAP_CALL_UPDATEMETEREDCOUNT)
		{
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_UPDATEMETEREDCOUNT_METHOD_HEADER);
			GeneratePropertyStream(stream, action);
			SOAPWriter.outputValue (stream, SOAPObject.SOAP_UPDATEMETEREDCOUNT_METHOD_TRAILER);
		}
		else
		{
			// return error here
		}

		SOAPWriter.outputValue (stream, SOAPObject.SOAP_BODY_TRAILER);
		SOAPWriter.outputValue (stream, SOAPObject.SOAP_ENVELOPE_TRAILER);
    	    	
   	SOAPWriter.outputNewLine(stream);

		return;
	}


	public void StreamObject (OutputStream stream) throws IOException
	{
    SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_ID_TAG);
		Long ID = new Long(mBatch.getID());
		SOAPWriter.outputValue (stream, ID.toString());															
    SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_ID_TAG);

		// Name
    SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_NAME_TAG);
		SOAPWriter.outputValue (stream, mBatch.getName().toString());
    SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_NAME_TAG);
	
		// Namespace
    SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_NAMESPACE_TAG);
		SOAPWriter.outputValue (stream, mBatch.getNamespace().toString());
    SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_NAMESPACE_TAG);
	
		// CreationDate -- TODO: IS this conversion correct
    SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_CREATIONDATE_TAG);
		SimpleDateFormat creationDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
		SOAPWriter.outputValue (stream, creationDate.format(mBatch.getCreationDate()));
    SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_CREATIONDATE_TAG);
	
		// Source
    SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_SOURCE_TAG);
		SOAPWriter.outputValue (stream, mBatch.getSource().toString());
    SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_SOURCE_TAG);
	
		// CompletedCount
    SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_COMPLETEDCOUNT_TAG);
		Long completedCount = new Long(mBatch.getCompletedCount());
		SOAPWriter.outputValue (stream, completedCount.toString());
    SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_COMPLETEDCOUNT_TAG);

		// ExpectedCount
   	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_EXPECTEDCOUNT_TAG);
		Long expectedCount = new Long(mBatch.getExpectedCount());
		SOAPWriter.outputValue (stream, expectedCount.toString());
   	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_EXPECTEDCOUNT_TAG);
	
		// FailureCount
   	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_FAILURECOUNT_TAG);
		Long failureCount = new Long(mBatch.getFailureCount());
		SOAPWriter.outputValue (stream, failureCount.toString());
   	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_FAILURECOUNT_TAG);
	
		// SequenceNumber
   	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_SEQUENCENUMBER_TAG);
		SOAPWriter.outputValue (stream, mBatch.getSequenceNumber().toString());
   	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_SEQUENCENUMBER_TAG);
			
		// SourceCreationDate -- TODO: IS this conversion correct
   	SOAPWriter.outputOpeningTag (stream, 
																 SOAPObject.BATCH_SOURCECREATIONDATE_TAG);
		SimpleDateFormat sourceCreationDate = new SimpleDateFormat(
			"yyyy-MM-dd'T'HH:mm:ss'Z'");
		SOAPWriter.outputValue (stream, sourceCreationDate.format(mBatch.getSourceCreationDate()));
   	SOAPWriter.outputClosingTag (stream, 
																 SOAPObject.BATCH_SOURCECREATIONDATE_TAG);
		
		// MeteredCount
   	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_METEREDCOUNT_TAG);
		Long meteredCount = new Long(mBatch.getMeteredCount());
		SOAPWriter.outputValue (stream, meteredCount.toString());
   	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_METEREDCOUNT_TAG);

		return;
	}

	public void GeneratePropertyStream(OutputStream stream, int action) throws IOException
	{
		if (action == SOAP_CALL_LOADBYNAME)
		{
    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_NAME_TAG);
			SOAPWriter.outputValue (stream, mBatch.getName());
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_NAME_TAG);

    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_NAMESPACE_TAG);
			SOAPWriter.outputValue (stream, mBatch.getNamespace());
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_NAMESPACE_TAG);

    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_SEQUENCENUMBER_TAG);
			SOAPWriter.outputValue (stream, mBatch.getSequenceNumber());
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_SEQUENCENUMBER_TAG);
		}
		else if (action == SOAP_CALL_LOADBYUID) 
		{
    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_UID_TAG);
			SOAPWriter.outputValue (stream, mBatch.getUID().toString());
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_UID_TAG);
		}
		else if ((action == SOAP_CALL_MARKASFAILED) ||
						 (action == SOAP_CALL_MARKASDISMISSED) ||
						 (action == SOAP_CALL_MARKASBACKOUT) ||
						 (action == SOAP_CALL_MARKASACTIVE) ||
						 (action == SOAP_CALL_MARKASCOMPLETED))
		{
    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_UID_TAG);
			SOAPWriter.outputValue (stream, mBatch.getUID());
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_UID_TAG);

    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_COMMENT_TAG);
			SOAPWriter.outputValue (stream, mBatch.getComment());
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_COMMENT_TAG);
		}
		else if (action == SOAP_CALL_UPDATEMETEREDCOUNT)
		{
    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_UID_TAG);
			SOAPWriter.outputValue (stream, mBatch.getUID());
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_UID_TAG);

			int i = (int)mBatch.getMeteredCount();
    	SOAPWriter.outputOpeningTag (stream, SOAPObject.BATCH_METEREDCOUNT_TAG);
			SOAPWriter.outputValue (stream, String.valueOf(i));
    	SOAPWriter.outputClosingTag (stream, SOAPObject.BATCH_METEREDCOUNT_TAG);
		}
		else
		{
			// TODO: record error
		}
		
		return;
	}
	
  public SOAPStatus getSOAPStatus ()
  {
    return mSOAPStatus;
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

	private String mMTErrorCode;
	private String mMTErrorMessage;
	
	private SOAPStatus mSOAPStatus;
	private MTMeterSOAPBatch mBatch;
}
