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

// ReSharper disable SpecifyACultureInStringConversionExplicitly
namespace MetraNet.AccountConfigSets
{
  public partial class ManageAccountConfigSet : MTPage, ICallbackEventHandler
  {
    public class AccountViewPropertyData
    {
      public string AccountView { get; set; }
      public string PropertyName { get; set; }
      public string TypeName { get; set; }
      public Type TypeObj { get; set; }
      public int MaxLength { get; set; }

      public string Id
      {
        get { return String.Format("{0}-{1}", AccountView, PropertyName); }
        set { }
      }
    }

    private List<AccountViewPropertyData> GetAccountViews(out List<string> AccountViewNames)
    {
      using (new HighResolutionTimer("GetAccountViews"))
      {
        var accountViews = Account.GetAllViews();

        AccountViewNames = new List<string>(0);
        var result = new List<AccountViewPropertyData>(0);
        foreach (var aw in accountViews)
        {
          AccountViewNames.Add(aw.ViewName);
          foreach (var propInfo in aw.GetProperties())
          {
            if (propInfo.Name.StartsWith("Is") || propInfo.Name.EndsWith("Dirty") ||
                propInfo.Name.EndsWith("DisplayName") || propInfo.Name.EndsWith("ViewName"))
              continue;
            var t = Nullable.GetUnderlyingType(propInfo.PropertyType) ?? propInfo.PropertyType;
            var newAccountViewPropertyData = new AccountViewPropertyData
              {
                AccountView = aw.ViewName,
                PropertyName = propInfo.Name,
                TypeName = t.Name,
                MaxLength = aw.GetPropertyLength(propInfo.Name)
              };
            result.Add(newAccountViewPropertyData);
          }
        }
        return result.OrderBy(aw => aw.Id).ToList();
      }
    }

    public List<AccountViewPropertyData> AccountViewPropertiesData
    {
      get { return Session["AccountViewPropertiesData"] as List<AccountViewPropertyData>; }
      set { Session["AccountViewPropertiesData"] = value; }
    }

    public List<string> AccountViews
    {
      get { return Session["AccountViews"] as List<string>; }
      set { Session["AccountViews"] = value; }
    }

    public List<AccountConfigSetPropertyValue> SelectionCriteria
    {
      get { return Session["SelectionCriteria"] as List<AccountConfigSetPropertyValue>; }
      set { Session["SelectionCriteria"] = value; }
    }

    public List<AccountConfigSetPropertyValue> PropertiesToSet
    {
      get { return Session["PropertiesToSet"] as List<AccountConfigSetPropertyValue>; }
      set { Session["PropertiesToSet"] = value; }
    }

    protected AccountConfigSet CurrentAccountConfigSet;
    protected AccountConfigSetParameters CurrentAccountConfigSetSubParams;

    private string _mode;

    public bool IsViewMode { get { return _mode == "VIEW"; } }

    protected int CurrentAccountConfigSetId;
    protected int CurrentAccountConfigSetSubParamsId;

    protected Dictionary<int, string> PiNames;

    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);
      
      ParseRequest();      
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
      if (value["subParamsId"] == "-")
        {
          int? items = null;
// ReSharper disable ExpressionIsAlwaysNull
          result = new { result = "ok", items };
// ReSharper restore ExpressionIsAlwaysNull
        }         
      else
      {
        try
        {
          CurrentAccountConfigSetSubParamsId = Convert.ToInt32(value["subParamsId"]);
          result = GetSubscriptionParametersResult();
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

    private object GetSubscriptionParametersResult()
    {
      object result;

      try
      {
        InvokeGetAccountConfigParametersSet();
        if (CurrentAccountConfigSetSubParams.AccountConfigSetParametersId <= 0)
        {
          int? items = null;
          result = new { result = "ok", items };
        }
        else
        {
          var items = new
              {
                CurrentAccountConfigSetSubParams.AccountConfigSetParametersId,
                CurrentAccountConfigSetSubParams.CorporateAccountId,
                CurrentAccountConfigSetSubParams.Description,
                EndDate = CurrentAccountConfigSetSubParams.EndDate.ToString("d"),
                CurrentAccountConfigSetSubParams.GroupSubscriptionName,
                CurrentAccountConfigSetSubParams.ProductOfferingId,
                StartDate = CurrentAccountConfigSetSubParams.StartDate.ToString("d"),
                UDRC = EncodeUDRCsForHiddenControl(CurrentAccountConfigSetSubParams)
              };
          result = new { result = "ok", items };
        }
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
            }
          }

          priceableItemsAll.Items.AddRange(priceableItems.Items);
        }
      }
      return priceableItemsAll;
    }

    #endregion

    #region Buttons click handlers
    protected void btnAddAccountConfigSet_Click(object sender, EventArgs e)
    {
      try
      {
        Page.Validate();
        ValidateRequest();
        var redirectPath = GetRedirectPath();

        InvokeAddAccountConfigSet(CurrentAccountConfigSet);
        Response.Redirect(redirectPath, false);

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
      var redirectPath = String.Format(@"/MetraNet/AccountConfigSets/ManageAccountConfigSet.aspx?mode=EDIT&acsId={0}", CurrentAccountConfigSetId);
      Response.Redirect(redirectPath, false);
    }

    protected void btnUpdateAccountConfigSet_Click(object sender, EventArgs e)
    {
      try
      {
        Page.Validate();
        ValidateRequest();
        var redirectPath = GetRedirectPath();

        InvokeUpdateAccountConfigSet(CurrentAccountConfigSet);
        Response.Redirect(redirectPath, false);
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
      return string.Format(@"/MetraNet/AccountConfigSets/AccountConfigSetList.aspx");
    }
    #endregion

    #region Invoke WCF clients

    private void ValidateRequest()
    {
      SetCurrentAccountConfigSet();

      using (var client = new AccountConfigurationSetServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        List<ErrorObject> errors;
        client.ValidateAccountConfigSet(CurrentAccountConfigSet, out errors);
      }
    }

    private void InvokeAddAccountConfigSet(AccountConfigSet acs)
    {
      using (var client = new AccountConfigurationSetServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        int acsId;
        client.AddAccountConfigSet(acs, out acsId);
      }
    }

    private void InvokeUpdateAccountConfigSet(AccountConfigSet acs)
    {
      using (var client = new AccountConfigurationSetServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.UpdateAccountConfigSet(acs);
      }
    }

    private void InvokeGetAccountConfigSet()
    {
      using (var qsc = new AccountConfigurationSetServiceClient())
      {
        if (qsc.ClientCredentials != null)
        {
          qsc.ClientCredentials.UserName.UserName = UI.User.UserName;
          qsc.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        qsc.GetAccountConfigSet(CurrentAccountConfigSetId, out CurrentAccountConfigSet);
      }
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
          qsc.GetAccountConfigSetSubscriptionParams(CurrentAccountConfigSetSubParamsId, out CurrentAccountConfigSetSubParams);
        }
        catch (Exception)
        {
          CurrentAccountConfigSetSubParams = new AccountConfigSetParameters();
        }
      }
    }

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
      catch
      {

      }
      return res;
    }

    #endregion

    #region Set server side data from controls

    private void SetCurrentAccountConfigSet()
    {
      CurrentAccountConfigSet = new AccountConfigSet
        {
          AcsId = CurrentAccountConfigSetId,
          AcsCreationDate = MetraTime.Now,
          Rank = String.IsNullOrEmpty(MTtbRank.Text) ? 0 : Convert.ToInt32(MTtbRank.Text),
          Enabled = MTcbAcsEnabled.Checked,
          EffectiveDate = Convert.ToDateTime(MTdpStartDate.Text),
          EffectiveEndDate = String.IsNullOrEmpty(MTdpEndDate.Text) ? MetraTime.Max : Convert.ToDateTime(MTdpEndDate.Text),
          Description = MTtbAcsDescription.Text,
          PropertiesToSet = GetPropertyValues(HiddenPropertiesToSet.Value),
          SelectionCriteria = GetPropertyValues(HiddenSelectionCriteria.Value)
        };

      var subParamId = 0;
      if (MTtbSubParamId.Value != "-")
        subParamId = String.IsNullOrEmpty(MTtbSubParamId.Value) ? 0 : Convert.ToInt32(MTtbSubParamId.Value);
      CurrentAccountConfigSet.SubscriptionParamsId = subParamId;
    }

    private List<AccountConfigSetPropertyValue> GetPropertyValues(string value)
    {
      var propertyValueList = new List<AccountConfigSetPropertyValue>();
      if (!string.IsNullOrEmpty(value))
      {
        var propertyValueStrArray = value.Replace("[", "").Replace("]", "").Split(new[] { "}," }, StringSplitOptions.None).ToList();

        propertyValueList.AddRange(propertyValueStrArray.Select(propertyValueStr => propertyValueStr.EndsWith("}") ? propertyValueStr : propertyValueStr + "}")
          .Select(propertyValueStr1 => ExtendedJavaScriptConverter<AccountConfigSetPropertyValue>.GetSerializer().Deserialize<AccountConfigSetPropertyValue>(propertyValueStr1)));
      }

      return propertyValueList;
    }

    #endregion

    #region Process request

    private void ParseRequest()
    {
      _mode = Request["mode"];
      object title;
      switch (_mode)
      {
        case "VIEW":
          CurrentAccountConfigSetId = Convert.ToInt32(Request["acsId"]);
          InvokeGetAccountConfigSet();
          LoadAccountConfigSetToControls();

          MTbtnGoToUpdateAccountConfigSet.Visible = true;
          title = GetLocalResourceObject("TEXT_MANAGE_ACCOUNTCONFIGSET");
          if (title != null)
            ManageAccountConfigSetTitle.Text = title.ToString();

          break;
        case "EDIT":
          CurrentAccountConfigSetId = Convert.ToInt32(Request["acsId"]);
          if (!IsPostBack)
          {
            InvokeGetAccountConfigSet();
            LoadAccountConfigSetToControls();
          }

          MTbtnUpdateAccountConfigSet.Visible = true;
          title = GetLocalResourceObject("TEXT_MANAGE_ACCOUNTCONFIGSET");
          if (title != null)
            ManageAccountConfigSetTitle.Text = title.ToString();

          break;
        default:
          MTbtnAddAccountConfigSet.Visible = true;

          NewAccountConfigSet();
          title = GetLocalResourceObject("TEXT_CREATE_ACCOUNTCONFIGSET");
          if (title != null)
            ManageAccountConfigSetTitle.Text = title.ToString();

          break;
      }
    }
        
    private void NewAccountConfigSet()
    {
      if (IsPostBack || IsViewMode) return;
      
      MTdpStartDate.Text = MetraTime.Now.Date.ToString();

      List<string> accountViews;
      AccountViewPropertiesData = GetAccountViews(out accountViews);
      AccountViews = accountViews;

      HiddenAccountViewPropertyData.Value = EncodeAccountViewPropertiesDataForHiddenControl(AccountViewPropertiesData);
      HiddenAccountViews.Value = EncodeAccountViewForHiddenControl(AccountViews);

    }

    private void LoadAccountConfigSetToControls()
    {
      MTtbAcsDescription.Text = CurrentAccountConfigSet.Description;
      MTtbRank.Text = CurrentAccountConfigSet.Rank.ToString();
      MTcbAcsEnabled.Checked = CurrentAccountConfigSet.Enabled;
      MTdpStartDate.Text = CurrentAccountConfigSet.EffectiveDate.ToString("d");
      MTdpEndDate.Text = CurrentAccountConfigSet.EffectiveEndDate.ToString("d");

      MTtbAcsDescription.ReadOnly = IsViewMode;
      MTtbRank.ReadOnly = IsViewMode;
      MTcbAcsEnabled.ReadOnly = IsViewMode;
      MTdpStartDate.ReadOnly = IsViewMode;
      MTdpEndDate.ReadOnly = IsViewMode;

      HiddenSelectionCriteria.Value = EncodePropertyValueForHiddenControl(CurrentAccountConfigSet.SelectionCriteria);
      HiddenPropertiesToSet.Value = EncodePropertyValueForHiddenControl(CurrentAccountConfigSet.PropertiesToSet);

      if (CurrentAccountConfigSet.SubscriptionParams != null)
      {
        MTPanelSubscriptionParameters.Collapsed = false;
        MTtbSubParamId.Value = CurrentAccountConfigSet.SubscriptionParams.AccountConfigSetParametersId.ToString();
        MTtbSubParamsDescription.Text = CurrentAccountConfigSet.SubscriptionParams.Description;        
        MTdpSubParamsStartDate.Text = CurrentAccountConfigSet.SubscriptionParams.StartDate.ToString("d");
        MTdpSubParamsEndDate.Text = CurrentAccountConfigSet.SubscriptionParams.EndDate.ToString("d");
        MTisCorpAccountId.Text = CurrentAccountConfigSet.SubscriptionParams.CorporateAccountId.ToString();
        MTtbGroupSubscriptionName.Text = CurrentAccountConfigSet.SubscriptionParams.GroupSubscriptionName;
        HiddenUDRCs.Value = EncodeUDRCsForHiddenControl(CurrentAccountConfigSet.SubscriptionParams);

        const string poStrTpl = "{0} ({1})";
        MTtbSubParamsPo.Text = String.Format(poStrTpl, CurrentAccountConfigSet.SubscriptionParams.ProductOfferingId.ToString(),
          GetPoName(CurrentAccountConfigSet.SubscriptionParams.ProductOfferingId));
      }
      else
      {
        MTPanelSubscriptionParameters.Collapsed = true;
      }

      if (!IsViewMode)
      {
        List<string> accountViews;
        AccountViewPropertiesData = GetAccountViews(out accountViews);
        AccountViews = accountViews;

        HiddenAccountViewPropertyData.Value = EncodeAccountViewPropertiesDataForHiddenControl(AccountViewPropertiesData);
        HiddenAccountViews.Value = EncodeAccountViewForHiddenControl(AccountViews);
      }
      else
      {
        MTPanelManageSubscriptionParameters.Visible = false;
      }
    }

    private string EncodeAccountViewPropertiesDataForHiddenControl(List<AccountViewPropertyData> values)
    {
      if (values.Count == 0)
        return String.Empty;
      const string accountStr = "{5}'AccountView': '{0}', 'PropertyName': '{1}', 'TypeName': '{2}', 'MaxLength': '{3}', 'Id': '{4}'{6}";

      var hiddenValue = values.Aggregate("[", (current, val) => current + string.Format(CultureInfo.CurrentCulture, accountStr, val.AccountView, val.PropertyName, val.TypeName, val.MaxLength, val.Id, "{", "},"));
      hiddenValue = hiddenValue.Substring(0, hiddenValue.Length - 1);
      return hiddenValue + "]";
    }

    private string EncodeAccountViewForHiddenControl(List<string> values)
    {
      if (values.Count == 0)
        return String.Empty;
      const string accountStr = "{1}'AccountView': '{0}'{2}";

      var hiddenValue = values.Aggregate("[", (current, val) => current + string.Format(CultureInfo.CurrentCulture, accountStr, val, "{", "},"));
      hiddenValue = hiddenValue.Substring(0, hiddenValue.Length - 1);
      return hiddenValue + "]";
    }

    private string EncodePropertyValueForHiddenControl(List<AccountConfigSetPropertyValue> values)
    {
      if (values.Count == 0)
        return String.Empty;
      const string accountStr = "{3}'AccountView': '{0}', 'Property': '{1}', 'Value': '{2}', 'CriterionId': '{0}-{1}'{4}";

      var hiddenValue = values.Aggregate("[", (current, val) => current + string.Format(CultureInfo.CurrentCulture, accountStr, val.AccountView, val.Property, val.Value, "{", "},"));
      hiddenValue = hiddenValue.Substring(0, hiddenValue.Length - 1);
      return hiddenValue + "]";
    }

    private string EncodeUDRCsForHiddenControl(AccountConfigSetParameters subParams)
    {
      var pis = GetPriceableItemsForPOs(new[] { subParams.ProductOfferingId.ToString() });

      PiNames = new Dictionary<int, string>();
      
      foreach (var pi in pis.Items.Where(pi => !PiNames.ContainsKey(Convert.ToInt32(pi.ID))))
      {
        PiNames.Add(Convert.ToInt32(pi.ID), pi.Name);
      }

      const string udrcStr = "{6}'PriceableItemId':{0},'PriceableItemName':'{5}','Value':'{1}','StartDate':'{2}','EndDate':'{3}','RecordId':'{4}'{7}";
      const string recodrIdStr = "{0}_{1}_{2}";

      if (subParams.UdrcValues == null)
        return String.Empty;

      if (subParams.UdrcValues.Count == 0)
        return String.Empty;

      var hiddenUdrcsValue = "[";
      foreach (var udrc in subParams.UdrcValues)
      {
        var recordId = string.Format(
          CultureInfo.CurrentCulture,
          recodrIdStr,
          udrc.UDRC_Id,
          udrc.StartDate.ToString("d"),
          udrc.EndDate.ToString("d")
          );
        string piName;
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

    #endregion
  }

  public class ExtendedJavaScriptConverter<T> : JavaScriptConverter where T : new()
  {
    public override IEnumerable<Type> SupportedTypes
    {
      get
      {
        return new[] { typeof(T) };
      }
    }

    public override object Deserialize(IDictionary<string, object> dictionary, Type type, JavaScriptSerializer serializer)
    {
      var p = new T();

      var props = typeof(T).GetProperties();

      foreach (var key in dictionary.Keys)
      {
        var prop = props.FirstOrDefault(t => t.Name == key);
        if (prop == null) continue;
        switch (prop.PropertyType.ToString())
        {
          case "System.DateTime":
            prop.SetValue(p, DateTime.Parse(dictionary[key].ToString()), null);
            break;
          case "System.Decimal":
            prop.SetValue(p, Decimal.Parse(dictionary[key].ToString()), null);
            break;
          default:
            prop.SetValue(p, dictionary[key], null);
            break;
        }
      }

      return p;
    }

    public override IDictionary<string, object> Serialize(object obj, JavaScriptSerializer serializer)
    {
      var p = (T)obj;
      IDictionary<string, object> serialized = new Dictionary<string, object>();

      foreach (var pi in typeof(T).GetProperties())
      {
        if (pi.PropertyType == typeof(DateTime))
        {
          serialized[pi.Name] = ((DateTime)pi.GetValue(p, null)).ToString(CultureInfo.CurrentCulture);
        }
        else
        {
          serialized[pi.Name] = pi.GetValue(p, null);
        }

      }

      return serialized;
    }
    public static JavaScriptSerializer GetSerializer()
    {
      var serializer = new JavaScriptSerializer();
      serializer.RegisterConverters(new[] { new ExtendedJavaScriptConverter<T>() });

      return serializer;
    }
  }
}
// ReSharper restore SpecifyACultureInStringConversionExplicitly