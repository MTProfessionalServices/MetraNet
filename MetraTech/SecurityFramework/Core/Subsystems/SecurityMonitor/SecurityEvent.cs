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
using System.Net;
using System.Text;
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Holds the security event data.
    /// </summary>
    [Serializable]
    public class SecurityEvent : ISecurityEvent
    {
        #region Properties

        /// <summary>
        /// Gets or sets an event type.
        /// </summary>
        public SecurityEventType EventType
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a source subsystem's name.
        /// </summary>
        public string SubsystemName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a source subsystem's category name.
        /// </summary>
        public string CategoryName
        {
            get;
            set;
        }

		/// <summary>
		/// Gets or sets an ID of the problem.
		/// </summary>
		public int? ProblemId
		{
			get;
			set;
		}

        /// <summary>
        /// Gets or sets a input data whith processed by an engine.
        /// </summary>
        public string InputData
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a reason of the current exception. 
        /// </summary>
        /// <remarks>It maybe a pattern expression whith detected a XSS attack.</remarks>
        public string Reason
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a time stamp when the event happened.
        /// </summary>
        public DateTime TimeStamp
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a called path within the app that causes an event.
        /// </summary>
        public string Path
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a name of the server that hosts the app.
        /// </summary>
        public string HostName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a text description to the event.
        /// </summary>
        public string Message
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a user's client IP address.
        /// </summary>
        public IPAddress ClientAddress
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a name of the user who caused the event.
        /// </summary>
        public string UserIdentity
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an app specific user's session ID.
        /// </summary>
        public string SessionId
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an info on the user's client.
        /// </summary>
        public string ClientInfo
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a stack trace to the code that cased the event.
        /// </summary>
        public string StackTrace
        {
            get;
            set;
        }

		/// <summary>
		/// Gets or sets an input data size.
		/// </summary>
		/// <remarks>Uses for large data that we don't want to record completely.</remarks>
		public ulong InputDataSize
		{
			get;
			set;
		}

        #endregion

        #region Constructors

        /// <summary>
        /// Creates an instance of the <see cref="SecurityEvent"/> class.
        /// </summary>
        public SecurityEvent()
        {
            IExecutionContext context = ExecutionContextFactory.Context;

            this.TimeStamp = DateTime.Now;
            this.SessionId = context.SessionId;
            this.ClientAddress = context.ClientAddress;
            this.Path = context.Path;
            this.ClientInfo = context.ClientInfo;
            this.UserIdentity = context.UserIdentity;
            this.HostName = context.HostName;
        }

        /// <summary>
        /// Creates an instance of the <see cref="SecurityEvent"/> class taking the data from a <paramref name="ex"/> argument.
        /// </summary>
        /// <param name="ex">An exception definining a security problem.</param>
        public SecurityEvent(BadInputDataException ex)
            : this()
        {
            this.Message = ex.Message;
            this.EventType = ex.EventType;
            this.SubsystemName = ex.SubsystemName;
            this.CategoryName = ex.CategoryName;
			this.ProblemId = ex.Id;
            this.StackTrace = ex.StackTrace;
            this.InputData = ex.InputData;
            this.Reason = ex.Reason;
			this.InputDataSize = ex.InputDataSize == 0 && ex.InputData != null ? (uint)ex.InputData.Length : (uint)ex.InputDataSize;
        }

        #endregion

        #region Public methods
        
        /// <summary>
        /// Writes the event data using the specified recorder.
        /// </summary>
        /// <param name="writer">A recorder to be used.</param>
        public void Record(SecurityEventWriter writer)
        {
            if (writer == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Writer);
            }

                writer.Write(Constants.Properties.EventType, EventType);
                writer.Write(Constants.Properties.SubsystemName, SubsystemName);
                writer.Write(Constants.Properties.CategoryName, CategoryName);
				writer.Write(Constants.Properties.ProblemId, ProblemId);
                writer.Write(Constants.Properties.TimeStamp, TimeStamp);
                writer.Write(Constants.Properties.Path, Path);
                writer.Write(Constants.Properties.HostName, HostName);
                writer.Write(Constants.Properties.Message, Message);
                writer.Write(Constants.Properties.ClientAddress, ClientAddress != null ? ClientAddress.ToString() : null);
                writer.Write(Constants.Properties.UserIdentity, UserIdentity);
                writer.Write(Constants.Properties.SessionId, SessionId);
                writer.Write(Constants.Properties.ClientInfo, ClientInfo);
                writer.Write(Constants.Properties.StackTrace, StackTrace);
				writer.Write(Constants.Properties.InputDataSize, InputDataSize);

                if (SecurityKernel.IsSecurityMonitorEnabled && SecurityKernel.SecurityMonitor.RecordInputData)
                {
                    writer.Write(Constants.Properties.InputData, InputData);
                }

                if (SecurityKernel.IsSecurityMonitorEnabled && SecurityKernel.SecurityMonitor.RecordEventReason)
                {
                    writer.Write(Constants.Properties.Reason, Reason);
                }
        }

        #endregion
    }
}
