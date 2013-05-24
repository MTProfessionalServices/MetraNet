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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Core.Common.Logging;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
	/// <summary>
	/// Provides functionality for security event processing.
	/// </summary>
	internal sealed class SecurityMonitorApi : ISecurityMonitorApi
	{
		#region Inner types

		/// <summary>
		/// Links an Action Type and Policy Action Handler together.
		/// </summary>
		internal class PolicyActionHandlerEntry
		{
			internal SecurityPolicyActionType ActionType
			{
				get;
				private set;
			}

			internal ISecurityPolicyActionHandler Handler
			{
				get;
				private set;
			}

			internal PolicyActionHandlerEntry(SecurityPolicyActionType actionType, ISecurityPolicyActionHandler handler)
			{
				this.ActionType = actionType;
				this.Handler = handler;
			}
		}

		#endregion

		#region Constants

		private const string StatisticsVirtualSubsystem = "Statistics";

		#endregion

		#region Private fields

		private object _syncRoot = new object();
		private bool _isInitialized;
		private SecurityPolicyEngine _policyEngine;
		private Dictionary<string, EventRecorderDefinition> _recorders =
			new Dictionary<string, EventRecorderDefinition>();
		private Dictionary<string, PolicyActionHandlerEntry> _handlers =
			new Dictionary<string, PolicyActionHandlerEntry>();

		#endregion

		#region Public methods

		/// <summary>
		/// Initializes a subsystem.
		/// </summary>
		/// <param name="properties"></param>
		public void Initialize(SecurityMonitorProperties properties)
		{
			if (properties == null)
			{
				throw new ArgumentNullException(Constants.Arguments.Properties);
			}

			if (properties.Recorders == null || properties.Recorders.Length == 0)
			{
				throw new SubsystemInputParamException("No recorders specified for the Security Monitor.");
			}

			if (properties.Policies == null || properties.Policies.Length == 0)
			{
				throw new SubsystemInputParamException("No security policies specified for the Security Monitor.");
			}

			// Initialize the event log analyzer.
			LogAnalizerFactory.Analyzer = properties.LogAnalyzer;

			// Initialize the policy engine.
			_policyEngine = new SecurityPolicyEngine(properties.Policies);

			// Initialize recorders.
			_recorders.Clear();
			foreach (EventRecorderDefinitionProperties definition in properties.Recorders)
			{
				if (_recorders.ContainsKey(definition.Id))
				{
					throw new SubsystemInputParamException(
						string.Format("Duplicated recorder ID \"{0}\"", definition.Id));
				}

				EventRecorderDefinition recorder = new EventRecorderDefinition();
				recorder.Initialize(definition);

				_recorders.Add(recorder.Id, recorder);
			}

			_isInitialized = true;
		}

		/// <summary>
		/// Sets event type to WebRequestEventType and processes an event and records it to the storage.
		/// </summary>
		/// <param name="evt">An event data to be processed.</param>
		public void ReportWebRequestEvent(ISecurityEvent evt)
		{
			evt.EventType = SecurityEventType.WebRequestEventType;
			ReportEvent(evt);
		}

		/// <summary>
		/// Sets event type to AuthenticationEventType and processes an event and records it to the storage.
		/// </summary>
		/// <param name="evt">An event data to be processed.</param>
		public void ReportAuthenticationEvent(ISecurityEvent evt)
		{
			evt.EventType = SecurityEventType.AuthenticationEventType;
			ReportEvent(evt);
		}

		/// <summary>
		/// Sets event type to AccessControlEventType and processes an event and records it to the storage.
		/// </summary>
		/// <param name="evt">An event data to be processed.</param>
		public void ReportAccessControlEvent(ISecurityEvent evt)
		{
			evt.EventType = SecurityEventType.AccessControlEventType;
			ReportEvent(evt);
		}

		/// <summary>
		/// Sets event type to SessionEventType and processes an event and records it to the storage.
		/// </summary>
		/// <param name="evt">An event data to be processed.</param>
		public void ReportSessionEvent(ISecurityEvent evt)
		{
			evt.EventType = SecurityEventType.SessionEventType;
			ReportEvent(evt);
		}

		/// <summary>
		/// Sets event type to InputDataProcessingEventType and processes an event and records it to the storage.
		/// </summary>
		/// <param name="evt">An event data to be processed.</param>
		public void ReportInputDataProcessingEvent(ISecurityEvent evt)
		{
			evt.EventType = SecurityEventType.InputDataProcessingEventType;
			ReportEvent(evt);
		}

		/// <summary>
		/// Sets event type to OutputDataProcessingEventType and processes an event and records it to the storage.
		/// </summary>
		/// <param name="evt">An event data to be processed.</param>
		public void ReportOutputDataProcessingEvent(ISecurityEvent evt)
		{
			evt.EventType = SecurityEventType.OutputDataProcessingEventType;
			ReportEvent(evt);
		}

		/// <summary>
		/// Sets event type to FileIoEventType and processes an event and records it to the storage.
		/// </summary>
		/// <param name="evt">An event data to be processed.</param>
		public void ReportFileIoEvent(ISecurityEvent evt)
		{
			evt.EventType = SecurityEventType.FileIoEventType;
			ReportEvent(evt);
		}

		/// <summary>
		/// Processes an event and records it to the storage.
		/// </summary>
		/// <param name="securityEvent">An event data to be processed.</param>
		public void ReportEvent(ISecurityEvent securityEvent)
		{
			if (securityEvent == null)
			{
				throw new ArgumentNullException(Constants.Arguments.SecurityEvent);
			}

			if (!_isInitialized)
			{
				throw new InvalidOperationException("Security Monitor is not initialized yet. Call Initialize method before.");
			}

			Stopwatch monitorWatch = new Stopwatch();
			monitorWatch.Start();

			try
			{
				List<PolicyAction> actions = new List<PolicyAction>();
				try
				{
					// Evaluate security policies and handle any of the matched.
					if (_policyEngine.ProcessEvent(securityEvent, actions))
					{
						monitorWatch.Stop();

						try
						{
							ExecutePolicyActions(securityEvent, actions);
						}
						finally
						{
							monitorWatch.Start();
						}
					}
				}
				catch (Exception ex)
				{
					// Log an exception and record an event regardless any possible exception during processing of it.
					LoggingHelper.Log(ex);
				}

				foreach (EventRecorderDefinition recorders in _recorders.Values)
				{
					try
					{
						recorders.Record(securityEvent, actions);
					}
					catch (Exception ex)
					{
						// Log an exception and hide it.
						LoggingHelper.Log(ex);
					}
				}
			}
			finally
			{
				// Measure performance.
				monitorWatch.Stop();
				PerformanceMonitor.IncrementMonitorTime(monitorWatch.ElapsedTicks);
			}
		}

		/// <summary>
		/// Adds an action handler for a specific action type(s).
		/// </summary>
		/// <param name="idHandler">An ID of the handler.</param>
		/// <param name="actionType">Action type(s) to add the handler for.</param>
		/// <param name="handler">The action handler.</param>
		/// <exception cref="ArgumentNullException">If <paramref name="idHandler"/> is null or empty string.</exception>
		/// <exception cref="ArgumentNullException">If <paramref name="handler"/> is null.</exception>
		/// <exception cref="SubsystemInputParamException">A handler with the same ID is already registered.</exception>
		/// <remarks>The method is thread safe.</remarks>
		public void AddPolicyActionHandler(
			string idHandler,
			SecurityPolicyActionType actionType,
			ISecurityPolicyActionHandler handler)
		{
			if (string.IsNullOrEmpty(idHandler))
			{
				throw new ArgumentNullException(Constants.Arguments.HandlerId);
			}

			if (handler == null)
			{
				throw new ArgumentNullException(Constants.Arguments.Handler);
			}

			lock (_syncRoot)
			{
				if (_handlers.ContainsKey(idHandler))
				{
					throw new SubsystemInputParamException(
						string.Format("Handler with ID \"{0}\" already exists.", idHandler));
				}

				_handlers.Add(idHandler, new PolicyActionHandlerEntry(actionType, handler));
			}
		}

		/// <summary>
		/// Removes an action handler with a specified ID.
		/// </summary>
		/// <param name="idHandler">An ID of the handler to be removed.</param>
		/// <exception cref="SubsystemInputParamException">If there is no handler with such ID found.</exception>
		/// <remarks>The method is thread safe.</remarks>
		public void RemovePolicyActionHandler(string idHandler)
		{
			lock (_syncRoot)
			{
				if (!_handlers.ContainsKey(idHandler))
				{
					throw new SubsystemInputParamException(
						string.Format("Handler with ID \"{0}\" not found.", idHandler));
				}

				_handlers.Remove(idHandler);
			}
		}

		/// <summary>
		/// Gets an event recorder with a specified ID.
		/// </summary>
		/// <param name="idRecorder">An ID of the recorder to be retrieved.</param>
		/// <returns>A recorder definition.</returns>
		/// <exception cref="SubsystemInputParamException">If a recorder with the specified ID not found.</exception>
		public EventRecorderDefinition GetRecorder(string idRecorder)
		{
			if (!_recorders.ContainsKey(idRecorder))
			{
				throw new SubsystemInputParamException(string.Format("Recorder with ID \"{0}\" not found.", idRecorder));
			}

			return _recorders[idRecorder];
		}

		/// <summary>
		/// Processes a successful user login security event.
		/// </summary>
		/// <remarks>Must be called after the user authentication.</remarks>
		public void ReportLogin()
		{
			ReportEvent(
				new SecurityEvent()
				{
					EventType = SecurityEventType.AppActivityTrendEventType,
					SubsystemName = StatisticsVirtualSubsystem,
					CategoryName = StatisticsCategory.UserLogin.ToString()
				});
		}

		/// <summary>
		/// Processes an explicit user logout security event.
		/// </summary>
		/// <remarks>Must be called before user is logged out.</remarks>
		public void ReportLogout()
		{
			ReportEvent(
				new SecurityEvent()
				{
					EventType = SecurityEventType.AppActivityTrendEventType,
					SubsystemName = StatisticsVirtualSubsystem,
					CategoryName = StatisticsCategory.UserLogout.ToString()
				});
		}

		/// <summary>
		/// Processes a feature usage security events.
		/// </summary>
		/// <param name="featurePath">A path to the feature that was used.</param>
		public void ReportFeatureUsage(string featurePath)
		{
			ReportEvent(
				new SecurityEvent()
				{
					EventType = SecurityEventType.UserActivityTrendEventType,
					SubsystemName = StatisticsVirtualSubsystem,
					CategoryName = StatisticsCategory.FeatureUsage.ToString(),
					Path = featurePath
				});
		}

		/// <summary>
		/// Processes a transaction usage security event.
		/// </summary>
		/// <param name="featurePath">A path to the feature that invoked a transaction.</param>
		public void ReportTransactionUsage(string featurePath)
		{
			ReportEvent(
				new SecurityEvent()
				{
					EventType = SecurityEventType.AppActivityTrendEventType,
					SubsystemName = StatisticsVirtualSubsystem,
					CategoryName = StatisticsCategory.TransactionUsage.ToString(),
					Path = featurePath
				});
		}

		/// <summary>
		/// Processes an irregular feature usage security event.
		/// </summary>
		/// <param name="featurePath">A path to the feature the was used in unexpected way.</param>
		public void ReportIrregularUsage(string featurePath)
		{
			ReportEvent(
				new SecurityEvent()
				{
					EventType = SecurityEventType.UserActivityTrendEventType,
					SubsystemName = StatisticsVirtualSubsystem,
					CategoryName = StatisticsCategory.IrregularUsage.ToString(),
					Path = featurePath
				});
		}

		/// <summary>
		/// Processes a file upload security event.
		/// </summary>
		/// <param name="fileSize">A size of the uploaded file.</param>
		public void ReportFileUpload(ulong fileSize)
		{
			ReportEvent(
				new SecurityEvent()
				{
					EventType = SecurityEventType.FileIoEventType,
					SubsystemName = StatisticsVirtualSubsystem,
					CategoryName = StatisticsCategory.FileUpload.ToString(),
					InputDataSize = fileSize
				});
		}

		#endregion

		#region Private methods

		private void ExecutePolicyActions(ISecurityEvent securityEvent, List<PolicyAction> actions)
		{
			Stopwatch handlersWatch = new Stopwatch();
			handlersWatch.Start();

			try
			{
				foreach (PolicyAction action in actions)
				{
					foreach (PolicyActionHandlerEntry entry in _handlers.Values)
					{
						if (entry.ActionType.HasFlag(action.ActionType))
						{
							entry.Handler.Handle(action, securityEvent);
						}
					}
				}
			}
			finally
			{
				// Measure performance
				handlersWatch.Stop();
				PerformanceMonitor.IncrementHandlersTime(handlersWatch.ElapsedTicks);
			}
		}

		#endregion
	}
}
