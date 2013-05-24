using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework.Serialization
{
	internal class SerializationException : System.Exception, ISerializationError
	{
		public Type Type
		{
			get;
			set;
		}

		public object Value
		{
			get;
			set;
		}

		public SortedList<string, string> PropertyCollectoin
		{
			get;
			set;
		}

		public Dictionary<string, object> ErrorPropertyCollectoin
		{
			get;
			set;
		}

		public SerializationException()
			: base()
		{
			this.PropertyCollectoin = new SortedList<string, string>();
			this.ErrorPropertyCollectoin = new Dictionary<string, object>();

		}

		public SerializationException(string message)
			: base(message)
		{
			this.PropertyCollectoin = new SortedList<string, string>();
			this.ErrorPropertyCollectoin = new Dictionary<string, object>();
		}

		public SerializationException(string message, Exception inner)
			: base(message, inner)
		{
			this.PropertyCollectoin = new SortedList<string, string>();
			this.ErrorPropertyCollectoin = new Dictionary<string, object>();
		}
	}
}
