using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace RequestResponseTest
{
  using System;
  using System.Threading;

  using Messages;

  using RabbitMQ.Client;

  class RabbitTransport : RequestResponseTest.IRequestTransport
  {
    private IConnection connection;
    private IModel channel;

    private RequestResponseTest.Configuration configuration;

    public void Connect(string hostName, RequestResponseTest.Configuration configuration)
    {
      this.configuration = configuration;

      ConnectionFactory factory = new ConnectionFactory
      {
        HostName = hostName,
        VirtualHost = this.configuration.VirtualHostName
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

      //channel.QueueDeclare(this.configuration.RequestQueueName, false, false, false, null);

    }

    public void Disconnect()
    {
      channel = null;

      if (connection.IsOpen)
      {
        connection.Close();
      }

      connection.Dispose();
      connection = null;
    }

    public void SendMessage<T>(T message, string replyTo)
    {
      byte[] messageBody = message.ToByteArray();
      SendMessage(messageBody, replyTo);
    }

    public void SendMessage<T>(T message)
    {
      SendMessage<T>(message, string.Empty);
    }

    public void SendMessage(byte[] message, string replyTo)
    {
      byte[] messageBody = message.ToByteArray();
      //this.channel.BasicPublish(string.Empty, this.configuration.RequestQueueName, null, messageBody);

      IBasicProperties requestProperties = channel.CreateBasicProperties();
      requestProperties.CorrelationId = Guid.NewGuid().ToString();
      if (!string.IsNullOrEmpty(replyTo))
        requestProperties.ReplyTo = replyTo;

      this.channel.BasicPublish(string.Empty, this.configuration.RequestQueueName, requestProperties, messageBody);

    }
  }

}
