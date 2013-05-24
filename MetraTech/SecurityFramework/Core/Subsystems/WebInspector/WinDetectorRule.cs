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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.SecurityFramework.Common.Configuration;

namespace MetraTech.SecurityFramework.WebInspector
{
	public class WinDetectorRule : WinRule
	{
		//SECENG
		private IEngine _engine = null;
		//private IDetectorEngine _engine = null;

		//SECENG
		//public WinDetectorRule(IDetectorEngine engine, WinRuleInfo info)
		public WinDetectorRule(IEngine engine, WinRuleInfo info)
			: base(info.Id, info.Engine, info.Subsystem)
		{
			_engine = engine;
			_contextParams = info.Params;
		}

		public override bool Filter(WinFilterContext context)
		{
			bool doContinue = true;
			if (null != _engine)
			{
				try
				{
                    _engine.Execute(context.paramValue);

                    // Check Form parameters
                    if (context.formParams != null)
                    {
                        foreach (string key in context.formParams.AllKeys)
                        {
                            _engine.Execute(context.formParams[key]);
                        }
                    }

                    // Check Query string parameters
                    if (context.queryStringParams != null)
                    {
                        foreach (string key in context.queryStringParams.AllKeys)
                        {
                            _engine.Execute(context.queryStringParams[key]);
                        }
                    }

                    // Check Headers
                    if (context.headers != null)
                    {
                        foreach (string key in context.headers.AllKeys)
                        {
                            _engine.Execute(context.headers[key]);
                        }
                    }

                    // Check Cookies
                    if (context.cookies != null)
                    {
                        foreach (string key in context.cookies.AllKeys)
                        {
                            System.Web.HttpCookie cookie = context.cookies[key];
                            if (cookie != null)
                            {
                                _engine.Execute(cookie.Value);
                            }
                        }
                    }
				}
				catch (DetectorInputDataException x)
				{
					doContinue = false;
					//SECENG:
					context.stopSubsystem = ConfigurationLoader.GetSubsystem<Detector>().SubsystemName;
					//context.stopSubsystem = SubsystemName.Detector;
					context.stopEngineId = x.Message;
					x.Report();
				}
				catch (Exception x)
				{
					Console.WriteLine(x.Message);
				}
			}
			return doContinue;
		}
	}
}

