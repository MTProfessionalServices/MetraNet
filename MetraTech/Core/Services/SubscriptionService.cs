/**************************************************************************
* Copyright 2007 by MetraTech
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
using System.Text;
using System.ServiceModel;
using System.Transactions;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MTAuth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.Rowset;
using System.Reflection;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.Validators;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
    [ServiceContract()]
    public interface ISubscriptionService
    {
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetSubscriptions(AccountIdentifier acct, ref MTList<Subscription> subs);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetSubscriptionDetail(AccountIdentifier acct, int subscriptionId, out Subscription sub);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetEligiblePOsForSubscription(AccountIdentifier acct, DateTime effectiveDate,
                                           ref MTList<ProductOffering> productOfferings);
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetEligiblePOsForSubscriptionMetraView(AccountIdentifier acct, DateTime effectiveDate, bool all_po,
                                           ref MTList<ProductOffering> productOfferings);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetUDRCInstancesForPO(int productOfferingId, out List<UDRCInstance> udrcInstances);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void AddSubscription(AccountIdentifier acct, ref Subscription sub);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void UpdateSubscription(AccountIdentifier acct, Subscription sub);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void DeleteSubscription(AccountIdentifier acct, int subscriptionId);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetCharacteristicValues(ref MTList<CharacteristicValue> charVals);
    }

    [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
    public class SubscriptionService : BaseSubscriptionService, ISubscriptionService
    {
        private Logger m_Logger = new Logger("[SubscriptionService]");

        /// <summary>
        /// For some methods, we will attempt retries if the first attempt fails.
        /// This constant holds the maximum number of "tries" that will be attempted.
        /// </summary>
        private const int MAX_TRIES = 5;

        #region ISubscriptionService Members

        [OperationCapability("View subscriptions")]
        public void GetSubscriptions(AccountIdentifier acct, ref MTList<Subscription> subs)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetSubscriptions"))
            {
                // Get the session context from the WCF ambient service security context
                MTAuth.IMTSessionContext sessionContext = GetSessionContext();

                #region Get Product Offering Meta Data

                string selectlist = "", joinlist = "";

                IMTProductCatalog prodCatalog = new MTProductCatalogClass();
                MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData = null;
                try
                {
                    // Get the meta data set
                    metaData = prodCatalog.GetMetaData(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_PRODUCT_OFFERING);
                    // Get additional sql for PO extended properties
                    metaData.GetPropertySQL("t_po.id_po", "", false, ref selectlist, ref joinlist);
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Exception getting PO properties in GetSubscriptions", e);

                    throw new MASBasicException("Unable to get Product Offering properties");
                }

                #endregion

                #region Get the list of subscriptions

                try
                {
                    // open the connection
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        // Get a filter/sort statement
                        using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\ProductCatalog", "__GET_ALL_SUBSCRIPTIONS__"))
                        {
                            // Set the parameters
                            stmt.AddParam("%%ID_ACC%%", AccountIdentifierResolver.ResolveAccountIdentifier(acct));
                            stmt.AddParam("%%COLUMNS%%", selectlist);
                            stmt.AddParam("%%JOINS%%", joinlist);
                            stmt.AddParam("%%ID_LANG%%", sessionContext.LanguageID);

                            ApplyFilterSortCriteria<Subscription>(stmt, subs, new FilterColumnResolver(GetColumnNameFromSubscribedPOPropertyName), metaData);

                            // execute the query
                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                Subscription sub;
                                // process the results
                                while (rdr.Read())
                                {
                                    sub = PopulateSubscribedProductOffering(metaData, rdr);

                                    subs.Items.Add(sub);
                                }

                                // get the total rows that would be returned without paging
                                subs.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Exception getting subscriptions in GetSubscriptions", e);

                    subs.Items.Clear();

                    throw new MASBasicException("Failed to retrieve subscriptions");
                }

            }
                #endregion
        }

        [OperationCapability("View subscriptions")]
        public void GetSubscriptionDetail(AccountIdentifier acct, int subscriptionId, out Subscription sub)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetSubscriptionDetail"))
            {
                try
                {
                    sub = null;
                    // Get the session context from the WCF ambient service security context
                    MTAuth.IMTSessionContext sessionContext = GetSessionContext();

                    int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

                    IMTProductCatalog prodCat = new MTProductCatalogClass();
                    prodCat.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

                    IMTPCAccount pcAccount = prodCat.GetAccount(id_acc);
                    pcAccount.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

                    IMTSubscriptionBase pcSub = pcAccount.GetSubscription(subscriptionId);

                    if (pcSub != null)
                    {
                        sub = new Subscription();
                        sub.SubscriptionId = pcSub.ID;
                        sub.ProductOfferingId = pcSub.ProductOfferingID;
                        sub.SubscriptionSpan = CastTimeSpan(pcSub.EffectiveDate);
                        sub.WarnOnEBCRStartDateChange = pcSub.WarnOnEBCRStartDateChange;

                        IMTProductOffering pcPO = prodCat.GetProductOffering(sub.ProductOfferingId);

                        ProductOffering po = new ProductOffering();
                        po.ProductOfferingId = pcPO.ID;
                        po.Name = pcPO.Name;
                        po.DisplayName = pcPO.DisplayName;
                        po.Description = pcPO.Description;
                        po.EffectiveTimeSpan = CastTimeSpan(pcPO.EffectiveDate);
                        po.AvailableTimeSpan = CastTimeSpan(pcPO.AvailabilityDate);

                        sub.ProductOffering = po;

                        MetraTech.Interop.MTProductCatalog.IMTRowSet rs = pcSub.GetRecurringChargeUnitValuesAsRowset();
                        Dictionary<string, List<UDRCInstanceValue>> udrcValues = null;

                        GetUDRCValues(rs, out udrcValues);
                        sub.UDRCValues = udrcValues;
                    }
                    else
                    {
                        m_Logger.LogError("The specified subscription could not be found");

                        throw new MASBasicException("The specified subscription could not be found");
                    }
                }
                catch (MASBasicException masBasic)
                {
                    throw masBasic;
                }
                catch (COMException comE)
                {
                    m_Logger.LogException("COM Exception getting subscription details", comE);

                    throw new MASBasicException(comE.Message);
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Exception getting subscription details", e);

                    throw new MASBasicException("Error getting subscription details");
                }
            }
        }

        public void GetEligiblePOsForSubscription(AccountIdentifier acct, DateTime effectiveDate, ref MTList<ProductOffering> productOfferings)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetEligiblePOsForSubscription"))
            {
                // Get the session context from the WCF ambient service security context
                MTAuth.IMTSessionContext sessionContext = GetSessionContext();

                string selectlist = "", joinlist = "";

                // Check ProdOff_AllowAccountPOCurrencyMismatch business rule and set the query parameter values accordingly
                string strCURRENCYFILTER1 = ""; // pl1.nm_currency_code = tav.c_currency";
                string strCURRENCYFILTER2 = ""; // tmp.payercurrency = t_pricelist.nm_currency_code";

                MTProductCatalog pc = new MTProductCatalog();
                if (pc.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch))
                {
                    strCURRENCYFILTER1 = " 1=1";
                    strCURRENCYFILTER2 = " 1=1";
                }
                else
                {
                    strCURRENCYFILTER1 = " pl1.nm_currency_code = tav.c_currency";
                    strCURRENCYFILTER2 = " tmp.payercurrency = t_pricelist.nm_currency_code";
                }


                IMTProductCatalog prodCatalog = new MTProductCatalogClass();
                MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData;
                try
                {
                    metaData = prodCatalog.GetMetaData(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_PRODUCT_OFFERING);
                    metaData.GetPropertySQL("t_po.id_po", "t_po", false, ref selectlist, ref joinlist);
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Exception getting PO properties in GetSubscriptions", e);

                    throw new MASBasicException("Unable to get Product Offering properties");
                }

                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init("queries\\ProductCatalog");
                            queryAdapter.Item.SetQueryTag("__FIND_SUBSCRIBABLE_PO_PARAM__");
                            queryAdapter.Item.AddParam("%%JOINS%%", joinlist, true);
                            queryAdapter.Item.AddParam("%%COLUMNS%%", selectlist, true);
                            queryAdapter.Item.AddParam("%%CURRENCYFILTER1%%", strCURRENCYFILTER1, true);
                            queryAdapter.Item.AddParam("%%CURRENCYFILTER2%%", strCURRENCYFILTER2, true);
                            queryAdapter.Item.AddParam("%%CURRENCYFILTER3%%", "1=1");

                            string rawSql = queryAdapter.Item.GetRawSQLQuery(true);

                            using (IMTPreparedFilterSortStatement stmt = conn.CreatePreparedFilterSortStatement(rawSql))
                            {
                                stmt.AddParam("idAcc", MTParameterType.Integer, AccountIdentifierResolver.ResolveAccountIdentifier(acct));
                                stmt.AddParam("idLangcode", MTParameterType.Integer, sessionContext.LanguageID);
                                stmt.AddParam("refDate", MTParameterType.DateTime, effectiveDate);

                                ApplyFilterSortCriteria<ProductOffering>(stmt, productOfferings, new FilterColumnResolver(GetColumnNameFromProductOfferingPropertyname), metaData);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    ProductOffering prod;
                                    while (rdr.Read())
                                    {
                                        prod = PopulateProductOffering(metaData, rdr);

                                        productOfferings.Items.Add(prod);
                                    }

                                    productOfferings.TotalRows = stmt.TotalRows;
                                }
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Exception getting eligible product offerings in GetEligiblePOsForSubscription", e);

                    productOfferings.Items.Clear();

                    throw new MASBasicException("Failed to retrieve product offerings");
                }
            }
        }

        public void GetEligiblePOsForSubscriptionMetraView(AccountIdentifier acct, DateTime effectiveDate, bool all_po, ref MTList<ProductOffering> productOfferings)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetEligiblePOsForSubscription"))
            {
                // Get the session context from the WCF ambient service security context
                MTAuth.IMTSessionContext sessionContext = GetSessionContext();

                string selectlist = "", joinlist = "";

                // Check ProdOff_AllowAccountPOCurrencyMismatch business rule and set the query parameter values accordingly
                string strCURRENCYFILTER1 = ""; // pl1.nm_currency_code = tav.c_currency";
                string strCURRENCYFILTER2 = ""; // tmp.payercurrency = t_pricelist.nm_currency_code";
                string strCURRENCYFILTER3 = ""; // t_po.b_user_subscribe='Y'"";

                MTProductCatalog pc = new MTProductCatalog();
                if (pc.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch))
                {
                    strCURRENCYFILTER1 = " 1=1";
                    strCURRENCYFILTER2 = " 1=1";
                }
                else
                {
                    strCURRENCYFILTER1 = " pl1.nm_currency_code = tav.c_currency";
                    strCURRENCYFILTER2 = " tmp.payercurrency = t_pricelist.nm_currency_code";
                }
                if (all_po)
                    strCURRENCYFILTER3 = " 1=1";
                else
                    strCURRENCYFILTER3 = " t_po.b_user_subscribe='Y'";

                IMTProductCatalog prodCatalog = new MTProductCatalogClass();
                MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData;
                try
                {
                    metaData = prodCatalog.GetMetaData(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_PRODUCT_OFFERING);
                    metaData.GetPropertySQL("t_po.id_po", "t_po", false, ref selectlist, ref joinlist);
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Exception getting PO properties in GetSubscriptions", e);

                    throw new MASBasicException("Unable to get Product Offering properties");
                }

                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init("queries\\ProductCatalog");
                            queryAdapter.Item.SetQueryTag("__FIND_SUBSCRIBABLE_PO_PARAM__");
                            queryAdapter.Item.AddParam("%%JOINS%%", joinlist, true);
                            queryAdapter.Item.AddParam("%%COLUMNS%%", selectlist, true);
                            queryAdapter.Item.AddParam("%%CURRENCYFILTER1%%", strCURRENCYFILTER1, true);
                            queryAdapter.Item.AddParam("%%CURRENCYFILTER2%%", strCURRENCYFILTER2, true);
                            queryAdapter.Item.AddParam("%%CURRENCYFILTER3%%", strCURRENCYFILTER3, true);

                            string rawSql = queryAdapter.Item.GetRawSQLQuery(true);

                            using (IMTPreparedFilterSortStatement stmt = conn.CreatePreparedFilterSortStatement(rawSql))
                            {
                                stmt.AddParam("idAcc", MTParameterType.Integer, AccountIdentifierResolver.ResolveAccountIdentifier(acct));
                                stmt.AddParam("idLangcode", MTParameterType.Integer, sessionContext.LanguageID);
                                stmt.AddParam("refDate", MTParameterType.DateTime, effectiveDate);

                                ApplyFilterSortCriteria<ProductOffering>(stmt, productOfferings, new FilterColumnResolver(GetColumnNameFromProductOfferingPropertyname), metaData);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    ProductOffering prod;
                                    while (rdr.Read())
                                    {
                                        prod = PopulateProductOffering(metaData, rdr);

                                        productOfferings.Items.Add(prod);
                                    }

                                    productOfferings.TotalRows = stmt.TotalRows;
                                }
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Exception getting eligible product offerings in GetEligiblePOsForSubscription", e);

                    productOfferings.Items.Clear();

                    throw new MASBasicException("Failed to retrieve product offerings");
                }
            }
        }

        public void GetUDRCInstancesForPO(int productOfferingId, out List<UDRCInstance> udrcInstances)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetUDRCInstancesForPO"))
            {
                GetUDRCInstancesForPOInternal(productOfferingId, out udrcInstances);
            }
        }

        [OperationCapability("Create subscription")]
        public void AddSubscription(AccountIdentifier acct, ref Subscription sub)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("AddSubscription"))
            {
                // Get the session context from the WCF ambient service security context
                MTAuth.IMTSessionContext sessionContext = GetSessionContext();

                // Steps for Add Subscription

                #region Validate account

                int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

                #endregion

                #region Set Time Values Properly

                AdjustTimeValues(ref sub);

                #endregion

                int numTries = 0;
                bool isSuccess = false;
                while ((isSuccess == false) && (numTries < MAX_TRIES))
                {
                    numTries++;
                    using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                    {
                        #region Validate Subscription

                        MTList<ProductOffering> pos = new MTList<ProductOffering>();
                        pos.Filters.Add(new MTFilterElement("ProductOfferingId", MTFilterElement.OperationType.Equal, sub.ProductOfferingId));

                        //       m_Logger.LogDebug("Get eligible product offerings, filtering on specified product offering ID");
                        //       GetEligiblePOsForSubscription(acct, MetraTime.Now, ref pos);

                        //       if (pos.Items.Count == 0)
                        //       {
                        //         throw new MASBasicException("The specified account is not eligible to subscribe to the specified product offering");
                        //       }

                        List<UDRCInstance> udrcInstances = null;
                        ValidateSubscription(sub, out udrcInstances);

                        IMTProductCatalog prodCat = new MTProductCatalogClass();

                        IMTPCAccount pcAcct = prodCat.GetAccount(id_acc);

                        if (sub.SubscriptionSpan.StartDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod && pcAcct.GetNextBillingIntervalEndDate((DateTime)sub.SubscriptionSpan.StartDate) == null)
                        {
                            throw new MASBasicException("Specified account does not have a available billing period after the start date");
                        }

                        if (sub.SubscriptionSpan.EndDate != null &&
                            sub.SubscriptionSpan.EndDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod &&
                            pcAcct.GetNextBillingIntervalEndDate((DateTime)sub.SubscriptionSpan.EndDate) == null)
                        {
                            throw new MASBasicException("Specified account does not have a available billing period after the end date");
                        }


                        #endregion

                        try
                        {
                            #region Inside Try
                            // Create subscription object
                            MetraTech.Interop.MTProductCatalog.IMTSubscription pcSub = new MTSubscriptionClass();
                            pcSub.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

                            pcSub.AccountID = id_acc;
                            pcSub.ProductOfferingID = sub.ProductOfferingId;
                            pcSub.EffectiveDate = CastTimeSpan(sub.SubscriptionSpan);

                            // Set UDRC instance Values
                            if (sub.IsUDRCValuesDirty && sub.UDRCValues != null)
                            {
                                foreach (KeyValuePair<string, List<UDRCInstanceValue>> kvp in sub.UDRCValues)
                                {
                                    foreach (UDRCInstanceValue val in kvp.Value)
                                    {
                                        pcSub.SetRecurringChargeUnitValue(val.UDRC_Id, val.Value, val.StartDate, val.EndDate);
                                    }
                                }
                            }
                            // Save the whole mess
                            pcSub.Save();

                            sub.SubscriptionId = pcSub.ID;

                            #region Create Characteristic Values

                            if (sub.CharacteristicValues != null)
                            {
                                if (sub.CharacteristicValues.Count > 0)
                                {
                                    string insertStmt = "BEGIN\n";
                                    IMTQueryAdapter qa = new MTQueryAdapterClass();
                                    qa.Init(@"Queries\ProductCatalog");

                                    foreach (CharacteristicValue cv in sub.CharacteristicValues)
                                    {
                                        qa.SetQueryTag("__SAVE_CHAR_VALS_FOR_SUB__");
                                        qa.AddParam("%%SPEC_CHAR_VAL_ID%%", cv.SpecCharValId);
                                        qa.AddParam("%%ENTITY_ID%%", sub.SubscriptionId.Value);
                                        qa.AddParam("%%VALUE%%", cv.Value);
                                        qa.AddParam("%%START_DATE%%", sub.SubscriptionSpan.StartDate);

                                        if (sub.SubscriptionSpan.EndDate == null)
                                            qa.AddParam("%%END_DATE%%", ProdCatTimeSpan.MTPCDateType.NoDate);
                                        else
                                            qa.AddParam("%%END_DATE%%", sub.SubscriptionSpan.EndDate);
                                        qa.AddParam("%%SPEC_NAME%%", cv.SpecName);
                                        qa.AddParam("%%SPEC_TYPE%%", cv.SpecType);
                                        insertStmt += qa.GetQuery().Trim() + ";\n";
                                    }

                                    insertStmt += "END;";
                                    m_Logger.LogDebug(insertStmt);

                                    using (IMTConnection conn = ConnectionManager.CreateConnection("queries\\ProductCatalog"))
                                    using (IMTStatement stmt = conn.CreateStatement(insertStmt))
                                    {
                                        stmt.ExecuteNonQuery();
                                    }
                                    m_Logger.LogDebug("Saving characteristic value for subscription.");
                                }
                            }

                            #endregion
                            #endregion
                        }
                        catch (COMException comE)
                        {
                            // The COMException might be related to a DB deadlock.
                            // So, attempt a retry if appropriate.
                            m_Logger.LogError("Caught COMException while creating subscription, numTries={0}", numTries);
                            if (numTries == (MAX_TRIES - 1))
                            {
                                // We have exceeded the number of "tries"
                                m_Logger.LogException("COM Exception creating subscription", comE);
                                throw new MASBasicException(comE.Message);
                            }
                            else
                            {
                                // attempt a retry
                                scope.Dispose();
                                continue;
                            }
                        }
                        catch (Exception e)
                        {
                            m_Logger.LogException("Exception creating subscription", e);

                            throw new MASBasicException("Error creating subscription");
                        }

                        scope.Complete();
                        isSuccess = true;
                    }
                }
            }
        }

        [OperationCapability("Update subscription")]
        public void UpdateSubscription(AccountIdentifier acct, Subscription sub)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("UpdateSubscription"))
            {
                // Get the session context from the WCF ambient service security context
                MTAuth.IMTSessionContext sessionContext = GetSessionContext();

                #region Validate account

                int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

                #endregion

                if (!sub.IsSubscriptionIdDirty || sub.SubscriptionId == null)
                {
                    throw new MASBasicException("The subscription ID must be specified");
                }

                var account = new Account();
                DateTime date = new DateTime();

                if (sub.SubscriptionSpan.StartDate.HasValue)
                    date = sub.SubscriptionSpan.StartDate.Value;
                else
                    date = MetraTime.Now;

                LoadAccountBase(acct, date, out account);

                if (account.AccountStartDate > sub.SubscriptionSpan.StartDate)
                {
                    throw new MASBasicException("The subscription start date cannot be greater than the account creation date");
                }

                #region Set Time Values Properly

                AdjustTimeValues(ref sub);

                #endregion

                Subscription existingSub = null;

                #region Get Existing Subscription and apply changes

                GetSubscriptionDetail(acct, (int)sub.SubscriptionId, out existingSub);

                ApplyDirtyProperties(ref existingSub, sub);

                #endregion

                #region Validate Subscription

                SubscriptionValidator validator = new SubscriptionValidator();
                List<string> validationErrors = null;
                if (!validator.Validate(existingSub, out validationErrors))
                {
                    MASBasicException err = new MASBasicException("Error validating subscription");

                    foreach (string validationError in validationErrors)
                    {
                        err.AddErrorMessage(validationError);
                    }

                    throw err;
                }

                IMTProductCatalog prodCat = new MTProductCatalogClass();

                IMTPCAccount pcAcct = prodCat.GetAccount(id_acc);

                if (existingSub.SubscriptionSpan.StartDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod &&
                    pcAcct.GetNextBillingIntervalEndDate((DateTime)existingSub.SubscriptionSpan.StartDate) == null)
                {
                    throw new MASBasicException("Specified account does not have a available billing period after the start date");
                }

                if (existingSub.SubscriptionSpan.EndDate != null &&
                    existingSub.SubscriptionSpan.EndDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod &&
                    pcAcct.GetNextBillingIntervalEndDate((DateTime)existingSub.SubscriptionSpan.EndDate) == null)
                {
                    throw new MASBasicException("Specified account does not have a available billing period after the end date");
                }

                #endregion

                int numTries = 0;
                bool isSuccess = false;
                while ((isSuccess == false) && (numTries < MAX_TRIES))
                {
                    numTries++;
                    using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                    {
                        #region Update the subscription

                        try
                        {
                            #region InsideTry
                            // Get subscription object
                            IMTSubscriptionBase pcSub = pcAcct.GetSubscription((int)sub.SubscriptionId);
                            bool bChanged = false;

                            if (pcSub != null)
                            {
                                pcSub.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

                                if (sub.IsSubscriptionSpanDirty && sub.SubscriptionSpan != null)
                                {
                                    if (sub.SubscriptionSpan.IsStartDateDirty)
                                    {
                                        if (sub.SubscriptionSpan.StartDate.HasValue)
                                        {
                                            pcSub.EffectiveDate.StartDate = (DateTime)sub.SubscriptionSpan.StartDate;
                                        }
                                        else
                                        {
                                            pcSub.EffectiveDate.StartDate = MetraTime.Min;
                                        }

                                        bChanged = true;
                                    }

                                    if (sub.SubscriptionSpan.IsStartDateTypeDirty)
                                    {
                                        pcSub.EffectiveDate.StartDateType =
                                          (MetraTech.Interop.MTProductCatalog.MTPCDateType)sub.SubscriptionSpan.StartDateType;
                                        bChanged = true;
                                    }

                                    if (sub.SubscriptionSpan.IsStartDateOffsetDirty)
                                    {
                                        pcSub.EffectiveDate.StartOffset = (int)sub.SubscriptionSpan.StartDateOffset;
                                        bChanged = true;
                                    }

                                    if (sub.SubscriptionSpan.IsEndDateDirty)
                                    {
                                        if (sub.SubscriptionSpan.EndDate.HasValue)
                                        {
                                            pcSub.EffectiveDate.EndDate = (DateTime)sub.SubscriptionSpan.EndDate;
                                        }
                                        else
                                        {
                                            pcSub.EffectiveDate.EndDate = MetraTime.Max;
                                        }
                                        bChanged = true;
                                    }

                                    if (sub.SubscriptionSpan.IsEndDateTypeDirty)
                                    {
                                        pcSub.EffectiveDate.EndDateType =
                                          (MetraTech.Interop.MTProductCatalog.MTPCDateType)sub.SubscriptionSpan.EndDateType;
                                        bChanged = true;
                                    }

                                    if (sub.SubscriptionSpan.IsEndDateOffsetDirty)
                                    {
                                        pcSub.EffectiveDate.EndOffset = (int)sub.SubscriptionSpan.EndDateOffset;
                                        bChanged = true;
                                    }
                                }
                                // Set UDRC instance Values
                                if (sub.IsUDRCValuesDirty && sub.UDRCValues != null)
                                {
                                    // Set the ID to 0 so that the UDRC value changes are stored in memory
                                    pcSub.ID = 0;

                                    MTTemporalList<UDRCInstanceValue> temporalList;
                                    foreach (KeyValuePair<string, List<UDRCInstanceValue>> kvp in sub.UDRCValues)
                                    {
                                        temporalList = new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate");

                                        // if the existing sub has UDRC values for this instance, load them and
                                        // assert the new values to be true via a MTTemporalList
                                        if (existingSub.UDRCValues.ContainsKey(kvp.Key) && existingSub.UDRCValues[kvp.Key] != null)
                                        {
                                            List<UDRCInstanceValue> existingValues = existingSub.UDRCValues[kvp.Key];
                                            foreach (UDRCInstanceValue val in existingValues)
                                            {
                                                temporalList.Add(val);
                                            }
                                        }

                                        foreach (UDRCInstanceValue val in kvp.Value)
                                        {
                                            if (!val.IsStartDateDirty || val.StartDate == null || val.StartDate == DateTime.MinValue)
                                            {
                                                val.StartDate = MetraTime.Min;
                                            }

                                            if (!val.IsEndDateDirty || val.EndDate == null || val.EndDate == DateTime.MaxValue)
                                            {
                                                val.EndDate = MetraTime.Max;
                                            }

                                            temporalList.Add(val);
                                        }

                                        foreach (UDRCInstanceValue val in temporalList.Items)
                                        {
                                            // Set UDRC value into Product Catalog Subscription,
                                            // since ID is 0, these will be stored in memroy
                                            // When sub is saved, the update will write all the values
                                            // at once
                                            pcSub.SetRecurringChargeUnitValue(val.UDRC_Id, val.Value, val.StartDate, val.EndDate);
                                        }
                                    }

                                    bChanged = true;

                                    // Restore the ID so that it get saved properly
                                    pcSub.ID = (int)sub.SubscriptionId;
                                }

                                // Save the whole mess
                                if (bChanged)
                                {
                                    pcSub.Save();
                                }
                            }
                            else
                            {
                                throw new MASBasicException("Specified subscription could not be loaded");
                            }
                            #endregion
                        }
                        catch (COMException comE)
                        {
                            // The COMException might be related to a DB deadlock.
                            // So, attempt a retry if appropriate.
                            m_Logger.LogError("Caught COMException while updating subscription, numTries={0}", numTries);
                            if (numTries == (MAX_TRIES - 1))
                            {
                                // We have exceeded the number of "tries"
                                m_Logger.LogException("COM Exception updating subscription", comE);
                                throw new MASBasicException(comE.Message);
                            }
                            else
                            {
                                // attempt a retry
                                scope.Dispose();
                                continue;
                            }
                        }
                        catch (MASBasicException masE)
                        {
                            throw masE;
                        }
                        catch (Exception e)
                        {
                            m_Logger.LogException("Exception updating subscription", e);

                            throw new MASBasicException("Error updating subscription");
                        }

                        #endregion

                        #region Update Characteristic Values

                        if (sub.CharacteristicValues != null)
                        {
                            if (sub.CharacteristicValues.Count > 0)
                            {
                                string insertStmt = "BEGIN\n";
                                IMTQueryAdapter qa = new MTQueryAdapterClass();
                                qa.Init(@"Queries\ProductCatalog");

                                foreach (CharacteristicValue cv in sub.CharacteristicValues)
                                {
                                    qa.SetQueryTag("__SAVE_CHAR_VALS_FOR_SUB__");
                                    qa.AddParam("%%SPEC_CHAR_VAL_ID%%", cv.SpecCharValId);
                                    qa.AddParam("%%ENTITY_ID%%", sub.SubscriptionId.Value);
                                    qa.AddParam("%%VALUE%%", cv.Value);
                                    qa.AddParam("%%START_DATE%%", sub.SubscriptionSpan.StartDate);
                                    qa.AddParam("%%END_DATE%%", sub.SubscriptionSpan.EndDate);
                                    qa.AddParam("%%SPEC_NAME%%", cv.SpecName);
                                    qa.AddParam("%%SPEC_TYPE%%", cv.SpecType);
                                    insertStmt += qa.GetQuery().Trim() + ";\n";
                                }

                                insertStmt += "END;";
                                m_Logger.LogDebug(insertStmt);

                                using (IMTConnection conn = ConnectionManager.CreateConnection("queries\\ProductCatalog"))
                                using (IMTStatement stmt = conn.CreateStatement(insertStmt))
                                {
                                    stmt.ExecuteNonQuery();
                                }
                                m_Logger.LogDebug("Saving characteristic value for subscription.");
                            }
                        }

                        #endregion

                        scope.Complete();
                        isSuccess = true;
                    }
                }
            }
        }

        [OperationCapability("Delete subscription")]
        public void DeleteSubscription(AccountIdentifier acct, int subscriptionId)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("DeleteSubscription"))
            {
                // Get the session context from the WCF ambient service security context
                MTAuth.IMTSessionContext sessionContext = GetSessionContext();

                #region Validate account

                int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

                #endregion

                Subscription existingSub;
                try
                {
                    GetSubscriptionDetail(acct, subscriptionId, out existingSub);
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Error getting subscription detail", e);

                    throw new MASBasicException("Specified subscription Id is invalid");
                }

                int numTries = 0;
                bool isSuccess = false;
                while ((isSuccess == false) && (numTries < MAX_TRIES))
                {

                    numTries++;

                    using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                    {
                        try
                        {
                            IMTProductCatalog prodCat = new MTProductCatalogClass();
                            IMTPCAccount pcAcct = prodCat.GetAccount(id_acc);

                            pcAcct.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

                            pcAcct.RemoveSubscription(subscriptionId);

                            using (IMTConnection conn = ConnectionManager.CreateConnection("queries\\ProductCatalog"))
                            {
                                using (IMTAdapterStatement deleteCharValStmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__DELETE_CHAR_VALS_FOR_SUB__"))
                                {
                                    deleteCharValStmt.AddParam("%%ID_SUB%%", subscriptionId);
                                    deleteCharValStmt.ExecuteNonQuery();
                                }
                            }
                            scope.Complete();
                            isSuccess = true;
                        }
                        catch (COMException comE)
                        {
                            // The COMException might be related to a DB deadlock.
                            // So, attempt a retry if appropriate.
                            m_Logger.LogError("Caught COMException while deleting subscription, numTries={0}", numTries);
                            if (numTries == (MAX_TRIES - 1))
                            {
                                // We have exceeded the number of "tries"
                                m_Logger.LogException("COM Exception deleting subscription", comE);
                                throw new MASBasicException(comE.Message);
                            }
                            else
                            {
                                // attempt a retry
                                scope.Dispose();
                                continue;
                            }
                        }
                        catch (Exception e)
                        {
                            m_Logger.LogException("Error deleting subscription", e);

                            throw new MASBasicException("Error deleting specified subscription");

                        }
                    }
                }
            }
        }

        [OperationCapability("View subscriptions")]
        public void GetCharacteristicValues(ref MTList<CharacteristicValue> charVals)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetCharacteristicValues"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
                    {
                        using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS", "__GET_CHAR_VALS__"))
                        {
                            ApplyFilterSortCriteria<CharacteristicValue>(stmt, charVals);

                            using (IMTDataReader dataReader = stmt.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    // TODO Localization
                                    CharacteristicValue val = new CharacteristicValue();
                                    val.SpecCharValId = dataReader.GetInt32("SpecCharValId");
                                    val.EntityId = dataReader.GetInt32("EntityId");
                                    val.Value = dataReader.GetString("Value");
                                    val.StartDate = dataReader.GetDateTime("StartDate");
                                    val.EndDate = dataReader.GetDateTime("EndDate");
                                    val.SpecName = dataReader.GetString("SpecName");
                                    PropertyType specType =
                                      (PropertyType)
                                      EnumHelper.GetEnumByValue(typeof(PropertyType), dataReader.GetInt32("SpecType").ToString());
                                    val.SpecType = specType;
                                    val.UserVisible = dataReader.GetBoolean("UserVisible");
                                    val.UserEditable = dataReader.GetBoolean("UserEditable");
                                    charVals.Items.Add(val);
                                }
                            }
                            charVals.TotalRows = stmt.TotalRows;
                        }
                    }

                    m_Logger.LogDebug("Retrieved {0} characteristic values ", charVals.TotalRows);
                }
                catch (CommunicationException e)
                {
                    m_Logger.LogException("Cannot retrieve characteristic values from system ", e);
                    throw;
                }

                catch (Exception e)
                {
                    m_Logger.LogException("Cannot retrieve characteristic values from system  ", e);
                    throw new MASBasicException("Cannot retrieve characteristic values from system ");
                }
            }
        }

        #endregion

        #region Public Members

        public void SaveCharacteristicValue(List<CharacteristicValue> characteristicValues, long subscriptionID)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("SaveCharacteristicValue"))
            {
                if (characteristicValues != null && characteristicValues.Count > 0)
                {
                    string insertStmt = "BEGIN\n";
                    IMTQueryAdapter qa = new MTQueryAdapterClass();
                    qa.Init(@"Queries\ProductCatalog");

                    foreach (CharacteristicValue cv in characteristicValues)
                    {
                        qa.SetQueryTag("__SAVE_CHAR_VALS_FOR_SUB__");
                        qa.AddParam("%%SPEC_CHAR_VAL_ID%%", cv.SpecCharValId);
                        qa.AddParam("%%ENTITY_ID%%", subscriptionID);
                        qa.AddParam("%%VALUE%%", cv.Value);
                        qa.AddParam("%%START_DATE%%", cv.StartDate);
                        qa.AddParam("%%END_DATE%%", cv.EndDate);
                        qa.AddParam("%%SPEC_NAME%%", cv.SpecName);
                        qa.AddParam("%%SPEC_TYPE%%", cv.SpecType);
                        insertStmt += qa.GetQuery().Trim() + ";\n";
                    }

                    insertStmt += "END;";
                    m_Logger.LogDebug(insertStmt);

                    using (IMTConnection conn = ConnectionManager.CreateConnection("queries\\ProductCatalog"))
                    using (IMTStatement stmt = conn.CreateStatement(insertStmt))
                    {
                        stmt.ExecuteNonQuery();
                    }
                    m_Logger.LogDebug("Saving characteristic value for subscription.");
                }
            }
        }

        #endregion

        #region Private Members

        private Subscription PopulateSubscribedProductOffering(
          MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData, IMTDataReader rdr)
        {
            Subscription sub = new Subscription();
            ProductOffering po = new ProductOffering();
            Type poType = po.GetType();

            sub.ProductOffering = po;

            string fieldName, propName;
            PropertyInfo propInfo;
            for (int i = 0; i < rdr.FieldCount; i++)
            {
                fieldName = rdr.GetName(i);

                switch (fieldName)
                {
                    case "id_po":
                        sub.ProductOfferingId = rdr.GetInt32(i);
                        po.ProductOfferingId = sub.ProductOfferingId;
                        break;

                    case "id_sub":
                        sub.SubscriptionId = rdr.GetInt32(i);
                        break;

                    case "dt_start":
                        if (!rdr.IsDBNull(i))
                        {
                            sub.SubscriptionSpan.StartDate = rdr.GetDateTime(i);
                        }
                        break;

                    case "dt_end":
                        if (!rdr.IsDBNull(i))
                        {
                            sub.SubscriptionSpan.EndDate = rdr.GetDateTime(i);
                        }
                        break;

                    case "po_nm_name":
                        po.Name = rdr.GetString(i);
                        break;

                    case "po_nm_display_name":
                        po.DisplayName = rdr.GetString(i);
                        break;

                    case "b_recurringcharge":
                        po.HasRecurringCharges = rdr.GetBoolean(i);
                        break;

                    case "b_discount":
                        po.HasDiscounts = rdr.GetBoolean(i);
                        break;

                    case "b_personalrate":
                        po.HasPersonalRates = rdr.GetBoolean(i);
                        break;

                    case "b_user_unsubscribe":
                        po.CanUserUnsubscribe = rdr.GetBoolean(i);
                        break;

                    #region Ignored Fields

                    case "id_sub_ext":
                    case "id_acc":
                    case "vt_start":
                    case "vt_end":
                    case "po_n_name":
                    case "po_n_display_name":
                    case "rownumber":
                        break;

                    #endregion

                    #region Handle Extended Properties

                    default:
                        propName = null;
                        foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData propData in metaData)
                        {
                            if (string.Compare(fieldName, propData.DBAliasName, true) == 0)
                            {
                                propName = propData.Name;
                                break;
                            }
                        }

                        if (propName != null)
                        {
                            propInfo = poType.GetProperty(propName,
                                                          BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.Public);

                            if (propInfo != null)
                            {
                                // Handle enums
                                if (EnumHelper.IsEnumType(propInfo.PropertyType))
                                {
                                    if (!rdr.IsDBNull(i))
                                    {
                                        // Get the generated enum based on rowset value (t_enum_data.id_enum_data)
                                        object mtEnum = EnumHelper.GetCSharpEnum(rdr.GetInt32(i));
                                        if (mtEnum == null)
                                        {
                                            m_Logger.LogError("Unable to find enum");
                                            throw new MASBasicException("Unable to find enum");
                                        }

                                        propInfo.SetValue(po, mtEnum, null);
                                    }
                                }
                                else
                                {
                                    if (!rdr.IsDBNull(i))
                                    {
                                        if (propInfo.PropertyType.FullName.Contains("Boolean"))
                                        {
                                            propInfo.SetValue(po, rdr.GetBoolean(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Decimal"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDecimal(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Double"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDecimal(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Float"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDecimal(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Int64"))
                                        {
                                            propInfo.SetValue(po, rdr.GetInt64(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("String"))
                                        {
                                            propInfo.SetValue(po, rdr.GetString(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Int32"))
                                        {
                                            propInfo.SetValue(po, rdr.GetInt32(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("DateTime"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDateTime(i), null);
                                        }
                                        else
                                        {
                                            propInfo.SetValue(po, rdr.GetValue(i), null);
                                        }
                                    }
                                }
                            }
                        }
                        break;

                    #endregion
                }
            }

            return sub;
        }

        private string GetColumnNameFromSubscribedPOPropertyName(string propName, ref object filterVal, object helper)
        {
            MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData =
              (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet)helper;

            if ((propName.IndexOf("#") > 0) && (propName.IndexOf("#") < propName.Length))
            {
                propName = propName.Substring(propName.IndexOf("#") + 1);
            }
            switch (propName)
            {

                case "ProductOffering_ProductOfferingId":
                    return "id_po";
                    break;

                case "ProductOfferingId":
                    return "id_po";
                    break;

                case "SubscriptionId":
                    return "id_sub";
                    break;

                case "SubscriptionSpan_StartDate":
                case "SubscriptionSpan.StartDate":
                case "StartDate":
                    return "dt_start";
                    break;

                case "SubscriptionSpan_EndDate":
                case "SubscriptionSpan.EndDate":
                case "EndDate":
                    return "dt_end";
                    break;

                case "ProductOffering_Name":
                case "ProductOffering.Name":
                case "Name":
                    return "po_nm_name";
                    break;

                case "ProductOffering_DisplayName":
                case "ProductOffering.DisplayName":
                case "DisplayName":
                    return "po_nm_display_name";
                    break;

                case "ProductOffering_HasRecurringCharges":
                case "ProductOffering.HasRecurringCharges":
                case "HasRecurringCharges":
                    if (filterVal != null)
                    {
                        bool val = (bool)filterVal;

                        if (val)
                        {
                            filterVal = "Y";
                        }
                        else
                        {
                            filterVal = "N";
                        }
                    }

                    return "b_recurringcharge";
                    break;

                case "ProductOffering_HasDiscounts":
                case "ProductOffering.HasDiscounts":
                case "HasDiscounts":
                    if (filterVal != null)
                    {
                        bool val = (bool)filterVal;

                        if (val)
                        {
                            filterVal = "Y";
                        }
                        else
                        {
                            filterVal = "N";
                        }
                    }

                    return "b_discount";
                    break;

                case "ProductOffering_HasPersonalRates":
                case "ProductOffering.HasPersonalRates":
                case "HasPersonalRates":
                    if (filterVal != null)
                    {
                        bool val = (bool)filterVal;

                        if (val)
                        {
                            filterVal = "Y";
                        }
                        else
                        {
                            filterVal = "N";
                        }
                    }

                    return "b_personalrate";
                    break;

                case "ProductOffering_CanUserUnsubscribe":
                case "ProductOffering.CanUserUnsubscribe":
                case "CanUserUnsubscribe":
                    return "b_user_unsubscribe";
                    break;

                #region Handle Extended Properties

                default:
                    foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData propData in metaData)
                    {
                        if (string.Compare(propName, propData.Name, true) == 0)
                        {
                            return propData.DBAliasName;
                            break;
                        }
                    }

                    throw new MASBasicException("Specified field not not valid for filtering or sorting");
                    break;

                #endregion
            }
            ;
        }

        public ProductOffering PopulateProductOffering(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData,
                                                       IMTDataReader rdr)
        {
            ProductOffering po = new ProductOffering();
            Type poType = po.GetType();

            string fieldName, propName;
            //int propNameStart;
            PropertyInfo propInfo;
            for (int i = 0; i < rdr.FieldCount; i++)
            {
                fieldName = rdr.GetName(i);

                switch (fieldName)
                {
                    case "id_po":
                        po.ProductOfferingId = rdr.GetInt32(i);
                        break;

                    case "id_eff_date":
                        po.EffectiveTimeSpan.TimeSpanId = rdr.GetInt32(i);
                        break;

                    case "te_n_begintype":
                        po.EffectiveTimeSpan.StartDateType = (ProdCatTimeSpan.MTPCDateType)rdr.GetInt32(i);
                        break;

                    case "te_dt_start":
                        if (!rdr.IsDBNull(i))
                        {
                            po.EffectiveTimeSpan.StartDate = rdr.GetDateTime(i);
                        }
                        break;

                    case "te_n_beginoffset":
                        po.EffectiveTimeSpan.StartDateOffset = rdr.GetInt32(i);
                        break;

                    case "te_n_endtype":
                        po.EffectiveTimeSpan.EndDateType = (ProdCatTimeSpan.MTPCDateType)rdr.GetInt32(i);
                        break;

                    case "te_dt_end":
                        if (!rdr.IsDBNull(i))
                        {
                            po.EffectiveTimeSpan.EndDate = rdr.GetDateTime(i);
                        }
                        break;

                    case "te_n_endoffset":
                        po.EffectiveTimeSpan.EndDateOffset = rdr.GetInt32(i);
                        break;

                    case "id_avail":
                        po.AvailableTimeSpan.TimeSpanId = rdr.GetInt32(i);
                        break;

                    case "ta_n_begintype":
                        po.AvailableTimeSpan.StartDateType = (ProdCatTimeSpan.MTPCDateType)rdr.GetInt32(i);
                        break;

                    case "ta_dt_start":
                        if (!rdr.IsDBNull(i))
                        {
                            po.AvailableTimeSpan.StartDate = rdr.GetDateTime(i);
                        }
                        break;

                    case "ta_n_beginoffset":
                        po.AvailableTimeSpan.StartDateOffset = rdr.GetInt32(i);
                        break;

                    case "ta_n_endtype":
                        po.AvailableTimeSpan.EndDateType = (ProdCatTimeSpan.MTPCDateType)rdr.GetInt32(i);
                        break;

                    case "ta_dt_end":
                        if (!rdr.IsDBNull(i))
                        {
                            po.AvailableTimeSpan.EndDate = rdr.GetDateTime(i);
                        }
                        break;

                    case "ta_n_endoffset":
                        po.AvailableTimeSpan.EndDateOffset = rdr.GetInt32(i);
                        break;

                    case "nm_name":
                        po.Name = rdr.GetString(i);
                        break;

                    case "nm_display_name":
                        if (!rdr.IsDBNull(i))
                        {
                            po.DisplayName = rdr.GetString(i);
                        }
                        break;

                    case "nm_desc":
                        if (!rdr.IsDBNull(i))
                        {
                            po.Description = rdr.GetString(i);
                        }
                        break;

                    case "b_recurringcharge":
                        po.HasRecurringCharges = rdr.GetBoolean(i);
                        break;

                    case "b_discount":
                        po.HasDiscounts = rdr.GetBoolean(i);
                        break;

                    case "b_personalrate":
                        po.HasPersonalRates = rdr.GetBoolean(i);
                        break;

                    case "b_user_subscribe":
                        po.CanUserSubscribe = rdr.GetBoolean(i);
                        break;

                    case "b_user_unsubscribe":
                        po.CanUserUnsubscribe = rdr.GetBoolean(i);
                        break;

                    #region Ignored Fields

                    case "n_name":
                    case "n_desc":
                    case "n_display_name":
                    case "rownumber":
                    case "b_hidden":
                        break;

                    #endregion

                    #region Handle the extended properties

                    default:
                        propName = null;
                        foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData propData in metaData)
                        {
                            if (string.Compare(fieldName, propData.DBAliasName, true) == 0)
                            {
                                propName = propData.Name;
                                break;
                            }
                        }

                        if (propName != null)
                        {
                            propInfo = poType.GetProperty(propName,
                                                          BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.Public);

                            if (propInfo != null)
                            {
                                // Handle enums
                                if (EnumHelper.IsEnumType(propInfo.PropertyType))
                                {
                                    if (!rdr.IsDBNull(i))
                                    {
                                        // Get the generated enum based on rowset value (t_enum_data.id_enum_data)
                                        object mtEnum = EnumHelper.GetCSharpEnum(rdr.GetInt32(i));
                                        if (mtEnum == null)
                                        {
                                            m_Logger.LogError("Unable to find enum");
                                            throw new MASBasicException("Unable to find enum");
                                        }

                                        propInfo.SetValue(po, mtEnum, null);
                                    }
                                }
                                else
                                {
                                    if (!rdr.IsDBNull(i))
                                    {
                                        if (propInfo.PropertyType.FullName.Contains("Boolean"))
                                        {
                                            propInfo.SetValue(po, rdr.GetBoolean(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Decimal"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDecimal(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Double"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDecimal(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Float"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDecimal(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Int64"))
                                        {
                                            propInfo.SetValue(po, rdr.GetInt64(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("String"))
                                        {
                                            propInfo.SetValue(po, rdr.GetString(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("Int32"))
                                        {
                                            propInfo.SetValue(po, rdr.GetInt32(i), null);
                                        }
                                        else if (propInfo.PropertyType.FullName.Contains("DateTime"))
                                        {
                                            propInfo.SetValue(po, rdr.GetDateTime(i), null);
                                        }
                                        else
                                        {
                                            propInfo.SetValue(po, rdr.GetValue(i), null);
                                        }
                                    }
                                }
                            }
                        }
                        break;

                    #endregion
                }
            }

            return po;
        }

        public string GetColumnNameFromProductOfferingPropertyname(string propName, ref object filterVal, object helper)
        {
            MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData =
              (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet)helper;

            if ((propName.IndexOf("#") > 0) && (propName.IndexOf("#") < propName.Length))
            {
                propName = propName.Replace("#", "_");
            }

            switch (propName)
            {
                case "ProductOfferingId":
                    return "id_po";
                    break;

                case "TimeSpanId":
                case "EffectiveTimeSpan_TimeSpanId":
                case "EffectiveTimeSpan.TimeSpanId":
                    return "id_eff_date";
                    break;

                case "StartDateType":
                case "EffectiveTimeSpan_StartDateType":
                case "EffectiveTimeSpan.StartDateType":
                    return "te_n_begintype";
                    break;

                case "EffectiveTimeSpan_StartDate":
                case "EffectiveTimeSpan.StartDate":
                    return "te_dt_start";
                    break;

                case "StartDateOffset":
                case "EffectiveTimeSpan_StartDateOffset":
                case "EffectiveTimeSpan.StartDateOffset":
                    return "te_n_beginoffset";
                    break;

                case "EffectiveTimeSpan_EndDateType":
                case "EffectiveTimeSpan.EndDateType":
                    return "te_n_endtype";
                    break;

                case "EffectiveTimeSpan_EndDate":
                case "EffectiveTimeSpan.EndDate":
                    return "te_dt_end";
                    break;

                case "EffectiveTimeSpan_EndDateOffset":
                case "EffectiveTimeSpan.EndDateOffset":
                    return "te_n_endoffset";
                    break;

                case "AvailableTimeSpan_TimeSpanId":
                case "AvailableTimeSpan.TimeSpanId":
                    return "id_avail";
                    break;

                case "AvailableTimeSpan_StartDateType ":
                case "AvailableTimeSpan.StartDateType ":
                    return "ta_n_begintype";
                    break;

                case "AvailableTimeSpan_StartDate":
                case "AvailableTimeSpan.StartDate":
                    return "ta_dt_start";
                    break;

                case "AvailableTimeSpan_StartDateOffset":
                case "AvailableTimeSpan.StartDateOffset":
                    return "ta_n_beginoffset";
                    break;

                case "AvailableTimeSpan_EndDateType":
                case "AvailableTimeSpan.EndDateType":
                    return "ta_n_endtype";
                    break;

                case "AvailableTimeSpan_EndDate":
                case "AvailableTimeSpan.EndDate":
                    return "ta_dt_end";
                    break;

                case "AvailableTimeSpan_EndDateOffset":
                case "AvailableTimeSpan.EndDateOffset":
                    return "ta_n_endoffset";
                    break;

                case "Name":
                    return "nm_name";
                    break;

                case "DisplayName":
                    return "nm_display_name";
                    break;

                case "Description":
                    return "nm_desc";
                    break;

                case "HasRecurringCharges":
                    if (filterVal != null)
                    {
                        bool val = Convert.ToBoolean(filterVal);

                        if (val)
                        {
                            filterVal = "Y";
                        }
                        else
                        {
                            filterVal = "N";
                        }
                    }

                    return "b_recurringcharge";
                    break;

                case "HasDiscounts":
                    if (filterVal != null)
                    {
                        bool val = Convert.ToBoolean(filterVal);

                        if (val)
                        {
                            filterVal = "Y";
                        }
                        else
                        {
                            filterVal = "N";
                        }
                    }
                    return "b_discount";
                    break;

                case "HasPersonalRates":
                    return "b_personalrate";
                    break;

                case "CanUserSubscribe":
                    return "b_user_subscribe";
                    break;

                case "CanUserUnsubscribe":
                    return "b_user_unsubscribe";
                    break;

                #region Handle the extended properties

                default:
                    foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData propData in metaData)
                    {
                        if (string.Compare(propName, propData.Name, true) == 0)
                        {
                            return propData.DBAliasName;
                            break;
                        }
                    }

                    throw new MASBasicException("Specified field not not valid for filtering or sorting");
                    break;

                #endregion
            }
        }

        private void ApplyDirtyProperties(ref Subscription existingSub, Subscription sub)
        {
            if (sub.SubscriptionSpan != null)
            {
                if (sub.SubscriptionSpan.IsStartDateDirty)
                {
                    existingSub.SubscriptionSpan.StartDate = sub.SubscriptionSpan.StartDate;
                }

                if (sub.SubscriptionSpan.IsStartDateOffsetDirty)
                {
                    existingSub.SubscriptionSpan.StartDateOffset = sub.SubscriptionSpan.StartDateOffset;
                }

                if (sub.SubscriptionSpan.IsStartDateTypeDirty)
                {
                    existingSub.SubscriptionSpan.StartDateType = sub.SubscriptionSpan.StartDateType;
                }

                if (sub.SubscriptionSpan.IsEndDateDirty)
                {
                    existingSub.SubscriptionSpan.EndDate = sub.SubscriptionSpan.EndDate;
                }

                if (sub.SubscriptionSpan.IsEndDateOffsetDirty)
                {
                    existingSub.SubscriptionSpan.EndDateOffset = sub.SubscriptionSpan.EndDateOffset;
                }

                if (sub.SubscriptionSpan.IsEndDateTypeDirty)
                {
                    existingSub.SubscriptionSpan.EndDateType = sub.SubscriptionSpan.EndDateType;
                }
            }
        }

        #endregion
    }
}