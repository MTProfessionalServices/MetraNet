using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls.Layouts
{
  [Serializable]
  public class WidgetLayout
  {
    public Guid ID;
    public string Name;
    public string Description;
    public string Title;
    public string Path;
    public int Position;
    public string Height;
    public string CssClass;
    public string Style;
    public string Type; //index in repository

    [XmlArrayItem("Parameter")]
    public List<WidgetParameterLayout> Parameters = new List<WidgetParameterLayout>();

  }
}
