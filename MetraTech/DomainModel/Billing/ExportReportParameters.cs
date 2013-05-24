using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
  public class ExportReportParameters : BaseObject
  {
    #region IDParameter
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isIDParameterDirty = false;
    private int m_IDParameter;
    [MTDataMember(Description = "This the Parameter ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDParameter
    {
      get { return m_IDParameter; }
      set
      {
        m_IDParameter = value;
        isIDParameterDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDParameterDirty
    {
      get { return isIDParameterDirty; }
    }
    #endregion

    
    #region ParameterName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterNameDirty = false;
    private string m_ParameterName;
    [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterName
    {
      get { return m_ParameterName; }
      set
      {
        m_ParameterName = value;
        isParameterNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterNameDirty
    {
      get { return isParameterNameDirty; }
    }
    #endregion

    #region ParameterDescription
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterDescriptionDirty = false;
    private string m_ParameterDescription;
    [MTDataMember(Description = "This the Parameter Description..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterDescription
    {
      get { return m_ParameterDescription; }
      set
      {
        m_ParameterDescription = value;
        isParameterDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterDescriptionDirty
    {
      get { return isParameterDescriptionDirty; }
    }
    #endregion

      /*
    #region Property Display Name
    [MTPropertyLocalizationAttribute(ResourceId = " .Property",
                                   DefaultValue = " ",
                                   MTLocalizationId = " /Property",
                                     Extension = " ",
                                     LocaleSpace = " ")]
    public string PropertyDisplayName
    {
      get
      {
        return ResourceManager.GetString(" .Property");
      }
    }
    #endregion
    */
           
  }
}
