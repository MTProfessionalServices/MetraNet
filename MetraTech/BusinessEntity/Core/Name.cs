using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Exception;
using MetraTech.BusinessEntity.Core.Model;
using NHibernate.Util;

namespace MetraTech.BusinessEntity.Core
{
  /// <summary>

  /// </summary>
  public static class Name
  {
    #region Entity
    /// <summary>
    ///    The input could look like one of the following:
    ///     (1) MetraTech.BusinessEntity.OrderManagement.OrderItem, MetraTech.BusinessEntity
    ///     (2) MetraTech.BusinessEntity.OrderManagement.OrderItem
    ///     (2) OrderItem
    ///     
    ///    For (1) and (2), return 'MetraTech.BusinessEntity.OrderManagement.OrderItem'
    ///    For (2), return defaultNamespace + OrderItem
    /// </summary>
    /// <param name="input"></param>
    /// <param name="defaultNamespace"></param>
    /// <returns></returns>
    public static string GetFullClassName(string input, string defaultNamespace)
    {
      string fullClassName = String.Empty;

      AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(input);
      fullClassName = assemblyQualifiedTypeName.Type;
      if (String.IsNullOrEmpty(StringHelper.Qualifier(fullClassName)))
      {
        fullClassName = defaultNamespace + "." + fullClassName;
      }

      return fullClassName;
    }

    public static void GetPartsOfName(string typeName, 
                                      out string entityClassName, 
                                      out string nameSpace, 
                                      out string extensionName,
                                      out string entityGroupName,
                                      out string assemblyName,
                                      out string assemblyQualifiedName)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(IsValidEntityTypeName(typeName),
                    String.Format("Type name '{0}' is invalid", typeName),
                    SystemConfig.CallerInfo);

      entityClassName = GetEntityClassName(typeName, false);
      nameSpace = GetEntityNamespace(typeName, false);
      extensionName = GetExtensionName(typeName, false);
      entityGroupName = GetEntityGroupName(typeName, false);
      assemblyName = GetEntityAssemblyName(typeName);
      assemblyQualifiedName = GetEntityAssemblyQualifiedName(typeName);

      Check.Ensure(!String.IsNullOrEmpty(entityClassName), String.Format("Cannot get class name from type '{0}'", typeName), SystemConfig.CallerInfo);
      Check.Ensure(!String.IsNullOrEmpty(nameSpace), String.Format("Cannot get name space from type '{0}'", typeName), SystemConfig.CallerInfo);
      Check.Ensure(!String.IsNullOrEmpty(extensionName), String.Format("Cannot get extension from type '{0}'", typeName), SystemConfig.CallerInfo);
      Check.Ensure(!String.IsNullOrEmpty(entityGroupName), String.Format("Cannot get entity group from type '{0}'", typeName), SystemConfig.CallerInfo);
      Check.Ensure(!String.IsNullOrEmpty(assemblyName), String.Format("Cannot get assembly name from type '{0}'", typeName), SystemConfig.CallerInfo);
      Check.Ensure(!String.IsNullOrEmpty(assemblyQualifiedName), String.Format("Cannot get assembly qualified name from type '{0}'", typeName), SystemConfig.CallerInfo);
    }

    /// <summary>
    ///    Get the extension name and entity group name from the specified typeName.
    /// </summary>
    /// <param name="typeName"></param>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    public static void GetExtensionAndEntityGroup(string typeName,
                                                  out string extensionName,
                                                  out string entityGroupName)
    {
      string className, nameSpace, assemblyName, assemblyQualifiedName;
      GetPartsOfName(typeName,
                     out className,
                     out nameSpace,
                     out extensionName,
                     out entityGroupName,
                     out assemblyName,
                     out assemblyQualifiedName);
    }

    /// <summary>
    ///    Get the extension name and entity group name from the specified typeName.
    /// </summary>
    /// <param name="typeName"></param>
    /// <param name="className"></param>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    public static void GetExtensionAndEntityGroupAndClass(string typeName,
                                                          out string extensionName,
                                                          out string entityGroupName,
                                                          out string className)
    {
      string nameSpace, assemblyName, assemblyQualifiedName;
      GetPartsOfName(typeName,
                     out className,
                     out nameSpace,
                     out extensionName,
                     out entityGroupName,
                     out assemblyName,
                     out assemblyQualifiedName);
    }

    public static string GetExtensionName(string typeName)
    {
      return GetExtensionName(typeName, true);
    }

    public static string GetEntityGroupName(string typeName)
    {
      return GetEntityGroupName(typeName, true);
    }

    public static string GetEntityClassName(string typeName)
    {
      return GetEntityClassName(typeName, true);
    }

    public static string GetEntityNamespace(string typeName)
    {
      return GetEntityNamespace(typeName, true);
    }

    public static string GetEntityNamespace(string extensionName, string entityGroupName)
    {
      return extensionName + "." + entityGroupName;
    }
    
    public static string GetEntityBusinessKeyClassName(string typeName)
    {
      // History entities have the same business key as the original entity
      string actualTypeName = typeName.EndsWith("History") ? typeName.Substring(0, typeName.Length - 7) : typeName;
      return GetEntityClassName(actualTypeName, true) + "BusinessKey";
    }

    public static string GetEntityBusinessKeyFullName(string typeName)
    {
      // History entities have the same business key as the original entity
      string actualTypeName = typeName.EndsWith("History") ? typeName.Substring(0, typeName.Length - 7) : typeName;
      return GetEntityNamespace(actualTypeName) + "." + GetEntityBusinessKeyClassName(actualTypeName);
    }

    public static string GetEntityBusinessKeyAssemblyQualifiedName(string typeName)
    {
      return GetEntityBusinessKeyFullName(typeName) + ", " + GetEntityAssemblyName(typeName);
    }

    public static string GetEntityBusinessKeyInterfaceName(string typeName)
    {
      // History entities have the same business key as the original entity
      string actualTypeName = typeName.EndsWith("History") ? typeName.Substring(0, typeName.Length - 7) : typeName;
      return GetInterfaceName(actualTypeName, true) + "BusinessKey";
    }

    public static string GetBusinessKeyPropertyName(string typeName)
    {
      return GetEntityClassName(typeName) + "BusinessKey";
    }

    public static string GetBusinessKeyFieldName(string typeName)
    {
      return "_" + GetBusinessKeyPropertyName(typeName).LowerCaseFirst();
    }

    public static string GetEntityBusinessKeyInterfaceFullName(string typeName)
    {
      // History entities have the same business key as the original entity
      string actualTypeName = typeName.EndsWith("History") ? typeName.Substring(0, typeName.Length - 7) : typeName;
      return GetInterfaceFullName(actualTypeName, true) + "BusinessKey";
    }

    public static string GetEntityHistoryClassName(string typeName)
    {
      return GetEntityClassName(typeName, true) + "History";
    }

    public static string GetLegacyClassName(string typeName)
    {
      return GetEntityClassName(typeName, true) + "_Legacy";
    }

    public static string GetLegacyFullName(string typeName)
    {
      return GetEntityNamespace(typeName) + "." + GetLegacyClassName(typeName);
    }

    public static string GetLegacyAssemblyQualifiedName(string typeName)
    {
      return GetLegacyFullName(typeName) + ", " + GetEntityAssemblyName(typeName);
    }

    public static List<string> GetEntityAssemblyNames()
    {
      var assemblyNames = new List<string>();

      Dictionary<string, List<string>> entityGroupsByExtension =
        SystemConfig.GetEntityGroupsByExtension();

      foreach(string extensionName in entityGroupsByExtension.Keys)
      {
        List<String> entityGroupNames = entityGroupsByExtension[extensionName];
        foreach(string entityGroupName in entityGroupNames)
        {
          string csProjFile = GetEntityCsProjFile(extensionName, entityGroupName);
          if (File.Exists(csProjFile))
          {
            assemblyNames.Add(GetEntityAssemblyName(extensionName, entityGroupName));
          }
        }
      }

      return assemblyNames;
    }
    /// <summary>
    ///   Given a namespace qualified type name, return the assembly name.
    ///   The assumption is that all namespace qualified type names start with the extension name.
    /// </summary>
    /// <param name="typeName"></param>
    /// <returns></returns>
    public static string GetEntityAssemblyName(string typeName)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(IsValidEntityTypeName(typeName),
                    String.Format("Type name '{0}' is invalid", typeName),
                    SystemConfig.CallerInfo);

      return GetExtensionName(typeName, false) + "." + GetEntityGroupName(typeName, false) + ".Entity";
    }

    /// <summary>
    ///   Given a namespace qualified type name, return the assembly name.
    ///   The assumption is that all namespace qualified type names start with the extension name.
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    public static string GetEntityAssemblyName(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty", SystemConfig.CallerInfo);


      return extensionName + "." + entityGroupName + ".Entity";
    }

    public static string GetEntityAssemblyNameWithPath(string extensionName, string entityGroupName)
    {
      string name = GetEntityAssemblyName(extensionName, entityGroupName) + ".dll";
      return Path.Combine(SystemConfig.GetBinDir(), name);
    }

    /// <summary>
    ///   Given a namespace qualified type name, return the assembly qualified name.
    ///   The assumption is that all namespace qualified type names start with the extension name.
    /// </summary>
    /// <param name="typeName"></param>
    /// <returns></returns>
    public static string GetEntityAssemblyQualifiedName(string typeName)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(IsValidEntityTypeName(typeName),
                    String.Format("Type name '{0}' is invalid", typeName),
                    SystemConfig.CallerInfo);

      return typeName + ", " + GetEntityAssemblyName(typeName);
    }

    public static string GetEntityHistoryAssemblyQualifiedName(string typeName)
    {
      return GetEntityHistoryTypeName(typeName) + ", " + GetEntityAssemblyName(typeName);
    }

    public static string GetEntityHistoryTableName(string entityTableName)
    {
      Check.Require(!String.IsNullOrEmpty(entityTableName), "entityTableName cannot be null or empty");
      return entityTableName.Truncate(26) + "_h";
    }

    public static string GetEntityHistoryTypeName(string entityTypeName)
    {
      Check.Require(!String.IsNullOrEmpty(entityTypeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(IsValidEntityTypeName(entityTypeName),
                    String.Format("Type name '{0}' is invalid", entityTypeName),
                    SystemConfig.CallerInfo);

      return entityTypeName + "History";
    }

    public static bool IsValidEntityTypeName(string typeName)
    {
      List<ErrorObject> errors;
      return IsValidEntityTypeName(typeName, out errors);
    }

    /// <summary>
    ///    Create a new csproj in the RMP\extensions\extensionName\BusinessEntity\entityGroupName\entity
    ///    using the starter csproj StarterBusinessEntity.csproj in RMP\Config\BusinessEntity.
    /// </summary>
    public static string CreateEntityCsProj(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty", SystemConfig.CallerInfo);

      string csProj = SystemConfig.GetStarterCsProjFile();

      // update the csproj
      XDocument xmldoc = XDocument.Load(csProj);

      XmlNamespaceManager namespaceManager = new XmlNamespaceManager(new NameTable());
      namespaceManager.AddNamespace("n", "http://schemas.microsoft.com/developer/msbuild/2003");

      #region ProjectGuid
      XElement xElement = xmldoc.XPathSelectElement("n:Project/n:PropertyGroup/n:ProjectGuid", namespaceManager);
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <Project><PropertyGroup><ProjectGuid> in file '{0}'", csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }
      xElement.SetValue(Guid.NewGuid());
      #endregion

      #region RootNamespace
      xElement = xmldoc.XPathSelectElement("n:Project/n:PropertyGroup/n:RootNamespace", namespaceManager);
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <Project><PropertyGroup><RootNamespace> in file '{0}'", csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      if (String.IsNullOrEmpty(xElement.Value) || !xElement.Value.Equals("BusinessEntity"))
      {
        string message = String.Format("The value '{0}' for <Project><PropertyGroup><RootNamespace> in file '{1}' is incorrect. Expected to find 'TemplateBusinessEntity'.", xElement.Value, csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      string rootNamespace = extensionName + "." + entityGroupName;
      xElement.SetValue(rootNamespace);
      #endregion

      #region AssemblyName
      xElement = xmldoc.XPathSelectElement("n:Project/n:PropertyGroup/n:AssemblyName", namespaceManager);
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <Project><PropertyGroup><AssemblyName> in file '{0}'", csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      if (String.IsNullOrEmpty(xElement.Value) || !xElement.Value.Equals("BusinessEntity"))
      {
        string message = String.Format("The value '{0}' for <Project><PropertyGroup><AssemblyName> in file '{1}' is incorrect. Expected to find 'TemplateBusinessEntity'.", xElement.Value, csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      xElement.SetValue(rootNamespace + ".Entity");
      #endregion

      string csProjFile = Path.Combine(GetEntityDir(extensionName, entityGroupName),
                                       rootNamespace + ".Entity.csproj");
      xmldoc.Save(csProjFile);

      return csProjFile;
    }

    /// <summary>
    ///   Given a namespace qualified type name, return true if this is valid type name.
    ///   Otherwise, return false with a list of errors.
    /// 
    ///   The assumption is that all namespace qualified type names have atleast 3 sections, where
    ///   the first section is the extension name, the second
    ///   section is the Entity group name and the third section is the Class name.
    /// 
    ///   e.g. Core.Common.EnumEntry
    /// </summary>
    /// <param name="typeName"></param>
    /// <returns></returns>
    public static bool IsValidEntityTypeName(string typeName, out List<ErrorObject> errors)
    {
      errors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(typeName))
      {
        string message = String.Format("Invalid type name '{0}'.", typeName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_INVALID_CLASS_IDENTIFIER;
        errorData.ErrorType = ErrorType.EntityValidation;
        errors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
        return false;
      }

      string[] sections = typeName.Split(new[] { '.' });

      if (sections.Length < 3)
      {
        string message = String.Format("Invalid type name '{0}'.", typeName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_INVALID_CLASS_IDENTIFIER;
        errorData.ErrorType = ErrorType.EntityValidation;
        errors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
        return false;
      }

      // Validate the sections
      for (int i = 0; i < sections.Length; i++)
      {
        string section = sections[i];
        if (!IsValidIdentifier(section))
        {
          string message = String.Format("Section '{0}' in type name '{1}' is not a valid C# identifier", section, typeName);
          var errorData = new EntityValidationErrorData();
          errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_INVALID_IDENTIFIER;
          errorData.ErrorType = ErrorType.EntityValidation;
          errors.Add(new ErrorObject(message, errorData));
          logger.Error(message);
        }
      }

      if (errors.Count > 0)
      {
        return false;
      }

      return true;
    }
   
    public static string GetComputedPropertyNamespace(string entityName)
    {
      return GetEntityNamespace(entityName) + ".ComputedProperty";
    }

    public static string GetComputedPropertyNamespace(string extensionName, string entityGroupName)
    {
      return extensionName + "." + entityGroupName + ".ComputedProperty";
    }

    public static string GetComputedPropertyCsProj(string extensionName, string entityGroupName)
    {
      return extensionName + "." + entityGroupName + ".ComputedProperty.csproj";
    }

    public static string GetComputedPropertyClassName(string entityName, string computedPropertyName)
    {
      return GetEntityClassName(entityName) + "_" + computedPropertyName;
    }

    public static string GetComputedPropertyTempDir(string entityName)
    {
      string extensionName, entityGroupName;
      GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
      return SystemConfig.GetComputedPropertyTempDir(extensionName, entityGroupName);
    }

    public static string GetComputedPropertyAssemblyName(string entityName)
    {
      string extensionName, entityGroupName;
      GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
      return extensionName + "." + entityGroupName + ".ComputedProperty.dll";
    }

    public static string GetComputedPropertyAssemblyName(string extensionName, string entityGroupName)
    {
      return extensionName + "." + entityGroupName + ".ComputedProperty.dll";
    }

    public static string GetComputedPropertyAssemblyNameWithPath(string extensionName, string entityGroupName)
    {
      return Path.Combine(SystemConfig.GetBinDir(), GetComputedPropertyAssemblyName(extensionName, entityGroupName));
    }

    //public static EntityGroupData GetEntityGroupData(string entityName)
    //{
    //  string extensionName, entityGroupName;
    //  GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
    //  return new EntityGroupData(extensionName, entityGroupName);
    //}

    #endregion

    #region Interface
    public static string GetInterfaceName(string typeName)
    {
      return GetInterfaceName(typeName, true);
    }

    public static string GetInterfaceNamespace(string typeName)
    {
      return GetInterfaceNamespace(typeName, true);
    }

    public static string GetInterfaceCsProjFileName(string extension)
    {
      return extension + ".Interface.csproj";
    }

    public static string GetInterfaceCsProjDefaultNamespace(string extension)
    {
      return extension + ".Interface";
    }

    public static string GetInterfaceFullName(string typeName)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(IsValidEntityTypeName(typeName),
                    String.Format("Type name '{0}' is invalid", typeName),
                    SystemConfig.CallerInfo);

      return GetInterfaceNamespace(typeName, false) + "." + GetInterfaceName(typeName, false);
    }

    public static string GetInterfaceAssemblyName(string typeName)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(IsValidEntityTypeName(typeName),
                    String.Format("Type name '{0}' is invalid", typeName),
                    SystemConfig.CallerInfo);

      return GetExtensionName(typeName, false) + ".Interface";
    }

    /// <summary>
    ///    If extensionName = "Core" and the entityGroupName = "Common", 
    ///    then the interface dir is
    ///    RMP\Extensions\Core\BusinessEntity\Common\Interface
    /// </summary>
    /// <param name="extensionName"></param>
    /// <returns></returns>
    public static string GetInterfaceDir(string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty");

      string tempExtensionName = extensionName.IndexOf('.') > 0
                                   ? extensionName.Substring(extensionName.LastIndexOf('.') + 1)
                                   : extensionName;

      var extensionDir = Path.Combine(SystemConfig.GetExtensionsDir(), tempExtensionName);
      string businessEntityDir = Path.Combine(extensionDir, "BusinessEntity");
      return Path.Combine(businessEntityDir, "Interface");
    }

    public static string GetBusinessEntityDir(string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty");
      string extensionDir = Path.Combine(SystemConfig.GetExtensionsDir(), extensionName);
      return Path.Combine(extensionDir, "BusinessEntity");
    }

    /// <summary>
    ///   Given the Core extension
    ///   The interface temp dir will be:
    ///   R:\extensions\core\businessentity\interface\temp
    /// </summary>
    /// <param name="extensionName"></param>
    /// <returns></returns>
    public static string GetInterfaceTempDir(string extensionName)
    {
      return Path.Combine(GetInterfaceDir(extensionName), "Temp");
    }

    public static string GetInterfaceCsProjFile(string extensionName, bool throwIfNotExists)
    {
      string interfaceDir = GetInterfaceDir(extensionName);

      // Check that directory exists
      Check.Require(Directory.Exists(interfaceDir), String.Format("Cannot find directory '{0}'", interfaceDir));

      string[] csprojFiles = Directory.GetFiles(interfaceDir, "*.csproj", SearchOption.TopDirectoryOnly);

      if (throwIfNotExists)
      {
        if (csprojFiles == null || csprojFiles.Length == 0)
        {
          string message = String.Format("No .csproj file found in directory '{0}'", interfaceDir);
          throw new BasicException(message);
        }
      }

      string csprojFile = String.Empty;
      if (csprojFiles != null && csprojFiles.Length == 1)
      {
        csprojFile = csprojFiles[0];
      }
      else if (csprojFiles != null && csprojFiles.Length > 1)
      {
        string message = String.Format("Found more than one .csproj file in directory '{0}'", interfaceDir);
        throw new BasicException(message);
      }

      return csprojFile;
    }

    /// <summary>
    ///   This will clean the entity dir for the given extension and entityGroup.
    /// </summary>
    public static void CleanEntityDir(string extensionName, string entityGroupName)
    {
      string dir = GetEntityDir(extensionName, entityGroupName);
      if (!Directory.Exists(dir))
      {
        return;
      }

      // Delete all the files in the directory
      Array.ForEach(Directory.GetFiles(dir), path => File.Delete(path));

    }

    public static string GetGeneratedDropSchemaFile(string extensionName, string entityGroupName, bool isOracle)
    {
      string fileName = "drop_schema.SqlServer.sql";
      if (isOracle)
      {
        fileName = "drop_schema.Oracle.sql";
      }
      return Path.Combine(GetEntityDir(extensionName, entityGroupName), fileName);
    }

    public static string GetGeneratedCreateSchemaFile(string extensionName, string entityGroupName, bool isOracle)
    {
      string fileName = "create_schema.SqlServer.sql";
      if (isOracle)
      {
        fileName = "create_schema.Oracle.sql";
      }
      return Path.Combine(GetEntityDir(extensionName, entityGroupName), fileName);
    }

    public static string GetEntityCsProjFileName(string extensionName, string entityGroupName)
    {
      return extensionName + "." + entityGroupName + ".Entity.csproj";
    }

    public static string GetEntityCsProjFile(string extensionName, string entityGroupName)
    {
      return GetEntityCsProjFile(extensionName, entityGroupName, false);
    }

    public static List<string> GetEntityCsProjFiles()
    {
      var csProjFiles = new List<string>();
      Dictionary<string, List<string>> entityGroupsByExtension = SystemConfig.GetEntityGroupsByExtension();

      foreach (string extensionName in entityGroupsByExtension.Keys)
      {
        List<string> entityGroupNames = entityGroupsByExtension[extensionName];
        foreach (string entityGroupName in entityGroupNames)
        {
          csProjFiles.Add(GetEntityCsProjFile(extensionName, entityGroupName, false));
        }
      }

      return csProjFiles;
    }

    public static string GetEntityCsProjFile(string extensionName, string entityGroupName, bool throwIfNotExists)
    {
      string entityDir = GetEntityDir(extensionName, entityGroupName);

      if (!Directory.Exists(entityDir))
      {
        if (throwIfNotExists)
        {
          throw new PreconditionException(String.Format("Cannot find directory '{0}'", entityDir));
        }

        return null;
      }

      string[] csprojFiles = Directory.GetFiles(entityDir, "*.csproj", SearchOption.TopDirectoryOnly);

      if (throwIfNotExists)
      {
        if (csprojFiles == null || csprojFiles.Length == 0)
        {
          string message = String.Format("No .csproj file found in directory '{0}'", entityDir);
          throw new BasicException(message);
        }
      }

      string csprojFile = String.Empty;
      if (csprojFiles != null && csprojFiles.Length > 0 && csprojFiles.Length <= 2)
      {
        if (extensionName.Contains(BMEConstants.BMERootNameSpace) && csprojFiles.Length == 1)
        {
          csprojFile = csprojFiles[0];
        }
        else if (extensionName.Contains(BMEConstants.BMERootNameSpace) && csprojFiles.Length == 2)
        {
          csprojFile = csprojFiles[1];
        }
        else
        {
          csprojFile = csprojFiles[0];
        }
      }
      else if (csprojFiles != null && csprojFiles.Length > 2)
      {
        string message = String.Format("Found more than two .csproj file in directory '{0}'", entityDir);
        throw new BasicException(message);
      }

      return csprojFile;
    }

    /// <summary>
    ///   E.g. For the following entity: Core.UI.Site
    ///   The entity temp directory will be:
    ///   R:\extensions\core\businessentity\ui\entity\temp
    /// </summary>
    /// <param name="typeName"></param>
    /// <returns></returns>
    public static string GetEntityTempDir(string typeName)
    {
      string extensionName, entityGroupName;
      GetExtensionAndEntityGroup(typeName, out extensionName, out entityGroupName);
      return Path.Combine(GetEntityDir(typeName), "Temp");
    }

    public static string GetEntityTempDir(string extensionName, string entityGroupName)
    {
      return Path.Combine(GetEntityDir(extensionName, entityGroupName), "Temp");
    }

    public static string GetInterfaceAssemblyNameFromExtension(string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      return extensionName + ".Interface.dll";
    }

    public static string GetInterfaceAssemblyFileNameWithPath(string extensionName)
    {
      string name = GetInterfaceAssemblyNameFromExtension(extensionName);
      return Path.Combine(SystemConfig.GetBinDir(), name);
    }

    public static string GetInterfaceAssemblyQualifiedName(string typeName)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(IsValidEntityTypeName(typeName),
                    String.Format("Type name '{0}' is invalid", typeName),
                    SystemConfig.CallerInfo);

      return GetInterfaceFullName(typeName) + ", " + GetInterfaceAssemblyName(typeName);
    }

    public static string GetInterfaceCodeFileName(string typeName)
    {
      return GetInterfaceCodeFileName(typeName, true);
    }

    public static string GetInterfaceCodeFileWithPath(string typeName)
    {
      string extensionName = GetExtensionName(typeName, true);
      return Path.Combine(GetInterfaceDir(extensionName), 
                          GetInterfaceCodeFileName(typeName, false));
    }
    /// <summary>
    ///    Create a new csproj in the RMP\extensions\extensionName\BusinessEntity\Interface
    ///    using the starter csproj StarterInterface.csproj in RMP\Config\BusinessEntity.
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    public static string CreateInterfaceCsProj(string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);

      string csProj = SystemConfig.GetStarterEntityInterfaceCsProjFile();

      // update the csproj
      XDocument xmldoc = XDocument.Load(csProj);

      XmlNamespaceManager namespaceManager = new XmlNamespaceManager(new NameTable());
      namespaceManager.AddNamespace("n", "http://schemas.microsoft.com/developer/msbuild/2003");

      #region ProjectGuid
      XElement xElement = xmldoc.XPathSelectElement("n:Project/n:PropertyGroup/n:ProjectGuid", namespaceManager);
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <Project><PropertyGroup><ProjectGuid> in file '{0}'", csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }
      xElement.SetValue(Guid.NewGuid());
      #endregion

      #region RootNamespace
      xElement = xmldoc.XPathSelectElement("n:Project/n:PropertyGroup/n:RootNamespace", namespaceManager);
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <Project><PropertyGroup><RootNamespace> in file '{0}'", csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      if (String.IsNullOrEmpty(xElement.Value) || !xElement.Value.Equals("BusinessEntity"))
      {
        string message = String.Format("The value '{0}' for <Project><PropertyGroup><RootNamespace> in file '{1}' is incorrect. Expected to find 'TemplateBusinessEntity'.", xElement.Value, csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      xElement.SetValue(extensionName + ".Interface");
      #endregion

      #region AssemblyName
      xElement = xmldoc.XPathSelectElement("n:Project/n:PropertyGroup/n:AssemblyName", namespaceManager);
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <Project><PropertyGroup><AssemblyName> in file '{0}'", csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      if (String.IsNullOrEmpty(xElement.Value) || !xElement.Value.Equals("BusinessEntity"))
      {
        string message = String.Format("The value '{0}' for <Project><PropertyGroup><AssemblyName> in file '{1}' is incorrect. Expected to find 'TemplateBusinessEntity'.", xElement.Value, csProj);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      xElement.SetValue(extensionName + ".Interface");
      #endregion

      string csProjFile = Path.Combine(GetInterfaceDir(extensionName),
                                       extensionName + ".Interface.csproj");
      xmldoc.Save(csProjFile);

      return csProjFile;
    }
    
    public static void ParseAssemblyQualifiedTypeName(string assemblyQualifiedName, 
                                                      out string typeName, 
                                                      out string assemblyName)
    {
      AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(assemblyQualifiedName);
      typeName = assemblyQualifiedTypeName.Type;
      assemblyName = assemblyQualifiedTypeName.Assembly;
    }

    public static string CreateEntityFullName(string extensionName, string entityGroupName, string className)
    {
      return extensionName + "." + entityGroupName + "." + className;
    }

    public static string GetEntityLocalizationFilePrefix(string entityName)
    {
      return "BusinessEntity_" + entityName + "_";
    }

    public static string GetEntityLocalizedLabelKey(string entityName)
    {
      return "BusinessEntity/" + entityName + "/Label";
    }

    public static string GetPropertyLocalizedLabelKey(string entityName, string propertyName)
    {
      return "BusinessEntity/" + entityName + "/" + propertyName + "/Label";
    }

    #endregion

    #region Public Properties
    public static XNamespace NHibernateNamespace
    {
      get
      {
        XNamespace xnamespace = "urn:nhibernate-mapping-2.2";
        return xnamespace;
      }
    }
    #endregion

    #region Public Methods
    /// <summary>
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    public static string GetIdentifier(string name)
    { //Compliant with item 2.4.2 of the C# specification
      Regex regex = new Regex(@"[^\p{Ll}\p{Lu}\p{Lt}\p{Lo}\p{Nd}\p{Nl}\p{Mn}\p{Mc}\p{Cf}\p{Pc}\p{Lm}]");
      string ret = regex.Replace(name, "_"); 
      //The identifier must start with a character or _
      if (!char.IsLetter(ret, 0))
      {
        ret = string.Concat("_", ret);
      }

      if (!IsValidIdentifier(ret))
      {
        ret = string.Concat("@", ret);
      }

      return ret; 
    }

    /// <summary>
    ///    Valid identifiers in C# are defined in the C# Language Specification, item 2.4.2. The rules are:
    ///     - An identifier must start with a letter or an underscore
    ///     - After the first character, it may contain numbers, letters, connectors, etc
    ///     - If the identifier is a keyword, it must be prepended with “@” 
    /// </summary>
    /// <param name="identifier"></param>
    /// <returns></returns>
    public static bool IsValidIdentifier(string identifier)
    {
      return Microsoft.CSharp.CSharpCodeProvider.CreateProvider("C#").IsValidIdentifier(identifier);
    }

    public static string GetEntityFullName(string extensionName, string entityGroupName, string name)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(name), "name cannot be null or empty", SystemConfig.CallerInfo);

      return extensionName + "." + entityGroupName + "." + name;
    }

    public static string GetEntityFullNameFromHistory(string historyFullName)
    {
      string name = historyFullName;
      int index = historyFullName.LastIndexOf("History");
      if (index != -1)
      {
        name = historyFullName.Substring(0, index);
      }

      return name;
    }

    public static string GetHbmFileName(string entityFullName)
    {
      return GetEntityClassName(entityFullName) + ".Generated.hbm.xml";
    }

    public static string GetHistoryHbmFileName(string entityFullName)
    {
      return GetEntityHistoryClassName(entityFullName) + ".Generated.hbm.xml";
    }

    public static string GetHbmFileNameWithPath(string entityFullName)
    {
      string mappingFile = GetHbmFileName(entityFullName);
      return Path.Combine(GetEntityDir(entityFullName), mappingFile);
    }

    public static string GetTempHbmFileNameWithPath(string entityFullName)
    {
      string mappingFile = GetHbmFileName(entityFullName);
      return Path.Combine(GetEntityTempDir(entityFullName), mappingFile);
    }

    public static string GetCodeFileName(string entityFullName)
    {
      return GetEntityClassName(entityFullName) + ".Generated.cs";
    }

    public static string GetHistoryCodeFileName(string entityFullName)
    {
      return GetEntityHistoryClassName(entityFullName) + ".Generated.cs";
    }

    public static string GetCodeFileNameWithPath(string entityFullName)
    {
      string mappingFile = GetCodeFileName(entityFullName);
      return Path.Combine(GetEntityDir(entityFullName), mappingFile);
    }

    /// <summary>
    ///    If extensionName = "Core" and entityGroupName = "Common", then the entity dir is
    ///    RMP\Extensions\Core\BusinessEntity\Common\Entity
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    public static string GetEntityDir(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty");

      string tempExtensionName = extensionName.IndexOf('.') > 0
                                   ? extensionName.Substring(extensionName.LastIndexOf('.') + 1)
                                   : extensionName;

      string extensionDir = Path.Combine(SystemConfig.GetExtensionsDir(), tempExtensionName);
      string businessEntityDir = Path.Combine(extensionDir, "BusinessEntity");
      return Path.Combine(Path.Combine(businessEntityDir, entityGroupName), "Entity");
    }

    public static string GetEntityDir(string entityFullName)
    {
      string extensionName, entityGroupName;
      GetExtensionAndEntityGroup(entityFullName, out extensionName, out entityGroupName);
      return GetEntityDir(extensionName, entityGroupName);
    }

    public static string GetInheritanceGraphDotFileName(bool hasCycle)
    {
      string fileName = "inheritance-graph";
      if (hasCycle)
      {
        fileName = "inheritance-graph-with-cycle";
      }
      return Path.Combine(SystemConfig.GetBusinessEntityConfigDir(), fileName);
    }

    public static string GetBuildGraphDotFileName(bool hasCycle)
    {
      string fileName = "build-graph";
      if (hasCycle)
      {
        fileName = "build-graph-with-cycle";
      }
      return Path.Combine(SystemConfig.GetBusinessEntityConfigDir(), fileName);
    }

    public static string GetEntityGraphDotFileName(bool hasCycle)
    {
      string fileName = "entity-graph";
      if (hasCycle)
      {
        fileName = "entity-graph-with-cycle";
      }
      return Path.Combine(SystemConfig.GetBusinessEntityConfigDir(), fileName);
    }

    public static string GetEntityGraphCacheFileName()
    {
      string cacheDir = Path.Combine(SystemConfig.GetBusinessEntityConfigDir(), "ICE");
      if (!Directory.Exists(cacheDir))
      {
        Directory.CreateDirectory(cacheDir);
      }

      return Path.Combine(cacheDir, "entity-graph.dat");
    }

    public static string GetHistoryTriggerName(string historyEntityName)
    {
      Check.Require(!String.IsNullOrEmpty(historyEntityName), "historyEntityName cannot be null or empty");

      if (historyEntityName.Length > 25)
      {
        historyEntityName = historyEntityName.Substring(0, 25);
      }

      return "TRG_" + historyEntityName;
    }
    
    #endregion

    #region Private Methods


    private static string GetExtensionName(string typeName, bool validate)
    {
      if (validate)
      {
        Check.Require(IsValidEntityTypeName(typeName),
                      String.Format("Type name '{0}' is invalid", typeName),
                      SystemConfig.CallerInfo);
      }

      var tempName = typeName.Substring(0, typeName.LastIndexOf('.'));

      return tempName.Substring(0, tempName.LastIndexOf('.'));
    }

    private static string GetEntityGroupName(string typeName, bool validate)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      if (validate)
      {
        Check.Require(IsValidEntityTypeName(typeName),
                      String.Format("Type name '{0}' is invalid", typeName),
                      SystemConfig.CallerInfo);
      }

      var tempName = typeName.Substring(0, typeName.LastIndexOf('.'));

      return tempName.Substring(tempName.LastIndexOf('.') + 1);
    }

    private static string GetEntityClassName(string typeName, bool validate)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      if (validate)
      {
        Check.Require(IsValidEntityTypeName(typeName),
                      String.Format("Type name '{0}' is invalid", typeName),
                      SystemConfig.CallerInfo);
      }

      string[] sections = typeName.Split(new[] { '.' });

      return sections[sections.Length - 1];
    }

    private static string GetEntityNamespace(string typeName, bool validate)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      if (validate)
      {
        Check.Require(IsValidEntityTypeName(typeName),
                      String.Format("Type name '{0}' is invalid", typeName),
                      SystemConfig.CallerInfo);
      }

      int index = typeName.LastIndexOf('.');

      return typeName.Substring(0, index);
    }

    private static string GetInterfaceName(string typeName, bool validate)
    {
      return "I" + GetEntityClassName(typeName, validate);
    }

    private static string GetInterfaceNamespace(string typeName, bool validate)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      if (validate)
      {
        Check.Require(IsValidEntityTypeName(typeName),
                      String.Format("Type name '{0}' is invalid", typeName),
                      SystemConfig.CallerInfo);
      }

      return GetExtensionName(typeName, false) + "." + GetEntityGroupName(typeName, false) + ".Interface";
    }

    private static string GetInterfaceFullName(string typeName, bool validate)
    {
      return GetInterfaceNamespace(typeName, validate) + "." + GetInterfaceName(typeName, validate);
    }

    private static string GetInterfaceCodeFileName(string typeName, bool validate)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      if (validate)
      {
        Check.Require(IsValidEntityTypeName(typeName),
                      String.Format("Type name '{0}' is invalid", typeName),
                      SystemConfig.CallerInfo);
      }

      return GetExtensionName(typeName, false) + "." +
             GetEntityGroupName(typeName, false) + "." +
             GetInterfaceName(typeName, false) + ".Generated.cs";
    }

    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("Name");
    #endregion
  }
}
