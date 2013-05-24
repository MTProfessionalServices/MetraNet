using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class ExtensionData : ExtensionBase
  {
    #region Public Methods
    public ExtensionData(string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty");

      ExtensionName = extensionName;
      EntityGroupDataList = new List<EntityGroupData>();

      CsProjFileName = Name.GetInterfaceCsProjFileName(extensionName);

      InterfaceDir = Name.GetInterfaceDir(extensionName);
      InterfaceTempDir = Name.GetInterfaceTempDir(extensionName);
      InterfaceAssemblyName = Name.GetInterfaceAssemblyNameFromExtension(extensionName);
      InterfaceAssemblyNameWithPath = Name.GetInterfaceAssemblyFileNameWithPath(extensionName);
      
      BackupInterfaceAssembly = Path.Combine(InterfaceTempDir, InterfaceAssemblyName + ".bak");
      
      LockedFiles = new Dictionary<string, FileStream>();
      AddedOrUpdatedInterfaceFiles = new Dictionary<string, string>();
      DeletedInterfaceFiles = new List<string>();
    }

    /// <summary>
    ///   (1) Let each entity group lock its own assemblies
    ///   (2) Lock the interface assembly, if one of the entity groups votes to build the interface assembly
    /// </summary>
    public void CopyToTempAndLockOutputFiles()
    {
      MustBuild = false;

      AddedOrUpdatedInterfaceFiles.Clear();
      DeletedInterfaceFiles.Clear();
    
      var addedOrUpdatedInterfaceFiles = new Dictionary<string, string>();
      var deletedInterfaceFiles = new List<string>();

      // Copy files to Temp
      BuildUtil.SetupTempDir(InterfaceDir, InterfaceTempDir);

      foreach(EntityGroupData entityGroupData in EntityGroupDataList)
      {
        // Get the interface file content from each EntityGroupData
        entityGroupData.GetInterfaceCode(ref addedOrUpdatedInterfaceFiles, ref deletedInterfaceFiles);

        entityGroupData.CopyToTempAndLockOutputFiles();

        if (entityGroupData.MustBuild)
        {
          MustBuild = true;
        }
      }

      if (!MustBuild)
      {
        return;
      }

      if (File.Exists(InterfaceAssemblyNameWithPath))
      {
        // Copy assembly to Temp as backup
        try
        {
          File.Copy(InterfaceAssemblyNameWithPath, BackupInterfaceAssembly);
        }
        catch (System.Exception e)
        {
          throw new MetadataException(String.Format("Cannot backup assembly '{0}'", InterfaceAssemblyNameWithPath), e);
        }

        LockedFiles.Add(InterfaceAssemblyName, DirectoryUtil.LockFile(InterfaceAssemblyNameWithPath));
      }

      string csprojFileNameWithPath = Path.Combine(InterfaceDir, CsProjFileName);
      if (File.Exists(csprojFileNameWithPath))
      {
        LockedFiles.Add(CsProjFileName, DirectoryUtil.LockFile(csprojFileNameWithPath));
      }
      

      foreach (string fileName in addedOrUpdatedInterfaceFiles.Keys)
      {
        string fileWithPath = Path.Combine(InterfaceDir, fileName);
        if (File.Exists(fileWithPath))
        {
          LockedFiles.Add(fileName, DirectoryUtil.LockFile(fileWithPath));
        }

        AddedOrUpdatedInterfaceFiles.Add(fileName, addedOrUpdatedInterfaceFiles[fileName]);
      }

      foreach (string fileName in deletedInterfaceFiles)
      {
        string fileWithPath = Path.Combine(InterfaceDir, fileName);
        if (File.Exists(fileWithPath))
        {
          LockedFiles.Add(fileName, DirectoryUtil.LockFile(fileWithPath));
        }

        DeletedInterfaceFiles.Add(fileName);
      }
    }

    /// <summary>
    ///   (1) Build the interface assembly
    ///   (2) Build each entity group
    /// </summary>
    public void Build()
    {
      if (MustBuild)
      {
        BuildInterfaceAssembly();
      }
      
      foreach(EntityGroupData entityGroupData in EntityGroupDataList)
      {
        entityGroupData.Build();
      }
    }

    /// <summary>
    ///   (1) Copy changes from temp to actual directory
    ///   (2) Delete temp
    /// </summary>
    public void Commit()
    {
      foreach (EntityGroupData entityGroupData in EntityGroupDataList)
      {
        entityGroupData.Commit();
      }

      if (!MustBuild)
      {
        return;
      }

      FileStream fileStream;
      string tempFileNameWithPath, fileNameWithPath;

      LockedFiles.TryGetValue(CsProjFileName, out fileStream);
      if (fileStream != null)
      {
        fileStream.Close();
      }
      
      tempFileNameWithPath = Path.Combine(InterfaceTempDir, CsProjFileName);
      Check.Require(File.Exists(tempFileNameWithPath), String.Format("Cannot find file '{0}'", tempFileNameWithPath));

      fileNameWithPath = Path.Combine(InterfaceDir, CsProjFileName);
      DirectoryUtil.CopyIfDifferent(tempFileNameWithPath, fileNameWithPath);

      foreach(string fileName in AddedOrUpdatedInterfaceFiles.Keys)
      {
        LockedFiles.TryGetValue(fileName, out fileStream);

        if (fileStream != null)
        {
          fileStream.Close();
        }

        tempFileNameWithPath = Path.Combine(InterfaceTempDir, fileName);
        Check.Require(File.Exists(tempFileNameWithPath), String.Format("Cannot find file '{0}'", tempFileNameWithPath));
        
        fileNameWithPath = Path.Combine(InterfaceDir, fileName);

        DirectoryUtil.CopyIfDifferent(tempFileNameWithPath, fileNameWithPath);
      }

      foreach (string fileName in DeletedInterfaceFiles)
      {
        LockedFiles.TryGetValue(fileName, out fileStream);

        if (fileStream != null)
        {
          fileStream.Close();
        }

        fileNameWithPath = Path.Combine(InterfaceDir, fileName);
        if (File.Exists(fileNameWithPath))
        {
          File.Delete(fileNameWithPath);
        }
      }

      LockedFiles.TryGetValue(InterfaceAssemblyName, out fileStream);
      if (fileStream != null)
      {
        fileStream.Close();
      }

      // Copy the assembly to directories specified in be.cfg.xml
      CopyAssemblyToDirectoriesSpecifiedInConfig(InterfaceAssemblyNameWithPath);
    }

    public void UnlockFilesAndRestoreAssembly()
    {
      FileStream fileStream;

      // Restore the original assembly from the backup
      if (File.Exists(BackupInterfaceAssembly))
      {
        
        LockedFiles.TryGetValue(InterfaceAssemblyName, out fileStream);

        if (fileStream != null)
        {
          fileStream.Close();
        }

        File.Copy(BackupInterfaceAssembly, InterfaceAssemblyNameWithPath, true);

        LockedFiles.Remove(InterfaceAssemblyName);
      }

      foreach (EntityGroupData entityGroupData in EntityGroupDataList)
      {
        entityGroupData.UnlockFilesAndRestoreAssembly();
      }

      foreach (string fileName in LockedFiles.Keys)
      {
        fileStream = LockedFiles[fileName];
        if (fileStream != null)
        {
          fileStream.Close();
        }
      }
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as ExtensionData;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.ExtensionName.Equals(ExtensionName, StringComparison.InvariantCultureIgnoreCase);
    }

    public override int GetHashCode()
    {
      return (ExtensionName.GetHashCode());
    }

    public override string ToString()
    {
      return String.Format("Extension='{0}'", ExtensionName);
    }
    #endregion

    #region Public Static Methods
    public static List<ExtensionData> GroupByExtension(List<EntityGroupData> entityGroupDataList)
    {
      Check.Require(entityGroupDataList != null, "entityGroupDataList cannot be null");

      var extensionDataList = new List<ExtensionData>();

      foreach (EntityGroupData entityGroupData in entityGroupDataList)
      {
        ExtensionData extensionData =
          extensionDataList.Find(e => e.ExtensionName.ToLowerInvariant() ==
                                      entityGroupData.ExtensionName.ToLowerInvariant());

        if (extensionData == null)
        {
          extensionData = new ExtensionData(entityGroupData.ExtensionName);
          extensionData.BuildGraph = entityGroupData.BuildGraph;
          extensionDataList.Add(extensionData);
        }

        extensionData.EntityGroupDataList.Add(entityGroupData);
      }

      return extensionDataList;
    }

    #endregion

    #region Public Properties
    public string ExtensionName { get; private set; }
    public List<EntityGroupData> EntityGroupDataList { get; private set; }
    public Dictionary<string, FileStream> LockedFiles { get; private set; }
    public Dictionary<string, string> AddedOrUpdatedInterfaceFiles { get; private set; }
    public List<string> DeletedInterfaceFiles { get; private set; }
    
    public string TempOutputAssembly { get; private set; }
    public string BackupInterfaceAssembly { get; private set; }
    public string CsProjFileName { get; private set; }
    public string InterfaceTempDir { get; private set; }
    public string InterfaceDir { get; private set; }
    public string InterfaceAssemblyName { get; private set; }
    public string InterfaceAssemblyNameWithPath { get; private set; }
    public BuildGraph BuildGraph { get; set; }
    #endregion

    #region Private Properties
    private bool MustBuild { get; set; }
    #endregion
    #region Private Methods
    /// <summary>
    ///   (1) Prepare the interface temp directory
    ///   (2) Copy the files to the temp directory
    ///   (3) Build the files in the temp directory
    ///       - Generate the assembly in the temp directory
    /// </summary>
    private void BuildInterfaceAssembly()
    {
      logger.Debug(String.Format("Building interface assembly '{0}' for extension '{1}' in directory '{2}'", 
                                  InterfaceAssemblyName, ExtensionName, InterfaceTempDir));

      string[] csprojFiles = Directory.GetFiles(InterfaceTempDir, "*.csproj", SearchOption.TopDirectoryOnly);

     // Create the csproj, if it doesn't exist
      if (!csprojFiles.Contains(Path.Combine(InterfaceTempDir, CsProjFileName)))
      {
        string csProjContent =
          BuildUtil.CreateCsProjFile(Name.GetInterfaceCsProjDefaultNamespace(ExtensionName),
                                     GetStandardInterfaceAssemblies());

        Check.Require(!String.IsNullOrEmpty(csProjContent), "csProjContent cannot be null or empty");
        string csProjFileName =
          Path.Combine(InterfaceTempDir, Name.GetInterfaceCsProjFileName(ExtensionName));

        logger.Debug(String.Format("Creating interface csproj file '{0}' for extension '{1}'", csProjFileName, ExtensionName));

        File.WriteAllText(csProjFileName, csProjContent);
      }

      var referenceAssemblies = new List<ReferenceAssembly>();
      List<string> extensionDependencies = BuildGraph.GetDependentAssembliesForExtension(ExtensionName);

      foreach (string assemblyName in extensionDependencies)
      {
        // If this assembly is found in the interface temp path, then use it from there
        if (File.Exists(Path.Combine(Name.GetInterfaceTempDir(ExtensionName), assemblyName)))
        {
          referenceAssemblies.Add(new ReferenceAssembly(Path.Combine(Name.GetInterfaceTempDir(ExtensionName),
                                                                     assemblyName)));
        }
        else
        {
          referenceAssemblies.Add(new ReferenceAssembly(assemblyName));
        }
      }

      // Unlock assembly
      FileStream fileStream;
      LockedFiles.TryGetValue(InterfaceAssemblyName, out fileStream);

      if (fileStream != null)
      {
        // Unlock original
        fileStream.Close();
      }

      // Build
      TempOutputAssembly = BuildUtil.BuildDir(InterfaceTempDir,
                                              AddedOrUpdatedInterfaceFiles, 
                                              DeletedInterfaceFiles,
                                              referenceAssemblies,
                                              CsProjFileName);

      // If TempOutputAssembly is null, no assembly was built - because there was nothing to compile
      // Delete the assembly from RMP\bin
      if (TempOutputAssembly == null)
      {
        if (File.Exists(InterfaceAssemblyNameWithPath))
        {
          File.Delete(InterfaceAssemblyNameWithPath);
        }
      }
      else
      {
        // Copy TempOutputAssembly to RMP\bin
        File.Copy(TempOutputAssembly, InterfaceAssemblyNameWithPath, true); 
      }

      logger.Debug(String.Format("Generated interface assembly '{0}' for extension '{1}'", TempOutputAssembly, ExtensionName));
    }

    private static List<ReferenceAssembly> GetStandardInterfaceAssemblies()
    {
      return new List<ReferenceAssembly>
                  {
                    new ReferenceAssembly("MetraTech.DomainModel.Enums.Generated.dll"),
                    new ReferenceAssembly("MetraTech.Basic.dll"),
                    new ReferenceAssembly("MetraTech.BusinessEntity.Core.dll"),
                    new ReferenceAssembly("MetraTech.BusinessEntity.DataAccess.dll")
                  };
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("ExtensionData");
    #endregion
  }
}
