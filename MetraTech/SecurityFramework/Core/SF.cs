using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Common.Logging;
using System.Web;

namespace MetraTech.SecurityFramework
{
	public static class SF
	{
		#region Private Fields

		private static IEngine _urlEncoder;
		private static IEngine _jsEncoder;
		private static IEngine _vbEncoder;
		private static IEngine _cssEncoder;
		private static IEngine _htmlEncoder;
		private static IEngine _htmlAttrEncoder;
		private static IEngine _xmlEncoder;
		private static IEngine _xmlAttrEncoder;
		private static IEngine _ldapEncoder;

		#endregion

		#region Prorerties

		/// <summary>
		/// Internally gets a Web Inspector to process an HTTP request.
		/// </summary>
		private static WebInspectorEngineBase RequestWebInspector
		{
			get
			{
				WebInspectorEngineBase _webInspector =
				  SecurityKernel.WebInspectorSubsystem.Api.GetDefaultEngine(WebInspectorEngineCategory.WebInspectorRequest.ToString()) as WebInspectorEngineBase;

				if (_webInspector == null)
				{
					throw new WebInspectorException("Web Inspector for request processing not found");
				}

				return _webInspector;
			}
		}

        /// <summary>
        /// Gets a default URL encoder engine.
        /// </summary>
        private static IEngine UrlEncoder
        {
            get
            {
                if (_urlEncoder == null)
                {
                    _urlEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.Url.ToString());
                    if (_urlEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.UrlEncoder", "No Url Encoder");
                        throw new SubsystemAccessException("No Url Encoder");
                    }
                }

                return _urlEncoder;
            }
        }

        /// <summary>
        /// Gets a defualt JavaScript encoder engine.
        /// </summary>
        private static IEngine JsEncoder
        {
            get
            {
                if (_jsEncoder == null)
                {
                    _jsEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.JavaScript.ToString());
                    if (_jsEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.JsEncoder", "No JS Encoder");
                        throw new SubsystemAccessException("No JS Encoder");
                    }
                }

                return _jsEncoder;
            }
        }

        /// <summary>
        /// Gets a default VB script encoder engine.
        /// </summary>
        private static IEngine VbEncoder
        {
            get
            {
                if (_vbEncoder == null)
                {
                    _vbEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.VbScript.ToString());
                    if (_vbEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.VbEncoder", "No VB Encoder");
                        throw new SubsystemAccessException("No VB Encoder");
                    }
                }

                return _vbEncoder;
            }
        }

        /// <summary>
        /// Gets a default CSS encoder engine.
        /// </summary>
        private static IEngine CssEncoder
        {
            get
            {
                if (_cssEncoder == null)
                {
                    _cssEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.Css.ToString());
                    if (_cssEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.CssEncoder", "No CSS Encoder");
                        throw new SubsystemAccessException("No VB Encoder");
                    }
                }

                return _cssEncoder;
            }
        }

        /// <summary>
        /// Gets a default HTML encoder engine.
        /// </summary>
        private static IEngine HtmlEncoder
        {
            get
            {
                if (_htmlEncoder == null)
                {
                    _htmlEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.Html.ToString());
                    if (_htmlEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.HtmlEncoder", "No HTML Encoder");
                        throw new SubsystemAccessException("No HTML Encoder");
                    }
                }

                return _htmlEncoder;
            }
        }

        /// <summary>
        /// Gets a default HTML attribute encoder engine.
        /// </summary>
        private static IEngine HtmlAttrEncoder
        {
            get
            {
                if (_htmlAttrEncoder == null)
                {
                    _htmlAttrEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.HtmlAttribute.ToString());
                    if (_htmlAttrEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.HtmlAttrEncoder", "No HTML Attr Encoder");
                        throw new SubsystemAccessException("No HTML Attr Encoder");
                    }
                }

                return _htmlAttrEncoder;
            }
        }

        /// <summary>
        /// Gets a default XML encoder engine.
        /// </summary>
        private static IEngine XmlEncoder
        {
            get
            {
                if (_xmlEncoder == null)
                {
                    _xmlEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.Xml.ToString());
                    if (_xmlEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.XmlEncoder", "No XML Encoder");
                        throw new SubsystemAccessException("No XML Encoder");
                    }
                }

                return _xmlEncoder;
            }
        }

        /// <summary>
        /// Gets a default XML attribute encoder engine.
        /// </summary>
        private static IEngine XmlAttrEncoder
        {
            get
            {
                if (_xmlAttrEncoder == null)
                {
                    _xmlAttrEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.XmlAttribute.ToString());
                    if (_xmlAttrEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.XmlAttrEncoder", "No XML Attr Encoder");
                        throw new SubsystemAccessException("No XML Attr Encoder");
                    }
                }

                return _xmlAttrEncoder;
            }
        }

        /// <summary>
        /// Gets a default LDAP encoder engine.
        /// </summary>
        private static IEngine LdapEncoder
        {
            get
            {
                if (_ldapEncoder == null)
                {
                    _ldapEncoder = SecurityKernel.Encoder.Api.GetDefaultEngine(EncoderEngineCategory.Ldap.ToString());
                    if (_ldapEncoder == null)
                    {
                        LoggingHelper.LogInfo("SecurityFramework.SF.LdapEncoder", "No LDAP Encoder");
                        throw new SubsystemAccessException("No LDAP Encoder");
                    }
                }

                return _ldapEncoder;
            }
        }

		#endregion

		#region Private Methods

		#endregion

		public static void Initialize(string sfPropsLocation)
		{
			if (!SecurityKernel.IsInitialized())
			{
				SecurityKernel.Initialize(sfPropsLocation);
			}
		}

		public static void ProcessWebRequest(HttpApplication app)
		{
			ProcessWebRequest(app, null, null, null);
			//_webInspector.ProcessRequest(app);
		}

		public static void ProcessWebRequest(HttpApplication app, HttpContext context, HttpRequest request, HttpResponse response)
		{
			SecurityKernel.WebInspectorSubsystem.Api.ExecuteDefaultByCategory(
				WebInspectorEngineCategory.WebInspectorRequest.ToString(),
				new ApiInput(new WebInspectorRequestApiInput(app, context, request, response)));
			//_webInspector.ProcessRequest(app, context, request, response);
		}

		public static void ProcessWebResponse(HttpApplication app)
		{
			ProcessWebResponse(app, app != null ? app.Request : null, app != null ? app.Response : null);
		}

		public static void ProcessWebResponse(HttpApplication app, HttpRequest request, HttpResponse response)
		{
			SecurityKernel.WebInspectorSubsystem.Api.ExecuteDefaultByCategory(
				WebInspectorEngineCategory.WebInspectorResponse.ToString(),
				new ApiInput(new WebInspectorResponseApiInput(app, request, response)));
			//_webInspector.ProcessResponse(app, request, response);
		}

		public static void ProcessWebError(HttpApplication app)
		{
			SecurityKernel.WebInspectorSubsystem.Api.ExecuteDefaultByCategory(
				WebInspectorEngineCategory.WebInspectorError.ToString(),
				new ApiInput(new WebInspectorErrorApiInput(app, null, null, null)));
			//_webInspector.ProcessError(app);
		}

		/// <summary>
		/// Gets a WebProcessor ID for the specified resource.
		/// </summary>
		/// <param name="appPath">A WEB app virtual path.</param>
		/// <param name="resourceName">A resource name (page, WEB service, handler, etc.)</param>
		/// <param name="resourceExt">A resource name extension.</param>
		/// <returns>An ID of the processor for the resources.</returns>
		public static string LookupWebProcessorId(string appPath, string resourceName, string resourceExt)
		{
			return RequestWebInspector.Inspector.LookupWebProcessorId(appPath, resourceName, resourceExt);
		}

		public static int IsWebRequestSourceBlocked(string pid, string remoteAddr)
		{
			//return _webInspector.IsWebRequestSourceBlocked(pid, remoteAddr);
			return 0;
		}

		public static string ProcessWebRequestProps(string pid, int bodySize, string remoteAddr, string userAgent, string referer, int paramCount, ref string[] paramNames, ref string url, ref string rawUrl)
		{
			return RequestWebInspector.Inspector.ProcessWebRequestProps(pid, bodySize, remoteAddr, userAgent, referer, paramCount, ref paramNames, ref url, ref rawUrl);
		}

		public static string ProcessWebRequestParam(string pid, string paramType, string paramName, ref string paramValue, ref string url, ref string rawUrl, string remoteAddr, string userAgent, string referer)
		{
			return RequestWebInspector.Inspector.ProcessWebRequestParam(pid, paramType, paramName, ref paramValue, ref url, ref rawUrl, remoteAddr, userAgent, referer);
		}

		public static string ForUrl(string val)
		{
			return UrlEncoder.Execute(val);
		}

		public static string ForHtml(string val)
		{
			return HtmlEncoder.Execute(val);
		}

		public static string ForHtmlAttr(string val)
		{
			return HtmlAttrEncoder.Execute(val);
		}

		public static string ForJs(string val)
		{
			return JsEncoder.Execute(val);
		}

		public static string ForVbs(string val)
		{
			return VbEncoder.Execute(val);
		}

		public static string ForCss(string val)
		{
			return CssEncoder.Execute(val);
		}

		public static string ForXml(string val)
		{
			return XmlEncoder.Execute(val);
		}

		public static string ForXmlAttr(string val)
		{
			return XmlAttrEncoder.Execute(val);
		}

		public static string ForLdap(string val)
		{
			return LdapEncoder.Execute(val);
		}

		public static string ToToken(string value)
		{
			string result = string.Empty;
			/*if (SecurityKernel.IsInitialized() && SecurityKernel.ObjectReferenceMapper != null)
			{
				result = SecurityKernel.ObjectReferenceMapper.Api.GetDefaultProvider(OrmProviderName.StringStandard).HasReference(value) ?
								 SecurityKernel.ObjectReferenceMapper.Api.GetDefaultProvider(OrmProviderName.StringStandard).GetReference(value) :
								 string.Empty;
			}*/

			return result;
		}

		public static string FromToken(string id)
		{
			string result = string.Empty;
			if (SecurityKernel.IsInitialized() && SecurityKernel.ObjectReferenceMapper != null)
			{
                result = SecurityKernel.ObjectReferenceMapper.Api.GetDefaultEngine(ObjectReferenceMapperEngineCategory.Str.ToString()).Execute(id);
			}

			return result;
		}


		/// <summary>
		/// Gets reference for appropriate value. Uses dynamic filling.
		/// </summary>
		public static string ToTokenDynamic(string value)
		{
			string result = string.Empty;
			if (SecurityKernel.IsInitialized() && SecurityKernel.ObjectReferenceMapper != null)
			{
				result = SecurityKernel.ObjectReferenceMapper.Api.GetDefaultEngine(ObjectReferenceMapperEngineCategory.Str.ToString()).Execute(value);
			}

			return result;
		}

		/// <summary>
		/// Gets value for appropriate reference. Uses dynamic filling. 
		/// </summary>
		public static string FromTokenDynamic(string id)
		{
			string result = string.Empty;
			if (SecurityKernel.IsInitialized() && SecurityKernel.ObjectReferenceMapper != null)
			{
				result = SecurityKernel.ObjectReferenceMapper.Api.GetDefaultEngine(ObjectReferenceMapperEngineCategory.Str.ToString()).Execute(id).ToString();
			}

			return result;
		}

		public static string NewTokenFor(string value)
		{
			string result = string.Empty;
			/*if (SecurityKernel.IsInitialized() && SecurityKernel.ObjectReferenceMapper != null)
			{
				result = SecurityKernel.ObjectReferenceMapper.Api.GetDefaultProvider("String.Standard").CreateReference(value);
			}*/

			return result;
		}

		public static void ReleaseToken(string id)
		{
			/*if (SecurityKernel.IsInitialized() && SecurityKernel.ObjectReferenceMapper != null)
			{
				SecurityKernel.ObjectReferenceMapper.Api.GetDefaultProvider("String.Standard").DestroyReferenceWithId(id);
			}*/
		}

		/// <summary>
		/// Wrapper for default url-engine of AccessController subsystem.
		/// </summary>
		public static void ForUrlAccessController(string value)
		{
			if (!SecurityKernel.IsInitialized())
			{
				string message = "SecurityKernel is not initialized!";
				throw new AccessControllerException(message);
			}

			SecurityKernel.AccessController.Api.GetDefaultEngine(AccessControllerEngineCategory.UrlController.ToString()).Execute(value);
		}

		public static void ForValidator(string value, string validatorId)
		{
			if (!SecurityKernel.IsInitialized())
			{
				string message = "SecurityKernel is not initialized!";
				throw new SecurityFrameworkException(message);
			}

			SecurityKernel.Validator.Api.GetEngine(validatorId).Execute(new ApiInput(value));
		}

		public static void ForDetector(string value, string detectorId)
		{
			if (!SecurityKernel.IsInitialized())
			{
				string message = "SecurityKernel is not initialized!";
				throw new SecurityFrameworkException(message);
			}

			SecurityKernel.Detector.Api.GetEngine(detectorId).Execute(value);
		}
	}
}