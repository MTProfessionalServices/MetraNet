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
    public class ProductViewFileData : ViewFileData
    {
        #region Public Methods

        public ProductViewFileData(string viewType)
            : base(viewType)
        {
        }

         /// <summary>
        ///    Return ProductViewFileData and LocalizationFileData for each paramete table file in RMP\Extensions. 
        /// </summary>
        /// <returns></returns>
        public static void GetList(ref List<FileData> productViewFiles, ref List<LocalizationFileData> localizationFiles)
        {
            foreach (string extension in BaseCodeGenerator.RCD.ExtensionList)
            {
                List<string> files = BaseCodeGenerator.GetFiles(extension, "productview", "msixdef");

                ProductViewFileData productViewFileData = null;

                foreach (string file in files)
                {
                    XmlDocument xmlDocument = new XmlDocument();
                    xmlDocument.Load(file);
                    XmlNode name = xmlDocument.SelectSingleNode(@"//name");

                    if (name == null)
                    {
                        logger.LogError(String.Format("ProductViewGenerator : Extension file {0} is missing a <name> node", file));
                        continue;
                    }

                    string localeSpace = name.InnerText.Trim().ToLower();

                    if (String.IsNullOrEmpty(localeSpace))
                    {
                        logger.LogError(String.Format("ProductViewGenerator : Extension file {0} : <name> node is empty", file));
                        continue;
                    }

                    productViewFileData = new ProductViewFileData(localeSpace);

                    productViewFileData.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath(file);
                    productViewFileData.FileName = Path.GetFileName(file);
                    productViewFileData.FullPath = file;

                    productViewFiles.Add(productViewFileData);

                    List<LocalizationFileData> locFileData = LocalizationFileData.GetLocalizationFileData(extension, localeSpace);

                    if (locFileData != null && locFileData.Count > 0)
                    {
                        localizationFiles.AddRange(locFileData);
                    }
                    
                }
            }

            // Add ancillary ProductView locales 
            localizationFiles.AddRange(LocalizationFileData.GetLocalizationFileData("Core", "metratech.com/defaultadjustmentdetail"));
        }

        #endregion
    }

    public class ProductViewGenerator : BaseCodeGenerator
    {
        #region Public Methods
        /// <summary>
        ///   Returns the singleton ProductViewGenerator.
        /// </summary>
        /// <returns></returns>
        public static ProductViewGenerator GetInstance()
        {
            return instance;
        }

        public static void InitResourceData()
        {
            if (resourceData == null)
            {
                resourceData = CreateResourceData(billingAssemblyName);
            }
        }

        public bool GenerateCode(bool debugMode)
        {
            try
            {
                List<FileData> allFiles = new List<FileData>();

                List<FileData> productViewFiles = new List<FileData>();
                List<LocalizationFileData> localizationFiles = new List<LocalizationFileData>();
                ProductViewFileData.GetList(ref productViewFiles, ref localizationFiles);

                if (productViewFiles.Count != 0)
                {
                    allFiles.AddRange(productViewFiles);
                }

                foreach (FileData file in localizationFiles)
                {
                    allFiles.Add(file);
                }

                // No need to generate the dll if the input files haven't changed
                if (!MustGenerateCode(checksums, allFiles))
                {
                    logger.LogDebug(String.Format("Assembly '{0}' was not generated because its input files haven't changed", billingAssemblyName));
                    return true;
                }

                Dictionary<string, CodeCompileUnit> codeUnits = new Dictionary<string, CodeCompileUnit>();

                // Generate Product View
                if (!ProductViewGenerator.GetInstance().GenerateCode(productViewNamespace, productViewFiles, codeUnits))
                {
                    logger.LogError(String.Format("Assembly '{0}' was not generated.  Rate Entry generation failed.", billingAssemblyName));
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
                referencedLocalAssemblies.Add("MetraTech.DomainModel.Enums.Generated.dll");
                referencedLocalAssemblies.Add("MetraTech.DomainModel.BaseTypes.dll");
                referencedLocalAssemblies.Add("MetraTech.ActivityServices.Common.dll");

                if (!BuildAssembly(billingAssemblyName,
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
                logger.LogException(String.Format("Code generation for Product Views failed."), e);
                throw;
            }

            return true;
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

        #region Private Methods
        private bool GenerateCode(string nameSpace, List<FileData> fileDataList, Dictionary<string, CodeCompileUnit> codeUnits)
        {
            if (fileDataList.Count == 0)
            {
                logger.LogDebug("No product view definition files found");
                return true;
            }

            CodeNamespace codeNamespace = new CodeNamespace(nameSpace);

            foreach (FileData fileData in fileDataList)
            {
                logger.LogDebug(String.Format("Creating product views from '{0}'.", fileData.FullPath));

                CodeTypeDeclaration productViewType = null;

                if (!CreateProductView(fileData, nameSpace, out productViewType))
                {
                    logger.LogDebug(String.Format("Unable to create product view from '{0}'.", fileData.FullPath));

                    return false;
                }

                // Add the [DataContract] attribute
                CodeAttributeDeclaration attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
                productViewType.CustomAttributes.Add(attribute);

                // Add the [Serializable] attribute
                attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
                productViewType.CustomAttributes.Add(attribute);

                codeNamespace.Types.Add(productViewType);
            }

            CodeCompileUnit codeUnit = new CodeCompileUnit();
            codeUnit.Namespaces.Add(codeNamespace);
            codeUnits.Add("ProductView.cs", codeUnit);

            return true;
        }

        private bool CreateProductView(FileData fileData, string nameSpace, out CodeTypeDeclaration productViewType)
        {
            productViewType = null;

            XmlDocument doc = new XmlDocument();
            doc.Load(fileData.FullPath);

            XmlNode nameNode = doc.SelectSingleNode("//name");
            if (nameNode == null)
            {
                productViewType = null;

                logger.LogError("Product view generator failed - bad xml: <name/> element is missing");
                return false;
            }

            string productViewName = nameNode.InnerText.Trim();

            if (String.IsNullOrEmpty(productViewName))
            {
                productViewType = null;

                logger.LogError("Product view generator failed - bad xml: <name/> element has no value");
                return false;
            }

            string productViewPrefix = MakeAlphaNumeric(productViewName);

            // Create the ProductView type
            productViewType = new CodeTypeDeclaration();
            productViewType.Name = productViewPrefix + "ProductView";

            productViewType.BaseTypes.Add("MetraTech.DomainModel.BaseTypes.BaseProductView");

            IAttributeDeclaration productViewMetadata = AttributeDeclarationFactory.Get<MTProductViewAttribute>();
            productViewMetadata.AddArgument("ViewName", productViewName);
            productViewType.CustomAttributes.Add(productViewMetadata.Attribute);

            // Add properties
            XmlNodeList ptypeNodes = doc.SelectNodes("//ptype");

            if (!CreateProductViewProperties(fileData, nameSpace, productViewName, ptypeNodes, ref productViewType))
            {
                return false;
            }

            return true;
        }

        private bool CreateProductViewProperties(FileData fileData, string nameSpace, string productViewName, XmlNodeList ptypeNodes, ref CodeTypeDeclaration productViewType)
        {
            foreach (XmlNode ptypeNode in ptypeNodes)
            {
                ConfigPropertyData configPropertyData = null;

                if (!GetPropertyData(ptypeNode, true, out configPropertyData))
                {
                    logger.LogError(String.Format("Failed to get config property data for {0} ", productViewType.Name));
                    return false;
                }

                CodeMemberProperty property =
                  CreatePropertyData(configPropertyData.Name,
                                     productViewNamespace + "." + productViewType.Name + "." + configPropertyData.Name,
                                     productViewName + "/" + configPropertyData.Name,
                                     configPropertyData.PropertyType.ToString(),
                                     configPropertyData.DefaultValue,
                                     configPropertyData.IsEnum,
                                     configPropertyData.IsRequired,
                                     ref productViewType,
                                     resourceData,
                                     fileData);

                CreateMTDataMemberAttribute(ref property, configPropertyData);

                IAttributeDeclaration rateEntryMetadata = AttributeDeclarationFactory.Get<MTProductViewMetadataAttribute>();
                rateEntryMetadata.AddArgument("ColumnName", configPropertyData.Name);
                rateEntryMetadata.AddArgument("DataType", configPropertyData.MsixType);
                rateEntryMetadata.AddArgument("Length", configPropertyData.Length);
                rateEntryMetadata.AddArgument("Filterable", configPropertyData.Filterable);
                rateEntryMetadata.AddArgument("Exportable", configPropertyData.Exportable);
                rateEntryMetadata.AddArgument("UserVisible", configPropertyData.UserVisible);
                property.CustomAttributes.Add(rateEntryMetadata.Attribute);
            }

            return true;
        }
        #endregion

        #region Data
        // .NET guarantees thread safety for static initialization 
        private static readonly ProductViewGenerator instance = new ProductViewGenerator();

        public const string productViewNamespace = "MetraTech.DomainModel.ProductView";
        public const string billingAssemblyName = "MetraTech.DomainModel.Billing.Generated.dll";
        public const string checksumResourceFileName = "checksum.resources";

        // initialized in the constructor
        private static readonly Dictionary<string, string> checksums = GetChecksums(billingAssemblyName, checksumResourceFileName);
        private static ResourceData resourceData = null;

        #endregion
    }
}