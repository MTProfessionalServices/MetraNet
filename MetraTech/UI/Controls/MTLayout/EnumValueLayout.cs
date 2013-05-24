using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Serialization;

namespace MetraTech.UI.Controls.MTLayout
{
  [Serializable]
  public class EnumValueLayout
  {
    public bool UseEnumValue = true;
    public String EnumClassName = null;
    public String EnumSpace = null;
    public String EnumType = null;
    public String DefaultValue = null;

    [XmlArrayItem("EnumValue")]
    public List<String> HideEnumValues = new List<string>();
  }
}
