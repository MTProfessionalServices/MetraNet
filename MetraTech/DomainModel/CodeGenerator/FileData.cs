using System.Collections.Generic;
using System.IO;
using System.Resources;
using System;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class FileData
  {
    #region Public Methods

    public FileData()
    {
      localizationFiles = new List<LocalizationFileData>();
    }

    public string GetLocalizedValue(string mtlocalizationKey, Language language)
    {
      string localizedValue = String.Empty;

      foreach(LocalizationFileData localizationFileData in localizationFiles)
      {
        if (localizationFileData.MTLanguage != language.MetraTech) continue;
        localizedValue = localizationFileData.GetLocalizedValue(mtlocalizationKey);
        break;
      }

      return localizedValue;
    }

    /// <summary>
    ///    Given a list of FileData items, create a checksum.resource file which
    ///    contains a mapping of keys (based on file name) to file checksums.
    /// </summary>
    /// <param name="files"></param>
    /// <param name="checksumResourceFileName"></param>
    /// <returns></returns>
    public static string CreateChecksumResource(Dictionary<string, FileData> files, string checksumResourceFileName)
    {
      // Path for the .resources files in Temp
      string checksumResourceFile = Path.Combine(Path.GetTempPath(), checksumResourceFileName);

      logger.LogDebug(String.Format("Generating '{0}'", checksumResourceFile));

      Dictionary<string, int> keys = new Dictionary<string, int>();

      using (ResourceWriter resourceWriter = new ResourceWriter(checksumResourceFile))
      {

        foreach (string key in files.Keys)
        {
          if (keys.ContainsKey(key))
          {
            continue;
          }
          FileData fileData = files[key];
          string checksum = BaseCodeGenerator.GetMD5ChecksumForFile(fileData.FullPath); 
          resourceWriter.AddResource(key, checksum);
          keys.Add(key, 1);

          foreach (LocalizationFileData localizationFileData in fileData.LocalizationFiles)
          {
            if (keys.ContainsKey(localizationFileData.ChecksumKey))
            {
              continue;
            }

            checksum = BaseCodeGenerator.GetMD5ChecksumForFile(localizationFileData.FullPath);
            resourceWriter.AddResource(localizationFileData.ChecksumKey, checksum);
            keys.Add(localizationFileData.ChecksumKey, 1);
          } 
        }

        resourceWriter.Generate();
        resourceWriter.Close();
      }

      return checksumResourceFile;
    }

    
    #endregion

    #region Properties
    private string fileName;
    public string FileName
    {
      get { return fileName; }
      set { fileName = value; }
    }

    private string fullPath;
    public string FullPath
    {
      get { return fullPath; }
      set { fullPath = value; }
    }

    private string extensionName;
    public string ExtensionName
    {
      get { return extensionName; }
      set { extensionName = value; }
    }

    public string[] LocalizationFileNames
    {
      get
      {
        string[] localizationFileNames = new string[localizationFiles.Count];
        for (int i = 0; i < localizationFiles.Count; i++)
        {
          localizationFileNames[i] = localizationFiles[i].FileName;
        }

        return localizationFileNames;
      }
    }

    /// <summary>
    ///    Map standard language code to corresponding LocalizationFileData
    /// </summary>
    private readonly List<LocalizationFileData> localizationFiles;
    public List<LocalizationFileData> LocalizationFiles
    {
      get { return localizationFiles; }
    }

    public string ResourceKey
    {
      get
      {
        return extensionName.ToLower() + "_" + fileName.ToLower();
      }
    }

    /// <summary>
    ///   This is used as the key for the checksum associated with this file.
    ///   The key/checksum pair is stored as a resource in the generated assemblies.
    /// </summary>
    public virtual string ChecksumKey
    {
      get
      {
        throw new NotImplementedException("Invalid use of ChecksumKey");
      }
    }
    #endregion

    #region Data
    protected static readonly Logger logger = new Logger("Logging\\DomainModel\\CodeGenerator", "[CodeGenerator]");
    #endregion
  }

}
