using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;

namespace SampleAspNetApp
{
	public partial class Decoder : System.Web.UI.Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			this.Title = "Decoder test";
		}

        protected void btnHtmlDecode_Click(object sender, EventArgs e)
        {
            txtResultHtmlDecode.Text = txtHtml.Text.DecodeFromHtml();
        }

		protected void btnJavaScriptDecode_Click(object sender, EventArgs e)
		{
			txtResultJavaScriptDecode.Text = txtJavaScriptDecode.Text.DecodeFromJavaScript();
		}

        protected void btnVbScriptDecode_Click(object sender, EventArgs e)
        {
            txtResultVbScriptDecode.Text = txtVbScriptDecode.Text.DecodeFromVbScript();
        }        

		protected void btnDecode_Click(object sender, EventArgs e)
		{
		    txtResultXmlDecode.Text = txtXml.Text.DecodeFromXml();
		}

		protected void btnUrlDecode_Click(object sender, EventArgs e)
		{
			txtResultUrlDecode.Text = txtUrl.Text.DecodeFromUrl();
		}        

		protected void btnCssDecode_Click(object sender, EventArgs e)
		{
			txtResultCssDecode.Text = txtCss.Text.DecodeFromCss();
		}

		protected void btnGZipDecode_Click(object sender, EventArgs e)
		{
			txtResultGZipDecode.Text = System.Text.Encoding.UTF8.GetString(txtGZip.Text.DecodeFromGZip());
		}

		protected void btnLdapDecode_Click(object sender, EventArgs e)
		{
			txtResultLdapDecode.Text = txtLdap.Text.DecodeFromLdap();
		}
	}
}