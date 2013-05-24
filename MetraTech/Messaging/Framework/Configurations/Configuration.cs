using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Messaging.Framework.Configurations
{
  public class Configuration
  {
    public RabbitMQServerConfig Server = new RabbitMQServerConfig();
    public QueueConfig RequestQueue = new QueueConfig();
    public QueueConfig ResponseQueue = new QueueConfig();
    public QueueConfig ErrorQueue = new QueueConfig();
    public ThreadPoolConfig ThreadPool = new ThreadPoolConfig();

    public int RequestPrefetchCount { get; set; }
    public int ResponsePrefetchCount { get; set; }

    public int TimeoutRequestInSeconds { get; set; }
    public int ArchiveRequestInMinutes { get; set; }

    public string RequestPersistenceFolder { get; set; }

    public Dictionary<string, MessageTypeRule> MessageTypeRules = new Dictionary<string, MessageTypeRule>();

    public string MessagingServerUniqueIdentifier { get; set; }
  }

}
