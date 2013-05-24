using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    /// <summary>
    /// A Decision defines a set of actions to take on a specified set
    /// of accounts when a summed quantity meets a specified criteria.
    ///
    /// To perform/execute an Aggregate decision, we must take the following steps:
    ///   <list type="bullet">
    ///       <item>
    ///           <description>Select the accounts where the decision should be applied (AccountQualificationGroups).</description>
    ///       </item>
    ///       <item>
    ///           <description>Select the usage events that will participate in the "summing" (UsageQualificationGroups).</description>
    ///       </item>
    ///       <item>
    ///           <description>Sort the usage events according to their occurrence time</description>
    ///       </item>
    ///       <item>
    ///           <description>Compute "total so far"</description>
    ///       </item>
    ///       <item>
    ///           <description>Compute "total within interval"</description>
    ///       </item>
    ///       <item>
    ///           <description>Use either the "total so far" or "total within interval" to determine if the criteria is met.</description>
    ///       </item>
    ///       <item>
    ///           <description>Apply the action if the criteria is met (e.g. change the rate, change the amount, add a generated charge)</description>
    ///       </item>
    ///       <item>
    ///           <description>Lastly, update "downstream" fields that depend on the value that changed (AmountChain).</description>
    ///       </item>
    ///   </list>
    ///
    ///   To accomplish these steps, Decisions are configured with ~31 fields.  For example,
    ///   the beginning of the criteria range is specified in the field "TierStart".
    ///
    ///   Fields can be configured two ways:
    ///   <list>
    ///       <item>
    ///           <description>
    ///               You can specify the value when configuring the decision (e.g. TierStart=200).
    ///               We refer to this as "hard-coding" the decision field value.
    ///           </description>
    ///       </item>
    ///       <item>
    ///           <description>
    ///               You can specify a column name within the parameter table associated with
    ///               this decision (e.g. TierEnd="c_numFreeMinutes").  We refer to this as
    ///               setting a "custimizable" value.
    ///           </description>
    ///       </item>
    ///   </list>
    ///
    ///   In the GUI, some fields must be "hard-coded".
    /// </summary>
  [DataContract]
  [Serializable]
  public class Decision : BaseObject
  {
    #region PUBLIC_ENUMS
    /// <summary>
    /// This enum defines the item that is being aggregated within this decision.
    /// e.g. if we are aggregating phone calls, ItemAggregated is "EVENTS".
    ///      if we are aggregating minutes within phone calls, ItemAggregated is "UNITS"
    ///      if we are aggregating the cost of phone calls, ItemAggregated is "CURRENCY"
    /// </summary>
    public enum ItemAggregatedEnum
    {
        /// <summary>
        /// Summing the amount field from t_acc_usage
        /// </summary>
        AGGREGATE_AMOUNT,

        /// <summary>
        /// Summing the number of usage events within the interval
        /// </summary>
        AGGREGATE_USAGE_EVENTS,

        /// <summary>
        /// Summing a field within the product view e.g. minutes
        /// </summary>
        AGGREGATE_UNITS_OF_USAGE
    };

    /// <summary>
    /// Determines the cycle of a decision.  Decisions can have a different
    /// cycle than the billing interval.  e.g.
    /// first 500 minutes within the first 6 months are free
    /// </summary>
    public enum CycleUnitTypeEnum
    {
        /// <summary>
        /// Decision cycle matches billing interval
        /// </summary>
        CYCLE_SAME_AS_BILLING_INTERVAL,

        /// <summary>
        /// Decision cycle is daily
        /// </summary>
        CYCLE_DAILY,

        /// <summary>
        /// Decision cycle is weekly
        /// </summary>
        CYCLE_WEEKLY,

        /// <summary>
        /// TBD
        /// </summary>
        CYCLE_MONTHLY,

        /// <summary>
        /// TBD
        /// </summary>
        CYCLE_QUARTERLY,

        /// <summary>
        /// TBD
        /// </summary>
        CYCLE_ANNUALLY
    };

    /// <summary>
    /// Decisions define a range via tierStart and tierEnd.
    /// However, if an account subscribes during an interval,
    /// we might want to scale the range.  For example, if
    /// a decision was "first 500 minutes per month are free",
    /// and the account subscribes half way through the month,
    /// we might want to only give 250 minutes free.
    ///
    /// This enum permits the scaling of tier start, tier end,
    /// or both.
    /// </summary>
    public enum TierProrationEnum
    {
        /// <summary>
        /// Don't perform any tier proration
        /// </summary>
        PRORATE_NONE,

        /// <summary>
        /// Only scale the tierStart when performing tier proration
        /// </summary>
        PRORATE_TIER_START,

        /// <summary>
        /// Only scale the tierEnd when performing tier proration
        /// </summary>
        PRORATE_TIER_END,

        /// <summary>
        /// Scale both tierStart and tierEnd when performing tier proration
        /// </summary>
        PRORATE_BOTH
    }

    /// <summary>
    /// This enum describes the conditions when a charge should be applied
    /// </summary>
    public enum ChargeConditionEnum
    {
        /// <summary> 
        /// Don't generate a charge
        /// </summary>
        CHARGE_NONE = 0,

        /// <summary> 
        /// Generate a charge when the "total so far" exceeds tierStart
        /// </summary>
        CHARGE_ON_INBOUND,

        /// <summary> 
        /// Generate a charge when the "total so far" exceeds tierEnd
        /// </summary>
        CHARGE_ON_OUTBOUND,

        /// <summary> 
        /// Generate a charge when the "total so far" lies within the tier.
        /// </summary>
        CHARGE_ON_EVERY,

        /// <summary> 
        /// Generate a charge when the "total within interval" lies within the tier.
        /// </summary>
        CHARGE_ON_FINAL
    };

    /// <summary>
    /// This enum describes the three algorithms for determining the charge amount.
    /// </summary>
    public enum ChargeAmountTypeEnum
    {
        /// <summary> 
        /// The charge amount is exactly as specified.  
        /// </summary>
        CHARGE_AMOUNT_FLAT = 0,

        /// <summary> 
        /// IMPORTANT - only applies when ChargeType==CHARGE_ON_FINAL
        /// The charge amount is proportional to the "distance from tierStart".
        /// chargeAmount = (totalWithinInterval - tierStart) /
        ///                     (tierEnd - tierStart) * Charge value
        /// </summary>
        CHARGE_AMOUNT_PROPORTIONAL,

        /// <summary> 
        /// IMPORTANT - only applies when ChargeType==CHARGE_ON_FINAL
        /// The charge amount is proportional to the "distance from tierEnd".
        /// chargeAmount = (tierEnd - totalWithinInterval) /
        ///                     (tierEnd - tierStart) * Charge value
        /// </summary>
        CHARGE_AMOUNT_INVERSE_PROPORTIONAL,

        /// <summary> 
        /// IMPORTANT - only applies when ChargeType==CHARGE_ON_FINAL
        /// chargeAmount = aggregatedQuantity * Charge value
        /// </summary>
        CHARGE_PERCENTAGE
    };

    /// <summary>
    /// This enum describes when this decision should be processed.
    /// </summary>
    public enum ExecutionFrequencyEnum
    {
        /// <summary> 
        /// This decision should only be executed during EOP
        /// </summary>
        DURING_EOP = 0,

        /// <summary> 
        /// This decision should only be executed during scheduled
        /// runs of AMP.
        /// </summary>
        DURING_SCHEDULED_RUNS,

        /// <summary> 
        /// This decision should be executed during scheduled runs
        /// of AMP and at EOP.
        /// </summary>
        DURING_BOTH
    };
    #endregion

    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
      /// <summary>
      /// Unique name for this decision supplied during configuration
      /// </summary>
    [MTDataMember(Description = "Unique identifier of the Decision", Length = 40)]
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

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
      /// <summary>
      /// A sentence or 2 describing the criteria and action of a decision
      /// </summary>
    [MTDataMember(Description = "A sentence or 2 describing the criteria and action of a decision", Length = 40)]
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

    #region UniqueId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUniqueIdDirty = false;
    private Guid m_UniqueId;
      /// <summary>
      /// Unique ID generated by the "backend" when inserting a decision in the DB
      /// TBD how can I make this only settable by the backend
      /// </summary>
    [MTDataMember(Description = "Unique identifier of the Decision", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid UniqueId
    {
      get { return m_UniqueId; }
      set
      {
          m_UniqueId = value;
          isUniqueIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUniqueIdDirty
    {
      get { return isUniqueIdDirty; }
    }
    #endregion

    #region ParameterTableName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterTableNameDirty = false;
    private string m_ParameterTableName;
      /// <summary>
      /// The name of the parameter table that is associated with this
      /// decision.  The number of rows in this table determines how many decisions
      /// are instantiated.  Also, this parameter table can hold "custimizable"
      /// decision parameters.
      /// </summary>
    [MTDataMember(Description = "The name of the parameter table that is associated with this decision", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterTableName
    {
      get { return m_ParameterTableName; }
      set
      {
          m_ParameterTableName = value;
          isParameterTableNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterTableNameDirty
    {
      get { return isParameterTableNameDirty; }
    }
    #endregion

    #region ParameterTableDisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterTableDisplayNameDirty = false;
    private string m_ParameterTableDisplayName;
    /// <summary>
    /// The display name of the parameter table that is associated with this
    /// decision.
    /// </summary>
    [MTDataMember(Description = "Display value of the parameter table for the Decision", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterTableDisplayName
    {
      get { return m_ParameterTableDisplayName; }
      set
      {
        m_ParameterTableDisplayName = value;
        isParameterTableDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterTableDisplayNameDirty
    {
      get { return isParameterTableDisplayNameDirty; }
    }
    #endregion

    #region TierStartColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierStartColumnNameDirty = false;
    private string m_TierStartColumnName;
    /// <summary>
    /// Column name within the parameter table associated with this decision
    /// where the TierStart value will be found at runtime by AMP.  TierStart is the
    /// beginning of the range of the decision.
    /// </summary>
    [MTDataMember(Description = "This is the identifier of the subscribed product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TierStartColumnName
    {
      get { return m_TierStartColumnName; }
      set
      {
          m_TierStartColumnName = value;
          isTierStartColumnNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTierStartColumnNameDirty
    {
      get { return isTierStartColumnNameDirty; }
    }
    #endregion

    #region TierStartValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierStartValueDirty = false;
    private decimal? m_TierStartValue;
    /// <summary>
    /// Hard coded value specified during decision creation that contains
    /// the beginning of the range of the decision.
    /// </summary>
    [MTDataMember(Description = "This is the identifier of the subscribed product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? TierStartValue
    {
      get { return m_TierStartValue; }
      set
      {
          m_TierStartValue = value;
          isTierStartValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTierStartValueDirty
    {
      get { return isTierStartValueDirty; }
    }
    #endregion

    #region TierEndColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierEndColumnNameDirty = false;
    private string m_TierEndColumnName;
    /// <summary>
    /// Column name within the parameter table associated with this decision
    /// where the TierEnd value will be found at runtime by AMP.  TierEnd is the
    /// end of the range of the decision.
    /// </summary>
    [MTDataMember(Description = "This is the identifier of the subscribed product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TierEndColumnName
    {
      get { return m_TierEndColumnName; }
      set
      {
          m_TierEndColumnName = value;
          isTierEndColumnNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTierEndColumnNameDirty
    {
      get { return isTierEndColumnNameDirty; }
    }
    #endregion

    #region TierEndValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierEndValueDirty = false;
    private decimal? m_TierEndValue;
    /// <summary>
    /// Hard coded value specified during decision creation that contains
    /// the end of the range of the decision.
    /// </summary>
    [MTDataMember(Description = "This is the identifier of the subscribed product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? TierEndValue
    {
      get { return m_TierEndValue; }
      set
      {
          m_TierEndValue = value;
          isTierEndValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTierEndValueDirty
    {
      get { return isTierEndValueDirty; }
    }
    #endregion

    #region TierRepetitionColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierRepetitionColumnNameDirty = false;
    private string m_TierRepetitionColumnName;
    /// <summary>
    /// Column name within the parameter table associated with this decision
    /// where the TierRepetition value will be found at runtime by AMP.  
    /// TierRepetition is the number of times the tier should be repeated.
    /// </summary>
    [MTDataMember(Description = "This is the identifier of the subscribed product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TierRepetitionColumnName
    {
      get { return m_TierRepetitionColumnName; }
      set
      {
          m_TierRepetitionColumnName = value;
          isTierRepetitionColumnNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTierRepetitionColumnNameDirty
    {
      get { return isTierRepetitionColumnNameDirty; }
    }
    #endregion

    #region TierRepetitionValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierRepetitionValueDirty = false;
    private string m_TierRepetitionValue;
    /// <summary>
    /// Hard coded value specified during decision creation that contains
    /// the number of times the tier should be repeated.
    /// </summary>
    [MTDataMember(Description = "This is the identifier of the subscribed product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TierRepetitionValue
    {
      get { return m_TierRepetitionValue; }
      set
      {
          m_TierRepetitionValue = value;
          isTierRepetitionValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTierRepetitionValueDirty
    {
      get { return isTierRepetitionValueDirty; }
    }
    #endregion

    #region AccountQualificationGroup
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountQualificationGroupDirty = false;
    private string m_AccountQualificationGroup;
    /// <summary>
    /// The AccountQualificationGroup specifies which accounts to consider when processing a decision.
    /// </summary>
    [MTDataMember(Description = "The AccountQualificationGroup specifies which accounts to consider when processing a decision.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AccountQualificationGroup
    {
        get { return m_AccountQualificationGroup; }
        set
        {
            m_AccountQualificationGroup = value;
            isAccountQualificationGroupDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsAccountQualificationGroupDirty
    {
        get { return isAccountQualificationGroupDirty; }
    }
    #endregion

    #region PvToAmountChainMapping
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPvToAmountChainMappingDirty = false;
    private string m_PvToAmountChainMapping;
    /// <summary>
    /// The PvToAmountChainMapping associates an amount chain with a product view.
    /// </summary>
    [MTDataMember(Description = "The PvToAmountChainMapping associates an amount chain with a product view.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PvToAmountChainMapping
    {
        get { return m_PvToAmountChainMapping; }
        set
        {
            m_PvToAmountChainMapping = value;
            isPvToAmountChainMappingDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsPvToAmountChainMappingDirty
    {
        get { return isPvToAmountChainMappingDirty; }
    }
    #endregion

    #region UsageQualificationGroup
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUsageQualificationGroupDirty = false;
    private string m_UsageQualificationGroup;
    /// <summary>
    /// The UsageQualificationGroup specifies which usage events to consider when processing a decision.
    /// </summary>
    [MTDataMember(Description = "The UsageQualificationGroup specifies which usage events to consider when processing a decision.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UsageQualificationGroup
    {
        get { return m_UsageQualificationGroup; }
        set
        {
            m_UsageQualificationGroup = value;
            isUsageQualificationGroupDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsUsageQualificationGroupDirty
    {
        get { return isUsageQualificationGroupDirty; }
    }
    #endregion

    #region ItemAggregated
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isItemAggregatedDirty = false;
    private ItemAggregatedEnum m_ItemAggregated;
    /// <summary>
    /// ItemAggregated defines the item that is being aggregated within this decision.
    /// e.g. if we are aggregating phone calls, ItemAggregated is "EVENTS".
    ///      if we are aggregating minutes within phone calls, ItemAggregated is "UNITS"
    ///      if we are aggregating the cost of phone calls, ItemAggregated is "CURRENCY"
    /// TBD SHOULD BE ENUM
    /// </summary>
    [MTDataMember(Description = "ItemAggregated defines the item that is being aggregated within this decision.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ItemAggregatedEnum ItemAggregated
    {
        get { return m_ItemAggregated; }
        set
        {
            m_ItemAggregated = value;
            isItemAggregatedDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsItemAggregatedDirty
    {
        get { return isItemAggregatedDirty; }
    }
    #endregion
 
    #region TierProration
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierProrationDirty = false;
    private TierProrationEnum m_TierProration;
    /// <summary>
    /// Decisions define a range via tierStart and tierEnd.
    /// However, if an account subscribes during an interval,
    /// we might want to scale the range.  For example, if
    /// a decision was "first 500 minutes per month are free",
    /// and the account subscribes half way through the month,
    /// we might want to only give 250 minutes free.
    /// TBD SHOULD BE ENUM
    /// </summary>
    [MTDataMember(Description = "TierProration defines whether the decision range should be scaled for accounts that subscribe during the interval", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public TierProrationEnum TierProration
    {
        get { return m_TierProration; }
        set
        {
            m_TierProration = value;
            isTierProrationDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsTierProrationDirty
    {
        get { return isTierProrationDirty; }
    }
    #endregion   

    #region CycleUnitType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCycleUnitTypeDirty = false;
    private CycleUnitTypeEnum m_CycleUnitType;
    /// <summary>
    /// <para>
    ///   This parameter holds the units of the decision cycle.
    /// </para>
    /// <para>
    /// All decisions have a cycle.  This is analagous to a billing cycle.
    /// The decision cycle does not have to match the billing cycle.  For example,
    /// imagine a monthly billing cycle with a decision that says "if the total minutes
    /// used this year exceeds 1000, then change the ratePerMinute".
    /// </para>
    /// </summary>
    [MTDataMember(Description = "This parameter holds the units of the decision cycle.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CycleUnitTypeEnum CycleUnitType
    {
        get { return m_CycleUnitType; }
        set
        {
            m_CycleUnitType = value;
            isCycleUnitTypeDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsCycleUnitTypeDirty
    {
        get { return isCycleUnitTypeDirty; }
    }
    #endregion   

    #region CycleUnitsPerTierValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCycleUnitsPerTierValueDirty = false;
    private int? m_CycleUnitsPerTierValue;
    /// <summary>
    /// To determine the duration of a decision cycle, you can multiply
    /// CycleUnitsPerTier by the CycleUnitType i.e.
    ///   decisionCycleDuration = PARAM_CYCLE_UNITS_PER_TIER * PARAM_CYCLE_UNIT_TYPE
    /// This member holds the hard coded value of CycleUnitsPerTier.
    /// </summary>
    [MTDataMember(Description = "multiplied by cycleUnitType to get cycleDuration", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? CycleUnitsPerTierValue
    {
        get { return m_CycleUnitsPerTierValue; }
        set
        {
            m_CycleUnitsPerTierValue = value;
            isCycleUnitsPerTierValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsCycleUnitsPerTierValueDirty
    {
        get { return isCycleUnitsPerTierValueDirty; }
    }
    #endregion   

    #region CycleUnitsPerTierColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCycleUnitsPerTierColumnNameDirty = false;
    private string m_CycleUnitsPerTierColumnName;
    /// <summary>
    /// To determine the duration of a decision cycle, you can multiply
    /// this value by the PARAM_CYCLE_UNIT_TYPE i.e.
    ///   decisionCycleDuration = PARAM_CYCLE_UNITS_PER_TIER * PARAM_CYCLE_UNIT_TYPE
    /// This field refers to a column name within the parameter table that
    /// will hold the value of CycleUnitsPerTier.
    /// </summary>
    [MTDataMember(Description = "multiplied by cycleUnitType to get cycleDuration", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string CycleUnitsPerTierColumnName
    {
        get { return m_CycleUnitsPerTierColumnName; }
        set
        {
            m_CycleUnitsPerTierColumnName = value;
            isCycleUnitsPerTierColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsCycleUnitsPerTierColumnNameDirty
    {
        get { return isCycleUnitsPerTierColumnNameDirty; }
    }
    #endregion   

    #region CycleUnitsOffsetValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCycleUnitsOffsetValueDirty = false;
    private int? m_CycleUnitsOffsetValue;
    /// <summary>
    /// By setting this parameter, you can offset the beginning of the decision cycle.
    /// For example, if you had a monthly decision cycle, you could specify a 
    /// decision that becomes active in the 3rd month of the subscription by setting
    /// the value of this parameter to 3.
    /// This member holds the hard coded value of CycleUnitsOffset.
    /// </summary>
    [MTDataMember(Description = "offsets the beginning of a decision cycle", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? CycleUnitsOffsetValue
    {
        get { return m_CycleUnitsOffsetValue; }
        set
        {
            m_CycleUnitsOffsetValue = value;
            isCycleUnitsOffsetValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsCycleUnitsOffsetValueDirty
    {
        get { return isCycleUnitsOffsetValueDirty; }
    }
    #endregion   

    #region CycleUnitsOffsetColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCycleUnitsOffsetColumnNameDirty = false;
    private string m_CycleUnitsOffsetColumnName;
    /// <summary>
    /// By setting this parameter, you can offset the beginning of the decision cycle.
    /// For example, if you had a monthly decision cycle, you could specify a 
    /// decision that becomes active in the 3rd month of the subscription by setting
    /// the value of this parameter to 3.
    /// This member holds the hard coded value of CycleUnitsOffset.
    /// </summary>
    [MTDataMember(Description = "offsets the beginning of a decision cycle", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string CycleUnitsOffsetColumnName
    {
        get { return m_CycleUnitsOffsetColumnName; }
        set
        {
            m_CycleUnitsOffsetColumnName = value;
            isCycleUnitsOffsetColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsCycleUnitsOffsetColumnNameDirty
    {
        get { return isCycleUnitsOffsetColumnNameDirty; }
    }
    #endregion   

    #region CyclesValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCyclesValueDirty = false;
    private int? m_CyclesValue;
    /// <summary>
    /// The number of decision cycles that this decision will remain active.
    /// For example, if the decisionCycleDuration is 1 month, you could create a decision
    /// that is only active for the first 6 months.
    /// This member holds the hard coded value of Cycles.
    /// </summary>
    [MTDataMember(Description = "number of decision cycles that a decision remains active", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? CyclesValue
    {
        get { return m_CyclesValue; }
        set
        {
            m_CyclesValue = value;
            isCyclesValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsCyclesValueDirty
    {
        get { return isCyclesValueDirty; }
    }
    #endregion   

    #region CyclesColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCyclesColumnNameDirty = false;
    private string m_CyclesColumnName;
    /// <summary>
    /// The number of decision cycles that this decision will remain active.
    /// For example, if the decisionCycleDuration is 1 month, you could create a decision
    /// that is only active for the first 6 months.
    /// This field refers to a column name within the parameter table that
    /// will hold the value of Cycles.
    /// </summary>
    [MTDataMember(Description = "number of cycles that a decision remains active", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string CyclesColumnName
    {
        get { return m_CyclesColumnName; }
        set
        {
            m_CyclesColumnName = value;
            isCyclesColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsCyclesColumnNameDirty
    {
        get { return isCyclesColumnNameDirty; }
    }
    #endregion   

    #region IsBulkDecision
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsBulkDecisionDirty = false;
    private bool? m_IsBulkDecision;
    /// <summary>
    /// <para>
    /// Determines if the "total so far" or "total within interval" should be
    /// used for the criteria.
    /// </para>
    /// <para>
    /// isBulk==true,   If the total-within_interval, after processing all usage events
    ///                 within the interval falls within the tier, then apply the
    ///                 specified action to all usage events within the interval
    /// </para>
    /// <para>
    /// isBulk==false,  Apply the action to usage events where the total-so-far
    ///                 falls within the tier.
    /// </para>
    /// </summary>
    [MTDataMember(Description = "if true, applies to all usage events within the interval", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? IsBulkDecision
    {
        get { return m_IsBulkDecision; }
        set
        {
            m_IsBulkDecision = value;
            isIsBulkDecisionDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsIsBulkDecisionDirty
    {
        get { return isIsBulkDecisionDirty; }
    }
    #endregion   

    #region PerUnitRateValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPerUnitRateValueDirty = false;
    private decimal? m_PerUnitRateValue;
    /// <summary>
    /// Set this value to apply a new rate for this usage event.
    /// e.g. amount = minutes * perUnitRate
    /// This member holds the hard coded value of PerUnitRate.
    /// </summary>
    [MTDataMember(Description = "a new rate for this usage event", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? PerUnitRateValue
    {
        get { return m_PerUnitRateValue; }
        set
        {
            m_PerUnitRateValue = value;
            isPerUnitRateValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsPerUnitRateValueDirty
    {
        get { return isPerUnitRateValueDirty; }
    }
    #endregion   

    #region PerUnitRateColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPerUnitRateColumnNameDirty = false;
    private string m_PerUnitRateColumnName;
    /// <summary>
    /// Set this value to apply a new rate for this usage event.
    /// e.g. amount = minutes * perUnitRate
    /// This field refers to a column name within the parameter table that
    /// will hold the value of PerUnitRate.
    /// </summary>
    [MTDataMember(Description = "a new rate for this usage event", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PerUnitRateColumnName
    {
        get { return m_PerUnitRateColumnName; }
        set
        {
            m_PerUnitRateColumnName = value;
            isPerUnitRateColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsPerUnitRateColumnNameDirty
    {
        get { return isPerUnitRateColumnNameDirty; }
    }
    #endregion   

    #region PerEventCostValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPerEventCostValueDirty = false;
    private decimal? m_PerEventCostValue;
    /// <summary>
    /// Set this value to apply a new cost for this usage event.
    /// e.g. amount = perEventCost
    /// This member holds the hard coded value of PerEventCost.
    /// </summary>
    [MTDataMember(Description = "a new cost for this event", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? PerEventCostValue
    {
        get { return m_PerEventCostValue; }
        set
        {
            m_PerEventCostValue = value;
            isPerEventCostValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsPerEventCostValueDirty
    {
        get { return isPerEventCostValueDirty; }
    }
    #endregion   

    #region PerEventCostColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPerEventCostColumnNameDirty = false;
    private string m_PerEventCostColumnName;
    /// <summary>
    /// Set this value to apply a new cost for this usage event.
    /// e.g. amount = perEventCost
    /// This field refers to a column name within the parameter table that
    /// will hold the value of PerEventCost.
    /// </summary>
    [MTDataMember(Description = "a new cost for this event", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PerEventCostColumnName
    {
        get { return m_PerEventCostColumnName; }
        set
        {
            m_PerEventCostColumnName = value;
            isPerEventCostColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsPerEventCostColumnNameDirty
    {
        get { return isPerEventCostColumnNameDirty; }
    }
    #endregion   

    #region TierDiscountValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierDiscountValueDirty = false;
    private decimal? m_TierDiscountValue;
    /// <summary>
    /// Apply this discount if decision criteria are met
    /// e.g. amount = amount * tierDiscount
    /// This member holds the hard coded value of TierDiscount.
    /// </summary>
    [MTDataMember(Description = "amount = amount * tierDiscount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? TierDiscountValue
    {
        get { return m_TierDiscountValue; }
        set
        {
            m_TierDiscountValue = value;
            isTierDiscountValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsTierDiscountValueDirty
    {
        get { return isTierDiscountValueDirty; }
    }
    #endregion   

    #region TierDiscountColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierDiscountColumnNameDirty = false;
    private string m_TierDiscountColumnName;
    /// <summary>
    /// Apply this discount if decision criteria are met
    /// e.g. amount = amount * tierDiscount
    /// This field refers to a column name within the parameter table that
    /// will hold the value of TierDiscount.
    /// </summary>
    [MTDataMember(Description = "amount = amount * tierDiscount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TierDiscountColumnName
    {
        get { return m_TierDiscountColumnName; }
        set
        {
            m_TierDiscountColumnName = value;
            isTierDiscountColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsTierDiscountColumnNameDirty
    {
        get { return isTierDiscountColumnNameDirty; }
    }
    #endregion   

    #region ChargeCondition
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargeConditionDirty = false;
    private ChargeConditionEnum m_ChargeCondition;
    /// <summary>
    /// This value defines the condition when a charge should be applied 
    /// e.g. generate a charge when units of usage exceeds a specified value.
    /// </summary>
    [MTDataMember(Description = "ChargeCondition defines the condition when a charge should be applied", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ChargeConditionEnum ChargeCondition
    {
        get { return m_ChargeCondition; }
        set
        {
            m_ChargeCondition = value;
            isChargeConditionDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsChargeConditionDirty
    {
        get { return isChargeConditionDirty; }
    }
    #endregion   

    #region ChargeAmountType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargeAmountTypeDirty = false;
    private ChargeAmountTypeEnum m_ChargeAmountType;
    /// <summary>
    /// This value defines the algorithm that should be used to compute the
    /// actual charge amount.
    /// </summary>
    [MTDataMember(Description = "ChargeAmountType defines the algorithm that should be used to compute the actual charge amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ChargeAmountTypeEnum ChargeAmountType
    {
        get { return m_ChargeAmountType; }
        set
        {
            m_ChargeAmountType = value;
            isChargeAmountTypeDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsChargeAmountTypeDirty
    {
        get { return isChargeAmountTypeDirty; }
    }
    #endregion   

    #region ChargeValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargeValueDirty = false;
    private decimal? m_ChargeValue;
    /// <summary>
    /// If ChargeCondition is none, then ChargeAmountType, ChargeValue, and ChargeColumnName can be ignored.  There will be no generated charge.
    /// If ChargeCondition is "on inbound" or "on outbound" or "on every":
    ///     ChargeAmountType must be "flat"
    ///     chargeAmount = chargeValue
    /// If ChargeCondition is "on final"
    ///     If ChargeAmountType is flat
    ///         chargeAmount = chargeValue
    ///     else if ChargeAmountType is "proportional"
    ///         chargeAmount = (totalWithinInterval - tierStart) / (tierEnd - tierStart) * chargeValue
    ///     else if ChargeAmountType is "inverse_proportional"
    ///         chargeAmount = (tierEnd - totalWithinInterval) / (tierEnd - tierStart) * chargeValue
    ///     else if ChargeAmountType is "percentage"
    ///         chargeAmount = totalWithinInterval * chargeValue
    /// </summary>
    [MTDataMember(Description = "ChargeValue is used to compute the actual charge amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? ChargeValue
    {
        get { return m_ChargeValue; }
        set
        {
            m_ChargeValue = value;
            isChargeValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsChargeValueDirty
    {
        get { return isChargeValueDirty; }
    }
    #endregion   

    #region ChargeColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargeColumnNameDirty = false;
    private string m_ChargeColumnName;
    /// <summary>
    /// Column name within the parameter table associated with this decision
    /// where the Charge value will be found at runtime by AMP.
    /// If ChargeCondition is none, then ChargeAmountType and ChargeColumnName can be ignored.  There will be no generated charge.
    /// If ChargeCondition is "on inbound" or "on outbound" or "on every":
    ///     ChargeAmountType must be "flat"
    ///     chargeAmount = Charge value
    /// If ChargeCondition is "on final"
    ///     If ChargeAmountType is flat
    ///         chargeAmount = Charge value
    ///     else if ChargeAmountType is "proportional"
    ///         chargeAmount = (totalWithinInterval - tierStart) / (tierEnd - tierStart) * Charge value
    ///     else if ChargeAmountType is "inverse_proportional"
    ///         chargeAmount = (tierEnd - totalWithinInterval) / (tierEnd - tierStart) * Charge value
    ///     else if ChargeAmountType is "percentage"
    ///         chargeAmount = totalWithinInterval * Charge value
    /// </summary>
    [MTDataMember(Description = "Charge value stored in parameter table column is used to compute the actual charge amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ChargeColumnName
    {
      get { return m_ChargeColumnName; }
      set
      {
        m_ChargeColumnName = value;
        isChargeColumnNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsChargeColumnNameDirty
    {
      get { return isChargeColumnNameDirty; }
    }
    #endregion

    #region GeneratedCharge
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isGeneratedChargeDirty = false;
    private string m_GeneratedCharge;
    /// <summary>
    /// One of the actions that decision can take is to create a new
    /// charge.  For example, if your minutes exceed 1000, then your
    /// account will incur a $50 charge.  The GeneratedCharge object
    /// tells AMP how to fill the columns related to the new charge.
    /// This member holds the name of the GeneratedCharge.
    /// </summary>
    [MTDataMember(Description = "name of the generated charge", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string GeneratedCharge
    {
        get { return m_GeneratedCharge; }
        set
        {
            m_GeneratedCharge = value;
            isGeneratedChargeDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsGeneratedChargeDirty
    {
        get { return isGeneratedChargeDirty; }
    }
    #endregion   

    #region IsUsageConsumed
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsUsageConsumedDirty = false;
    private bool? m_IsUsageConsumed;
    /// <summary>
    /// When there are multiple decisions that consider the same usage
    /// event, we need to decide if the current decision should "consume"
    /// the usage.  This means that a subsequent decision will not
    /// get a chance to process this usage event.  This method determines
    /// if the usage should be consumed by this decision.
    /// </summary>
    [MTDataMember(Description = "determines if the usage is consumed by this decision", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? IsUsageConsumed
    {
        get { return m_IsUsageConsumed; }
        set
        {
            m_IsUsageConsumed = value;
            isIsUsageConsumedDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsIsUsageConsumedDirty
    {
        get { return isIsUsageConsumedDirty; }
    }
    #endregion   

    #region PriorityValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPriorityValueDirty = false;
    private int? m_PriorityValue;
    /// <summary>
    /// A decision's priority determines when it will be executed with
    /// respect to other decisions.  Lower priority integer values will
    /// be executed first.  If multiple decisions have the same priority,
    /// the order of their execution is undefined.
    /// </summary>
    [MTDataMember(Description = "determines the order that decisions are executed", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? PriorityValue
    {
        get { return m_PriorityValue; }
        set
        {
            m_PriorityValue = value;
            isPriorityValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsPriorityValueDirty
    {
        get { return isPriorityValueDirty; }
    }
    #endregion   

    #region PriorityColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPriorityColumnNameDirty = false;
    private string m_PriorityColumnName;
    /// <summary>
    /// A decision's priority determines when it will be executed with
    /// respect to other decisions.  Lower priority integer values will
    /// be executed first.  If multiple decisions have the same priority,
    /// the order of their execution is undefined.
    /// </summary>
    [MTDataMember(Description = "determines the order that decisions are executed", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PriorityColumnName
    {
        get { return m_PriorityColumnName; }
        set
        {
            m_PriorityColumnName = value;
            isPriorityColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsPriorityColumnNameDirty
    {
        get { return isPriorityColumnNameDirty; }
    }
    #endregion   

    #region IsActive
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsActiveDirty = false;
    private bool? m_IsActive;
    /// <summary>
    /// Determines if a decision should be processed when the AMP
    /// engine runs.  If the value is true, the decision will be
    /// processed when the AMP engine runs.  If the value is false,
    /// this decision will be ignored and will have no impact
    /// when the AMP engine runs.
    /// </summary>
    [MTDataMember(Description = "determines if the AMP engine should consider this decision", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? IsActive
    {
        get { return m_IsActive; }
        set
        {
            m_IsActive = value;
            isIsActiveDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsIsActiveDirty
    {
        get { return isIsActiveDirty; }
    }
    #endregion   

    #region IsEditable
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsEditableDirty = false;
    private bool? m_IsEditable;
    /// <summary>
    /// Determines if a decision can be editted via the GUI.
    /// Some decisions are configured to be "templates",
    /// and should not be editted.
    /// </summary>
    [MTDataMember(Description = "determines if the AMP GUI can change this decision", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? IsEditable
    {
        get { return m_IsEditable; }
        set
        {
            m_IsEditable = value;
            isIsEditableDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsIsEditableDirty
    {
        get { return isIsEditableDirty; }
    }
    #endregion   

    #region TierOverrideNameValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierOverrideNameValueDirty = false;
    private string m_TierOverrideNameValue;
    /// <summary>
    /// TierOverrideName
    /// </summary>
    [MTDataMember(Description = "determines the order that decisions are executed", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TierOverrideNameValue
    {
        get { return m_TierOverrideNameValue; }
        set
        {
            m_TierOverrideNameValue = value;
            isTierOverrideNameValueDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsTierOverrideNameValueDirty
    {
        get { return isTierOverrideNameValueDirty; }
    }
    #endregion   

    #region TierOverrideNameColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTierOverrideNameColumnNameDirty = false;
    private string m_TierOverrideNameColumnName;
    /// <summary>
    /// TierOverrideName
    /// </summary>
    [MTDataMember(Description = "determines the order that decisions are executed", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TierOverrideNameColumnName
    {
        get { return m_TierOverrideNameColumnName; }
        set
        {
            m_TierOverrideNameColumnName = value;
            isTierOverrideNameColumnNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsTierOverrideNameColumnNameDirty
    {
        get { return isTierOverrideNameColumnNameDirty; }
    }
    #endregion   

    #region ExecutionFrequency
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecutionFrequencyDirty = false;
    private ExecutionFrequencyEnum m_ExecutionFrequency;
    /// <summary>
    /// This value determines when the decision should be executed.
    /// </summary>
    [MTDataMember(Description = "ExecutionFrequency defines how often this decision should be executed", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecutionFrequencyEnum ExecutionFrequency
    {
        get { return m_ExecutionFrequency; }
        set
        {
            m_ExecutionFrequency = value;
            isExecutionFrequencyDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsExecutionFrequencyDirty
    {
        get { return isExecutionFrequencyDirty; }
    }
    #endregion   

    #region OtherAttributes
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOtherAttributesDirty = false;
    private Dictionary<string, DecisionAttributeValue> m_OtherAttributes;
    /// <summary>
    /// Most decision attributes are defined by member variables
    /// within this class.  However, to provide extensibility, this
    /// dictionary member holds any other decision attributes.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<string, DecisionAttributeValue> OtherAttributes
    {
        get { return m_OtherAttributes; }
        set
        {
            m_OtherAttributes = value;
            isOtherAttributesDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsOtherAttributesDirty
    {
        get { return isOtherAttributesDirty; }
    }
    #endregion

  }
}
