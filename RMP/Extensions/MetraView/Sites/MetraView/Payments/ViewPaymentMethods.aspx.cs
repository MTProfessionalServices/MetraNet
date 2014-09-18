using System;
using System.IO;
using MetraTech.UI.Common;
using MetraTech.Xml;
using RCD = MetraTech.Interop.RCD;

public partial class Payments_ViewPaymentMethods : MTPage
{
  private static string m_gatewayName;

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
      SetError((string) GetLocalResourceObject("TEXT_ERROR_MSG"));
      return;
    }
    if (Request.Params["paymentStatus"] == "REFUSED")
    {
      SetError((string) GetLocalResourceObject("PAYMENT_METHOD_REFUSED"));
      return;
    }

    if (IsPostBack) return;
    // If MetraPay is not installed, the Add payment method buttons won't be displayed.
    RCD.IMTRcd rcd = new RCD.MTRcd();
    var paymentSvrClientExtFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvrClient\config\extension.xml");
    MetraPayIsInstalled = File.Exists(paymentSvrClientExtFile) ? 1 : 0;
    //Cards are editable by default, to allow backwards compatibility with existing gateway files.
    //If there is no gateway file, make everything editable, again to ensure backwards compatibility.
    CreditCardsAreEditable = true;
    AchAccountsAreEditable = true;

    var configFile = Path.Combine(rcd.ExtensionDir, "PaymentSvr\\config\\Gateway\\Gateway.xml");
    if (!File.Exists(configFile))
      return;

    var doc = new MTXmlDocument();
    if (doc.GetNodeValueAsString("/configuration/creditCardsAreEditable", "true") == "false")
    {
      CreditCardsAreEditable = false;
    }

    if (doc.GetNodeValueAsString("/configuration/achAccountsAreEditable", "true") == "false")
    {
      AchAccountsAreEditable = false;
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

  #region Private methods

  /// <summary>
  /// This is a placeholder for a real gateway selection algorithm if we ever get into a situation
  /// where we need to choose gateways based on some sort of criteria.
  /// </summary>
  private string SelectGateway()
  {
    if (m_gatewayName == null)
    {
      try
      {
        RCD.IMTRcd rcd = new RCD.MTRcd();
        var configFile = Path.Combine(rcd.ExtensionDir, "PaymentSvr\\config\\Gateway\\Gateway.xml");
        var doc = new MTXmlDocument();
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

  #endregion
}