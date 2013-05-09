using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RabbitMQ.Client;
using System.Net;
using System.IO;

namespace RequestResponseTest
{
  public class NotificationsManagementRabbitMQ : INotificationsManagement
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
    }

    public List<string> GetQueues()  //Possibly just for particular exchange
    {
      List<string> results = new List<string>();

      //Dummy code for now
      Configuration configuration = new Configuration();

      results.Add(configuration.RequestQueueName);

      //Need to 'discover' all the response queues

      return results;
    }

    public Dictionary<string, string> GetQueueInformation(string queueName) //Need to abstract out channel for MetraTech
    {
      Dictionary<string, string> results = new Dictionary<string, string>();

      try
      {
        QueueDeclareOk result = channel.QueueDeclarePassive(queueName);
        if (result != null)
        {
          results.Add("MessageCount", result.MessageCount.ToString());
          results.Add("ConsumerCount", result.ConsumerCount.ToString());
        }
      }
      catch (Exception ex)
      {
        throw new ArgumentException(string.Format("Unable to get queue information for {0}: {1}", queueName, ex.Message), ex);
      }

      return results;
    }

    public void PurgeQueue(string queueName)
    {}

    public void MoveMessages(string fromQueueName, string toQueueName)
    { }

    public void MoveMessages(string fromQueueName, string toQueueName, List<string> messageIdentifiers)
    {}

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

    
    
  }


  public class RabbitMQManagementAPI
  {
    public string Host { get; set; }
    public string UserName { get; set; }
    public string Password { get; set; }
    public int Port { get; set; }

    public string VirtualHost { get; set; }

    public RabbitMQManagementAPI()
    {
      Host = "localhost";
      UserName = "guest";
      Password = "guest";
      Port = 55672;
    }

    protected string MakeRequest(string url)
    {
      // used to build entire input
      StringBuilder sb = new StringBuilder();

      // used on each read operation
      byte[] buf = new byte[8192];

      // prepare the web page we will be asking for
      HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);

      //Set the username/password
      CredentialCache wrCache = new CredentialCache();
      wrCache.Add(new Uri(url), "Basic", new NetworkCredential(this.UserName, this.Password));
      request.Credentials = wrCache;

      // execute the request
      HttpWebResponse response = (HttpWebResponse)request.GetResponse();

      // we will read data via the response stream
      Stream resStream = response.GetResponseStream();

      string tempString = null;
      int count = 0;

      do
      {
        // fill the buffer with data
        count = resStream.Read(buf, 0, buf.Length);

        // make sure we read some data
        if (count != 0)
        {
          // translate from bytes to ASCII text
          tempString = Encoding.ASCII.GetString(buf, 0, count);

          // continue building the string
          sb.Append(tempString);
        }
      }
      while (count > 0); // any more data to read?

      // print out page source
      //Console.WriteLine(sb.ToString());

      return sb.ToString();
    }

    protected string BaseURL(string request)
    {
      return "http://" + Host + ":" + Port.ToString() + "/api/" + request;
    }

    public string GetQueueList()
    {
      return MakeRequest(BaseURL("queues"));
    }

    public string GetExchangeList()
    {
      return MakeRequest(BaseURL("exchanges"));
    }
  }
}
