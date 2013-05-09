package com.metratech.sdk.base;

import java.io.*;

/**
 * {internal}
 */
class SOAPStatusCode implements SOAPObject
{
	protected SOAPStatusCode ()
	{
		this.mValue = new Long(0);
	}
	
	protected String getName ()
	{
		return this.mName;
	}

	protected long getValue ()
	{
		return this.mValue.longValue();
	}
	
	protected Long getLongValue ()
	{
		return this.mValue;
	}
	
	public SOAPObject create (String type)
	{
		return null;
	}
	
	public void parse (String data) throws MTException
	{
		try 
		{		
			this.mValue = Long.valueOf(data,16);
		}
		catch (NumberFormatException ex)
		{
			throw new MTException ("Error parsing status code " + ex);
		}
	}
	
	public void complete (SOAPObject obj)
	{
	}
		
	public void toStream (OutputStream stream, int action) throws IOException
	{
		SOAPWriter.outputOpeningTag (stream, mName);
		SOAPWriter.outputValue (stream, this.mValue.toString());
		SOAPWriter.outputClosingTag (stream, mName);
	}
	
	private String	mName;	
	private Long	mValue;
}
