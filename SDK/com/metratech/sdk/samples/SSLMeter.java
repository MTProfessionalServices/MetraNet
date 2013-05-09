package com.metratech.sdk.samples;

import com.metratech.sdk.utils.*;
import com.metratech.sdk.base.*;
import java.util.*;
import java.net.*;
import java.io.*;
import java.security.*;
import javax.security.cert.*;

public class SSLMeter extends ConsoleApp
{
    public static void main(String[] args)
    {

        // Initialize crypto
        System.setProperty("javax.net.ssl.trustStore", "c:\\j2sdk1.4.1_01\\jre\\lib\\security\\fabricio_truststore");

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
            // TODO: setSecure is set to true, so it should go to https
            MTServerEntry myServer = new MTServerEntry();
            myServer.setPriority(-1);
            myServer.setServerName(host);
            myServer.setPortNumber(MTMSIXConnection.DEFAULT_HTTPS_PORT);
            myServer.setSecure(true);
            myServer.setUserName("");
            myServer.setPassword("");

            // Add it to the list of available connections
            myMeter.addServer(myServer);

            // Create a session
            MTMeterSessionSet mySet = myMeter.createSessionSet();
            MTMeterSession mySession = mySet.createSession("metratech.com/TestService");

            // Set the session's properties
            mySession.setProperty("Units", 1.0);
            mySession.setProperty("Description", "Java Test");
            mySession.setProperty("AccountName", "demo");
            mySession.setProperty("Time", new Date());

            // Close the session to send the data
            mySet.close();

            System.out.println("Metering completed successfully");
        }

        // Handle any errors that occur
        catch (Exception e)
        {
            System.out.println("Error Metering session : " + e);
        }
    }

}