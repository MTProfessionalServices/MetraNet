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

namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinAction
    {
        private string _actionType = string.Empty;
        private Dictionary<string, object> _actionParams = new Dictionary<string,object>();

        public string ActionType
        { get { return _actionType; } }

        public object GetActionParam(string paramName)
        {
            object result = null;
            _actionParams.TryGetValue(paramName, out result);

            return result;
        }

        public static WinAction CreateAction(WinActionInfo info)
        {
            WinAction obj = new WinAction(info);
            return obj;
        }

        private WinAction(WinActionInfo info)
        {
            _actionType = info.Name;

            if (null == info.Params)
                return;

            foreach (string key in info.Params.Keys)
            {
                switch (key.ToLower())
                {
                    case "time":
                    {
                        int timeVal = Convert.ToInt32(info.Params[key]);
                        _actionParams[key] = timeVal;
                        break;
                    }
                    case "istemp":
                    {
                        bool val = Convert.ToBoolean(info.Params[key]);
                        _actionParams[key] = val;
                        break;
                    }
                    default:
                    _actionParams[key] = info.Params[key];
                    break;
                }
            }
        }
    }
}
