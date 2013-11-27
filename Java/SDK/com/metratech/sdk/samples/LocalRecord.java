package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.io.*;
import java.util.*;

/** 
 * Records a session locally for later playback.
 */
public class LocalRecord extends ConsoleApp
{
	public static void main(String[] args)
	{
		try
		{
			// prompt for a local mode file
			String file = readLine ("Local mode file : ");

			// Create an instance of the base meter object
			MTMeter myMeter = new MTMeterImpl();

			// Create the Server Entry object
      MTServerEntry myServer = new MTServerEntry();
      myServer.setPriority(-1); 
      myServer.setServerName("localhost"); 
      myServer.setPortNumber(MTMSIXConnection.DEFAULT_HTTP_PORT); 
      myServer.setSecure(false); 
      myServer.setUserName(""); 
      myServer.setPassword(""); 
			
			// Create a file oriented connection
			// TODO: this needs to work with myServer
			MTFileConnection myConnection = new MTFileConnection ("TEST", file);
		
			// Add it to the list of connections
			myMeter.addServer (myServer);
		
			// create a new session
			MTMeterSession mySession;
						
			for (int i = 0; i < 5; i++)
			{
			    mySession = myMeter.createSession ("metratech.com/TestService");
			    mySession.setProperty ("Units", (double)i);
			    mySession.setProperty ("Description", "Java Local Mode Test" + i);
			    mySession.setProperty ("AccountName", "demo");
			    mySession.setProperty ("Time", new Date());
			    mySession.close();
			}

			System.out.println ("Local mode recording complete.");
		}
		
		catch (Exception e)
		{
			System.out.println ("Error Metering local mode session : " + e);
		}	
		
	}

}
