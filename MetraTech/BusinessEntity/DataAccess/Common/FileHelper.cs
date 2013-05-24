using System;
using System.Collections.Generic;
using System.IO;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  /// <summary>
  /// </summary>
  public static class FileHelper
  {
    /// <summary>
    ///   File must exist
    /// </summary>
    /// <param name="fileName"></param>
    /// <returns></returns>
    public static string BackupFile(string fileName)
    {
      Check.Require(!String.IsNullOrEmpty(fileName), "Argument 'fileName' cannot be null", SystemConfig.CallerInfo);
      string message = String.Format("Cannot  backup file '{0}' because it cannot be found", fileName);
      Check.Require(File.Exists(fileName), message, SystemConfig.CallerInfo);
      
      string backup = fileName + ".original";
      File.Copy(fileName, backup, true);

      return backup;
    }

    /// <summary>
    ///   The backup file ends with .original
    ///   The corresponding current file has the same name as the backup file but without the .original at the end
    /// 
    ///   (1) Each item in backupFiles must end with .original
    ///   (2) Each item in backupFiles must exist
    ///   
    ///   (3) If markCurrentAsError is true:
    ///         If the current file exists, replace it with the .error extension 
    ///   
    ///   (4) Replace current file with backup   
    ///          
    ///   (5) Delete backup (.original)
    /// </summary>
    /// <param name="backupFiles"></param>
    /// <param name="markCurrentAsError"></param>
    public static List<ErrorObject> RestoreFiles(ICollection<string> backupFiles, bool markCurrentAsError)
    {
      Check.Require(backupFiles != null, "Argument 'backupFiles' cannot be null", SystemConfig.CallerInfo);
      List<ErrorObject> errors = new List<ErrorObject>();

      backupFiles.ForEach(backup =>
      {
        if (!File.Exists(backup))
        {
          string message = String.Format("Cannot find backup file '{0}'", backup);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }

        if (!backup.EndsWith(".original"))
        {
          string message = String.Format("The backup file '{0}' must have a '.original' extension", backup);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }

        string current = backup.Replace(".original", "");
        // Copy the current to current.error
        if (File.Exists(current) && markCurrentAsError)
        {
          File.Copy(current, current + ".error", true);
        }
        
        // Restore backup
        File.Copy(backup, current, true);
        // Delete backup
        File.Delete(backup);

      });

      return errors;
    }

    public static void RestoreFile(string backup)
    {
      RestoreFiles(new List<string> {backup}, false);
    }

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("FileHelper");
    #endregion
  }
}
