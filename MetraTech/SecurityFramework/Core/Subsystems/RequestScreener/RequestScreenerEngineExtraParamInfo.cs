using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework
{
	internal class RequestScreenerEngineExtraParamInfo
	{
		[SerializeProperty]
		public string Type
		{ 
			get;
			set; 
		}

		[SerializeProperty]
		public string Id 
		{ 
			get;
			set; 
		}

		[SerializeProperty]
		public string Data 
		{ 
			get;
			set; 
		}
	}
}
