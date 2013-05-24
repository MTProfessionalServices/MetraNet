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
  public class Subscription : BaseObject
  {
    #region SubscriptionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSubscriptionIdDirty = false;
    private int? m_SubscriptionId;
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

    #region ProductOfferingId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProductOfferingIdDirty = false;
    private int m_ProductOfferingId;
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

    #region Product Offering
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProductOfferingDirty = false;
    private ProductOffering m_ProductOffering;
    [MTDataMember(Description = "This is the object that contains the Product Offering details", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ProductOffering ProductOffering
    {
      get { return m_ProductOffering; }
      set
      {
 
          m_ProductOffering = value;
          isProductOfferingDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsProductOfferingDirty
    {
      get { return isProductOfferingDirty; }
    }
    #endregion

    #region SubscriptionSpan
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSubscriptionSpanDirty = false;
    private ProdCatTimeSpan m_SubscriptionSpan = new ProdCatTimeSpan();
    [MTDataMember(Description = "This is the time span for the subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ProdCatTimeSpan SubscriptionSpan
    {
      get { return m_SubscriptionSpan; }
      set
      {
 
          m_SubscriptionSpan = value;
          isSubscriptionSpanDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSubscriptionSpanDirty
    {
      get { return isSubscriptionSpanDirty; }
    }
    #endregion

    #region WarnOnEBCRStartDateChange
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isWarnOnEBCRStartDateChangeDirty = false;
    private bool? m_WarnOnEBCRStartDateChange;
    [MTDataMember(Description = "", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? WarnOnEBCRStartDateChange
    {
      get { return m_WarnOnEBCRStartDateChange; }
      set
      {
 
          m_WarnOnEBCRStartDateChange = value;
          isWarnOnEBCRStartDateChangeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsWarnOnEBCRStartDateChangeDirty
    {
      get { return isWarnOnEBCRStartDateChangeDirty; }
    }
    #endregion
    
    #region UDRCValues
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUDRCValuesDirty = false;
    private Dictionary<string, List<UDRCInstanceValue>> m_UDRCValues;
    [MTDataMember(Description = "These are the temporal collections of values for UDRC instances in the PO", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<string, List<UDRCInstanceValue>> UDRCValues
    {
      get 
      {
          if (m_UDRCValues == null)
          {
              m_UDRCValues = new Dictionary<string, List<UDRCInstanceValue>>();
          }

          return m_UDRCValues; 
      }
      set
      {
          m_UDRCValues = value;
          isUDRCValuesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUDRCValuesDirty
    {
      get { return isUDRCValuesDirty; }
    }
    #endregion

    #region CharacteristicValues
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCharacteristicValuesDirty = false;
    private List<CharacteristicValue> m_CharacteristicValues;
    [MTDataMember(Description = "These are characteristic values for a subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<CharacteristicValue> CharacteristicValues
    {
      get
      {
        if (m_CharacteristicValues == null)
        {
          m_CharacteristicValues = new List<CharacteristicValue>();
        }

        return m_CharacteristicValues;
}
      set
      {
        m_CharacteristicValues = value;
        isCharacteristicValuesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCharacteristicValuesDirty
    {
      get { return isCharacteristicValuesDirty; }
    }
    #endregion
  }
}
