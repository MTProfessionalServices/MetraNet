package com.metratech.sdk.base;

import java.io.*;
import java.util.Date;
import java.util.TimeZone;
import java.text.SimpleDateFormat;

/**
 * {internal}
 */
class MSIXValue implements MSIXObject
{
	protected MSIXValue (String name)
	{
		this.mName = name;
	}
	
	protected String getName ()
	{
		return this.mName;
	}

	protected Object getValue ()
	{
		return this.mValue;
	}
		
	protected synchronized void setValue (Object obj)
	{
		this.mValue = obj;
	}
	
	public MSIXObject create (String type)
	{
		return null;
	}
	
	public void parse (String data) throws MTParseException
	{
		throw new MTParseException ("Unexpected data in aggregate");
	}
	
	public void complete (MSIXObject obj)
	{
	}
	
	public void toStream (OutputStream stream) throws IOException
	{
		MSIXWriter.outputOpeningTag(stream, this.mName);
		if (mValue instanceof Date) {
			SimpleDateFormat txtFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
			txtFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
			MSIXWriter.outputValue(stream, txtFormat.format(this.mValue));	
		} else if (mValue instanceof Boolean) {
			if (((Boolean)mValue).booleanValue()) {
	   	        MSIXWriter.outputValue(stream, "T");
		    } else {
				MSIXWriter.outputValue(stream, "F");
		    }
		}
		else
			MSIXWriter.outputValue(stream, this.mValue.toString());
		
		MSIXWriter.outputClosingTag(stream, this.mName);
	}
	
	private String	mName;	
	private Object	mValue;
}
