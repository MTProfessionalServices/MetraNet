using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class IntersectionSlice : TimeSlice
    {
        #region LeftHandSide
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isLeftHandSideDirty = false;
        private TimeSlice m_LeftHandSide;
        [MTDataMember(Description = "This is the left hand side parameter.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]  
        public TimeSlice LeftHandSide
        {
          get { return m_LeftHandSide; }
          set
          {
              m_LeftHandSide = value;
              isLeftHandSideDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsLeftHandSideDirty
        {
          get { return isLeftHandSideDirty; }
        }
        #endregion

        #region RighHandSide
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isRighHandSideDirty = false;
        private TimeSlice m_RighHandSide;
        [MTDataMember(Description = "This is the right hand side parameter.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TimeSlice RighHandSide
        {
          get { return m_RighHandSide; }
          set
          {
              m_RighHandSide = value;
              isRighHandSideDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsRighHandSideDirty
        {
          get { return isRighHandSideDirty; }
        }
        #endregion
    }
}