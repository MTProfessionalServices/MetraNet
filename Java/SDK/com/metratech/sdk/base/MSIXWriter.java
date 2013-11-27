package com.metratech.sdk.base;

import java.io.*;

class MSIXWriter
{

	protected static void outputOpeningTag (OutputStream stream, String tag) throws IOException
	{
		stream.write(MSIXObject.MSIX_OPENINGTAG_PREFIX.getBytes());
		stream.write(tag.getBytes());
		stream.write(MSIXObject.MSIX_OPENINGTAG_SUFFIX.getBytes());
	}
	
	protected static void outputValue (OutputStream stream, String val) throws IOException
	{
		// System.out.println("Before escaping = " + val);
		val = val.replaceAll("&", "&amp;");
		val = val.replaceAll("<", "&lt;");
		val = val.replaceAll(">", "&gt;");
		val = val.replaceAll("'", "&apos;");
		val = val.replaceAll("\"", "&quot;");
		// System.out.println("After escaping = " + val);

		stream.write(val.toString().getBytes());
	}
	
	protected static void outputClosingTag (OutputStream stream, String tag) throws IOException
	{
		stream.write(MSIXObject.MSIX_CLOSINGTAG_PREFIX.getBytes());
		stream.write(tag.getBytes());
		stream.write(MSIXObject.MSIX_CLOSINGTAG_SUFFIX.getBytes());
	}
	
	protected static void outputNewLine(OutputStream stream) throws IOException
	{
	    stream.write(System.getProperty("line.separator").getBytes());    
	}
}

