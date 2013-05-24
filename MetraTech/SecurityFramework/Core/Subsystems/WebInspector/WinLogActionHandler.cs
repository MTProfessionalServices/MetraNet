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
//using NLog;
//using NLog.Targets;
//using NLog.Targets.Wrappers;
using System.Web;
using Microsoft.Win32;
using MetraTech.SecurityFramework.Core.Common.Logging;


namespace MetraTech.SecurityFramework.WebInspector
{
	internal class WinLogActionHandler
	{
		//Logger _logger = null;

		internal WinLogActionHandler(WinPropertiesInfo info)
		{
			//SECENG
			/*string targetName = info.ActionLogTarget;
			switch (targetName.ToLower())
			{
					case "file":
							{
									CreateFileLogger(info.ActionLogPath, info.UseRelativeActionLogPath);
									break;
							}
					case "eventlog":
							break;
					default:
							return;
			}*/
		}

		private void CreateFileLogger(string logFilePath, bool useRelativeActionLogPath)
		{
			//SECENG:
			//LogDirector.AddLogChannel("WIN.ACTION", "Info", logFilePath, useRelativeActionLogPath);
		}

		internal void Start()
		{
			//SECENG:
			//_logger = LogDirector.GetLogger("WIN.ACTION.LOGGER");
		}

		internal void Process(HttpRequest request, WinProcessor processor, string sourceIp)
		{
			//SECENG:
			//if (null != _logger)
			//{
			StringBuilder sb = new StringBuilder();
			sb.Append("SRC: ");
			sb.Append(sourceIp);
			sb.Append(" URL: ");
			//Logging the whole URL if it's huge is going to result in a lot of wasted space
			//For now just log the path part
			//sb.Append(request.Url.ToString());
			sb.Append(request.Url.AbsolutePath);
			sb.Append(" PID: ");
			sb.Append(processor.ProcessorId);

			if (processor.HasActionableResults())
			{
				foreach (WinActionableResult result in processor.ActionableResults)
				{
					sb.Append(" RID: ");
					sb.Append(result.RuleId);
					sb.Append(" SS: ");
					sb.Append(result.Subsystem);
					sb.Append(" ENG: ");
					sb.Append(result.Engine);
					sb.Append(" FS: ");
					sb.Append(result.FieldSource);
					sb.Append(" FN: ");
					sb.Append(result.FieldName);
					sb.Append(" FV: ");
					sb.Append(result.FieldValue);
				}
			}
			LoggingHelper.LogInfo("WinLogActionHandler.Process", sb.ToString());
			//_logger.Info(sb.ToString());
			//}
		}

		internal void ProcessSimple(WinProcessor processor, string sourceIp, string userAgent, string referer, string url)
		{
			//SECENG:
			//if (null != _logger)
			//{
			StringBuilder sb = new StringBuilder();
			sb.Append("SRC: ");
			sb.Append(sourceIp);
			sb.Append("UA: ");
			sb.Append(userAgent);
			sb.Append("REF: ");
			sb.Append(referer);
			sb.Append(" URL: ");
			//Logging the whole URL if it's huge is going to result in a lot of wasted space
			sb.Append(url);
			sb.Append(" PID: ");
			sb.Append(processor.ProcessorId);

			if (processor.HasActionableResults())
			{
				foreach (WinActionableResult result in processor.ActionableResults)
				{
					sb.Append(" RID: ");
					sb.Append(result.RuleId);
					sb.Append(" SS: ");
					sb.Append(result.Subsystem);
					sb.Append(" ENG: ");
					sb.Append(result.Engine);
					sb.Append(" FS: ");
					sb.Append(result.FieldSource);
					sb.Append(" FN: ");
					sb.Append(result.FieldName);
					sb.Append(" FV: ");
					sb.Append(result.FieldValue);
				}
			}

			//_logger.Info(sb.ToString());
			//}
			LoggingHelper.LogWarning("WinLogActionHandler.ProcessSimle", sb.ToString());
		}
	}
}

