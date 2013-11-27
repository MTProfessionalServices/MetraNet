using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class Payments_PayFinal : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      MetraPayManager.PaymentConfirmationData paymentConfirmationData = (MetraPayManager.PaymentConfirmationData)Session["PaymentConfirmationData"];
      if (paymentConfirmationData.MethodType == MetraPayManager.PaymentMethodType.CreditCard)//CreditCard
      {
        lcType.Label = (string)GetLocalResourceObject("CardType");
        lcNumber.Label = (string)GetLocalResourceObject("CardNumber");
      }
      else if (paymentConfirmationData.MethodType == MetraPayManager.PaymentMethodType.ACH)
      {
        lcType.Label = (string)GetLocalResourceObject("BankAccountType");
        lcNumber.Label = (string)GetLocalResourceObject("AccountNumber");
      }
      lcConfirmationNumber.Text = paymentConfirmationData.ConfirmationNumber; ;
      lcAmount.Text = paymentConfirmationData.Amount.ToDisplayAmount(UI);
      lcDate.Text = paymentConfirmationData.SchedulePaymentDate.ToShortDateString();
      lcMethod.Text = paymentConfirmationData.Method;
      lcType.Text = paymentConfirmationData.Type;
      lcNumber.Text = paymentConfirmationData.Number;
      //lcConfirmationNumber
      //lcAmount
      //lcDate
      //lcMethod
      //lcType
      //lcNumber
    }
  }
}
