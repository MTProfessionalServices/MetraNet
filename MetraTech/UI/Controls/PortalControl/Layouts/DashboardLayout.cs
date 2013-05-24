using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls.Layouts
{
  [Serializable]
  public class DashboardLayout
  {
    public Guid DashboardID;
    public string Name;
    public string Description;
    public string Title;
    public string CssClass;
    public string Style;

    [XmlArrayItem("Columns")]
    public List<DashboardColumnLayout> Columns = new List<DashboardColumnLayout>();
  }
}
