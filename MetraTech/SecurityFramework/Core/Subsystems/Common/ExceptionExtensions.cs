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
using System.Diagnostics;
using MetraTech.SecurityFramework.Core.Common.Logging;
using MetraTech.SecurityFramework.Core.SecurityMonitor;


namespace MetraTech.SecurityFramework
{
    public static class ExceptionExtensions
    {
        private const int AutoreportCallStackLength = 3;

        public static void Report(this Exception x)
        {
            BadInputDataException sfx = x as BadInputDataException;

            try
            {
                if ((null != sfx) &&
                    !sfx.IsReported &&
                    SecurityKernel.IsSecurityMonitorEnabled &&
                    SecurityKernel.SecurityMonitor.IsRuntimeApiEnabled)
                {
                    ISecurityEvent evt = new SecurityEvent(sfx);

                    // Stack trace is not available at auto-reporting.
                    if (string.IsNullOrEmpty(evt.StackTrace))
                    {
                        StackTrace stack = new StackTrace(AutoreportCallStackLength);
                        evt.StackTrace = stack.ToString();
                    }

                    SecurityKernel.SecurityMonitor.Api.ReportEvent(evt);

                    sfx.IsReported = true;
                }
            }
            catch (Exception ex)
            {
                // Hide and log any exception here.
                LoggingHelper.Log(ex);
            }
        }
    }
}
