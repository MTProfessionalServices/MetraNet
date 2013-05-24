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
    /// One of the action options for an AMP decision is to generate a new
    /// charge.  This action involves creating a new row in t_acc_usage and 
    /// t_pv_*, and populating those rows.  This object contains the 
    /// information necessary to fill a new row in t_acc_usage and t_pv_*.
    /// </summary>
  [DataContract]
  [Serializable]
  public class GeneratedCharge : BaseObject
  {
    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "Unique name of the generated charge", Length = 40)]
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
    [MTDataMember(Description = "Description of the generated charge", Length = 40)]
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
    [MTDataMember(Description = "Unique identifier of the generated charge", Length = 40)]
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

    #region AmountChainName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountChainNameDirty = false;
    private string m_AmountChainName;
    /// <summary>
    /// This is a reference to an amount chain that will be denormalized 
    /// when the charge generation is completed to ensure that all the 
    /// cascading amount fields are set appropriately once the master 
    /// amount has been set.
    /// TBD Should we allow more than one amountChain?
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AmountChainName
    {
      get { return m_AmountChainName; }
      set
      {
          m_AmountChainName = value;
          isAmountChainNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAmountChainNameDirty
    {
      get { return isAmountChainNameDirty; }
    }
    #endregion

    #region ProductViewName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProductViewNameDirty = false;
    private string m_ProductViewName;
    /// <summary>
    /// This defines the product view into which the generated charge 
    /// should be inserted.
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

    #region GeneratedChargeDirectives
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isGeneratedChargeDirectivesDirty = false;
    private List<GeneratedChargeDirective> m_GeneratedChargeDirectives;
    /// <summary>
    /// This is the ordered list of directives that will be executed
    /// to fill the columns of the product view associated with a
    /// generated charge.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<GeneratedChargeDirective> GeneratedChargeDirectives
    {
        get { return m_GeneratedChargeDirectives; }
        set
        {
            m_GeneratedChargeDirectives = value;
            isGeneratedChargeDirectivesDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsGeneratedChargeDirectivesDirty
    {
        get { return isGeneratedChargeDirectivesDirty; }
    }
    #endregion
  }
}
