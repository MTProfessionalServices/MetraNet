using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using Microsoft.Build.BuildEngine;

namespace MetraTech.Basic
{
  #pragma warning disable 618
  public static class BuildUtil
  {
    /// <summary>
    ///   Create and return the contents of a visual studio project file, based on 
    ///   the specified rootNamespace and the specified referenceAssemblies.
    ///   
    ///   The output assembly will have the same name as the rootNamespace.
    /// </summary>
    /// <param name="rootNamespace"></param>
    /// <param name="referenceAssemblies"></param>
    /// <returns></returns>
    public static string CreateCsProjFile(string rootNamespace,
                                          List<ReferenceAssembly> referenceAssemblies)
    {
      return CreateCsProjFile(rootNamespace, rootNamespace, referenceAssemblies);
    }

    /// <summary>
    ///   Create and return the contents of a visual studio project file, based on 
    ///   the specified rootNamespace, assembly name (without extension) and the specified referenceAssemblies.
    /// </summary>
    /// <param name="rootNamespace"></param>
    /// <param name="assemblyName"></param>
    /// <param name="referenceAssemblies"></param>
    /// <returns></returns>
    public static string CreateCsProjFile(string rootNamespace,
                                          string assemblyName,
                                          List<ReferenceAssembly> referenceAssemblies)
    {
      Check.Require(!String.IsNullOrEmpty(rootNamespace), "rootNamespace cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(assemblyName), "assemblyName cannot be null or empty", SystemConfig.CallerInfo);

      var csProjFile = new StringBuilder(File.ReadAllText(SystemConfig.GetTemplateCsProjFile()));

      csProjFile.Replace("%%PROJECT_GUID%%", Guid.NewGuid().ToString());
      csProjFile.Replace("%%ROOT_NAMESPACE%%", rootNamespace);
      csProjFile.Replace("%%ASSEMBLY_NAME%%", assemblyName.ToLower().EndsWith(".dll") ? 
                                              assemblyName.Replace(".dll", "") :
                                              assemblyName);

      var references = new StringBuilder(String.Empty);
      if (referenceAssemblies != null)
      {
        referenceAssemblies.ForEach(r => references.Append(GetReferenceSnippet(r)));
      }

      csProjFile.Replace("%%REFERENCE_ITEMS%%", references.ToString());

      return csProjFile.ToString();
    }

    /// <summary>
    ///   Build the items in buildDir together with the new code and new references. 
    /// 
    ///   Pre-conditions:
    ///   (1) buildDir must be a valid directory
    ///   (2) buildDir must contain one and only one csproj file
    /// 
    ///   Steps:
    ///   (1) Create (or clean) the temp directory
    ///   (2) Copy the items in buildDir to the temp directory
    ///   (3) Build the items in tempDir
    ///   (4) Copy all the relevant files from the tempDir to buildDir
    ///   (5) Clean temp dir
    /// 
    /// </summary>
    /// <param name="buildDir">directory to build. Must contain a .csproj file</param>
    /// <param name="addCodeFiles">Maps the file name (without path) to the file content</param>
    /// <param name="addReferenceAssemblies">List of ReferenceAssembly</param>
    public static void AddFilesAndBuild(string buildDir,
                                        Dictionary<string, string> addCodeFiles,
                                        List<ReferenceAssembly> addReferenceAssemblies)
    {
      CheckPreconditions(buildDir);

      #region Setup Temp directory
      // Create or clean the temp dir
      string tempDir = Path.Combine(buildDir, "Temp");
      // Copy files from buildDir to tempDir
      SetupTempDir(buildDir, tempDir);
      #endregion

      // Build the files in tempDir
      BuildDir(tempDir, 
               addCodeFiles, 
               new List<string>(), 
               new Dictionary<string, string>(),
               new List<string>(),
               addReferenceAssemblies,
               new List<string>());

      #region Copy files from temp to buildDir
      string[] files = Directory.GetFiles(tempDir);
      foreach (string file in files)
      {
        File.WriteAllText(Path.Combine(buildDir, Path.GetFileName(file)), File.ReadAllText(file));
      }
      #endregion

      #region Delete temp
      DirectoryUtil.CleanDir(tempDir);
      #endregion
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="buildDir"></param>
    /// <param name="deletedFiles"></param>
    /// <param name="deletedReferences"></param>
    public static void DeleteFilesAndBuild(string buildDir,
                                           List<string> deletedFiles,
                                           List<string> deletedReferences)
    {

    }

    public static void SetupTempDir(string buildDir,
                                    string tempDir,
                                    Dictionary<string, FileStream> lockedFiles = null)
    {
      if (!Directory.Exists(tempDir))
      {
        Directory.CreateDirectory(tempDir);
      }
      else
      {
        DirectoryUtil.CleanDir(tempDir);
      }

      // Copy files from buildDir to tempDir
      string[] files = Directory.GetFiles(buildDir);
      foreach (string file in files)
      {
        // Ignore .sln, .suo, .user files 
        string extension = Path.GetExtension(file).ToLower();
        if (extension == ".sln" ||
            extension == ".suo" ||
            extension == ".user")
        {
          continue;
        }

          if (lockedFiles != null)
          {
              if (lockedFiles.Count > 0)
              {
                  FileStream fileStream;
                  lockedFiles.TryGetValue(Path.GetFileName(file), out fileStream);
                  if (fileStream != null)
                  {
                      fileStream.Close();
                  }
              }
          }
          try
          {
              File.Copy(file, Path.Combine(tempDir, Path.GetFileName(file)));
          }
          catch (System.Exception e)
          {
              logger.Warn("File copy of file into temp folder is missed (file should be already there) " + e.Message);
          }
      }
    }

    public static bool HasCsProjFile(string dir)
    {
      string[] csprojFiles = Directory.GetFiles(dir, "*.csproj", SearchOption.TopDirectoryOnly);

      if (csprojFiles == null || csprojFiles.Length == 0)
      {
        return false;
      }

      return true;
    }

    public static string BuildDir(string dir,
                                Dictionary<string, string> addCodeFiles,
                                List<string> deleteCodeFiles,
                                List<ReferenceAssembly> addReferenceAssemblies,
                                string csProjFileName = null)
    {
      return BuildDir(dir, 
                      addCodeFiles, 
                      deleteCodeFiles, 
                      new Dictionary<string, string>(), 
                      new List<string>(), 
                      addReferenceAssemblies, 
                      new List<string>(),
                      csProjFileName);
    }

   
    /// <summary>
    ///   Return the path to the output assembly. 
    ///   Returns null, if there are no files to build.
    /// </summary>
    /// <param name="dir"></param>
    /// <param name="addCodeFiles"></param>
    /// <param name="deleteCodeFiles"></param>
    /// <param name="addEmbeddedResources"></param>
    /// <param name="deleteEmbeddedResources"></param>
    /// <param name="addReferenceAssemblies"></param>
    /// <param name="deleteReferenceAssemblies"></param>
    /// <returns></returns>
    public static string BuildDir(string dir,
                                  Dictionary<string, string> addCodeFiles,
                                  List<string> deleteCodeFiles,
                                  Dictionary<string, string> addEmbeddedResources,
                                  List<string> deleteEmbeddedResources,
                                  List<ReferenceAssembly> addReferenceAssemblies,
                                  List<string> deleteReferenceAssemblies,
                                  string csProjFileName = null)
    {
      Check.Require(addCodeFiles != null, "addCodeFiles cannot be null", SystemConfig.CallerInfo);
      Check.Require(deleteCodeFiles != null, "deleteCodeFiles cannot be null", SystemConfig.CallerInfo);

      Check.Require(addEmbeddedResources != null, "addEmbeddedResources cannot be null", SystemConfig.CallerInfo);
      Check.Require(deleteEmbeddedResources != null, "deleteEmbeddedResources cannot be null", SystemConfig.CallerInfo);

      Check.Require(addReferenceAssemblies != null, "addReferenceAssemblies cannot be null", SystemConfig.CallerInfo);
      Check.Require(deleteReferenceAssemblies != null, "deleteReferenceAssemblies cannot be null", SystemConfig.CallerInfo);

      // Get the csProj file
      string[] csProjFiles = Directory.GetFiles(dir, "*.csproj");

      Check.Require(csProjFiles.Length > 0, String.Format("Cannot find .csproj file in directory '{0}'", dir));

      string csProjFile = !String.IsNullOrEmpty(csProjFileName) ?  Path.Combine(dir,csProjFileName) : csProjFiles[0];
      
      // Load csproj
      var csProject = new Project();
      csProject.Load(csProjFile);

      // Get the compile items (with the path and lowercased).
      List<string> compileItems = csProject.GetCompileItems();

      // Remove compileItems from the csproj file - that don't exist in the file system
      compileItems.ForEach(e =>
      {
        if (!File.Exists(Path.Combine(dir, Path.GetFileName(e))))
        {
          logger.Warn(
            String.Format("Removing code file '{0}' from csproj file '{1}' because it is not found in directory '{2}'",
                          e, csProjFile, dir));

          deleteCodeFiles.Add(Path.GetFileName(e));
        }
      });

      var newCompileItems = new List<string>();

      #region Resolve Compile Items
      // Create the new files
      foreach (string fileName in addCodeFiles.Keys)
      {
        string fileNameWithPath = Path.Combine(dir, Path.GetFileName(fileName));
        string content = addCodeFiles[fileName];

        Check.Require(!String.IsNullOrEmpty(content),
                      String.Format("The content for file '{0}' cannot be empty", fileName),
                      SystemConfig.CallerInfo);

        File.WriteAllText(fileNameWithPath, content);

        // Add this file to the list of items to compile (if necessary)
        if (!compileItems.Exists(c => Path.GetFileName(c).ToLowerInvariant() ==
                                      Path.GetFileName(fileName).ToLowerInvariant()))
        {
          compileItems.Add(fileName);
          newCompileItems.Add(fileName);
        }
      }

      // Delete the files in the deleteFiles list and remove them from compileItems
      foreach (string fileName in deleteCodeFiles)
      {
        compileItems.RemoveAll(c => Path.GetFileName(c).ToLowerInvariant() ==
                                    Path.GetFileName(fileName).ToLowerInvariant());

        if (File.Exists(Path.Combine(dir, fileName)))
        {
          File.Delete(Path.Combine(dir, fileName));
        }
      }

      if (compileItems.Count == 0)
      {
        return null;
      }
      #endregion

      // Get the embedded resources.
      List<string> embeddedResources = csProject.GetEmbeddedResources();

      // Remove embeddedResources from the csproj file - that don't exist in the file system
      embeddedResources.ForEach(e =>
        {
          if (!File.Exists(Path.Combine(dir, Path.GetFileName(e))))
          {
            logger.Warn(
              String.Format("Removing resource '{0}' from csproj file '{1}' because the resource file is not found in directory '{2}'",
                            e, csProjFile, dir));

            deleteEmbeddedResources.Add(Path.GetFileName(e));
          }
        });

      var newEmbeddedResources = new List<string>();

      #region Resolve Embedded Resources

      // Create the new files
      foreach (string fileName in addEmbeddedResources.Keys)
      {
        string fileNameWithPath = Path.Combine(dir, Path.GetFileName(fileName));
        string content = addEmbeddedResources[fileName];

        Check.Require(!String.IsNullOrEmpty(content),
                      String.Format("The content for file '{0}' cannot be empty", fileName),
                      SystemConfig.CallerInfo);

        File.WriteAllText(fileNameWithPath, content);

        // Add this file to the list of items to compile (if necessary)
        if (!embeddedResources.Exists(c => Path.GetFileName(c).ToLowerInvariant() == 
                                           Path.GetFileName(fileName).ToLowerInvariant()))
        {
          embeddedResources.Add(fileName.ToLowerInvariant());
          newEmbeddedResources.Add(fileName.ToLowerInvariant());
        }
      }

      // Delete the files in the deleteEmbeddedResources list and remove them from embeddedResources
      foreach (string fileName in deleteEmbeddedResources)
      {
        embeddedResources.RemoveAll(c => Path.GetFileName(c).ToLowerInvariant() ==
                                         Path.GetFileName(fileName).ToLowerInvariant());
        if (File.Exists(Path.Combine(dir, fileName)))
        {
          File.Delete(Path.Combine(dir, fileName));
        }
      }
      #endregion

      // Get the reference items (with the path and lowercased).
      List<string> references = csProject.GetReferences();
      var newReferences = new List<ReferenceAssembly>();

      #region Resolve References
      // Add the reference items in the addReferenceAssemblies list
      foreach (ReferenceAssembly referenceAssembly in addReferenceAssemblies)
      {
        if (!references.Exists(r => Path.GetFileName(r).ToLowerInvariant() == 
                                    Path.GetFileName(referenceAssembly.Name).ToLowerInvariant()))
        {
          if (referenceAssembly.IsSystem || !referenceAssembly.UseRmpBinForBuild)
          {
            references.Add(referenceAssembly.Name);
          }
          else 
          {
            references.Add(Path.Combine(SystemConfig.GetRmpBinDir(), referenceAssembly.Name));
          }

          newReferences.Add(referenceAssembly);
        }
        else
        {
          // Replace the existing reference with the new one, if necessary
          if (!referenceAssembly.UseRmpBinForBuild)
          {
            references.RemoveAll(r => Path.GetFileName(r).ToLowerInvariant() == 
                                      Path.GetFileName(referenceAssembly.Name).ToLowerInvariant());
            references.Add(referenceAssembly.Name);
          }
        }
      }

      // Remove the reference items in the deleteReferenceAssemblies list
      foreach (string referenceAssembly in deleteReferenceAssemblies)
      {
        references.RemoveAll(r => Path.GetFileNameWithoutExtension(r).ToLower() ==
                                  Path.GetFileNameWithoutExtension(referenceAssembly.ToLower()));
      }

      #endregion

      #region Create msbuild project

      string msBuildProjectFile = csProjFile.Replace(".csproj", ".Generated.proj");
      var msBuildProject = new Project();
      msBuildProject.DefaultToolsVersion = csProject.ToolsVersion;
      msBuildProject.DefaultTargets = "Compile";

      // Add items
      msBuildProject.AddReferencesForMsBuildProj(references);
      msBuildProject.AddCompileItems(compileItems);
      msBuildProject.AddEmbeddedResources(embeddedResources);

      #region Other
      // Target
      const string compileTargetName = "Compile";

      Target compileTarget = msBuildProject.Targets.AddNewTarget(compileTargetName);
      BuildTask cscTask = compileTarget.AddNewTask("Csc");
      cscTask.SetParameterValue("Sources", "@(Compile)");

      if (references.Count > 0)
      {
        cscTask.SetParameterValue("References", "@(Reference)");
      }

      if (embeddedResources.Count > 0)
      {
        cscTask.SetParameterValue("Resources", "@(EmbeddedResource)");
      }

      cscTask.SetParameterValue("TargetType", "library");

      // Set the output assembly
      string assemblyName = csProject.GetAssemblyName();
      Check.Assert(!String.IsNullOrEmpty(assemblyName),
                   String.Format("Cannot find 'AssemblyName' in project file '{0}'.", csProjFile),
                   SystemConfig.CallerInfo);

      // Create output in the specified directory
      string outputAssemblyFile = Path.Combine(dir, assemblyName + ".dll");
      cscTask.SetParameterValue("OutputAssembly", outputAssemblyFile);

      // Set the key file
      string keyFile;
      bool signAssembly = csProject.GetSignAssembly(out keyFile);
      if (signAssembly)
      {
        Check.Assert(!String.IsNullOrEmpty(keyFile),
                     String.Format("Cannot find 'AssemblyOriginatorKeyFile' in project file '{0}'.", csProjFile),
                     SystemConfig.CallerInfo);

        cscTask.SetParameterValue("KeyFile", keyFile);
      }

      // Default target
      msBuildProject.DefaultTargets = compileTargetName;

      // Create the file
      msBuildProject.Save(msBuildProjectFile);
      #endregion

      #endregion

      #region Build
      Engine engine = new Engine();

      // Instantiate a new FileLogger to generate build log
      FileLogger fileLogger = new FileLogger();

      // Set the logfile parameter to indicate the log destination
      string logFile = Path.Combine(dir, "build.log");
      fileLogger.Parameters = @"logfile=" + logFile;

      // Register the logger with the engine
      engine.RegisterLogger(fileLogger);

      bool successBuild = false;
      try
      {
        successBuild = engine.BuildProjectFile(msBuildProjectFile);
      }
      finally
      {
        //Unregister all loggers to close the log file
        engine.UnregisterAllLoggers();

        if (successBuild)
        {
          logger.Debug(String.Format("Successfully built files in directory '{0}' using project file '{1}'.",
                                      dir, csProjFile));
        }
        else
        {
          string errorMessage =
            String.Format("Failed to build files in directory '{0}' using project file '{1}'", dir, csProjFile);

          string buildMessages = File.ReadAllText(logFile);

          logger.Error(errorMessage + String.Format("Build output: '{0}'", buildMessages));

          throw new BuildException(errorMessage);
        }
      }
      #endregion

      #region Update csProj
      csProject.AddCompileItems(newCompileItems);
      csProject.RemoveCompileItems(deleteCodeFiles);

      csProject.AddEmbeddedResources(newEmbeddedResources);
      csProject.RemoveEmbeddedResources(deleteEmbeddedResources);

      csProject.AddReferencesForCsProj(newReferences);
      csProject.RemoveReferences(deleteReferenceAssemblies);

      csProject.Save(csProjFile);
      #endregion

      // Delete log file, msbuild proj file
      // File.Delete(logFile);
      // File.Delete(msBuildProjectFile);

      return outputAssemblyFile;
    }

    #region Private Methods
    private static void CheckPreconditions(string buildDir)
    {
      Check.Require(!String.IsNullOrEmpty(buildDir), "buildDir cannot be null or empty");
      Check.Require(Directory.Exists(buildDir), String.Format("Cannot find directory '{0}'", buildDir));

      string[] csprojFiles = Directory.GetFiles(buildDir, "*.csproj", SearchOption.TopDirectoryOnly);

      if (csprojFiles == null || csprojFiles.Length == 0)
      {
        string message = String.Format("Cannot find .csproj file in directory '{0}'", buildDir);
        throw new BuildException(message);
      }

      if (csprojFiles.Length > 1)
      {
        string message = String.Format("Found more than one .csproj file in directory '{0}'", buildDir);
        throw new BuildException(message);
      }
    }

    

    
    private static BuildItemGroup GetBuildItemGroup(Project project)
    {
      BuildItemGroup buildItemGroup = null;
      foreach (BuildItemGroup itemGroup in project.ItemGroups)
      {
        buildItemGroup = itemGroup;
        break;
      }

      if (buildItemGroup == null)
      {
        buildItemGroup = project.AddNewItemGroup();
      }

      return buildItemGroup;
    }

    private static string GetReferenceSnippet(ReferenceAssembly referenceAssembly)
    {
      string referenceSnippet;

      if (referenceAssembly.IsSystem)
      {
        referenceSnippet =
          "\n<Reference Include=\"" + Path.GetFileNameWithoutExtension(referenceAssembly.Name) + "\"/>\n";
      }
      else
      {
        referenceSnippet =
          "\n<Reference Include=\"" + Path.GetFileNameWithoutExtension(referenceAssembly.Name) + "\">\n" +
          "<SpecificVersion>False</SpecificVersion>\n" +
          "<HintPath>$(MTRMPBIN)\\" + referenceAssembly.Name + "</HintPath>\n" +
          "<Private>False</Private>\n" +
          "</Reference>\n";
      }
   
      return referenceSnippet;
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("BuildUtil");
    #endregion
  }
}
