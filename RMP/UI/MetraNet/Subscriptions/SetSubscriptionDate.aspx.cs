using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;
using PropertyType = MetraTech.DomainModel.Enums.Core.Global.PropertyType;
using MetraNet.Models;

public partial class Subscriptions_SetSubscriptionDate : MTPage
{
  public Subscription SubscriptionInstance
  {
    get { return ViewState["SubscriptionInstance"] as Subscription; }
    set { ViewState["SubscriptionInstance"] = value; }
  }

  public Dictionary<string, SpecCharacteristicValueModel> SpecValues
  {
    get { return Session["SpecValues"] as Dictionary<string, SpecCharacteristicValueModel>; }
    set { Session["SpecValues"] = value; }
  }

  protected string FormatDateMessage(DateTime? startDate, DateTime? endDate)
  {
    string msg = Resources.Resource.TEXT_SUB_DATE_MESSAGE_START;

    if (startDate.HasValue)
    {
      msg += " " + Resources.Resource.TEXT_AFTER + " " + startDate.Value.ToShortDateString();
    }

    if (startDate.HasValue && endDate.HasValue)
    {
      msg += " " + Resources.Resource.TEXT_AND;
    }

    if (endDate.HasValue)
    {
      msg += " " + Resources.Resource.TEXT_BEFORE + " " + endDate.Value.ToShortDateString();
    }

    return msg;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      SpecValues = new Dictionary<string, SpecCharacteristicValueModel>();
      SubscriptionInstance = PageNav.Data.Out_StateInitData["SubscriptionInstance"] as Subscription;

      if (SubscriptionInstance != null)
      {
        LblMessage.Text = FormatDateMessage(SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate,
                                            SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate);

        // validate date range client side in Ext
        StartDate.Options += String.Format(",minValue:'{0}',maxValue:'{1}'", 
                                            SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate,
                                            SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate);

        EndDate.Options += String.Format(",minValue:'{0}',maxValue:'{1}',compareValue:'{2}'",
                                            SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate,
                                            SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate,
                                            DateTime.Today);

        if (SubscriptionInstance.SubscriptionSpan.StartDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod)
        {
          cbStartNextBillingPeriod.Checked = true;
        }

        if (SubscriptionInstance.SubscriptionSpan.EndDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod)
        {
          cbEndNextBillingPeriod.Checked = true;
        }

        // if subscription dates are null default them to the effective dates on the PO
        if(SubscriptionInstance.SubscriptionSpan.StartDate == null)
        {
          SubscriptionInstance.SubscriptionSpan.StartDate = ApplicationTime;
          //SubscriptionInstance.SubscriptionSpan.StartDate = SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate;
        }

        if (SubscriptionInstance.SubscriptionSpan.EndDate == null)
        {
          SubscriptionInstance.SubscriptionSpan.EndDate = SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate;
        }

        // Bind Subscription Properties
        SpecCharacteristicsBinder.BindProperties(pnlSubscriptionProperties, 
          SubscriptionInstance, this, SpecValues);
      }

      if (!MTDataBinder1.DataBind())
      {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
      else
      {
          // SECENG: Added HTML encoding
          lblDisplayName.Text = Utils.EncodeForHtml(lblDisplayName.Text);
          lblDescDispName.Text = Utils.EncodeForHtml(lblDescDispName.Text);
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (!Page.IsValid) return;

    MTDataBinder1.Unbind();

    if (cbStartNextBillingPeriod.Checked)
    {
      SubscriptionInstance.SubscriptionSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
    }

    if (cbEndNextBillingPeriod.Checked)
    {
      SubscriptionInstance.SubscriptionSpan.EndDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
    }

    // Unbind Subscription Properties
    var charVals = new List<CharacteristicValue>();
    SpecCharacteristicsBinder.UnbindProperies(charVals, pnlSubscriptionProperties, SpecValues);
    SubscriptionInstance.CharacteristicValues = charVals;

    SubscriptionsEvents_OKSetSubscriptionDate_Client update = new SubscriptionsEvents_OKSetSubscriptionDate_Client();
    update.In_SubscriptionInstance = SubscriptionInstance;
    update.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(update);
  }


  protected void btnCancel_Click(object sender, EventArgs e)
  {
    SubscriptionsEvents_CancelSubscriptions_Client cancel = new SubscriptionsEvents_CancelSubscriptions_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }
}