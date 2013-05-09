using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MonitorQueues
{
  class Program
  {
    static void Main(string[] args)
    {
      Console.WriteLine("Current Interesting Queue Status");

      //RequestResponseTest.INotificationsManagement management = new RequestResponseTest.NotificationsManagementRabbitMQ();
      RequestResponseTest.NotificationsManagementRabbitMQ management = new RequestResponseTest.NotificationsManagementRabbitMQ(); 
      RequestResponseTest.Configuration configuration = new RequestResponseTest.Configuration();

      management.Connect(configuration);

      List<string> queues = management.GetQueues();

      foreach(string queueName in queues)
      {
        Console.WriteLine("==== {0} =================", queueName);
        WriteQueueInformationToConsole(management.GetQueueInformation(queueName));
      }

      //Json
      RequestResponseTest.RabbitMQManagementAPI rabbitManagement = new RequestResponseTest.RabbitMQManagementAPI();
      rabbitManagement.Host = configuration.ManagementHostName;
      rabbitManagement.UserName = configuration.ManagementUserName;
      rabbitManagement.Password = configuration.ManagementPassword;
      
      Console.WriteLine("=== Raw Json For All Queues ==============");
      Console.WriteLine(rabbitManagement.GetQueueList());
      Console.WriteLine(rabbitManagement.GetExchangeList());

      management.Disconnect();

    }

    static void WriteQueueInformationToConsole(Dictionary<string, string> queueInformation)
    {
      
      foreach (KeyValuePair<string, string> kvp in queueInformation)
        Console.WriteLine("\t{0}\t{1}", kvp.Key, kvp.Value);

      Console.WriteLine();
    }
  }
}
