package com.metratech.sdk.base;

import java.io.*;

class SOAPWriter
{

	protected static void outputOpeningTag (OutputStream stream, String tag) throws IOException
	{
		stream.write(SOAPObject.SOAP_OPENINGTAG_PREFIX.getBytes());
		stream.write(tag.getBytes());
		stream.write(SOAPObject.SOAP_OPENINGTAG_SUFFIX.getBytes());
	}
	
	protected static void outputValue (OutputStream stream, String val) throws IOException
	{
		stream.write(val.getBytes());
	}
	
	protected static void outputClosingTag (OutputStream stream, String tag) throws IOException
	{
		stream.write(SOAPObject.SOAP_CLOSINGTAG_PREFIX.getBytes());
		stream.write(tag.getBytes());
		stream.write(SOAPObject.SOAP_CLOSINGTAG_SUFFIX.getBytes());
	}
	
	protected static void outputNewLine(OutputStream stream) throws IOException
	{
	    stream.write(System.getProperty("line.separator").getBytes());    
	}
	
}
