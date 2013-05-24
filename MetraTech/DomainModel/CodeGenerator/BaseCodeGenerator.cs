using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.Reflection;
using System.Xml;
using System.Xml.Linq;
using System.Linq;
using System.Resources;
using System.Security.Cryptography;
using System.Diagnostics;
using Microsoft.CSharp;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Interop.RCD;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.CodeGenerator
{
  public abstract class BaseCodeGenerator
  {
    #region Static Methods
    //ESR-4289 Hard-coded languages in the domain model code generator
    private static Dictionary<string, string> GetLanguageMappings()
    {
      string configFile = BaseCodeGenerator.RCD.ConfigDir + @"domainmodel\config.xml";
      if (!File.Exists(configFile))
      {
        logger.LogError((String.Format("Cannot find domain model config file '{0}'", configFile)));
      }

      var languageMappings = new Dictionary<string, string>();

      IEnumerable<XElement> languageSpecs =
        from s in XElement.Load(configFile).Elements("language")
        select s;

      foreach (XElement languageSpec in languageSpecs)
      {
        XAttribute metratechCode = languageSpec.Attribute("metratech");

        if (metratechCode == null)
        {
          throw new ApplicationException(String.Format("Cannot find 'metratech' attribute for 'language' element in config file '{0}'", configFile));
        }

        if (String.IsNullOrEmpty(metratechCode.Value))
        {
          throw new ApplicationException(String.Format("The 'metratech' attribute for 'language' element in config file  '{0}' cannot be empty", configFile));
        }

        XAttribute standardCode = languageSpec.Attribute("standard");
        if (standardCode == null)
        {
          throw new ApplicationException(String.Format("Cannot find 'standardCode' attribute for 'language' element in config file '{0}'", configFile));
        }

        if (String.IsNullOrEmpty(standardCode.Value))
        {
          throw new ApplicationException(String.Format("The 'standardCode' attribute for 'language' element in config file  '{0}' cannot be empty", configFile));
        }

        languageMappings.Add(metratechCode.Value, standardCode.Value);
      }

      return languageMappings;
    }
    public static void CleanShadowCopyDir()
    {
      try
      {
        if (Directory.Exists(ShadowCopyDir))
        {
          Directory.Delete(ShadowCopyDir, true);
        }
      }
      catch (Exception e)
      {
        logger.LogInfo(String.Format("Cannot delete shadow copy dir '{0}' because: '{1}'", ShadowCopyDir, e.Message));
      }
    }

    /// <summary>
    ///    Copy the given assembly from the local bin directory to a temporary folder and load it from there.
    /// </summary>
    /// <param name="assemblyName"></param>
    /// <returns></returns>
    public static Assembly GetAssembly(string assemblyName)
    {
      Assembly assembly = null;

      string assemblyPath = Path.Combine(SystemConfig.GetBinDir(), assemblyName);
      if (!File.Exists(assemblyPath))
      {
        logger.LogDebug(String.Format("Unable to find assembly '{0}' in directory '{1}'", assemblyName, SystemConfig.GetBinDir()));
        return assembly;
      }

      try
      {
        if (assemblyName.ToLower().EndsWith(".dll", true, null))
        {
          string name = assemblyName.ToLower().Replace(".dll", "");
          assembly = Assembly.Load(name);
        }
      }
      catch (Exception)
      {
        // For the webapp, AppDomain.CurrentDomain.BaseDirectory will be one level higher than
        // the bin directory
        if (!assemblyName.EndsWith(".dll", true, null))
        {
          assemblyName = assemblyName + ".dll";
        }
      
        string[] files =
          Directory.GetFiles(AppDomain.CurrentDomain.BaseDirectory, assemblyName, SearchOption.AllDirectories);

        if (files == null || files.Length == 0)
        {
          throw new ApplicationException(string.Format("Unable to find assembly '{0]' in BaseDirectory : {1}", assemblyName, AppDomain.CurrentDomain.BaseDirectory));
        }

        string fileNameWithPath = files[0];

        try
        {
          string mtTempDir = Path.Combine(Path.GetTempPath(), "MTCodeGeneration");
          if (!Directory.Exists(mtTempDir))
          {
            Directory.CreateDirectory(mtTempDir);
          }

          string tempAssemblyPath = Path.Combine(mtTempDir, Path.GetFileName(fileNameWithPath));

          if (!File.Exists(tempAssemblyPath))
          {
            File.Copy(fileNameWithPath, tempAssemblyPath, true);
          }
          else
          {
            // File exists. If the file time has changed, then copy the file
            // to a guid based directory and load it from there.
            DateTime originalFileTime = File.GetLastWriteTime(fileNameWithPath);
            DateTime tempFileTime = File.GetLastWriteTime(tempAssemblyPath);

            if (originalFileTime > tempFileTime)
            {
              DirectoryInfo dirInfo = Directory.CreateDirectory(Path.Combine(mtTempDir, Guid.NewGuid().ToString()));
              tempAssemblyPath = Path.Combine(dirInfo.FullName, Path.GetFileName(fileNameWithPath));
              File.Copy(fileNameWithPath, tempAssemblyPath, true);
            }
          }

          assembly = Assembly.LoadFrom(tempAssemblyPath);
        }
        catch (Exception e)
        {
          //logger.LogException("Unable to load assembly 'MetraTech.DomainModel.BaseTypes.Generated.dll' from BaseDirectory : " + AppDomain.CurrentDomain.BaseDirectory, e);
          throw new ApplicationException(string.Format("Unable to load assembly '{0}' from BaseDirectory : {1}", assemblyName, AppDomain.CurrentDomain.BaseDirectory), e);
        }
      }
     
      return assembly;
    }

    
    /// <summary>
    ///    Return false (ie. Checksums don't match) if any of the following are true for any FileData in files.
    ///    (1) The checksum key is not found in assemblyChecksums
    ///    (2) The checksum does not match.
    /// </summary>
    /// <param name="assemblyChecksums"></param>
    /// <param name="files"></param>
    /// <returns></returns>
    public bool ChecksumsMatch(Dictionary<string, string> assemblyChecksums, 
                               Dictionary<string, FileData> files)
    {
      if (assemblyChecksums == null || files == null)
      {
        return false;
      }

      Dictionary<string, FileData> localizationChecksumKeys = new Dictionary<string, FileData>();

      foreach(FileData fileData in files.Values)
      {
        if (!ChecksumsMatch(assemblyChecksums, fileData))
        {
          return false;
        }

        foreach(LocalizationFileData localizationFileData in fileData.LocalizationFiles)
        {
          if (localizationChecksumKeys.ContainsKey(localizationFileData.ChecksumKey))
          {
            continue;
          }
          localizationChecksumKeys.Add(localizationFileData.ChecksumKey, localizationFileData);
          if (!ChecksumsMatch(assemblyChecksums, localizationFileData))
          {
            return false;
          }
        }
      }

      // Make sure that all the assemblyChecksum keys are found
      foreach(string key in assemblyChecksums.Keys)
      {
        if (!files.ContainsKey(key) && !localizationChecksumKeys.ContainsKey(key))
        {
          return false;
        }
      }

      return true;
    }

    /// <summary>
    ///    (1) Load the given assembly
    ///    (2) Retrieve the resources for the given checksumResourceFileName embedded in the assembly
    /// </summary>
    /// <param name="assemblyName"></param>
    /// <param name="checksumResourceFileName"></param>
    /// <returns></returns>
    public static Dictionary<string, string> GetChecksums(string assemblyName, string checksumResourceFileName)
    {
      Dictionary<string, string> checksums = null;

      Assembly assembly = GetAssembly(assemblyName);
      if (assembly == null)
      {
        return null;
      }

      // Get the resource stream
      Stream stream = null;
      IResourceReader reader = null;

      try
      {
        using (stream = assembly.GetManifestResourceStream(checksumResourceFileName))
        {
          if (stream == null)
          {
            logger.LogError(String.Format("Unable to load checksum resource '{0}' from assembly '{1}'",
                                          checksumResourceFileName, assembly.FullName));
            return null;
          }

          using (reader = new ResourceReader(stream))
          {
            IDictionaryEnumerator enumerator = reader.GetEnumerator();
            checksums = new Dictionary<string, string>();
            while (enumerator.MoveNext())
            {
              checksums.Add(enumerator.Key.ToString(), enumerator.Value.ToString());
            }
          }
        }
      }
      catch (Exception e)
      {
        logger.LogException(String.Format("Error loading checksum resource '{0}' from assembly '{1}'",
                            checksumResourceFileName, assembly.FullName), e);

        throw;
      }
      finally
      {
        if (stream != null)
        {
          stream.Close();
        }

        if (reader != null)
        {
          reader.Close();
        }
      }

      return checksums;
    }

    /// <summary>
    ///   Get all the files in the given extension\config under the given rootDir with the
    ///   given fileExtension (e.g. xml or msixdef)
    ///   E.g. Given the Account extension and Localization rootDir, return all 
    ///   the xml files under RMP\extensions\Account\config\Localization
    /// </summary>
    /// <param name="extension"></param>
    /// <param name="rootDir"></param>
    /// <param name="fileExtension"></param>
    /// <returns></returns>
    public static List<string> GetFiles(string extension, string rootDir, string fileExtension)
    {
      List<string> files = new List<string>();

      string searchDir = Path.Combine(Path.Combine(RCD.ExtensionDir, extension), "config");

      if (!Directory.Exists(searchDir))
      {
        return files;
      }

      string[] directories =
        Directory.GetDirectories(searchDir, rootDir, SearchOption.AllDirectories);

      foreach (string directory in directories)
      {
        string[] xmlFiles = Directory.GetFiles(directory, "*." + fileExtension, SearchOption.AllDirectories);
        foreach (string xmlFile in xmlFiles)
        {
          files.Add(xmlFile);
        }
      }

      return files;
    }

    /// <summary>
    ///    Calculate the checksum for the given fileName.
    /// </summary>
    /// <param name="filename"></param>
    /// <returns></returns>
    public static string GetMD5ChecksumForFile(string filename)
    {
      string checksum = String.Empty;

      if (filename == null)
      {
        throw new ArgumentNullException("The 'filename' parameter cannot be null.");
      }

      if (!File.Exists(filename))
      {
        throw new ArgumentException(string.Format("Filename '{0}' does not exist.", filename));
      }

      // Adding FileAccess.Read to avoid racing condition in the build.
      using (FileStream fstream = new FileStream(filename, FileMode.Open, FileAccess.Read))
      {
        byte[] hash = new MD5CryptoServiceProvider().ComputeHash(fstream);

        // Convert the byte array to a printable string.
        StringBuilder sb = new StringBuilder(32);
        foreach (byte hex in hash)
        {
          sb.Append(hex.ToString("X2"));
        }
        checksum = sb.ToString().ToUpper();
      }

      return checksum;
    }

    /// <summary>
    ///    Initialize based on DomainModelConfig
    /// </summary>
    /// <returns></returns>
    public static Dictionary<string, Dictionary<string, string>> InitLanguageResources()
    {
      Dictionary<string, Dictionary<string, string>> languageResources = new Dictionary<string, Dictionary<string, string>>();

      foreach(string language in LanguageMappings.Keys)
      {
        languageResources.Add(language, new Dictionary<string, string>());
      }

      return languageResources;
    }

    #endregion

    #region Public Methods

    
    
    
    /// <summary>
    ///    (1) If there are no checksums, the assembly had not been generated
    ///    (2) Look for checksums for each fileName (in fileNames) in the loaded assembly.
    ///        The key is the extension name. Value is the fileName
    ///    (3) If the checksums do not match, then return true.
    ///    (4) If all checkusms match, but there are still more keys left in the assembly,
    ///        then some files must have been removed from the current configuration and 
    ///        we need to re-generate.
    /// </summary>
    /// <param name="assemblyChecksums"></param>
    /// <param name="files"></param>
    /// <returns></returns>
    public bool MustGenerateCode(Dictionary<string, string> assemblyChecksums, List<FileData> files)
    {
      bool generateCode = false;
      
      if (assemblyChecksums == null)
      {
        return true;
      }

      string checksum = String.Empty;
      string originalChecksum = String.Empty;

      foreach (FileData fileData in files)
      {
          if (assemblyChecksums.TryGetValue(fileData.ResourceKey, out originalChecksum))
          {
              if (String.IsNullOrEmpty(fileData.FullPath))
              {
                  checksum = GetMD5ChecksumForFile(fileData.FileName);
              }
              else
              {
                  checksum = GetMD5ChecksumForFile(fileData.FullPath);
              }

              if (originalChecksum != checksum)
              {
                  generateCode = true;
                  break;
              }
          }
          else
          {
              generateCode = true;
              break;
          }
      }

      // At this point all the current files have been
      // accounted for as resource keys in the assembly.
      // The existence of any more keys in the assembly
      // means that some files were removed since the last
      // time the assembly had been built.
      if (!generateCode && files.Count != assemblyChecksums.Keys.Count)
      {
          generateCode = true;
      }      

      return generateCode;
    }

    public string GetChecksumFromStream(Assembly assembly, string key)
    {
      string checksum = String.Empty;

      // Get the resource stream
      Stream stream = assembly.GetManifestResourceStream(checksumResource);
      if (stream == null)
      {
        logger.LogError(String.Format("Unable to load checksum resource '{0}' from assembly '{1}'",
                                      checksumResource, assembly.FullName));
        return checksum;
      }

      IResourceReader reader = new ResourceReader(stream);
      IDictionaryEnumerator enumerator = reader.GetEnumerator();

      while (enumerator.MoveNext())
      {
        if (enumerator.Key.ToString() == key)
        {
          checksum = enumerator.Value as string;
          break;
        }
      }

      reader.Close();

      return checksum;
    }

    /// <summary>
    ///    Build a .resources file that contains the checksums for each file in files keyed by
    ///    FileData.ExtensionName + FileData.FileName
    /// </summary>
    /// <param name="files"></param>
    /// <param name="checksumResourceFile"></param>
    public void BuildChecksumResource(List<FileData> files, out string checksumResourceFile)
    {
      logger.LogDebug(String.Format("Generating checksums."));

      // Path for the .resources files 
      checksumResourceFile = Path.Combine(Path.GetTempPath(), checksumResource);

      ResourceWriter resourceWriter = new ResourceWriter(checksumResourceFile);

      string resourceKey = String.Empty;
      string checksum = String.Empty;

      foreach (FileData fileData in files)
      {
          checksum = GetMD5ChecksumForFile(fileData.FullPath == null ? fileData.FileName : fileData.FullPath);
        resourceWriter.AddResource(fileData.ResourceKey, checksum);
      }
        
      resourceWriter.Generate();
      resourceWriter.Close();
    }

    public static void WriteFile(CodeCompileUnit codeCompileUnit, string fileName)
    {
      CodeDomProvider codeProvider = new CSharpCodeProvider();

      // The CodeGeneratorOptions object allows us to specify
      // various formatting settings that will be used 
      // by the generator.
      CodeGeneratorOptions codeGeneratorOptions = new CodeGeneratorOptions();

      // Here we specify that the curley braces should start 
      // on the line following the opening of the block
      codeGeneratorOptions.BracingStyle = "C";

      // Here we specify that each block should be indented by 2 spaces
      codeGeneratorOptions.IndentString = "  ";

      using (StreamWriter writer = new StreamWriter(new FileStream(fileName, FileMode.Create), Encoding.UTF8))
      {
        codeProvider.GenerateCodeFromCompileUnit(codeCompileUnit, writer, codeGeneratorOptions);
        writer.Flush();
      }
    }

    public static string UpperCaseFirst(string input)
    {
        return StringUtils.UpperCaseFirst(input);
    }

    public static string LowerCaseFirst(string input)
    {
        return StringUtils.LowerCaseFirst(input);
      }

    /// <summary>
    ///   (1) Replace all non alpha-numeric characters from the input string with underscore.
    ///   (2) If the first letter is a digit, prefix with underscore. 
    ///       Otherwise, capitalize the first letter.
    /// 
    ///   Return the modified string.
    /// </summary>
    /// <param name="input"></param>
    /// <returns></returns>
    public static string MakeAlphaNumeric(string input)
    {
        return StringUtils.MakeAlphaNumeric(input);
    }

    public static string GenerateKeyFile()
    {
      string keyFile = Path.Combine(SystemConfig.GetBinDir(), string.Format("GenDMKey{0}.snk", Process.GetCurrentProcess().Id));
      try
      {
        if (File.Exists(keyFile))
        {
          File.Delete(keyFile);
        }

        FileStream wtr = File.Open(keyFile, FileMode.Create, FileAccess.Write, FileShare.None);

        wtr.Write(KeyRes.MetraTech, 0, KeyRes.MetraTech.Length);

        wtr.Flush();
        wtr.Close();
        wtr.Dispose();
      }
      catch (Exception e)
      {
        logger.LogException("Unable to generate key file", e);
        throw;
      }

      return keyFile;
    }
    /// <summary>
    ///    Build an assembly using the specified CodeCompileUnits. The assembly will be
    ///    created in the directory from which this code is being run. 
    ///    
    ///    Returns false, if an error occurs.
    /// 
    /// </summary>
    /// <param name="assemblyName">name of the assembly to be generated</param>
    /// <param name="codeUnits">map of source file name to CodeCompileUnits</param>
    /// <param name="referencedSystemAssemblies">list of referenced system assemblies</param>
    /// <param name="referencedLocalAssemblies">list of referenced local assemblies</param>
    /// <param name="resourceFiles">list of .resources files that will be embedded in this assembly</param>
    /// <param name="debugBuild">Specify true if this is a debug build. False, if it's a release build</param>
    /// <param name="generatedSourceDir">If this is not null or empty, then source files will be generated in this directory.
    ///                                  If the directory does not exist, it will be created.</param>
    public bool BuildAssembly(string assemblyName,
                              Dictionary<string, CodeCompileUnit> codeUnits,
                              List<string> referencedSystemAssemblies,
                              List<string> referencedLocalAssemblies,
                              List<string> resourceFiles,
                              bool debugBuild,
                              string generatedSourceDir)
    {
      string buildMode = "debug";
      if (!debugBuild)
      {
        buildMode = "release";
      }
      logger.LogDebug(String.Format("Building assembly '{0}' in " + buildMode + " mode.", assemblyName));
      bool status = true;

      try
      {
        string keyFile = GenerateKeyFile();

        // Setup compiler options
        string compilerFlags = "/keyfile:" + keyFile;
        CSharpCodeProvider compiler = new CSharpCodeProvider();
        CompilerParameters compilerParameters = new CompilerParameters();
        compilerParameters.GenerateInMemory = false;
        compilerParameters.TempFiles.KeepFiles = false;
        compilerParameters.OutputAssembly = Path.Combine(SystemConfig.GetBinDir(), assemblyName);

        if (debugBuild)
        {
          compilerFlags += " /debug:full ";
          compilerParameters.IncludeDebugInformation = true;
        }
        else
        {
          compilerParameters.IncludeDebugInformation = false;
        }

        compilerParameters.CompilerOptions = compilerFlags;

        // Add referenced system assemblies
        foreach (string referencedSystemAssembly in referencedSystemAssemblies)
        {
          compilerParameters.ReferencedAssemblies.Add(referencedSystemAssembly);
        }

        // Add referenced local assemblies
        foreach (string referencedLocalAssembly in referencedLocalAssemblies)
        {
          compilerParameters.ReferencedAssemblies.Add
            (Path.Combine(SystemConfig.GetBinDir(), referencedLocalAssembly));
        }

        // Embed the .resources
        if (resourceFiles != null)
        {
          foreach (string file in resourceFiles)
          {
            compilerParameters.EmbeddedResources.Add(file);
          }
        }

        // Delete the existing assembly
        //File.Delete(Path.Combine(GetBinDirectory(), assemblyName));

        // Build
        CompilerResults result = null;
        if (!debugBuild)
        {
          CodeCompileUnit[] codeUnitArray = new CodeCompileUnit[codeUnits.Values.Count];
          codeUnits.Values.CopyTo(codeUnitArray, 0);
          result = compiler.CompileAssemblyFromDom(compilerParameters, codeUnitArray);
        }
        else
        {
          logger.LogDebug("Building in Debug Mode");
          #region Compile in Debug Mode
          string path = Path.Combine(SystemConfig.GetBinDir(), "Accounts");

          if (!Directory.Exists(path))
          {
            Directory.CreateDirectory(path);
          }

          string[] fileNames = new string[codeUnits.Count];
          string fileNameWithPath = String.Empty;
          int i = 0;

          foreach (string fileName in codeUnits.Keys)
          {
            try
            {
              fileNameWithPath = Path.Combine(path, fileName);
              WriteFile(codeUnits[fileName] as CodeCompileUnit, fileNameWithPath);
              fileNames[i] = fileNameWithPath;
            }
            catch (Exception e)
            {
              logger.LogException("Error dumping code", e);
              throw e;
            }

            i++;
          }

          result = compiler.CompileAssemblyFromFile(compilerParameters, fileNames);
          #endregion
        }

        // Check for errors
        if (result.Errors.HasErrors || result.Errors.HasWarnings)
        {
          bool throwException = false;

          foreach (CompilerError err in result.Errors)
          {
            if (err.IsWarning)
            {
              logger.LogWarning("Warning {0}: {1} occurred on line {2}, column {3} in file \"{4}\"",
                                err.ErrorNumber, err.ErrorText, err.Line, err.Column, err.FileName);
            }
            else
            {
              logger.LogError("Error {0}: {1} occurred on line {2}, column {3} in file \"{4}\"",
                              err.ErrorNumber, err.ErrorText, err.Line, err.Column, err.FileName);
              throwException = true;
            }

            if (throwException)
            {
              throw new ApplicationException(String.Format("Unable to compile assembly '{0}'", assemblyName));
            }
          }
        }

        // Generate source code if necessary
        if (!String.IsNullOrEmpty(generatedSourceDir))
        {
          string path = Path.Combine(SystemConfig.GetBinDir(), generatedSourceDir);
          if (!Directory.Exists(path))
          {
            Directory.CreateDirectory(path);
          }
          foreach (string fileName in codeUnits.Keys)
          {
            WriteFile(codeUnits[fileName] as CodeCompileUnit, Path.Combine(path, fileName));
          }
        }

        // Copy files to directories specified in RMP\config\domainmodel\config.xml
        CopyAssemblyToDirectoriesSpecifiedInConfig(compilerParameters.OutputAssembly);

        // Delete key file
        //if (File.Exists(keyFileName))
        //{
        //  File.Delete(keyFileName);
        //}

        // Delete resource files
        if (resourceFiles != null)
        {
          foreach (string file in resourceFiles)
          {
            if (File.Exists(file))
            {
              File.Delete(file);
            }
          }
        }
      }
      catch (Exception e)
      {
        string msg = "Unable to build assembly '" + assemblyName + "'.";
        logger.LogException(msg, e);
        throw;
      }

      logger.LogDebug(String.Format("Successfully built assembly '{0}' in " + buildMode + " mode.", assemblyName));

      return status;
    }


    public static CodeMemberProperty CreatePropertyData(string name,
                                                        string fqn,
                                                        string mtlocalizationKey,
                                                        string type,
                                                        object defaultValue,
                                                        bool isEnum,
                                                        bool isRequired,
                                                        ref CodeTypeDeclaration codeType,
                                                        ResourceData resourceData,
                                                        FileData fileData)
    {

        return CreatePropertyData(name,
                                  fqn,
                                  mtlocalizationKey,
                                  type,
                                  false,
                                  0,
                                  defaultValue,
                                  isEnum,
                                  isRequired,
                                  ref codeType,
                                  resourceData,
                                  fileData);
                                  
    }


    /// <summary>
    ///    Create the following type of code (two fields and two properties) based on the given parameters:
    ///     
    ///    // Field 1
    ///    private bool isContactTypeDirty = false;
    ///    
    ///    // Field 2
    ///    private Nullable<ContactType> contactType = MetraTech.DomainModel.ContactType.BillTo;
    ///    
    ///    // Property 1
    ///    [MTDataMember(IsRequired = true, IsPartOfKey = true, Description = "")]
    ///    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    ///    public Nullable<ContactType> ContactType
    ///    {
    ///      get { return contactType; }
    ///      set
    ///      {
    ///        contactType = value;
    ///        isContactTypeDirty = true;
    ///      }
    ///    }
    /// 
    ///    // Property 2
    ///    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    ///    public bool IsContactTypeDirty
    ///    {
    ///      get
    ///      {
    ///        return isContactTypeDirty;
    ///      }
    ///    }
    /// </summary>
    /// <param name="name"></param>
    /// <param name="type"></param>
    /// <param name="defaultValue"></param>
    /// <param name="isEnum"></param>
    /// <param name="isRequired"></param>
    /// <param name="codeType"></param>
    /// <returns></returns>
    public static CodeMemberProperty CreatePropertyData(string name,
                                                        string fqn,
                                                        string mtlocalizationKey,
                                                        string type,
                                                        bool bIsArray,
                                                        int arraySize,
                                                        object defaultValue,
                                                        bool isEnum,
                                                        bool isRequired,
                                                        ref CodeTypeDeclaration codeType,
                                                        ResourceData resourceData,
                                                        FileData fileData)
    {
        CodeMemberProperty property = null;

        CodeMemberField dirtyField = null;
        string dirtyFieldName = CreateDirtyField(ref codeType, name, out dirtyField);

        #region Create regular field and property
        // Create the regular field
        CodeMemberField field = new CodeMemberField();
        field.Name = LowerCaseFirst(name);
        if (field.Name.StartsWith("_"))
        {
            field.Name = "m" + field.Name;
        }
        CodeTypeReference fieldDataType = new CodeTypeReference();

        if (isEnum)
        {
            fieldDataType.BaseType = "System.Nullable<" + type + ">";
        }
        else
        {
            fieldDataType.BaseType = type;
        }

        field.Type = fieldDataType;

        if (bIsArray)
        {
            fieldDataType.ArrayRank = 1;

            if (arraySize > 0)
            {
                CodeArrayCreateExpression fieldInit = new CodeArrayCreateExpression(fieldDataType.BaseType, arraySize);
                field.InitExpression = fieldInit;
            }
            else
            {
                CodePrimitiveExpression fieldInit = new CodePrimitiveExpression(null);
                field.InitExpression = fieldInit;
            }

        }
        else
        {
            if (defaultValue != null)
            {
                if (isEnum && defaultValue is Enum)
                {
                    CodeTypeReferenceExpression codeTypeReference =
                      new CodeTypeReferenceExpression(defaultValue.GetType());

                    field.InitExpression =
                      new CodeFieldReferenceExpression(codeTypeReference,
                         Enum.GetName(defaultValue.GetType(), (int)defaultValue));
                }
                else if (defaultValue is DateTime)
                {
                    field.InitExpression = CodeCreateUTCDateTimeValue((DateTime)defaultValue);
                }
                else if (defaultValue is CodeExpression)
                {
                    field.InitExpression = (CodeExpression)defaultValue;
                }
                else
                {
                    field.InitExpression = new CodePrimitiveExpression(defaultValue);
                }

                if (defaultValue is string && String.IsNullOrEmpty(defaultValue as string))
                {
                    field.InitExpression = null;
                }
            }
        }

        codeType.Members.Add(field);

        // Create the regular property
        property = new CodeMemberProperty();
        property.Name = UpperCaseFirst(name);
        property.Type = fieldDataType;
        property.Attributes = MemberAttributes.Public | MemberAttributes.Final;
        property.HasGet = true;
        property.HasSet = true;
        codeType.Members.Add(property);

        // Create the getter
        CodeFieldReferenceExpression fieldRef =
          new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name);

        if (type.StartsWith("List", StringComparison.InvariantCultureIgnoreCase) || type.StartsWith("Dictionary", StringComparison.InvariantCultureIgnoreCase))
        {
            CodeConditionStatement condStmt = new CodeConditionStatement();
            condStmt.Condition = new CodeBinaryOperatorExpression(fieldRef, CodeBinaryOperatorType.ValueEquality, new CodePrimitiveExpression(null));
            condStmt.TrueStatements.Add(new CodeAssignStatement(fieldRef, new CodeObjectCreateExpression(fieldDataType)));

            property.GetStatements.Add(condStmt);
        }

        CodeMethodReturnStatement returnStatement1 = new CodeMethodReturnStatement(fieldRef);
        property.GetStatements.Add(returnStatement1);

        // Create the setter
        property.SetStatements.Add
          (new CodeAssignStatement(fieldRef, new CodeArgumentReferenceExpression("value")));
        property.SetStatements.Add
          (new CodeAssignStatement
            (new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), dirtyFieldName),
             new CodePrimitiveExpression(true)));


        #endregion

        if (!String.IsNullOrEmpty(fqn))
        {
            #region Create DisplayName property

            CodeMemberProperty displayNameProperty = new CodeMemberProperty();
            displayNameProperty.Name = property.Name + "DisplayName";
            displayNameProperty.Type = new CodeTypeReference("System.String");
            displayNameProperty.Attributes = MemberAttributes.Public | MemberAttributes.Final;
            displayNameProperty.HasGet = true;
            displayNameProperty.HasSet = false;
            codeType.Members.Add(displayNameProperty);

            displayNameProperty.GetStatements.Add
              (new CodeMethodReturnStatement
                 (new CodeSnippetExpression("ResourceManager.GetString(\"" + fqn.ToLower() + "\")")));

            // Create the MTLocalizationAttribute for DisplayName
            List<CodeAttributeArgument> localizationAttributeItems = new List<CodeAttributeArgument>();

            localizationAttributeItems.Add((new CodeAttributeArgument("ResourceId", new CodePrimitiveExpression(fqn.ToLower()))));
            localizationAttributeItems.Add
                (new CodeAttributeArgument("DefaultValue",
                                           new CodePrimitiveExpression(property.Name)));

            // Only View properties have MetraTech localization data
            string localeSpace = null;
            if (fileData != null && fileData is ViewFileData)
            {
                localizationAttributeItems.Add
                  (new CodeAttributeArgument("MTLocalizationId",
                                             new CodePrimitiveExpression(mtlocalizationKey)));
                localizationAttributeItems.Add
                  (new CodeAttributeArgument("Extension",
                                             new CodePrimitiveExpression(fileData.ExtensionName)));

                localeSpace = ((ViewFileData)fileData).ViewType;
                localizationAttributeItems.Add
                  (new CodeAttributeArgument("LocaleSpace",
                                             new CodePrimitiveExpression(localeSpace)));

                if (fileData.LocalizationFiles.Count > 0)
                {
                    string[] localizationFileNames = fileData.LocalizationFileNames;
                    CodePrimitiveExpression[] localizationFiles = new CodePrimitiveExpression[localizationFileNames.Length];
                    for (int j = 0; j < localizationFileNames.Length; j++)
                    {
                        localizationFiles[j] = new CodePrimitiveExpression(localizationFileNames[j]);
                    }
                    CodeArrayCreateExpression localizationFilesArray =
                      new CodeArrayCreateExpression(new CodeTypeReference("System.String"), localizationFiles);
                    localizationAttributeItems.Add(new CodeAttributeArgument("LocalizationFiles", localizationFilesArray));
                }
            }

            CodeAttributeDeclaration mtLocalizationAttribute =
              new CodeAttributeDeclaration(MTPropertyLocalizationAttribute.QualifiedName, localizationAttributeItems.ToArray());

            displayNameProperty.CustomAttributes.Add(mtLocalizationAttribute);

            if (resourceData != null)
            {
                resourceData.AddResource(mtlocalizationKey, fqn.ToLower(), property.Name, fileData.ExtensionName, localeSpace);
            }

            #endregion

            #region Create extra EnumDisplayName property
            if (isEnum)
            {
                // Create the regular property
                displayNameProperty = new CodeMemberProperty();
                displayNameProperty.Name = property.Name + "ValueDisplayName";
                displayNameProperty.Type = new CodeTypeReference("System.String");
                displayNameProperty.Attributes = MemberAttributes.Public | MemberAttributes.Final;
                displayNameProperty.HasGet = true;
                displayNameProperty.HasSet = true;
                codeType.Members.Add(displayNameProperty);

                // Create call to EnumHelper.GetDisplayName
                CodePropertyReferenceExpression enumPropertyRef =
                  new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), (property.Name));

                CodeMethodInvokeExpression getDisplayName =
                  new CodeMethodInvokeExpression
                    (new CodeTypeReferenceExpression("MetraTech.DomainModel.BaseTypes.BaseObject"),
                                                     "GetDisplayName",
                                                     new CodeExpression[] { enumPropertyRef });

                displayNameProperty.GetStatements.Add(new CodeMethodReturnStatement(getDisplayName));

                // Create the setter
                CodeMethodInvokeExpression getEnumInstanceByDisplayName =
                  new CodeMethodInvokeExpression
                    (new CodeTypeReferenceExpression("MetraTech.DomainModel.BaseTypes.BaseObject"),
                                                     "GetEnumInstanceByDisplayName",
                                                     new CodeExpression[] { new CodeTypeOfExpression(new CodeTypeReference(type)),
                                                                    new CodeArgumentReferenceExpression("value") });

                CodeCastExpression enumCast =
                 new CodeCastExpression(new CodeTypeReference(property.Type.BaseType), getEnumInstanceByDisplayName);

                displayNameProperty.SetStatements.Add(new CodeAssignStatement(enumPropertyRef, enumCast));
            }
            #endregion
        }

        #region Create the DataMember attribute
        CodeAttributeArgument[] attributeItems = new CodeAttributeArgument[2];
        // Until we solve ContactType - which is required and doesn't have a default value.
        attributeItems[0] =
          (new CodeAttributeArgument("IsRequired", new CodePrimitiveExpression(false)));
        attributeItems[1] =
          (new CodeAttributeArgument("EmitDefaultValue", new CodePrimitiveExpression(false)));
        CodeAttributeDeclaration dataMemberAttribute =
          new CodeAttributeDeclaration("System.Runtime.Serialization.DataMemberAttribute", attributeItems);

        property.CustomAttributes.Add(dataMemberAttribute);
        dirtyField.CustomAttributes.Add(dataMemberAttribute);

        #endregion

        return property;
    }

    /// <summary>
    ///    Create the following type of code (two fields and two properties) based on the given parameters:
    ///     
    ///    // Field 1
    ///    private bool isContactTypeDirty = false;
    ///    
    ///    // Field 2
    ///    private Nullable<ContactType> contactType = MetraTech.DomainModel.ContactType.BillTo;
    ///    
    ///    // Property 1
    ///    [MTDataMember(IsRequired = true, IsPartOfKey = true, Description = "")]
    ///    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    ///    public Nullable<ContactType> ContactType
    ///    {
    ///      get { return contactType; }
    ///      set
    ///      {
    ///        contactType = value;
    ///        isContactTypeDirty = true;
    ///      }
    ///    }
    /// 
    ///    // Property 2
    ///    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    ///    public bool IsContactTypeDirty
    ///    {
    ///      get
    ///      {
    ///        return isContactTypeDirty;
    ///      }
    ///    }
    /// </summary>
    /// <param name="name"></param>
    /// <param name="type"></param>
    /// <param name="bIsArray"></param>
    ///  <param name="arraySize"></param>
    /// <param name="defaultValue"></param>
    /// <param name="isEnum"></param>
    /// <param name="isRequired"></param>
    /// <param name="codeType"></param>
    /// <returns></returns>
    public static CodeMemberProperty CreatePropertyData(string name,
                                                        string type,
                                                        bool bIsArray,
                                                        int arraySize,
                                                        object defaultValue,
                                                        bool isEnum,
                                                        bool isRequired,
                                                        ref CodeTypeDeclaration codeType)
    {
        CodeMemberProperty property = null;

        CodeMemberField dirtyField = null;
        string dirtyFieldName = CreateDirtyField(ref codeType, name, out dirtyField);

        #region Create regular field and property
        // Create the regular field
        CodeMemberField field = new CodeMemberField();
        field.Name = LowerCaseFirst(name);
        if (field.Name.StartsWith("_"))
        {
            field.Name = "m" + field.Name;
        }
        CodeTypeReference fieldDataType = new CodeTypeReference();

        if (isEnum)
        {
            fieldDataType.BaseType = "System.Nullable<" + type + ">";
        }
        else
        {
            fieldDataType.BaseType = type;
        }

        field.Type = fieldDataType;

        if (bIsArray)
        {
            fieldDataType.ArrayRank = 1;

            if (arraySize > 0)
            {
                CodeArrayCreateExpression fieldInit = new CodeArrayCreateExpression(fieldDataType.BaseType, arraySize);
                field.InitExpression = fieldInit;
            }
            else
            {
                CodePrimitiveExpression fieldInit = new CodePrimitiveExpression(null);
                field.InitExpression = fieldInit;
            }

        }
        else
        {
            if (defaultValue != null)
            {
                if (isEnum && defaultValue is Enum)
                {
                    CodeTypeReferenceExpression codeTypeReference =
                      new CodeTypeReferenceExpression(defaultValue.GetType());

                    field.InitExpression =
                      new CodeFieldReferenceExpression(codeTypeReference,
                         Enum.GetName(defaultValue.GetType(), (int)defaultValue));
                }
                else if (defaultValue is DateTime)
                {
                    field.InitExpression = CodeCreateUTCDateTimeValue((DateTime)defaultValue);
                }
                else if (defaultValue is CodeExpression)
                {
                    field.InitExpression = (CodeExpression)defaultValue;
                }
                else
                {
                    field.InitExpression = new CodePrimitiveExpression(defaultValue);
                }

                if (defaultValue is string && String.IsNullOrEmpty(defaultValue as string))
                {
                    field.InitExpression = null;
                }
            }
        }

        codeType.Members.Add(field);

        // Create the regular property
        property = new CodeMemberProperty();
        property.Name = UpperCaseFirst(name);
        property.Type = fieldDataType;
        property.Attributes = MemberAttributes.Public | MemberAttributes.Final;
        property.HasGet = true;
        property.HasSet = true;
        codeType.Members.Add(property);

        // Create the getter
        CodeFieldReferenceExpression fieldRef =
          new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name);

        if (type.StartsWith("List", StringComparison.InvariantCultureIgnoreCase) || type.StartsWith("Dictionary", StringComparison.InvariantCultureIgnoreCase))
        {
            CodeConditionStatement condStmt = new CodeConditionStatement();
            condStmt.Condition = new CodeBinaryOperatorExpression(fieldRef, CodeBinaryOperatorType.ValueEquality, new CodePrimitiveExpression(null));
            condStmt.TrueStatements.Add(new CodeAssignStatement(fieldRef, new CodeObjectCreateExpression(fieldDataType)));

            property.GetStatements.Add(condStmt);

        }

        CodeMethodReturnStatement returnStatement1 = new CodeMethodReturnStatement(fieldRef);
        property.GetStatements.Add(returnStatement1);

        // Create the setter
        property.SetStatements.Add
          (new CodeAssignStatement(fieldRef, new CodeArgumentReferenceExpression("value")));
        property.SetStatements.Add
          (new CodeAssignStatement
            (new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), dirtyFieldName),
             new CodePrimitiveExpression(true)));


        #endregion

      #region Create the DataMember attribute
      CodeAttributeArgument[] attributeItems = new CodeAttributeArgument[2];
      // Until we solve ContactType - which is required and doesn't have a default value.
      attributeItems[0] =
        (new CodeAttributeArgument("IsRequired", new CodePrimitiveExpression(false)));
      attributeItems[1] =
        (new CodeAttributeArgument("EmitDefaultValue", new CodePrimitiveExpression(false)));
      CodeAttributeDeclaration dataMemberAttribute =
        new CodeAttributeDeclaration("System.Runtime.Serialization.DataMemberAttribute", attributeItems);

      property.CustomAttributes.Add(dataMemberAttribute);
      dirtyField.CustomAttributes.Add(dataMemberAttribute);

      #endregion

      return property;
    }

    /// <summary>
    ///    Create the following type of code (two fields and two properties) based on the given parameters:
    ///     
    ///    // Field 1
    ///    private bool isContactTypeDirty = false;
    ///    
    ///    // Field 2
    ///    private Nullable<ContactType> contactType = MetraTech.DomainModel.ContactType.BillTo;
    ///    
    ///    // Property 1
    ///    [MTDataMember(IsRequired = true, IsPartOfKey = true, Description = "")]
    ///    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    ///    public Nullable<ContactType> ContactType
    ///    {
    ///      get { return contactType; }
    ///      set
    ///      {
    ///        contactType = value;
    ///        isContactTypeDirty = true;
    ///      }
    ///    }
    /// 
    ///    // Property 2
    ///    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    ///    public bool IsContactTypeDirty
    ///    {
    ///      get
    ///      {
    ///        return isContactTypeDirty;
    ///      }
    ///    }
    /// </summary>
    /// <param name="name"></param>
    /// <param name="type"></param>
    /// <param name="bIsArray"></param>
    ///  <param name="arraySize"></param>
    /// <param name="defaultValue"></param>
    /// <param name="isEnum"></param>
    /// <param name="isRequired"></param>
    /// <param name="codeType"></param>
    /// <returns></returns>
    public static CodeMemberProperty CreatePropertyData(string name,
                                                        Type type,
                                                        bool bIsArray,
                                                        int arraySize,
                                                        object defaultValue,
                                                        bool isEnum,
                                                        bool isRequired,
                                                        ref CodeTypeDeclaration codeType)
    {
        CodeMemberProperty property = null;

        CodeMemberField dirtyField = null;
        string dirtyFieldName = CreateDirtyField(ref codeType, name, out dirtyField);

        #region Create regular field and property
        // Create the regular field
        CodeMemberField field = new CodeMemberField();
        field.Name = LowerCaseFirst(name);
        if (field.Name.StartsWith("_"))
        {
            field.Name = "m" + field.Name;
        }
        CodeTypeReference fieldDataType = new CodeTypeReference(type);
        
        field.Type = fieldDataType;

        if (bIsArray)
        {
            fieldDataType.ArrayRank = 1;

            if (arraySize > 0)
            {
                CodeArrayCreateExpression fieldInit = new CodeArrayCreateExpression(fieldDataType.BaseType, arraySize);
                field.InitExpression = fieldInit;
            }
            else
            {
                CodePrimitiveExpression fieldInit = new CodePrimitiveExpression(null);
                field.InitExpression = fieldInit;
            }

        }
        else
        {
            if (defaultValue != null)
            {
                if (isEnum && defaultValue is Enum)
                {
                    CodeTypeReferenceExpression codeTypeReference =
                      new CodeTypeReferenceExpression(defaultValue.GetType());

                    field.InitExpression =
                      new CodeFieldReferenceExpression(codeTypeReference,
                         Enum.GetName(defaultValue.GetType(), (int)defaultValue));
                }
                else if (defaultValue is DateTime)
                {
                    field.InitExpression = CodeCreateUTCDateTimeValue((DateTime)defaultValue);
                }
                else if (defaultValue is CodeExpression)
                {
                    field.InitExpression = (CodeExpression)defaultValue;
                }
                else
                {
                    field.InitExpression = new CodePrimitiveExpression(defaultValue);
                }

                if (defaultValue is string && String.IsNullOrEmpty(defaultValue as string))
                {
                    field.InitExpression = null;
                }
            }
        }

        codeType.Members.Add(field);

        // Create the regular property
        property = new CodeMemberProperty();
        property.Name = UpperCaseFirst(name);
        property.Type = fieldDataType;
        property.Attributes = MemberAttributes.Public | MemberAttributes.Final;
        property.HasGet = true;
        property.HasSet = true;
        codeType.Members.Add(property);

        // Create the getter
        CodeFieldReferenceExpression fieldRef =
          new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name);

        if (type.Name.StartsWith("List", StringComparison.InvariantCultureIgnoreCase) || type.Name.StartsWith("Dictionary", StringComparison.InvariantCultureIgnoreCase))
        {
            CodeConditionStatement condStmt = new CodeConditionStatement();
            condStmt.Condition = new CodeBinaryOperatorExpression(fieldRef, CodeBinaryOperatorType.ValueEquality, new CodePrimitiveExpression(null));
            condStmt.TrueStatements.Add(new CodeAssignStatement(fieldRef, new CodeObjectCreateExpression(fieldDataType)));

            property.GetStatements.Add(condStmt);
            
        }

        CodeMethodReturnStatement returnStatement1 = new CodeMethodReturnStatement(fieldRef);
        property.GetStatements.Add(returnStatement1);

        // Create the setter
        property.SetStatements.Add
          (new CodeAssignStatement(fieldRef, new CodeArgumentReferenceExpression("value")));
        property.SetStatements.Add
          (new CodeAssignStatement
            (new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), dirtyFieldName),
             new CodePrimitiveExpression(true)));


        #endregion

        #region Create the DataMember attribute
        CodeAttributeArgument[] attributeItems = new CodeAttributeArgument[2];
        // Until we solve ContactType - which is required and doesn't have a default value.
        attributeItems[0] =
          (new CodeAttributeArgument("IsRequired", new CodePrimitiveExpression(false)));
        attributeItems[1] =
          (new CodeAttributeArgument("EmitDefaultValue", new CodePrimitiveExpression(false)));
        CodeAttributeDeclaration dataMemberAttribute =
          new CodeAttributeDeclaration("System.Runtime.Serialization.DataMemberAttribute", attributeItems);

        property.CustomAttributes.Add(dataMemberAttribute);
        dirtyField.CustomAttributes.Add(dataMemberAttribute);

        #endregion

        return property;
    }
    public static CodeExpression CodeCreateUTCDateTimeValue(DateTime value)
    {
        DateTime dtUTC = value.ToUniversalTime();

        CodeTypeReferenceExpression codeTypeReference =
          new CodeTypeReferenceExpression(typeof(DateTimeKind));

        CodeFieldReferenceExpression refKind =
            new CodeFieldReferenceExpression(codeTypeReference,
               Enum.GetName(typeof(DateTimeKind), dtUTC.Kind));

        return new CodeObjectCreateExpression(dtUTC.GetType(),
            new CodePrimitiveExpression(dtUTC.Ticks), refKind);
    }

    public static string CreateDirtyField(ref CodeTypeDeclaration codeType, string propertyName, out CodeMemberField dirtyField)
    {
      // Create the is[fieldName]Dirty field
      string dirtyFieldName = "is" + propertyName + "Dirty";
      dirtyField = new CodeMemberField(new CodeTypeReference(typeof(bool)), dirtyFieldName);
      dirtyField.InitExpression = new CodePrimitiveExpression(false);
      codeType.Members.Add(dirtyField);

      // Create the property for the dirtyField with a getter only
      CodeMemberProperty dirtyProperty = new CodeMemberProperty();
      dirtyProperty.Name = UpperCaseFirst(dirtyFieldName);
      dirtyProperty.Type = new CodeTypeReference(typeof(bool));
      dirtyProperty.Attributes = MemberAttributes.Public | MemberAttributes.Final;
      dirtyProperty.HasGet = true;
      codeType.Members.Add(dirtyProperty);

		// Create the ScriptIgnore attribute on the property
		CodeAttributeDeclaration scriptIgnoreAttribute =
		  new CodeAttributeDeclaration("System.Web.Script.Serialization.ScriptIgnoreAttribute");
		dirtyProperty.CustomAttributes.Add(scriptIgnoreAttribute);

      // Create the getter
      CodeFieldReferenceExpression dirtyFieldRef =
        new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), dirtyFieldName);

      CodeMethodReturnStatement returnStatement = new CodeMethodReturnStatement(dirtyFieldRef);

      dirtyProperty.GetStatements.Add(returnStatement);

      return dirtyFieldName;

    }

    /// <summary>
    ///   Creates ResourceData by loading the generated assembly and reflecting over types.
    /// </summary>
    public static ResourceData CreateResourceData(string generatedAssemblyName)
    {

        ResourceData resourceData = new ResourceData();

        AddResourceData(generatedAssemblyName, resourceData);

        return resourceData;

    }

    public static void AddResourceData(string generatedAssemblyName, ResourceData resourceData)
    {
        Assembly assembly = GetAssembly(generatedAssemblyName);
        if (assembly == null)
        {
            logger.LogDebug(String.Format("Unable to load assembly '{0}'", generatedAssemblyName));
            return;
        }

        Dictionary<string, int> localizationFiles = new Dictionary<string, int>();

        try
        {
            foreach (Type type in assembly.GetTypes())
            {
                if (type.IsEnum)
                {
                    object[] attributes = type.GetCustomAttributes(typeof(MTEnumLocalizationAttribute), false);

                    if (attributes == null || attributes.Length <= 0) continue;

                    MTEnumLocalizationAttribute attribute = attributes[0] as MTEnumLocalizationAttribute;
                    Debug.Assert(attribute != null);

                    if (attribute.LocalizationFiles != null)
                    {
                        foreach (string fileName in attribute.LocalizationFiles)
                        {
                            if (localizationFiles.ContainsKey(fileName)) continue;
                            LocalizationFileData.UpdateEntries(attribute.Extension, fileName);
                            localizationFiles.Add(fileName, 0);
                        }
                    }

                    if (attribute.MTLocalizationIds == null || attribute.MTLocalizationIds.Length == 0) continue;

                    int i = 0;
                    foreach (string mtLocalizationId in attribute.MTLocalizationIds)
                    {
                        resourceData.AddResource(mtLocalizationId,
                                                 attribute.ResourceIds[i],
                                                 attribute.DefaultValues[i],
                                                 attribute.Extension,
                                                 attribute.LocaleSpace);
                        i++;
                    }
                }
                else
                {
                    foreach (PropertyInfo propertyInfo in type.GetProperties())
                    {
                        if (!propertyInfo.Name.EndsWith("DisplayName")) continue;

                        object[] attributes = propertyInfo.GetCustomAttributes(typeof(MTPropertyLocalizationAttribute), false);

                        if (attributes == null || attributes.Length <= 0) continue;

                        MTPropertyLocalizationAttribute attribute = attributes[0] as MTPropertyLocalizationAttribute;
                        Debug.Assert(attribute != null);

                        resourceData.AddResource(attribute.MTLocalizationId,
                                                 attribute.ResourceId,
                                                 attribute.DefaultValue,
                                                 attribute.Extension,
                                                 attribute.LocaleSpace);

                        // Init localization data if necessary
                        if (String.IsNullOrEmpty(attribute.Extension) || String.IsNullOrEmpty(attribute.LocaleSpace))
                        {
                            continue;
                        }
                        LocalizationFileData.GetLocalizationFileData(attribute.Extension, attribute.LocaleSpace);
                    }
                }
            }
        }
        catch (Exception e)
        {
            logger.LogException(String.Format("Error loading types from assembly '{0}'", generatedAssemblyName), e);
        }
    }

    /// <summary>
    ///    Return a ConfigPropertyData class given the following kind of <ptype> node.
    /// 
    ///      <ptype>
		///        <dn>PaymentMethod</dn>
		///        <type EnumSpace="metratech.com/accountcreation" EnumType="PaymentMethod">enum</type>
		///        <length></length>
		///        <required>N</required>
		///        <defaultvalue>CreditOrACH</defaultvalue>
    ///        <description>Payment method.</description>
	  ///      </ptype>
    /// 
    /// </summary>
    /// <param name="ptype"></param>
    /// <param name="bMakeNullable"></param>
    /// <param name="configPropertyData"></param>
    /// <returns></returns>
    public static bool GetPropertyData(XmlNode ptype, bool bMakeNullable,
                                       out ConfigPropertyData configPropertyData)
    {
      bool status = true;
      configPropertyData = new ConfigPropertyData();

      // Get partofkey attribute 
      XmlAttribute partOfKeyAttribute = null;
      partOfKeyAttribute = ptype.Attributes["partofkey"];
      if (partOfKeyAttribute != null)
      {
        if (!String.IsNullOrEmpty(partOfKeyAttribute.InnerText.Trim()))
        {
                bool bResult;
                if (StringUtils.TryConvertToBoolean(partOfKeyAttribute.InnerText, out bResult))
          {
                    configPropertyData.IsPartOfKey = bResult;
          }
          else
          {
            logger.LogError(String.Format("Could not convert 'partOfKey' attribute '{0}' to boolean in file '{1}'.",
                                          partOfKeyAttribute.InnerText, ptype.BaseURI));
          }

        }
        else
        {
          logger.LogError(String.Format("'partOfKey' attribute does not have a value in file '{1}'.", ptype.BaseURI));
        }
      }

            XmlAttribute conditionAttrib = ptype.Attributes["condition"];
            if (conditionAttrib != null && !String.IsNullOrEmpty(conditionAttrib.InnerText))
        {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(conditionAttrib.InnerText, out bResult))
        {
                configPropertyData.Condition = bResult;
        }
                else
            {
                    logger.LogError(String.Format("Could not convert <condition> '{0}' to boolean in file '{1}'.",
                                                  conditionAttrib.InnerText, ptype.BaseURI));
            }
        }

            XmlAttribute operatorAttrib = ptype.Attributes["operator"];
            if (operatorAttrib != null && !String.IsNullOrEmpty(operatorAttrib.InnerText))
        {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(operatorAttrib.InnerText, out bResult))
            {
                configPropertyData.Operator = bResult;
            }
            else
            {
                    logger.LogError(String.Format("Could not convert <operator> '{0}' to boolean in file '{1}'.",
                                                  operatorAttrib.InnerText, ptype.BaseURI));
        }
        }

            XmlAttribute actionAttrib = ptype.Attributes["action"];
            if (actionAttrib != null && !String.IsNullOrEmpty(actionAttrib.InnerText))
                {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(actionAttrib.InnerText, out bResult))
                        {
                configPropertyData.Action = bResult;
                        }
                            else
                            {
                    logger.LogError(String.Format("Could not convert <action> '{0}' to boolean in file '{1}'.",
                                                  actionAttrib.InnerText, ptype.BaseURI));
                        }
                    }

            XmlAttribute filterableAttrib = ptype.Attributes["filterable"];
            if (filterableAttrib != null && !String.IsNullOrEmpty(filterableAttrib.InnerText))
                    {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(filterableAttrib.InnerText, out bResult))
                        {
                configPropertyData.Filterable = bResult;
                }
                            else
                            {
                    logger.LogError(String.Format("Could not convert <filterable> '{0}' to boolean in file '{1}'.",
                                                  filterableAttrib.InnerText, ptype.BaseURI));
        }
    }

        XmlAttribute exportableAttrib = ptype.Attributes["exportable"];
        if (exportableAttrib != null && !String.IsNullOrEmpty(exportableAttrib.InnerText))
      {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(exportableAttrib.InnerText, out bResult))
          {
                configPropertyData.Exportable = bResult;
          }
            else
          {
                logger.LogError(String.Format("Could not convert <exportable> '{0}' to boolean in file '{1}'.",
                                              exportableAttrib.InnerText, ptype.BaseURI));
        }
        }

        XmlAttribute userVisibleAttrib = ptype.Attributes["uservisible"];
        if (userVisibleAttrib != null && !String.IsNullOrEmpty(userVisibleAttrib.InnerText))
        {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(userVisibleAttrib.InnerText, out bResult))
            {
                configPropertyData.UserVisible = bResult;
            }
        else
        {
                logger.LogError(String.Format("Could not convert <uservisible> '{0}' to boolean in file '{1}'.",
                                              userVisibleAttrib.InnerText, ptype.BaseURI));
            }
        }

        XmlAttribute opPerRuleAttrib = ptype.Attributes["operator_per_rule"];
        if (opPerRuleAttrib != null && !String.IsNullOrEmpty(opPerRuleAttrib.InnerText))
        {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(opPerRuleAttrib.InnerText, out bResult))
            {
                configPropertyData.OperatorPerRule = bResult;
            }
            else
            {
                    logger.LogError(String.Format("Could not convert <operator_per_rule> '{0}' to boolean in file '{1}'.",
                                                  opPerRuleAttrib.InnerText, ptype.BaseURI));
        }
      }

      // Get name
      XmlNode nameNode = ptype.SelectSingleNode("dn");
      if (nameNode == null)
      {
        logger.LogError(String.Format("<name> not found under <ptype> in file '{0}'.", ptype.BaseURI));
        return false;
      }

      if (String.IsNullOrEmpty(nameNode.InnerText))
      {
        logger.LogError(String.Format("<name> is empty in file '{0}'.", ptype.BaseURI));
        return false;
      }

      configPropertyData.Name = MakeAlphaNumeric(nameNode.InnerText.Trim());

      XmlNode lengthNode = ptype.SelectSingleNode("length");
      if (lengthNode != null && !String.IsNullOrEmpty(lengthNode.InnerText))
      {
        try
        {
          configPropertyData.Length = Convert.ToInt32(lengthNode.InnerText.Trim());
        }
        catch (Exception e)
        {
          logger.LogException(String.Format("Could not convert <length> '{0}' to integer in file '{1}'.",
                                            lengthNode.InnerText, ptype.BaseURI), e);
        }
      }

      XmlNode requiredNode = ptype.SelectSingleNode("required");
      if (requiredNode != null && !String.IsNullOrEmpty(requiredNode.InnerText))
      {
            bool bResult;
            if (StringUtils.TryConvertToBoolean(requiredNode.InnerText, out bResult))
        {
                configPropertyData.IsRequired = bResult;
        }
        else
        {
          logger.LogError(String.Format("Could not convert <required> '{0}' to boolean in file '{1}'.",
                                        requiredNode.InnerText, ptype.BaseURI));
        }
      }

      XmlNode defaultValueNode = ptype.SelectSingleNode("defaultvalue");
      if (defaultValueNode != null)
      {
        configPropertyData.DefaultValue = defaultValueNode.InnerText.Trim();
      }

      XmlNode descriptionNode = ptype.SelectSingleNode("description");
      if (descriptionNode != null)
      {
        configPropertyData.Description = descriptionNode.InnerText.Trim();
      }

      XmlNode typeNode = ptype.SelectSingleNode("type");
      if (typeNode == null)
      {
        logger.LogError(String.Format("<type> not found under <ptype> in file '{0}'.", ptype.BaseURI));
        return false;
      }

      if (String.IsNullOrEmpty(typeNode.InnerText) || String.IsNullOrEmpty(typeNode.InnerText.Trim()))
      {
        logger.LogError(String.Format("<type> is empty in file '{0}'.", ptype.BaseURI));
        return false;
      }

      configPropertyData.MsixType = typeNode.InnerText.Trim().ToLower();
      switch (configPropertyData.MsixType)
      {
        case "unistring":
        case "string":
          {
            configPropertyData.PropertyType = typeof(System.String);
            break;
          }
        case "timestamp":
          {
                        configPropertyData.PropertyType = bMakeNullable ? typeof(System.Nullable<System.DateTime>) : typeof(System.DateTime);
            if (!String.IsNullOrEmpty(configPropertyData.DefaultValue as string))
            {
              try
              {
                configPropertyData.DefaultValue = Convert.ToDateTime(configPropertyData.DefaultValue);
              }
              catch (Exception)
              {
                logger.LogError(String.Format
                  ("Cannot convert default value '{0}' to type '{1}' in file '{2}'.", configPropertyData.DefaultValue, "System.DateTime", ptype.BaseURI));
                configPropertyData.DefaultValue = null;
              }
            }
            break;
          }
        case "float":
        case "decimal":
          {
                        configPropertyData.PropertyType = bMakeNullable ? typeof(System.Nullable<decimal>) : typeof(decimal);
            if (!String.IsNullOrEmpty(configPropertyData.DefaultValue as string))
            {
              try
              {
                configPropertyData.DefaultValue = Convert.ToDecimal(configPropertyData.DefaultValue);
              }
              catch (Exception)
              {
                logger.LogError(String.Format
                  ("Cannot convert default value '{0}' to type '{1}' in file '{2}'.", configPropertyData.DefaultValue, "System.Decimal", ptype.BaseURI));
                configPropertyData.DefaultValue = null;
              }
            }
            break;
          }
        case "double":
          {
                        configPropertyData.PropertyType = bMakeNullable ? typeof(System.Nullable<double>) : typeof(double);
            if (!String.IsNullOrEmpty(configPropertyData.DefaultValue as string))
            {
              try
              {
                configPropertyData.DefaultValue = Convert.ToDouble(configPropertyData.DefaultValue);
              }
              catch (Exception)
              {
                logger.LogError(String.Format
                  ("Cannot convert default value '{0}' to type '{1}' in file '{2}'.", configPropertyData.DefaultValue, "System.Double", ptype.BaseURI));
                configPropertyData.DefaultValue = null;
              }
            }
            break;
          }
        case "int32":
          {
                        configPropertyData.PropertyType = bMakeNullable ? typeof(System.Nullable<System.Int32>) : typeof(System.Int32);
            if (!String.IsNullOrEmpty(configPropertyData.DefaultValue as string))
            {
              try
              {
                configPropertyData.DefaultValue = Convert.ToInt32(configPropertyData.DefaultValue);
              }
              catch (Exception)
              {
                logger.LogError(String.Format
                  ("Cannot convert default value '{0}' to type '{1}' in file '{2}'.", configPropertyData.DefaultValue, "System.Int32", ptype.BaseURI));
                configPropertyData.DefaultValue = null;
              }
            }
            break;
          }
        case "int64":
          {
                        configPropertyData.PropertyType = bMakeNullable ? typeof(System.Nullable<System.Int64>) : typeof(System.Int64);
            if (!String.IsNullOrEmpty(configPropertyData.DefaultValue as string))
            {
              try
              {
                configPropertyData.DefaultValue = Convert.ToInt64(configPropertyData.DefaultValue);
              }
              catch (Exception)
              {
                logger.LogError(String.Format
                  ("Cannot convert default value '{0}' to type '{1}' in file '{2}'.", configPropertyData.DefaultValue, "System.Int64", ptype.BaseURI));
                configPropertyData.DefaultValue = null;
              }
            }
            break;
          }
        case "boolean":
          {
                        configPropertyData.PropertyType = bMakeNullable ? typeof(System.Nullable<bool>) : typeof(bool);
            if (!String.IsNullOrEmpty(configPropertyData.DefaultValue as string))
            {
              try
              {
                configPropertyData.DefaultValue = Convert.ToBoolean(configPropertyData.DefaultValue);
              }
              catch (Exception)
              {
                  bool bResult;
                  if (StringUtils.TryConvertToBoolean(configPropertyData.DefaultValue as string, out bResult))
                {
                      configPropertyData.DefaultValue = bResult;
                }
                else
                {
                  logger.LogError(String.Format("Could not convert default value '{0}' to boolean in file '{1}'.",
                                                configPropertyData.DefaultValue, ptype.BaseURI));
                  configPropertyData.DefaultValue = null;
                }
              }
            }
            break;
          }
        case "enum":
          {
            configPropertyData.IsEnum = true;
            Type propertyType;
            status = GetEnumPropertyType(typeNode, out propertyType);
            configPropertyData.PropertyType = propertyType;

            // If there's a default value, reset defaultvalue to the correct enum instance
            if (status == true && configPropertyData.PropertyType != null)
            {
              if (!String.IsNullOrEmpty(configPropertyData.DefaultValue as string))
              {
                logger.LogDebug("Enum property type = " + configPropertyData.PropertyType.Name);
                configPropertyData.DefaultValue = EnumHelper.GetGeneratedEnumByEntry(configPropertyData.PropertyType, configPropertyData.DefaultValue as string);
              }
            }
            break;
          }
        default:
          {
            logger.LogError(String.Format("Unknown msix property type '{0}' in file '{1}'.", typeNode.InnerText, ptype.BaseURI));
            status = false;
            break;
          }

      }

      return status;
    }

    /// <summary>
        ///    Return a ConfigPropertyData class given the following kind of <ptype> node.
        /// 
        ///      <ptype>
        ///        <dn>PaymentMethod</dn>
        ///        <type EnumSpace="metratech.com/accountcreation" EnumType="PaymentMethod">enum</type>
        ///        <length></length>
        ///        <required>N</required>
        ///        <defaultvalue>CreditOrACH</defaultvalue>
        ///        <description>Payment method.</description>
        ///      </ptype>
        /// 
        /// </summary>
        /// <param name="ptype"></param>
        /// <param name="configPropertyData"></param>
        /// <returns></returns>
        public static bool GetPropertyData(XmlNode ptype,
                                           out ConfigPropertyData configPropertyData)
        {
            return GetPropertyData(ptype, true, out configPropertyData);
        }

        /// <summary>
    ///    Return the C# enum type corresponding to a node like the following:
    ///      <type EnumSpace="metratech.com/accountcreation" EnumType="PaymentMethod">enum</type>
    ///    
    /// </summary>
    /// <param name="typeNode"></param>
    /// <param name="enumType"></param>
    /// <returns></returns>
    public static bool GetEnumPropertyType(XmlNode typeNode, out Type enumType)
    {
      bool status = true;
      enumType = null;
      string configEnumSpace = String.Empty;
      string configEnumType = String.Empty;

      if (typeNode.InnerText.Trim().ToLower() != "enum")
      {
        logger.LogError(String.Format("Non enum type node passed to 'GetEnumPropertyType' method from file '{0}'.", typeNode.BaseURI));
        return false;
      }

      // Get the EnumSpace attribute on typeNode
      XmlAttribute enumSpaceAttrib = typeNode.Attributes["EnumSpace"];
      if (enumSpaceAttrib == null)
      {
        enumSpaceAttrib = typeNode.Attributes["enumSpace"];

        if (enumSpaceAttrib == null)
        {
          enumSpaceAttrib = typeNode.Attributes["enumspace"];

          if (enumSpaceAttrib == null)
          {
            logger.LogError(String.Format("Cannot find 'EnumSpace' attribute for enums type in '{0}'.", typeNode.BaseURI));
            return false;
          }
        }
      }

      configEnumSpace = enumSpaceAttrib.InnerText.Trim();
      if (String.IsNullOrEmpty(configEnumSpace))
      {
        logger.LogError(String.Format("The 'EnumSpace' attribute does not have a value in '{0}'.", typeNode.BaseURI));
        return false;
      }

      // Get the EnumSpace attribute on typeNode
      XmlAttribute enumTypeAttrib = typeNode.Attributes["EnumType"];
      if (enumTypeAttrib == null)
      {
        enumTypeAttrib = typeNode.Attributes["enumType"];

        if (enumTypeAttrib == null)
        {
          enumTypeAttrib = typeNode.Attributes["enumtype"];

          if (enumTypeAttrib == null)
          {
            logger.LogError(String.Format("Cannot find 'EnumSpace' attribute for enums type in '{0}'.", typeNode.BaseURI));
            return false;
          }
        }
      }

      configEnumType = enumTypeAttrib.InnerText.Trim();

      if (String.IsNullOrEmpty(configEnumType))
      {
        logger.LogError(String.Format("The 'EnumType' attribute does not have a value in '{0}'.", typeNode.BaseURI));
        return false;
      }

      enumType = EnumHelper.GetGeneratedEnumType(configEnumSpace, configEnumType, SystemConfig.GetBinDir());
      if (enumType == null)
      {
        logger.LogError(String.Format("Unable to find generated enum type for EnumSpace '{0}' and EnumType '{1}' " +
                                      "in file '{0}'.", configEnumSpace, configEnumType, typeNode.BaseURI));
        return false;
      }

      return status;  
    }


    public void CreateMTDataMemberAttribute(ref CodeMemberProperty property, ConfigPropertyData configPropertyData)
    {
      List<CodeAttributeArgument> attributeItems = new List<CodeAttributeArgument>();
      attributeItems.Add(new CodeAttributeArgument("IsRequired", new CodePrimitiveExpression(configPropertyData.IsRequired)));
      if (configPropertyData.IsPartOfKey)
      {
        attributeItems.Add(new CodeAttributeArgument("IsPartOfKey", new CodePrimitiveExpression(configPropertyData.IsPartOfKey)));
      }

      if (configPropertyData.Length > 0)
      {
        attributeItems.Add(new CodeAttributeArgument("Length", new CodePrimitiveExpression(configPropertyData.Length)));
      }

      if (!String.IsNullOrEmpty(configPropertyData.Description))
      {
        attributeItems.Add(new CodeAttributeArgument("Description", new CodePrimitiveExpression(configPropertyData.Description)));
      }

      if (!String.IsNullOrEmpty(configPropertyData.MsixType))
      {
        attributeItems.Add(new CodeAttributeArgument("MsixType", new CodePrimitiveExpression(configPropertyData.MsixType)));
      }

      CodeAttributeDeclaration mtDataMemberAttribute =
        new CodeAttributeDeclaration(MTDataMemberAttribute.QualifiedName, attributeItems.ToArray());

      property.CustomAttributes.Add(mtDataMemberAttribute);
    }

    /// <summary>
    ///   Given a localSpace item found in localization files as shown below:
    ///   <mt_config>
    ///     <language_code>us</language_code>
    ///     <locale_space name="metratech.com/indextest">
    ///        <locale_entry>
    ///          <Name>metratech.com/indextest/InvoiceMethod</Name>
    ///          <Value>Invoice Method</Value>
    ///        </locale_entry>
    ///     </locale_space>
    ///   </mt_config>
    /// </summary>
    /// <param name="localeSpace"></param>
    /// <returns></returns>
    public List<string> GetResourceFiles(string localeSpace)
    {
      List<string> resourceFiles = new List<string>();

      return resourceFiles;
    }
    #endregion

    #region Properties
    public static IMTRcd RCD
    {
      get
      {
        return rcd;
      }
    }

    public static Dictionary<string, string> LanguageMappings
    {
      get
      {
        return languageMappings;
      }
    }

    public static Version AssemblyVersion
    {
      get
      {
        return assemblyVersion;
      }
    }

    public static byte[] AssemblyPublicKeyToken
    {
      get
      {
        return assemblyPublicKeyToken;
      }
    }

    public static byte[] AssemblyPublicKey
    {
      get
      {
        return assemblyPublicKey;
      }
    }

    public static string KeyFile
    {
      get
      {
        return keyFile;
      }
    }

    public static byte[] KeyFileBytes
    {
      get
      {
        if (keyFileBytes != null)
        {
          return keyFileBytes;
        }

        FileStream fs = new FileStream(keyFile, FileMode.Open,FileAccess.Read);

        // Create a byte array of file stream length
        keyFileBytes = new byte[fs.Length];

        //Read block of bytes from stream into the byte array
        fs.Read(keyFileBytes, 0, Convert.ToInt32(fs.Length));

        //Close the File Stream
        fs.Close();

        return keyFileBytes;
      }
    }

    public static ResourceData ResourceData
    {
        get
        {
            return resourceData;
        }
        set
        {
            resourceData = value;
        }
    }

    public static string ShadowCopyDir
    {
      get
      {
        return shadowCopyDir;
      }
    }
    #endregion

    #region Private Methods
    /// <summary>
    ///    Locate the local bin directory
    /// </summary>
    /// <returns></returns>
    private static string GetBinDirectory()
    {
      string path = typeof(EnumHelper).Assembly.CodeBase.ToLower();

      path = path.Replace("metratech.domainmodel.enums.dll", "");
      string dir = path.Replace("file:///", "");

      return dir;
    }

    private static bool ChecksumsMatch(IDictionary<string, string> assemblyChecksums, FileData fileData)
    {
      if (!assemblyChecksums.ContainsKey(fileData.ChecksumKey))
      {
        return false;
      }
      else
      {
        string checksum = GetMD5ChecksumForFile(fileData.FullPath);
        string storedChecksum = (string)assemblyChecksums[fileData.ChecksumKey];

        if (checksum != storedChecksum)
        {
          return false;
        }
      }

      return true;
    }

    protected void CopyAssemblyToDirectoriesSpecifiedInConfig(string assemblyFileWithPath)
    {
      // domain model config file
      string configFile = BaseCodeGenerator.RCD.ConfigDir + @"domainmodel\config.xml";
      if (!File.Exists(configFile))
      {
        logger.LogError((String.Format("Cannot find domain model config file '{0}'", configFile)));
      }

      IEnumerable<XElement> directorySpecs = 
        from s in XElement.Load(configFile).Elements("copy-generated-assemblies-to")
        select s;

      foreach (XElement directorySpec in directorySpecs)
      {
        XAttribute virtualDir = directorySpec.Attribute("virtual-dir");
        if (virtualDir == null)
        {
          logger.LogInfo(String.Format("Cannot find virtual directory specification in config file '{0}'", configFile));
          continue;
        }
        
        if (String.IsNullOrEmpty(virtualDir.Value))
        {
          logger.LogInfo(String.Format("Cannot find virtual directory specification in config file '{0}'", configFile));
          continue;
        }

        string dir = DirectoryUtil.ResolveVirtualDirectory(virtualDir.Value.Trim());
        if (String.IsNullOrEmpty(dir))
        {
          logger.LogInfo(String.Format("Cannot resolve virtual directory '{0}' in config file '{1}'", 
                                        virtualDir.Value.Trim(), configFile));
          continue;
        }

        dir = Path.Combine(dir, "bin");
        if (!Directory.Exists(dir))
        {
          logger.LogError(String.Format("Cannot find bin path '{0}' for virtual directory '{1}' in config file '{0}'",
                                         dir, virtualDir.Value.Trim(), configFile));
          continue;
        }

        try
        {
          logger.LogDebug(String.Format("Copying assembly '{0}' to directory '{1}'", assemblyFileWithPath, dir));
          File.Copy(assemblyFileWithPath, Path.Combine(dir, Path.GetFileName(assemblyFileWithPath)), true);
        }
        catch (Exception e)
        {
          logger.LogError((String.Format("Cannot copy assembly '{0}' to directory '{1}' with exception: '{2}'",
                           assemblyFileWithPath, dir, e.Message)));
        }
        
      }
    }
    
    #endregion

    #region Data

    protected static Logger logger =
      new Logger("Logging\\DomainModel\\CodeGenerator", "[CodeGenerator]");

    public static Logger Logger
    {
        get
        {
            return logger;
        }
    }


    // private const string standardCompilerFlags = "/nowarn:1591 /nowarn:0618 /optimize /keyfile:GenDMKey.snk ";    
    private const string checksumResource = "checksum.resources";

    private static readonly string binDir = GetBinDirectory();
    private static readonly IMTRcd rcd = new MTRcd();
    private static readonly Dictionary<string, string> languageMappings = GetLanguageMappings();

    private static readonly Version assemblyVersion = Assembly.GetExecutingAssembly().GetName().Version;
    private static readonly byte[] assemblyPublicKeyToken = Assembly.GetExecutingAssembly().GetName().GetPublicKeyToken();
    private static readonly byte[] assemblyPublicKey = Assembly.GetExecutingAssembly().GetName().GetPublicKey();
    private static readonly string keyFile = GenerateKeyFile();
    private static byte[] keyFileBytes = null;
    private static ResourceData resourceData = null;
    private static readonly string shadowCopyDir = Path.Combine(Path.GetTempPath(), "MTCodeGeneration");
    #endregion
  }

  #region Helper classes
  public class ConfigPropertyData
  {
        public ConfigPropertyData()
        {
            Filterable = true;
            Action = false;
            Condition = false;
            OperatorPerRule = false;
            Exportable = true;
            UserVisible = true;
            isEnum = false;
            isPartOfKey = false;
        }

    private string name;
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    private Type propertyType;
    public Type PropertyType
    {
      get { return propertyType; }
      set { propertyType = value; }
    }

    private int length;
    public int Length
    {
      get { return length; }
      set { length = value; }
    }

    private bool isRequired;
    public bool IsRequired
    {
      get { return isRequired; }
      set { isRequired = value; }
    }

    private object defaultValue;
    public object DefaultValue
    {
      get { return defaultValue; }
      set { defaultValue = value; }
    }

    private string description;
    public string Description
    {
      get { return description; }
      set { description = value; }
    }

    private bool isEnum;
    public bool IsEnum
    {
      get { return isEnum; }
      set { isEnum = value; }
    }

    private bool isPartOfKey;
    public bool IsPartOfKey
    {
      get { return isPartOfKey; }
      set { isPartOfKey = value; }
    }

    private string msixType;
    public string MsixType
    {
      get { return msixType; }
      set { msixType = value; }
    }

        public bool Action { get; set; }
        public bool Condition { get; set; }
        public bool Operator { get; set; }
        public bool Filterable { get; set; }
        public bool OperatorPerRule { get; set; }
        public bool Exportable { get; set; }
        public bool UserVisible { get; set; }
  }


  public delegate T ConvertValue<T>(string value);

  public class ConfigValueHelper
  {
      static public bool ConvertToBool(string configString)
      {
          return ((String.Compare(configString, "YES", true) == 0 
                  || String.Compare(configString, "TRUE", true) == 0
                  || String.Compare(configString, "1") == 0) ? true : false);
      }
  }

  public interface IAttributeDeclaration
  {
      bool AddArgument(XmlNode argument);
      bool AddArgument(XmlNode rootNode, string argumentXPath);
      bool AddArgument(XmlNode rootNode, string argumentXPath, string attributeProperty);
      bool AddArgument(string name, object value);

      bool AddArgument<T>(XmlNode argument, ConvertValue<T> converter);
      bool AddArgument<T>(XmlNode rootNode, string argumentXPath, ConvertValue<T> converter);

      bool AddArgument<T>(XmlNode argument, ConvertValue<T> converter, string attributeProperty);
      bool AddArgument<T>(XmlNode rootNode, string argumentXPath, string attributeProperty, ConvertValue<T> converter);


      CodeAttributeDeclaration Attribute { get; }
  }

  public class AttributeDeclarationFactory
  {
      public AttributeDeclarationFactory()
      { }

      public static IAttributeDeclaration Get(string attributeType)
      {
          IAttributeDeclaration attr = new AttributeCodeDeclaration(attributeType);
          return attr;
  }

      public static IAttributeDeclaration Get<T>() where T : Attribute
      {
          IAttributeDeclaration attr = new AttributeCodeDeclaration(typeof(T).FullName);
          return attr;
      }

      private class AttributeCodeDeclaration : IAttributeDeclaration
      {
          public AttributeCodeDeclaration(string attributeType) 
          {
              this.attributeType = attributeType;
          }

          public bool AddArgument(XmlNode argument)
          {
              return AddArgument(argument, (ConvertValue<bool>)null);
          }

          public bool AddArgument<T>(XmlNode argument, ConvertValue<T> converter)
          {
              if (argument == null)
              {
                  logger.LogError("CustomAttributeBuilder.AddArgument() - invalid argument (null).");
                  return false;
              }

              if (String.IsNullOrEmpty(argument.InnerText.Trim()))
              {
                  logger.LogWarning(String.Format("Cannot add attribute argument: XMLNode {0} has no value", argument.Name));
                  return true;
              }

              string strValue = argument.InnerText.Trim();
              object objValue = null;
              if (converter != null)
              {
                  objValue = converter(strValue);
              }
              else
              {
                  objValue = strValue;
              }

              attributeArgs.Add(new CodeAttributeArgument(argument.Name, new CodePrimitiveExpression(objValue)));

              return true;
          }

          public bool AddArgument(XmlNode rootNode, string argumentXPath)
          {
              return AddArgument<bool>(rootNode, argumentXPath, null);
          }

          public bool AddArgument<T>(XmlNode rootNode, string argumentXPath, ConvertValue<T> converter)
          {
              if (rootNode == null)
              {
                  logger.LogError("CustomAttributeBuilder.AddArgument() - invalid rootNode argument (null).");
                  return false;
              }

              if (String.IsNullOrEmpty(argumentXPath))
              {
                  logger.LogError(String.Format("CustomAttributeBuilder.AddArgument() - invalid argumentXPath argument."));
                  return false;
              }

              XmlNode argNode = rootNode.SelectSingleNode(argumentXPath);

              if (argNode == null)
              {
                  logger.LogError("CustomAttributeBuilder.AddArgument() - unable to find {0} rooted at {1}.", argumentXPath, rootNode.Name);
                  return false;
              }

              if (String.IsNullOrEmpty(argNode.InnerText.Trim()))
              {
                  logger.LogWarning(String.Format("Cannot add attribute argument: XMLNode {0} has no value", argNode.Name));
                  return true;
              }

              string strValue = argNode.InnerText.Trim();
              object objValue = null;
              if (converter != null)
              {
                  objValue = converter(strValue);
              }
              else
              {
                  objValue = strValue;
              }

              attributeArgs.Add(new CodeAttributeArgument(argNode.Name, new CodePrimitiveExpression(objValue)));

              return true;
          }

          public bool AddArgument(string name, object value)
          {
              attributeArgs.Add(new CodeAttributeArgument(name, new CodePrimitiveExpression(value)));
              return true;
          }

          public bool AddArgument<T>(XmlNode argument, ConvertValue<T> converter, string attributeProperty)
          {
              if (argument == null)
              {
                  logger.LogError("CustomAttributeBuilder.AddArgument() - invalid argument (null).");
                  return false;
              }

              if (String.IsNullOrEmpty(argument.InnerText.Trim()))
              {
                  logger.LogWarning(String.Format("Cannot add attribute argument: XMLNode {0} has no value", argument.Name));
                  return true;
              }

              string strValue = argument.InnerText.Trim();
              object objValue = null;
              if (converter != null)
              {
                  objValue = converter(strValue);
              }
              else
              {
                  objValue = strValue;
              }

              attributeArgs.Add(new CodeAttributeArgument(attributeProperty, new CodePrimitiveExpression(objValue)));

              return true;
          }

          public bool AddArgument(XmlNode rootNode, string argumentXPath, string attributeProperty)
          {
              return AddArgument<bool>(rootNode, argumentXPath, attributeProperty, (ConvertValue<bool>)null);
          }

          public bool AddArgument<T>(XmlNode rootNode, string argumentXPath, string attributeProperty, ConvertValue<T> converter)
          {
              if (rootNode == null)
              {
                  logger.LogError("CustomAttributeBuilder.AddArgument() - invalid rootNode argument (null).");
                  return false;
              }

              XmlNode argNode = null;

              if (!String.IsNullOrEmpty(argumentXPath))
              {

                  argNode = rootNode.SelectSingleNode(argumentXPath);

                  if (argNode == null)
                  {
                      logger.LogError("CustomAttributeBuilder.AddArgument() - unable to find {0} rooted at {1}.", argumentXPath, rootNode.Name);
                      return false;
                  }

                  if (String.IsNullOrEmpty(argNode.InnerText.Trim()))
                  {
                      logger.LogWarning(String.Format("Cannot add attribute argument: XMLNode {0} has no value", argNode.Name));
                      return true;
                  }
              }
              else
              {
                  argNode = rootNode;
              }

              string strValue = argNode.InnerText.Trim();
              if (String.IsNullOrEmpty(argNode.InnerText.Trim()))
              {
                  logger.LogWarning(String.Format("Cannot add attribute argument: XMLNode {0} has no value", argNode.Name));
                  return true;
              }

              object objValue = null;
              if (converter != null)
              {
                  objValue = converter(strValue);
              }
              else
              {
                  objValue = strValue;
              }

              attributeArgs.Add(new CodeAttributeArgument(attributeProperty, new CodePrimitiveExpression(objValue)));

              return true;
          }

          public CodeAttributeDeclaration Attribute
          {
              get
              {

                  CodeAttributeDeclaration attribute = null;

                  if (attributeArgs.Count > 0)
                  {
                      attribute = new CodeAttributeDeclaration(attributeType, attributeArgs.ToArray());
                  }
                  else
                  {
                      attribute = new CodeAttributeDeclaration(attributeType);
                  }

                  return attribute;
              }
          }

          string attributeType;
          private Logger logger = BaseCodeGenerator.Logger;
          List<CodeAttributeArgument> attributeArgs = new List<CodeAttributeArgument>();
      }
  } 
  
  #endregion
}
