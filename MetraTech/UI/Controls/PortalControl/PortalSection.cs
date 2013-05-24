using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using MetraTech.UI.Controls.Layouts;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls
{
  public class PortalSection
  {
    public string ID { get; set; }
    public string Title { get; set; }
    public string CssClass { get; set; }

    private List<PortalColumn> columns;
    public List<PortalColumn> Columns
    {
      get
      {
        if (columns == null)
        {
          columns = new List<PortalColumn>();
        }
        return columns;
      }
    }

    public void LoadFromLayout(PortalSectionLayout layout)
    {
      ID = layout.ID;
      Title = layout.Title;
      CssClass = layout.CssClass;

      foreach (PortalColumnLayout pcl in layout.Columns)
      {
        PortalColumn pc = new PortalColumn();
        pc.LoadFromLayout(pcl);

        Columns.Add(pc);
      }
    }
  }
}
