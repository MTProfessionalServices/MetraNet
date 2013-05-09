using System.Collections.Generic;
using RabbitMQ.Client;

namespace SampleSendRequestReceiveResponse
{
  public class RabbitQueueSetup: RabbitTransport
  {
    public void CreateQueue(string queueName)
    {
      CreateQueue(queueName, true, false, false);
    }

    public void CreateQueue(string queueName, bool durable, bool exclusive, bool autoDelete)
    {
      channel.QueueDeclare(queueName, durable, exclusive, autoDelete, GetDefaultQueueCreationArguments(queueName));
    }

    public Dictionary<string, object> GetDefaultQueueCreationArguments(string queueName)
    {
      //int messageTimeoutInSeconds = 60;

      Dictionary<string, object> args = new Dictionary<string, object>();

      //args.Add("x-dead-letter-exchange", "Dead_Letter");
      ////args.Add("x-dead-letter-exchange", "/");
      //args.Add("x-dead-letter-routing-key", "TimeoutRequest");
      //args.Add("x-message-ttl", this.configuration.RequestMessageTimeoutInSeconds * 1000);
      //args.Add("x-message-ttl", messageTimeoutInSeconds * 1000);

      return args;
    }

    public bool VerifyQueueExists(string queueName)
    {
      try
      {
        QueueDeclareOk result = channel.QueueDeclarePassive(queueName);
        return (result != null);
      }
      catch (RabbitMQ.Client.Exceptions.OperationInterruptedException ex)
      {
        if (ex.Message.Contains("NOT_FOUND"))
          return false;
        else
          throw;
      }

    }

    public bool GetQueueInformation(string queueName, out int messageCount, out int consumerCount)
    {
      messageCount = -1;
      consumerCount = -1;

      try
      {
        QueueDeclareOk result = channel.QueueDeclarePassive(queueName);
        if (result != null)
        {
          messageCount = (int)result.MessageCount;
          consumerCount = (int)result.ConsumerCount;

          return true;
        }
        else
        {
          return false;
        }
      }
      catch (RabbitMQ.Client.Exceptions.OperationInterruptedException ex)
      {
        if (ex.Message.Contains("NOT_FOUND"))
          return false;
        else
          throw;
      }
    }
     
  }
}
