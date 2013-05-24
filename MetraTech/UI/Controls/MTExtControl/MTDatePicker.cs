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
  [ToolboxData("<{0}:MTDatePicker runat=server></{0}:MTDatePicker>")]
  public class MTDatePicker : MTExtControl 
  {
    #region JavaScript
    public string Options = @"format:DATE_FORMAT,
                             altFormats:DATE_TIME_FORMAT,
                             minValue:%%MIN_VALUE%%,
                             maxValue:%%MAX_VALUE%%,
                             regex:%%VALIDATION_REGEX%%";
    #endregion


    #region Properties

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

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string MaxValue
    {
      get
      {
        String s = (String)ViewState["MaxValue"];
        return s;
      }

      set
      {
        ViewState["MaxValue"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string MinValue
    {
      get
      {
        String s = (String)ViewState["MinValue"];
        return s;
      }

      set
      {
        ViewState["MinValue"] = value;
      }
    }
    #endregion

    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "DateField";

      base.OnInit(e);
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      // modify js
      ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);
      string options = Options.Replace("%%MAX_VALUE%%", (String.IsNullOrEmpty(MaxValue)? "null" : "'" + MaxValue + "'"));
      options = options.Replace("%%MIN_VALUE%%", (String.IsNullOrEmpty(MinValue) ? "null" : "'" + MinValue + "'"));
      options = options.Replace("%%VALIDATION_REGEX%%", (String.IsNullOrEmpty(ValidationRegex) ? "null" : ValidationRegex));

      //attach options to OptionalExtConfig. NOTE: there is no duplicate resolution
      OptionalExtConfig = (String.IsNullOrEmpty(OptionalExtConfig) ? options : options + "," + OptionalExtConfig);

      // call base render
      base.RenderContents(output);
    }
    #endregion

  }
}
