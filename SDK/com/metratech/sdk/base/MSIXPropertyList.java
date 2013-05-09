package com.metratech.sdk.base;

import java.io.*;
import java.util.*;

/**
 * {internal}
 */

class MSIXPropertyList implements MSIXObject
{
	protected MSIXPropertyList()
	{
		this.mProperties = new Hashtable();
	}


	protected Enumeration properties ()
	{
		return this.mProperties.elements();
	}

	protected void addProperty (MSIXProperty prop)
	{
		this.mProperties.put (prop.getName().getValue(), prop);
	}
		
	
	public MSIXObject create (String type)
	{
		MSIXObject obj = null;
		if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_PROPERTY))
		{
			MSIXProperty prop = new MSIXProperty();
			obj = (MSIXObject)prop;
		}
			
			
		return obj;
	}
	
	public void parse (String type) throws MTParseException
	{
			throw new MTParseException ("Unexpected data in aggregate");
	}

	public void complete (MSIXObject obj)
	{
		if (obj instanceof MSIXProperty)
		{
			MSIXProperty prop = (MSIXProperty)obj;
			mProperties.put (prop.getName().getValue(), obj);
		}
		
	}
	
	public void toStream (OutputStream stream) throws IOException
	{
		MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_PROPERTIES);
		Enumeration props = mProperties.elements();
		while (props.hasMoreElements())
		{
			MSIXProperty prop = (MSIXProperty)props.nextElement();
			if (prop != null)
			{
				prop.toStream (stream);
			}
		}
		MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_PROPERTIES);
	}
		
	private Hashtable  mProperties;
}

