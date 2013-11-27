package com.metratech.sdk.base;

import java.io.*;

/**
 * {internal}
 */

class SOAPStatus implements SOAPObject
{
	protected SOAPStatus()
	{
	}

	protected SOAPStatusCode getCode()
	{
		return this.mCode;
	}

	protected SOAPString getMessage()
	{
		return this.mMessage;
	}
	
	protected synchronized void setCode (SOAPStatusCode code)
	{
		this.mCode = code;
	}

	protected synchronized void setMessage (SOAPString msg)
	{
		this.mMessage = msg;
	}
	
	public SOAPObject create (String type)
	{
		SOAPObject obj = null;
		/*
		if (type.equalsIgnoreCase(SOAPObject.SOAP_TAG_CODE))
		{
			SOAPStatusCode anInt = new SOAPStatusCode();
			obj = (SOAPObject)anInt;
		}
		else if (type.equalsIgnoreCase(SOAPObject.SOAP_TAG_STATUSMESSAGE))
		{
			SOAPString aString = new SOAPString(type);
			obj = (SOAPObject)aString;
		}
		*/			
		return obj;
	}
	
	public void parse (String type) throws MTParseException
	{
		throw new MTParseException ("Unexpected data in aggregate");		
	}

	public void complete (SOAPObject obj)
	{
		if (obj instanceof SOAPStatusCode)
		{
			SOAPStatusCode aCode = (SOAPStatusCode)obj;
			setCode (aCode);
		}
		else if (obj instanceof SOAPString)
		{
			SOAPString aMsg = (SOAPString)obj;
			setMessage (aMsg);
		}			
		
	}

	public void toStream (OutputStream stream, int action) throws IOException
	{
		/*
		SOAPWriter.outputOpeningTag (stream, SOAPObject.SOAP_TAG_STATUS);
		this.mCode.toStream (stream);
		SOAPWriter.outputClosingTag (stream, SOAPObject.SOAP_TAG_STATUS);
		*/
	}
		
	private SOAPStatusCode	mCode;
	private SOAPString		mMessage;
}

