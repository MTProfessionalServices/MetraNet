package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;
import java.math.BigDecimal;


public class SimpleMeter extends ConsoleApp
{
  public static void main(String[] args)
  {
    try
    {
      // prompt for a server host name
      String host = readLine ("Server host name : ");
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

      // Add it to the list of available connections
      myMeter.addServer(myServer);

      // Create a session
      MTMeterSession mySession = myMeter.createSession("metratech.com/TestService");
      mySession.setSynchronous(true);
      // Set the session's properties
      mySession.setProperty("Units", 1.0);
      mySession.setProperty("Description", "SimpleMeter test");
      mySession.setProperty("AccountName", "demo");
      mySession.setProperty("Time", new Date());
      mySession.setProperty("DecProp1", new BigDecimal("-123456789.1456"));

      // Close the session to send the data
      mySession.close();

      System.out.println("Metering completed successfully");
    }
    catch (Exception e)
    {
      System.out.println("Error Metering session : " + e);
    }
  }
}
