package com.metratech.sdk.base;

/**
 *  Description:
 *		The MTPropetyException class handles property specific errors.
 *		This class extends the MTException class.
 */
public class MTPropertyException extends MTException
{
	/**
	 *  Description:
	 *		Default Constructor
	 */
	public MTPropertyException()
	{
	}
	
	/**
	 *  Description:
	 *		Construct with a message
	 */
	public MTPropertyException(String message)
	{
		super (message);
	}
}
