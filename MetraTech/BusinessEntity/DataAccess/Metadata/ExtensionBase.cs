using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core.Config;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class ExtensionBase
  {
    #region Protected Methods
    protected void CopyAssemblyToDirectoriesSpecifiedInConfig(string assemblyFileWithPath)
    {
      // Copy the assembly to directories specified in be.cfg.xml
      IList<string> copyToDirectories = BusinessEntityConfig.Instance.GetAssemblyCopyDirectories();

      foreach (string directory in copyToDirectories)
      {
        try
        {
          if (File.Exists(assemblyFileWithPath))
          {
            logger.Debug(String.Format("Copying assembly '{0}' to directory '{1}'", assemblyFileWithPath, directory));
            File.Copy(assemblyFileWithPath, Path.Combine(directory, Path.GetFileName(assemblyFileWithPath)), true);
          }
        }
        catch (System.Exception e)
        {
          logger.Error
            (String.Format("Cannot copy assembly '{0}' to directory '{1}' with exception: '{2}'",
                            assemblyFileWithPath, directory, e.Message));
        }
      }
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("ExtensionBase");
    #endregion
  }
}
