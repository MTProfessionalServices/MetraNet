package com.metratech.sdk.base;


//
// This class seems to be of dubious utility.  It should probably be eliminated
// in favor of maintining values in MTMeterSession's Hashtable.
//

/**
 * The MTMeterProperty class manages a session property as a name-value 
 * associated pair.
 */
public class MTMeterProperty
{
	/**
	 * Construct a property pair from the supplied values.
	 * 
	 * @param Name The name of the property.
	 * @param Value The object representing the property's value.
	 * 
	 */
	public MTMeterProperty(String name, Object val)
	{
		mName = name;
		mValue = val;
	}
	

	/**
	 * Obtains the property's name.
	 * 
	 * @return The property name.
	 * 
	 */
	public String getName ()
	{
		return mName;
	}
	

	/**
	 * Obtains the property's value.
	 * 
	 * @return The property value.
	 */
	public Object getValue ()
	{
		return mValue;
	}
	
	// the name of the property
	protected String mName;
	
	// its value
	protected Object mValue;
}
