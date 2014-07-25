using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class Payments_ReviewPayment : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      MetraPayManager.MakePaymentData paymentData = (MetraPayManager.MakePaymentData)Session["MakePaymentData"];
      // if session information is missing - go to the very beginning.
      if (paymentData == null) Response.Redirect("MakePayment.aspx");

      if (paymentData.MethodType == MetraPayManager.PaymentMethodType.CreditCard)//CreditCard
      {
        lcType.Label = (string)GetLocalResourceObject("CardType");
        lcNumber.Label = (string)GetLocalResourceObject("CardNumber");
      }
      else if (paymentData.MethodType == MetraPayManager.PaymentMethodType.ACH)
      {
        lcType.Label = (string)GetLocalResourceObject("BankAccountType");
        lcNumber.Label = (string)GetLocalResourceObject("AccountNumber");
      }
      lcAmount.Text = paymentData.Amount.ToDisplayAmount(UI);
      lcDate.Text = paymentData.SchedulePaymentDate.ToShortDateString();
      lcMethod.Text = paymentData.Method;
      lcType.Text = ExtensionMethods.GetLocalizedBankAccountType(paymentData.Type);
      lcNumber.Text = HideNumber(paymentData.Number);
    }
  }
    
    // This method masks the input number string only showing the last 4 characters. All other characters are masked with * character.
    protected string HideNumber(string number)
    {
        if (String.IsNullOrEmpty(number))
            return String.Empty;
        if (number.Length <= 4)
            return number;
        string hiddenString = number.Substring(number.Length - 4).PadLeft(number.Length, '*');
        return hiddenString;
    }
    
protected void btnNext_Click(object sender, EventArgs e)
  {
    try
    {
      MetraPayManager metraPayManger = new MetraPayManager(UI);
      MetraPayManager.MakePaymentData paymentData = (MetraPayManager.MakePaymentData)Session["MakePaymentData"];
      MetraPayManager.PaymentConfirmationData confirmationData = metraPayManger.MakePayment(paymentData);
      Session["PaymentConfirmationData"] = confirmationData;
      Session["MakePaymentData"] = null; //clear it so nobody pays more than once
      Response.Redirect("PayFinal.aspx", false);
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_MAKE_PAYMENT);
      this.Logger.LogException("Unable to make a payment", ex);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(String.Format("{0}/",Request.ApplicationPath));
  }

}
