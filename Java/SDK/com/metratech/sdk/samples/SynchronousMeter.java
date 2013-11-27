package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;

public class SynchronousMeter extends ConsoleApp
{
  public static void main(String[] args)
  {
    try
    {
      // prompt for a server host name
            String host;
            if(args.length ==0)
            {
                host = readLine ("Server host name : ");
            }
            else
            {
                host = args[0];
            }

      // Create the SDK base object
      MTMeter myMeter = new MTMeterImpl();

      // Create the Server Entry object
      MTServerEntry myServer = new MTServerEntry();
      myServer.setPriority(-1); 
      myServer.setServerName("localhost"); 
      myServer.setPortNumber(MTMSIXConnection.DEFAULT_HTTP_PORT); 
      myServer.setSecure(false);
      myServer.setUserName(""); 
      myServer.setPassword(""); 

      myMeter.setLoggingLevel (MTMeter.LOG_LEVEL_DEBUG);
      myMeter.setLoggingStream (System.out);
			
      // Add it to the list of available connections
      myMeter.addServer (myServer);
					
      // Create a session
      MTMeterSession mySession = myMeter.createSession ("metratech.com/TestService");
			
      // Mark for sychronous processing
      mySession.setSynchronous (true);
			
      // Set the session's properties
      mySession.setProperty ("Units", 1.0);
      mySession.setProperty ("Description", "Java Test");
      mySession.setProperty ("AccountName", "demo");
      mySession.setProperty ("Time", new Date());
      mySession.setProperty ("Description", "Java Test");
			
      // Close the session to send the data
      mySession.close();
			
      System.out.println ("Metering completed successfully");			
			
      // Grab the result session
      MTMeterSession resultSession = mySession.getResultSession();
      if (resultSession != null)
      {
	// locate the _Amount property
	Object Amount = resultSession.getProperty ("_Amount");
	if (Amount != null)
	{
	  // Print its value
	  Float fAmount = new Float (Amount.toString());
	  System.out.println ("A charge of " + fAmount + " was applied."); 
	}
      }
    }
		
    // Handle any errors that occur
    catch (Exception e)
    {
      System.out.println ("Error Metering session : " + e);
    }	
		
  }
}
