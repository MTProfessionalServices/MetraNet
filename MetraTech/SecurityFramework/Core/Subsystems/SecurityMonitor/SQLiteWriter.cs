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
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Core.SecurityMonitor.SQLite;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    ///  Provides a writer to record security events to a SQLite database.
    /// </summary>
    internal class SQLiteWriter : SecurityEventWriter
    {
        #region Private fields

        private string _connectionString;
		private bool _useAsynchronousRecording;
        private Dictionary<string, object> _record;
		private List<Dictionary<string, object>> _actions;
		private bool _actionRecording;

        #endregion

		#region Properties

		/// <summary>
		/// Gets a value indicating the writer supports recording info about recommended security policy actions.
		/// </summary>
		/// <remarks>always True</remarks>
		public override bool SupportsActionsRecording
		{
			get
			{
				return true;
			}
		}

		#endregion

		#region Constructor

		/// <summary>
        /// Creates an instance of the <see cref="SQLiteWriter"/> class.
        /// </summary>
        /// <param name="connectionString">A database connection string.</param>
        public SQLiteWriter(string connectionString, bool useAsynchronousRecording)
        {
            _connectionString = connectionString;
			_useAsynchronousRecording = useAsynchronousRecording;
        }

        #endregion

        #region Overriden methods

        /// <summary>
        /// Accurate an exclusive lock. Starts writing of the event data.
        /// </summary>
        public override void BeginRecord()
        {
            base.BeginRecord();

            _record = new Dictionary<string, object>();
			_actions = new List<Dictionary<string, object>>();
        }

        /// <summary>
        /// Finishes writing of the event data. Releases an exclusive lock.
        /// </summary>
        public override void EndRecord()
        {
			if (_actionRecording)
			{
				EndRecordAction();
			}

            try
            {
				SQLiteDataAccess.AddEvent(_connectionString, _record, _actions, _useAsynchronousRecording);
                _record = null;
				_actions = null;
            }
            finally
            {
                base.EndRecord();
            }
        }

		/// <summary>
		/// Writes a string field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, string value)
        {
            SetValue(fieldName, value);
        }

		/// <summary>
		/// Writes an integer field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, int value)
        {
            SetValue(fieldName, value);
        }

		/// <summary>
		/// Writes a nullable integer value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, int? value)
		{
			SetValue(fieldName, value);
		}

		/// <summary>
		/// Writes a boolean field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, bool value)
        {
            SetValue(fieldName, value);
        }

		/// <summary>
		/// Writes a date/time field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, DateTime value)
        {
            SetValue(fieldName, value.ToString(Constants.Formatting.ISO8601DateFormat));
        }

		/// <summary>
		/// Writes an event type field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, SecurityEventType value)
        {
            SetValue(fieldName, value.ToString(Constants.Formatting.EnumToStringFormat));
		}

		/// <summary>
		/// Writes a double field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, double value)
		{
			SetValue(fieldName, value);
		}

		/// <summary>
		/// Begins action recording.
		/// </summary>
		public override void BeginRecordAction()
		{
			_actions.Add(new Dictionary<string, object>());
			_actionRecording = true;
		}

		/// <summary>
		/// Ends action recording.
		/// </summary>
		public override void EndRecordAction()
		{
			_actionRecording = false;
		}

        #endregion

        #region Private methods

        private void SetValue(string fieldName, object value)
        {
            if (_record == null)
            {
                throw new InvalidOperationException("Writing record is not started. Call BeginRecord() method at first.");
            }

			if (!_actionRecording)
			{
				_record[fieldName] = value;
			}
			else
			{
				// Put the data into the last action record.
				_actions[_actions.Count - 1][fieldName] = value;
			}
        }

        #endregion
    }
}
