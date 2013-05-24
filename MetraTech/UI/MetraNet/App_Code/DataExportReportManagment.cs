using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml;
using MetraTech.DataAccess;
using MetraTech.DataAccess.QueryManagement.Business.Logic;
using MetraTech.Interop.RCD;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;


namespace MetraTech.UI.MetraNet.App_Code
{
  /// <summary>
  /// Summary description for DataExportReportManagment
  /// </summary>
  public class DataExportReportManagment
  {
    private const string queryPath = @"DataExport\Config\queries\Custom\";
    private const string queryPathforQueryManagment = @"DataExport\Config\SqlCore\Queries\Custom";

    protected readonly Logger logger;

    public DataExportReportManagment(Logger logger)
    {
      this.logger = logger;
    }


    public List<string> GetQueryTagList()
    {
      var result = new List<string>();
      IMTRcd _rcd = new MTRcdClass();
      var _ext = _rcd.ExtensionDir;

      // Check Query Management Enabled or not? 
      var qm = new QueryMapper();

      if (qm.Enabled)
      {
        ReadBatchQueryTags(Path.Combine(_ext, queryPathforQueryManagment), ref result);
      }
      else
      {
        var strqueryfile = "ExportReportQueries.xml";
        var _queryconfigFile = Path.Combine(_ext, queryPath, strqueryfile);

        result.AddRange(GetQueryTagsFromFile(_queryconfigFile));

        strqueryfile = GetQueriesFileName(Path.Combine(_ext, queryPath));

        _queryconfigFile = Path.Combine(_ext, queryPath, strqueryfile);
        result.AddRange(GetQueryTagsFromFile(_queryconfigFile));
      }

      return result;
    }

    private List<string> GetQueryTagsFromFile(string _queryconfigFile)
    {
      List<string> result = new List<string>();
      var XMLdoc = new XmlDocument();
      XMLdoc.Load(_queryconfigFile);

      XmlElement RootNode = XMLdoc.DocumentElement;
      XmlNodeList nodeList = RootNode.GetElementsByTagName("query_tag");

      for (int i = 0; i <= (nodeList.Count - 1); i++)
      {
        var xmlNode = nodeList.Item(i);
        if (xmlNode != null) result.Add(xmlNode.InnerXml);
      }

      return result;
    }

    private string GetQueriesFileName(string adapterConfigPath)
    {
      var info = ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database");

      var XMLdoc = new XmlDocument();
      XMLdoc.Load(Path.Combine(adapterConfigPath, "queryadapter.xml"));

      return info.IsOracle
               ? XMLdoc.GetElementsByTagName("oracle_query_file")[0].InnerText
               : XMLdoc.GetElementsByTagName("sql_server_query_file")[0].InnerText;
    }

    private void ReadBatchQueryTags(string orderdQueryPath, ref List<string> queryTagList)
    {
      try
      {
        logger.LogDebug("The list of query tag being read from: {0}.", orderdQueryPath); 
        queryTagList = QueryFinder.Execute(orderdQueryPath);
      }
      catch (Exception e)
      {
        logger.LogError(e.ToString());
        logger.LogError("Unable to get query tags from {0}.", orderdQueryPath);
        throw e;
      }
    }

  }
}