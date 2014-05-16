using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.ServiceModel;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Xml.Linq;
using MetraTech;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.RCD;
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

    private string _mode;

    public bool IsViewMode { get { return _mode == "VIEW"; } }

    protected int CurrentQuoteId;

    private Dictionary<int, string> PoNames;
    private Dictionary<int, string> PiNames;

    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);

      ParseRequest();

      if (!IsPostBack)
      {
        // ReSharper disable SpecifyACultureInStringConversionExplicitly
        MTdpStartDate.Text = MetraTime.Now.Date.ToString();
        MTdpEndDate.Text = MetraTime.Now.Date.AddMonths(1).ToString();
        // ReSharper restore SpecifyACultureInStringConversionExplicitly
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
        result = GetPriceableItemsResult(value["poIds"]);
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

    private object GetPriceableItemsResult(IEnumerable<string> poIds)
    {
      object result;

      try
      {
        var priceableItemsAll = GetPriceableItemsForPOs(poIds);
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

    private MTList<BasePriceableItemInstance> GetPriceableItemsForPOs(IEnumerable<string> poIds)
    {
      var priceableItemsAll = new MTList<BasePriceableItemInstance>();
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
      return priceableItemsAll;
    }

    #endregion

    private delegate void AsyncCreateQuote(QuoteRequest request);

    protected void btnGenerateQuote_Click(object sender, EventArgs e)
    {
      try
      {
        Page.Validate();
        ValidateRequest();
        var redirectPath = GetRedirectPath();

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

    protected void btnConvertQuote_Click(object sender, EventArgs e)
    {
      try
      {
        using (var client = new QuotingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.ConvertToSubscription(CurrentQuoteId);
          var redirectPath = GetRedirectPath();
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

    private string GetRedirectPath()
    {
      var accountsFilterValue = Request["Accounts"];
      var param = accountsFilterValue == "ONE" ? string.Empty : "Accounts=ALL";
      return string.Format(@"/MetraNet/Quoting/QuoteList.aspx?{0}", param);
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
          StartDate = udrc.StartDate <= new DateTime() ? MetraTime.Min : udrc.StartDate,
          EndDate = udrc.EndDate <= new DateTime() ? MetraTime.Max : udrc.EndDate,
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
      using (var qsc = new QuotingServiceClient())
      {
        // ReSharper disable PossibleNullReferenceException
        qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
        qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        // ReSharper restore PossibleNullReferenceException

        qsc.GetQuote(CurrentQuoteId, out CurrentQuote);
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
      HiddenPis.Value = EncodePisForHiddenControl(CurrentQuote.ProductOfferings);

      MTCheckBoxIsGroupSubscription.Value = CurrentQuote.GroupSubscription.ToString();
      if (CurrentQuote.GroupSubscription)
        HiddenGroupId.Value = EncodeAccountsForHiddenControl(new List<int> { CurrentQuote.CorporateAccountId });

      HiddenUDRCs.Value = EncodeUDRCsForHiddenControl();
      MTPanelUDRC.Visible = !string.IsNullOrEmpty(HiddenUDRCs.Value);

      HiddenICBs.Value = EncodeICBsForHiddenControl();
      MTPanelICB.Visible = !string.IsNullOrEmpty(HiddenICBs.Value);

      MTbtnGenerateQuote.Visible = false;
      MTbtnConvertQuote.Visible = CurrentQuote.Status == QuoteStatus.Complete;
      MTPanelResult.Visible = true;
      MTPanelLog.Visible = true;

      MTTextBoxControlStatus.Text = CurrentQuote.Status.ToString();
      MTTextBoxControlGroup.Text = CurrentQuote.GroupSubscription ? "Yes" : "No";
      ReportLink.Text = GetReportLink();

      var curDecDig = CultureInfo.CurrentCulture.NumberFormat.CurrencyDecimalDigits;
      var totalAmount = decimal.Round(CurrentQuote.TotalAmount, curDecDig).ToString(CultureInfo.CurrentCulture);
      MTTextBoxControlTotal.Text = string.Format("{0} {1}", totalAmount, CurrentQuote.Currency);
      
      var taxAmount = decimal.Round(CurrentQuote.TotalTax, curDecDig).ToString(CultureInfo.CurrentCulture);
      MTTextBoxControlTax.Text = string.Format("{0} {1}", taxAmount, CurrentQuote.Currency);

      MTMessageFailed.Text = string.Format("{0}: <br/> {1}",
                                           GetLocalResourceObject("QuoteFailed.Label"),
                                           CurrentQuote.FailedMessage);
      MTMessageFailed.Visible = !string.IsNullOrEmpty(CurrentQuote.FailedMessage);
      
      var sb = new MTStringBuilder();
      sb.Append(string.Format("{0}: <br/>", GetLocalResourceObject("QuoteLog.Label")));
      foreach (var rec in CurrentQuote.MessageLog)
        sb.Append(string.Format("{0}: {1} <br/>", rec.DateAdded, rec.Message));
      MTMessageLog.Text = sb.ToString();
      MTMessageLog.Visible = CurrentQuote.MessageLog.Count > 0;
    }

    private string EncodeAccountsForHiddenControl(IEnumerable<int> accounts)
    {
      using (var qsc = new AccountServiceClient())
      {
        // ReSharper disable PossibleNullReferenceException
        qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
        qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        // ReSharper restore PossibleNullReferenceException

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
        // ReSharper disable PossibleNullReferenceException
        qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
        qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        // ReSharper restore PossibleNullReferenceException

        const string poStr = "{2}'Name': '{0}', 'ProductOfferingId': {1}{3}";

        PoNames = new Dictionary<int, string>();

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

          PoNames.Add(Convert.ToInt32(po.ProductOfferingId), po.Name);
        }
        hiddenPosValue = hiddenPosValue.Substring(0, hiddenPosValue.Length - 1);
        return hiddenPosValue + "]";
      }
    }

    private string EncodePisForHiddenControl(IEnumerable<int> pos)
    {
      var pis = GetPriceableItemsForPOs(pos.Select(poId => poId.ToString(CultureInfo.InvariantCulture)));

      const string piStr = "{9}'ProductOfferingId':{0},'ProductOfferingName':'{1}','PriceableItemId':{2},'Name':'{3}','DisplayName':'{4}','Description':'{5}','PIKind':'{6}','PICanICB':'{7}','RecordId':'{8}'{10}";
      const string recodrIdStr = "{0}_{1}";

      PiNames = new Dictionary<int, string>();

      var hiddenPisValue = "[";
      foreach (var pi in pis.Items)
      {
        var recordId = string.Format(
            CultureInfo.CurrentCulture,
            recodrIdStr,
            pi.PO_ID,
            pi.ID);

        string poName;
        PoNames.TryGetValue(Convert.ToInt32(pi.PO_ID), out poName);
        hiddenPisValue += string.Format(
              CultureInfo.CurrentCulture,
              piStr,
              pi.PO_ID,
              poName,
              pi.ID,
              pi.Name,
              pi.DisplayName,
              pi.Description,
              pi.PIKind,
              pi.PICanICB,
              recordId,
              "{", "},");



        if (!PiNames.ContainsKey(Convert.ToInt32(pi.ID)))
          PiNames.Add(Convert.ToInt32(pi.ID), pi.Name);
      }
      hiddenPisValue = hiddenPisValue.Substring(0, hiddenPisValue.Length - 1);
      return hiddenPisValue + "]";
    }

    private string EncodeICBsForHiddenControl()
    {
      const string icbStr = "{8}'ProductOfferingId':{0},'PriceableItemId':{1},'Price':'{2}','BaseAmount':'{3}','UnitValue':'{4}','UnitAmount':'{5}','RecordId':'{6}','GroupId':'{7}'{9}";
      const string recodrIdStr = "{0}_{1}_{2}_{3}_{4}_{5}";

      if (CurrentQuote.IcbPrices.Count == 0)
        return String.Empty;

      var hiddenIcbsValue = "[";
      foreach (var icb in CurrentQuote.IcbPrices)
        foreach (var rate in icb.ChargesRates)
        {
          var recordId = string.Format(
            CultureInfo.CurrentCulture,
            recodrIdStr,
            icb.ProductOfferingId,
            icb.PriceableItemId,
            rate.Price,
            rate.BaseAmount,
            rate.UnitValue,
            rate.UnitAmount
            );
          var groupId = GetGroupId(icb.ProductOfferingId, Convert.ToInt32(icb.PriceableItemId));

          hiddenIcbsValue += string.Format(
            CultureInfo.CurrentCulture,
            icbStr,
            icb.ProductOfferingId,
            icb.PriceableItemId,
            Math.Round(rate.Price, 2),
            Math.Round(rate.BaseAmount, 2),
            Math.Round(rate.UnitValue, 2),
            Math.Round(rate.UnitAmount, 2),
            recordId,
            groupId,
            "{", "},");
        }
      hiddenIcbsValue = hiddenIcbsValue.Substring(0, hiddenIcbsValue.Length - 1);
      return hiddenIcbsValue + "]";

    }

    private string GetGroupId(int poId, int piId)
    {
      const string groupIdStr = "{0}: {1}; {2}: {3}";
      string poName;
      PoNames.TryGetValue(poId, out poName);
      string piName;
      PiNames.TryGetValue(piId, out piName);
      var groupId = string.Format(
        CultureInfo.CurrentCulture,
        groupIdStr,
        GetLocalResourceObject("PONAME"),
        poName,
        GetLocalResourceObject("PINAME"),
        piName
        );
      return groupId;
    }

    private string EncodeUDRCsForHiddenControl()
    {
      const string udrcStr = "{7}'ProductOfferingId':{0},'PriceableItemId':{1},'Value':'{2}','StartDate':'{3}','EndDate':'{4}','RecordId':'{5}','GroupId':'{6}'{8}";
      const string recodrIdStr = "{0}_{1}_{2}_{3}";

      if (CurrentQuote.UdrcValues.Count == 0)
        return String.Empty;

      var hiddenUdrcsValue = "[";
      foreach (var udrc in CurrentQuote.UdrcValues)
      {
        var recordId = string.Format(
          CultureInfo.CurrentCulture,
          recodrIdStr,
          udrc.ProductOfferingId,
          udrc.UDRC_Id,
          udrc.StartDate,
          udrc.EndDate
          );
        var groupId = GetGroupId(udrc.ProductOfferingId, Convert.ToInt32(udrc.UDRC_Id));

        hiddenUdrcsValue += string.Format(
          CultureInfo.CurrentCulture,
          udrcStr,
          udrc.ProductOfferingId,
          udrc.UDRC_Id,
          Math.Round(udrc.Value, 2),
          udrc.StartDate.Date,
          udrc.EndDate.Date,
          recordId,
          groupId,
          "{", "},");
      }
      hiddenUdrcsValue = hiddenUdrcsValue.Substring(0, hiddenUdrcsValue.Length - 1);

      return hiddenUdrcsValue + "]";
    }

    #region PDF
    private XDocument reportFormats = new XDocument();
    private void ReportFormatConfigValidation()
    {
      if (reportFormats.Root != null)
      {
        foreach (XElement format in reportFormats.Root.Elements())
        {
          XAttribute formatType = format.Attribute("type");
          XElement reportImage = format.Element("ReportImage");

          if ((formatType == null) || (string.IsNullOrEmpty(formatType.Value)))
          {
            throw new UIException(Resources.ErrorMessages.ERROR_REPORT_FORMAT);
          }
          if (reportImage == null)
          {
            throw new UIException(Resources.ErrorMessages.ERROR_REPORT_IMAGE);
          }
        }
      }
    }
    private XDocument GetReportFormatConfigFile()
    {
      IMTRcd rcd = new MTRcd();
      string reportFormatFile = String.Empty;

      try
      {
        reportFormatFile = Path.Combine(rcd.ExtensionDir, @"MetraView\Config\ReportFormats.xml");
        reportFormats = XDocument.Load(reportFormatFile);
        ReportFormatConfigValidation();
      }
      catch (Exception exp)
      {
        throw new UIException(String.Format("{0} {1} Details:{2}", Resources.ErrorMessages.ERROR_REPORT_CONFIG, reportFormatFile, exp));
      }
      finally
      {
        Marshal.ReleaseComObject(rcd);
      }
      return reportFormats;
    }

    private string GetReportLink()
    {
      if (CurrentQuote.ReportLink == null)
        return String.Empty;

      List<ReportFile> reports;
      var accId = CurrentQuote.Accounts.First();

      using(var getReportsListClient = new StaticReportsServiceClient())
      {
        try
        {
          // ReSharper disable PossibleNullReferenceException
          getReportsListClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          getReportsListClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          getReportsListClient.GetReportsList(new AccountIdentifier(accId), -1, out reports);
          // ReSharper restore PossibleNullReferenceException
        }
        catch (EndpointNotFoundException)
        {
          //Logger.LogWarning("Unable to get PDF reports. Not able to connect to reporting service. Was reporting extension installed?");
          //Logger.LogWarning("error message was: {0}", Ex.Message);
          return String.Empty;
        }
        catch (Exception exp)
        {
          Logger.LogException("Error getting PDF reports", exp);
          return String.Empty;   // possibly no report server
        }
      }

      if (reports.Count <= 0)
        return String.Empty;
      
      string fileName = String.Format(@"Quote_{1}", accId, CurrentQuote.IdQuote);  //todo read from quotingconfiguration
      var reportFileNameForShowReports = String.Empty;
      foreach (var report in reports.Where(report => report.FileName.Contains(fileName)))
      {
        reportFileNameForShowReports = report.FileName;
        break;
      }

      if (String.IsNullOrEmpty(reportFileNameForShowReports))
        return String.Empty;

      string reportFormat = Path.GetExtension(reportFileNameForShowReports);
      reportFormats = GetReportFormatConfigFile();
      
// ReSharper disable PossibleNullReferenceException
      foreach (XElement format in reportFormats.Root.Elements().Where(format => format.Attribute("type").Value.Equals(reportFormat)))
      {
        return String.Format(
          "<li><a href=\"ShowReports.aspx?report={0}&account={3}\"><img src='{1}'/>PDF report for quote {2}</a></li>",
          Server.UrlEncode(reportFileNameForShowReports),
          format.Element("ReportImage").Value,
          CurrentQuote.IdQuote,
          accId);
      }
// ReSharper restore PossibleNullReferenceException

      return String.Empty;
    }
    #endregion

    private void ParseRequest()
    {
      _mode = Request["mode"];

      switch (_mode)
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
