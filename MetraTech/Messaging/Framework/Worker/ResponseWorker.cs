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

  public class ResponseWorker : ListenerWorker
  {

    public override void Initialize(int aThreadNumber, Configurations.QueueConfig aQueueConfig)
    {
      base.Initialize(aThreadNumber,aQueueConfig);
      logger = new Logger(string.Format("[ResponseWorker{0}]", ThreadNumber));
      this.QueuePrefetchCount = Configuration.ResponsePrefetchCount;
    }

    public override void ProcessMessage(BasicDeliverEventArgs ea)
    {
      Response response = new Response();
      response.Parse(ea);
      Request request = repository.GetRequest(response.CorrelationId);
      if (request == null)
      {
        string msg = string.Format("Unable to find original request for the response received. Correlation id {0} for message {1}", response.CorrelationId, response.MessageBody);
        throw new Exception(msg);
      }
      if (request.IsTimeoutNeeded) repository.CancelTimeout(response.CorrelationId);
      //put the original request back
      response.OriginalRequest = request;
      channel.BasicPublish("", request.ReplyToAddress, ea.BasicProperties, ea.Body);

      logger.LogDebug(" [x] Received response {0}", response.ToString());

    }

  }
}
