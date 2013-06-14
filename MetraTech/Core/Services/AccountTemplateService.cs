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
using System.Runtime.Serialization;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Validators;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using Common = MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MTAuth = MetraTech.Interop.MTAuth;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Accounts.Type;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.NameID;
using MetraTech.Pipeline;
using MetraTech.DomainModel.Common;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTYAAC;
using BaseTypes = MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accounttemplate;
using System.Threading;
using System.Configuration;
using System.IO;
using MetraTech.Interop.RCD;
using ProdCatalog = MetraTech.Interop.MTProductCatalog;
using Subscription = MetraTech.Interop.Subscription;
using System.Reflection;
using MetraTech.Core.Client;
using MetraTech.Interop.GenericCollection;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuditEvents;
using IMTYAAC = MetraTech.Interop.MTYAAC.IMTYAAC;
using MetraTech.Debug.Diagnostics;



//using MetraTech.Interop.MTAuth;



namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IAccountTemplateService
  {
    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void GetTemplatesForOwner(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        ref List<AccountTemplateDef> templateDefs);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void GetTemplateDefForAccountType(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        bool inheritAnscestorProperties,
        out AccountTemplate template);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void GetEligiblePOsForAccountType(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        ref Common.MTList<ProductOffering> productOfferings);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void GetEligibleGroupSubsForAccountType(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        ref Common.MTList<GroupSubscription> groupSubs);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void SaveAccountTemplate(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        ref AccountTemplate template);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void DeleteAccountTemplate(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void ApplyAccountTemplate(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        AccountTemplateScope templateScope,
        DateTime effectiveDate,
        List<string> propNames,
        List<AccountTemplateSubscription> subscriptions,
        BaseTypes.ProdCatTimeSpan subscriptionDates,
        bool endConflictingSubscriptions,
        out int sessionId);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void ApplyTemplateToAccounts(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        List<MetraTech.ActivityServices.Common.AccountIdentifier> accountIds,
        DateTime effectiveDate,
        List<string> propNames,
        List<AccountTemplateSubscription> subscriptions,
        BaseTypes.ProdCatTimeSpan subscriptionDates,
        bool endConflictingSubscriptions,
        out int sessionId);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void GetAccountTemplateSessions(ref Common.MTList<AccountTemplateSession> sessions);

    [OperationContract]
    [FaultContract(typeof(Common.MASBasicFaultDetail))]
    void GetTemplateSessionDetails(int sessionId, ref Common.MTList<AccountTemplateSessionDetail> details);
  }

  [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
  public class AccountTemplateService : CMASServiceBase, IAccountTemplateService
  {
		//Describes signature of method which implemented business logic for applying account template in background thread.
		delegate void ApplyAccountTemplateDelegate(int templateId, int sessionId, object additional);

    #region Private Members
    private static Logger m_Logger = new Logger("[AccountTemplateService]");
    private static IdGenerator m_SessionIdGenerator = new IdGenerator("id_template_session", 100);

    private static AccountTemplateServiceConfigSection m_ConfigSection;

    private static MTRecoverableQueue<AccountTemplateRequest> m_RequestsQueue = null;

    private const int RootAccountId = 1;
    Auditor auditor = new Auditor();
    #endregion

    public static AccountTemplateServiceConfigSection Config
	{
        get
        {
			Configuration config = LoadConfigurationFile(@"AccountTemplateService\AccountTemplateServiceConfig.xml");
			AccountTemplateServiceConfigSection section = config.GetSection("AccountTemplateService") as AccountTemplateServiceConfigSection;
			if (section == null) 
			{ 
				throw new ConfigurationErrorsException(@"Section AccountTemplateService was not found in configuration file AccountTemplateService\AccountTemplateServiceConfig.xml");
			}
			return section;
        }
    }

	static AccountTemplateService()
	{
		m_ConfigSection = Config;

      CMASServiceBase.ServiceStarting += new ServiceStartingEventHandler(AccountTemplateService_ServiceStarting);
      CMASServiceBase.ServiceStarted += new ServiceStartedEventHandler(AccountTemplateService_ServiceStarted);
      CMASServiceBase.ServiceStopped += new ServiceStoppedEventHandler(AccountTemplateService_ServiceStopped);
    }

    #region IAccountTemplateService Members
    public void GetTemplatesForOwner(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        ref List<AccountTemplateDef> templateDefs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetTemplatesForOwner"))
      {
        try
        {
          MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC = null;
          int templateAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);

          templateYAAC = new MTYAACClass();
          templateYAAC.InitAsSecuredResource(templateAcctId, (YAAC.IMTSessionContext)GetSessionContext(), MetraTime.Now);

          if (templateDefs == null)
          {
            templateDefs = new List<AccountTemplateDef>();
          }

          YAAC.IMTSQLRowset rs = templateYAAC.GetTemplatesAsRowset(MetraTime.Now);
          if (rs.RecordCount != 0)
          {
            rs.MoveFirst();

            while (!Convert.ToBoolean(rs.EOF))
            {
              if ((int)rs.get_Value("templateFolderID") == templateAcctId)
              {
                AccountTemplateDef templateDef = new AccountTemplateDef();
                templateDef.AccountType = (string)rs.get_Value("accountTypeName");
                templateDef.CreationDate = (DateTime)rs.get_Value("templateDateCreated");
                templateDef.TemplateName = (string)rs.get_Value("templateName");
                if (rs.get_Value("templateDesc") != null)
                {
                  templateDef.TemplateDescription = (string)rs.get_Value("templateDesc");
                }
                templateDef.TemplateId = (int)rs.get_Value("templateID");

                templateDefs.Add(templateDef);
              }

              rs.MoveNext();
            }
          }
        }
        catch (Common.MASBasicException mas)
        {

          m_Logger.LogException("MAS Exception caught loading account template definitions for owner", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught loading account template definitions for owner", comE);

          Common.MASBasicException mas = new Common.MASBasicException("Error loading account templates");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception loading account template definitions for owner", e);

          throw new Common.MASBasicException("Failed to load account template definitions for owner");
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void GetTemplateDefForAccountType(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        bool inheritAnscestorProperties,
        out AccountTemplate template)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetTemplateDefForAccountType"))
      {
        MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC = null;
        MetraTech.Interop.IMTAccountType.IMTAccountType accType = null;

        template = null;

        try
        {
          int templateAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);

          ValidateAccountTemplateInfo(templateAcctId, accountType, effectiveDate, out templateYAAC, out accType);

          template = LoadTemplateDataInternal(templateAcctId, accType, effectiveDate, inheritAnscestorProperties, GetSessionContext(), true);

          template.AccountType = accountType;
        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught loading account template def", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught loading account template def", comE);

          Common.MASBasicException mas = new Common.MASBasicException("Error loading account template");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception loading account template def", e);

          throw new Common.MASBasicException("Failed to load account template definition");
        }
      }
    }

    public void GetEligiblePOsForAccountType(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        ref Common.MTList<ProductOffering> productOfferings)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetEligiblePOsForAccountType"))
      {
        IMTYAAC templateYAAC = null;
        MetraTech.Interop.IMTAccountType.IMTAccountType accType = null;

        try
        {

          //Check ProdOff_AllowAccountPOCurrencyMismatch business rule and set currencyfilter parameter values accordingly
          string strCURRENCYFILTER1 = "";
          string strCURRENCYFILTER4 = "";

          MTProductCatalog pc1 = new MTProductCatalog();
          //   if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch))
          if (pc1.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch))
          {
            strCURRENCYFILTER1 = " 1=1 ";
            strCURRENCYFILTER4 = " 1=1 ";
          }
          else
          {
            strCURRENCYFILTER1 = " pl1.nm_currency_code = tav.c_currency ";
            strCURRENCYFILTER4 = " tmp.PayerCurrency = tpl.nm_currency_code ";
          }

          int templateAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);

          ValidateAccountTemplateInfo(templateAcctId, accountType, effectiveDate, out templateYAAC, out accType);

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\AccHierarchies", "__FIND_AVAILABLE_POS_FOR_TEMPLATE_V2__"))
            {

              stmt.AddParam("%%REFDATE%%", effectiveDate, true);
              stmt.AddParam("%%ID_LANG%%", GetSessionContext().LanguageID);
              stmt.AddParam("%%FOLDERACCOUNT%%", templateAcctId);
              stmt.AddParam("%%ACCOUNT_TYPE%%", accType.ID);
              stmt.AddParam("%%CORPORATEACCOUNT%%", templateYAAC.CorporateAccountID);
              stmt.AddParam("%%CURRENCYFILTER1%%", strCURRENCYFILTER1);
              stmt.AddParam("%%CURRENCYFILTER4%%", strCURRENCYFILTER4);

              ApplyFilterSortCriteria<ProductOffering>(stmt, productOfferings, new FilterColumnResolver(GetColumnNameFromProductOfferingPropertyname), null);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                ProductOffering prod;
                while (rdr.Read())
                {
                  prod = PopulateProductOffering(rdr);

                  productOfferings.Items.Add(prod);
                }

                productOfferings.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught loading product offerings for template", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught loading product offerings for account template", comE);

          Common.MASBasicException mas = new Common.MASBasicException("Error loading product offerings for account template");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting eligible product offerings in GetEligiblePOsForAccountType", e);

          productOfferings.Items.Clear();

          throw new Common.MASBasicException("Failed to retrieve product offerings");
        }
      }
    }

    public void GetEligibleGroupSubsForAccountType(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        ref Common.MTList<GroupSubscription> groupSubs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetEligibleGroupSubsForAccountType"))
      {
        MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC = null;
        MetraTech.Interop.IMTAccountType.IMTAccountType accType = null;

        try
        {
          int templateAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);

          ValidateAccountTemplateInfo(templateAcctId, accountType, effectiveDate, out templateYAAC, out accType);

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\AccHierarchies", "__FIND_AVAILABLE_GROUPSUBS_FOR_TEMPLATE_V2__"))
            {

              stmt.AddParam("%%REFDATE%%", effectiveDate, true);
              stmt.AddParam("%%ID_ACC%%", templateAcctId);
              stmt.AddParam("%%ACCOUNT_TYPE%%", accType.ID);

              // Check cross corporate business rule
              MTProductCatalog pc = new MTProductCatalog();
              if (pc.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations))
              {
                stmt.AddParam("%%CORPORATEACCOUNT%%", templateYAAC.CorporateAccountID);
              }
              else
              {
                stmt.AddParam("%%CORPORATEACCOUNT%%", RootAccountId);
              }

              ApplyFilterSortCriteria<GroupSubscription>(stmt, groupSubs, new FilterColumnResolver(GetColumnNameFromGroupSubscriptionPropertyname), null);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                GroupSubscription gSub;
                while (rdr.Read())
                {
                  gSub = PopulateGroupSubscription(rdr);

                  groupSubs.Items.Add(gSub);
                }

                groupSubs.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught loading group subscriptions for template", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught loading group subscriptions for account template", comE);

          Common.MASBasicException mas = new Common.MASBasicException("Error loading group subscriptions for account template");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting eligible group subscriptions in GetEligibleGroupSubsForAccountType", e);

          groupSubs.Items.Clear();

          throw new Common.MASBasicException("Failed to retrieve group subscriptions");
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void SaveAccountTemplate(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate,
        ref AccountTemplate template)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveAccountTemplate"))
      {
        MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC = null;
        MetraTech.Interop.IMTAccountType.IMTAccountType accType = null;

        int templateAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);

        try
        {

          ValidateAccountTemplateInfo(templateAcctId, accountType, effectiveDate, out templateYAAC, out accType);

          try
          {
            // CORE-1391: Test to make sure that properties in template are all of the correct type
            Account testAcct = Account.CreateAccount(accountType);
            template.ApplyTemplatePropsToAccount(testAcct);
              var validationErrors = new List<String>();
            var usageCycleType = ((InternalView)testAcct.GetInternalView()).UsageCycleType;
              if (usageCycleType.HasValue)
              {
                  if (!AccountValidator.ValidateUsageCycle(testAcct, validationErrors))
                  {
                      StringBuilder error = new StringBuilder();
                      foreach (string errorString in validationErrors)
                          error.Append(errorString).Append(". ");
                      throw new ApplicationException(error.ToString());
                  }
              }
          }
          catch (ApplicationException e)
          {
            MASBasicException masE = new MASBasicException("Invalid account property specified in template");
            masE.AddErrorMessage(e.Message);

            if (e.InnerException != null)
            {
              masE.AddErrorMessage(e.InnerException.Message);
            }

            throw masE;
          }

          // Try to get the existing template if it exists
          MTAccountTemplate mtTemplate = (YAAC.MTAccountTemplate)templateYAAC.GetAccountTemplate(effectiveDate, accType.ID);

          // If IDs match or if retrieved ID is -1 (not in DB), then go ahead and save
          if ((!template.IsIDDirty || mtTemplate.ID == template.ID) || mtTemplate.ID == -1)
          {
            if (template.IsAccountIDDirty)
            {
              mtTemplate.AccountID = template.AccountID;
            }
            else
            {
              mtTemplate.AccountID = templateAcctId;
            }

            if (template.IsApplyDefaultSecurityPolicyDirty)
            {
              mtTemplate.ApplyDefaultSecurityPolicy = template.ApplyDefaultSecurityPolicy;
            }

            if (template.IsCreateDtDirty)
            {
              mtTemplate.DateCrt = template.CreateDt;
            }

            if (template.IsDescriptionDirty)
            {
              mtTemplate.Description = template.Description;
            }

            if (template.IsNameDirty)
            {
              mtTemplate.Name = template.Name;
            }

            if (template.Properties != null)
            {
              mtTemplate.Properties.Clear();

              foreach (KeyValuePair<string, object> kvp in template.Properties)
              {
                MetraTech.Interop.MTYAAC.PropValType propType;
                string val = ConvertTemplatePropertyValue(kvp.Value, out propType);
                            if (val != string.Empty)
                            {
                                mtTemplate.Properties.Add(kvp.Key, val, propType);
                            }
                }
            }

            if (template.Subscriptions != null)
            {
              mtTemplate.Subscriptions.Clear();

              foreach (AccountTemplateSubscription templateSub in template.Subscriptions)
              {
                MetraTech.Interop.MTYAAC.IMTAccountTemplateSubscription sub = new MTAccountTemplateSubscriptionClass();

                if (templateSub.ProductOfferingId.HasValue)
                {
                  sub.ProductOfferingID = templateSub.ProductOfferingId.Value;
                }

                if (templateSub.GroupID.HasValue)
                {
                  sub.GroupID = templateSub.GroupID.Value;
                  sub.GroupSubName = templateSub.GroupSubName;
                }

                sub.StartDate = templateSub.StartDate;
                sub.EndDate = templateSub.EndDate;

                mtTemplate.Subscriptions.Add(sub);
              }
            }

            mtTemplate.Save(effectiveDate);

                        auditor.FireEvent(
                            (int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_SAVE_SUCCESS, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
String.Format("Saved account template {0} for account {1} successfully",
"'" + accType.Name + "'", templateAcctId.ToString()));
          }
          else
          {

                        auditor.FireFailureEvent(
                            (int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_SAVE_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
 String.Format("Error saving account template {0} for account {1}",
 "'" + accType.Name.ToString() + "'", templateAcctId.ToString()));
            throw new Common.MASBasicException("The specified account template ID does not match the ID for the existing template");
          }
        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught saving account template", mas);

                    auditor.FireFailureEvent(
                        (int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_SAVE_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
   String.Format("Error saving account template {0} for account {1}",
   "'" + accType.Name.ToString() + "'", templateAcctId.ToString()));

                    throw;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught saving account template", comE);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_SAVE_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
   String.Format("Error saving account template {0} for account {1}",
   "'" + accType.Name.ToString() + "'", templateAcctId.ToString()));

          Common.MASBasicException mas = new Common.MASBasicException("Error saving account template");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception saving account template", e);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_SAVE_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
 String.Format("Error saving account template {0} for account {1}",
 "'" + accType.Name.ToString() + "'", templateAcctId.ToString()));

          throw new Common.MASBasicException("Failed to save account template");
        }
      }
    }

    public void DeleteAccountTemplate(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        DateTime effectiveDate)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteAccountTemplate"))
      {
        MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC = null;
        MetraTech.Interop.IMTAccountType.IMTAccountType accType = null;
        int templateAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);

        try
        {

          ValidateAccountTemplateInfo(templateAcctId, accountType, effectiveDate, out templateYAAC, out accType);

          templateYAAC.DeleteTemplate(accType.ID);

          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_DELETE_SUCCESS, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
    String.Format("Deleted the account template {0} from account {1} successfully",
    "'" + accType.Name + "'", templateAcctId.ToString()));

        }
        catch (Common.MASBasicException mas)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_DELETE_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
     String.Format("Error deleting account template {0} from account {1}",
     "'" + accType.Name.ToString() + "'", templateAcctId.ToString()));
          m_Logger.LogException("MAS Exception caught deleting account template", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught deleting account template", comE);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_DELETE_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
     String.Format("Error deleting account template {0} from account {1}",
     "'" + accType.Name.ToString() + "'", templateAcctId.ToString()));
          Common.MASBasicException mas = new Common.MASBasicException("Error deleting account template");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception deleting account template", e);
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_DELETE_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, templateAcctId,
   String.Format("Error deleting account template {0} from account {1}",
   "'" + accType.Name.ToString() + "'", templateAcctId.ToString()));
          throw new Common.MASBasicException("Failed to delete account template");
        }
      }
    }

    public void ApplyAccountTemplate(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        AccountTemplateScope templateScope,
        DateTime effectiveDate,
        List<string> propNames,
        List<AccountTemplateSubscription> subscriptions,
        BaseTypes.ProdCatTimeSpan subscriptionDates,
        bool endConflictingSubscriptions,
        out int sessionId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApplyAccountTemplate"))
      {

        int ownerId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);
        try
        {
          sessionId = -1;


          m_Logger.LogInfo("Applying template to {0} for descendents of {1}", accountType, ownerId);

          ValidateTemplateExists(templateOwner, accountType);

          m_Logger.LogDebug("Template exists for account type {0} for descendents of {1}", accountType, ownerId);

          #region Load descendent accounts
          MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC = new MTYAACClass();
          templateYAAC.InitAsSecuredResource(ownerId, (YAAC.IMTSessionContext)GetSessionContext(), effectiveDate);

          YAAC.IMTCollection accountCol = (YAAC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();
          YAAC.IMTCollection accountTypeCol = (YAAC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();
          YAAC.MTHierarchyPathWildCard wildCard = ((YAAC.MTHierarchyPathWildCard)((int)templateScope));

          accountTypeCol.Add(accountType);

          templateYAAC.GetDescendents(accountCol, effectiveDate, wildCard, true, accountTypeCol);

          List<MetraTech.ActivityServices.Common.AccountIdentifier> accIds = new List<MetraTech.ActivityServices.Common.AccountIdentifier>();

          foreach (int accId in accountCol)
          {
            accIds.Add(new MetraTech.ActivityServices.Common.AccountIdentifier(accId));
          }
          #endregion

          InternalApplyTemplateToAccounts(
             ownerId,
             accountType,
             accIds,
             effectiveDate,
             subscriptions,
             subscriptionDates,
             endConflictingSubscriptions,
              out sessionId);

          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_SUCCESS, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
  String.Format("Applied the account template {0} to account {1} successfully",
  "'" + accountType + "'", ownerId.ToString()));


        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught applying account template", mas);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
  String.Format("Error while applying the account template {0} to account {1}", "'" + accountType + "'", ownerId.ToString()));

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught applying account template", comE);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
  String.Format("Error while applying the account template {0} to account {1}", "'" + accountType + "'", ownerId.ToString()));

          Common.MASBasicException mas = new Common.MASBasicException("Error applying account template");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception applying account template", e);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
   String.Format("Error while applying the account template {0} to account {1}", "'" + accountType + "'", ownerId.ToString()));

          throw new Common.MASBasicException("Unknown error applying account template");
        }
      }
    }

    public void ApplyTemplateToAccounts(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType,
        List<MetraTech.ActivityServices.Common.AccountIdentifier> accountIds,
        DateTime effectiveDate,
        List<string> propNames,
        List<AccountTemplateSubscription> subscriptions,
        BaseTypes.ProdCatTimeSpan subscriptionDates,
        bool endConflictingSubscriptions,
        out int sessionId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApplyTemplateToAccounts"))
      {

        int ownerId = AccountIdentifierResolver.ResolveAccountIdentifier(templateOwner);
        try
        {
          sessionId = -1;

          m_Logger.LogInfo("Applying template to {0} for specific descendents of {1}", accountType, ownerId);

          ValidateTemplateExists(templateOwner, accountType);

          m_Logger.LogDebug("Template exists for account type {0} for specific descendents of {1}", accountType, ownerId);

          InternalApplyTemplateToAccounts(
              ownerId,
              accountType,
              accountIds,
              effectiveDate,
              subscriptions,
              subscriptionDates,
              endConflictingSubscriptions,
              out sessionId);

          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_SUCCESS, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
String.Format("Applied the account template {0} to specific descendants of account {1} successfully",
"'" + accountType + "'", ownerId.ToString()));


        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught applying account template to accounts", mas);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
String.Format("Error while applying the account template {0} to specific descendants of account {1}", "'" + accountType + "'", ownerId.ToString()));

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught applying account template to accounts", comE);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
String.Format("Error while applying the account template {0} to specific descendants of account {1}", "'" + accountType + "'", ownerId.ToString()));

          Common.MASBasicException mas = new Common.MASBasicException("Error applying account template to accounts");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception applying account template to accounts", e);

          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_TEMPLATE_APPLY_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, ownerId,
String.Format("Error while applying the account template {0} to specific descendants of account {1}", "'" + accountType + "'", ownerId.ToString()));

          throw new Common.MASBasicException("Unknown error applying account template to accounts");
        }
      }
    }

    public void GetAccountTemplateSessions(ref Common.MTList<AccountTemplateSession> sessions)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountTemplateSessions"))
      {
        try
        {
          m_Logger.LogInfo("Loading account template sessions");

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(@"Queries\AccHierarchies", "__LOAD_TEMPLATE_SESSIONS__"))
            {
              ApplyFilterSortCriteria<AccountTemplateSession>(stmt, sessions);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  AccountTemplateSession session = new AccountTemplateSession();
                  session.SessionId = rdr.GetInt32("SessionId");
                  session.TemplateOwnerId = rdr.GetInt32("TemplateOwnerId");
                  session.TemplateOwnerName = rdr.GetString("TemplateOwnerName");
                  session.AccountType = rdr.GetString("AccountType");
                  session.SubmissionDate = rdr.GetDateTime("SubmissionDate");
                  session.SubmitterID = rdr.GetInt32("SubmitterId");
                  session.SubmitterName = rdr.GetString("SubmitterName");
                  session.ServerName = rdr.GetString("ServerName");
                  session.Status = (TemplateStatus)EnumHelper.GetCSharpEnum(rdr.GetInt32("Status"));
                  session.NumAccounts = rdr.GetInt32("NumAccounts");
                  session.NumAccountsCompleted = rdr.GetInt32("NumAccountsCompleted");
                  session.NumAccountErrors = rdr.GetInt32("NumAccountErrors");
                  session.NumSubscriptions = rdr.GetInt32("NumSubscriptions");
                  session.NumSubscriptionsCompleted = rdr.GetInt32("NumSubscriptionsCompleted");
                  session.NumSubscriptionErrors = rdr.GetInt32("NumSubscriptionErrors");
                  session.NumRetries = System.Convert.ToInt32(rdr.GetValue("NumRetries"));

                  sessions.Items.Add(session);
                }

                sessions.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught getting account template sessions", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught getting account template sessions", comE);

          Common.MASBasicException mas = new Common.MASBasicException("Error getting account template sessions");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting account template sessions", e);

          throw new Common.MASBasicException("Unknown error getting account template sessions");
        }
      }
    }

    public void GetTemplateSessionDetails(int sessionId, ref Common.MTList<AccountTemplateSessionDetail> details)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetTemplateSessionDetails"))
      {
        try
        {
          m_Logger.LogInfo("Loading account template session details for session {0}", sessionId);

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(@"Queries\AccHierarchies", "__LOAD_TEMPLATE_SESSION_DETAILS__"))
            {
              ApplyFilterSortCriteria<AccountTemplateSessionDetail>(stmt, details);

              stmt.AddParam("%%SESSION_ID%%", sessionId);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  AccountTemplateSessionDetail detail = new AccountTemplateSessionDetail();
                  detail.DetailId = rdr.GetInt32("DetailId");
                  detail.SequenceId = rdr.GetInt32("SequenceId");
                  detail.SessionId = rdr.GetInt32("SessionId");
                  detail.Type = (DetailType)EnumHelper.GetCSharpEnum(rdr.GetInt32("Type"));
                  detail.Result = (DetailResult)EnumHelper.GetCSharpEnum(rdr.GetInt32("Result"));
                  detail.DetailDate = rdr.GetDateTime("DetailDate");
                  detail.Detail = rdr.GetString("Detail");
                  detail.NumRetries = System.Convert.ToInt32(rdr.GetValue("NumRetries"));

                  details.Items.Add(detail);
                }

                details.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (Common.MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught getting account template session details", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught getting account template session details", comE);

          Common.MASBasicException mas = new Common.MASBasicException("Error getting account template session details");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting account template session details", e);

          throw new Common.MASBasicException("Unknown error getting account template session details");
        }
      }
    }
    #endregion

    #region Private Methods

        private AccountTemplate LoadTemplateDataInternal(
          int templateOwner,
          MetraTech.Interop.IMTAccountType.IMTAccountType accType,
          DateTime effectiveDate,
          bool inheritAnscestorProperties,
          MTAuth.IMTSessionContext sessionContext,
          bool pulicTemplate)
    {
      AccountTemplate template = new AccountTemplate();
      template.ID = -1;
      template.AccountID = templateOwner;
      int loadedTemplateId = -1;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\AccHierarchies", "__LOAD_ACC_TEMPLATE__"))
        {
          #region Load Code Template Members
          stmt.AddParam("%%ACCOUNTID%%", templateOwner);
          stmt.AddParam("%%ACCOUNTTYPEID%%", accType.ID);
          stmt.AddParam("%%REFDATE%%", effectiveDate);

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            if (rdr.Read())
            {
              int folderId = rdr.GetInt32("id_folder");

              loadedTemplateId = rdr.GetInt32("id_acc_template");

              if (folderId == templateOwner)
              {
                // Only load these if the loaded template is declared for the template owner, otherwise use -1 for template ID
                template.ID = loadedTemplateId;
                template.CreateDt = rdr.GetDateTime("dt_crt");
              }

              // Only load these if template ID is > 0 (which means it is defined at template owner 
              // or if the inheritAncestorProperties paramter is set to true
              if (template.ID > 0 || inheritAnscestorProperties)
              {
                if (!rdr.IsDBNull("tx_name"))
                {
                  template.Name = rdr.GetString("tx_name");
                }
                if (!rdr.IsDBNull("tx_desc"))
                {
                  template.Description = rdr.GetString("tx_desc");
                }
                template.ApplyDefaultSecurityPolicy = rdr.GetBoolean("b_ApplyDefaultPolicy");
              }
            }
          }
          #endregion
        }
        // Only load properties and subscriptions if template ID is > 0 or if
        // inheritAncestorProperties is set to true
        if (template.ID > 0 || inheritAnscestorProperties)
        {
          #region Load Template Properties
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
              @"Queries\AccHierarchies",
					    pulicTemplate ? @"__LOAD_TEMPLATE_PROPERTIES_PUB__" : @"__LOAD_TEMPLATE_PROPERTIES__"))
          {
            stmt.AddParam("%%TEMPLATEID%%", loadedTemplateId);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                string name = rdr.GetString("nm_prop");
                template.Properties.Add(
                    name,
                    GetTemplatePropertyValue(
                        name,
                        long.Parse(rdr.GetString("nm_prop_class")),
                        rdr.GetString("nm_value")));
              }
            }
          }
          #endregion

          #region Load Template Subscriptions
					using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
					@"Queries\AccHierarchies",
					pulicTemplate ?  @"__LOAD_TEMPLATE_SUBSCRIPTIONS_PUB__" : @"__LOAD_TEMPLATE_SUBSCRIPTIONS__"))
          {
            stmt.AddParam("%%TEMPLATEID%%", loadedTemplateId);
            stmt.AddParam("%%ID_LANG%%", sessionContext.LanguageID);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                AccountTemplateSubscription atSub = new AccountTemplateSubscription();

                if (!rdr.IsDBNull("ID_PO"))
                {
                  atSub.ProductOfferingId = rdr.GetInt32("ID_PO");
                }
                else
                {
                  atSub.GroupID = rdr.GetInt32("ID_GROUP");
                }

                if (!rdr.IsDBNull("NM_GROUPSUBNAME"))
                {
                  atSub.GroupSubName = rdr.GetString("NM_GROUPSUBNAME");
                }

                if (!rdr.IsDBNull("VT_START"))
                {
                  atSub.StartDate = rdr.GetDateTime("VT_START");
                }

                if (!rdr.IsDBNull("VT_END"))
                {
                  atSub.EndDate = rdr.GetDateTime("VT_END");
                }

                atSub.PODisplayName = rdr.GetString("PODisplayName");

                template.Subscriptions.Add(atSub);
              }
            }
          }
          #endregion
        }
      }

      return template;
    }

    private string GetColumnNameFromProductOfferingPropertyname(string propName, ref object filterVal, object helper)
    {
      switch (propName)
      {
        case "ProductOfferingId":
          return "id_prop";
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

        case "CanUserSubscribe":
          return "b_user_subscribe";
          break;

        case "CanUserUnsubscribe":
          return "b_user_unsubscribe";
          break;

        default:
          throw new Common.MASBasicException("Specified field not not valid for filtering or sorting");
          break;
      };
    }

    private ProductOffering PopulateProductOffering(IMTDataReader rdr)
    {
      ProductOffering po = new ProductOffering();

      string fieldName;
      for (int i = 0; i < rdr.FieldCount; i++)
      {
        fieldName = rdr.GetName(i);

        if (!rdr.IsDBNull(i))
        {
          switch (fieldName)
          {
            case "id_prop":
              po.ProductOfferingId = rdr.GetInt32(i);
              break;

            case "nm_name":
              po.Name = rdr.GetString(i);
              break;

            case "nm_desc":
              po.Description = rdr.GetString(i);
              break;

            case "nm_display_name":
              po.DisplayName = rdr.GetString(i);
              break;

            case "b_user_subscribe":
              po.CanUserSubscribe = rdr.GetBoolean(i);
              break;

            case "b_user_unsubscribe":
              po.CanUserUnsubscribe = rdr.GetBoolean(i);
              break;

            #region Ignored Columns
            case "n_name":
            case "n_desc":
            case "n_display_name":
            case "Available_StartDate":
              break;
            #endregion
          };
        }
      }

      ProdCatTimeSpan availableDate = GetEffectiveDate(rdr, "Available");

      po.AvailableTimeSpan.TimeSpanId = availableDate.TimeSpanId.Value;
      po.AvailableTimeSpan.StartDateOffset = availableDate.StartDateOffset;
      po.AvailableTimeSpan.StartDateType = availableDate.StartDateType;
      po.AvailableTimeSpan.EndDateOffset = availableDate.EndDateOffset;
      po.AvailableTimeSpan.EndDateType = availableDate.EndDateType;
      po.AvailableTimeSpan.StartDate = availableDate.StartDate;
      po.AvailableTimeSpan.EndDate = availableDate.EndDate;

      return po;
    }
        
    private object GetTemplatePropertyValue(string name, long templateType, string templateValue)
    {
      YAAC.PropValType propType = (YAAC.PropValType)templateType;
      switch (propType)
      {
        case YAAC.PropValType.PROP_TYPE_ASCII_STRING:
        case YAAC.PropValType.PROP_TYPE_STRING:
        case YAAC.PropValType.PROP_TYPE_UNICODE_STRING:
          return templateValue;
          break;

        case YAAC.PropValType.PROP_TYPE_BIGINTEGER:
          return long.Parse(templateValue);
          break;

        case YAAC.PropValType.PROP_TYPE_INTEGER:
          return Int32.Parse(templateValue);
          break;

        case YAAC.PropValType.PROP_TYPE_BOOLEAN:
          return bool.Parse(templateValue);
          break;

        case YAAC.PropValType.PROP_TYPE_DATETIME:
          return DateTime.Parse(templateValue);
          break;

        case YAAC.PropValType.PROP_TYPE_TIME:
          return TimeSpan.Parse(templateValue);
          break;

        case YAAC.PropValType.PROP_TYPE_DECIMAL:
          return decimal.Parse(templateValue);
          break;

        case YAAC.PropValType.PROP_TYPE_DOUBLE:
          return double.Parse(templateValue);
          break;

        case YAAC.PropValType.PROP_TYPE_ENUM:
          return EnumHelper.GetCSharpEnum(Int32.Parse(templateValue));
          break;

        case YAAC.PropValType.PROP_TYPE_UNKNOWN:
          return null;

        default:
          throw new Common.MASBasicException("Unknown account template property type for property: " + name);

      };

      return null;
    }

    private string ConvertTemplatePropertyValue(object propVal, out MetraTech.Interop.MTYAAC.PropValType propType)
    {
      string valStr = "";
      if (propVal == null)
      {
        propType = YAAC.PropValType.PROP_TYPE_UNKNOWN;
        return valStr;
      }

      if (propVal.GetType() == typeof(string))
      {
        valStr = ((string)propVal);
        propType = YAAC.PropValType.PROP_TYPE_STRING;
      }
      else if (propVal.GetType() == typeof(long))
      {
        valStr = ((long)propVal).ToString();
        propType = YAAC.PropValType.PROP_TYPE_BIGINTEGER;
      }
      else if (propVal.GetType() == typeof(int) ||
              propVal.GetType() == typeof(Int32))
      {
        valStr = ((int)propVal).ToString();
        propType = YAAC.PropValType.PROP_TYPE_INTEGER;
      }
      else if (propVal.GetType() == typeof(decimal) ||
              propVal.GetType() == typeof(Decimal))
      {
        valStr = ((decimal)propVal).ToString();
        propType = YAAC.PropValType.PROP_TYPE_DECIMAL;
      }
      else if (propVal.GetType() == typeof(double) ||
              propVal.GetType() == typeof(double))
      {
        valStr = ((double)propVal).ToString();
        propType = YAAC.PropValType.PROP_TYPE_DOUBLE;
      }
      else if (propVal.GetType() == typeof(DateTime))
      {
        valStr = ((DateTime)propVal).ToString();
        propType = YAAC.PropValType.PROP_TYPE_DATETIME;
      }
      else if (propVal.GetType() == typeof(TimeSpan))
      {
        valStr = ((TimeSpan)propVal).ToString();
        propType = YAAC.PropValType.PROP_TYPE_TIME;
      }
      else if (propVal.GetType() == typeof(bool))
      {
        valStr = ((bool)propVal).ToString();
        propType = YAAC.PropValType.PROP_TYPE_BOOLEAN;
      }
      else if (propVal.GetType().IsSubclassOf(typeof(Enum)))
      {
        propType = YAAC.PropValType.PROP_TYPE_ENUM;
        valStr = EnumHelper.GetDbValueByEnum(propVal).ToString();
      }
      else
      {
        throw new Common.MASBasicException("Unsupported template property type: " + propVal.ToString());
      }

      return valStr;
    }

    private void GetYaacAndAccountType(
        int templateOwner,
        string accountType,
        DateTime effectiveDate,
        YAAC.IMTSessionContext sessionContext,
        out MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC,
        out MetraTech.Interop.IMTAccountType.IMTAccountType accType)
    {
      templateYAAC = new MTYAACClass();
      templateYAAC.InitAsSecuredResource(templateOwner, sessionContext, effectiveDate);

      AccountTypeCollection accountTypeCol = new AccountTypeCollection();
      accType = accountTypeCol.GetAccountType(accountType);

      if (accType == null)
      {
        throw new Common.MASBasicException("Invalid account type specified");
      }
    }

    private void ValidateAccountTemplateInfo(
        int templateAcctId,
        string accountType,
        DateTime effectiveDate,
        out MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC,
        out MetraTech.Interop.IMTAccountType.IMTAccountType accType)
    {
      if (templateAcctId <= 1)
      {
        throw new MASBasicException("Templates cannot be defined for the hierarchy root");
      }

      GetYaacAndAccountType(
          templateAcctId,
          accountType,
          effectiveDate,
          (YAAC.IMTSessionContext)GetSessionContext(),
          out templateYAAC,
          out accType);

      AccountType acctType = new AccountType();
      acctType.InitializeByID(templateYAAC.AccountTypeID);

      if (!acctType.CanHaveTemplates)
      {
        throw new Common.MASBasicException("The account type for the specified account can not have templates");
      }

      if (accountType.ToLower() != templateYAAC.AccountType.ToLower()) // let account types that are the same go through for the current node case
      {
        YAAC.IMTSQLRowset rs = (YAAC.IMTSQLRowset)acctType.GetAllDescendentAccountTypesAsRowset();
        YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
        filter.Add("DescendentTypeName", YAAC.MTOperatorType.OPERATOR_TYPE_EQUAL, accountType);

        rs.Filter = filter;

        if (rs.RecordCount == 0)
        {
          throw new Common.MASBasicException(
            "The specified account type is not a valid descendent account type for the specified account");
        }
      }
    }

    private string GetColumnNameFromGroupSubscriptionPropertyname(string propName, ref object filterVal, object helper)
    {
      switch (propName)
      {
        case "SubscriptionId":
          return "id_sub";
          break;

        case "GroupId":
          return "id_group";
          break;

        case "Name":
          return "tx_name";
          break;

        case "ProductOfferingId":
        case "ProductOffering.ProductOfferingId":
          return "id_po";
          break;

        case "Description":
          return "tx_desc";
          break;

        case "CorporateAccountId":
          return "corporate_account";
          break;

        case "DiscountAccountId":
          return "discount_account";
          break;

        case "SubscriptionSpan.StartDate":
          return "vt_start";
          break;

        case "SubscriptionSpan.EndDate":
          return "vt_end";
          break;

        case "SupportsGroupOperations":
          return "b_supportgroupops";
          break;

        case "Proportional":
          return "b_proportional";
          break;

        case "UsageCycleId":
          return "usage_cycle";
          break;

        default:
          throw new Common.MASBasicException("Specified field not not valid for filtering or sorting");
          break;
      };
    }

    private GroupSubscription PopulateGroupSubscription(IMTDataReader rdr)
    {
      GroupSubscription gsub = new GroupSubscription();
      ProductOffering po = new ProductOffering();
      gsub.ProductOffering = po;

      string fieldName;
      for (int i = 0; i < rdr.FieldCount; i++)
      {
        fieldName = rdr.GetName(i);

        if (!rdr.IsDBNull(i))
        {
          switch (fieldName)
          {
            case "id_sub":
              gsub.SubscriptionId = rdr.GetInt32(i);
              break;

            case "id_group":
              gsub.GroupId = rdr.GetInt32(i);
              break;

            case "id_po":
              gsub.ProductOfferingId = rdr.GetInt32(i);
              gsub.ProductOffering.ProductOfferingId = gsub.ProductOfferingId;
              break;

            case "vt_start":
              gsub.SubscriptionSpan.StartDate = rdr.GetDateTime(i);
              break;

            case "vt_end":
              gsub.SubscriptionSpan.EndDate = rdr.GetDateTime(i);
              break;

            case "usage_cycle":
              gsub.UsageCycleId = rdr.GetInt32(i);
              break;

            case "b_visable":
              gsub.Visible = rdr.GetBoolean(i);
              break;

            case "tx_name":
              gsub.Name = rdr.GetString(i);
              break;

            case "tx_desc":
              gsub.Description = rdr.GetString(i);
              break;

            case "b_proportional":
              gsub.ProportionalDistribution = rdr.GetBoolean(i);
              break;

            case "b_supportgroupops":
              gsub.SupportsGroupOperations = rdr.GetBoolean(i);
              break;

            case "corporate_account":
              gsub.CorporateAccountId = rdr.GetInt32(i);
              break;

            case "discount_account":
              gsub.DiscountAccountId = rdr.GetInt32(i);
              break;
          };
        }
      }

      return gsub;
    }

    private void ValidateTemplateExists(
        MetraTech.ActivityServices.Common.AccountIdentifier templateOwner,
        string accountType)
    {
      List<AccountTemplateDef> defs = new List<AccountTemplateDef>();
      GetTemplatesForOwner(templateOwner, ref defs);

      bool found = false;
      foreach (AccountTemplateDef def in defs)
      {
        if (string.Compare(def.AccountType, accountType, true) == 0)
        {
          found = true;
          break;
        }
      }

      if (!found)
      {
        throw new Common.MASBasicException("Specified template owner does not have a template defined for the specified account type");
      }
    }

    private void InternalApplyTemplateToAccounts(
        int templateOwnerId,
        string accountType,
        List<MetraTech.ActivityServices.Common.AccountIdentifier> accountIds,
        DateTime effectiveDate,
        List<AccountTemplateSubscription> subscriptions,
        BaseTypes.ProdCatTimeSpan subscriptionDates,
        bool endConflictingSubscriptions,
        out int sessionId)
    {

      if (accountIds.Count == 0)
      {
        throw new MASBasicException("No accounts to apply template to!");
      }

      #region Validate Specified Accounts
      List<ValidatedAccount> loadedIds = new List<ValidatedAccount>();

      if (accountIds.Count > 0)
      {
        StringBuilder builder = new StringBuilder();

        for (int i = 0; i < accountIds.Count; i++)
        {
          builder.Append(GetWhereClause(accountIds[i]));

          if (((i + 1) % 1000 == 0) || (i == accountIds.Count - 1))
          {
            string whereClause = builder.ToString();

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\AccHierarchies", "__VALIDATE_TEMPLATE_ACCOUNTS__"))
              {

                stmt.AddParam("%%ACCOUNT_TYPE%%", accountType);
                stmt.AddParam("%%TEMPLATE_OWNER%%", templateOwnerId);
                stmt.AddParam("%%ACCOUNT_LIST%%", whereClause, true);
                stmt.AddParam("%%EFFECTIVE_DATE%%", effectiveDate);

                using (IMTDataReader rdr = stmt.ExecuteReader())
                {
                  while (rdr.Read())
                  {
                    ValidatedAccount acct = new ValidatedAccount();
                    acct.AccountId = rdr.GetInt32("accountId");
                    acct.AccountName = rdr.GetString("accountName");

                    loadedIds.Add(acct);
                  }
                }
              }
            }
            builder.Length = 0;
          }
          else builder.Append(" or ");
        }

        if (loadedIds.Count == accountIds.Count)
        {
          m_Logger.LogDebug("Specified accounts are valid descendents of the correct type");
        }
        else
        {
          throw new Common.MASBasicException("Not all specified accounts are descendents of the template owner, or they are not of the specified account type");
        }
      }
      else
      {
        throw new Common.MASBasicException("At least one account must be specified");
      }
      #endregion

      #region Load Template Def
      AccountTemplate template;

      MetraTech.Interop.MTYAAC.IMTYAAC templateYAAC;
      MetraTech.Interop.IMTAccountType.IMTAccountType accType;

      YAAC.IMTSessionContext sessionContext = (YAAC.IMTSessionContext)GetSessionContext();

      m_Logger.LogDebug("[{0}] Get YAAC and IMTAccountType instance", Thread.CurrentThread.ManagedThreadId);
      GetYaacAndAccountType(
          templateOwnerId,
          accountType,
          effectiveDate,
          sessionContext,
          out templateYAAC,
          out accType);

      m_Logger.LogDebug("[{0}] Load AccountTemplate instance", Thread.CurrentThread.ManagedThreadId);
            template = LoadTemplateDataInternal(templateOwnerId, accType, effectiveDate, false, (MTAuth.IMTSessionContext)sessionContext, false);

      if (template.ID == -1)
      {
        throw new MASBasicException("Invalid template specified");
      }
      #endregion

      sessionId = m_SessionIdGenerator.NextId;

      AccountTemplateRequest request = new AccountTemplateRequest();
      request.SessionId = sessionId;
      request.AccountIds = loadedIds;
      request.AccountType = accountType;
      request.EffectiveDate = effectiveDate;
      request.EndConflictingSubscriptions = endConflictingSubscriptions;
      request.SubscriptionDates = subscriptionDates;
      request.Subscriptions = subscriptions;
      request.TemplateOwnerId = templateOwnerId;

      request.SessionContext = (YAAC.IMTSessionContext)GetSessionContext();
      request.ClientUserName = ServiceSecurityContext.Current.PrimaryIdentity.Name;

      request.Template = template;
      if (request.PropNames == null)
      {
        request.PropNames = new List<string>();
        request.PropNames.AddRange(template.Properties.Keys);
      }

      if (request.Subscriptions == null)
      {
        request.Subscriptions = new List<AccountTemplateSubscription>();
        request.Subscriptions.AddRange(template.Subscriptions);
      }

      m_Logger.LogInfo("Creating new template session {0} to apply template to account type {1} to descendents of {2}", sessionId, accountType, templateOwnerId);

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\AccHierarchies", "__INSERT_TEMPLATE_SESSION__"))
        {
          stmt.AddParam("%%SESSION_ID%%", sessionId);
          stmt.AddParam("%%OWNER_ID%%", templateOwnerId);
          stmt.AddParam("%%ACCT_TYPE%%", accountType);
          stmt.AddParam("%%SUBMISSION_DATE%%", MetraTime.Now);
          stmt.AddParam("%%SUBMITTER_ID%%", GetSessionContext().AccountID);
          stmt.AddParam("%%HOST_NAME%%", System.Net.Dns.GetHostName());
          stmt.AddParam("%%STATUS%%", EnumHelper.GetDbValueByEnum(TemplateStatus.Submitted));
          stmt.AddParam("%%NUM_ACCTS%%", (request.PropNames.Count > 0 ? accountIds.Count : 0));
          stmt.AddParam("%%NUM_SUBS%%", request.Subscriptions.Count);

          m_Logger.LogInfo("Inserting template session {0} to apply template to account type {1} to descendents of {2}", sessionId, accountType, templateOwnerId);
          stmt.ExecuteNonQuery();

        }
      }

			List<Exception> errorList = new List<Exception>(1);
			//State array contain elements:
			//0: list of exceptions which was thrown while account template properties were applied.
			//1: template request - wraps other entities which needs for future applying template.
			var state = new object[] {errorList, request };

			ApplyAccountTemplateDelegate worker = new ApplyAccountTemplateDelegate(BackgroundApplyAccountTemplate);
			//Run applying template properties in background thread.
			worker.BeginInvoke(template.ID, sessionId, errorList, new AsyncCallback(BackgroundApplyAccountTemplateCallback), state);
		}

		private void BackgroundApplyAccountTemplate(int templateId, int sessionId, object additional)
		{
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				//Calling stored procedure which applying template properties.
				using (var stmt = conn.CreateCallableStatement("ApplyAccountTemplate"))
				{
					try
					{
						stmt.AddParam("accountTemplateId", MTParameterType.Integer, templateId);
						stmt.AddParam("sessionId", MTParameterType.Integer, sessionId);
						stmt.AddParam("systemDate", MTParameterType.DateTime, MetraTime.Now);

						stmt.ExecuteNonQuery();
					}
					catch (Exception exc)
					{
						string msg = string.Format("Error while applying template {0}. Session: {1}", templateId, sessionId);
						m_Logger.LogException(msg, exc);
						(additional as List<Exception>).Add(exc);
						throw;
					}
				}
			}
		}

		private void BackgroundApplyAccountTemplateCallback(IAsyncResult result)
		{
			StringBuilder sb = new StringBuilder();
			sb.Append("Applying properties of template to accounts is complete.");
			
			//State array contain elements:
			//0: list of exceptions which was thrown while account template properties were applied.
			//1: template request - wraps other entities which needs for future applying template.
			object[] stateArray = ((object[])result.AsyncState);

			var exceptionList = stateArray[0] as List<Exception>;

			if (exceptionList.Count == 0)
			{
				//Enqueue request for further applying process if process of applying properties was ended without errors.
				AccountTemplateRequest request = stateArray[1] as AccountTemplateRequest;
      m_RequestsQueue.Enqueue(request);
    }
			else
			{
				sb.AppendLine();
				sb.AppendFormat(" An exception was thrown: \"{0}\"", exceptionList[0].Message);
			}

			m_Logger.LogInfo(sb.ToString());
		}

    private static void AccountTemplateService_ServiceStarting()
    {
      m_Logger.LogInfo("AccountTemplateService - Service starting");
    }

    static void AccountTemplateService_ServiceStarted()
    {
      m_RequestsQueue = new MTRecoverableQueue<AccountTemplateRequest>(m_Logger, m_ConfigSection.ThreadPoolSize, ApplyTemplate, "AccountTemplates", true);
    }

    private static void AccountTemplateService_ServiceStopped()
    {
      m_Logger.LogInfo("AccountTemplateService - Service stopping");

      m_RequestsQueue.Stop();
    }

    private string GetWhereClause(MetraTech.ActivityServices.Common.AccountIdentifier accountIdentifier)
    {
      string retval = "";

      if (accountIdentifier.AccountID.HasValue)
      {
        retval = string.Format("am.id_acc = {0}", accountIdentifier.AccountID.Value);
      }
      else
      {
        retval = string.Format("(am.nm_login='{0}' and am.nm_space='{1}')", accountIdentifier.Username, accountIdentifier.Namespace);
      }

      return retval;
    }

    #endregion

    #region Template Application Methods

    private static void UpdateSessionStatus(int sessionid, TemplateStatus templateStatus)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\AccHierarchies", "__UPDATE_TEMPLATE_SESSION_STATUS__"))
        {
          stmt.AddParam("%%SESSION_ID%%", sessionid);
          stmt.AddParam("%%STATUS%%", EnumHelper.GetDbValueByEnum(templateStatus));

          stmt.ExecuteNonQuery();
        }
      }
    }

    private static bool ApplyTemplate(AccountTemplateRequest request, MTRecoverableQueue<AccountTemplateRequest>.HandlerArgs args)
    {

      bool bRequestProcessed = true;

      if (request != null)
      {
        m_Logger.LogDebug("[{0}] Queue {4} Received request to process session {1} for account type {2} at account {3}", Thread.CurrentThread.ManagedThreadId, request.SessionId, request.AccountType, request.TemplateOwnerId, args.QueueName);

        TemplateStatus status = TemplateStatus.In_Progress;

        try
        {
          UpdateSessionStatus(request.SessionId, status);

          DoApplyTemplate(request);

          status = TemplateStatus.Completed;
        }
        catch (System.ServiceModel.CommunicationException comEx)
        {
          status = TemplateStatus.Failed;
          m_Logger.LogException(String.Format("[{0}] Communication Exception applying template: Queue {4}, session {1}, account type {2}, account {3}", Thread.CurrentThread.ManagedThreadId, request.SessionId, request.AccountType, request.TemplateOwnerId, args.QueueName), comEx);
          bRequestProcessed = false;
        }
        catch (Exception e)
        {
          status = TemplateStatus.Failed;
          m_Logger.LogException(String.Format("[{0}] Exception applying template: Queue {4}, session {1}, account type {2}, account {3}", Thread.CurrentThread.ManagedThreadId, request.SessionId, request.AccountType, request.TemplateOwnerId, args.QueueName), e);
        }
        finally
        {
          UpdateSessionStatus(request.SessionId, status);
        }
      }

      return bRequestProcessed;
    }

    private static void DoApplyTemplate(AccountTemplateRequest request)
    {
      AccountTemplate template = request.Template;
      int nRetryCount = 0;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTMultiSelectAdapterStatement stmt = conn.CreateMultiSelectStatement(@"Queries\AccHierarchies", "__UPDATE_TEMPLATE_SESSION_RETRIES__"))
        {
          stmt.AddParam("%%SESSION_ID%%", request.SessionId);
          stmt.SetResultSetCount(1);
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            if (reader.Read())
            {
              if (reader.FieldCount == 0)
              {
                throw new MASBasicException("Unable to get template session retry count");
              }

              nRetryCount = System.Convert.ToInt32(reader.GetValue("NumRetries"));
            }
            else
            {
              throw new MASBasicException("__UPDATE_TEMPLATE_SESSION_RETRIES__ did not return a row");
            }
          }
        }
      }

			//FEAT-1730: this business logic was relocated to processing by the database.
			/*WriteSessionDetail(request.SessionId, DetailType.General, DetailResult.Information, "Starting application of template", nRetryCount);

      if (request.PropNames.Count > 0)
      {
        #region Update Accounts
        string updateAuditMsg = "Applying the following account property values: ";
        foreach (string propName in request.PropNames)
        {
          object value = template.Properties[propName];

          if (value != null && !value.GetType().IsSubclassOf(typeof(Enum)))
          {
            updateAuditMsg += string.Format("{0}:{1}\r\n", propName, value.ToString());
          }
          else if (value != null)
          {
            updateAuditMsg += string.Format("{0}:{1}\r\n", propName, EnumHelper.GetFQN(value));
          }
          else
          {
            updateAuditMsg += string.Format("{0}:NULL\r\n", propName);
          }
        }

        m_Logger.LogInfo("[{0}] {1}", Thread.CurrentThread.ManagedThreadId, updateAuditMsg);
        WriteSessionDetail(request.SessionId, DetailType.Update, DetailResult.Information, updateAuditMsg, nRetryCount);

        m_Logger.LogDebug("[{0}] Create account instance", Thread.CurrentThread.ManagedThreadId);
        BaseTypes.Account modifiedAccount = BaseTypes.Account.CreateAccount(request.AccountType);

        #region Set up modified account for update
        m_Logger.LogDebug("[{0}] Apply template props to account instance", Thread.CurrentThread.ManagedThreadId);
        template.ApplyTemplatePropsToAccount(modifiedAccount, request.PropNames);

        modifiedAccount.ApplyDefaultSecurityPolicy = template.ApplyDefaultSecurityPolicy;
        #endregion

        #region Submit Update Requests
        m_Logger.LogDebug("[{0}] Create Account Update client", Thread.CurrentThread.ManagedThreadId);
        AccountCreationClient client = null;
        bool clientFaulted = false;

        try
        {
          client = CoreClientConnector.CreateMASClient
                   <AccountCreationClient, IAccountCreation, NetTcpBinding>
                   (HostLocation.Remote,
                       "AccountCreation",
                       request.ClientUserName,
                       (MTAuth.IMTSessionContext)request.SessionContext);

          int maxConcurrent = Math.Min(Math.Min(m_ConfigSection.MaxConcurrentUpdatesPerThread, request.AccountIds.Count), 64);
          ActiveUpdateRequest[] asyncResults = new ActiveUpdateRequest[maxConcurrent];
          WaitHandle[] waitHandles = new WaitHandle[maxConcurrent];

          int i = 0;
          for (i = 0; i < maxConcurrent; i++)
          {
            m_Logger.LogDebug("[{0}] Sending update request for account {1}({2})", Thread.CurrentThread.ManagedThreadId, request.AccountIds[i].AccountName, request.AccountIds[i].AccountId);

            BaseTypes.Account newAcct = modifiedAccount.Clone() as BaseTypes.Account;
            newAcct._AccountID = request.AccountIds[i].AccountId;

            asyncResults[i] = new ActiveUpdateRequest();
            client.InnerChannel.OperationTimeout = new TimeSpan(0, Math.Max(m_ConfigSection.ClientTimoutMinutes, 1), 0);
            asyncResults[i].AsyncResult = client.BeginUpdateAccount(newAcct, false, null, null, null);
            waitHandles[i] = asyncResults[i].AsyncResult.AsyncWaitHandle;
            asyncResults[i].Account = request.AccountIds[i];
          }

          while (i < request.AccountIds.Count)
          {
            int completed = WaitHandle.WaitAny(waitHandles);

            CompleteRequest(client, request, asyncResults[completed], nRetryCount, ref clientFaulted);

            m_Logger.LogDebug("[{0}] Sending update request for account {1}({2})", Thread.CurrentThread.ManagedThreadId, request.AccountIds[i].AccountName, request.AccountIds[i].AccountId);

            BaseTypes.Account newAcct = modifiedAccount.Clone() as BaseTypes.Account;
            newAcct._AccountID = request.AccountIds[i].AccountId;

            asyncResults[completed] = new ActiveUpdateRequest();
            asyncResults[completed].AsyncResult = client.BeginUpdateAccount(newAcct, false, null, null, null);
            waitHandles[completed] = asyncResults[completed].AsyncResult.AsyncWaitHandle;
            asyncResults[completed].Account = request.AccountIds[i];

            i++;
          }

          WaitHandle.WaitAll(waitHandles);

          for (int j = 0; j < maxConcurrent; j++)
          {
            CompleteRequest(client, request, asyncResults[j], nRetryCount, ref clientFaulted);
          }
          client.Close();
        }
        catch (Exception e)
        {
          client.Abort();
          m_Logger.LogException("An unknown exception has occurred.  Please review system logs.", e);
          throw e;
        }
        #endregion
        #endregion
      }
      else
      {
        WriteSessionDetail(request.SessionId, DetailType.Update, DetailResult.Information, "There are no account properties to be applied", nRetryCount);
			}*/

      if (request.Subscriptions.Count > 0)
      {
        #region Apply Subscriptions
        m_Logger.LogDebug("Creating Product Catalog and setting session context");
        ProdCatalog.IMTProductCatalog productCatalog = new ProdCatalog.MTProductCatalogClass();
        productCatalog.SetSessionContext((ProdCatalog.IMTSessionContext)request.SessionContext);

        m_Logger.LogDebug("Creating subscription catalog and setting session context");
        Subscription.IMTSubscriptionCatalog subscriptionCatalog = new Subscription.MTSubscriptionCatalogClass();
        subscriptionCatalog.SetSessionContext((MetraTech.Interop.Subscription.IMTSessionContext)request.SessionContext);

        foreach (AccountTemplateSubscription sub in request.Subscriptions)
        {
          try
          {
            if (!(sub.ProductOfferingId.HasValue && sub.GroupID.HasValue))
            {
              Subscription.IMTCollection subMemberCol = (Subscription.IMTCollection)new MTCollectionClass();
              ProdCatalog.IMTGroupSubscription groupSub = null;

              if (sub.GroupID.HasValue)
              {
                m_Logger.LogDebug("Load Group Subscription by ID");
                groupSub = productCatalog.GetGroupSubscriptionByID(sub.GroupID.Value);
              }

              m_Logger.LogDebug("Adding SubInfo objects");
              foreach (ValidatedAccount acct in request.AccountIds)
              {
                ProdCatalog.IMTSubInfo subInfo = new ProdCatalog.MTSubInfoClass();

                subInfo.AccountID = acct.AccountId;

                if (sub.ProductOfferingId.HasValue)
                {
                  subInfo.ProdOfferingID = sub.ProductOfferingId.Value;
                }
                else
                {
                  subInfo.ProdOfferingID = sub.GroupID.Value;
                  subInfo.CorporateAccountID = groupSub.CorporateAccount;
                  subInfo.GroupSubID = groupSub.GroupID;
                }

                if (!request.SubscriptionDates.StartDate.HasValue || request.SubscriptionDates.StartDate.Value < sub.StartDate)
                {
                  subInfo.SubsStartDate = sub.StartDate;
                }
                else
                {
                  subInfo.SubsStartDate = request.SubscriptionDates.StartDate.Value;
                }
                subInfo.SubsStartDateType = (ProdCatalog.MTPCDateType)request.SubscriptionDates.StartDateType;

                if (!request.SubscriptionDates.EndDate.HasValue || request.SubscriptionDates.EndDate.Value > sub.EndDate)
                {
                  subInfo.SubsEndDate = sub.EndDate;
                }
                else
                {
                  subInfo.SubsEndDate = request.SubscriptionDates.EndDate.Value;
                }
                subInfo.SubsEndDateType = (ProdCatalog.MTPCDateType)request.SubscriptionDates.EndDateType;

                subMemberCol.Add(subInfo);
              }

              bool bDateModified = false;
              Subscription.IMTRowSet errors = null;
              if (sub.ProductOfferingId.HasValue)
              {
                m_Logger.LogDebug("Subscribe accounts to product offering");
                errors = subscriptionCatalog.SubscribeAccounts(subMemberCol, null, request.EndConflictingSubscriptions, out bDateModified, null);
              }
              else
              {
                m_Logger.LogDebug("Subscribe accounts to group subscription");
                errors = subscriptionCatalog.SubscribeToGroups(subMemberCol, null, request.EndConflictingSubscriptions, out bDateModified, null);
              }

              if (errors.RecordCount == 0)
              {
                string msg = string.Format(
                        "Successfully applied {0} {1} to all accounts",
                        (sub.ProductOfferingId.HasValue ? "subscription to product offering" : "group subscription"),
                        (sub.ProductOfferingId.HasValue ? sub.ProductOfferingId.Value : sub.GroupID.Value));

                m_Logger.LogDebug(msg);

                WriteSessionDetail(
                    request.SessionId,
                    DetailType.Subscription,
                    DetailResult.Success,
                    msg, nRetryCount);
              }
              else
              {
                string errorMsg = string.Format("Failed to apply {0} {1} to at least one account",
                        (sub.ProductOfferingId.HasValue ? "subscription to product offering" : "group subscription"),
                        (sub.ProductOfferingId.HasValue ? sub.ProductOfferingId.Value : sub.GroupID.Value));

                m_Logger.LogError(errorMsg);
                WriteSessionDetail(request.SessionId, DetailType.Subscription, DetailResult.Failure, errorMsg, nRetryCount);

                errors.MoveFirst();

                while (!Convert.ToBoolean(errors.EOF))
                {
                  errorMsg = string.Format(
                                  "{0} failed for account {1}: {2};",
                                  (sub.ProductOfferingId.HasValue ? "Subscription to product offering" : "Group subscription"),
                                  errors.get_Value("accountname"),
                                  errors.get_Value("description"));

                  m_Logger.LogError(errorMsg);
                  WriteSessionDetail(request.SessionId, DetailType.Subscription, DetailResult.FailureDetail, errorMsg, nRetryCount);

                  errors.MoveNext();
                }

              }
            }
            else
            {
              string msg = string.Format("Unable to apply subscription that had Product Offering ID {0} specified as well as Group ID {1} specified", sub.ProductOfferingId, sub.GroupID);

              m_Logger.LogError(msg);

              WriteSessionDetail(
                  request.SessionId,
                  DetailType.Subscription,
                  DetailResult.Failure,
                  msg, nRetryCount);
            }
          }
          catch (Exception e)
          {
            m_Logger.LogException(string.Format("Error processing {0} {1}",
                            (sub.ProductOfferingId.HasValue ? "subscription to product offering" : "group subscription"),
                            (sub.ProductOfferingId.HasValue ? sub.ProductOfferingId.Value : sub.GroupID.Value)), e);


            WriteSessionDetail(
                    request.SessionId,
                    DetailType.Subscription,
                    DetailResult.Failure,
                    string.Format("Unexpected error processing {0} {1}",
                            (sub.ProductOfferingId.HasValue ? "subscription to product offering" : "group subscription"),
                            (sub.ProductOfferingId.HasValue ? sub.ProductOfferingId.Value : sub.GroupID.Value)), nRetryCount);
          }
        }
        #endregion
      }
      else
      {
        WriteSessionDetail(request.SessionId, DetailType.Subscription, DetailResult.Information, "There are no subscriptions to be applied", nRetryCount);
      }

      WriteSessionDetail(request.SessionId, DetailType.General, DetailResult.Information, "Template application complete", nRetryCount);
    }

    private static void CompleteRequest(
        AccountCreationClient client,
        AccountTemplateRequest request,
        ActiveUpdateRequest activeUpdateRequest,
        int nRetryCount,
        ref bool clientFaulted)
    {
      try
      {
        client.EndUpdateAccount(activeUpdateRequest.AsyncResult);

        WriteSessionDetail(
            request.SessionId,
            DetailType.Update,
            DetailResult.Success,
            string.Format("Successfully updated account {0}({1})", activeUpdateRequest.Account.AccountName, activeUpdateRequest.Account.AccountId), nRetryCount);

        m_Logger.LogInfo("Successfully updated account {0}({1})", activeUpdateRequest.Account.AccountName, activeUpdateRequest.Account.AccountId);
      }
      catch (FaultException<Common.MASBasicFaultDetail> fe)
      {
        string errMsg = string.Format("Failed to update account {0}({1}): ", activeUpdateRequest.Account.AccountName, activeUpdateRequest.Account.AccountId);

        foreach (string err in fe.Detail.ErrorMessages)
        {
          errMsg += err + "\r\n";
        }

        m_Logger.LogError(errMsg);
        WriteSessionDetail(request.SessionId, DetailType.Update, DetailResult.Failure, errMsg, nRetryCount);
      }
      catch (System.ServiceModel.CommunicationException comEx)
      {
        m_Logger.LogException("Communication Exception caught updating account", comEx);

        WriteSessionDetail(
            request.SessionId,
            DetailType.Update,
            DetailResult.Failure,
            string.Format(
                "Error updating account {0}({1}): {2}",
                activeUpdateRequest.Account.AccountName,
                activeUpdateRequest.Account.AccountId,
                comEx.Message), nRetryCount);

        clientFaulted = true;

        throw comEx;
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception caught updating account", e);

        WriteSessionDetail(
            request.SessionId,
            DetailType.Update,
            DetailResult.Failure,
            string.Format(
                "Error updating account {0}({1}): {2}",
                activeUpdateRequest.Account.AccountName,
                activeUpdateRequest.Account.AccountId,
                e.Message), nRetryCount);

        clientFaulted = true;
      }

    }

    private static void WriteSessionDetail(int sessionId, DetailType detailType, DetailResult result, string message, int nRetryCount)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\AccHierarchies", "__INSERT_TEMPLATE_SESSION_DETAIL__"))
        {
          stmt.AddParam("%%SESSION_ID%%", sessionId);
          stmt.AddParam("%%DETAIL_TYPE%%", EnumHelper.GetDbValueByEnum(detailType));
          stmt.AddParam("%%RESULT%%", EnumHelper.GetDbValueByEnum(result));
          stmt.AddParam("%%DETAIL_DATE%%", MetraTime.Now);
          stmt.AddParam("%%TEXT%%", message);
          stmt.AddParam("%%RETRY_COUNT%%", nRetryCount);

          stmt.ExecuteNonQuery();
        }
      }
    }
    #endregion
  }

  [Serializable]
  internal class AccountTemplateRequest : ISerializable
  {
    #region Data
    public int SessionId { get; set; }
    public int TemplateOwnerId { get; set; }
    public string AccountType { get; set; }
    public List<ValidatedAccount> AccountIds { get; set; }
    public DateTime EffectiveDate { get; set; }
    public List<string> PropNames { get; set; }
    public List<AccountTemplateSubscription> Subscriptions { get; set; }
    public BaseTypes.ProdCatTimeSpan SubscriptionDates { get; set; }
    public bool EndConflictingSubscriptions { get; set; }

    public string ClientUserName { get; set; }

    public AccountTemplate Template { get; set; }

    public MetraTech.Interop.MTYAAC.IMTSessionContext SessionContext { get; set; }
    #endregion Data

    #region Constructors
    public AccountTemplateRequest()
    {
    }

    protected AccountTemplateRequest(SerializationInfo info, StreamingContext context)
    {
      SessionId = info.GetInt32("SessionId");
      TemplateOwnerId = info.GetInt32("TemplateOwnerId");
      AccountType = info.GetString("AccountType");
      AccountIds = (List<ValidatedAccount>)info.GetValue("AccountIds", typeof(List<ValidatedAccount>));
      EffectiveDate = info.GetDateTime("EffectiveDate");
      PropNames = (List<string>)info.GetValue("PropNames", typeof(List<string>));
      Subscriptions = (List<AccountTemplateSubscription>)info.GetValue("Subscriptions", typeof(List<AccountTemplateSubscription>));
      SubscriptionDates = (BaseTypes.ProdCatTimeSpan)info.GetValue("SubscriptionDates", typeof(BaseTypes.ProdCatTimeSpan));
      EndConflictingSubscriptions = info.GetBoolean("EndConflictingSubscriptions");
      ClientUserName = info.GetString("ClientUserName");
      Template = (AccountTemplate)info.GetValue("Template", typeof(AccountTemplate));
      SessionContext = (YAAC.IMTSessionContext)new MTSessionContextClass();
      SessionContext.FromXML(info.GetString("SessionContext"));
    }
    #endregion Constructors

    #region ISerializable Members

    public void GetObjectData(SerializationInfo info, StreamingContext context)
    {
      info.AddValue("SessionId", SessionId);
      info.AddValue("TemplateOwnerId", TemplateOwnerId);
      info.AddValue("AccountType", AccountType);
      info.AddValue("AccountIds", AccountIds, typeof(List<ValidatedAccount>));
      info.AddValue("EffectiveDate", EffectiveDate);
      info.AddValue("PropNames", PropNames, typeof(List<string>));
      info.AddValue("Subscriptions", Subscriptions, typeof(List<AccountTemplateSubscription>));
      info.AddValue("SubscriptionDates", SubscriptionDates);
      info.AddValue("EndConflictingSubscriptions", EndConflictingSubscriptions);
      info.AddValue("ClientUserName", ClientUserName);
      info.AddValue("Template", Template);
      string ctx = SessionContext.ToXML();
      info.AddValue("SessionContext", ctx);
    }

    #endregion
  }

  [Serializable]
  internal class ValidatedAccount
  {
    public int AccountId { get; set; }
    public string AccountName { get; set; }
  }

  internal class ActiveUpdateRequest
  {
    public ValidatedAccount Account { get; set; }
    public IAsyncResult AsyncResult { get; set; }
  }

  #region Compiled-in AccountCreation Client Proxy
  /// Compiling in a copy of the AccountCreation client proxy so that changes to the interface
  /// by SIs do not break the application of templates.  The only gotcha is that SIs must not remove
  /// or rename any of the core arguments and must only add NULLABLE types.
  [ServiceContract(ConfigurationName = "IAccountCreation")]
  public interface IAccountCreation
  {

    [OperationContract()]
    [System.ServiceModel.FaultContractAttribute(typeof(MASBasicFaultDetail))]
    void AddAccount(ref global::MetraTech.DomainModel.BaseTypes.Account Account, global::System.Nullable<bool> ApplyAccountTemplate);

    [OperationContract()]
    [System.ServiceModel.FaultContractAttribute(typeof(MASBasicFaultDetail))]
    void UpdateAccount(global::MetraTech.DomainModel.BaseTypes.Account Account, global::System.Nullable<bool> ApplyAccountTemplate, global::System.Nullable<DateTime> LoadTime);

    [OperationContract()]
    [System.ServiceModel.FaultContractAttribute(typeof(MASBasicFaultDetail))]
    void UpdateAccountView(global::MetraTech.DomainModel.BaseTypes.Account Account);

    [OperationContract(AsyncPattern = true)]
    System.IAsyncResult BeginAddAccount(ref MetraTech.DomainModel.BaseTypes.Account Account, System.Nullable<bool> ApplyAccountTemplate, System.AsyncCallback callback, object asyncState);

    void EndAddAccount(ref MetraTech.DomainModel.BaseTypes.Account Account, System.IAsyncResult result);

    [OperationContract(AsyncPattern = true)]
    System.IAsyncResult BeginUpdateAccount(global::MetraTech.DomainModel.BaseTypes.Account Account, global::System.Nullable<bool> ApplyAccountTemplate, global::System.Nullable<DateTime> LoadTime, System.AsyncCallback callback, object asyncState);

    void EndUpdateAccount(System.IAsyncResult result);

    [OperationContract(AsyncPattern = true)]
    System.IAsyncResult BeginUpdateAccountView(MetraTech.DomainModel.BaseTypes.Account Account, System.AsyncCallback callback, object asyncState);

    void EndUpdateAccountView(System.IAsyncResult result);
  }

  public interface IAccountCreationChannel : IAccountCreation, System.ServiceModel.IClientChannel
  {
  }

  [System.Diagnostics.DebuggerStepThroughAttribute()]
  public partial class AccountCreationClient : System.ServiceModel.ClientBase<IAccountCreation>, IAccountCreation
  {

    public AccountCreationClient()
    {
      this.AddKnownTypes();
    }

    public AccountCreationClient(string endpointConfigurationName) :
      base(endpointConfigurationName)
    {
      this.AddKnownTypes();
    }

    public AccountCreationClient(string endpointConfigurationName, string remoteAddress) :
      base(endpointConfigurationName, remoteAddress)
    {
      this.AddKnownTypes();
    }

    public AccountCreationClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) :
      base(endpointConfigurationName, remoteAddress)
    {
      this.AddKnownTypes();
    }

    public AccountCreationClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
      base(binding, remoteAddress)
    {
      this.AddKnownTypes();
    }

    private void AddKnownTypes()
    {
      System.Collections.Generic.IEnumerator<System.ServiceModel.Description.OperationDescription> iter = base.Endpoint.Contract.Operations.GetEnumerator();
      bool iterValid = false;
      for (iterValid = iter.MoveNext(); iterValid; iterValid = iter.MoveNext())
      {
        if (iter.Current.Name.Contains("AddAccount"))
        {
        }
        else
        {
          if (iter.Current.Name.Contains("UpdateAccount"))
          {
          }
          else
          {
            if (iter.Current.Name.Contains("UpdateAccountView"))
            {
            }
          }
        }
      }
    }

    public virtual void AddAccount(ref global::MetraTech.DomainModel.BaseTypes.Account Account, global::System.Nullable<bool> ApplyAccountTemplate)
    {
      base.Channel.AddAccount(ref Account, ApplyAccountTemplate);
    }

    public virtual System.IAsyncResult BeginAddAccount(ref MetraTech.DomainModel.BaseTypes.Account Account, System.Nullable<bool> ApplyAccountTemplate, System.AsyncCallback callback, object asyncState)
    {
      return base.Channel.BeginAddAccount(ref Account, ApplyAccountTemplate, callback, asyncState);
    }

    public virtual void EndAddAccount(ref MetraTech.DomainModel.BaseTypes.Account Account, System.IAsyncResult result)
    {
      base.Channel.EndAddAccount(ref Account, result);
    }

    public virtual void UpdateAccount(global::MetraTech.DomainModel.BaseTypes.Account Account, global::System.Nullable<bool> ApplyAccountTemplate, global::System.Nullable<DateTime> LoadTime)
    {
        base.Channel.UpdateAccount(Account, ApplyAccountTemplate, LoadTime);
    }

    public virtual System.IAsyncResult BeginUpdateAccount(global::MetraTech.DomainModel.BaseTypes.Account Account, global::System.Nullable<bool> ApplyAccountTemplate, global::System.Nullable<DateTime> LoadTime, System.AsyncCallback callback, object asyncState)
    {
        return base.Channel.BeginUpdateAccount(Account, ApplyAccountTemplate, LoadTime, callback, asyncState);
    }

    public virtual void EndUpdateAccount(System.IAsyncResult result)
    {
      base.Channel.EndUpdateAccount(result);
    }

    public virtual void UpdateAccountView(global::MetraTech.DomainModel.BaseTypes.Account Account)
    {
      base.Channel.UpdateAccountView(Account);
    }

    public virtual System.IAsyncResult BeginUpdateAccountView(MetraTech.DomainModel.BaseTypes.Account Account, System.AsyncCallback callback, object asyncState)
    {
      return base.Channel.BeginUpdateAccountView(Account, callback, asyncState);
    }

    public virtual void EndUpdateAccountView(System.IAsyncResult result)
    {
      base.Channel.EndUpdateAccountView(result);
    }
  }
  #endregion

}
