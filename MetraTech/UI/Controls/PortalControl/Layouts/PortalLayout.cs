using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls.Layouts
{
  [Serializable]
  public class PortalLayout
  {
    public string ID { get; set; }
    public LocalizableString Title { get; set; }
    public string CssClass { get; set; }
    public string CssPath { get; set; }

    [XmlArrayItem("Section")]
    public List<PortalSectionLayout> Sections = new List<PortalSectionLayout>();
  }
}
