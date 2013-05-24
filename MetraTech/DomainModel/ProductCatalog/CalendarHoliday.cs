using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class CalendarHoliday : CalendarDay
    {
        #region HolidayID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isHolidayIDDirty = false;
        private int? m_HolidayID;
        [MTDataMember(Description = "This is the internal identifier of the holiday instance", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int? HolidayID
        {
            get { return m_HolidayID; }
            set
            {
                m_HolidayID = value;
                isHolidayIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsHolidayIDDirty
        {
            get { return isHolidayIDDirty; }
        }
        #endregion

        #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the holiday. ", Length = 40)]
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

        #region Date
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDateDirty = false;
    private DateTime m_Date;
    [MTDataMember(Description = "This is the date for the holiday.  Any time period information in the DateTime structure will be ignored. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime Date
    {
      get { return m_Date; }
      set
      {
          m_Date = value;
          isDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDateDirty
    {
      get { return isDateDirty; }
    }
    #endregion
    }
}
