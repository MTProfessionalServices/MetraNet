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
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.SecurityMonitor;

namespace MetraTech.SecurityFramework
{
    public interface ISecurityMonitor
    {
        ISecurityMonitorApi Api
        {
            get;
        }

        ISecurityMonitorControlApi ControlApi
        {
            get;
        }

        /// <summary>
        /// Gets a value indicating that the Security Monitor API is enabled.
        /// </summary>
        bool IsRuntimeApiEnabled
        {
            get;
        }

        /// <summary>
        /// Gets a value indicating that the Security Monitor control API is enabled.
        /// </summary>
        bool IsControlApiEnabled
        {
            get;
        }

        /// <summary>
        /// Gets or internally sets a value indication if Input Data should be recorder together with other information.
        /// </summary>
        bool RecordInputData
        {
            get;
        }

        /// <summary>
        /// Gets or internally sets a value indication if security event Reason should be recorder together with other information.
        /// </summary>
        bool RecordEventReason
        {
            get;
        }
    }
}
