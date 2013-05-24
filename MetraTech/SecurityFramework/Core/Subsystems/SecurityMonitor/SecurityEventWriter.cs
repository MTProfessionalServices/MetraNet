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
using System.Threading;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Provides an interface for writer that is used by <see cref="SecurityEvent"/>.
    /// </summary>
    public abstract class SecurityEventWriter
	{
		#region Private fields

		private object syncRoot = new object();

		#endregion

		#region Properties

		/// <summary>
		/// Gets a value indicating the writer supports recording info about recommended security policy actions.
		/// </summary>
		public abstract bool SupportsActionsRecording
		{
			get;
		}

		#endregion

		#region Public methods

		/// <summary>
        /// Accurate an exclusive lock. Starts writing of the event data.
        /// </summary>
        public virtual void BeginRecord()
        {
            Monitor.Enter(syncRoot);
        }

        /// <summary>
        /// Finishes writing of the event data. Releases an exclusive lock.
        /// </summary>
        public virtual void EndRecord()
        {
            Monitor.Exit(syncRoot);
        }

        /// <summary>
        /// Writes a string field value.
        /// </summary>
        /// <param name="fieldName">A field name.</param>
        /// <param name="value">A field value.</param>
        public abstract void Write(string fieldName, string value);

        /// <summary>
        /// Writes an integer field value.
        /// </summary>
        /// <param name="fieldName">A field name.</param>
        /// <param name="value">A field value.</param>
        public abstract void Write(string fieldName, int value);

		/// <summary>
		/// Writes a nullable integer value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public abstract void Write(string fieldName, int? value);

        /// <summary>
        /// Writes a boolean field value.
        /// </summary>
        /// <param name="fieldName">A field name.</param>
        /// <param name="value">A field value.</param>
        public abstract void Write(string fieldName, bool value);

        /// <summary>
        /// Writes a date/time field value.
        /// </summary>
        /// <param name="fieldName">A field name.</param>
        /// <param name="value">A field value.</param>
        public abstract void Write(string fieldName, DateTime value);

        /// <summary>
        /// Writes an event type field value.
        /// </summary>
        /// <param name="fieldName">A field name.</param>
        /// <param name="value">A field value.</param>
		public abstract void Write(string fieldName, SecurityEventType eventType);

		/// <summary>
		/// Writes a double field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public abstract void Write(string fieldName, double value);

		/// <summary>
		/// Begins action recording is suppurted.
		/// </summary>
		public abstract void BeginRecordAction();

		/// <summary>
		/// Ends action recording if supported.
		/// </summary>
		public abstract void EndRecordAction();

		#endregion
	}
}
