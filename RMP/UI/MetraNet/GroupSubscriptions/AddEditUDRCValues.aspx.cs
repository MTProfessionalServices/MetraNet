using System;
using System.Collections.Generic;
using System.Web.UI;
using MetraTech;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Controls;

public partial class GroupSubscriptions_AddEditUDRCValues : MTPage
{
  public UDRCInstanceValue CurrentUDRCValue
  {
    get { return ViewState["CurrentUDRCValue"] as UDRCInstanceValue; }
    set { ViewState["CurrentUDRCValue"] = value; }
  }

  public GroupSubscription GroupSubscriptionInstance
  {
    get { return ViewState["GroupSubscriptionInstance"] as GroupSubscription; }
    set { ViewState["GroupSubscriptionInstance"] = value; }
  }

  public UDRCInstance CurrentUDRCInstance
  {
    get { return ViewState["CurrentUDRCInstance"] as UDRCInstance; }
    set { ViewState["CurrentUDRCInstance"] = value; }
  }


  protected void Page_Load(object sender, EventArgs e)
  {


    if (!IsPostBack)
    {
      CurrentUDRCValue = PageNav.Data.Out_StateInitData["CurrentUDRCValue"] as UDRCInstanceValue;
      GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;
      CurrentUDRCInstance = PageNav.Data.Out_StateInitData["CurrentUDRCInstance"] as UDRCInstance;

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = CurrentUDRCValue.GetType();
      MTGenericForm1.RenderObjectInstanceName = "CurrentUDRCValue";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.TemplateName = "UDRCValue";
      MTGenericForm1.ReadOnly = false;
      lblSetUDRCValuesTitle.Text = GetLocalResourceObject("UDRCValueUnitName").ToString() +
                                   CurrentUDRCInstance.DisplayName;

      CurrentUDRCValue.StartDate = GroupSubscriptionInstance.SubscriptionSpan.StartDate.Value;
      CurrentUDRCValue.EndDate = GroupSubscriptionInstance.SubscriptionSpan.EndDate.Value;
      CurrentUDRCValue.Value = CurrentUDRCInstance.MinValue;

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
    }

    if (CurrentUDRCInstance.IsIntegerValue)
    {
      MTMessage1.Text = MTMessage1.Text + ((int)CurrentUDRCInstance.MinValue).ToString() +
                        GetLocalResourceObject("Message").ToString() +
                        ((int)CurrentUDRCInstance.MaxValue).ToString();
    }
    else
    {
      MTMessage1.Text = MTMessage1.Text + CurrentUDRCInstance.MinValue.ToString() +
                        GetLocalResourceObject("Message").ToString() + CurrentUDRCInstance.MaxValue.ToString();
    }   
  }
  
  protected void MTDataBinder1_AfterBindControl(MTDataBindingItem Item)
  {
    if (Item.ControlId != "tbValue")
        return;

    if (CurrentUDRCInstance.IsIntegerValue)
    {
      ((MTNumberField)FindControlRecursive(Page, Item.ControlId)).AllowDecimals = false;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Page.Validate();
      MTDataBinder1.Unbind();
      bool okFlag = true;


      if (GroupSubscriptionInstance.UDRCValues == null)
      {
        /*
        if ((CurrentUDRCValue.StartDate != GroupSubscriptionInstance.SubscriptionSpan.StartDate) || (CurrentUDRCValue.EndDate != GroupSubscriptionInstance.SubscriptionSpan.EndDate))
        {
          string errMsg = GetLocalResourceObject("ErrorUDRCInitStartEndDate").ToString();
          SetError(errMsg);
          Logger.LogError(errMsg);
          okFlag = false;
        }
        */
      }

      if ((CurrentUDRCValue.EndDate <= GroupSubscriptionInstance.SubscriptionSpan.StartDate) || (CurrentUDRCValue.EndDate > GroupSubscriptionInstance.SubscriptionSpan.EndDate))
      {
        string errMsg = GetLocalResourceObject("ErrorUDRCEndDate").ToString();
        SetError(errMsg);
        Logger.LogError(errMsg);
        okFlag = false;
      }

      if ((CurrentUDRCValue.StartDate < GroupSubscriptionInstance.SubscriptionSpan.StartDate) || (CurrentUDRCValue.StartDate >= GroupSubscriptionInstance.SubscriptionSpan.EndDate))
      {
        string errMsg = GetLocalResourceObject("ErrorUDRCStartDate").ToString();
        SetError(errMsg);
        Logger.LogError(errMsg);
        okFlag = false;
      }

      if (CurrentUDRCValue.Value == 0)
      {
        string errMsg = GetLocalResourceObject("ErrorUDRCValue").ToString();
        SetError(errMsg);
        Logger.LogError(errMsg);
        okFlag = false;
      }

      if (CurrentUDRCValue.StartDate >= CurrentUDRCValue.EndDate)
      {
        string errMsg = GetLocalResourceObject("ErrorStartEndDates").ToString();
        SetError(errMsg);
        Logger.LogError(errMsg);
        okFlag = false;
      }

      if((CurrentUDRCValue.Value < CurrentUDRCInstance.MinValue) || (CurrentUDRCValue.Value > CurrentUDRCInstance.MaxValue))
      {
        string errMsg = GetLocalResourceObject("ErrorUDRCValue").ToString();
        SetError(errMsg);
        Logger.LogError(errMsg);
        okFlag = false;
      }

      if (okFlag)
      {

        /*if (CurrentUDRCInstance.ChargePerParticipant)
        {
          GroupSubscriptionInstance.UDRCInstances = new List<UDRCInstance>();
          GroupSubscriptionInstance.UDRCInstances.Add(CurrentUDRCInstance);  
        }*/

        Dictionary<string, MTTemporalList<UDRCInstanceValue>> UDRCDictionary =
            new Dictionary<string, MTTemporalList<UDRCInstanceValue>>();

        if (GroupSubscriptionInstance.UDRCValues != null)
        {
          foreach (KeyValuePair<string, List<UDRCInstanceValue>> kvp in GroupSubscriptionInstance.UDRCValues)
          {
            MTTemporalList<UDRCInstanceValue> temporalList =
                new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate");
            foreach (UDRCInstanceValue udrcInstanceValue in kvp.Value)
            {
              temporalList.Add(udrcInstanceValue);
            }
            UDRCDictionary.Add(kvp.Key, temporalList);
          }
        }

        UDRCInstanceValue addValue = new UDRCInstanceValue();
        addValue.UDRC_Id = int.Parse(CurrentUDRCInstance.ID.ToString());
        addValue.Value = CurrentUDRCValue.Value;
        addValue.StartDate = CurrentUDRCValue.StartDate;
        addValue.EndDate = CurrentUDRCValue.EndDate;

        if (!UDRCDictionary.ContainsKey(CurrentUDRCInstance.ID.ToString()))
        {
          UDRCDictionary.Add(CurrentUDRCInstance.ID.ToString(),
                             new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate"));
        }
        UDRCDictionary[CurrentUDRCInstance.ID.ToString()].Add(addValue);

        GroupSubscriptionInstance.UDRCValues = new Dictionary<string, List<UDRCInstanceValue>>();
        foreach (KeyValuePair<string, MTTemporalList<UDRCInstanceValue>> kvp in UDRCDictionary)
        {
          GroupSubscriptionInstance.UDRCValues.Add(kvp.Key, kvp.Value.Items);
        }

        GroupSubscriptionsEvents_OKAddEditUDRCValues_Client okAddEditUdrcValuesClient =
            new GroupSubscriptionsEvents_OKAddEditUDRCValues_Client();
        okAddEditUdrcValuesClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        okAddEditUdrcValuesClient.In_GroupSubscriptionInstance = GroupSubscriptionInstance;
        PageNav.Execute(okAddEditUdrcValuesClient);
      }
    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorAddUDRCValues").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs eventArgs)
  {
    GroupSubscriptionsEvents_CancelAddEditUDRCValues_Client cancelAddEditUdrcValuesClient =
        new GroupSubscriptionsEvents_CancelAddEditUDRCValues_Client();
    cancelAddEditUdrcValuesClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancelAddEditUdrcValuesClient);
  }





}