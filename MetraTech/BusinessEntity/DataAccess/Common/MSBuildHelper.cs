using System;
using System.Collections.Generic;
using System.IO;
using System.EnterpriseServices.Internal;
using System.Text;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using Microsoft.Build.BuildEngine;

using MetraTech.Basic.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.DataAccess.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  /// <summary>
  /// </summary>
  public static class MSBuildHelper
  {
    #region Public Methods

    

   

    
    /// <summary>
    ///   Build the interfaces for each entity.
    ///   Each item in entities must have a valid interface file.
    /// </summary>
    /// <param name="entities"></param>
    /// <returns></returns>
    public static List<ErrorObject> BuildInterfaces(ICollection<Entity> entities)
    {
      var errors = new List<ErrorObject>();

      Check.Require(entities != null, "Argument 'entities' cannot be null", SystemConfig.CallerInfo);
      if (entities.Count == 0)
      {
        return errors;
      }

      var entityByExtensionAndEntityGroup = GetEntitiesByExtensionAndGroup(entities);
      foreach (string extensionName in entityByExtensionAndEntityGroup.Keys)
      {
        string outputAssemblyFile;
        var entityList = new List<Entity>();

        var entityGroups = entityByExtensionAndEntityGroup[extensionName];

        foreach (string entityGroupName in entityGroups.Keys)
        {
          entityList.AddRange(entityGroups[entityGroupName]);
        }

        errors.AddRange(BuildInterfaces(extensionName, entityList, out outputAssemblyFile));
      }

      return errors;
    }

    /// <summary>
    ///   Build the entities.
    ///   Each item in entities must have a valid hbm.xml file and a valid .cs file.
    /// </summary>
    /// <param name="entities"></param>
    /// <returns></returns>
    public static List<ErrorObject> BuildEntities(ICollection<Entity> entities)
    {
      var errors = new List<ErrorObject>();

      Check.Require(entities != null, "Argument 'entities' cannot be null", SystemConfig.CallerInfo);
      if (entities.Count == 0)
      {
        return errors;
      }

      var entityByExtensionAndEntityGroup = GetEntitiesByExtensionAndGroup(entities);
      foreach (string extensionName in entityByExtensionAndEntityGroup.Keys)
      {
        var entityGroups = entityByExtensionAndEntityGroup[extensionName];
        foreach(string entityGroupName in entityGroups.Keys)
        {
          string outputAssemblyFile;
          List<Entity> entityList = entityGroups[entityGroupName];
          errors.AddRange(BuildEntities(extensionName, entityGroupName, entityList, out outputAssemblyFile));
        }
      }

      return errors;
    }

    public static List<ErrorObject> BuildInterfaces(string extensionName)
    {
      string outputAssemblyFile;
      return BuildInterfaces(extensionName, null, out outputAssemblyFile);
    }

    public static List<ErrorObject> BuildInterfaces(string extensionName, 
                                                    ICollection<Entity> entities,
                                                    out string outputAssemblyFile)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "Argument 'extensionName' cannot be null", SystemConfig.CallerInfo);

      var errors = new List<ErrorObject>();
      outputAssemblyFile = String.Empty;

      if (entities == null || entities.Count == 0)
      {
        logger.Debug(String.Format("BuildInterfaces called without any entities. " +
                                   "Building interfaces for all entities in extension '{0}'",
                                   extensionName));

        entities = MetadataRepository.Instance.GetEntities(extensionName, true);
      }

      #region Create csProj file if necessary

      var csProjFile = Name.GetInterfaceCsProjFile(extensionName, false);

      // Create it, if it doesn't exist
      if (String.IsNullOrEmpty(csProjFile))
      {
        csProjFile = Name.CreateInterfaceCsProj(extensionName);
      }

      Check.Ensure(!String.IsNullOrEmpty(csProjFile), "csProjFile cannot be null or empty", SystemConfig.CallerInfo);
      Check.Ensure(File.Exists(csProjFile), String.Format("Cannot find file '{0}'", csProjFile), SystemConfig.CallerInfo);
      #endregion

      #region Get interface .cs files
      var csFiles = new List<string>();
      foreach(Entity entity in entities)
      {
        if (entity.ExtensionName.ToLower() != extensionName.ToLower())
        {
          var message = String.Format("The extension name for entity '{0}' does not match the specified extension '{1}'",
                                         entity.FullName,
                                         extensionName);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }

        string interfaceCodeFile = Name.GetInterfaceCodeFileWithPath(entity.FullName);
        if (String.IsNullOrEmpty(interfaceCodeFile))
        {
          var message = String.Format("Interface code file must be specified for entity '{0}'", entity.FullName);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }
        else
        {
          csFiles.Add(interfaceCodeFile);
        }
      }

      if (errors.Count > 0)
      {
        return errors;
      }
      #endregion

      // Create the MS Build project file and build
      var logFile = Path.Combine(Name.GetInterfaceDir(extensionName), "build.log");
      var outputDir = SystemConfig.GetBinDir();
      string msBuildProjFile;

      var references = GetInterfaceReferences(entities, TypeCategory.Interface);
      

      errors.AddRange(CreateMsBuildProjectAndBuild(extensionName,
                                                   null,
                                                   csProjFile,
                                                   outputDir,
                                                   logFile,
                                                   csFiles,
                                                   null,
                                                   references,
                                                   out msBuildProjFile,
                                                   out outputAssemblyFile));
      return errors;
    }

    public static List<ErrorObject> BuildEntities(string extensionName, string entityGroupName)
    {
      string outputAssemblyFile;
      return BuildEntities(extensionName, entityGroupName, null, out outputAssemblyFile);
    }

    /// <summary>
    ///    All the entities must have the specified extensionName and entityGroupName.
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <param name="entities"></param>
    /// <param name="outputAssemblyFile"></param>
    /// <returns></returns>
    public static List<ErrorObject> BuildEntities(string extensionName, 
                                                  string entityGroupName,
                                                  ICollection<Entity> entities,
                                                  out string outputAssemblyFile)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "Argument 'extensionName' cannot be null", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "Argument 'entityGroupName' cannot be null", SystemConfig.CallerInfo);

      var errors = new List<ErrorObject>();
      outputAssemblyFile = String.Empty;
      
      if (entities == null || entities.Count == 0)
      {
        logger.Debug(String.Format("BuildEntities called without any entities. " +
                                   "Building all entities for extension '{0}' and entity group '{1}'",
                                   extensionName, entityGroupName));

        entities = MetadataRepository.Instance.GetEntities(extensionName, entityGroupName, true);
      }

      string tempDir = Name.GetEntityTempDir(extensionName, entityGroupName);
      if (Directory.Exists(tempDir))
      {
        // Delete files in Temp dir
        Array.ForEach(Directory.GetFiles(tempDir), File.Delete);
      }

      #region Create csProj file, if necessary

      // Get the csproj file
      var csProjFile = Name.GetEntityCsProjFile(extensionName, entityGroupName, false);

      // Create it, if it doesn't exist
      if (String.IsNullOrEmpty(csProjFile))
      {
        csProjFile = Name.CreateEntityCsProj(extensionName, entityGroupName);
      }

      Check.Ensure(!String.IsNullOrEmpty(csProjFile), "csProjFile cannot be null or empty", SystemConfig.CallerInfo);
      Check.Ensure(File.Exists(csProjFile), String.Format("Cannot find file '{0}'", csProjFile), SystemConfig.CallerInfo);
      #endregion

      #region Get hbm.xml and .cs files
      var csFiles = new List<string>();
      var hbmFiles = new List<string>();

      // Collect the hbm.xml file and cs file for each entity
      foreach(Entity entity in entities)
      {
        if (entity.ExtensionName.ToLower() != extensionName.ToLower())
        {
          string message = String.Format("The extension name for entity '{0}' does not match the specified extension '{1}'", 
                                         entity.FullName,
                                         extensionName);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }

        if (entity.EntityGroupName.ToLower() != entityGroupName.ToLower())
        {
          string message = String.Format("The entity group name for entity '{0}' does not match the specified entity group '{1}'",
                                         entity.FullName,
                                         entityGroupName);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }

        string hbmFileName = Name.GetHbmFileNameWithPath(entity.FullName);
        if (!File.Exists(hbmFileName))
        {
          string message = String.Format("Cannot find mapping file '{0}' for entity '{1}'", hbmFileName, entity.FullName);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }

        string codeFileName = Name.GetCodeFileNameWithPath(entity.FullName);
        if (!File.Exists(codeFileName))
        {
          string message = String.Format("Cannot find code file '{0}' for entity '{1}'", codeFileName, entity.FullName);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        }

        csFiles.Add(codeFileName);
        hbmFiles.Add(hbmFileName);
      }

      if (errors.Count > 0)
      {
        return errors;
      }
      #endregion

      // Create the MS Build project file and build
      var logFile = Path.Combine(Name.GetEntityDir(extensionName, entityGroupName), "build.log");
      var outputDir = SystemConfig.GetBinDir();
      string msBuildProjFile;

      var references = GetInterfaceReferences(entities, TypeCategory.Class);

      errors.AddRange(CreateMsBuildProjectAndBuild(extensionName,
                                                   entityGroupName,
                                                   csProjFile,
                                                   outputDir,
                                                   logFile,
                                                   csFiles,
                                                   hbmFiles,
                                                   references,
                                                   out msBuildProjFile,
                                                   out outputAssemblyFile));

      return errors;
    }

    

    /// <summary>
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public static List<ErrorObject> RemoveEntityFromCsProj(string entityName)
    {
      string extensionName, entityGroupName;
      Name.GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
      string csFileName = Name.GetCodeFileNameWithPath(entityName);
      string hbmFileName = Name.GetHbmFileNameWithPath(entityName);
      if (File.Exists(csFileName) && File.Exists(hbmFileName))
      {
        return RemoveEntityFromCsProj(extensionName, 
                                      entityGroupName,
                                      new List<string> { csFileName },
                                      new List<string> { hbmFileName });

      }

      return new List<ErrorObject>();
    }

    /// <summary>
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <param name="csFiles"></param>
    /// <param name="hbmMappingFiles"></param>
    public static List<ErrorObject> RemoveEntityFromCsProj(string extensionName, 
                                                           string entityGroupName, 
                                                           ICollection<string> csFiles, 
                                                           ICollection<string> hbmMappingFiles)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(extensionName), "entityGroupName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(csFiles != null && csFiles.Count > 0, "csFiles cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(hbmMappingFiles != null && hbmMappingFiles.Count > 0, "hbmMappingFiles cannot be null or empty", SystemConfig.CallerInfo);

      string csProjFile = Name.GetEntityCsProjFile(extensionName, entityGroupName, true);
      Check.Require(!String.IsNullOrEmpty(csProjFile), String.Format("csProjFile cannot be null or empty for extension '{0}' and entity group '{1}'", extensionName, entityGroupName), SystemConfig.CallerInfo);
      Check.Require(File.Exists(csProjFile), String.Format("csProjFile '{0}' cannot be found for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName), SystemConfig.CallerInfo);
      
      List<ErrorObject> errors = new List<ErrorObject>();

      csFiles.ForEach(file =>
      {
        if (!File.Exists(Path.Combine(Name.GetEntityDir(extensionName, entityGroupName), file)))
        {
          string message = String.Format("The specified cs file '{0}' cannot be found.", file);
          errors.Add(new ErrorObject(message));
        }
      });

      hbmMappingFiles.ForEach(file =>
      {
        if (!File.Exists(Path.Combine(Name.GetEntityDir(extensionName, entityGroupName), file)))
        {
          string message = String.Format("The specified hbm mapping file '{0}' cannot be found.", file);
          errors.Add(new ErrorObject(message));
        }
      });

      // Cannot proceed if there are errors
      if (errors.Count > 0)
      {
        return errors;
      }

      try
      {
        Project csProject = new Project();
        csProject.Load(csProjFile);

        BuildItemGroup buildItemGroup = null;
        BuildItem buildItem = null;

        csFiles.ForEach(file =>
        {
          if (FileExistsInCsProj(csProject, file, "Compile", out buildItemGroup, out buildItem))
          {
            buildItemGroup.RemoveItem(buildItem);
          }
        });

        hbmMappingFiles.ForEach(file =>
        {
          if (FileExistsInCsProj(csProject, file, "EmbeddedResource", out buildItemGroup, out buildItem))
          {
            buildItemGroup.RemoveItem(buildItem);
          }
        });

        logger.Debug(String.Format("Updating visual studio project file '{0}' for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName));
        csProject.Save(csProjFile);
        logger.Debug(String.Format("Updated visual studio project file '{0}' for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName));
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot save project file '{0}' for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName);
        errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        logger.Error(message, e);
      }

      return errors;
    }

    public static List<ErrorObject> RemoveInterfaceFromCsProj(string extensionName,
                                                 string csFile)
    {
      return RemoveInterfaceFromCsProj(extensionName,  new List<string> { csFile });
    }

    /// <summary>
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="csFiles"></param>
    public static List<ErrorObject> RemoveInterfaceFromCsProj(string extensionName,
                                                              ICollection<string> csFiles)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      var errors = new List<ErrorObject>();

      if (csFiles == null || csFiles.Count == 0)
      {
        return errors;
      }

      string csProjFile = Name.GetInterfaceCsProjFile(extensionName, true);
      Check.Require(!String.IsNullOrEmpty(csProjFile), String.Format("Interface csProjFile cannot be null or empty for extension '{0}'", extensionName), SystemConfig.CallerInfo);
      Check.Require(File.Exists(csProjFile), String.Format("Interface csProjFile '{0}' cannot be found for extension '{1}'", csProjFile, extensionName), SystemConfig.CallerInfo);

      csFiles.ForEach(file =>
      {
        if (!File.Exists(Path.Combine(Name.GetInterfaceDir(extensionName), file)))
        {
          string message = String.Format("The specified cs file '{0}' cannot be found.", file);
          errors.Add(new ErrorObject(message));
        }
      });

      // Cannot proceed if there are errors
      if (errors.Count > 0)
      {
        return errors;
      }

      try
      {
        Project csProject = new Project();
        csProject.Load(csProjFile);

        BuildItemGroup buildItemGroup = null;
        BuildItem buildItem = null;

        csFiles.ForEach(file =>
        {
          if (FileExistsInCsProj(csProject, file, "Compile", out buildItemGroup, out buildItem))
          {
            buildItemGroup.RemoveItem(buildItem);
          }
        });

        logger.Debug(String.Format("Updating visual studio project file '{0}' for extension '{1}'", csProjFile, extensionName));
        csProject.Save(csProjFile);
        logger.Debug(String.Format("Updated visual studio project file '{0}' for extension '{1}'", csProjFile, extensionName));
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot save project file '{0}' for extension '{1}'", csProjFile, extensionName);
        errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        logger.Error(message, e);
      }

      return errors;
    }

    /// <summary>
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <param name="file"></param>
    /// <returns></returns>
    public static bool CSharpFileExistsInCsProj(string extensionName, string entityGroupName, string file)
    {
      return FileExistsInCsProj(Name.GetEntityCsProjFile(extensionName, entityGroupName, true), file, "Compile");
    }

    /// <summary>
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <param name="file"></param>
    /// <returns></returns>
    public static bool HbmMappingFileExistsInCsProj(string extensionName, string entityGroupName, string file)
    {
      return FileExistsInCsProj(Name.GetEntityCsProjFile(extensionName, entityGroupName, true), file, "EmbeddedResource");
    }

    public static string BackupCsProj(string extensionName, string entityGroupName)
    {
      string csProjFile = Name.GetEntityCsProjFile(extensionName, entityGroupName, true);
      return FileHelper.BackupFile(csProjFile);
    }

    public static void RestoreCsProj(string fileName)
    {
      if (Path.GetExtension(fileName).Equals("csproj", StringComparison.InvariantCultureIgnoreCase))
      {
        string message = String.Format("The specified file '{0}' does not have a csproj extension.", fileName);
        throw new MetadataException(message, SystemConfig.CallerInfo);
      }

      FileHelper.RestoreFile(fileName);
    }
    #endregion

    #region Private Methods
    
    /// <summary>
    ///    Create a MSBuild project file (*.proj) based on the specified csproj file.
    ///    The .proj file is created in the same directory as the csproj file.
    ///    outputDir specifies the location of the generated assembly when the msBuildProjectFile is run.
    ///    
    ///    .cs files that are not present in the csProjFile may be passed in via csFiles.
    ///    .hbm.xml files that are not present in the csProjFile may be passed in via hbmMappingFiles.
    /// </summary>
    /// <param name="csprojFile"></param>
    /// <param name="outputDir"></param>
    /// <param name="msBuildProjectFile"></param>
    /// <returns></returns>
    private static void CreateMSBuildProjectFile(string extensionName,
                                                 string entityGroupName,
                                                 string csprojFile, 
                                                 string outputDir, 
                                                 List<string> csFiles,
                                                 List<string> hbmMappingFiles,
                                                 List<string> references,
                                                 out string msBuildProjectFile,
                                                 out string outputAssemblyFile)
    {
      List<ErrorObject> errors = new List<ErrorObject>();
      msBuildProjectFile = String.Empty;
      outputAssemblyFile = String.Empty;

      if (!File.Exists(csprojFile))
      {
        string message = String.Format("Cannot find file '{0}'.", csprojFile);
        throw new MetadataException(message, SystemConfig.CallerInfo);
      }

      Project csProject = new Project();
      csProject.Load(csprojFile);

      List<string> projReferences = new List<string>();
      bool signAssembly = false;
      string keyFile = String.Empty;
      string assemblyName = String.Empty;
      string rootNamespace = String.Empty;

      // So we don't update the incoming Lists
      List<string> projCsFiles = new  List<string>();
      projCsFiles.AddRange(csFiles);
      List<string> projHbmFiles = new List<string>();
      if (hbmMappingFiles != null)
      {
        projHbmFiles.AddRange(hbmMappingFiles);
      }

      if (references != null)
      {
        projReferences.AddRange(references);
      }

      #region Retrieve relevant data from the csproj file
      foreach (BuildPropertyGroup buildPropertyGroup in csProject.PropertyGroups)
      {
        foreach (BuildProperty buildProperty in buildPropertyGroup)
        {
          if (buildProperty.Name == "AssemblyName")
          {
            if (String.IsNullOrEmpty(assemblyName))
            {
              assemblyName = buildProperty.Value;
            }
          }
          else if (buildProperty.Name == "RootNamespace")
          {
            if (String.IsNullOrEmpty(rootNamespace))
            {
              rootNamespace = buildProperty.Value;
            }
          }
          else if (buildProperty.Name == "SignAssembly")
          {
            signAssembly = Convert.ToBoolean(buildProperty.Value);
          }
          else if (buildProperty.Name == "AssemblyOriginatorKeyFile")
          {
            if (String.IsNullOrEmpty(keyFile))
            {
              keyFile = buildProperty.Value;
            }
          }
        }
      }

      Check.Assert(!String.IsNullOrEmpty(assemblyName),
                   String.Format("Cannot find 'AssemblyName' in project file '{0}'.", csprojFile),
                   SystemConfig.CallerInfo);

      Check.Assert(!String.IsNullOrEmpty(rootNamespace),
                   String.Format("Cannot find 'RootNamespace' in project file '{0}'.", csprojFile),
                   SystemConfig.CallerInfo);

      if (signAssembly)
      {
        Check.Assert(!String.IsNullOrEmpty(rootNamespace),
                     String.Format("Cannot find 'AssemblyOriginatorKeyFile' in project file '{0}'.", csprojFile),
                     SystemConfig.CallerInfo);
      }

      foreach (BuildItemGroup buildItemGroup in csProject.ItemGroups)
      {
        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          if (buildItem.Name == "Compile")
          {
            if (!csFiles.Exists(f => Path.GetFileName(f).Equals(Path.GetFileName(buildItem.Include), StringComparison.InvariantCultureIgnoreCase)))
            {
              projCsFiles.Add(buildItem.Include.ReplaceMtRmp());
            }
          }
          else if (buildItem.Name == "Reference")
          {
            string itemToAdd = buildItem.GetMetadata("HintPath");
            if (String.IsNullOrEmpty(itemToAdd))
            {
              itemToAdd = buildItem.Include;
            }

            if (!references.Exists(f => Path.GetFileName(f).Equals(Path.GetFileName(itemToAdd), StringComparison.InvariantCultureIgnoreCase)))
            {
              projReferences.Add(itemToAdd.ReplaceMtRmp());
            }
          }
          else if (buildItem.Name == "EmbeddedResource")
          {
            if (buildItem.Include.EndsWith("hbm.xml"))
            {
              if (!hbmMappingFiles.Exists(f => Path.GetFileName(f).Equals(Path.GetFileName(buildItem.Include), StringComparison.InvariantCultureIgnoreCase)))
              {
                string tempDir = Name.GetEntityTempDir(extensionName, entityGroupName);
                if (!Directory.Exists(tempDir))
                {
                  Directory.CreateDirectory(tempDir);
                }
                // Visual Studio build prefixes resource files with the assembly namespace so we're going to do it as well
                string fileName =
                  Path.Combine(tempDir,
                               rootNamespace + "." + buildItem.Include.Replace(Path.DirectorySeparatorChar.ToString(), "."));

                projHbmFiles.Add(fileName);

                File.Copy(Path.Combine(Name.GetEntityDir(extensionName, entityGroupName), buildItem.Include),
                          fileName);
              }
            }
          }
        }
      }

      #endregion

      #region Create the msbuild project file
      msBuildProjectFile = csprojFile.Replace(".csproj", ".Generated.proj");
      Project msBuildProject = new Project();
      msBuildProject.DefaultToolsVersion = csProject.ToolsVersion;
      msBuildProject.DefaultTargets = "Compile";

      BuildItemGroup itemGroup = msBuildProject.AddNewItemGroup();

      // Add the references. 
      projReferences.ForEach(reference =>
      {
        if (reference.EndsWith(".dll"))
        {
          itemGroup.AddNewItem("Reference", reference);
        }
        else
        {
          itemGroup.AddNewItem("Reference", reference + ".dll");
        }
      });

      msBuildProject.AddNewItemGroup();
      // Add the cs files
      projCsFiles.ForEach(csFile => itemGroup.AddNewItem("Compile", csFile));
      
      // Add the hbm.xml files
      projHbmFiles.ForEach(hbmConfigFile => itemGroup.AddNewItem("EmbeddedResource", hbmConfigFile));

      // Create the target
      const string compileTargetName = "Compile";

      Target compileTarget = msBuildProject.Targets.AddNewTarget(compileTargetName);
      BuildTask cscTask = compileTarget.AddNewTask("Csc");
      cscTask.SetParameterValue("Sources", "@(Compile)");
      if (projHbmFiles.Count > 0)
      {
        cscTask.SetParameterValue("Resources", "@(EmbeddedResource)");
      }

      if (projReferences.Count > 0)
      {
        cscTask.SetParameterValue("References", "@(Reference)");
      }
      cscTask.SetParameterValue("TargetType", "library");
      // cscTask.SetParameterValue("EmitDebugInformation", "true");
      outputAssemblyFile = Path.Combine(outputDir, assemblyName + ".dll");
      cscTask.SetParameterValue("OutputAssembly", outputAssemblyFile);
      if (signAssembly)
      {
        cscTask.SetParameterValue("KeyFile", keyFile.ReplaceMtRmp());
      }

      // Copy output to RMPBIN
      const string postBuildTargetName = "PostBuild";
      Target postBuildTarget = msBuildProject.Targets.AddNewTarget(postBuildTargetName);
      postBuildTarget.DependsOnTargets = compileTargetName;
      BuildTask copyTask = postBuildTarget.AddNewTask("Copy");
      copyTask.SetParameterValue("SourceFiles", outputAssemblyFile);
      copyTask.SetParameterValue("DestinationFolder", SystemConfig.GetBinDir());

      // Default target
      msBuildProject.DefaultTargets = postBuildTargetName;

      // Create the file
      msBuildProject.Save(msBuildProjectFile);

      #endregion
    }

    private static List<ErrorObject> BuildMSProjectFiles(List<string> projectFiles, 
                                                         string buildLogFile,
                                                         string outputDir)
    {
      List<ErrorObject> errors = new List<ErrorObject>();

      Engine engine = new Engine();
      // engine.BinPath = RuntimeEnvironment.GetRuntimeDirectory();

      // Instantiate a new FileLogger to generate build log
      FileLogger fileLogger = new FileLogger();

      // Set the logfile parameter to indicate the log destination
      fileLogger.Parameters = @"logfile=" + buildLogFile;

      // Register the logger with the engine
      engine.RegisterLogger(fileLogger);

      // Build the project files
      try
      {
        foreach (string projFile in projectFiles)
        {
          bool success = engine.BuildProjectFile(projFile);
          if (success)
          {
            logger.Debug(String.Format("Successfully built files in directory '{0}' using project file '{1}'.", 
                                       outputDir, projFile));
          }
          else
          {
            string errorMessage = 
              String.Format("Failed to build files in directory '{0}' using project file '{1}'. " +
                            "See log file '{2}' for errors.", outputDir, projFile, buildLogFile);
            errors.Add(new ErrorObject(errorMessage));
          }
        }
      }
      finally
      {
        //Unregister all loggers to close the log file
        engine.UnregisterAllLoggers();
      }

      return errors;
    }


    private static bool FileExistsInCsProj(string csProjFile,
                                           string fileName,
                                           string buildItemName)
    {
      BuildItemGroup buildItemGroup = null;
      BuildItem buildItem = null;
      Project csProject = new Project();
      csProject.Load(csProjFile);

      return FileExistsInCsProj(csProject, fileName, buildItemName, out buildItemGroup, out buildItem);
    }

    private static bool FileExistsInCsProj(Project csProject,
                                           string fileName,
                                           string buildItemName)
    {
      BuildItemGroup buildItemGroup = null;
      BuildItem buildItem = null;
      return FileExistsInCsProj(csProject, fileName, buildItemName, out buildItemGroup, out buildItem);
    }

    private static bool FileExistsInCsProj(Project project, 
                                           string fileName, 
                                           string buildItemName,
                                           out BuildItemGroup theBuildItemGroup,
                                           out BuildItem theBuildItem)
    {
      theBuildItem = null;
      theBuildItemGroup = null;

      foreach (BuildItemGroup buildItemGroup in project.ItemGroups)
      {
        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          // Handle Reference items separately
          if (buildItem.Name == "Reference" && buildItemName == "Reference")
          {
            if (buildItem.Name == buildItemName &&
                Path.GetFileName(buildItem.Include)
               .Equals(Path.GetFileNameWithoutExtension(fileName), StringComparison.InvariantCultureIgnoreCase))
            {
              theBuildItemGroup = buildItemGroup;
              theBuildItem = buildItem;
              return true;
            }
          }

          if (buildItem.Name == buildItemName && 
              Path.GetFileName(buildItem.Include)
               .Equals(Path.GetFileName(fileName), StringComparison.InvariantCultureIgnoreCase))
          {
            theBuildItemGroup = buildItemGroup;
            theBuildItem = buildItem;
            return true;
          }
        }
      }

      return false;
    }

    private static void ValidateAssembliesExist(IEnumerable<string> assemblies)
    {
      foreach (string assembly in assemblies)
      {
        string message = String.Format("Expected output assembly '{0}' cannot be found", assembly);
        Check.Assert(File.Exists(assembly), message, SystemConfig.CallerInfo);
      }
    }

    private static void RegisterAssembliesInGac(IEnumerable<string> assemblies)
    {
      Publish publish = new Publish();
      foreach (string assembly in assemblies)
      {
        publish.GacInstall(assembly);
      }
    }

    private static List<ErrorObject> ValidateAndRegisterInGac(IEnumerable<string> assemblies, bool registerInGac)
    {
      List<ErrorObject> errors = new List<ErrorObject>();

      assemblies.ForEach(assembly =>
       {
         if (!File.Exists(assembly))
         {
           string message = String.Format("Expected output assembly '{0}' cannot be found", assembly);
           errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
           logger.Error(message);
         }

         if (registerInGac)
         {
           GacHelper.AddAssemblyToCache(assembly);
         }
       });

      return errors;
    }

    private static Dictionary<string, Dictionary<string, List<Entity>>> GetEntitiesByExtensionAndGroup(ICollection<Entity> entities)
    {
      var entityByExtensionAndEntityGroup = new Dictionary<string, Dictionary<string, List<Entity>>>();

      #region Classify entites by extension and entity group
      foreach (Entity entity in entities)
      {
        Check.Require(!String.IsNullOrEmpty(entity.ExtensionName));
        Check.Require(!String.IsNullOrEmpty(entity.EntityGroupName));

        if (entityByExtensionAndEntityGroup.ContainsKey(entity.ExtensionName))
        {
          // Found extension, get entityGroups
          var entityGroups = entityByExtensionAndEntityGroup[entity.ExtensionName];
          // Found entity group
          if (entityGroups.ContainsKey(entity.EntityGroupName))
          {
            // Add entity
            var entityList = entityGroups[entity.EntityGroupName];
            entityList.Add(entity);
          }
          else
          {
            // Create new entity group entry
            var entityList = new List<Entity>();
            entityList.Add(entity);
            entityGroups.Add(entity.EntityGroupName, entityList);
          }
        }
        else
        {
          var entityGroups = new Dictionary<string, List<Entity>>();
          var entityList = new List<Entity>();
          entityList.Add(entity);
          entityGroups.Add(entity.EntityGroupName, entityList);
          entityByExtensionAndEntityGroup.Add(entity.ExtensionName, entityGroups);
        }
      }
      #endregion

      return entityByExtensionAndEntityGroup;
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <param name="csProjFile"></param>
    /// <param name="logFile"></param>
    /// <param name="outputDir"></param>
    /// <param name="csFiles"></param>
    /// <param name="hbmFiles"></param>
    /// <param name="references"></param>
    /// <param name="msBuildProjFile"></param>
    /// <param name="outputAssemblyFile"></param>
    /// <returns></returns>
    public static List<ErrorObject> CreateMsBuildProjectAndBuild(string extensionName, 
                                                                 string entityGroupName,
                                                                 string csProjFile,
                                                                 string outputDir,
                                                                 string logFile,
                                                                 List<string> csFiles,
                                                                 List<string> hbmFiles,
                                                                 List<string> references,
                                                                 out string msBuildProjFile,
                                                                 out string outputAssemblyFile)
    {
      logger.Debug(String.Format("Generating msbuild project file for extension '{0}' and entity group '{1}'", extensionName, entityGroupName));

      var errors = new List<ErrorObject>();
      // Create the MS Build project file
      CreateMSBuildProjectFile(extensionName,
                               entityGroupName,
                               csProjFile,
                               outputDir,
                               csFiles,
                               hbmFiles,
                               references,
                               out msBuildProjFile,
                               out outputAssemblyFile);

      #region Build

      logger.Debug(String.Format("Building entities for extension '{0}' and entity group '{1}'", extensionName, entityGroupName));

      errors.AddRange(BuildMSProjectFiles(new List<string> { msBuildProjFile }, logFile, outputDir));

      // Validate that the outputAssemblyFile exists
      if (errors.Count == 0)
      {
        if (!File.Exists(outputAssemblyFile))
        {
          var message = String.Format("Expected output assembly '{0}' cannot be found", outputAssemblyFile);
          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
          logger.Error(message);
        }
      }

      // Delete msbuild project file
      if (errors.Count == 0)
      {
        if (File.Exists(msBuildProjFile))
        {
          File.Delete(msBuildProjFile);
        }

        if (File.Exists(logFile))
        {
          File.Delete(logFile);
        }

        // Update csproj
        errors.AddRange(AddToCsProj(extensionName, 
                                    entityGroupName, 
                                    csProjFile, 
                                    csFiles, 
                                    hbmFiles,
                                    references));
      }

      // Delete files in Temp dir
      if (!String.IsNullOrEmpty(entityGroupName))
      {
        string tempDir = Name.GetEntityTempDir(extensionName, entityGroupName);
        if (Directory.Exists(tempDir))
        {
          Array.ForEach(Directory.GetFiles(tempDir), File.Delete);
        }
      }

      #endregion

      return errors;
    }

    /// <summary>
    ///    Update the csproj file for the tenant by adding the specified csFiles and hbmMappingFiles.
    ///    The csFiles and hbmMappingFiles are expected to be found in the BusinessEntity directory of the specified tenant.
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <param name="csProjFile"></param>
    /// <param name="csFiles"></param>
    /// <param name="hbmMappingFiles"></param>
    /// <param name="references"></param>
    private static List<ErrorObject> AddToCsProj(string extensionName,
                                                 string entityGroupName,
                                                 string csProjFile,
                                                 ICollection<string> csFiles,
                                                 ICollection<string> hbmMappingFiles,
                                                 ICollection<string> references)
    {
      var errors = new List<ErrorObject>();

      if (csFiles == null && hbmMappingFiles == null && references == null)
      {
        return errors;
      }

      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(csProjFile), String.Format("csProjFile cannot be null or empty for extension '{0}' and entity group '{1}'", extensionName, entityGroupName), SystemConfig.CallerInfo);
      Check.Require(File.Exists(csProjFile), String.Format("csProjFile '{0}' cannot be found for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName), SystemConfig.CallerInfo);

      var fileDir = Path.GetDirectoryName(csProjFile);

      if (csFiles != null)
      {
        csFiles.ForEach(file =>
        {
          if (!File.Exists(Path.Combine(fileDir, file)))
          {
            string message = String.Format("The specified cs file '{0}' cannot be found.", file);
            errors.Add(new ErrorObject(message));
          }
        });
      }

      if (hbmMappingFiles != null)
      {
        hbmMappingFiles.ForEach(file =>
        {
          if (!File.Exists(Path.Combine(fileDir, file)))
          {
            string message =
              String.Format("The specified hbm mapping file '{0}' cannot be found.", file);
            errors.Add(new ErrorObject(message));
          }
        });
      }

      if (references != null)
      {
        references.ForEach(file =>
        {
          if (!File.Exists(Path.Combine(fileDir, file)))
          {
            string message =
              String.Format("The specified reference '{0}' cannot be found.", file);
            errors.Add(new ErrorObject(message));
          }
        });
      }

      // Cannot proceed if there are errors
      if (errors.Count > 0)
      {
        return errors;
      }

      try
      {
        var csProject = new Project();
        csProject.Load(csProjFile);
        string directory = Path.GetDirectoryName(csProjFile);

        BuildItemGroup buildItemGroup = null;
        foreach(BuildItemGroup itemGroup in csProject.ItemGroups)
        {
          buildItemGroup = itemGroup;
          break;
        }
        
        if (buildItemGroup == null)
        {
          buildItemGroup = csProject.AddNewItemGroup();
        }

        csFiles.ForEach(file =>
        {
          if (!FileExistsInCsProj(csProject, file, "Compile"))
          {
            buildItemGroup.AddNewItem("Compile", file.Replace(directory + Path.DirectorySeparatorChar, ""));
          }
        });

        if (hbmMappingFiles != null)
        {
          hbmMappingFiles.ForEach(file =>
          {
            if (!FileExistsInCsProj(csProject, file, "EmbeddedResource"))
            {
              buildItemGroup.AddNewItem("EmbeddedResource",
                                        file.Replace(directory + Path.DirectorySeparatorChar,
                                                     ""));
            }
          });
        }

        if (references != null)
        {
          references.ForEach(file =>
          {
            if (!FileExistsInCsProj(csProject, file, "Reference"))
            {
              BuildItem referenceItem = buildItemGroup.AddNewItem("Reference", Path.GetFileNameWithoutExtension(file));
              referenceItem.SetMetadata("SpecificVersion", "false");
              referenceItem.SetMetadata("HintPath", Path.Combine("$(MTRMPBIN)", Path.GetFileName(file)));
              referenceItem.SetMetadata("Private", "false");
            }
          });
        }

        logger.Debug(String.Format("Updating visual studio project file '{0}' for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName));
        csProject.Save(csProjFile);
        logger.Debug(String.Format("Updated visual studio project file '{0}' for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName));
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot save project file '{0}' for extension '{1}' and entity group '{2}'", csProjFile, extensionName, entityGroupName);
        errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
        logger.Error(message, e);
      }

      return errors;
    }

    private static List<string> GetInterfaceReferences(ICollection<Entity> entities, TypeCategory typeCategory)
    {
      var references = new List<string>();
      ICollection<string> assemblyNames;

      foreach (Entity entity in entities)
      {
        if (typeCategory == TypeCategory.Interface)
        {
          assemblyNames = entity.GetInterfaceAssemblyNames(false, true);
        }
        else
        {
          assemblyNames = entity.GetInterfaceAssemblyNames(true, true);
        }

        foreach (string assemblyName in assemblyNames)
        {
          if (!references.Contains(assemblyName))
          {
            references.Add(assemblyName);
          }
        }
      }

      return references;
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("MSBuildHelper");
    #endregion
  }
}
