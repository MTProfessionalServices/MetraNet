using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Serialization;

namespace MetraTech.SecurityFramework.Common.Configuration
{
    /// <summary>
    /// This class describes the serialization error
    /// </summary>
    public sealed class SerializationException : SecurityFrameworkException, ISerializationError
	{
		/// <summary>
		/// Gets or sets type of deserialized object
		/// </summary>
		public Type Type
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets deserialized object
		/// </summary>
		public object Value
		{
			get;
			set;
		}
		
		/// <summary>
		/// Gets or sets collection properties of deserialize object
		/// </summary>
		public SortedList<string, string> PropertyCollectoin
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets collection properties of deserialize object with deserialize error
		/// </summary>
		public Dictionary<string, object> ErrorPropertyCollectoin
		{
			get;
			set;
		}

        public SerializationException() : base() 
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
