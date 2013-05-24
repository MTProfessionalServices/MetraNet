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
using MetraTech.SecurityFramework.Serialization.Attributes;


namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinPropertiesInfo
		{
			#region Public properties
			
			[SerializeProperty]
			public string Version
			{ 
				get; 
				set; 
			}

			[SerializeProperty]
			public bool DoMonitorPerformance
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool DoActionLog
			{
				get;
				set;
			}

			[SerializeProperty]
			public string ActionLogTarget
			{
				get;
				set;
			}

			[SerializeProperty]
			public string ActionLogPath
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool UseRelativeActionLogPath
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool DoSysLog
			{
				get;
				set;
			}

			[SerializeProperty]
			public string SysLogTarget
			{
				get;
				set;
			}

			[SerializeProperty]
			public string SysLogPath
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool UseRelativeSysLogPath
			{
				get;
				set;
			}

			[SerializeProperty]
			public string SysLogLevel
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool IgnoreAspNetValidation
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool HideAspNetExceptions
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool DoGlobalDisable
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool DoGlobalRequestRulesDisable
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool DoGlobalParamRulesDisable
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool DoGlobalRuleActionsDisable
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool DoGlobalResponseActionsDisable
			{
				get;
				set;
			}

			[SerializeProperty]
			public bool ProcessAuthenticatedOnly
			{
				get;
				set;
			}

			[SerializeProperty]
			public long ProcessRequestTimeout
			{
				get;
				set;
			}

			[SerializeProperty]
			public long ProcessResponseTimeout
			{
				get;
				set;
			}

			[SerializeCollection(ElementType = typeof(WinProcessorInfo), ElementName = "Processor")]
			public List<WinProcessorInfo> Processors
			{
				get;
				set;
			}

			#endregion

			#region Constructors

			public WinPropertiesInfo()
			{
				Version = "<missing>";
        DoMonitorPerformance = false;
        DoActionLog = false;
        UseRelativeActionLogPath = false;
        DoSysLog = false;
        UseRelativeSysLogPath = false;
        IgnoreAspNetValidation = true;
        HideAspNetExceptions = true;
        DoGlobalDisable = false;
        DoGlobalRequestRulesDisable = false;
        DoGlobalParamRulesDisable = false;
        DoGlobalRuleActionsDisable = false;
        DoGlobalResponseActionsDisable = false;
        ProcessAuthenticatedOnly = true;
        ProcessRequestTimeout = 30000;
        ProcessResponseTimeout = 30000;
				Processors = new List<WinProcessorInfo>();
			}

			#endregion

			//SECENG:
        /*public string Version = "<missing>";
        public bool DoMonitorPerformance = false;

        public bool DoActionLog = false;
        public string ActionLogTarget;
        public string ActionLogPath;
        public bool UseRelativeActionLogPath = false;

        public bool DoSysLog = false;
        public string SysLogTarget;
        public string SysLogPath;
        public bool UseRelativeSysLogPath = false;
        public string SysLogLevel;

        public bool IgnoreAspNetValidation = true;
        public bool HideAspNetExceptions = true;
        public bool DoGlobalDisable = false;
        public bool DoGlobalRequestRulesDisable = false;
        public bool DoGlobalParamRulesDisable = false;
        public bool DoGlobalRuleActionsDisable = false;
        public bool DoGlobalResponseActionsDisable = false;
        public bool ProcessAuthenticatedOnly = true;
        public long ProcessRequestTimeout = 30000;
        public long ProcessResponseTimeout = 30000;
        public List<WinProcessorInfo> Processors;*/
    }
}
