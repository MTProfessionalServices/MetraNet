using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MetraTech.UI.Controls
{
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTPasswordMeter runat=server></{0}:MTPasswordMeter>")]
  public class MTPasswordMeter : MTExtControl
  {
    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "PasswordMeter";
      XTypeNameSpace = "ux";

      base.OnInit(e);
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      // call base render
      base.RenderContents(output);
    }
    #endregion

  }
}
