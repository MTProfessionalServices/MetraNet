using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace MetraTech.SecurityFramework
{
	public class WebInspectorResponseApiInput
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

		public WebInspectorResponseApiInput(HttpApplication app, HttpRequest request, HttpResponse response)
		{
			App = app;
			Response = response;
			Request = request;
		}
	}
}
