using System;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.MetraPay.PaymentGateway;
using System.Xml;
using System.Net;
using System.IO;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;

public partial class Payments_WorldPaySuccess : MTPage
{
  private string _strOrderKey;
  private string _strGuid;
  private string _strCCNo;
  private static WorldPayConfig _wpConfig;

  protected void Page_Load(object sender, EventArgs e)
  {
    _wpConfig = WorldPayConfig.GetGlobalInstance();
    if (Request.Params["orderKey"] != null)
    {
      _strOrderKey = Request.Params["orderKey"];
      _strGuid = _strOrderKey.Substring(_strOrderKey.LastIndexOf("^", StringComparison.Ordinal) + 1,
                                        _strOrderKey.Length - _strOrderKey.LastIndexOf('^') - 1);
      statuslabel.InnerText = _strGuid;

      var reply = QueryWorldPayforCc();
      ExtractCcNo(reply);
      statuslabel.InnerText = _strCCNo;
      var paymentInstrumentId = AddPaymentMethod();
      if (!PayNow)
      {
        Response.Redirect("ViewPaymentMethods.aspx", false);
      }
      else
      {
        var metraPayManger = new MetraPayManager(UI);
        var paymentData = (MetraPayManager.MakePaymentData) Session["MakePaymentData"];
        paymentData.PaymentInstrumentId = paymentInstrumentId.ToString();
        var confirmationData = metraPayManger.MakePayment(paymentData);
        Session["PaymentConfirmationData"] = confirmationData;
        Session["MakePaymentData"] = null; //clear it so nobody pays more than once
        Response.Redirect("PayFinal.aspx", false);
      }
    }
    else
      statuslabel.InnerText = "no orderKey sent by worldpay";
  }

  #region Private methods

  private bool PayNow
  {
    get { return !String.IsNullOrEmpty(Request.QueryString["pay"]); }
  }

  private Guid AddPaymentMethod()
  {
    try
    {
      var acct = UI.Subscriber.SelectedAccount._AccountID == null
                   ? null
                   : new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var metraPayManger = new MetraPayManager(UI);
      var creditCard = new CreditCardPaymentMethod
      {
        CreditCardType = CreditCardType.None,
        AccountNumber = _strGuid,
        SafeAccountNumber = _strCCNo
      };

      return metraPayManger.AddPaymentMethod(acct, creditCard);
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_CC_ADD);
      Logger.LogException("My Exception", ex);
      statuslabel.InnerText = ex.Message;
    }
    //Should never get here.
    return Guid.Empty;
  }

  private void ExtractCcNo(XmlDocument reply)
  {
    if (reply == null)
    {
      _strCCNo = "";
      return;
    }
    var list = reply.GetElementsByTagName("cardNumber");
    if (list.Count <= 0) return;
    var xmlNode = list.Item(0);
    if (xmlNode != null)
      _strCCNo = xmlNode.InnerText;
  }

  private XmlDocument QueryWorldPayforCc()
  {
    try
    {
      var token = WorldPayTokenizer.GetInquiryToken(_wpConfig, _strGuid, false);
      var url = _wpConfig.Url.Value;
      var request = HttpWebRequest.Create(url);
      var credentials = _wpConfig.MonitoringCredential;
      request.Credentials = credentials;
      // Set the Method property of the request to POST.
      request.Method = "POST";
      // Create POST data and convert it to a byte array.
      var dataStream = request.GetRequestStream();
      // Send token
      token.Save(dataStream);
      // Close the Stream object.
      dataStream.Close();
      // Get the response.
      var response = request.GetResponse();
      // Display the status.
      // Get the stream containing content returned by the server.
      dataStream = response.GetResponseStream();
      // Open the stream using a StreamReader for easy access.
      if (dataStream == null) return null;
      var reader = new StreamReader(dataStream);
      // Read the content.
      var responseFromServer = reader.ReadToEnd();
      // Display the content.
      // Clean up the streams.
      reader.Close();
      dataStream.Close();
      response.Close();
      var responseDoc = new XmlDocument();
      responseDoc.LoadXml(responseFromServer);
      return responseDoc;
    }
    catch (Exception E)
    {
      statuslabel.InnerText = "exception in redirect method : " + E.Message;
      return null;
    }
  }

  #endregion
}