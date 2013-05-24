using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
  [DataContract]
  [Serializable]
  public class UDRCInstance : RecurringCharge
  {
    #region IsIntegerValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsIntegerValueDirty = false;
    private bool m_IsIntegerValue;
    [MTDataMember(Description = "This indicates whether the UDRC instance has integer values", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool IsIntegerValue
    {
      get { return m_IsIntegerValue; }
      set
      {
 
          m_IsIntegerValue = value;
          isIsIntegerValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIsIntegerValueDirty
    {
      get { return isIsIntegerValueDirty; }
    }
    #endregion
    
    #region MinValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMinValueDirty = false;
    private decimal m_MinValue;
    [MTDataMember(Description = "This is the mininum allowable value for the UDRC instance", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal MinValue
    {
      get { return m_MinValue; }
      set
      {
 
          m_MinValue = value;
          isMinValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMinValueDirty
    {
      get { return isMinValueDirty; }
    }
    #endregion
    
    #region MaxValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMaxValueDirty = false;
    private decimal m_MaxValue;
    [MTDataMember(Description = "This is the maximum allowable value for the UDRC instance", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal MaxValue
    {
      get { return m_MaxValue; }
      set
      {
 
          m_MaxValue = value;
          isMaxValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMaxValueDirty
    {
      get { return isMaxValueDirty; }
    }
    #endregion

    #region UnitValueEnumeration
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUnitValueEnumerationDirty = false;
    private List<decimal> m_UnitValueEnumeration;
    [MTDataMember(Description = "This is the list of allowable values for the UDRC instance", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<decimal> UnitValueEnumeration
    {
      get { return m_UnitValueEnumeration; }
      set
      {
 
          m_UnitValueEnumeration = value;
          isUnitValueEnumerationDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUnitValueEnumerationDirty
    {
      get { return isUnitValueEnumerationDirty; }
    }
    #endregion

    #region UnitName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUnitNameDirty = false;
    private string m_UnitName;
    [MTDataMember(Description = "This is the name of the unit value", Length = 40)]
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
    [MTDataMember(Description = "This is the display name of the unit value", Length = 255)]
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
  }

  [DataContract]
  [Serializable]
  public class UDRCInstanceValue : BaseObject, ICloneable
  {
    #region UDRC_Id
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUDRC_IdDirty = false;
    private int m_UDRC_Id;
    [MTDataMember(Description = "This is the identifier of the UDRC for this instance value", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int UDRC_Id
    {
      get { return m_UDRC_Id; }
      set
      {
 
          m_UDRC_Id = value;
          isUDRC_IdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUDRC_IdDirty
    {
      get { return isUDRC_IdDirty; }
    }
    #endregion
    
    #region StartDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartDateDirty = false;
    private DateTime m_StartDate = DateTime.MinValue;
    [MTDataMember(Description = "This is the start date of the UDRC instance value", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime StartDate
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
    private DateTime m_EndDate = DateTime.MaxValue;
    [MTDataMember(Description = "This is the end date for the UDRC instance value", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime EndDate
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
    
    #region Value
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isValueDirty = false;
    private decimal m_Value;
    [MTDataMember(Description = "This is the value the user entered", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal Value
    {
      get { return m_Value; }
      set
      {
 
          m_Value = value;
          isValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsValueDirty
    {
      get { return isValueDirty; }
    }
    #endregion

    #region ICloneable Members

    public object Clone()
    {
      UDRCInstanceValue retval = new UDRCInstanceValue();

      retval.UDRC_Id = UDRC_Id;
      retval.StartDate = StartDate;
      retval.EndDate = EndDate;
      retval.Value = Value;

      return retval;
    }

    #endregion

    public override string ToString()
    {
      return string.Format("ID: {0}\tStart: {1}\tEnd: {2}\tValue: {3}", UDRC_Id, StartDate, EndDate, Value);
    }
  }
}
