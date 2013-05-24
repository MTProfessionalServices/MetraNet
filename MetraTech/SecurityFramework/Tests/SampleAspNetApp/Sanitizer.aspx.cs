using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;

namespace SampleAspNetApp
{
    public partial class Sanitizer : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnBase64Sanitizer_Click(object sender, EventArgs e)
        {
            SetTextOrError(lbBase64Sanitizer,
                           delegate
                               {
                                   lbBase64Sanitizer.Text =
                                       HttpUtility.HtmlEncode(SecurityKernel.Sanitizer.Api.Execute(
                                           "Base64Sanitizer.V1", txtBase64Sanitizer.Text));
                               });
        }

        private delegate void SetText();

        private void SetTextOrError(Label lb, SetText dlSetText)
        {
            try
            {
                lb.ForeColor = Color.Black;
                dlSetText();
            }
            catch (Exception ex)
            {
                lb.ForeColor = Color.Red;
                lb.Text = HttpUtility.HtmlEncode(String.Format("Error: {0}. {1}",
                                                           ex.Message,
                                                           ex.InnerException == null ? ""
                                                                    : String.Format("Inner Exceptions: {0}.", ex.InnerException.Message)));
            }
        }
    }
}