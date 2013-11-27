using System;
using MetraTech;

public class UIException : ApplicationException
{
  private static readonly Logger Logger = new Logger("[MetraView]");
  
  public UIException(string message) : base(message)
  {
    Logger.LogError(message); 
  }
}
