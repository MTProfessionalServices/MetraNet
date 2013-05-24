using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    /// <summary>
    /// An AmountChainField is a field within the amount chain.  These
    /// include the unitsOfUsage, the amount, or dependent fields.
    /// This object describes how this field is related to the amount.
    /// </summary>
  [DataContract]
  [Serializable]
  public class AmountChainField : BaseObject
  {
#region PUBLIC_ENUMS
    /// <summary>
    /// This enum defines the types of relationships that are supported
    /// by AMP.  AMP will determine the new value of the amount dependent
    /// field using this relationship.
    /// </summary>
    public enum FieldRelationshipEnum
    {
        /// <summary>
        /// The specified field is the amount
        /// </summary>
        RELATIONSHIP_AMOUNT,

        /// <summary>
        /// The specified field is the units of usage e.g. call duration in minutes
        /// </summary>
        RELATIONSHIP_UNITS_OF_USAGE,

        /// <summary>
        /// The specified field is a percentage of another field 
        /// </summary>
        RELATIONSHIP_PERCENTAGE,

        /// <summary>
        /// The specified field is proportional to another field
        /// </summary>
        RELATIONSHIP_PROPORTIONAL,

        /// <summary>
        /// The specified field is the same as another field, but in a different currency
        /// </summary>
        RELATIONSHIP_CURRENCY_CONVERSION,

        /// <summary>
        /// The specified field is a constant offset from another field e.g. field = amount - 20
        /// </summary>
        RELATIONSHIP_DELTA,

        /// <summary>
        /// The specified field can be computed using some 
        /// mathematical expression e.g. field = (3 * amount) + 7
        /// </summary>
        RELATIONSHIP_MODIFIER
    };

    /// <summary>
    /// This enum defines direction of the amount chain field.
    /// </summary>
    public enum FieldDirectionEnum
    {
        /// <summary>
        /// TBD
        /// </summary>
        NORMALIZE,

        /// <summary>
        /// TBD
        /// </summary>
        DENORMALIZE,

        /// <summary>
        /// TBD
        /// </summary>
        BOTH
    };
#endregion

    #region UniqueId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUniqueIdDirty = false;
    private Guid m_UniqueId;
    /// <summary>
    /// Unique identifier associated with this amount chain field.  The DB
    /// creates this ID when the amount chain field is inserted into the DB.
    /// </summary>
    [MTDataMember(Description = "Unique identifier of the amount chain field", Length = 40)]
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

    #region FieldName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFieldNameDirty = false;
    private string m_FieldName;
    /// <summary>
    /// The name of the amount dependent field.
    /// </summary>
    [MTDataMember(Description = "name of the amount dependent field", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string FieldName
    {
      get { return m_FieldName; }
      set
      {
          m_FieldName = value;
          isFieldNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFieldNameDirty
    {
      get { return isFieldNameDirty; }
    }
    #endregion

    #region ProductViewName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProductViewNameDirty = false;
    private string m_ProductViewName;
    /// <summary>
    /// The name of the ProductView where the dependent field resides.
    /// </summary>
    [MTDataMember(Description = "name of the ProductView where the dependent field resides", Length = 40)]
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

    #region FieldDirection
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFieldDirectionDirty = false;
    private FieldDirectionEnum m_FieldDirection;
    /// <summary>
    /// This value specifies the Direction between the FieldName
    /// and some other field.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public FieldDirectionEnum FieldDirection
    {
      get { return m_FieldDirection; }
      set
      {
          m_FieldDirection = value;
          isFieldDirectionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFieldDirectionDirty
    {
      get { return isFieldDirectionDirty; }
    }
    #endregion
    #region FieldRelationship
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFieldRelationshipDirty = false;
    private FieldRelationshipEnum m_FieldRelationship;
    /// <summary>
    /// This value specifies the relationship between the FieldName
    /// and some other field.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public FieldRelationshipEnum FieldRelationship
    {
      get { return m_FieldRelationship; }
      set
      {
          m_FieldRelationship = value;
          isFieldRelationshipDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFieldRelationshipDirty
    {
      get { return isFieldRelationshipDirty; }
    }
    #endregion

    #region ContributingField
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isContributingFieldDirty = false;
    private string m_ContributingField;
    /// <summary>
    /// The FieldName is dependent on the ContributingField.  For example,
    /// if the FieldRelationship is proportional, and the contributing field is "amount",
    /// then the FieldName is proportional to amount.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ContributingField
    {
      get { return m_ContributingField; }
      set
      {
          m_ContributingField = value;
          isContributingFieldDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsContributingFieldDirty
    {
      get { return isContributingFieldDirty; }
    }
    #endregion

    #region PercentageValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPercentageValueDirty = false;
    private decimal? m_PercentageValue;
    /// <summary>
    /// This member contains a hard coded value for the percentage.
    /// It should only be set when the relationship is a percentage.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal? PercentageValue
    {
      get { return m_PercentageValue; }
      set
      {
          m_PercentageValue = value;
          isPercentageValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPercentageValueDirty
    {
      get { return isPercentageValueDirty; }
    }
    #endregion

    #region PercentageColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPercentageColumnNameDirty = false;
    private string m_PercentageColumnName;
    /// <summary>
    /// This member holds a column name that holds the percentage.
    /// It should only be set when the relationship is a percentage.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PercentageColumnName
    {
      get { return m_PercentageColumnName; }
      set
      {
          m_PercentageColumnName = value;
          isPercentageColumnNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPercentageColumnNameDirty
    {
      get { return isPercentageColumnNameDirty; }
    }
    #endregion

    #region CurrencyValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCurrencyValueDirty = false;
    private string m_CurrencyValue;
    /// <summary>
    /// This member contains a hard coded value for the currency of the FieldName.
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
    /// This member holds a column name that holds the currency of the FieldName.
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

    #region Modifier
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isModifierDirty = false;
    private string m_Modifier;
    /// <summary>
    /// This member holds a string containing a mathematical expression
    /// written in MVM language.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Modifier
    {
      get { return m_Modifier; }
      set
      {
          m_Modifier = value;
          isModifierDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsModifierDirty
    {
      get { return isModifierDirty; }
    }
    #endregion

    #region Filter
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFilterDirty = false;
    private string m_Filter;
    /// <summary>
    /// This member holds a string containing a filter written in MVM language.
    /// If this filter evaluates to false, FieldName will not be updated.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Filter
    {
      get { return m_Filter; }
      set
      {
          m_Filter = value;
          isFilterDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFilterDirty
    {
      get { return isFilterDirty; }
    }
    #endregion

    #region Rounding
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRoundingDirty = false;
    private AmountChain.RoundingOptionsEnum? m_Rounding;
    /// <summary>
    /// The type of rounding that should be used after computing the dependent field.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public AmountChain.RoundingOptionsEnum? Rounding
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
    /// If the Rounding is ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS,
    /// then round FieldName so that it only contains this number
    /// of digits after the decimal point.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
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

    #region Priority
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPriorityDirty = false;
    private int? m_Priority;
    /// <summary>
    /// Use this value to order the amount dependent fields.
    /// </summary>
    [MTDataMember(Description = "Use this value to order the amount dependent fields", Length = 40)]
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
  }
}
