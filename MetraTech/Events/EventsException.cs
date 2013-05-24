using System;

namespace MetraTech.Events
{
  [Serializable]
  public class EventsException : ApplicationException
  {
    readonly Logger _logger = new Logger("[MetraTech.Events.EventsException]");

    public EventsException()
    { }

    public EventsException(string message)
      : base(message)
    {
      _logger.LogError(message);
    }

    public EventsException(string message, Exception e)
      : base(message, e)
    {
      _logger.LogException(message, e);
    }
  }
}