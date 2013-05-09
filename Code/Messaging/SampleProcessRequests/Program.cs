using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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
      int rabbitMQPort = 5672;

      int QueuePrefetchCount = 0;
      //QueuePrefetchCount = 0: Do not limit the amount of transactions pre-fetched from the queue
      //Otherwise this value will limit the number of unacknowledged messages this processor can have at a time

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
        QueuePrefetchCount = parser.GetIntegerOption("QueuePrefetchCount", QueuePrefetchCount);

        parser.CheckForUnusedOptions(true);
      }
      catch (CommandLineParserException ex)
      {
        Console.WriteLine("An error occurred parsing the command line arguments.");
        Console.WriteLine("{0}", ex.Message);
        DisplayUsage();
        Environment.Exit(1);
      }

      string requestQueue = "TestClient";

      string responseExchange = string.Empty;
      string responseQueue = ""; //Set per message based on ReplyTo in the request

      ////Setup
      //RabbitQueueSetup serverSetup = new RabbitQueueSetup();
      //serverSetup.Connect(rabbitMQServer, rabbitMQVirtualHostName, rabbitMQUser, rabbitMQPassword, rabbitMQPort);

      //if (!serverSetup.VerifyQueueExists(requestQueue))
      //{
      //  Console.WriteLine("Queue '{0}' doesn't exist on server {1} for virtual host {2}", requestQueue, rabbitMQServer, rabbitMQVirtualHostName);
      //  Console.WriteLine("Queue should have been created by messaging service during startup");
      //  //Environment.Exit(1);

      //  Console.WriteLine("Creating '{0}' queue", requestQueue);
      //  serverSetup.CreateQueue(requestQueue);
      //}

      //if (!serverSetup.VerifyQueueExists(responseQueue))
      //{
      //  Console.WriteLine("Queue '{0}' doesn't exist on server {1} for virtual host {2}", requestQueue, rabbitMQServer, rabbitMQVirtualHostName);

      //  Console.WriteLine("Creating '{0}' queue", responseQueue);
      //  serverSetup.CreateQueue(responseQueue);
      //}

      //serverSetup.Disconnect();



      //Connect to server and send requests
      //IRequestTransport transport = new RabbitTransport();
      //transport.Connect(rabbitMQServer, rabbitMQVirtualHostName, rabbitMQUser, rabbitMQPassword, rabbitMQPort);

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
        Console.WriteLine("[Error] Unable to connect to RabbitMQ server: {0}", ex.Message);
        Environment.Exit(1);
      }


      //Process requests
      Console.WriteLine("Processing requests");

      bool autoAcknowledgeTheReceiptWhenMessageIsDequeued = false;


      rabbitChannel.BasicQos(0, Convert.ToUInt16(QueuePrefetchCount), false);

      QueueingBasicConsumer rabbitConsumer = new QueueingBasicConsumer(rabbitChannel);
      rabbitChannel.BasicConsume(requestQueue, autoAcknowledgeTheReceiptWhenMessageIsDequeued, "", rabbitConsumer);

      const int timeoutMilliseconds = 400;
      object result;

      int requestCount = 0;

      bool done = false;

      while(!done)
      {
        if (rabbitConsumer.Queue.Dequeue(timeoutMilliseconds, out result))
        {
          //We have a new request, now process it
          requestCount++;
          //Console.WriteLine("[{0}]", requestCount);
          Console.Write(".");

          //Process the message
          BasicDeliverEventArgs messageInEnvelope = result as BasicDeliverEventArgs;

          //Get the actual response message
          byte[] rabbitMessage = messageInEnvelope.Body;


          if (autoAcknowledgeTheReceiptWhenMessageIsDequeued == false)
          {
            //Acknowledge/confirm we have received the message; if we crash after acknowledging the message, we must recover it. If we crash before recovering it, rabbitmq will requeue the message for processing
            //Note: Faster processing can be achieved by acknowledging in bulk (after every 100 or 1000 messages)
            rabbitChannel.BasicAck(messageInEnvelope.DeliveryTag, false);
          }

          //Convert it to xml
          string xmlMessage = System.Text.Encoding.UTF8.GetString(rabbitMessage);
          XmlDocument doc = new XmlDocument();
          doc.LoadXml(xmlMessage);

          //Code similar to doc.SelectSingleNode("/Request/Body") will retrieve the interesting parameters of the particualr request
          
          //Generate the response message that will be routed back to the requester
          string xmlBaseMetraTechResponse = "<Response><MessageType>{0}</MessageType><Request></Request><Code>{1}</Code><Body>{2}</Body></Response>";

          //Get the queue the response should be delivered to
          IBasicProperties requestProperties = messageInEnvelope.BasicProperties;
          responseQueue = requestProperties.ReplyTo;

          //Set the correlation id of the response to that of the request
          IBasicProperties responseProperties = rabbitChannel.CreateBasicProperties();
          responseProperties.CorrelationId = requestProperties.CorrelationId;

          //Set the result of processing, this is either "Success" or "Failure". Note that "Timeout", the only other valid return code would typically be set by the messaging framework.
          string processingResultCode = "Success";

          //Set the values for the return values based on processing and on the 'type' of request (return values are hard coded in this example)
          string xmlMyResponseProperties = @"<AccountIdentifier>ABC</AccountIdentifier>
                                            <AccountType>Residential</AccountType>
                                            <Amount>10.50</Amount>
                                            <Currency>USD</Currency>
                                            <TransactionDate>20120904 13:45:00</TransactionDate>
                                            <ProcessingNode>12</ProcessingNode>
                                            <IdAcc>12345</IdAcc>
                                            <DecisionUniqueId>A123D456F789</DecisionUniqueId>";

          string xmlMyMetraTechFormattedResponse = string.Format(xmlBaseMetraTechResponse, "TestMessageType", processingResultCode, xmlMyResponseProperties);

          //Note: The original request can be set into the <Request> node of the response, or if left empty, the node will automatically be populated by the messaging framework

          //Send the response
          byte[] rabbitMessageBody = System.Text.Encoding.UTF8.GetBytes(xmlMyMetraTechFormattedResponse);
          rabbitChannel.BasicPublish(responseExchange, responseQueue, responseProperties, rabbitMessageBody);

        }

        //Check to determine if we should exit
        done = (Console.KeyAvailable && (Console.ReadKey(true)).Key == ConsoleKey.Q); 

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

    private static void DisplayUsage()
    {
      Console.WriteLine("Usage:");
      Console.WriteLine("  SampleProcessRequests [Parameters]");
      Console.WriteLine("");
      Console.WriteLine("Parameters:");
      Console.WriteLine("--Server=<string>           Address of RabbitMQ server");
      Console.WriteLine("                            Default: localhost");
      Console.WriteLine("--User=<string>             RabbitMQ user name");
      Console.WriteLine("                            Default: guest");
      Console.WriteLine("--Password=<string>         RabbitMQ password");
      Console.WriteLine("                            Default: guest");
      Console.WriteLine("--VirtualHost=<string>      RabbitMQ virtual host name");
      Console.WriteLine("--Port=<integer>            RabbitMQ listenting port");
      Console.WriteLine("                            Default: 5672");
      Console.WriteLine("--NumberToProcess=<integer> Number of requests to process before exiting, usefule for testing");
      Console.WriteLine("                            Default: 0 (0 indicates continuously process and have user manually exit)");
      Console.WriteLine("");
      Console.WriteLine("Examples:");
      Console.WriteLine("    SampleProcessRequests --server=localhost --user=mtuser --password=MySecretPassword --VirtualHost=MetraTech");
    }
  }
}

