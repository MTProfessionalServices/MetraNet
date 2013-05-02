
// Generated on 8/19/2009 1:40:15 AM from entityClass.tt

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity;
using MetraTech.Basic;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core;

namespace MetraTech.BusinessEntity.OrderManagement
{
  [DataContract(IsReference = true)]
  [ConfigDriven]
  [Serializable]
  public partial class OrderItem : DataObject
  {
    #region Basic Properties
    private System.String  _itemReference;
    [BusinessKey]
  
    [DataMember]
    public virtual System.String ItemReference
    {
      get { return _itemReference; }
      set { _itemReference = value; }
    }
    private System.String  _description;
  
    [DataMember]
    public virtual System.String Description
    {
      get { return _description; }
      set { _description = value; }
    }
    #endregion 
	
    #region Navigation Properties
    private Order  _order;
    [DataMember]
    public virtual Order Order
    {
      get { return _order; }
      set { _order = value; }
    }
    private IList< Product > _products = new List< Product >();
    [DataMember]
    public virtual IList< Product > Products
    {
      get { return _products; }
      protected set { _products = value; }
    }
    #endregion
  }
}

