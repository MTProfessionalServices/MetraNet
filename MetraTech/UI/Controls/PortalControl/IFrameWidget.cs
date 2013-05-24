using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;

namespace MetraTech.UI.Controls.Layouts
{
  public class IFrameWidget : BaseWidget
  {
    public string URL { get; set; }

    public IFrameWidget()
    {
      Type = WidgetType.IFrame;
    }

    protected override void CreateChildControls()
    {
      string combinedURL = base.ConstructURLFromParams(true);
      WidgetParameter widthParam = Parameters.Find(GetWidthParameter);
      WidgetParameter heightParam = Parameters.Find(GetHeightParameter);

      string widgetHTML = "<iframe src='" + combinedURL + "' ";
      if (widthParam != null)
      {
        int width;
        if (int.TryParse(widthParam.ParameterValue.ToString(), out width))
        {
          widgetHTML += "width='" + width.ToString() + "' ";
        }
        else
        {
          widgetHTML += "width='100%' ";
        }
      }
      if (heightParam != null)
      {
        int height;
        if (int.TryParse(heightParam.ParameterValue.ToString(), out height))
        {
          widgetHTML += "height='" + height.ToString() + "' ";
        }
        else
        {
          widgetHTML += "height='100%' ";
        }
      }

      widgetHTML += "frameborder='0' ";
      widgetHTML += "></iframe>";

      Controls.Add(new LiteralControl(widgetHTML));

    }


  }
}
