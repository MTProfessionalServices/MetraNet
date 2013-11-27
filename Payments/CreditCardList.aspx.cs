using System;
using System.IO;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Xml;
using RCD = MetraTech.Interop.RCD;

public partial class Payments_CreditCardList : MTPage
{
  private static string m_gatewayName = GetGatewayName();

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

  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.Subscriber.SelectedAccount == null)
    {
      SetError(GetLocalResourceObject("SELECT_ACCOUNT_ERROR").ToString());
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
      doc.Load(configFile);

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

  protected static string GetCreditCardLayoutTemplate()
  {
    return m_gatewayName + "CreditCardListLayoutTemplate.xml";
  }

  private static string GetGatewayName()
  {
  
    //This is a placeholder for a real gateway selection algorithm if we ever get into a situation
    //  where we need to choose gateways based on some sort of criteria.
    try
      {
        RCD.IMTRcd rcd = new RCD.MTRcd();
        string configFile = Path.Combine(rcd.ExtensionDir, "PaymentSvr\\config\\Gateway\\Gateway.xml");
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(configFile);

        return doc.GetNodeValueAsString("/configuration/name", "");
      }
      catch 
      {
        return "";
      }
  }
  
  protected static string GetCreditCardPage()
  {
    return m_gatewayName;
  }
}
