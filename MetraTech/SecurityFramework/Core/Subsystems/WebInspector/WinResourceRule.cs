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
using MetraTech.SecurityFramework;

namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinResourceRule
    {
        private bool _stopOnError = false;
        private Dictionary<string, List<WinRule>> _paramRules = new Dictionary<string, List<WinRule>>();
        private List<WinRule> _allParamRules = new List<WinRule>();

        public HashSet<string> _excludeAllPrams = new HashSet<string>();
        public HashSet<string> _excludePrams = new HashSet<string>(); 

        protected WinResourceRule(bool stopOnError,List<WinParamRuleInfo> paramRules)
        {
            _stopOnError = stopOnError;
            foreach (WinParamRuleInfo rinfo in paramRules)
            {
                List<WinRule> rlist = null;
                string key = rinfo.Param.ToLower();

                //Check if it's a speciall rule that applies to all parameters:
                if (key == "=")
                {
                    WinRule rule = WinRule.CreateRule(rinfo.Rule);
                    _allParamRules.Add(rule);
                }
                else
                {
                    if (rinfo.ExcludeAll)
                    {
                        _excludeAllPrams.Add(key);
                    }
                    else if (rinfo.Exclude)
                    {
                        _excludePrams.Add(key);
                    }
                    else
                    {
                        if (_paramRules.ContainsKey(key))
                        {
                            if (_paramRules.TryGetValue(key, out rlist))
                            {
                                WinRule rule = WinRule.CreateRule(rinfo.Rule);
                                rlist.Add(rule);
                            }
                        }
                        else
                        {
                            rlist = new List<WinRule>();
                            if (null != rlist)
                            {
                                WinRule rule = WinRule.CreateRule(rinfo.Rule);
                                rlist.Add(rule);
                                _paramRules[key] = rlist;
                            }
                        }
                    }
                }
            }
        }

        public static WinResourceRule CreateRule(bool stopOnError, WinResourceRuleInfo info)
        {
            if (string.IsNullOrEmpty(info.Resource))
            {
                return null;
            }

            if (null == info.ParamRules)
            {
                return null;
            }

            WinResourceRule rule = new WinResourceRule(stopOnError,info.ParamRules);
            return rule;
        }

        public List<WinRule> GetRules(string paramName)
        {
            List<WinRule> rules = null;
            if (string.IsNullOrEmpty(paramName))
                return null;

            if (_paramRules.TryGetValue(paramName.ToLower(), out rules))
            {
                return rules;
            }
            else
            {
                return null;
            }
        }

        public bool Filter(WebInspector.WinRequestContext wrContext, WinFilterContext context)
        {
            //For now we will not keep track of the operations performed on the parameter
            //Later we can use rule.EngineId and rule.SubsystemId for those purposes
            bool doContinue = true;

            if (null == context)
                return doContinue;

            if (null == context.paramName)
                return doContinue;

            List<WinRule> rlist = null;
            //NOTE: We know that context.paramName is already lowercase
            if (_paramRules.TryGetValue(context.paramName, out rlist))
            {
                if (null != rlist)
                {
                    foreach (WinRule rule in rlist)
                    {
                        if (!rule.Filter(context))
                        {
                            context.stopRuleId = rule.RuleId;

                            if (_stopOnError)
                                return false;
                        }
                    }
                }
            }

            return doContinue;
        }
    }
}
