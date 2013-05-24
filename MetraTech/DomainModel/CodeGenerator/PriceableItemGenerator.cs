using System;
using System.Collections.Generic;
using System.IO;
using System.CodeDom;
using System.Web.Script.Serialization;
using System.Xml;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.Interop.RCD;
using System.Configuration;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class PriceableItemData
  {
    public static List<FileData> GetFiles()
    {

      List<FileData> fileData = new List<FileData>();
      fileData.AddRange(ExtensionFiles);
      fileData.AddRange(ExtendedPropertyFiles);

      return fileData;
    }

    public static List<FileData> ExtensionFiles
    {
      get
      {
        if (extensionFiles == null)
        {
          extensionFiles = new List<FileData>();

          foreach (string extension in BaseCodeGenerator.RCD.ExtensionList)
          {
            List<string> files = BaseCodeGenerator.GetFiles(extension, "PriceableItems", "xml");

            foreach (string file in files)
            {
              FileData fileDataPITEmplate = new FileData();
              fileDataPITEmplate.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath(file);
              fileDataPITEmplate.FileName = Path.GetFileName(file);
              fileDataPITEmplate.FullPath = file;

              extensionFiles.Add(fileDataPITEmplate);
            }

          }
        }

        return extensionFiles;
      }
    }

    public static List<FileData> ExtendedPropertyFiles
    {
      get
      {
        return ExtendedPropertyProvider.ExtendedPropertyFiles;
      }
    }

    public static Dictionary<string, List<ExtendedPropertyData>> ExtendedProperties
    {
      get
      {
        return ExtendedPropertyProvider.ExtendedProperties;
      }
    }

    #region Members
    private static List<FileData> extensionFiles = null;
    #endregion
  }

  class PriceableItemGenerator : BaseCodeGenerator
  {
    #region Public Methods

    /// <summary>
    ///   Returns the singleton PITemplateGenerator.
    /// </summary>
    /// <returns></returns>
    public static PriceableItemGenerator GetInstance()
    {
      return instance;
    }

    static PriceableItemGenerator()
    {
      instance = new PriceableItemGenerator();
    }

    public bool GenerateCode(string nameSpace, Dictionary<string, CodeCompileUnit> codeUnits)
    {
      if (PriceableItemData.ExtensionFiles.Count == 0)
      {
        logger.LogDebug("No Priecable Item extension files found");
        return true;
      }


      CodeNamespace codeNamespaceForTemplate = new CodeNamespace(nameSpace);
      CodeNamespace codeNamespaceForInstance = new CodeNamespace(nameSpace);
      CodeNamespace codeNamespaceForAdjustments = new CodeNamespace(nameSpace);

      codeNamespaceForTemplate.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
      codeNamespaceForTemplate.Imports.Add(new CodeNamespaceImport("MetraTech.DomainModel.BaseTypes"));
      codeNamespaceForTemplate.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));

      codeNamespaceForInstance.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
      codeNamespaceForInstance.Imports.Add(new CodeNamespaceImport("MetraTech.DomainModel.BaseTypes"));
      codeNamespaceForInstance.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));

      codeNamespaceForAdjustments.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
      codeNamespaceForAdjustments.Imports.Add(new CodeNamespaceImport("MetraTech.DomainModel.BaseTypes"));
      codeNamespaceForAdjustments.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));

      foreach (FileData fileData in PriceableItemData.ExtensionFiles)
      {
          logger.LogDebug(String.Format("Creating priceable item from '{0}'.", fileData.FullPath));

          CodeTypeDeclaration piTemplateType = null;
          CodeTypeDeclaration piInstanceType = null;

          if (!CreatePriceableItem(fileData, nameSpace, out piTemplateType, out piInstanceType))
          {
              logger.LogDebug(String.Format("Unable to create priceable item from '{0}'.", fileData.FullPath));

              return false;
          }

          codeNamespaceForTemplate.Types.Add(piTemplateType);
          codeNamespaceForInstance.Types.Add(piInstanceType);

          if (!CreateAdjustments(fileData, nameSpace, ref codeNamespaceForAdjustments))
          {
              logger.LogDebug("Unable to create adjustments from '{0}'.", fileData.FullPath);

              return false;
          }
      }

      CodeTypeDeclarationCollection templateTypes = codeNamespaceForTemplate.Types;
      CodeTypeDeclarationCollection instanceTypes = codeNamespaceForInstance.Types;

      for (int count = 0; count < templateTypes.Count; count++)
      {
        CodeTypeDeclaration t = templateTypes[count];
        string typeName = t.Name;
        foreach (KeyValuePair<string, string> kvp in mParentChild)
        {
          if (kvp.Value.Equals(typeName))
          {
            bool childMemberSet = false;
            logger.LogDebug("The type is {0}", typeName);
            CodeTypeMemberCollection members = t.Members;

            foreach (CodeTypeMember d in members)
            {
              if (d.Name.Equals(kvp.Key))
              {
                logger.LogDebug("Child Value is set {0}", d.Name);
                childMemberSet = true;
                break;
              }
            }
            if (!childMemberSet)
            {
              string childName = MakeAlphaNumeric(kvp.Key);
              logger.LogDebug("We need to set the child member for {0}", typeName);
              CodeMemberProperty property =
              CreatePropertyData(childName,
                                childName + "PITemplate",
                                false,
                                0,
                                null,
                                false,
                                true,
                                ref t);

              IAttributeDeclaration mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
              mtDataMember.AddArgument("Description", "Child Priceable Item Template");
              property.CustomAttributes.Add(mtDataMember.Attribute);

              logger.LogDebug("Setting Child Instance");
              PopulateChildInstance(kvp.Value.Replace("PITemplate", ""), childName, instanceTypes, mtDataMember, property);
              logger.LogDebug("Setted Child Instance");
            }
          }
        }
      }


      CodeCompileUnit codeUnitForTemplate = new CodeCompileUnit();
      codeUnitForTemplate.Namespaces.Add(codeNamespaceForTemplate);
      codeUnits.Add("PITemplates.cs", codeUnitForTemplate);

      CodeCompileUnit codeUnitForInstance = new CodeCompileUnit();
      codeUnitForInstance.Namespaces.Add(codeNamespaceForInstance);
      codeUnits.Add("PIInstances.cs", codeUnitForInstance);

      CodeCompileUnit codeUnitForAdjustments = new CodeCompileUnit();
      codeUnitForAdjustments.Namespaces.Add(codeNamespaceForAdjustments);
      codeUnits.Add("Adjustments.cs", codeUnitForAdjustments);

      return true;
    }

    #endregion

    #region Private Methods

    private PriceableItemGenerator()
    {
      // The strings that specify the PI kind in xml config are not allways consistent.
      // Several aliases exist. (e.g. "nonrecurring", "non_recurring").
      // We need to build a mapping between the aliases and the PI base classes.  (The base
      // classes correspond to PI kinds.)

      PIKindMapData mapData;

      mapData = new PIKindMapData();
      mapData.BaseClassName = "RecurringCharge";
      mapData.PIKindID = "20";

      kindToBaseClassMap.Add("recurring", mapData);

      mapData = new PIKindMapData();
      mapData.BaseClassName = "NonRecurringCharge";
      mapData.PIKindID = "30";

      kindToBaseClassMap.Add("nonrecurring", mapData);
      kindToBaseClassMap.Add("non-recurring", mapData);
      kindToBaseClassMap.Add("non_recurring", mapData);

      mapData = new PIKindMapData();
      mapData.BaseClassName = "Usage";
      mapData.PIKindID = "10";

      kindToBaseClassMap.Add("usage", mapData);

      mapData = new PIKindMapData();
      mapData.BaseClassName = "AggregateCharge";
      mapData.PIKindID = "15";

      kindToBaseClassMap.Add("aggregate", mapData);


      mapData = new PIKindMapData();
      mapData.BaseClassName = "Discount";
      mapData.PIKindID = "40";

      kindToBaseClassMap.Add("discount", mapData);


      mapData = new PIKindMapData();
      mapData.BaseClassName = "UnitDependentRecurringCharge";
      mapData.PIKindID = "25";

      kindToBaseClassMap.Add("unitdependentrecurring", mapData);
      kindToBaseClassMap.Add("unit_dependent_recurring", mapData);
      kindToBaseClassMap.Add("unit-dependent-recurring", mapData);

    }

    private bool CreatePriceableItem(FileData fileData, string nameSpace, out CodeTypeDeclaration piTemplateType, out CodeTypeDeclaration piInstanceType)
    {
      bool bResult = true;
      piTemplateType = null;
      piInstanceType = null;

      XmlDocument doc = new XmlDocument();
      doc.Load(fileData.FullPath);

      XmlNode nameNode = doc.SelectSingleNode("//name");
      if (nameNode == null)
      {
        logger.LogError("Priceable Item generator failed - bad xml: <name/> element is missing in file " + fileData.FullPath);
        return false;
      }

      // Create the PITemplate type
      string piTypeName = nameNode.InnerText.Trim();

      piTemplateType = new CodeTypeDeclaration();
      piTemplateType.Name = MakeAlphaNumeric(piTypeName + "PITemplate");

      IAttributeDeclaration typeAttrib = AttributeDeclarationFactory.Get<MTPriceableItemTemplateAttribute>();
      typeAttrib.AddArgument("PIType", piTypeName);
      piTemplateType.CustomAttributes.Add(typeAttrib.Attribute);

      // Create the PIInstance type
      piInstanceType = new CodeTypeDeclaration();
      piInstanceType.Name = MakeAlphaNumeric(piTypeName + "PIInstance");

      typeAttrib = AttributeDeclarationFactory.Get<MTPriceableItemInstanceAttribute>();
      typeAttrib.AddArgument("PIType", piTypeName);
      piInstanceType.CustomAttributes.Add(typeAttrib.Attribute);

      //Get the 'Kind'
      XmlNode itemTypeNode = doc.SelectSingleNode("//item_type");
      if (itemTypeNode == null)
      {
        logger.LogError("Priceable Item generator failed - bad xml: <item_type/> element is missing in file " + fileData.FullPath);
        return false;
      }

      string kind = itemTypeNode.InnerText.Trim().ToLower();

      //Add the base classes
      string baseClassName = kindToBaseClassMap[kind].BaseClassName;
      if (String.IsNullOrEmpty(baseClassName))
      {
        logger.LogError("Priceable Item generator failed: Unknown item_type in file " + fileData.FullPath);
        return false;
      }

      piTemplateType.BaseTypes.Add(String.Format("MetraTech.DomainModel.BaseTypes.{0}PITemplate", baseClassName));
      piInstanceType.BaseTypes.Add(String.Format("MetraTech.DomainModel.BaseTypes.{0}PIInstance", baseClassName));

      // Add the [DataContract] attribute
      CodeAttributeDeclaration attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
      piTemplateType.CustomAttributes.Add(attribute);

      attribute = new CodeAttributeDeclaration("System.Runtime.Serialization.DataContractAttribute");
      piInstanceType.CustomAttributes.Add(attribute);

      // Add the [Serializable] attribute
      attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
      piTemplateType.CustomAttributes.Add(attribute);

      attribute = new CodeAttributeDeclaration("System.SerializableAttribute");
      piInstanceType.CustomAttributes.Add(attribute);

      //Add extended properties
      string kindID = kindToBaseClassMap[kind].PIKindID;
      if (PriceableItemData.ExtendedProperties.ContainsKey(kindID))
      {
        foreach (ExtendedPropertyData epd in PriceableItemData.ExtendedProperties[kindID])
        {
          foreach (ConfigPropertyData configPropertyData in epd.Properties)
          {
            CodeMemberProperty property =
              CreatePropertyData(configPropertyData.Name,
                                 configPropertyData.PropertyType.ToString(),
                                 false,
                                 0,
                                 configPropertyData.DefaultValue,
                                 configPropertyData.IsEnum,
                                 configPropertyData.IsRequired,
                                 ref piTemplateType);

            CreateMTDataMemberAttribute(ref property, configPropertyData);

            // add extended property attribute
            IAttributeDeclaration epAttribute = AttributeDeclarationFactory.Get<MTExtendedPropertyAttribute>();
            epAttribute.AddArgument("TableName", epd.TableName);
            epAttribute.AddArgument("ColumnName", string.Format("c_{0}", configPropertyData.Name));
            property.CustomAttributes.Add(epAttribute.Attribute);

            property = CreatePropertyData(configPropertyData.Name,
                                          configPropertyData.PropertyType.ToString(),
                                          false,
                                          0,
                                          configPropertyData.DefaultValue,
                                          configPropertyData.IsEnum,
                                          configPropertyData.IsRequired,
                                          ref piInstanceType);

            CreateMTDataMemberAttribute(ref property, configPropertyData);

            // add extended property attribute
            epAttribute = AttributeDeclarationFactory.Get<MTExtendedPropertyAttribute>();
            epAttribute.AddArgument("TableName", epd.TableName);
            epAttribute.AddArgument("ColumnName", string.Format("c_{0}", configPropertyData.Name));
            property.CustomAttributes.Add(epAttribute.Attribute);
          }
        }
      }

      //Add parents and children
      XmlNode nodeParent = doc.SelectSingleNode("//relationships/parent");
      if (!String.IsNullOrEmpty(nodeParent.InnerText.Trim()))
      {
        string pName = MakeAlphaNumeric(nodeParent.InnerText.Trim()) + "PITemplate";
        mParentChild.Add(piTypeName, pName);
        logger.LogDebug("Added to dictionary {0}", pName);
        CodeMemberProperty property =
            CreatePropertyData("ParentPITemplate",
                               "PCIdentifier",
                               false,
                               0,
                               null,
                               false,
                               true,
                               ref piTemplateType);

        IAttributeDeclaration mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
        mtDataMember.AddArgument("Description", "Identifier of Parent Priceable Item Template");
        property.CustomAttributes.Add(mtDataMember.Attribute);

        property =
            CreatePropertyData("ParentPIInstance",
                               "PCIdentifier",
                               false,
                               0,
                               null,
                               false,
                               true,
                               ref piInstanceType);

        mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
        mtDataMember.AddArgument("Description", "Identifier of Parent Priceable Item Instance");
        property.CustomAttributes.Add(mtDataMember.Attribute);
      }

      XmlNodeList children = doc.SelectNodes("//relationships/child");
      if (children.Count != 0)
      {
        foreach (XmlNode child in children)
        {
          string childName = child.InnerText.Trim();
          if (String.IsNullOrEmpty(childName))
          {
            logger.LogError("PriceableItemGenerator - bad xml: A name of a priceable item child is missing for " + piInstanceType.Name);
          }
          else
          {

            childName = MakeAlphaNumeric(childName);
            logger.LogDebug("Adding childName for " + childName);
            CodeMemberProperty property =
             CreatePropertyData(childName,
                                childName + "PITemplate",
                                false,
                                0,
                                null,
                                false,
                                true,
                                ref piTemplateType);

            IAttributeDeclaration mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
            mtDataMember.AddArgument("Description", "Collection of child Priceable Item Template identifiers");
            mtDataMember.AddArgument("Length", children.Count);
            property.CustomAttributes.Add(mtDataMember.Attribute);

            // PI Instances
            property =
             CreatePropertyData(childName,
                                childName + "PIInstance",
                                false,
                                0,
                                null,
                                false,
                                true,
                                ref piInstanceType);

            mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
            mtDataMember.AddArgument("Description", "Child Priceable Item Instance");
            property.CustomAttributes.Add(mtDataMember.Attribute);
          }
        }

      }

      // check to see if some parents did not have a reference to their children


      //Add Adjustments
      XmlNodeList adjustments = doc.SelectNodes("//adjustment_type");
      if (adjustments.Count > 0)
      {
        foreach (XmlNode adjustment in adjustments)
        {
          XmlNode adjustmentName = adjustment.SelectSingleNode("./name");
          if (adjustmentName == null)
          {
            logger.LogError("Priceable Item Template generator failed - bad xml: //adjustment_type/name element is missing in file " + fileData.FullPath);
            return false;
          }

          string name = MakeAlphaNumeric(adjustmentName.InnerText.Trim());

          CodeMemberProperty property
              = CreatePropertyData(name,
                                   "MetraTech.DomainModel.BaseTypes.AdjustmentTemplate",
                                   false,
                                   0,
                                   null,
                                   false,
                                   true,
                                   ref piTemplateType);

          IAttributeDeclaration mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
          mtDataMember.AddArgument("Description", "Adjustment Template");
          property.CustomAttributes.Add(mtDataMember.Attribute);

          IAttributeDeclaration mtAdjustmentType = AttributeDeclarationFactory.Get<MTAdjustmentTypeAttribute>();
          mtAdjustmentType.AddArgument("Type", name);
          property.CustomAttributes.Add(mtAdjustmentType.Attribute);

          property = CreatePropertyData(name,
                                        "MetraTech.DomainModel.BaseTypes.AdjustmentInstance",
                                        false,
                                        0,
                                        null,
                                        false,
                                        true,
                                        ref piInstanceType);

          mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
          mtDataMember.AddArgument("Description", "Adjustment Instance");
          property.CustomAttributes.Add(mtDataMember.Attribute);

          mtAdjustmentType = AttributeDeclarationFactory.Get<MTAdjustmentTypeAttribute>();
          mtAdjustmentType.AddArgument("Type", name);
          property.CustomAttributes.Add(mtAdjustmentType.Attribute);
        }
      }

      if (!AddCounters(fileData, nameSpace, doc, ref piTemplateType))
      {
        logger.LogError(String.Format("Unable to create Priceable Item Template type from file {0}", fileData.FullPath));
        return false;
      }


      if (!CreatePriceableItemInstance(fileData, nameSpace, doc, ref piInstanceType))
      {
        logger.LogError(String.Format("Unable to create Priceable Item Instance type from file {0}", fileData.FullPath));
        return false;
      }

      return bResult;
    }

    private bool AddCounters(FileData fileData, string nameSpace, XmlDocument doc, ref CodeTypeDeclaration piCodeType)
    {
      //Add Counters
      XmlNodeList counters = doc.SelectNodes("//counters/cpd");
      if (counters.Count > 0)
      {
        foreach (XmlNode counter in counters)
        {
          XmlNode nameNode = counter.SelectSingleNode("./name");
          if (nameNode == null)
          {
            logger.LogError("Priceable Item generator failed - bad xml: //counters/cpd/name element is missing in file " + fileData.FullPath);
            return false;
          }

          string name = MakeAlphaNumeric(nameNode.InnerText.Trim());

          CodeMemberProperty property
              = CreatePropertyData(name,
                                   "MetraTech.DomainModel.BaseTypes.Counter",
                                   false,
                                   0,
                                   null,
                                   false,
                                   true,
                                   ref piCodeType);

          IAttributeDeclaration mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
          mtDataMember.AddArgument("Description", "Counter");
          property.CustomAttributes.Add(mtDataMember.Attribute);

          //Decorate with CounterPropertyDefinitionAttribute
          IAttributeDeclaration cpdAttribute = AttributeDeclarationFactory.Get<CounterPropertyDefinitionAttribute>();
          cpdAttribute.AddArgument(counter, "./name", "Name");
          cpdAttribute.AddArgument(counter, "./display_name", "DisplayName");
          cpdAttribute.AddArgument(counter, "./service_property", "ServiceProperty");
          property.CustomAttributes.Add(cpdAttribute.Attribute);

        }
      }

      return true;
    }

    private bool CreatePriceableItemInstance(FileData fileData, string nameSpace, XmlDocument doc, ref CodeTypeDeclaration piInstance)
    {
      XmlNodeList paramTables = doc.SelectNodes("//parameter_table");

      if (paramTables.Count > 0)
      {
        foreach (XmlNode paramTable in paramTables)
        {
          string name = paramTable.InnerText.Trim();
          if (String.IsNullOrEmpty(name))
          {
            logger.LogError("Priceable Item generator failed to crate PIInstance - bad xml: parmeter tabe name is missing in file " + fileData.FullPath);
            return false;
          }

          string cannonicalName = RateEntryGenerator.GetRatePrefix(name);
          if (!String.IsNullOrEmpty(cannonicalName))
          {
            string propertyName = MakeAlphaNumeric(name) + "_RateSchedules";
            string type = "List<RateSchedule<" + cannonicalName + "RateEntry, " + cannonicalName + "DefaultRateEntry>>";

            CodeMemberProperty property
                = CreatePropertyData(propertyName,
                                     type,
                                     false,
                                     0,
                                     null,
                                     false,
                                     true,
                                     ref piInstance);

            IAttributeDeclaration mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
            mtDataMember.AddArgument("Description", "A collection of rate schedules for " + name + " parameter table.");
            property.CustomAttributes.Add(mtDataMember.Attribute);

            IAttributeDeclaration rateSchedAttrib = AttributeDeclarationFactory.Get<MTRateSchedulesPropertyAttribute>();
            rateSchedAttrib.AddArgument("ParameterTable", name);
            property.CustomAttributes.Add(rateSchedAttrib.Attribute);
          }
          else
          {
            logger.LogWarning("PriceableItemGenerator: Parameter Table {0} does not exist", name);
          }
        }

      }

      return true;
    }

    private void PopulateChildInstance(string parentName, string childName, CodeTypeDeclarationCollection instanceTypes, IAttributeDeclaration mtDataMember, CodeMemberProperty property)
    {
      for (int count = 0; count < instanceTypes.Count; count++)
      {
        CodeTypeDeclaration instance = instanceTypes[count];
        string typeName = instance.Name;
        string parentInstanceName = parentName + "PIInstance";

        if (parentInstanceName.Equals(typeName))
        {
          // PI Instances
          property =
           CreatePropertyData(childName,
                              childName + "PIInstance",
                              false,
                              0,
                              null,
                              false,
                              true,
                              ref instance);

          mtDataMember = AttributeDeclarationFactory.Get<MTDataMemberAttribute>();
          mtDataMember.AddArgument("Description", "Child Priceable Item Instance");
          property.CustomAttributes.Add(mtDataMember.Attribute);
          break;
        }
      }
    }

    private bool CreateAdjustments(FileData fileData, string nameSpace, ref CodeNamespace codeNamespaceForAdjustments)
    {
        bool retval = true;

        XmlDocument doc = new XmlDocument();
        doc.Load(fileData.FullPath);

        XmlNodeList adjustments = doc.SelectNodes("//adjustment_type");
        if (adjustments.Count > 0)
        {
            foreach (XmlNode adjustment in adjustments)
            {
                XmlNode adjustmentName = adjustment.SelectSingleNode("./name");
                if (adjustmentName == null)
                {
                    logger.LogError("Adjustment generator failed - bad xml: //adjustment_type/name element is missing in file " + fileData.FullPath);
                    return false;
                }

                string name = MakeAlphaNumeric(adjustmentName.InnerText.Trim());

                #region Add Inputs Class
                XmlNode requiredInputs = adjustment.SelectSingleNode("./required_inputs");
                if (requiredInputs == null)
                {
                    logger.LogError("Adjustment generator failed - bad xml: //adjustment_type/required_inputs element is missing in file {0}", fileData.FullPath);
                    return false;
                }

                CodeTypeDeclaration inputsClass = new CodeTypeDeclaration(string.Format("{0}Inputs", name));
                inputsClass.BaseTypes.Add("MetraTech.DomainModel.BaseTypes.AdjustmentInput");

                foreach (XmlNode inputs in requiredInputs.ChildNodes)
                {
                    if (string.Compare(inputs.Name, "input_val", true) == 0)
                    {
                        string inputName = inputs.Attributes["name"].Value;

                        CreatePropertyData(inputName, "System.Decimal", false, 0, null, false, true, ref inputsClass);

                        CodeObjectCreateExpression coce = new CodeObjectCreateExpression(
                            Type.GetType("System.Collections.Generic.Dictionary`2[[MetraTech.DomainModel.Enums.Core.Global.LanguageCode, MetraTech.DomainModel.Enums.Generated ],[System.String, mscorlib]]"), 
                            new CodeExpression[0]);

                        CreatePropertyData(string.Format("{0}DisplayNames", inputName), 
                            Type.GetType("System.Collections.Generic.Dictionary`2[[MetraTech.DomainModel.Enums.Core.Global.LanguageCode, MetraTech.DomainModel.Enums.Generated ],[System.String, mscorlib]]"), 
                            false, 
                            0, 
                            coce, 
                            false, 
                            false, 
                            ref inputsClass);
                    }
                    else
                    {
                        logger.LogError("Adjustment generator failed - bad xml: unexpected required_inputs child element {1} in file {0}", fileData.FullPath, inputs.Name);
                        return false;
                    }
                }

                codeNamespaceForAdjustments.Types.Add(inputsClass);
                #endregion

                #region Add Outputs Class
                XmlNode outputsNode = adjustment.SelectSingleNode("./outputs");
                if (outputsNode == null)
                {
                    logger.LogError("Adjustment generator failed - bad xml: //adjustment_type/outputs element is missing in file {0}", fileData.FullPath);
                    return false;
                }

                CodeTypeDeclaration outputsClass = new CodeTypeDeclaration(string.Format("{0}Outputs", name));
                outputsClass.BaseTypes.Add("MetraTech.DomainModel.BaseTypes.AdjustmentOutput");

                foreach (XmlNode outputs in outputsNode.ChildNodes)
                {
                    if (string.Compare(outputs.Name, "output_val", true) == 0)
                    {
                        string outputName = outputs.Attributes["name"].Value;

                        CreatePropertyData(outputName, "System.Decimal", false, 0, null, false, true, ref outputsClass);

                        CodeObjectCreateExpression coce = new CodeObjectCreateExpression(
                            Type.GetType("System.Collections.Generic.Dictionary`2[[MetraTech.DomainModel.Enums.Core.Global.LanguageCode, MetraTech.DomainModel.Enums.Generated ],[System.String, mscorlib]]"), 
                            new CodeExpression[0]);
                        
                        CreatePropertyData(string.Format("{0}DisplayNames", outputName), 
                            Type.GetType("System.Collections.Generic.Dictionary`2[[MetraTech.DomainModel.Enums.Core.Global.LanguageCode, MetraTech.DomainModel.Enums.Generated ],[System.String, mscorlib]]"), 
                            false, 
                            0, 
                            coce, 
                            false, 
                            false, 
                            ref outputsClass);
                    }
                    else
                    {
                        logger.LogError("Adjustment generator failed - bad xml: unexpected outputs child element {1} in file {0}", fileData.FullPath, outputs.Name);
                        return false;
                    }
                }

                codeNamespaceForAdjustments.Types.Add(outputsClass);
                #endregion
            }
        }

        
        return retval;
    }
    
    #endregion

    #region Properties
    private static Dictionary<string, string> mParentChild = new Dictionary<string, string>();
    #endregion

    #region Data

    // .NET guarantees thread safety for static initialization 
    private static readonly PriceableItemGenerator instance;

    private static Dictionary<string, PIKindMapData> kindToBaseClassMap = new Dictionary<string, PIKindMapData>(StringComparer.InvariantCultureIgnoreCase);

    #endregion
  }

  internal class PIKindMapData
  {
    public string BaseClassName { get; set; }
    public string PIKindID { get; set; }
  }
}
