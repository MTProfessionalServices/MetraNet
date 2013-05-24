using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Security.Permissions;

using log4net;


namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class BasicException : System.Exception, ISerializable
  {
    public BasicException()
    {
      LogMessage("Error occurred", null, BasicException.m_Component, null);
    }

    public BasicException(string message)
      : base(message)
    {
      LogMessage(message, null, BasicException.m_Component, null);
    }

    public BasicException(string message, string component)
      : base(message)
    {
      LogMessage(message, null, component, null);
    }

    public BasicException(string message, List<ErrorObject> errors)
      : base(message)
    {
      LogMessage(message, errors, BasicException.m_Component, null);
      Errors = errors;
    }

    public BasicException(string message, List<ErrorObject> errors, string component)
      : base(message)
    {
      LogMessage(message, errors, component, null);
      Errors = errors;
    }

    public BasicException(System.Exception e)
      : base("Error occurred", e)
    {
      LogMessage("Error occurred", null, BasicException.m_Component, e);
    }

    public BasicException(System.Exception e, string component)
      : base("Error occurred", e)
    {
      LogMessage("Error occurred", null, component, e);
    }

    public BasicException(string message, System.Exception e)
      : base(message, e)
    {
      LogMessage(message, null, BasicException.m_Component, e);
    }

    public BasicException(string message, System.Exception e, string component)
      : base(message, e)
    {
      LogMessage(message, null, component, e);
    }

    public BasicException(string message, List<ErrorObject> errors, System.Exception e)
      : base(message, e)
    {
      LogMessage(message, errors, m_Component, e);
      Errors = errors;
    }

    public BasicException(string message, List<ErrorObject> errors, System.Exception e, string component)
      : base(message, e)
    {
      LogMessage(message, errors, component, e);
      Errors = errors;
    }

    #region ISerializable
    protected BasicException(SerializationInfo info, StreamingContext context) 
    {
      Errors = (List<ErrorObject>)info.GetValue("errors", typeof(List<ErrorObject>));
      ErrorMessage = (string)info.GetValue("errormessage", typeof(string));
      InnerMessage = (string)info.GetValue("innermessage", typeof(string));
      InnerStackTrace = (string)info.GetValue("innerstacktrace", typeof(string));
      Component = (string)info.GetValue("component", typeof(string));

      LogMessage(ErrorMessage, Errors, Component, InnerMessage, InnerStackTrace);
    }

    [SecurityPermissionAttribute(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
      info.AddValue("errors", Errors);
      info.AddValue("errormessage", Message);
      info.AddValue("innermessage", InnerMessage);
      info.AddValue("innerstacktrace", InnerStackTrace);
      info.AddValue("component", Component);
      base.GetObjectData(info, context);
    }


    #endregion

    #region Properties
    public List<ErrorObject> Errors { get; protected set; }
    public string ErrorMessage { get; set; }
    public string InnerMessage { get; set; }
    public string InnerStackTrace { get; set; }
    public string Component { get; set; }

    #endregion



    #region Private Methods

    private void LogMessage(string errorMessage, List<ErrorObject> errors, string component, System.Exception e)
    {
      if (e != null)
      {
        ErrorMessage = errorMessage;
        InnerMessage = e.Message + Environment.NewLine; 
        System.Exception exception = e.InnerException;
        while (exception != null)
        {
          InnerMessage += exception.Message + Environment.NewLine;
          exception = exception.InnerException;
        }
        
        InnerStackTrace = e.StackTrace;

        ILog logger = LogManager.GetLogger(component);
        logger.Error(errorMessage, e);
        LogMessage(null, errors, component, null, null);
      }
      else
      {
        LogMessage(errorMessage, errors, component, null, null);
        
      }
    }

    private void LogMessage(string errorMessage, 
                            List<ErrorObject> errors, 
                            string component, 
                            string innerMessage, 
                            string innerStackTrace)
    {
      
      Component = component;

      ILog logger = LogManager.GetLogger(component);

      if (!String.IsNullOrEmpty(errorMessage))
      {
        ErrorMessage = errorMessage;
        logger.Error(errorMessage);
      }

      if (!String.IsNullOrEmpty(innerMessage))
      {
        InnerMessage = innerMessage;
        logger.Error(innerMessage);
      }

      if (!String.IsNullOrEmpty(innerStackTrace))
      {
        InnerStackTrace = innerStackTrace;
        logger.Error(innerStackTrace);
      }

      if (errors != null)
      {
        Errors = errors;
        foreach (ErrorObject errorObject in errors)
        {
          if (!String.IsNullOrEmpty(errorObject.Component))
          {
            ILog componentLogger = LogManager.GetLogger(errorObject.Component);
            LogMessage(errorObject.Message, errorObject.Level, componentLogger);
          }
          else
          {
            LogMessage(errorObject.Message, errorObject.Level, logger);
          }
        }
      }
    }

    private void LogMessage(string message, Level level, ILog logger)
    {
      if (level == Level.Warning)
      {
        logger.Warn(message);
      }
      else
      {
        logger.Error(message);
      }
    }
  
    #endregion

    #region Data
    [NonSerialized]
    private static readonly string m_Component = "BusinessEntityException";
    #endregion
  }
}
