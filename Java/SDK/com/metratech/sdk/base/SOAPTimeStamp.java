package com.metratech.sdk.base;

import java.util.*;
import java.text.*;
import java.io.*;

class SOAPTimeStamp implements SOAPObject
{
	protected SOAPTimeStamp ()
	{
		this.mValue = new Date();
	}
	
	protected Date getValue ()
	{
		return this.mValue;
	}

	public SOAPObject create (String type)
	{
		return null;
	}
	
	public void parse (String data) throws MTParseException
	{
		try
		{
			SimpleDateFormat txtDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
			this.mValue = txtDate.parse(data);
		}
		catch (ParseException e)
		{
			throw new MTParseException ("Error parsing timestamp " + e);
		}
	}
	
	public void complete (SOAPObject obj)
	{
	}
	
	//TODO -- action is not really needed here.  need to take it out
	public void toStream (OutputStream stream, int action) throws IOException
	{
		// TODO: should probably make this format static
		SimpleDateFormat txtFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
		txtFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
		String aString = txtFormat.format(this.mValue);
		//SOAPWriter.outputOpeningTag (stream, SOAPObject.SOAP_TAG_TIMESTAMP);
		SOAPWriter.outputValue (stream, aString);
		//SOAPWriter.outputClosingTag (stream, SOAPObject.SOAP_TAG_TIMESTAMP);
	}

	private Date mValue;
}

