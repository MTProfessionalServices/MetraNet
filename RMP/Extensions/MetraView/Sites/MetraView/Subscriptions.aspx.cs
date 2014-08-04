using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI.WebControls;

using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;


public partial class Subscriptions : MTAccountPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (SiteConfig.Settings.BillSetting.AllowSelfCare == false)
    {
      return;
    }

    Session["ActiveMenu"] = "MySubscriptions";
    if (!IsPostBack)
    {

      try
      {
        var billManager = new BillManager(UI);
        var repository = new SpecCharacteristicRepository(UI);
        MTList<Subscription> subList = new MTList<Subscription>();
        subList = billManager.GetSubscriptions(subList);
 
        MTList<ProductOffering> poList = new MTList<ProductOffering>();
        poList = billManager.GetEligiblePOsForSubscriptions(poList);

        if (subList.Items.Count == 0)
        {
          LitEmptyText.Visible = true;
        }
        else
        {
          StringBuilder mySub = new StringBuilder();
          mySub.Append("<br/><ul class='bullets'>");

          foreach (Subscription sub in subList.Items)
          {
            sub.CharacteristicValues = repository.LoadCharacteristicValuesForEntity((int)sub.SubscriptionId).Items;

            mySub.Append("<li>");
            // SECENG: CORE-4772 CLONE - MSOL BSS 27144 Online Bill - Stored XSS allowed in the priceable item name (post-pb)
            // Added HTML encoding
            mySub.Append(Utils.EncodeForHtml(sub.ProductOffering.DisplayName));
            if (sub.SubscriptionSpan.EndDate < MetraTime.Now)
            {
              mySub.Append("<font color='red'><b>&nbsp;(Past)</b></font>");
            }

            foreach (var v in sub.CharacteristicValues)
            {
              if (v.UserVisible)
              {
                mySub.Append("<br/>");
                mySub.Append(String.Format("<span style='padding-left:20px;'>{0}:  {1}</span>", v.SpecName, v.Value));
                  // TODO: localize specname and value when list
              }
            }
            mySub.Append("</li>");
          }

          mySub.Append("</ul>");
          LitCurrPlan.Text = mySub.ToString();

        }
        
        if (poList.Items.Count > 0)
        {
          foreach (ProductOffering prodOff in poList.Items)
          {
            ListItem poItem = new ListItem();
            if (prodOff.Description != null)
            {
              if (prodOff.DisplayName != null)
              {
                poItem.Text = prodOff.DisplayName + "---" + prodOff.Description.ToString() + "<br/><br/>";
              }
              else
              {
                poItem.Text = prodOff.Name + "---" + prodOff.Description.ToString() + "<br/><br/>"; 
              }
            }
            else
            {
              if (prodOff.DisplayName != null)
              {
                poItem.Text = prodOff.DisplayName + "<br/><br/>";
              }
              else
              {
                poItem.Text = prodOff.Name + "<br/><br/>";
              }
            }

            poItem.Value = prodOff.ProductOfferingId.Value.ToString();
            this.radPoList.Items.Add(poItem);
          }
        }
        else
        {
          EmptyLabel.Visible = true;
          AddButton.Visible = false;
        }

      }
      catch (Exception ex)
      {
        Logger.LogError(ex.Message);
      }
    }

  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    bool submitFlag = true;
    try
    {
      Subscription sub = new Subscription();
      int poId = 0;
      if (radPoList.SelectedIndex >= 0)
      {
        poId = Convert.ToInt32(radPoList.SelectedItem.Value);
      }
      else
      {
        submitFlag = false;
      }

      if (submitFlag)
      {
	    // get the specs for this po
		var repository = new SpecCharacteristicRepository(UI);
		var specs = repository.LoadSpecCharacteristics(poId, true);

		if (specs != null && specs.Count > 0)
		{
		  Session["SubscriptionPropertyPOID"] = poId;
		  Response.Redirect("SubscriptionProperties.aspx", false);
		}
		else
		{
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
      }
     else
      {
        SetError(GetLocalResourceObject("ErrorSelectPO").ToString());
      }

      
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
