package com.metratech.sdk.base;

import java.util.*;
import java.text.*;
import java.io.*;

class MSIXTimeStamp implements MSIXObject
{
	protected MSIXTimeStamp ()
	{
		this.mValue = new Date();
	}
	
	protected Date getValue ()
	{
		return this.mValue;
	}

	public MSIXObject create (String type)
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
	
	public void complete (MSIXObject obj)
	{
	}
		
	public void toStream (OutputStream stream) throws IOException
	{
		// TODO: should probably make this format static
		SimpleDateFormat txtFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
		txtFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
		String aString = txtFormat.format(this.mValue);
		MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_TIMESTAMP);
		MSIXWriter.outputValue (stream, aString);
		MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_TIMESTAMP);
	}

	private Date mValue;
}

