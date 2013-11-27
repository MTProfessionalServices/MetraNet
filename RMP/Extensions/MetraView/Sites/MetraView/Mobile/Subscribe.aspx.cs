using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
public partial class Mobile_Subscribe : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string resultSuccess = "{ \"success\": \"true\", \"errorMessage\" : \"\"}";
        string resultFailed = "{ \"success\": \"false\", \"errorMessage\" : \"%%ERROR_MESSAGE%%\" }";

        try
        {
            BillManager billManager = new BillManager(UI);

            Subscription sub = new Subscription();
            int poId = Convert.ToInt32(Request["poid"]);

            sub.ProductOfferingId = poId;
            sub.SubscriptionSpan = new ProdCatTimeSpan();
            sub.SubscriptionSpan.StartDate = MetraTime.Now;

            List<UDRCInstance> udrcInstanceColl = new List<UDRCInstance>();
            udrcInstanceColl = billManager.GetUDRCInstancesForPO(poId);

            if ((udrcInstanceColl != null) && (udrcInstanceColl.Count > 0))
            {
                List<UDRCInstanceValue> udrcValuesList = new List<UDRCInstanceValue>();
                UDRCInstanceValue udrcVal = new UDRCInstanceValue();
                udrcVal.StartDate = MetraTime.Now;
                udrcVal.Value = udrcInstanceColl[0].MinValue;
                udrcVal.UDRC_Id = udrcInstanceColl[0].ID;
                udrcValuesList.Add(udrcVal);
                sub.UDRCValues = new Dictionary<string, List<UDRCInstanceValue>>();
                sub.UDRCValues.Add(udrcInstanceColl[0].ID.ToString(), udrcValuesList);
            }
            billManager.AddSubscription(sub);

            Response.Write(resultSuccess);
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            string message = "";
            foreach (string msg in fe.Detail.ErrorMessages)
            {
                message += msg + " ";
            }
            Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", message));
        }
        catch (Exception ex)
        {
            Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", ex.Message));
            Logger.LogError(ex.Message);
        }
    }
}
