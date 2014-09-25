using System;
using MetraTech.UI.Common;

public partial class Payments_PayFinal : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsPostBack) return;
    var paymentConfirmationData = (MetraPayManager.PaymentConfirmationData)Session["PaymentConfirmationData"];
    switch (paymentConfirmationData.MethodType)
    {
      case MetraPayManager.PaymentMethodType.CreditCard:
        lcType.Label = (string)GetLocalResourceObject("CardType");
        lcNumber.Label = (string)GetLocalResourceObject("CardNumber");
        break;
      case MetraPayManager.PaymentMethodType.ACH:
        lcType.Label = (string)GetLocalResourceObject("BankAccountType");
        lcNumber.Label = (string)GetLocalResourceObject("AccountNumber");
        break;
    }
    lcConfirmationNumber.Text = paymentConfirmationData.ConfirmationNumber;
    lcAmount.Text = paymentConfirmationData.Amount.ToDisplayAmount(UI);
    lcDate.Text = paymentConfirmationData.SchedulePaymentDate.ToShortDateString();
    lcMethod.Text = paymentConfirmationData.Method;
    lcType.Text = ExtensionMethods.GetLocalizedBankAccountType(paymentConfirmationData.Type);
    lcNumber.Text = paymentConfirmationData.Number;
  }
}