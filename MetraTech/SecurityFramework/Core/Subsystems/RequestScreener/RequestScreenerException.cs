using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

namespace MetraTech.SecurityFramework
{
	public class RequestScreenerException : SecurityFrameworkException
	{
		public RequestScreenerException()
			: base()
		{ }

		public RequestScreenerException(string message)
			: base(message)
		{ }

		public RequestScreenerException(string message, Exception inner)
			: base(message, inner)
		{ }

		public RequestScreenerException(SerializationInfo info, StreamingContext context)
			: base(info, context)
		{ }
	}
}
