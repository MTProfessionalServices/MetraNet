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
    public class CounterGenerator : BaseCodeGenerator
    {
        #region Public Methods

        /// <summary>
        ///   Returns the singleton CounterGenerator.
        /// </summary>
        /// <returns></returns>
        public static CounterGenerator GetInstance()
        {
            return instance;
        }

        #endregion

         
        #region Private Methods

        private CounterGenerator()
        {
        }

        public bool GenerateCode(string nameSpace, Dictionary<string, CodeCompileUnit> codeUnits)
        {
            bool bResult = false;

            FileData counterConfigFile = GetCounterConfigFilename();

            logger.LogDebug(String.Format("Creating counters from '{0}'.", counterConfigFile.FileName));

            CodeNamespace codeNamespace = new CodeNamespace(nameSpace);

            XmlDocument doc = new XmlDocument();
            doc.Load(counterConfigFile.FileName);

            XmlNodeList counterTypes = doc.SelectNodes("//CounterType");

            foreach (XmlNode counterTypeNode in counterTypes)
            {
                CodeTypeDeclaration counterType = null;
                bResult = CreateCounter(counterTypeNode, out counterType);
                if (bResult)
                {
                    codeNamespace.Types.Add(counterType);
                }
            }

            if (bResult)
            {
                CodeCompileUnit codeUnit = new CodeCompileUnit();
                codeUnit.Namespaces.Add(codeNamespace);
                codeUnits.Add("Counters.cs", codeUnit);
            }

            return bResult;
        }

        private bool CreateCounter(XmlNode counterTypeNode,
                                   out CodeTypeDeclaration counterType)
        {
            // Create the Counter type
            counterType = new CodeTypeDeclaration();
            XmlNode nameNode = counterTypeNode.SelectSingleNode("Name");
            if (nameNode == null)
            {
                logger.LogError("Counter generator failed - bad xml: <Name/> element is missing");
                return false;
            }

            counterType.Name = MakeAlphaNumeric(nameNode.FirstChild.Value + "Counter");

            // Add the base class
            counterType.BaseTypes.Add("MetraTech.DomainModel.BaseTypes.Counter");

            #region Add attributes

            // Add the [DataContract] attribute
            CodeAttributeDeclaration attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
            counterType.CustomAttributes.Add(attribute);

            // Add the [Serializable] attribute
            attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
            counterType.CustomAttributes.Add(attribute);

            // Add [CounterTypeMetadata] attribute
            IAttributeDeclaration counterTypeMetadata = AttributeDeclarationFactory.Get<CounterTypeMetadataAttribute>();

            if (!counterTypeMetadata.AddArgument(nameNode))
            {
                return false;
            }

            if (!counterTypeMetadata.AddArgument(counterTypeNode, "Description"))
            {
                return false;
            }

            if (!counterTypeMetadata.AddArgument<bool>(counterTypeNode, "ValidForDistribution", ConfigValueHelper.ConvertToBool))
            {
                return false;
            }

            counterType.CustomAttributes.Add(counterTypeMetadata.Attribute);

            #endregion Add attributes

            #region Add counter parameters

            // Gather all counter parameters
            XmlNodeList counterParameters = counterTypeNode.SelectNodes("FormulaDef/Params/Param");
            foreach (XmlNode counterParameter in counterParameters)
            {
                // Create parameter field (e.g. "string m_A")
                CodeMemberField field = new CodeMemberField();
                CodeTypeReference fieldDataType = new CodeTypeReference(typeof(string));
                field.Type = fieldDataType;
                string parameterName = counterParameter.SelectSingleNode("Name").FirstChild.Value;
                field.Name = "m_" + parameterName;
                counterType.Members.Add(field);
                
                // Create the "dirty" field
                CodeMemberField dirtyField = null;
                string dirtyFieldName = CreateDirtyField(ref counterType, parameterName, out dirtyField);

                IAttributeDeclaration dataMemberAttribute = AttributeDeclarationFactory.Get<DataMemberAttribute>();
                dataMemberAttribute.AddArgument("IsRequired", false);
                dataMemberAttribute.AddArgument("EmitDefaultValue", false);

                dirtyField.CustomAttributes.Add(dataMemberAttribute.Attribute);

                // Create parameter property (e.g. "string A")
                CodeMemberProperty property = null;
                property = new CodeMemberProperty();
                property.Name = parameterName;
                property.Type = fieldDataType;
                property.Attributes = MemberAttributes.Public | MemberAttributes.Final;
                property.HasGet = true;
                property.HasSet = true;

                // Create the getter
                CodeFieldReferenceExpression fieldRef =
                  new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name);

                CodeMethodReturnStatement returnStatement1 = new CodeMethodReturnStatement(fieldRef);
                property.GetStatements.Add(returnStatement1);

                // Create the setter
                property.SetStatements.Add
                  (new CodeAssignStatement(fieldRef, new CodeArgumentReferenceExpression("value")));
                property.SetStatements.Add
                  (new CodeAssignStatement
                    (new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), dirtyFieldName),
                     new CodePrimitiveExpression(true)));

                // Add [DataMember] attribute to property
                property.CustomAttributes.Add(dataMemberAttribute.Attribute);

                // Add [CounterParamMetadata] attribute to property
                IAttributeDeclaration counterParamMetadata = AttributeDeclarationFactory.Get<CounterParamMetadataAttribute>();

                if (!counterParamMetadata.AddArgument(counterParameter, "Kind"))
                {
                    return false;
                }

                if (!counterParamMetadata.AddArgument(counterParameter, "DBType"))
                {
                    return false;
                }

                property.CustomAttributes.Add(counterParamMetadata.Attribute);

                // Add [MTDataMember] attribute to property
                IAttributeDeclaration mtDataMemberAttribute = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
                mtDataMemberAttribute.AddArgument("Description", "Counter parameter");
                mtDataMemberAttribute.AddArgument("Length", 40);

                property.CustomAttributes.Add(mtDataMemberAttribute.Attribute);

                counterType.Members.Add(property);
            }

            #endregion Add counter parameters

            return true;
        }

       /// <summary>
        ///    R:\extensions\Core\config\CounterType\CounterType.xml
        /// </summary>
        /// <returns></returns>
        public static FileData GetCounterConfigFilename()
        {
            FileData fileData = null;

            if (File.Exists(Path.Combine(RCD.ExtensionDir, @"Core\config\CounterType\CounterType.xml")))
            {
                fileData = new FileData();
                fileData.ExtensionName = "Core";
                fileData.FileName = Path.Combine(RCD.ExtensionDir, @"Core\config\CounterType\CounterType.xml");
            }

            return fileData;
        }

        #endregion

        #region Data

        // .NET guarantees thread safety for static initialization 
        private static readonly CounterGenerator instance = new CounterGenerator();

        #endregion

    }
}