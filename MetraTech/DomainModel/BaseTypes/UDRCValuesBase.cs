using System;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.BaseTypes
{
  [DataContract]
  [Serializable]
  public class UDRCInstanceValueBase : BaseObject, ICloneable
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
      UDRCInstanceValueBase retval = new UDRCInstanceValueBase();

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
