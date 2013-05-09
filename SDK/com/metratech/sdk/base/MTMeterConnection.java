package com.metratech.sdk.base;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.net.*;
import java.io.*;

/**  *   The MTMeterConnection class is an interface
 *   which represents a connection to a Metering Server.
 */
public interface MTMeterConnection
{
  boolean equals (Object obj);
	
  /**	
   * 	Obtains the Connection's name.
   *  
   *  @param none.
   *	@return	The connection's name.
   *   
   */
  public String getName ();
	
  /**		 
   * Sets the connection's unique name.
   *  @param Name The unique connection name.		  	
   *	@return	None.
   *  	
   */
  public void setName (// Name of the connection
    String name) ;
	
  /**
   * Gets the connection's InputStream.
   * @param None
   * @return InputStream The connection's InputStream.
   * @exception IOException as propagated.
   */
  public InputStream getInputStream () throws IOException;
	
  /**
   * Gets the connection's OutputStream.
   * @param None
   * @return OutputStream The connection's OutputStream.
   * @exception IOException as propagated.
   */			
  public OutputStream getOutputStream () throws IOException;
	
  /**
   * Gets the connection's URL.
   * @param None
   * @return the Connection's URL
   * @exception IOException as propagated.
   */			
  public URL getMTConnectionURL();

  /**
   * Gets the connection.
   * @param None
   * @return the Connection
   * @exception IOException as propagated.
   */			
  public HttpURLConnection getConnection();
	
  /**
   * 	The default port for normal HTTP connections
   */
  public static final int DEFAULT_HTTP_PORT = 80;
	
  /**
   * 	The default port for testing normal HTTP connections
   */
  public static final int DEFAULT_HTTP_TEST_PORT = 8080;
	
  /**
   *	The default port for secure HTTP connections
   */
  public static final int DEFAULT_HTTPS_PORT = 443;

  /**
   * Description:
   *		The default metering server.
   */
  public static final String DEFAULT_LISTENER = "/msix/listener.dll";

  /**
   * Description:
   *		The default Batch Listener.
   */
  public static final String DEFAULT_BATCH_LISTENER = "/Batch/Listener.asmx";
	
  public String mProtocol = "MSIX";
}
