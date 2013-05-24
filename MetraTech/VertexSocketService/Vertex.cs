using System;
using System.Runtime.InteropServices;
using System.Xml;
using System.Configuration;
using MetraTech;
using Interop.VertexATLWrapperLib;


namespace VertexSocketService
{
  /// <summary>
  /// Does all vertex related tasks.
  /// </summary>
  /// <remarks></remarks>
  internal class Vertex
  {
    private static string _vertexCfg;
    private static string _vertexPath;
    private static readonly AppSettingsReader appSettingsReader = new AppSettingsReader();
    private static VertexCtrl _objVertex = new VertexCtrl();
    private static readonly Logger _logger = new Logger("[VertexSocketService.VertexQ]");
    private static bool _isInitialized = false;
    private static readonly object locker = new object();
    private string _strRet;
    private const string strFailure = "FAILED";
    private const string strCompleted = "COMPLETED";

    /// <summary>
    /// Gets a value indicating whether this instance is vertex initialized.
    /// </summary>
    /// <remarks></remarks>
    public bool IsVertexInitialized
    {
      get { return _isInitialized; }
    }

    # region Configure
    /// <summary>
    /// Loads the vertex settings.
    /// </summary>
    /// <remarks></remarks>
    internal void LoadVertexSettings()
    {
      lock (locker)
      {
        if (_isInitialized)
          return;
      }

      string vertexServerConfigFilePath =
         appSettingsReader.GetValue("VertexServerConfigFile", typeof(string)).ToString();

      XmlDocument xmlDoc = new XmlDocument();
      xmlDoc.Load(vertexServerConfigFilePath);

      XmlNode xmlConfigNode = xmlDoc.SelectSingleNode("//xmlconfig");

      if (null != xmlConfigNode)
      {
        _vertexPath = xmlConfigNode.SelectSingleNode("//VertexPath").InnerText;
        _vertexCfg = xmlConfigNode.SelectSingleNode("//VertexDefaultConfig").InnerText;
      }

      _objVertex.bstrVertexConfigName = _vertexCfg;
      _objVertex.bstrVertexConfigPath = _vertexPath;

      _logger.LogInfo("Using Vertex Config : " + _vertexCfg);
      _logger.LogInfo("Using Vertex Path : " + _vertexPath);

      lock (locker)
      {
        _isInitialized = true;
      }
    }

    /// <summary>
    /// Initializes the vertex.
    /// </summary>
    /// <remarks></remarks>
    internal void InitializeVertex()
    {
      if (!_isInitialized)
        LoadVertexSettings();

      // Initialize the Vertex Object
      string strRet = _objVertex.Initialize();
      _objVertex.sReturnTimings = 0;

      // Put the return xml into a document for processing.
      XmlDocument doc = new XmlDocument();
      doc.LoadXml(strRet);
      // Make sure we were successfull.
      XmlNodeList nList = doc.GetElementsByTagName("Success");
      if (nList.Count > 0)
      {
        _logger.LogInfo("AsynchVertexSocketServer.Vertex::Initialize() - " + strRet);
      }
      else
      {
        // We were not successful so process the error
        nList = doc.GetElementsByTagName("Error");
        if (nList.Count > 0)
        {
          XmlNode node = nList.Item(0);
          _logger.LogError("AsynchVertexSocketServer.Configure: Initialize Vertex Error: " + node.InnerXml);
          throw new Exception("AsynchVertexSocketServer.Configure: Initialize Vertex Error: '" + node.InnerXml +
                              "'");
        }
        else
        {
          // Should not reach here.
          // We have bad xml back from the Vertex object.
          _logger.LogError(
              "AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: " + strRet);
          throw new Exception(
              "AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: '" + strRet +
              "'");
        }
      }
    }

    /// <summary>
    /// Reconnects the vertex.
    /// </summary>
    /// <remarks></remarks>
    public void ReconnectVertex()
    {
      string strRet = _objVertex.Reconnect();

      // Put the return xml into a document for processing.
      XmlDocument doc = new XmlDocument();
      doc.LoadXml(strRet);

      // Make sure we were successfull.
      XmlNodeList nList = doc.GetElementsByTagName("Success");
      if (nList.Count > 0)
      {
        _logger.LogDebug("AsynchVertexSocketServer.Vertex::ReconnectVertex() - " + strRet);
      }
      else
      {
        // We were not successful so process the error
        nList = doc.GetElementsByTagName("Error");
        if (nList.Count > 0)
        {
          XmlNode node = nList.Item(0);
          if (node != null)
          {
            _logger.LogError("AsynchVertexSocketServer.Configure: Reconnect Vertex Error: " + node.InnerXml);
            throw new Exception("AsynchVertexSocketServer.Configure: Reconnect Vertex Error: '" + node.InnerXml + "'");
          }
          else
          {
            // Should not reach here.
            // We have bad xml back from the Vertex object.
            _logger.LogError("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Reconnect Vertex : " + strRet);
            throw new Exception("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Reconnect Vertex : '" + strRet + "'");
          }
        }
        else
        {
          // Should not reach here.
          // We have bad xml back from the Vertex object.
          _logger.LogError("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: " + strRet);
          throw new Exception("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: '" + strRet + "'");
        }
      }
    }

    public void RefreshVertex()
    {
      string strRet = _objVertex.Refresh();

      // Put the return xml into a document for processing.
      XmlDocument doc = new XmlDocument();
      doc.LoadXml(strRet);

      // Make sure we were successfull.
      XmlNodeList nList = doc.GetElementsByTagName("Success");
      if (nList.Count > 0)
      {
        _logger.LogDebug("AsynchVertexSocketServer.Vertex::RefreshVertex() - " + strRet);
      }
      else
      {
        // We were not successful so process the error
        nList = doc.GetElementsByTagName("Error");
        if (nList.Count > 0)
        {
          XmlNode node = nList.Item(0);
          if (node != null)
          {
            _logger.LogError("AsynchVertexSocketServer.Configure: Refresh Vertex Error: " + node.InnerXml);
            throw new Exception("AsynchVertexSocketServer.Configure: Refresh Vertex Error: '" + node.InnerXml + "'");
          }
          else
          {
            // Should not reach here.
            // We have bad xml back from the Vertex object.
            _logger.LogError("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Refresh Vertex : " + strRet);
            throw new Exception("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Refresh Vertex : '" + strRet + "'");
          }
        }
        else
        {
          // Should not reach here.
          // We have bad xml back from the Vertex object.
          _logger.LogError("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Refresh Vertex: " + strRet);
          throw new Exception("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Refresh Vertex: '" + strRet + "'");
        }
      }

    }

    public void ResetVertex()
    {
      // Create our Vertex object
      if (_objVertex == null)
        _objVertex = new VertexCtrl();
      _objVertex.bstrVertexConfigPath = _vertexPath;

      // Use the default for now.  It can be changed per session.
      _objVertex.bstrVertexConfigName = _vertexCfg;

      // Reset the Vertex object
      string strRet = _objVertex.Reset();
      _objVertex.sReturnTimings = 0;

      // Put the return xml into a document for processing.
      XmlDocument doc = new XmlDocument();
      doc.LoadXml(strRet);

      // Make sure we were successfull.
      XmlNodeList nList = doc.GetElementsByTagName("Success");
      if (nList.Count > 0)
      {
        _logger.LogDebug("AsynchVertexSocketServer.Vertex::ResetVertex() - " + strRet);
      }
      else
      {
        // We were not successful so process the error
        nList = doc.GetElementsByTagName("Error");
        if (nList.Count > 0)
        {
          XmlNode node = nList.Item(0);
          if (node != null)
          {
            _logger.LogError("AsynchVertexSocketServer.Configure: Reset Vertex Error: " + node.InnerXml);
            throw new Exception("AsynchVertexSocketServer.Configure: Reset Vertex Error: '" + node.InnerXml + "'");
          }
          else
          {
            // Should not reach here.
            // We have bad xml back from the Vertex object.
            _logger.LogError("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: " + strRet);
            throw new Exception("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: '" + strRet + "'");
          }
        }
        else
        {
          // Should not reach here.
          // We have bad xml back from the Vertex object.
          _logger.LogError("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: " + strRet);
          throw new Exception("AsynchVertexSocketServer.Configure: Unknow XML tag returned from Calculate Taxes: '" + strRet + "'");
        }
      }
    }
    #endregion

    #region Shutdown
    /// <summary>
    /// Shutdowns this instance.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    public string Shutdown()
    {
      _logger.LogDebug("AsynchVertexSocketServer.Shutdown Method");
      string returnXmlParams = null;

      try
      {
        // Clean up the Vertex object
        if (null != _objVertex)
        {
          string strReturn = _objVertex.Terminate();
          _logger.LogDebug("AsynchVertexSocketServer.Vertex:Terminate() - " + strReturn);
          returnXmlParams = XMLFormatter.FormXMLStringForInputParams("0", "Success");
        }
      }
      catch (Exception ex)
      {
        _logger.LogError(string.Format("AsynchVertexSocketServer.Shutdown caught exception {0}", ex.Message));
        returnXmlParams = XMLFormatter.FormXMLStringForInputParams("-1", "Failed");
      }

      _logger.LogDebug("AsynchVertexSocketServer.Shutdown Return XML :" + returnXmlParams);
      return returnXmlParams;
    }
    #endregion
    
    /// <summary>
    /// Calculates the taxes.
    /// </summary>
    /// <param name="xmlString">The XML string.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    internal string CalculateTaxes(string xmlString)
    {
      _strRet = strCompleted;
      string returnXmlParams = null;
      string vertexResults = String.Empty;

      try
      {
        // Call vertex to calculate taxes
        vertexResults = _objVertex.CalculateTaxes(xmlString);

        // Put the return xml into a document for processing.
        XmlDocument doc = new XmlDocument();
        doc.LoadXml(vertexResults);

        // Make sure we were successful.
        XmlNodeList nList = doc.GetElementsByTagName("Success");
        if (nList.Count > 0)
        {
          // Get the "TaxRecords" children
          _logger.LogDebug("AsynchVertexSocketServer.ProcessSess: Calculate Taxes Success");
          XmlNodeList nRecordsList = doc.GetElementsByTagName("TaxRecords");
          if (nRecordsList.Count == 0)
          {
            // No such child, so we have an error
            _logger.LogWarning(
                "AsynchVertexSocketServer.ProcessSess: Calculate Taxes returned invalid values (TaxRecords): " +
                doc.InnerXml);
            throw new Exception(
                "AsynchVertexSocketServer.ProcessSess: Calculate Taxes returned invalid values: '" +
                doc.InnerXml + "'");
          }
        }
        else
        {
          // We were not successful so process the error
          nList = doc.GetElementsByTagName("Error");
          if (nList.Count > 0)
          {
            //???
            _strRet = strFailure;
            XmlNode node = nList.Item(0);
            if (node != null)
              _logger.LogDebug("AsynchVertexSocketServer.ProcessSess: Calc Tax Error: " + node.InnerXml);
          }
          else
          {
            // Should not reach here.
            // We have bad xml back from the Vertex object.
            throw new Exception(
                "AsynchVertexSocketServer.ProcessSess: Unknow XML tag returned from Calculate Taxes: '" +
                vertexResults + "'");
          }
        }

        returnXmlParams = XMLFormatter.FormXMLStringForInputParams("0", _strRet.Equals("COMPLETED") ? "Success" : "Failed");
      }
      catch (COMException comEx)
      {
        _logger.LogError(string.Format("AsynchVertexSocketServer caught exception {0}", comEx.Message));
        returnXmlParams = XMLFormatter.FormXMLStringForInputParams("-2", comEx.Message);
      }
      catch (Exception e)
      {
        returnXmlParams = XMLFormatter.FormXMLStringForInputParams("-2", e.Message);
      }
      _logger.LogDebug("AsynchVertexSocketServer.ProcessSess Return XML :" + returnXmlParams);

      return vertexResults;
    }
  }
}
