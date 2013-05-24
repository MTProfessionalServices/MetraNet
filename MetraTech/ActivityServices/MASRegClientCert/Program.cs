using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography;
using System.Transactions;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MTAuth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTServerAccess;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.Core.Activities;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAccount;
using MetraTech.Interop.Rowset;

namespace MetraTech.ActivityServices.ClientCertRegistrar
{
    class Program
    {
        #region Members
        private static Nullable<StoreLocation> m_StoreLocation = null;
        private static Nullable<StoreName> m_StoreName = null;
        private static Nullable<X509FindType> m_FindType = null;
        private static string m_FindValue = null;
        private static string m_RoleName = null;
        #endregion

        static void Main(string[] args)
        {
            // Validate & parse args
            if (ParseArgs(args))
            {
                MTAuth.IMTRole specifiedRole = null;

                #region Get session context
                MTAuth.IMTLoginContext loginContext = new MTAuth.MTLoginContextClass();
                IMTServerAccessDataSet sa = new MTServerAccessDataSet();
                sa.Initialize();
                IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
                string suName = accessData.UserName;
                string suPassword = accessData.Password;
                MTAuth.MTSessionContext suCtx = loginContext.Login(suName, "system_user", suPassword);
                #endregion

                #region Get Specified MT Role
                //Determine if specified Role is valid
                MTAuth.MTSecurity secServer = new MTAuth.MTSecurityClass();
                specifiedRole = secServer.GetRoleByName(suCtx, m_RoleName);
                #endregion

                #region Get Client Certificate from Store
                // Locate Certificate
                X509Certificate2 clientCert = GetClientCertificate();
                #endregion

                #region Set up system user accoutn
                if (clientCert != null)
                {
                    try
                    {
                        YAAC.MTYAAC yaac = null;
                        YAAC.MTAccountCatalog acctCat = new YAAC.MTAccountCatalogClass();
                        acctCat.Init(((YAAC.IMTSessionContext)suCtx));

                        // Determine if user exists for certificate in t_account_mapper
                        try
                        {
                            yaac = acctCat.GetAccountByName(clientCert.SerialNumber, "auth", MetraTime.Now);
                        }
                        catch
                        {
                          // Do nothing since we create the account if necessary
                        }

                        if (yaac == null)
                        {
                            // Account does not exist, so create it
                            //using (TransactionScope scope = new TransactionScope())
                            //{
                                int id_acc = CreateAccount(clientCert);
                                CreateInternalView(clientCert, id_acc);

                                //scope.Complete();
                            //}

                            // Now get the YAAC so that the role can be added
                            yaac = acctCat.GetAccountByName(clientCert.SerialNumber, "auth", MetraTime.Now.AddDays(1));
                        }

                        // Determine if account has role already assigned
                        if (!yaac.SessionContext.SecurityContext.IsInRole(m_RoleName))
                        {
                            // Role not assigned, so add it
                            YAAC.IMTPrincipalPolicy policy = yaac.GetActivePolicy(((YAAC.IMTSessionContext)suCtx));
                            policy.AddRole(((YAAC.IMTRole)specifiedRole));
                            policy.Save();
                        }
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("Error occured creating certificate registration");
                        Console.WriteLine("Error was: {0}", e.Message);
                        Console.WriteLine("Error occurrred at: {0}", e.StackTrace);

                        Exception inner = e.InnerException;

                        while (inner != null)
                        {
                            Console.WriteLine();

                            Console.WriteLine("Inner message: {0}", inner.Message);
                            Console.WriteLine("Inner occurred at: {0}", inner.StackTrace);

                            inner = inner.InnerException;
                        }
                    }
                }
                #endregion
            }            
        }

        private static void CreateInternalView(X509Certificate2 clientCert, int id_acc)
        {
            MTAccountServer acctServer = new MTAccountServerClass();
            acctServer.Initialize("Internal");

            MTAccountPropertyCollection acctProps = new MTAccountPropertyCollectionClass();

            acctProps.Add("id_acc", id_acc);

            acctProps.Add("taxexempt", "1");
            acctProps.Add("SecurityAnswer", "None");
            acctProps.Add("StatusReasonOther", "No other reason");
            acctProps.Add("TaxExemptID", "1234567");
            acctProps.Add("currency", "USD");
            acctProps.Add("folder", "1");
            acctProps.Add("billable", "1");
            acctProps.Add("timezoneID", EnumHelper.GetDbValueByEnum("Global/TimezoneID/(GMT) Monrovia, Casablanca"));

            acctProps.Add("PaymentMethod", EnumHelper.GetDbValueByEnum("metratech.com/accountcreation/PaymentMethod/CashOrCheck"));
            acctProps.Add("AccountStatus", EnumHelper.GetDbValueByEnum("metratech.com/accountcreation/AccountStatus/Active"));
            acctProps.Add("SecurityQuestion", EnumHelper.GetDbValueByEnum("metratech.com/accountcreation/SecurityQuestion/Pin"));
            acctProps.Add("InvoiceMethod", EnumHelper.GetDbValueByEnum("metratech.com/accountcreation/InvoiceMethod/None"));
            acctProps.Add("UsageCycleType", EnumHelper.GetDbValueByEnum("metratech.com/BillingCycle/UsageCycleType/Monthly"));
            acctProps.Add("StatusReason", EnumHelper.GetDbValueByEnum("metratech.com/accountcreation/StatusReason/AccountTerminated"));
            acctProps.Add("Language", EnumHelper.GetDbValueByEnum("Global/LanguageCode/US"));

            acctServer.AddData("Internal", acctProps, null);
        }

        private static int CreateAccount(X509Certificate2 clientCert)
        {
            IdGenerator profileIdGenerator = new IdGenerator("id_profile", 1);
            IdGenerator accountIdGenerator = new IdGenerator("id_acc", 1);

            int accountId = accountIdGenerator.NextMashedId;


            // Execute the stored procedure "AddNewAccount"
            using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddNewAccount"))
                {

                    stmt.AddParam("p_id_acc_ext", MTParameterType.String, Guid.NewGuid().ToString("N"));
                    stmt.AddParam("p_acc_state", MTParameterType.String, AccountStatus.Active);
                    // p_acc_status_ext is not used by the stored proc
                    stmt.AddParam("p_acc_status_ext", MTParameterType.Integer, null);

                    stmt.AddParam("p_acc_vtstart", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddParam("p_acc_vtend", MTParameterType.DateTime, MetraTime.Max);
                    stmt.AddParam("p_nm_login", MTParameterType.String, clientCert.SerialNumber);
                    stmt.AddParam("p_nm_space", MTParameterType.String, "auth");

                    // Hash the password. 
                    stmt.AddParam("p_tx_password", MTParameterType.String, AccountHelper.EncryptPassword(clientCert.SerialNumber, "auth", clientCert.Thumbprint));

                    stmt.AddParam("p_auth_type", MTParameterType.Integer, EnumHelper.GetValueByEnum(AuthenticationType.MetraNetInternal));

                    stmt.AddParam("p_langcode", MTParameterType.String, LanguageCode.US.ToString());
                    stmt.AddParam("p_profile_timezone", MTParameterType.Integer, 18);
                    stmt.AddParam("p_id_cycle_type", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(UsageCycleType.Monthly)));

                    stmt.AddParam("p_day_of_month", MTParameterType.Integer, 31);
                    stmt.AddParam("p_day_of_week", MTParameterType.Integer, null);
                    stmt.AddParam("p_first_day_of_month", MTParameterType.Integer, null);
                    stmt.AddParam("p_second_day_of_month", MTParameterType.Integer, null);
                    stmt.AddParam("p_start_day", MTParameterType.Integer, null);
                    stmt.AddParam("p_start_month", MTParameterType.Integer, null);
                    stmt.AddParam("p_start_year", MTParameterType.Integer, null);

                    stmt.AddParam("p_billable", MTParameterType.String, EnumHelper.GetMTBool(true));

                    stmt.AddParam("p_id_payer", MTParameterType.Integer, accountId);
                    // Null out the payer dates - stored proc will always pick up the date from account start date
                    stmt.AddParam("p_payer_startdate", MTParameterType.DateTime, null);
                    stmt.AddParam("p_payer_enddate", MTParameterType.DateTime, null);
                    stmt.AddParam("p_payer_login", MTParameterType.String, null);
                    stmt.AddParam("p_payer_namespace", MTParameterType.String, null);

                    stmt.AddParam("p_id_ancestor", MTParameterType.Integer, 1);

                    // Null out the hierarchy dates - stored proc will always pick up the date from account start date 
                    stmt.AddParam("p_hierarchy_start", MTParameterType.DateTime, null);
                    stmt.AddParam("p_hierarchy_end", MTParameterType.DateTime, null);
                    stmt.AddParam("p_ancestor_name", MTParameterType.String, null);
                    stmt.AddParam("p_ancestor_namespace", MTParameterType.String, null);

                    stmt.AddParam("p_acc_type", MTParameterType.String, "SystemAccount");

                    stmt.AddParam("p_apply_default_policy", MTParameterType.String, "True");
                    stmt.AddParam("p_systemdate", MTParameterType.DateTime, MetraTime.Now);

                    // Convert to bool
                    IMTProductCatalog productCatalog = new MTProductCatalogClass();
                    string enforceSameCorporation = "1";
                    if (productCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == false)
                    {
                        enforceSameCorporation = "0";
                    }
                    stmt.AddParam("p_enforce_same_corporation", MTParameterType.String, enforceSameCorporation);
                    stmt.AddParam("p_account_currency", MTParameterType.String, "USD");


                    stmt.AddParam("p_profile_id", MTParameterType.Integer, profileIdGenerator.NextId);

                    // LoginApplication is valid only for system accounts

                    stmt.AddParam("p_login_app", MTParameterType.String, "CSR");

                    stmt.AddParam("accountID", MTParameterType.Integer, accountId);

                    // Outputs
                    stmt.AddOutputParam("status", MTParameterType.Integer, 0);
                    stmt.AddOutputParam("p_hierarchy_path", MTParameterType.String, 4000);
                    stmt.AddOutputParam("p_currency", MTParameterType.String, 10);
                    stmt.AddOutputParam("p_id_ancestor_out", MTParameterType.Integer, 0);
                    stmt.AddOutputParam("p_corporate_account_id", MTParameterType.Integer, 0);
                    stmt.AddOutputParam("p_ancestor_type_out", MTParameterType.String, 40);

                    stmt.ExecuteNonQuery();

                    int status = (int)stmt.GetOutputValue("status");

                    if (status != 1)
                    {
                        string error = GetErrorMsg(status);

                        throw new ApplicationException(error);
                    }
                }
            }

            return accountId;
        }

        private static string GetErrorMsg(int status)
        {
            string error = String.Empty;
            switch (status)
            {
                case ACCOUNTMAPPER_ERR_ALREADY_EXISTS:
                    {
                        error = ACCOUNTMAPPER_ERR_ALREADY_EXISTS_MSG;
                        break;
                    }
                case MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH:
                    {
                        error = MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH_MSG;
                        break;
                    }
                case MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER:
                    {
                        error = MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER_MSG;
                        break;
                    }
                case MT_CANNOT_RESOLVE_PAYING_ACCOUNT:
                    {
                        error = MT_CANNOT_RESOLVE_PAYING_ACCOUNT_MSG;
                        break;
                    }
                case MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT:
                    {
                        error = MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT_MSG;
                        break;
                    }
                case MT_PARENT_NOT_IN_HIERARCHY:
                    {
                        error = MT_PARENT_NOT_IN_HIERARCHY_MSG;
                        break;
                    }
                case MT_ANCESTOR_OF_INCORRECT_TYPE:
                    {
                        error = MT_ANCESTOR_OF_INCORRECT_TYPE_MSG;
                        break;
                    }
                case MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START:
                    {
                        error = MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START_MSG;
                        break;
                    }
                case MT_ACCOUNT_ALREADY_IN_HIERARCHY:
                    {
                        error = MT_ACCOUNT_ALREADY_IN_HIERARCHY_MSG;
                        break;
                    }
                case MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE:
                    {
                        error = MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE_MSG;
                        break;
                    }
                case MT_PAYMENT_START_AND_END_ARE_THE_SAME:
                    {
                        error = MT_PAYMENT_START_AND_END_ARE_THE_SAME_MSG;
                        break;
                    }
                case MT_PAYMENT_START_AFTER_END:
                    {
                        error = MT_PAYMENT_START_AFTER_END_MSG;
                        break;
                    }
                case MT_ACCOUNT_IS_NOT_BILLABLE:
                    {
                        error = MT_ACCOUNT_IS_NOT_BILLABLE_MSG;
                        break;
                    }
                case MT_PAYER_IN_INVALID_STATE:
                    {
                        error = MT_PAYER_IN_INVALID_STATE_MSG;
                        break;
                    }
                case MT_PAYER_PAYEE_CURRENCY_MISMATCH_SQL:
                case MT_PAYER_PAYEE_CURRENCY_MISMATCH_ORC:
                    {
                        error = MT_PAYER_PAYEE_CURRENCY_MISMATCH_MSG;
                        break;
                    }
                case MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT:
                    {
                        error = MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT_MSG;
                        break;
                    }
                case MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE:
                    {
                        error = MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE_MSG;
                        break;
                    }
                default:
                    {
                        // return error
                        error = String.Format("Unable to create account with status '{0}'.", status);
                        break;
                    }
            }

            return error;

        }

        private static X509Certificate2 GetClientCertificate()
        {
            X509Certificate2 clientCert = null;

            X509Store xStore = new X509Store(m_StoreName.Value, m_StoreLocation.Value);
            xStore.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);

            X509Certificate2Collection certCollection = xStore.Certificates;

            object findVal = m_FindValue;

            if (m_FindType.Value == X509FindType.FindByTimeExpired || m_FindType.Value == X509FindType.FindByTimeNotYetValid ||
                m_FindType.Value == X509FindType.FindByTimeValid)
            {
                findVal = DateTime.Parse(m_FindValue);
            }

            X509Certificate2Collection foundCerts = certCollection.Find(m_FindType.Value, findVal, true);

            if (foundCerts.Count > 1)
            {
                X509Certificate2Collection selectedCerts = X509Certificate2UI.SelectFromCollection(foundCerts, "Select client certificate", "Select a certificate from the following list to register it with the MetraNet system", X509SelectionFlag.SingleSelection);

                if (selectedCerts.Count == 1)
                {
                    clientCert = selectedCerts[0];
                }
            }
            else if (foundCerts.Count == 1)
            {
                clientCert = foundCerts[0];
            }

            return clientCert;
        }

        private static void PrintUsage()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("MASRegClientCert /? /sn:<StoreName> /sl:<StoreLocation> /ft:<FindType> /v:<FindValue> /r:<Role>");
            Console.WriteLine("/?\t\t\t\tPrint Usage");
            Console.WriteLine("/sn:<StoreName>\t\t\t\tThe name of the certificate store that contains the desired certificate");
            Console.WriteLine("/sl:<StoreLocation>\t\t\t\tThe location of the certificate store that contains the desired certificate");
            Console.WriteLine("/ft:<FindType>\t\t\t\tSpecifies the property of the certificate to search for a match to <FindValue>");
            Console.WriteLine("/fv:<FindValue>\t\t\t\tThe value to search for that identifies the certificate");
            Console.WriteLine("/r:<Role>\t\t\t\tThe name of the MetraNet role to be asssigned to the account");
        }

        private static bool ParseArgs(string[] args)
        {
            bool retval = true;
            if (args.Length == 5)
            {
                #region Parse arguments
                try
                {
                    foreach (string arg in args)
                    {
                        if (arg != "/?")
                        {
                            string[] parts = arg.Split(':');

                            switch (parts[0])
                            {
                                case "/sn":
                                    m_StoreName = (StoreName)Enum.Parse(typeof(StoreName), parts[1]);
                                    break;
                                case "/sl":
                                    m_StoreLocation = (StoreLocation)Enum.Parse(typeof(StoreLocation), parts[1]);
                                    break;
                                case "/ft":
                                    m_FindType = (X509FindType)Enum.Parse(typeof(X509FindType), parts[1]);
                                    break;
                                case "/fv":
                                    m_FindValue = parts[1];
                                    break;
                                case "/r":
                                    m_RoleName = parts[1];
                                    break;
                                default:
                                    throw new ApplicationException(string.Format("Argument {0} not recognized", arg));
                            }
                        }
                        else
                        {
                            retval = false;
                            break;
                        }
                    }

                    if (m_StoreLocation == null || m_StoreName == null || m_FindType == null || m_FindValue == null || m_RoleName == null)
                    {
                        Console.WriteLine("Not all arguments have been specified");
                        retval = false;
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine("Error occurred parsing arguments: {0}", e.Message);
                    retval = false;
                }
                #endregion
            }
            else
            {
                Console.WriteLine("Incorrect number of argument specified");
                retval = false;
            }

            if (!retval)
            {
                PrintUsage();
            }

            return retval;
        }

        #region Error Strings
        private const int ACCOUNTMAPPER_ERR_ALREADY_EXISTS = -501284862;
        private const string ACCOUNTMAPPER_ERR_ALREADY_EXISTS_MSG = "Account mapping already exists";

        private const int MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH = -486604732;
        private const string MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH_MSG = "Account Type and Namespace mismatch during account creation.";

        private const int MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER = -486604768;
        private const string MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER_MSG = "An account marked as non-billable must have a paying account.";

        private const int MT_CANNOT_RESOLVE_PAYING_ACCOUNT = -486604792;
        private const string MT_CANNOT_RESOLVE_PAYING_ACCOUNT_MSG = "Account Creation can not resolve the payer account from the login and namespace.";

        private const int MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT = -486604791;
        private const string MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT_MSG = "Account Creation can not resolve the hierarchy parent from the login and namespace.";

        private const int MT_PARENT_NOT_IN_HIERARCHY = -486604771;
        private const string MT_PARENT_NOT_IN_HIERARCHY_MSG = "The specified parent does not exist in the hierarchy.";

        private const int MT_ANCESTOR_OF_INCORRECT_TYPE = -486604714;
        private const string MT_ANCESTOR_OF_INCORRECT_TYPE_MSG = "Account requires a parent account.";

        private const int MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START = -486604746;
        private const string MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START_MSG = "The system cannot create the account in the hierarchy before the start date of the ancestor.";

        private const int MT_ACCOUNT_ALREADY_IN_HIERARCHY = -486604785;
        private const string MT_ACCOUNT_ALREADY_IN_HIERARCHY_MSG = "The account is already in the hierarchy in the specified time range.";

        private const int MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE = -486604753;
        private const string MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE_MSG = "The system cannot create a payment record before the creation date of the account.";

        private const int MT_PAYMENT_START_AND_END_ARE_THE_SAME = -486604735;
        private const string MT_PAYMENT_START_AND_END_ARE_THE_SAME_MSG = "The system cannot create a payment record where the start and end day are the same day.";

        private const int MT_PAYMENT_START_AFTER_END = -486604734;
        private const string MT_PAYMENT_START_AFTER_END_MSG = "The payment start date must be before the payment end date.";

        private const int MT_ACCOUNT_IS_NOT_BILLABLE = -486604795;
        private const string MT_ACCOUNT_IS_NOT_BILLABLE_MSG = "The paying account is not billable.";

        private const int MT_PAYER_IN_INVALID_STATE = -486604736;
        private const string MT_PAYER_IN_INVALID_STATE_MSG = "The paying account is not active during the payment time interval.";

        private const int MT_PAYER_PAYEE_CURRENCY_MISMATCH_SQL = -486604737;  // Error Condition Returned by SQL Server
        private const int MT_PAYER_PAYEE_CURRENCY_MISMATCH_ORC = -486604728;  // Error Condition Returned by Oracle
        private const string MT_PAYER_PAYEE_CURRENCY_MISMATCH_MSG = "The currency of the payer account must match the currency of the payee account.";

        private const int MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT = -486604758;
        private const string MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT_MSG = "Both the payer account and payee account must share the same corporate account.";

        private const int MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE = -289472464;
        private const string MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE_MSG = "";

        #endregion
    }
}
