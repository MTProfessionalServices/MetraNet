using System;
using System.Xml;

namespace VertexSocketService
{
  /// <summary>
  /// 
  /// </summary>
  /// <remarks></remarks>
  internal class XMLFormatter
  {
    /// <summary>
    /// 
    /// </summary>
    /// <param name="returnCode"></param>
    /// <param name="returnMessage"></param>
    /// <returns></returns>
    internal static string FormXMLStringForInputParams(string returnCode, string returnMessage)
    {
      const string xmlbaseParam1 = "<Return>";
      string param1 = "<ReturnCode>" + returnCode + "</ReturnCode>";
      string param2 = "<ReturnMessage>" + returnMessage + "</ReturnMessage>";
      const string xmlbaseParam2 = "</Return>";

      return xmlbaseParam1 + param1 + param2 + xmlbaseParam2;
    }

    ///// <summary>
    ///// Parses the XML params.
    ///// </summary>
    ///// <param name="callType">Type of the call.</param>
    ///// <param name="xmlParams">The XML params.</param>
    ///// <returns></returns>
    ///// <remarks></remarks>
    //internal static bool ParseXmlParams(string callType, string xmlParams)
    //{
    //  // TODO : should calltype be enum ?
    //  try
    //  {
    //    XmlDocument xmldoc = new XmlDocument();
    //    xmldoc.LoadXml(xmlParams);

    //    XmlNode xmlConfigNode = xmldoc.SelectSingleNode("//xmlconfig");
    //    if (xmlConfigNode != null)
    //    {
    //      switch (callType)
    //      {
    //        case "Config":
    //          _strVertexPath = xmlConfigNode.SelectSingleNode("//VertexPath").InnerText;
    //          _strVertexCfg = xmlConfigNode.SelectSingleNode("//VertexDefaultConfig").InnerText;
    //          break;

    //        case "ProcessSession":
    //          break;

    //        default:
    //          break;
    //      }
    //    }
    //  }
    //  catch (Exception ex)
    //  {
    //    throw ex;
    //  }
    //  return true;
    //}

    //  /// <summary>
    //  /// Parses the return XML params for sess.
    //  /// </summary>
    //  /// <param name="xmlParams">The XML params.</param>
    //  /// <returns></returns>
    //  /// <remarks></remarks>
    //  internal static bool ParseReturnXmlParamsForSess(string xmlParams)
    //  {
    //    _returnCode = null;
    //    _returnMessage = null;

    //    try
    //    {
    //      XmlDocument xmldoc = new XmlDocument();

    //      xmldoc.LoadXml(xmlParams);

    //      XmlNode xmlReturnNode = xmldoc.SelectSingleNode("//Return");

    //      if (xmlReturnNode != null)
    //      {
    //        _returnCode = xmlReturnNode.SelectSingleNode("//ReturnCode").InnerText;
    //        _returnMessage = xmlReturnNode.SelectSingleNode("//ReturnMessage").InnerText;
    //      }

    //    }
    //    catch (Exception ex)
    //    {
    //      throw ex;
    //    }
    //    return true;
    //  }
    //}
  }
}
