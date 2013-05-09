package com.metratech.sdk.base;

import java.net.*;
import java.io.*;

/**  
 *   The MTSOAPConnection class wraps the java.net.HttpUrlConnection class
 *   to represent a connection to a metering sever using the HTTP protocol.
 */
public class MTSOAPConnection implements MTMeterConnection
{
  /**
   * Construct the Connection. 
   * 
   * @param Name	The name of the connection.
   * @param URL	The URL for the Metering Server.
   * @param operation This is the precise soap server method that is being invoked by the operation that requested this connection.
   * @exception IOException as propagated from HttpUrlConnection.
   */
  public MTSOAPConnection (String name, URL url, String operation) throws IOException
  { 
    Initialize (name, url, operation);
  }

  /**
   * Construct the Connection. 
   * 
   * @param Name	The name of the connection.
   * @param URL	The URL for the Metering Server.
   * @param operation This is the precise soap server method that is being invoked by the operation that requested this connection.
   * @param username Username to be used for authenticating this connection on the server. 
   * @param password Password for the username above, for server authentication.
   * @exception IOException as propagated from HttpUrlConnection.
   */
  public MTSOAPConnection (String name, URL url, String operation, String username, String password) throws IOException
  { 
    Initialize (name, url, operation, username, password);
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

  /**
   * Initialize the connection
   * @param name
   * @param url
   * @param operation This String argument will be useful in building the String to hit the Batch Listener with.
   * @return OutputStream The connection's OutputStream.
   * @exception IOException as propagated from HttpUrlConnection
   */
  protected void Initialize (String name, URL url, String operation) throws IOException
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
		
    String strHitListener;
    strHitListener = "\"http://metratech.com/webservices/" + operation + "\"";
				
    this.mConnection.setRequestProperty ("soapaction", strHitListener);
    this.mConnection.setRequestProperty ("content-Type", "text/xml; charset=utf-8");
  }

  protected void Initialize (String name, URL url, String operation, String username, String password) throws IOException
  {
    Initialize(name, url, operation);
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
