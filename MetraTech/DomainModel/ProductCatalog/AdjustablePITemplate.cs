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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class AdjustablePITemplate : BaseObject
    {
        #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int m_ID;
    [MTDataMember(Description = "ID of PI template", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int ID
    {
      get { return m_ID; }
      set
      {
          m_ID = value;
          isIDDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsIDDirty
    {
      get { return isIDDirty; }
    }
    #endregion
  
        #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "Name of the PI Template", Length = 40)]
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

        #region DisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDisplayNameDirty = false;
    private string m_DisplayName;
    [MTDataMember(Description = "Localized Name of PI Template", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DisplayName
    {
      get { return m_DisplayName; }
      set
      {
          m_DisplayName = value;
          isDisplayNameDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsDisplayNameDirty
    {
      get { return isDisplayNameDirty; }
    }
    #endregion

    }
}
