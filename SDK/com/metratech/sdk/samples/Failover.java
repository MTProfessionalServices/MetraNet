package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;


public class Failover extends ConsoleApp
{
	public static void main(String[] args)
	{
		try
		{
			// prompt for a primary server host name
			String primaryHost = readLine ("Primary server host name : ");

			// prompt for a backup server host name
			String backupHost = readLine ("Backup Server host name : ");

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

			/*
			// Create a connection
			MTHTTPConnection myConnection = 
				new MTHTTPConnection("Primary", new URL("http", primaryHost,
													 MTHTTPConnection.DEFAULT_HTTP_PORT,
													 MTHTTPConnection.DEFAULT_LISTENER));
			*/

			
			// Add it to the list of available connections
			myMeter.addServer (myServer);
			
			/*
			myConnection = 
				new MTHTTPConnection("Backup", new URL("http", backupHost,
													   MTHTTPConnection.DEFAULT_HTTP_PORT,
													   MTHTTPConnection.DEFAULT_LISTENER));
			
			myMeter.addConnection (myConnection);
			*/
			
			// Create a session
			MTMeterSession mySession = myMeter.createSession ("metratech.com/TestService");
			
			// Set the session's properties
			mySession.setProperty ("Units", 1.0);
			mySession.setProperty ("Description", "Java Test");
			mySession.setProperty ("AccountName", "demo");
			mySession.setProperty ("Time", new Date());
			mySession.setProperty ("Description", "Java Test");
			
			// Close the session to send the data
			mySession.close();
			
			System.out.println ("Metering completed successfully");			
		}
		
		// Handle any errors that occur
		catch (Exception e)
		{
			System.out.println ("Error Metering session : " + e);
		}	
		
	}

}
