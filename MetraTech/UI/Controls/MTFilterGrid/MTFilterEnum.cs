using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;
using System.Web.UI;

namespace MetraTech
{
  public class MTFilterEnum
  {
    private string enumSpace = "";
    private string enumType = "";
    private string defaultValue = "";
    private string enumClassName = "";
    private bool useEnumValue = true;
    private List<String>hideEnumValues = new List<string>();

    /// <summary>
    /// If this property is set to true, enum values will be used,
    /// If set to False, database values will be used
    /// </summary>
    public bool UseEnumValue
    {
      get { return useEnumValue; }
      set { useEnumValue = value; }
    }

    public string EnumClassName
    {
      get { return enumClassName; }
      set { enumClassName = value; }
    }

    public string EnumSpace
    {
      get { return enumSpace; }
      set { enumSpace = value; }
    }

    public string EnumType
    {
      get { return enumType; }
      set { enumType = value; }
    }

    public string DefaultValue
    {
      get { return defaultValue; }
      set { defaultValue = value; }
    }

    /// <summary>
    /// List of enum values to hide from display in filter/edit dropdowns
    /// </summary>
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
    [PersistenceMode(PersistenceMode.InnerProperty)]
    [NotifyParentProperty(true)]
    public List<string> HideEnumValues
    {
      get { return hideEnumValues; }
      set { hideEnumValues = value; }
    }
  }
}
