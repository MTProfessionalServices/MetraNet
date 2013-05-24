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
using System.Web;
using System.Threading;

namespace MetraTech.SecurityFramework.Core.Common.Web
{
    /// <summary>
    /// Represents a HTTP execution context provider.
    /// </summary>
    internal class HttpExecutionContext : IExecutionContext
    {
        private const string RemoteAddrHeader = "REMOTE_ADDR";

        /// <summary>
        /// Gets an application specific user session ID.
        /// </summary>
        /// <remarks>Returns null if there is no current HTTP context.</remarks>
        public string SessionId
        {
            get
            {
                string result;
                result = HttpContext.Current != null && HttpContext.Current.Session != null ? HttpContext.Current.Session.SessionID : null;

                return result;
            }
        }

        /// <summary>
        /// Gets a user's client IP address.
        /// </summary>
		/// <remarks>Returns null if there is no current HTTP context.</remarks>
        public IPAddress ClientAddress
        {
            get
            {
                string clietnIp;
                clietnIp = HttpContext.Current != null && HttpContext.Current.Request != null ? HttpContext.Current.Request.ServerVariables[RemoteAddrHeader] : null;

                return clietnIp != null ? IPAddress.Parse(clietnIp) : null;
            }
        }

        /// <summary>
        /// Gets a info on the user's client app.
        /// </summary>
		/// <remarks>Returns null if there is no current HTTP context.</remarks>
        public string ClientInfo
        {
            get
            {
                string result;
                result = HttpContext.Current != null && HttpContext.Current.Request != null ? HttpContext.Current.Request.UserAgent : null;

                return result;
            }
        }

        /// <summary>
        /// Gets a called path within the app that causes an event.
		/// </summary>
        public string Path
        {
            get
            {
                string result;
                result = HttpContext.Current != null && HttpContext.Current.Request != null ? HttpContext.Current.Request.Path : null;

                return result;
            }
        }

        /// <summary>
        /// Gets a name of the user who is currently logged in.
		/// </summary>
        public string UserIdentity
        {
            get
            {
                string result;
                result =
                    Thread.CurrentPrincipal != null &&
                    Thread.CurrentPrincipal.Identity != null &&
                    Thread.CurrentPrincipal.Identity.IsAuthenticated ? Thread.CurrentPrincipal.Identity.Name : null;

                return result;
            }
        }

        /// <summary>
        /// Gets the name of the server that hosts the app.
		/// </summary>
        public string HostName
        {
            get
            {
                // The current computer is a host.
                return Environment.MachineName;
            }
        }

        /// <summary>
        /// Maps a relative path to the app.
        /// Passes through absolute file pathes.
        /// </summary>
        /// <param name="relativePath">A path to be resolved.</param>
        /// <returns>A physical path.</returns>
        public string MapPath(string relativePath)
        {
            string result = null;
            try
            {
                // Allows to handle an absolute file path.
                if (System.IO.Path.IsPathRooted(relativePath))
                {
                    result = relativePath;
                }
            }
            catch (ArgumentException)
            {
                // Just hide an exception if the specified path is invalid.
            }

            if (result == null)
            {
                result = HttpContext.Current != null && HttpContext.Current.Server != null ? HttpContext.Current.Server.MapPath(relativePath) : relativePath;
            }

            return result;
        }
    }
}
