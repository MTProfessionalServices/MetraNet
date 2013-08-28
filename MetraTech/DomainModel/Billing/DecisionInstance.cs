using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments;

namespace MetraTech.DomainModel.Billing
{
    /// <summary>
    /// Contains attributes and instance values for a decision instance
    /// </summary>
    [DataContract]
    [Serializable]
    public class DecisionInstance : BaseObject
    {
        #region DecisionUniqueId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDecisionUniqueIdDirty = false;
        private string m_DecisionUniqueId;
        /// <summary>
        /// The unique identifier for a decision instance.
        /// </summary>
        [MTDataMember(Description = "This is the decision instance identifier.", Length = 256)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string DecisionUniqueId
        {
            get { return m_DecisionUniqueId; }
            set
            {
                m_DecisionUniqueId = value;
                isDecisionUniqueIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDecisionUniqueIdDirty
        {
            get { return isDecisionUniqueIdDirty; }
        }
        #endregion

        #region AccountId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAccountIdDirty = false;
        private int m_AccountId;
        /// <summary>
        /// The identifier for the account that owns this decision instance
        /// </summary>
        [MTDataMember(Description = "This is the account identifier", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AccountId
        {
            get { return m_AccountId; }
            set
            {
                m_AccountId = value;
                isAccountIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAccountIdDirty
        {
            get { return isAccountIdDirty; }
        }
        #endregion

        #region UsageInterval
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUsageIntervalDirty = false;
        private int? m_UsageInterval;
        /// <summary>
        /// The identifier of the corresponding usage interval for this decision instance
        /// </summary>
        [MTDataMember(Description = "This is the numeric index of the usage interval.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int? UsageInterval
        {
            get { return m_UsageInterval; }
            set
            {
                m_UsageInterval = value;
                isUsageIntervalDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUsageIntervalDirty
        {
            get { return isUsageIntervalDirty; }
        }
        #endregion

        #region StartDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartDateDirty = false;
        private DateTime? m_StartDate;
        /// <summary>
        /// The start date for this decision
        /// </summary>
        [MTDataMember(Description = "This is the start date of the decision.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime? StartDate
        {
            get { return m_StartDate; }
            set
            {
                m_StartDate = value;
                isStartDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartDateDirty
        {
            get { return isStartDateDirty; }
        }
        #endregion

        #region EndDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEndDateDirty = false;
        private DateTime? m_EndDate;
        /// <summary>
        /// The end date for this decision
        /// </summary>
        [MTDataMember(Description = "This is the end date of the decision.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime? EndDate
        {
            get { return m_EndDate; }
            set
            {
                m_EndDate = value;
                isEndDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsEndDateDirty
        {
            get { return isEndDateDirty; }
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
        public bool IsAccountQualificationGroupColumnNameDirty
        {
            get { return isAccountQualificationGroupDirty; }
        }
        #endregion

        #region SubscriptionId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubscriptionIdDirty = false;
        private int? m_SubscriptionId;
        /// <summary>
        /// identifier for the subscription for this decision instance
        /// </summary>
        [MTDataMember(Description = "This is the identifier of the Subscription", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int? SubscriptionId
        {
            get { return m_SubscriptionId; }
            set
            {

                m_SubscriptionId = value;
                isSubscriptionIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubscriptionIdDirty
        {
            get { return isSubscriptionIdDirty; }
        }
        #endregion

        #region GroupId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isGroupIdDirty = false;
        private int? m_GroupId;
        /// <summary>
        /// This is the identifier of the Group Subscription
        /// </summary>
        [MTDataMember(Description = "This is the identifier of the Group Subscription", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int? GroupId
        {
            get { return m_GroupId; }
            set
            {

                m_GroupId = value;
                isGroupIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsGroupIdDirty
        {
            get { return isGroupIdDirty; }
        }
        #endregion

        #region ProductOfferingId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isProductOfferingIdDirty = false;
        private int m_ProductOfferingId;
        /// <summary>
        /// This is the identifier of the subscribed product offering
        /// </summary>
        [MTDataMember(Description = "This is the identifier of the subscribed product offering", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ProductOfferingId
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

        #region RateScheduleId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isRateScheduleIdDirty = false;
        private int m_RateScheduleId;
        /// <summary>
        /// This is the identifier of the rate schedule
        /// </summary>
        [MTDataMember(Description = "This is the identifier of the rate schedule", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int RateScheduleId
        {
            get { return m_RateScheduleId; }
            set
            {

                m_RateScheduleId = value;
                isRateScheduleIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsRateScheduleIdDirty
        {
            get { return isRateScheduleIdDirty; }
        }
        #endregion

        #region NOrder
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNOrderDirty = false;
        private int m_NOrder;
        /// <summary>
        /// This is the order number of the parameter table row
        /// </summary>
        [MTDataMember(Description = "This is the order number of the parameter table row", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NOrder
        {
            get { return m_NOrder; }
            set
            {

                m_NOrder = value;
                isNOrderDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNOrderDirty
        {
            get { return isNOrderDirty; }
        }
        #endregion

        #region TtStartDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTtStartDateDirty = false;
        private DateTime? m_TtStartDate;
        /// <summary>
        /// This is the start date of the parameter table row.
        /// </summary>
        [MTDataMember(Description = "This is the start date of the parameter table row.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime? TtStartDate
        {
            get { return m_TtStartDate; }
            set
            {
                m_TtStartDate = value;
                isTtStartDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTtStartDateDirty
        {
            get { return isTtStartDateDirty; }
        }
        #endregion

        #region TierColumnGroup
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTierColumnGroupDirty = false;
        private string m_TierColumnGroup;
        /// <summary>
        /// The Tier column group
        /// </summary>
        [MTDataMember(Description = "The tier column group.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TierColumnGroup
        {
            get { return m_TierColumnGroup; }
            set
            {
                m_TierColumnGroup = value;
                isTierColumnGroupDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTierColumnGroupDirty
        {
            get { return isTierColumnGroupDirty; }
        }
        #endregion

        #region TierCategory
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTierCategoryDirty = false;
        private string m_TierCategory;
        /// <summary>
        /// The tier category
        /// </summary>
        [MTDataMember(Description = "The tier category.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TierCategory
        {
            get { return m_TierCategory; }
            set
            {
                m_TierCategory = value;
                isTierCategoryDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTierCategoryDirty
        {
            get { return isTierCategoryDirty; }
        }
        #endregion

        #region TierPriority
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTierPriorityDirty = false;
        private string m_TierPriority;
        /// <summary>
        /// The tier priority
        /// </summary>
        [MTDataMember(Description = "The tier priority.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TierPriority
        {
            get { return m_TierPriority; }
            set
            {
                m_TierPriority = value;
                isTierPriorityDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTierPriorityDirty
        {
            get { return isTierPriorityDirty; }
        }
        #endregion

        #region TierResponsiveness
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTierResponsivenessDirty = false;
        private string m_TierResponsiveness;
        /// <summary>
        /// The tier responsiveness, whether it is realtime (RAMP) or not (AMP)
        /// </summary>
        [MTDataMember(Description = "The tier responsiveness.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TierResponsiveness
        {
            get { return m_TierResponsiveness; }
            set
            {
                m_TierResponsiveness = value;
                isTierResponsivenessDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTierResponsivenessDirty
        {
            get { return isTierResponsivenessDirty; }
        }
        #endregion

        #region QualifiedEvents
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isQualifiedEventsDirty = false;
        private decimal? m_QualifiedEvents;
        /// <summary>
        /// This is the quantity of qualified events
        /// </summary>
        [MTDataMember(Description = "This is the quantity of qualified events", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal? QualifiedEvents
        {
            get { return m_QualifiedEvents; }
            set
            {

                m_QualifiedEvents = value;
                isQualifiedEventsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsQualifiedEventsDirty
        {
            get { return isQualifiedEventsDirty; }
        }
        #endregion

        #region TierStart
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTierStartDirty = false;
        private decimal? m_TierStart;
        /// <summary>
        /// This is the tier start
        /// </summary>
        [MTDataMember(Description = "This is the tier start", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal? TierStart
        {
            get { return m_TierStart; }
            set
            {

                m_TierStart = value;
                isTierStartDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTierStartDirty
        {
            get { return isTierStartDirty; }
        }
        #endregion

        #region TierEnd
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTierEndDirty = false;
        private decimal? m_TierEnd;
        /// <summary>
        /// This is the tier end
        /// </summary>
        [MTDataMember(Description = "This is the tier end", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal? TierEnd
        {
            get { return m_TierEnd; }
            set
            {

                m_TierEnd = value;
                isTierEndDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTierEndDirty
        {
            get { return isTierEndDirty; }
        }
        #endregion

        #region QualifiedUnits
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isQualifiedUnitsDirty = false;
        private decimal? m_QualifiedUnits;
        /// <summary>
        /// This is the quantity of qualified units
        /// </summary>
        [MTDataMember(Description = "This is the quantity of qualified units", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal? QualifiedUnits
        {
            get { return m_QualifiedUnits; }
            set
            {

                m_QualifiedUnits = value;
                isQualifiedUnitsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsQualifiedUnitsDirty
        {
            get { return isQualifiedUnitsDirty; }
        }
        #endregion

        #region QualifiedAmounts
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isQualifiedAmountsDirty = false;
        private decimal? m_QualifiedAmounts;
        /// <summary>
        /// This is the quantity of qualified amounts
        /// </summary>
        [MTDataMember(Description = "This is the quantity of qualified amounts", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal? QualifiedAmounts
        {
            get { return m_QualifiedAmounts; }
            set
            {

                m_QualifiedAmounts = value;
                isQualifiedAmountsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsQualifiedAmountsDirty
        {
            get { return isQualifiedAmountsDirty; }
        }
        #endregion

        #region OtherDecisionAttributes
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isOtherDecisionAttributesDirty = false;
        private Dictionary<string, string> m_OtherDecisionAttributes;
        /// <summary>
        /// dictionary member holds any other decision attributes.
        /// </summary>
        [MTDataMember(Description = "Additional Decision Attributes", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Dictionary<string, string> OtherDecisionAttributes
        {
            get { return m_OtherDecisionAttributes; }
            set
            {
                m_OtherDecisionAttributes = value;
                isOtherDecisionAttributesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsOtherDecisionAttributesDirty
        {
            get { return isOtherDecisionAttributesDirty; }
        }
        #endregion

        #region OtherInstanceValues
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isOtherInstanceValuesDirty = false;
        private Dictionary<string, string> m_OtherInstanceValues;
        /// <summary>
        /// Contains all of the instance values
        /// </summary>
        [MTDataMember(Description = "Additional Decision Instance Values", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Dictionary<string, string> OtherInstanceValues
        {
            get { return m_OtherInstanceValues; }
            set
            {
                m_OtherInstanceValues = value;
                isOtherInstanceValuesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsOtherInstanceValuesDirty
        {
            get { return isOtherInstanceValuesDirty; }
        }
        #endregion
    }
}