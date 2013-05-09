using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SampleSendRequestReceiveResponse
{

  using System;
  using System.Threading;

  using RabbitMQ.Client;

  interface ITransport
  {
    void Connect(string hostName, string virtualHost, string userName, string password, int port);

    void Disconnect();
  }

  //interface IRequestTransport
  //{
  //  void Connect(string hostName, string virtualHost, string userName, string password, int port);

  //  string SendMessage(string destinationQueue, string messageType, string xmlMessageBody, string replyToQueueName);
  //  //void SendMessage<T>(T message);
  //  //void SendMessage<T>(T message, string replyTo);

  //  void Disconnect();
  //}

  public class RabbitTransport : ITransport
  {
    protected IConnection connection;
    protected IModel channel;

    public IModel RabbitChannel
    {
      get { return channel; }
    }

    //private RequestResponseTest.Configuration configuration;

    public void Connect(string hostName, string virtualHost, string userName, string password, int port)
    {
      //this.configuration = configuration;

      ConnectionFactory factory = new ConnectionFactory
      {
        HostName = hostName,
        UserName = userName,
        Password = password,
        Port = port,
        VirtualHost = virtualHost
      };

      connection = factory.CreateConnection();
      channel = connection.CreateModel();

      //channel.ExchangeDeclare("Dead_Letter", "direct");

      //Dictionary<string, object> args = new Dictionary<string, object>();
      //args.Add("x-dead-letter-exchange", "Dead_Letter");
      ////args.Add("x-dead-letter-exchange", "/");
      //args.Add("x-dead-letter-routing-key", "TimeoutRequest");
      //args.Add("x-message-ttl", this.configuration.RequestMessageTimeoutInSeconds * 1000);

      ////QueueDeclareOk QueueDeclare(string queue, bool durable, bool exclusive, bool autoDelete, IDictionary arguments);
      //channel.QueueDeclare(this.configuration.RequestQueueName, true, false, false, args);

      ////channel.QueueDeclare(this.configuration.RequestQueueName, false, false, false, null);

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

    //public void SendMessage<T>(T message, string replyTo)
    //{
    //  byte[] messageBody = message.ToByteArray();
    //  //this.channel.BasicPublish(string.Empty, this.configuration.RequestQueueName, null, messageBody);

    //  IBasicProperties requestProperties = channel.CreateBasicProperties();
    //  requestProperties.CorrelationId = Guid.NewGuid().ToString();
    //  if (!string.IsNullOrEmpty(replyTo))
    //    requestProperties.ReplyTo = replyTo;

    //  this.channel.BasicPublish(string.Empty, this.configuration.RequestQueueName, requestProperties, messageBody);

    //}

    //public void SendMessage<T>(T message)
    //{
    //  SendMessage<T>(message, string.Empty);
    //}

    //public string SendMessage(string destinationQueue, string messageType, string xmlMessageBody, string replyToQueueName)
    //{
    //  //Create the MetraTech specific xml message and convert to byte array
    //  byte[] rabbitMessageBody = System.Text.Encoding.UTF8.GetBytes(MetraTechMessage.CreateRequestMessage(messageType, xmlMessageBody, true));

    //  //Create a unique correlation id for the message and set the replyToQueueName if specified
    //  IBasicProperties requestProperties = channel.CreateBasicProperties();
    //  requestProperties.CorrelationId = Guid.NewGuid().ToString();
    //  if (!string.IsNullOrEmpty(replyToQueueName))
    //    requestProperties.ReplyTo = replyToQueueName;

    //  //Send the message
    //  this.channel.BasicPublish(string.Empty, destinationQueue, requestProperties, rabbitMessageBody);

    //  return requestProperties.CorrelationId;
    //}
  }

}
