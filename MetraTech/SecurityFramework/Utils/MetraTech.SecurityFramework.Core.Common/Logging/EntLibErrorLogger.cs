/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Text;
using MetraTech.SecurityFramework.Core.Common.Logging.Configuration;
using MetraTech.SecurityFramework.Serialization.Attributes;
using Microsoft.Practices.EnterpriseLibrary.Common.Configuration;
using Microsoft.Practices.EnterpriseLibrary.ExceptionHandling;
using Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Logging;
using Microsoft.Practices.EnterpriseLibrary.Logging;
using Microsoft.Practices.EnterpriseLibrary.Logging.Configuration;
using Microsoft.Practices.EnterpriseLibrary.Logging.Filters;
using Microsoft.Practices.EnterpriseLibrary.Logging.Formatters;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Common;

namespace MetraTech.SecurityFramework.Core.Common.Logging
{
  /// <summary>
  /// Provides logging errors functionality with Microsoft Enterprise Library.
  /// </summary>
  internal sealed class EntLibErrorLogger : IErrorLogger
  {
    private const string PolicyNameAttribute = "policyName";
    private const string PolicyNotConfigured = "Required attribute \"policyName\" not found.";
    private const string NoExceptionPolicySpecified = "Exception policy not specified.";

    private ExceptionManager _manager;
    private string _category;
    private Dictionary<string, LogSource> _logSources;
    public TraceListenerConfiguration[] _listeners;

    /// <summary>
    /// Gets or internally sets an exception handling policy name.
    /// </summary>
    [SerializePropertyAttribute]
    public string PolicyName
    {
      get;
      private set;
    }

    #region Public methods

    /// <summary>
    /// Reads the logger configuration.
    /// </summary>
    /// <param name="configuration">A configuration to be read.</param>
    public void Initialize(LoggingConfiguration configuration)
    {
      if (configuration == null)
      {
        throw new ArgumentNullException(Constants.Arguments.Configuration);
      }

      if (configuration.ExceptionPolicyConfiguration == null)
      {
        throw new ArgumentException(NoExceptionPolicySpecified, Constants.Arguments.Configuration);
      }

      try
      {
        // Setup a logging configuration.
        Dictionary<string, TraceListener> listeners = new Dictionary<string, TraceListener>();
        _logSources = new Dictionary<string, LogSource>();

        InitializeLogging(configuration, listeners, _logSources);
        LogSource errorSource = configuration.Errors != null ? CreateLogSource(listeners, configuration.Errors) : null;
        this._listeners = configuration.Listeners;

        // Setup an exception handling policy.
        List<ExceptionPolicyEntry> policyEntries = CreateExceptionPolicyEntries(configuration, _logSources, errorSource);

        ExceptionPolicyImpl policy =
            new ExceptionPolicyImpl(configuration.ExceptionPolicyConfiguration.PolicyName, policyEntries);

        Dictionary<string, ExceptionPolicyImpl> policies = new Dictionary<string, ExceptionPolicyImpl>();
        policies.Add(policy.PolicyName, policy);
        _manager = new ExceptionManagerImpl(policies);

        this.PolicyName = policy.PolicyName;
        _category = configuration.DefaultCategory;
      }
      catch (ConfigurationException)
      {
        throw;
      }
      catch (Exception ex)
      {
        throw new ConfigurationException(ex.Message, ex);
      }
    }

    /// <summary>
    /// Writes info about the exception to the log.
    /// </summary>
    /// <param name="ex">The data to be written.</param>
    /// <returns>true if the exception was handled successfully and false otherwise.</returns>
    public bool Log(Exception ex)
    {
      bool result;
      if (_manager != null)
      {
        result = _manager.HandleException(ex, this.PolicyName);
      }
      else
      {
        result = ExceptionPolicy.HandleException(ex, this.PolicyName);
      }

      return result;
    }

    /// <summary>
    /// Writes Debug message to the log.
    /// </summary>
    /// <param name="msg">The data to be written.</param>
    public void LogDebug(string msg)
    {
      LogMessage(msg, TraceEventType.Verbose);
    }

    /// <summary>
    /// Writes Debug message to the log.
    /// </summary>
    /// <param name="tag">String describing WHERE the log called.
    /// For example Subsystem and Method names</param>
    /// <param name="msg">The data to be written.</param>
    public void LogDebug(string tag, string msg)
    {
      LogMessage(tag, msg, TraceEventType.Verbose);
    }

    /// <summary>
    /// Writes Info message to the log.
    /// </summary>
    /// <param name="msg">The data to be written.</param>
    public void LogInfo(string msg)
    {
      LogMessage(msg, TraceEventType.Information);
    }

    /// <summary>
    /// Writes Info message to the log.
    /// </summary>
    /// <param name="tag">String describing WHERE the log called.
    /// For example Subsystem and Method names</param>
    /// <param name="msg">The data to be written.</param>
    public void LogInfo(string tag, string msg)
    {
      LogMessage(tag, msg, TraceEventType.Information);
    }
    /// <summary>
    /// Writes Warning message to the log.
    /// </summary>
    /// <param name="msg">The data to be written.</param>
    public void LogWarning(string msg)
    {
      LogMessage(msg, TraceEventType.Warning);
    }

    /// <summary>
    /// Writes Error message to the log.
    /// </summary>
    /// <param name="tag">String describing WHERE the log called.
    /// For example Subsystem and Method names</param>
    /// <param name="msg">The data to be written.</param>
    public void LogError(string tag, string msg)
    {
      LogMessage(msg, TraceEventType.Error);
    }

    /// <summary>
    /// Writes Warning message to the log.
    /// </summary>
    /// <param name="tag">String describing WHERE the log called.
    /// For example Subsystem and Method names</param>
    /// <param name="msg">The data to be written.</param>
    public void LogWarning(string tag, string msg)
    {
      LogMessage(tag, msg, TraceEventType.Warning);
    }

    /// <summary>
    /// Determines if there is any listener esteblished to log DEBUG messages.
    /// </summary>
    /// <returns>true if the logging is enabled and false otherwise</returns>
    public bool CanLogDebug()
    {
      bool result = CanLogLevel(System.Diagnostics.SourceLevels.Verbose);

      return result;
    }

    /// <summary>
    /// Determines if there is any listener esteblished to log INFO messages.
    /// </summary>
    /// <returns>true if the logging is enabled and false otherwise</returns>
    public bool CanLogInfo()
    {
      bool result = CanLogLevel(System.Diagnostics.SourceLevels.Information);

      return result;
    }

    /// <summary>
    /// Determines if there is any listener esteblished to log WARNING messages.
    /// </summary>
    /// <returns>true if the logging is enabled and false otherwise</returns>
    public bool CanLogWarning()
    {
      bool result = CanLogLevel(System.Diagnostics.SourceLevels.Warning);

      return result;
    }

    /// <summary>
    /// Determines if there is any listener esteblished to log ERROR messages.
    /// </summary>
    /// <returns>true if the logging is enabled and false otherwise</returns>
    public bool CanLogError()
    {
      bool result = CanLogLevel(System.Diagnostics.SourceLevels.Error);

      return result;
    }

    #endregion

    #region Private methods

    private static void SafeSetProperty(object obj, Type objType, object value, string propertyName)
    {
      PropertyInfo property = objType.GetProperty(propertyName);
      if (property != null)
      {
        property.SetValue(obj, value, null);
      }
    }

    private static void InitializeLogging(LoggingConfiguration configuration, Dictionary<string, TraceListener> listeners, Dictionary<string, LogSource> sources)
    {
      // Initialize formatters.
      Dictionary<string, ILogFormatter> formatters = new Dictionary<string, ILogFormatter>();

      if (configuration.Formatters != null)
      {
        foreach (LogFormatterConfiguration formatterDefinition in configuration.Formatters)
        {
          Type formatterType = Type.GetType(formatterDefinition.TypeName, true);
          ILogFormatter formatter = (ILogFormatter)Activator.CreateInstance(formatterType);

          SafeSetProperty(formatter, formatterType, formatterDefinition.Template, Constants.Properties.Template);

          formatters.Add(formatterDefinition.Name, formatter);
        }
      }

      // Initialize trace listeners.
      if (configuration.Listeners != null)
      {
        foreach (TraceListenerConfiguration listenerDefinition in configuration.Listeners)
        {
          TraceListener listener = CreateTraceListener(formatters, listenerDefinition);

          listeners.Add(listenerDefinition.Name, listener);

          if (configuration.TracingEnabled)
          {
            Trace.Listeners.Add(listener);
          }
        }
      }

      // Initialize log sources.
      if (configuration.CategorySources != null)
      {
        foreach (EventCategorySourceConfiguration sourceDefinition in configuration.CategorySources)
        {
          LogSource source = CreateLogSource(listeners, sourceDefinition);
          sources.Add(sourceDefinition.CategoryName, source);
        }
      }

      if (configuration.AllEvents != null && configuration.AllEvents.Listeners != null)
      {
        LogSource allEvents = CreateLogSource(listeners, configuration.AllEvents);
        sources.Add(configuration.AllEvents.CategoryName, allEvents);
      }
    }

    private static TraceListener CreateTraceListener(Dictionary<string, ILogFormatter> formatters, TraceListenerConfiguration listenerDefinition)
    {
      Type listenerDataType = Type.GetType(listenerDefinition.ListenerDataType, true);
      TraceListenerData listenerData = (TraceListenerData)Activator.CreateInstance(listenerDataType);

      // Initialize general properties.
      SafeSetProperty(listenerData, listenerDataType, listenerDefinition.Filter, Constants.Properties.Filter);
      // SafeSetProperty(listenerData, listenerDataType, listenerDefinition.Formatter, Constants.Properties.Formatter);
      SafeSetProperty(listenerData, listenerDataType, listenerDefinition.IndentLevel, Constants.Properties.IndentLevel);
      SafeSetProperty(listenerData, listenerDataType, listenerDefinition.IndentSize, Constants.Properties.IndentSize);
      SafeSetProperty(listenerData, listenerDataType, listenerDefinition.NeedIndent, Constants.Properties.NeedIndent);

      TraceOptions options = TraceOptions.None;
      if (!string.IsNullOrEmpty(listenerDefinition.TraceOutputOptions))
      {
        options = (TraceOptions)Enum.Parse(typeof(TraceOptions), listenerDefinition.TraceOutputOptions, true);
      }

      SafeSetProperty(listenerData, listenerDataType, options, Constants.Properties.TraceOutputOptions);

      // Initialize file log specific properties.
      FlatFileTraceListenerConfiguration fileListenerDefinition =
          listenerDefinition as FlatFileTraceListenerConfiguration;
      if (fileListenerDefinition != null)
      {
        SafeSetProperty(
            listenerData,
            listenerDataType,
            fileListenerDefinition.FileName,
            Constants.Properties.FileName);
      }

      TraceListener listener =
          listenerData.
          GetRegistrations().
          Select(p => p.LambdaExpression.Compile().DynamicInvoke() as TraceListener).
          FirstOrDefault();

      if (!string.IsNullOrEmpty(listenerDefinition.Formatter))
      {
        SafeSetProperty(listener, listener.GetType(), formatters[listenerDefinition.Formatter], Constants.Properties.Formatter);
      }

      return listener;
    }

    private static LogSource CreateLogSource(Dictionary<string, TraceListener> listeners, EventCategorySourceConfiguration sourceDefinition)
    {
      LogSource source;

      IEnumerable<TraceListener> sourceListeners =
          listeners.Where(p => sourceDefinition.Listeners.Contains(p.Key)).Select(p => p.Value);
      source = new LogSource(sourceDefinition.CategoryName, sourceListeners, sourceDefinition.SwitchValue);

      return source;
    }

    private static List<ExceptionPolicyEntry> CreateExceptionPolicyEntries(LoggingConfiguration configuration, Dictionary<string, LogSource> sources, LogSource errorSource)
    {
      List<ExceptionPolicyEntry> policyEntries = new List<ExceptionPolicyEntry>();

      if (configuration.ExceptionPolicyConfiguration.ExceptionTypes != null)
      {
        foreach (ExceptionTypeConfiguration typeDefinition in configuration.ExceptionPolicyConfiguration.ExceptionTypes)
        {
          // Create a policy for the especial exception type.
          Type exceptionType = Type.GetType(typeDefinition.TypeName, true);

          List<IExceptionHandler> handlers = new List<IExceptionHandler>();

          if (typeDefinition.ExceptionHandlers != null)
          {
            foreach (ExceptionHandlerConfiguration handlerDefinition in typeDefinition.ExceptionHandlers)
            {
              CreateExceptionHandler(configuration, sources, errorSource, handlers, handlerDefinition);
            }
          }

          ExceptionPolicyEntry entry = new ExceptionPolicyEntry(exceptionType, typeDefinition.PostHandlingAction, handlers);
          policyEntries.Add(entry);
        }
      }

      return policyEntries;
    }

    private static void CreateExceptionHandler(
        LoggingConfiguration configuration,
        Dictionary<string, LogSource> sources,
        LogSource errorSource,
        List<IExceptionHandler> handlers,
        ExceptionHandlerConfiguration handlerDefinition)
    {
      Type handlerType = Type.GetType(handlerDefinition.TypeName, true);

      if (handlerType == typeof(LoggingExceptionHandler))
      {
        LogWriterImpl writer = new LogWriterImpl(
            new ILogFilter[]
                    {
                    },
            sources.Values,
            errorSource,
            configuration.DefaultCategory);

        IExceptionHandler handler = new LoggingExceptionHandler(
            handlerDefinition.LogCategory,
            handlerDefinition.EventId,
            handlerDefinition.Severity,
            handlerDefinition.Title,
            handlerDefinition.Priority,
            Type.GetType(handlerDefinition.FormatterType, true),
            writer);

        handlers.Add(handler);
      }
      // else
      // Ignore another handler types for now.
    }

    /// <summary>
    /// Writes message ot the log
    /// </summary>
    /// <param name="msg">The data to be written.</param>
    /// <param name="severity">Identifies the type of event that has caused the trace.</param>
    private void LogMessage(string msg, TraceEventType severity)
    {
      try
      {
        Write(new LogEntry() { Message = msg, Severity = severity, }, severity);
      }
      catch (Exception ex)
      {
        Log(ex);
      }
    }

    /// <summary>
    /// Writes message ot the log
    /// </summary>
    /// <param name="tag">String describing WHERE the log called.
    /// For example Subsystem and Method names</param>
    /// <param name="msg">The data to be written.</param> 
    /// <param name="severity">Identifies the type of event that has caused the trace.</param>
    private void LogMessage(string tag, string msg, TraceEventType severity)
    {
      try
      {
        Write(
          new LogEntry()
          {
            Message = msg,
            Severity = severity,
            ExtendedProperties = new Dictionary<string, object>() { { Constants.Logging.DefaultTagKey, FormatTag(tag) } }
          },
          severity
        );
      }
      catch (Exception ex)
      {
        Log(ex);
      }
    }

    private void Write(LogEntry logEntry, TraceEventType severity)
    {
      if (_logSources != null)
      {
        foreach (LogSource source in _logSources.Values)
        {
          source.TraceData(severity, 100, logEntry);
        }
      }
    }

    /// <summary>
    /// Adds start string ("[" by default) at the start of tag and end string("]" by default) at the end of it
    /// whether them don`t already exist
    /// </summary>
    /// <param name="tag">tag to format</param>
    /// <param name="startString">"[" by default</param>
    /// <param name="endString">"]" by default</param>
    /// <returns>Formatted tag</returns>
    private string FormatTag(string tag, string startString = "[", string endString = "]")
    {
      var formattedTag = new StringBuilder();
      if (!tag.StartsWith(startString))
        formattedTag.Append(startString);
      formattedTag.Append(tag);
      if (!tag.EndsWith(endString))
        formattedTag.Append(endString);
      return formattedTag.ToString();
    }

    private bool CanLogLevel(System.Diagnostics.SourceLevels level)
    {
      bool result = false;

      if (this._listeners != null)
      {
        for (int i = 0; i < this._listeners.Length; i++)
        {
          result = this._listeners[i].Filter >= level;
        }
      }

      return result;
    }

    #endregion
  }
}
