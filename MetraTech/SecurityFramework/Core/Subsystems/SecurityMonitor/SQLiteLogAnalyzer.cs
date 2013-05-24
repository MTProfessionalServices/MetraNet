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
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Analyses the data in the Security Monitor database.
    /// </summary>
    [Serializable]
    internal sealed class SQLiteLogAnalyzer : ILogAnalizerRepository
    {
        /// <summary>
        /// Gets or sets a connection string for the Security Monitor database.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string DatabaseFileName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets a SQLite database conenction string.
        /// </summary>
        private string ConnectionString
        {
            get
            {
                return SQLiteHelper.CreateConnectionString(DatabaseFileName);
            }
        }

        /// <summary>
        /// Determines a number of the events of the specified kind happened within the session with the specified ID.
        /// </summary>
        /// <param name="sessionId">An ID of the user's session to find events within.</param>
        /// <param name="subsystemName">An event's source subsystem name.</param>
        /// <param name="categoryName">An event's source category name.</param>
        /// <returns>A number of the events with the specified parameters.</returns>
        public int GetEventsNumberInSession(string sessionId, string subsystemName, string categoryName)
        {
            return SQLiteDataAccess.GetEventsNumberInSession(ConnectionString, sessionId, subsystemName, categoryName);
        }

        /// <summary>
        /// Determines a number of the event of the specified kind happened since the specified time.
        /// </summary>
        /// <param name="fromTime">
        /// A date and time to count event heppened since.
        /// Value must be passed in ISO-8601 format.
        /// </param>
        /// <param name="subsystemName">An event's source subsystem name.</param>
        /// <param name="categoryName">An event's source category name.</param>
        /// <returns>A number of the events with the specified parameters.</returns>
        public int GetEventsNumberInTimespan(DateTime fromTime, string subsystemName, string categoryName)
        {
            return SQLiteDataAccess.GetEventsNumberInTimespan(
                ConnectionString,
                fromTime.ToString(Constants.Formatting.ISO8601DateFormat),
                subsystemName,
                categoryName);
		}

		/// <summary>
		/// Determines a number of distinct IP client addresses within the session except the current one.
		/// </summary>
		/// <param name="sessionId">An ID of the user's session to find IP addresses within.</param>
		/// <param name="currentAddress">A current client address.</param>
		/// <returns>A number of IP addresses used in the specified session.</returns>
		public int GetSessionIPAddressesNumber(string sessionId, string currentAddress)
		{
			return SQLiteDataAccess.GetSessionIPAddressesNumber(ConnectionString, sessionId, currentAddress);
		}

		/// <summary>
		/// Retrives date/time of the event the action of the specific type was recommended for.
		/// </summary>
		/// <param name="actionTypeId">An action type to look for.</param>
		/// <returns>
		/// Last date/time of the event the action was recommended for.
		/// Returms DateTime.MinValue if such action was never recommended.
		/// </returns>
		public DateTime GetLastActionTimeStamp(int actionTypeId)
		{
			return SQLiteDataAccess.GetLastActionTimeStamp(ConnectionString, actionTypeId);
		}
    }
}
