using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
  [DataContract]
  [Serializable]
  public class BaseProductOffering : BaseObject
  {
    #region ProductOfferingId
    private bool isProductOfferingIdDirty = true;
    private int? m_ProductOfferingId;
    [MTDataMember(Description = "This is the identifier of the product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? ProductOfferingId
    {
      get { return m_ProductOfferingId; }
      set
      {
 
          m_ProductOfferingId = value;
          isProductOfferingIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsProductOfferingIdDirty
    {
      get { return isProductOfferingIdDirty; }
    }
      #endregion

    #region Name
    private bool isNameDirty = true;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Name
    {
      get { return m_Name; }
      set
      {
 
          m_Name = value;
          isNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNameDirty
    {
      get { return isNameDirty; }
    }
    #endregion

    #region DisplayName
    private bool isDisplayNameDirty = true;
    private string m_DisplayName;
    [MTDataMember(Description = "This is the localized display name of the product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DisplayName
    {
      get { return m_DisplayName; }
      set
      {
 
          m_DisplayName = value;
          isDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDisplayNameDirty
    {
      get { return isDisplayNameDirty; }
    }
    #endregion
    
    #region LocalizedDisplayNames
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDisplayNamesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDisplayNames = null;
    [MTDataMember(Description = " This is a collection of localized display names for the product offering.  The collection is keyed by values from the LanguageCode enumeration.  If a value cannot be found for a specific LanguageCode, the value from the DisplayName property should be used as a default.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDisplayNames
    {
      get { return m_LocalizedDisplayNames; }
      set
      {
          m_LocalizedDisplayNames = value;
          isLocalizedDisplayNamesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDisplayNamesDirty
    {
      get { return isLocalizedDisplayNamesDirty; }
    }
    #endregion

    #region Description
    private bool isDescriptionDirty = true;
    private string m_Description;
    [MTDataMember(Description = "This is the description of the product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Description
    {
      get { return m_Description; }
      set
      {
 
          m_Description = value;
          isDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDescriptionDirty
    {
      get { return isDescriptionDirty; }
    }
    #endregion

    #region LocalizedDescriptions
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDescriptionsDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDescriptions = null;
    [MTDataMember(Description = "This is a collection of localized descriptions for the product offering.  The collection is keyed by values from the LanguageCode enumeration.  If a value cannot be found for a specific LanguageCode, the value from the Description property should be used as a default.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDescriptions
    {
      get { return m_LocalizedDescriptions; }
      set
      {
          m_LocalizedDescriptions = value;
          isLocalizedDescriptionsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDescriptionsDirty
    {
      get { return isLocalizedDescriptionsDirty; }
    }
    #endregion

    #region Currency
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCurrencyDirty = false;
    private SystemCurrencies m_Currency;
    [MTDataMember(Description = "This property stores a value from the Currency enumeration to indicate the currency of the product offering.  All priceable items must be in the same currency and subscribers must have the same currency as well. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SystemCurrencies Currency
    {
      get { return m_Currency; }
      set
      {
          m_Currency = value;
          isCurrencyDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCurrencyDirty
    {
      get { return isCurrencyDirty; }
    }
    #endregion

    #region Currency Value Display Name
    public string CurrencyValueDisplayName
    {
      get
      {
        return GetDisplayName(this.Currency);
      }
      set
      {
        this.Currency = ((SystemCurrencies)(GetEnumInstanceByDisplayName(typeof(SystemCurrencies), value)));
      }
    }
    #endregion
    
    #region SelfSubscribable
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSelfSubscribableDirty = false;
    private bool m_SelfSubscribable;
    [MTDataMember(Description = "This flag indicates whether or not users can self-subscribe to this product offering via MetraView. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool SelfSubscribable
    {
      get { return m_SelfSubscribable; }
      set
      {
          m_SelfSubscribable = value;
          isSelfSubscribableDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSelfSubscribableDirty
    {
      get { return isSelfSubscribableDirty; }
    }
    #endregion

    #region SelfUnsubscribable
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSelfUnsubscribableDirty = false;
    private bool m_SelfUnsubscribable;
    [MTDataMember(Description = "This flag indicates whether or not users can self-unsubscribe to this product offering via MetraView. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool SelfUnsubscribable
    {
      get { return m_SelfUnsubscribable; }
      set
      {
          m_SelfUnsubscribable = value;
          isSelfUnsubscribableDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSelfUnsubscribableDirty
    {
      get { return isSelfUnsubscribableDirty; }
    }
    #endregion

    #region SupportedAccountTypes
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSupportedAccountTypesDirty = false;
    private List<string> m_SupportedAccountTypes = new List<string>();
    [MTDataMember(Description = "This property stores a list of account types that can subscribe to this product offering.  If this list is empty, all account types can subscribe to the product offering. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<string> SupportedAccountTypes
    {
      get 
      {
          if (m_SupportedAccountTypes == null)
          {
              m_SupportedAccountTypes = new List<string>();
          }

          return m_SupportedAccountTypes; 
      }
      set
      {
          m_SupportedAccountTypes = value;
          isSupportedAccountTypesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSupportedAccountTypesDirty
    {
      get { return isSupportedAccountTypesDirty; }
    }
    #endregion

    #region PriceableItems
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPriceableItemsDirty = false;
    private List<BasePriceableItemInstance> m_PriceableItems = new List<BasePriceableItemInstance>();
    [MTDataMember(Description = "This is the collection of priceable item instances for the product offering.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<BasePriceableItemInstance> PriceableItems
    {
      get 
      {
          if (m_PriceableItems == null)
          {
              m_PriceableItems = new List<BasePriceableItemInstance>();
          }

          return m_PriceableItems; 
      }
      set
      {
          m_PriceableItems = value;
          isPriceableItemsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPriceableItemsDirty
    {
      get { return isPriceableItemsDirty; }
    }
    #endregion

    #region HasRecurringCharges
    private bool isHasRecurringChargesDirty = true;
    private bool? m_HasRecurringCharges;
    [MTDataMember(Description = "This indicates whether or not the PO has recurring charges", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? HasRecurringCharges
    {
      get { return m_HasRecurringCharges; }
      set
      {
 
          m_HasRecurringCharges = value;
          isHasRecurringChargesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsHasRecurringChargesDirty
    {
      get { return isHasRecurringChargesDirty; }
    }
    #endregion

    #region HasDiscounts
    private bool isHasDiscountsDirty = true;
    private bool? m_HasDiscounts;
    [MTDataMember(Description = "This indicates whether or not the PO has discounts", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? HasDiscounts
    {
      get { return m_HasDiscounts; }
      set
      {
 
          m_HasDiscounts = value;
          isHasDiscountsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsHasDiscountsDirty
    {
      get { return isHasDiscountsDirty; }
    }
    #endregion

    #region HasPersonalRates
    private bool isHasPersonalRatesDirty = true;
    private bool? m_HasPersonalRates;
    [MTDataMember(Description = "This indicates whether or not the PO allows personal rates (ICBs)", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? HasPersonalRates
    {
      get { return m_HasPersonalRates; }
      set
      {
 
          m_HasPersonalRates = value;
          isHasPersonalRatesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsHasPersonalRatesDirty
    {
      get { return isHasPersonalRatesDirty; }
    }
    #endregion

    #region CanUserUnSubscribe
    private bool isCanUserUnsubscribeDirty = true;
    private bool? m_CanUserUnsubscribe;
    [MTDataMember(Description = "This indicates whether or not the user can self-unsubscribe", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? CanUserUnsubscribe
    {
      get { return m_CanUserUnsubscribe; }
      set
      {
 
          m_CanUserUnsubscribe = value;
          isCanUserUnsubscribeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCanUserUnsubscribeDirty
    {
      get { return isCanUserUnsubscribeDirty; }
    }
    #endregion

    #region CanUserSubscribe
    private bool isCanUserSubscribeDirty = true;
    private bool? m_CanUserSubscribe;
    [MTDataMember(Description = "This indicates whether or not the user can self-subscribe", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? CanUserSubscribe
    {
      get { return m_CanUserSubscribe; }
      set
      {
 
          m_CanUserSubscribe = value;
          isCanUserSubscribeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCanUserSubscribeDirty
    {
      get { return isCanUserSubscribeDirty; }
    }
    #endregion

    #region AvailableTimeSpan
    private bool isAvailableTimeSpanDirty = true;
    private ProdCatTimeSpan m_AvailableTimeSpan = new ProdCatTimeSpan();
    [MTDataMember(Description = "This is the span during which the PO is available", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ProdCatTimeSpan AvailableTimeSpan
    {
      get { return m_AvailableTimeSpan; }
      set
      {
 
          m_AvailableTimeSpan = value;
          isAvailableTimeSpanDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAvailableTimeSpanDirty
    {
      get { return isAvailableTimeSpanDirty; }
    }
    #endregion

    #region EffectiveTimeSpan
    private bool isEffectiveTimeSpanDirty = true;
    private ProdCatTimeSpan m_EffectiveTimeSpan = new ProdCatTimeSpan();
    [MTDataMember(Description = "This is the span during which the PO is effective", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ProdCatTimeSpan EffectiveTimeSpan
    {
      get { return m_EffectiveTimeSpan; }
      set
      {
 
          m_EffectiveTimeSpan = value;
          isEffectiveTimeSpanDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEffectiveTimeSpanDirty
    {
      get { return isEffectiveTimeSpanDirty; }
    }
    #endregion

    #region GroupSubscriptionRequiresCycle
    private bool isGroupSubscriptionRequiresCycleDirty = true;
    private bool? m_GroupSubscriptionRequiresCycle;
    [MTDataMember(Description = "This indicates if the group subscription requires a cycle to be specified in order to get subscribed to this PO", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? GroupSubscriptionRequiresCycle
    {
      get { return m_GroupSubscriptionRequiresCycle; }
      set
      {
         m_GroupSubscriptionRequiresCycle = value;
        isGroupSubscriptionRequiresCycleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsGroupSubscriptionRequiresCycleDirty
    {
      get { return isGroupSubscriptionRequiresCycleDirty; }
    }
    #endregion

    #region UsageCycleType
    private bool isUsageCycleTypeDirty = true;
    private int m_UsageCycleType;
    [MTDataMember(Description = "This is the description of the product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int UsageCycleType
    {
      get { return m_UsageCycleType; }
      set
      {

        m_UsageCycleType = value;
        isUsageCycleTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUsageCycleTypeDirty
    {
      get { return isUsageCycleTypeDirty; }
    }
    #endregion

    #region IsHidden
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsHiddenDirty = false;
    private bool m_IsHidden;
    [MTDataMember(Description = "This flag indicates whether the product offering is dirty. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool IsHidden
    {
      get { return m_IsHidden; }
      set
      {
        m_IsHidden = value;
        isIsHiddenDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIsHiddenDirty
    {
      get { return isIsHiddenDirty; }
    }
    #endregion

    #region SpecificationCharacteristics
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSpecificationCharacteristicsDirty = false;
    private List<int> m_SpecificationCharacteristics = new List<int>();
    [MTDataMember(Description = "This property stores a list of the ids of the spcification characteristics assoicated with a product offering. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<int> SpecificationCharacteristics
    {
      get
      {
        if (m_SpecificationCharacteristics == null)
        {
          m_SpecificationCharacteristics = new List<int>();
        }

        return m_SpecificationCharacteristics;
}
      set
      {
        m_SpecificationCharacteristics = value;
        isSpecificationCharacteristicsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSpecificationCharacteristicsDirty
    {
      get { return isSpecificationCharacteristicsDirty; }
    }
    #endregion
  }
}
