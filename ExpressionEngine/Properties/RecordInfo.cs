using System;
using System.Collections.Generic;
using System.Xml;
using MetraTech.ICE.FileLoadResults;
using MetraTech.ICE.ValidationResults;

namespace MetraTech.ICE.TreeFlows
{
  /// <summary>
  /// MetaData for Records
  /// </summary>
  public class RecordInfo
  {
    #region Constants
    public const string USAGE_EVENT = "UsageEvent";
    public const string CHILD_USAGE_EVENT = "ChildUsageEvent";
    public const string SUBSCRIPTION = "Subscription";
    public const string RATE_SCHEDULE = "RateSchedule";
    public const string ACCOUNT = "Account"; 
    #endregion

    #region Properties
    /// <summary>
    /// A static dictionary of the fields
    /// </summary>
    public static Dictionary<string, RecordInfo> RecordInfos;

    /// <summary>
    /// The name of the record; visible to the user
    /// </summary>
    public string Name { get; private set; }

    /// <summary>
    /// Indicates if the record supports dynamic fields
    /// </summary>
    public bool SupportsDynamicFields { get; private set; }

    /// <summary>
    /// Short description to be used in tooltips etc.
    /// </summary>
    public string Description { get; private set; }

    private ConfigItemInfo Template;

    /// <summary>
    /// The static fields, if any
    /// </summary>
    public List<ConfigItemInfo> StaticConfigItems = new List<ConfigItemInfo>();

    #endregion Properties

    #region Methods

    /// <summary>
    /// Copies the record to the specified collection using the specfied instance name. Both the record and its
    /// associated FieldBindings are copied. Note that dynamic bindings are not handled by this method and must be
    /// coded by hand. In the future, it seems that we should add RecordBindings here as well.
    /// </summary>
    /// <param name="collection"></param>
    /// <param name="recordInstanceName"></param>
    /// <returns></returns>
    public Property_TreeFlow CopyRecordToPropertyCollection(List<Property_TreeFlow> collection, string recordInstanceName, bool fieldsAreAssigned)
    {
      //Add the record
      var record = new Property_TreeFlow(Template, recordInstanceName);

      //Add the fields
      foreach (ConfigItemInfo infoField in StaticConfigItems)
      {
        var field = new Property_TreeFlow(infoField);
        field.Name = recordInstanceName + "." + infoField.Name;
        field.Direction = DirectionType.Output;
        field.Required = infoField.IsRequired;
        field.IsAssigned = fieldsAreAssigned;
        field.Description = infoField.Description;
        collection.Add(field);
      }

      return record;
    }

    public Property_TreeFlow CopyToPropertyCollection(Dictionary<string, Property_TreeFlow> collection, string recordInstanceName, bool fieldsAreAssigned)
    {
        //Add the record
        var record = new Property_TreeFlow(Template, recordInstanceName);

        //Add the fields
        foreach (ConfigItemInfo infoField in StaticConfigItems)
        {
            var field = new Property_TreeFlow(infoField);
            field.Name = recordInstanceName + "." + infoField.Name;
            field.Required = infoField.IsRequired;
            field.IsAssigned = fieldsAreAssigned;
            field.Description = infoField.Description;
            collection.Add(field.Name,field);
        }

        return record;
    }

    public ConfigItemInfo GetField(string fieldName)
    {
      //return StaticConfigItems.First(s => s.Name == fieldName);]
      foreach (var info in StaticConfigItems)
      {
        if (info.Name.Equals(fieldName, StringComparison.CurrentCultureIgnoreCase))
          return info;
      }
      return null;
    }

    #endregion Methods

    #region StaticMethods

    /// <summary>
    /// Static constructor that loads all of the metadata from a single file.
    /// </summary>
    static RecordInfo()
    {
      RecordInfos = new Dictionary<string, RecordInfo>(StringComparer.CurrentCultureIgnoreCase);

      string filePath = EnvironmentConfiguration.Instance.ICEConfigDirectory + @"\TreeFlowRecordInfo.xml";
      XmlDocument doc = new XmlDocument();
      doc.Load(filePath);

      try
      {
        foreach (XmlNode recordNode in doc.SelectNodes("TreeFlowRecordInfo/Record"))
        {
          var recordInfo = RecordInfo.CreateFromXmlNode(recordNode);         
          RecordInfos.Add(recordInfo.Name, recordInfo);
        }
      }
      catch (Exception ex)
      {
        FileLoadResultManager.Instance.AppendFileLoadResult(ValidationItem.ValLevel.Error, null, filePath, "Unable to load TreeFlowNode record info file [" + ex.Message + "]");
      }
    }

    /// <summary>
    /// Returns a new RecordInfo from the specified xmlNode.
    /// </summary>
    /// <param name="xmlNode"></param>
    /// <returns></returns>
    public static RecordInfo CreateFromXmlNode(XmlNode xmlNode)
    {
      var recordInfo = new RecordInfo();
      recordInfo.Name = XmlDocHelper.XmlNodeGetRequiredTag(xmlNode, "Name");
      recordInfo.SupportsDynamicFields = XmlDocHelper.XmlNodeGetRequiredBoolTag(xmlNode, "SupportsDynamicFields");
      recordInfo.Description = XmlDocHelper.XmlNodeGetRequiredTag(xmlNode, "Description");

      recordInfo.Template = new ConfigItemInfo(recordInfo.Name, new DataTypeInfo(DataType._record, recordInfo.Name));

      //Load the static fields
      foreach (XmlNode fieldNode in xmlNode.SelectNodes("StaticFields/Field"))
      {
        var fieldInfo = ConfigItemInfo.CreateFromXmlNode(fieldNode);
        fieldInfo.RecordInfo = recordInfo;
        recordInfo.StaticConfigItems.Add(fieldInfo);
      }

      if (string.IsNullOrEmpty(recordInfo.Name))
        throw new Exception("Name not specified.");

      return recordInfo;
    }

    /// <summary>
    /// Used when binding an output to another record.
    /// </summary>
    /// <param name="recordName"></param>
    /// <param name="fieldName"></param>
    /// <returns></returns>
    public static Property_TreeFlow CopyRecordField(string recordName, string fieldName, DirectionType direction)
    {
      if (!RecordInfos.ContainsKey(recordName))
        throw new Exception("Unable to find RecordInfo: " + recordName);
      var record = RecordInfos[recordName];

      var configInfo = record.GetField(fieldName);
      if (configInfo == null)
        throw new Exception("Unable to find Field: " + recordName + "." + fieldName);

      var field = new Property_TreeFlow(configInfo);
      field.Name = recordName + "." + fieldName;
      field.Description = configInfo.Description;
      field.Direction = direction;
      return field;
    }

    /// <summary>
    /// Copies the record to the specified collection using the specfied instance name. Both the record and its
    /// associated FieldBindings are copied. Note that dynamic bindings are not handled by this method and must be
    /// coded by hand. In the future, it seems that we should add RecordBindings here as well.
    /// </summary>
    /// <param name="collection"></param>
    /// <param name="recordInstanceName"></param>
    /// <returns></returns>
    public static Property_TreeFlow CopyRecordToPropertyCollection(List<Property_TreeFlow> collection, string recordName, string recordInstanceName, bool fieldsAreAssigned, object tag)
    {
      //Find the record
      if (!RecordInfos.ContainsKey(recordName))
        throw new Exception("Unable to find record info: " + recordName);

      var recordInfo = RecordInfos[recordName];

      //Add the record
      var record = new Property_TreeFlow(recordInstanceName, new DataTypeInfo(DataType._record, recordName), DirectionType.Output);
      record.Tag = tag;
      collection.Add(record);

      //Add the fields
      foreach (ConfigItemInfo infoField in recordInfo.StaticConfigItems)
      {
        var field = new Property_TreeFlow(infoField);
        field.Name = recordInstanceName + "." + infoField.Name;
        field.Direction = DirectionType.Output;
        field.Required = infoField.IsRequired;
        field.IsAssigned = fieldsAreAssigned;
        field.Description = infoField.Description;
        field.Direction = DirectionType.Output;
        collection.Add(field);
      }

      return record;
    }
    #endregion StaticMethods

  }
}
