package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.net.*;
import java.io.*;

/**
 * Demonstrates re-play of a previously recorded local mode session.
 */
public class LocalPlayback extends ConsoleApp
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
      myServer.setServerName("localhost"); 
      myServer.setPortNumber(MTMSIXConnection.DEFAULT_HTTP_PORT); 
      myServer.setSecure(false); 
      myServer.setUserName(""); 
      myServer.setPassword(""); 

			/*
			// Create a connection
			MTHTTPConnection myConnection = 
				new MTHTTPConnection("TEST", new URL("http", host,
													 MTHTTPConnection.DEFAULT_HTTP_PORT,
													 MTHTTPConnection.DEFAULT_LISTENER));
			*/
		
			// Add it to the list of available connections
			myMeter.addServer (myServer);

			// prompt for a local mode file
			String file = readLine ("Local mode file : ");
			String jfile = readLine ("Journal file : ");

      myMeter.setJournal(jfile);

			// Create the input stream
			FileInputStream myStream = new FileInputStream (file);

			// playback the stream
			myMeter.meterStream (myStream);
      myMeter.flushJournal();
			System.out.println ("Local mode playback completed successfully");			
		}
		
		catch (Exception e)
		{
			System.out.println ("Error Metering session : " + e);
		}	

	}
}
