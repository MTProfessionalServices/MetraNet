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
using System.Text;
using System.Collections.Specialized;
using System.Web;

namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinFilterContext
    {
        public string rawUrl = string.Empty;
        public string normalUrl = string.Empty;
        public string paramName = string.Empty;
        public string paramValue = string.Empty;
        public string stopSubsystem = string.Empty;
        public string stopEngineId = string.Empty;
        public string stopRuleId = string.Empty;
        
        public NameValueCollection queryStringParams = null;
        public NameValueCollection formParams = null;
        public HttpCookieCollection cookies = null;
        public NameValueCollection headers = null;
        public int requestBodySize = 0;

        public int paramCount = 0;
        public string[] paramNames = null;
        public string remoteAddr = string.Empty;
        public string userAgent = string.Empty;
        public string referer = string.Empty;
    }
}
