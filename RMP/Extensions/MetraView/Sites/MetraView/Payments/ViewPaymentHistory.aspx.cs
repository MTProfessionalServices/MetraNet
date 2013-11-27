using System;
using System.Globalization;
using System.Threading;
using System.Web.Security;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using MetraTech.Interop.MTAuth;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.ActivityServices.Common;

public partial class Payments_ViewPaymentHistory : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.Subscriber.SelectedAccount == null)
    {
      SetError((string)GetLocalResourceObject("TEXT_ERROR_MSG"));
      return;
    }
  }
}
