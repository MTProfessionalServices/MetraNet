package com.metratech.sdk.base;

/**
 *  Description: *		The MTParseException class handles parsing specific errors.
 *		This class extends the MTException class.
 */
public class MTParseException extends MTException
{
	/**
	 *  Description:
	 *		Default Constructor
	 */
	public MTParseException()
	{
	}
	
	/**
	 *  Description:
	 *		Construct with a message
	 */
	public MTParseException(String message)
	{	super (message);
	}
}
