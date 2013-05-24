using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    /// <summary>
    /// AmountChain is a class that describes the "food chain" of the specified amount field.
    /// Therefore, it contains fields that affect the amount, and fields that are derived from amount.
    /// Information about the AmountChain is stored in the tables:
    /// t_amp_amountchain
    /// t_amp_amountchainfield
    /// </summary>
  [DataContract]
  [Serializable]
  public class AmountChain : BaseObject
  {
    #region Enums
    /// <summary>
    /// This enum defines the type of rounding that should be used
    /// when updating fields that depend on amount.
    /// </summary>
    public enum RoundingOptionsEnum
    {
        /// <summary>
        /// Don't perform any rounding
        /// </summary>
        NO_ROUNDING,

        /// <summary>
        /// Round to the currency of the target field
        /// </summary>
        ROUND_TO_CURRENCY,

        /// <summary>
        /// Round to a specified number of digits
        /// </summary>
        ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS
    };
    #endregion

    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    /// <summary>
    /// Unique name of this amount chain specified when it was created
    /// </summary>
    [MTDataMember(Description = "Unique name of the amount chain", Length = 40)]
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

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    /// <summary>
    /// A sentence or two describing this amount chain
    /// </summary>
    [MTDataMember(Description = "Description of the amount chain", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Description
    {
      get { return m_Description; }
      set
      {
          m_Description = value;
          isDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDescriptionDirty
    {
      get { return isDescriptionDirty; }
    }
    #endregion

    #region UniqueId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUniqueIdDirty = false;
    private Guid m_UniqueId;
    /// <summary>
    /// Unique identifier associated with this amount chain.  The DB
    /// creates this ID when the amount chain is inserted into the DB.
    /// </summary>
    [MTDataMember(Description = "Unique identifier of the amount chain", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid UniqueId
    {
      get { return m_UniqueId; }
      set
      {
          m_UniqueId = value;
          isUniqueIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUniqueIdDirty
    {
      get { return isUniqueIdDirty; }
    }
    #endregion

    #region ProductViewName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProductViewNameDirty = false;
    private string m_ProductViewName;
    /// <summary>
    /// The name of the product view that is associated with this amount chain.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ProductViewName
    {
      get { return m_ProductViewName; }
      set
      {
          m_ProductViewName = value;
          isProductViewNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsProductViewNameDirty
    {
      get { return isProductViewNameDirty; }
    }
    #endregion

#if false
    #region AmountField
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountFieldDirty = false;
    private string m_AmountField;
    /// <summary>
    /// Column within the PV/t_acc_usage that holds the amount
    /// </summary>
    [MTDataMember(Description = "Column within the PV/t_acc_usage that holds the amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AmountField
    {
      get { return m_AmountField; }
      set
      {
          m_AmountField = value;
          isAmountFieldDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAmountFieldDirty
    {
      get { return isAmountFieldDirty; }
    }
    #endregion

    #region CurrencyValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCurrencyValueDirty = false;
    private string m_CurrencyValue;
    /// <summary>
    /// Hard coded value for the currency of the "amount" e.g. "USD"
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string CurrencyValue
    {
      get { return m_CurrencyValue; }
      set
      {
          m_CurrencyValue = value;
          isCurrencyValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCurrencyValueDirty
    {
      get { return isCurrencyValueDirty; }
    }
    #endregion

    #region CurrencyColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCurrencyColumnNameDirty = false;
    private string m_CurrencyColumnName;
    /// <summary>
    /// The column name that specifies the currency of the amount.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string CurrencyColumnName
    {
      get { return m_CurrencyColumnName; }
      set
      {
          m_CurrencyColumnName = value;
          isCurrencyColumnNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCurrencyColumnNameDirty
    {
      get { return isCurrencyColumnNameDirty; }
    }
    #endregion

    #region UnitsOfUsage
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUnitsOfUsageDirty = false;
    private string m_UnitsOfUsage;
    /// <summary>
    /// The column name within the specified product view that specifies
    /// the units of usage.  An example is "c_durationMinutes" in a 
    /// product view related to conference calls.  Then, the charge for
    /// a conference call is:  charge = unitsOfUsage * rate.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UnitsOfUsage
    {
      get { return m_UnitsOfUsage; }
      set
      {
          m_UnitsOfUsage = value;
          isUnitsOfUsageDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUnitsOfUsageDirty
    {
      get { return isUnitsOfUsageDirty; }
    }
    #endregion
#endif

    #region UseTaxAdapter
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUseTaxAdapterDirty = false;
    private bool? m_UseTaxAdapter;
    /// <summary>
    /// Set this to true if this amount chain should compute taxes
    /// using the tax adapter.  Then, the taxes, which are derived from
    /// the amount will be automatically updated using the tax adapter.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? UseTaxAdapter
    {
      get { return m_UseTaxAdapter; }
      set
      {
          m_UseTaxAdapter = value;
          isUseTaxAdapterDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUseTaxAdapterDirty
    {
      get { return isUseTaxAdapterDirty; }
    }
    #endregion

#if false
    #region Rounding
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRoundingDirty = false;
    private RoundingOptionsEnum? m_Rounding;
    /// <summary>
    /// The type of rounding that should be used when computing taxes.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public RoundingOptionsEnum? Rounding
    {
      get { return m_Rounding; }
      set
      {
          m_Rounding = value;
          isRoundingDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRoundingDirty
    {
      get { return isRoundingDirty; }
    }
    #endregion

    #region RoundingNumDigits
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRoundingNumDigitsDirty = false;
    private int? m_RoundingNumDigits;
    /// <summary>
    /// When the value of Rounding is ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS,
    /// this field holds the number of digits.
    /// </summary>
    [MTDataMember(Description = "number of digits to round to", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? RoundingNumDigits
    {
      get { return m_RoundingNumDigits; }
      set
      {
          m_RoundingNumDigits = value;
          isRoundingNumDigitsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRoundingNumDigitsDirty
    {
      get { return isRoundingNumDigitsDirty; }
    }
    #endregion
#endif

    #region AmountChainFields
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountChainFieldsDirty = false;
    private List<AmountChainField> m_AmountChainFields;
    /// <summary>
    /// This is the ordered list of fields that are dependent on the amount field.
    /// The order of dependencies must be controled by the configuration and maintained.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<AmountChainField> AmountChainFields
    {
        get { return m_AmountChainFields; }
        set
        {
            m_AmountChainFields = value;
            isAmountChainFieldsDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsAmountChainFieldsDirty
    {
        get { return isAmountChainFieldsDirty; }
    }
    #endregion
  }
}
