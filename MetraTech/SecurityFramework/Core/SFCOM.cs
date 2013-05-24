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
using System.Runtime.InteropServices;
using MetraTech.SecurityFramework.Core.Common.Logging;


namespace MetraTech.SecurityFramework
{
  [Guid("F0D26B3E-1205-4892-8A7C-26E353484231")]
  [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
  public interface ISFCOM
  {
    string ApiTest(string text, int num);
    string ForCss(ref string val);
    bool ForDetector(ref string val, ref string id);
    string ForHtml(ref string val);
    string ForHtmlAttr(ref string val);
    string ForJs(ref string val);
    string ForLdap(ref string val);
    string ForUrl(ref string val);
    bool ForUrlAccessController(ref string val);
    bool ForValidator(ref string val, ref string id);
    string ForVbs(ref string val);
    string ForXml(ref string val);
    string ForXmlAttr(ref string val);
    string FromToken(ref string id);
    void Initialize(string sfPropsLocation);
    string InspectMode();
    int IsWebRequestSourceBlocked(string pid, string remoteAddr);
    string LookupWebProcessorId(string appPath, string resourceName, string resourceExt);
    string NewTokenFor(ref string id);
    string ProcessWebRequestParam(string pid, string paramType, string paramName, ref string paramValue, ref string url, ref string rawUrl, string remoteAddr, string userAgent, string referer);
    string ProcessWebRequestProps(string pid, int bodySize, string remoteAddr, string userAgent, string referer, int paramCount, ref string[] paramNames, ref string url, ref string rawUrl);
    void ReleaseToken(ref string id);
    string ToToken(ref string value);
  }

	[Guid("9986FDE4-1363-4DD2-B1A1-030ADBECA297")]
	[ComVisible(true)]
	[ClassInterface(ClassInterfaceType.None)]
	public class SFCOM : ISFCOM
	{
		public SFCOM() { }

		public string ApiTest(string text, int num)
		{
			return "[SFCOM.ApiTest(" + text + "," + num.ToString() + ")=OK]";
		}

		public string InspectMode()
		{
			//"full",
			return "external";
		}

		public void Initialize(string sfPropsLocation)
		{
			try
			{
				SF.Initialize(sfPropsLocation);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("SecurityFramework.SFCOM.Initialize", x.Message); ;
			}
		}

		public string LookupWebProcessorId(string appPath, string resourceName, string resourceExt)
		{
			try
			{
				return SF.LookupWebProcessorId(appPath, resourceName, resourceExt);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public int IsWebRequestSourceBlocked(string pid, string remoteAddr)
		{
			try
			{
				return SF.IsWebRequestSourceBlocked(pid, remoteAddr);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return 0;
		}

		public string ProcessWebRequestProps(string pid, int bodySize, string remoteAddr, string userAgent, string referer, int paramCount, ref string[] paramNames, ref string url, ref string rawUrl)
		{
			try
			{
				return SF.ProcessWebRequestProps(pid, bodySize, remoteAddr, userAgent, referer, paramCount, ref paramNames, ref url, ref rawUrl);
			}
			catch (BadInputDataException x)
			{
				StringBuilder sb = new StringBuilder();
					sb.Append(x.Message);
					sb.Append("=>");
					sb.Append(bodySize.ToString());
					sb.Append("=>");
					sb.Append(paramCount.ToString());
					sb.Append("=>");
					sb.Append(url);

					LoggingHelper.LogError("TODO: enter tag", sb.ToString());

				return "SF_BAD_INPUT";
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);

				return "SF_EXEC_ERROR";
			}

			//return string.Empty;
		}

		public string ProcessWebRequestParam(string pid, string paramType, string paramName, ref string paramValue, ref string url, ref string rawUrl, string remoteAddr, string userAgent, string referer)
		{
			try
			{
				return SF.ProcessWebRequestParam(pid, paramType, paramName, ref paramValue, ref url, ref rawUrl, remoteAddr, userAgent, referer);
			}
			catch (BadInputDataException x)
			{
				StringBuilder sb = new StringBuilder();
					sb.Append(x.Message);
					sb.Append("=>");
					sb.Append(paramName);
					sb.Append("=>");
					sb.Append(paramValue);
					sb.Append("=>");
					sb.Append(url);

					LoggingHelper.LogError("TODO: enter tag", sb.ToString());

				return "SF_BAD_INPUT";
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);

				return "SF_EXEC_ERROR";
			}
		}

		public string ForUrl(ref string val)
		{
			try
			{
				return SF.ForUrl(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForHtml(ref string val)
		{
			try
			{
				return SF.ForHtml(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForHtmlAttr(ref string val)
		{
			try
			{
				return SF.ForHtmlAttr(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForJs(ref string val)
		{
			try
			{
				return SF.ForJs(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForVbs(ref string val)
		{
			try
			{
				return SF.ForVbs(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForCss(ref string val)
		{
			try
			{
				return SF.ForCss(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForXml(ref string val)
		{
			try
			{
				return SF.ForXml(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForXmlAttr(ref string val)
		{
			try
			{
				return SF.ForXmlAttr(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ForLdap(ref string val)
		{
			try
			{
				return SF.ForLdap(val);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string ToToken(ref string value)
		{
			try
			{
				return SF.ToToken(value);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string FromToken(ref string id)
		{
			try
			{
				return SF.FromToken(id);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public string NewTokenFor(ref string id)
		{
			try
			{
				return SF.NewTokenFor(id);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}

			return string.Empty;
		}

		public void ReleaseToken(ref string id)
		{
			try
			{
				SF.ReleaseToken(id);
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);
			}
		}

		/// <summary>
		/// COM-wrapper for default url-engine of AccessController subsystem.
		/// </summary>
		public bool ForUrlAccessController(ref string val)
		{
			bool result;
			try
			{
				SF.ForUrlAccessController(val);
				result = true;
			}
			catch (AccessControllerException)
			{
				result = false;
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("SFCOM.ForUrlAccessController", x.Message);

				result = false;
			}

			return result;
		}

		public bool ForValidator(ref string val, ref string id)
		{
			bool result;
			try
			{
				SF.ForValidator(val, id);
				result = true;
			}
			catch (ValidatorInputDataException)
			{
				result = false;
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("SFCOM.ForValidator", x.Message);

				result = false;
			}

			return result;
		}

		public bool ForDetector(ref string val, ref string id)
		{
			bool result;
			try
			{
				SF.ForDetector(val, id);
				result = true;
			}
			catch (DetectorInputDataException)
			{
				result = false;
			}
			catch (Exception x)
			{
				LoggingHelper.LogError("TODO: enter tag", x.Message);

				result = false;
			}

			return result;
		}
	}
}
