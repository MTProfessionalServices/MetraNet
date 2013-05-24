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
    public partial class DecoderBase64 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnComplexBase64Decode_Click(object sender, EventArgs e)
        {
           SetTextOrError(textResultComplexBase64Decode,
                           delegate
                               {
                                   textResultComplexBase64Decode.Text =
                                      SecurityKernel.Decoder.Api.Execute(
                                           "Base64.ComplexDecoder", txtComplexBase64.Text);
                               });

        }

        protected void btnStandartBase64Decode_Click(object sender, EventArgs e)
        {
            SetTextOrError(txtResultStandartBase64,
                          delegate
                          {
                              txtResultStandartBase64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                        "Base64.Standart", txtStandartBase64.Text);
                          });
        }

        protected void btnModifiedForFilenamesBase64Decode_Click(object sender, EventArgs e)
        {
           SetTextOrError(txtResultModifiedForFilenamesBase64,
                          delegate
                          {
                              txtResultModifiedForFilenamesBase64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                    "Base64.ModifiedForFilenames", txtModifiedForFilenamesBase64.Text);
                          });
        }

        protected void btnModifiedForURLBase64Decode_Click(object sender, EventArgs e)
        {
            SetTextOrError(txtResultModifiedForURLBase64,
                          delegate
                          {
                              txtResultModifiedForURLBase64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                        "Base64.ModifiedForURL", txtModifiedForURLBase64.Text);
                          });
        }

        protected void btnModifiedForXmlNmtokeBase64Decode_Click(object sender, EventArgs e)
        {
            SetTextOrError(txtResultModifiedForXmlNmtokeBase64,
                          delegate
                          {
                              txtResultModifiedForXmlNmtokeBase64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                        "Base64.ModifiedForXmlNmtoken", txtModifiedForXmlNmtokeBase64.Text);
                          });
        }

        protected void btnModifiedForXmlNameBase64Decode_Click(object sender, EventArgs e)
        {


            SetTextOrError(txtResultModifiedForXmlNameBase64,
                          delegate
                          {
                              txtResultModifiedForXmlNameBase64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                    "Base64.ModifiedForXmlName", txtModifiedForXmlNameBase64.Text);
                          });
        }

        protected void btnModifiedForProgramIdentofiersV1Base64Decode_Click(object sender, EventArgs e)
        {
            SetTextOrError(txtResultModifiedForProgramIdentofiersV1Base64,
                          delegate
                          {
                              txtResultModifiedForProgramIdentofiersV1Base64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                    "Base64.ModifiedForProgramIdentofiersV1", txtModifiedForProgramIdentofiersV1Base64.Text);
                          });
        }

        protected void btnModifiedForProgramIdentofiersV2Base64Decode_Click(object sender, EventArgs e)
        {
            SetTextOrError(txtResultModifiedForProgramIdentofiersV2Base64,
                          delegate
                          {
                              txtResultModifiedForProgramIdentofiersV2Base64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                    "Base64.ModifiedForProgramIdentofiersV2", txtModifiedForProgramIdentofiersV2Base64.Text);
                          });
        }

        protected void btnModifiedForRegularExpressionsBase64Decode_Click(object sender, EventArgs e)
        {
            SetTextOrError(txtResultModifiedForRegularExpressionsBase64,
                          delegate
                          {
                              txtResultModifiedForRegularExpressionsBase64.Text = 
                                  SecurityKernel.Decoder.Api.Execute(
                                    "Base64.ModifiedForRegularExpressions", txtModifiedForRegularExpressionsBase64.Text);
                          });
        }

        private delegate void SetText();

        private void SetTextOrError(TextBox textBox, SetText dlSetText)
        {
            try
            {
                textBox.ForeColor = Color.Black;
                dlSetText();
            }
            catch (Exception ex)
            {
                textBox.ForeColor = Color.Red;
                textBox.Text = String.Format("Error: {0}. {1}", 
                                            ex.Message,
                                            ex.InnerException == null 
                                                              ? ""
                                                              : String.Format("Inner Exceptions: {0}.", 
                                                                                ex.InnerException.Message));
            }
        }
    }
}