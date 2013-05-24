using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.DataExportFramework.Components.DataExporter
{
  /// <summary>
  /// Inteface for DEF configuration should be used like Singltone
  /// </summary>
  public interface IConfiguration
  {
    /// <summary>
    /// Gets full path to query for Windows Service
    /// </summary>
    /// <returns>absolute Dir path</returns>
    string GetServiceQueryDir();

    /// <summary>
    /// Gets full path to query for custom queries which can be used in UI side
    /// </summary>
    /// <returns>absolute Dir path</returns>
    string GetCustomQueryDir();

    /// <summary>
    /// Gets full path to config faile
    /// </summary>
    /// <returns>full file name</returns>
    string GetReportConfigFilePath();

    /// <summary>
    /// Gets extension dir
    /// </summary>
    /// <returns></returns>
    string GetExtentionDir();

    /// <summary>
    /// Gets FieldDef dir
    /// </summary>
    /// <returns></returns>
    string GetFieldDefDir();

  }
}
