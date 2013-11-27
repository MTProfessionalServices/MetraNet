using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using RabbitMQ.Client;
using RabbitMQ.Client.Events;
//using Messages;
using System.Threading;

namespace SampleSendRequestReceiveResponse
{
  public class RabbitThreadedConsumer : RabbitTransport
  {
    //public string nodeIdentifierForQueue { get; set; }

    //public string GetQueueName()
    //{
    //  return this.configuration.ReplyQueueName + (string.IsNullOrEmpty(nodeIdentifierForQueue) ? "":"@") + nodeIdentifierForQueue;
    //}

    public int countReceived = 0;
    //public void Connect(RequestResponseTest.Configuration configuration, string nodeIdentifierForQueue)
    //{
    //  this.configuration = configuration;
    //  this.nodeIdentifierForQueue = nodeIdentifierForQueue;

    //  ConnectionFactory factory = new ConnectionFactory
    //  {
    //    HostName = this.configuration.RequestHostName
    //  };

    //  connection = factory.CreateConnection();
    //  channel = connection.CreateModel();

    //  channel.QueueDeclare(GetQueueName(), true, false, false, null);
    //}

    //public void Connect(RequestResponseTest.Configuration configuration)
    //{
    //  Connect(configuration, string.Empty);
    //}
    protected bool ShutDown = false;

    public void ConsumeMessages(string queueName, Func<object, bool> methodToProcessMessage)
    {
      QueueingBasicConsumer consumer = RegisterConsumer(queueName, "");
      
      bool done = false;
      while (!done)
      {
        ReadAMessage(consumer, methodToProcessMessage);
      }

      connection.Close();
      connection.Dispose();
      connection = null;
    }

    public QueueingBasicConsumer RegisterConsumer(string queueName, string consumerTag)
    {
      QueueingBasicConsumer consumer = new QueueingBasicConsumer(channel);
      channel.BasicConsume(queueName, true, consumerTag, consumer);
      return consumer;
    }

    private void ReadAMessage(QueueingBasicConsumer consumer, Func<object, bool> methodToProcessMessage)
    {
      BasicDeliverEventArgs messageInEnvelope = DequeueMessage(consumer);

      if (messageInEnvelope == null)
      {
        return;
      }

      try
      {
        //object message = SerializationHelper.FromByteArray(messageInEnvelope.Body);
        Interlocked.Increment(ref countReceived);

        ////Testing: Verify this is our response and we are not seeing someone else's
        //IncreaseBalanceResponseMessage increaseBalanceResponseMessage = message as IncreaseBalanceResponseMessage;
        //if (increaseBalanceResponseMessage.OriginalRequest.AmpNodeId != Messages.NodeIdentifier.GetNodeIdentifier())
        //{
        //  Console.WriteLine("[Error] Received message not intended for this node: Received [{0}] Expected [{1}]", increaseBalanceResponseMessage.OriginalRequest.AmpNodeId, Messages.NodeIdentifier.GetNodeIdentifier());
        //  //System.Diagnostics.Debugger.Break();
        //}

        if (methodToProcessMessage != null)
        {
          methodToProcessMessage(messageInEnvelope.Body);
        }
      }
      catch (Exception ex)
      {
        Console.WriteLine("Failed message: {0}", ex);
      }
    }

    protected virtual BasicDeliverEventArgs DequeueMessage(QueueingBasicConsumer consumer)
    {
      const int timeoutMilseconds = 400;
      object result;

      consumer.Queue.Dequeue(timeoutMilseconds, out result);
      return result as BasicDeliverEventArgs;
    }

    private void ProcessMessageByJustWritingItOut(object message)
    {
      //Console.WriteLine("Received {0} : {1}", message.GetType().Name, message);
      string value = ASCIIEncoding.ASCII.GetString((byte [])message);
      Console.WriteLine("Received: {0}", value);
    }

    //private void ProcessMessageByGeneratingAResponse(QueueingBasicConsumer consumer, BasicDeliverEventArgs messageInEnvelope, object message)
    //{
    //  //ReplyMessage replyMessage = this.MakeReply(request);
    //  if (message is IncreaseBalanceRequestMessage)
    //  {
    //    IncreaseBalanceRequestMessage requestMessage = message as IncreaseBalanceRequestMessage;
    //    IncreaseBalanceResponseMessage responseMessage = new IncreaseBalanceResponseMessage(); // InitializeResponseFromRequest(requestMessage);

    //    //Simulate Processing Increase Balance Request
    //    Messages.Simulator.ProcessIncreaseBalanceRequest(requestMessage, responseMessage);

    //    IBasicProperties requestProperties = messageInEnvelope.BasicProperties;
    //    IBasicProperties responseProperties = consumer.Model.CreateBasicProperties();
    //    responseProperties.CorrelationId = requestProperties.CorrelationId;
    //    this.SendReply(requestProperties.ReplyTo, responseProperties, responseMessage);
    //    this.channel.BasicAck(messageInEnvelope.DeliveryTag, false);

    //    Console.WriteLine("sent reply to: {0}", requestMessage);
    //  }
    //  else
    //  {
    //    Console.WriteLine("I don't know how to reply to messages of type: {0}", message.GetType().Name);
    //    this.channel.BasicAck(messageInEnvelope.DeliveryTag, false);

    //  }
    //}

    //private IncreaseBalanceResponseMessage InitializeResponseFromRequest(IncreaseBalanceRequestMessage request)
    //{
    //  IncreaseBalanceResponseMessage response = new IncreaseBalanceResponseMessage();
    //  response.OriginalRequest = request;

    //  return response;
    //}

    //private void SendReply(string replyQueueName, IBasicProperties responseProperties, IncreaseBalanceResponseMessage response)
    //{
    //  this.channel.BasicPublish(string.Empty, replyQueueName, responseProperties, response.ToByteArray());
    //}
  }
}
