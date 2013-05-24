using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.Reflection;
using System.IO;
using Microsoft.Win32;
using System.Web;
using System.Collections.Specialized;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework.WebInspector
{
	public class WebInspector : ISecurityPolicyActionHandler
	{
		public class WinRequestContext
		{
			internal long startTicks = 0;
			internal bool doBlacklistBlock = false;
			internal bool doAction = false;
			internal bool doBlock = false;
			internal bool doBlacklist = false;
			internal bool doRedirect = false;
			internal bool doRewriteUrl = false;
			internal bool doLog = false;

			internal HashSet<string> excludeParams = new HashSet<string>();
			internal HashSet<string> excludeAllParams = new HashSet<string>();
		}

		private static readonly string _inspectorVersion = "X.1.2";

		private bool _hasSfStarted = false;
		private string _winPropsLocation = string.Empty;
		private string _sfPropsLocation = string.Empty;
		private object _syncRoot = new object();

		private WinPropertiesInfo _winProperties = null;

		private Dictionary<string, DateTime> _blacklistedSources = new Dictionary<string, DateTime>();
		private Dictionary<string, List<WinProcessorQualifier>> _qualifiers = new Dictionary<string, List<WinProcessorQualifier>>(new CaseInsensitiveStringComparer());
		private List<WinProcessor> _processors = new List<WinProcessor>();
		private Dictionary<string, WinProcessor> _processorsById = new Dictionary<string, WinProcessor>();

        private Dictionary<string, WinProcessor> _processorsPageCache = new Dictionary<string, WinProcessor>(new CaseInsensitiveStringComparer());
        private HashSet<string> _processorsPageExcludeCache = new HashSet<string>(new CaseInsensitiveStringComparer());

		private WinPerformanceMonitor _perfMon = null;
		private WinLogActionHandler _laHandler = null;

		public void Initialize(WinPropertiesInfo info)
		{
			lock (_syncRoot)
			{
				if (_hasSfStarted)
					return;

				try
				{
					//SECENG:
					/*if (string.IsNullOrEmpty(winPropsLocation) && string.IsNullOrEmpty(sfPropsLocation))
					{
					  winPropsLocation = WinConfigInfo.Instance.WinPropsLocation;
					  sfPropsLocation = WinConfigInfo.Instance.SfPropsLocation;
					}

					PreparePropsLocations(winPropsLocation, sfPropsLocation);
					_winProperties = WinConfigInfo.GetProperties(_winPropsLocation);
					InitLogActionHandler();

					SetupSecurityFramework();*/

					_winProperties = info;
					InitLogActionHandler();

					if (0 == _winProperties.ProcessRequestTimeout)
					{
						_winProperties.ProcessRequestTimeout = 30000;
					}
					if (0 == _winProperties.ProcessResponseTimeout)
					{
						_winProperties.ProcessResponseTimeout = 30000;
					}
					LoadProcessors();

					InitPerformanceMonitor();
					LoggingHelper.LogDebug("SF.WebInspector", "State=[InitializeDone]");

					_hasSfStarted = true;
				}
				catch (Exception x)
				{
					LoggingHelper.Log(x);
					throw;
				}
			}
		}

		//private void PreparePropsLocations(string winPropsLocation, string sfPropsLocation)
		//{
		//  _winPropsLocation = winPropsLocation.Trim();
		//  if (string.IsNullOrEmpty(_winPropsLocation))
		//    throw new ArgumentNullException("winPropsLocation");

		//  _sfPropsLocation = sfPropsLocation.Trim();
		//  if (string.IsNullOrEmpty(_sfPropsLocation))
		//    throw new ArgumentNullException("sfPropsLocation");

		//  _winPropsLocation = PreparePropsLocation(_winPropsLocation);
		//  _sfPropsLocation = PreparePropsLocation(_sfPropsLocation);
		//}

		//private string PreparePropsLocation(string name)
		//{
		//  string result = name;
		//  if (result[0] == '%')
		//  {
		//    //expand the env var
		//    result = Environment.ExpandEnvironmentVariables(result);
		//  }
		//  else if (result[1] == ':')
		//  {
		//    //do nothing; we have an absolute path
		//  }
		//  else if ((result[0] == '\\') || (result[0] == '/'))
		//  {
		//    string baseDir = GetCurrentAssemblyPath();
		//    result = MakeFullPath(baseDir, name);
		//  }
		//  else
		//  {
		//    //get base path from the registry:
		//    RegistryKey rk = Registry.LocalMachine;
		//    rk = rk.OpenSubKey(@"SOFTWARE\MetraTech\MetraNet");
		//    string regv = (string)rk.GetValue("InstallDir");

		//    if (!string.IsNullOrEmpty(regv))
		//    {
		//      result = MakeFullPath(regv, name);
		//    }
		//    else
		//    {
		//      //fall back: use it as a relative path
		//      string baseDir = GetCurrentAssemblyPath();
		//      result = MakeFullPath(baseDir, name);
		//    }
		//  }

		//  if (!File.Exists(result))
		//  {
		//    throw new ArgumentException("WebInspector.PreparePropsLocation(" + name + "): missing file");
		//  }

		//  return result;
		//}

		//private string GetCurrentAssemblyPath()
		//{
		//  string filePath = new Uri(Assembly.GetExecutingAssembly().CodeBase).LocalPath;
		//  return Path.GetDirectoryName(filePath);
		//}

		//private string MakeFullPath(string baseDir, string name)
		//{
		//  StringBuilder result = new StringBuilder("");

		//  if (!string.IsNullOrEmpty(baseDir))
		//    result.Append(baseDir);

		//  if ((result.Length > 0) && !string.IsNullOrEmpty(name) && ((baseDir[baseDir.Length - 1] != '\\') || (baseDir[baseDir.Length - 1] != '/')))
		//    result.Append('\\');

		//  if (!string.IsNullOrEmpty(name))
		//    result.Append(name);

		//  return result.ToString();
		//}

		//private void SetupSecurityFramework()
		//{
		//  //SECENG:
		//  /*if (_hasSfStarted)
		//    return;

		//  try
		//  {
		//    SecurityKernel.Initialize(_sfPropsLocation);
		//    SecurityKernel.SecurityMonitor.ControlApi.AddPolicyActionHandler("SF_WIN", SecurityPolicyActionType.All, this);
		//    SecurityKernel.Start();
		//    _hasSfStarted = true;
		//  }
		//  catch (SubsystemAccessException x)
		//  {
		//    Debug.WriteLine(x.Message);
		//    throw;
		//  }
		//  catch (SubsystemApiAccessException x)
		//  {
		//    Debug.WriteLine(x.Message);
		//    throw;
		//  }
		//  catch (Exception x)
		//  {
		//    Debug.WriteLine(x.Message);
		//    throw;
		//  }*/
		//}

		private void ShutdownSecurityFramework()
		{
			if (!_hasSfStarted)
				return;

			try
			{
				SecurityKernel.Stop();
				SecurityKernel.Shutdown();
				_hasSfStarted = false;
			}
			catch (Exception x)
			{
                LoggingHelper.Log(x);
			}
		}

		private void LoadProcessors()
		{
			if (null == _winProperties)
				return;

			if (null == _winProperties.Processors)
				return;

			foreach (WinProcessorInfo pi in _winProperties.Processors)
			{
				if (string.IsNullOrEmpty(pi.Id) || (null == pi.Qualifier) || string.IsNullOrEmpty(pi.Qualifier.AppPath) || _processorsById.ContainsKey(pi.Id))
					continue;

				WinProcessor processor = WinProcessor.CreateProcessor(pi);
				if (null == processor)
					continue;

				LoggingHelper.LogDebug("SF.WI.LoadProcessors()", string.Format("SF.WI.LoadProcessors(): Created processor = {0}", pi.Id));

				WinProcessorQualifier qualifier = WinProcessorQualifier.CreateQualifier(pi.Qualifier, processor);

				if (null == qualifier)
				{
					processor = null;
					continue;
				}

				if (_qualifiers.ContainsKey(pi.Qualifier.AppPath))
				{
					List<WinProcessorQualifier> plist = null;
					if (_qualifiers.TryGetValue(pi.Qualifier.AppPath, out plist) && (null != plist))
					{
						plist.Add(qualifier);
					}
					else
					{
						qualifier = null;
						processor = null;
						continue;
					}
				}
				else
				{
					List<WinProcessorQualifier> plist = new List<WinProcessorQualifier>();
					plist.Add(qualifier);
					_qualifiers[pi.Qualifier.AppPath] = plist;
				}

				_processors.Add(processor);
				_processorsById[pi.Id] = processor;
			}
		}

		private void InitPerformanceMonitor()
		{
			if ((null == _winProperties) || (!_winProperties.DoMonitorPerformance))
			{
				_perfMon = null;
			}
			else
			{
				_perfMon = new WinPerformanceMonitor();
				_perfMon.CreateCounters();
			}
		}

		private void InitLogActionHandler()
		{
			//SECENG:
			if ((null == _winProperties) || (!_winProperties.DoActionLog) || (string.IsNullOrEmpty(_winProperties.ActionLogTarget)))
			{
				_laHandler = null;
			}
			else
			{
				if (_winProperties.DoSysLog)
				{
					LoggingHelper.LogDebug("SF.WebInspector", string.Format("SF.WebInspector: Version=[{0}]", _inspectorVersion));
				}

				_laHandler = new WinLogActionHandler(_winProperties);
				_laHandler.Start();
			}
		}

		//SECENG:
		//public void Handle(ISecurityPolicyAction policyAction, ISecurityEvent securityEvent)
		public void Handle(PolicyAction policyAction, ISecurityEvent securityEvent)
		{
            //ISecurityPolicyActionHandler.Handle() implementation
			LoggingHelper.LogDebug("WebInspector.Handle", "handle policy action");
		}

		private string HandleNonSessionProcessorActionsSimple(
			WinProcessor processor,
			DateTime now,
			string sourceIp,
			string userAgent,
			string referer,
			string url,
			string rawUrl)
		{
			string sessionActions = string.Empty;
			bool isDone = false;

			if ((null != _winProperties) && _winProperties.DoGlobalRuleActionsDisable)
			{
				isDone = true;
			}
			else
			{
				foreach (WinAction action in processor.RuleActions)
				{
					switch (action.ActionType)
					{
						case WinActionType.BlockOperation:
							sessionActions += WinActionType.BlockOperation.ToString() + " ";
							isDone = true;
							break;
						case WinActionType.BlacklistSource:
							DoBlacklistSource(action, null, null, sourceIp, now, null);
							isDone = true;
							break;
						case WinActionType.RedirectOperation:
							sessionActions += WinActionType.RedirectOperation.ToString();
							object newLocationObj = action.GetActionParam("NewLocation");
							if (newLocationObj != null)
							{
								string newLocation = (string)newLocationObj;
								sessionActions += "=" + newLocation;
							}
							sessionActions += " ";
							isDone = true;
							break;
						case WinActionType.RewriteUrl:
							sessionActions += WinActionType.RedirectOperation.ToString();
							object fullUrlRewriteObj = action.GetActionParam("FullUrlRewrite");
							if (fullUrlRewriteObj != null)
							{
								object newUrlObj = action.GetActionParam("NewUrl");
								if (newUrlObj != null)
								{
									string newUrl = (string)newUrlObj;
									sessionActions += "=" + newUrl;
								}
							}
							sessionActions += " ";
							isDone = true;
							break;
						case WinActionType.Log:
							DoLogSimple(action, processor, sourceIp, userAgent, referer, url, rawUrl, now);
							break;
						default:
							break;
					}
				}
			}

			if (isDone)
			{
				processor.ClearActionableResults();
			}

			return sessionActions;
		}

		private bool HandleProcessorActions(HttpApplication app, HttpContext context, HttpRequest request, WinProcessor processor, string sourceIp, DateTime now, WinRequestContext wrc)
		{
			bool isDone = false;

			if ((null != _winProperties) && _winProperties.DoGlobalRuleActionsDisable)
			{
				isDone = true;
			}
			else
			{
				foreach (WinAction action in processor.RuleActions)
				{
					switch (action.ActionType)
					{
						case WinActionType.BlockOperation:
							DoBlockOperation(action, app, context, wrc);
							if (null != wrc)
							{
								wrc.doBlock = true;
							}
							isDone = true;
							break;
						case WinActionType.BlacklistSource:
							DoBlacklistSource(action, app, context, sourceIp, now, wrc);
							if (null != wrc)
							{
								wrc.doBlacklist = true;
							}
							isDone = true;
							break;
						case WinActionType.RedirectOperation:
							DoRedirectOperation(action, context);
							if (null != wrc)
							{
								wrc.doRedirect = true;
							}
							isDone = true;
							break;
						case WinActionType.RewriteUrl:
							DoRewriteUrl(action, context, request);
							if (null != wrc)
							{
								wrc.doRedirect = true;
							}
							isDone = true;
							break;
						case WinActionType.Log:
							DoLog(action, app, context, request, processor, sourceIp, now);
							if (null != wrc)
							{
								wrc.doLog = true;
							}
							break;
						default:
							break;
					}
				}
			}

			if (isDone)
			{
				processor.ClearActionableResults();
			}

			return isDone;
		}

		private void DoBlockOperation(WinAction action, HttpApplication app, HttpContext context, WinRequestContext wrc)
		{
			if (!wrc.doBlacklist)
				BuildResponse(app, context);
		}

		private void DoBlacklistSource(WinAction action, HttpApplication app, HttpContext context, string sourceIp, DateTime now, WinRequestContext wrc)
		{
			DateTime releaseTime = now.AddYears(1000);
			object isTemp = action.GetActionParam("IsTemp");
			if (isTemp != null)
			{
				object timeToBlockObj = action.GetActionParam("Time");
				if (timeToBlockObj != null)
				{
					int timeToBlock = (int)timeToBlockObj;
					releaseTime = now.AddMinutes((double)timeToBlock);
				}
			}

			AddSourceToBlacklist(sourceIp, releaseTime);

			if ((null != wrc) && !wrc.doBlock)
				BuildResponse(app, context);
		}

		private void DoRedirectOperation(WinAction action, HttpContext context)
		{
			object newLocationObj = action.GetActionParam("NewLocation");
			if (newLocationObj != null)
			{
				string newLocation = (string)newLocationObj;
				context.Response.Redirect(newLocation);
			}
		}

		private void DoRewriteUrl(WinAction action, HttpContext context, HttpRequest request)
		{
			object fullUrlRewriteObj = action.GetActionParam("FullUrlRewrite");
			if (fullUrlRewriteObj != null)
			{
				object newUrlObj = action.GetActionParam("NewUrl");
				if (newUrlObj != null)
				{
					string newUrl = (string)newUrlObj;
					context.RewritePath(newUrl, false);
				}
			}
			else
			{
				object pathObj = action.GetActionParam("Path");
				object pathInfoObj = action.GetActionParam("PathInfo");
				object queryStringObj = action.GetActionParam("QueryString");
				string path = request.FilePath;
				string pathInfo = request.PathInfo;
				string queryString = request.Url.Query;

				if (pathObj != null)
				{
					path = (string)pathObj;
				}
				if (pathInfoObj != null)
				{
					pathInfo = (string)pathInfoObj;
				}
				if (queryStringObj != null)
				{
					queryString = (string)queryStringObj;
				}

				context.RewritePath(path, pathInfo, queryString, false);
			}
		}

		private void DoLog(WinAction action, HttpApplication app, HttpContext context, HttpRequest request, WinProcessor processor, string sourceIp, DateTime now)
		{
			if ((null != _laHandler) && (null != processor) && (null != request))
			{
				_laHandler.Process(request, processor, sourceIp);
			}
		}

		private void DoLogSimple(WinAction action,
														WinProcessor processor,
														string sourceIp,
														string userAgent,
														string referer,
														string url,
														string rawUrl,
														DateTime now)
		{
			if ((null != _laHandler) && (null != processor))
			{
				_laHandler.ProcessSimple(processor, sourceIp, userAgent, referer, url);
			}
		}

		private void BuildResponse(HttpApplication app, HttpContext context)
		{
			context.Response.StatusCode = 403;
			app.Response.Write("<html><body><h1>You are not allowed to perform this operation.</h1></body></html>");
			context.ApplicationInstance.CompleteRequest();
		}

		private void AddSourceToBlacklist(string ip, DateTime releaseTime)
		{
			if (string.IsNullOrEmpty(ip))
				return;

			_blacklistedSources[ip] = releaseTime;
		}

		private void RemoveSourceFromBlacklist(string ip)
		{
			if (string.IsNullOrEmpty(ip))
				return;

			if (_blacklistedSources.ContainsKey(ip))
			{
				_blacklistedSources.Remove(ip);
			}
		}

		private void DoRequestPostProcessing(WinRequestContext context)
		{
			if ((null != context) && (null != _perfMon))
			{
				long end = _perfMon.CurrentTickCount();
				_perfMon.UpdateCommonRequestStats(end - context.startTicks);

				if (context.doAction)
				{
					if (context.doLog)
					{
						_perfMon.UpdateLogCount();
					}
					else if (context.doBlock)
					{
						_perfMon.UpdateBlockCount();
					}
					else if (context.doBlacklist)
					{
						_perfMon.UpdateBlacklistCount();
					}
					else if (context.doRedirect)
					{
						_perfMon.UpdateRedirectCount();
					}
					else if (context.doRewriteUrl)
					{
						_perfMon.UpdateRewriteUrlCount();
					}
				}
				else if (context.doBlacklistBlock)
				{
					_perfMon.UpdateBlacklistBlockCount();
				}
			}
		}

		private WinRequestContext CreateWafRequestContext()
		{
			WinRequestContext wrc = new WinRequestContext();
			if (null != _perfMon)
			{
				wrc.startTicks = _perfMon.CurrentTickCount();
			}
			return wrc;
		}

		public void ProcessRequest(HttpApplication app)
		{
			if (null == app)
				return;

			HttpContext context = app.Context;
			HttpRequest request = context.Request;
			HttpResponse response = context.Response;

			string msg = string.Format("SF.WI.ProcessRequest(): => {0} [{1}]",
						request.Path, (null == request ? "unknown" : request.IsAuthenticated ? "Is Auth'ed" : "Not Auth'ed"));
			LoggingHelper.LogDebug("SF.WI.ProcessRequest()", msg);

			if (null != request)
			{
				if (null == _winProperties)
				{
					ProcessRequest(app, context, request, response);
				}
				else
				{
					if (!_winProperties.ProcessAuthenticatedOnly)
					{
						ProcessRequest(app, context, request, response);
					}
					else
					{
						if (request.IsAuthenticated)
						{
							ProcessRequest(app, context, request, response);
						}
					}
				}
			}
		}

		private void DoProcessRequest(HttpApplication app, HttpContext context, HttpRequest request, HttpResponse response)
		{
			try
			{
				DateTime now = DateTime.Now;

				// Create HttpApplication and HttpContext objects to access
				// request and response properties.

				WinRequestContext wrc = CreateWafRequestContext();

				string sourceIp = request.UserHostAddress;
				if (_blacklistedSources.ContainsKey(sourceIp))
				{
					LoggingHelper.LogWarning("SF.WI.DoProcessRequest()", string.Format("SF.WI.DoProcessRequest(): blacklisted ip => {0}", sourceIp));

					DateTime releaseTime = now;
					if (_blacklistedSources.TryGetValue(sourceIp, out releaseTime))
					{
                        //releaseTime == DateTime.MinValue when we have a permanent block
						if ((releaseTime == DateTime.MinValue) || (releaseTime > now))
						{
							LoggingHelper.LogWarning("SF.WI.DoProcessRequest()", string.Format("SF.WI.DoProcessRequest(): blacklist response => {0}", sourceIp));

							BuildResponse(app, context);
							wrc.doBlacklistBlock = true;
							DoRequestPostProcessing(wrc);
							return;
						}
						else
						{
                            if (releaseTime != DateTime.MinValue)
							{
								RemoveSourceFromBlacklist(sourceIp);
								LoggingHelper.LogWarning("SF.WI.DoProcessRequest()", string.Format("SF.WI.DoProcessRequest(): release ip => {0}", sourceIp));
							}
						}
					}
				}

				/*
					Input: http://localhost:96/Cambia3/Temp/Test.aspx?q=item#fragment
                 
				 Request.ApplicationPath: /Cambia3
				 Request.CurrentExecutionFilePath: /Cambia3/Temp/Test.aspx
				 Request.FilePath: /Cambia3/Temp/Test.aspx
				 Request.Path: /Cambia3/Temp/Test.aspx
				 Request.PathInfo:
				 Request.PhysicalApplicationPath: D:\Inetpub\wwwroot\CambiaWeb\Cambia3\
				 Request.QueryString: /Cambia3/Temp/Test.aspx?query=arg
				 Request.Url.AbsolutePath: /Cambia3/Temp/Test.aspx
				 Request.Url.AbsoluteUri: http://localhost:96/Cambia3/Temp/Test.aspx?query=arg
				 Request.Url.Fragment:
				 Request.Url.Host: localhost
				 Request.Url.Authority: localhost:96
				 Request.Url.LocalPath: /Cambia3/Temp/Test.aspx
				 Request.Url.PathAndQuery: /Cambia3/Temp/Test.aspx?query=arg
				 Request.Url.Port: 96
				 Request.Url.Query: ?query=arg
				 Request.Url.Scheme: http
				 Request.Url.Segments: /
																Cambia3/
																Temp/
																Test.aspx
                 
				 Input: http://localhost:96/Cambia3/Temp/Test.aspx/path/info?q=item#fragment
                 
				 Request.ApplicationPath: /Cambia3
				 Request.CurrentExecutionFilePath:	/Cambia3/Temp/Test.aspx
				 Request.FilePath:	/Cambia3/Temp/Test.aspx
				 Request.Path:	/Cambia3/Temp/Test.aspx/path/info
				 Request.PathInfo:	/path/info
				 Request.PhysicalApplicationPath:	D:\Inetpub\wwwroot\CambiaWeb\Cambia3\
				 Request.QueryString:	/Cambia3/Temp/Test.aspx/path/info?query=arg
				 Request.Url.AbsolutePath:	/Cambia3/Temp/Test.aspx/path/info
				 Request.Url.AbsoluteUri:	http://localhost:96/Cambia3/Temp/Test.aspx/path/info?query=arg
				 Request.Url.Fragment:	
				 Request.Url.Host:	localhost
				 Request.Url.LocalPath:	/Cambia3/Temp/Test.aspx/path/info
				 Request.Url.PathAndQuery:	/Cambia3/Temp/Test.aspx/path/info?query=arg
				 Request.Url.Port:	96
				 Request.Url.Query:	?query=arg
				 Request.Url.Scheme:	http
				 Request.Url.Segments:	/
																Cambia3/
																Temp/
																Test.aspx/
																path/
																info
				*/

				string appPath = request.ApplicationPath.ToLower();
				string resourceName = request.FilePath.ToLower();
				string resourceExt = VirtualPathUtility.GetExtension(resourceName).ToLower();
				string pageKey = appPath + resourceName + resourceExt;

				LoggingHelper.LogDebug(
					"SF.WI.DoProcessRequest()",
					string.Format(
						"SF.WI.DoProcessRequest(): Page Key => {0} | {1} | {2} [{3}]",
						appPath,
						resourceName,
						resourceExt,
						pageKey));

				//if (_processorsPageExcludeCache.Contains(pageKey))
				//{
				//    LoggingHelper.LogWarning("SF.WI.DoProcessRequest()", string.Format("SF.WI.DoProcessRequest(): Exclude page cache => {0}", pageKey));

				//    DoRequestPostProcessing(wrc);
				//    return;
				//}

				if (_processorsPageCache.ContainsKey(pageKey))
				{
					LoggingHelper.LogDebug("SF.WI.DoProcessRequest()", string.Format("SF.WI.DoProcessRequest(): Page cache => {0}", pageKey));

					WinProcessor processor = null;
					if (!_processorsPageCache.TryGetValue(pageKey, out processor))
					{
						DoRequestPostProcessing(wrc);
						return;
					}
					else if (DoProcessRequestRules(app, context, request, now, wrc, sourceIp, processor, resourceName))
						return;
				}
				else
				{
					if (!_qualifiers.ContainsKey(appPath))
					{
						_processorsPageExcludeCache.Add(pageKey);
						DoRequestPostProcessing(wrc);
						return;
					}

					List<WinProcessorQualifier> qlist = null;
					if (!_qualifiers.TryGetValue(appPath, out qlist))
					{
						DoRequestPostProcessing(wrc);
						return;
					}

					if (null == qlist)
					{
						DoRequestPostProcessing(wrc);
						return;
					}

					bool foundMatch = false;
					foreach (WinProcessorQualifier qualifier in qlist)
					{
						if (null == qualifier)
							continue;
						LoggingHelper.LogDebug(
							"SF.WI.DoProcessRequest()",
							string.Format("SF.WI.DoProcessRequest(): Matching => {0}|{1}|{2}", appPath, resourceExt, resourceName));

						if (!qualifier.IsMatch(appPath, resourceExt, resourceName))
							continue;

						WinProcessor processor = qualifier.Processor;
						if (null == processor)
							continue;

						foundMatch = true;
						_processorsPageCache[pageKey] = processor;

						if (DoProcessRequestRules(app, context, request, now, wrc, sourceIp, processor, resourceName))
							return;

						break;
					}

					if (!foundMatch)
					{
						_processorsPageExcludeCache.Add(pageKey);
					}
				}

				DoRequestPostProcessing(wrc);

			}
			catch (HttpRequestValidationException x)
			{
				LoggingHelper.LogWarning("SF.WI.DoProcessRequest() Validation", x.Message);

				WinRequestContext wrc = CreateWafRequestContext();
				wrc.doAction = true;
				wrc.doBlock = true;
				DoRequestPostProcessing(wrc);
			}
			catch (Exception x)
			{
				LoggingHelper.Log(x);
			}
		}

		public void ProcessRequest(HttpApplication app, HttpContext context, HttpRequest request, HttpResponse response)
		{
			if (!_hasSfStarted)
				return;

			if ((null != _winProperties) && _winProperties.DoGlobalDisable)
				return;

			long timeout = (null == _winProperties) ? 45000 : _winProperties.ProcessRequestTimeout;

			if (timeout < 0)
			{
				DoProcessRequest(app, context, request, response);
			}
			else
			{
				LoggingHelper.LogDebug("SF.WI.ProcessRequest()", string.Format("SF.WI.ProcessRequest(): time out => {0}", timeout));
				Stopwatch watch = new Stopwatch();
				watch.Start();
				try
				{
					DoProcessRequest(app, context, request, response);
				}
				catch (Exception exc)
				{
					LoggingHelper.Log(exc);
				}
				watch.Stop();
			}
		}

		public void ProcessError(HttpApplication app)
		{
			if (null == app)
				return;

			Exception exception = app.Server.GetLastError();
			Exception baseException = exception.GetBaseException();
			HttpResponse response = app.Context.Response;

			ProcessError(app, response, exception, baseException);
		}

		public void ProcessError(HttpApplication app, HttpResponse response, Exception exception, Exception baseException)
		{
			if (!_hasSfStarted)
				return;

			try
			{
				if ((null != _winProperties) && _winProperties.HideAspNetExceptions)
				{
					response.Clear();
					app.Server.ClearError();

					response.StatusCode = 503;
					response.Write("<html><body><h1>Application execution error.</h1></body></html>");
					app.Context.ApplicationInstance.CompleteRequest();
				}
				else
				{
					response.Write("<hr><h1><font color=red>" +
						//SECENG:	
						//"SecurityFramework.WebAppFirewall: Error Info: " + SecurityKernel.Encoder.Api.Encode("Html.Default", exception.Message) +
								  "SecurityFramework.WebAppFirewall: Error Info: " +
					  SecurityKernel.
									Encoder.
									Api.
									ExecuteDefaultByCategory(
										EncoderEngineCategory.Html.ToString(),
										new ApiInput(exception.Message)).
									ToString() +
								  "</font></h1>");
				}
			}
			catch { }
		}

		public void ProcessResponse(HttpApplication app)
		{
			if (null == app)
				return;

			HttpRequest request = app.Context.Request;
			HttpResponse response = app.Context.Response;

			if ((null != request) && request.IsAuthenticated)
			{
				ProcessResponse(app, request, response);
			}
		}

		public void ProcessResponse(HttpApplication app, HttpRequest request, HttpResponse response)
		{
			if (!_hasSfStarted)
				return;

			if ((null != _winProperties) && (_winProperties.DoGlobalDisable || _winProperties.DoGlobalResponseActionsDisable))
				return;
		}

		public string LookupWebProcessorId(string appPath, string resourceName, string resourceExt)
		{
			string pid = string.Empty;

			if (!_hasSfStarted)
				return pid;

			if ((null != _winProperties) && _winProperties.DoGlobalDisable)
				return pid;

			if (string.IsNullOrEmpty(appPath) || string.IsNullOrEmpty(resourceName) || string.IsNullOrEmpty(resourceExt))
				throw new SecurityFrameworkException("LookupWebProcessorId: bad parameter");

			appPath = appPath.ToLower();
			resourceName = resourceName.ToLower();
			resourceExt = resourceExt.ToLower();

			string pageKey = appPath + resourceName + resourceExt;

			if (_processorsPageExcludeCache.Contains(pageKey))
			{
				return pid;
			}

			if (_processorsPageCache.ContainsKey(pageKey))
			{
				WinProcessor proc = null;
				if (!_processorsPageCache.TryGetValue(pageKey, out proc))
				{
					return pid;
				}
				else
				{
					if (null != proc)
					{
						return proc.ProcessorId;
					}
					else
					{
						return pid;
					}
				}
			}
			else
			{
				if (!_qualifiers.ContainsKey(appPath))
				{
					return pid;
				}

				List<WinProcessorQualifier> qlist = null;
				if (!_qualifiers.TryGetValue(appPath, out qlist))
				{
					return pid;
				}

				if (null == qlist)
				{
					return pid;
				}

				bool foundMatch = false;
				foreach (WinProcessorQualifier qualifier in qlist)
				{
					if (null == qualifier)
						continue;

					if (!qualifier.IsMatch(appPath, resourceExt, resourceName))
						continue;

					WinProcessor processor = qualifier.Processor;
					if (null == processor)
						continue;

					foundMatch = true;
					_processorsPageCache[pageKey] = processor;
					pid = processor.ProcessorId;
					break;
				}

				if (!foundMatch)
				{
					_processorsPageExcludeCache.Add(pageKey);
				}
			}

			return pid;
		}

		public int IsWebRequestSourceBlocked(string pid, string sourceIp)
		{
			int isBlocked = 0;

			if (!_hasSfStarted)
				return isBlocked;

			if ((null != _winProperties) && _winProperties.DoGlobalDisable)
				return isBlocked;

			if (string.IsNullOrEmpty(sourceIp))
				throw new Exception("IsWebRequestSourceBlocked:BadSourceIp");

			if (string.IsNullOrEmpty(pid) || !_processorsById.ContainsKey(pid))
				throw new Exception("IsWebRequestSourceBlocked:UnknownWebProcessorId");

			WinProcessor proc = null;
			if (!_processorsById.TryGetValue(pid, out proc))
				throw new Exception("IsWebRequestSourceBlocked:WebProcessorIdError");

			if (_blacklistedSources.ContainsKey(sourceIp))
			{
				DateTime now = DateTime.Now;
				DateTime releaseTime = now;
				if (_blacklistedSources.TryGetValue(sourceIp, out releaseTime))
				{
					//releaseTime == null when we have a permanent block
					if ((null == releaseTime) || (releaseTime > now))
					{
						isBlocked = 1;
					}
					else
					{
						if (null != releaseTime)
						{
							RemoveSourceFromBlacklist(sourceIp);
						}
					}
				}
			}

			return isBlocked;
		}

		public string ProcessWebRequestProps(string pid, int bodySize, string remoteAddr, string userAgent, string referer, int paramCount, ref string[] paramNames, ref string url, ref string rawUrl)
		{
			string actions = string.Empty;

			if (!_hasSfStarted)
				return actions;

			if ((null != _winProperties) && _winProperties.DoGlobalDisable)
				return actions;

			if (string.IsNullOrEmpty(pid) || !_processorsById.ContainsKey(pid))
				throw new SecurityFrameworkException("ProcessWebRequestProps:UnknownWebProcessorId");

			WinProcessor proc = null;
			if (!_processorsById.TryGetValue(pid, out proc))
				throw new SecurityFrameworkException("ProcessWebRequestProps:WebProcessorIdError");

			if ((null != _winProperties) && !_winProperties.DoGlobalRequestRulesDisable)
			{
				DateTime now = DateTime.Now;

				if (!proc.ProcessRequestSimple(url, rawUrl, remoteAddr, userAgent, referer, paramCount, ref paramNames, bodySize))
				{
					actions = CheckForActions(url, rawUrl, remoteAddr, userAgent, referer, actions, proc, now);
				}
			}

			return actions;
		}

		public string ProcessWebRequestParam(string pid, string paramType, string paramName, ref string paramValue, ref string url, ref string rawUrl, string remoteAddr, string userAgent, string referer)
		{
			string actions = string.Empty;

			if (!_hasSfStarted)
				return actions;

			if ((null != _winProperties) && _winProperties.DoGlobalDisable)
				return actions;

			if (string.IsNullOrEmpty(paramType))
				throw new SecurityFrameworkException("ProcessWebRequestParam:BadParamType");

			if (string.IsNullOrEmpty(pid) || !_processorsById.ContainsKey(pid))
				throw new SecurityFrameworkException("ProcessWebRequestParam:UnknownWebProcessorId");

			WinProcessor proc = null;
			if (!_processorsById.TryGetValue(pid, out proc))
				throw new SecurityFrameworkException("ProcessWebRequestParam:WebProcessorIdError");

			if ((null != _winProperties) && !_winProperties.DoGlobalParamRulesDisable)
			{
				DateTime now = DateTime.Now;
				string normParamName = string.Empty;

				//'url' is normally just the resource name for ASP calls, 
				//but in case it's not we need to get rid of the query string part
				string resourceName = string.Empty;
				if (!string.IsNullOrEmpty(url))
				{
					int pos = url.IndexOf('?');
					if (-1 == pos)
					{
						resourceName = url;
					}
					else
					{
						resourceName = url.Substring(0, pos).ToLower();
					}
				}

				if (null != paramName)
				{
					normParamName = paramName.ToLower();
				}

				WinRequestContext wrc = CreateWafRequestContext();

				if (!proc.CheckFirstResourceRulesForParam(wrc, resourceName, normParamName, paramValue, url, rawUrl))
				{
					actions = CheckForActions(url, rawUrl, remoteAddr, userAgent, referer, actions, proc, now);

					return actions;
				}

				switch (paramType.Trim().ToLower())
				{
					case "qs":
						if (!proc.ProcessQueryStringParam(wrc, url, rawUrl, normParamName, paramValue))
						{
							actions = CheckForActions(url, rawUrl, remoteAddr, userAgent, referer, actions, proc, now);
						}
						break;
					case "form":
						if (!proc.ProcessFormParam(wrc, url, rawUrl, normParamName, paramValue))
						{
							actions = CheckForActions(url, rawUrl, remoteAddr, userAgent, referer, actions, proc, now);
						}
						break;
					case "cookie":
						if (!proc.ProcessCookie(url, rawUrl, normParamName, paramValue))
						{
							actions = CheckForActions(url, rawUrl, remoteAddr, userAgent, referer, actions, proc, now);
						}
						break;
					default:
						//log it
						break;
				}

				if (!string.IsNullOrEmpty(actions))
				{
					return actions;
				}

				if (!proc.CheckLastResourceRulesForParam(wrc, resourceName, normParamName, paramValue, url, rawUrl))
				{
					actions = CheckForActions(url, rawUrl, remoteAddr, userAgent, referer, actions, proc, now);
				}
			}

			return actions;
		}

		public void Shutdown()
		{
			if (!_hasSfStarted)
				return;

			ShutdownSecurityFramework();
		}

		/// <summary>
		/// Processes the rules configured for an HTTP request.
		/// </summary>
		/// <returns>true if something malicious was found and false otherwise.</returns>
		private bool DoProcessRequestRules(
		  HttpApplication app,
		  HttpContext context,
		  HttpRequest request,
		  DateTime now,
		  WinRequestContext wrc,
		  string sourceIp,
		  WinProcessor processor,
		  string resourceName)
		{
			string normalizedUrl = request.Url.ToString();
			string rawUrl = request.RawUrl;

			NameValueCollection headers = null;
			NameValueCollection qsParams = null;
			NameValueCollection formParams = null;
			HttpCookieCollection cookies = null;

			try
			{
				qsParams = request.QueryString;
				formParams = request.Form;
				cookies = request.Cookies;
				headers = request.Headers;
			}
			catch (HttpRequestValidationException x)
			{
				LoggingHelper.LogWarning("SF.WI.DoProcessRequest()", x.Message);

				if (!((null != _winProperties) && _winProperties.IgnoreAspNetValidation))
					throw;
				else
				{
					if (null == qsParams)
						qsParams = request.QueryString;

					if (null == formParams)
						formParams = request.Form;

					if (null == cookies)
						cookies = request.Cookies;

					if (null == headers)
						headers = request.Headers;
				}
			}

			if ((null != _winProperties) && !_winProperties.DoGlobalRequestRulesDisable)
			{
				if (!processor.ProcessRequest(normalizedUrl, rawUrl, qsParams, formParams, cookies, headers, request.TotalBytes) &&
				  HandleProcessorAction(app, context, request, now, wrc, sourceIp, processor, "SF.WI.DoProcessRequest(): Request screen processor match"))
				{
					return true;
				}
			}

			if ((null != _winProperties) && !_winProperties.DoGlobalParamRulesDisable)
			{
				if (!processor.CheckFirstResourceRules(wrc, resourceName, qsParams, formParams, normalizedUrl, rawUrl) &&
				  HandleProcessorAction(app, context, request, now, wrc, sourceIp, processor, string.Empty))
				{
					return true;
				}

				if (!processor.ProcessQueryStringParams(wrc, qsParams, normalizedUrl, rawUrl) &&
				  HandleProcessorAction(app, context, request, now, wrc, sourceIp, processor, "SF.WI.DoProcessRequest(): Query param processor match"))
				{
					return true;
				}

				if (!processor.ProcessFormParams(wrc, formParams, normalizedUrl, rawUrl) &&
				  HandleProcessorAction(app, context, request, now, wrc, sourceIp, processor, "SF.WI.DoProcessRequest(): Form param processor match"))
				{
					return true;
				}

				if (!processor.ProcessCookies(wrc, request.Cookies) &&
				  HandleProcessorAction(app, context, request, now, wrc, sourceIp, processor, "SF.WI.DoProcessRequest(): Cookie processor match"))
				{
					return true;
				}

				if (!processor.CheckLastResourceRules(wrc, resourceName, qsParams, formParams, normalizedUrl, rawUrl) &&
				  HandleProcessorAction(app, context, request, now, wrc, sourceIp, processor, "SF.WI.DoProcessRequest(): First resource rule match"))
				{
					return true;
				}
			}

			return false;
		}

		/// <summary>
		/// Handle an action and returns if the action was actually handled.
		/// </summary>
		/// <returns>true if the action was handled and false otherwise.</returns>
		private bool HandleProcessorAction(
		  HttpApplication app,
		  HttpContext context,
		  HttpRequest request,
		  DateTime now,
		  WinRequestContext wrc,
		  string sourceIp,
		  WinProcessor processor,
		  string logMessage)
		{
			LoggingHelper.LogWarning("SF.WI.DoProcessRequest()", logMessage);

			wrc.doAction = true;
			if (HandleProcessorActions(app, context, request, processor, sourceIp, now, wrc))
			{
				DoRequestPostProcessing(wrc);
				return true;
			}
			else
			{
				return false;
			}
		}

		/// <summary>
		/// Defines actions for the given input data.
		/// </summary>
		/// <returns>A name of the action to be performed.</returns>
		private string CheckForActions(string url, string rawUrl, string remoteAddr, string userAgent, string referer, string actions, WinProcessor proc, DateTime now)
		{
			bool doAction = true;
			if ((null != _winProperties) && _winProperties.DoGlobalRuleActionsDisable)
			{
				doAction = false;
			}

			if (doAction)
			{
				//Do simple HandleNonSessionProcessorActions
				//then return the list of session actions to execute
				actions = HandleNonSessionProcessorActionsSimple(proc, now, remoteAddr, userAgent, referer, url, rawUrl);
				//DoRequestPostProcessing(wrc);
			}
			return actions;
		}
	}
}
