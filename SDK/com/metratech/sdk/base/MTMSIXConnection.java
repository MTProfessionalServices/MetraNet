package com.metratech.sdk.base;

import java.net.*;
import java.io.*;

/**  
 *   The MTMSIXConnection class wraps the java.net.HttpUrlConnection class
 *   to represent a connection to a metering sever using the HTTP protocol.
 */
public class MTMSIXConnection implements MTMeterConnection
{
  /**
   * Construct the Connection. 
   * 
   * @param Name	The name of the connection.
   * @param URL	The URL for the Metering Server.
   * @exception IOException as propagated from HttpUrlConnection.
   */
  public MTMSIXConnection (String name, URL url) throws IOException
  { 
    Initialize (name, url);
  }

  /**
   * Construct the Connection. 
   * 
   * @param Name	The name of the connection.
   * @param URL	The URL for the Metering Server.
   * @param username Username used to authenticate user on server connection, if specified, a proper header will be inserted on the request
   * @param password The password for the user above, also used in authentication
   * @exception IOException as propagated from HttpUrlConnection.
   */
  public MTMSIXConnection (String name, URL url, String username, String password) throws IOException
  { 
    Initialize (name, url, username, password);
  }

  /**
   * Obtains the Connection's name.
   * 
   * @param None.
   * @return The connection.
   * .
   */
  public String getName ()
  {
    return this.mName;
  }
	
  /**	 
   * Sets the connection's unique name. 		 
   *	
   * @param name The connection's unique name.
   * @return	None.
   * @exception	Nothing.	
   */
  public synchronized void setName (// Name of the connection
    String name) 
  {
    this.mName = name;
  }	
	
  /**
   * Gets the connection's InputStream.
   * @param None
   * @return InputStream The connection's InputStream.
   * @exception IOException as propagated from HttpUrlConnection
   */
  public InputStream getInputStream () throws IOException
  {
    return this.mConnection.getInputStream();
  }
	
  /**
   * Gets the connection's OutputStream.
   * @param None
   * @return OutputStream The connection's OutputStream.
   * @exception IOException as propagated from HttpUrlConnection
   */		
  public OutputStream getOutputStream () throws IOException
  {
    return this.mConnection.getOutputStream();
  }

  protected void Initialize (String name, URL url) throws IOException
  {
    // Save the URL
    this.mURL = url;	
    setName (name);

    // Open the connection and set some default request
    // properties that we always use
    this.mConnection = (HttpURLConnection)mURL.openConnection();
    this.mConnection.setRequestMethod ("POST");
    this.mConnection.setDoOutput (true);
    this.mConnection.setDoInput (true);
    this.mConnection.setRequestProperty ("Content-Type", "application/x-metratech-xml");
    this.mConnection.setRequestProperty ("Accept", "application/x-metratech-xml");	
  }

  protected void Initialize (String name, URL url, String username, String password) throws IOException
  {
    Initialize(name, url);

    if (username.length() > 0)
    {
      String concat = new String(username + ":" + password);
      this.mConnection.setRequestProperty("Authorization", "Basic " + new sun.misc.BASE64Encoder().encode(concat.getBytes()));
    }
  }
  
  public URL getMTConnectionURL()
  {
    return mURL;    
  }
	
  public HttpURLConnection getConnection()
  {
    return mConnection;	
  }

  private String mName;
  private URL mURL;
  private HttpURLConnection mConnection;
}
