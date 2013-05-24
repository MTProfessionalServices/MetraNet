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
using System.Net;
using System.Text;
using MetraTech.SecurityFramework.Core.SecurityMonitor;

namespace MetraTech.SecurityFramework
{
    public enum SecurityEventType
    {
        Unknown,
        WebRequestEventType,
        WebResponseEventType,
        AuthenticationEventType,
        AccessControlEventType,
        SessionEventType, 
        InputDataProcessingEventType,
        OutputDataProcessingEventType,
        FileIoEventType,
        UserActivityTrendEventType,
        AppActivityTrendEventType
    }

    /// <summary>
    /// Represents an interface for the security event definition.
    /// </summary>
    public interface ISecurityEvent
    {
        #region Properties

        /// <summary>
        /// Gets or sets an event type.
        /// </summary>
        SecurityEventType EventType
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a source subsystem's name.
        /// </summary>
        string SubsystemName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a source subsystem's category name.
        /// </summary>
        string CategoryName
        {
            get;
            set;
        }

		/// <summary>
		/// Gets or sets an ID of the problem.
		/// </summary>
		int? ProblemId
		{
			get;
			set;
		}

        /// <summary>
        /// Gets or sets a input data whith processed by an engine.
        /// </summary>
        string InputData
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a reason of the current exception. 
        /// </summary>
        /// <remarks>It maybe a pattern expression whith detected a XSS attack.</remarks>
        string Reason
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a time stamp when the event happened.
        /// </summary>
        DateTime TimeStamp
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a called path within the app that causes an event.
        /// </summary>
        string Path
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a name of the server that hosts the app.
        /// </summary>
        string HostName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a text description to the event.
        /// </summary>
        string Message
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a user's client IP address.
        /// </summary>
        IPAddress ClientAddress
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a name of the user who caused the event.
        /// </summary>
        string UserIdentity
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an app specific user's session ID.
        /// </summary>
        string SessionId
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an info on the user's client.
        /// </summary>
        string ClientInfo
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a stack trace to the code that cased the event.
        /// </summary>
        string StackTrace
        {
            get;
            set;
        }

		/// <summary>
		/// Gets or sets an input data size.
		/// </summary>
		/// <remarks>Uses for large data that we don't want to record completely.</remarks>
		ulong InputDataSize
		{
			get;
			set;
		}

        #endregion

        #region Methods

        /// <summary>
        /// Writes the event data using the specified recorder.
        /// </summary>
        /// <param name="writer">A recorder to be used.</param>
        void Record(SecurityEventWriter writer);

        #endregion
    }
}
