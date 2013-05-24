using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework
{
	public class WebInspectorErrorEngine : WebInspectorEngineBase
	{
		public WebInspectorErrorEngine() : 
			base(WebInspectorEngineCategory.WebInspectorError)
		{ }

		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			ApiOutput result = base.ExecuteInternal(input);
			WebInspectorErrorApiInput apiInput = input.Value as WebInspectorErrorApiInput;

			if (apiInput == null)
			{
				throw new WebInspectorException(string.Format("Input parameter type for WebInspector {0} is not valid!", Id));
			}

			Inspector.ProcessError(apiInput.App, apiInput.Response, apiInput.Exception, apiInput.BaseException);

			return result;
		}
	}
}
