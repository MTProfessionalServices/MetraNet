using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
  [DataContract]
  [Serializable]
  public class ProdCatTimeSpan : BaseObject
  {
      [Serializable]
    public enum MTPCDateType
    {
      NoDate = 0,
      Absolute = 1,
      SubscriptionRelative = 2,
      NextBillingPeriod = 3,
      Null = 4
    }

    private bool isTimeSpanIdDirty = false;
    private int? m_TimeSpanId;
    [MTDataMember(Description = "This is the ID of the time span in the DB", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? TimeSpanId
    {
      get { return m_TimeSpanId; }
      set
      {
 
          m_TimeSpanId = value;
          isTimeSpanIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTimeSpanIdDirty
    {
      get { return isTimeSpanIdDirty; }
    }
      
    private bool isStartDateDirty = false;
    private DateTime? m_StartDate;
    [MTDataMember(Description = "This is the start date of the time span", Length = 40)]
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
    
    private bool isStartDateTypeDirty = false;
    private MTPCDateType m_StartDateType = MTPCDateType.Null;
    [MTDataMember(Description = "This is the enumeration that indicates the start date type", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public MTPCDateType StartDateType
    {
      get { return m_StartDateType; }
      set
      {
 
          m_StartDateType = value;
          isStartDateTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartDateTypeDirty
    {
      get { return isStartDateTypeDirty; }
    }
    
    private bool isStartDateOffsetDirty = false;
    private int? m_StartDateOffset;
    [MTDataMember(Description = "This is the offset on the start date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? StartDateOffset
    {
      get { return m_StartDateOffset; }
      set
      {
 
          m_StartDateOffset = value;
          isStartDateOffsetDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartDateOffsetDirty
    {
      get { return isStartDateOffsetDirty; }
    }
    
    private bool isEndDateDirty = false;
    private DateTime? m_EndDate;
    [MTDataMember(Description = "This is the end date of the time span", Length = 40)]
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
    
    private bool isEndDateTypeDirty = false;
    private MTPCDateType m_EndDateType = MTPCDateType.Null;
    [MTDataMember(Description = "This is the type of the end date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public MTPCDateType EndDateType
    {
      get { return m_EndDateType; }
      set
      {
 
          m_EndDateType = value;
          isEndDateTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEndDateTypeDirty
    {
      get { return isEndDateTypeDirty; }
    }
    
    private bool isEndDateOffsetDirty = false;
    private int? m_EndDateOffset;
    [MTDataMember(Description = "This is the offset for the end date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? EndDateOffset
    {
      get { return m_EndDateOffset; }
      set
      {
 
          m_EndDateOffset = value;
          isEndDateOffsetDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEndDateOffsetDirty
    {
      get { return isEndDateOffsetDirty; }
    }
      
  }
}
