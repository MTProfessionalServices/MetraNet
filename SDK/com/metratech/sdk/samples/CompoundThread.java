package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;
import java.math.BigDecimal;

public class CompoundThread extends ConsoleApp
{
  public static void main(String[] args)
  {
    try
    {
      // prompt for a server host name
      String host = ConsoleApp.readLine ("Server host name : ");

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
		
      // Add it to the list of available connections
      myMeter.addServer (myServer);
		
      int i;
      ParentSession Sessions[] = new ParentSession[6];

      for (i=1 ; i <= 5; i++)
      {
	ParentSession aParent = new ParentSession (i, myMeter);
	aParent.start();
	Sessions[i] = aParent;
      }
		
      for (i=1 ; i <= 5; i++)
      {
	Sessions[i].join();
      }
			
			
      System.out.println ("Metering completed successfully");			
    }
		
    // Handle any errors that occur
    catch (Exception e)
    {
      System.out.println ("Error Metering session : " + e);
    }	
  }
}


class ParentSession extends Thread
{
  public ParentSession (int number, MTMeter meter)
  {
    this.mId = new Integer (number);
    this.mMeter = meter;
  }
	
  public void run ()
  {
    try
    {
      sleep ((int)(Math.random()*2000));
					
      // Create a parent session
      MTMeterSession myParent = mMeter.createSession ("metratech.com/TestParent");
			
      int i;
      ChildSession Children[] = new ChildSession[6];

      for (i=1 ; i <= 5; i++)
      {
	ChildSession aChild = new ChildSession (i, myParent);
	aChild.start();
	Children[i] = aChild;
      }
		
      for (i=1 ; i <= 5; i++)
      {
	Children[i].join();
      }

      // Set the parent's properties
      myParent.setProperty ("Description", "Java Test Parent " + mId.toString());
      myParent.setProperty ("AccountName", "demo");
      myParent.setProperty ("Time", new Date());
	
      // Close the parent session to send the data
      // Closing the parent also sends all of the children
      myParent.close();

    }
    catch (Exception e)
    {
    }
  }
	
	
  private MTMeter			mMeter;
  private Integer			mId;
}

class ChildSession extends Thread
{
  public ChildSession (int number, MTMeterSession parent)
  {
    this.mId = new Integer (number);
    this.mParent = parent;
  }
	
  public void run () 
  {
    try
    {
      sleep ((int)(Math.random()*2000));
      // Create a child session of this parent
      MTMeterSession mySession = mParent.createChildSession ("metratech.com/TestService");
		
      // Set the child's properties
      mySession.setProperty ("Units", mId.floatValue());
      mySession.setProperty ("Description", "Java Test " + mId.toString());
      mySession.setProperty ("AccountName", "demo");
      mySession.setProperty ("Time", new Date());		
      mySession.setProperty ("DecProp1", new BigDecimal("-123456789.1456"));
    }
    catch (Exception e)
    {
    }

  }
	
	
  private MTMeterSession	mParent;
  private Integer			mId;
}
