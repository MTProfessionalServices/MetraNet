using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Common;

namespace MetraNet.Quoting
{
  public partial class CreateQuote : MTPage, ICallbackEventHandler
  {
    public List<int> Accounts { get; set; }
    public List<int> Pos { get; set; }
    public List<UDRCInstance> UDRCs
    {
      get { return Session["UDRCs"] as List<UDRCInstance>; }
      set { Session["UDRCs"] = value; }
    }
    public Subscription SubscriptionInstance
    {
      get { return Session["SubscriptionInstance"] as Subscription; }
      set { Session["SubscriptionInstance"] = value; }
    }
    public Dictionary<string, MTTemporalList<UDRCInstanceValue>> UDRCDictionary
    {
      get { return Session["UDRCDictionary"] as Dictionary<string, MTTemporalList<UDRCInstanceValue>>; }
      set { Session["UDRCDictionary"] = value; }
    }

    protected string AccountArray;

    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);

      MTdpStartDate.Text = MetraTime.Now.Date.ToString();
      MTdpEndDate.Text = MetraTime.Now.Date.AddMonths(1).ToString();

      #region render Accounts grid

      AccountRenderGrid();
      
      #endregion
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      //var accountsFilterValue = Request["Accounts"];
      //if (String.IsNullOrEmpty(accountsFilterValue)) return;

      //if (accountsFilterValue == "ALL")
      //  QuoteListGrid.DataSourceURL = @"../AjaxServices/LoadQuotesList.aspx?Accounts=ALL";
    }

    #region Implementation of ICallbackEventHandler

    private string _callbackResult = string.Empty;

    /// <summary>
    /// Processes a callback event that targets a control.
    /// </summary>
    /// <param name="eventArgument">A string that represents an event argument to pass to the event handler.</param>
    public void RaiseCallbackEvent(string eventArgument)
    {
      object result = null;
      var serializer = new JavaScriptSerializer();
      var value = serializer.Deserialize<Dictionary<string, string>>(eventArgument);
      var action = value["action"];
      try
      {
        switch (action)
        {
          case "getUDRC":
            {
              var poId = int.Parse(value["poId"]);
              result = GetPriceableItemsWithUdrc(action, poId);
              break;
            }
          case "getICB":
            {
              var poId = int.Parse(value["poId"]);
              result = GetPriceableItemsAllowIcb(action, poId);
              break;
            }
        }
      }
      catch (Exception ex)
      {
        Logger.LogError(ex.Message);
        result = new {result = "error", errorMessage = ex.Message};
      }
      if (result != null)
      {
        _callbackResult = serializer.Serialize(result);
      }
    }

    /// <summary>
    /// Returns the results of a callback event that targets a control.
    /// </summary>
    /// <returns>
    /// The result of the callback.
    /// </returns>
    public string GetCallbackResult()
    {
      return _callbackResult;
    }

    private object GetPriceableItemsWithUdrc(string action, int poId)
    {
      var filter = new MTFilterElement(
        "PIKind", MTFilterElement.OperationType.Equal, (int) PriceableItemKinds.UnitDependentRecurring);
      return GetPriceableItems(action, poId, filter);
    }

    private object GetPriceableItemsAllowIcb(string action, int poId)
    {
      var filter = new MTFilterElement(
        "PICanICB", MTFilterElement.OperationType.Equal, "Y");
      return GetPriceableItems(action, poId, filter);
    }

    private object GetPriceableItems(string action, int poId, MTFilterElement filter)
    {
      object result;
      try
      {
        var priceableItems = new MTList<BasePriceableItemInstance>();
        priceableItems.Filters.Add(filter);

        using (var client = new ProductOfferingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          var pciPoId = new PCIdentifier(poId);
          client.GetPIInstancesForPO(pciPoId, ref priceableItems);
          var items = priceableItems.Items.Select(
            x => new {x.ID, x.Name, x.DisplayName, x.Description, x.PIKind}).ToArray();
          result = new { result = "ok", action, items};
        }
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        result = new { result = "error", errorMessage = ex.Detail.ErrorMessages[0] };
      }
      return result;
    }

    #endregion

    private delegate void AsyncCreateQuote(QuoteRequest request);

    protected void btnGenerateQuote_Click(object sender, EventArgs e)
    {
      try
      {
        Page.Validate();
        ValidateRequest();
        if (!MTCheckBoxViewResult.Checked)  //do async call
        {
          AsyncCreateQuote asynCall = InvokeCreateQuote;
          asynCall.BeginInvoke(RequestForCreateQuote, null, null);
          Response.Redirect(@"/MetraNet/Quoting/QuoteList.aspx?Accounts=ALL", false);
        }
        else
        {
          InvokeCreateQuote(RequestForCreateQuote);
          Response.Redirect(@"/MetraNet/Quoting/QuoteList.aspx?Accounts=ALL", false);
        }
        
      }
      catch (MASBasicException exp)
      {
        SetError(exp.Message);
      }
      catch (Exception exp)
      {
        SetError(exp.Message);
      }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
    }

    private QuoteRequest RequestForCreateQuote { get; set; }

    private void SetQuoteRequestInput()
    {
      RequestForCreateQuote = new QuoteRequest
        {
          QuoteDescription = MTtbQuoteDescription.Text,
          QuoteIdentifier =  MTtbQuoteIdentifier.Text,
          EffectiveDate = Convert.ToDateTime(MTdpStartDate.Text),
          EffectiveEndDate = Convert.ToDateTime(MTdpStartDate.Text),
          ReportParameters = { PDFReport = MTcbPdf.Checked },
          Accounts = Accounts,
          ProductOfferings = Pos
        };

      //RequestForCreateQuote.SubscriptionParameters.UDRCValues = UDRCs;

    }

    private void ValidateRequest()
    {
      if (!string.IsNullOrEmpty(HiddenAccountIds.Value))
        Accounts = HiddenAccountIds.Value.Split(',').Select(int.Parse).ToList();

      //todo read Account Id for group subscription
      //if (!string.IsNullOrEmpty(HiddenGroupId.Value))

      if (!string.IsNullOrEmpty(HiddenPoIdTextBox.Value))
        Pos = HiddenPoIdTextBox.Value.Split(',').Select(int.Parse).ToList();

      SetQuoteRequestInput();

      using (var client = new QuotingServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.ValidateRequest(RequestForCreateQuote);
      }
    }

    private void InvokeCreateQuote(QuoteRequest request)
    {
      using (var client = new QuotingServiceClient())
      {
        QuoteResponse response;
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.CreateQuoteWithoutValidation(request, out response);
      }
    }
      
    private void AccountRenderGrid()
    {
      if (IsPostBack || UI.Subscriber.SelectedAccount == null) return;
      
      var accountsFilterValue = Request["Accounts"];
      if (string.IsNullOrEmpty(accountsFilterValue) || accountsFilterValue != "ONE") return;
      
      var account = UI.Subscriber.SelectedAccount;
      const string currentAccount = "[{6}'_AccountID': {0}, 'AccountStatus': {1}, 'AccountType': '{2}', 'Internal#Folder': {3}, 'IsGroup': {4}, 'UserName': '{5}'{7}]";
      HiddenAccounts.Value = string.Format(
        CultureInfo.CurrentCulture,
        currentAccount,
        account._AccountID,
        (int) account.AccountStatus.GetValueOrDefault(),
        account.AccountType,
        "false",
        0,
        account.UserName,
        "{", "}");
    }
  }
}
