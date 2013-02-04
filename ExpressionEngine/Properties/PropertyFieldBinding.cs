using System.Collections.Generic;
using System.Xml;

namespace MetraTech.ICE.TreeFlows
{
  public class PropertyFieldBinding
  {
    public string PropertyName;
    public string FieldName;

    public PropertyFieldBinding(string propertyName, string fieldName)
    {
      this.PropertyName = propertyName;
      this.FieldName = fieldName;
    }

    public MetraTech.ICE.Property GetProperty(MetraTech.ICE.PropertyCollection props)
    {
      return props.GetByName(PropertyName);
    }

    public Property_TreeFlow GetField(Dictionary<string, Property_TreeFlow> fields)
    {
      Property_TreeFlow field = null;
      fields.TryGetValue(FieldName, out field);
      return field;
    }

    public Property_TreeFlow GetNewFieldBasedOnProperty(MetraTech.ICE.PropertyCollection props, DirectionType direction)
    {
      var prop = GetProperty(props);
      if (prop == null)
        return null;
      var field = new Property_TreeFlow(prop, direction);
      field.Name = FieldName;
      return field;
    }

    public static PropertyFieldBinding CreateFromXmlNode(XmlNode xmlNode)
    {
      var bindingNode = XmlDocHelper.XmlNodeGetRequiredNode(xmlNode, "PropertyName"); 
      var fieldName = XmlDocHelper.XmlNodeGetRequiredAttribute(xmlNode, "FieldName");
      return new PropertyFieldBinding(bindingNode.InnerText, fieldName);
    }

    public void AppendXmlNode(XmlNode xmlNode)
    {
      XmlNode bindingNode = XmlDocHelper.XmlNodeAppendChildNode(xmlNode, "PropertyBinding", PropertyName);
      XmlDocHelper.XmlNodeSetAttribute(bindingNode, "FieldName", FieldName);
    }

    public string Check(MetraTech.ICE.PropertyCollection props, Dictionary<string, Property_TreeFlow> fields)
    {
      if (string.IsNullOrEmpty(PropertyName))
        return "Property Name is not specified.";

      var prop = GetProperty(props);
      if (prop == null)
        return string.Format("Unaable to find the '{0}' property.", PropertyName);

      if (prop.Required && string.IsNullOrEmpty(FieldName))
        return "Field Name not specified.";

      if (string.IsNullOrEmpty(FieldName))
        return null;

      Property_TreeFlow field;
      fields.TryGetValue(prop.Name, out field);
      if (field == null)
        return string.Format("The '{0}' field is not available.", FieldName);

      if (!field.DataTypeInfo.IsSameType(prop.DataTypeInfo))
        return string.Format("The '{0}' Property and the '{1}' Field do not have the same data type.", PropertyName, FieldName);

      return null;
    }

  }
}
