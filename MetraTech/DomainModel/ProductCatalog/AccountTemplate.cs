using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;
using System.Collections;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class AccountTemplateSubscription : BaseObject
    {
        #region ProductOfferingId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isProductOfferingIdDirty = false;
        private int? m_ProductOfferingId;
        [MTDataMember(Description = "This is the product offering of the subscription", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int? ProductOfferingId
        {
            get { return m_ProductOfferingId; }
            set
            {

                m_ProductOfferingId = value;
                isProductOfferingIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsProductOfferingIdDirty
        {
            get { return isProductOfferingIdDirty; }
        }
        #endregion

        #region GroupID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isGroupIDDirty = false;
        private int? m_GroupID;
        [MTDataMember(Description = "This is the group subscription identifier", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int? GroupID
        {
            get { return m_GroupID; }
            set
            {

                m_GroupID = value;
                isGroupIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsGroupIDDirty
        {
            get { return isGroupIDDirty; }
        }
        #endregion

        #region GroupSubName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isGroupSubNameDirty = false;
        private string m_GroupSubName;
        [MTDataMember(Description = "This is the name of the group subscription", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string GroupSubName
        {
            get { return m_GroupSubName; }
            set
            {

                m_GroupSubName = value;
                isGroupSubNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsGroupSubNameDirty
        {
            get { return isGroupSubNameDirty; }
        }
        #endregion

        #region PODisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPODisplayNameDirty = false;
        private string m_PODisplayName;
        [MTDataMember(Description = "This is the display name for the product offering specified in either ProductOfferingID or by the group sub idenfieid by GroupID", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PODisplayName
        {
            get { return m_PODisplayName; }
            set
            {
                m_PODisplayName = value;
                isPODisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPODisplayNameDirty
        {
            get { return isPODisplayNameDirty; }
        }
        #endregion

        #region StartDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartDateDirty = false;
        private DateTime m_StartDate;
        [MTDataMember(Description = "This is the start date of the subscription", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime StartDate
        {
            get { return m_StartDate; }
            set
            {

                m_StartDate = value;
                isStartDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStartDateDirty
        {
            get { return isStartDateDirty; }
        }
        #endregion

        #region EndDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEndDateDirty = false;
        private DateTime m_EndDate;
        [MTDataMember(Description = "This is the end date of the subscription", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime EndDate
        {
            get { return m_EndDate; }
            set
            {

                m_EndDate = value;
                isEndDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsEndDateDirty
        {
            get { return isEndDateDirty; }
        }
        #endregion

        public bool IsGroupSub
        {
            get { return !m_ProductOfferingId.HasValue; }
        }
    }

    public enum AccountTemplateScope
    {
        CURRENT_FOLDER = 0,
        DIRECT_DESCENDENTS = 1,
        ALL_DESCENDENTS = 2
    }

    [KnownType("KnownTypes")]
    [DataContract]
    [Serializable]
    public class AccountTemplate : BaseObject
    {
        #region ID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIDDirty = false;
        private int m_ID;
        [MTDataMember(Description = "This is the primary identifier of the template", Length = 40)]
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

        #region AccountID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAccountIDDirty = false;
        private int m_AccountID;
        [MTDataMember(Description = "This is the account on which the template is defined", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AccountID
        {
            get { return m_AccountID; }
            set
            {

                m_AccountID = value;
                isAccountIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAccountIDDirty
        {
            get { return isAccountIDDirty; }
        }
        #endregion

        #region AccountType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAccountTypeDirty = false;
        private string m_AccountType;
        [MTDataMember(Description = "This is the account type to which the template applies", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AccountType
        {
            get { return m_AccountType; }
            set
            {
                m_AccountType = value;
                isAccountTypeDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAccountTypeDirty
        {
            get { return isAccountTypeDirty; }
        }
        #endregion

        #region ApplyDefaultSecurityPolicy
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isApplyDefaultSecurityPolicyDirty = false;
        private bool m_ApplyDefaultSecurityPolicy;
        [MTDataMember(Description = "This specifies whether or not the default security policy is to be applied", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool ApplyDefaultSecurityPolicy
        {
            get { return m_ApplyDefaultSecurityPolicy; }
            set
            {

                m_ApplyDefaultSecurityPolicy = value;
                isApplyDefaultSecurityPolicyDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsApplyDefaultSecurityPolicyDirty
        {
            get { return isApplyDefaultSecurityPolicyDirty; }
        }
        #endregion

        #region CreateDt
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCreateDtDirty = false;
        private DateTime m_CreateDt;
        [MTDataMember(Description = "This is the date the template was created", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime CreateDt
        {
            get { return m_CreateDt; }
            set
            {

                m_CreateDt = value;
                isCreateDtDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCreateDtDirty
        {
            get { return isCreateDtDirty; }
        }
        #endregion

        #region Description
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDescriptionDirty = false;
        private string m_Description;
        [MTDataMember(Description = "This is the description of the template", Length = 40)]
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

        #region Name
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNameDirty = false;
        private string m_Name;
        [MTDataMember(Description = "This is the name of the template", Length = 40)]
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

        #region Properties
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPropertiesDirty = false;
        private Dictionary<string, object> m_Properties = new Dictionary<string, object>();
        [MTDataMember(Description = "This is the collection of account properties on the template", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Dictionary<string, object> Properties
        {
            get 
            {
                if (m_Properties == null)
                {
                    m_Properties = new Dictionary<string, object>();
                }

                return m_Properties; 
            }
            set
            {

                m_Properties = value;
                isPropertiesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPropertiesDirty
        {
            get { return isPropertiesDirty; }
        }
        #endregion

        #region Subscriptions
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubscriptionsDirty = false;
        private List<AccountTemplateSubscription> m_Subscriptions = new List<AccountTemplateSubscription>();
        [MTDataMember(Description = "This is the collection of subscriptions associated with the template", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<AccountTemplateSubscription> Subscriptions
        {
            get 
            {
                if (m_Subscriptions == null)
                {
                    m_Subscriptions = new List<AccountTemplateSubscription>();
                }

                return m_Subscriptions; 
            }
            set
            {

                m_Subscriptions = value;
                isSubscriptionsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubscriptionsDirty
        {
            get { return isSubscriptionsDirty; }
        }
        #endregion

        #region Known Types Method
        public static Type[] KnownTypes()
        {
            List<Type> types = new List<Type>();
            Assembly enumAssembly = CommonEnumHelper.GetAssembly(CommonEnumHelper.enumAssemblyName, "");

            if (enumAssembly != null)
            {
                foreach (Type type in enumAssembly.GetTypes())
                {
                    object[] attributes = type.GetCustomAttributes(typeof(MTEnumAttribute), false);
                    if (attributes != null && attributes.Length > 0)
                    {
                        types.Add(type);
                    }
                }
            }

            return types.ToArray();
        }
        #endregion

        #region Private Static Members
        [NonSerialized]
        [ScriptIgnore]
        private static Dictionary<string, Dictionary<string, Dictionary<string, PropertyInfo>>> m_PropertyCache = new Dictionary<string, Dictionary<string, Dictionary<string, PropertyInfo>>>();
        #endregion

        #region Public Methods
        public void ApplyTemplatePropsToAccount(Account account)
        {
            ApplyTemplatePropsToAccount(account, null);
        }

        public void ApplyTemplatePropsToAccount(Account account, List<string> propNames)
        {
            Dictionary<string, View> touchedViews = new Dictionary<string, View>();
            List<string> appliedProps = propNames;

            if (appliedProps == null)
            {
                appliedProps = new List<string>();
            }

            if (appliedProps.Count == 0)
            {
                appliedProps.AddRange(Properties.Keys);
            }

            foreach (string propName in appliedProps)
            {
                try
                {
                    if (Properties.ContainsKey(propName))
                    {
                        // Get the property value from the template...uses the full name
                        object value = Properties[propName];

                        string[] propNameParts = propName.Split('.');

                        if (propNameParts[0].ToUpper() == "ACCOUNT")
                        {
                            PropertyInfo prop = account.GetProperty(propNameParts[1]);
                            prop.SetValue(account, value, null);
                        }
                        else
                        {
                            View view = null;
                            if (touchedViews.ContainsKey(propNameParts[0]))
                            {
                                view = touchedViews[propNameParts[0]];
                            }
                            else
                            {
                                view = GetSpecifiedView(propNameParts[0], account);

                                touchedViews.Add(propNameParts[0], view);
                            }

                            PropertyInfo prop = view.GetProperty(propNameParts[1]);
                            prop.SetValue(view, value, null);
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Property does not exist on the account type");
                    }
                }
                catch (Exception e)
                {
                    throw new ApplicationException(string.Format("Error applying template property {0} to account", propName), e);
                }
            }
        }

        public void GetTemplatePropsFromAccount(Account account)
        {
            Account a = new Account();
            List<PropertyInfo> props = a.GetMTProperties();

            Properties.Clear();

            foreach (PropertyInfo prop in props)
            {
                if (account.IsDirty(prop) &&
                    string.Compare(prop.Name, "_AccountID", true) != 0 &&
                    string.Compare(prop.Name, "Name_Space", true) != 0 &&
                    string.Compare(prop.Name, "Username", true) != 0 &&
                    string.Compare(prop.Name, "AccountType", true) != 0 &&
                    string.Compare(prop.Name, "ApplyDefaultSecurityPolicy", true) != 0 &&
                    string.Compare(prop.Name, "Password_", true) != 0 &&
                    string.Compare(prop.Name, "AuthenticationType", true) != 0)
                {
                    if (!Properties.ContainsKey(prop.Name))
                    {
                        Properties.Add(string.Format("Account.{0}", prop.Name), prop.GetValue(account, null));
                    }
                }
            }

            foreach (KeyValuePair<string, List<View>> views in account.GetViews())
            {
                PropertyInfo baseProp = account.GetProperty(views.Key);
                object[] attribs = baseProp.GetCustomAttributes(typeof(MTDataMemberAttribute), false);

                List<PropertyInfo> keyProps = View.GetKeyProperties(((MTDataMemberAttribute)attribs[0]).ClassName);
                Dictionary<string, PropertyInfo> keyPropsMap = new Dictionary<string, PropertyInfo>();

                foreach (View view in views.Value)
                {
                    string propNameBase = views.Key;

                    if (keyProps.Count > 0)
                    {
                        propNameBase += "[";

                        foreach (PropertyInfo keyProp in keyProps)
                        {
                            if (!keyPropsMap.ContainsKey(keyProp.Name))
                            {
                                keyPropsMap.Add(keyProp.Name, keyProp);
                            }
                            propNameBase += string.Format("{0}={1};", keyProp.Name, keyProp.GetValue(view, null));
                        }

                        propNameBase = propNameBase.Substring(0, propNameBase.Length - 1) + "]";
                    }

                    foreach (PropertyInfo viewProp in view.GetMTProperties())
                    {
                        if (!keyPropsMap.ContainsKey(viewProp.Name) && view.IsDirty(viewProp))
                        {
                            Properties.Add(string.Format("{0}.{1}", propNameBase, viewProp.Name), viewProp.GetValue(view, null));
                        }
                    }
                }
            }
        }
        #endregion

        #region Private Methods
        private View GetSpecifiedView(string viewIdentifier, Account account)
        {
            View retval = null;
            Dictionary<string, string> keyPropMap = new Dictionary<string, string>();

            string viewName = viewIdentifier;

            if (viewName.IndexOf("[") != -1)
            {
                #region Parse View Identifier
                viewName = viewIdentifier.Substring(0, viewIdentifier.IndexOf("["));
                string keyProps = viewIdentifier.Substring(
                                            viewIdentifier.IndexOf("[") + 1,
                                            (viewIdentifier.LastIndexOf("]") - (viewIdentifier.IndexOf("[") + 1)));

                string[] keyPropParts = keyProps.Split(';');

                foreach (string keyProp in keyPropParts)
                {
                    string[] keyParts = keyProp.Split('=');

                    keyPropMap.Add(keyParts[0], keyParts[1]);
                }
                #endregion
            }

            PropertyInfo viewProp = account.GetProperty(viewName);
            object[] attribs = viewProp.GetCustomAttributes(typeof(MTDataMemberAttribute), false);
            MTDataMemberAttribute dataMemberAttrib = ((MTDataMemberAttribute)attribs[0]);

            if (!dataMemberAttrib.IsListView)
            {
                #region Locate/Create view that does not have key props
                retval = viewProp.GetValue(account, null) as View;

                if (retval == null)
                {
                    retval = View.CreateView(dataMemberAttrib.ClassName);

                    viewProp.SetValue(account, retval, null);
                }
                #endregion
            }
            else
            {
                #region Locate/Create view that has key props
                IEnumerable views = viewProp.GetValue(account, null) as IEnumerable;

                List<PropertyInfo> keyProps = View.GetKeyProperties(dataMemberAttrib.ClassName);

                IEnumerator iter = views.GetEnumerator();

                #region Determine if specified view instance exists
                if (views != null && iter.MoveNext())
                {
                    do
                    {
                        View view = iter.Current as View;

                        bool bFound = true;

                        foreach (PropertyInfo keyProp in keyProps)
                        {
                            if (keyPropMap.ContainsKey(keyProp.Name))
                            {
                                object value = keyProp.GetValue(view, null);

                                if (view == null || value == null || string.Compare(value.ToString(), keyPropMap[keyProp.Name], true) != 0)
                                {
                                    bFound = false;
                                    break;
                                }
                            }
                            else
                            {
                                bFound = false;
                                break;
                            }
                        }

                        if (bFound)
                        {
                            retval = view;
                            break;
                        }
                    }
                    while (iter.MoveNext());
                }
                #endregion

                #region View not found, so create
                if (retval == null)
                {
                    retval = View.CreateView(dataMemberAttrib.ClassName);

                    foreach (PropertyInfo keyProp in keyProps)
                    {
                        if (keyPropMap.ContainsKey(keyProp.Name))
                        {
                            object value;

                            Type propType = keyProp.PropertyType;

                            if (propType.IsGenericType)
                            {
                                propType = propType.GetGenericArguments()[0];
                            }

                            if (propType.IsSubclassOf(typeof(Enum)))
                            {
                                value = Convert.ChangeType(Enum.Parse(propType, keyPropMap[keyProp.Name]), propType);
                            }
                            else
                            {
                                value = Convert.ChangeType(keyPropMap[keyProp.Name], propType);
                            }

                            keyProp.SetValue(retval, value, null);
                        }
                    }

                    account.AddView(retval, viewName);
                }
                #endregion
                #endregion
            }

            return retval;
        }
        #endregion
    }

    [DataContract]
    [Serializable]
    public class AccountTemplateKeyValue : BaseObject
    {
        #region Key
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isKeyDirty = false;
        private string m_Key;
        [MTDataMember(Description = "This is the key.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Key
        {
            get { return m_Key; }
            set
            {

                m_Key = value;
                isKeyDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsKeyDirty
        {
            get { return isKeyDirty; }
        }
        #endregion

        #region Name
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNameDirty = false;
        private string m_Name;
        [MTDataMember(Description = "This is the Name.", Length = 40)]
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
        [MTDataMember(Description = "This is the DisplayName.", Length = 40)]
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

        #region Value
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isValueDirty = false;
        private string m_Value;
        [MTDataMember(Description = "This is the value.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Value
        {
            get { return m_Value; }
            set
            {

                m_Value = value;
                isValueDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsValueDirty
        {
            get { return isValueDirty; }
        }
        #endregion
    }
}
