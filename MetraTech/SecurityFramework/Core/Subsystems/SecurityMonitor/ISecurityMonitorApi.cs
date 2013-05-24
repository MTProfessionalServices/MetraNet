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
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.SecurityMonitor;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Represents an interface for the Security Monitor API.
    /// </summary>
    public interface ISecurityMonitorApi
    {
        /// <summary>
        /// Sets event type to WebRequestEventType and processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportWebRequestEvent(ISecurityEvent evt);

        /// <summary>
        /// Sets event type to AuthenticationEventType and processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportAuthenticationEvent(ISecurityEvent evt);

        /// <summary>
        /// Sets event type to AccessControlEventType and processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportAccessControlEvent(ISecurityEvent evt);

        /// <summary>
        /// Sets event type to SessionEventType and processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportSessionEvent(ISecurityEvent evt);

        /// <summary>
        /// Sets event type to InputDataProcessingEventType and processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportInputDataProcessingEvent(ISecurityEvent evt);

        /// <summary>
        /// Sets event type to OutputDataProcessingEventType and processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportOutputDataProcessingEvent(ISecurityEvent evt);

        /// <summary>
        /// Sets event type to FileIoEventType and processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportFileIoEvent(ISecurityEvent evt);

        /// <summary>
        /// Processes an event and records it to the storage.
        /// </summary>
        /// <param name="evt">An event data to be processed.</param>
        void ReportEvent(ISecurityEvent evt);

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
        void AddPolicyActionHandler(string idHandler, SecurityPolicyActionType actionType, ISecurityPolicyActionHandler handler);
        
        /// <summary>
        /// Removes an action handler with a specified ID.
        /// </summary>
        /// <param name="idHandler">An ID of the handler to be removed.</param>
        /// <exception cref="SubsystemInputParamException">If there is no handler with such ID found.</exception>
        /// <remarks>The method is thread safe.</remarks>
        void RemovePolicyActionHandler(string idHandler);

        /// <summary>
        /// Gets an event recorder with a specified ID.
        /// </summary>
        /// <param name="idRecorder">An ID of the recorder to be retrieved.</param>
        /// <returns>A recorder definition.</returns>
        /// <exception cref="SubsystemInputParamException">If a recorder with the specified ID not found.</exception>
        EventRecorderDefinition GetRecorder(string idRecorder);

		/// <summary>
		/// Processes a successful user login security event.
		/// </summary>
		/// <remarks>Must be called after the user authentication.</remarks>
		void ReportLogin();

		/// <summary>
		/// Processes an explicit user logout security event.
		/// </summary>
		/// <remarks>Must be called before user is logged out.</remarks>
		void ReportLogout();

		/// <summary>
		/// Processes a feature usage security events.
		/// </summary>
		/// <param name="featurePath">A path to the feature that was used.</param>
		void ReportFeatureUsage(string featurePath);

		/// <summary>
		/// Processes a transaction usage security event.
		/// </summary>
		/// <param name="featurePath">A path to the feature that invoked a transaction.</param>
		void ReportTransactionUsage(string featurePath);

		/// <summary>
		/// Processes an irregular feature usage security event.
		/// </summary>
		/// <param name="featurePath">A path to the feature the was used in unexpected way.</param>
		void ReportIrregularUsage(string featurePath);

		/// <summary>
		/// Processes a file upload security event.
		/// </summary>
		/// <param name="fileSize">A size of the uploaded file.</param>
		void ReportFileUpload(ulong fileSize);
    }
}
