package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.text.*;
import java.net.*;
import java.io.*;
import java.math.BigDecimal;


public class TestBatch extends ConsoleApp
{
  private static void printUsage()
  {
    System.err.println("usage: TestBatch [{-h,--host}] a_host]" + 
		       "[{-p,--port}] a_port]" + 
		       "[{-n,--negativetest}]" +
		       "[{-s,--secure}]");
  }

  public TestBatch()
  {
    mID = -1;
    mPort = -1;
    mUID = "";
    mName = "";
    mNamespace = "";
    mSequenceNumber = "";
    mNegativeTest = false;
    mSecureTest = false;
  }

  void setID (long ID)
  { this.mID = ID; }
  public long getID ()
  { return mID; }
	
  void setPort (long Port)
  { this.mPort = Port; }
  public long getPort ()
  { return mPort; }
	
  public void setName (String name)
  { this.mName = name; } 
  public String getName ()
  { return mName; }

  public void setNamespace (String namespace)
  { this.mNamespace = namespace; } 
  public String getNamespace ()
  { return mNamespace; }

  void setUID (String UID)
  { this.mUID = UID; }
  public String getUID ()
  { return mUID; }

  void setSequenceNumber (String SequenceNumber)
  { this.mSequenceNumber = SequenceNumber; }
  public String getSequenceNumber ()
  { return mSequenceNumber; }

  void setNegativeTest (boolean NegativeTest)
  { this.mNegativeTest = NegativeTest; }
  public boolean getNegativeTest ()
  { return mNegativeTest; }

  void setSecureTest (boolean SecureTest)
  { this.mSecureTest = SecureTest; }
  public boolean getSecureTest ()
  { return mSecureTest; }
	
  public static void main(String[] args)
  {
    CmdLineParser parser = new CmdLineParser();
    CmdLineParser.Option host = parser.addStringOption('h', "host");
    CmdLineParser.Option port = parser.addIntegerOption('p', "port");
    CmdLineParser.Option negativeTest = parser.addBooleanOption('n', "negativetest");
    CmdLineParser.Option secureTest = parser.addBooleanOption('s', "securetest");

    // To use secure connections, you might need to use a line like the one below, to specify your truststore
    // You need to have your certs properly configured to meter securely. You must trust the server cert in particular.
    System.setProperty("javax.net.ssl.trustStore", "c:\\j2sdk1.4.1_01\\jre\\lib\\security\\fabricio_truststore");	

    try {
      parser.parse(args);
    }
    catch ( CmdLineParser.OptionException e ) {
      System.err.println(e.getMessage());
      printUsage();
      System.exit(2);
    }

    // Extract the values entered for the various options -- if the
    // options were not specified, the corresponding values will be
    // null.
    String hostValue = (String)parser.getOptionValue(host);
    Integer portValue = (Integer)parser.getOptionValue(port);
    Boolean negativeTestValue = (Boolean)parser.getOptionValue(negativeTest);
    Boolean secureTestValue = (Boolean)parser.getOptionValue(secureTest);

    // For testing purposes, we just print out the option values
    //System.out.println("port: " + portValue);
    //System.out.println("negativeTest: " + negativeTestValue);
    //System.out.println("secureTest: " + secureTestValue);

    TestBatch test = new TestBatch();
    if (portValue.intValue() <= 0)
      portValue = new Integer(80);
    
    test.setPort(portValue.intValue());
		
    // figure out a better way to do this
    if (negativeTestValue != null)
      test.setNegativeTest(true);

    if (secureTestValue != null)
      test.setSecureTest(true);
		
    try
    {
      MTMeter myMeter = new MTMeterImpl();
      myMeter.startup();
      myMeter.setTimeoutValue(7000);
      myMeter.setNumberofRetries(0);

      // Create the Server Entry object
      MTServerEntry myServer = new MTServerEntry();
      myServer.setPriority(-1); 
      myServer.setServerName(hostValue); 
      myServer.setSecure(test.getSecureTest()); 
      myServer.setUserName(""); 
      myServer.setPassword(""); 
      
      // Create a connection 
      myServer.setPortNumber(test.getPort()); 
      myMeter.addServer(myServer);

			
      // -----------------------------------------------------------------
      // this is only for some minor tests 
      //System.out.println("Testing simpleTest...");
      //test.simpleTest();
	
      // -----------------------------------------------------------------
      System.out.println("Testing Creation...");
      String UID = test.createBatchAndSubmitSessions(myMeter);
      if (UID == "")
      {
	System.out.println("Creation test failed...");
	return;
      }
			
      // -----------------------------------------------------------------
      System.out.println("Testing LoadByUID...");
      if (test.testLoadByUID(myMeter,
			     test.getUID(), 
			     test.getName(), 
			     test.getNamespace()) != true)
      {
	System.out.println("LoadByUID test failed...");
	return;
      }

      // -----------------------------------------------------------------
      System.out.println("Testing LoadByName...");
      if (test.testLoadByName(myMeter,
			      test.getName(), 
			      test.getNamespace(), 
			      test.getSequenceNumber(), 
			      test.getUID()) != true)
      {
	System.out.println("LoadByName test failed...");
	return;
      }

      // -----------------------------------------------------------------
      System.out.println("Testing MarkAsFailed...");
      if (test.testMarkAsFailed(myMeter, test.getUID()) != true)
      {
	System.out.println("MarkAsFailed test failed...");
	return;
      }

      // -----------------------------------------------------------------
      System.out.println("Testing MarkAsCompleted...");
      if (test.testMarkAsCompleted(myMeter, test.getUID()) != true)
      {
	System.out.println("MarkAsCompleted test failed...");
	return;
      }

      // -----------------------------------------------------------------
      System.out.println("Testing MarkAsFailed...");
      if (test.testMarkAsFailed(myMeter, test.getUID()) != true)
      {
	System.out.println("MarkAsFailed test failed...");
	return;
      }

      // -----------------------------------------------------------------
      System.out.println("Testing MarkAsBackout...");
      if (test.testMarkAsBackout(myMeter, test.getUID()) != true)
      {
	System.out.println("MarkAsBackout test failed...");
	return;
      }

      // -----------------------------------------------------------------
      System.out.println("Testing MarkAsDismissed...");
      if (test.testMarkAsDismissed(myMeter, test.getUID()) != true)
      {
	System.out.println("MarkAsDismissed test failed...");
	return;
      }

      // -----------------------------------------------------------------
      System.out.println("Testing UpdateMeteredCount...");
      if (test.testUpdateMeteredCount(myMeter, test.getUID(), 10) != true)
      {
	System.out.println("UpdateMeteredCount test failed...");
	return;
      }

      System.out.println("------- SUCCESS ---------");
    }
    catch (Exception e)
    {
      System.out.println("TestBatch::Error Metering session : " + e);
    }
		
    return;
  }

  //
  //
  //
  public String createBatchAndSubmitSessions (MTMeter aMeter)
  {
    String id = "";
    try
    {
      MTMeterBatch batch = aMeter.createBatch();
			
      long mSecs = System.currentTimeMillis();
      Integer tempMs = new Integer((int)mSecs);
      batch.setName(tempMs.toString());
      batch.setNamespace("Java SDK");
      batch.setExpectedCount(10);
      batch.setSource("Java SDK");
      batch.setSequenceNumber(tempMs.toString());
      batch.setSourceCreationDate(new Date());
	
      batch.save();
      if (this.getNegativeTest() == true)
	batch.save();
      id = batch.getUID();

      // create a session set
      MTMeterSessionSet mySet = batch.createSessionSet();

      // Configure the first session set
      for (int i = 1; i <= 10; i++)
      {
	System.out.println("Adding Session " + i);
	MTMeterSession mySession = mySet.createSession("metratech.com/TestService");
	mySession.setProperty("Units", 1.0);
	mySession.setProperty("Description", "Session " + i + " in batch");
	mySession.setProperty("AccountName", "demo");
	mySession.setProperty("Time", new Date());
	mySession.setProperty("DecProp1", new BigDecimal("-123456789.1456"));
      }
	
      System.out.println("Submit sessionset");
      // Close the session to send the data
      mySet.close();
	
      System.out.println("Metering completed successfully");
	
      aMeter.shutdown();
			
      this.setUID(id);
      this.setName(tempMs.toString());
      this.setNamespace("Java SDK");
      this.setSequenceNumber(tempMs.toString());
      this.setID(batch.getID());
			
      return id; 
    }
    /*
      catch (SOAPException e)
      {
      //System.out.println("(Before) Error Message --> {0}", e.Message);
      String strippedMessage = StripSOAPException(e.getMessage());
      System.out.println("-----------------------");
      System.out.println(strippedMessage);
      System.out.println("-----------------------");

      //System.out.println("Fault Code Namespace --> {0}", e.Code.Namespace);
      //System.out.println("Fault Code --> {0}", e.Code);
      //System.out.println("Fault Code Name --> {0}", e.Code.Name);
      //System.out.println("SOAP Actor that threw Exception --> {0}", e.Actor);
      //System.out.println("Code --> {0}", e.Code);
      //System.out.println("Inner Exception is --> {0}",e.InnerException);
      System.out.println ("Caught SOAP Exception (" + e.toString() + 
      "):" + 
      e.getMessage());
      }
    */
    catch (MTException e)
    {
      System.out.println(e.toString());
    }
		
    return id;
  }

  //
  //
  //
  public boolean testLoadByUID (MTMeter aMeter, 
				String UID,
				String name,
				String namespace)
  {
    MTMeterBatch batch;
    try
    {
      batch = aMeter.openBatchByUID(UID);
    }
    catch (MTException e)
    {
      //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
      //string strippedMessage = StripSOAPException(e.Message);
      //System.Console.WriteLine("-----------------------");
      //System.Console.WriteLine("{0}", strippedMessage);
      //System.Console.WriteLine("-----------------------");
      System.out.println(e.toString());
      return false;
    }

    DumpBatch(batch);
    if ((0 == batch.getName().compareTo(name)) && 
	(0 == batch.getNamespace().compareTo(namespace))) 
    {
      return true;
    }
    else
      return false;
  }

  //
  //
  //
  public boolean testLoadByName(MTMeter aMeter,
				String name, 
				String namespace, 
				String sequencenumber, 
				String expectedBatchUID)
  {
    MTMeterBatch batch;
    try
    {
      batch = aMeter.openBatchByName(name, namespace, sequencenumber);
    }
    catch (MTException e)
    {
      System.out.println(e.toString());
      return false;
    }

    DumpBatch(batch);

    if (0 == batch.getUID().compareToIgnoreCase(expectedBatchUID))
      return true;
    else
      return false;
  }

  //
  //
  //
  public boolean testMarkAsFailed (MTMeter aMeter, String UID)
  {
    try
    {
      MTMeterBatch batch;
      batch = aMeter.openBatchByUID(UID);
      batch.markAsFailed("Marking batch " + UID + " as failed from Java SDK");
			
      MTMeterBatch newBatch;
      newBatch = aMeter.openBatchByUID(UID);
      if (0 == newBatch.getStatus().compareToIgnoreCase("F"))
	return true;
      else
	return false;
    }
    catch (MTException e)
    {
      System.out.println(e.toString());
      return false;
    }
  }

  public boolean testMarkAsCompleted (MTMeter aMeter, String UID)
  {
    try
    {
      MTMeterBatch batch;
      batch = aMeter.openBatchByUID(UID);
      batch.markAsCompleted("Marking batch " + UID + " as completed from Java SDK");
			
      MTMeterBatch newBatch;
      newBatch = aMeter.openBatchByUID(UID);
      if (0 == newBatch.getStatus().compareToIgnoreCase("C"))
	return true;
      else
	return false;
    }
    catch (MTException e)
    {
      System.out.println(e.toString());
      return false;
    }
  }

  //
  //
  //
  public boolean testMarkAsBackout (MTMeter aMeter, String UID)
  {
    try
    {
      MTMeterBatch batch;
      batch = aMeter.openBatchByUID(UID);
      batch.markAsBackout("Marking batch " + UID + " as backout from Java SDK");
			
      MTMeterBatch newBatch;
      newBatch = aMeter.openBatchByUID(UID);
      if (0 == newBatch.getStatus().compareToIgnoreCase("B"))
	return true;
      else
	return false;
    }
    catch (MTException e)
    {
      System.out.println(e.toString());
      return false;
    }
  }

  //
  //
  //
  public boolean testMarkAsDismissed (MTMeter aMeter, String UID)
  {
    try
    {
      MTMeterBatch batch;
      batch = aMeter.openBatchByUID(UID);
      batch.markAsDismissed("Marking batch " + UID + " as dismissed from Java SDK");
			
      MTMeterBatch newBatch;
      newBatch = aMeter.openBatchByUID(UID);
      if (0 == newBatch.getStatus().compareToIgnoreCase("D"))
	return true;
      else
	return false;
    }
    catch (MTException e)
    {
      System.out.println(e.toString());
      return false;
    }
  }

  //
  //
  //
  public boolean testUpdateMeteredCount(MTMeter aMeter, String UID, long meteredCount)
  {
    try
    {
      MTMeterBatch batch;
      batch = aMeter.openBatchByUID(UID);
      batch.updateMeteredCount(meteredCount);
		
      MTMeterBatch newBatch;
      newBatch = aMeter.openBatchByUID(UID);
      if (newBatch.getMeteredCount() == meteredCount)
	return true;
      else
	return false;
    }
    catch (MTException e)
    {
      System.out.println(e.toString());
      return false;
    }
  }

  //
  //
  //
  public void simpleTest () throws MTParseException
  {
    Date afterDateValue;
    //"2002-11-30T23:16:17.0000000-05:00";
    String beforeDateValue = "2002-11-30T23:16:17.0000000-05:00";
    SimpleDateFormat txtDate = new SimpleDateFormat(
      "yyyy-MM-dd'T'HH:mm:ss");
    System.out.println("Before --> " + beforeDateValue);
    try
    {
      afterDateValue = txtDate.parse(beforeDateValue);
    }
    catch (ParseException e)
    {
      throw new MTParseException ("Error parsing timestamp " + e);
    }
    System.out.println("After --> " + afterDateValue);

    return;
  }

  //
  //
  //
  public String StripSOAPException(String soapexception) 
  {
    int index = soapexception.indexOf("Fusion log");
    // this is a soap exception
    if (index != -1)
    {
      int totallength = soapexception.length();
      System.out.println("Index --> " + index);
      System.out.println("Total Length --> " + totallength);
      return (soapexception.substring(index, (totallength - index)));
    }
    else
      return soapexception;
  }

  public void DumpBatch(MTMeterBatch batch) 
  {
    System.out.println("---------------------------------------");
    System.out.println("ID = <" + batch.getID() + ">");
    System.out.println("UID Encoded = <" + batch.getUID() + ">");
    System.out.println("Name = <" + batch.getName() + ">");
    System.out.println("Namespace = <" + batch.getNamespace() + ">");
    System.out.println("Status = <" + batch.getStatus() + ">");
    System.out.println("Creation Date = <" + batch.getCreationDate() + ">");
    System.out.println("Source = <" + batch.getSource() + ">");
    System.out.println("Sequence Number = <" + batch.getSequenceNumber() + ">");
    System.out.println("Completed Count = <" + batch.getCompletedCount() + ">");
    System.out.println("Expected Count = <" + batch.getExpectedCount() + ">");
    System.out.println("Failure Count = <" + batch.getFailureCount() + ">");
    System.out.println("Source Creation Date = <" + batch.getSourceCreationDate() + ">");
    System.out.println("---------------------------------------");

    return;
  }

  private long mID;
  private long mPort;
  private String mName;
  private String mNamespace;
  private String mUID;
  private String mSequenceNumber;
  private boolean mNegativeTest;
  private boolean mSecureTest;
}
