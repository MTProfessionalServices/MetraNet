package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;
import java.math.BigDecimal;


public class SimpleSessionSetMeter extends ConsoleApp
{
  public static void main(String[] args)
  {
    try
    {
      // prompt for a server host name
      String host = readLine ("Server host name : ");

      // Synchronous metering or not
      boolean bSynchronous = false;

      // Create the SDK base object
      MTMeter myMeter = new MTMeterImpl();

      // Create the Server Entry object
      MTServerEntry myServer = new MTServerEntry();
      myServer.setPriority(-1); 
      myServer.setServerName(host); 
      myServer.setPortNumber(MTMSIXConnection.DEFAULT_HTTP_PORT); 
      myServer.setSecure(false); 
      myServer.setUserName(""); 
      myServer.setPassword(""); 

      myMeter.setTimeoutValue(7000);
      myMeter.setNumberofRetries(0);

      System.out.println("Creating the server entry");
      myMeter.addServer(myServer);

      System.out.println("Creating the session set");
      // Create a Session Set
      MTMeterSessionSet mySet = myMeter.createSessionSet();
            
      System.out.println("Creating the sessions within the set");
      // Configure the first session
      MTMeterSession myFirstSession = mySet.createSession("metratech.com/TestService");
      myFirstSession.setProperty("Units", 1.0);
      myFirstSession.setProperty("Description", "SimpleSessionSetMeter 1");
      myFirstSession.setProperty("AccountName", "demo");
      myFirstSession.setProperty("Time", new Date());
      myFirstSession.setProperty("DecProp1", new BigDecimal("-123456789.1456"));
      myFirstSession.setSynchronous(bSynchronous);

      // Configure the second session
      MTMeterSession mySecondSession = mySet.createSession("metratech.com/TestService");
      mySecondSession.setProperty("Units", 2.0);
      mySecondSession.setProperty("Description", "SimpleSessionSetMeter 2");
      mySecondSession.setProperty("AccountName", "demo");
      mySecondSession.setProperty("Time", new Date());
      mySecondSession.setProperty("DecProp1", new BigDecimal("-123456789.1456"));
      mySecondSession.setSynchronous(bSynchronous);

      System.out.println("Submitting sessionset...");

      // Close the session to send the data
      try 
      {
	mySet.close();
      }
      catch (Exception e) // Handle possible metering and parsing errors
      {
	System.out.println("One or more error(s) happened while metering this sessionset: " + e);
	System.out.println("First session error code: " + myFirstSession.getStatusCode() + " and message: " +  myFirstSession.getStatusMessage());
	System.out.println("Second session error code: " + mySecondSession.getStatusCode() + " and message: " +  mySecondSession.getStatusMessage());
	return;
      }
      System.out.println("Metering completed successfully");

      if (bSynchronous)
      {
	// Check for any property that was set by the pipeline and returned to this client, just as an example
	 System.out.println("Checking properties on each session of this sessionset");
	MTMeterSession resultFirstSession = myFirstSession.getResultSession();
	MTMeterSession resultSecondSession = mySecondSession.getResultSession();
	System.out.println("Printing a return property value for the first session: " + resultFirstSession.getProperty("_PRODUCTVIEWID"));
	System.out.println("Printing a return property value for the second session: " + resultSecondSession.getProperty("_PRODUCTVIEWID"));
      }
    }
    catch (Exception e)
    {
      System.out.println("SimpleSessionSetMeter sample failed with an unexpected error:" + e);
    }
  }
}
