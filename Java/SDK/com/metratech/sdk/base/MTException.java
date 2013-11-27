package com.metratech.sdk.base;

/**
 *   The MTException class is the base exception class
 *   which extends the default java.exception class.
 */
public class MTException extends Exception
{
	/**
	 *	Default Constructor
	 */
	public MTException()
	{
	}
	
	/**
	 * 	Construct with a code and a message
	 * 
	 * @param code The numberic error code
	 * @param message A textual description
	 */
	public MTException(long code, String message)
	{
		super("Code: 0x" + Long.toHexString(code) + " Msg: " + message);
	}
	
	/**
	 * 	Construct with a message
	 * 
	 * @param message A textual description
	 */
	public MTException(String message)
	{
		super(message);
	}
	
}
