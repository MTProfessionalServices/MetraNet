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
using MetraTech.SecurityFramework.Common.Configuration;

namespace MetraTech.SecurityFramework.WebInspector
{
	public abstract class WinRule
	{
		private delegate WinRule RuleCreator(WinRuleInfo info);

		private static Dictionary<string, RuleCreator> _ruleFactory = new Dictionary<string, RuleCreator>() 
        {
					//SECENG:
            /*{SubsystemName.Decoder, CreateDecoderRule},
            {SubsystemName.Detector, CreateDetectorRule},
            {SubsystemName.Validator, CreateValidatorRule},
            {SubsystemName.RequestScreener, CreateRequestScreenerRule}*/
						{ConfigurationLoader.GetSubsystem<Decoder>().SubsystemName, CreateDecoderRule},
            {ConfigurationLoader.GetSubsystem<Detector>().SubsystemName, CreateDetectorRule},
            {ConfigurationLoader.GetSubsystem<Validator>().SubsystemName, CreateValidatorRule},
            {ConfigurationLoader.GetSubsystem<RequestScreener>().SubsystemName, CreateRequestScreenerRule}
        };

		protected string _ruleId;
		protected string _engineId;
		protected string _subsystemId;

		protected Dictionary<string, string> _contextParams = null;

		protected WinRule(string ruleId, string engineId, string subsystemId)
		{
			_ruleId = ruleId;
			_engineId = engineId;
			_subsystemId = subsystemId;
		}

		public string RuleId
		{ get { return _ruleId; } }

		public string EngineId
		{ get { return _engineId; } }

		public string SubsystemId
		{ get { return _subsystemId; } }

		public Dictionary<string, string> ContextParams
		{ get { return _contextParams; } }

		public abstract bool Filter(WinFilterContext context);

		public static WinRule CreateRule(WinRuleInfo info)
		{
			WinRule rule = null;
			RuleCreator ruleCreator = null;
			if (_ruleFactory.TryGetValue(info.Subsystem, out ruleCreator) && (null != ruleCreator))
			{
				rule = ruleCreator(info);
			}
			return rule;
		}

		static WinRule CreateRequestScreenerRule(WinRuleInfo info)
		{
			WinRule rule = null;
			//SECENG:
			//IRequestScreenerEngine engine = SecurityKernel.RequestScreener.Api.GetEngine(info.Engine); //Decoder.Api.GetEngine(info.Engine);
			IEngine engine = ConfigurationLoader.GetSubsystem<RequestScreener>().Api.GetEngine(info.Engine);
			rule = new WinRequestScreenerRule(engine, info);
			return rule;
		}

		static WinRule CreateDecoderRule(WinRuleInfo info)
		{
			WinRule rule = null;
			//SECENG:
			//IDecoderEngine engine = SecurityKernel.Decoder.Api.GetEngine(info.Engine);
			IEngine engine = ConfigurationLoader.GetSubsystem<Decoder>().Api.GetEngine(info.Engine);
			rule = new WinDecoderRule(engine, info);
			return rule;
		}

		static WinRule CreateDetectorRule(WinRuleInfo info)
		{
			WinRule rule = null;
			//SECENG:
			//IDetectorEngine engine = SecurityKernel.Detector.Api.GetEngine(info.Engine);
			IEngine engine = ConfigurationLoader.GetSubsystem<Detector>().Api.GetEngine(info.Engine);
			rule = new WinDetectorRule(engine, info);
			return rule;
		}

		static WinRule CreateValidatorRule(WinRuleInfo info)
		{
			WinRule rule = null;
			//SECENG:
			//IValidatorEngine engine = SecurityKernel.Validator.Api.GetEngine(info.Engine);
			IEngine engine = ConfigurationLoader.GetSubsystem<Validator>().Api.GetEngine(info.Engine);
			rule = new WinValidatorRule(engine, info);
			return rule;
		}
	}
}

