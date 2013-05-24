using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

namespace MetraTech.SecurityFramework
{
	public class RequestScreenerInputDataException : RequestScreenerException
	{
				public RequestScreenerInputDataException()
			: base()
		{ }

		public RequestScreenerInputDataException(string message)
			: base(message)
		{ }

		public RequestScreenerInputDataException(string message, Exception inner)
			: base(message, inner)
		{ }

		public RequestScreenerInputDataException(SerializationInfo info, StreamingContext context)
			: base(info, context)
		{ }
	}
}
