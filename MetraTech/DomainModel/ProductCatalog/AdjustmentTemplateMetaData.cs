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
using System.Runtime.Serialization;
using System.Text;
//MetraTech
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Adjustments;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class AdjustmentTemplateMetaData : BaseObject
    {
        #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int  m_ID;
    [MTDataMember(Description = "ID for the Adjustment Template ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int  ID
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
    private string  m_Name;
    [MTDataMember(Description = "Name of the Adjustment Template", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string  Name
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
    [MTDataMember(Description = "Display Name of the templae", Length = 40)]
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

        #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "Description of the Adjustment Template", Length = 40)]
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
        #region SupportsBulk
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSupportsBulkDirty = false;
    private bool m_SupportsBulk;
    [MTDataMember(Description = "Template supports bulk transactions", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool SupportsBulk
    {
      get { return m_SupportsBulk; }
      set
      {
          m_SupportsBulk = value;
          isSupportsBulkDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsSupportsBulkDirty
    {
      get { return isSupportsBulkDirty; }
    }
    #endregion

        #region Kind
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isKindDirty = false;
    private AdjustmentKind m_Kind;
    [MTDataMember(Description = "Enum specifies type of adjustment", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public AdjustmentKind Kind
    {
      get { return m_Kind; }
      set
      {
          m_Kind = value;
          isKindDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsKindDirty
    {
      get { return isKindDirty; }
    }
    #endregion

        #region RequiredInputs
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRequiredInputsDirty = false;
    private AdjustmentInput m_RequiredInputs;
    [MTDataMember(Description = "Input for the Adjustment", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public AdjustmentInput RequiredInputs
    {
      get { return m_RequiredInputs; }
      set
      {
          m_RequiredInputs = value;
          isRequiredInputsDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsRequiredInputsDirty
    {
      get { return isRequiredInputsDirty; }
    }
    #endregion

        #region ReasonCodes
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReasonCodesDirty = false;
    private List<AdjustmentReasonCode>  m_ReasonCodes;
    [MTDataMember(Description = "List Reason Codes Instances", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<AdjustmentReasonCode>  ReasonCodes
    {
      get { return m_ReasonCodes; }
      set
      {
          m_ReasonCodes = new List<AdjustmentReasonCode>();

          m_ReasonCodes = value;
          isReasonCodesDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsReasonCodesDirty
    {
      get { return isReasonCodesDirty; }
    }
    #endregion

    }
}
