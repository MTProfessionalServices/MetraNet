using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [Serializable]
    public enum CycleType
    {
        Monthly = 1,
        Daily = 3,
        Weekly = 4,
        Bi_Weekly = 5,
        Semi_Monthly = 6,
        Quarterly = 7,
        Annually = 8,
        Semi_Annually = 9
    };

    [Serializable]
    public enum ExtendedCycleType
    {
        Monthly = 1,
        Weekly = 4,
        Bi_Weekly = 5,
        Quarterly = 7,
        Annually = 8,
        Semi_Annually = 9
    };

    [Serializable]
    [DataContract]
    [KnownType(typeof(UsageCycleInfo))]
    [KnownType(typeof(ExtendedRelativeUsageCycleInfo))]
    public abstract class ExtendedUsageCycleInfo : BaseObject
    {
    }

    [Serializable]
    [DataContract]
    [KnownType(typeof(RelativeUsageCycleInfo))]
    [KnownType(typeof(DailyUsageCycleInfo))]
    [KnownType(typeof(WeeklyUsageCycyleInfo))]
    [KnownType(typeof(BiWeeklyUsageCycleInfo))]
    [KnownType(typeof(SemiMonthlyUsageCycleInfo))]
    [KnownType(typeof(MonthlyUsageCycleInfo))]
    [KnownType(typeof(QuarterlyUsageCycleInfo))]
    [KnownType(typeof(SemiAnnualUsageCycleInfo))]
    [KnownType(typeof(AnnualUsageCycleInfo))]
    public abstract class UsageCycleInfo : ExtendedUsageCycleInfo
    {
    }

    [Serializable]
    [DataContract] 
    public abstract class FixedUsageCycleInfo : UsageCycleInfo
    {
        public abstract CycleType GetCycleType();
    }

    [Serializable]
    [DataContract]
    public class ExtendedRelativeUsageCycleInfo : ExtendedUsageCycleInfo
    {
        #region ExtendedUsageCycle
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isExtendedUsageCycleDirty = false;
        private ExtendedCycleType m_ExtendedUsageCycle;
        [MTDataMember(Description = "This is the EBCR cycle type", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ExtendedCycleType ExtendedUsageCycle
        {
            get { return m_ExtendedUsageCycle; }
            set
            {
                m_ExtendedUsageCycle = value;
                isExtendedUsageCycleDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsExtendedUsageCycleDirty
        {
            get { return isExtendedUsageCycleDirty; }
        }
        #endregion
    }

    [Serializable]
    [DataContract]
    public class RelativeUsageCycleInfo : UsageCycleInfo
    {
        #region UsageCycleType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUsageCycleTypeDirty = false;
        private Nullable<CycleType> m_UsageCycleType;
        [MTDataMember(Description = "If set, this specifies the usage cycle the subscriber's account must have", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Nullable<CycleType> UsageCycleType
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

        #region UsageCycleType Value Display Name
        public string UsageCycleTypeValueDisplayName
        {
            get
            {
                if (this.UsageCycleType.HasValue)
                {
                    return GetDisplayName(this.UsageCycleType.Value);
                }
                else
                {
                    return string.Empty;
                }
            }
            set
            {
                this.UsageCycleType = ((CycleType)(GetEnumInstanceByDisplayName(typeof(CycleType), value)));
            }
        }
        #endregion

        #endregion
    }

    [Serializable]
    [DataContract]
    public class DailyUsageCycleInfo : FixedUsageCycleInfo
    {
        public override CycleType GetCycleType()
        {
            return CycleType.Daily;
        }
    }

    [Serializable]
    [DataContract]
    public class WeeklyUsageCycyleInfo : FixedUsageCycleInfo
    {
        public override CycleType GetCycleType()
        {
            return CycleType.Weekly;
        }

        #region DayOfWeek
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDayOfWeekDirty = false;
        private DayOfWeek m_DayOfWeek;
        [MTDataMember(Description = "This is the day of the week on which the cycle starts", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DayOfWeek DayOfWeek
        {
            get { return m_DayOfWeek; }
            set
            {
                m_DayOfWeek = value;
                isDayOfWeekDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDayOfWeekDirty
        {
            get { return isDayOfWeekDirty; }
        }
        #endregion
    }

    [Serializable]
    [DataContract]
    public class BiWeeklyUsageCycleInfo : FixedUsageCycleInfo
    {
        public override CycleType GetCycleType()
        {
            return CycleType.Bi_Weekly;
        }

        #region StartDay
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartDayDirty = false;
        private int m_StartDay;
        [MTDataMember(Description = "This is the start day for the bi-weekly interval", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int StartDay
        {
            get { return m_StartDay; }
            set
            {
                m_StartDay = value;
                isStartDayDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartDayDirty
        {
            get { return isStartDayDirty; }
        }
        #endregion

        #region StartMonth
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartMonthDirty = false;
        private int m_StartMonth;
        [MTDataMember(Description = "This is the start month of the bi-weekly interval", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int StartMonth
        {
            get { return m_StartMonth; }
            set
            {
                m_StartMonth = value;
                isStartMonthDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartMonthDirty
        {
            get { return isStartMonthDirty; }
        }
        #endregion

        #region StartYear
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartYearDirty = false;
        private int m_StartYear;
        [MTDataMember(Description = "This is the start year for the bi-weekly interval", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int StartYear
        {
            get { return m_StartYear; }
            set
            {
                m_StartYear = value;
                isStartYearDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartYearDirty
        {
            get { return isStartYearDirty; }
        }
        #endregion
    }

    [Serializable]
    [DataContract]
    public class SemiMonthlyUsageCycleInfo : FixedUsageCycleInfo
    {
        public override CycleType GetCycleType()
        {
            return CycleType.Semi_Monthly;
        }

        #region Day1
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDay1Dirty = false;
        private int m_Day1;
        [MTDataMember(Description = "This is the first day of month for the interval", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int Day1
        {
            get { return m_Day1; }
            set
            {
                m_Day1 = value;
                isDay1Dirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDay1Dirty
        {
            get { return isDay1Dirty; }
        }
        #endregion

        #region Day2
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDay2Dirty = false;
        private int m_Day2;
        [MTDataMember(Description = "This is the second day of month for the interval", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int Day2
        {
            get { return m_Day2; }
            set
            {
                m_Day2 = value;
                isDay2Dirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDay2Dirty
        {
            get { return isDay2Dirty; }
        }
        #endregion
    }

    [Serializable]
    [DataContract]
    public class MonthlyUsageCycleInfo : FixedUsageCycleInfo
    {
        public override CycleType GetCycleType()
        {
            return CycleType.Monthly;
        }

        #region EndDay
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEndDayDirty = false;
        private int m_EndDay;
        [MTDataMember(Description = "Specifies the day of month the cycle ends", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int EndDay
        {
            get { return m_EndDay; }
            set
            {
                m_EndDay = value;
                isEndDayDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsEndDayDirty
        {
            get { return isEndDayDirty; }
        }
        #endregion
    }

    [Serializable]
    [DataContract]
    public class QuarterlyUsageCycleInfo : FixedUsageCycleInfo
    {
        public override CycleType GetCycleType()
        {
            return CycleType.Quarterly;
        }

        #region StartMonth
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartMonthDirty = false;
        private int m_StartMonth;
        [MTDataMember(Description = "This specifies the start month for the cycle", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int StartMonth
        {
            get { return m_StartMonth; }
            set
            {
                m_StartMonth = value;
                isStartMonthDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartMonthDirty
        {
            get { return isStartMonthDirty; }
        }
        #endregion

        #region StartDay
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartDayDirty = false;
        private int m_StartDay;
        [MTDataMember(Description = "This specifies the start day of month for the cycle", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int StartDay
        {
            get { return m_StartDay; }
            set
            {
                m_StartDay = value;
                isStartDayDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartDayDirty
        {
            get { return isStartDayDirty; }
        }
        #endregion
    }

    [Serializable]
    [DataContract]
    public class AnnualUsageCycleInfo : FixedUsageCycleInfo
    {
        public override CycleType GetCycleType()
        {
          return CycleType.Annually; //ESR-4291 Function MetraTech.DomainModel.BaseTypes.AnnualUsageCycleInfo.GetCycleType() return wrong Cycle Type 
        }

        #region StartMonth
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartMonthDirty = false;
        private int m_StartMonth;
        [MTDataMember(Description = "This specifies the start month for the cycle", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int StartMonth
        {
            get { return m_StartMonth; }
            set
            {
                m_StartMonth = value;
                isStartMonthDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartMonthDirty
        {
            get { return isStartMonthDirty; }
        }
        #endregion

        #region StartDay
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartDayDirty = false;
        private int m_StartDay;
        [MTDataMember(Description = "This specifies the start day of month for the cycle", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int StartDay
        {
            get { return m_StartDay; }
            set
            {
                m_StartDay = value;
                isStartDayDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartDayDirty
        {
            get { return isStartDayDirty; }
        }
        #endregion
    }

    [Serializable]
    [DataContract]
    public class SemiAnnualUsageCycleInfo : FixedUsageCycleInfo
    {
      public override CycleType GetCycleType()
      {
        return CycleType.Semi_Annually; 
      }

      #region StartMonth
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isStartMonthDirty = false;
      private int m_StartMonth;
      [MTDataMember(Description = "This specifies the start month for the cycle", Length = 40)]
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      public int StartMonth
      {
        get { return m_StartMonth; }
        set
        {
          m_StartMonth = value;
          isStartMonthDirty = true;
        }
      }
      [ScriptIgnore]
      public bool IsStartMonthDirty
      {
        get { return isStartMonthDirty; }
      }
      #endregion

      #region StartDay
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isStartDayDirty = false;
      private int m_StartDay;
      [MTDataMember(Description = "This specifies the start day of month for the cycle", Length = 40)]
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      public int StartDay
      {
        get { return m_StartDay; }
        set
        {
          m_StartDay = value;
          isStartDayDirty = true;
        }
      }
      [ScriptIgnore]
      public bool IsStartDayDirty
      {
        get { return isStartDayDirty; }
      }
      #endregion
    }
}
