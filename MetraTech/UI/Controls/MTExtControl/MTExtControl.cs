using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;

namespace MetraTech.UI.Controls
{
    [DefaultProperty("Text")]
    [ToolboxData("<{0}:MTExtControl runat=server></{0}:MTExtControl>")]
    public class MTExtControl : WebControl, IPostBackDataHandler
    {
        #region JavaScript
        public string ControlScript = @"
      <div class=""x-form-item"" id=""MTField_%%CONTROL_ID%%"">
        <table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""clear:both;"">
            <tr>
                <td valign=""top"">
                    <label class=""x-form-item-label %%LABEL_STYLE%%"" style=""width:%%LABEL_WIDTH%%px;display:%%HIDE_LABEL%%"">%%CTL_LABEL%%%%LABEL_SEPARATOR%%</label>
                </td>
        %%OPTIONAL_SPACER%%
                <td valign=""top"" class=""%%EXTRA_SPACE_CSS%%"">
                    <div class=""%%X_FORM_STYLE%%"" style=""%%READONLY_PADDING%%padding-left:%%LABEL_WIDTH_PAD%%px"" id=""MTCtl_%%CONTROL_ID%%""></div>
                </td>
            </tr>
        </table>
      </div>

      <script type=""text/javascript"">
        Ext.onReady(function(){
          Ext.QuickTips.init();
          var formField_%%CONTROL_ID%% = new Ext.%%XTYPENAMESPACE%%.%%XTYPE%%({renderTo: 'MTCtl_%%CONTROL_ID%%',
            value: '%%CTL_VALUE%%',
            id: '%%CONTROL_ID%%',   
            name: '%%CONTROL_NAME%%',
            width: %%WIDTH%%,
            height: %%HEIGHT%%,
            listeners: %%LISTENERS%%,
            readOnly: %%READ_ONLY%%,
            disabled: %%DISABLED%%,
            tabIndex: %%TAB_INDEX%%,
            allowBlank: %%ALLOW_BLANK%%,
            validator: %%VALIDATION_FUNCTION%%,
            %%OPTIONAL_EXT_CONFIG%%
            vtype: '%%VTYPE%%'
          });
          formField_%%CONTROL_ID%%.clearInvalid();
          %%INLINE_SCRIPT%% 
        });
      </script>
    ";
        #endregion

        #region Control State
        [Serializable]
        private struct StateProperties
        {
            public string Text;
        }
        private StateProperties mStateProps;

        protected override void OnInit(EventArgs e)
        {
            Page.RegisterRequiresControlState(this);

            //enable the control to receive postbacks
            Page.RegisterRequiresPostBack(this);

            base.OnInit(e);
        }

        protected override object SaveControlState()
        {
            return mStateProps;
        }

        protected override void LoadControlState(object savedState)
        {
            mStateProps = new StateProperties();
            mStateProps = (StateProperties)savedState;
        }
        #endregion

        #region Properties
        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        public virtual string XType
        {
            get
            {
                String s = (String)ViewState["XType"];
                return (s ?? "TextField");
            }

            set
            {
                ViewState["XType"] = value;
            }
        }

        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        public virtual string XTypeNameSpace
        {
            get
            {
                String s = (String)ViewState["XTypeNameSpace"];
                return (s ?? "form");
            }

            set
            {
                ViewState["XTypeNameSpace"] = value;
            }
        }

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
        public string ValidationFunction
        {
            get
            {
                String s = (String)ViewState["ValidationFunction"];
                return (s ?? String.Empty);
            }

            set
            {
                ViewState["ValidationFunction"] = value;
            }
        }

        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        public string Name
        {
            get
            {
                String s = (String)ViewState["Name"];
                return (s ?? String.Empty);
            }

            set
            {
                ViewState["Name"] = value;
            }
        }

        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        [Localizable(true)]
        [NotifyParentProperty(true)]
        public virtual string Text
        {
            get
            {
                String s = mStateProps.Text;
                return (s ?? String.Empty);
            }

            set
            {
                mStateProps.Text = value;
                SaveControlState();
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
                return (s ?? String.Empty);
            }

            set
            {
                ViewState["ControlHeight"] = value;
            }
        }

        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
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

        private readonly Dictionary<string, string> optionsDictionary = new Dictionary<string, string>();
        #endregion

        #region RenderContents
        public override void RenderBeginTag(HtmlTextWriter writer)
        {
            //base.RenderBeginTag(writer);
        }

        public override void RenderEndTag(HtmlTextWriter writer)
        {
            //base.RenderEndTag(writer);
        }

        protected override void RenderContents(HtmlTextWriter output)
        {
            EnsureChildControls();
            ParseOptionConfigToDictionary(OptionalExtConfig);

            // Set some defaults for rendering
            ControlWidth = ((ControlWidth == String.Empty) ? "200" : ControlWidth);
            ControlHeight = ((ControlHeight == String.Empty) ? "18" : ControlHeight);

            if (optionsDictionary.ContainsKey("labelWidth"))
            {
              LabelWidth = optionsDictionary["labelWidth"];
            }
            LabelWidth = ((LabelWidth == String.Empty) ? "120" : LabelWidth);
            string labelStyle = AllowBlank ? "Caption" : "CaptionRequired";
            string hideLabel = HideLabel ? "none;" : "block;";

            if (DesignMode)
            {
                // Render an approximation of what it will look like
                output.Write(String.Format("<div><span style='width:{0}px;' class='{1}'>{2}</span>: <input style='width:{3}px,height:{4}px' value='{5}' /></div><br/>",
                             LabelWidth, labelStyle, Label, ControlWidth, ControlHeight, Text));
            }
            else
            {
                string html = ControlScript;

                // Runtime replacements for Ext
                html = html.Replace("%%CONTROL_ID%%", ClientID);
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //html = html.Replace("%%CONTROL_NAME%%", Name);
                html = html.Replace("%%CONTROL_NAME%%", Name.EncodeForJavaScript());

                if (!ReadOnly)
                {
                    html = html.Replace("%%XTYPE%%", XType);
                    html = html.Replace("%%LABEL_WIDTH_PAD%%", (/*int.Parse(LabelWidth) + */0).ToString());
                }
                else
                {
                    html = html.Replace("%%XTYPE%%", "StaticTextField");
                    html = html.Replace("%%LABEL_WIDTH_PAD%%", "0");
                    XTypeNameSpace = "ux";
                }
                html = html.Replace("%%XTYPENAMESPACE%%", XTypeNameSpace);
                html = !ReadOnly ? html.Replace("%%VTYPE%%", VType) : html.Replace("%%VTYPE%%", "");
                html = !ReadOnly ? html.Replace("%%VALIDATION_FUNCTION%%", (String.IsNullOrEmpty(ValidationFunction) ? "null" : ValidationFunction)) : html.Replace("%%VALIDATION_FUNCTION%%", "null");
                //html = !ReadOnly ? html.Replace("%%VALIDATION_REGEX%%", (String.IsNullOrEmpty(ValidationRegex) ? "null" : ValidationRegex)) : html.Replace("%%VALIDATION_REGEX%%", "null");        
                html = html.Replace("%%X_FORM_STYLE%%", "x-form-element");
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //html = html.Replace("%%CTL_LABEL%%", Label);
                //html = html.Replace("%%CTL_VALUE%%", Text.Replace("\\", "\\\\").Replace("'", "\\'").Replace("</script>", "</scr' + 'ipt>").Replace(Environment.NewLine, "\\r\\n"));
                //html = html.Replace("%%WIDTH%%", ControlWidth);
                //html = html.Replace("%%HEIGHT%%", ControlHeight);
                //html = html.Replace("%%LABEL_SEPARATOR%%", LabelSeparator);
                html = html.Replace("%%CTL_LABEL%%", Label.EncodeForHtmlAttribute());
                html = html.Replace("%%CTL_VALUE%%", Text.EncodeForJavaScript().Replace(Environment.NewLine, "\\r\\n"));
                html = html.Replace("%%WIDTH%%", ControlWidth.EncodeForJavaScript());
                html = html.Replace("%%HEIGHT%%", ControlHeight.EncodeForJavaScript());
                html = html.Replace("%%LABEL_SEPARATOR%%", LabelSeparator);
                if (HideLabel)
                {
                    html = html.Replace("%%OPTIONAL_SPACER%%", @"<label style=""width:%%LABEL_WIDTH%%px;""></label>");
                }
                else
                {
                    html = html.Replace("%%OPTIONAL_SPACER%%", "");
                }
                //html = html.Replace("%%LABEL_WIDTH%%", LabelWidth);
                html = html.Replace("%%LABEL_WIDTH%%", LabelWidth.EncodeForJavaScript());
                html = html.Replace("%%LABEL_STYLE%%", labelStyle);
                html = html.Replace("%%HIDE_LABEL%%", hideLabel);

                html = html.Replace("%%LISTENERS%%", Listeners);
                html = html.Replace("%%TAB_INDEX%%", TabIndex.ToString());
                html = html.Replace("%%READ_ONLY%%", ReadOnly.ToString().ToLower());
                html = html.Replace("%%DISABLED%%", (!Enabled).ToString().ToLower());
              
                html = html.Replace("%%ALLOW_BLANK%%", AllowBlank.ToString().ToLower());
                if (OptionalExtConfig != String.Empty)
                {
                    if (!OptionalExtConfig.EndsWith(","))
                    {
                        OptionalExtConfig += ", ";
                    }
                }
                html = html.Replace("%%OPTIONAL_EXT_CONFIG%%", OptionalExtConfig);
                html = html.Replace("%%INLINE_SCRIPT%%", InlineScript);
                html = html.Replace("%%READONLY_PADDING%%", (ReadOnly || (this is MTLiteralControl)) ? "padding-top:1px;" : "");
                html = html.Replace("%%EXTRA_SPACE_CSS%%", ReadOnly ? "x-extra-space-readonly" : "x-extra-space");
                output.Write(html);
            }

        }

        //CORE-5972: Enable to add style properties to template in xml
        private void ParseOptionConfigToDictionary(string optionConfig)
        {
          var lines = optionConfig.Split(",".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
          foreach (string line in lines)
          {
            var pair = line.Split(":".ToCharArray(), 2, StringSplitOptions.RemoveEmptyEntries);
            if (pair.Length == 2)
            {
              var key = pair[0].Trim();
              var value = pair[1].Trim();
              
              if (optionsDictionary.ContainsKey(key))
              {
                optionsDictionary.Remove(key);
              }
              optionsDictionary.Add(key, value);
            }
          }
        }
        #endregion
        
        #region IPostBackDataHandler
        virtual public bool LoadPostData(string postDataKey, System.Collections.Specialized.NameValueCollection postCollection)
        {
            EnsureChildControls();

            mStateProps.Text = postCollection[ClientID];

            return false;
        }

        virtual public void RaisePostDataChangedEvent()
        {
            //throw new Exception("The method or operation is not implemented.");
        }
        #endregion

    }
}
