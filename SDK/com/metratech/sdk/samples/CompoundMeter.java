package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;

/**
 * Demonstrates compound metering using MetraTech's test services.
 */
public class CompoundMeter extends ConsoleApp
{
  public static void main(String[] args)
  {
    try
    {
      // prompt for a server host name
      String host = ConsoleApp.readLine("Server host name : ");

      // Create the SDK base object
      MTMeter myMeter = new MTMeterImpl();

      // Create the Server Entry object
      MTServerEntry myServer = new MTServerEntry();
      myServer.setPriority(-1); 
      myServer.setServerName("localhost"); 
      myServer.setPortNumber(MTMSIXConnection.DEFAULT_HTTP_PORT); 
      myServer.setSecure(false);
		
      // Add it to the list of available connections
      myMeter.addServer (myServer);
		
      // Create a parent session
      MTMeterSession myParent = myMeter.createSession ("metratech.com/TestParent");
			
      // Set the parent's properties
      myParent.setProperty ("Description", "Java Test Parent");
      myParent.setProperty ("AccountName", "demo");
      myParent.setProperty ("Time", new Date());

      // Create a child session of this parent
      MTMeterSession mySession = myParent.createChildSession ("metratech.com/TestService");
			
      // Set the child's properties
      mySession.setProperty ("Units", 1.0);
      mySession.setProperty ("Description", "Java Test");
      mySession.setProperty ("AccountName", "demo");
      mySession.setProperty ("Time", new Date());
			
      // Close the parent session to send the data
      // Closing the parent also sends all of the children
      myParent.close();
			
      System.out.println ("Metering completed successfully");			
    }
		
    // Handle any errors that occur
    catch (Exception e)
    {
      System.out.println ("Error Metering session : " + e);
    }	
  }

}

