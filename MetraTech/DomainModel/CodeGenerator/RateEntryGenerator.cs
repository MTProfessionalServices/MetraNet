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
    public class ParamTableFileData : FileData
    {
        #region Public Methods

        public ParamTableFileData()
        {
        }

        /// <summary>
        ///    Return ParamTableFileData for each paramete table file in RMP\Extensions. 
        /// </summary>
        /// <returns></returns>
        public static List<FileData> GetList()
        {
            List<FileData> paramTableFiles = new List<FileData>();

            foreach (string extension in BaseCodeGenerator.RCD.ExtensionList)
            {
                List<string> files = BaseCodeGenerator.GetFiles(extension, "ParamTable", "msixdef");

                foreach (string file in files)
                {
                    ParamTableFileData paramTableFileData = new ParamTableFileData();
                    paramTableFileData.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath(file);
                    paramTableFileData.FileName = Path.GetFileName(file);
                    paramTableFileData.FullPath = file;

                    paramTableFiles.Add(paramTableFileData);
                }

            }

            return paramTableFiles;
        }

        #endregion
    }

    public class RateEntryGenerator : BaseCodeGenerator
    {
        #region Public Methods

        /// <summary>
        ///   Returns the singleton RateEntryGenerator.
        /// </summary>
        /// <returns></returns>
        public static RateEntryGenerator GetInstance()
        {
            return instance;
        }

        public bool GenerateCode(string nameSpace, List<FileData> fileDataList, Dictionary<string, CodeCompileUnit> codeUnits)
        {
            if (fileDataList.Count == 0)
            {
                logger.LogDebug("No parameter table definition files found");
                return true;
            }

            CodeNamespace codeNamespace = new CodeNamespace(nameSpace);

            foreach (FileData fileData in fileDataList)
            {
                logger.LogDebug(String.Format("Creating rate entries from '{0}'.", fileData.FullPath));

                CodeTypeDeclaration rateEntryType = null;
                CodeTypeDeclaration defaultRateEntryType = null;

                if (!CreateRateEntry(fileData, nameSpace, out rateEntryType, out defaultRateEntryType))
                {
                    logger.LogDebug(String.Format("Unable to create rate entry from '{0}'.", fileData.FullPath));

                    return false;
                }

                // Add the [DataContract] attribute
                CodeAttributeDeclaration attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
                rateEntryType.CustomAttributes.Add(attribute);

                attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
                defaultRateEntryType.CustomAttributes.Add(attribute);

                // Add the [Serializable] attribute
                attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
                rateEntryType.CustomAttributes.Add(attribute);

                attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
                defaultRateEntryType.CustomAttributes.Add(attribute);


                codeNamespace.Types.Add(rateEntryType);
                codeNamespace.Types.Add(defaultRateEntryType);
            }

            CodeCompileUnit codeUnit = new CodeCompileUnit();
            codeUnit.Namespaces.Add(codeNamespace);
            codeUnits.Add("RateEntries.cs", codeUnit);

            return true;
        }

        #endregion
        
        #region Private Methods

        private RateEntryGenerator()
        {
        }

        private bool CreateRateEntry(FileData fileData, string nameSpace, out CodeTypeDeclaration rateEntryType, out CodeTypeDeclaration defaultRateEntryType)
        {
            rateEntryType = null;

            XmlDocument doc = new XmlDocument();
            doc.Load(fileData.FullPath);

            XmlNode nameNode = doc.SelectSingleNode("//name");
            if (nameNode == null)
            {
                rateEntryType = null;
                defaultRateEntryType = null;

                logger.LogError("Rate entry generator failed - bad xml: <name/> element is missing");
                return false;
            }

            string paramTableName = nameNode.InnerText.Trim();

            if (String.IsNullOrEmpty(paramTableName))
            {
                rateEntryType = null;
                defaultRateEntryType = null;

                logger.LogError("Rate entry generator failed - bad xml: <name/> element has no value");
                return false;
            }

            string rateEntryPrefix = MakeAlphaNumeric(paramTableName);
            rateEntryPrefixes[paramTableName] = rateEntryPrefix;

            // Create the RateEntry type
            rateEntryType = new CodeTypeDeclaration();
            rateEntryType.Name = rateEntryPrefix + "RateEntry";

            rateEntryType.BaseTypes.Add("MetraTech.DomainModel.BaseTypes.RateEntry");

            rateEntryType.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(MTRateEntryAttribute))));

            // Create the DefaultRateEntry type
            defaultRateEntryType = new CodeTypeDeclaration();
            defaultRateEntryType.Name = rateEntryPrefix + "DefaultRateEntry";

            defaultRateEntryType.BaseTypes.Add("MetraTech.DomainModel.BaseTypes.RateEntry");

            defaultRateEntryType.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(MTDefaultRateEntryAttribute))));

            // Add conditions
            XmlNodeList ptypeNodes = doc.SelectNodes("//ptype[@condition=\"Y\"]");

            bool bDefaultRateEntryHasActions = true;
            if (!CreateRateEntryProperties(fileData, nameSpace, ptypeNodes, ref rateEntryType, out bDefaultRateEntryHasActions))
            {
                return false;
            }

            // Add operators
            ptypeNodes = doc.SelectNodes("//ptype[@operator=\"Y\"]");

            if (!CreateRateEntryProperties(fileData, nameSpace, ptypeNodes, ref rateEntryType))
            {
                return false;
            }

            // Add actions
            ptypeNodes = doc.SelectNodes("//ptype[@action=\"Y\"]");

            if (!CreateRateEntryProperties(fileData, nameSpace, ptypeNodes, ref rateEntryType))
            {
                return false;
            }

            // Add actions to default rate entry if necessary
            if (bDefaultRateEntryHasActions)
            {
                return CreateRateEntryProperties(fileData, nameSpace, ptypeNodes, ref defaultRateEntryType);
            }

            return true;
        }

        private bool CreateRateEntryProperties(FileData fileData, string nameSpace, XmlNodeList ptypeNodes, ref CodeTypeDeclaration rateEntryType)
        {
            bool bDummy = false;

            return CreateRateEntryProperties(fileData, nameSpace, ptypeNodes, ref rateEntryType, out bDummy);
        }

        private bool CreateRateEntryProperties(FileData fileData, string nameSpace, XmlNodeList ptypeNodes, ref CodeTypeDeclaration rateEntryType, out bool bAllConditionsNullable)
        {
            bAllConditionsNullable = true;

            foreach (XmlNode ptypeNode in ptypeNodes)
            {
                ConfigPropertyData configPropertyData = null;

                if (!GetPropertyData(ptypeNode, true, out configPropertyData))
                {
                    logger.LogError(String.Format("Failed to get config property data for {0} ", rateEntryType.Name));
                    return false;
                }

                bAllConditionsNullable &= !configPropertyData.IsRequired;

                CodeMemberProperty property =
                  CreatePropertyData(configPropertyData.Name,
                                     (configPropertyData.Operator ? 
                                            "MetraTech.DomainModel.BaseTypes.RateEntryOperators" : 
                                            configPropertyData.PropertyType.ToString()),
                                     false,
                                     0,
                                     configPropertyData.DefaultValue,
                                     configPropertyData.IsEnum,
                                     (configPropertyData.Operator ? true : configPropertyData.IsRequired),
                                     ref rateEntryType);

                CreateMTDataMemberAttribute(ref property, configPropertyData);

                IAttributeDeclaration rateEntryMetadata = AttributeDeclarationFactory.Get<MTRateEntryMetadataAttribute>();
                rateEntryMetadata.AddArgument("ColumnName", configPropertyData.Name);
                rateEntryMetadata.AddArgument("DataType", configPropertyData.MsixType);
                rateEntryMetadata.AddArgument("Length", configPropertyData.Length);
                rateEntryMetadata.AddArgument("IsAction", configPropertyData.Action);
                rateEntryMetadata.AddArgument("IsCondition", configPropertyData.Condition);
                rateEntryMetadata.AddArgument("IsOperator", configPropertyData.Operator);
                rateEntryMetadata.AddArgument("OperatorPerRule", configPropertyData.OperatorPerRule);
                rateEntryMetadata.AddArgument("Filterable", configPropertyData.Filterable);
                property.CustomAttributes.Add(rateEntryMetadata.Attribute);

                //string displayName = configPropertyData.Name + "DisplayName";
                //property = CreatePropertyData(displayName,
                //                              configPropertyData.PropertyType.ToString(),
                //                              false,
                //                              0,
                //                              configPropertyData.DefaultValue,
                //                              configPropertyData.IsEnum,
                //                              configPropertyData.IsRequired,
                //                              ref rateEntryType);

                //CreateMTDataMemberAttribute(ref property, configPropertyData);

            }

            return true;
        }


        #endregion

        #region Properties

        static public string GetRatePrefix(string paramTable)
        {
            if (rateEntryPrefixes.ContainsKey(paramTable))
            {
                return rateEntryPrefixes[paramTable];
            }
            else
            {
                return "";
            }
        }

        #endregion

        #region Data

        // .NET guarantees thread safety for static initialization 
        private static readonly RateEntryGenerator instance = new RateEntryGenerator();

        private static Dictionary<string, string> rateEntryPrefixes = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);

        #endregion
   }
}