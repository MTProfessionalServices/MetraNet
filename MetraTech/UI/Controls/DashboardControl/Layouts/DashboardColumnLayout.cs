using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums.Core.UI;

namespace MetraTech.UI.Controls.Layouts
{
  [Serializable]
  public class DashboardColumnLayout
  {

    public Guid ID;
    public string Name;
    public string Description;
    public string Title;
    public int Position;
    public DashboardColumnWidth Width;
    public string CssClass;
    public string Style;

    [XmlArrayItem("Widget")]
    public List<WidgetLayout> Widgets = new List<WidgetLayout>();
  }
}
