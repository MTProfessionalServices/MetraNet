using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.UI.Controls.Layouts;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls
{
  public class PortalRow
  {
    public string ID { get; set; }
    public string Title { get; set; }
    public string CssClass { get; set; }
    public List<BaseWidget> Widgets = new List<BaseWidget>();

    public void LoadFromLayout(PortalRowLayout layout)
    {
      ID = layout.ID;
      Title = layout.Title;
      CssClass = layout.CssClass;

      foreach (WidgetLayout wl in layout.Widgets)
      {
        //Create object based on type
        BaseWidget widget = BaseWidget.CreateWidget(wl.Type);
        widget.LoadFromLayout(wl);

        Widgets.Add(widget);
      }
    }
  }
}
