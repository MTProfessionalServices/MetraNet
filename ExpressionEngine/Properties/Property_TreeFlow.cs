using System;
using System.Xml;

namespace MetraTech.ICE.TreeFlows
{
  #region Enums
  /// <summary>
  /// Differnt ways in which the user can interact with the configuration item.
  /// </summary>
  public enum InteractionType { FieldBinding, FieldOrConstantBinding, RecordBinding, GeneralMetaData }

  /// <summary>
  /// The type of binding mode that the user has selected. The ConfigItem must have a InteractionType=FieldOrConstantBinding for this to be of use.
  /// </summary>
  public enum BindingMode { Field, Constant }
  #endregion Enums

  /// <summary>
  /// A configuration item for a tree for node. We are using the Name property for values of constants.... need to think through
  /// </summary>
  public class Property_TreeFlow
  {
    #region Properties

    public string Name { get; set; }
    private DataTypeInfo _dataTypeInfo = new DataTypeInfo(DataType._int32);
    public DataTypeInfo DataTypeInfo { get { return _dataTypeInfo; } set { _dataTypeInfo = value; } }

    public DirectionType Direction;
    public string Description;


    /// <summary>
    /// Indicates if a setting is required. This is instance-level. In some cases Info.Required will be false but
    /// here it will be true. That's because something decided that in a certain case it is required. Best example
    /// is the Namespace in AccountLookup node with is require only if the LookupMode is external
    /// </summary>
    public bool Required { get; set; }

    /// <summary>
    /// I think that this is a hold over from property. I would think there is no need for this given that we have autobinding
    /// in metadata class. Damian to think through
    /// </summary>
    public string DefaultValue;

    public string ToolTipText
    {
      get
      {
        {
          string tooltipStr;
          switch (DataTypeInfo.Type)
          {
            case DataType._record:
              tooltipStr = "Record: " + DataTypeInfo.Name;
              if (Tag != null)
              {
                string prefix = "\r\nContext: ";
                switch (DataTypeInfo.Name)
                {
                  case RecordInfo.SUBSCRIPTION:
                    tooltipStr += prefix + "PriceableItem=" + Tag.ToString();
                    break;                  
                  case RecordInfo.RATE_SCHEDULE:
                    tooltipStr += prefix + "ParameterTable=" + Tag.ToString();
                    break;
                }
              }
              break;
            case DataType._element:
              tooltipStr = "Element: " + DataTypeInfo.Name;
              break;
            default:
              tooltipStr = DataTypeInfo.ToUserString(true);
              if (IsCounter)
                tooltipStr += string.Format(" (Counter with key={0})", Counter.KeyObj.Name);
              break;
          }
          if (!string.IsNullOrEmpty(Description))
            tooltipStr += "\r\n" + Description;
          return tooltipStr;
        }
      }
    }
    //Used for testing/debugging scenarios
    public string Value;

    /// <summary>
    /// Indicates how the field is bound. Vast majority are 'Field'
    /// </summary>
    public BindingMode BindingMode { get; set; }

    private bool _isAssigned = true;
    public bool IsAssigned { get { return _isAssigned; } set { _isAssigned = value; } }

    public bool IsCounter { get { return Counter != null; } }
    public Counter Counter;

    /// <summary>
    /// Indicates if the name has a "." in it indicating that it is part of a record.
    /// </summary>
    public bool HasDot { get { return Name.Contains("."); } }
    public bool IsParentRef { get { return Name.StartsWith(TreeFlow.PARENT_PREFIX + "."); } }

    /// <summary>
    /// Indicates that if the field should be included in generic field binding processing 99% are true
    /// AccountLookup Namespace is an example of a config field that is only bound conditionally
    /// </summary>
    public bool IncludeInFieldBindings { get { return _includeInFieldBindings; } set { _includeInFieldBindings = value; } }
    private bool _includeInFieldBindings = true;

    /// <summary>
    /// Provides metadata about how the field can be bound. Doesn't apply to all fields (maybe it should?)
    /// </summary>
    public ConfigItemInfo Info { get; /*private*/ set; }

    public string GuiControlName
    {
      get
      {
        if (Info != null)
          return Info.GuiControlName;
        else
          return null;
      }
    }

    /// <summary>
    /// This is used to pass additional metadata in the designer. Example, the SubscriptionLookup record is tied to a priceable item
    /// and we'd like to know that downstream.
    /// </summary>
    public object Tag { get; set; }

    #endregion Properties

    #region Constructors

    public Property_TreeFlow(string name, DataTypeInfo dtInfo, DirectionType direction)
    {
      Name = name;
      DataTypeInfo = dtInfo;
      Direction = direction;
    }


    public Property_TreeFlow(Property prop, DirectionType direction)
    {
      Name = prop.Name;
      DataTypeInfo = prop.DataTypeInfo.Copy();
      Direction = direction;
      Description = prop.Description;
    }

    public Property_TreeFlow()
    {
    }

    public Property_TreeFlow(ConfigItemInfo info)
      : this(info, info.AutoBinding)
    {
    }

    public Property_TreeFlow(ConfigItemInfo info, string name)
    {
      Name = name;
      DataTypeInfo = info.DataTypeInfo.Copy();
      Direction = info.Direction;
      //Don't copy the description

      Info = info;
    }

    public Property_TreeFlow(MetraTech.BusinessEntity.DataAccess.Metadata.Property prop, DirectionType direction, InteractionType interactionType):this(prop, direction)
    {
      Info = new ConfigItemInfo(this.Name, this.DataTypeInfo.Copy(), interactionType);
    }
    public Property_TreeFlow(MetraTech.BusinessEntity.DataAccess.Metadata.Property prop, DirectionType direction)
    {
      Name = prop.Name;
      DataTypeInfo = new DataTypeInfo(prop);
      Direction = direction;
      Description = prop.Description;
    }


    #endregion Constructors

    #region FileIO

    //
    //Parse the XML node; we're going to override because we support a more compact format!
    //
    public void ParsePtypeXmlNode(XmlNode node)
    {
      XmlNode nameNode = XmlDocHelper.XmlNodeGetRequiredNode(node, "Name");
      Name = nameNode.InnerText;
      var modeStr = XmlDocHelper.XmlNodeGetOptionalAttribute(nameNode, "BindingMode");
      if (modeStr == null)
        BindingMode = TreeFlows.BindingMode.Field;
      else
        BindingMode = (TreeFlows.BindingMode)Helper.ConvertStringToEnum(typeof(TreeFlows.BindingMode), modeStr, true);
      //I have no idea why following line doesnt' work!!!!!!!!!!!!!!!
      //BindingMode = (TreeFlows.BindingMode)Helper.ConvertStringToEnum(typeof(TreeFlows.BindingMode), XmlDocHelper.XmlNodeGetOptionalAttribute(nameNode, "BindingNode", TreeFlows.BindingMode.Field.ToString()), true);

      DataTypeInfo = DataTypeInfo.CreateFromDataTypeInfoXmlNode(node);
      Required = XmlDocHelper.XmlNodeGetOptionalBoolTag(node, "Required", false);
      DefaultValue = XmlDocHelper.XmlNodeGetOptionalTag(node, "DefaultValue", null);
      //EnumType = DataTypeInfo.EnumType;
      Direction = Property.GetDirectionEnum(XmlDocHelper.XmlNodeGetRequiredTag(node, "Direction"));
      Description = XmlDocHelper.XmlNodeGetOptionalTag(node, "Description");
    }


    //
    //Writes the properties to an XML file; we're going to override because we support a more compact format!
    //
    public void Write(XmlDocument doc, XmlNode node)
    {
      XmlNode nameNode = XmlDocHelper.XmlNodeSetChildNode(node, "Name", Name);
      if (this.BindingMode == TreeFlows.BindingMode.Constant)
        XmlDocHelper.XmlNodeSetAttribute(nameNode, "BindingMode", BindingMode.ToString());

      DataTypeInfo.WriteXmlNode(node);
      XmlDocHelper.XmlNodeSetChildNode(node, "Required", Required.ToString());
      XmlDocHelper.XmlNodeSetChildNodeIfNotNullOrEmpty(node, "DefaultValue", DefaultValue);
      XmlDocHelper.XmlNodeSetChildNode(node, "Direction", Direction.ToString());
      XmlDocHelper.XmlNodeSetChildNodeIfNotNullOrEmpty(node, "Description", Description);
    }

    public void WriteConfigItemInstance(XmlNode node)
    {
      if (Info == null)
        throw new Exception(string.Format("Field {0} does not have a FieldBindingInfo.", Name));
      XmlNode bindingNode = XmlDocHelper.XmlNodeSetChildNode(node, Info.Name, this.Name);
      if (Info.Interaction == TreeFlows.InteractionType.FieldOrConstantBinding)
        XmlDocHelper.XmlNodeSetAttribute(bindingNode, "BindingMode", BindingMode.ToString());
    }
    public void ParseConfigItemInstance(XmlNode node)
    {
      if (Info == null)
        throw new Exception(string.Format("Field {0} does not have a FieldBindingInfo.", Name));
      //XmlNode theNode = XmlDocHelper.XmlNodeGetRequiredNode(node, Info.Name);
      XmlNode theNode = node.SelectSingleNode(Info.Name);
      if (theNode == null)
        Name = null;
      else
        Name = theNode.InnerText;

      if (theNode != null && Info.Interaction == TreeFlows.InteractionType.FieldOrConstantBinding)
        BindingMode = (TreeFlows.BindingMode)Helper.ConvertStringToEnum(typeof(TreeFlows.BindingMode), XmlDocHelper.XmlNodeGetRequiredAttribute(theNode, "BindingMode"), true);
      else
        BindingMode = TreeFlows.BindingMode.Field;
    }

    /// <summary>


    #endregion FileIO

    #region OtherMethods

    public static Property_TreeFlow CreateFromProperty(Property prop)
    {
      var nProp = new Property_TreeFlow(prop, prop.Direction)
      {
        DataTypeInfo = prop.DataTypeInfo.Copy(),
        Name = prop.Name,
        Direction = prop.Direction,
        Required = prop.Required,
        DefaultValue = prop.DefaultValue
      };

      return nProp;
    }

    public Property CreateMetraConfigProperty()
    {

      var nProp = new Property(this.Name, this.DataTypeInfo, this.Direction)
      {
        Required = this.Required,
        DefaultValue = this.DefaultValue,
        Description = this.Description,
      };

      return nProp;
    }

    public string GetFormattedMetraFlowArgument()
    {
      if (Info == null)
        throw new Exception(string.Format("Field {0} does not have a BindingFieldInfo.", Name));

      if (string.IsNullOrEmpty(Info.MetraFlowArgName))
        throw new Exception(string.Format("MetraFlowArgument name for property {0} is null or empty.", Name));
      return string.Format("{0}=\"{1}\"", Info.MetraFlowArgName);
    }

    /// <summary>
    /// Returns a formatted tooltip.
    /// </summary>
    /// <returns></returns>
    public string GetToolTip()
    {
      string toolTip = string.Format("{0} ({1})", Name, Direction.ToString());
      if (string.IsNullOrEmpty(Description))
        return toolTip;
      return toolTip + "\r\n" + Description;
    }


    /// <summary>
    /// Returns an image to indicate direction.
    /// </summary>
    /// <param name="prop"></param>
    /// <returns></returns>
    public static string GetImageName(Property_TreeFlow prop)
    {
      switch (prop.Direction)
      {
        case DirectionType.Input:
          return "Value.png";
        case DirectionType.Output:
          return "ValueOutput.png";
        case DirectionType.InOut:
          return "ValueOutput.png";  //need to change this to something else
        default:
          throw new Exception("Unhandled Direction");
      }
    }

    public string GetQualifierString()
    {
      if (Info == null)
        return "";

      if (Info.Interaction == InteractionType.RecordBinding)
        return "record";
      else if (Info.Interaction == InteractionType.FieldOrConstantBinding)
      {
        if (BindingMode == TreeFlows.BindingMode.Field)
          return "field";
        else
          return "setting";
      }
      else if (Info.Interaction == InteractionType.FieldBinding)
        return "field";
      else 
        return "setting";
    }

    public Property GetProperty()
    {
      var prop = new Property(Name, DataTypeInfo.Copy(), Direction);
      prop.Required = Required;
      prop.Description = Description;
      return prop;
    }

    public object Clone()
    {
      //May want to be more judicious when creating a copy of the property
      //but using MemberwiseClone works for the moment
      Property_TreeFlow field = this.MemberwiseClone() as Property_TreeFlow;
      field.DataTypeInfo = this.DataTypeInfo.Copy();
      field.Counter = this.Counter;
      field.Tag = this.Tag;
      return field;
    }

    //
    //Determines if the the property is an input or an inout
    //
    public bool IsInputOrInOut()
    {
      return Direction == DirectionType.Input || Direction == DirectionType.InOut;
    }
    //
    //Determines if the the property is an output or an inout
    //
    public bool IsOutputOrInOut()
    {
      return Direction == DirectionType.Output || Direction == DirectionType.InOut;
    }


    /// <summary>
    /// Refactors the name if appropriate.
    /// </summary>
    /// <param name="oldName"></param>
    /// <param name="newName"></param>
    /// <param name="isRecord"></param>
    /// <returns></returns>
    public void Refactor(string oldName, string newName, bool isRecord)
    {
      if (IsRefactorMatch(oldName, isRecord))
        Name = newName;
    }

    /// <summary>
    ///  Determines if the specified paramters coould result in a refactoring match.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="isRecord"></param>
    /// <returns></returns>
    public bool IsRefactorMatch(string name, bool isRecord)
    {
      //If the name of the field or the new name is null or empty, there is nothing to refactor
      if (string.IsNullOrEmpty(Name) || string.IsNullOrEmpty(name))
        return false;

      if (isRecord)
      {
        if (!Name.ToLower().StartsWith(name.ToLower() + "."))
          return false;
      }
      else if (!Name.Equals(name, StringComparison.CurrentCultureIgnoreCase))
        return false;

      switch (Info.Interaction)
      {
        case InteractionType.RecordBinding:
          return isRecord;
        case InteractionType.FieldBinding:
          return !isRecord;
        case InteractionType.FieldOrConstantBinding:
          return (BindingMode == TreeFlows.BindingMode.Field);
        default:
          return false;
      }
    }

    public string GetRefactorContext(string oldName, bool isRecord)
    {
      if (IsRefactorMatch(oldName, isRecord))
        return Direction.ToString() + " binding";
      else
        return null;
    }

    public string GetCSharpBinding()
    {
      switch (Info.Interaction)
      {
        case InteractionType.FieldBinding:
        case InteractionType.RecordBinding:
          return Name;
        case InteractionType.FieldOrConstantBinding:
          if (BindingMode == TreeFlows.BindingMode.Field)
            return Name;
          else
            return DataTypeInfo.ConvertValueStringToCSharpConstant(DataTypeInfo, Name);
        case InteractionType.GeneralMetaData:
          return DataTypeInfo.ConvertValueStringToCSharpConstant(DataTypeInfo, Name);
        default:
          throw new Exception("Unhandled InteractionType: " + Info.Interaction.ToString());
      }
    }

    /// <summary>
    /// Useful for debugging.
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
      string tagStr = null;
      if (Tag != null)
        tagStr = Tag.ToString();
      return string.Format("Name={0}; Type={1}; Tag={2}", Name, DataTypeInfo.ToUserString(true), tagStr);
    }


    #endregion OtherMethods

  }
}
