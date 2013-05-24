using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI.WebControls;
using System.ComponentModel;
using System.Web.UI;
using MetraTech.SecurityFramework;

namespace MetraTech.UI.Controls
{
    [DefaultProperty("Text")]
    [ToolboxData("<{0}:MTButton runat=server></{0}:MTButton>")]
    public class MTButton : Button, IPostBackEventHandler
    {

        private const string MAIN_TAG = @"<span id=""div_%%CONTROL_ID%%"" style=""white-space:nowrap""></span>";
        private const string MAIN_SCRIPT = @"<script type=""text/javascript"">
                                          function tmpFunction_%%CONTROL_ID%%()
                                          {
                                            %%ON_CLIENT_CLICK%%
                                          }
                                          Ext.onReady(function(){
                                            btn_%%CONTROL_ID%% = new Ext.Button( {
                                                id: '%%CONTROL_ID%%',
                                                text: '%%TEXT%%',
                                                %%TOOLTIP%%
                                                %%HANDLER%%,
                                                renderTo: Ext.get(""div_%%CONTROL_ID%%"")
                                            });
                                          });
                                        </script>";


        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue(true)]
        [Localizable(true)]
        public bool ServerSide
        {
            get
            {
                if (ViewState["ServerSide"] == null)
                {
                    return true;
                }
                return (bool)ViewState["ServerSide"];
            }

            set
            {
                ViewState["ServerSide"] = value;
            }
        }

        protected override void OnLoad(EventArgs e)
        {
            Page.ClientScript.GetPostBackEventReference(this, String.Empty);
            base.OnLoad(e);
        }

        protected override void OnPreRender(EventArgs e)
        {
            string html = MAIN_SCRIPT;
            html = html.Replace("%%CONTROL_ID%%", this.ClientID);
            html = html.Replace("%%UNIQUE_ID%%", this.UniqueID);
            html = html.Replace("%%TOOLTIP%%", GenerateTooltip());
            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added JavaScript encoding
            //html = html.Replace("%%TEXT%%", Text.Replace("'", "\\'"));
            html = html.Replace("%%TEXT%%", Text.EncodeForJavaScript());
            html = html.Replace("%%HANDLER%%", GenerateHandler());
            html = html.Replace("%%ON_CLIENT_CLICK%%", FormatClientScript());


            string scriptIncludeKey = "script_" + this.ClientID;
            if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), scriptIncludeKey))
            {
                Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), scriptIncludeKey, html);
            }
        }

        protected override void Render(HtmlTextWriter writer)
        {
            string html = MAIN_TAG;
            html = html.Replace("%%CONTROL_ID%%", this.ClientID);
            html = html.Replace("%%UNIQUE_ID%%", this.UniqueID);
            html = html.Replace("%%TOOLTIP%%", GenerateTooltip());
            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added HTML encoding
            //html = html.Replace("%%TEXT%%", Text.Replace("'", "\\'"));
            html = html.Replace("%%TEXT%%", Text.EncodeForHtmlAttribute());
            html = html.Replace("%%HANDLER%%", GenerateHandler());
            html = html.Replace("%%ON_CLIENT_CLICK%%", FormatClientScript());
            writer.Write(html);
        }

        protected string GenerateTooltip()
        {
            if (String.IsNullOrEmpty(ToolTip))
            {
                return string.Empty;
            }

            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added JavaScript encoding
            //return "tooltip:'" + ToolTip.Replace("'", "\\'") + "',";
            return "tooltip:'" + ToolTip.EncodeForJavaScript() + "',";
        }

        protected string GenerateHandler()
        {
            //client script not provided - just call the postback
            String s = @"handler: function()
                {
                  if(tmpFunction_" + this.ClientID + @"() != false){";
            if (ServerSide)
            {
                s = s + "    __doPostBack('" + this.UniqueID + "','');";
            }
            s = s + @"
                  }
                }";


            return s;
        }

        public override void RenderBeginTag(HtmlTextWriter writer)
        {
            writer.RenderBeginTag(HtmlTextWriterTag.Span);
        }


        protected string FormatClientScript()
        {
            if (String.IsNullOrEmpty(OnClientClick))
            {
                return string.Empty;
            }

            string s = OnClientClick;
            s = s.Replace("javascript:", "");

            //if empty after replacement, return
            if (String.IsNullOrEmpty(s))
            {
                return string.Empty;
            }

            //add semicolon in the end if missing
            if (!s.EndsWith(";"))
            {
                s = s + ";";
            }

            return s;

        }

        #region IPostBackEventHandler Members

        void IPostBackEventHandler.RaisePostBackEvent(string eventArgument)
        {
            if (ServerSide)
            {
                base.OnClick(EventArgs.Empty);
            }
        }

        #endregion
    }
}
