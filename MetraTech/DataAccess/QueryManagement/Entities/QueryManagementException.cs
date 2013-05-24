//=============================================================================
// Copyright 2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
//
// MODULE: QueryDirectoryFinder.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Runtime.Serialization;
    using System.Runtime.InteropServices;

    /// <summary>
    /// Class indicating a QueryManagement exception has occurred.
    /// </summary>
    [Serializable]
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("57E5DB5F-230D-494A-8C38-79FF615AAA4B")]
    public class QueryManagementException : Exception
    {
        /// <summary>
        /// Initializes a new instance of the QueryManagementException class.
        /// </summary>
        public QueryManagementException()
        {
        }

        /// <summary>
        /// Initializes a new instance of the QueryManagementException class.
        /// </summary>
        public QueryManagementException(string message) : base(message)
        {
        }

        /// <summary>
        /// Initializes a new instance of the QueryManagementException class.
        /// </summary>
        /// <param name="message">The message to initialize this instance of the QueryManagementException class from.</param>
        /// <param name="innerException">The inner exception to initialize this instance of the QueryManagementException class from.</param>
        public QueryManagementException(string message, Exception innerException) : base(message, innerException)
        {
        }

        /// <summary>
        /// Microsoft design...
        /// </summary>
        /// <param name="info">The serialization info object</param>
        /// <param name="context">The streaming context object</param>
        protected QueryManagementException(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
        }

        /// <summary>
        /// Microsoft design...
        /// </summary>
        /// <param name="info">The serialization info object</param>
        /// <param name="context">The streaming context object</param>
        public virtual new void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            base.GetObjectData(info, context);
        }
    }
}