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
	public class WinProcessorInfo
	{
		#region Public properties

		[SerializeProperty]
		public string Id
		{
			get;
			set;
		}

		[SerializeProperty]
		public bool StopOnError
		{
			get;
			set;
		}

		[SerializeProperty]
		public WinQualifierInfo Qualifier
		{
			get;
			set;
		}

		[SerializeCollection(ElementName = "RequestRule", ElementType = typeof(WinRuleInfo))]
		public List<WinRuleInfo> RequestRules
		{
			get;
			set;
		}

		[SerializeCollection(ElementName = "CommonRule", ElementType = typeof(WinRuleInfo))]
		public List<WinRuleInfo> CommonRules
		{
			get;
			set;
		}

    [SerializeCollection]
    //[SerializeCollection(ElementName = "CommonQueryStringRule", ElementType = typeof(WinRuleInfo))]
    public List<WinRuleInfo> CommonQueryStringRules
		{
			get;
			set;
		}

    [SerializeCollection]
    //[SerializeCollection(ElementName = "NamedQueryStringRule", ElementType = typeof(WinRuleInfo))]
		public Dictionary<string, WinRuleInfo> NamedQueryStringRules
		{
			get;
			set;
		}

    [SerializeCollection(ElementName = "CommonFormRule", ElementType = typeof(WinRuleInfo))]
		public List<WinRuleInfo> CommonFormRules
		{
			get;
			set;
		}

    [SerializeCollection]
    //[SerializeCollection(ElementName = "NamedFormRule", ElementType = typeof(WinRuleInfo))]
		public Dictionary<string, WinRuleInfo> NamedFormRules
		{
			get;
			set;
		}

    [SerializeCollection]
    //[SerializeCollection(ElementName = "CommonCookieRule", ElementType = typeof(WinRuleInfo))]
		public List<WinRuleInfo> CommonCookieRules
		{
			get;
			set;
		}

    [SerializeCollection]
    //[SerializeCollection(ElementName = "NamedCookieRule", ElementType = typeof(WinRuleInfo))]
		public Dictionary<string, WinRuleInfo> NamedCookieRules
		{
			get;
			set;
		}

		[SerializeCollection(ElementName = "ResourceRule", ElementType = typeof(WinResourceRuleInfo))]
		public List<WinResourceRuleInfo> ResourceRules
		{
			get;
			set;
		}

		[SerializeCollection(ElementName = "ActionRule", ElementType = typeof(WinActionInfo))]
		public List<WinActionInfo> RuleActions
		{
			get;
			set;
		}

		#endregion

		#region Constructors

		public WinProcessorInfo()
		{
			Id = "<missing>";
			StopOnError = true;
			RequestRules = new List<WinRuleInfo>();
			CommonRules = new List<WinRuleInfo>();
			CommonQueryStringRules = new List<WinRuleInfo>();
			NamedQueryStringRules = new Dictionary<string, WinRuleInfo>();
			CommonFormRules = new List<WinRuleInfo>();
			NamedFormRules = new Dictionary<string, WinRuleInfo>();
			CommonCookieRules = new List<WinRuleInfo>();
			NamedCookieRules = new Dictionary<string, WinRuleInfo>();
			ResourceRules = new List<WinResourceRuleInfo>();
			RuleActions = new List<WinActionInfo>();
		}

		#endregion
	}
}

