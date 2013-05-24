using System;
using System.Collections.Generic;
using System.IO;
using System.DirectoryServices;

using MetraTech.Basic.Exception;
using MetraTech.Security.DPAPI;

namespace MetraTech.Basic
{
  public static class DirectoryUtil
  {
    public static string ResolveVirtualDirectory(string virtualDirectoryName)
    {
      Check.Require(!String.IsNullOrEmpty(virtualDirectoryName), "virtualDirectoryName cannot be null or empty");
      string dir = String.Empty;

      try
      {
        using (var w3Svc = new DirectoryEntry("IIS://localhost/W3SVC/1/Root"))
        {
          foreach (DirectoryEntry directoryEntry in w3Svc.Children)
          {
            if (directoryEntry.Properties["Path"].Value != null &&
                directoryEntry.Name.ToLower() == virtualDirectoryName.ToLower())
            {
              dir = (string)directoryEntry.Properties["Path"].Value;
              break;
            }
          }
        }
      }
      catch (System.Exception e)
      {
        logger.Info(String.Format("Cannot resolve path for virtual directory '{0}' with message '{1}'", virtualDirectoryName, e.Message));
      }
      
      return dir;
    }

    /// <summary>
    ///   Delete the contents of the specified directory
    /// </summary>
    /// <param name="dir"></param>
    public static void CleanDir(string dir)
    {
      if (!Directory.Exists(dir)) return;

      Array.ForEach(Directory.GetFiles(dir), File.Delete);

      string[] directories = Directory.GetDirectories(dir);
      foreach(string directory in directories)
      {
        logger.Debug(String.Format("Deleting directory '{0}'", directory));
        Directory.Delete(directory, true);
      }
    }

    public static FileStream LockFile(string fileName)
    {
      Dictionary<string, FileStream> files = LockFiles(new List<string> {fileName});
      return files[fileName];
    }

    /// <summary>
    ///    Lock the specified files
    /// </summary>
    /// <param name="fileNames"></param>
    /// <returns></returns>
    public static Dictionary<string, FileStream> LockFiles(List<string> fileNames)
    {
      var lockedFiles = new Dictionary<string, FileStream>();

      foreach (string fileName in fileNames)
      {
        Check.Require(File.Exists(fileName), String.Format("Cannot find file '{0}'", fileName));

        try
        {
          // logger.Debug(String.Format("Attempting to lock file for writing '{0}'.", fileName));
          // Other processes will not be able to write to fileName
          var fileStream = File.OpenWrite(fileName);
          lockedFiles.Add(fileName, fileStream);
        }
        catch(System.Exception e)
        {
          string message = String.Format("Cannot lock file for writing '{0}'. Possibly in use", fileName);
          logger.Error(message, e);
          throw new BasicException(message, e);
        }
      }

      return lockedFiles;
    }


    public static string GetChecksum(string fileNameWithPath)
    {
      Check.Require(File.Exists(fileNameWithPath), String.Format("Cannot find file '{0}'", fileNameWithPath));
      string content = File.ReadAllText(fileNameWithPath);
      return KeyGenerator.Hash(content);
    }

    /// <summary>
    ///    Return true, if the files are different and the copy was made. 
    ///    Handles only .cs, .xml and .csproj files.
    /// </summary>
    /// <param name="fromFileNameWithPath"></param>
    /// <param name="toFileNameWithPath"></param>
    /// <returns></returns>
    public static bool CopyIfDifferent(string fromFileNameWithPath, string toFileNameWithPath)
    {
      Check.Require(File.Exists(fromFileNameWithPath), String.Format("Cannot find file '{0}'", fromFileNameWithPath));
      
      Check.Require(fromFileNameWithPath.ToLower().EndsWith(".cs") ||
                    fromFileNameWithPath.ToLower().EndsWith(".xml") ||
                    fromFileNameWithPath.ToLower().EndsWith(".csproj"), 
                    String.Format("Cannot handle file '{0}'", fromFileNameWithPath));
     
      bool copy = true;

      if (File.Exists(toFileNameWithPath))
      {
        string fromFileChecksum = GetChecksum(fromFileNameWithPath);
        string toFileChecksum = GetChecksum(toFileNameWithPath);

        if (fromFileChecksum == toFileChecksum)
        {
          copy = false;
        }
      }

      if (copy)
      {
        File.Copy(fromFileNameWithPath, toFileNameWithPath, true);
      }

      return copy;
    }

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("DirectoryUtil");
    #endregion
  }
}
