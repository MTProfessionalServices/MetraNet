using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Validator;
using System.Reflection;

namespace SampleAspNetApp
{
	delegate void del();
	public partial class Validator : System.Web.UI.Page
	{
		public static string CreateMessageFromException(BadInputDataException ex)
		{
			string fullMessage = "1. Problem Id = '{0}';\n 2. Subsystem = '{1}';\n 3. Category = '{2}';\n 4. Message (User will see this text) ="+
								 " '{3}';\n 5. Input data = '{4}';\n 6. Reason = '{5}';\n 7. Event Type = '{6}';";
			return String.Format(fullMessage, 
								ex.Id, ex.SubsystemName,
								ex.CategoryName,
								ex.Message,
								HttpUtility.HtmlEncode(ex.InputData), 
								HttpUtility.HtmlEncode(ex.Reason), 
								ex.EventType);
		}

		protected void Page_Init(object sender, EventArgs e)
		{
			ddlPatterValidator.DataSource =
				SecurityKernel.
				Validator.
				ControlApi.
				Engines.
				Where(p => p.CategoryName == ValidatorEngineCategory.PatternString.ToString()).
				Select(p => p.Id);
			ddlPatterValidator.DataBind();
		}

		protected void Page_PreRender(object sender, EventArgs e)
		{
			this.txtBasicInt.Enabled = !this.chbBasicIntNull.Checked;
			this.txtBasicLong.Enabled = !this.chbBasicLongNull.Checked;
			this.txtBasicDouble.Enabled = !this.chbBasicDoubleNull.Checked;
			this.txtBasicString.Enabled = !this.chbBasicStringNull.Checked;
			this.txtPatternString.Enabled = !this.chbPatternNull.Checked;
			this.txtCcn.Enabled = !this.chbCreditCardNull.Checked;
			this.txtHexString.Enabled = !this.chbHexNull.Checked;
			this.txtPrintableString.Enabled = !this.chbPrintableNull.Checked;
			this.txtDateString.Enabled = !this.chbDateStringNull.Checked;
			this.txtBase64String.Enabled = !this.chbBase64Null.Checked;
		}

		protected void btnBasicIntValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbBasicIntNull.Checked ? txtBasicInt.Text : null;

				int myValue = testInputParam.ValidateAsBasicInt();

				txtOutBasicInt.Text = myValue.ToString();
			}
			catch (NullInputDataException exc)
			{
				txtOutBasicInt.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutBasicInt.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnBasicLongValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbBasicLongNull.Checked ? txtBasicLong.Text : null;

				long myValue = testInputParam.ValidateAsBasicLong();

				txtOutBasicLong.Text = myValue.ToString();
			}
			catch (NullInputDataException exc)
			{
				txtOutBasicLong.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutBasicLong.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnBasicDoubleValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbBasicDoubleNull.Checked ? txtBasicDouble.Text : null;

				double myValue = testInputParam.ValidateAsBasicDouble();

				txtOutbasicDouble.Text = myValue.ToString();
			}
			catch (NullInputDataException exc)
			{
				txtOutbasicDouble.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutbasicDouble.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnBasicStringValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbBasicStringNull.Checked ? txtBasicString.Text : null;

				string myValue = testInputParam.ValidateAsBasicString();

				txtOutBasicString.Text = HttpUtility.HtmlEncode(myValue);
			}
			catch (NullInputDataException exc)
			{
				txtOutBasicString.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutBasicString.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnPatternStringValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbPatternNull.Checked ? txtPatternString.Text : null;

				string myValue = SecurityKernel.Validator.Api.Execute(ddlPatterValidator.SelectedValue, testInputParam);

				txtOutPatternString.Text = HttpUtility.HtmlEncode(myValue);
			}
			catch (NullInputDataException exc)
			{
				txtOutPatternString.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutPatternString.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnCcnValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbCreditCardNull.Checked ? txtCcn.Text : null;

				string myValue = testInputParam.ValidateAsCreditCardNumber();

				txtOutCcn.Text = HttpUtility.HtmlEncode(myValue);
			}
			catch (NullInputDataException exc)
			{
				txtOutCcn.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutCcn.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnHexStringValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbHexNull.Checked ? txtHexString.Text : null;

				string myValue = testInputParam.ValidateAsHexString();

				txtOutHex.Text = HttpUtility.HtmlEncode(myValue);
			}
			catch (NullInputDataException exc)
			{
				txtOutHex.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutHex.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnPrintableStringValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbPrintableNull.Checked ? txtPrintableString.Text : null;

				string myValue = testInputParam.ValidateAsPrintableString();

				txtOutPrintable.Text = HttpUtility.HtmlEncode(myValue);
			}
			catch (NullInputDataException exc)
			{
				txtOutPrintable.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutPrintable.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnDateStringValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbDateStringNull.Checked ? txtDateString.Text : null;

				DateTime myValue = testInputParam.ValidateAsDateString();

				txtOutDate.Text = myValue.ToString();
			}
			catch (NullInputDataException exc)
			{
				txtOutDate.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtOutDate.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}

		protected void btnBase64StringValidate_Click(object sender, EventArgs e)
		{
			try
			{
				string testInputParam = !chbBase64Null.Checked ? txtBase64String.Text : null;

				string myValue = testInputParam.ValidateAsBase64String();

				txtBase64.Text = HttpUtility.HtmlEncode(myValue);
			}
			catch (NullInputDataException exc)
			{
				txtBase64.Text = string.Format("NULL input value found :\n {0}", CreateMessageFromException(exc));
			}
			catch (BadInputDataException ex)
			{
				txtBase64.Text = string.Format("Invalid input data found. {0}", HttpUtility.HtmlEncode(ex.Message));
			}
		}
	}
}