using System;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class ErrorObject
  {
    #region Constructors
    public ErrorObject()
    {
      Level = Level.Error;
    }

    public ErrorObject(string message)
    {
      Message = message;
    }

    public ErrorObject(string message, ErrorData errorData)
    {
      Message = message;
      ErrorData = errorData;
    }

    public ErrorObject(string message, string component)
    {
      Message = message;
      Component = component;
    }

    public ErrorObject(string message, string component, ErrorData errorData)
    {
      Message = message;
      Component = component;
      ErrorData = errorData;
    }

    public ErrorObject(string message, Level level)
    {
      Message = message;
      Level = level;
    }

    public ErrorObject(string message, Level level, ErrorData errorData)
    {
      Message = message;
      Level = level;
      ErrorData = errorData;
    }

    public ErrorObject(string message, Level level, string component)
    {
      Message = message;
      Level = level;
      Component = component;
    }

    public ErrorObject(string message, Level level, string component, ErrorData errorData)
    {
      Message = message;
      Level = level;
      Component = component;
      ErrorData = errorData;
    }

    #endregion

    #region Properties
    public Level Level { get; set; }
    public string Message { get; set; }
    public string Component { get; set; }
    public ErrorData ErrorData { get; set; }
    #endregion

  }

  public enum Level
  {
    Error,
    Warning,
    Info
  }

  
}
