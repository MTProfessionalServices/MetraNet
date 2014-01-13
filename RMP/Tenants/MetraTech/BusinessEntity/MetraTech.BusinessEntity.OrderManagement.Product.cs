
// Generated on 8/19/2009 1:40:16 AM from entityClass.tt

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
  public partial class Product : DataObject
  {
    #region Basic Properties
    private System.String  _referenceNumber;
    [BusinessKey]
  
    [DataMember]
    public virtual System.String ReferenceNumber
    {
      get { return _referenceNumber; }
      set { _referenceNumber = value; }
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
    private OrderItem  _orderItem;
    [DataMember]
    public virtual OrderItem OrderItem
    {
      get { return _orderItem; }
      set { _orderItem = value; }
    }
    #endregion
  }
}

