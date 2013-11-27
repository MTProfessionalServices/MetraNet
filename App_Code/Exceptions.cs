using System;
using MetraTech;

public class UIException : ApplicationException
{
  private static readonly Logger Logger = new Logger("[MetraNet]");
  
  public UIException(string message) : base(message)
  {
    Logger.LogError(message); 
  }
}
