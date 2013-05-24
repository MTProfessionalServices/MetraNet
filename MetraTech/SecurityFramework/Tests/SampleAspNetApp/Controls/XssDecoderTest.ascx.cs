using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;

namespace SampleAspNetApp.Controls
{
	public partial class XssDecoderTest : System.Web.UI.UserControl
	{
		/// <summary>
		/// Gets or sets whether the XSS detection is turned on.
		/// </summary>
		[Browsable(true)]
		public bool TestForXss
		{
			get;
			set;
		}

		protected void btnTest_Click(object sender, EventArgs e)
		{
			if (TestForXss)
			{
				try
				{
					SecurityKernel.Processor.Api.ExecuteDefaultByCategory(ProcessorEngineCategory.Xss.ToString(), txtField1.Text);
				}
				catch (BadInputDataException)
				{
					// Hide an exception.
				}

				try
				{
					SecurityKernel.Processor.Api.ExecuteDefaultByCategory(ProcessorEngineCategory.Xss.ToString(), txtField2.Text);
				}
				catch (BadInputDataException)
				{
					// Hide an exception.
				}

				try
				{
					SecurityKernel.Processor.Api.ExecuteDefaultByCategory(ProcessorEngineCategory.Xss.ToString(), txtField3.Text);
				}
				catch (BadInputDataException)
				{
					// Hide an exception.
				}
			}
		}
	}
}