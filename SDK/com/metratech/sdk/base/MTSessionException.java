package com.metratech.sdk.base;

/**
 *  Description: *		The MTSessionException class handles session specific errors.
 *		This class extends the MTException class.
 */
public class MTSessionException extends MTException
{
	/**
	 *  Description:
	 *		Default Constructor
	 */
	public MTSessionException()
	{
	}

	/**
	 *  Description:
	 *		Construct with a code and a message
	 */
	public MTSessionException(long code, String message)
	{	super (code, message);
	}
	
	/**
	 *  Description:
	 *		Construct with a message
	 */
	public MTSessionException(String message)
	{	super (message);
	}
}


