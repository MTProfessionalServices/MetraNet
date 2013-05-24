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
using System.Collections.Specialized;
using System.Web;

namespace MetraTech.SecurityFramework.WebInspector
{
	public class WinProcessor
	{
		private string _processorId = string.Empty;
		private bool _stopOnError = true;

		private List<WinRule> _requestRules = new List<WinRule>();
		private List<WinRule> _commonRules = new List<WinRule>();
		private List<WinRule> _commonQueryStringRules = new List<WinRule>();
		private Dictionary<string, WinRule> _namedQueryStringRules = new Dictionary<string, WinRule>();
		private List<WinRule> _commonFormRules = new List<WinRule>();
		private Dictionary<string, WinRule> _namedFormRules = new Dictionary<string, WinRule>();
		private List<WinRule> _commonCookieRules = new List<WinRule>();
		private Dictionary<string, WinRule> _namedCookieRules = new Dictionary<string, WinRule>();

		private Dictionary<string, WinResourceRule> _firstResourceRules = new Dictionary<string, WinResourceRule>();
		private Dictionary<string, WinResourceRule> _lastResourceRules = new Dictionary<string, WinResourceRule>();

		private List<WinAction> _actions = new List<WinAction>();
		private List<WinActionableResult> _actionableResults = new List<WinActionableResult>();

		public string ProcessorId
		{ get { return _processorId; } }

		public bool HasActionableResults()
		{ return (_actionableResults.Count > 0); }

		public List<WinActionableResult> ActionableResults
		{ get { return _actionableResults; } }

		public void ClearActionableResults()
		{
			_actionableResults.Clear();
		}

		public List<WinAction> RuleActions
		{ get { return _actions; } }

		public static WinProcessor CreateProcessor(WinProcessorInfo info)
		{
			WinProcessor obj = new WinProcessor(info);
			return obj;
		}

		private WinProcessor(WinProcessorInfo info)
		{
			_processorId = info.Id;
			_stopOnError = info.StopOnError;

			if (null != info.RequestRules)
			{
				foreach (WinRuleInfo rinfo in info.RequestRules)
				{
					WinRule rule = WinRule.CreateRule(rinfo);
					_requestRules.Add(rule);
				}
			}

			if (null != info.CommonRules)
			{
				foreach (WinRuleInfo rinfo in info.CommonRules)
				{
					WinRule rule = WinRule.CreateRule(rinfo);
					_commonRules.Add(rule);
				}
			}

			if (null != info.CommonQueryStringRules)
			{
				foreach (WinRuleInfo rinfo in info.CommonQueryStringRules)
				{
					WinRule rule = WinRule.CreateRule(rinfo);
					_commonQueryStringRules.Add(rule);
				}
			}

			if (null != info.NamedQueryStringRules)
			{
				foreach (string name in info.NamedQueryStringRules.Keys)
				{
					WinRuleInfo rinfo = info.NamedQueryStringRules[name];
					WinRule rule = WinRule.CreateRule(rinfo);
					string normName = name.ToLower();
					_namedQueryStringRules[normName] = rule;
				}
			}

			if (null != info.CommonFormRules)
			{
				foreach (WinRuleInfo rinfo in info.CommonFormRules)
				{
					WinRule rule = WinRule.CreateRule(rinfo);
					_commonFormRules.Add(rule);
				}
			}

			if (null != info.NamedFormRules)
			{
				foreach (string name in info.NamedFormRules.Keys)
				{
					WinRuleInfo rinfo = info.NamedFormRules[name];
					WinRule rule = WinRule.CreateRule(rinfo);
					string normName = name.ToLower();
					_namedFormRules[normName] = rule;
				}
			}

			if (null != info.CommonCookieRules)
			{
				foreach (WinRuleInfo rinfo in info.CommonCookieRules)
				{
					WinRule rule = WinRule.CreateRule(rinfo);
					_commonCookieRules.Add(rule);
				}
			}

			if (null != info.NamedCookieRules)
			{
				foreach (string name in info.NamedCookieRules.Keys)
				{
					WinRuleInfo rinfo = info.NamedCookieRules[name];
					WinRule rule = WinRule.CreateRule(rinfo);
					string normName = name.ToLower();
					_namedCookieRules[normName] = rule;
				}
			}

			if (null != info.ResourceRules)
			{
				foreach (WinResourceRuleInfo rinfo in info.ResourceRules)
				{
					WinResourceRule rule = WinResourceRule.CreateRule(_stopOnError, rinfo);
					if (null != rule)
					{
						string normResource = rinfo.Resource.ToLower();
						if (rinfo.UseFirst)
						{
							_firstResourceRules[normResource] = rule;
						}
						else
						{
							_lastResourceRules[normResource] = rule;
						}
					}
				}
			}

			if (null != info.RuleActions)
			{
				foreach (WinActionInfo ainfo in info.RuleActions)
				{
					WinAction action = WinAction.CreateAction(ainfo);
					_actions.Add(action);
				}
			}
		}

		public bool ProcessRequest(string normalizedUrl,
								   string rawUrl,
								   NameValueCollection queryStringParams,
								   NameValueCollection formParams,
								   HttpCookieCollection cookies,
								   NameValueCollection headers,
								   int requestBodySize)
		{
			bool isOk = true;

			WinFilterContext filterContext = new WinFilterContext();
			filterContext.rawUrl = rawUrl;
			filterContext.normalUrl = normalizedUrl;
			filterContext.queryStringParams = queryStringParams;
			filterContext.formParams = formParams;
			filterContext.cookies = cookies;
			filterContext.requestBodySize = requestBodySize;

			foreach (WinRule rule in _requestRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						rule.RuleId, "", "", "", filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			return isOk;
		}

		public bool ProcessRequestSimple(string normalizedUrl,
									  string rawUrl,
									 string remoteAddr,
									 string userAgent,
									 string referer,
									 int paramCount,
									 ref string[] paramNames,
									 int requestBodySize)
		{
			bool isOk = true;

			WinFilterContext filterContext = new WinFilterContext();
			filterContext.rawUrl = rawUrl;
			filterContext.normalUrl = normalizedUrl;
			filterContext.queryStringParams = null;
			filterContext.formParams = null;
			filterContext.cookies = null;
			filterContext.requestBodySize = requestBodySize;

			filterContext.paramCount = paramCount;
			filterContext.paramNames = paramNames;
			filterContext.remoteAddr = remoteAddr;
			filterContext.userAgent = userAgent;
			filterContext.referer = referer;

			foreach (WinRule rule in _requestRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						rule.RuleId, "", "", "", filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			return isOk;
		}

		public bool CheckFirstResourceRules(WebInspector.WinRequestContext wrContext,
											string resourceName,
											NameValueCollection queryStringParams,
											NameValueCollection formParams,
											string normalizedUrl,
											string rawUrl)
		{
			bool isOk = true;

			if (string.IsNullOrEmpty(resourceName))
				return isOk;

			if ((null == queryStringParams) && (null == formParams))
				return isOk;

			WinResourceRule rule = null;
			if (!_firstResourceRules.TryGetValue(resourceName, out rule))
				return isOk;

			if (null == rule)
				return isOk;

			if (null != queryStringParams)
			{
				String[] qsa = queryStringParams.AllKeys;
				for (int i = 0; i < qsa.Length; i++)
				{
					string paramName = qsa[i];
					if (string.IsNullOrEmpty(paramName))
						continue;

					paramName = paramName.ToLower();

					if (rule._excludeAllPrams.Contains(paramName))
					{
						wrContext.excludeAllParams.Add(paramName);
					}
					else if (rule._excludePrams.Contains(paramName))
					{
						wrContext.excludeParams.Add(paramName);
					}
					else
					{
						String[] values = queryStringParams.GetValues(qsa[i]);

						for (int j = 0; j < values.Length; j++)
						{
							if (string.IsNullOrEmpty(values[j]))
								continue;

							WinFilterContext filterContext = new WinFilterContext();
							filterContext.rawUrl = rawUrl;
							filterContext.normalUrl = normalizedUrl;
							filterContext.paramName = paramName;
							filterContext.paramValue = values[j];

							if (!rule.Filter(wrContext, filterContext))
							{
								string ruleId = filterContext.stopRuleId + "/ResourceRule";
								_actionableResults.Add(new WinActionableResult(
									ruleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
								isOk = false;

								if (_stopOnError)
									return isOk;
							}
						} // end of for loop
					}
				}

			}

			if (null != formParams)
			{
				for (int i = 0; i < formParams.Count; i++)
				{
					string paramName = formParams.GetKey(i);
					if (string.IsNullOrEmpty(paramName))
						continue;

					paramName = paramName.ToLower();

					if (rule._excludeAllPrams.Contains(paramName))
					{
						wrContext.excludeAllParams.Add(paramName);
					}
					else if (rule._excludePrams.Contains(paramName))
					{
						wrContext.excludeParams.Add(paramName);
					}
					else
					{
						string[] values = formParams.GetValues(i);
						for (int j = 0; j < values.Length; j++)
						{
							if (string.IsNullOrEmpty(values[j]))
								continue;

							WinFilterContext filterContext = new WinFilterContext();
							filterContext.rawUrl = rawUrl;
							filterContext.normalUrl = normalizedUrl;
							filterContext.paramName = paramName;
							filterContext.paramValue = values[j];

							if (!rule.Filter(wrContext, filterContext))
							{
								string ruleId = filterContext.stopRuleId + "/ResourceRule";
								_actionableResults.Add(new WinActionableResult(
									ruleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
								isOk = false;

								if (_stopOnError)
									return isOk;
							}
						} //end of for loop
					}
				}
			}

			return isOk;
		}

		public bool CheckFirstResourceRulesForParam(WebInspector.WinRequestContext wrContext,
													string resourceName,
													string normParamName,
													string paramValue,
													string normalizedUrl,
													string rawUrl)
		{
			//paramName is already normalized/lowercase
			bool isOk = true;

			if (string.IsNullOrEmpty(resourceName))
				return isOk;

			if (string.IsNullOrEmpty(normParamName))
				return isOk;

			if (string.IsNullOrEmpty(paramValue))
				return isOk;

			WinResourceRule rule = null;
			if (!_firstResourceRules.TryGetValue(resourceName, out rule))
				return isOk;

			if (null == rule)
				return isOk;

			if (rule._excludeAllPrams.Contains(normParamName))
			{
				wrContext.excludeAllParams.Add(normParamName);
			}
			else if (rule._excludePrams.Contains(normParamName))
			{
				wrContext.excludeParams.Add(normParamName);
			}
			else
			{
				WinFilterContext filterContext = new WinFilterContext();
				filterContext.rawUrl = rawUrl;
				filterContext.normalUrl = normalizedUrl;
				filterContext.paramName = normParamName;
				filterContext.paramValue = paramValue;

				if (!rule.Filter(wrContext, filterContext))
				{
					string ruleId = filterContext.stopRuleId + "/ResourceRule";
					_actionableResults.Add(new WinActionableResult(
									ruleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;
				}
			}


			return isOk;
		}

		public bool CheckLastResourceRulesForParam(WebInspector.WinRequestContext wrContext,
												   string resourceName,
												   string normParamName,
												   string paramValue,
												   string normalizedUrl,
												   string rawUrl)
		{
			//paramName is already normalized/lowercase
			bool isOk = true;

			if (string.IsNullOrEmpty(resourceName))
				return isOk;

			if (string.IsNullOrEmpty(normParamName))
				return isOk;

			if (string.IsNullOrEmpty(paramValue))
				return isOk;

			if (wrContext.excludeAllParams.Contains(normParamName))
				return isOk;

			WinResourceRule rule = null;
			if (!_lastResourceRules.TryGetValue(resourceName, out rule))
				return isOk;

			if (null == rule)
				return isOk;

			WinFilterContext filterContext = new WinFilterContext();
			filterContext.rawUrl = rawUrl;
			filterContext.normalUrl = normalizedUrl;
			filterContext.paramName = normParamName;
			filterContext.paramValue = paramValue;

			if (!rule.Filter(wrContext, filterContext))
			{
				string ruleId = filterContext.stopRuleId + "/ResourceRule";
				_actionableResults.Add(new WinActionableResult(
								ruleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
				isOk = false;
			}


			return isOk;
		}

		public bool CheckLastResourceRules(WebInspector.WinRequestContext wrContext,
										   string resourceName,
										   NameValueCollection queryStringParams,
										   NameValueCollection formParams,
										   string normalizedUrl,
										   string rawUrl)
		{
			bool isOk = true;

			if (string.IsNullOrEmpty(resourceName))
				return isOk;

			if ((null == queryStringParams) && (null == formParams))
				return isOk;

			WinResourceRule rule = null;
			if (!_lastResourceRules.TryGetValue(resourceName, out rule))
				return isOk;

			if (null == rule)
				return isOk;

			if (null != queryStringParams)
			{
				String[] qsa = queryStringParams.AllKeys;
				for (int i = 0; i < qsa.Length; i++)
				{
					string paramName = qsa[i];
					if (string.IsNullOrEmpty(paramName))
						continue;

					paramName = paramName.ToLower();

					if (wrContext.excludeAllParams.Contains(paramName))
						continue;

					String[] values = queryStringParams.GetValues(qsa[i]);

					for (int j = 0; j < values.Length; j++)
					{
						if (string.IsNullOrEmpty(values[j]))
							continue;

						WinFilterContext filterContext = new WinFilterContext();
						filterContext.rawUrl = rawUrl;
						filterContext.normalUrl = normalizedUrl;
						filterContext.paramName = qsa[i].ToLower();
						filterContext.paramValue = values[j];

						if (!rule.Filter(wrContext, filterContext))
						{
							string ruleId = filterContext.stopRuleId + "/ResourceRule";
							_actionableResults.Add(new WinActionableResult(
								ruleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}
				}

			}

			if (null != formParams)
			{
				for (int i = 0; i < formParams.Count; i++)
				{
					string paramName = formParams.GetKey(i);
					if (string.IsNullOrEmpty(paramName))
						continue;

					paramName = paramName.ToLower();

					if (wrContext.excludeAllParams.Contains(paramName))
						continue;

					string[] values = formParams.GetValues(i);
					for (int j = 0; j < values.Length; j++)
					{
						if (string.IsNullOrEmpty(values[j]))
							continue;

						WinFilterContext filterContext = new WinFilterContext();
						filterContext.rawUrl = rawUrl;
						filterContext.normalUrl = normalizedUrl;
						filterContext.paramName = paramName;
						filterContext.paramValue = values[j];

						if (!rule.Filter(wrContext, filterContext))
						{
							string ruleId = filterContext.stopRuleId + "/ResourceRule";
							_actionableResults.Add(new WinActionableResult(
								ruleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}
				}
			}

			return isOk;
		}

		public bool ProcessQueryStringParams(WebInspector.WinRequestContext wrContext, NameValueCollection queryStringParams, string normalizedUrl, string rawUrl)
		{
			bool isOk = true;

			if (null == queryStringParams)
				return isOk;

			String[] qsa = queryStringParams.AllKeys;
			for (int i = 0; i < qsa.Length; i++)
			{
				string paramName = qsa[i].ToLower();
				if (string.IsNullOrEmpty(paramName))
					continue;

				if (wrContext.excludeAllParams.Contains(paramName) || wrContext.excludeParams.Contains(paramName))
					continue;

				String[] values = queryStringParams.GetValues(qsa[i]);
				for (int j = 0; j < values.Length; j++)
				{
					if (string.IsNullOrEmpty(values[j]))
						continue;

					WinFilterContext filterContext = new WinFilterContext();
					filterContext.rawUrl = rawUrl;
					filterContext.normalUrl = normalizedUrl;
					filterContext.paramName = qsa[i].ToLower();
					filterContext.paramValue = values[j];

					foreach (WinRule rule in _commonRules)
					{
						if (!rule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								rule.RuleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}

					foreach (WinRule rule in _commonQueryStringRules)
					{
						if (!rule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								rule.RuleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}

					WinRule namedRule = null;
					if (_namedQueryStringRules.TryGetValue(filterContext.paramName, out namedRule))
					{
						if (!namedRule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								namedRule.RuleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}
				}
			}

			return isOk;
		}

		public bool ProcessQueryStringParam(WebInspector.WinRequestContext wrContext, string normalizedUrl, string rawUrl, string paramName, string paramValue)
		{
			//paramName is already normalized/lowercase
			bool isOk = true;

			if (string.IsNullOrEmpty(paramName))
				return isOk;

			if (string.IsNullOrEmpty(paramValue))
				return isOk;

			if (wrContext.excludeAllParams.Contains(paramName) || wrContext.excludeParams.Contains(paramName))
				return isOk;

			WinFilterContext filterContext = new WinFilterContext();
			filterContext.rawUrl = rawUrl;
			filterContext.normalUrl = normalizedUrl;
			filterContext.paramName = paramName; //already lowercase
			filterContext.paramValue = paramValue;

			foreach (WinRule rule in _commonRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						rule.RuleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			foreach (WinRule rule in _commonQueryStringRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						rule.RuleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			WinRule namedRule = null;
			if (_namedQueryStringRules.TryGetValue(filterContext.paramName, out namedRule))
			{
				if (!namedRule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						namedRule.RuleId, WinFieldSource.QueryString, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			return isOk;
		}

		public bool ProcessFormParams(WebInspector.WinRequestContext wrContext, NameValueCollection formParams, string normalizedUrl, string rawUrl)
		{
			bool isOk = true;

			if (null == formParams)
				return isOk;

			for (int i = 0; i < formParams.Count; i++)
			{
				string paramName = formParams.GetKey(i);
				if (string.IsNullOrEmpty(paramName))
					continue;

				paramName = paramName.ToLower();

				if (wrContext.excludeAllParams.Contains(paramName) || wrContext.excludeParams.Contains(paramName))
					continue;

				string[] values = formParams.GetValues(i);
				for (int j = 0; j < values.Length; j++)
				{
					if (string.IsNullOrEmpty(values[j]))
						continue;

					WinFilterContext filterContext = new WinFilterContext();
					filterContext.rawUrl = rawUrl;
					filterContext.normalUrl = normalizedUrl;
					filterContext.paramName = paramName;
					filterContext.paramValue = values[j];

					foreach (WinRule rule in _commonRules)
					{
						if (!rule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								rule.RuleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}

					foreach (WinRule rule in _commonFormRules)
					{
						if (!rule.Filter(filterContext))
						{
							_actionableResults.Add(
								new WinActionableResult(rule.RuleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}

					WinRule namedRule = null;
					if (_namedFormRules.TryGetValue(filterContext.paramName, out namedRule))
					{
						if (!namedRule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								namedRule.RuleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}
				}
			}

			return isOk;
		}

		public bool ProcessFormParam(WebInspector.WinRequestContext wrContext, string normalizedUrl, string rawUrl, string paramName, string paramValue)
		{
			//paramName is already normalized/lowercase
			bool isOk = true;

			if (string.IsNullOrEmpty(paramName))
				return isOk;

			if (string.IsNullOrEmpty(paramValue))
				return isOk;

			if (wrContext.excludeAllParams.Contains(paramName) || wrContext.excludeParams.Contains(paramName))
				return isOk;

			WinFilterContext filterContext = new WinFilterContext();
			filterContext.rawUrl = rawUrl;
			filterContext.normalUrl = normalizedUrl;
			filterContext.paramName = paramName; //already lowercase
			filterContext.paramValue = paramValue;

			foreach (WinRule rule in _commonRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						rule.RuleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			foreach (WinRule rule in _commonFormRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(
						new WinActionableResult(rule.RuleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			WinRule namedRule = null;
			if (_namedFormRules.TryGetValue(filterContext.paramName, out namedRule))
			{
				if (!namedRule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						namedRule.RuleId, WinFieldSource.Form, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			return isOk;
		}

		public bool ProcessCookies(WebInspector.WinRequestContext wrContext, HttpCookieCollection cookies)
		{
			bool isOk = true;

			String[] ca = cookies.AllKeys;//cookie names
			for (int i = 0; i < ca.Length; i++)
			{
				HttpCookie cookie = cookies[ca[i]];
				//cookie.Name
				//cookie.Expires
				//cookie.Secure

				String[] values = cookie.Values.AllKeys;
				for (int j = 0; j < values.Length; j++)
				{
					if (string.IsNullOrEmpty(values[j]))
						continue;

					WinFilterContext filterContext = new WinFilterContext();
					filterContext.paramName = cookie.Name;
					if (null != filterContext.paramName)
					{
						filterContext.paramName = filterContext.paramName.ToLower();
					}
					filterContext.paramValue = values[j];

					foreach (WinRule rule in _commonRules)
					{
						if (!rule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								rule.RuleId, WinFieldSource.Cookie, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}

					foreach (WinRule rule in _commonQueryStringRules)
					{
						if (!rule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								rule.RuleId, WinFieldSource.Cookie, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}

					WinRule namedRule = null;
					if (_namedQueryStringRules.TryGetValue(filterContext.paramName, out namedRule))
					{
						if (!namedRule.Filter(filterContext))
						{
							_actionableResults.Add(new WinActionableResult(
								namedRule.RuleId, WinFieldSource.Cookie, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
							isOk = false;

							if (_stopOnError)
								return isOk;
						}
					}
				}
			}

			return isOk;
		}

		public bool ProcessCookie(string normalizedUrl, string rawUrl, string cookieName, string cookieValue)
		{
			//cookieName is already normalized/lowercase
			bool isOk = true;

			if (string.IsNullOrEmpty(cookieName))
				return isOk;

			if (string.IsNullOrEmpty(cookieValue))
				return isOk;

			WinFilterContext filterContext = new WinFilterContext();
			filterContext.paramName = cookieName;
			filterContext.paramValue = cookieValue;

			foreach (WinRule rule in _commonRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						rule.RuleId, WinFieldSource.Cookie, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			foreach (WinRule rule in _commonCookieRules)
			{
				if (!rule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						rule.RuleId, WinFieldSource.Cookie, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			WinRule namedRule = null;
			if (_namedCookieRules.TryGetValue(filterContext.paramName, out namedRule))
			{
				if (!namedRule.Filter(filterContext))
				{
					_actionableResults.Add(new WinActionableResult(
						namedRule.RuleId, WinFieldSource.Cookie, filterContext.paramName, filterContext.paramValue, filterContext.stopSubsystem, filterContext.stopEngineId));
					isOk = false;

					if (_stopOnError)
						return isOk;
				}
			}

			return isOk;
		}
	}
}
