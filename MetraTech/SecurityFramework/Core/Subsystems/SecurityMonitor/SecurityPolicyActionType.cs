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
    /// Enlists possible security action types.
    /// </summary>
    [Flags]
    public enum SecurityPolicyActionType
    {
        None = 0,
        BlockOperation = 1,
        BlockUser = 2,
        BlockAddress = 4,
        Log = 8,
        RedirectOperation = 16,
        RedirectUser = 32,
        LogoutUser = 64,
        SendSecurityWarningToUser = 128,
        SendAdminNotification = 256,
        ChangeSessionParameter = 512
    }
}
