using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.UI.Controls
{
  public class GridLayoutWidget : BaseWidget
  {
    private MetraTech.Logger mtLog = new Logger("[Portal]");

    protected override void CreateChildControls()
    {
      string extensionName = string.Empty;
      string templateName = string.Empty;

      //read params
      foreach (WidgetParameter wp in Parameters)
      {
        if (wp.ParameterName == "ExtensionName")
        {
          extensionName = wp.ParameterValue.ToString();
          continue;
        }

        if (wp.ParameterName == "TemplateFileName")
        {
          templateName = wp.ParameterValue.ToString();
          continue;
        }
      }

      //check if valid
      if (string.IsNullOrEmpty(extensionName) || string.IsNullOrEmpty(templateName))
      {
        mtLog.LogWarning("Extension Name or Template Name required to render grid");
        return;
      }

      MTFilterGrid grid = new MTFilterGrid();
      grid.TemplateFileName = templateName;
      grid.ExtensionName = extensionName;

      Controls.Add(grid);

    }
  }


}
