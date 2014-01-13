using System;
using System.Collections.Generic;
using System.Text;

using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;


public partial class UserControls_Subscriptions : System.Web.UI.UserControl
{

  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  private int maxDisplayItems = 5;
  public int MaxDisplayItems
  {
    get
    {
      return maxDisplayItems;
    }
    set { maxDisplayItems = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    try
    {
      if (SiteConfig.Settings.BillSetting.AllowSelfCare == false)
      {
        EditButton.Visible = false;
      }

      var billManager = new BillManager(UI);
      MTList<Subscription> subList = new MTList<Subscription>();
      subList = billManager.GetSubscriptions(subList);


      MTList<ProductOffering> poList = new MTList<ProductOffering>();
      poList = billManager.GetEligiblePOsForSubscriptions(poList);
      //poList.PageSize = maxDisplayItems;

      //read into dictionary
      Dictionary<int, ProductOffering> currentPOs = new Dictionary<int, ProductOffering>();
      Dictionary<int, ProductOffering> availablePOs = new Dictionary<int, ProductOffering>();

      foreach (Subscription sub in subList.Items)
      {
        if (!currentPOs.ContainsKey(sub.ProductOffering.ProductOfferingId.Value))
        {
          if (sub.SubscriptionSpan.EndDate == null || sub.SubscriptionSpan.EndDate > MetraTime.Now)
          {
            currentPOs.Add(sub.ProductOffering.ProductOfferingId.Value, sub.ProductOffering);
          }
        }
      }

      foreach (ProductOffering po in poList.Items)
      {
        if (!availablePOs.ContainsKey(po.ProductOfferingId.Value))
        {
          if (!currentPOs.ContainsKey(po.ProductOfferingId.Value))
          {
            availablePOs.Add(po.ProductOfferingId.Value, po);
          }
        }
      }

      if (subList.Items.Count == 0)
      {
        LitEmptyText1.Visible = true;
      }
      else
      {
        StringBuilder myPO = new StringBuilder();
        myPO.Append("<br/><ul class='bullets'>");
        /*
        for (int i = 0; i < subList.Items.Count; i++)
        {
          myPO.Append("<br /><li>");
          myPO.Append(subList.Items[i].ProductOffering.Name);
          myPO.Append("</li>");
        }
        */
        foreach (ProductOffering po in currentPOs.Values)
        {
          myPO.Append("<li>");
          // SECENG: CORE-4772 CLONE - MSOL BSS 27144 Online Bill - Stored XSS allowed in the priceable item name (post-pb)
          // Added HTML encoding
          myPO.Append(Utils.EncodeForHtml(po.DisplayName));
          myPO.Append("</li>");
        }
        myPO.Append("</ul>");
        LitCurrPlan.Text = myPO.ToString();

      }

      
      //if (poList.Items.Count == 0)
      if(availablePOs.Keys.Count == 0)
      {
        LitEmptyText2.Visible = true;
        AddButton.Visible = false;
      }
      else
      {
        LitEmptyText2.Visible = false;
        AddButton.Visible = true;

        StringBuilder prodOfferingList = new StringBuilder();
        prodOfferingList.Append("<ul class=\"bullets\">");

        /*
        for (int i = 0; i < poList.Items.Count; i++)
        {
          string externalUrl = poList.Items[i].ExternalInformationURL.TrimStart();

          if (externalUrl.Length > 1)
          {
            externalUrl = GetLocalResourceObject("HttpUrl").ToString() + Server.UrlEncode(externalUrl);
            prodOfferingList.Append("<li><a href='" + externalUrl + "'" +
                                      "target='_blank' onclick='window.open(this.href);return false''>" +
                                      poList.Items[i].Name + "</a></li>");
          }
          else
          {
            prodOfferingList.Append("<li>" + poList.Items[i].Name + "</li>");
          }
        }
        */

        int maxDisplay = maxDisplayItems;       
        foreach (ProductOffering po in availablePOs.Values)
        {
          if (maxDisplay <= 0)
          {
            break;
          }
          maxDisplay--;

          string externalUrl = po.ExternalInformationURL.TrimStart();

          if (externalUrl.Length > 1)
          {
            externalUrl = GetLocalResourceObject("HttpUrl").ToString() + Server.UrlEncode(externalUrl);
            prodOfferingList.Append("<li><a href='" + externalUrl + "'" +
                                      "target='_blank' onclick='window.open(this.href);return false''>" +
                                      po.DisplayName + "</a></li>");
          }
          else
          {
            prodOfferingList.Append("<li>" + po.DisplayName + "</li>");
          }
        }

        prodOfferingList.Append("</ul>");

        //if (poList.TotalRows > maxDisplayItems)
        if(availablePOs.Values.Count > maxDisplayItems)
        {
          prodOfferingList.Append("<br /><a href='" + SiteConfig.Settings.RootUrl + "/Subscriptions.aspx'>" + Resources.Resource.TEXT_MORE_ITEMS + "</a>");
        }
        LitProdOff.Text = prodOfferingList.ToString();
      }
    }
    catch (Exception)
    {
      // throw new Exception("Unable to get list of subscriptions", ex);
    }
  }

  protected void OnAdd_Click(object sender, EventArgs e)
  {
    Response.Redirect("Subscriptions.aspx");
  }


}
