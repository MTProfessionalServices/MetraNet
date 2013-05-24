using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.MetraPay
{
  [DataContract]
  [Serializable]
  public class PurchaseCardPaymentMethod : CreditCardPaymentMethod
  {
    #region ReferenceId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isReferenceIdDirty = false;
    [MTDirtyProperty("IsReferenceIDDirty")]
    protected string m_ReferenceId;
    [MTDataMember(Description = "This is the customer reference ID", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReferenceId
    {
      get { return m_ReferenceId; }
      set
      {
        m_ReferenceId = value;
        isReferenceIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReferenceIdDirty
    {
      get { return isReferenceIdDirty; }
    }
    #endregion

    #region VATNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isVATNumberDirty = false;
    [MTDirtyProperty("IsVATNumberDirty")]
    protected string m_VATNumber;
    [MTDataMember(Description = "This is the customer's VAT number", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string VATNumber
    {
      get { return m_VATNumber; }
      set
      {
        m_VATNumber = value;
        isVATNumberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsVATNumberDirty
    {
      get { return isVATNumberDirty; }
    }
    #endregion
  }
}