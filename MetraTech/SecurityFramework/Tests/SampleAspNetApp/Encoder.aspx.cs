using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;

namespace SampleAspNetApp
{
    public partial class Encoder : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
			this.Title = "Encoders tests";
        }

        protected void btnUrlEncode_Click(object sender, EventArgs e)
        {
            this.lblUrlEncoded.Text = HttpUtility.HtmlEncode(txtUrl.Text.EncodeForUrl());
        }

        protected void btnHtmlEncode_Click(object sender, EventArgs e)
        {
            this.lblHtmlEmcoded.Text = HttpUtility.HtmlEncode(txtHtml.Text.EncodeForHtml());
        }

        protected void btnHtmlAttributeEncode_Click(object sender, EventArgs e)
        {
            this.lblHtmlAttributeEncoded.Text = HttpUtility.HtmlEncode(txtHtmlAttribute.Text.EncodeForHtmlAttribute());
        }

        protected void btnCssEncode_Click(object sender, EventArgs e)
        {
            this.lblCssEncoded.Text = HttpUtility.HtmlEncode(txtCss.Text.EncodeForCss());
        }

        protected void btnJavaScriptEncode_Click(object sender, EventArgs e)
        {
            this.lblJavaScriptEncoded.Text = HttpUtility.HtmlEncode(txtJavaScript.Text.EncodeForJavaScript());
        }

        protected void btnVbScriptEncode_Click(object sender, EventArgs e)
        {
            this.lblVbScriptEncoded.Text = HttpUtility.HtmlEncode(txtVbScript.Text.EncodeForVbScript());
        }

        protected void btnXmlEncode_Click(object sender, EventArgs e)
        {
            this.lblXmlEncoded.Text = HttpUtility.HtmlEncode(txtXml.Text.EncodeForXml());
        }

        protected void btnXmlAttributeEncode_Click(object sender, EventArgs e)
        {
            this.lblXmlAttributeEncoded.Text = HttpUtility.HtmlEncode(txtXmlAttribute.Text.EncodeForXmlAttribute());
        }

        protected void btnLdapEncode_Click(object sender, EventArgs e)
        {
            this.lblLdapEncoded.Text = HttpUtility.HtmlEncode(this.txtLdap.Text.EncodeForLdap());
        }
    }
}