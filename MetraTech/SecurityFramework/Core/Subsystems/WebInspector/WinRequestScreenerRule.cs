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
    public class WinRequestScreenerRule : WinRule
    {
        private IEngine _engine = null;

				public WinRequestScreenerRule(IEngine engine, WinRuleInfo info)
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
                    int paramCount = 0;
                    int qsParamCount = 0;
                    int formParamCount = 0;

                    if (0 == context.paramCount)
                    {
                        if (null != context.queryStringParams)
                        {
                            qsParamCount = context.queryStringParams.Count;
                            paramCount += qsParamCount;
                        }
                        if (null != context.formParams)
                        {
                            formParamCount = context.formParams.Count;
                            paramCount += formParamCount;
                        }
                    }

                    //_engine.Execute(context.requestBodySize, paramCount);

                    //Yes, we should be using a combined collection for qs and form params,
                    //but request.Params also has other params we don't want

                    if ((0 != qsParamCount) && (null != context.queryStringParams))
                    {
											//SECENG:
											RequestScreenerApiInput input = new RequestScreenerApiInput(context.requestBodySize, paramCount, context.queryStringParams);
											_engine.Execute(new ApiInput(input));
                        /*string[] qsa = context.queryStringParams.AllKeys;
                        for (int i = 0; i < qsa.Length; i++)
                        {     
                            string name = qsa[i];
                            if (string.IsNullOrEmpty(name))
                                continue;

                            _engine.ExecuteAllowedRequestParam(name);

                            if(_engine.HasMaxParamCountExceptions())
                            {
                                string[] values = context.queryStringParams.GetValues(name);
                                if (null != values)
                                {
                                    _engine.ExecuteAllowedRequestParamRepeatCount(name, values.Length);
                                }
                            }
                        }*/
                    }

                    if ((0 != formParamCount) && (null != context.formParams))
										{
											//SECENG:
											RequestScreenerApiInput input = new RequestScreenerApiInput(context.requestBodySize, paramCount, context.formParams);
											_engine.Execute(new ApiInput(input));
                        /*string[] fa = context.formParams.AllKeys;
                        for (int i = 0; i < fa.Length; i++)
                        {
                            string name = fa[i];
                            if (string.IsNullOrEmpty(name))
                                continue;

                            _engine.ExecuteAllowedRequestParam(name);

                            if (_engine.HasMaxParamCountExceptions())
                            {
                                string[] values = context.formParams.GetValues(name);
                                if (null != values)
                                {
                                    _engine.ExecuteAllowedRequestParamRepeatCount(name, values.Length);
                                }
                            }
                        }*/
                    }

                }
                catch (RequestScreenerInputDataException x)
                {
                    doContinue = false;
                  //SECENG:  
									//context.stopSubsystem = SubsystemName.RequestScreener;
										context.stopSubsystem = ConfigurationLoader.GetSubsystem<RequestScreener>().SubsystemName;
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
