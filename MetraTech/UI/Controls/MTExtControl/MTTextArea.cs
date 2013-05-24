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
  [ToolboxData("<{0}:MTTextArea runat=server></{0}:MTTextArea>")]
  public class MTTextArea : MTExtControl
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
    public int MinLength
    {
      get
      {
        if (ViewState["MinLength"] == null)
        {
          return 0;
        }
        return (int)ViewState["MinLength"];
      }

      set
      {
        ViewState["MinLength"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public int MaxLength
    {
      get
      {
        if (ViewState["MaxLength"] == null)
        {
          return -1;
        }
        return (int)ViewState["MaxLength"];
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
    public string ValidationRegex
    {
      get
      {
        string s = (string)ViewState["ValidationRegex"];
        return ((String.IsNullOrEmpty(s)) ? "null" : s);
      }

      set
      {
        ViewState["ValidationRegex"] = value;
      }
    }

    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "TextArea";
     
      base.OnInit(e);
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      // modify js
      ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);

      string options = Options.Replace("%%MAX_LENGTH%%", ((MaxLength == -1) ? "Number.MAX_VALUE" : MaxLength.ToString()));
      options = options.Replace("%%MIN_LENGTH%%", MinLength.ToString());

      //attach options to OptionalExtConfig. NOTE: there is no duplicate resolution
      OptionalExtConfig = (String.IsNullOrEmpty(OptionalExtConfig) ? options : options + "," + OptionalExtConfig);

      // call base render
      base.RenderContents(output);
    }
    #endregion
  }
}
