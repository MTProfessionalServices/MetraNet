package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;
import java.math.BigDecimal;
import java.util.Date;

public class SimpleAccountMeter extends ConsoleApp
{
	public static void main(String[] args)
  {
    try
    {   String host;
    
         if(args.length ==0){
               host = readLine ("Server host name : ");
        }
        else{
            host = args[0];
        }
    
    

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

      System.out.println("Creating the connection");
      myMeter.addServer(myServer);

      System.out.println("Creating the session set");
      // Create a Session Set
      MTMeterSessionSet mySet = myMeter.createSessionSet();
      mySet.setSessionContextUsername("su");
      mySet.setSessionContextPassword("su123");
      mySet.setSessionContextNamespace("system_user");


      System.out.println("Setting account");
      // Configure the first session set
      MTMeterSession mySession = mySet.createSession("metratech.com/AccountCreation");

      mySession.setSynchronous(true);
      mySession.setProperty("username", "test_java2");
      //operation is ADD, UPDATE or DELETE
      mySession.setProperty("operation", "add");
      //actiontype is ACCOUNT, CONTACT or BOTH
      mySession.setProperty("actiontype", "both");
      //currency is USD, GBP, CAD or EUR
      mySession.setProperty("currency", "USD");
      mySession.setProperty("_Accountid", 0);
      mySession.setProperty("billable", true);
      mySession.setProperty("password_", "test123");
      mySession.setProperty("name_space", "mt");

      //     accounttype enums: can be verified in db, table "t_account_type"
      //Version 3.5 - 4 : CSR, SUB, MCM, MOM, SYS or IND
      //Version 5.0 and after: CoreSubscriber, CorporateAccount, DepartmentAccount, IndependentAccount, Root, SystemAccount
      
      mySession.setProperty("accounttype", "IndependentAccount");
      //contacttype is Bill-To(1), Ship-To(2) or None(0)
      mySession.setProperty("contacttype", "Bill-To");
      mySession.setProperty("firstname", "Java");
      mySession.setProperty("usagecycletype", "daily");
      mySession.setProperty("language", "US");
      mySession.setProperty("taxexempt", false);
      mySession.setProperty("timezoneID", 18);
      mySession.setProperty("accountstatus", "ac");
      mySession.setProperty("accountstartdate", "2003-03-14T10:42:55Z");

      System.out.println("Submit sessionset");

      // Close the session to send the data
      mySet.close();
			System.out.println("Metering completed successfully");
		}
    catch (Exception e)
    {
			System.out.println("Error Metering session : " + e);
    }
	}
}
