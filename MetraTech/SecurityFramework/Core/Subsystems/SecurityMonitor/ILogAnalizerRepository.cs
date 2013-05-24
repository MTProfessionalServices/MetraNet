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

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Represents an interface that determines methods to read and analyze recorded security events.
    /// It is used by policy rules and can be used by a prospective monitoring tool with UI.
    /// An implementation is used for analyses must be coupled with one of the configured event recorders.
    /// </summary>
    public interface ILogAnalizerRepository
    {
        /// <summary>
        /// Determines a number of the events of the specified kind happened within the session with the specified ID.
        /// </summary>
        /// <param name="sessionId">An ID of the user's session to find events within.</param>
        /// <param name="subsystemName">An event's source subsystem name.</param>
        /// <param name="categoryName">An event's source category name.</param>
        /// <returns>A number of the events with the specified parameters.</returns>
        int GetEventsNumberInSession(string sessionId, string subsystemName, string categoryName);

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
        int GetEventsNumberInTimespan(DateTime fromTime, string subsystemName, string categoryName);

		/// <summary>
		/// Determines a number of distinct IP client addresses within the session except the current one.
		/// </summary>
		/// <param name="sessionId">An ID of the user's session to find IP addresses within.</param>
		/// <param name="currentAddress">A current client address.</param>
		/// <returns>A number of IP addresses used in the specified session.</returns>
		int GetSessionIPAddressesNumber(string sessionId, string currentAddress);

		/// <summary>
		/// Retrives date/time of the event the action of the specific type was recommended for.
		/// </summary>
		/// <param name="actionTypeId">An action type to look for.</param>
		/// <returns>
		/// Last date/time of the event the action was recommended for.
		/// Returms DateTime.MinValue if such action was never recommended.
		/// </returns>
		DateTime GetLastActionTimeStamp(int actionTypeId);
    }
}
