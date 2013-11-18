using System;
using System.Net;
using System.Text;
using System.IO;
using System.Xml;
using MetraTech.DomainModel.MetraPay;
using MetraTech.UI.Common;
using MetraTech.MetraPay.PaymentGateway;

public partial class Payments_WorldPayCreditCardAdd : MTPage
{
  protected WorldPayConfig WpConfig;
  private Guid _guid;

  public CreditCardPaymentMethod CreditCard
  {
    get
    {
      if (ViewState["CreditCard"] == null)
      {
        ViewState["CreditCard"] = new CreditCardPaymentMethod();
      }
      return ViewState["CreditCard"] as CreditCardPaymentMethod;
    }
    set { ViewState["CreditCard"] = value; }
  }

  protected string getPaymentMask()
  {
    var mask = new StringBuilder();
    mask.Append("<paymentMethodMask>");
    foreach (MaskElement m in WpConfig.PaymentMethodMasks)
    {
      mask.Append("<include code=" + "\"" + m.Code + "\"/>");
    }
    return mask.ToString();
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    LoadConfig();
    getPaymentMask();
    try
    {
      _guid = Guid.NewGuid();
      const decimal amountToPay = 1.00m;
      var doc = WorldPayTokenizer.GetAuthorizationToken(WpConfig, _guid, false, amountToPay);

      var reply = Authorize2WorldPay(doc);
      if (PositiveReply(reply))
        Redirect2WorldPay(reply);
      else
        result.InnerText = reply.InnerXml;
    }
    catch (Exception exc)
    {
      result.InnerText = "Exception:" + exc.Message;
    }
  }

  private Boolean PositiveReply(XmlDocument doc)
  {
    return doc.GetElementsByTagName("orderStatus").Count > 0;
  }

  private bool PayNow
  {
    get { return !String.IsNullOrEmpty(Request.QueryString["pay"]); }
  }

  protected void Redirect2WorldPay(XmlDocument doc)
  {
    if (doc == null)
      return;

    var nlist = doc.GetElementsByTagName("orderStatus");
    foreach (XmlElement order in nlist)
    {
      order.GetAttribute("orderCode");
      var url = order.GetElementsByTagName("reference").Item(0).InnerText;

      //We pass two urls to WorldPay, where if the transaction succeeds they go to the success URL, otherwise the failure URL.
      //  localIP is the IP address of the MetraTech server to return to, which the user's browser will be forwarded to.
      //  So it could be the actual server's address, or a load balancer, or possibly "localhost" for testing.
      var localIp = WpConfig.ReturnIp.Value;
      url += "&successURL=http://" + localIp + Request.ApplicationPath + "/Payments/WorldPaySuccess.aspx?pay=" +
             (PayNow ? "true" : "false") +
             "&failureURL=http://" + localIp + Request.ApplicationPath + "/Payments/WorldPayFailure.aspx";
        //TODO WorldPayFailure is blank, it should be implemented
      Response.Redirect(url);
    }
  }

  protected XmlDocument Authorize2WorldPay(XmlDocument doc)
  {
    try
    {
      var url = WpConfig.Url.Value;
      var request = HttpWebRequest.Create(url);
      var credentials = WpConfig.MonitoringCredential;
      request.Credentials = credentials;
      // Set the Method property of the request to POST.
      request.Method = "POST";
      // Create POST data and convert it to a byte array.
      var dataStream = request.GetRequestStream();
      // Send token
      doc.Save(dataStream);
      // Close the Stream object.
      dataStream.Close();
      // Get the response.
      var response = request.GetResponse();
      // Display the status.
      // Get the stream containing content returned by the server.
      dataStream = response.GetResponseStream();
      // Open the stream using a StreamReader for easy access.
      var reader = new StreamReader(dataStream);
      // Read the content.
      var responseFromServer = reader.ReadToEnd();
      // Display the content.
      result.InnerText = doc.InnerXml + "\n\n" + responseFromServer;
      // Clean up the streams.
      reader.Close();
      dataStream.Close();
      response.Close();
      XmlDocument responseDoc = new XmlDocument();
      responseDoc.LoadXml(responseFromServer);
      return responseDoc;
    }
    catch (Exception E)
    {
      result.InnerText = "exception in redirect method : " + E.Message;
      return null;
    }
  }

  protected void LoadConfig()
  {
    WpConfig = WorldPayConfig.GetGlobalInstance();
  }
}