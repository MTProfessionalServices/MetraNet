using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using Messages;

namespace RequestResponseTest
{
  class SampleAmpRequesterNode
  {
    static void Main(string[] args)
    {
      bool monitorResponses = true;
      int numberOfMessagesToSendEachTime = 100;

      decimal sleepForSeconds = 2.0M; // .5M;

      //Get a simple identifier for this test node for debugging/testing
      string nodeIdentifier = Messages.NodeIdentifier.GetNodeIdentifier();

      RequestResponseTest.Configuration configuration = new RequestResponseTest.Configuration();
      //This helper is just to make initial programming easier as it confirms all the queues are set as expected
      //Useful as the queue configuration changes to make sure everything is insync
      RequestResponseTest.Setup.TearDownDeleteExistingQueues(configuration);
      RequestResponseTest.Setup.CreateNeededExchangesAndQueues(configuration);

      //Start thread for monitoring/processing responses
      Thread t = new Thread(MonitorResponses);
      t.Start();


      //Start sending requests
      IRequestTransport transport = new RabbitTransport();

      transport.Connect(configuration.RequestHostName, configuration);

      string replyTo = configuration.ReplyQueueName + "@" + Messages.NodeIdentifier.GetNodeIdentifier();

      //for (int i = 0; i < 10; i++)
      int i = 0;
      bool done = false;
      while (!done)
      {
        for (int j = 0; j < numberOfMessagesToSendEachTime && !done; j++)
        {
          //Create simulated message
          Messages.IncreaseBalanceRequestMessage requestMessage = new Messages.IncreaseBalanceRequestMessage() { Id = i, TestingMessage = "Request sent from " + nodeIdentifier, Amount = 20.00M, AmountCurrency = "USD", AmpNodeId = nodeIdentifier };

          //Test if message is picked up but never processed/acknowledged
          //requestMessage.DesiredTestingOutcome = new SimulatorDesiredOutcome() { DesiredResult = Messages.SimulatorOutcome.TakeMessageButDoNotDoAnything };

          transport.SendMessage<Messages.IncreaseBalanceRequestMessage>(requestMessage, replyTo);
          Console.WriteLine("SEND: {0}", requestMessage);

          i++;
          done = WasQuitKeyPressed(ref sleepForSeconds);
        }

        //done = true;
        if (Decimal.Floor(sleepForSeconds)>0.0M)
          Thread.Sleep((int)Decimal.Floor(sleepForSeconds * 1000));
      }

      transport.Disconnect();

      Console.WriteLine("Sent {0} Messages.", i);

      return;
      //Console.ReadLine();
    }

    static void MonitorResponses()
    {
      Console.WriteLine("Starting thread to monitor responses...");
      RequestResponseTest.Configuration configuration = new RequestResponseTest.Configuration();

      RabbitThreadedConsumer consumer = new RabbitThreadedConsumer();

      string myUniqueIdentifierForThisNodeToReceiveResponsesFor = Messages.NodeIdentifier.GetNodeIdentifier();
      consumer.Connect(configuration, myUniqueIdentifierForThisNodeToReceiveResponsesFor);

      consumer.ConsumeMessages();

      Console.WriteLine("Received {0} messages", consumer.countReceived);
      Console.WriteLine("Quitting thread monitoring responses...");
    }

    static bool WasQuitKeyPressed(ref decimal sleepForSeconds)
    {
      if (Console.KeyAvailable)
      {
        bool result = false;

        ConsoleKeyInfo keyInfo = Console.ReadKey();
        if (Char.ToUpperInvariant(keyInfo.KeyChar) == 'W')
        {
          sleepForSeconds -= 1.0M;
          Console.WriteLine("Sleeping less: {0}", sleepForSeconds);
        }
        if (Char.ToUpperInvariant(keyInfo.KeyChar) == 'X')
        {
          sleepForSeconds += 1.0M;
          Console.WriteLine("Sleeping more: {0}", sleepForSeconds);
        }

        if (Char.ToUpperInvariant(keyInfo.KeyChar) == 'Q')
        {
          result = true;
        }

        return result;
      }

      return false;
    }
  }


}
