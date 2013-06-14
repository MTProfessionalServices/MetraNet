using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class EntityGroupData : ExtensionBase
  {
    #region Public Methods
    public static EntityGroupData CreateEntityGroupData(string entityName)
    {
      string extensionName, entityGroupName;
      Name.GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
      return new EntityGroupData(extensionName, entityGroupName);
    }

    public EntityGroupData(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty");

      ExtensionName = extensionName;
      EntityGroupName = entityGroupName;

      LockedFiles = new Dictionary<string, FileStream>();

      EntityDir = Name.GetEntityDir(extensionName, entityGroupName);
      EntityTempDir = Name.GetEntityTempDir(extensionName, entityGroupName);
      ComputedPropertyDir = SystemConfig.GetComputedPropertyDir(extensionName, entityGroupName);

      EntityAssemblyName = Name.GetEntityAssemblyName(extensionName, entityGroupName) + ".dll";
      EntityAssemblyWithPath = Name.GetEntityAssemblyNameWithPath(ExtensionName, EntityGroupName);

      CsProjFileName = Name.GetEntityCsProjFileName(extensionName, entityGroupName);
      ComputedPropertyAssemblyName = Name.GetComputedPropertyAssemblyName(extensionName, entityGroupName);

      BackupEntityAssembly = Path.Combine(EntityTempDir, EntityAssemblyName + ".bak");

      NewOrUpdatedCodeFiles = new Dictionary<string, string>();
      NewOrUpdatedHbmMappingFiles = new Dictionary<string, string>();
      DeletedCodeFiles = new List<string>();
      DeletedHbmMappingFiles = new List<string>();
    }


    public void CopyToTempAndLockOutputFiles()
    {
      Check.Require(LockedFiles.Count == 0, 
                    String.Format("Found unexpected locked assemblies '{0}'", 
                                  String.Join(",", LockedFiles.Keys.ToArray())));

      if (!MustBuild)
      {
        return;
      }
      
      // Copy files to Temp
      BuildUtil.SetupTempDir(EntityDir, EntityTempDir, LockedFiles);

      if (File.Exists(EntityAssemblyWithPath))
      {
        // Copy assembly to Temp as backup
        try
        {
          logger.Debug(String.Format("Backing up assembly '{0}' to '{1}'", EntityAssemblyWithPath, BackupEntityAssembly));
          File.Copy(EntityAssemblyWithPath, BackupEntityAssembly);
        }
        catch (System.Exception e)
        {
          string message = String.Format("Cannot backup assembly '{0}' to '{1}'", EntityAssemblyWithPath, BackupEntityAssembly);
          logger.Error(message, e);
          throw new MetadataException(message, e);
        }

        LockedFiles.Add(EntityAssemblyName, DirectoryUtil.LockFile(EntityAssemblyWithPath));
      }

      // Lock the csproj file, if it exists
      LockFile(CsProjFileName);
      

      if (MustBuildComputedPropertyAssembly())
      {
        string computedPropertyAssemblyWithPath =
          Name.GetComputedPropertyAssemblyNameWithPath(ExtensionName, EntityGroupName);

        if (File.Exists(computedPropertyAssemblyWithPath))
        {
          LockedFiles.Add(ComputedPropertyAssemblyName, DirectoryUtil.LockFile(computedPropertyAssemblyWithPath));
        }
      }

      Dictionary<string, string> newOrUpdatedCodeFiles, newOrUpdatedHbmMappingFiles;
      List<string> deletedCodeFiles, deletedHbmMappingFiles;

      SyncData.GetFileContents(out newOrUpdatedCodeFiles, 
                               out newOrUpdatedHbmMappingFiles, 
                               out deletedCodeFiles, 
                               out deletedHbmMappingFiles);

      NewOrUpdatedCodeFiles.Clear();
      NewOrUpdatedHbmMappingFiles.Clear();
      DeletedCodeFiles.Clear();
      DeletedHbmMappingFiles.Clear();

      foreach (KeyValuePair<string, string> pair in newOrUpdatedCodeFiles)
      {
        NewOrUpdatedCodeFiles.Add(pair.Key, pair.Value);
      }

      foreach (KeyValuePair<string, string> pair in newOrUpdatedHbmMappingFiles)
      {
        NewOrUpdatedHbmMappingFiles.Add(pair.Key, pair.Value);
      }

      DeletedCodeFiles.AddRange(deletedCodeFiles);
      DeletedHbmMappingFiles.AddRange(deletedHbmMappingFiles);

      LockFiles(new List<string>(NewOrUpdatedCodeFiles.Keys));
      LockFiles(new List<string>(NewOrUpdatedHbmMappingFiles.Keys));
      LockFiles(DeletedCodeFiles);
      LockFiles(DeletedHbmMappingFiles);
    }

    public void GetInterfaceCode(ref Dictionary<string, string> updatedInterfaceCodeFiles,
                                 ref List<string> deletedInterfaceCodeFiles)
    {
      SyncData.GetInterfaceFileContents(ref updatedInterfaceCodeFiles, ref deletedInterfaceCodeFiles);
    }

    internal void GetTempHbmMappingFileNames(out Dictionary<Entity, string> newHbmMappingFiles,
                                             out Dictionary<Entity, string> deletedHbmMappingFiles,
                                             out Dictionary<Entity, string> modifiedHbmMappingFiles)
    {
      SyncData.GetTempHbmMappingFileNames(out newHbmMappingFiles,
                                          out deletedHbmMappingFiles,
                                          out modifiedHbmMappingFiles);
    }

    /// <summary>
    ///   Build the entity assembly
    ///   Build the computed properties
    ///    - if this fails, disable computed property
    ///   Build the rules
    ///    - if this fails, disable rules
    /// </summary>
    public void Build()
    {
      BuildEntities();
    }

    public void Commit()
    {
      CommitEntities();
    }

    public void UnlockFilesAndRestoreAssembly()
    {
      FileStream fileStream;

      // Restore the original assembly from the backup
      if (File.Exists(BackupEntityAssembly))
      {
        LockedFiles.TryGetValue(EntityAssemblyName, out fileStream);

        if (fileStream != null)
        {
          fileStream.Close();
        }

        File.Copy(BackupEntityAssembly, EntityAssemblyWithPath, true);

        LockedFiles.Remove(EntityAssemblyName);
      }

      foreach(string fileName in LockedFiles.Keys)
      {
        fileStream = LockedFiles[fileName];
        if (fileStream != null)
        {
          fileStream.Close();
        }
      }
    }
    /// <summary>
    ///   Create ExtensionName.EntityGroupName.ComputedProperty.csproj in
    ///   RMP\extensions\ExtensionName\BusinessEntity\EntityGroupName\ComputedProperty
    /// </summary>
    public void CreateComputedPropertyCsProjFile()
    {
      string computedPropertyDir = SystemConfig.GetComputedPropertyDir(ExtensionName, EntityGroupName);
      if (!Directory.Exists(computedPropertyDir))
      {
        Directory.CreateDirectory(computedPropertyDir);
        Directory.CreateDirectory(SystemConfig.GetComputedPropertyTempDir(ExtensionName, EntityGroupName));
      }
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as EntityGroupData;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.ExtensionName.Equals(ExtensionName, StringComparison.InvariantCultureIgnoreCase) &&
             compareTo.EntityGroupName.Equals(EntityGroupName, StringComparison.InvariantCultureIgnoreCase);
    }

    public override int GetHashCode()
    {
      return (ExtensionName + "." + EntityGroupName).GetHashCode();
    }

    public override string ToString()
    {
      return String.Format("Extension='{0}', EntityGroup='{1}'", ExtensionName, EntityGroupName);
    }
    #endregion

    #region Public Properties
    public string ExtensionName { get; set; }
    public string EntityGroupName { get; set; }

    public string EntityDir { get; private set; }
    public string EntityTempDir { get; private set; }
    public string ComputedPropertyDir { get; private set; }

    public string EntityAssemblyName { get; private set; }
    public string EntityAssemblyWithPath { get; private set; }

    public string CsProjFileName { get; private set; }
    public string ComputedPropertyAssemblyName { get; private set; }

    public string BackupEntityAssembly { get; private set; }

    public string TempEntityOutputAssembly { get; private set; }

    public Dictionary<string, string> NewOrUpdatedCodeFiles { get; private set; }
    public Dictionary<string, string> NewOrUpdatedHbmMappingFiles { get; private set; }
    public List<string> DeletedCodeFiles { get; private set; }
    public List<string> DeletedHbmMappingFiles { get; private set; }

    public SyncData SyncData { get; set; }
    public BuildGraph BuildGraph { get; set; }
    #endregion

    #region Internal Methods
    /// <summary>
    ///   Set the value of MustBuild to true if any of the following are true:
    ///   - hbm files must be overwritten
    ///   - the entity assembly does not exist
    ///   - any hbm for this entity group has a timestamp greater than the timestamp of the entity assembly
    /// </summary>
    internal void SetBuildStatus()
    {
      if (!File.Exists(EntityAssemblyWithPath) || SyncData.OverwriteHbm)
      {
        MustBuild = true;
        return;
      }

      DateTime assemblyDateTime = File.GetLastWriteTime(EntityAssemblyWithPath);
      DateTime maxHbmFileDateTime = SyncData.GetMaxHbmFileDateTime();

      MustBuild = maxHbmFileDateTime > assemblyDateTime ? true : false;
    }
    #endregion

    #region Internal Properties
    internal bool MustBuild { get; set; }
    #endregion

    #region Private Properties
    private Dictionary<string, FileStream> LockedFiles { get; set; }
    #endregion

    #region Private Methods

    private bool MustBuildComputedPropertyAssembly()
    {
      if (MustBuild ||
          SyncData.NewComputedPropertyDataList.Count > 0 ||
          SyncData.DeletedComputedPropertyDataList.Count > 0)
      {
        return true;
      }

      return false;
    }

    private void BuildEntities()
    {
      if (!MustBuild)
      {
        return;
      }

      logger.Debug(String.Format("Building entity assembly '{0}' for entity group '{1}' in directory '{2}'", 
                                 EntityAssemblyName, EntityGroupName, EntityTempDir));

      List<ReferenceAssembly> entityReferenceAssemblies = GetStandardEntityAssemblies();
      entityReferenceAssemblies.AddRange
        (BuildGraph.GetDependentAssembliesForEntityGroup(ExtensionName, EntityGroupName).ConvertAll(s => new ReferenceAssembly(s)));

      string[] csprojFiles = Directory.GetFiles(EntityTempDir, "*.csproj", SearchOption.TopDirectoryOnly);
      // Create the csproj, if it doesn't exist
      if (!csprojFiles.Contains(Path.Combine(EntityTempDir, CsProjFileName)))
      {
        string csProjContent =
        BuildUtil.CreateCsProjFile(Name.GetEntityNamespace(ExtensionName, EntityGroupName),
                                   EntityAssemblyName,
                                   entityReferenceAssemblies);

        Check.Require(!String.IsNullOrEmpty(csProjContent), "csProjContent cannot be null or empty");
        string csProjFileName =
          Path.Combine(EntityTempDir, Name.GetEntityCsProjFileName(ExtensionName, EntityGroupName));

        logger.Debug(String.Format("Creating entity csproj file '{0}' in directory '{1}'", csProjFileName, EntityTempDir));

        File.WriteAllText(csProjFileName, csProjContent);
      }

      FileStream fileStream;
      LockedFiles.TryGetValue(EntityAssemblyName, out fileStream);

      if (fileStream != null)
      {
        // Unlock original
        fileStream.Close();
      }

      // Build
      TempEntityOutputAssembly =
        BuildUtil.BuildDir(EntityTempDir,
                           NewOrUpdatedCodeFiles,
                           DeletedCodeFiles,
                           NewOrUpdatedHbmMappingFiles,
                           DeletedHbmMappingFiles,
                           entityReferenceAssemblies,
                           new List<string>(),
                           CsProjFileName);

      // If TempOutputAssembly is null, no assembly was built - because there was nothing to compile
      // Delete the assembly from RMP\bin
      if (TempEntityOutputAssembly == null)
      {
        if (File.Exists(EntityAssemblyWithPath))
        {
          File.Delete(EntityAssemblyWithPath);
        }
      }
      else
      {
        // Copy TempOutputAssembly to RMP\bin
        File.Copy(TempEntityOutputAssembly, EntityAssemblyWithPath, true);
      }
    }

    private List<ReferenceAssembly> GetStandardEntityAssemblies()
    {
      var referenceAssemblies = 
        new List<ReferenceAssembly>
          {
            new ReferenceAssembly("MetraTech.DomainModel.Enums.Generated.dll"),
            new ReferenceAssembly("MetraTech.DomainModel.BaseTypes.dll"),
            new ReferenceAssembly("MetraTech.Basic.dll"),
            new ReferenceAssembly("MetraTech.BusinessEntity.Core.dll"),
            new ReferenceAssembly("MetraTech.BusinessEntity.DataAccess.dll"),
            // the interface assembly has been copied to RMP\bin
            new ReferenceAssembly(Name.GetInterfaceAssemblyNameFromExtension(ExtensionName))
          };

      return referenceAssemblies;
    }

    private void LockFiles(IEnumerable<string> fileNames)
    {
      foreach(string fileName in fileNames)
      {
        LockFile(fileName);
      }
    }

    private void LockFile(string fileName)
    {
      string fileNameWithPath = Path.Combine(EntityDir, fileName);
      if (File.Exists(fileNameWithPath))
      {
        LockedFiles.Add(fileName, DirectoryUtil.LockFile(fileNameWithPath));
      }
    }

    private void UnlockFiles(IEnumerable<string> fileNames)
    {
      foreach (string fileName in fileNames)
      {
        UnlockFile(fileName);
      }
    }

    private void UnlockFile(string fileName)
    {
      FileStream fileStream;
      LockedFiles.TryGetValue(fileName, out fileStream);

      if (fileStream != null)
      {
        fileStream.Close();
      }
    }

    private void UnlockAndCopyFiles(IEnumerable<string> fileNames)
    {
      foreach (string fileName in fileNames)
      {
        UnlockAndCopyFile(fileName);
      }
    }

    private void UnlockAndCopyFile(string fileName)
    {
      string tempFileNameWithPath = Path.Combine(EntityTempDir, fileName);
      Check.Require(File.Exists(tempFileNameWithPath),
                    String.Format("Cannot find file '{0}'", tempFileNameWithPath));

      string fileNameWithPath = Path.Combine(EntityDir, fileName);
      FileStream fileStream;
      LockedFiles.TryGetValue(fileName, out fileStream);

      if (fileStream != null)
      {
        fileStream.Close();
      }

      DirectoryUtil.CopyIfDifferent(tempFileNameWithPath, fileNameWithPath);
    }

    private void UnlockAndDeleteFiles(IEnumerable<string> fileNames)
    {
      foreach (string fileName in fileNames)
      {
        UnlockAndDeleteFile(fileName);
      }
    }

    private void UnlockAndDeleteFile(string fileName)
    {
      FileStream fileStream;
      LockedFiles.TryGetValue(fileName, out fileStream);

      if (fileStream != null)
      {
        fileStream.Close();
      }

      string fileNameWithPath = Path.Combine(EntityDir, fileName);
      if (File.Exists(fileNameWithPath))
      {
        File.Delete(fileNameWithPath);
      }
    }

    private void CommitEntities()
    {
      if (!MustBuild)
      {
        return;
      }

      UnlockAndCopyFile(CsProjFileName);

      UnlockAndCopyFiles(NewOrUpdatedCodeFiles.Keys);

      if (SyncData.OverwriteHbm)
      {
        UnlockAndCopyFiles(NewOrUpdatedHbmMappingFiles.Keys);
      }
      else
      {
        UnlockFiles(NewOrUpdatedHbmMappingFiles.Keys);
      }

      UnlockAndDeleteFiles(DeletedCodeFiles);
      UnlockAndDeleteFiles(DeletedHbmMappingFiles);

      // Unlock the assembly
      FileStream fileStream;
      LockedFiles.TryGetValue(EntityAssemblyName, out fileStream);
      if (fileStream != null)
      {
        fileStream.Close();
      }

      // Copy the assembly to directories specified in be.cfg.xml
      CopyAssemblyToDirectoriesSpecifiedInConfig(EntityAssemblyWithPath);
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("EntityGroupData");
    #endregion
  }
}
