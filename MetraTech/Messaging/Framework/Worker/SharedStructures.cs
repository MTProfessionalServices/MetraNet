using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Messaging.Framework.Worker
{
  public static class SharedStructures
  {
    private static object l = new object();
    
    private static Configurations.Configuration mConfiguration = null;
    public static Configurations.Configuration Configuration {
      get {
        lock (l) return mConfiguration;
      }
      set
      {
        lock (l) mConfiguration = value;
      }
    }

    private static Persistence.IRequestRepository mRepository = null;
    public static Persistence.IRequestRepository Repository
    {
      get
      {
        lock (l) return mRepository;
      }
      set
      {
        lock (l) mRepository = value;
      }
    }

    private static RabbitMQ.Client.ConnectionFactory mRabbitMQFactory = null;
    public static RabbitMQ.Client.ConnectionFactory RabbitMQFactory
    {
      get { lock (l) return mRabbitMQFactory; }
      set { lock (l) mRabbitMQFactory = value; }
    }
  }
}
