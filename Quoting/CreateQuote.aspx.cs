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
    public Dictionary<string, List<UDRCInstanceValue>> UDRCDictionary
    {
      get { return Session["UDRCDictionary"] as Dictionary<string, List<UDRCInstanceValue>>; }
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
      object result;
      var serializer = new JavaScriptSerializer();
      var value = serializer.Deserialize<Dictionary<string, string[]>>(eventArgument);
      try
      {
        result = GetPriceableItems(value["poIds"]);
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

    private object GetPriceableItems(IEnumerable<string> poIds)
    {
      object result;
      var priceableItemsAll = new MTList<BasePriceableItemInstance>();
      try
      {
        using (var client = new ProductOfferingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          foreach (var poIdStr in poIds)
          {
            var poId = int.Parse(poIdStr);
            var priceableItems = new MTList<BasePriceableItemInstance>();

            var pciPoId = new PCIdentifier(poId);
            client.GetPIInstancesForPO(pciPoId, ref priceableItems);

            priceableItemsAll.Items.AddRange(priceableItems.Items);
          }
        }
        var items = priceableItemsAll.Items.Select(
            x => new
            {
              PriceableItemId = x.ID,
              ProductOfferingId = x.PO_ID,
              x.Name,
              x.DisplayName,
              x.Description,
              x.PIKind,
              x.PICanICB
            }).ToArray();
        result = new { result = "ok", items };
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
          QuoteIdentifier = MTtbQuoteIdentifier.Text,
          EffectiveDate = Convert.ToDateTime(MTdpStartDate.Text),
          EffectiveEndDate = Convert.ToDateTime(MTdpStartDate.Text),
          ReportParameters = { PDFReport = MTcbPdf.Checked },
          Accounts = Accounts,
          ProductOfferings = Pos,
          SubscriptionParameters = new SubscriptionParameters
          {
            IsGroupSubscription = MTCheckBoxIsGroupSubscription.Checked,
            CorporateAccountId = Convert.ToInt32(HiddenGroupId.Value)
          }
        };
      foreach (var udrc in UDRCs)
      {
        //RequestForCreateQuote.SubscriptionParameters.Add(udrc.ID.ToString(), );
      }
      

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
        (int)account.AccountStatus.GetValueOrDefault(),
        account.AccountType,
        "false",
        0,
        account.UserName,
        "{", "}");
    }
  }
}
