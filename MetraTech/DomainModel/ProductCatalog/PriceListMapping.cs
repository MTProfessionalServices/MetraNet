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
  public class PriceListMapping : BaseObject
  {
    #region priceListID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPriceListIDDirty = false;
    private int m_priceListID;
    [MTDataMember(Description = "This is the id of the pricelist", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int priceListID
    {
      get { return m_priceListID; }
      set
      {

        m_priceListID = value;
        isPriceListIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPriceListIDDirty
    {
      get { return isPriceListIDDirty; }
    }
    #endregion

    #region SharedPriceList
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSharedPriceListDirty = false;
    private bool? m_SharedPriceList;
    [MTDataMember(Description = "This Boolean value represents whether it is a shared pricelist or a non-shared pricelist.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? SharedPriceList
    {
      get { return m_SharedPriceList; }
      set
      {

        m_SharedPriceList = value;
        isSharedPriceListDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSharedPriceListDirty
    {
      get { return isSharedPriceListDirty; }
    }
    #endregion

    #region piInstanceID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPiInstanceIDDirty = false;
    private int m_piInstanceID;
    [MTDataMember(Description = "This is the priceable item instance id.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int piInstanceID
    {
      get { return m_piInstanceID; }
      set
      {

        m_piInstanceID = value;
        isPiInstanceIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPiInstanceIDDirty
    {
      get { return isPiInstanceIDDirty; }
    }
    #endregion

    #region paramTableDefID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParamTableDefIDDirty = false;
    private int m_paramTableDefID;
    [MTDataMember(Description = "This is the id of the parameter table definition.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int paramTableDefID
    {
      get { return m_paramTableDefID; }
      set
      {

        m_paramTableDefID = value;
        isParamTableDefIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParamTableDefIDDirty
    {
      get { return isParamTableDefIDDirty; }
    }
    #endregion

    #region CanICB
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCanICBDirty = false;
    private bool? m_CanICB;
    [MTDataMember(Description = "This Boolean value represents if a particular pricelist allows individual case based (ICB) rates.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? CanICB
    {
      get { return m_CanICB; }
      set
      {

        m_CanICB = value;
        isCanICBDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCanICBDirty
    {
      get { return isCanICBDirty; }
    }
    #endregion
  }
}
