using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Detector;

namespace SampleAspNetApp
{
	public partial class Detector : System.Web.UI.Page
	{
		public static string CreateMessageFromException(BadInputDataException ex)
		{
			string fullMessage = "1. Problem Id = '{0}';<br/> 2. Subsystem = '{1}';<br/> 3. Category = '{2}';<br/> 4. Message (User will see this text) = '{3}';<br/> 5. Input data = '{4}';<br/> 6. Reason = '{5}';<br/> 7. Event Type = '{6}';";
			return String.Format(fullMessage, ex.Id, ex.SubsystemName
									, ex.CategoryName, ex.Message
									, HttpUtility.HtmlEncode(ex.InputData), HttpUtility.HtmlEncode(ex.Reason), ex.EventType);
		}

		protected void Page_Load(object sender, EventArgs e)
		{
			this.Title = "Detector test";
		}

        protected void Page_PreRender(object sender, EventArgs e)
        {
            this.txtXss.Enabled = !this.chbXssNull.Checked;
            this.txtSql.Enabled = !this.chbSqlNull.Checked;
        }

	    protected void btnXssDetect_Click(object sender, EventArgs e)
		{
            try
            {
                string testInputParam = !chbXssNull.Checked ? txtXss.Text : null;

                testInputParam.DetectXss();

                ltrText.Text = string.Format("XSS injections NOT found in : {0}", HttpUtility.HtmlEncode(testInputParam));
            }
            catch (DetectorInputDataException ex)
            {
                ltrText.Text = string.Format("<b>XSS injection found :</b><br/> {0}", CreateMessageFromException(ex));
            }
            catch (NullInputDataException ex)
            {
                //ltrText.Text = HttpUtility.HtmlEncode(string.Format("NULL input value found.\n {0}", CreateMessageFromException(ex)));
                ltrText.Text = string.Format("<b>NULL input value found :</b><br/> {0}", CreateMessageFromException(ex));
            }
            finally
            {
                ltrText.Visible = true;
            }

		}

		protected void btnSqlDetect_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbSqlNull.Checked ? txtSql.Text : null;

				testInputParam.DetectSql();

				lblSqlDetect.Text = HttpUtility.HtmlEncode(string.Format("SQL injections not found in: {0}", testInputParam));
			}
			catch (DetectorInputDataException x)
			{
				lblSqlDetect.Text = HttpUtility.HtmlEncode(string.Format("SQL injection found. Engine ID {0}", x.Message));
            }
            catch (NullInputDataException ex)
            {
                lblSqlDetect.Text = HttpUtility.HtmlEncode(string.Format("NULL input value found. Engine ID - {0}", ex.Message));
            }
		}
	}
}