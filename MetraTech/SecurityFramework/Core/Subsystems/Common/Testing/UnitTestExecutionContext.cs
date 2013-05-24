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
using System.Net;
using System.Diagnostics;
using System.Reflection;
using System.Threading;
using System.Security.Principal;

namespace MetraTech.SecurityFramework.Core.Common.Testing
{
    /// <summary>
    /// Represents an execution context provider for unit testing.
    /// </summary>
    public class UnitTestExecutionContext : IExecutionContext
    {
		private static IPAddress _defaultAddress = IPAddress.Loopback;

        /// <summary>
        /// Gets an application specific user session ID.
        /// </summary>
        public string SessionId
        {
            get
            {
                return string.Concat(
                    Process.GetCurrentProcess().StartTime.ToString(),
                    "_",
                    Thread.CurrentThread.ManagedThreadId.ToString());
            }
        }

        /// <summary>
        /// Gets a user's client IP address.
        /// </summary>
        public IPAddress ClientAddress
        {
            get
            {
				return _defaultAddress;
            }
			set
			{
				_defaultAddress = value;
			}
        }

        /// <summary>
        /// Gets a info on the user's client app.
        /// </summary>
        public string ClientInfo
        {
            get
            {
                return Process.GetCurrentProcess().ProcessName;
            }
        }

        /// <summary>
        /// Gets a called path within the app that causes an event.
        /// </summary>
        public string Path
        {
            get
            {
                // Skip stack trace untill the direct caller.
                StackFrame[] stack = new StackTrace(1).GetFrames();

                // Look for the test method.
                foreach (StackFrame frame in stack)
                {
                    MethodBase method = frame.GetMethod();
                    object[] attrs = method.GetCustomAttributes(
                        Type.GetType("Microsoft.VisualStudio.TestTools.UnitTesting.TestMethodAttribute, Microsoft.VisualStudio.QualityTools.UnitTestFramework"),
                        false);

                    if (attrs != null && attrs.Length > 0)
                    {
                        return method.Name;
                    }
                }

                return string.Empty;
            }
        }

        /// <summary>
        /// Gets a name of the user who is currently logged in.
        /// </summary>
        public string UserIdentity
        {
            get
            {
                IPrincipal principal = Thread.CurrentPrincipal;

                return principal != null && principal.Identity != null ? principal.Identity.Name : null;
            }
        }

        /// <summary>
        /// Gets the name of the server that hosts the app.
        /// </summary>
        public string HostName
        {
            get
            {
                return Process.GetCurrentProcess().MachineName;
            }
        }

        /// <summary>
        /// Maps a relative path to the app.
        /// </summary>
        /// <param name="relativePath">A path to be resolved.</param>
        /// <returns>A physical path.</returns>
        public string MapPath(string relativePath)
        {
            string result = System.IO.Path.GetFullPath(relativePath);

            return result;
        }
    }
}
