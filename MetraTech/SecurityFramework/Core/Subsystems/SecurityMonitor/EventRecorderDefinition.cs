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
using System.Reflection;
using System.Text;
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Determines an event recorder.
    /// </summary>
    public class EventRecorderDefinition
    {
        #region Private fileds

        private static readonly Type[] CustomFilterArguments = new Type[] { typeof(object), typeof(CustomFilterEventArgs) };

        private List<SecurityEventFilter> _filters;
        private SecurityEventWriter _writer;

        #endregion

        #region Properties

        /// <summary>
        /// Gets or sets an unique id of the recorder.
        /// </summary>
        public string Id
        {
            get;
            private set;
        }

        #endregion

        #region Public methods

        /// <summary>
        /// Initializes filters and a writer.
        /// </summary>
        public void Initialize(EventRecorderDefinitionProperties properties)
        {
            if (properties == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Properties);
            }

            Id = properties.Id;
            _writer = null;
            _filters = new List<SecurityEventFilter>();

            try
            {
                // Initialize the writer.
                _writer = properties.CreateWriter();

                if (properties.Filters != null)
                {
                    // Initialize the filters list.
                    for (int i = 0; i < properties.Filters.Length; i++)
                    {
                        EventFilterProperties filterDefinition = properties.Filters[i];
                        SecurityEventFilter filter =
                            new SecurityEventFilter()
                            {
                                EventType = filterDefinition.EventType,
                                SubsystemName = properties.Filters[i].SubsystemName,
                                SubsystemCategoryName = properties.Filters[i].SubsystemCategoryName
                            };

                        if (filterDefinition.CustomFilter != null)
                        {
                            // Initialize a custom filter when specified.
                            Type handlerType = Type.GetType(filterDefinition.CustomFilter.TypeName, true);
                            MethodInfo handlerMethod =
                                handlerType.GetMethod(filterDefinition.CustomFilter.MethodName, CustomFilterArguments);

                            if (handlerMethod == null || !handlerMethod.IsStatic)
                            {
                                throw new ConfigurationException(
                                    string.Format(
                                    "Unable find a static method \"{1}\" in the type\"{0}\".",
                                    filterDefinition.CustomFilter.TypeName,
                                    filterDefinition.CustomFilter.MethodName));
                            }

                            // Create a delegate from the custom filter method.
                            filter.CustomFilter += new CustomFilterEventHandler(
                                delegate(object sender, CustomFilterEventArgs e)
                                {
                                    handlerMethod.Invoke(null, new object[] { sender, e });
                                });
                        }

                        AddFilter(filter);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new ConfigurationException(
                    string.Format(
                    "Cannot initialize the event recorder \"{0}\". See inner exception for details.",
                    properties.Id),
                    ex);
            }
        }

        /// <summary>
        /// Determines whether a specified event matches at least one of the configured filters
        /// and writes it using the configured writer if matches.
        /// </summary>
        /// <param name="securityEvent">An event to be written.</param>
		/// <param name="actions">A list of recommended actions for the event.</param>
		/// <exception cref="ArgumentNullException">if <paramref name="securityEvent"/> is null.</exception>
		public void Record(ISecurityEvent securityEvent, IEnumerable<PolicyAction> actions)
		{
			if (securityEvent == null)
			{
				throw new ArgumentNullException(Constants.Arguments.SecurityEvent);
			}

			bool isMatched = false;
			if (_filters != null && _filters.Count > 0)
			{
				// Evaluate filters if any.
				foreach (SecurityEventFilter filter in _filters)
				{
					if (filter.IsMatched(securityEvent))
					{
						isMatched = true;
						break;
					}
				}
			}
			else
			{
				isMatched = true;
			}

			if (isMatched)
			{
				_writer.BeginRecord();
				try
				{
					securityEvent.Record(_writer);
					if (actions != null && _writer.SupportsActionsRecording)
					{
						// Record recommended security policy actions if any.
						foreach (PolicyAction action in actions)
						{
							_writer.BeginRecordAction();
							action.Record(_writer);
							_writer.EndRecordAction();
						}
					}
				}
				finally
				{
					_writer.EndRecord();
				}
			}
		}

        /// <summary>
        /// Adds a filter to the recorder definition.
        /// </summary>
        /// <param name="filter">A filter to be added.</param>
        public void AddFilter(SecurityEventFilter filter)
        {
            if (filter == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Filter);
            }

            this._filters.Add(filter);
        }

        /// <summary>
        /// Removes all configured filters.
        /// </summary>
        public void RemoveAllFilters()
        {
            _filters.Clear();
        }

        #endregion
    }
}
