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
  [ToolboxData("<{0}:MTHtmlEditor runat=server></{0}:MTHtmlEditor>")]
  public class MTHtmlEditor : MTExtControl
  {
    #region JavaScript
    public string Options = @"maxLength:%%MAX_LENGTH%%,
                              minLength:%%MIN_LENGTH%%";
    #endregion

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string MaxLength
    {
      get
      {
        String s = (String)ViewState["MaxLength"];
        return ((s == null) ? "1000" : s);
      }

      set
      {
        ViewState["MaxLength"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string MinLength
    {
      get
      {
        String s = (String)ViewState["MinLength"];
        return ((s == null) ? "0" : s);
      }

      set
      {
        ViewState["MinLength"] = value;
      }
    }
    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "HtmlEditor";
     
      base.OnInit(e);
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      // modify js
      ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);

      string options = Options.Replace("%%MAX_LENGTH%%", MaxLength);
      options = options.Replace("%%MIN_LENGTH%%", MinLength);

      //attach options to OptionalExtConfig. NOTE: there is no duplicate resolution
      OptionalExtConfig = (String.IsNullOrEmpty(OptionalExtConfig) ? options : options + "," + OptionalExtConfig);

      // call base render
      base.RenderContents(output);
    }
    #endregion
  }
}
