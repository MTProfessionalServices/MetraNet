package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;
import java.math.BigDecimal;

// Creator: Fabricio Pettena
// Note that this method of storing username and password is very insecure.
// Only use this thru SSL. See example SSLMeter.java .

public class AuthMeter extends ConsoleApp
{
  public static void main(String[] args)
  {
    try
    {
      // prompt for a server host name
      String host = readLine ("Server host name : ");
	    
      // New server auth 
      String username = readLine ("Username on server: ");
      String password = readLine ("Password on server: ");
      
      // Create the SDK base object
      MTMeter myMeter = new MTMeterImpl();
      
      // Create the Server Entry object
      MTServerEntry myServer = new MTServerEntry();
      myServer.setPriority(-1); 
      myServer.setServerName(host); 
      myServer.setPortNumber(MTMSIXConnection.DEFAULT_HTTP_PORT); 
      myServer.setSecure(false); 
      myServer.setUserName(username); 
      myServer.setPassword(password); 

      // Add it to the list of available connections
      myMeter.addServer(myServer);
      
      // Create a session
      MTMeterSession mySession = myMeter.createSession("metratech.com/TestService");
      
      // Mark for sychronous processing
      mySession.setSynchronous (true);
      
      // Set the session's properties
      mySession.setProperty("Units", 1.0);
      mySession.setProperty("Description", "AuthMeter");
      mySession.setProperty("AccountName", "demo");
      mySession.setProperty("Time", new Date());
      mySession.setProperty("DecProp1", new BigDecimal("-1234567890.123456"));

      // Close the session to send the data
      mySession.close();

      // Grab the result session
      MTMeterSession resultSession = mySession.getResultSession();
      if (resultSession != null)
      {
	// locate the _Amount property
	Object Amount = resultSession.getProperty ("_Amount");
	Object DecProp1 = resultSession.getProperty ("DecProp1");
	if (Amount != null)
	{
	  // Print its value
	  System.out.println ("A charge of " + Amount.toString() + " was applied.");
	  System.out.println ("DecProp1 is " + DecProp1.toString()); 
	}
      }
      System.out.println("Metering completed successfully");
    }
    // Handle any errors that occur
    catch (Exception e)
    {
      System.out.println("Error Metering session : " + e);
    }
  }
}


