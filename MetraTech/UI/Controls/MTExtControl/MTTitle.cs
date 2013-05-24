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
    [ToolboxData("<{0}:MTTitle runat=server></{0}:MTTitle>")]
    public class MTTitle : WebControl
    {
        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        [Localizable(true)]
        public string Text
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
            string html = @"<div class=""CaptionBar"">{0}</div>";
            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added HTML encoding
            //output.Write(String.Format(html, Text));
            output.Write(String.Format(html, Text.EncodeForHtml()));
        }
    }
}
