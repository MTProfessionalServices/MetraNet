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

namespace MetraTech.SecurityFramework
{
    public static class EncoderExtensions
    {
        public static string Encode(this string str, string selectorId)
        {
            return string.Empty;
        }

        public static string EncodeDefault(this string str)
        {
            return string.Empty;
        }

        public static string EncodeForUrl(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.Url.ToString(), str) : str;
        }

        public static string EncodeForHtml(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.Html.ToString(), str) : str;
        }

        public static string EncodeForHtmlAttribute(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.HtmlAttribute.ToString(), str) : str;
        }

        public static string EncodeForCss(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.Css.ToString(), str) : str;
        }

        public static string EncodeForJavaScript(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.JavaScript.ToString(), str) : str;
        }

        public static string EncodeForVbScript(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.VbScript.ToString(), str) : str;
        }

        public static string EncodeForXml(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.Xml.ToString(), str) : str;
        }

        public static string EncodeForXmlAttribute(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.XmlAttribute.ToString(), str) : str;
        }

        public static string EncodeForLdap(this string str)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(EncoderEngineCategory.Ldap.ToString(), str) : str;
        }

        public static string EncodeWithEngine(this string str, string engineId)
        {
            return
                !string.IsNullOrEmpty(str) ?
                SecurityKernel.Encoder.Api.Execute(engineId, new ApiInput(str)).ToString() : str;
        }
    }
}