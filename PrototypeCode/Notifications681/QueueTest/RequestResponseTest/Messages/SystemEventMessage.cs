using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Messages
{
  [Serializable]
  public class SystemEventMessage
  {
    public enum SystemEventType
    {
      Info,
      Error,
      Debug
    }

    public string EventName { get; set; }
    public SystemEventType EventType { get; set; }
    public string EventDetails { get; set; }

    public override string ToString()
    {
      return string.Format("EventName: {0} EventType: {1} EventDetails: {2}", EventName, EventType, EventDetails);
    }
  }
}
