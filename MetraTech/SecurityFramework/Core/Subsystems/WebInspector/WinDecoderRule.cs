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
    public class WinDecoderRule : WinRule
    {
			//SECENG
			private IEngine _engine = null;
        //private IDecoderEngine _engine = null;
			//SECENG:
			//public WinDecoderRule(IDecoderEngine engine, WinRuleInfo info) : base(info.Id,info.Engine,info.Subsystem)
        public WinDecoderRule(IEngine engine, WinRuleInfo info) : base(info.Id,info.Engine,info.Subsystem)
        {
            _engine = engine;
            _contextParams = info.Params;
        }

        public override bool Filter(WinFilterContext context)
        {
            bool doContinue = true;
            return doContinue;
        }
    }
}
