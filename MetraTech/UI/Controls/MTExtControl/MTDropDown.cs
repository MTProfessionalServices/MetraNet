using System;
using System.ComponentModel;
using System.Web.UI;
using MetraTech.SecurityFramework;
using MetraTech.UI.Tools;

namespace MetraTech.UI.Controls
{
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTDropDown runat=server></{0}:MTDropDown>")]
  public class MTDropDown : System.Web.UI.WebControls.DropDownList
  {

    #region JavaScript
    private const string EXT_SCRIPT = @"
                      <script type=""text/javascript"">
                       Ext.onReady(function(){
                          var converted_%%CONTROL_ID%% = new Ext.form.ComboBox({
                              %%OPTIONAL_EXT_CONFIG%% typeAhead: true,
                              triggerAction: 'all',
                              transform:'%%CONTROL_ID%%',
                              forceSelection:true,
                              value:'%%SELECTED_VALUE%%',
                              id: '%%CONTROL_ID%%',   
                              hiddenId: '%%CONTROL_ID%%',  
                              name: '%%CONTROL_ID%%',
                              width: %%WIDTH%%,
                              height: %%HEIGHT%%,
                              listeners: %%LISTENERS%%,
                              readOnly: %%READ_ONLY%%,
                              disabled: %%DISABLED%%,
                              tabIndex: %%TAB_INDEX%%,
                              allowBlank: %%ALLOW_BLANK%%,
                              editable: %%EDITABLE%%,
                              listWidth:%%LIST_WIDTH%%,
                              grow: true,
                              vtype: '%%VTYPE%%'
                          });
                          converted_%%CONTROL_ID%%.clearInvalid();

                          var qt_value_%%CONTROL_ID%% = converted_%%CONTROL_ID%%.getRawValue();
                          if(qt_value_%%CONTROL_ID%% == '')
                          {
                            qt_value_%%CONTROL_ID%% = TEXT_EMPTY;
                          }

                          var qt_%%CONTROL_ID%% = new Ext.ToolTip({
                              target: '%%CONTROL_ID%%_wrapper',
                              html: qt_value_%%CONTROL_ID%%
                          });
                            
                          qt_%%CONTROL_ID%%.on('beforeshow', function(comp){
                            if(converted_%%CONTROL_ID%%.getRawValue() == '')
                            {
                              return;
                            }
                            if (qt_%%CONTROL_ID%%.rendered)
                            {  
                              qt_%%CONTROL_ID%%.body.dom.innerHTML = converted_%%CONTROL_ID%%.getRawValue(); 
                            }
                          });

                          if (typeof(cBoxes) != 'undefined')
                          {
                            cBoxes['%%CONTROL_ID%%'] = converted_%%CONTROL_ID%%;
                          }
                          %%INLINE_SCRIPT%% 

                      });
                      </script>";
    #endregion

    #region Properties
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    public string VType
    {
      get
      {
        String s = (String)ViewState["VType"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["VType"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string ListWidth
    {
      get
      {
        String s = (String)ViewState["ListWidth"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["ListWidth"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public new string Text
    {
      get
      {
        String s = (String)ViewState["Text"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["Text"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string InlineScript
    {
      get
      {
        String s = (String)ViewState["InlineScript"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["InlineScript"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Label
    {
      get
      {
        String s = (String)ViewState["Label"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["Label"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string ControlWidth
    {
      get
      {
        String s = (String)ViewState["ControlWidth"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["ControlWidth"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string LabelWidth
    {
      get
      {
        String s = (String)ViewState["LabelWidth"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["LabelWidth"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string ControlHeight
    {
      get
      {
        String s = (String)ViewState["ControlHeight"];
        return s ?? String.Empty;
      }

      set
      {
        ViewState["ControlHeight"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [Description("For Example: { 'click' : this.onClick, 'mouseover' : this.onMouseOver, 'mouseout' : this.onMouseOut,  scope: this } ")]
    public string Listeners
    {
      get
      {
        String s = (String)ViewState["Listeners"];
        return (s ?? "{}");
      }

      set
      {
        ViewState["Listeners"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public bool AllowBlank
    {
      get
      {
        bool b = false;
        if (ViewState["AllowBlank"] != null)
        {
          b = (bool)ViewState["AllowBlank"];
        }
        return b;
      }

      set
      {
        ViewState["AllowBlank"] = value;
      }
    }


    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public bool ReadOnly
    {
      get
      {
        bool b = false;
        if (ViewState["ReadOnly"] != null)
        {
          b = (bool)ViewState["ReadOnly"];
        }
        return b;
      }

      set
      {
        ViewState["ReadOnly"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public bool Editable
    {
      get
      {
        bool b = true;
        if (ViewState["Editable"] != null)
        {
          b = (bool)ViewState["Editable"];
        }
        return b;
      }

      set
      {
        ViewState["Editable"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public bool HideLabel
    {
      get
      {
        bool b = false;
        if (ViewState["HideLabel"] != null)
        {
          b = (bool)ViewState["HideLabel"];
        }
        return b;
      }

      set
      {
        ViewState["HideLabel"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public String LabelSeparator
    {
      get
      {
        String s = (String)ViewState["LabelSeparator"];
        return (s ?? ":");
      }

      set
      {
        ViewState["LabelSeparator"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string OptionalExtConfig
    {
      get
      {
        String s = (String)ViewState["OptionalExtConfig"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["OptionalExtConfig"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string EnumSpace
    {
      get
      {
        String s = (String)ViewState["EnumSpace"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["EnumSpace"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string EnumType
    {
      get
      {
        String s = (String)ViewState["EnumType"];
        return (s ?? String.Empty);
      }

      set
      {
        ViewState["EnumType"] = value;
      }
    }
    
    #endregion

    #region RenderContents
    protected override void Render(HtmlTextWriter writer)
    {
      //if (SelectedItem == null)
      //  return;

      string html = @"<div id=""%%CONTROL_ID%%_wrapper"" class=""x-form-item"">
                        <table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""clear:both;""><tr>
                            <td valign=""top"">
                                <label class=""x-form-item-label  %%LABEL_STYLE%%"" style=""width: %%LABEL_WIDTH%%px;display:%%HIDE_LABEL%%"" for=""x-form-el-combo_%%CONTROL_ID%%"">%%LABEL%%%%LABEL_SEPARATOR%%</label>
                            </td>
                            <td valign=""top"" class=""%%EXTRA_SPACE_CSS%%"">
                                <div id=""x-form-el-combo_%%CONTROL_ID%%"" class=""x-form-element"" style=""padding-left:%%LABEL_WIDTH_PAD%%px"">  
                                    <div class=""%%WRAPPER_CSS%%"">
                    ";
      string endHtml = "</div></div></td></tr></table></div>";

      // Set some defaults for rendering
      ControlWidth = ((ControlWidth == String.Empty) ? "200" : ControlWidth);
      ControlHeight = ((ControlHeight == String.Empty) ? "18" : ControlHeight);
      LabelWidth = ((LabelWidth == String.Empty) ? "120" : LabelWidth);
      ListWidth = ((ListWidth == String.Empty) ? "200" : ListWidth);
      string labelStyle = AllowBlank ? "Caption" : "CaptionRequired";
      string hideLabel = HideLabel ? "none;" : "block;";

      html = html.Replace("%%CONTROL_ID%%", ClientID);
      // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
      html = html.Replace("%%LABEL%%", Utils.EncodeForHtmlAttribute(Label));
      html = html.Replace("%%LABEL_WIDTH%%", Utils.EncodeForHtmlAttribute(LabelWidth));
      html = html.Replace("%%LABEL_STYLE%%", labelStyle);
      html = html.Replace("%%WRAPPER_CSS%%", ReadOnly ? "x-form-dd-wrap-readonly" : "x-form-dd-wrap");
      html = html.Replace("%%EXTRA_SPACE_CSS%%", ReadOnly ? "x-extra-space-readonly" : "x-extra-space");

      html = html.Replace("%%HIDE_LABEL%%", hideLabel);
      html = html.Replace("%%LABEL_SEPARATOR%%", Utils.EncodeForHtmlAttribute(LabelSeparator));
      html = html.Replace("%%LABEL_WIDTH_PAD%%", (/*int.Parse(LabelWidth)*/0).ToString());

      writer.Write(html);
      if (!ReadOnly)
      {
        base.Render(writer);
      }
      else
      {
        //readonly mode will allow access to displayed value and hidden selected index
        string readOnlyHTML = @"<div id=""%%CONTROL_ID%%_readonly_value"">%%CONTROL_VALUE%%</div><div style=""display:none"" id=""%%CONTROL_ID%%_readonly_index"">%%SELECTED_INDEX%%</div>";
        readOnlyHTML = readOnlyHTML.Replace("%%CONTROL_ID%%", ClientID);

        string tmpText = SelectedItem.Text;
        if (tmpText.Trim().Length == 0)
        {
          tmpText = " ";
        }
        // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
        readOnlyHTML = readOnlyHTML.Replace("%%CONTROL_VALUE%%", Utils.EncodeForHtml(tmpText));
        readOnlyHTML = readOnlyHTML.Replace("%%SELECTED_INDEX%%", this.SelectedIndex.ToString());

        writer.Write(readOnlyHTML);
      }

      writer.Write(endHtml);

      if (!DesignMode)
      {
        if (!ReadOnly)
        {
          string extScript = EXT_SCRIPT.Replace("%%CONTROL_ID%%", ClientID);
          extScript = extScript.Replace("%%VTYPE%%", VType);
          // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
          // Added JavaScript encoding
          //extScript = extScript.Replace("%%SELECTED_VALUE%%", SelectedValue);
          extScript = extScript.Replace("%%SELECTED_VALUE%%", Utils.EncodeForJavaScript(SelectedValue));
          extScript = extScript.Replace("%%X_FORM_STYLE%%", "x-form-element"); 
      	  // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
          // Added Encoding
		  extScript = extScript.Replace("%%WIDTH%%", Utils.EncodeForJavaScript(ControlWidth));
          extScript = extScript.Replace("%%HEIGHT%%", Utils.EncodeForJavaScript(ControlHeight));
          extScript = extScript.Replace("%%OPTIONAL_SPACER%%", "");
          extScript = extScript.Replace("%%LISTENERS%%", Listeners);
          extScript = extScript.Replace("%%LIST_WIDTH%%", Utils.EncodeForJavaScript(ListWidth));
          extScript = extScript.Replace("%%TAB_INDEX%%", TabIndex.ToString());
          extScript = extScript.Replace("%%READ_ONLY%%", ReadOnly.ToString().ToLower());
          extScript = extScript.Replace("%%DISABLED%%", (!Enabled).ToString().ToLower());
          extScript = extScript.Replace("%%ALLOW_BLANK%%", AllowBlank.ToString().ToLower());
          extScript = extScript.Replace("%%EDITABLE%%", Editable.ToString().ToLower());
          if (OptionalExtConfig != String.Empty)
          {
            if (!OptionalExtConfig.EndsWith(","))
            {
              OptionalExtConfig += ", ";
            }
          }
          extScript = extScript.Replace("%%OPTIONAL_EXT_CONFIG%%", OptionalExtConfig);
          extScript = extScript.Replace("%%INLINE_SCRIPT%%", InlineScript);

          writer.Write(extScript);
        }
      }
    }
    #endregion

  }
}