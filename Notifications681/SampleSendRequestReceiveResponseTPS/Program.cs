using System;
using System.Collections.Generic;
using MetraTech; //For command line parser
using System.Diagnostics;
using System.Threading;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Xml; 

namespace SampleSendRequestReceiveResponse
{
  class Program
  {
    static void Main(string[] args)
    {
      string rabbitMQServer = "127.0.0.1";
      string rabbitMQVirtualHostName = "MetraTech";
      string rabbitMQUser = "guest";
      string rabbitMQPassword = "guest";
      int    rabbitMQPort = 5672;

      int numberOfRequestsToSend = 5;
      bool processResponses = false;

      //Performance testing
      int desiredTPS = 100;

      //Get a simple identifier for this test node for debugging/testing
      string nodeIdentifier = GetNodeIdentifier();

      // Parse the command line arguments.
      CommandLineParser parser = new CommandLineParser(args, 0, args.Length);

      try
      {
        parser.Parse();

        if (parser.OptionExists("help") || parser.OptionExists("?"))
        {
          DisplayUsage();
          Environment.Exit(0);
        }

        rabbitMQServer = parser.GetStringOption("server", rabbitMQServer);
        rabbitMQVirtualHostName = parser.GetStringOption("virtualhost", rabbitMQVirtualHostName);
        rabbitMQUser = parser.GetStringOption("user", rabbitMQUser);
        rabbitMQPassword = parser.GetStringOption("password", rabbitMQPassword);
        rabbitMQPort = parser.GetIntegerOption("port", rabbitMQPort);

        numberOfRequestsToSend = parser.GetIntegerOption("NumberToSend", numberOfRequestsToSend);
        processResponses = parser.GetBooleanOption("processResponses", processResponses);

        nodeIdentifier = parser.GetStringOption("NodeIdentifier", nodeIdentifier);

        desiredTPS = parser.GetIntegerOption("DesiredTPS", desiredTPS);

        parser.CheckForUnusedOptions(true);
      }
      catch (CommandLineParserException ex)
      {
        Console.WriteLine("An error occurred parsing the command line arguments.");
        Console.WriteLine("{0}", ex.Message);
        DisplayUsage();
        Environment.Exit(1);
      }

      //// Check if the specified concurrent limit is reasonable
      //if (concurrentLimit < 1)
      //{
      //  Console.Error.WriteLine("ERROR: Concurrent Limit must be at least 1");
      //  Environment.Exit(1);
      //}
      string requestQueue = "MTRequest"; //Well known name of queue of messaging server that receives requests
      string responseQueue = "SampleSendRequestReceiveResponse@" + nodeIdentifier; //Whatever queue name the client making the request would like to receive requests on


      IConnection rabbitConnection = null;
      IModel rabbitChannel = null;

      //Connect to RabbitMQ server
      try
      {
        ConnectionFactory rabbitFactory = new ConnectionFactory
        {
          HostName = rabbitMQServer,
          UserName = rabbitMQUser,
          Password = rabbitMQPassword,
          Port = rabbitMQPort,
          VirtualHost = rabbitMQVirtualHostName
        };

        rabbitConnection = rabbitFactory.CreateConnection();
        rabbitChannel = rabbitConnection.CreateModel();
      }
      catch (Exception ex)
      {
        Console.WriteLine("[Error] Unable to connect to RabbitMQ server: {0}",ex.Message);
        Environment.Exit(1);
      }

      //MessagingServer will have created the well-known request queue
      //We need to create the response queue where we want our responses to be delivered to
      //Declare queue for our responses
      try
      {
        DeclareQueueUsingDefaults(rabbitChannel, responseQueue);
      }
      catch (Exception ex)
      {
        Console.WriteLine("[Error] Unable to declare the response queue (create or verify queue exists): {0}",ex.Message);
        Environment.Exit(1);
      }

      int iterations = 1000;
      int multiplier = 2;

      //Send 5 times the desired tps, then wait if there is extra time
      numberOfRequestsToSend = desiredTPS*multiplier;

      for (int iteration = 0; iteration < iterations; iteration++)
      {
        //Send requests
        Console.WriteLine("Sending requests");
        Dictionary<string, bool> requestsSent = new Dictionary<string, bool>(numberOfRequestsToSend);

        DateTime requestsStartTime = DateTime.Now;
        DateTime desiredEndTimeBasedOnTPS = requestsStartTime.AddSeconds(multiplier);

        for (int i = 0; i < numberOfRequestsToSend; i++)
        {
          //Create a sample request message
          string xmlBaseMetraTechRequest =
            "<Request NeedsTimeout=\"{0}\"><MessageType>{1}</MessageType><Body>{2}</Body></Request>";

          //Set the type specific custom request properties
          string xmlMyRequestProperties =
            @"<AccountIdentifier>ABC</AccountIdentifier>
                                          <AccountType>Residential</AccountType>
                                          <Amount>10.50</Amount>
                                          <Currency>USD</Currency>
                                          <TransactionDate>20120904 13:45:00</TransactionDate>
                                          <ProcessingNode>12</ProcessingNode>
                                          <IdAcc>12345</IdAcc>
                                          <DecisionUniqueId>A123D456F789</DecisionUniqueId>";

          string xmlMyMetraTechFormattedRequest = string.Format(xmlBaseMetraTechRequest, "true", "TestMessageType",
                                                                xmlMyRequestProperties);

          //string messageGUID = transport.SendMessage(requestQueue, "SampleRequest", xmlMyRequest, responseQueue);
          //Create the MetraTech specific xml message and convert to byte array
          //byte[] rabbitMessageBody = System.Text.Encoding.UTF8.GetBytes(MetraTechMessage.CreateRequestMessage(messageType, xmlMessageBody, true));
          byte[] rabbitMessageBody = System.Text.Encoding.UTF8.GetBytes(xmlMyMetraTechFormattedRequest);

          //Create a unique correlation id for the message and set the replyToQueueName if specified
          IBasicProperties requestProperties = rabbitChannel.CreateBasicProperties();
          requestProperties.CorrelationId = Guid.NewGuid().ToString();
          if (!string.IsNullOrEmpty(responseQueue))
            requestProperties.ReplyTo = responseQueue;

          //Send the message
          rabbitChannel.BasicPublish(string.Empty, requestQueue, requestProperties, rabbitMessageBody);

          Console.Write(".");

          //Update our list of messages sent so we can verify we get the response
          //requestsSent.Add(messageGUID, false);
          requestsSent.Add(requestProperties.CorrelationId, false);
        }

        DateTime requestsEndTime = DateTime.Now;
        
        Console.WriteLine();
        Console.WriteLine("Done sending requests");

        double requestsPerSecond = (numberOfRequestsToSend/(requestsEndTime - requestsStartTime).TotalSeconds);
        Console.WriteLine("Sent {0} in {1} ({2:0}/second)", numberOfRequestsToSend,
                          (requestsEndTime - requestsStartTime).TotalSeconds, requestsPerSecond);

        //Throttle TPS
        if (requestsEndTime>desiredEndTimeBasedOnTPS)
        {
          Console.WriteLine("Error: Unable to send at the desired TPS rate. Continueing on anyway");
        }
        else
        {
          TimeSpan timeToWait = desiredEndTimeBasedOnTPS - requestsEndTime;
          Console.WriteLine("Enforcing {0} TPS: Sleeping for {1} seconds", desiredTPS, timeToWait.TotalSeconds);
          Thread.Sleep(timeToWait);
        }
      

      //Process responses
        if (processResponses)
        {
          Console.WriteLine("Processing responses");

          //RabbitThreadedConsumer consumer = new RabbitThreadedConsumer();
          //consumer.Connect(rabbitMQServer, rabbitMQVirtualHostName, rabbitMQUser, rabbitMQPassword, rabbitMQPort);
          //consumer.ConsumeMessages(requestQueue, ProcessMessageByJustWritingItOut);

          bool autoAcknowledgeTheReceiptWhenMessageIsDequeued = true;

          QueueingBasicConsumer rabbitConsumer = new QueueingBasicConsumer(rabbitChannel);
          rabbitChannel.BasicConsume(responseQueue, autoAcknowledgeTheReceiptWhenMessageIsDequeued, "", rabbitConsumer);

          const int timeoutMilliseconds = 400;
          object result;

          DateTime responsesStartTime = DateTime.Now;

          int responseCount = 0;
          while (true)
          {
            if (rabbitConsumer.Queue.Dequeue(timeoutMilliseconds, out result))
            {

              //Process the message
              BasicDeliverEventArgs messageInEnvelope = result as BasicDeliverEventArgs;

              //Get the actual response message
              byte[] rabbitMessage = messageInEnvelope.Body;

              //Convert it to xml
              string xmlMessage = System.Text.Encoding.UTF8.GetString(rabbitMessage);
              XmlDocument doc = new XmlDocument();
              doc.LoadXml(xmlMessage);

              string metraTechReturnCode = doc.SelectSingleNode("/Response/Code").InnerText;

              if (metraTechReturnCode.ToLower().CompareTo("timeout") == 0)
              {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine(
                  "[Timeout Received] Request with correlation id {0} has timed out, although it is still being processed",
                  messageInEnvelope.BasicProperties.CorrelationId);
                Console.ResetColor();
                continue; //Just continue on as we should receive the actual response for this request later
              }

              //Use the correlation id (unique message id) to update the list we sent
              if (!requestsSent.ContainsKey(messageInEnvelope.BasicProperties.CorrelationId))
              {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("[Warning] Received message with id {0} that was not in list of messages we sent",
                                  messageInEnvelope.BasicProperties.CorrelationId);
                Console.ResetColor();
                continue;
              }
              else
              {
                //Keep track that we received this response
                requestsSent[messageInEnvelope.BasicProperties.CorrelationId] = true;
              }

              responseCount++;
              Console.Write("[{0}] ", responseCount);

              if (metraTechReturnCode.ToLower().CompareTo("success") != 0)
              {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Request with correlation id {0} has not returned success: {1}",
                                  messageInEnvelope.BasicProperties.CorrelationId, metraTechReturnCode);
                Console.ResetColor();
              }
              else
              {
                Console.WriteLine("Received response to request {0}", messageInEnvelope.BasicProperties.CorrelationId);
              }

              if (responseCount >= numberOfRequestsToSend)
                break;
            }
          }

          DateTime responsesEndTime = DateTime.Now;


          double responsesPerSecond = (responseCount/(responsesEndTime - responsesStartTime).TotalSeconds);
          Console.WriteLine("Received {0} in {1} ({2:0}/second)", responseCount,
                            (responsesEndTime - responsesStartTime).TotalSeconds, responsesPerSecond);


          //Check that we received each request
          foreach (string messageId in requestsSent.Keys)
          {
            if (requestsSent[messageId] == false)
            {
              Console.ForegroundColor = ConsoleColor.Red;
              Console.WriteLine("[Warning] Looks like we didn't get a response to request id {0}", messageId);
              Console.ResetColor();
            }
          }
        }
      }

      //Disconnect
      rabbitChannel = null;

      if (rabbitConnection.IsOpen)
      {
        rabbitConnection.Close();
      }

      rabbitConnection.Dispose();
      rabbitConnection = null;

      Environment.Exit(0);
    }

    private static void DeclareQueueUsingDefaults(IModel channel, string queueName)
    {
      try
      {
        channel.QueueDeclare(queueName, true, false, false, null);
      }
      catch (Exception ex)
      {
        string msg = string.Format("Unable to declare queue {0}. This usually happens when the queue was already declared with different parameters.", queueName);
        throw new Exception(msg, ex);
      }
    }

    private static void DisplayUsage()
    {
      Console.WriteLine("Usage:");
      Console.WriteLine("  SampleSendRequestReceiveResponseTPS [Parameters]");
      Console.WriteLine("");
      Console.WriteLine("Parameters:");
      Console.WriteLine("--DesiredTPS=<integer>      Send requests at roughly this number per second");
      Console.WriteLine("                            Default: 100"); 
      Console.WriteLine("--NumberToSend=<integer>    Number of requests to send per iteration");
      Console.WriteLine("                            Default: 100");
      Console.WriteLine("--Server=<string>           Address of RabbitMQ server");
      Console.WriteLine("                            Default: localhost");
      Console.WriteLine("--User=<string>             RabbitMQ user name");
      Console.WriteLine("                            Default: guest");
      Console.WriteLine("--Password=<string>         RabbitMQ password");
      Console.WriteLine("                            Default: guest");
      Console.WriteLine("--VirtualHost=<string>      RabbitMQ virtual host name");
      Console.WriteLine("--Port=<integer>            RabbitMQ listenting port");
      Console.WriteLine("                            Default: 5672");
      Console.WriteLine("--NodeIdentifier=<string>   Unique identifier for this requester node");
      Console.WriteLine("                            Default: Generated as <MachineName>_<ProcessName>_<ProcessId>");
      Console.WriteLine("--processResponses+         Check responses after sending request.");
      Console.WriteLine("--processResponses-         Do not check responses, just send requests. This is the default.");
      Console.WriteLine("");
      Console.WriteLine("Examples:");
      Console.WriteLine("    SampleSendRequestReceiveResponse");
      Console.WriteLine("        (send 100 requests to localhost and check for reponse using defaults");
      Console.WriteLine("    SampleSendRequestReceiveResponse --server=localhost --user=mtuser --password=MySecretPassword --VirtualHost=MetraTech --NumberToSend=10000");
    }

    public static string GetNodeIdentifier()
    {
      return Environment.MachineName + "_" + Process.GetCurrentProcess().ProcessName + "_" + Process.GetCurrentProcess().Id;
    }

    public static string GetThreadedNodeIdentifier()
    {
      return GetNodeIdentifier() + "_" + Thread.CurrentThread.ManagedThreadId;
    }

  }
}

