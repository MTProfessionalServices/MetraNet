using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Text;
using System.IO;
using System.Xml;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.MetraPay.PaymentGateway;
using System.Configuration;
using RCD = MetraTech.Interop.RCD;

public partial class Payments_WorldPayCreditCardAdd : MTPage
{
    protected WorldPayConfig _wpConfig;

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
    protected string getPaymentMask() {

        StringBuilder mask = new StringBuilder();
        mask.Append("<paymentMethodMask>");
        foreach (MaskElement m in _wpConfig.PaymentMethodMasks)
        {
            mask.Append("<include code=" + "\"" + m.Code + "\"/>");
        }
        return mask.ToString();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        LoadConfig();
        string mask = getPaymentMask();
        XmlDocument doc;
        try
        {
            _guid = Guid.NewGuid();
            Decimal amountToPay = 1.00m;
            doc = WorldPayTokenizer.GetAuthorizationToken(_wpConfig, _guid, false, amountToPay);
          
            XmlDocument reply  = Authorize2WorldPay(doc);
            if(PositiveReply(reply))
                Redirect2WorldPay(reply);
            else
                result.InnerText = reply.InnerXml;
        }
        catch (Exception E){ 
            result.InnerText = "Exception:" +  E.Message;
        }

    }
    private Boolean PositiveReply(XmlDocument doc) {
        
        if(doc.GetElementsByTagName("orderStatus").Count > 0 )
            return true;
        return false;
    }

    private bool PayNow
    {
      get
      {
        return !String.IsNullOrEmpty(Request.QueryString["pay"]);
      }
    }

    protected void Redirect2WorldPay(XmlDocument doc){
        if (doc==null)
            return;
        XmlNodeList nlist = doc.GetElementsByTagName("orderStatus");
        foreach (XmlElement order in nlist){
            string strGuid = order.GetAttribute("orderCode");
            string url = order.GetElementsByTagName("reference").Item(0).InnerText;
            
            //We pass two urls to WorldPay, where if the transaction succeeds they go to the success URL, otherwise the failure URL.
            //  localIP is the IP address of the MetraTech server to return to, which the user's browser will be forwarded to.
            //  So it could be the actual server's address, or a load balancer, or possibly "localhost" for testing.
            string localIP = _wpConfig.ReturnIp.Value;
            url += "&successURL=http://" + localIP + Request.ApplicationPath + "/Payments/WorldPaySuccess.aspx?pay=" + (PayNow?"true":"false") +
                     "&failureURL=http://" + localIP + Request.ApplicationPath + "/Payments/ViewPaymentMethods.aspx";
            Response.Redirect(url);                        
        }

    }
    protected XmlDocument Authorize2WorldPay(XmlDocument doc){
        try
        {

            string url = _wpConfig.Url.Value;
            WebRequest request = HttpWebRequest.Create(url);
            NetworkCredential credentials = _wpConfig.MonitoringCredential;
            request.Credentials = credentials;
            // Set the Method property of the request to POST.
            request.Method = "POST";
            // Create POST data and convert it to a byte array.
            Stream dataStream = request.GetRequestStream();
            // Send token
            doc.Save(dataStream);
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
            result.InnerText = doc.InnerXml + "\n\n" + responseFromServer;
            // Clean up the streams.
            reader.Close();
            dataStream.Close();
            response.Close();
            XmlDocument responseDoc = new XmlDocument();
            responseDoc.LoadXml(responseFromServer);
            return responseDoc;
        }catch(Exception E){
            result.InnerText = "exception in redirect method : " + E.Message;
            return null;
        }
    }
    protected void LoadConfig() {
        
        /*RCD.IMTRcd rcd = new RCD.MTRcd();
        ExeConfigurationFileMap map = new ExeConfigurationFileMap();
        map.ExeConfigFilename = Path.Combine(rcd.ExtensionDir, @"PaymentSvr\config\Gateway\WorldPayConfig.xml");

        Configuration config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

        try
        {
            w_Config = (WorldPayConfig)config.GetSection("WorldPayConfig");
            w_Config.ConfigPath = map.ExeConfigFilename.Substring(0, map.ExeConfigFilename.LastIndexOf(@"\") + 1);
            result.InnerText = "w_config : "  + w_Config.MerchantID.Value;
        }
        catch (Exception e)
        {
            string s = e.Message +  " " + e.GetType();
            result.InnerText = "exception : " + s;
            
        }*/

        _wpConfig = WorldPayConfig.GetGlobalInstance();

    }
    
}