using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using MetraTech.SecurityFramework;

namespace MetraTech.UI.Controls
{
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTRadioControl runat=server></{0}:MTRadioControl>")]
  public class MTRadioControl : MTExtControl 
  {
    #region JavaScript
    public string CheckBoxScriptOptions = @"boxLabel:'%%BOX_LABEL%%',
                                            inputValue:'%%CTL_VALUE%%',
                                            value:'%%CTL_VALUE%%',
                                            checked:%%CHECKED%%";
    #endregion

    #region Properties
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string BoxLabel
    {
      get
      {
        String s = (String)ViewState["BoxLabel"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["BoxLabel"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public string Value
    {
      get
      {
        String s = (String)ViewState["Value"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Value"] = value;
      }
    }


    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public bool Checked
    {
      get
      {
        bool b = false;
        if (ViewState["Checked"] != null)
        {
          b = (bool)ViewState["Checked"];
        }
        return b;
      }

      set
      {
        ViewState["Checked"] = value;
      }
    }

    #endregion

    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "Radio";
      HideLabel = true;

      base.OnInit(e);
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      EnsureChildControls();

      // modify js
      ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);
      ControlScript = ControlScript.Replace("%%X_FORM_STYLE%%", "x-form-check-wrap");
      //ControlScript = ControlScript.Replace("%%OPTIONAL_SPACER%%", @"<label style=""width:%%LABEL_WIDTH%%px;""></label>");
      ControlScript = ControlScript.Replace("%%OPTIONAL_SPACER%%", "");

      // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
      // Added JavaScript encoding
      //string options = CheckBoxScriptOptions.Replace("%%BOX_LABEL%%", BoxLabel);
      string options = CheckBoxScriptOptions.Replace("%%BOX_LABEL%%", BoxLabel.EncodeForJavaScript());
      options = options.Replace("%%CTL_VALUE%%", Text.EncodeForJavaScript());
      options = options.Replace("%%CHECKED%%", Checked.ToString().ToLower());

      //attach options to OptionalExtConfig. NOTE: there is no duplicate resolution
      OptionalExtConfig = (String.IsNullOrEmpty(OptionalExtConfig) ? options : options + "," + OptionalExtConfig);

      if (this.DesignMode)
      {
        // Render an approximation of what it will look like
        output.Write(String.Format("<div><input type='radio' style='width:{0},height:{1}' value='{2}' />&nbsp;&nbsp;{3}</div>",
                     ControlWidth, ControlHeight, Text, BoxLabel));
      }
      else
      {
        // call base render
        base.RenderContents(output);
      }
    }
    #endregion

    #region IPostBackDataHandler
    public override bool LoadPostData(string postDataKey, System.Collections.Specialized.NameValueCollection postCollection)
    {
      EnsureChildControls();

      if (postCollection[this.Name] != null)
      {
        this.Checked = postCollection[this.Name] == Text;
      }
      else
      {
        this.Checked = postCollection[this.ClientID] != null;
      }

      bool res = false;
      return res;
    }

    public override void RaisePostDataChangedEvent()
    {
      //throw new Exception("The method or operation is not implemented.");
    }
        #endregion
  }
}
