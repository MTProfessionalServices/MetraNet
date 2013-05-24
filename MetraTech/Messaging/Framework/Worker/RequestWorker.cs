using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MetraTech;


namespace MetraTech.Messaging.Framework.Worker
{
  using Messages;
  using Configurations;

  public class RequestWorker : ListenerWorker
  {
    private string mResponseQueue;

    public override void Initialize(int aThreadNumber, Configurations.QueueConfig aQueueConfig)
    {
      base.Initialize(aThreadNumber,aQueueConfig);
      logger = new Logger(string.Format("[RequestWorker{0}]",ThreadNumber));
      mResponseQueue = Configuration.ResponseQueue.Name;
      this.QueuePrefetchCount = Configuration.RequestPrefetchCount;
    }

    public override void ProcessMessage(BasicDeliverEventArgs ea)
    {
      Request request = new Request();
      request.Parse(ea);
      request.SetTimeoutSeconds(Configuration.TimeoutRequestInSeconds);
      repository.StoreRequest(request);
      if (!Configuration.MessageTypeRules.ContainsKey(request.MessageType))
        throw new Exception(string.Format("No rules configured for message type [{0}]: Check the MessagingService.xml file to make sure a valid rule exists for the message type.", request.MessageType));
      MessageTypeRule rule = Configuration.MessageTypeRules[request.MessageType];
      if (rule == null) throw new Exception(string.Format("No rules found to process message type [{0}]: : Check the MessagingService.xml file to make sure a valid rule exists for the message type.", request.MessageType));
      //forwarding the message
      ea.BasicProperties.ReplyTo = mResponseQueue; 
      channel.BasicPublish("", rule.ForwardToQueue.Name, ea.BasicProperties, ea.Body);
      //channel.BasicAck(ea.DeliveryTag, true); //Testing immediate acknowledge once it is forwarded (no batching of acknowledgements)

      logger.LogDebug(" [x] Received request {0}", request.ToString());

    }

  }
}
