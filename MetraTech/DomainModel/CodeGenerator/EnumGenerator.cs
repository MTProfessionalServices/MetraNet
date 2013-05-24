using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.CodeDom;
using System.Reflection;
using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class EnumGenerator : BaseCodeGenerator
  {

    #region Public Static Methods
    /// <summary>
    ///   Returns the singleton EnumGenerator.
    /// </summary>
    /// <returns></returns>
    public static EnumGenerator GetInstance()
    {
      return instance;
    }

    /// <summary>
    ///   Initializes ResourceData by loading the generated assembly and reflecting over types.
    /// </summary>
    public static void InitResourceData()
    {
      if (resourceData != null)
      {
        return;
      }

      resourceData = new ResourceData();
      Assembly assembly = GetAssembly(enumAssemblyName);
      if (assembly == null)
      {
          logger.LogDebug(String.Format("Unable to load assembly '{0}'", enumAssemblyName));
          return;
      }
      Dictionary<string, int> localizationFiles = new Dictionary<string, int>();

      foreach(Type type in assembly.GetTypes())
      {
        if (!type.IsEnum) continue;

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
        foreach(string mtLocalizationId in attribute.MTLocalizationIds)
        {
          resourceData.AddResource(mtLocalizationId, 
                                   attribute.ResourceIds[i], 
                                   attribute.DefaultValues[i],
                                   attribute.Extension,
                                   attribute.LocaleSpace);
          i++;
        }
      }
    }
    #endregion

    #region Public Methods
    /// <summary>
    ///    GenerateCode
    /// </summary>
    public bool GenerateCode(bool debugMode)
    {
      try
      {
        List<EnumFileData> enumFiles = EnumFileData.GetEnumFileData();

        Dictionary<string, FileData> allFiles = new Dictionary<string, FileData>();

        foreach (EnumFileData fileData in enumFiles)
        {
          allFiles.Add(fileData.ChecksumKey, fileData);
        }

        // No need to generate assembly if input files (including resources) haven't changed
        if (ChecksumsMatch(Checksums, allFiles))
        {
          assemblyGenerated = false;
          logger.LogDebug(String.Format("Assembly '{0}' was not generated because its input files haven't changed", enumAssemblyName));
          return true;
        }


        // Initialize resourceData
        resourceData = new ResourceData();

        CodeCompileUnit codeCompileUnit = new CodeCompileUnit();

        // Initialize the codeCompileUnit with assembly attributes as shown below
        // codeCompileUnit.AssemblyCustomAttributes.Add
        //  (new CodeAttributeDeclaration("AssemblyVersion", 
        //                                new CodeAttributeArgument(new CodePrimitiveExpression("5.1.0.0"))));

        // Collect all the EnumSpaces
        List<EnumSpace> enumSpaces = new List<EnumSpace>();
        foreach(EnumFileData enumFileData in enumFiles)
        {
          enumSpaces.AddRange(enumFileData.EnumSpaces);
        }
      
        foreach (EnumSpace enumSpace in enumSpaces)
        {
          foreach (EnumType enumType in enumSpace.EnumTypes)
          {
            string nameSpace = enumNamespace + "." +
                                   MakeAlphaNumeric(enumSpace.FileData.ExtensionName) + "." +
                                   MakeAlphaNumeric(enumSpace.Name);

            CodeNamespace codeNamespace = new CodeNamespace(nameSpace);
            codeCompileUnit.Namespaces.Add(codeNamespace);

            CodeTypeDeclaration enumCode = CreateEnum(enumType, nameSpace, enumSpace.FileData.ExtensionName);
            codeNamespace.Types.Add(enumCode);
          }
        }

        // TODO Remove after testing
        // WriteFile(codeCompileUnit, @"S:\MetraTech\DomainModel\test.cs");

        // Generate the temporary .resources files
        List<string> resourceFiles = new List<string>();

        // Generate the checksum.resources files
        string checksumResourceFile = FileData.CreateChecksumResource(allFiles, checksumResourceFileName);
        resourceFiles.Add(checksumResourceFile);

        Dictionary<string, CodeCompileUnit> codeUnits = new Dictionary<string, CodeCompileUnit>();
        codeUnits.Add("Enums.cs", codeCompileUnit);

        List<string> referencedSystemAssemblies = new List<string>();
        referencedSystemAssemblies.Add("System.dll");

        List<string> referencedLocalAssemblies = new List<string>();
        referencedLocalAssemblies.Add("MetraTech.DomainModel.Common.dll");

        if (!BuildAssembly(enumAssemblyName,
                           codeUnits,
                           referencedSystemAssemblies,
                           referencedLocalAssemblies,
                           resourceFiles,
                           debugMode,
                           @"Enums"))
        {
          return false;
        }
      }
      catch (Exception e)
      {
        logger.LogException(String.Format("Code generation for enums failed."), e);
        return false;
      }

      return true;
    }
    #endregion

    #region Private Methods

    // Private constructor
    private EnumGenerator()
    {
    }

    /// <summary>
    ///    Create an enum that resembles the following structure:
    /// 
    ///    [MTEnum(EnumSpace = "metratech.com/accountcreation",
    ///            EnumName = "AccountStatus",
    ///            StoredAsInt = false,           
    ///            OldEnumValues = new string[] { "0:\"PendingActiveApproval\":PA", 
    ///                                           "1:\"Active\":AC", 
    ///                                           "2:\"Suspended\":SU", 
    ///                                           "3:\"PendingFinalBill\":PF", 
    ///                                           "4:\"Closed\":CL", 
    ///                                           "5:\"Archived\":AR" },
    /// 
    ///            Keys = new string[] { "metratech.com/accountcreation/AccountStatus/PendingActiveApproval", 
    ///                                  "metratech.com/accountcreation/AccountStatus/Active", 
    ///                                  "metratech.com/accountcreation/AccountStatus/Suspended", 
    ///                                  "metratech.com/accountcreation/AccountStatus/PendingFinalBill", 
    ///                                  "metratech.com/accountcreation/AccountStatus/Closed", 
    ///                                  "metratech.com/accountcreation/AccountStatus/Archived" })]
    /// 
    ///    [MTEnumLocalizationAttribute
    ///            Extension = "Accounts"
    ///            LocaleSpace = "metratech.com/accountcreation"
    ///            MTLocalizationIds = new string[] { "metratech.com/accountcreation/AccountStatus/PendingActiveApproval", 
    ///                                               "metratech.com/accountcreation/AccountStatus/Active", 
    ///                                               "metratech.com/accountcreation/AccountStatus/Suspended", 
    ///                                               "metratech.com/accountcreation/AccountStatus/PendingFinalBill", 
    ///                                               "metratech.com/accountcreation/AccountStatus/Closed", 
    ///                                               "metratech.com/accountcreation/AccountStatus/Archived" })]
    ///            ResourceIds = new string[] { "MetraTech.DomainModel.Enums.AccountStatus.PendingActiveApproval", 
    ///                                         "MetraTech.DomainModel.Enums.AccountStatus.Active", 
    ///                                         "MetraTech.DomainModel.Enums.AccountStatus.Suspended", 
    ///                                         "MetraTech.DomainModel.Enums.AccountStatus.PendingFinalBill", 
    ///                                         "MetraTech.DomainModel.Enums.AccountStatus.Closed", 
    ///                                         "MetraTech.DomainModel.Enums.AccountStatus.Archived" })]
    /// 
    ///    public enum AccountStatus
    ///    {
    ///      PendingActiveApproval = 0,
    ///      Active = 1,
    ///      Suspended = 2,
    ///      PendingFinalBill = 3,
    ///      Closed = 4,
    ///      Archived = 5
    ///    }
    /// </summary>
    /// <param name="enumType"></param>
    /// <param name="nameSpace"></param>
    /// <param name="extension"></param>
    /// <returns></returns>
    private CodeTypeDeclaration CreateEnum(EnumType enumType, string nameSpace, string extension)
    {
      CodeTypeDeclaration enumCode = new CodeTypeDeclaration();
      enumCode.Name = MakeAlphaNumeric(enumType.Name);
      enumCode.IsEnum = true;

      int i = 0;
      CodePrimitiveExpression[] arrayItems = new CodePrimitiveExpression[enumType.EntryValues.Count];
      CodePrimitiveExpression[] keys = new CodePrimitiveExpression[enumType.EntryValues.Count];
      CodePrimitiveExpression[] resourceIds = new CodePrimitiveExpression[enumType.EntryValues.Count];
      CodePrimitiveExpression[] defaultValues = new CodePrimitiveExpression[enumType.EntryValues.Count];

      foreach (string entryName in enumType.EntryValues.Keys)
      {
        List<string> values = enumType.EntryValues[entryName];
        CodeMemberField enumField = new CodeMemberField();
        enumField.Name = MakeAlphaNumeric(entryName);
        enumField.InitExpression = new CodePrimitiveExpression(i);
        enumCode.Members.Add(enumField);

        string existingEnumValue = i + @":""" + entryName + @""":";

        int j = 0;
        foreach(string value in values)
        {
          if (j > 0)
          {
            existingEnumValue += ":" + value;
          }
          else
          {
            existingEnumValue += value;
          }
          j++;
        }

        string mtLocalizationId = enumType.FQN.ToLower() + "/" + entryName.ToLower();
        string resourceId = nameSpace + "." + enumCode.Name + "." + enumField.Name;

        resourceData.AddResource(mtLocalizationId, 
                                 resourceId, 
                                 enumField.Name, 
                                 enumType.EnumSpace.FileData.ExtensionName,
                                 enumType.EnumSpace.Name);

        arrayItems[i] = new CodePrimitiveExpression(existingEnumValue);
        keys[i] = new CodePrimitiveExpression(mtLocalizationId);
        resourceIds[i] = new CodePrimitiveExpression(resourceId);
        defaultValues[i] = new CodePrimitiveExpression(entryName);
        i++;
      }

      // Create the MTEnum attribute
      CodeAttributeArgument[] attributeItems = new CodeAttributeArgument[3];
      attributeItems[0] =
        (new CodeAttributeArgument("EnumSpace", new CodePrimitiveExpression(enumType.EnumSpace.Name)));
      attributeItems[1] =
        (new CodeAttributeArgument("EnumName", new CodePrimitiveExpression(enumType.Name)));

      CodeArrayCreateExpression array = 
        new CodeArrayCreateExpression(new CodeTypeReference("System.String"), arrayItems);
      
      attributeItems[2] = (new CodeAttributeArgument("OldEnumValues", array));

      CodeAttributeDeclaration mtEnumAttribute =
        new CodeAttributeDeclaration(MTEnumAttribute.QualifiedName, attributeItems);

      enumCode.CustomAttributes.Add(mtEnumAttribute);

      // Create the MTLocalization attribute
      attributeItems = new CodeAttributeArgument[6];
      attributeItems[0] =
        (new CodeAttributeArgument("Extension", new CodePrimitiveExpression(extension)));
      attributeItems[1] =
        (new CodeAttributeArgument("LocaleSpace", new CodePrimitiveExpression(enumType.EnumSpace.Name)));
      CodeArrayCreateExpression resourceIdArray =
        new CodeArrayCreateExpression(new CodeTypeReference("System.String"), resourceIds);
      attributeItems[2] = (new CodeAttributeArgument("ResourceIds", resourceIdArray));
      CodeArrayCreateExpression keyArray =
        new CodeArrayCreateExpression(new CodeTypeReference("System.String"), keys);
      attributeItems[3] = (new CodeAttributeArgument("MTLocalizationIds", keyArray));
      CodeArrayCreateExpression defaultValuesArray =
        new CodeArrayCreateExpression(new CodeTypeReference("System.String"), defaultValues);
      attributeItems[4] = (new CodeAttributeArgument("DefaultValues", defaultValuesArray));

      string[] localizationFileNames = enumType.EnumSpace.FileData.LocalizationFileNames;
      CodePrimitiveExpression[] localizationFiles = new CodePrimitiveExpression[localizationFileNames.Length];
      for (int j = 0; j < localizationFileNames.Length; j++)
      {
        localizationFiles[j] = new CodePrimitiveExpression(localizationFileNames[j]);
      }
      CodeArrayCreateExpression localizationFilesArray =
        new CodeArrayCreateExpression(new CodeTypeReference("System.String"), localizationFiles);
      attributeItems[5] = (new CodeAttributeArgument("LocalizationFiles", localizationFilesArray));

      CodeAttributeDeclaration mtLocalizationAttribute =
        new CodeAttributeDeclaration(MTEnumLocalizationAttribute.QualifiedName, attributeItems);

      enumCode.CustomAttributes.Add(mtLocalizationAttribute);

      return enumCode;
    }

  
    /// <summary>
    ///    Return false if the output assembly cannot be opened for writing.
    /// </summary>
    private bool CheckOutputAssembly(string assemblyName)
    {
      bool canOpenForWriting = true;

      try
      {
        FileStream fileStream = File.Open(assemblyName, FileMode.Create);
        fileStream.Close();
      }
      catch (Exception e)
      {
        string msg = "Unable to create enum assembly '" + assemblyName + "'";
        Console.WriteLine(msg + " See log for details.");
        logger.LogException(msg, e);
        canOpenForWriting = false;
      }

      return canOpenForWriting;
    }

    #endregion

    #region Properties
    public static Dictionary<string, string> Checksums
    {
      get
      {
        return checksums;
      }
    }

    public static bool AssemblyGenerated
    {
      get
      {
        return assemblyGenerated;
      }
    }

    public new static ResourceData ResourceData
    {
      get
      {
        return resourceData;
      }
    }

    public static string EnumSpace
    {
        get
        {
            return enumNamespace;
        }

    }

    #endregion

    #region Data

    // Static members are lazily initialized. 
    // .NET guarantees thread safety for static initialization 
    private static readonly EnumGenerator instance = new EnumGenerator(); 

    private const string enumNamespace = "MetraTech.DomainModel.Enums";
    public const string enumAssemblyName = "MetraTech.DomainModel.Enums.Generated.dll";
    public const string checksumResourceFileName = "checksum.resources";

    // initialized in the constructor
    private static readonly Dictionary<string, string> checksums = GetChecksums(enumAssemblyName, checksumResourceFileName);
    private static bool assemblyGenerated = true;
    private static ResourceData resourceData;

    #endregion
  }
}
