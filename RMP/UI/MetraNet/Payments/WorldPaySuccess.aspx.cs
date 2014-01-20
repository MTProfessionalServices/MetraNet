using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.MetraPay.PaymentGateway;
using System.Xml;
using System.Net;
using System.IO;
using System.Text;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;
using CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType;

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
            _strOrderKey = Request.Params["orderKey"] as string;
            _strGuid = _strOrderKey.Substring(_strOrderKey.LastIndexOf("^") + 1, _strOrderKey.Length - _strOrderKey.LastIndexOf('^') - 1 );
            statuslabel.InnerText = _strGuid;

            XmlDocument reply = queryWorldPayforCC();
            extractCCNo(reply);
            statuslabel.InnerText = _strCCNo;
            addPaymentMethod();
        }
        else
            statuslabel.InnerText = "no orderKey sent by worldpay";
    }

    private void addPaymentMethod(){
      RecurringPaymentsServiceClient client = null;

      try
      {
        client = new RecurringPaymentsServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        Guid paymentInstrumentID;
        CreditCardPaymentMethod CreditCard = new CreditCardPaymentMethod();
        CreditCard.CreditCardType = CreditCardType.None;
        CreditCard.AccountNumber = _strGuid;
        CreditCard.SafeAccountNumber = _strCCNo;
        client.AddPaymentMethod(acct, CreditCard, out paymentInstrumentID);
        Response.Redirect("CreditCardList.aspx", false);
        client.Close();
      }
      catch (Exception ex)
      {
        SetError(Resources.ErrorMessages.ERROR_CC_ADD);
        this.Logger.LogError(ex.Message);
        client.Abort();
        throw;
      }
    }
    private void extractCCNo(XmlDocument reply){
        if (reply == null)
        {
            _strCCNo = "";
            return;
        }
        XmlNodeList list = reply.GetElementsByTagName("cardNumber");
        if(list.Count > 0)
        _strCCNo = list.Item(0).InnerText;
    }
    private XmlDocument queryWorldPayforCC() {
        try
        {
            //statuslabel.InnerText = _wpConfig.TemplatesXmlDoc.InnerXml;
            XmlDocument token = WorldPayTokenizer.GetInquiryToken(_wpConfig, _strGuid, false);
            string url = _wpConfig.Url.Value;
            WebRequest request = HttpWebRequest.Create(url);
//            NetworkCredential credentials = new NetworkCredential("METRATECHUSD", "happynewyear12");
          NetworkCredential credentials = _wpConfig.MonitoringCredential;
            request.Credentials = credentials;
            // Set the Method property of the request to POST.
            request.Method = "POST";
            // Create POST data and convert it to a byte array.
            Stream dataStream = request.GetRequestStream();
            // Send token
            token.Save(dataStream);
            // Close the Stream object.
            dataStream.Close();
            // Get the response.
            WebResponse response = request.GetResponse();
            // Display the status.
            // Get the stream containing content returned by the server.
            dataStream = response.GetResponseStream();
            // Open the stream using a StreamReader for easy access.
            StreamReader reader = new StreamReader(dataStream);
            // Read the content.
            string responseFromServer = reader.ReadToEnd();
            // Display the content.
            // Clean up the streams.
            reader.Close();
            dataStream.Close();
            response.Close();
            XmlDocument responseDoc = new XmlDocument();
            responseDoc.LoadXml(responseFromServer);
            return responseDoc;
        }catch(Exception E){
            statuslabel.InnerText = "exception in redirect method : " + E.Message ;
            return null;
    }

    }

}