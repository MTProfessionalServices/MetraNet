/**************************************************************************
* Copyright 1997-2011 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: Viktor Grytsay
*
* <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace MetraTech.SecurityFramework
{
	public class WebInspectorRequestApiInput
	{
		public HttpApplication App
		{
			get;
			private set;
		}

		public HttpResponse Response
		{
			get;
			private set;
		}

		public HttpRequest Request
		{
			get;
			private set;
		}

		public HttpContext Context
		{
			get;
			private set;
		}

		public WebInspectorRequestApiInput(HttpApplication app, HttpContext context, HttpRequest request, HttpResponse response)
		{
			App = app;
			Response = response;
			Request = request;
			Context = context;
		}
	}
}
