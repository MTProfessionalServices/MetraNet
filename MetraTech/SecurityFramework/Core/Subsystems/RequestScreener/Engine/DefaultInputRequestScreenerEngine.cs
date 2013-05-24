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
* Viktor Grytsay <vgrytsay@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Data.Schema.ScriptDom.Sql;
using System.IO;
using Microsoft.Data.Schema.ScriptDom;
using MetraTech.SecurityFramework.Serialization.Attributes;


namespace MetraTech.SecurityFramework
{
	internal class DefaultInputRequestScreenerEngine : RequestScreenerEngineBase
	{
		private Dictionary<string, int> _maxParamCountExceptions = new Dictionary<string, int>();
		private HashSet<string> _allowedRequestParams = new HashSet<string>();

		#region Properties

		[SerializeProperty(IsRequired = true)]
		public uint MaxBodySize
		{
			get;
			private set;
		}

		[SerializeProperty(IsRequired = true)]
		public uint MaxParamCount
		{
			get;
			private set;
		}

		[SerializeProperty(IsRequired = true)]
		public uint DefaultMaxParamRepeatCount
		{
			get;
			private set;
		}

		[SerializeProperty(IsRequired=true)]
		public bool DoVerifyParamNames
		{
			get;
			private set;
		}

		[SerializeCollection(ElementName = "eParameter", ElementType = typeof(RequestScreenerEngineExtraParamInfo), IsRequired=true)]
		public List<RequestScreenerEngineExtraParamInfo> ExtraParams
		{
			get;
			set;
		}

		#endregion

		public DefaultInputRequestScreenerEngine() : base(RequestScreenerEngineCategory.Input) { }

		public override void Initialize()
		{
			foreach (RequestScreenerEngineExtraParamInfo paramInfo in ExtraParams)
			{
				if (paramInfo.Type == "RequestParams")
				{
					_allowedRequestParams.Add(paramInfo.Id);

					if (!(string.IsNullOrEmpty(paramInfo.Data) || (paramInfo.Data == "0")))
					{
						string sval = paramInfo.Data.Trim();
						int ival = 0;
						int.TryParse(sval, out ival);
						_maxParamCountExceptions.Add(paramInfo.Id, ival);
					}
				}
			}

			base.Initialize();
		}

		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			RequestScreenerApiInput apiInput = input.Value as RequestScreenerApiInput;
			if (apiInput == null)
			{
				throw new ApplicationException("DefaultInputRequestScreenerEngine.Execute() => Bad api input from context");
			}

			CheckContextSize(apiInput.RequestBodySize, apiInput.ParametersCount);

			string[] nameOfParameters = apiInput.Parameters.AllKeys;
			for (int i = 0; i < nameOfParameters.Length; i++)
			{
				string name = nameOfParameters[i];
				if (string.IsNullOrEmpty(name))
					continue;

				ExecuteAllowedRequestParam(name);

				if (HasMaxParamCountExceptions())
				{
					string[] values = apiInput.Parameters.GetValues(name);
					if (null != values)
					{
						ExecuteAllowedRequestParamRepeatCount(name, values.Length);
					}
				}
			}

			return new ApiOutput(input);
		}

		#region External

		private void CheckContextSize(int bodySize, int paramCount)
		{
			if (bodySize < 0)
				throw new ApplicationException("DefaultInputRequestScreenerEngine.Execute() => Bad bodySize argument");

			if (paramCount < 0)
				throw new ApplicationException("DefaultInputRequestScreenerEngine.Execute() => Bad paramCount argument");

			if ((bodySize > MaxBodySize) || (paramCount > MaxParamCount))
				throw new RequestScreenerInputDataException(Id);
		}

		private void ExecuteAllowedRequestParam(string paramName)
		{
			if (DoVerifyParamNames)
			{
				if (string.IsNullOrEmpty(paramName))
					throw new ArgumentNullException("DefaultInputRequestScreenerEngine.ExecuteAllowedRequestParam");

				if (!_allowedRequestParams.Contains(paramName))
					throw new RequestScreenerInputDataException(Id);
			}
		}

		private void ExecuteAllowedRequestParamRepeatCount(string paramName, int paramRepeatCount)
		{
			if (paramRepeatCount < 0)
				throw new ApplicationException("DefaultInputRequestScreenerEngine.ExecuteAllowedRequestParamRepeatCount() => Bad bodySize argument");

			if (string.IsNullOrEmpty(paramName))
				throw new ArgumentNullException("DefaultInputRequestScreenerEngine.ExecuteAllowedRequestParamRepeatCount");

			if (_maxParamCountExceptions.ContainsKey(paramName))
			{
				int count = 0;
				if (_maxParamCountExceptions.TryGetValue(paramName, out count))
				{
					if (paramRepeatCount > count)
					{
						throw new RequestScreenerInputDataException(Id);
					}
				}
				else
				{
					if (paramRepeatCount > DefaultMaxParamRepeatCount)
					{
						throw new RequestScreenerInputDataException(Id);
					}
				}
			}
			else
			{
				if (paramRepeatCount > DefaultMaxParamRepeatCount)
				{
					throw new RequestScreenerInputDataException(Id);
				}
			}
		}

		public bool HasMaxParamCountExceptions()
		{
			return _maxParamCountExceptions.Count > 0 ? true : false;
		}

		#endregion
	}
}
