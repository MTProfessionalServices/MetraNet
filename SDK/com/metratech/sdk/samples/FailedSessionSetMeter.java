package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;
import java.math.BigDecimal;
import javax.xml.parsers.*;
import org.w3c.dom.*;


public class FailedSessionSetMeter extends ConsoleApp
{
  public static void main(String[] args)
  {
    try
    {
      // prompt for a server host name
      String host = readLine ("Server host name : ");
      String datafile = readLine ("XML file name : ");
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

      MTMeterBatch batch = myMeter.createBatch();

      long mSecs = System.currentTimeMillis();
      Integer tempMs = new Integer((int)mSecs);

      batch.setName(tempMs.toString());
      batch.setNamespace("Java SDK");
      batch.setExpectedCount(10);
      batch.setSource("Java SDK");
      batch.setSequenceNumber("100");
      batch.setSourceCreationDate(new Date());

      batch.save();

      System.out.println("Creating the session set");
      // Create a Session Set
      MTMeterSessionSet mySet = myMeter.createSessionSet();

      System.out.println("Creating the sessions within the set");

      DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
      DocumentBuilder builder = factory.newDocumentBuilder();
      //Loading the sessiondata xml file
      org.w3c.dom.Document document = builder.parse(datafile);
      document.normalize();

      Node documentnode = document.getElementsByTagName("xmlconfig").item(0);
      NodeList parentlist = documentnode.getChildNodes();

      //Looping through all the child nodes for the parent
      for(int parentcount=0; parentcount<parentlist.getLength(); parentcount++ )
      {
        Node parentnode = parentlist.item(parentcount);
        if( parentnode.getNodeName().compareTo("session") != 0)
          continue;

        // Create a Parent Session
        System.out.println("Creating a parent session");
        MTMeterSession parentSess = CreateParentSession(parentnode, mySet);
        NodeList childlist = parentnode.getChildNodes();

        for(int childcount=0; childcount<childlist.getLength(); childcount++ )
        {
          Node childNode = childlist.item(childcount);
          if( childNode.getNodeName().compareToIgnoreCase("session") == 0)
          {
            //Adding the child sessions to the parent session
            System.out.println("Adding the child sessions to the parent session");
            CreateChildSession(childNode, parentSess);
          }
        }
      }

      System.out.println("Submitting sessionset...");

      // Close the session to send the data
      try
      {
	mySet.close();
      }
      catch (Exception e) // Handle possible metering and parsing errors
      {
	System.out.println("One or more error(s) happened while metering this sessionset: " + e);
        Vector parentsessVec = mySet.getSessions();
        for(int i=0;i<parentsessVec.size(); i++)
        {
          MTMeterSession sess1 = (MTMeterSession) parentsessVec.get(i);
          System.out.println( "Service:" +sess1.getName() +" SessionID:" +sess1.getSessionID() +" Error: " +sess1.getStatusMessage());
          Vector childsessVector = sess1.getChildSessions();
          for(int j=0; j<childsessVector.size(); j++ )
          {
            MTMeterSession sess2 = (MTMeterSession) childsessVector.get(j);
            System.out.println( "Service:" +sess2.getName() +" SessionID:" +sess2.getSessionID() +" Error: " +sess2.getStatusMessage());
          }
        }
	return;
      }
      System.out.println("Metering completed successfully");
    }
    catch (Exception e)
    {
      System.out.println("Metering sample failed with an unexpected error:" + e);
    }
  }

  //THis function is used to add the parent session to the session set object. It reads the values from the
  //xml node and sets them in the parent session.
   private static MTMeterSession CreateParentSession(Node parentNode, MTMeterSessionSet sessionSet) throws Exception
  {
    MTMeterSession parentSession = null;
    NodeList list = parentNode.getChildNodes();

    for(int attcount=0; attcount<list.getLength(); attcount++ )
    {
      //set the properties in the session object
      if( list.item(attcount).getNodeName().compareToIgnoreCase("inputs") == 0 )
      {
        NodeList childlist = list.item(attcount).getChildNodes();
        for(int parentattcount=0;parentattcount<childlist.getLength(); parentattcount++)
        {
          if( childlist.item(parentattcount).getNodeType() == Node.ELEMENT_NODE )
            parentSession.setProperty(childlist.item(parentattcount).getNodeName(),  childlist.item(parentattcount).getChildNodes().item(0).getNodeValue() );
        }
      }
      //Create the session object using the service name
      if( list.item(attcount).getNodeName().compareToIgnoreCase("ServiceName") == 0 )
      {
        String servicename = list.item(attcount).getChildNodes().item(0).getNodeValue();
        parentSession = sessionSet.createSession (servicename);
        if( parentSession == null)
          throw new Exception("Parent Session couldn't be created. Please Check the configuration.");
      }
    }
    parentSession.setSynchronous(false);
    return parentSession;
  }

  //This function is used to add the child session to the parent session. It reads the values from the
  //xml node and sets them in the child session.
  private static void CreateChildSession(Node childNode, MTMeterSession parentSession) throws Exception
  {
    MTMeterSession childSession = null;
    NodeList list = childNode.getChildNodes();

    for(int attcount=0; attcount<list.getLength(); attcount++ )
    {
      //set the properties in the session object
      if( list.item(attcount).getNodeName().compareToIgnoreCase("inputs") == 0 )
      {
        NodeList childlist = list.item(attcount).getChildNodes();
        for(int childattcount=0;childattcount<childlist.getLength(); childattcount++)
        {
          if( childlist.item(childattcount).getNodeType() == Node.ELEMENT_NODE )
            childSession.setProperty(childlist.item(childattcount).getNodeName(),  childlist.item(childattcount).getChildNodes().item(0).getNodeValue() );
        }
      }
      //Create the session object using the service name
      if( list.item(attcount).getNodeName().compareToIgnoreCase("ServiceName") == 0 )
      {
        String servicename = list.item(attcount).getChildNodes().item(0).getNodeValue();
        childSession = parentSession.createChildSession (servicename);
        if( childSession == null )
          throw new Exception("Child Session couldn't be created. Please Check the configuration.");
      }
    }
  }
}
