using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework
{
	public class RequestScreenerApiInput
	{
		public int RequestBodySize { get; private set; }

		public int ParametersCount { get; private set; }

		public NameValueCollection Parameters { get; private set; }

		public RequestScreenerApiInput(int requestBodySize, int parametersCount, NameValueCollection parameters)
		{
			RequestBodySize = requestBodySize;
			ParametersCount = parametersCount;
			Parameters = parameters;
		}
	}
}
