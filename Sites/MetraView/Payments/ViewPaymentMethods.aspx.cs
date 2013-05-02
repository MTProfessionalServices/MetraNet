using System;
using System.IO;
using System.Globalization;
using System.Threading;
using System.Web.Security;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.MetraPay;
using MetraTech.UI.Common;
using MetraTech.Xml;
using RCD = MetraTech.Interop.RCD;
using MetraTech.Interop.MTAuth;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.ActivityServices.Common;

public partial class Payments_ViewPaymentMethods : MTPage
{
  protected int? MetraPayIsInstalled
  {
    get { return ViewState["MetraPayIsInstalled"] as int?; }
    set { ViewState["MetraPayIsInstalled"] = value; }
  }

  protected bool? CreditCardsAreEditable
  {
    get { return ViewState["CreditCardsAreEditable"] as bool?; }
    set { ViewState["CreditCardsAreEditable"] = value; }
  }

    protected bool? AchAccountsAreEditable
  {
    get { return ViewState["AchAccountsAreEditable"] as bool?; }
    set { ViewState["AchAccountsAreEditable"] = value; }
  }

  private static string m_gatewayName = null;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.Subscriber.SelectedAccount == null)
    {
      SetError((string)GetLocalResourceObject("TEXT_ERROR_MSG"));
      return;
    }
    if (Request.Params["paymentStatus"] == "REFUSED")
    {
      SetError((string)GetLocalResourceObject("PAYMENT_METHOD_REFUSED"));
      return;
    }

    if (!IsPostBack)
    {
      // If MetraPay is not installed, the Add payment method buttons won't be displayed.
      MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
      string paymentSvrClientExtFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvrClient\config\extension.xml");
      if (File.Exists(paymentSvrClientExtFile))
      {
        MetraPayIsInstalled = 1;
      }
      else
      {
        MetraPayIsInstalled = 0;
      }
      //Cards are editable by default, to allow backwards compatibility with existing gateway files.
      //If there is no gateway file, make everything editable, again to ensure backwards compatibility.
      CreditCardsAreEditable = true;
      AchAccountsAreEditable = true; 

      string configFile = Path.Combine(rcd.ExtensionDir, "PaymentSvr\\config\\Gateway\\Gateway.xml");
      if (!File.Exists(configFile))
        return;

      MTXmlDocument doc = new MTXmlDocument();
      if (doc.GetNodeValueAsString("/configuration/creditCardsAreEditable", "true") == "false")
      {
        CreditCardsAreEditable = false;
      }
      
      if (doc.GetNodeValueAsString("/configuration/achAccountsAreEditable", "true") == "false")
      {
        AchAccountsAreEditable = false;
      }
    }
  }
 

  protected void OnAddACH_Click(object sender, EventArgs e)
  {
    Response.Redirect("ACHAdd.aspx");
  }

  protected void OnAddCreditCard_Click(object sender, EventArgs e)
  {
    Response.Redirect(SelectGateway() + "CreditCardAdd.aspx");
  }

  //This is a placeholder for a real gateway selection algorithm if we ever get into a situation
  //  where we need to choose gateways based on some sort of criteria.
  private string SelectGateway()
  {
    if (m_gatewayName == null)
    {
      try
      {
        RCD.IMTRcd rcd = new RCD.MTRcd();
        string configFile = Path.Combine(rcd.ExtensionDir, "PaymentSvr\\config\\Gateway\\Gateway.xml");
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(configFile);

        m_gatewayName = doc.GetNodeValueAsString("/configuration/name", "");
}
      catch
      {
        m_gatewayName = "";
      }
    }
    return m_gatewayName;
  }
}
