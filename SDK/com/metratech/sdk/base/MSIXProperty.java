package com.metratech.sdk.base;

import java.io.*;

/**
 * Represents an MSIX property aggregate.
 */
class MSIXProperty implements MSIXObject
{
	/**
	 * Construct the default MSIX property. 
	 * 
	 * @param None.
	 * @return New MSIXproperty object.
	 * .
	 */

	protected MSIXProperty ()
	{
		
	}

	/**
	 * Construct an MSIX property with the given name. 
	 * 
	 * @param name The name of the MSIX property.
	 * @return New MSIX property object.
	 * .
	 */
	protected MSIXProperty (MSIXString name)
	{
		this.mName = name;
	}
	
	protected MSIXProperty (String name, Object val)
	{
		this.mName = new MSIXString(MSIXObject.MSIX_TAG_DISTINGUISEDNAME);
		this.mName.setValue(name);
		this.mValue = new MSIXValue(MSIXObject.MSIX_TAG_VALUE);
		this.mValue.setValue (val);
	}
	
	
	protected MSIXString getName ()
	{
		return this.mName;
	}

	protected synchronized void setName (MSIXString name)
	{
		this.mName = name;
	}
	
	protected synchronized void setValue (MSIXValue value)
	{
		this.mValue = value;
	}
	
	protected MSIXValue getValue ()
	{
		return this.mValue;
	}
	
	
	public MSIXObject create (String type) throws MTParseException
	{	
		MSIXObject obj = null;
		if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_DISTINGUISEDNAME))
		{
			MSIXString aString = new MSIXString(type);
			obj = (MSIXObject)aString;
		}
		else if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_VALUE))
		{
			MSIXString aString = new MSIXString(type);
			obj = (MSIXObject)aString;
		}
		else 
			throw new MTParseException ("Unrecognized sub-object " + type); 
		
		return obj;
	}
	
	public void parse (String data) throws MTParseException
	{
		throw new MTParseException ("Unexpected data in aggregate");
	}
	
	public void complete (MSIXObject obj)
	{
		if (obj instanceof MSIXString)
		{
			MSIXString prop = (MSIXString) obj;
			if (prop.getName().equalsIgnoreCase(MSIXObject.MSIX_TAG_DISTINGUISEDNAME))
			{
				setName (prop);
			}
			else if (prop.getName().equalsIgnoreCase(MSIXObject.MSIX_TAG_VALUE))
			{
				MSIXValue aVal = new MSIXValue (MSIXObject.MSIX_TAG_VALUE);
				aVal.setValue (prop);
				setValue (aVal);
			}
		}
	}
	
	public void toStream (OutputStream stream) throws IOException
	
	{
		MSIXWriter.outputOpeningTag (stream, MSIXObject.MSIX_TAG_PROPERTY);		
		this.mName.toStream (stream);
		this.mValue.toStream (stream);
		MSIXWriter.outputClosingTag (stream, MSIXObject.MSIX_TAG_PROPERTY);		
	}

	
	private MSIXString	mName;	
	private MSIXValue	mValue;
}

