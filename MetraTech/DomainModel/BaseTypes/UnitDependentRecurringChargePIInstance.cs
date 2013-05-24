using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.BaseTypes
{

    [DataContract]
    [Serializable]
    public class UnitDependentRecurringChargePIInstance : BaseRecurringChargePIInstance
    {
        protected override PriceableItemKinds GetPIKind()
        {
            return PriceableItemKinds.UnitDependentRecurring;
        }

        #region UnitName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUnitNameDirty = false;
    private string m_UnitName;
    [MTDataMember(Description = "This is the name of the unit value.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UnitName
    {
      get { return m_UnitName; }
      set
      {
          m_UnitName = value;
          isUnitNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUnitNameDirty
    {
      get { return isUnitNameDirty; }
    }
    #endregion

        #region UnitDisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUnitDisplayNameDirty = false;
    private string m_UnitDisplayName;
    [MTDataMember(Description = "This is the default display name for the unit value.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UnitDisplayName
    {
      get { return m_UnitDisplayName; }
      set
      {
          m_UnitDisplayName = value;
          isUnitDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUnitDisplayNameDirty
    {
      get { return isUnitDisplayNameDirty; }
    }
    #endregion

        #region LocalizedUnitDisplayNames
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedUnitDisplayNamesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedUnitDisplayNames = null;
    [MTDataMember(Description = "This is a collection of localized unit value names for the unit dependent recurring charge priceable item template. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedUnitDisplayNames
    {
      get { return m_LocalizedUnitDisplayNames; }
      set
      {
          m_LocalizedUnitDisplayNames = value;
          isLocalizedUnitDisplayNamesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedUnitDisplayNamesDirty
    {
      get { return isLocalizedUnitDisplayNamesDirty; }
    }
    #endregion

        #region IntegerUnitValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIntegerUnitValueDirty = false;
    private  Nullable<bool> m_IntegerUnitValue;
    [MTDataMember(Description = "This flag indicates whether or not the unit value is a decimal or an integer.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public  Nullable<bool> IntegerUnitValue
    {
      get { return m_IntegerUnitValue; }
      set
      {
          m_IntegerUnitValue = value;
          isIntegerUnitValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIntegerUnitValueDirty
    {
      get { return isIntegerUnitValueDirty; }
    }
    #endregion

        #region MinUnitValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMinUnitValueDirty = false;
    private  Nullable<decimal> m_MinUnitValue;
    [MTDataMember(Description = "This specifies the minimum allowable unit value.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public  Nullable<decimal> MinUnitValue
    {
      get { return m_MinUnitValue; }
      set
      {
          m_MinUnitValue = value;
          isMinUnitValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMinUnitValueDirty
    {
      get { return isMinUnitValueDirty; }
    }
    #endregion

        #region MaxUnitValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMaxUnitValueDirty = false;
    private  Nullable<decimal> m_MaxUnitValue;
    [MTDataMember(Description = "This specifies the maximum allowable unit value.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public  Nullable<decimal> MaxUnitValue
    {
      get { return m_MaxUnitValue; }
      set
      {
          m_MaxUnitValue = value;
          isMaxUnitValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMaxUnitValueDirty
    {
      get { return isMaxUnitValueDirty; }
    }
    #endregion

        #region AllowedUnitValues
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAllowedUnitValuesDirty = false;
    private List<decimal> m_AllowedUnitValues = new List<decimal>();
    [MTDataMember(Description = "If values are specified in this collection, then only one of the values from this collection is allowed to be specified when setting up a subscription to the UDRC.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<decimal> AllowedUnitValues
    {
      get 
      {
          if (m_AllowedUnitValues == null)
          {
              m_AllowedUnitValues = new List<decimal>();
          }

          return m_AllowedUnitValues; 
      }
      set
      {
          m_AllowedUnitValues = value;
          isAllowedUnitValuesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAllowedUnitValuesDirty
    {
      get { return isAllowedUnitValuesDirty; }
    }
    #endregion

        #region RatingType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRatingTypeDirty = false;
    private  Nullable<UDRCRatingType> m_RatingType;
    [MTDataMember(Description = " This indicates whether the unit dependent recurring charge uses a tapered or tiered method for determining rates. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public  Nullable<UDRCRatingType> RatingType
    {
      get { return m_RatingType; }
      set
      {
          m_RatingType = value;
          isRatingTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRatingTypeDirty
    {
      get { return isRatingTypeDirty; }
    }
    #endregion
    }
}
