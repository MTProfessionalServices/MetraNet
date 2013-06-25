using System;
using System.Diagnostics;
using System.Threading;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using System.Reflection;
using MetraTech.DomainModel.ProductView;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using MetraTech.OnlineBill;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.Interop.COMDBObjects;
using HR = MetraTech.Interop.MTHierarchyReports;
using MetraTech.Interop.MTAuthExec;
using MetraTech.Interop.Rowset;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTHierarchyReports;
using MetraTech.DomainModel.Common;
using BILL = MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global;
using ProductViewLib = MetraTech.Interop.MTProductView;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments;
using System.Collections;
using MetraTech.Debug.Diagnostics;


namespace MetraTech.Core.Services
{
    [ServiceContract]
    public partial interface IUsageHistoryService
    {
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccountIntervals(AccountIdentifier accountID, out List<Interval> acctIntervals);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetInvoiceReport(AccountIdentifier owner, int intervalID, LanguageCode languageID, bool inlineVATTaxes, out InvoiceReport report);

        #region ByFolder original deprecated methods
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetByFolderReportLevel(AccountIdentifier owner, AccountIdentifier folder, ReportParameters repParams, out ReportLevel reportData);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetByFolderReportLevelChildren(AccountIdentifier owner, AccountIdentifier folder, string hierarchyPath, ReportParameters repParams, ref MTList<ReportLevel> children);
        #endregion

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetByProductReport(AccountIdentifier owner, ReportParameters repParams, out ReportLevel reportData);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetUsageDetails(ReportParameters repParams,
                                SingleProductSlice productSlice,
                                AccountSlice accountSlice,
                                ref MTList<BaseProductView> usageDetails);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetUsageDetailsAll(ReportParameters repParams,
                                SingleProductSlice productSlice,
                                AccountSlice accountSlice,
                                bool populateAdjustmentInfo,
                                ref List<BaseProductView> usageDetails);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetCompoundChildUsageSummaries(ReportParameters repParams,
                                            AccountSlice accountSlice,
                                            Int64 parentSessionID,
                                            out List<ChildUsageSummary> childUsageSummaries);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetBaseAdjustmentDetails(BILL.TimeSlice timeSlice,
                                        AccountSlice accountSlice,
                                        bool isPostbill,
                                        LanguageCode languageId,
                                        ref MTList<BaseAdjustmentDetail> adjustmentDetails);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetBillingHistory(AccountIdentifier accountID, LanguageCode languageID, out List<Interval> intervals);

        [OperationContract]
        [FaultContract(typeof(MASBaseFaultDetail))]
        void GetPaymentHistory(AccountIdentifier accountID, LanguageCode languageID, ref MTList<Payment> payments);

        [OperationContract]
        [FaultContract(typeof(MASBaseFaultDetail))]
        void GetPaymentInfo(AccountIdentifier accountID, LanguageCode languageID, ref PaymentInfo paymentInfo);

    }

    [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
    public partial class UsageHistoryService : CMASServiceBase, IUsageHistoryService
    {
        #region Private Members
        private static Logger mLogger = new Logger("[UsageHistoryService]");
        #region Constants
        const uint MTAUTH_ACCESS_DENIED = 0xE29F0001;

        const string METRAVIEW_QUERY_FOLDER = "Queries\\MetraViewServices";

        const string DB_COMPOUND_SESSION = "Compound";
        const string DB_ATOMIC_SESSION = "Atomic";

        #region Display Amount Constants
        const string AMOUNT = "au.Amount";
        const string TOTAL_TAX = "{fn IFNULL((tax_federal), 0.0)} + {fn IFNULL((tax_state), 0.0)} + {fn IFNULL((tax_county), 0.0)} + " +
                                "{fn IFNULL((tax_local), 0.0)} + {fn IFNULL((tax_other), 0.0)}";
        const string PRE_BILL_ADJ_AMOUNT = "{fn IFNULL((CompoundPrebillAdjAmt), 0.0)}";
        const string POST_BILL_ADJ_AMOUNT = "{fn IFNULL((CompoundPostbillAdjAmt), 0.0)}";
        const string PRE_BILL_TOTAL_TAX_ADJ_AMOUNT = "{fn IFNULL((CompoundPrebillTotalTaxAdjAmt), 0.0)}";
        const string POST_BILL_TOTAL_TAX_ADJ_AMOUNT = "{fn IFNULL((CompoundPostbillTotalTaxAdjAmt), 0.0)}";
        #endregion

        #endregion

        private enum TaxType { Other, Fed, State, Local, Cnty, Total, Implied, Informational, ImplInf, Billable, Nonimplied }
        private enum AtomicOrCompoundType { Atomic, Compound }
        private enum DisplayModeEnum
        {
            ONLINE_BILL,
            ONLINE_BILL_ADJUSTMENTS,
            ONLINE_BILL_ADJUSTMENTS_TAXES,
            ONLINE_BILL_TAXES,
            REPORT,
            REPORT_ADJUSTMENTS,
            REPORT_ADJUSTMENTS_TAXES,
            REPORT_TAXES,
        }

        private Manager mMVManager;

        private struct ProductViewData
        {
            public int ID { get; set; }
            public string Name { get; set; }
            public bool HasChildren { get; set; }
        }

        private static Dictionary<int, ProductViewData> m_PVIdToNameMap = new Dictionary<int, ProductViewData>();
        private static Dictionary<string, ProductViewData> m_PVNameToIdMap = new Dictionary<string, ProductViewData>(StringComparer.CurrentCultureIgnoreCase);

        private static Dictionary<int, ProductViewLib.ProductView> m_ProductViews = new Dictionary<int, MetraTech.Interop.MTProductView.ProductView>();

        private static Dictionary<int, string> m_UsageDetailQueries = new Dictionary<int, string>();
        // ESR-5421
        private static Dictionary<int, string> m_UsageDetailQueriesInterval = new Dictionary<int, string>();

        private const string PAYMENT_PRODUCTVIEW = "METRATECH.COM/PAYMENT";
        #endregion

        static UsageHistoryService()
        {
            CMASServiceBase.ServiceStarting += new ServiceStartingEventHandler(CMASServiceBase_ServiceStarting);
        }

        static void CMASServiceBase_ServiceStarting()
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateStatement("select pv.id_view, nm_name, case when (COUNT(*) - 1 > 0) then 1 else 0 end " +
                                                                    "hasChildren from t_prod_view pv left outer join t_view_hierarchy vh on " +
                                                                    "pv.id_view = vh.id_view_parent group by pv.id_view, nm_name"))
                {
                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            ProductViewData data = new ProductViewData();
                            data.ID = rdr.GetInt32(0);
                            data.Name = rdr.GetString(1);
                            data.HasChildren = (rdr.GetInt32(2) == 1 ? true : false);

                            m_PVIdToNameMap.Add(data.ID, data);
                            m_PVNameToIdMap.Add(data.Name, data);
                        }
                    }
                }
            }
        }

        #region IUsageHistoryService Members

        public void GetAccountIntervals(AccountIdentifier accountID, out List<Interval> acctIntervals)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountIntervals"))
            {
                try
                {
                    acctIntervals = new List<Interval>();

                    if (accountID == null)
                    {
                        throw new MASBasicException("Must specify identifier of priceable item template to be loaded");
                    }

                    int accountId = AccountIdentifierResolver.ResolveAccountIdentifier(accountID);
                    if (accountId == -1)
                        throw new MASBasicException("Invalid Account Identifier sepecified.");

                    COMDataAccessor dataAccessor = new COMDataAccessorClass();
                    dataAccessor.AccountID = accountId;
                    MetraTech.Interop.MTYAAC.IMTSQLRowset usageIntervals = (MetraTech.Interop.MTYAAC.IMTSQLRowset)dataAccessor.GetUsageInterval();

                    if (usageIntervals.RecordCount > 0)
                    {
                        usageIntervals.MoveFirst();
                        while (!Convert.ToBoolean(usageIntervals.EOF))
                        {
                            Interval interval = new Interval();
                            interval.ID = (int)usageIntervals.get_Value("IntervalID");
                            interval.StartDate = (DateTime)usageIntervals.get_Value("StartDate");
                            interval.EndDate = (DateTime)usageIntervals.get_Value("EndDate");
                            interval.Status = GetIntervalStatusCode(usageIntervals.get_Value("Status").ToString()); // (IntervalStatusCode)Enum.Parse(typeof(IntervalStatusCode), usageIntervals.get_Value("Status").ToString());
                            interval.InvoiceNumber = usageIntervals.get_Value("InvoiceNumber").ToString();

                            acctIntervals.Add(interval);
                            usageIntervals.MoveNext();
                        }

                    }

                }
                catch (MASBasicException masBasic)
                {
                    mLogger.LogException("Exception while getting account intervals", masBasic);
                    throw;
                }
                catch (COMException comE)
                {
                    mLogger.LogException("COM Exception getting account intervals", comE);
                    throw new MASBasicException(comE.Message);
                }
                catch (Exception e)
                {
                    mLogger.LogException("Exception getting account intervals", e);
                    throw new MASBasicException("Error getting account intervals");
                }
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetInvoiceReport(AccountIdentifier owner, int intervalID, LanguageCode languageID, bool inlineVATTaxes, out InvoiceReport report)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetInvoiceReport"))
            {
                mLogger.LogInfo("Executing GetInvoiceReport Method in UsageHistoryService");
                try
                {
                    int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(owner);

                    #region Check Caller Has "Manage Account Hierarchies" capability



                    if (!HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                        MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }

                    #endregion

                    int payerId = acctId;

                    InvoiceReport invReport = new InvoiceReport();

                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        #region Get Invoice Report - Invoice Header.
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);
                            queryAdapter.Item.SetQueryTag("__GET_INVOICE_REPORT__");

                            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("idInterval", MTParameterType.Integer, intervalID);
                                stmt.AddParam("idAcc", MTParameterType.Integer, acctId);

                                using (IMTDataReader reader = stmt.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        InvoiceInfo invInfo = new InvoiceInfo();
                                        invInfo.Currency = reader.GetString("currency");
                                        invInfo.ID = reader.GetInt32("id_invoice");
                                        invInfo.IntervalEndDate = reader.GetDateTime("interval_end");
                                        invInfo.IntervalID = reader.GetInt32("id_interval");
                                        invInfo.IntervalStartDate = reader.GetDateTime("interval_start");
                                        invInfo.InvoiceDate = reader.GetDateTime("invoice_date");
                                        invInfo.InvoiceDueDate = reader.GetDateTime("invoice_due_date");
                                        invInfo.InvoiceNum = reader.GetInt32("id_invoice_num");
                                        invInfo.InvoiceString = reader.GetString("invoice_string");
                                        payerId = reader.GetInt32("id_payer");
                                        invReport.InvoiceHeader = invInfo;

                                        InvoiceBalances invBalances = new InvoiceBalances();
                                        invBalances.BalanceForward = reader.GetDecimal("balance_forward");
                                        invBalances.Currency = invInfo.Currency;
                                        invBalances.BalanceForwardAsString = LocalizeCurrencyString(invBalances.BalanceForward, languageID, invBalances.Currency);
                                        invBalances.CurrentBalance = reader.GetDecimal("current_balance");
                                        invBalances.CurrentBalanceAsString = LocalizeCurrencyString(invBalances.CurrentBalance, languageID, invBalances.Currency);
                                        invBalances.Estimation = EstimationType.None;
                                        invBalances.PreviousBalance = reader.GetDecimal("previous_balance");
                                        invBalances.PreviousBalanceAsString = LocalizeCurrencyString(invBalances.PreviousBalance, languageID, invBalances.Currency);

                                        invReport.PreviousBalances = invBalances;
                                    }
                                }
                            }
                        }
                        #endregion

                        #region Get Balance without Invoice Header.
                        if (invReport.InvoiceHeader == null)
                        {
                            string spName = string.Format("GETBALANCES{0}", IsDataMartEnabled() ? "_DATAMART" : "");

                            using (IMTCallableStatement stmt = conn.CreateCallableStatement(spName))
                            {
                                stmt.AddParam("@id_acc", MTParameterType.Integer, acctId);
                                stmt.AddParam("@id_interval", MTParameterType.Integer, intervalID);
                                stmt.AddOutputParam("@previous_balance", MTParameterType.Decimal);
                                stmt.AddOutputParam("@balance_forward", MTParameterType.Decimal);
                                stmt.AddOutputParam("@current_balance", MTParameterType.Decimal);
                                stmt.AddOutputParam("@currency", MTParameterType.String, 3);
                                stmt.AddOutputParam("@estimation_code", MTParameterType.Integer);
                                stmt.AddOutputParam("@return_code", MTParameterType.Integer);

                                stmt.ExecuteNonQuery();

                                int returnCode = (int)stmt.GetOutputValue("@return_code");

                                if (returnCode == 1)
                                {
                                    throw new MASBasicException("currency mismatch while running getbalances stored proc");
                                }

                                EstimationType estType = (EstimationType)((int)stmt.GetOutputValue("@estimation_code"));

                                InvoiceBalances invBalances = new InvoiceBalances();
                                invBalances.BalanceForward = (decimal)stmt.GetOutputValue("@balance_forward");
                                invBalances.Currency = (string)stmt.GetOutputValue("@currency");
                                invBalances.BalanceForwardAsString = LocalizeCurrencyString(invBalances.BalanceForward, languageID, invBalances.Currency);
                                invBalances.CurrentBalance = (decimal)stmt.GetOutputValue("@current_balance");
                                invBalances.CurrentBalanceAsString = LocalizeCurrencyString(invBalances.CurrentBalance, languageID, invBalances.Currency);
                                invBalances.Estimation = estType;
                                invBalances.PreviousBalance = (decimal)stmt.GetOutputValue("@previous_balance");
                                invBalances.PreviousBalanceAsString = LocalizeCurrencyString(invBalances.PreviousBalance, languageID, invBalances.Currency);

                                invReport.PreviousBalances = invBalances;
                            }
                        }
                        #endregion

                        if (invReport.InvoiceHeader == null)
                        {
                            invReport.InvoiceHeader = new InvoiceInfo();
                        }

                        #region Get invoice Report Accounts
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);
                            queryAdapter.Item.SetQueryTag("__GET_INVOICE_REPORT_ACCOUNTS__");

                            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("idAcc", MTParameterType.Integer, acctId);
                                stmt.AddParam("idPayer", MTParameterType.Integer, payerId);

                                using (IMTDataReader reader = stmt.ExecuteReader())
                                {
                                    while (reader.Read())
                                    {
                                        InvoiceAccount invAcct = new InvoiceAccount();
                                        invAcct.ID = reader.GetInt32("id_acc");
                                        invAcct.ExternalID = reader.GetString("external_account_id");
                                        invAcct.Address1 = !reader.IsDBNull("address1") ? reader.GetString("address1") : "";
                                        invAcct.Address2 = !reader.IsDBNull("address2") ? reader.GetString("address2") : "";
                                        invAcct.Address3 = !reader.IsDBNull("address3") ? reader.GetString("address3") : "";
                                        invAcct.Company = !reader.IsDBNull("company") ? reader.GetString("company") : "";
                                        invAcct.City = !reader.IsDBNull("city") ? reader.GetString("city") : "";
                                        invAcct.State = !reader.IsDBNull("state") ? reader.GetString("state") : "";
                                        invAcct.Zip = !reader.IsDBNull("zip") ? reader.GetString("zip") : "";
                                        if (!reader.IsDBNull("country"))
                                        {
                                            invAcct.Country = (CountryName)EnumHelper.GetCSharpEnum(reader.GetInt32("country"));
                                        }
                                        invAcct.FirstName = !reader.IsDBNull("firstname") ? reader.GetString("firstname") : "";
                                        invAcct.LastName = !reader.IsDBNull("lastname") ? reader.GetString("lastname") : "";
                                        invAcct.MiddleInitial = !reader.IsDBNull("middleinitial") ? reader.GetString("middleinitial") : "";

                                        if (invReport.InvoiceHeader.PayeeAccount == null && invAcct.ID == acctId)
                                        {
                                            invReport.InvoiceHeader.PayeeAccount = invAcct;
                                        }

                                        if (invReport.InvoiceHeader.PayerAccount == null && invAcct.ID == payerId)
                                        {
                                            invReport.InvoiceHeader.PayerAccount = invAcct;
                                        }
                                    }
                                }
                            }
                        }
                        #endregion

                        #region Get Adjustments, Payments and Post-bill Adjustments.
                        string queryString = string.Format("__GET_ADJUSTMENTS_PAYMENTS{0}__", DataMartEnabledString());

                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);
                            queryAdapter.Item.SetQueryTag(queryString);

                            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.SetResultSetCount(3);

                                stmt.AddParam("idAcc", MTParameterType.Integer, acctId);
                                stmt.AddParam("idInterval", MTParameterType.Integer, intervalID);
                                stmt.AddParam("idLangcode", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(languageID, 1)));
                                stmt.AddParam("viewId", MTParameterType.Integer, m_PVNameToIdMap[PAYMENT_PRODUCTVIEW].ID);

                                using (IMTDataReader reader = stmt.ExecuteReader())
                                {
                                    ARAdjustment adjustments;
                                    invReport.ARAdjustments = new List<ARAdjustment>();
                                    while (reader.Read())
                                    {
                                        adjustments = new ARAdjustment();
                                        adjustments.Currency = reader.GetString("currency");
                                        adjustments.Amount = reader.GetDecimal("amount");
                                        adjustments.AmountAsString = LocalizeCurrencyString(adjustments.Amount, languageID, adjustments.Currency);
                                        if (!reader.IsDBNull("description"))
                                        {
                                            adjustments.Description = reader.GetString("description");
                                        }
                                        adjustments.EventDate = reader.GetDateTime("event_date");
                                        if (!reader.IsDBNull("reason_code"))
                                        {
                                            adjustments.ReasonCode = reader.GetString("reason_code");
                                        }
                                        adjustments.SessionID = reader.GetInt64("id_sess");

                                        invReport.ARAdjustments.Add(adjustments);


                                    }

                                    reader.NextResult();

                                    Payment payment;
                                    invReport.Payments = new List<Payment>();

                                    while (reader.Read())
                                    {
                                        payment = new Payment();
                                        payment.Currency = reader.GetString("currency");
                                        payment.Amount = reader.GetDecimal("amount");
                                        payment.AmountAsString = LocalizeCurrencyString(payment.Amount, languageID, payment.Currency);
                                        payment.PaymentMethod = (PaymentMethod)EnumHelper.GetCSharpEnum(reader.GetInt32("payment_method"));


                                        if (!reader.IsDBNull("check_or_card_number"))
                                        {
                                            payment.CheckOrCardNumber = reader.GetString("check_or_card_number");
                                        }
                                        if (!reader.IsDBNull("cc_type") && !reader.IsDBNull("payment_method") && payment.PaymentMethod == PaymentMethod.CreditCard)
                                        {
                                            payment.CreditCardType = (MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType)EnumHelper.GetCSharpEnum(reader.GetInt32("cc_type"));
                                        }
                                        else
                                        {
                                            payment.CreditCardType = null;
                                        }

                                        if (!reader.IsDBNull("description"))
                                        {
                                            payment.Description = reader.GetString("description");
                                        }
                                        payment.PaymentDate = reader.GetDateTime("event_date");
                                        if (!reader.IsDBNull("reason_code"))
                                        {
                                            if (reader.GetInt32("reason_code") > 0)
                                            {
                                                payment.ReasonCode = (MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments.ReasonCode)EnumHelper.GetCSharpEnum(reader.GetInt32("reason_code"));
                                            }
                                            // MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.
                                            //MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments.ReasonCode.

                                        }

                                        payment.SessionID = reader.GetInt64("id_sess");

                                        invReport.Payments.Add(payment);
                                    }

                                    reader.NextResult();

                                    PostBillAdjustments pbAdjustments;
                                    invReport.PostBillAdjustments = new List<PostBillAdjustments>();

                                    while (reader.Read())
                                    {
                                        pbAdjustments = new PostBillAdjustments();
                                        pbAdjustments.Currency = reader.GetString("currency");

                                        pbAdjustments.TotalTax = new TaxData();
                                        pbAdjustments.TotalTax.TaxAmount = reader.GetDecimal("tax_adjustment_amount");
                                        pbAdjustments.TotalTax.TaxAmountAsString = LocalizeCurrencyString(pbAdjustments.TotalTax.TaxAmount, languageID, pbAdjustments.Currency);

                                        pbAdjustments.AdjustmentAmount = reader.GetDecimal("amount");
                                        pbAdjustments.AdjustmentAmountAsString = LocalizeCurrencyString(pbAdjustments.AdjustmentAmount, languageID, pbAdjustments.Currency);

                                        if (inlineVATTaxes)
                                        {
                                            pbAdjustments.AdjustmentDisplayAmount = pbAdjustments.AdjustmentAmount + pbAdjustments.TotalTax.TaxAmount;
                                        }
                                        else
                                        {
                                            pbAdjustments.AdjustmentDisplayAmount = pbAdjustments.AdjustmentAmount;
                                        }

                                        pbAdjustments.AdjustmentDisplayAmountAsString = LocalizeCurrencyString(pbAdjustments.AdjustmentDisplayAmount, languageID, pbAdjustments.Currency);


                                        pbAdjustments.AdjustmentAmountAsString = LocalizeCurrencyString(pbAdjustments.AdjustmentAmount, languageID, pbAdjustments.Currency);
                                        pbAdjustments.CountyTax = new TaxData();
                                        pbAdjustments.CountyTax.TaxAmount = reader.GetDecimal("county_tax_adjustment_amount");
                                        pbAdjustments.CountyTax.TaxAmountAsString = LocalizeCurrencyString(pbAdjustments.CountyTax.TaxAmount, languageID, pbAdjustments.Currency);
                                        pbAdjustments.FederalTax = new TaxData();
                                        pbAdjustments.FederalTax.TaxAmount = reader.GetDecimal("federal_tax_adjustment_amount");
                                        pbAdjustments.FederalTax.TaxAmountAsString = LocalizeCurrencyString(pbAdjustments.FederalTax.TaxAmount, languageID, pbAdjustments.Currency);
                                        pbAdjustments.StateTax = new TaxData();
                                        pbAdjustments.StateTax.TaxAmount = reader.GetDecimal("state_tax_adjustment_amount");
                                        pbAdjustments.StateTax.TaxAmountAsString = LocalizeCurrencyString(pbAdjustments.StateTax.TaxAmount, languageID, pbAdjustments.Currency);
                                        pbAdjustments.LocalTax = new TaxData();
                                        pbAdjustments.LocalTax.TaxAmount = reader.GetDecimal("local_tax_adjustment_amount");
                                        pbAdjustments.LocalTax.TaxAmountAsString = LocalizeCurrencyString(pbAdjustments.LocalTax.TaxAmount, languageID, pbAdjustments.Currency);
                                        pbAdjustments.OtherTax = new TaxData();
                                        pbAdjustments.OtherTax.TaxAmount = reader.GetDecimal("other_tax_adjustment_amount");
                                        pbAdjustments.OtherTax.TaxAmountAsString = LocalizeCurrencyString(pbAdjustments.OtherTax.TaxAmount, languageID, pbAdjustments.Currency);

                                        pbAdjustments.NumAdjustments = reader.GetInt32("count");




                                        invReport.PostBillAdjustments.Add(pbAdjustments);
                                    }
                                }
                            }
                        }
                    }
                        #endregion

                    report = invReport;


                }
                catch (MASBasicException masBasic)
                {
                    mLogger.LogException("Exception while getting invoice report", masBasic);
                    throw;
                }
                catch (COMException comE)
                {
                    mLogger.LogException("COM Exception getting invoice report", comE);
                    throw new MASBasicException(comE.Message);
                }
                catch (Exception e)
                {
                    mLogger.LogException("Exception getting invoice report", e);
                    throw new MASBasicException("Error getting invoice report");
                }
            }
        }

        [Obsolete("This is an old buggy version and will be deprecated. Use GetByFolderReportLevel2 instead")]
        [OperationCapability("Manage Account Hierarchies")]
        public void GetByFolderReportLevel(AccountIdentifier owner, AccountIdentifier folder, ReportParameters repParams, out ReportLevel reportData)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetByFolderReportLevel"))
            {
                mLogger.LogInfo("Executing GetByFolderReportLevel Method in UsageHistoryService");
                mLogger.LogWarning("GetByFolderReportLevel is deprecated, use GetByFolderReportLevel2 instead");

                try
                {
                    #region Actual Implementation

                    #region Validate Input Parameters.
                    if (repParams == null)
                    {
                        throw new MASBasicException("Invalid argument: Report Parameters is null");
                    }

                    if (repParams.DateRange == null)
                    {
                        throw new MASBasicException("Invalid ReportParameter property: DateRange.");
                    }

                    if (owner == null)
                    {
                        throw new MASBasicException("Invalid argument: owner cannot be null");
                    }

                    int ownerId = AccountIdentifierResolver.ResolveAccountIdentifier(owner);

                    if (ownerId <= 0)
                    {
                        throw new MASBasicException("Unable to resolve Account Information.");
                    }

                    int folderId = -1;
                    if (folder != null)
                    {
                        folderId = AccountIdentifierResolver.ResolveAccountIdentifier(folder);

                        if (folderId <= 0)
                        {
                            throw new MASBasicException("Unable to resolve folder information");
                        }
                    }
                    #endregion

                    #region Check Caller Has "Manage Account Hierarchies" capability

                    if (!HasManageAccHeirarchyAccess(ownerId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                    {
                        throw new MASBasicException("Account access denied");
                    }

                    #endregion

                    ReportLevel repLevelData = new ReportLevel();

                    string queryString = string.Empty;

                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);

                            if (repParams.ReportView == ReportViewType.OnlineBill)
                            {
                                if (folder == null) //|| ownerId == folderId)
                                {
                                    queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_LEASTCOMMONANCESTOROFPAYEES_DATAMART__" : "__GET_LEASTCOMMONANCESTOROFPAYEES__");

                                    int level = 0;
                                    queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", GetQueryPredicate(repParams.DateRange, conn.ConnectionInfo.IsOracle, ref level), true);

                                    using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                    {
                                        stmt.AddParam("idAcc", MTParameterType.Integer, ownerId);

                                        level = 0;
                                        AddSliceParameters(stmt, repParams.DateRange, ref level);

                                        using (IMTDataReader reader = stmt.ExecuteReader())
                                        {

                                            if (reader.Read())
                                            {
                                                folderId = reader.GetInt32("id_ancestor");
                                            }
                                            else
                                            {
                                                reportData = repLevelData;

                                                mLogger.LogInfo("GetByFolderReportLevel: Nothing to report for account {0}.", ownerId);
                                                return;
                                            }
                                        }

                                    }
                                }

                                queryString = IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_PAYEES_DATAMART__" : "__GET_BYFOLDER_REPORT_FOR_PAYEES__";
                            }
                            else
                            {
                                if (folder == null)
                                {
                                    folderId = ownerId;
                                }

                                queryString = IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS_DATAMART__" : "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS__";
                            }
                        }
                    }

                    if (queryString.Equals(string.Empty))
                    {
                        throw new MASBasicException("Cannot find QueryString");
                    }

                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);

                            queryAdapter.Item.SetQueryTag(queryString);

                            int level = 0;
                            queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", GetQueryPredicate(repParams.DateRange, conn.ConnectionInfo.IsOracle, ref level), true);
                            queryAdapter.Item.AddParam("%%LIKE_OR_NOT_LIKE%%", repParams.UseSecondPassData ? " NOT LIKE " : " LIKE ", true);

                            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetQuery()))
                            {
                                stmt.SetResultSetCount(2);

                                if (repParams.ReportView == ReportViewType.OnlineBill)
                                {
                                    stmt.AddParam("idPayer", MTParameterType.Integer, ownerId);
                                }

                                DateTime startDt, endDt;
                                GetTimeSpan(repParams.DateRange, out startDt, out endDt);

                                if (repParams.ReportView == ReportViewType.OnlineBill)
                                {
                                    BILL.PayerAccountSlice payerSlice = new BILL.PayerAccountSlice();
                                    payerSlice.PayerID = new AccountIdentifier(ownerId);

                                    repLevelData.OwnerSlice = payerSlice;

                                    BILL.PayerAndPayeeSlice payeeSlice = new BILL.PayerAndPayeeSlice();
                                    payeeSlice.PayerAccountId = new AccountIdentifier(ownerId);
                                    payeeSlice.PayeeAccountId = new AccountIdentifier(folderId);

                                    repLevelData.FolderSlice = payeeSlice;
                                }
                                else
                                {
                                    BILL.DescendentPayeeSlice descendentSlice = new BILL.DescendentPayeeSlice();
                                    descendentSlice.AncestorAccountId = new AccountIdentifier(folderId);
                                    descendentSlice.StartDate = MetraTime.Min;
                                    descendentSlice.EndDate = MetraTime.Max;

                                    repLevelData.OwnerSlice = descendentSlice;

                                    BILL.PayeeAccountSlice payeeSlice = new PayeeAccountSlice();
                                    payeeSlice.PayeeID = new AccountIdentifier(folderId);

                                    repLevelData.FolderSlice = payeeSlice;
                                }

                                stmt.AddParam("numGenerations", MTParameterType.Integer, 0);
                                stmt.AddParam("idAcc", MTParameterType.Integer, folderId);
                                stmt.AddParam("dtBegin", MTParameterType.DateTime, startDt);
                                stmt.AddParam("dtEnd", MTParameterType.DateTime, endDt);
                                stmt.AddParam("idLang", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(repParams.Language, 1)));

                                level = 0;
                                AddSliceParameters(stmt, repParams.DateRange, ref level);
                                using (IMTDataReader reader = stmt.ExecuteReader())
                                {
                                    while (reader.Read())
                                    {
                                        repLevelData.ID = folderId;
                                        repLevelData.HierarchyPath = reader.GetString("HierarchyPath");
                                        PopulateReportLevelData(reader, repParams.Language, repLevelData);
                                        repLevelData.Name = reader.GetString("AccountName");
                                        PopulateDisplayAmount(repLevelData, repParams);
                                        PopulatePreBillAdjustmentDisplayAmount(repLevelData, repParams);
                                    }

                                    reader.NextResult();

                                    ParseChargeQuery(repLevelData, reader, repParams);

                                }
                            }
                        }
                    }

                    reportData = repLevelData;

                    #endregion
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("Error getting report level by folder. ", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error getting report level by folder. ", e);

                    throw new MASBasicException("Error getting report level by folder. ");
                }
            }
        }

        [Obsolete("This is an old buggy version and will be deprecated. Use GetByFolderReportLevelChildren2 instead")]
        [OperationCapability("Manage Account Hierarchies")]
        public void GetByFolderReportLevelChildren(AccountIdentifier owner, AccountIdentifier folder, string hierarchyPath, ReportParameters repParams, ref MTList<ReportLevel> children)
        {
            mLogger.LogInfo("Executing GetByFolderReportLevelChildren Method in UsageHistoryService");
            mLogger.LogWarning("GetByFolderReportLevelChildren is deprecated, use GetByFolderReportLevelChildren2 instead");

            try
            {
                using (MetraTech.Debug.Diagnostics.HighResolutionTimer timer = new MetraTech.Debug.Diagnostics.HighResolutionTimer("GetByFolderReportLevelChildren", 10000))
                {
                    #region Actual Implementation

                    #region Validate Input Parameters.
                    if (repParams == null)
                    {
                        throw new MASBasicException("Invalid argument: Report Parameters is null");
                    }

                    if (repParams.DateRange == null)
                    {
                        throw new MASBasicException("Invalid ReportParameter property: DateRange.");
                    }


                    if (string.IsNullOrEmpty(hierarchyPath))
                    {
                        hierarchyPath = string.Empty;
                        //throw new MASBasicException("Invalid hierarchy path.");
                    }

                    if (owner == null)
                    {
                        throw new MASBasicException("Invalid argument: owner cannot be null");
                    }

                    int ownerId = AccountIdentifierResolver.ResolveAccountIdentifier(owner);

                    if (ownerId <= 0)
                    {
                        throw new MASBasicException("Unable to resolve Account Information.");
                    }

                    int folderId = -1;
                    if (folder != null)
                    {
                        folderId = AccountIdentifierResolver.ResolveAccountIdentifier(folder);

                        if (folderId <= 0)
                        {
                            throw new MASBasicException("Unable to resolve folder information");
                        }
                    }
                    #endregion

                    #region Check Caller Has "Manage Account Hierarchies" capability

                    if (!HasManageAccHeirarchyAccess(ownerId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                    {
                        throw new MASBasicException("Account access denied");
                    }

                    #endregion

                    int level = 0;
                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        string queryString = string.Empty;

                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);

                            if (repParams.ReportView == ReportViewType.OnlineBill)
                            {
                                if (folder == null) //|| ownerId == folderId)
                                {
                                    queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_LEASTCOMMONANCESTOROFPAYEES_DATAMART__" : "__GET_LEASTCOMMONANCESTOROFPAYEES__");

                                    level = 0;
                                    queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", GetQueryPredicate(repParams.DateRange, conn.ConnectionInfo.IsOracle, ref level), true);

                                    using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                    {
                                        stmt.AddParam("idAcc", MTParameterType.Integer, ownerId);

                                        level = 0;
                                        AddSliceParameters(stmt, repParams.DateRange, ref level);

                                        using (IMTDataReader reader = stmt.ExecuteReader())
                                        {

                                            if (reader.Read())
                                            {
                                                folderId = reader.GetInt32("id_ancestor");
                                                if (string.IsNullOrEmpty(hierarchyPath))
                                                {
                                                    hierarchyPath = reader.GetString("hierarchy_path");
                                                }
                                            }
                                            else
                                            {
                                                mLogger.LogInfo("GetByFolderReportLevel: Nothing to report for account {0}.", ownerId);
                                                return;
                                            }
                                        }

                                    }
                                }

                                queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_PAYEES_SUMMARY_DATAMART__" : "__GET_BYFOLDER_REPORT_FOR_PAYEES_SUMMARY__");
                            }
                            else
                            {
                                if (folder == null)
                                {
                                    folderId = ownerId;
                                }

                                queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS_SUMMARY_DATAMART__" : "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS_SUMMARY__");
                            }

                            level = 0;
                            queryAdapter.Item.AddParam("%%LIKE_OR_NOT_LIKE%%", repParams.UseSecondPassData ? " NOT LIKE " : " LIKE ", true);
                            queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", GetQueryPredicate(repParams.DateRange, queryAdapter.Item.IsOracle(), ref level), true);

                            queryAdapter.Item.AddParamIfFound("%%TX_PATH%%", hierarchyPath, true);

                            queryString = queryAdapter.Item.GetRawSQLQuery(true);
                        }

                        using (IMTPreparedFilterSortStatement stmt = conn.CreatePreparedFilterSortStatement(queryString))
                        {
                            level = 0;
                            AddSliceParameters(stmt, repParams.DateRange, ref level);

                            if (repParams.ReportView == ReportViewType.OnlineBill)
                            {
                                stmt.AddParam("idPayer", MTParameterType.Integer, ownerId);
                            }

                            ApplyFilterSortCriteria<ReportLevel>(stmt, children);

                            stmt.AddParam("idAcc", MTParameterType.Integer, folderId);
                            DateTime beginDate;
                            DateTime endDate;
                            GetTimeSpan(repParams.DateRange, out beginDate, out endDate);
                            stmt.AddParam("dtBegin", MTParameterType.DateTime, beginDate);
                            stmt.AddParam("dtEnd", MTParameterType.DateTime, endDate);

                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    ReportLevel repLevelData = new ReportLevel();
                                    repLevelData.ID = folderId;

                                    int accountId = reader.GetInt32("AccountId");

                                    if (repParams.ReportView == ReportViewType.OnlineBill)
                                    {
                                        BILL.PayerAccountSlice payerSlice = new BILL.PayerAccountSlice();
                                        payerSlice.PayerID = new AccountIdentifier(ownerId);

                                        repLevelData.OwnerSlice = payerSlice;

                                        BILL.PayerAndPayeeSlice payeeSlice = new BILL.PayerAndPayeeSlice();
                                        payeeSlice.PayerAccountId = new AccountIdentifier(ownerId);
                                        payeeSlice.PayeeAccountId = new AccountIdentifier(accountId);

                                        repLevelData.FolderSlice = payeeSlice;
                                    }
                                    else
                                    {
                                        BILL.DescendentPayeeSlice descendentSlice = new BILL.DescendentPayeeSlice();
                                        descendentSlice.AncestorAccountId = new AccountIdentifier(folderId);
                                        descendentSlice.StartDate = MetraTime.Min;
                                        descendentSlice.EndDate = MetraTime.Max;

                                        repLevelData.OwnerSlice = descendentSlice;

                                        BILL.PayeeAccountSlice payeeSlice = new PayeeAccountSlice();
                                        payeeSlice.PayeeID = new AccountIdentifier(accountId);

                                        repLevelData.FolderSlice = payeeSlice;
                                    }

                                    repLevelData.HierarchyPath = reader.GetString("HierarchyPath");

                                    PopulateReportLevelData(reader, repParams.Language, repLevelData);
                                    repLevelData.Name = reader.GetString("AccountName");
                                    PopulateDisplayAmount(repLevelData, repParams);
                                    PopulatePreBillAdjustmentDisplayAmount(repLevelData, repParams);

                                    children.Items.Add(repLevelData);
                                }
                            }

                            children.TotalRows = stmt.TotalRows;
                        }
                    }

                    #endregion
                }
            }
            catch (MASBasicException masE)
            {
                mLogger.LogException("Error getting report level children by folder. ", masE);
                throw;
            }
            catch (Exception e)
            {
                mLogger.LogException("Error getting report level by folder. ", e);

                throw new MASBasicException("Error getting report level by folder. ");
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetByProductReport(AccountIdentifier owner, ReportParameters repParams, out ReportLevel reportData)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetByProductReport"))
            {
                mLogger.LogInfo("Executing GetByProductReport Method in UsageHistoryService");

                try
                {
                    #region Actual Implementation

                    #region Validate Input Parameters.
                    if (repParams == null)
                    {
                        throw new MASBasicException("Report Parameters is null");
                    }

                    if (repParams.DateRange == null)
                    {
                        throw new MASBasicException("Invalid or Incorrect or Null Timeslice (daterange) passed");
                    }

                    int ownerAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(owner);

                    if (ownerAcctId <= 0)
                    {
                        throw new MASBasicException("Cannot fetch Account Information.");
                    }
                    #endregion

                    #region Check Caller Has "Manage Account Hierarchies" capability

                    if (!HasManageAccHeirarchyAccess(ownerAcctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                        MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }

                    #endregion


                    ReportLevel repLevelData = new ReportLevel();

                    string queryString = string.Empty;
                    int accountId = ownerAcctId;

                    if (repParams.ReportView == ReportViewType.OnlineBill)
                    {
                        if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations))
                        {
                            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\AccHierarchies"))
                            {
                                //ESR-4376 Billing descrepancy when accounts are moved within billing interval 
                                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AccHierarchies", "__GET_CORPORATE_ACCOUNT_OF_CURRENT_ACCOUNT__"))
                                {
                                    stmt.AddParam("%%ID_ACC%%", ownerAcctId);
                                    stmt.AddParam("%%EFF_DATE%%", MetraTime.Now);

                                    using (IMTDataReader reader = stmt.ExecuteReader())
                                    {

                                        if (reader.Read())
                                        {
                                            accountId = reader.GetInt32("id_ancestor");
                                        }
                                        else
                                        {
                                            throw new MASBasicException("Cannot fetch Corporate Account Information");
                                        }
                                    }


                                }
                            }
                        }
                        else
                        {
                            accountId = 1; // Since rules are turned off, set it to Root to include all corporations
                        }

                        queryString = string.Format("__GET_BYPRODUCT_REPORT_FOR_PAYEES{0}__",
                                IsDataMartEnabled() ? "_DATAMART" : string.Empty);
                    }
                    else
                    {
                        queryString = string.Format("__GET_BYPRODUCT_REPORT_FOR_DESCENDENTS{0}__",
                                IsDataMartEnabled() ? "_DATAMART" : string.Empty);
                    }

                    if (queryString.Equals(string.Empty))
                    {
                        throw new MASBasicException("Cannot find QueryString");
                    }

                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);

                            queryAdapter.Item.SetQueryTag(queryString);

                            int level = 0;
                            queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", GetQueryPredicate(repParams.DateRange, conn.ConnectionInfo.IsOracle, ref level), true);
                            queryAdapter.Item.AddParam("%%LIKE_OR_NOT_LIKE%%", repParams.UseSecondPassData ? " NOT LIKE " : " LIKE ", true);

                            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetQuery()))
                            {
                                stmt.SetResultSetCount(2);

                                if (repParams.ReportView == ReportViewType.OnlineBill)
                                {
                                    stmt.AddParam("idPayer", MTParameterType.Integer, ownerAcctId);
                                }

                                DateTime startDt, endDt;
                                if (repParams.ReportView == ReportViewType.OnlineBill)
                                {
                                    startDt = MetraTime.Min;
                                    endDt = MetraTime.Max;
                                }
                                else
                                {
                                    GetTimeSpan(repParams.DateRange, out startDt, out endDt);
                                }

                                if (repParams.ReportView == ReportViewType.OnlineBill)
                                {
                                    BILL.PayerAccountSlice payerSlice = new PayerAccountSlice();
                                    payerSlice.PayerID = new AccountIdentifier(ownerAcctId);

                                    repLevelData.OwnerSlice = payerSlice;
                                    repLevelData.FolderSlice = payerSlice;
                                }
                                else
                                {
                                    BILL.DescendentPayeeSlice descendentSlice = new BILL.DescendentPayeeSlice();
                                    descendentSlice.AncestorAccountId = new AccountIdentifier(accountId);
                                    descendentSlice.StartDate = startDt;
                                    descendentSlice.EndDate = endDt;

                                    repLevelData.OwnerSlice = descendentSlice;
                                    repLevelData.FolderSlice = descendentSlice;
                                }

                                stmt.AddParam("idAcc", MTParameterType.Integer, accountId);
                                stmt.AddParam("dtBegin", MTParameterType.DateTime, startDt);
                                stmt.AddParam("dtEnd", MTParameterType.DateTime, endDt);
                                stmt.AddParam("idLang", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(repParams.Language, 1)));

                                level = 0;
                                AddSliceParameters(stmt, repParams.DateRange, ref level);

                                using (IMTDataReader reader = stmt.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        repLevelData.ID = accountId;
                                        PopulateReportLevelData(reader, repParams.Language, repLevelData);
                                        PopulateDisplayAmount(repLevelData, repParams);
                                        PopulatePreBillAdjustmentDisplayAmount(repLevelData, repParams);
                                    }

                                    reader.NextResult();

                                    ParseChargeQuery(repLevelData, reader, repParams);

                                }
                            }
                        }
                    }

                    //return object.
                    reportData = repLevelData;
                    #endregion

                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("MAS Error in GetByProductReport", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error in GetByProductReport", e);

                    throw new MASBasicException("Unknown error getting by-product report");
                }
                    

            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetUsageDetails(ReportParameters repParams,
                                    SingleProductSlice productSlice,
                                    AccountSlice accountSlice,
                                    ref MTList<BaseProductView> usageDetails)
        {
            string queryText = ConstructGetUsageDetailsQuery(repParams, productSlice, accountSlice);

            ExecuteGetUsageDetailsQuery(queryText, repParams, productSlice, accountSlice, ref usageDetails);
        }

        /// <summary>
        /// Invoke this activity service method if you want to retrieve all of the usage indicated by the
        /// first three parameters (repParams, productSlice, accountSlice).  This method differs from "GetUsageDetails"
        /// in that the returned list is not "pageable".  Instead, it returns the complete list of usage.
        /// </summary>
        /// <param name="repParams">Defines the date range or interval for retrieving usage</param>
        /// <param name="productSlice">Defines which product views to retrieve usage for</param>
        /// <param name="accountSlice">Defines which account/s to retrieve usage for</param>
        /// <param name="populateAdjustmentInfo">Set to true if you would like adjustmentInfo to be populated in the output usage details list</param>
        /// <param name="usageDetailsList">List of the resulting usage</param>
        [OperationCapability("Manage Account Hierarchies")]
        public void GetUsageDetailsAll(ReportParameters repParams,
                                    SingleProductSlice productSlice,
                                    AccountSlice accountSlice,
                                    bool populateAdjustmentInfo,
                                    ref List<BaseProductView> usageDetailsList)
        {
            string queryText = ConstructGetUsageDetailsQuery(repParams, productSlice, accountSlice);

            ExecuteGetUsageDetailsQuery(queryText, repParams, productSlice, accountSlice, populateAdjustmentInfo, ref usageDetailsList);
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetCompoundChildUsageSummaries(ReportParameters repParams,
                                                    AccountSlice accountSlice,
                                                    Int64 parentSessionID,
                                                    out List<ChildUsageSummary> childUsageSummaries)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetCompoundChildUsageSummaries"))
            {
                childUsageSummaries = new List<ChildUsageSummary>();

                try
                {
                    HR.ITimeSlice cTimeSlice = SliceConverter.ConvertSlice(repParams.DateRange) as HR.ITimeSlice;
                    HR.IAccountSlice cAcctSlice = SliceConverter.ConvertSlice(accountSlice) as HR.IAccountSlice;
                    HR.ISessionChildrenSlice cParentSlice = new HR.SessionChildrenSliceClass();
                    cParentSlice.ParentID = parentSessionID;

                    #region Check Caller Has "Manage Account Hierarchies" capability

                    #region GetAccountIDs
                    List<int> acctIds = new List<int>();

                    if (accountSlice.GetType() == typeof(PayerAccountSlice))
                    {
                        int payerId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayerID"));
                        if (payerId > 0)
                        {
                            acctIds.Add(payerId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(PayeeAccountSlice))
                    {
                        int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayeeID"));
                        if (payeeId > 0)
                        {
                            acctIds.Add(payeeId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(MetraTech.DomainModel.Billing.PayerAndPayeeSlice))
                    {
                        int payerId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayerAccountId"));
                        if (payerId > 0)
                        {
                            acctIds.Add(payerId);
                        }
                        int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayeeAccountId"));
                        if (payeeId > 0)
                        {
                            acctIds.Add(payeeId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(MetraTech.DomainModel.Billing.DescendentPayeeSlice))
                    {
                        int ancId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("AncestorAccountId"));
                        if (ancId > 0)
                        {
                            acctIds.Add(ancId);
                        }
                    }
                    #endregion

                    bool bHasAccess = false;
                    foreach (int acctId in acctIds)
                    {
                        if (HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                            MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                        {
                            bHasAccess = true;
                            break;
                        }
                    }

                    if (!bHasAccess)
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }
                    #endregion

                    UsageSummaryQuery usageSummaryQuery = new UsageSummaryQueryClass();

                    usageSummaryQuery.InlineAdjustments = repParams.InlineAdjustments;
                    usageSummaryQuery.InlineVATTaxes = repParams.InlineVATTaxes;
                    usageSummaryQuery.InteractiveReport = (repParams.ReportView == ReportViewType.Interactive);

                    string queryText = usageSummaryQuery.GenerateQueryString(
                                            Convert.ToInt32(EnumHelper.GetValueByEnum(repParams.Language, 1)),
                                            cTimeSlice,
                                            cAcctSlice,
                                            cParentSlice,
                                            IsDataMartEnabled());

                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTStatement stmt = conn.CreateStatement(queryText))
                        {
                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    ChildUsageSummary summary = new ChildUsageSummary();

                                    if (rdr.IsDBNull("PriceableItemTemplateId"))
                                    {
                                        BILL.ProductViewSlice slice = new BILL.ProductViewSlice();
                                        int viewId = rdr.GetInt32("ViewId");
                                        slice.ViewID = new PCIdentifier(viewId, m_PVIdToNameMap[viewId].Name);
                                        slice.ViewDisplayName = rdr.GetString("ViewName");
                                        summary.ProductSlice = slice;
                                    }
                                    else if (rdr.IsDBNull("ProductOfferingId"))
                                    {
                                        BILL.PriceableItemTemplateSlice slice = new BILL.PriceableItemTemplateSlice();
                                        slice.PITemplateID = new PCIdentifier(rdr.GetInt32("PriceableItemTemplateId"));
                                        int viewId = rdr.GetInt32("ViewId");
                                        slice.ViewID = new PCIdentifier(viewId, m_PVIdToNameMap[viewId].Name);
                                        slice.ViewDisplayName = rdr.GetString("ViewName");
                                        summary.ProductSlice = slice;
                                    }
                                    else
                                    {
                                        BILL.PriceableItemInstanceSlice instSlice = new BILL.PriceableItemInstanceSlice();
                                        instSlice.PIInstanceID = new PCIdentifier(rdr.GetInt32("PriceableItemInstanceId"));
                                        instSlice.POInstanceID = new PCIdentifier(rdr.GetInt32("ProductOfferingId"));
                                        int viewId = rdr.GetInt32("ViewId");
                                        instSlice.ViewID = new PCIdentifier(viewId, m_PVIdToNameMap[viewId].Name);
                                        instSlice.ViewDisplayName = rdr.GetString("ViewName");

                                        summary.ProductSlice = instSlice;
                                    }

                                    summary.DisplayName = rdr.GetString("ViewName");

                                    string currency = rdr.GetString("Currency");
                                    decimal displayAmount = rdr.GetDecimal("DisplayAmount");
                                    summary.DisplayAmount = displayAmount;
                                    summary.DisplayAmountAsString = LocalizeCurrencyString(displayAmount, repParams.Language, currency);

                                    childUsageSummaries.Add(summary);
                                }
                            }
                        }
                    }
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("Error while processing GetCompoundChildUsageSummaries", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error while processing GetCompoundChildUsageSummaries", e);

                    throw new MASBasicException("Error while retrieving child usage summaries");
                }
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetBaseAdjustmentDetails(BILL.TimeSlice timeSlice,
                                        AccountSlice accountSlice,
                                        bool isPostbill,
                                        LanguageCode languageId,
                                        ref MTList<BaseAdjustmentDetail> adjustmentDetails)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetBaseAdjustmentDetails"))
            {
                try
                {
                    #region Check Caller Has "Manage Account Hierarchies" capability

                    #region GetAccountIDs
                    List<int> acctIds = new List<int>();

                    if (accountSlice.GetType() == typeof(PayerAccountSlice))
                    {
                        int payerId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayerID"));
                        if (payerId > 0)
                        {
                            acctIds.Add(payerId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(PayeeAccountSlice))
                    {
                        int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayeeID"));
                        if (payeeId > 0)
                        {
                            acctIds.Add(payeeId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(MetraTech.DomainModel.Billing.PayerAndPayeeSlice))
                    {
                        int payerId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayerAccountId"));
                        if (payerId > 0)
                        {
                            acctIds.Add(payerId);
                        }
                        int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayeeAccountId"));
                        if (payeeId > 0)
                        {
                            acctIds.Add(payeeId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(MetraTech.DomainModel.Billing.DescendentPayeeSlice))
                    {
                        int ancId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("AncestorAccountId"));
                        if (ancId > 0)
                        {
                            acctIds.Add(ancId);
                        }
                    }
                    #endregion

                    bool bHasAccess = false;
                    foreach (int acctId in acctIds)
                    {
                        if (HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                            MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                        {
                            bHasAccess = true;
                            break;
                        }
                    }

                    if (!bHasAccess)
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }
                    #endregion

                    using (IMTConnection conn = ConnectionManager.CreateConnection(true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);
                            queryAdapter.Item.SetQueryTag(string.Format("__GET_BASE_ADJUSTMENT_DETAIL{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));

                            int level = 0;
                            string queryPredicate = GetQueryPredicate(timeSlice, queryAdapter.Item.IsOracle(), ref level);
                            queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", queryPredicate, true);

                            queryPredicate = GetQueryPredicate(accountSlice, queryAdapter.Item.IsOracle(), ref level);
                            queryAdapter.Item.AddParam("%%ACCOUNT_PREDICATE%%", queryPredicate, true);

                            queryAdapter.Item.AddParam("%%FROM_CLAUSE%%", GetAccountFromClause(accountSlice), true);

                            using (IMTPreparedFilterSortStatement prepSortStmt = conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                level = 0;
                                AddSliceParameters(prepSortStmt, timeSlice, ref level);
                                AddSliceParameters(prepSortStmt, accountSlice, ref level);

                                prepSortStmt.AddParam("IsPostbill", MTParameterType.String, (isPostbill ? "Y" : "N"));
                                prepSortStmt.AddParam("langCode", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(languageId, 1)));

                                ApplyFilterSortCriteria<BaseAdjustmentDetail>(prepSortStmt, adjustmentDetails);

                                using (IMTDataReader reader = prepSortStmt.ExecuteReader())
                                {
                                    BaseAdjustmentDetail adjDetail;
                                    string currency;

                                    while (reader.Read())
                                    {
                                        adjDetail = new BaseAdjustmentDetail();

                                        currency = reader.GetString("Currency");

                                        adjDetail.SessionID = reader.GetInt64("SessionID");
                                        adjDetail.UnadjustedAmount = reader.GetDecimal("UnadjustedAmount");
                                        adjDetail.UnadjustedAmountAsString = LocalizeCurrencyString(adjDetail.UnadjustedAmount, languageId, currency);
                                        adjDetail.UnadjustedAmountWithTax = reader.GetDecimal("UnadjustedAmountWithTax");
                                        adjDetail.UnadjustedAmountWithTaxAsString = LocalizeCurrencyString(adjDetail.UnadjustedAmountWithTax, languageId, currency);

                                        adjDetail.FederalTax = PopulateTaxData(reader, currency, languageId, TaxType.Fed);
                                        adjDetail.StateTax = PopulateTaxData(reader, currency, languageId, TaxType.State);
                                        adjDetail.CountyTax = PopulateTaxData(reader, currency, languageId, TaxType.Cnty);
                                        adjDetail.LocalTax = PopulateTaxData(reader, currency, languageId, TaxType.Local);
                                        adjDetail.OtherTax = PopulateTaxData(reader, currency, languageId, TaxType.Other);

                                        adjDetail.AdjustmentAmount = reader.GetDecimal("AdjustmentAmount");
                                        adjDetail.AdjustmentAmountAsString = LocalizeCurrencyString(adjDetail.AdjustmentAmount, languageId, currency);
                                        adjDetail.AdjustedAmount = reader.GetDecimal("AdjustedAmount");
                                        adjDetail.AdjustedAmountAsString = LocalizeCurrencyString(adjDetail.AdjustedAmount, languageId, currency);

                                        adjDetail.AdjustmentAmountWithTax = reader.GetDecimal("AdjustmentAmountWithTax");
                                        adjDetail.AdjustmentAmountWithTaxAsString = LocalizeCurrencyString(adjDetail.AdjustmentAmountWithTax, languageId, currency);
                                        adjDetail.AdjustedAmountWithTax = reader.GetDecimal("AdjustedAmountWithTax");
                                        adjDetail.AdjustedAmountWithTaxAsString = LocalizeCurrencyString(adjDetail.AdjustedAmountWithTax, languageId, currency);

                                        adjDetail.AdjustmentTemplateDisplayName = reader.GetString("AdjustmentTemplateDisplayName");
                                        adjDetail.AdjustmentInstanceDisplayName = reader.GetString("AdjustmentInstanceDisplayName");

                                        adjDetail.Description = reader.GetString("Description");

                                        adjDetail.AdjustmentReason = new MetraTech.DomainModel.BaseTypes.ReasonCode();
                                        adjDetail.AdjustmentReason.ID = reader.GetInt32("ReasonCode");
                                        adjDetail.AdjustmentReason.Name = reader.GetString("ReasonCodeName");
                                        adjDetail.AdjustmentReason.Description = reader.GetString("ReasonCodeDescription");
                                        adjDetail.AdjustmentReason.DisplayName = reader.GetString("ReasonCodeDisplayName");

                                        adjustmentDetails.Items.Add(adjDetail);
                                    }

                                    adjustmentDetails.TotalRows = prepSortStmt.TotalRows;
                                }
                            }
                        }
                    }
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("MAS Exception caught in GetBaseAdjustmentDetails", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Unexpected error in GetBaseAdjustmentDetails", e);
                    throw new MASBasicException("Unexpected error getting base adjustment details");
                }
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetBillingHistory(AccountIdentifier accountID, LanguageCode languageID, out List<Interval> intervals)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetBillingHistory"))
            {
                #region Actual Implementation

                try
                {
                    #region Validate Inputs
                    int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(accountID);

                    if (acctId <= 0)
                    {
                        throw new MASBasicException("Cannot fetch Account Information.");
                    }
                    #endregion

                    #region Check Caller Has "Manage Account Hierarchies" capability

                    if (!HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                        MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }

                    #endregion

                    int ancestorId = GetCommonAncestor(acctId);

                    intervals = new List<Interval>();

                    if (ancestorId > 0)
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                        {
                            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                            {
                                queryAdapter.Item = new MTQueryAdapterClass();
                                queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);
                                queryAdapter.Item.SetQueryTag(string.Format("__GET_ALLCHARGESALLINTERVALSFORPAYER{0}__", IsDataMartEnabled() ? "_DATAMART" : string.Empty));

                                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                {
                                    stmt.AddParam("idAcc", MTParameterType.Integer, acctId);

                                    using (IMTDataReader reader = stmt.ExecuteReader())
                                    {
                                        Interval interval;

                                        while (reader.Read())
                                        {
                                            interval = new Interval();
                                            int idxID = reader.GetOrdinal("id_usage_interval");
                                            int idxStartDate = reader.GetOrdinal("dt_start");
                                            int idxEndDate = reader.GetOrdinal("dt_end");
                                            int idxStatus = reader.GetOrdinal("tx_interval_status");
                                            int idxUsageAmount = reader.GetOrdinal("TotalAmount");
                                            int idxCurrency = reader.GetOrdinal("currency");
                                            int idxInvoiceString = reader.GetOrdinal("invoice_string");

                                            if (!reader.IsDBNull(idxID))
                                            {
                                                interval.ID = reader.GetInt32(idxID);
                                            }
                                            if (!reader.IsDBNull(idxStartDate))
                                            {
                                                interval.StartDate = reader.GetDateTime(idxStartDate);
                                            }
                                            if (!reader.IsDBNull(idxEndDate))
                                            {
                                                interval.EndDate = reader.GetDateTime(idxEndDate);
                                            }
                                            if (!reader.IsDBNull(idxStatus))
                                            {
                                                interval.Status = GetIntervalStatusCode(reader.GetString(idxStatus));
                                            }
                                            if (!reader.IsDBNull(idxUsageAmount))
                                            {
                                                interval.UsageAmount = reader.GetDecimal(idxUsageAmount);
                                            }
                                            if (!reader.IsDBNull(idxCurrency))
                                            {
                                                string Currency = reader.GetString(idxCurrency);
                                                interval.UsageAmountAsString = LocalizeCurrencyString(interval.UsageAmount.Value, languageID, Currency);
                                            }
                                            if (!reader.IsDBNull(idxInvoiceString))
                                            {
                                                interval.InvoiceNumber = reader.GetString(idxInvoiceString);
                                            }

                                            intervals.Add(interval);
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("Error while processing Get Billing History ", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error while processing Get Billing History", e);

                    throw new MASBasicException("Error while processing Get Billing History");
                }


                #endregion
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetPaymentHistory(AccountIdentifier accountID, LanguageCode languageID, ref MTList<Payment> payments)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetPaymentHistory"))
            {
                try
                {
                    #region Validate Inputs.
                    int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(accountID);

                    if (acctId <= 0)
                    {
                        throw new MASBasicException("Cannot fetch Account Information.");
                    }

                    #endregion

                    #region Check Caller Has "Manage Account Hierarchies" capability

                    if (!HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                        MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }

                    #endregion


                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        string queryString = string.Format("__GET_PAYMENT_HISTORY{0}__",
                            IsDataMartEnabled() ? "_DATAMART" : string.Empty);

                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);
                            queryAdapter.Item.SetQueryTag(string.Format("__GET_PAYMENT_HISTORY{0}__", IsDataMartEnabled() ? "_DATAMART" : string.Empty));

                            using (IMTPreparedFilterSortStatement stmt = conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<Payment>(stmt, payments, new FilterColumnResolver(GetColumnNameFromPaymentPVPropertyname), null);

                                #region Apply Parameter Filters.
                                stmt.AddParam("idAcc", MTParameterType.Integer, acctId);
                                stmt.AddParam("viewId", MTParameterType.Integer, m_PVNameToIdMap[PAYMENT_PRODUCTVIEW].ID);
                                #endregion

                                Payment payment;
                                payments.TotalRows = 0;

                                using (IMTDataReader reader = stmt.ExecuteReader())
                                {

                                    while (reader.Read())
                                    {
                                        payment = new Payment();
                                        payment.Amount = reader.GetDecimal("amount");
                                        payment.SessionID = reader.GetInt64("id_sess");
                                        payment.Currency = reader.GetString("currency");
                                        payment.AmountAsString = LocalizeCurrencyString(payment.Amount, languageID, payment.Currency);
                                        if (!reader.IsDBNull("description"))
                                        {
                                            payment.Description = reader.GetString("description");
                                        }
                                        payment.PaymentDate = reader.GetDateTime("event_date");
                                        if (!reader.IsDBNull("reason_code"))
                                        {
                                            int reasonCode = reader.GetInt32("reason_code");

                                            if (reasonCode != 0)
                                            {
                                                payment.ReasonCode = (MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments.ReasonCode)EnumHelper.GetCSharpEnum(reasonCode);
                                            }
                                        }
                                        if (!reader.IsDBNull("payment_method"))
                                        {
                                            payment.PaymentMethod = (PaymentMethod)EnumHelper.GetCSharpEnum(reader.GetInt32("payment_method"));
                                        }
                                        if (!reader.IsDBNull("cc_type") && !reader.IsDBNull("payment_method") && payment.PaymentMethod == PaymentMethod.CreditCard)
                                        {
                                            payment.CreditCardType = (MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType)EnumHelper.GetCSharpEnum(reader.GetInt32("cc_type"));
                                        }
                                        else
                                        {
                                            payment.CreditCardType = null;
                                        }



                                        if (!reader.IsDBNull("check_or_card_number"))
                                        {
                                            payment.CheckOrCardNumber = reader.GetString("check_or_card_number");
                                        }

                                        payments.Items.Add(payment);
                                    }

                                    payments.TotalRows = stmt.TotalRows;
                                }

                            }
                        }

                    }

                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("Error while processing Get payment History ", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error while processing Get payment History", e);

                    throw new MASBasicException("Error while processing Get payment History");
                }
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetPaymentInfo(AccountIdentifier accountID, LanguageCode languageID, ref PaymentInfo paymentInfo)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetPaymentInfo"))
            {
                try
                {
                    #region Validate Inputs.
                    int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(accountID);

                    if (acctId <= 0)
                    {
                        throw new MASBasicException("Cannot fetch Account Information.");
                    }

                    #endregion

                    #region Check Caller Has "Manage Account Hierarchies" capability

                    if (!HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                        MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }

                    #endregion

                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        using (IMTCallableStatement stmt = conn.CreateCallableStatement("GETPAYMENTINFO"))
                        {
                            stmt.AddParam("@id_acc", MTParameterType.Integer, acctId);
                            stmt.AddOutputParam("@amount", MTParameterType.Decimal);
                            stmt.AddOutputParam("@due_date", MTParameterType.DateTime);
                            stmt.AddOutputParam("@invoice_num", MTParameterType.Integer);
                            stmt.AddOutputParam("@invoice_date", MTParameterType.DateTime);
                            stmt.AddOutputParam("@currency", MTParameterType.String, 3);
                            stmt.AddOutputParam("@last_payment", MTParameterType.Decimal);
                            stmt.AddOutputParam("@last_payment_date", MTParameterType.DateTime);

                            stmt.ExecuteNonQuery();

                            //paymentInfo = new PaymentInfo();

                            // AmountDue is never null, 0 returned when no invoice and no payments found
                            paymentInfo.AmountDue = (decimal)stmt.GetOutputValue("@amount");
                            // check for nulls
                            object o = stmt.GetOutputValue("@due_date");
                            paymentInfo.DueDate = (o is DBNull) ? new DateTime(1900, 1, 1) : (DateTime)o;
                            // check for nulls
                            o = stmt.GetOutputValue("@invoice_num");
                            paymentInfo.InvoiceNumber = (o is DBNull) ? "" : ((int)o).ToString();
                            // check for nulls
                            o = stmt.GetOutputValue("@invoice_date");
                            paymentInfo.InvoiceDate = (o is DBNull) ? new DateTime(1900, 1, 1) : (DateTime)o;
                            // check for nulls
                            o = stmt.GetOutputValue("@currency");
                            paymentInfo.Currency = (o is DBNull) ? "" : (string)o;
                            // this is never null, 0 returned if no payment been made.
                            paymentInfo.LastPaymentAmount = (decimal)stmt.GetOutputValue("@last_payment");
                            // this is never null, 1900-01-01 returned if no payment been made
                            paymentInfo.LastPaymentDate = (DateTime)stmt.GetOutputValue("@last_payment_date");
                            paymentInfo.AmountDueAsString = LocalizeCurrencyString(paymentInfo.AmountDue, languageID, paymentInfo.Currency);
                            paymentInfo.LastPaymentAmountAsString = LocalizeCurrencyString(paymentInfo.LastPaymentAmount, languageID, paymentInfo.Currency);
                        }

                    }

                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("Error while processing Get payment Information ", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error while processing Get payment Information", e);

                    throw new MASBasicException("Error while processing Get payment Information");
                }
            }
        }
        #endregion

        #region Protected member methods

        protected string ResolveUiEnums(string propName, ref object propValue, object helper)
        {
            Enum enumVal = null;
            BaseObject baseHelper = (BaseObject)helper;
            PropertyInfo propInfo = baseHelper.GetProperty(propName);
            if (EnumHelper.IsEnumType(propInfo.PropertyType))
            {
                if (!EnumHelper.IsEnumType(propValue.GetType()))
                {
                    Type enumType = propInfo.PropertyType;
                    // We need to check whether the enumType is NULLABLE
                    if (enumType.IsGenericType && enumType.GetGenericTypeDefinition() == typeof(Nullable<>))
                    {
                        // If it is NULLABLE, then get the underlying type. eg if "Nullable<int>" then this will return just "int"

                        enumType = enumType.GetGenericArguments()[0];
                    }
                    enumVal = (Enum)EnumHelper.GetGeneratedEnumByValue(enumType, propValue.ToString());

                    if (enumVal == null)
                    {
                        enumVal = (Enum)EnumHelper.GetGeneratedEnumByEntry(enumType, propValue.ToString());
                    }

                    if (enumVal == null)
                    {
                        enumVal = (Enum)EnumHelper.GetCSharpEnum(Int32.Parse(propValue.ToString()));
                    }

                    if (enumVal == null)
                    {
                        throw new MASBasicException("Unable to resolve enum filter to generated enum type");
                    }
                }
                else
                {
                    enumVal = (Enum)propValue;
                }


                propValue = EnumHelper.GetDbValueByEnum(enumVal);
            }

            return propName;

        }

        protected string GetColumnNameFromPaymentPVPropertyname(string propName, ref object filterVal, object helper)
        {
            switch (propName)
            {
                case "PaymentType":
                    return "cc_type";
                    break;

                case "PaymentDate":
                    return "event_date";
                    break;

                case "PaymentMethod":
                    return "payment_method";
                    break;

                case "CheckOrCardNumber":
                    return "check_or_card_number";
                    break;

                default:
                    return propName;
            }
        }
#endregion

        #region Private Methods
        /// <summary>
        /// This private method is used by the GetUsageDetails* methods to produce
        /// the desired query from the input parameters
        /// </summary>
        /// <param name="repParams">Defines the date range or interval for retrieving usage</param>
        /// <param name="productSlice">Defines which product views to retrieve usage for</param>
        /// <param name="accountSlice">Defines which account/s to retrieve usage for</param>
        /// <returns>String containing the query</returns>
        private string ConstructGetUsageDetailsQuery(ReportParameters repParams,
                                    SingleProductSlice productSlice,
                                    AccountSlice accountSlice)
        {
            string queryText = "";
            using (HighResolutionTimer timer = new HighResolutionTimer("ConstructGetUsageDetailsQuery"))
            {
                try
                {
                    // Check Caller Has "Manage Account Hierarchies" capability
                    List<int> acctIds = new List<int>();

                    if (accountSlice.GetType() == typeof(PayerAccountSlice))
                    {
                        int payerId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayerID"));
                        if (payerId > 0)
                        {
                            acctIds.Add(payerId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(PayeeAccountSlice))
                    {
                        int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayeeID"));
                        if (payeeId > 0)
                        {
                            acctIds.Add(payeeId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(MetraTech.DomainModel.Billing.PayerAndPayeeSlice))
                    {
                        int payerId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayerAccountId"));
                        if (payerId > 0)
                        {
                            acctIds.Add(payerId);
                        }
                        int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("PayeeAccountId"));
                        if (payeeId > 0)
                        {
                            acctIds.Add(payeeId);
                        }
                    }
                    if (accountSlice.GetType() == typeof(MetraTech.DomainModel.Billing.DescendentPayeeSlice))
                    {
                        int ancId = AccountIdentifierResolver.ResolveAccountIdentifier((AccountIdentifier)accountSlice.GetValue("AncestorAccountId"));
                        if (ancId > 0)
                        {
                            acctIds.Add(ancId);
                        }
                    }

                    bool bHasAccess = false;
                    foreach (int acctId in acctIds)
                    {
                        if (HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ,
                            MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
                        {
                            bHasAccess = true;
                            break;
                        }
                    }

                    if (!bHasAccess)
                    {
                        mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
                        throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
                    }

                    queryText = GetUsageDetailQuery(repParams, productSlice, accountSlice);
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("ConstructUsageDetailsQuery: Error while processing Get Usage Details", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("ConstructUsageDetailsQuery: Error while processing Get Usage Details", e);

                    throw new MASBasicException("ConstructUsageDetailsQuery: Error while retrieving Usage Details");
                }
            }
            return queryText;
        }

        /// <summary>
        /// Execute the specified query and populate the usageDetails
        /// </summary>
        /// <param name="queryText">string containing the query that will be used to retrieve usage</param>
        /// <param name="repParams">Defines the date range or interval for retrieving usage</param>
        /// <param name="productSlice">Defines which product views to retrieve usage for</param>
        /// <param name="accountSlice">Defines which account/s to retrieve usage for</param>
        /// <param name="usageDetails">Resulting usage</param>
        private void ExecuteGetUsageDetailsQuery(string queryText, ReportParameters repParams,
                                    SingleProductSlice productSlice,
                                    AccountSlice accountSlice,
                                    ref MTList<BaseProductView> usageDetails)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("ExecuteGetUsageDetailsQueryMtList"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        using (IMTPreparedFilterSortStatement stmt = conn.CreatePreparedFilterSortStatement(queryText))
                        {
                            int level = 0;
                            AddSliceParameters(stmt, repParams.DateRange, ref level);
                            AddSliceParameters(stmt, productSlice, ref level);
                            AddSliceParameters(stmt, accountSlice, ref level);

                            if (System.Text.RegularExpressions.Regex.Match(queryText, "@langCode", System.Text.RegularExpressions.RegexOptions.IgnoreCase).Success
                                || System.Text.RegularExpressions.Regex.Match(queryText, ":langCode", System.Text.RegularExpressions.RegexOptions.IgnoreCase).Success)
                            {
                                stmt.AddParam("langCode", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(repParams.Language, 1)));
                            }

                            BaseProductView bpview;

                            PCIdentifier viewId = (PCIdentifier)productSlice.GetValue("ViewID");
                            bpview = GetProductViewInstance(viewId);
                            Type viewType = bpview.GetType();
                            object helper = Activator.CreateInstance(viewType);
                            ApplyFilterSortCriteria<BaseProductView>(stmt, usageDetails, new FilterColumnResolver(ResolveUiEnums), helper);

                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                bool populateAdjustmentInfo = true;
                                bool useMtList = true;
                                List<BaseProductView> unused = new List<BaseProductView>();
                                PopulateGetUsageDetailsList(reader, repParams, viewId, populateAdjustmentInfo, useMtList, ref usageDetails,
                                    ref unused);
                            }
                            usageDetails.TotalRows = stmt.TotalRows;
                        }
                    }
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("ExecuteUsageDetailsQuery: Error while processing Get Usage Details", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("ExecuteUsageDetailsQuery: Error while processing Get Usage Details", e);

                    throw new MASBasicException("ExecuteUsageDetailsQuery: Error while retrieving Usage Details");
                }
            }
        }

        /// <summary>
        /// Execute the specified query and populate the usageDetails
        /// </summary>
        /// <param name="queryText">string containing the query that will be used to retrieve usage</param>
        /// <param name="repParams">Defines the date range or interval for retrieving usage</param>
        /// <param name="productSlice">Defines which product views to retrieve usage for</param>
        /// <param name="accountSlice">Defines which account/s to retrieve usage for</param>
        /// <param name="populateAdjustmentInfo">Set this to true if you would like adjustment fields 
        /// within the resulting usage to be populated.  If you set it to false, the performance is better.</param>
        /// <param name="usageDetails">Resulting usage</param>
        private void ExecuteGetUsageDetailsQuery(string queryText, ReportParameters repParams,
                                    SingleProductSlice productSlice,
                                    AccountSlice accountSlice,
                                    bool populateAdjustmentInfo,
                                    ref List<BaseProductView> usageDetails)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("ExecuteGetUsageDetailsQueryList"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER, true))
                    {
                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryText))
                        {
                            int level = 0;
                            AddSliceParameters(stmt, repParams.DateRange, ref level);
                            AddSliceParameters(stmt, productSlice, ref level);
                            AddSliceParameters(stmt, accountSlice, ref level);

                            if (System.Text.RegularExpressions.Regex.Match(queryText, "@langCode", System.Text.RegularExpressions.RegexOptions.IgnoreCase).Success
                                || System.Text.RegularExpressions.Regex.Match(queryText, ":langCode", System.Text.RegularExpressions.RegexOptions.IgnoreCase).Success)
                            {
                                stmt.AddParam("langCode", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(repParams.Language, 1)));
                            }

                            BaseProductView bpview;

                            PCIdentifier viewId = (PCIdentifier)productSlice.GetValue("ViewID");
                            bpview = GetProductViewInstance(viewId);
                            Type viewType = bpview.GetType();
                            object helper = Activator.CreateInstance(viewType);

                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                bool useMtList = false;
                                MTList<BaseProductView> unused = new MTList<BaseProductView>();
                                PopulateGetUsageDetailsList(reader, repParams, viewId, populateAdjustmentInfo, useMtList, ref unused, ref usageDetails);
                            }
                        }
                    }
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("ExecuteUsageDetailsQuery: Error while processing Get Usage Details", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("ExecuteUsageDetailsQuery: Error while processing Get Usage Details", e);

                    throw new MASBasicException("ExecuteUsageDetailsQuery: Error while retrieving Usage Details");
                }
            }
        }

        /// <summary>
        /// Reads rows from the DB and populates the desired output list
        /// </summary>
        /// <param name="reader">reads rows from the DB</param>
        /// <param name="repParams">Defines the date range or interval for retrieving usage</param>
        /// <param name="viewId">Id of the product view we are retrieving</param>
        /// <param name="populateAdjustmentInfo">Set this to true if you would like adjustment fields within the resulting 
        /// usage to be populated.  If you set it to false, the performance is better.</param>
        /// <param name="useMtList">True if you would like to populate the MTList paramter.  False if you would like to populate the List paramter</param>
        /// <param name="usageDetailsMtList">MTList to fill with usage</param>
        /// <param name="usageDetailsList">List to fill with usage</param>
        private void PopulateGetUsageDetailsList(IMTDataReader reader, ReportParameters repParams,
            PCIdentifier viewId, bool populateAdjustmentInfo,
            bool useMtList,
                ref MTList<BaseProductView> usageDetailsMtList, ref List<BaseProductView> usageDetailsList)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("PopulateGetUsageDetailsList"))
            {
                try
                {
                    bool foundIndexes = false;
                    int CurrencyIndex = 0;
                    int AccountIDIndex = 0;
                    int AmountIndex = 0;
                    int AmountWithTaxIndex = 0;
                    int AtomicPostbillAdjedAmtIndex = 0;
                    int AtomicPostbillAdjAmtIndex = 0;
                    int AtomicPrebillAdjustedAmtIndex = 0;
                    int AtomicPrebillAdjAmtIndex = 0;
                    int CanAdjustIndex = 0;
                    int CanManageAdjustmentsIndex = 0;
                    int CanRebillIndex = 0;
                    int CompoundPostbillAdjedAmtIndex = 0;
                    int CompoundPostbillAdjAmtIndex = 0;
                    int CompoundPrebillAdjedAmtIndex = 0;
                    int CompoundPrebillAdjAmtIndex = 0;
                    int CountyTaxAmountIndex = 0;
                    int DisplayAmountIndex = 0;
                    int FederalTaxAmountIndex = 0;
                    int StateTaxAmountIndex = 0;
                    int LocalTaxAmountIndex = 0;
                    int OtherTaxAmountIndex = 0;
                    int IntervalIDIndex = 0;
                    int IsAdjustedIndex = 0;
                    int IsIntervalSoftClosedIndex = 0;
                    int IsPostBillAdjustedIndex = 0;
                    int IsPrebillAdjustedIndex = 0;
                    int IsPrebillTransactionIndex = 0;
                    int PIInstanceIndex = 0;
                    int PITemplateIndex = 0;
                    int PostbillAdjustmentIDIndex = 0;
                    int PrebillAdjustmentIDIndex = 0;
                    int SessionIDIndex = 0;
                    int ParentSessionIDIndex = 0;
                    int SessionTypeIndex = 0;
                    int TaxAmountIndex = 0;
                    int TimestampIndex = 0;
                    int ViewIDIndex = 0;
                    int IsTaxInclusiveIndex = 0;
                    int IsTaxCalculatedIndex = 0;
                    int IsTaxInformationalIndex = 0;

                    while (reader.Read())
                    {
                        // The first time through this loop, find the indexes for all of the
                        // parameters to be extracted.
                        if (!foundIndexes)
                        {
                            CurrencyIndex = reader.GetOrdinal("Currency");
                            AccountIDIndex = reader.GetOrdinal("AccountId");
                            AmountIndex = reader.GetOrdinal("Amount");
                            AmountWithTaxIndex = reader.GetOrdinal("AmountWithTax");
                            CanRebillIndex = reader.GetOrdinal("CanRebill");
                            if (populateAdjustmentInfo)
                            {
                                AtomicPostbillAdjedAmtIndex = reader.GetOrdinal("AtomicPostbillAdjedAmt");
                                AtomicPostbillAdjAmtIndex = reader.GetOrdinal("AtomicPostbillAdjAmt");
                                AtomicPrebillAdjustedAmtIndex = reader.GetOrdinal("AtomicPrebillAdjustedAmt");
                                AtomicPrebillAdjAmtIndex = reader.GetOrdinal("AtomicPrebillAdjAmt");
                                CompoundPostbillAdjedAmtIndex = reader.GetOrdinal("CompoundPostbillAdjedAmt");
                                CompoundPostbillAdjAmtIndex = reader.GetOrdinal("CompoundPostbillAdjAmt");
                                CompoundPrebillAdjedAmtIndex = reader.GetOrdinal("CompoundPrebillAdjedAmt");
                                CompoundPrebillAdjAmtIndex = reader.GetOrdinal("CompoundPrebillAdjAmt");
                                CanAdjustIndex = reader.GetOrdinal("CanAdjust");
                                CanManageAdjustmentsIndex = reader.GetOrdinal("CanManageAdjustments");
                                IsPostBillAdjustedIndex = reader.GetOrdinal("IsPostBillAdjusted");
                                IsPrebillAdjustedIndex = reader.GetOrdinal("IsPrebillAdjusted");
                                PostbillAdjustmentIDIndex = reader.GetOrdinal("PostbillAdjustmentID");
                                PrebillAdjustmentIDIndex = reader.GetOrdinal("PrebillAdjustmentID");
                            }
                            CountyTaxAmountIndex = reader.GetOrdinal("CountyTaxAmount");
                            DisplayAmountIndex = reader.GetOrdinal("DisplayAmount");
                            FederalTaxAmountIndex = reader.GetOrdinal("FederalTaxAmount");
                            StateTaxAmountIndex = reader.GetOrdinal("StateTaxAmount");
                            LocalTaxAmountIndex = reader.GetOrdinal("LocalTaxAmount");
                            OtherTaxAmountIndex = reader.GetOrdinal("OtherTaxAmount");
                            IntervalIDIndex = reader.GetOrdinal("IntervalID");
                            IsAdjustedIndex = reader.GetOrdinal("IsAdjusted");
                            IsIntervalSoftClosedIndex = reader.GetOrdinal("IsIntervalSoftClosed");

                            IsPrebillTransactionIndex = reader.GetOrdinal("IsPrebillTransaction");
                            PIInstanceIndex = reader.GetOrdinal("PIInstance");
                            PITemplateIndex = reader.GetOrdinal("PITemplate");

                            SessionIDIndex = reader.GetOrdinal("SessionID");
                            ParentSessionIDIndex = reader.GetOrdinal("ParentSessionID");
                            SessionTypeIndex = reader.GetOrdinal("SessionType");
                            TaxAmountIndex = reader.GetOrdinal("TaxAmount");
                            TimestampIndex = reader.GetOrdinal("Timestamp");
                            ViewIDIndex = reader.GetOrdinal("ViewID");
                            IsTaxInclusiveIndex = reader.GetOrdinal("IsTaxInclusive");
                            IsTaxInformationalIndex = reader.GetOrdinal("IsTaxInformational");
                            IsTaxCalculatedIndex = reader.GetOrdinal("IsTaxCalculated");
                            foundIndexes = true;
                        }

                        // Create a new BaseProductView instance
                        BaseProductView bpview = GetProductViewInstance(viewId);

                        // Populate the BaseProductView instance using the previously computed indexes
                        if (bpview != null)
                        {
                            bpview.Currency = reader.GetString(CurrencyIndex);
                            bpview.AccountID = new AccountIdentifier(reader.GetInt32(AccountIDIndex));
                            bpview.Amount = reader.GetDecimal(AmountIndex);
                            bpview.AmountWithTax = reader.GetDecimal(AmountWithTaxIndex);
                            bpview.AmountWithTaxAsString = LocalizeCurrencyString(bpview.AmountWithTax,
                                                                                  repParams.Language,
                                                                                  bpview.Currency);
                            bpview.CanRebill = reader.GetBoolean(CanRebillIndex);
                            bpview.AtomicAdjustmentInfo = new MetraTech.DomainModel.BaseTypes.Adjustments();

                            MetraTech.DomainModel.BaseTypes.Adjustments atomicAdj =
                                new MetraTech.DomainModel.BaseTypes.Adjustments();
                            bpview.AtomicAdjustmentInfo = atomicAdj;
                            MetraTech.DomainModel.BaseTypes.Adjustments compoundAdj =
                                new MetraTech.DomainModel.BaseTypes.Adjustments();
                            bpview.CompoundAdjustmentInfo = compoundAdj;

                            // Some clients don't need the adjustment related parameters to be filled
                            if (populateAdjustmentInfo)
                            {
                                atomicAdj.PostBillAdjustedAmount =
                                    reader.GetDecimal(AtomicPostbillAdjedAmtIndex);
                                atomicAdj.PostBillAdjustedAmountAsString =
                                    LocalizeCurrencyString(atomicAdj.PostBillAdjustedAmount,
                                                           repParams.Language, bpview.Currency);
                                atomicAdj.PostBillAdjustmentAmount =
                                    reader.GetDecimal(AtomicPostbillAdjAmtIndex);
                                atomicAdj.PostBillAdjustmentAmountAsString =
                                    LocalizeCurrencyString(atomicAdj.PostBillAdjustmentAmount,
                                                           repParams.Language, bpview.Currency);
                                atomicAdj.PreBillAdjustedAmount =
                                    reader.GetDecimal(AtomicPrebillAdjustedAmtIndex);
                                atomicAdj.PreBillAdjustedAmountAsString =
                                    LocalizeCurrencyString(atomicAdj.PreBillAdjustedAmount,
                                                           repParams.Language, bpview.Currency);
                                atomicAdj.PreBillAdjustmentAmount =
                                    reader.GetDecimal(AtomicPrebillAdjAmtIndex);
                                atomicAdj.PreBillAdjustmentAmountAsString =
                                    LocalizeCurrencyString(atomicAdj.PreBillAdjustmentAmount,
                                                           repParams.Language, bpview.Currency);


                                bpview.AtomicCountyTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                           bpview.Currency,
                                                                                           repParams.
                                                                                               Language,
                                                                                           TaxType.Cnty,
                                                                                           AtomicOrCompoundType
                                                                                               .Atomic);
                                bpview.AtomicFederalTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                            bpview.Currency,
                                                                                            repParams.
                                                                                                Language,
                                                                                            TaxType.Fed,
                                                                                            AtomicOrCompoundType
                                                                                                .Atomic);
                                bpview.AtomicStateTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                          bpview.Currency,
                                                                                          repParams.Language,
                                                                                          TaxType.State,
                                                                                          AtomicOrCompoundType
                                                                                              .Atomic);
                                bpview.AtomicLocalTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                          bpview.Currency,
                                                                                          repParams.Language,
                                                                                          TaxType.Local,
                                                                                          AtomicOrCompoundType
                                                                                              .Atomic);
                                bpview.AtomicOtherTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                          bpview.Currency,
                                                                                          repParams.Language,
                                                                                          TaxType.Other,
                                                                                          AtomicOrCompoundType
                                                                                              .Atomic);
                                bpview.AtomicTotalTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                          bpview.Currency,
                                                                                          repParams.Language,
                                                                                          TaxType.Total,
                                                                                          AtomicOrCompoundType
                                                                                              .Atomic);
                                bpview.CanAdjust = reader.GetBoolean(CanAdjustIndex);
                                bpview.CanManageAdjustments = reader.GetBoolean(CanManageAdjustmentsIndex);



                                compoundAdj.PostBillAdjustedAmount =
                                    reader.GetDecimal(CompoundPostbillAdjedAmtIndex);
                                compoundAdj.PostBillAdjustedAmountAsString =
                                    LocalizeCurrencyString(compoundAdj.PostBillAdjustedAmount,
                                                           repParams.Language, bpview.Currency);
                                compoundAdj.PostBillAdjustmentAmount =
                                    reader.GetDecimal(CompoundPostbillAdjAmtIndex);
                                compoundAdj.PostBillAdjustmentAmountAsString =
                                    LocalizeCurrencyString(compoundAdj.PostBillAdjustmentAmount,
                                                           repParams.Language, bpview.Currency);
                                compoundAdj.PreBillAdjustedAmount =
                                    reader.GetDecimal(CompoundPrebillAdjedAmtIndex);
                                compoundAdj.PreBillAdjustedAmountAsString =
                                    LocalizeCurrencyString(compoundAdj.PreBillAdjustedAmount,
                                                           repParams.Language, bpview.Currency);
                                compoundAdj.PreBillAdjustmentAmount =
                                    reader.GetDecimal(CompoundPrebillAdjAmtIndex);
                                compoundAdj.PreBillAdjustmentAmountAsString =
                                    LocalizeCurrencyString(compoundAdj.PreBillAdjustmentAmount,
                                                           repParams.Language, bpview.Currency);


                                bpview.CompoundCountyTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                             bpview.Currency,
                                                                                             repParams.
                                                                                                 Language,
                                                                                             TaxType.Cnty,
                                                                                             AtomicOrCompoundType
                                                                                                 .Compound);
                                bpview.CompoundFederalTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                              bpview.
                                                                                                  Currency,
                                                                                              repParams.
                                                                                                  Language,
                                                                                              TaxType.Fed,
                                                                                              AtomicOrCompoundType
                                                                                                  .Compound);
                                bpview.CompoundStateTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                            bpview.Currency,
                                                                                            repParams.
                                                                                                Language,
                                                                                            TaxType.State,
                                                                                            AtomicOrCompoundType
                                                                                                .Compound);
                                bpview.CompoundLocalTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                            bpview.Currency,
                                                                                            repParams.
                                                                                                Language,
                                                                                            TaxType.Local,
                                                                                            AtomicOrCompoundType
                                                                                                .Compound);
                                bpview.CompoundOtherTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                            bpview.Currency,
                                                                                            repParams.
                                                                                                Language,
                                                                                            TaxType.Other,
                                                                                            AtomicOrCompoundType
                                                                                                .Compound);
                                bpview.CompoundTotalTaxAdjustments = PopulateTaxAdjustments(reader,
                                                                                            bpview.Currency,
                                                                                            repParams.
                                                                                                Language,
                                                                                            TaxType.Total,
                                                                                            AtomicOrCompoundType
                                                                                                .Compound);
                                bpview.IsAdjusted = reader.GetBoolean(IsAdjustedIndex);
                                bpview.IsPostBillAdjusted = reader.GetBoolean(IsPostBillAdjustedIndex);
                                bpview.IsPreBillAdjusted = reader.GetBoolean(IsPrebillAdjustedIndex);
                                bpview.PostBillAdjustmentID = reader.GetInt32(PostbillAdjustmentIDIndex);
                                bpview.PreBillAdjustmentID = reader.GetInt32(PrebillAdjustmentIDIndex);
                            }
                            bpview.CountyTaxAmount = reader.GetDecimal(CountyTaxAmountIndex);
                            bpview.CountyTaxAmountAsString = LocalizeCurrencyString(bpview.CountyTaxAmount, repParams.Language, bpview.Currency);
                            bpview.DisplayAmount = reader.GetDecimal(DisplayAmountIndex);
                            bpview.DisplayAmountAsString = LocalizeCurrencyString(bpview.DisplayAmount, repParams.Language, bpview.Currency);

                            bpview.FederalTaxAmount = reader.GetDecimal(FederalTaxAmountIndex);
                            bpview.FederalTaxAmountAsString = LocalizeCurrencyString(bpview.FederalTaxAmount, repParams.Language, bpview.Currency);
                            bpview.StateTaxAmount = reader.GetDecimal(StateTaxAmountIndex);
                            bpview.StateTaxAmountAsString = LocalizeCurrencyString(bpview.StateTaxAmount, repParams.Language, bpview.Currency);
                            bpview.LocalTaxAmount = reader.GetDecimal(LocalTaxAmountIndex);
                            bpview.LocalTaxAmountAsString = LocalizeCurrencyString(bpview.LocalTaxAmount, repParams.Language, bpview.Currency);
                            bpview.OtherTaxAmount = reader.GetDecimal(OtherTaxAmountIndex);
                            bpview.OtherTaxAmountAsString = LocalizeCurrencyString(bpview.OtherTaxAmount, repParams.Language, bpview.Currency);

                            bpview.IntervalID = reader.GetInt32(IntervalIDIndex);

                            bpview.IsIntervalSoftClosed = reader.GetBoolean(IsIntervalSoftClosedIndex);

                            bpview.IsPreBillTransaction = reader.GetBoolean(IsPrebillTransactionIndex);

                            if (!reader.IsDBNull(PIInstanceIndex))
                            {
                                bpview.PIInstance = reader.GetInt32(PIInstanceIndex);
                            }

                            if (!reader.IsDBNull(PITemplateIndex))
                            {
                                bpview.PITemplate = reader.GetInt32(PITemplateIndex);
                            }


                            bpview.SessionID = reader.GetInt64(SessionIDIndex);

                            if (!reader.IsDBNull(ParentSessionIDIndex))
                            {
                                bpview.ParentSessionID = reader.GetInt64(ParentSessionIDIndex);
                            }

                            bpview.SessionType = (SessionType)Enum.Parse(typeof(SessionType), reader.GetString(SessionTypeIndex));

                            bpview.TaxAmount = reader.GetDecimal(TaxAmountIndex);
                            bpview.TaxAmountAsString = LocalizeCurrencyString(bpview.TaxAmount, repParams.Language, bpview.Currency);

                            bpview.TimeStamp = reader.GetDateTime(TimestampIndex);
                            bpview.ViewID = reader.GetInt32(ViewIDIndex);
                            bpview.IsTaxAlreadyCalculated = reader.GetBoolean(IsTaxCalculatedIndex);
                            bpview.IsTaxInclusive = reader.GetBoolean(IsTaxInclusiveIndex);
                            bpview.IsTaxInformational = reader.GetBoolean(IsTaxInformationalIndex);

                            PopulateProdViewSpecificData(reader, bpview);

                            if (useMtList)
                            {
                                usageDetailsMtList.Items.Add(bpview);
                            }
                            else
                            {
                                usageDetailsList.Add(bpview);
                            }
                        }
                        else
                        {
                            throw new MASBasicException("PopulateGetUsageDetailsList: failed to allocate BaseProductView");
                        }
                    }
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("PopulateGetUsageDetailsList: Error while processing Get Usage Details", masE);
                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("PopulateGetUsageDetailsList: Error while processing Get Usage Details", e);

                    throw new MASBasicException("PopulateGetUsageDetailsList: Error while retrieving Usage Details");
                }
            }
        }


        private IntervalStatusCode GetIntervalStatusCode(string code)
        {
            try
            {
                if (code != null && code != string.Empty && code.Length == 1)
                {
                    switch (code.ToUpper())
                    {
                        case "B":
                            return IntervalStatusCode.SoftClosed;
                            break;
                        case "H":
                            return IntervalStatusCode.HardClosed;
                        case "O":
                        case "C":
                            return IntervalStatusCode.Open;
                        default:
                            throw new MASBasicException(string.Format("invalid interval status code passed. {0}", code));
                            break;
                    }
                }
                else
                {
                    throw new MASBasicException("Invalid interval status code passed");
                }
            }
            catch (Exception e)
            {
                mLogger.LogException("Error at GetIntervalStatusCode ", e);
                throw;
            }
        }

        private void PopulateProdViewSpecificData(IMTDataReader reader, BaseProductView prodView)
        {
            string columnName;

            foreach (PropertyInfo prop in prodView.GetType().GetProperties())
            {
                object[] attribs = prop.GetCustomAttributes(typeof(MTProductViewMetadataAttribute), false);
                if (attribs.HasValue())
                {
                    MTProductViewMetadataAttribute pvattrib = (MTProductViewMetadataAttribute)attribs[0];
                    if (pvattrib.UserVisible)
                    {
                        columnName = String.Format("{0}", pvattrib.ColumnName);
                        //prodView.SetValue(prop, reader.GetValue(columnName));
                        //prodView.SetValue(prop, BasePCWebService.GetValue(columnName, prop.PropertyType, reader));
                        prop.SetValue(prodView, BasePCWebService.GetValue(columnName, prop.PropertyType, reader),
                                      null);

                    }
                }

            }

        }

        private TaxAdjustments PopulateTaxAdjustments(IMTDataReader reader, string currency, LanguageCode languageID, TaxType taxType, AtomicOrCompoundType atomicOrCompType)
        {
            TaxAdjustments taxAdjustments = new TaxAdjustments();

            taxAdjustments.PostBillTaxAdjustmentAmount = reader.GetDecimal(string.Format("{0}Postbill{1}TaxAdjAmt", atomicOrCompType.ToString(), taxType.ToString()));
            taxAdjustments.PostBillTaxAdjustmentAmountAsString =
                LocalizeCurrencyString(taxAdjustments.PostBillTaxAdjustmentAmount, languageID, currency);
            taxAdjustments.PreBillTaxAdjustmentAmount = reader.GetDecimal(string.Format("{0}Prebill{1}TaxAdjAmt", atomicOrCompType.ToString(), taxType.ToString()));
            taxAdjustments.PreBillTaxAdjustmentAmountAsString =
                LocalizeCurrencyString(taxAdjustments.PreBillTaxAdjustmentAmount, languageID, currency);

            return taxAdjustments;
        }

        private BaseProductView GetProductViewInstance(PCIdentifier viewID)
        {
            BaseProductView o = null;

            int vid = PCIdentifierResolver.ResolveProductView(viewID);

            if (vid != -1 && m_PVIdToNameMap.ContainsKey(vid))
            {
                string viewName = string.Format("MetraTech.DomainModel.ProductView.{0}ProductView", StringUtils.MakeAlphaNumeric(m_PVIdToNameMap[vid].Name));
                o = (BaseProductView)System.Activator.CreateInstance("MetraTech.DomainModel.Billing.Generated.dll", viewName).Unwrap();
            }
            else
            {
                throw new MASBasicException("Cannot find product view object.");
            }

            return o;

        }

        private int GetCommonAncestor(int accountId)
        {
            int ancestorId = -1;
            using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER))
            {
                string queryString = string.Format("__GET_COMMONANCESTOROFPAYEES{0}__",
                    IsDataMartEnabled() ? "_DATAMART" : string.Empty);

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(METRAVIEW_QUERY_FOLDER, queryString))
                {
                    stmt.AddParam("%%ID_ACC%%", accountId);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            ancestorId = reader.GetInt32("id_ancestor");
                        }
                    }
                }
            }
            return ancestorId;

        }

        private void ParseChargeQuery(ReportLevel level, IMTDataReader reader, ReportParameters repParams)
        {
            Dictionary<int, ReportProductOffering> pos = new Dictionary<int, ReportProductOffering>();
            Dictionary<int, ReportCharge> parentCharges = new Dictionary<int, ReportCharge>(); ;

            while (reader.Read())
            {
                //Create new charge instance
                ReportCharge repCharge = new ReportCharge();

                //Get PO ID from result set

                int? poId = null;

                ReportProductOffering po;

                if (!level.ProductOfferings.HasValue())
                {
                    level.ProductOfferings = new List<ReportProductOffering>();
                }

                if (!reader.IsDBNull("ProductOfferingId"))
                {
                    poId = reader.GetInt32("ProductOfferingId");
                    if (pos.ContainsKey(poId.Value))
                    {
                        po = pos[poId.Value];
                    }
                    else
                    {
                        po = new ReportProductOffering();
                        po.Name = reader.GetString("ProductOfferingName");
                        pos.Add(poId.Value, po);
                        level.ProductOfferings.Add(po);
                    }
                }

                ReportCharge parentCharge = null;

                int parentId = -1;

                if (!reader.IsDBNull("PriceableItemParentId"))
                {
                    parentId = reader.GetInt32("PriceableItemParentId");
                    parentCharge = parentCharges[parentId];
                }

                #region Populate Report Charge from Reader.
                string currency = reader.GetString("Currency");

                repCharge.Currency = currency;
                repCharge.AdjustmentInfo = PopulateAdjustment(reader, repParams.Language, currency);
                repCharge.Amount = reader.GetDecimal("Amount");
                repCharge.AmountAsString = LocalizeCurrencyString(repCharge.Amount, repParams.Language, currency);
                repCharge.CountyTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.Cnty);

                repCharge.FederalTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.Fed);
                repCharge.LocalTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.Local);
                repCharge.OtherTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.Other);
                repCharge.StateTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.State);
                repCharge.TotalTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.Total);
                repCharge.ImpliedTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.Implied);
                repCharge.InformationalTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.Informational);
                repCharge.ImplInfTax = PopulateTaxData(reader, currency, repParams.Language, TaxType.ImplInf);

                repCharge.PreAndPostBillTotalTaxAdjustmentAmount = repCharge.TotalTax.PreBillTaxAdjustmentAmount +
                                                                    repCharge.TotalTax.PostBillTaxAdjustmentAmount;
                repCharge.PreAndPostBillTotalTaxAdjustmentAmountAsString = LocalizeCurrencyString(repCharge.PreAndPostBillTotalTaxAdjustmentAmount, repParams.Language, currency);

                if (reader.IsDBNull("PriceableItemTemplateId") || (reader.GetInt32("PriceableItemTemplateId") == 0))
                {
                    BILL.ProductViewSlice slice = new BILL.ProductViewSlice();
                    int viewId = reader.GetInt32("ViewId");
                    slice.ViewID = new PCIdentifier(viewId, m_PVIdToNameMap[viewId].Name);
                    slice.ViewDisplayName = reader.IsDBNull("ViewName") ? string.Empty : reader.GetString("ViewName");
                    repCharge.DisplayName = reader.IsDBNull("ViewName") ? string.Empty : reader.GetString("ViewName");
                    repCharge.ProductSlice = slice;
                    repCharge.ID = reader.GetInt32("ViewId");
                }
                else if (reader.IsDBNull("ProductOfferingId"))
                {
                    BILL.PriceableItemTemplateSlice slice = new BILL.PriceableItemTemplateSlice();
                    slice.PITemplateID = new PCIdentifier(reader.GetInt32("PriceableItemTemplateId"));
                    int viewId = reader.GetInt32("ViewId");
                    slice.ViewID = new PCIdentifier(viewId, m_PVIdToNameMap[viewId].Name);
                    slice.ViewDisplayName = reader.IsDBNull("ViewName") ? string.Empty : reader.GetString("ViewName");
                    repCharge.DisplayName = reader.IsDBNull("PriceableItemName") ? string.Empty : reader.GetString("PriceableItemName");
                    repCharge.ProductSlice = slice;
                    repCharge.ID = reader.GetInt32("PriceableItemId");
                }
                else
                {
                    BILL.PriceableItemInstanceSlice instSlice = new BILL.PriceableItemInstanceSlice();
                    instSlice.PIInstanceID = new PCIdentifier(reader.GetInt32("PriceableItemInstanceId"));
                    instSlice.POInstanceID = new PCIdentifier(reader.GetInt32("ProductOfferingId"));
                    int viewId = reader.GetInt32("ViewId");
                    instSlice.ViewID = new PCIdentifier(viewId, m_PVIdToNameMap[viewId].Name);
                    instSlice.ViewDisplayName = reader.IsDBNull("ViewName") ? string.Empty : reader.GetString("ViewName");
                    repCharge.DisplayName = reader.IsDBNull("PriceableItemInstanceName") ? string.Empty : reader.GetString("PriceableItemInstanceName");
                    repCharge.ProductSlice = instSlice;
                    repCharge.ID = reader.GetInt32("PriceableItemInstanceId");
                }

                PopulateDisplayAmount(repCharge, repParams);

                #endregion


                if (!parentCharges.ContainsKey(parentId) && parentId != -1)
                {
                    parentCharges.Add(parentId, repCharge);
                }


                //if (pos.HasValue() && parentCharge == null && poId.HasValue && pos.ContainsKey(poId.Value))
                if (poId.HasValue && parentCharge == null)
                {
                    if (pos[poId.Value].Charges == null)
                    {
                        pos[poId.Value].Charges = new List<ReportCharge>();
                    }
                    pos[poId.Value].Charges.Add(repCharge);
                }
                else if (parentCharge != null)
                {
                    if (parentCharge.SubCharges == null)
                    {
                        parentCharge.SubCharges = new List<ReportCharge>();
                    }
                    parentCharge.SubCharges.Add(repCharge);
                }
                else
                {
                    if (level.Charges == null)
                    {
                        level.Charges = new List<ReportCharge>();
                    }

                    level.Charges.Add(repCharge);
                }

            }

        }

        private MetraTech.DomainModel.BaseTypes.Adjustments PopulateAdjustment(IMTDataReader reader, LanguageCode languageID, string currency)
        {
            MetraTech.DomainModel.BaseTypes.Adjustments adj =
                new MetraTech.DomainModel.BaseTypes.Adjustments();

            adj.PostBillAdjustedAmount = reader.GetDecimal("PostbillAdjustedAmount");
            adj.PostBillAdjustedAmountAsString = LocalizeCurrencyString(adj.PostBillAdjustedAmount, languageID, currency);

            adj.PostBillAdjustmentAmount = reader.GetDecimal("PostbillAdjAmt");
            adj.PostBillAdjustmentAmountAsString = LocalizeCurrencyString(adj.PostBillAdjustmentAmount, languageID, currency);

            adj.PreBillAdjustedAmount = reader.GetDecimal("PrebillAdjustedAmount");
            adj.PreBillAdjustedAmountAsString = LocalizeCurrencyString(adj.PreBillAdjustedAmount, languageID, currency);

            adj.PreBillAdjustmentAmount = reader.GetDecimal("PrebillAdjAmt");
            adj.PreBillAdjustmentAmountAsString = LocalizeCurrencyString(adj.PreBillAdjustmentAmount, languageID, currency);

            return adj;


        }

        private TaxData PopulateTaxData(IMTDataReader reader, string currency, LanguageCode languageID, TaxType taxType)
        {
            TaxData taxData = new TaxData();
            if (taxType != TaxType.Billable && taxType != TaxType.Nonimplied && taxType != TaxType.ImplInf)
            {
            taxData.PostBillTaxAdjustmentAmount = reader.GetDecimal(string.Format("Postbill{0}TaxAdjAmt", taxType.ToString()));
            taxData.PostBillTaxAdjustmentAmountAsString = LocalizeCurrencyString(taxData.PostBillTaxAdjustmentAmount, languageID, currency);
            taxData.PreBillTaxAdjustmentAmount = reader.GetDecimal(string.Format("Prebill{0}TaxAdjAmt", taxType.ToString()));
            taxData.PreBillTaxAdjustmentAmountAsString = LocalizeCurrencyString(taxData.PreBillTaxAdjustmentAmount, languageID, currency);
            }
            switch (taxType)
            {
                case TaxType.Fed:
                    taxData.TaxAmount = reader.GetDecimal("TotalFederalTax");
                    break;
                case TaxType.Cnty:
                    taxData.TaxAmount = reader.GetDecimal("TotalCountyTax");
                    break;
                case TaxType.Total:
                    taxData.TaxAmount = reader.GetDecimal("TotalTax");
                    break;
                case TaxType.Implied:
                    taxData.TaxAmount = reader.GetDecimal("TotalImpliedTax") - reader.GetDecimal("TotalImplInfTax");
                    break;
                case TaxType.Informational:
                    taxData.TaxAmount = reader.GetDecimal("TotalInformationalTax") - reader.GetDecimal("TotalImplInfTax");
                    break;
                case TaxType.ImplInf:
                    taxData.TaxAmount = reader.GetDecimal("TotalImplInfTax");
                    break;
                case TaxType.Billable:
                    // Billable tax = Nonimplied - Informational
                    taxData.TaxAmount = (reader.GetDecimal("TotalTax") - reader.GetDecimal("TotalImpliedTax")) -
                        (reader.GetDecimal("TotalInformationalTax") - reader.GetDecimal("TotalImplInfTax"));
                    break;
                case TaxType.Nonimplied:
                    taxData.TaxAmount = reader.GetDecimal("TotalTax") - reader.GetDecimal("TotalImpliedTax");
                    break;
                default:
                    taxData.TaxAmount = reader.GetDecimal(string.Format("Total{0}Tax", taxType.ToString()));
                    break;
            }

            taxData.TaxAmountAsString = LocalizeCurrencyString(taxData.TaxAmount, languageID, currency);

            return taxData;
        }

        private string LocalizeCurrencyString(decimal amount, LanguageCode languageID, string currency)
        {
            return GetLocaleTranslator(languageID).GetCurrency(amount, currency);
        }

        private void PopulateReportLevelData(IMTDataReader reader, LanguageCode languageID, ReportLevel reportData)
        {

            reportData.Currency = reader.GetString("Currency");

            reportData.AdjustmentInfo = PopulateAdjustment(reader, languageID, reportData.Currency);

            reportData.Amount = reader.GetDecimal("Amount");
            reportData.AmountAsString = LocalizeCurrencyString(reportData.Amount, languageID, reportData.Currency);
            
            reportData.CountyTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Cnty);
            reportData.FederalTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Fed);
            reportData.LocalTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Local);
            reportData.OtherTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Other);
            reportData.StateTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.State);
            reportData.TotalTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Total);
            reportData.ImpliedTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Implied);
            reportData.InformationalTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Informational);
            reportData.ImplInfTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.ImplInf);
            reportData.BillableTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Billable);
            reportData.NonImpliedTax = PopulateTaxData(reader, reportData.Currency, languageID, TaxType.Nonimplied);

            reportData.UsageAmount = reportData.Amount - reportData.ImpliedTax.TaxAmount - reportData.ImplInfTax.TaxAmount;
            reportData.UsageAmountAsString = LocalizeCurrencyString(reportData.UsageAmount, languageID, reportData.Currency);

            reportData.NumPostBillAdjustments = reader.GetInt32("NumPostbillAdjustments");
            reportData.NumPreBillAdjustments = reader.GetInt32("NumPrebillAdjustments");


            reportData.PreAndPostBillTotalTaxAdjustmentAmount = reportData.TotalTax.PreBillTaxAdjustmentAmount +
                                                                reportData.TotalTax.PostBillTaxAdjustmentAmount;
            reportData.PreAndPostBillTotalTaxAdjustmentAmountAsString =
                LocalizeCurrencyString(reportData.PreAndPostBillTotalTaxAdjustmentAmount, languageID, reportData.Currency);

        }

        /// <summary>
        /// support method for stub implementation.
        /// </summary>
        /// <returns></returns>
        //private ReportLevel GetReportData()
        //{
        //    ReportLevel reportData = new ReportLevel();

        //    Adjustments adj = new Adjustments();
        //    adj.PostBillAdjustedAmount = 3.00M;
        //    adj.PostBillAdjustedAmountAsString = "3.00";
        //    adj.PostBillAdjustmentAmount = 4.00M;
        //    adj.PostBillAdjustmentAmountAsString = "4.00";
        //    adj.PreBillAdjustedAmount = 5.00M;
        //    adj.PreBillAdjustedAmountAsString = "5.00";
        //    adj.PreBillAdjustmentAmount = 6.00M;
        //    adj.PreBillAdjustmentAmountAsString = "6.00";

        //    reportData.AdjustmentInfo = new Adjustments();
        //    reportData.AdjustmentInfo = adj;

        //    reportData.Amount = 10.00M;
        //    reportData.AmountAsString = "10.00";
        //    reportData.Charges = new List<ReportCharge>();

        //    ReportCharge rc = new ReportCharge();
        //    rc.AdjustmentInfo = new Adjustments();
        //    rc.AdjustmentInfo = adj;
        //    rc.Amount = 1.00M;
        //    rc.AmountAsString = "1.00";

        //    rc.CountyTax = new TaxData();

        //    TaxData tdata = new TaxData();
        //    tdata.PostBillTaxAdjustmentAmount = 1.00M;
        //    tdata.PostBillTaxAdjustmentAmountAsString = "1.00";
        //    tdata.PreBillTaxAdjustmentAmount = 0.50M;
        //    tdata.PreBillTaxAdjustmentAmountAsString = "0.50";
        //    tdata.TaxAmount = 1.50M;
        //    tdata.TaxAmountAsString = "1.50";

        //    rc.CountyTax = tdata;
        //    rc.Currency = "USD";
        //    rc.DisplayAmount = 14.00M;
        //    rc.DisplayAmountAsString = "14.00";
        //    rc.FederalTax = new TaxData();
        //    rc.FederalTax = tdata;

        //    rc.ID = 222;
        //    rc.LocalTax = new TaxData();
        //    rc.LocalTax = tdata;

        //    rc.OtherTax = new TaxData();
        //    rc.OtherTax = tdata;

        //    rc.PreAndPostBillTotalTaxAdjustmentAmount = 100.00M;
        //    rc.PreAndPostBillTotalTaxAdjustmentAmountAsString = "100.00";

        //    rc.ProductSlice = new SingleProductSlice();
        //    rc.StateTax = new TaxData();
        //    rc.StateTax = tdata;

        //    rc.SubCharges = new List<ReportCharge>();

        //    rc.TotalTax = new TaxData();
        //    rc.TotalTax = tdata;

        //    reportData.Charges.Add(rc);

        //    reportData.CountyTax = new TaxData();
        //    reportData.CountyTax = tdata;

        //    reportData.Currency = "USD";
        //    reportData.DisplayAmount = 102.00M;
        //    reportData.DisplayAmountAsString = "102.00";
        //    reportData.FederalTax = new TaxData();
        //    reportData.FederalTax = tdata;

        //    reportData.ID = 22233;
        //    reportData.LocalTax = new TaxData();
        //    reportData.LocalTax = tdata;

        //    reportData.Name = "report level name";
        //    reportData.NumPostBillAdjustments = 23;
        //    reportData.NumPreBillAdjustments = 22;
        //    reportData.OtherTax = new TaxData();
        //    reportData.OtherTax = tdata;
        //    reportData.PreAndPostBillTotalTaxAdjustmentAmount = 30.00M;
        //    reportData.PreAndPostBillTotalTaxAdjustmentAmountAsString = "30.00";
        //    reportData.PreBillAdjustmentsDisplayAmount = 44.00M;
        //    reportData.PreBillAdjustmentsDisplayAmountAsString = "44.00";

        //    reportData.ProductOfferings = new List<ReportProductOffering>();

        //    ReportProductOffering rpo = new ReportProductOffering();
        //    rpo.Amount = 20.00M;
        //    rpo.AmountAsString = "20.00";
        //    rpo.Charges = new List<ReportCharge>();
        //    rpo.Charges.Add(rc);

        //    rpo.Currency = "USD";
        //    rpo.ID = "rpo id";
        //    rpo.Name = "report prod offer";

        //    reportData.ProductOfferings.Add(rpo);

        //    reportData.StateTax = new TaxData();
        //    reportData.StateTax = tdata;

        //    reportData.TotalDisplayAmount = 333.00M;
        //    reportData.TotalDisplayAmountAsString = "333.00";
        //    reportData.TotalTax = new TaxData();
        //    reportData.TotalTax = tdata;

        //    return reportData;

        //}

        private string DataMartEnabledString()
        {
            return IsDataMartEnabled() ? "_DATAMART" : "";
        }
        private bool IsDataMartEnabled()
        {
            if (mMVManager == null)
            {
                mMVManager = new Manager();
                mMVManager.Initialize();
            }
            return mMVManager.IsMetraViewSupportEnabled;
        }

        private DisplayModeEnum GetDisplayMode(ReportParameters repParams)
        {
            DisplayModeEnum retVal = DisplayModeEnum.ONLINE_BILL;

            if (repParams.ReportView == ReportViewType.Interactive)
            {
                if (repParams.InlineAdjustments)
                {
                    if (repParams.InlineVATTaxes)
                    {
                        retVal = DisplayModeEnum.REPORT_ADJUSTMENTS_TAXES;
                    }
                    else
                    {
                        retVal = DisplayModeEnum.REPORT_ADJUSTMENTS;
                    }
                }
                else
                {
                    if (repParams.InlineVATTaxes)
                    {
                        retVal = DisplayModeEnum.REPORT_TAXES;
                    }
                    else
                    {
                        retVal = DisplayModeEnum.REPORT;
                    }
                }
            }
            else
            {
                if (repParams.InlineAdjustments)
                {
                    if (repParams.InlineVATTaxes)
                    {
                        retVal = DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS_TAXES;
                    }
                    else
                    {
                        retVal = DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS;
                    }
                }
                else
                {
                    if (repParams.InlineVATTaxes)
                    {
                        retVal = DisplayModeEnum.ONLINE_BILL_TAXES;
                    }
                    else
                    {
                        retVal = DisplayModeEnum.ONLINE_BILL;
                    }
                }
            }

            return retVal;
        }

        private void PopulateDisplayAmount(ReportLineItem level, ReportParameters repParams)
        {
            DisplayModeEnum displayMode = GetDisplayMode(repParams);

            decimal adjustmentAmount = 0.00M;
            decimal taxAmount = 0.00M;
            decimal ajTaxAmount = 0.00M;

            switch (displayMode)
            {
                case DisplayModeEnum.ONLINE_BILL:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount - level.ImplInfTax.TaxAmount;

                    break;

                case DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount + adjustmentAmount - level.ImplInfTax.TaxAmount;
                    break;

                case DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS_TAXES:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount + adjustmentAmount + taxAmount + ajTaxAmount - level.ImpliedTax.TaxAmount - level.InformationalTax.TaxAmount;
                    break;

                case DisplayModeEnum.ONLINE_BILL_TAXES:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount + taxAmount - level.ImpliedTax.TaxAmount - level.InformationalTax.TaxAmount;
                    break;

                case DisplayModeEnum.REPORT:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount + level.AdjustmentInfo.PostBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount + level.TotalTax.PostBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount + adjustmentAmount - level.ImplInfTax.TaxAmount;
                    break;

                case DisplayModeEnum.REPORT_ADJUSTMENTS:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount + level.AdjustmentInfo.PostBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount + level.TotalTax.PostBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount + adjustmentAmount - level.ImplInfTax.TaxAmount;
                    break;

                case DisplayModeEnum.REPORT_ADJUSTMENTS_TAXES:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount + level.AdjustmentInfo.PostBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount + level.TotalTax.PostBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount + adjustmentAmount + taxAmount + ajTaxAmount - level.ImpliedTax.TaxAmount - level.InformationalTax.TaxAmount;
                    break;

                case DisplayModeEnum.REPORT_TAXES:
                    adjustmentAmount = level.AdjustmentInfo.PreBillAdjustmentAmount + level.AdjustmentInfo.PostBillAdjustmentAmount;
                    taxAmount = level.TotalTax.TaxAmount;
                    ajTaxAmount = level.TotalTax.PreBillTaxAdjustmentAmount + level.TotalTax.PostBillTaxAdjustmentAmount;
                    level.DisplayAmount = level.Amount + adjustmentAmount + taxAmount + ajTaxAmount - level.ImpliedTax.TaxAmount - level.InformationalTax.TaxAmount;
                    break;
            }

            level.DisplayAmountAsString = LocalizeCurrencyString(level.DisplayAmount, repParams.Language, level.Currency);

            if (level.GetType() == typeof(ReportLevel))
            {
                ReportLevel repLevel = level as ReportLevel;
                repLevel.TotalDisplayAmount = level.Amount + adjustmentAmount + ajTaxAmount - level.ImplInfTax.TaxAmount + level.BillableTax.TaxAmount;
                repLevel.TotalDisplayAmountAsString = LocalizeCurrencyString(repLevel.TotalDisplayAmount, repParams.Language, level.Currency);
            }
        }

        private void PopulatePreBillAdjustmentDisplayAmount(ReportLevel level, ReportParameters repParams)
        {

            if (repParams.InlineVATTaxes)
            {
                level.PreBillAdjustmentsDisplayAmount = level.AdjustmentInfo.PreBillAdjustmentAmount +
                                                            level.TotalTax.PreBillTaxAdjustmentAmount;
            }
            else
            {
                level.PreBillAdjustmentsDisplayAmount = level.AdjustmentInfo.PreBillAdjustmentAmount;
            }

            level.PreBillAdjustmentsDisplayAmountAsString = LocalizeCurrencyString(level.PreBillAdjustmentsDisplayAmount, repParams.Language, level.Currency);
        }

        private void AddSliceParameters(IMTNamedParamterStatement stmt, BaseSlice slice, ref int level)
        {
            if (slice.GetType() == typeof(BILL.DateRangeSlice))
            {
                BILL.DateRangeSlice dSlice = slice as BILL.DateRangeSlice;

                stmt.AddParam(string.Format("dtBegin{0}", level), MTParameterType.DateTime, JustifyStartDate(dSlice.Begin));
                stmt.AddParam(string.Format("dtEnd{0}", level), MTParameterType.DateTime, JustifyEndDate(dSlice.End));
            }
            else if (slice.GetType() == typeof(BILL.IntersectionSlice))
            {
                IntersectionSlice iSlice = slice as IntersectionSlice;

                ++level;
                AddSliceParameters(stmt, iSlice.LeftHandSide, ref level);
                ++level;
                AddSliceParameters(stmt, iSlice.RighHandSide, ref level);
            }
            else if (slice.GetType() == typeof(BILL.UsageIntervalSlice))
            {
                BILL.UsageIntervalSlice uSlice = slice as BILL.UsageIntervalSlice;

                stmt.AddParam(string.Format("idInterval{0}", level), MTParameterType.Integer, uSlice.UsageInterval);
            }
            else if (slice.GetType() == typeof(BILL.CurrentAccountIntervalSlice))
            {
                BILL.CurrentAccountIntervalSlice pSlice = slice as BILL.CurrentAccountIntervalSlice;

                int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.AccountId);

                if (id_acc == -1)
                {
                    throw new MASBasicException("Invalid account specified in CurrentAccountIntervalSlice");
                }

                stmt.AddParam(string.Format("idInterval{0}", level), MTParameterType.Integer, SliceConverter.GetCurrentAccountInterval(id_acc));
            }
            else if (slice.GetType() == typeof(BILL.PriceableItemInstanceSlice))
            {
                BILL.PriceableItemInstanceSlice piSlice = slice as BILL.PriceableItemInstanceSlice;

                int poId = PCIdentifierResolver.ResolveProductOffering(piSlice.POInstanceID);
                if (poId == -1)
                {
                    throw new MASBasicException("Invalid Product Offering specified");
                }

                int piId = PCIdentifierResolver.ResolvePriceableItemInstance(poId, piSlice.PIInstanceID);
                if (piId == -1)
                {
                    throw new MASBasicException("Invalid Priceable Item Instance specified");
                }

                stmt.AddParam(string.Format("idPiInstance{0}", level), MTParameterType.Integer, piId);

                int viewId = -1;
                viewId = PCIdentifierResolver.ResolveProductView(piSlice.ViewID);
                if (viewId == -1)
                {
                    throw new MASBasicException("Invalid Product View specified");
                }

                stmt.AddParam(string.Format("idView{0}", level), MTParameterType.Integer, viewId);
            }
            else if (slice.GetType() == typeof(BILL.PriceableItemTemplateSlice))
            {
                BILL.PriceableItemTemplateSlice ptSlice = slice as BILL.PriceableItemTemplateSlice;

                int idTemplate = PCIdentifierResolver.ResolvePriceableItemTemplate(ptSlice.PITemplateID);
                if (idTemplate == -1)
                {
                    throw new MASBasicException("Invalid Priceable Item Template specified");
                }

                stmt.AddParam(string.Format("idTemplate{0}", level), MTParameterType.Integer, idTemplate);

                int viewId = -1;
                viewId = PCIdentifierResolver.ResolveProductView(ptSlice.ViewID);
                if (viewId == -1)
                {
                    throw new MASBasicException("Invalid Product View specified");
                }

                stmt.AddParam(string.Format("idView{0}", level), MTParameterType.Integer, viewId);
            }
            else if (slice.GetType() == typeof(BILL.ProductViewSlice))
            {
                BILL.ProductViewSlice viewSlice = slice as BILL.ProductViewSlice;

                int viewId = -1;
                viewId = PCIdentifierResolver.ResolveProductView(viewSlice.ViewID);
                if (viewId == -1)
                {
                    throw new MASBasicException("Invalid Product View specified");
                }

                stmt.AddParam(string.Format("idView{0}", level), MTParameterType.Integer, viewId);
            }
            else if (slice.GetType() == typeof(BILL.ProductViewAllUsageSlice))
            {
                BILL.ProductViewAllUsageSlice viewSlice = slice as BILL.ProductViewAllUsageSlice;

                int viewId = -1;
                viewId = PCIdentifierResolver.ResolveProductView(viewSlice.ViewID);
                if (viewId == -1)
                {
                    throw new MASBasicException("Invalid Product View specified");
                }

                stmt.AddParam(string.Format("idView{0}", level), MTParameterType.Integer, viewId);
            }
            else if (slice.GetType() == typeof(BILL.PayerAccountSlice))
            {
                BILL.PayerAccountSlice payerSlice = slice as BILL.PayerAccountSlice;

                int accId = AccountIdentifierResolver.ResolveAccountIdentifier(payerSlice.PayerID);
                if (accId == -1)
                {
                    throw new MASBasicException("Invalid payer account specified");
                }

                stmt.AddParam(string.Format("idPayer{0}", level), MTParameterType.Integer, accId);
            }
            else if (slice.GetType() == typeof(BILL.PayeeAccountSlice))
            {
                BILL.PayeeAccountSlice payeeSlice = slice as BILL.PayeeAccountSlice;

                int accId = AccountIdentifierResolver.ResolveAccountIdentifier(payeeSlice.PayeeID);
                if (accId == -1)
                {
                    throw new MASBasicException("Invalid payee account specified");
                }

                stmt.AddParam(string.Format("idPayee{0}", level), MTParameterType.Integer, accId);
            }
            else if (slice.GetType() == typeof(BILL.PayerAndPayeeSlice))
            {
                BILL.PayerAndPayeeSlice pslice = slice as BILL.PayerAndPayeeSlice;

                int accId = AccountIdentifierResolver.ResolveAccountIdentifier(pslice.PayerAccountId);
                if (accId == -1)
                {
                    throw new MASBasicException("Invalid payer account specified");
                }

                stmt.AddParam(string.Format("idPayer{0}", level), MTParameterType.Integer, accId);

                accId = AccountIdentifierResolver.ResolveAccountIdentifier(pslice.PayeeAccountId);
                if (accId == -1)
                {
                    throw new MASBasicException("Invalid payee account specified");
                }

                stmt.AddParam(string.Format("idPayee{0}", level), MTParameterType.Integer, accId);
            }
            else if (slice.GetType() == typeof(BILL.DescendentPayeeSlice))
            {
                BILL.DescendentPayeeSlice dSlice = slice as BILL.DescendentPayeeSlice;

                int ancestorId = AccountIdentifierResolver.ResolveAccountIdentifier(dSlice.AncestorAccountId);
                if (ancestorId == -1)
                {
                    throw new MASBasicException("Invalid ancestor account specified");
                }

                stmt.AddParam(string.Format("idAncestor{0}", level), MTParameterType.Integer, ancestorId);

                stmt.AddParam(string.Format("dtAccBegin{0}", level), MTParameterType.DateTime, dSlice.StartDate);
                stmt.AddParam(string.Format("dtAccEnd{0}", level), MTParameterType.DateTime, dSlice.EndDate);
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        private DateTime JustifyEndDate(DateTime dateTime)
        {
            DateTime retval = dateTime;
            if (dateTime > MetraTime.Max || dateTime < MetraTime.Min)
            {
                retval = MetraTime.Max;
            }

            return retval;
        }

        private DateTime JustifyStartDate(DateTime dateTime)
        {
            DateTime retval = dateTime;
            if (dateTime < MetraTime.Min || dateTime > MetraTime.Max)
            {
                retval = MetraTime.Min;
            }

            return retval;
        }

        private string GetQueryPredicate(BaseSlice slice, bool isOracle, ref int level)
        {
            string retval = string.Empty;

            using (MTComSmartPtr<IMTQueryAdapter> qa = new MTComSmartPtr<IMTQueryAdapter>())
            {
                qa.Item = new MTQueryAdapterClass();
                qa.Item.Init(METRAVIEW_QUERY_FOLDER);

                if (slice.GetType() == typeof(BILL.DateRangeSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__DATE_RANGE_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.IntersectionSlice))
                {
                    IntersectionSlice iSlice = slice as IntersectionSlice;

                    ++level;
                    string leftHandSide = GetQueryPredicate(iSlice.LeftHandSide, isOracle, ref level);
                    ++level;
                    string rightHandSide = GetQueryPredicate(iSlice.RighHandSide, isOracle, ref level);

                    retval = string.Format("{0} AND {1}", leftHandSide, rightHandSide);
                }
                else if (slice.GetType() == typeof(BILL.UsageIntervalSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__USAGE_INTERVAL_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.CurrentAccountIntervalSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__USAGE_INTERVAL_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.PriceableItemInstanceSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__PRICEABLE_ITEM_INSTANCE_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.PriceableItemTemplateSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__PRICEABLE_ITEM_TEMPLATE_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.ProductViewSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__PRODUCT_VIEW_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.ProductViewAllUsageSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__PRODUCT_VIEW_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.PayerAccountSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__PAYER_ACCOUNT_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.PayeeAccountSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__PAYEE_ACCOUNT_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.PayerAndPayeeSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__PAYER_AND_PAYEE_ACCOUNT_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else if (slice.GetType() == typeof(BILL.DescendentPayeeSlice))
                {
                    qa.Item.SetQueryTag(string.Format("__DESCENDENT_PAYEE_PREDICATE{0}__", (IsDataMartEnabled() ? "_DATAMART" : "")));
                    qa.Item.AddParam("%%LEVEL%%", level, true);
                    retval = qa.Item.GetRawSQLQuery(true);
                }
                else
                {
                    throw new NotImplementedException();
                }
            }

            return retval;
        }

        private void GetTimeSpan(TimeSlice timeSlice, out DateTime startDt, out DateTime endDt)
        {
            startDt = MetraTime.Min;
            endDt = MetraTime.Max;

            if (timeSlice.GetType() == typeof(BILL.DateRangeSlice))
            {
                BILL.DateRangeSlice drSlice = timeSlice as BILL.DateRangeSlice;

                startDt = JustifyStartDate(drSlice.Begin);
                endDt = JustifyEndDate(drSlice.End);
            }
            else if (timeSlice.GetType() == typeof(BILL.IntersectionSlice))
            {
                IntersectionSlice iSlice = timeSlice as IntersectionSlice;
                DateTime lhStart, lhEnd;
                DateTime rhStart, rhEnd;

                GetTimeSpan(iSlice.LeftHandSide, out lhStart, out lhEnd);
                GetTimeSpan(iSlice.RighHandSide, out rhStart, out rhEnd);

                startDt = (lhStart < rhStart) ? lhStart : rhStart;
                endDt = (lhEnd < rhEnd) ? rhEnd : lhEnd;
            }
            else if (timeSlice.GetType() == typeof(BILL.UsageIntervalSlice))
            {
                BILL.UsageIntervalSlice uSlice = timeSlice as BILL.UsageIntervalSlice;

                using (MTComSmartPtr<HR.UsageIntervalSlice> iSlice = new MTComSmartPtr<MetraTech.Interop.MTHierarchyReports.UsageIntervalSlice>())
                {
                    iSlice.Item = new HR.UsageIntervalSliceClass();
                    iSlice.Item.IntervalID = uSlice.UsageInterval;

                    iSlice.Item.GetTimeSpan(out startDt, out endDt);
                }
            }
            else if (timeSlice.GetType() == typeof(BILL.CurrentAccountIntervalSlice))
            {
                BILL.CurrentAccountIntervalSlice pSlice = timeSlice as BILL.CurrentAccountIntervalSlice;

                int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.AccountId);

                if (id_acc == -1)
                {
                    throw new MASBasicException("Invalid account specified in CurrentAccountIntervalSlice");
                }

                using (MTComSmartPtr<HR.UsageIntervalSlice> iSlice = new MTComSmartPtr<MetraTech.Interop.MTHierarchyReports.UsageIntervalSlice>())
                {
                    iSlice.Item = new HR.UsageIntervalSliceClass();
                    iSlice.Item.IntervalID = SliceConverter.GetCurrentAccountInterval(id_acc);

                    iSlice.Item.GetTimeSpan(out startDt, out endDt);
                }
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        private string GetUsageDetailQuery(ReportParameters repParams, SingleProductSlice productSlice, AccountSlice accountSlice)
        {
            string retval = null;

            int viewId = -1;
            viewId = PCIdentifierResolver.ResolveProductView(productSlice.ViewID);
            if (viewId == -1)
            {
                throw new MASBasicException("Invalid Product View specified");
            }

            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
                queryAdapter.Item = new MTQueryAdapterClass();
                queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER);

                // ESR-5421 Figure out if it is By Interval or Anything else then cache query into one of two dictionaries. 
                //One for By Interval Queries, one for Everything else. Check in the right dictionary that we have a cached query
                //splitting the single DATAMART query into two queries will allow tuning of the individual query
                bool doWeHaveCachedQuery = false;
                string baseDetailQuery;
                int level1 = 0;
                string sMainStr = GetQueryPredicate(repParams.DateRange, queryAdapter.Item.IsOracle(), ref level1);
                string sSearchStr = "id_usage_interval";
                bool IsItIntervalBasedQuery;
                IsItIntervalBasedQuery = sMainStr.Contains(sSearchStr);

                // ESR-5421 we now have "intervalBased" datamart queries and non interval based queries. the non interval based queries being the originial "DATE" based queries
                // added the "GET_USAGE_DETAIL_INTERVAL" and "GET_USAGE_DETAIL_INTERVAL_DATAMART tags.These two new tags exist in both the "ORACLE.xml" and SqlServer.xml                
                // this was done to allow query tuning for "DATE" or "INTERVAL" based query, "DATE" bring the orginial query or by "INTERVAL" the new query
                // only the sql server "GET_USAGE_DETAIL_INTERVAL_DATAMART datamart query has been tuned as part of ESR-5421 
                if (IsItIntervalBasedQuery)
                {
                    // okay we are interval based, run the DataMart Interval or Non Datamart Interval query
                    queryAdapter.Item.SetQueryTag(string.Format("__GET_USAGE_DETAIL{0}{1}__", (!IsItIntervalBasedQuery ? "" : "_INTERVAL"), (!IsDataMartEnabled() ? "" : "_DATAMART")));
                    doWeHaveCachedQuery = m_UsageDetailQueriesInterval.TryGetValue(viewId, out baseDetailQuery);
                    mLogger.LogDebug("Execute the query {0} to select data by interval. ", string.Format("__GET_USAGE_DETAIL{0}{1}__", (!IsItIntervalBasedQuery ? "" : "_INTERVAL"), (!IsDataMartEnabled() ? "" : "_DATAMART")));
                }
                else
                {
                    // this is the orginial query                    
                    queryAdapter.Item.SetQueryTag(string.Format("__GET_USAGE_DETAIL{0}__", (!IsDataMartEnabled() ? "" : "_DATAMART")));
                    doWeHaveCachedQuery = m_UsageDetailQueries.TryGetValue(viewId, out baseDetailQuery);
                    mLogger.LogDebug("Execute the query {0} to select data. ", string.Format("__GET_USAGE_DETAIL{0}__", (!IsDataMartEnabled() ? "" : "_DATAMART")));
                }

                // ESR-5421 check to see if the query has been cached
                if (!doWeHaveCachedQuery)
                {
                    ProductViewLib.ProductView productView = GetProductView(viewId);

                    string selectList = "";
                    string fromClause = "";

                    #region Build Select list and From clause
                    foreach (ProductViewLib.ProductViewProperty prodViewProp in productView.GetProperties())
                    {
                        if (!prodViewProp.Core && prodViewProp.UserVisible)
                        {
                            if (prodViewProp.PropertyType != ProductViewLib.MSIX_PROPERTY_TYPE.MSIX_TYPE_ENUM)
                            {
                                selectList += string.Format(", pv.{0} {1}", prodViewProp.ColumnName, prodViewProp.dn);
                            }
                            else
                            {
                                int descId = prodViewProp.DescriptionID;
                                fromClause += string.Format(
                                    "\n{0} t_description desc{1} ON desc{1}.id_desc = pv.{2} and desc{1}.id_lang_code = {3}langCode",
                                    (prodViewProp.required ? "INNER JOIN" : "LEFT OUTER JOIN"),  // ESR-6199
                                    descId, 
                                    prodViewProp.ColumnName, 
                                    (queryAdapter.Item.IsOracle() ? ":" : "@")
                                    );
                                selectList += string.Format(", desc{0}.id_desc {1}", descId, prodViewProp.dn);
                            }
                        }
                    }
                    #endregion

                    #region Build base query template

                    queryAdapter.Item.AddParam("%%SELECT_CLAUSE%%", selectList, true);
                    queryAdapter.Item.AddParam("%%FROM_CLAUSE%%", fromClause, true);
                    queryAdapter.Item.AddParam("%%TABLE_NAME%%", productView.tablename, true);

                    if (m_PVIdToNameMap[viewId].HasChildren)
                    {
                        queryAdapter.Item.AddParam("%%SESSION_TYPE%%", DB_COMPOUND_SESSION, true);
                    }
                    else
                    {
                        queryAdapter.Item.AddParam("%%SESSION_TYPE%%", DB_ATOMIC_SESSION, true);
                    }

                    IQueryHinter hinter = (IQueryHinter)queryAdapter.Item.GetHinter();
                    if (hinter != null)
                    {
                        hinter.AddParam("AccountSlice", SliceConverter.ToString(accountSlice));
                        hinter.AddParam("ProductSlice", SliceConverter.ToString(productSlice));
                        hinter.Apply();
                    }

                    baseDetailQuery = queryAdapter.Item.GetRawSQLQuery(true);


                    // ESR-5421 cache the query 
                    if (IsItIntervalBasedQuery)
                    {
                        m_UsageDetailQueriesInterval.Add(viewId, baseDetailQuery);
                    }
                    else
                    {
                        m_UsageDetailQueries.Add(viewId, baseDetailQuery);
                    }

                    #endregion
                }

                queryAdapter.Item.SetRawSQLQuery(baseDetailQuery.Clone() as string);

                string displayAmount = "";

                #region Build display amount value
                if (repParams.ReportView == ReportViewType.OnlineBill)
                {
                    if (repParams.InlineAdjustments)
                    {
                        if (repParams.InlineVATTaxes)
                        {
                            displayAmount = string.Format("{0} + {1} + {2} + {3}", AMOUNT, TOTAL_TAX, PRE_BILL_ADJ_AMOUNT, PRE_BILL_TOTAL_TAX_ADJ_AMOUNT);
                        }
                        else
                        {
                            displayAmount = string.Format("{0} + {1}", AMOUNT, PRE_BILL_ADJ_AMOUNT);
                        }
                    }
                    else
                    {
                        if (repParams.InlineVATTaxes)
                        {
                            displayAmount = string.Format("{0} + {1}", AMOUNT, TOTAL_TAX);
                        }
                        else
                        {
                            displayAmount = string.Format("{0}", AMOUNT);
                        }
                    }
                }
                else
                {
                    // NOTE: We always inline adjustments in the report view so that is why we don't check InlineAdjustments value
                    if (repParams.InlineVATTaxes)
                    {
                        displayAmount = string.Format("{0} + {1} + {2} + {3} + {4} + {5}",
                                                        AMOUNT,
                                                        TOTAL_TAX,
                                                        PRE_BILL_ADJ_AMOUNT,
                                                        PRE_BILL_TOTAL_TAX_ADJ_AMOUNT,
                                                        POST_BILL_ADJ_AMOUNT,
                                                        POST_BILL_TOTAL_TAX_ADJ_AMOUNT);
                    }
                    else
                    {
                        displayAmount = string.Format("{0} + {1} + {2}", AMOUNT, PRE_BILL_ADJ_AMOUNT, POST_BILL_ADJ_AMOUNT);
                    }
                }
                #endregion

                queryAdapter.Item.AddParam("%%DISPLAYAMOUNT%%", displayAmount, true);

                int level = 0;
                string queryPredicate = GetQueryPredicate(repParams.DateRange, queryAdapter.Item.IsOracle(), ref level);
                queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", queryPredicate, true);

                queryPredicate = GetQueryPredicate(productSlice, queryAdapter.Item.IsOracle(), ref level);
                queryAdapter.Item.AddParam("%%PRODUCT_PREDICATE%%", queryPredicate, true);

                queryPredicate = GetQueryPredicate(accountSlice, queryAdapter.Item.IsOracle(), ref level);
                queryAdapter.Item.AddParam("%%ACCOUNT_PREDICATE%%", queryPredicate, true);

                queryAdapter.Item.AddParam("%%ACCOUNT_FROM_CLAUSE%%", GetAccountFromClause(accountSlice), true);

                retval = queryAdapter.Item.GetQuery();
            }

            return retval;
        }

        private string GetAccountFromClause(AccountSlice accountSlice)
        {
            string fromClause = "";

            if (accountSlice.GetType() == typeof(BILL.DescendentPayeeSlice))
            {
                fromClause = "INNER JOIN t_account_ancestor aa on au.id_payee = aa.id_descendent";
            }

            return fromClause;
        }

        private ProductViewLib.ProductView GetProductView(int viewId)
        {
            ProductViewLib.ProductView prodView = null;

            lock (m_ProductViews)
            {
                if (!m_ProductViews.TryGetValue(viewId, out prodView))
                {
                    ProductViewData viewName = m_PVIdToNameMap[viewId];

                    prodView = new ProductViewLib.ProductViewClass();
                    prodView.Init(viewName.Name, viewName.HasChildren);

                    m_ProductViews.Add(viewId, prodView);
                }
            }

            return prodView;
        }
        #endregion
    }
}
        
