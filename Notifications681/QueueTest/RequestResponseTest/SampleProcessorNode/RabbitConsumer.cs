namespace RequestResponseTest
{
  using System;
  using Messages;

  using RabbitMQ.Client;
  using RabbitMQ.Client.Events;
  using System.Collections.Generic;

  internal class RabbitConsumer
  {
    private IConnection connection;
    private IModel channel;

    RequestResponseTest.Configuration configuration;

    public void Connect(RequestResponseTest.Configuration configuration)
    {
      this.configuration = configuration;

      ConnectionFactory factory = new ConnectionFactory
      {
        HostName = this.configuration.RequestHostName
      };

      connection = factory.CreateConnection();
      channel = connection.CreateModel();

      channel.ExchangeDeclare("Dead_Letter", "direct");

      Dictionary<string, object> args = new Dictionary<string, object>();
      args.Add("x-dead-letter-exchange", "Dead_Letter");
      //args.Add("x-dead-letter-exchange", "/");
      args.Add("x-dead-letter-routing-key", "TimeoutRequest");
      args.Add("x-message-ttl", this.configuration.RequestMessageTimeoutInSeconds * 1000);

      //QueueDeclareOk QueueDeclare(string queue, bool durable, bool exclusive, bool autoDelete, IDictionary arguments);
      channel.QueueDeclare(this.configuration.RequestQueueName, true, false, false, args);
    }

    public void ConsumeMessages()
    {
      QueueingBasicConsumer consumer = MakeConsumer();

      bool done = false;
      while (!done)
      {
        ReadAMessage(consumer);

        done = this.WasQuitKeyPressed();
      }

      connection.Close();
      connection.Dispose();
      connection = null;
    }


    private QueueingBasicConsumer MakeConsumer()
    {
      QueueingBasicConsumer consumer = new QueueingBasicConsumer(channel);
      channel.BasicConsume(this.configuration.RequestQueueName, this.configuration.AutomaticallyAcknowledgeRetrievedMessages, consumer);
      return consumer;
    }

    private bool WasQuitKeyPressed()
    {
      if (Console.KeyAvailable)
      {
        ConsoleKeyInfo keyInfo = Console.ReadKey();

        if (Char.ToUpperInvariant(keyInfo.KeyChar) == 'Q')
        {
          return true;
        }
      }

      return false;
    }

    private void ReadAMessage(QueueingBasicConsumer consumer)
    {
      BasicDeliverEventArgs messageInEnvelope = DequeueMessage(consumer);
      if (messageInEnvelope == null)
      {
        return;
      }

      try
      {
        object message = SerializationHelper.FromByteArray(messageInEnvelope.Body);
        ProcessMessageByJustWritingItOut(message);
        ProcessMessageByGeneratingAResponse(consumer, messageInEnvelope, message);
      }
      catch (Exception ex)
      {
        Console.WriteLine("Failed message: {0}", ex);
      }
    }

    private BasicDeliverEventArgs DequeueMessage(QueueingBasicConsumer consumer)
    {
      const int timeoutMilseconds = 400;
      object result;

      consumer.Queue.Dequeue(timeoutMilseconds, out result);
      return result as BasicDeliverEventArgs;
    }


    private void ProcessMessageByJustWritingItOut(object message)
    {
      Console.WriteLine("Received {0} : {1}", message.GetType().Name, message);
    }

    private void ProcessMessageByGeneratingAResponse(QueueingBasicConsumer consumer, BasicDeliverEventArgs messageInEnvelope, object message)
    {
      //ReplyMessage replyMessage = this.MakeReply(request);
      if (message is IncreaseBalanceRequestMessage)
      {
        IncreaseBalanceRequestMessage requestMessage = message as IncreaseBalanceRequestMessage;
        IncreaseBalanceResponseMessage responseMessage = new IncreaseBalanceResponseMessage(); // InitializeResponseFromRequest(requestMessage);

        //Simulate Processing Increase Balance Request
        if (requestMessage.DesiredTestingOutcome == null || requestMessage.DesiredTestingOutcome.DesiredResult != SimulatorOutcome.TakeMessageButDoNotDoAnything)
        {
          Messages.Simulator.ProcessIncreaseBalanceRequest(requestMessage, responseMessage);

          IBasicProperties requestProperties = messageInEnvelope.BasicProperties;
          IBasicProperties responseProperties = consumer.Model.CreateBasicProperties();
          responseProperties.CorrelationId = requestProperties.CorrelationId;
          this.SendReply(requestProperties.ReplyTo, responseProperties, responseMessage);

          if (!this.configuration.AutomaticallyAcknowledgeRetrievedMessages)
            this.channel.BasicAck(messageInEnvelope.DeliveryTag, false);

          Console.WriteLine("sent reply to: {0}", requestMessage);
        }
        else
        {
          Console.WriteLine("Simulating taking message but not acknowledging or sending response for : {0}", requestMessage);
        }
      }
      else
      {
        Console.WriteLine("I don't know how to reply to messages of type: {0}", message.GetType().Name);
        this.channel.BasicAck(messageInEnvelope.DeliveryTag, false);

      }
    }

    private IncreaseBalanceResponseMessage InitializeResponseFromRequest(IncreaseBalanceRequestMessage request)
    {
      IncreaseBalanceResponseMessage response = new IncreaseBalanceResponseMessage();
      response.OriginalRequest = request;

      return response;      
    }

    private void SendReply(string replyQueueName, IBasicProperties responseProperties, IncreaseBalanceResponseMessage response)
    {
      this.channel.BasicPublish(string.Empty, replyQueueName, responseProperties, response.ToByteArray());
    }
  }
}