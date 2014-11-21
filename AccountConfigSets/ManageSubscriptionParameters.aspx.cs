using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech;
using MetraTech.Domain.AccountConfigurationSets;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Basic.Exception;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;

namespace MetraNet.AccountConfigSets
{
  public partial class ManageSubscriptionParameters : MTPage, ICallbackEventHandler
  {
    public class Udrc
    {
      public int PriceableItemId { get; set; }
      public decimal Value { get; set; }
      public DateTime StartDate { get; set; }
      public DateTime EndDate { get; set; }
      public string RecordId { get; set; }
    }

    protected AccountConfigSetParameters CurrentAccountConfigSetSubscriptionParams;
    protected int CurrentAccountConfigSetSubParamsId;
    protected int CurrentPoId;
    protected string CurrentPoString;

    private Dictionary<int, string> PiNames;

    private string _mode;

    public bool IsViewMode { get { return _mode == "VIEW"; } }

    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);

      ParseRequest();

      if (IsPostBack) return;      
    }

    private void ParseRequest()
    {
      _mode = Request["mode"];
      object title = null;
      switch (_mode)
      {
        case "VIEW":
          CurrentAccountConfigSetSubParamsId = Convert.ToInt32(Request["acsId"]);
          InvokeGetAccountConfigParametersSet();
          LoadAccountConfigSetSubParamsToControls();

          MTbtnGoToUpdateAccountConfigSet.Visible = true;
          title = GetLocalResourceObject("TEXT_MANAGE_ACCOUNTCONFIGSET_PARAMS");
          if (title != null)
            ManageSubscriptionParameterTitle.Text = title.ToString();

          break;
        case "EDIT":
          CurrentAccountConfigSetSubParamsId = Convert.ToInt32(Request["acsId"]);
          if (!IsPostBack)
          {
            InvokeGetAccountConfigParametersSet();
            LoadAccountConfigSetSubParamsToControls();
          }

          MTbtnUpdateAccountConfigSet.Visible = true;
          title = GetLocalResourceObject("TEXT_MANAGE_ACCOUNTCONFIGSET_PARAMS");
          if (title != null)
            ManageSubscriptionParameterTitle.Text = title.ToString();

          break;
        default:
          MTbtnAddAccountConfigSet.Visible = true;

          NewAccountConfigSetSubParams();
          title = GetLocalResourceObject("TEXT_ADD_ACCOUNTCONFIGSET_PARAMS");
          if (title != null)
            ManageSubscriptionParameterTitle.Text = title.ToString();

          break;
      }
    }

    private void NewAccountConfigSetSubParams()
    {
      if (IsPostBack || IsViewMode) return;      
      MTdpSubParamsStartDate.Text = MetraTime.Now.Date.ToString();
    }

    private void LoadAccountConfigSetSubParamsToControls()
    {
      //MTtbSubParamId.Text = CurrentAccountConfigSetSubscriptionParams.AccountConfigSetParametersId.ToString();
      MTtbSubParamsDescription.Text = CurrentAccountConfigSetSubscriptionParams.Description;
      MTtbSubParamsPo.Text = CurrentAccountConfigSetSubscriptionParams.ProductOfferingId.ToString();
      MTdpSubParamsStartDate.Text = CurrentAccountConfigSetSubscriptionParams.StartDate.ToString("d");
      MTdpSubParamsEndDate.Text = CurrentAccountConfigSetSubscriptionParams.EndDate.ToString("d");
      MTisCorpAccountId.Text = CurrentAccountConfigSetSubscriptionParams.CorporateAccountId.ToString();
      MTtbGroupSubscriptionName.Text = CurrentAccountConfigSetSubscriptionParams.GroupSubscriptionName;      
      HiddenPis.Value = EncodePisForHiddenControl(new int[] { CurrentAccountConfigSetSubscriptionParams.ProductOfferingId });
      HiddenUDRCs.Value = EncodeUDRCsForHiddenControl();

      MTtbSubParamsPoName.Text = GetPoName(CurrentAccountConfigSetSubscriptionParams.ProductOfferingId);

      
      MTtbSubParamsDescription.ReadOnly = IsViewMode;
      
      MTdpSubParamsStartDate.ReadOnly = IsViewMode;
      MTdpSubParamsEndDate.ReadOnly = IsViewMode;
      MTisCorpAccountId.ReadOnly = IsViewMode;
      MTtbGroupSubscriptionName.ReadOnly = IsViewMode;
    }

    private void SetCurrentAccountConfigSetSubscriptionParams()
    {
      CurrentAccountConfigSetSubscriptionParams = new AccountConfigSetParameters
      {
        AccountConfigSetParametersId = CurrentAccountConfigSetSubParamsId
      };

      CurrentAccountConfigSetSubscriptionParams.Description = MTtbSubParamsDescription.Text;
      CurrentAccountConfigSetSubscriptionParams.ProductOfferingId = String.IsNullOrEmpty(MTtbSubParamsPo.Text) ? 0 : Convert.ToInt32(MTtbSubParamsPo.Text);
      CurrentAccountConfigSetSubscriptionParams.StartDate = Convert.ToDateTime(MTdpSubParamsStartDate.Text);
      CurrentAccountConfigSetSubscriptionParams.EndDate = String.IsNullOrEmpty(MTdpSubParamsEndDate.Text) ? MetraTime.Max : Convert.ToDateTime(MTdpSubParamsEndDate.Text);
      CurrentAccountConfigSetSubscriptionParams.CorporateAccountId = String.IsNullOrEmpty(MTisCorpAccountId.AccountID) ? 0 : Convert.ToInt32(MTisCorpAccountId.AccountID);
      CurrentAccountConfigSetSubscriptionParams.GroupSubscriptionName = MTtbGroupSubscriptionName.Text;

      CurrentAccountConfigSetSubscriptionParams.UdrcValues = GetUdrcValues();
    }

    private List<UDRCInstanceValue> GetUdrcValues()
    {
      var udrcList = new List<Udrc>();
      if (!string.IsNullOrEmpty(HiddenUDRCs.Value))
      {
        var udrcStrArray = HiddenUDRCs.Value.Replace("[", "").Replace("]", "").Split(new[] { "}," }, StringSplitOptions.None).ToList();
        udrcList.AddRange(udrcStrArray.Select(udrcStr => udrcStr.EndsWith("}") ? udrcStr : udrcStr + "}")
          .Select(udrcStr1 => ExtendedJavaScriptConverter<Udrc>.GetSerializer().Deserialize<Udrc>(udrcStr1)));
      }

      var udrcPrices = new List<UDRCInstanceValue>();
      foreach (var udrc in udrcList)
      {
        var record = new UDRCInstanceValue
          {
            StartDate = udrc.StartDate <= new DateTime() ? MetraTime.Min : udrc.StartDate,
            EndDate = udrc.EndDate <= new DateTime() ? MetraTime.Max : udrc.EndDate,
            Value = udrc.Value,
            UDRC_Id = udrc.PriceableItemId
          };

        udrcPrices.Add(record);
      }

      return udrcPrices;
    }

    private void InvokeGetAccountConfigParametersSet()
    {
      using (var qsc = new AccountConfigurationSetServiceClient())
      {
        if (qsc.ClientCredentials != null)
        {
          qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
          qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        try
        {
          qsc.GetAccountConfigSetSubscriptionParams(CurrentAccountConfigSetSubParamsId, out CurrentAccountConfigSetSubscriptionParams);
        }
        catch (Exception)
        {
          CurrentAccountConfigSetSubscriptionParams = new AccountConfigSetParameters();
        }
      }
    }

    private void ValidateRequest()
    {
      SetCurrentAccountConfigSetSubscriptionParams();

      using (var client = new AccountConfigurationSetServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        List<ErrorObject> errors;
        client.ValidateAccountConfigSetSubscriptionParams(CurrentAccountConfigSetSubscriptionParams, out errors);
      }
    }

    private int InvokeAddAccountConfigSetSubscriptionParams(AccountConfigSetParameters acs)
    {
      int acsId;
      using (var client = new AccountConfigurationSetServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.AddAccountConfigSetSubscriptionParams(acs, out acsId);
      }
      return acsId;
    }

    private void InvokeUpdateAccountConfigSetSubscriptionParams(AccountConfigSetParameters acs)
    {
      using (var client = new AccountConfigurationSetServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.UpdateAccountConfigSetSubscriptionParams(acs);
      }
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
      var value = serializer.Deserialize<Dictionary<string, string>>(eventArgument);
      if (value["poId"] == "-")
      {
        int? items = null;
        result = new { result = "ok", items };
      }
      else
      {
        try
        {
          CurrentPoId = Convert.ToInt32(value["poId"]);
          result = GetPoAndPriceableItemsResult(CurrentPoId.ToString());
        }
        catch (Exception ex)
        {
          Logger.LogError(ex.Message);
          result = new { result = "error", errorMessage = ex.Message };
        }
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

    #endregion

    private string GetPoName(int poId)
    {
      var res = String.Empty;
      try
      {
        using (var client = new ProductOfferingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          ProductOffering po;
          client.GetProductOffering(new PCIdentifier(poId), out po);
          if (po != null)
            res = po.DisplayName;
        }
      }
      catch (Exception)
      {
        
      }
      return res;
    }

    private object GetPoAndPriceableItemsResult(string poId)
    {
      object result;

      try
      {
        var poIds = new List<string> { poId };
        var poIdInt = Convert.ToInt32(poId);
        var poName = GetPoName(poIdInt);

        var priceableItemsAll = GetPriceableItemsForPOs(poIds);
        var items = priceableItemsAll.Items.Select(
            x => new
            {
              PriceableItemId = x.ID,              
              x.Name,
              x.DisplayName,
              PIKind = x.PIKind.ToString(),              
              RatingType = (x.PIKind == PriceableItemKinds.UnitDependentRecurring ? ((Unit_Dependent_Recurring_ChargePIInstance)x).RatingType.ToString() : null)
            }).ToArray();
        result = new { result = "ok", items, poName };
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

          for (var i = 0; i < priceableItems.Items.Count; i++)
          {
            if (priceableItems.Items[i].PIKind == PriceableItemKinds.UnitDependentRecurring)
            {
              BasePriceableItemInstance udrcPi;
              client.GetPIInstanceForPO(new PCIdentifier(poId), new PCIdentifier((int)priceableItems.Items[i].ID), out udrcPi);
              priceableItems.Items[i] = udrcPi;

              priceableItemsAll.Items.Add(priceableItems.Items[i]);
            }
          }
        }
      }
      return priceableItemsAll;
    }

    private string EncodePisForHiddenControl(IEnumerable<int> pos)
    {
      var pis = GetPriceableItemsForPOs(pos.Select(poId => poId.ToString(CultureInfo.InvariantCulture)));

      const string piStr = "{9}'ProductOfferingId':{0},'ProductOfferingName':'{1}','PriceableItemId':{2},'Name':'{3}','DisplayName':'{4}','PIKind':'{5}','PICanICB':'{6}','RatingType':'{7}','RecordId':'{8}'{10}";
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

        string poName = String.Empty;
        hiddenPisValue += string.Format(
              CultureInfo.CurrentCulture,
              piStr,
              pi.PO_ID,
              poName,
              pi.ID,
              pi.Name,
              pi.DisplayName,
              pi.PIKind,
              pi.PICanICB,
              pi.PIKind == PriceableItemKinds.UnitDependentRecurring ? ((Unit_Dependent_Recurring_ChargePIInstance)pi).RatingType : null,
              recordId,
              "{", "},");

        if (!PiNames.ContainsKey(Convert.ToInt32(pi.ID)))
          PiNames.Add(Convert.ToInt32(pi.ID), pi.Name);
      }
      hiddenPisValue = hiddenPisValue.Substring(0, hiddenPisValue.Length - 1);
      return hiddenPisValue + "]";
    }

    private string EncodeUDRCsForHiddenControl()
    {
      const string udrcStr = "{6}'PriceableItemId':{0},'PriceableItemName':'{5}','Value':'{1}','StartDate':'{2}','EndDate':'{3}','RecordId':'{4}'{7}";
      const string recodrIdStr = "{0}_{1}_{2}";

      if (CurrentAccountConfigSetSubscriptionParams == null)
        return String.Empty;

      if (CurrentAccountConfigSetSubscriptionParams.UdrcValues == null)
        return String.Empty;

      if (CurrentAccountConfigSetSubscriptionParams.UdrcValues.Count == 0)
        return String.Empty;

      var hiddenUdrcsValue = "[";
      foreach (var udrc in CurrentAccountConfigSetSubscriptionParams.UdrcValues)
      {
        var recordId = string.Format(
          CultureInfo.CurrentCulture,
          recodrIdStr,
          udrc.UDRC_Id,
          udrc.StartDate.ToString("d"),
          udrc.EndDate.ToString("d")
          );
        string piName = "";
        PiNames.TryGetValue(udrc.UDRC_Id, out piName);
        hiddenUdrcsValue += string.Format(
          CultureInfo.CurrentCulture,
          udrcStr,
          udrc.UDRC_Id,
          Math.Round(udrc.Value, 2),
          udrc.StartDate.ToString("d"),
          udrc.EndDate.ToString("d"),
          recordId,
          piName,
          "{", "},");
      }
      hiddenUdrcsValue = hiddenUdrcsValue.Substring(0, hiddenUdrcsValue.Length - 1);

      return hiddenUdrcsValue + "]";
    }

    #region Buttons click handlers
    protected void btnAddAccountConfigSet_Click(object sender, EventArgs e)
    {
      try
      {
        Page.Validate();
        ValidateRequest();        

        InvokeAddAccountConfigSetSubscriptionParams(CurrentAccountConfigSetSubscriptionParams);
        Response.Redirect(GetRedirectPath(), false);
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

    protected void btnGoToUpdateAccountConfigSet_Click(object sender, EventArgs e)
    {
      var redirectPath = String.Format(@"/MetraNet/AccountConfigSets/ManageSubscriptionParameters.aspx?mode=EDIT&acsId={0}", CurrentAccountConfigSetSubParamsId);
      Response.Redirect(redirectPath, false);
    }

    protected void btnUpdateAccountConfigSet_Click(object sender, EventArgs e)
    {
      try
      {
        Page.Validate();
        ValidateRequest();
        var redirectPath = GetRedirectPath();

        InvokeUpdateAccountConfigSetSubscriptionParams(CurrentAccountConfigSetSubscriptionParams);
        Response.Redirect(GetRedirectPath(), false);       
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
      Response.Redirect(GetRedirectPath(), false);
    }

    private string GetRedirectPath()
    {
      return string.Format(@"/MetraNet/AccountConfigSets/AccountConfigSetSubscriptionParamsList.aspx?t=Frame&f=addSubParamsCallback");
    }

    #endregion
  }

}