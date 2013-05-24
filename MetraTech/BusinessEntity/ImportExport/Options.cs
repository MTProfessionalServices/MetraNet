using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.BusinessEntity.ImportExport
{
  public static class Options
  {
    public static bool IgnoreMetadataDifferences = false;
    public enum ImportModeEnum { Replace, Append }
    public static ImportModeEnum ImportMode = ImportModeEnum.Replace;
  }
}
