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
  [ToolboxData("<{0}:MTTextBoxControl runat=server></{0}:MTTextBoxControl>")]
  public class MTTextBoxControl : MTExtControl 
  {
    #region JavaScript
    public string Options = @"minLength:%%MIN_LENGTH%%,
                              maxLength:%%MAX_LENGTH%%,
                              regex:%%VALIDATION_REGEX%%";

    #endregion

    #region Properties
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
    #endregion

    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "TextField";

      base.OnInit(e);
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      // modify js
       ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);

      string options = Options.Replace("%%MIN_LENGTH%%", MinLength.ToString());
      options = options.Replace("%%MAX_LENGTH%%", ((MaxLength == -1) ? "Number.MAX_VALUE" : MaxLength.ToString()));
      options = options.Replace("%%VALIDATION_REGEX%%", (String.IsNullOrEmpty(ValidationRegex) ? "null" : ValidationRegex));

      //attach options to OptionalExtConfig. NOTE: there is no duplicate resolution
      OptionalExtConfig = (String.IsNullOrEmpty(OptionalExtConfig) ? options : options + "," + OptionalExtConfig);

      // call base render
      base.RenderContents(output);
    }
    #endregion

  }
}
