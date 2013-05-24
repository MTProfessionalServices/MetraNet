using System;
using System.Collections.Generic;
using System.IO;
using System.CodeDom;
using System.Web.Script.Serialization;
using System.Xml;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class ProductOfferingGenerator : BaseCodeGenerator
  {
    #region Public Methods
    /// <summary>
    ///   Returns the singleton ProductOfferingGenerator.
    /// </summary>
    /// <returns></returns>
    public static ProductOfferingGenerator GetInstance()
    {
      return instance;
    }

    public static void InitResourceData()
    {
        if (resourceData == null)
        {
            resourceData = CreateResourceData(productOfferingAssemblyName);
        }
    }

    /// <summary>
    ///   (1) R:\...\AccountType contains all the account type definitions 
    ///   (2) The account type definitions refer to views that are at ..\AccountView
    ///   (3) Create a class for each account view referenced by each account type
    ///   (4) Generate a class for each account type (derived from MetraTech.DomainModel.Account)
    ///   (5) Add properties representing each account view 
    ///   (6) Generate the assembly.
    /// </summary>
    public bool GenerateCode(bool debugMode)
    {
      try
      {
        List<FileData> allFiles = new List<FileData>();

          /* 
           * The ProductOffering 'file' is actually an extended property file which is included in the
           * PriceableItemData.GetFiles() result set below
           */
       
        FileData counterConfigFile = CounterGenerator.GetCounterConfigFilename();
        if (counterConfigFile != null)
        {
            allFiles.Add(counterConfigFile);
        }

        List<FileData> paramTableFiles = ParamTableFileData.GetList();
        if (paramTableFiles.Count != 0)
        {
            allFiles.AddRange(paramTableFiles);
        }

        List<FileData> priceableItemFiles = PriceableItemData.GetFiles();
        if (priceableItemFiles.Count != 0)
        {
            allFiles.AddRange(priceableItemFiles);
        }

        FileData productOfferingConfigFile = ProductOfferingGenerator.GetProductOfferingConfigFilename();
        if (productOfferingConfigFile != null)
        {
          allFiles.Add(productOfferingConfigFile);
        }

        // No need to generate the dll if the input files haven't changed
        if (!MustGenerateCode(checksums, allFiles))
        {
          logger.LogDebug(String.Format("Assembly '{0}' was not generated because its input files haven't changed", productOfferingAssemblyName));
          return true;
        }

        Dictionary<string, CodeCompileUnit> codeUnits = new Dictionary<string, CodeCompileUnit>();
        ResourceData = new ResourceData();

        // Generate Counters
        if (!CounterGenerator.GetInstance().GenerateCode(productOfferingNamespace, codeUnits))
        {
            logger.LogError(String.Format("Assembly '{0}' was not generated.  Counter generation failed.", productOfferingAssemblyName));
            return false;
        }

        // Generate Rate Entries
        if (!RateEntryGenerator.GetInstance().GenerateCode(productOfferingNamespace, paramTableFiles, codeUnits))
        {
            logger.LogError(String.Format("Assembly '{0}' was not generated.  Rate Entry generation failed.", productOfferingAssemblyName));
            return false;
        }

        // Generate Priceable Item Templates and Instances
        if (!PriceableItemGenerator.GetInstance().GenerateCode(productOfferingNamespace, codeUnits))
        {
            logger.LogError(String.Format("Assembly '{0}' was not generated.  Priceable Item Template / Instance generation failed.", productOfferingAssemblyName));
            return false;
        }

        // Generate Product Offering
        if (!GenerateCode(productOfferingNamespace, codeUnits))
        {
            logger.LogError(String.Format("Assembly '{0}' was not generated.  Product Offering generation failed.", productOfferingAssemblyName));
            return false;
        }

        //////////////////////////////////////////
        //////////////////////////////////////
        // Generate the checksum.resources files
        string checksumResourceFile;
        BuildChecksumResource(allFiles, out checksumResourceFile);
        List<string> resourceFiles = new List<string>();
        resourceFiles.Add(checksumResourceFile);

        List<string> referencedSystemAssemblies = new List<string>();
        referencedSystemAssemblies.Add("System.dll");
		  referencedSystemAssemblies.Add(typeof(ScriptIgnoreAttribute).Assembly.Location);
        referencedSystemAssemblies.Add(typeof(DataContractAttribute).Assembly.Location);
      
        List<string> referencedLocalAssemblies = new List<string>();
        referencedLocalAssemblies.Add("MetraTech.DomainModel.Common.dll");
        //referencedLocalAssemblies.Add("MetraTech.DomainModel.Enums.dll");
        referencedLocalAssemblies.Add("MetraTech.DomainModel.Enums.Generated.dll");
        referencedLocalAssemblies.Add("MetraTech.DomainModel.BaseTypes.dll");
        referencedLocalAssemblies.Add("MetraTech.ActivityServices.Common.dll");

        if (!BuildAssembly(productOfferingAssemblyName,
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
        logger.LogException(String.Format("Code generation for product offerings failed."), e);
        throw e;
      }

      return true;
    }
    #endregion

    // Private constructor
    #region Private Methods

    
    private ProductOfferingGenerator()
    {
    }

    private bool GenerateCode(string nameSpace, Dictionary<string, CodeCompileUnit> codeUnits)
    {
        CodeCompileUnit codeCompileUnit = new CodeCompileUnit();

        // Initialize the codeCompileUnit with assembly attributes as shown below
        // codeCompileUnit.AssemblyCustomAttributes.Add
        //  (new CodeAttributeDeclaration("AssemblyVersion", 
        //                                new CodeAttributeArgument(new CodePrimitiveExpression("5.1.0.0"))));

        CodeNamespace codeNamespace = new CodeNamespace(nameSpace);
        codeCompileUnit.Namespaces.Add(codeNamespace);
        codeNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));

        // Create ProductOffering
        CodeTypeDeclaration codeType = null;
        if (!CreateProductOffering(out codeType))
        {
            return false;
        }

        codeNamespace.Types.Add(codeType);

        // TODO Remove after testing
        // WriteFile(codeCompileUnit, @"S:\MetraTech\code.cs");

        //Dictionary<string, CodeCompileUnit> codeUnits = new Dictionary<string, CodeCompileUnit>();
        codeUnits.Add("ProductOffering.cs", codeCompileUnit);

        return true;
    }

    private bool CreateProductOffering(out CodeTypeDeclaration productOfferingType)
    {
      logger.LogDebug("Creating product offering");

      productOfferingType = new CodeTypeDeclaration();
      productOfferingType.Name = "ProductOffering";

      // Add the base class
      productOfferingType.BaseTypes.Add(new CodeTypeReference("MetraTech.DomainModel.BaseTypes.BaseProductOffering"));

      // Add the [DataContract] attribute
      CodeAttributeDeclaration attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
      productOfferingType.CustomAttributes.Add(attribute);

      // Add the [Serializable] attribute
      attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
      productOfferingType.CustomAttributes.Add(attribute);

      CodeMemberProperty property = null;
        List<ExtendedPropertyData> extendedProperties = null;
        if (ExtendedPropertyProvider.ExtendedProperties.TryGetValue("100", out extendedProperties))
      {
            foreach (ExtendedPropertyData epd in extendedProperties)
        {
                foreach (ConfigPropertyData configPropertyData in epd.Properties)
          {
          property = CreatePropertyData(configPropertyData.Name,
                                        productOfferingNamespace + "." + productOfferingType.Name + configPropertyData.Name,
                                        String.Empty,
                                        configPropertyData.PropertyType.ToString(),
                                        configPropertyData.DefaultValue,
                                        configPropertyData.IsEnum,
                                        configPropertyData.IsRequired,
                                        ref productOfferingType,
                                              null, //resourceData,
                                        null);

          CreateMTDataMemberAttribute(ref property, configPropertyData);

                    // add extended property attribute
                    IAttributeDeclaration epAttribute = AttributeDeclarationFactory.Get<MTExtendedPropertyAttribute>();
                    epAttribute.AddArgument("TableName", epd.TableName);
                    epAttribute.AddArgument("ColumnName", string.Format("c_{0}", configPropertyData.Name));
                    property.CustomAttributes.Add(epAttribute.Attribute);
        }
      }
        }

      return true;
    }

    /// <summary>
    ///   Return the list of view configuration files found at:
    ///    R:\extensions\[extension name]\config\AccountView\[namespace]\*.msixdef
    /// </summary>
    /// <returns></returns>
    public static FileData GetProductOfferingConfigFilename()
    {
      FileData fileData = null;

      if (File.Exists(Path.Combine(RCD.ExtensionDir, @"SystemConfig\config\ExtendedProp\po.msixdef")))
      {
        fileData = new FileData();
        fileData.ExtensionName = "SystemConfig";
        fileData.FileName = Path.Combine(RCD.ExtensionDir, @"SystemConfig\config\ExtendedProp\po.msixdef");
      }

      return fileData;
    }

    public new static ResourceData ResourceData
    {
        get
        {
            if (resourceData == null)
            {
                InitResourceData();
            }

            return resourceData;
        }
        set
        {
            resourceData = value;
        }
    }

    #endregion

    #region Data
    // .NET guarantees thread safety for static initialization 
    private static readonly ProductOfferingGenerator instance = new ProductOfferingGenerator();

    public const string productOfferingNamespace = "MetraTech.DomainModel.ProductCatalog";
    public const string productOfferingAssemblyName = "MetraTech.DomainModel.ProductCatalog.Generated.dll";
    public const string checksumResourceFileName = "checksum.resources";

    // initialized in the constructor
    private static readonly Dictionary<string, string> checksums = GetChecksums(productOfferingAssemblyName, checksumResourceFileName);
    //private static bool assemblyGenerated = true;
    private static ResourceData resourceData = null;

    #endregion
  }

  

  
}
