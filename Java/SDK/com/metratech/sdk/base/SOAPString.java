package com.metratech.sdk.base;

import java.io.*;

/**
 * {internal}
 */
class SOAPString implements SOAPObject
{
	// TODO -- the constructor should probably take the value as well
	protected SOAPString (String name)
	{
		this.mName = name;
	}
	
	protected synchronized void setName(String name)
	{
		this.mName = name;
	}
	
	protected synchronized void setValue(String val)
	{
		this.mValue = val;
	}
	
	protected String getName ()
	{
		return this.mName;
	}

	protected String getValue ()
	{
		return this.mValue;
	}

	
	public SOAPObject create (String type)
	{
		return null;
	}
	
	public void parse (String data)
	{
		this.mValue = data;
	}
	
	public void complete (SOAPObject obj)
	{
	}
	
	// TODO: There should be no action  here
	public void toStream (OutputStream stream, int action) throws IOException
	{
		SOAPWriter.outputOpeningTag (stream, this.mName);
		SOAPWriter.outputValue (stream, this.mValue);
		SOAPWriter.outputClosingTag (stream, this.mName);
	}

	private String mName;	
	private String mValue;
}
