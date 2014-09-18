using System;
using MetraTech.UI.Common;

public partial class Payments_ReviewPayment : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsPostBack) return;
    var paymentData = (MetraPayManager.MakePaymentData) Session["MakePaymentData"];
    // if session information is missing - go to the very beginning.
    if (paymentData == null)
    {
      Response.Redirect("MakePayment.aspx");
    }

// ReSharper disable PossibleNullReferenceException
    switch (paymentData.MethodType)
// ReSharper restore PossibleNullReferenceException
    {
      case MetraPayManager.PaymentMethodType.CreditCard:
        lcType.Label = (string) GetLocalResourceObject("CardType");
        lcNumber.Label = (string) GetLocalResourceObject("CardNumber");
        break;
      case MetraPayManager.PaymentMethodType.ACH:
        lcType.Label = (string) GetLocalResourceObject("BankAccountType");
        lcNumber.Label = (string) GetLocalResourceObject("AccountNumber");
        break;
    }
    lcAmount.Text = paymentData.Amount.ToDisplayAmount(UI);
    lcDate.Text = paymentData.SchedulePaymentDate.ToShortDateString();
    lcMethod.Text = paymentData.Method;
    lcType.Text = ExtensionMethods.GetLocalizedBankAccountType(paymentData.Type);
    lcNumber.Text = HideNumber(paymentData.Number);
  }

  protected void btnNext_Click(object sender, EventArgs e)
  {
    try
    {
      var metraPayManger = new MetraPayManager(UI);
      var paymentData = (MetraPayManager.MakePaymentData) Session["MakePaymentData"];
      var confirmationData = metraPayManger.MakePayment(paymentData);
      Session["PaymentConfirmationData"] = confirmationData;
      Session["MakePaymentData"] = null; //clear it so nobody pays more than once
      Response.Redirect("PayFinal.aspx", false);
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_MAKE_PAYMENT);
      Logger.LogException("Unable to make a payment", ex);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(String.Format("{0}/", Request.ApplicationPath));
  }

  #region Private methods
  
  /// <summary>
  /// This method masks the input number string only showing the last 4 characters. All other characters are masked with * character.
  /// </summary>
  /// <param name="number"></param>
  /// <returns></returns>
  protected string HideNumber(string number)
  {
    if (String.IsNullOrEmpty(number))
      return String.Empty;
    if (number.Length <= 4)
      return number;
    var hiddenString = number.Substring(number.Length - 4).PadLeft(number.Length, '*');
    return hiddenString;
  }

  #endregion
}