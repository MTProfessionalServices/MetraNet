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

    public class Icb
    {
      public int PriceableItemId { get; set; }
      public int ProductOfferingId { get; set; }
      public decimal Price { get; set; }
      public decimal UnitValue { get; set; }
      public decimal UnitAmount { get; set; }
      public decimal BaseAmount { get; set; }
      public string RecordId { get; set; }
    }

    public class Udrc
    {
      public int PriceableItemId { get; set; }
      public int ProductOfferingId { get; set; }
      public decimal Value { get; set; }
      public DateTime StartDate { get; set; }
      public DateTime EndDate { get; set; }
      public string GroupId { get; set; }
      public string RecordId { get; set; }
    }

    protected string AccountArray;

    protected Quote CurrentQuote;

    protected string Mode;
    protected int CurrentQuoteId;

    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);

      if (!IsPostBack)
      {
        MTdpStartDate.Text = MetraTime.Now.Date.ToString();
        MTdpEndDate.Text = MetraTime.Now.Date.AddMonths(1).ToString();
      }

      #region render Accounts grid

      AccountRenderGrid();

      #endregion
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
        result = new { result = "error", errorMessage = ex.Message };
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
        var accountsFilterValue = Request["Accounts"];
        var param = accountsFilterValue == "ONE" ? string.Empty : "Accounts=ALL";
        var redirectPath = string.Format(@"/MetraNet/Quoting/QuoteList.aspx?{0}", param);

        if (!MTCheckBoxViewResult.Checked)  //do async call
        {
          AsyncCreateQuote asynCall = InvokeCreateQuote;
          asynCall.BeginInvoke(RequestForCreateQuote, null, null);
          Response.Redirect(redirectPath, false);
        }
        else
        {
          InvokeCreateQuote(RequestForCreateQuote);
          Response.Redirect(redirectPath, false);
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
      if (!string.IsNullOrEmpty(HiddenAccountIds.Value))
        Accounts = HiddenAccountIds.Value.Split(',').Select(int.Parse).ToList();

      if (!string.IsNullOrEmpty(HiddenPoIdTextBox.Value))
        Pos = HiddenPoIdTextBox.Value.Split(',').Select(int.Parse).ToList();

      var isGroupSubscription = Convert.ToBoolean(MTCheckBoxIsGroupSubscription.Value);
      RequestForCreateQuote = new QuoteRequest
        {
          QuoteDescription = MTtbQuoteDescription.Text,
          QuoteIdentifier = MTtbQuoteIdentifier.Text,
          EffectiveDate = Convert.ToDateTime(MTdpStartDate.Text),
          EffectiveEndDate = Convert.ToDateTime(MTdpEndDate.Text),
          ReportParameters = { PDFReport = MTcbPdf.Checked },
          Accounts = Accounts,
          ProductOfferings = Pos,
          IcbPrices = GetIcbPrices(),

          SubscriptionParameters = new SubscriptionParameters
            {
              IsGroupSubscription = isGroupSubscription,
              UDRCValues = GetUdrcPrices()
            }
        };
      if (isGroupSubscription)
        RequestForCreateQuote.SubscriptionParameters.CorporateAccountId = Convert.ToInt32(HiddenGroupId.Value);
    }

    private List<IndividualPrice> GetIcbPrices()
    {
      var icbList = new List<Icb>();
      if (!string.IsNullOrEmpty(HiddenICBs.Value))
      {
        var icbStrArray = HiddenICBs.Value.Replace("[", "").Replace("]", "").Split(new[] { "}," }, StringSplitOptions.None).ToList();
        icbList.AddRange(icbStrArray.Select(icbStr => icbStr.EndsWith("}") ? icbStr : icbStr + "}").Select(icbStr1 => new JavaScriptSerializer().Deserialize<Icb>(icbStr1)));
      }

      var icbPrices = new List<IndividualPrice>();
      foreach (var record in icbList.Select(t => new { t.PriceableItemId, t.ProductOfferingId }).Distinct())
      {
        var record1 = record;
        var chargesRates = icbList.Where(t => t.PriceableItemId == record1.PriceableItemId && t.ProductOfferingId == record1.ProductOfferingId).Select(icb => new ChargesRate
        {
          Price = icb.Price,
          BaseAmount = icb.BaseAmount,
          UnitAmount = icb.UnitAmount,
          UnitValue = icb.UnitValue
        });
        var qip = new IndividualPrice
        {
          CurrentChargeType = ChargeType.RecurringCharge,//TODO investigate this code
          ProductOfferingId = record.ProductOfferingId,
          ChargesRates = chargesRates.ToList(),
          PriceableItemId = record.PriceableItemId
        };

        icbPrices.Add(qip);
      }

      return icbPrices;
    }

    private Dictionary<string, List<UDRCInstanceValue>> GetUdrcPrices()
    {
      var udrcList = new List<Udrc>();
      if (!string.IsNullOrEmpty(HiddenUDRCs.Value))
      {
        var udrcStrArray = HiddenUDRCs.Value.Replace("[", "").Replace("]", "").Split(new[] { "}," }, StringSplitOptions.None).ToList();
        udrcList.AddRange(udrcStrArray.Select(udrcStr => udrcStr.EndsWith("}") ? udrcStr : udrcStr + "}").Select(udrcStr1 => new JavaScriptSerializer().Deserialize<Udrc>(udrcStr1)));
      }

      var udrcPrices = new Dictionary<string, List<UDRCInstanceValue>>();
      foreach (var record in udrcList.Select(t => new { t.ProductOfferingId }).Distinct())
      {
        var record1 = record;
        var uiv = udrcList
          .Where(t => t.ProductOfferingId == record1.ProductOfferingId)
          .Select(udrc => new UDRCInstanceValue
        {
          StartDate = udrc.StartDate <= new DateTime() ? MetraTech.MetraTime.Min : udrc.StartDate,
          EndDate = udrc.EndDate <= new DateTime() ? MetraTech.MetraTime.Max : udrc.EndDate,
          Value = udrc.Value,
          UDRC_Id = udrc.PriceableItemId
        });

        udrcPrices.Add(record1.ProductOfferingId.ToString(CultureInfo.InvariantCulture), uiv.ToList());
      }

      return udrcPrices;
    }

    private void ValidateRequest()
    {
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

    private void LoadQuote()
    {
      var qsc = new QuotingServiceClient();

      try
      {
        qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
        qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        qsc.GetQuote(CurrentQuoteId, out CurrentQuote);
      }


      finally
      {
        if (qsc.State == CommunicationState.Opened)
        {
          qsc.Close();
        }
        else
        {
          qsc.Abort();
        }
      }
    }

    private void LoadQuoteToControls()
    {

      //MTPanelQuoteParameters

      MTtbQuoteDescription.Text = CurrentQuote.QuoteDescription;
      MTtbQuoteIdentifier.Text = CurrentQuote.QuoteIdentifier;
      MTcbPdf.Visible = false;

      MTdpStartDate.Text = CurrentQuote.EffectiveDate.ToString(CultureInfo.InvariantCulture);
      MTdpEndDate.Text = CurrentQuote.EffectiveEndDate.ToString(CultureInfo.InvariantCulture);

      MTtbQuoteDescription.ReadOnly = true;
      MTtbQuoteIdentifier.ReadOnly = true;

      MTdpStartDate.ReadOnly = true;
      MTdpEndDate.ReadOnly = true;

      HiddenAccounts.Value = EncodeAccountsForHiddenControl(CurrentQuote.Accounts);
      
      HiddenPos.Value = EncodePosForHiddenControl(CurrentQuote.ProductOfferings);
      
      MTCheckBoxIsGroupSubscription.Value = CurrentQuote.GroupSubscription.ToString();
      if (CurrentQuote.GroupSubscription)
        HiddenGroupId.Value = EncodeAccountsForHiddenControl(new List<int> {CurrentQuote.CorporateAccountId});

      PutUDRCsInControl();

      PutICBsInControl();

      //todo fill Quote results section

    }

    private string EncodeAccountsForHiddenControl(IEnumerable<int> accounts)
    {
      using (var qsc = new AccountServiceClient())
      {
        qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
        qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        const string accountStr = "{6}'_AccountID': {0}, 'AccountStatus': {1}, 'AccountType': '{2}', 'Internal#Folder': {3}, 'IsGroup': {4}, 'UserName': '{5}'{7}";

        var hiddenAccountsValue = "[";
        foreach (var accountId in accounts)
        {
          Account account;
          qsc.LoadAccount(new AccountIdentifier(accountId), MetraTime.Now, out account);

          hiddenAccountsValue += string.Format(
                CultureInfo.CurrentCulture,
                accountStr,
                account._AccountID,
                (int)account.AccountStatus.GetValueOrDefault(),
                account.AccountType,
                "false",
                0,
                account.UserName,
                "{", "},");
        }
        hiddenAccountsValue = hiddenAccountsValue.Substring(0, hiddenAccountsValue.Length - 1);
        return hiddenAccountsValue + "]";         
      }
    }


    private string EncodePosForHiddenControl(IEnumerable<int> pos)
    {
      using (var qsc = new ProductOfferingServiceClient())
      {
        qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
        qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        const string poStr = "{2}'Name': '{0}', 'ProductOfferingId': {1}{3}";
      
        var hiddenPosValue = "[";
        foreach (var poId in pos)
        {
          ProductOffering po;
          qsc.GetProductOffering(new PCIdentifier(poId), out po);

          hiddenPosValue += string.Format(
                CultureInfo.CurrentCulture,
                poStr,
                po.Name,
                po.ProductOfferingId,
                "{", "},");
        }
        hiddenPosValue = hiddenPosValue.Substring(0, hiddenPosValue.Length - 1);
        return hiddenPosValue + "]";
      }
    }

    private void PutICBsInControl()
    {
      //throw new NotImplementedException();
    }

    private void PutUDRCsInControl()
    {
      //throw new NotImplementedException();
    }

    private void ParseRequest()
    {
      Mode = Request["mode"];


      switch (Mode)
      {
        case "VIEW":
          {
            CurrentQuoteId = Convert.ToInt32(Request["quoteId"]);
            LoadQuote();
            LoadQuoteToControls();

            break;
          }
        case "UPDATE":
          {
            break;
          }
        case "CLONE":
          {
            break;
          }
      }
    }
  }
}
