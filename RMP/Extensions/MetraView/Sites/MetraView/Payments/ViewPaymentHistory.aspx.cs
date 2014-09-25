using System;
using MetraTech.UI.Common;

public partial class Payments_ViewPaymentHistory : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.Subscriber.SelectedAccount == null)
    {
      SetError((string)GetLocalResourceObject("TEXT_ERROR_MSG"));
    }
  }
}
