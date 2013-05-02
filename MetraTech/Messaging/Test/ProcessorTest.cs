using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MetraTech.Messaging.Framework;
using MetraTech.Messaging.Framework.Configurations;

namespace MetraTech.Messaging.Test
{
  //
  // To run the this test fixture:
  // S:\Thirdparty\NUnit260\bin\nunit-console-x86.exe o:\debug\Bin\MetraTech.Messaging.Test.dll
  //

  [TestClass]
  [ComVisible(false)]
  public class ProcessorTest
  {
    /// <summary>
    /// Test Start and Stop
    /// </summary>
    [TestMethod()]
    public void TestRestart()
    {
      MessageProcessor processor = new MessageProcessor();
      processor.Start();
      Thread.Sleep(5000);
      processor.Stop();
      //Assert.AreEqual(1, 1, "Hey, should not be paused");
    }

    /// <summary>
    /// Test Start and Stop
    /// </summary>
    [TestMethod()]
    public void TestSendReceive()
    {
      string ConfigFileName = @"R:\config\Messaging\MessagingService.xml";
      
      MessageProcessor processor = new MessageProcessor();
      processor.ReadConfigFile(ConfigFileName);
      processor.Start();

      ConnectionFactory factory = processor.factory;

      using (IConnection connection = processor.factory.CreateConnection())
      {
        using (IModel channel = connection.CreateModel())
        {
          channel.QueueDeclare(processor.Configuration.RequestQueue.Name, true, false, false, null);
          int num = 5;
          for (int i = 0; i < num; i++)
          {
            Framework.Messages.Request request = new Framework.Messages.Request();
            request.MessageType = "TestMessageType";
            request.ReplyToAddress = "hello";
            request.SetRequestBodyAsString(i.ToString());
            //string message = string.Format("<root>{0}</root>", i);
            //byte[] body = System.Text.Encoding.UTF8.GetBytes(message);
            byte[] body = System.Text.Encoding.UTF8.GetBytes(request.MessageBody);
            IBasicProperties props = channel.CreateBasicProperties();
            props.ContentType = "text/plain";
            props.DeliveryMode = 2;
            props.Expiration = "200";
            //props.CorrelationId = Guid.NewGuid().ToString();
            props.CorrelationId = request.CorrelationId.ToString();
            props.ReplyTo = request.ReplyToAddress;
            channel.BasicPublish("", processor.Configuration.RequestQueue.Name, props, body);
          }
          Thread.Sleep(1000);
          string testQueueName = processor.Configuration.MessageTypeRules["TestMessageType"].ForwardToQueue.Name;
          channel.QueueDeclare(testQueueName, true, false, false, null);
          QueueingBasicConsumer consumer = new QueueingBasicConsumer(channel);
          channel.BasicConsume(testQueueName, true, consumer);
          int j = 0;
          while (true)
          {
            object result;
            if (!consumer.Queue.Dequeue(1000, out result)) break;
            BasicDeliverEventArgs ea = result as BasicDeliverEventArgs;
            Framework.Messages.Request request = new Framework.Messages.Request();
            request.Parse(ea);
            Framework.Messages.Response response = new Framework.Messages.Response(request.CorrelationId);
            response.SetResponseBodyAsXml(j.ToString());
            byte[] body = System.Text.Encoding.UTF8.GetBytes(response.MessageBody);
            channel.BasicPublish("", ea.BasicProperties.ReplyTo,ea.BasicProperties, body);
            j++;
          }
          Thread.Sleep(1000);//sleep so responses can be processed
          processor.Stop();
          Assert.AreEqual(num, j, "unexpected number of messages processed");
        }

      }
    }
      
  }


}
