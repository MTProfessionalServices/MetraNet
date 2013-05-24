using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MetraTech;

namespace MetraTech.Messaging.Framework.Worker
{
  public class BaseWorker
  {
    protected Logger logger;
    protected bool mHasUnAcknowledgedMessages = false;
    private bool mNeedToAcknowledge = false;
    public bool NeedToAcknowledge
    {
      set
      {
        lock (this)
        {
          mNeedToAcknowledge = value;
        }
      }
      get
      {
        lock (this)
        {
          return mNeedToAcknowledge;
        }
      }
    }
    public ConnectionFactory factory;
    public Persistence.IRequestRepository repository = null;

    public BaseWorker()
    {
      repository = SharedStructures.Repository;
      factory = SharedStructures.RabbitMQFactory;
    }

    //Needs Persistence class
    //Queue class
    //Message Parser

  }
}
