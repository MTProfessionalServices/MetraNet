using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Messaging.Framework.Configurations
{
  public class MessageTypeRule
  {
    public string MessageType;
    public bool IsTimeoutNeeded;
    public bool IsResponseNeeded;
    public QueueConfig ForwardToQueue = new QueueConfig();
  }
}
