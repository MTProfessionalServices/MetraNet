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
using System.Net;
using System.Text;

namespace MetraTech.SecurityFramework.Core.Common
{
    /// <summary>
    /// represents an interface for an context provider, specific for the execition environment.
    /// </summary>
    public interface IExecutionContext
    {
        /// <summary>
        /// Gets an application specific user session ID.
        /// </summary>
        string SessionId
        {
            get;
        }

        /// <summary>
        /// Gets a user's client IP address.
        /// </summary>
        IPAddress ClientAddress
        {
            get;
        }

        /// <summary>
        /// Gets a info on the user's client app.
        /// </summary>
        string ClientInfo
        {
            get;
        }

        /// <summary>
        /// Gets a called path within the app that causes an event.
        /// </summary>
        string Path
        {
            get;
        }

        /// <summary>
        /// Gets a name of the user who is currently logged in.
        /// </summary>
        string UserIdentity
        {
            get;
        }

        /// <summary>
        /// Gets the name of the server that hosts the app.
        /// </summary>
        string HostName
        {
            get;
        }

        /// <summary>
        /// Maps a relative path to the app.
        /// </summary>
        /// <param name="relativePath">A path to be resolved.</param>
        /// <returns>A physical path.</returns>
        string MapPath(string relativePath);
    }
}
