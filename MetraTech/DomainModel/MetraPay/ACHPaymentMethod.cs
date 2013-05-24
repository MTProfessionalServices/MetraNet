using System;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.MetraPay
{
  [DataContract]
  [Serializable]
  public class ACHPaymentMethod : MetraPaymentMethod
  {
    public override PaymentType PaymentMethodType
    {
      get { return PaymentType.ACH; }
    }
    
    #region AccountType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isAccountTypeDirty = false;
    [MTDirtyProperty("IsAccountTypeDirty")]
    protected BankAccountType m_AccountType;
    [MTDataMember(Description = "This is the type of bank account being accessed", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public BankAccountType AccountType
    {
      get { return m_AccountType; }
      set
      {
        m_AccountType = value;
        isAccountTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAccountTypeDirty
    {
      get { return isAccountTypeDirty; }
    }
    #endregion
      
    #region RoutingNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isRoutingNumberDirty = false;
    [MTDirtyProperty("IsRoutingNumberDirty")]
    protected string m_RoutingNumber;
    [MTDataMember(Description = "This is the routing number for the bank", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string RoutingNumber
    {
      get { return m_RoutingNumber; }
      set
      {
        m_RoutingNumber = value;
        isRoutingNumberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRoutingNumberDirty
    {
      get { return isRoutingNumberDirty; }
    }
    #endregion

    #region BankName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isBankNameDirty = false;
    [MTDirtyProperty("IsBankNameDirty")]
    protected string m_BankName;
    [MTDataMember(Description = "This is the name of the bank", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string BankName
    {
      get { return m_BankName; }
      set
      {
        m_BankName = value;
        isBankNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsBankNameDirty
    {
      get { return isBankNameDirty; }
    }
    #endregion

    #region BankAddress
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isBankAddressDirty = false;
    [MTDirtyProperty("IsBankaddressDirty")]
    protected string m_BankAddress;
    [MTDataMember(Description = "This is the address of the bank", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string BankAddress
    {
      get { return m_BankAddress; }
      set
      {
        m_BankAddress = value;
        isBankAddressDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsBankAddressDirty
    {
      get { return isBankAddressDirty; }
    }
    #endregion

    #region BankCity
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isBankCityDirty = false;
    [MTDirtyProperty("IsBankCityDirty")]
    protected string m_BankCity;
    [MTDataMember(Description = "This is the bank city", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string BankCity
    {
      get { return m_BankCity; }
      set
      {

        m_BankCity = value;
        isBankCityDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsBankCityDirty
    {
      get { return isBankCityDirty; }
    }
    #endregion

    #region BankState
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isBankStateDirty = false;
    [MTDirtyProperty("IsBankStateDirty")]
    protected string m_BankState;
    [MTDataMember(Description = "This is the bank state", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string BankState
    {
      get { return m_BankState; }
      set
      {

        m_BankState = value;
        isBankStateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsBankStateDirty
    {
      get { return isBankStateDirty; }
    }
    #endregion

    #region BankZipCode
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isBankZipCodeDirty = false;
    [MTDirtyProperty("IsBankZipCodeDirty")]
    protected string m_BankZipCode;
    [MTDataMember(Description = "This is the bank zip-code", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string BankZipCode
    {
      get { return m_BankZipCode; }
      set
      {

        m_BankZipCode = value;
        isBankZipCodeDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsBankZipCodeDirty
    {
      get { return isBankZipCodeDirty; }
    }
    #endregion

    #region BankCountry
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isBankCountryDirty = false;
    [MTDirtyProperty("IsBankCountryDirty")]
    protected PaymentMethodCountry m_BankCountry;
    [MTDataMember(Description = "This is the country of the bank", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public PaymentMethodCountry BankCountry
    {
      get { return m_BankCountry; }
      set
      {

        m_BankCountry = value;
        isBankCountryDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsBankCountryDirty
    {
      get { return isBankCountryDirty; }
    }
    #endregion
    protected override string GetUniqueAccountNumber()
    {
      return string.Format("{0}_{1}", m_RoutingNumber, m_AccountNumber);
    }
  }
}
