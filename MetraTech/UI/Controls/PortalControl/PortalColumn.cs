using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using MetraTech.UI.Controls.Layouts;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls
{
  public class PortalColumn
  {
    public string ID { get; set; }
    public string Title { get; set; }
    public string CssClass { get; set; }

    private List<PortalRow> rows;
    public List<PortalRow> Rows {
      get
      {
        if (rows == null)
        {
          rows = new List<PortalRow>();
        }
        return rows;
      }
    }


    public void LoadFromLayout(PortalColumnLayout layout)
    {
      ID = layout.ID;
      Title = layout.Title;
      CssClass = layout.CssClass;

      foreach (PortalRowLayout prl in layout.Rows)
      {
        PortalRow pr = new PortalRow();
        pr.LoadFromLayout(prl);

        Rows.Add(pr);
      }
    }
  }
}
