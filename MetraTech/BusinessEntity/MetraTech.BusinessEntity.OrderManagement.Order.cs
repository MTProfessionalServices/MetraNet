
// Generated on 8/19/2009 1:40:14 AM from entityClass.tt

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
  public partial class Order : DataObject
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
    //private MetraTech.DomainModel.Enums.Core.Global.CountryName  _countryName;
  
    //[DataMember]
    //public virtual MetraTech.DomainModel.Enums.Core.Global.CountryName CountryName
    //{
    //  get { return _countryName; }
    //  set { _countryName = value; }
    //}
    
    #endregion 
	
    #region Navigation Properties
    private IList< OrderItem > _orderItems = new List< OrderItem >();
    [DataMember]
    public virtual IList< OrderItem > OrderItems
    {
      get { return _orderItems; }
      protected set { _orderItems = value; }
    }
    #endregion
  }
}

