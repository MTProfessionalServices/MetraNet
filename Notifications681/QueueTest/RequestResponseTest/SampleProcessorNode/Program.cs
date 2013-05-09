using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace RequestResponseTest
{
  class Program
  {
    static void Main(string[] args)
    {
      Configuration configuration = new Configuration();

      string startMessage = string.Format("Waiting for messages on {0}/{1}. Press 'q' to quit",
        configuration.RequestHostName, configuration.RequestQueueName);

      Console.WriteLine(startMessage);

      RabbitConsumer consumer = new RabbitConsumer();
      consumer.Connect(configuration);

      consumer.ConsumeMessages();

      Console.WriteLine("Quitting...");
    }
  }
}
