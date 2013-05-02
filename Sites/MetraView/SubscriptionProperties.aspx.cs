using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI.WebControls;
using MetraNet.Models;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;


public partial class Subscriptions : MTAccountPage
{
  public Dictionary<string, SpecCharacteristicValueModel> SpecValues
  {
    get { return Session["SpecValues"] as Dictionary<string, SpecCharacteristicValueModel>; }
    set { Session["SpecValues"] = value; }
  }
  
  protected void Page_Load(object sender, EventArgs e)
  {
    if (SiteConfig.Settings.BillSetting.AllowSelfCare == false)
    {
      return;
    }

    Session["ActiveMenu"] = "MySubscriptions";
    if (!IsPostBack)
    {
      SpecValues = new Dictionary<string, SpecCharacteristicValueModel>();
      try
      {
          // Bind Subscription Properties
        Subscription sub = new Subscription();
        sub.ProductOfferingId = (int)Session["SubscriptionPropertyPOID"];
        SpecCharacteristicsBinder.BindProperties(pnlSubscriptionProperties, sub, this, SpecValues);
      }
      catch (Exception ex)
      {
        Logger.LogError(ex.Message);
      }
    }

  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
		Subscription sub = new Subscription();
		int poId = (int)Session["SubscriptionPropertyPOID"];

		// Unbind Subscription Properties
		var charVals = new List<CharacteristicValue>();
		SpecCharacteristicsBinder.UnbindProperies(charVals, pnlSubscriptionProperties, SpecValues);
		sub.CharacteristicValues = charVals;
	 
		sub.ProductOfferingId = poId;
		sub.SubscriptionSpan = new ProdCatTimeSpan();
		sub.SubscriptionSpan.StartDate = MetraTime.Now;

		var billManager = new BillManager(UI);
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
		Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString(), false);
      
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      Session[Constants.ERROR] = Resources.ErrorMessages.ERROR_ADD_SUBSCRIPTION;
    }

  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
  }
}
