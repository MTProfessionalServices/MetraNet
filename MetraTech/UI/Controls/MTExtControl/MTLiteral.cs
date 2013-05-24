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
  [ToolboxData("<{0}:MTLiteralControl runat=server></{0}:MTLiteralControl>")]
  public class MTLiteralControl : MTExtControl 
  {
    #region JavaScript
    #endregion

    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "MiscField";

      base.OnInit(e);
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public override string Text
    {
      get
      {
        String s = (String)ViewState["Text"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Text"] = value;
      }
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      // modify js
      ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);
     
      // call base render
      base.RenderContents(output);
    }
    #endregion

  }
}
