using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;

using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class InvoiceAccount : BaseObject
    {
        #region ID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIDDirty = false;
        private int m_ID;
        [MTDataMember(Description = "This is the account identifier", Length = 40)]
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

        #region ExternalID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isExternalIDDirty = false;
        private string m_ExternalID;
        [MTDataMember(Description = "This is the external identifier for the account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ExternalID
        {
          get { return m_ExternalID; }
          set
          {
              m_ExternalID = value;
              isExternalIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsExternalIDDirty
        {
          get { return isExternalIDDirty; }
        }
        #endregion

        #region FirstName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isFirstNameDirty = false;
        private string m_FirstName;
        [MTDataMember(Description = "This is the first name designated on the account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string FirstName
        {
          get { return m_FirstName; }
          set
          {
              m_FirstName = value;
              isFirstNameDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsFirstNameDirty
        {
          get { return isFirstNameDirty; }
        }
        #endregion

        #region LastName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isLastNameDirty = false;
        private string m_LastName;
        [MTDataMember(Description = "This is the last name designated on the account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string LastName
        {
          get { return m_LastName; }
          set
          {
              m_LastName = value;
              isLastNameDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsLastNameDirty
        {
          get { return isLastNameDirty; }
        }
        #endregion

        #region MiddleInitial
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isMiddleInitialDirty = false;
        private string m_MiddleInitial;
        [MTDataMember(Description = "This is the middle initial designated on the account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string MiddleInitial
        {
          get { return m_MiddleInitial; }
          set
          {
              m_MiddleInitial = value;
              isMiddleInitialDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsMiddleInitialDirty
        {
          get { return isMiddleInitialDirty; }
        }
        #endregion

        #region Company
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCompanyDirty = false;
        private string m_Company;
        [MTDataMember(Description = "This is the company designated on the account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Company
        {
          get { return m_Company; }
          set
          {
              m_Company = value;
              isCompanyDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsCompanyDirty
        {
          get { return isCompanyDirty; }
        }
        #endregion

        #region Address1
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAddress1Dirty = false;
        private string m_Address1;
        [MTDataMember(Description = "This is the first address field.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Address1
        {
          get { return m_Address1; }
          set
          {
              m_Address1 = value;
              isAddress1Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAddress1Dirty
        {
          get { return isAddress1Dirty; }
        }
        #endregion

        #region Address2
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAddress2Dirty = false;
        private string m_Address2;
        [MTDataMember(Description = "This is the second address field.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Address2
        {
            get { return m_Address2; }
            set
            {
                m_Address2 = value;
                isAddress2Dirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAddress2Dirty
        {
            get { return isAddress2Dirty; }
        }
        #endregion

        #region Address3
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAddress3Dirty = false;
        private string m_Address3;
        [MTDataMember(Description = "This is the third address field.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Address3
        {
            get { return m_Address3; }
            set
            {
                m_Address3 = value;
                isAddress3Dirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAddress3Dirty
        {
            get { return isAddress3Dirty; }
        }
        #endregion

        #region City
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCityDirty = false;
        private string m_City;
        [MTDataMember(Description = "This is the city field.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string City
        {
            get { return m_City; }
            set
            {
                m_City = value;
                isCityDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCityDirty
        {
            get { return isCityDirty; }
        }
        #endregion

        #region State
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStateDirty = false;
        private string m_State;
        [MTDataMember(Description = "This is the state field.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string State
        {
            get { return m_State; }
            set
            {
                m_State = value;
                isStateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStateDirty
        {
            get { return isStateDirty; }
        }
        #endregion

        #region Zip
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isZipDirty = false;
        private string m_Zip;
        [MTDataMember(Description = "This is the zip or postal code field.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Zip
        {
            get { return m_Zip; }
            set
            {
                m_Zip = value;
                isZipDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsZipDirty
        {
            get { return isZipDirty; }
        }
        #endregion

        #region Country
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCountryDirty = false;
        private Nullable<CountryName> m_Country;
        [MTDataMember(Description = "This is the contry designated on the account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Nullable<CountryName> Country
        {
          get { return m_Country; }
          set
          {
              m_Country = value;
              isCountryDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsCountryDirty
        {
          get { return isCountryDirty; }
        }
        #endregion

        #region Country Value Display Name
        public string CountryValueDisplayName
        {
          get
          {
              if (Country.HasValue)
              {
                  return GetDisplayName(this.Country.Value);
          }
              else
              {
                  return "";
              }
          }
          set
          {
            this.Country = ((CountryName)(GetEnumInstanceByDisplayName(typeof(CountryName), value)));
          }
        }
        #endregion
    
    }
}