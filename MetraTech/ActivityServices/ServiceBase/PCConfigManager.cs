using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;
using MetraTech.Interop.RCD;
using MetraTech.ActivityServices.Common;

namespace MetraTech.ActivityServices.Services.Common
{
    public abstract class PCConfigManager
    {
        #region Private Members
        private static object mLockObject = new object();

        private static Logger mLogger = new Logger("logging\\ProductCatalog", "[PCConfigManager]");

        private static bool mConfigLoaded = false;
        private static bool mAttributesLoaded = false;

        private static PLChainingRule mChainingRule = PLChainingRule.NONE;
        private static int mBatchSubmitTimeout = 3600;
        private static bool mDebugTempTables = false;
        private static int mRSCacheMaxSize = 500000;
        private static Dictionary<string, bool> mBusinessRules = new Dictionary<string, bool>();
        private static Dictionary<int, Dictionary<string, bool>> mPropertyAttributes = new Dictionary<int, Dictionary<string, bool>>();
        #endregion

        #region Public Static Methods
        public static bool IsBusinessRuleEnabled(string businessRuleName)
        {
            bool ruleEnabled = false;

            LoadConfigIfNeeded();

            //lock (mBusinessRules)
            {
                if (mBusinessRules.ContainsKey(businessRuleName))
                {
                    ruleEnabled = mBusinessRules[businessRuleName];
                }
                else
                {
                    throw new MASBasicException("Unknown business rule");
                }
            }

            mLogger.LogDebug("{0} business rule: {1}",
                (ruleEnabled ? "Checking" : "Ignoring disabled"),
                businessRuleName);

            return ruleEnabled;
        }

        public static bool IsPropertyOverridable(int entityId, string propertyName)
        {
            bool retval = false;

            LoadAttributesIfNeeded();

            if (mPropertyAttributes.ContainsKey(entityId))
            {
                if (mPropertyAttributes[entityId].ContainsKey(propertyName))
                {
                    retval = mPropertyAttributes[entityId][propertyName];
                }
            }

            return retval;
        }

        #endregion

        #region Private Static Methods
        private static void LoadConfigIfNeeded()
        {
            lock (mLockObject)
            {
                if (!mConfigLoaded)
                {
                    mLogger.LogDebug("Loading configuration into cache");

                    IMTRcd rcd = new MTRcdClass();

                    string configFile = Path.Combine(rcd.ConfigDir, @"ProductCatalog\PCConfig.xml");

                    StreamReader rdr = new StreamReader(configFile);
                    XmlDocument configDoc = new XmlDocument();
                    configDoc.Load(rdr);

                    XmlNode root = configDoc.FirstChild;

                    if (string.Compare(root.Name, "xmlconfig") == 0)
                    {
                        foreach (XmlNode childNode in root.ChildNodes)
                        {
                            if (childNode.NodeType != XmlNodeType.Comment)
                            {
                                switch (childNode.Name)
                                {
                                    case "PLChainingRule":
                                        mChainingRule = (PLChainingRule)Enum.Parse(typeof(PLChainingRule), childNode.InnerText);
                                        break;
                                    case "BatchSubmitTimeout":
                                        mBatchSubmitTimeout = int.Parse(childNode.InnerText);
                                        break;
                                    case "DebugTempTables":
                                        mDebugTempTables = bool.Parse(childNode.InnerText);
                                        break;
                                    case "RSCacheMaxSize":
                                        mRSCacheMaxSize = int.Parse(childNode.InnerText);
                                        break;
                                    case "BusinessRules":
                                        foreach (XmlNode businessRule in childNode.ChildNodes)
                                        {
                                            if (businessRule.Name == "BusinessRule")
                                            {
                                                string ruleName = null;
                                                bool enabled = false;
                                                foreach (XmlNode subNode in businessRule.ChildNodes)
                                                {
                                                    switch (subNode.Name)
                                                    {
                                                        case "Type":
                                                            ruleName = subNode.InnerText;
                                                            break;
                                                        case "Enabled":
                                                            enabled = bool.Parse(subNode.InnerText);
                                                            break;
                                                        default:
                                                            break;
                                                    }
                                                }

                                                if (!string.IsNullOrEmpty(ruleName))
                                                {
                                                    mBusinessRules.Add(ruleName, enabled);
                                                }
                                                else
                                                {
                                                    throw new MASBasicException("Business rule name not specified in PCConfig.xml");
                                                }
                                            }
                                        }
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }
                    }
                    else
                    {
                        throw new MASBasicException("Invalid root element in PCConfig.xml");
                    }

                    mConfigLoaded = true;
                }
            }
        }

        private static void LoadAttributesIfNeeded()
        {
            lock (mLockObject)
            {
                if (!mAttributesLoaded)
                {
                    mLogger.LogDebug("Loading configuration into cache");

                    IMTRcd rcd = new MTRcdClass();

                    IMTRcdFileList fileList = rcd.RunQuery(@"config\attributes\attribute_values.xml", true);

                    foreach (string configFile in fileList)
                    {
                        StreamReader rdr = new StreamReader(configFile);
                        XmlDocument configDoc = new XmlDocument();
                        configDoc.Load(rdr);

                        XmlNode root = configDoc.FirstChild;

                        if (string.Compare(root.Name, "mt_config", true) == 0)
                        {
                            foreach (XmlNode childNode in root.ChildNodes)
                            {
                                if (childNode.NodeType != XmlNodeType.Comment)
                                {
                                    if (string.Compare(childNode.Name, "attribute_value", true) == 0)
                                    {
                                        string entityIdStr = childNode.Attributes["pcentitytype"].Value;
                                        int entityId = Int32.Parse(entityIdStr);

                                        string propertyName = null, attribute = null, value = null;

                                        foreach (XmlNode attributeNode in childNode.ChildNodes)
                                        {
                                            switch (attributeNode.Name.ToUpper())
                                            {
                                                case "PROPERTY":
                                                    propertyName = attributeNode.InnerText;
                                                    break;
                                                case "ATTRIBUTE":
                                                    attribute = attributeNode.InnerText;
                                                    break;
                                                case "VALUE":
                                                    value = attributeNode.InnerText;
                                                    break;
                                            }
                                        }

                                        if (!string.IsNullOrEmpty(propertyName) && !string.IsNullOrEmpty(attribute) && !string.IsNullOrEmpty(value))
                                        {
                                            if (string.Compare(attribute, "overrideable", true) == 0)
                                            {
                                                if (!mPropertyAttributes.ContainsKey(entityId))
                                                {
                                                    mPropertyAttributes[entityId] = new Dictionary<string, bool>();
                                                }

                                                mPropertyAttributes[entityId][propertyName] = bool.Parse(value);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            throw new MASBasicException("Invalid root element in attribute_values.xml");
                        }
                    }

                    mAttributesLoaded = true;
                }
            }
        }

        #endregion

        #region Enums
        public enum PLChainingRule
        {
            NONE,
            ALL,
            PO_ONLY
        };

        #endregion

        #region Business Rule Names
        public const string MTPC_BUSINESS_RULE_All_NoEmptyRequiredProperty = "All_NoEmptyRequiredProperty";
        public const string MTPC_BUSINESS_RULE_All_CheckStringLength = "All_CheckStringLength";
        public const string MTPC_BUSINESS_RULE_Account_NoConflictingProdOff = "Account_NoConflictingProdOff";
        public const string MTPC_BUSINESS_RULE_Account_NoDuplicateProdOff = "Account_NoDuplicateProdOff";
        public const string MTPC_BUSINESS_RULE_Account_CheckBillingCycleChange = "Account_CheckBillingCycleChange";
        public const string MTPC_BUSINESS_RULE_EffDate_CheckDateCompatibility = "EffDate_CheckDateCompatibility";
        public const string MTPC_BUSINESS_RULE_EffDate_NoEndBeforeStart = "EffDate_NoEndBeforeStart";
        public const string MTPC_BUSINESS_RULE_PITempl_NoDuplicateName = "PITempl_NoDuplicateName";
        public const string MTPC_BUSINESS_RULE_PIType_NoDuplicateName = "PIType_NoDuplicateName";
        public const string MTPC_BUSINESS_RULE_PIType_NoRemoveIfTemplate = "PIType_NoRemoveIfTemplate";
        public const string MTPC_BUSINESS_RULE_PriceList_NoDuplicateName = "PriceList_NoDuplicateName";
        public const string MTPC_BUSINESS_RULE_ProdOff_CheckConfiguration = "ProdOff_CheckConfiguration";
        public const string MTPC_BUSINESS_RULE_ProdOff_CheckCurrency = "ProdOff_CheckCurrency";
        public const string MTPC_BUSINESS_RULE_ProdOff_CheckDates = "ProdOff_CheckDates";
        public const string MTPC_BUSINESS_RULE_ProdOff_CheckModification = "ProdOff_CheckModification";
        public const string MTPC_BUSINESS_RULE_ProdOff_NoDuplicateUsageTemplate = "ProdOff_NoDuplicateUsageTemplate";
        public const string MTPC_BUSINESS_RULE_ProdOff_NoDuplicateTemplate = "ProdOff_NoDuplicateTemplate";
        public const string MTPC_BUSINESS_RULE_ProdOff_NoDuplicateInstanceName = "ProdOff_NoDuplicateInstanceName";
        public const string MTPC_BUSINESS_RULE_ProdOff_NoDuplicateName = "ProdOff_NoDuplicateName";
        public const string MTPC_BUSINESS_RULE_ProdOff_NoModificationIfAvailable = "ProdOff_NoModificationIfAvailable";
        public const string MTPC_BUSINESS_RULE_IgnoreDateCheckOnGroupSubDelete = "IgnoreDateCheckOnGroupSubDelete";
        public const string MTPC_BUSINESS_RULE_IgnoreDateCheckOnSubscriptionDelete = "IgnoreDateCheckOnSubscriptionDelete";
        public const string MTPC_BUSINESS_RULE_OnlyAbsoluteRateSchedulesWithGroupSubscription = "OnlyAbsoluteRateSchedulesWithGroupSubscription";
        public const string MTPC_BUSINESS_RULE_PI_CheckCycleChange = "PI_CheckCycleChange";
        public const string MTPC_BUSINESS_RULE_Rates_DeleteOverride = "Rates_DeleteOverride";
        public const string MTPC_BUSINESS_RULE_Adjustments_NoGreaterThanCharge = "Adjustments_NoGreaterThanCharge";
        public const string MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations = "Hierarchy_RestrictedOperations";
        public const string MTPC_BUSINESS_RULE_Subscription_TruncateTimeValues = "Subscription_TruncateTimeValues";
        public const string MTPC_BUSINESS_RULE_MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch = "AllowAccountPOCurrencyMismatch";
        public const string MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC = "AllowMultiplePISubscriptionRCNRC";
        #endregion
    }
}
