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
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Common.Logging.Configuration
{
  /// <summary>
  /// Represents the logging configuration.
  /// </summary>
  public class LoggingConfiguration
  {
    /// <summary>
    /// Gets or sets whether the tracing is enabled.
    /// </summary>
    [SerializePropertyAttribute]
    public bool TracingEnabled
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a name of the default log source category.
    /// </summary>
    [SerializePropertyAttribute(IsRequired = true)]
    public string DefaultCategory
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a list of registered listeners.
    /// </summary>
    [SerializeCollectionAttribute(IsRequired = true)]
    public TraceListenerConfiguration[] Listeners
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a list of registered log formatters.
    /// </summary>
    [SerializeCollectionAttribute(IsRequired = true)]
    public LogFormatterConfiguration[] Formatters
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a list of registered category sources.
    /// </summary>
    [SerializeCollectionAttribute(IsRequired = true)]
    public EventCategorySourceConfiguration[] CategorySources
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a configuration for "All Events" category.
    /// </summary>
    [SerializePropertyAttribute(IsRequired = true)]
    public EventCategorySourceConfiguration AllEvents
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a configuration for "Not Processed" category.
    /// </summary>
    [SerializePropertyAttribute(IsRequired = true)]
    public EventCategorySourceConfiguration NotProcessed
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a configuration for "Errors" category.
    /// </summary>
    [SerializePropertyAttribute(IsRequired = true)]
    public EventCategorySourceConfiguration Errors
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets an exception policy configuration.
    /// </summary>
    [SerializePropertyAttribute(IsRequired = true)]
    public ExceptionPolicyConfiguration ExceptionPolicyConfiguration
    {
      get;
      set;
    }

    /// <summary>
    /// Creates a new instance of the <see cref="LoggingConfiguration"/> class.
    /// </summary>
    public LoggingConfiguration()
    {
      // Initialize default values.
      this.TracingEnabled = true;
    }
  }
}