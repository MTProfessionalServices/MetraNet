/**************************************************************************
* Copyright 2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/
using System;
using System.Runtime.Serialization;

using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.DataAccess
{
  [Serializable]
  [DataContract]
  public abstract class AdjustmentBase : DataObject
  {          
    [DataMember]
    public abstract Nullable<int> InternalId { get; set; }
    [DataMember]
    public abstract Nullable<int> ReasonCode { get; set; }
    [DataMember]
    public abstract string Description { get; set; }
   
  }
}
