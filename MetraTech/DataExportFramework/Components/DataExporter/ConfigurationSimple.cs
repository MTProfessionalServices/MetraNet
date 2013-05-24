using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.DataAccess.QueryManagement.Business.Logic;
using MetraTech.Interop.RCD;


namespace MetraTech.DataExportFramework.Components.DataExporter
{
  public class ConfigurationSimple : IConfiguration
  {
    private static readonly IQueryMapper _queriManager = new QueryMapper();
    private const String CurrentExtensionDirName = "DataExport";
    private const String UsageDir = @"Config\Usage";
    /// <summary>
    /// path to query for service in V2 format (Query Managemtn on)
    /// </summary>
    private const String ServiceQueryDirV2 = @"Config\SqlCore\Queries\Service";

    /// <summary>
    /// path to cusom query in V2 format (Query Managemtn on)
    /// </summary>
    private const String CustomQueryDirV2 = @"Config\SqlCore\Queries\Custom";

    /// <summary>
    /// path to query for service in V1 format (Query Managemtn off)
    /// </summary>
    private const String ServiceQueryDirV1 = @"Config\queries\Service";

    /// <summary>
    /// path to cusom query in V1 format (Query Managemtn off)
    /// </summary>
    private const String CustomQueryDirV1 = @"Config\queries\Custom";

    private const String FiledDefDir = @"Config\FieldDef";
    private const String ReportConfigurationFileName = "MetratechReports.xml";

    private readonly string _extensionDir = null;

			
    private static readonly IConfiguration  _instance = new ConfigurationSimple();
    private ConfigurationSimple()
    {
      IMTRcd rcd = new MetraTech.Interop.RCD.MTRcdClass();
      rcd.Init();
      _extensionDir = rcd.ExtensionDir;
    }

    public static IConfiguration Instance
    {
      get { return _instance; }
    }
    public string GetServiceQueryDir()
    {
      return CombinePathToExtensionDir(_queriManager.Enabled
                ? ServiceQueryDirV2
                : ServiceQueryDirV1);
    }

    public string GetCustomQueryDir()
    {
      return CombinePathToExtensionDir(_queriManager.Enabled
                ? CustomQueryDirV2
                : CustomQueryDirV1);
    }

    public string GetReportConfigFilePath()
    {
      return CombinePathToExtensionDir(Path.Combine(UsageDir, ReportConfigurationFileName));
    }

    public string GetExtentionDir()
    {
      return CombinePathToExtensionDir(String.Empty);
    }

    public string GetFieldDefDir()
    {
      return CombinePathToExtensionDir(FiledDefDir);
    }

    private string CombinePathToExtensionDir(string path)
    {
      return Path.Combine(_extensionDir, CurrentExtensionDirName, path);
    }

  }
}
 