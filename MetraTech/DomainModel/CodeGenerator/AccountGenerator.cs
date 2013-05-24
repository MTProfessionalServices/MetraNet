using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using System.CodeDom;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class AccountGenerator : BaseCodeGenerator
  {
    #region Public Methods
    /// <summary>
    ///   Returns the singleton AccountGenerator.
    /// </summary>
    /// <returns></returns>
    public static AccountGenerator GetInstance()
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

      Assembly assembly = GetAssembly(generatedAccountAssemblyName);
      if (assembly == null)
      {
        logger.LogDebug(String.Format("Unable to load assembly '{0}'", generatedAccountAssemblyName));
        return;
      }

      Dictionary<string, Dictionary<string, int>> extensionsWithLocaleSpace = new Dictionary<string, Dictionary<string, int>>();

      try
      {
        foreach (Type type in assembly.GetTypes())
        {
          foreach (PropertyInfo propertyInfo in type.GetProperties())
          {
            if (!propertyInfo.Name.EndsWith("DisplayName")) continue;

            object[] attributes = propertyInfo.GetCustomAttributes(typeof (MTPropertyLocalizationAttribute), false);

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
      catch (Exception e)
      {
        logger.LogException(String.Format("Error loading types from assembly '{0}'", generatedAccountAssemblyName), e);
      }
    }

    /// <summary>
    ///   (1) R:\...\AccountType contains all the account type definitions 
    ///   (2) The account type definitions refer to views that are at ..\AccountView
    ///   (3) Create a class for each account view referenced by each account type
    ///   (4) Generate a class for each account type (derived from MetraTech.DomainModel.BaseTypes.Account)
    ///   (5) Add properties representing each account view 
    ///   (6) Generate the assembly.
    /// </summary>
    public bool GenerateCode(bool debugMode)
    {
      try
      {
        // Get the view files
        ViewFileData[] viewFiles = ViewFileData.ViewFiles;

        // Get the account files
        List<AccountFileData> accountFiles = AccountFileData.GetAccountFileData();

        Dictionary<string, FileData> allFiles = new Dictionary<string, FileData>();

        foreach (ViewFileData fileData in viewFiles)
        {
          allFiles.Add(fileData.ChecksumKey, fileData);
        }

        foreach (AccountFileData fileData in accountFiles)
        {
          allFiles.Add(fileData.ChecksumKey, fileData);
        }

        // No need to generate assembly if input files (including resources) haven't changed
        if (ChecksumsMatch(Checksums, allFiles))
        {
          assemblyGenerated = false;
          logger.LogDebug(String.Format("Assembly '{0}' was not generated because its input files haven't changed", generatedAccountAssemblyName));
          return true;
        }

        // Initialize resourceData
        resourceData = new ResourceData();

        CodeCompileUnit codeCompileUnit = new CodeCompileUnit();

        // Initialize the codeCompileUnit with assembly attributes as shown below
        // codeCompileUnit.AssemblyCustomAttributes.Add
        //  (new CodeAttributeDeclaration("AssemblyVersion", 
        //                                new CodeAttributeArgument(new CodePrimitiveExpression("5.1.0.0"))));

        CodeNamespace codeNamespace = new CodeNamespace(accountNamespace);
        codeCompileUnit.Namespaces.Add(codeNamespace);
        codeNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
       
        // Create Views
        foreach (ViewFileData viewFileData in viewFiles)
        {
          codeNamespace.Types.Add(CreateView(viewFileData));
        }

        // Create Accounts
       
        // This dictionary will be used to create the GetDescendentTypes method
        Dictionary<AccountFileData, CodeTypeDeclaration> accountDataColl = new Dictionary<AccountFileData, CodeTypeDeclaration>();

        foreach (AccountFileData accountFileData in accountFiles)
        {
          CodeTypeDeclaration accountType = CreateAccount(accountFileData);
          codeNamespace.Types.Add(accountType);
          accountDataColl.Add(accountFileData, accountType);
        }

        InitResourcesForBaseProperties();
        CreateGetDescendentTypesMethod(accountDataColl);

        // TODO Remove after testing
        // WriteFile(codeCompileUnit, @"S:\MetraTech\DomainModel\test.cs");

        string checksumResourceFile = FileData.CreateChecksumResource(allFiles, checksumResourceFileName);
        List<string> resourceFiles = new List<string>();
        resourceFiles.Add(checksumResourceFile);

        Dictionary<string, CodeCompileUnit> codeUnits = new Dictionary<string, CodeCompileUnit>();
        codeUnits.Add("Accounts.cs", codeCompileUnit);

        List<string> referencedSystemAssemblies = new List<string>();
        referencedSystemAssemblies.Add("System.dll");
		  referencedSystemAssemblies.Add(typeof(ScriptIgnoreAttribute).Assembly.Location);
        referencedSystemAssemblies.Add(typeof(DataContractAttribute).Assembly.Location);
      
        List<string> referencedLocalAssemblies = new List<string>();
        referencedLocalAssemblies.Add("MetraTech.DomainModel.Common.dll");
        //referencedLocalAssemblies.Add("MetraTech.DomainModel.Enums.dll");
        referencedLocalAssemblies.Add("MetraTech.DomainModel.Enums.Generated.dll");
        referencedLocalAssemblies.Add("MetraTech.DomainModel.BaseTypes.dll");

        if (!BuildAssembly(generatedAccountAssemblyName,
                           codeUnits,
                           referencedSystemAssemblies,
                           referencedLocalAssemblies,
                           resourceFiles,
                           debugMode,
                           @"Accounts"))
        {
          return false;
        }
      }
      catch (Exception e)
      {
        logger.LogException(String.Format("Code generation for account types failed."), e);
        throw;
      }

      return true;
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
      set
      {
        resourceData = value;
      }
    }
    #endregion

    // Private constructor
    #region Private Methods

    /// <summary>
    ///   Initializes resourceData for the base account properties
    /// </summary>
    private static void InitResourcesForBaseProperties()
    {
      Assembly assembly = GetAssembly(baseAccountAssemblyName);
      if (assembly == null)
      {
        logger.LogError(String.Format("Unable to load assembly '{0}'", baseAccountAssemblyName));
        return;
      }

      try
      {
        foreach (Type type in assembly.GetTypes())
        {
          foreach (PropertyInfo propertyInfo in type.GetProperties())
          {
            if (!propertyInfo.Name.EndsWith("DisplayName")) continue;

            object[] attributes = propertyInfo.GetCustomAttributes(typeof (MTPropertyLocalizationAttribute), false);

            if (attributes == null || attributes.Length <= 0) continue;

            MTPropertyLocalizationAttribute attribute = attributes[0] as MTPropertyLocalizationAttribute;
            Debug.Assert(attribute != null);

            ResourceData.AddResource(attribute.MTLocalizationId,
                                     attribute.ResourceId,
                                     attribute.DefaultValue,
                                     attribute.Extension,
                                     attribute.LocaleSpace);

          }
        }
      }
      catch (Exception e)
      {
        logger.LogException(String.Format("Error loading types from assembly '{0}'", baseAccountAssemblyName), e);
      }
    }

    private void CreateGetDescendentTypesMethod(Dictionary<AccountFileData, CodeTypeDeclaration> dictionary)
    {
      // Collect the keys
      List<AccountFileData> accountDataList = new List<AccountFileData>();
      foreach (AccountFileData accountData in dictionary.Keys)
      {
        accountDataList.Add(accountData);
      }

      // Create the method
      CodeTypeDeclaration codeType;
      foreach (AccountFileData accountData in dictionary.Keys)
      {
        List<string> descendantTypes = GetDescendantTypes(accountData, accountDataList);
        codeType = dictionary[accountData];

        CodeMemberMethod method = new CodeMemberMethod();
        method.Name = "GetDescendantTypes";
        method.Attributes = MemberAttributes.Public | MemberAttributes.Override;
        method.ReturnType = new CodeTypeReference("List<string>");

        codeType.Members.Add(method);
        string variableName = "accountTypes";
        CodeVariableDeclarationStatement stringList =
          new CodeVariableDeclarationStatement(new CodeTypeReference("List<string>"), variableName);

        stringList.InitExpression = new CodeObjectCreateExpression(new CodeTypeReference("List<string>"), new CodePrimitiveExpression[] { });
        method.Statements.Add(stringList);
        foreach(string descendantType in descendantTypes)
        {
          method.Statements.Add
            (new CodeMethodInvokeExpression
              (new CodeMethodReferenceExpression
                (new CodeVariableReferenceExpression(variableName), "Add"),
                 new CodePrimitiveExpression(descendantType)));

        }
        method.Statements.Add(new CodeMethodReturnStatement(new CodeVariableReferenceExpression(variableName)));
      }
    }

    private List<string> GetDescendantTypes(AccountFileData accountData, List<AccountFileData> accountDataList)
    {
      List<string> descendants = accountData.Descendants;

      foreach (AccountFileData accountDataItem in accountDataList)
      {
        if (accountDataItem.Name == accountData.Name)
        {
          continue;
        }

        if (!accountDataItem.Ancestors.Contains(accountData.Name)) continue;

        if (!descendants.Contains(accountDataItem.Name))
        {
          descendants.Add(accountDataItem.Name);
        }

        foreach (string descendant in accountDataItem.Descendants)
        {
          if (!descendants.Contains(descendant))
          {
            descendants.Add(descendant);
          }
        }
      }

      return descendants;
    }

    private AccountGenerator()
    {
    }

    private CodeTypeDeclaration CreateAccount(AccountFileData accountFileData)
    {
      logger.LogDebug(String.Format("Creating account type from '{0}'.", accountFileData.FullPath));

      CodeTypeDeclaration accountType = new CodeTypeDeclaration();
      accountType.Name = accountFileData.ClassName;

      // Add the base class
      accountType.BaseTypes.Add(new CodeTypeReference("MetraTech.DomainModel.BaseTypes.Account"));

      // Create constructor 
      CodeConstructor constructor = new CodeConstructor();
      constructor.Attributes = MemberAttributes.Public;
      accountType.Members.Add(constructor);

      // Set 'AccountType' property
      CodeAssignStatement codeAssignStatement =
        new CodeAssignStatement(new CodeVariableReferenceExpression("AccountType"),
                                new CodePrimitiveExpression(accountType.Name));
      constructor.Statements.Add(codeAssignStatement);

      // Add the [MTAccount] attribute
      CodeAttributeArgument[] attributeItems = new CodeAttributeArgument[1];
      attributeItems[0] =
        (new CodeAttributeArgument("Extension", new CodePrimitiveExpression(accountFileData.ExtensionName)));
      CodeAttributeDeclaration attribute =
        new CodeAttributeDeclaration(MTAccountAttribute.QualifiedName, attributeItems);
      accountType.CustomAttributes.Add(attribute);

      // Add the [DataContract] attribute
      attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
      accountType.CustomAttributes.Add(attribute);

      // Add the [Serializable] attribute
      attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
      accountType.CustomAttributes.Add(attribute);

      // Create the view properties for the account
      CreateAccountProperties(ref accountType, ref constructor, accountFileData.ViewProperties);

      // Create the LoginApplication property for System accounts. 
      // There's no entry for this in the system account type file.
      if (accountType.Name.ToLower() == "systemaccount")
      {
        CreatePropertyData("LoginApplication", 
                           accountNamespace + "." + accountType.Name + "." + "LoginApplication",
                           String.Empty,
                           "MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.LoginApplication", 
                           null, 
                           true, 
                           false, 
                           ref accountType,
                           resourceData,
                           accountFileData);
      }

      logger.LogDebug(String.Format("Successfully created account type '{0}' from '{1}'.", accountType.Name, accountFileData.FullPath));

      return accountType;
    }

    private void CreateAccountProperties(ref CodeTypeDeclaration codeType, 
                                         ref CodeConstructor constructor,
                                         Dictionary<string, ViewFileData> viewProperties)
    {
      foreach (string propertyName in viewProperties.Keys)
      {
        string typeName;
        string tmpPropertyName = propertyName;
        ViewFileData viewFileData = viewProperties[propertyName];

        if (viewFileData.MakeList)
        {
          typeName = "List<MetraTech.DomainModel.AccountTypes." + viewFileData.ClassName + ">";
          // Initialize empty list
          if (constructor != null)
          {
            // Set 'AccountType' property
            CodeAssignStatement codeAssignStatement =
              new CodeAssignStatement(new CodeVariableReferenceExpression(LowerCaseFirst(propertyName)),
                                      new CodeObjectCreateExpression(new CodeTypeReference(typeName), new CodeExpression[] { }));
            constructor.Statements.Add(codeAssignStatement);
          }
        }
        else
        {
          typeName = "MetraTech.DomainModel.AccountTypes." + viewFileData.ClassName;
        }

        // Create the fields and properties
        if (tmpPropertyName == codeType.Name)
        {
          tmpPropertyName = tmpPropertyName + "_";
        }

        CodeMemberProperty property = 
          CreatePropertyData(tmpPropertyName,
                             accountNamespace + "." + viewFileData.ClassName + "." + tmpPropertyName, 
                             String.Empty,
                             typeName, 
                             null, 
                             false, 
                             false, 
                             ref codeType,
                             resourceData,
                             viewFileData);

        CreateMTDataMemberAttribute(ref property, viewFileData);
      }
    }


    private CodeTypeDeclaration CreateView(ViewFileData viewFileData)
    {
      logger.LogDebug(String.Format("Creating view type from '{0}'.", viewFileData.FullPath));

      CodeTypeDeclaration viewType = new CodeTypeDeclaration();
      // Add the base class
      viewType.BaseTypes.Add(new CodeTypeReference("MetraTech.DomainModel.BaseTypes.View"));
      viewType.Name = viewFileData.ClassName;

      // Add the [DataContract] attribute
      CodeAttributeDeclaration dataContractAttribute =
        new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
      viewType.CustomAttributes.Add(dataContractAttribute);

      // Add the [Serializable] attribute
      CodeAttributeDeclaration serializableAttribute =
        new CodeAttributeDeclaration("System.SerializableAttribute");
      viewType.CustomAttributes.Add(serializableAttribute);

      // Add the [MTView] attribute
      // The viewType is something like "metratech.com/Contact"
      CodeAttributeArgument[] attributeItems = new CodeAttributeArgument[2];
      attributeItems[0] =
        (new CodeAttributeArgument("ViewType", new CodePrimitiveExpression(viewFileData.ViewType)));
      attributeItems[1] =
        (new CodeAttributeArgument("Extension", new CodePrimitiveExpression(viewFileData.ExtensionName)));
      CodeAttributeDeclaration mtViewAttribute =
        new CodeAttributeDeclaration(MTViewAttribute.QualifiedName, attributeItems);
      viewType.CustomAttributes.Add(mtViewAttribute);

      if (viewFileData.Properties.Count == 0)
      {
        logger.LogWarning(String.Format("View found in '{0}' does not have any properties.", viewFileData.FullPath));
      }
      else
      {
        logger.LogDebug(String.Format("Creating view properties from '{0}'.", viewFileData.FullPath)); 
      }

      // Create the view properties
      foreach (ConfigPropertyData configPropertyData in viewFileData.Properties)
      {
        CodeMemberProperty property = 
          CreatePropertyData(configPropertyData.Name, 
                             accountNamespace + "." + viewType.Name + "." + configPropertyData.Name,
                             viewFileData.ViewType + "/" + configPropertyData.Name,
                             configPropertyData.PropertyType.ToString(), 
                             configPropertyData.DefaultValue,
                             configPropertyData.IsEnum,
                             configPropertyData.IsRequired,
                             ref viewType,
                             resourceData,
                             viewFileData);

        CreateMTDataMemberAttribute(ref property, configPropertyData);
      }

      logger.LogDebug(String.Format("Successfully created view type '{0}' from '{1}'.", viewFileData.ClassName, viewFileData.FullPath));

      return viewType;
    }

    private void CreateMTDataMemberAttribute(ref CodeMemberProperty property, ViewFileData viewData)
    {
      List<CodeAttributeArgument> attributeItems = new List<CodeAttributeArgument>();

      // ViewType = "metratech.com/internal", ClassName = "InternalView", ViewName = "Internal"
      if (viewData.MakeList)
      {
        attributeItems.Add(new CodeAttributeArgument("IsListView",
                                                      new CodePrimitiveExpression(true)));
      }
      attributeItems.Add(new CodeAttributeArgument("ViewType",
                                                   new CodePrimitiveExpression(viewData.ViewType)));
      attributeItems.Add(new CodeAttributeArgument("ClassName",
                                                   new CodePrimitiveExpression(viewData.ClassName)));
      attributeItems.Add(new CodeAttributeArgument("ViewName",
                                                   new CodePrimitiveExpression(property.Name)));

      CodeAttributeDeclaration mtDataMemberAttribute =
        new CodeAttributeDeclaration(MTDataMemberAttribute.QualifiedName, attributeItems.ToArray());

      property.CustomAttributes.Add(mtDataMemberAttribute);
    }

    #endregion

    #region Data
    // Static members are lazily initialized. 
    // .NET guarantees thread safety for static initialization 
    private static readonly AccountGenerator instance = new AccountGenerator();

    public const string accountNamespace = "MetraTech.DomainModel.AccountTypes";
    public const string baseAccountAssemblyName = "MetraTech.DomainModel.BaseTypes.dll";
    public const string generatedAccountAssemblyName = "MetraTech.DomainModel.AccountTypes.Generated.dll";
    public const string checksumResourceFileName = "checksum.resources";

    // initialized in the constructor
    private static readonly Dictionary<string, string> checksums = GetChecksums(generatedAccountAssemblyName, checksumResourceFileName);
    private static bool assemblyGenerated = true;
    private static ResourceData resourceData = null;

    #endregion
  }
}
