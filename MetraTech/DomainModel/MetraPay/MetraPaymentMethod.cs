using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using System.Reflection;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.BaseTypes;
using System.Diagnostics;

namespace MetraTech.DomainModel.MetraPay
{
  [DataContract]
  [Serializable]
  [KnownType(typeof(CreditCardPaymentMethod))]
  [KnownType(typeof(ACHPaymentMethod))]
  [KnownType(typeof(PurchaseCardPaymentMethod))]
  public abstract class MetraPaymentMethod : BaseObject, ICloneable, IEquatable<MetraPaymentMethod>
  {
    #region Properties
    public abstract PaymentType PaymentMethodType
    {
      get;
    }

    #region AccountNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isAccountNumberDirty = false;
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    [MTDirtyProperty("IsAccountNumberDirty")]
    protected string m_AccountNumber;

      [MTDataMember(Description = "This is the account number (a.k.a. Credit Card Number)", Length = 40)]
      public string AccountNumber
      {
          get
          {
              if (!String.IsNullOrEmpty(m_AccountNumber))
              {
                  if (!String.IsNullOrEmpty(m_SafeAccountNumber))
                  {
                      return m_SafeAccountNumber;
                  }
                  else
                  {
                      //Someone bypassed the proper set method, so call it first, then return safe accoout number
                      this.AccountNumber = m_AccountNumber;
                      return m_SafeAccountNumber;
                  }
              }
              else
              {
                  return "";
              }
          }
          set
          {
              m_AccountNumber = value;
              if (m_AccountNumber.Length > 4)
              {
                  m_SafeAccountNumber = "******" + m_AccountNumber.Substring(m_AccountNumber.Length - 4);
              }
              else
              {
                  m_SafeAccountNumber = m_AccountNumber;
              }
              isAccountNumberDirty = true;
          }
      }

      [ScriptIgnore]
    public bool IsAccountNumberDirty
    {
      get { return isAccountNumberDirty; }
    }

    #region SafeAccountNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSafeAccountNumberDirty = false;
    private String m_SafeAccountNumber;
    [MTDataMember(Description = "Stores a version of the account number with the last four digits.  The account number may be a token; this is what we display to users", Length = 140)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public String SafeAccountNumber
    {
      get { return m_SafeAccountNumber; }
      set
      {
          m_SafeAccountNumber = value;
          isSafeAccountNumberDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsSafeAccountNumberDirty
    {
      get { return isSafeAccountNumberDirty; }
    }
    #endregion

    [ScriptIgnore]
    public string RawAccountNumber
    {
      get
      {
        StackTrace trace = new StackTrace();
        StackFrame frame = trace.GetFrame(1);

        if (Assembly.GetEntryAssembly().FullName.StartsWith("MetraPayService") ||
            frame.GetMethod().DeclaringType.Name == "ElectronicPaymentServices")
        {
          return m_AccountNumber;
        } else if (Assembly.GetEntryAssembly().FullName.StartsWith("MASHostService"))
        {
          //Fake out the security checker; no reason for MASHostService to have access to this #.
          return "Not a real account #";
        }
        else
        {
          throw new InvalidOperationException("This property is not available in this context");
        }
      }
    }

    [ScriptIgnore]
    public string UniqueAccountNumber
    {
      get
      {
        StackTrace trace = new StackTrace();
        StackFrame frame = trace.GetFrame(1);

        if (Assembly.GetEntryAssembly().FullName.StartsWith("MetraPayService") ||
            frame.GetMethod().DeclaringType.Name == "ElectronicPaymentServices")
        {
          return GetUniqueAccountNumber();
        }
        else if (Assembly.GetEntryAssembly().FullName.StartsWith("MASHostService"))
        {
          //Fake out the security checker; no reason for MASHostService to have access to this #.
          return "Not a real account #";
        }
        else
        {
          throw new InvalidOperationException("This property is not available in this context");
        }
      }
    }

      [ScriptIgnore]
      public string AccountToken
      {
          get { Guid retval;
              if (Guid.TryParse(m_AccountNumber, out retval))
                  return m_AccountNumber;
              else
              {
                  return null;
              }
          }
      }
    #endregion

    #region PaymentInstrumentIDString
    //[MTDataMember(Description = "Uniquely identifies a payment instrument, converted to string", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public String PaymentInstrumentIDString
    {
      get
      {
        return m_PaymentInstrumentID.ToString();
      }
      set
      {
        //Read-only
      }
    }
    #endregion

    #region PaymentInstrumentID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isPaymentInstrumentIDDirty = false;
    [MTDirtyProperty("IsPaymentInstrumentIDDirty")]
    protected Guid m_PaymentInstrumentID = Guid.Empty;
    [MTDataMember(Description = "Uniquely identifies a payment instrument", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid PaymentInstrumentID
    {
      get { return m_PaymentInstrumentID; }
      set
      {
        m_PaymentInstrumentID = value;
        isPaymentInstrumentIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPaymentInstrumentIDDirty
    {
      get { return isPaymentInstrumentIDDirty; }
    }
    #endregion

    #region MaxChargePerCycle
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isMaxChargePerCycleDirty = false;
    [MTDirtyProperty("IsMaxChargePerCycleDirty")]
    protected decimal? m_MaxChargePerCycle;
    [MTDataMember(Description = "This specifies the maximum amount to charge per billing cycle", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? MaxChargePerCycle
    {
      get { return m_MaxChargePerCycle; }
      set
      {

        m_MaxChargePerCycle = value;
        isMaxChargePerCycleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMaxChargePerCycleDirty
    {
      get { return isMaxChargePerCycleDirty; }
    }
    #endregion

    #region Priority
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isPriorityDirty = false;
    [MTDirtyProperty("IsPriorityDirty")]
    protected int? m_Priority;
    [MTDataMember(Description = "This specifies the order in which payment methods are to be charged", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? Priority
    {
      get { return m_Priority; }
      set
      {

        m_Priority = value;
        isPriorityDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPriorityDirty
    {
      get { return isPriorityDirty; }
    }
    #endregion

    #region FirstName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isFirstNameDirty = false;
    [MTDirtyProperty("IsFirstNameDirty")]
    protected string m_FirstName;
    [MTDataMember(Description = "This is the customer's first name", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string FirstName
    {
      get { return m_FirstName; }
      set
      {
        m_FirstName = value;
        isFirstNameDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsFirstNameDirty
    {
      get { return isFirstNameDirty; }
    }
    #endregion

    #region MiddleName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isMiddleNameDirty = false;
    [MTDirtyProperty("IsMiddleNameDirty")]
    protected string m_MiddleName;
    [MTDataMember(Description = "This is the customer's middle initial", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string MiddleName
    {
      get { return m_MiddleName; }
      set
      {
        m_MiddleName = value;
        isMiddleNameDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsMiddleNameDirty
    {
      get { return isMiddleNameDirty; }
    }
    #endregion

    #region LastName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isLastNameDirty = false;
    [MTDirtyProperty("IsLastNameDirty")]
    protected string m_LastName;
    [MTDataMember(Description = "This is the customer's last name", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string LastName
    {
      get { return m_LastName; }
      set
      {
        m_LastName = value;
        isLastNameDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsLastNameDirty
    {
      get { return isLastNameDirty; }
    }
    #endregion

    #region Street
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isStreetDirty = false;
    [MTDirtyProperty("IsStreetDirty")]
    protected string m_Street;
    [MTDataMember(Description = "This is the first line of the street address", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Street
    {
      get { return m_Street; }
      set
      {
        m_Street = value;
        isStreetDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStreetDirty
    {
      get { return isStreetDirty; }
    }
    #endregion

    #region Street2
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isStreet2Dirty = false;
    [MTDirtyProperty("IsStreet2Dirty")]
    protected string m_Street2;
    [MTDataMember(Description = "This is the second line of the street address", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Street2
    {
      get { return m_Street2; }
      set
      {
        m_Street2 = value;
        isStreet2Dirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStreet2Dirty
    {
      get { return isStreet2Dirty; }
    }
    #endregion

    #region City
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isCityDirty = false;
    [MTDirtyProperty("IsCityDirty")]
    protected string m_City;
    [MTDataMember(Description = "This is the city part of the bill-to address", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string City
    {
      get { return m_City; }
      set
      {

        m_City = value;
        isCityDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsCityDirty
    {
      get { return isCityDirty; }
    }
    #endregion

    #region State
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isStateDirty = false;
    [MTDirtyProperty("IsStateDirty")]
    protected string m_State;
    [MTDataMember(Description = "This is the state component of the bill-to address", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string State
    {
      get { return m_State; }
      set
      {

        m_State = value;
        isStateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStateDirty
    {
      get { return isStateDirty; }
    }
    #endregion

    #region ZipCode
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isZipCodeDirty = false;
    [MTDirtyProperty("IsZipCodeDirty")]
    protected string m_ZipCode;
    [MTDataMember(Description = "This is the zip-code component of the bill-to address", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ZipCode
    {
      get { return m_ZipCode; }
      set
      {

        m_ZipCode = value;
        isZipCodeDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsZipCodeDirty
    {
      get { return isZipCodeDirty; }
    }
    #endregion

    #region Country
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isCountryDirty = false;
    [MTDirtyProperty("IsCountryDirty")]
    protected PaymentMethodCountry m_Country;
    [MTDataMember(Description = "This is the country component of the bill-to address", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public PaymentMethodCountry Country
    {
      get { return m_Country; }
      set
      {

        m_Country = value;
        isCountryDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsCountryDirty
    {
      get { return isCountryDirty; }
    }

    public string CountryValueDisplayName
    {
      get
      {
        return BaseObject.GetDisplayName(this.Country);
      }
    }
    #endregion

    #endregion

    #region Public Methods
    public void ApplyDirtyProperties(MetraPaymentMethod modifiedPaymentMethod)
    {
      if (this.Equals(modifiedPaymentMethod))
      {
        FieldInfo[] fields = this.GetType().GetFields(BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);

        foreach (FieldInfo field in fields)
        {
          if (field.Name.EndsWith("Dirty", true, null) || modifiedPaymentMethod.IsFieldDirty(field))
          {
            if (field.Name.CompareTo("m_AccountNumber") != 0)
            {
              field.SetValue(this, field.GetValue(modifiedPaymentMethod));
            }
            else
            {
              string newValue = (string)field.GetValue(modifiedPaymentMethod);

              if (!newValue.StartsWith("************") || string.IsNullOrEmpty(m_AccountNumber))
              {
                field.SetValue(this, newValue);
              }
            }
          }
        }
      }
      else
      {
        throw new ArgumentException("The modified payment method does not match this payment method");
      }
    }
    #endregion

    #region IEquatable<MetraPaymentMethod> Members

    public bool Equals(MetraPaymentMethod other)
    {
      bool retval = false;

      if ((this.GetType() == other.GetType() ||
            other.GetType().IsSubclassOf(this.GetType())) &&
        this.PaymentInstrumentID.Equals(other.PaymentInstrumentID))
      {
        retval = true;
      }

      return retval;
    }

    #endregion

    #region ICloneable Members

    public object Clone()
    {
      MetraPaymentMethod newPaymentMethod = null;

      newPaymentMethod = (MetraPaymentMethod)(this.GetType().Assembly.CreateInstance(this.GetType().FullName));
      newPaymentMethod.PaymentInstrumentID = this.PaymentInstrumentID;

      newPaymentMethod.ApplyDirtyProperties(this);

      return newPaymentMethod;
    }

    #endregion

    #region Protected Methods
    protected bool IsFieldDirty(FieldInfo field)
    {
      bool retval = true;

      object[] attribs = field.GetCustomAttributes(typeof(MTDirtyPropertyAttribute), false);

      if (attribs.Length > 0)
      {
        string dirtyProperty = ((MTDirtyPropertyAttribute)attribs[0]).PropertyName;

        PropertyInfo prop = this.GetType().GetProperty(dirtyProperty);

        if (prop != null)
        {
          retval = (bool)prop.GetValue(this, null);
        }
      }

      return retval;
    }

    protected virtual string GetUniqueAccountNumber()
    {
      return m_AccountNumber;
    }
    #endregion
  }


}
