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
    /// This class provides a mapping between a product view and an AmountChain.
    /// This mapping is used within the AMP engine.
    /// </summary>
  [DataContract]
  [Serializable]
  public class PvToAmountChainMapping : BaseObject
  {
    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    /// <summary>
    /// Unique name assigned to this mapping from a product view to an amount chain
    /// </summary>
    [MTDataMember(Description = "Unique name assigned to this mapping from a product view to an amount chain", Length = 40)]
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
    /// description of this mapping from a product view to an amount chain
    /// </summary>
    [MTDataMember(Description = "description of this mapping from a product view to an amount chain", Length = 40)]
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
    /// Unique identifier assigned to this mapping from product view to amount chain
    /// when it is inserted in the DB.
    /// </summary>
    [MTDataMember(Description = "Unique id assigned to this mapping from product view to amount chain when it is inserted in the DB", Length = 40)]
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
    /// Name of a product view
    /// </summary>
    [MTDataMember(Description = "Name of a product view", Length = 40)]
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

    #region AmountChainUniqueId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountChainUniqueIdDirty = false;
    private Guid m_AmountChainUniqueId;
    /// <summary>
    /// Unique ID of the amount chain that is associated with the specified
    /// product view.
    /// </summary>
    [MTDataMember(Description = "Unique ID of the amount chain that is associated with the specified pv", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid AmountChainUniqueId
    {
      get { return m_AmountChainUniqueId; }
      set
      {
          m_AmountChainUniqueId = value;
          isAmountChainUniqueIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAmountChainUniqueIdDirty
    {
      get { return isAmountChainUniqueIdDirty; }
    }
    #endregion
  }
}
