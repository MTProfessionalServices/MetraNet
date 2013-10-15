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
using System.Threading;
using System.Transactions;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Interop.QueryAdapter;
using MTAuth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.Rowset;
using System.Reflection;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.Validators;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.GenericCollection;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using IMTRowSet = MetraTech.Interop.Rowset.IMTRowSet;
using MetraTech.Interop.MTYAAC;
using IMTPropertyMetaDataSet = MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Debug.Diagnostics;


namespace MetraTech.Core.Services
{
  [ServiceContract()]
  public interface IGroupSubscriptionService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetGroupSubscriptionsForMemberAccount(AccountIdentifier acct, ref MTList<GroupSubscription> groupSubs);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetGroupSubscriptionsForCorporateAccount(AccountIdentifier acct, ref MTList<GroupSubscription> groupSubs);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetEligibleGroupSubscriptions(AccountIdentifier acct, ref MTList<GroupSubscription> groupSubs);


    /* [OperationContract]
     [FaultContract(typeof(MASBasicFaultDetail))]
     void GetMembersForGroupSubscription(int groupSubscriptionId,
                                         out List<GroupSubscriptionMember> groupSubscriptionMembers);*/

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetMembersForGroupSubscription2(int groupSubscriptionId,
                                         ref MTList<GroupSubscriptionMember> groupSubscriptionMembers);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetMemberInfoForGroupSubscription(int groupSubscriptionId, int memberId,
                                         ref GroupSubscriptionMember memberInfo);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetProductOfferingsForGroupSubscriptions(AccountIdentifier acct,
                                                  DateTime effectiveDate,
                                                  ref MTList<ProductOffering> productOfferings);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetGroupSubscriptionDetail(int groupSubscriptionId,
                                    out GroupSubscription groupSubscription);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetFlatRateRecurringChargeInstancesForPO(int productOfferingId,
                                                  out List<FlatRateRecurringChargeInstance> flatRateRecurringChargeInstances);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddGroupSubscription(ref GroupSubscription groupSubscription);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddMembersToGroupSubscription(int groupSubscriptionId,
                                       List<GroupSubscriptionMember> groupSubscriptionMembers);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddMemberHierarchiesToGroupSubscription(int groupSubscriptionId,
                                        ProdCatTimeSpan subscriptionSpan,
                                        Dictionary<AccountIdentifier, AccountTemplateScope> accounts);
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteMembersFromGroupSubscription(int groupSubscriptionId,
                                            List<GroupSubscriptionMember> groupSubscriptionMembers);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateGroupSubscriptionMember(GroupSubscriptionMember groupSubscriptionMember);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UnsubscribeGroupSubscriptionMembers(List<GroupSubscriptionMember> groupSubscriptionMembers);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateGroupSubscription(GroupSubscription groupSubscription);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteGroupSubscription(int groupSubscriptionId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetCharacteristicValuesForGroupSub(ref MTList<CharacteristicValue> charVals);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class GroupSubscriptionService : BaseSubscriptionService, IGroupSubscriptionService
  {
    public GroupSubscriptionService(){}
    public GroupSubscriptionService(MTAuth.IMTSessionContext sessionContext) : base(sessionContext) { }
      
    private Logger m_Logger = new Logger("[GroupSubscriptionService]");

    #region ISubscriptionService Members

    [OperationCapability("View group subscriptions")]
    public void GetGroupSubscriptionsForMemberAccount(AccountIdentifier acct, ref MTList<GroupSubscription> groupSubs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetGroupSubscriptionsForMemberAccount"))
      {
        try
        {
          // Get the session context from the WCF ambient service security context
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

          string selectlist;
          string joinlist;
          var metaData = GetProductOfferingMetaData(out selectlist, out joinlist);

          #region Get the list of group subscriptions


          // open the connection
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            
            bool isOracle = conn.ConnectionInfo.IsOracle;
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\AccHierarchies",
                                                                           "__FIND_GROUP_SUBS_BY_DATE_RANGE__"))
            {
              /* if (prodCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == false)
               {
                   // Get a filter/sort statement
                   string filterlist = "";

                   stmt.AddParam("%%TIMESTAMP%%", MetraTime.Now);
                   stmt.AddParam("%%FILTERS%%", filterlist);

               }*/
              // else
              // {
              // Get a filter/sort statement
              stmt.ConfigPath = "queries\\ProductCatalog";
              stmt.QueryTag = "__GET_ALL_ACCOUNT_GROUP_SUBS__";

              // Set the parameters
              stmt.AddParam("%%ID_ACC%%", id_acc);
              stmt.AddParam("%%COLUMNS%%", selectlist);
              stmt.AddParam("%%JOINS%%", joinlist);
              stmt.AddParam("%%ID_LANG%%", sessionContext.LanguageID);

              // }

              ApplyFilterSortCriteria<GroupSubscription>(stmt, groupSubs, new FilterColumnResolver(GetColumnNameFromGroupSubPropertyName), metaData);

              // execute the query
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                GroupSubscription grpSub = null;
                // process the results
                while (rdr.Read())
                {
                  grpSub = PopulateGroupSubscription(metaData, rdr, isOracle);
                  groupSubs.Items.Add(grpSub);
                  groupSubs.TotalRows++;

                }

                // get the total rows that would be returned without paging
                groupSubs.TotalRows = stmt.TotalRows;
              }
            }
          }
          #endregion

        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception getting group subscriptions", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception getting group subscriptions", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting group subscriptions", e);
          throw new MASBasicException("Error getting group subscriptions");
        }
      }
    }

    private IMTPropertyMetaDataSet GetProductOfferingMetaData(out string selectlist, out string joinlist)
    {
      selectlist = "";
      joinlist = "";

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
        m_Logger.LogException("Exception getting group subscription properties in GetProductOfferingMetaData", e);
        throw new MASBasicException("Unable to get Group subscription properties");
      }

      return metaData;
    }

    [OperationCapability("View group subscriptions")]
    public void GetEligibleGroupSubscriptions(AccountIdentifier acct, ref MTList<GroupSubscription> groupSubs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetEligibleGroupSubscriptions"))
      {
        try
        {
          // Get the session context from the WCF ambient service security context
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();

          int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

          if (id_acc <= 0)
            throw new MASBasicException("Invalid Account identifier / Account not found");

          int corpID = -1;

          GetCorporateAccount(id_acc, MetraTime.Now, out corpID);

          string selectlist;
          string joinlist;
          var metaData = GetProductOfferingMetaData(out selectlist, out joinlist);

          #region Get the list of group subscription members


          // open the connection
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            bool isOracle = conn.ConnectionInfo.IsOracle;
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\AccHierarchies",
                                                                           "__FIND_GROUP_SUBS_BY_DATE_RANGE__"))
            {
                // Get a filter/sort statement
                stmt.ConfigPath = "queries\\AccHierarchies";
                stmt.QueryTag = "__FIND_ELIGIBLE_GROUP_SUBS__";
                // Set the parameters
                stmt.AddParam("%%CORPORATEACCOUNT%%", corpID);
                stmt.AddParam("%%ID_ACC%%", id_acc);

              ApplyFilterSortCriteria<GroupSubscription>(stmt, groupSubs, new FilterColumnResolver(GetColumnNameFromGroupSubPropertyName), metaData);

              // execute the query
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                GroupSubscription grpSub = null;
                // process the results
                while (rdr.Read())
                {
                  grpSub = PopulateGroupSubscription(metaData, rdr, isOracle);
                  groupSubs.Items.Add(grpSub);
                  groupSubs.TotalRows++;

                }

                // get the total rows that would be returned without paging
                groupSubs.TotalRows = stmt.TotalRows;
              }
            }
          }
          #endregion


        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception getting group subscriptions", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception getting group subscriptions", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting group subscriptions", e);
          throw new MASBasicException("Error getting group subscriptions");
        }
      }
    }

    [OperationCapability("View group subscriptions")]
    public void GetGroupSubscriptionsForCorporateAccount(AccountIdentifier acct, ref MTList<GroupSubscription> groupSubs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetGroupSubscriptionsForCorporateAccount"))
      {
        try
        {
          // Get the session context from the WCF ambient service security context
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();

          int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

          string selectlist;
          string joinlist;
          var metaData = GetProductOfferingMetaData(out selectlist, out joinlist);
          #region Get the list of group subscription members


          // open the connection
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            bool isOracle = conn.ConnectionInfo.IsOracle;
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\AccHierarchies",
                                                                           "__FIND_GROUP_SUBS_BY_DATE_RANGE__"))
            {
              IMTProductCatalog prodCatalog = new MTProductCatalogClass();
              if (prodCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == false)
              {
                // Get a filter/sort statement
                string filterlist = "";

                stmt.AddParam("%%TIMESTAMP%%", MetraTime.Now);
                stmt.AddParam("%%FILTERS%%", filterlist);
              }

              else
              {
                // Get a filter/sort statement
                stmt.ConfigPath = "queries\\AccHierarchies";
                stmt.QueryTag = "__FIND_GROUP_SUBS_BY_CORPORATE_ACCOUNT__";
                // Set the parameters
                stmt.AddParam("%%CORPORATEACCOUNT%%", id_acc);
              }

              ApplyFilterSortCriteria<GroupSubscription>(stmt, groupSubs, new FilterColumnResolver(GetColumnNameFromGroupSubPropertyName), metaData);

              // execute the query
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                GroupSubscription grpSub = null;
                // process the results
                while (rdr.Read())
                {
                  grpSub = PopulateGroupSubscription(metaData, rdr, isOracle);
                  groupSubs.Items.Add(grpSub);
                  groupSubs.TotalRows++;

                }

                // get the total rows that would be returned without paging
                groupSubs.TotalRows = stmt.TotalRows;
              }
            }
          }
          #endregion
        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception getting group subscriptions", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception getting group subscriptions", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting group subscriptions", e);
          throw new MASBasicException("Error getting group subscriptions");
        }

      }
    }


    private string GetColumnNameFromGroupSubPropertyName(string propName, ref object filterVal, object helper)
    {
      MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData = (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet)helper;

      if ((propName.IndexOf("#") > 0) && (propName.IndexOf("#") < propName.Length))
      {
        propName = propName.Substring(propName.IndexOf("#") + 1);
      }
      switch (propName)
      {

        case "SubscriptionId":
          return "id_sub";
          break;

        case "GroupId":
          return "id_group";
          break;

        case "ProductOfferingId":
          return "id_po";
          break;

        case "SubscriptionSpan.StartDate":
        case "SubscriptionSpan_StartDate":
        case "StartDate":
          return "vt_start";
          break;

        case "SubscriptionSpan.EndDate":
        case "SusbcriptionSpan_EndDate":
        case "EndDate":
          return "vt_end";
          break;

        case "UsageCycleId":
          return "usage_cycle";
          break;

        case "Name":
          return "tx_name";
          break;

        case "Description":
          return "tx_desc";
          break;

        case "ProportionalDistribution":
          return "b_proportional";
          break;

        case "CorporateAccountId":
          return "corporate_account";
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

      };
    }

    /* [OperationCapability("View group subscriptions")]
  public void GetMembersForGroupSubscription(int groupSubscriptionId,
                                             out List<GroupSubscriptionMember> groupSubscriptionMembers)
  {
    try
    {
      groupSubscriptionMembers = new List<GroupSubscriptionMember>();

      MTAuth.IMTSessionContext sessionContext = GetSessionContext();

      IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
      mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

      IMTGroupSubscription mtGroupSub = mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionId);
      if (mtGroupSub == null)
      {
        m_Logger.LogError("Error retrieving group subscription");
        throw new MASBasicException("Error retrieving group subscription");
      }

      GroupSubscriptionMember groupSubMember = null;

      MTGroupSubSlice mtGroupSubSlice = mtGroupSub.Membership();
      foreach (MTGSubMember mtGsubMember in mtGroupSubSlice.GroupMembers)
      {
        groupSubMember = new GroupSubscriptionMember();
        groupSubMember.MembershipSpan = new ProdCatTimeSpan();
        groupSubMember.AccountId = mtGsubMember.AccountID;
        groupSubMember.GroupId = groupSubscriptionId;
        groupSubMember.MembershipSpan.StartDate = mtGsubMember.StartDate;
        groupSubMember.MembershipSpan.EndDate = mtGsubMember.EndDate;

        groupSubscriptionMembers.Add(groupSubMember);
      }

    }
    catch (MASBasicException masBasic)
    {
      m_Logger.LogException("Exception getting members for group subscription", masBasic);
      throw masBasic;
    }
    catch (COMException comE)
    {
      if (comE.Message == "Unable to populate group subscription membership collection")
      {
          groupSubscriptionMembers = new List<GroupSubscriptionMember>();

      }
      else
      {
          m_Logger.LogException("COM Exception getting members for group subscription", comE);
          throw new MASBasicException(comE.Message);
      }
        
    }
    catch (Exception e)
    {
      m_Logger.LogException("Exception getting members for group subscription", e);
      throw new MASBasicException("Error getting members for group subscription");
    }
  }
    */
    [OperationCapability("View group subscriptions")]
    public void GetProductOfferingsForGroupSubscriptions(AccountIdentifier acct,
                                                         DateTime effectiveDate,
                                                         ref MTList<ProductOffering> productOfferings)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetProductOfferingsForGroupSubscriptions"))
      {
        /*  try
          {
              // Get the session context from the WCF ambient service security context
              MTAuth.IMTSessionContext sessionContext = GetSessionContext();

              int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

              IMTProductCatalog productCatalog = new MTProductCatalogClass();
              productCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

              MetraTech.Interop.MTProductCatalog.IMTSQLRowset rowset = null;

              if (productCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == false)
              {
                  rowset = productCatalog.FindAvailableProductOfferingsAsRowset(Missing.Value, effectiveDate);
              }
              else
              {
                  rowset = productCatalog.FindAvailableProductOfferingsForGroupSubscriptionAsRowset(id_acc, Missing.Value, effectiveDate);
              }

              ProductOffering productOffering = null;
              int productOfferingId = 0;

              if (rowset != null)
              {
                  while (!System.Convert.ToBoolean(rowset.EOF))
                  {
                      productOfferingId = (int)rowset.get_Value("id_prop");
                      productOffering = GetProductOffering(productOfferingId);

                      if (productOffering != null)
                      {
                          productOfferings.Items.Add(productOffering);
                          productOfferings.TotalRows++;
                      }
                      else
                      {
                          m_Logger.LogError(String.Format("Error retrieving product offering with id '{0}' for group subscriptions", productOfferingId));
                          throw new MASBasicException("Error retrieving product offering for group subscriptions");
                      }

                      rowset.MoveNext();
                  }
              }
              else
              {
                  m_Logger.LogError("Error retrieving available product offerings for group subscriptions");
                  throw new MASBasicException("Error retrieving available product offerings for group subscriptions");
              }
          }
          catch (MASBasicException masBasic)
          {
              m_Logger.LogException("Exception getting product offerings", masBasic);
              throw masBasic;
          }
          catch (COMException comE)
          {
              m_Logger.LogException("COM Exception getting product offerings", comE);
              throw new MASBasicException(comE.Message);
          }
          catch (Exception e)
          {
              m_Logger.LogException("Exception getting product offerings", e);
              throw new MASBasicException("Error getting product offerings");
          }*/


        try
        {
          // Get the session context from the WCF ambient service security context
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

          #region Get Product Offering Meta Data

          string selectlist = "", joinlist = "";
          SubscriptionService subService = new SubscriptionService();

          IMTProductCatalog productCatalog = new MTProductCatalogClass();
          MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData = null;
          try
          {
            // Get the meta data set
            metaData = productCatalog.GetMetaData(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_PRODUCT_OFFERING);
            // Get additional sql for PO extended properties
            metaData.GetPropertySQL("t_po.id_po", "", false, ref selectlist, ref joinlist);
          }
          catch (Exception e)
          {
            m_Logger.LogException("Exception getting group subscription properties in GetProductOfferingsForGroupSubscriptions", e);
            throw new MASBasicException("Unable to get Group subscription properties");
          }

          #endregion

          #region Get the list of product offerings

          // open the connection
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\ProductCatalog", "__FIND_AVAILABLE_PRODUCTOFFERINGS__"))
            {

              //Check ProdOff_AllowAccountPOCurrencyMismatch business rule and set currencyfilter parameter values accordingly
              string strCURRENCYFILTER3 = "";
              if (productCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) != false)
              {
                strCURRENCYFILTER3 = " 1=1 ";
              }
              else
              {
                strCURRENCYFILTER3 = " tavi.c_currency = tpl.nm_currency_code ";
              }


              // Get a filter/sort statement
              if (productCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) != false)
              {
                stmt.ConfigPath = "queries\\ProductCatalog";
                stmt.QueryTag = "__FIND_AVAILABLE_PRODUCTOFFERINGS_FOR_GROUPSUBSCRIPTION__";
                stmt.AddParam("%%CORPORATEACCOUNT%%", id_acc);
                //CORE-4962 fix
                stmt.AddParam("%%CURRENCYFILTER3%%", strCURRENCYFILTER3);
                //CORE-4962 fix
              }

              stmt.AddParam("%%ID_LANG%%", sessionContext.LanguageID);
              stmt.AddParam("%%REFDATE%%", effectiveDate, true);


              ApplyFilterSortCriteria<ProductOffering>(stmt, productOfferings, new FilterColumnResolver(subService.GetColumnNameFromProductOfferingPropertyname), metaData);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                ProductOffering prod;

                while (rdr.Read())
                {
                  prod = subService.PopulateProductOffering(metaData, rdr);

                  ProductOffering prodOff = ConfigureUsageCycleTypeForProductOffering(prod.ProductOfferingId.Value);
                  prod.UsageCycleType = prodOff.UsageCycleType;
                  prod.GroupSubscriptionRequiresCycle = prodOff.GroupSubscriptionRequiresCycle.Value;
                  prod = GetProductOffering(prod.ProductOfferingId.Value);
                  productOfferings.Items.Add(prod);
                }

                productOfferings.TotalRows = stmt.TotalRows;
              }

            }
          }
          #endregion

        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception retrieving product offerings for group subscriptions", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception retrieving product offerings for group subscriptions", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception retrieving product offerings for group subscriptions", e);
          throw new MASBasicException("Error retrieving product offerings for group subscriptions");
        }
      }
    }

    [OperationCapability("View group subscriptions")]
    public void GetGroupSubscriptionDetail(int groupSubscriptionId,
                                           out GroupSubscription groupSubscription)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetGroupSubscriptionDetail"))
      {
        try
        {
          groupSubscription = null;

          MTAuth.IMTSessionContext sessionContext = GetSessionContext();

          IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
          mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          IMTGroupSubscription mtGroupSub = mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionId);
          if (mtGroupSub == null)
          {
            m_Logger.LogError("Error retrieving group subscription");
            throw new MASBasicException("Error retrieving group subscription");
          }

          PopulateGroupSubscription(mtGroupSub, mtProductCatalog, out groupSubscription);

          #region Populate UDRCValues
          MetraTech.Interop.MTProductCatalog.IMTRowSet rs = mtGroupSub.GetRecurringChargeUnitValuesAsRowset();
          Dictionary<string, List<UDRCInstanceValue>> udrcValues = null;

          GetUDRCValues(rs, out udrcValues);
          groupSubscription.UDRCValues = udrcValues;
          #endregion

          #region Populate UDRCInstances
          MetraTech.Interop.MTProductCatalog.IMTRowSet UDRCInstanceRowSet = mtGroupSub.GetRecurringChargeAccounts(MetraTime.Max);
          List<UDRCInstance> udrcInstances = null;
          GetGroupSubUDRCInstances(UDRCInstanceRowSet, out udrcInstances);
          groupSubscription.UDRCInstances = udrcInstances;
          #endregion

          #region Populate Flat Rate Recurring Charge Instances

          MetraTech.Interop.MTProductCatalog.IMTRowSet FRRCInstanceRowSet = mtGroupSub.GetRecurringChargeAccounts(MetraTime.Max);
          List<FlatRateRecurringChargeInstance> frrcInstances = null;
          GetGroupSubFRRCInstances(FRRCInstanceRowSet, out frrcInstances);
          groupSubscription.FlatRateRecurringChargeInstances = frrcInstances;
          #endregion

          #region Populate Members
          MTList<GroupSubscriptionMember> members = new MTList<GroupSubscriptionMember>();
          GetMembersForGroupSubscription2(groupSubscriptionId, ref members);
          groupSubscription.Members = members;

          #endregion

          MTList<CharacteristicValue> vals = new MTList<CharacteristicValue>();
          vals.Filters.Add(new MTFilterElement("EntityId", MTFilterElement.OperationType.Equal, groupSubscriptionId));
          GetCharacteristicValuesForGroupSub(ref vals);
          groupSubscription.CharacteristicValues = vals.Items;

        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception getting group subscription detail", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception getting group subscription detail", comE);

          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting group subscription detail", e);

          throw new MASBasicException("Error getting group subscription detail");
        }
      }
    }

    public void GetGroupSubUDRCInstances(MetraTech.Interop.MTProductCatalog.IMTRowSet rs, out List<UDRCInstance> udrcInstances)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetGroupSubUDRCInstances"))
      {
        udrcInstances = new List<UDRCInstance>();

        if (rs.RecordCount > 0)
        {
          rs.MoveFirst();
          while (!Convert.ToBoolean(rs.EOF))
          {
            if (rs.get_Value("nm_servicedef").ToString().Contains("udrecurringcharge"))
            {
              UDRCInstance udrcInst = new UDRCInstance();

              udrcInst.ID = (int)rs.get_Value("id_prop");
              udrcInst.DisplayName = rs.get_Value("nm_display_name").ToString();
              if (rs.get_Value("id_acc").ToString() != "")
              {
                udrcInst.ChargeAccountId = (int)rs.get_Value("id_acc");
              }
              udrcInst.ChargeAccountSpan = new ProdCatTimeSpan();
              if (rs.get_Value("vt_start").ToString() != "")
              {
                udrcInst.ChargeAccountSpan.StartDate = (DateTime)rs.get_Value("vt_start");
              }
              if (rs.get_Value("vt_end").ToString() != "")
              {
                udrcInst.ChargeAccountSpan.EndDate = (DateTime)rs.get_Value("vt_end");
              }
              udrcInst.MinValue = (decimal)rs.get_Value("min_unit_value");
              udrcInst.MaxValue = (decimal)rs.get_Value("max_unit_value");
              udrcInst.UnitDisplayName = rs.get_Value("nm_unit_name").ToString();
              if (rs.get_Value("b_charge_per_participant").ToString() == "Y")
              {
                udrcInst.ChargePerParticipant = true;
              }
              else if (rs.get_Value("b_charge_per_participant").ToString() == "N")
              {
                udrcInst.ChargePerParticipant = false;
              }
              udrcInstances.Add(udrcInst);

            }
            rs.MoveNext();

          }
        }
      }
    }


    public void GetGroupSubFRRCInstances(MetraTech.Interop.MTProductCatalog.IMTRowSet rs, out List<FlatRateRecurringChargeInstance> frrcInstances)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetGroupSubFRRCInstances"))
      {
        frrcInstances = new List<FlatRateRecurringChargeInstance>();

        if (rs.RecordCount > 0)
        {
          rs.MoveFirst();
          while (!Convert.ToBoolean(rs.EOF))
          {
            if (rs.get_Value("nm_servicedef").ToString().Contains("flatrecurringcharge"))
            {
              FlatRateRecurringChargeInstance frrcInst = new FlatRateRecurringChargeInstance();

              frrcInst.ID = (int)rs.get_Value("id_prop");
              frrcInst.DisplayName = rs.get_Value("nm_display_name").ToString();
              if (rs.get_Value("id_acc").ToString() != "")
              {
                frrcInst.ChargeAccountId = (int)rs.get_Value("id_acc");
              }
              frrcInst.ChargeAccountSpan = new ProdCatTimeSpan();
              if (rs.get_Value("vt_start").ToString() != "")
              {
                frrcInst.ChargeAccountSpan.StartDate = (DateTime)rs.get_Value("vt_start");
              }
              if (rs.get_Value("vt_end").ToString() != "")
              {
                frrcInst.ChargeAccountSpan.EndDate = (DateTime)rs.get_Value("vt_end");
              }
              if (rs.get_Value("b_charge_per_participant").ToString() == "Y")
              {
                frrcInst.ChargePerParticipant = true;
              }
              else if (rs.get_Value("b_charge_per_participant").ToString() == "N")
              {
                frrcInst.ChargePerParticipant = false;
              }
              frrcInstances.Add(frrcInst);
            }
            rs.MoveNext();

          }
        }
      }
    }

    [OperationCapability("View group subscriptions")]
    public void GetFlatRateRecurringChargeInstancesForPO(int productOfferingId,
                                                         out List<FlatRateRecurringChargeInstance> flatRateRecurringChargeInstances)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetFlatRateRecurringChargeInstancesForPO"))
      {
        try
        {
          flatRateRecurringChargeInstances = new List<FlatRateRecurringChargeInstance>();

          MTAuth.IMTSessionContext sessionContext = GetSessionContext();

          IMTProductCatalog mtProdCatalog = new MTProductCatalogClass();
          mtProdCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          IMTProductOffering mtProductOffering = mtProdCatalog.GetProductOffering(productOfferingId);

          if (mtProductOffering != null)
          {
            MTPriceableItemType mtPriceableItemType = mtProdCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge");
            if (mtPriceableItemType != null)
            {
              MetraTech.Interop.MTProductCatalog.IMTCollection mtPriceableItems = mtProductOffering.GetPriceableItemsOfType(mtPriceableItemType.ID);
              FlatRateRecurringChargeInstance flatRateRecurringChargeInstance = null;

              foreach (IMTRecurringCharge recurringCharge in mtPriceableItems)
              {
                flatRateRecurringChargeInstance = new FlatRateRecurringChargeInstance();
                flatRateRecurringChargeInstance.ID = recurringCharge.ID;
                flatRateRecurringChargeInstance.Name = recurringCharge.Name;
                flatRateRecurringChargeInstance.Description = recurringCharge.Description;
                flatRateRecurringChargeInstance.DisplayName = recurringCharge.DisplayName;
                flatRateRecurringChargeInstance.ChargePerParticipant = recurringCharge.ChargePerParticipant;


                flatRateRecurringChargeInstances.Add(flatRateRecurringChargeInstance);
              }
            }
            else
            {
              m_Logger.LogDebug("Flat Rate Recurring Charges not found");
            }
          }
          else
          {
            m_Logger.LogError(String.Format("The product offering with id '{0}' could not be found", productOfferingId));
            throw new MASBasicException("The product offering could not be found");
          }
        }
        catch (MASBasicException masBasic)
        {
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception getting flat rate recurring charge instances", comE);

          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting flat rate recurring charge instances", e);

          throw new MASBasicException("Error getting flat rate recurring charge instances");
        }
      }
    }

    [OperationCapability("Create group subscriptions")]
    [OperationCapability("Update group subscriptions")]
    public void AddGroupSubscription(ref GroupSubscription groupSubscription)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddGroupSubscription"))
      {
        try
        {
          #region Set Time Values Properly
          Subscription sub = groupSubscription as Subscription;
          AdjustTimeValues(ref sub);
          #endregion

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            // Validate
            // Validate the group subscription
            List<UDRCInstance> udrcInstances = null;
            ValidateSubscription(groupSubscription, out udrcInstances);
            ValidateGroupSubscription(true, groupSubscription);

            #region Validate Group Subscription Name

            // open the connection
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (
                IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\AccHierarchies",
                                                                             "__FIND_GROUP_SUBS_BY_NAME__"))
              {
                stmt.AddParam("%%TIMESTAMP%%", MetraTime.Now);
                stmt.AddParam("%%NAME%%", groupSubscription.Name);

                using (IMTDataReader rdr = stmt.ExecuteReader())
                {
                  // process the results
                  while (rdr.Read())
                  {
                    if (!rdr.IsDBNull(0))
                    {
                      m_Logger.LogError("Duplicate group subscription name");
                      throw new MASBasicException("Duplicate group subscription name");
                    }
                  }
                  rdr.Close();
                }

              }
            }

            #endregion

            #region Create the Group Subscription

            MTAuth.IMTSessionContext sessionContext = GetSessionContext();
            IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
            mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

            IMTGroupSubscription mtGroupSubscription = mtProductCatalog.CreateGroupSubscription();
            mtGroupSubscription.EffectiveDate = CastTimeSpan(groupSubscription.SubscriptionSpan);
            mtGroupSubscription.ProductOfferingID = groupSubscription.ProductOfferingId;
            mtGroupSubscription.ProportionalDistribution = groupSubscription.ProportionalDistribution;
            if (!groupSubscription.ProportionalDistribution)
            {
              mtGroupSubscription.DistributionAccount = groupSubscription.DiscountAccountId.Value;
            }
            mtGroupSubscription.Name = groupSubscription.Name;
            mtGroupSubscription.Description = groupSubscription.Description;
            mtGroupSubscription.SupportGroupOps = groupSubscription.SupportsGroupOperations;
            mtGroupSubscription.CorporateAccount = groupSubscription.CorporateAccountId;
            mtGroupSubscription.Cycle = CastCycle(groupSubscription.Cycle);

            DateTime startDate, endDate;

            #region Update UDRCInstance values

            if (groupSubscription.UDRCInstances != null)
            {
              // Check that the list of UDRCInstances in groupSubscription matches those in the database
              foreach (UDRCInstance udrcInstance in groupSubscription.UDRCInstances)
              {
                bool match = false;
                foreach (UDRCInstance dbUDRCInstance in udrcInstances)
                {
                  if (udrcInstance.ID == dbUDRCInstance.ID)
                  {
                    match = true;
                    break;
                  }
                }

                if (match)
                {
                  // Set recurring charge unit values
                  List<UDRCInstanceValue> udrcInstanceValues = groupSubscription.UDRCValues[udrcInstance.ID.ToString()];
                  foreach (UDRCInstanceValue udrcInstanceValue in udrcInstanceValues)
                  {
                    mtGroupSubscription.SetRecurringChargeUnitValue(udrcInstanceValue.UDRC_Id,
                                                                    udrcInstanceValue.Value,
                                                                    udrcInstanceValue.StartDate,
                                                                    udrcInstanceValue.EndDate);
                  }


                  // Set charge accounts
                  if (!udrcInstance.ChargePerParticipant)
                  {
                    GetDates(udrcInstance.ChargeAccountSpan,
                             groupSubscription.SubscriptionSpan,
                             out startDate,
                             out endDate);

                    if (!udrcInstance.ChargeAccountId.HasValue)
                    {
                      m_Logger.LogError("Missing charge account id for UDRC not marked as ChargePerParticipant");
                      throw new MASBasicException("Missing charge account id for UDRC not marked as ChargePerParticipant");
                    }

                    mtGroupSubscription.SetChargeAccount(udrcInstance.ID,
                                                         udrcInstance.ChargeAccountId.Value,
                                                         startDate,
                                                         endDate);
                  }
                }
                else
                {
                  m_Logger.LogError("Found unknown UDRC instance in group subscription");
                  throw new MASBasicException("Found unknown UDRC instance in group subscription");
                }
              }
            }

            #endregion

            #region Update Flat Rate Recurring Charge values

            List<FlatRateRecurringChargeInstance> flatRateRecurringChargeInstances = null;
            GetFlatRateRecurringChargeInstancesForPO(mtGroupSubscription.ProductOfferingID,
                                                     out flatRateRecurringChargeInstances);

            if (groupSubscription.FlatRateRecurringChargeInstances != null)
            {
              foreach (FlatRateRecurringChargeInstance flatRateRecurringChargeInstance in
                groupSubscription.FlatRateRecurringChargeInstances)
              {
                bool match = false;

                foreach (FlatRateRecurringChargeInstance dbFlatRateRecurringChargeInstance in
                  flatRateRecurringChargeInstances)
                {
                  if (dbFlatRateRecurringChargeInstance.ID == flatRateRecurringChargeInstance.ID)
                  {
                    match = true;
                    break;
                  }
                }

                if (match)
                {
                  // Set charge accounts
                  if (!flatRateRecurringChargeInstance.ChargePerParticipant)
                  {
                    GetDates(flatRateRecurringChargeInstance.ChargeAccountSpan,
                             groupSubscription.SubscriptionSpan,
                             out startDate,
                             out endDate);

                    if (!flatRateRecurringChargeInstance.ChargeAccountId.HasValue)
                    {
                      m_Logger.LogError(
                        "Missing charge account id for Flat Rate Recurring Charge not marked as ChargePerParticipant");
                      throw new MASBasicException(
                        "Missing charge account id for Flat Rate Recurring Charge not marked as ChargePerParticipant");
                    }

                    mtGroupSubscription.SetChargeAccount(flatRateRecurringChargeInstance.ID,
                                                         flatRateRecurringChargeInstance.ChargeAccountId.Value,
                                                         startDate,
                                                         endDate);
                  }
                }
                else
                {
                  m_Logger.LogError("Found unknown Flat Rate Recurring Charge instance in group subscription");
                  throw new MASBasicException("Found unknown Flat Rate Recurring Charge instance in group subscription");
                }
              }
            }

            #endregion

            mtGroupSubscription.Save();

            groupSubscription.GroupId = mtGroupSubscription.GroupID;

            #endregion

            #region Create Characteristic Values

            if (sub.CharacteristicValues != null)
            {
              if (sub.CharacteristicValues.Count > 0)
              {
                string insertStmt = "BEGIN\n";
                IMTQueryAdapter qa = new MTQueryAdapterClass();
                qa.Init(@"Queries\ProductCatalog");

                foreach (CharacteristicValue cv in groupSubscription.CharacteristicValues)
                {
                  qa.SetQueryTag("__SAVE_CHAR_VALS_FOR_SUB__");
                  qa.AddParam("%%SPEC_CHAR_VAL_ID%%", cv.SpecCharValId);
                  qa.AddParam("%%ENTITY_ID%%", mtGroupSubscription.ID);
                  qa.AddParam("%%VALUE%%", cv.Value);
                  qa.AddParam("%%START_DATE%%", groupSubscription.SubscriptionSpan.StartDate);
                  qa.AddParam("%%END_DATE%%", groupSubscription.SubscriptionSpan.EndDate);
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
                m_Logger.LogDebug("Saving characteristic value for group subscription.");
              }
            }

            #endregion

            scope.Complete();
          }

          #region Add the Group Subscription Members

          if (groupSubscription.Members != null && groupSubscription.Members.Items.Count > 0)
          {
            AddMembersToGroupSubscription(groupSubscription.GroupId.Value, groupSubscription.Members.Items);
          }

          #endregion
        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception adding group subscription", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception adding group subscription", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception adding group subscription", e);
          throw new MASBasicException("Error adding group subscription");
        }
      }
    }

    [OperationCapability("Add to group subscription")]
    public void AddMembersToGroupSubscription(int groupSubscriptionId,
                                              List<GroupSubscriptionMember> groupSubscriptionMembers)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddMembersToGroupSubscription"))
      {
        try
        {
          #region Validate Members
          List<string> validationErrors = new List<string>();
          if (!GroupSubscriptionValidator.ValidateMembers(groupSubscriptionMembers, validationErrors))
          {
            MASBasicException err = new MASBasicException("Error validating group subscription members");

            foreach (string validationError in validationErrors)
            {
              err.AddErrorMessage(validationError);
            }

            throw err;
          }
          #endregion

          MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
          mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          MTGroupSubscription mtGroupSubscription =
            mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionId);

          if (mtGroupSubscription == null)
          {
            m_Logger.LogError("Error finding group subscription");
            throw new MASBasicException("Error finding group subscription");
          }

          MTGSubMember mtGsubMember = null;
          MetraTech.Interop.MTProductCatalog.IMTCollection mtCollection =
            new MTCollection() as MetraTech.Interop.MTProductCatalog.IMTCollection;

          if (groupSubscriptionMembers.Count == 1)
          {
            mtGsubMember = new MTGSubMember();
            mtGsubMember.AccountID = groupSubscriptionMembers[0].AccountId.Value;
            mtGsubMember.StartDate = groupSubscriptionMembers[0].MembershipSpan.StartDate.Value;
            if (groupSubscriptionMembers[0].MembershipSpan.EndDate.HasValue)
            {
              mtGsubMember.EndDate = groupSubscriptionMembers[0].MembershipSpan.EndDate.Value;
            }

            mtGroupSubscription.AddAccount(mtGsubMember);

          }
          else
          {
            foreach (GroupSubscriptionMember groupSubMember in groupSubscriptionMembers)
            {
              mtGsubMember = new MTGSubMember();
              mtGsubMember.AccountID = groupSubMember.AccountId.Value;
              mtGsubMember.StartDate = groupSubMember.MembershipSpan.StartDate.Value;
              if (groupSubMember.MembershipSpan.EndDate.HasValue)
              {
                mtGsubMember.EndDate = groupSubMember.MembershipSpan.EndDate.Value;
              }
              mtCollection.Add(mtGsubMember);
            }

            bool modified;
            MetraTech.Interop.MTProductCatalog.IMTRowSet errorRowset =
                mtGroupSubscription.AddAccountBatch(mtCollection, null, out modified, null);

            if (errorRowset.RecordCount > 0)
            {
              StringBuilder errorString = new StringBuilder();
              string curError = "Error adding group subscription members";
              m_Logger.LogError(curError);
              errorString.Append(curError + "<br/>");

              while (!System.Convert.ToBoolean(errorRowset.EOF))
              {
                curError = "Account " +
                    ((int)errorRowset.get_Value("id_acc")).ToString() +
                    ": " +
                    (string)errorRowset.get_Value("description");

                m_Logger.LogError(curError);
                errorString.Append("<li>" + curError + "</li>");

                errorRowset.MoveNext();
              }
              errorRowset.MoveFirst();
              throw new MASBasicException(errorString.ToString());
            }
          }

        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception adding members to group subscription", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception adding members to group subscription", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception adding members to group subscription", e);
          throw new MASBasicException("Error adding members to group subscription");
        }
      }
    }

    [OperationCapability("Add to group subscription")]
    public void AddMemberHierarchiesToGroupSubscription(int groupSubscriptionId,
                                        ProdCatTimeSpan subscriptionSpan,
                                        Dictionary<AccountIdentifier, AccountTemplateScope> accounts)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddMemberHierarchiesToGroupSubscription"))
      {
        Dictionary<int, GroupSubscriptionMember> groupSubMembers = new Dictionary<int, GroupSubscriptionMember>();

        foreach (KeyValuePair<AccountIdentifier, AccountTemplateScope> kvp in accounts)
        {
          int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(kvp.Key);

          if (kvp.Value == AccountTemplateScope.CURRENT_FOLDER)
          {
            if (!groupSubMembers.ContainsKey(acctId))
            {
              GroupSubscriptionMember subMember = new GroupSubscriptionMember();
              subMember.GroupId = groupSubscriptionId;
              subMember.AccountId = acctId;
              subMember.MembershipSpan = subscriptionSpan;

              groupSubMembers.Add(acctId, subMember);
            }
          }
          else
          {
            IMTYAAC templateYAAC = new MTYAACClass();
            templateYAAC.InitAsSecuredResource(acctId, (YAAC.IMTSessionContext)GetSessionContext(), MetraTime.Now);

            YAAC.IMTCollection accountCol = (YAAC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();
            YAAC.MTHierarchyPathWildCard wildCard = ((YAAC.MTHierarchyPathWildCard)((int)kvp.Value));

            templateYAAC.GetDescendents(accountCol, MetraTime.Now, wildCard, true, System.Reflection.Missing.Value);

            foreach (int childId in accountCol)
            {
              if (!groupSubMembers.ContainsKey(childId))
              {
                GroupSubscriptionMember subMember = new GroupSubscriptionMember();
                subMember.GroupId = groupSubscriptionId;
                subMember.AccountId = childId;
                subMember.MembershipSpan = subscriptionSpan;

                groupSubMembers.Add(childId, subMember);
              }
            }

          }
        }

        List<GroupSubscriptionMember> groupSubscriptionMembers = new List<GroupSubscriptionMember>();
        groupSubscriptionMembers.AddRange(groupSubMembers.Values);

        AddMembersToGroupSubscription(groupSubscriptionId, groupSubscriptionMembers);
      }
    }

    [OperationCapability("Modify groupsub membership")]
    public void DeleteMembersFromGroupSubscription(int groupSubscriptionId,
                                                   List<GroupSubscriptionMember> groupSubscriptionMembers)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteMembersFromGroupSubscription"))
      {
        try
        {
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
          mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          MTGroupSubscription mtGroupSubscription =
            mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionId);

          if (mtGroupSubscription == null)
          {
            m_Logger.LogError("Error finding group subscription");
            throw new MASBasicException("Error finding group subscription");
          }


          MTGSubMember mtGsubMember = null;
          MetraTech.Interop.MTProductCatalog.IMTCollection mtCollection =
            new MTCollection() as MetraTech.Interop.MTProductCatalog.IMTCollection;

          foreach (GroupSubscriptionMember groupSubMember in groupSubscriptionMembers)
          {
            mtGsubMember = new MTGSubMember();
            if (!groupSubMember.AccountId.HasValue)
            {
              m_Logger.LogError("Missing account id in group subscription member");
              throw new MASBasicException("Missing account id in group subscription member");
            }
            mtGsubMember.AccountID = groupSubMember.AccountId.Value;
            mtCollection.Add(mtGsubMember);
          }

          MetraTech.Interop.MTProductCatalog.IMTRowSet errorRowset =
            mtGroupSubscription.DeleteMemberBatch(mtCollection, null);

          if (errorRowset.RecordCount > 0)
          {
            m_Logger.LogError("Error deleting group subscription members");

            while (!System.Convert.ToBoolean(errorRowset.EOF))
            {
              m_Logger.LogError((string)errorRowset.get_Value("description"));
              errorRowset.MoveNext();
            }

            errorRowset.MoveFirst();
            throw new MASBasicException((string)errorRowset.get_Value("description"));
            // throw new MASBasicException("Error deleting group subscription members");

          }
        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception deleting members from group subscription", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception deleting members from group subscription", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception deleting members from group subscription", e);
          throw new MASBasicException("Error deleting members from group subscription");
        }
      }
    }


    [OperationCapability("Modify groupsub membership")]
    public void UpdateGroupSubscriptionMember(GroupSubscriptionMember groupSubscriptionMember)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateGroupSubscriptionMember"))
      {
        bool save = false;

        try
        {
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();

          IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
          mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          MTGroupSubscription mtGroupSubscription = mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionMember.GroupId.Value);

          if (mtGroupSubscription == null)
          {
            m_Logger.LogError("Error finding group subscription");
            throw new MASBasicException("Error finding group subscription");
          }

          MTGSubMember mtGroupSubMember = new MTGSubMember();
          mtGroupSubMember = mtGroupSubscription.FindMember(groupSubscriptionMember.AccountId.Value, groupSubscriptionMember.MembershipSpan.StartDate.Value);

          if (mtGroupSubMember == null)
          {
            m_Logger.LogError("Error finding group subscription member");
            throw new MASBasicException("Error finding group subscription member");
          }


          // if fields are dirty
          if (groupSubscriptionMember.MembershipSpan.IsStartDateDirty)
          {
            if (groupSubscriptionMember.MembershipSpan.StartDate.HasValue)
            {
              mtGroupSubMember.StartDate = groupSubscriptionMember.MembershipSpan.StartDate.Value;
              save = true;
            }

          }

          if (groupSubscriptionMember.MembershipSpan.IsEndDateDirty)
          {
            if (groupSubscriptionMember.MembershipSpan.EndDate.HasValue)
            {
              mtGroupSubMember.EndDate = groupSubscriptionMember.MembershipSpan.EndDate.Value;
              save = true;
            }
          }

          mtGroupSubscription.ModifyMembership(mtGroupSubMember);
          if (save)
          {
            mtGroupSubscription.Save();
          }


        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception updating group subscription member", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception updating group subscription member", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception updating group subscription member", e);
          throw new MASBasicException("Error updating group subscription member");
        }
      }
    }


    [OperationCapability("Modify groupsub membership")]
    public void UnsubscribeGroupSubscriptionMembers(List<GroupSubscriptionMember> groupSubscriptionMembers)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UnsubscribeGroupSubscriptionMembers"))
      {
        /* MTAuth.IMTSessionContext sessionContext = GetSessionContext();
         IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
         mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

         MTGroupSubscription mtGroupSubscription = mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionMember.GroupId.Value);

         if (mtGroupSubscription == null)
         {
             m_Logger.LogError("Error finding group subscription");
             throw new MASBasicException("Error finding group subscription");
         }

         MTGSubMember mtGroupSubMember = new MTGSubMember();
         mtGroupSubMember = mtGroupSubscription.FindMember(groupSubscriptionMember.AccountId.Value,
                                                                        groupSubscriptionMember.MembershipSpan.
                                                                            StartDate.Value);

         if(mtGroupSubMember == null)
         {
             m_Logger.LogError("Error finding group subscription member");
             throw new MASBasicException("Error finding group subscription member");
         }

         MTProductOffering prodOffering = mtGroupSubscription.GetProductOffering();
         if (prodOffering.EffectiveDate.EndDate != null)
         {
             mtGroupSubMember.EndDate = prodOffering.EffectiveDate.EndDate;
         }

         mtGroupSubscription.UnsubscribeMember(mtGroupSubMember);
              
         mtGroupSubscription.Save();*/


        try
        {
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
          mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);


          MTGSubMember mtGsubMember = null;
          MetraTech.Interop.MTProductCatalog.IMTCollection mtCollection =
            new MTCollection() as MetraTech.Interop.MTProductCatalog.IMTCollection;

          MTGroupSubscription mtGroupSubscription = mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionMembers[0].GroupId.Value);

          if (mtGroupSubscription == null)
          {
            m_Logger.LogError("Error finding group subscription");
            throw new MASBasicException("Error finding group subscription");
          }

          foreach (GroupSubscriptionMember groupSubMember in groupSubscriptionMembers)
          {
            mtGsubMember = new MTGSubMember();
            if (!groupSubMember.AccountId.HasValue)
            {
              m_Logger.LogError("Missing account id in group subscription member");
              throw new MASBasicException("Missing account id in group subscription member");
            }
            mtGsubMember.AccountID = groupSubMember.AccountId.Value;
            mtGsubMember.AccountName = groupSubMember.AccountName;
            mtGsubMember.StartDate = groupSubMember.MembershipSpan.StartDate.Value;
            mtGsubMember.EndDate = groupSubMember.MembershipSpan.EndDate.Value;
            mtCollection.Add(mtGsubMember);
          }

          MetraTech.Interop.MTProductCatalog.IMTRowSet errorRowset =
            mtGroupSubscription.UnsubscribeMemberBatch(mtCollection, null);

          if (errorRowset.RecordCount > 0)
          {
            m_Logger.LogError("Error unsubscribing group subscription members");

            while (!System.Convert.ToBoolean(errorRowset.EOF))
            {
              m_Logger.LogError((string)errorRowset.get_Value("description"));
              errorRowset.MoveNext();
            }

            errorRowset.MoveFirst();
            throw new MASBasicException((string)errorRowset.get_Value("description"));
            // throw new MASBasicException("Error unsubscribing group subscription members");
          }

        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception unsubscribing group subscription members", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception unsubscribing group subscription members", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception unsubscribing group subscription members", e);
          throw new MASBasicException("Error unsubscribing group subscription members");
        }
      }
    }


    [OperationCapability("Update group subscriptions")]
    public void UpdateGroupSubscription(GroupSubscription groupSubscription)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateGroupSubscription"))
      {
        try
        {
          // Retrieve the existing group subscription
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
          mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          MTGroupSubscription mtGroupSubscription =
            mtProductCatalog.GetGroupSubscriptionByID(groupSubscription.GroupId.Value);
          mtGroupSubscription.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          if (mtGroupSubscription == null)
          {
            m_Logger.LogError("Error finding group subscription");
            throw new MASBasicException("Error finding group subscription");
          }

          GroupSubscription existingGroupSub;
          GetGroupSubscriptionDetail(groupSubscription.GroupId.Value, out existingGroupSub);

          if (existingGroupSub == null)
          {
            m_Logger.LogError("Error finding group subscription");
            throw new MASBasicException("Error finding group subscription");
          }

          Subscription sub = groupSubscription as Subscription;
          AdjustTimeValues(ref sub);

          #region Validate
          ValidateGroupSubscription(false, groupSubscription);

          IMTPCAccount pcAcct = mtProductCatalog.GetAccount(groupSubscription.CorporateAccountId);

          if (existingGroupSub.SubscriptionSpan.StartDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod &&
              pcAcct.GetNextBillingIntervalEndDate(existingGroupSub.SubscriptionSpan.StartDate.Value) == null)
          {
            throw new MASBasicException("Owner account does not have a available billing period after the start date");
          }

          if (existingGroupSub.SubscriptionSpan.EndDate != null &&
              existingGroupSub.SubscriptionSpan.EndDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod &&
              pcAcct.GetNextBillingIntervalEndDate(existingGroupSub.SubscriptionSpan.EndDate.Value) == null)
          {
            throw new MASBasicException("Owner account does not have a available billing period after the end date");
          }
          #endregion

          bool save = false;

          #region Discount
          if (groupSubscription.IsProportionalDistributionDirty)
          {
            save = true;
            mtGroupSubscription.ProportionalDistribution = groupSubscription.ProportionalDistribution;
            if (!groupSubscription.ProportionalDistribution)
            {
              if (!groupSubscription.DiscountAccountId.HasValue)
              {
                m_Logger.LogError("Missing account for discount charge");
                throw new MASBasicException("Missing account for discount charge");
              }
              else
              {
                if (groupSubscription.IsDiscountAccountIdDirty)
                {
                  mtGroupSubscription.DistributionAccount = groupSubscription.DiscountAccountId.Value;

                }
              }
            }

          }
          #endregion

          #region Name
          if (groupSubscription.IsNameDirty)
          {
            save = true;
            mtGroupSubscription.Name = groupSubscription.Name;
          }
          #endregion

          #region Description
          if (groupSubscription.IsDescriptionDirty)
          {
            save = true;
            mtGroupSubscription.Description = groupSubscription.Description;
          }
          #endregion

          #region SupportsGroupOperations
          if (groupSubscription.IsSupportsGroupOperationsDirty)
          {
            save = true;
            mtGroupSubscription.SupportGroupOps = groupSubscription.SupportsGroupOperations;
          }
          #endregion

          #region
          if (groupSubscription.IsCycleDirty)
          {
            save = true;
            mtGroupSubscription.Cycle = CastCycle(groupSubscription.Cycle);
          }
          #endregion


          #region StartDate
          if (groupSubscription.SubscriptionSpan.IsStartDateDirty)
          {
            save = true;
            mtGroupSubscription.EffectiveDate.StartDate = groupSubscription.SubscriptionSpan.StartDate.Value;
          }
          #endregion

          #region EndDate
          if (groupSubscription.SubscriptionSpan.IsEndDateDirty)
          {
            save = true;
            mtGroupSubscription.EffectiveDate.EndDate = groupSubscription.SubscriptionSpan.EndDate.Value;
          }
          #endregion


          #region UDRC Charge Accounts
          if (groupSubscription.IsUDRCInstancesDirty && groupSubscription.UDRCInstances != null)
          {
            save = true;

            // Set the ID to 0 so that the changes are stored in memory
            mtGroupSubscription.ID = 0;

            foreach (UDRCInstance udrcInstance in groupSubscription.UDRCInstances)
            {
              if (!udrcInstance.ChargePerParticipant)
              {
                mtGroupSubscription.SetChargeAccount(udrcInstance.ID, udrcInstance.ChargeAccountId.Value,
                                                     udrcInstance.ChargeAccountSpan.StartDate.Value,
                                                     udrcInstance.ChargeAccountSpan.EndDate.Value);
              }
            }

            // Restore the ID so that it get saved properly
            mtGroupSubscription.ID = groupSubscription.GroupId.Value;
          }
          #endregion

          #region Flat Rate Recurring Charge Accounts
          if (groupSubscription.IsFlatRateRecurringChargeInstancesDirty && groupSubscription.FlatRateRecurringChargeInstances != null)
          {
            save = true;

            // Set the ID to 0 so that the changes are stored in memory
            mtGroupSubscription.ID = 0;

            foreach (FlatRateRecurringChargeInstance frrcInstance in groupSubscription.FlatRateRecurringChargeInstances)
            {
              if (!frrcInstance.ChargePerParticipant)
              {
                mtGroupSubscription.SetChargeAccount(frrcInstance.ID, frrcInstance.ChargeAccountId.Value,
                                                     frrcInstance.ChargeAccountSpan.StartDate.Value,
                                                     frrcInstance.ChargeAccountSpan.EndDate.Value);
              }
            }

            // Restore the ID so that it get saved properly
            mtGroupSubscription.ID = groupSubscription.GroupId.Value;
          }
          #endregion

          #region UDRCInstanceValues
          if (groupSubscription.IsUDRCValuesDirty && groupSubscription.UDRCValues != null)
          {
            save = true;

            // Set the ID to 0 so that the UDRC value changes are stored in memory
            mtGroupSubscription.ID = 0;


            MTTemporalList<UDRCInstanceValue> temporalList;
            foreach (KeyValuePair<string, List<UDRCInstanceValue>> kvp in groupSubscription.UDRCValues)
            {
              temporalList = new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate");

              // if the existing sub has UDRC values for this instance, load them and
              // assert the new values to be true via a MTTemporalList
              if (existingGroupSub.UDRCValues.ContainsKey(kvp.Key) && existingGroupSub.UDRCValues[kvp.Key] != null)
              {
                List<UDRCInstanceValue> existingValues = existingGroupSub.UDRCValues[kvp.Key];
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
                ((IMTSubscriptionBase)mtGroupSubscription).ID = existingGroupSub.SubscriptionId.Value;
                mtGroupSubscription.SetRecurringChargeUnitValue(val.UDRC_Id, val.Value, val.StartDate, val.EndDate);
              }
            }

            // Restore the ID so that it get saved properly
            mtGroupSubscription.ID = groupSubscription.GroupId.Value;
          }
          #endregion


          if (save)
          {
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
              mtGroupSubscription.Save();

              #region Update Characteristic Values

              if (groupSubscription.CharacteristicValues != null)
              {
                if (groupSubscription.CharacteristicValues.Count > 0)
                {
                  string insertStmt = "BEGIN\n";
                  IMTQueryAdapter qa = new MTQueryAdapterClass();
                  qa.Init(@"Queries\ProductCatalog");

                  foreach (CharacteristicValue cv in groupSubscription.CharacteristicValues)
                  {
                    qa.SetQueryTag("__UPDATE_CHAR_VALS_FOR_SUB__");
                    qa.AddParam("%%VALUE%%", cv.Value);
                    qa.AddParam("%%SPEC_CHAR_VAL_ID%%", cv.SpecCharValId);
                    qa.AddParam("%%ENTITY_ID%%", groupSubscription.SubscriptionId.Value);
                    insertStmt += qa.GetQuery().Trim() + ";\n";
                  }

                  insertStmt += "END;";
                  m_Logger.LogDebug(insertStmt);
                  using (IMTConnection conn = ConnectionManager.CreateConnection("queries\\ProductCatalog"))
                  using (IMTStatement stmt = conn.CreateStatement(insertStmt))
                  {
                    stmt.ExecuteNonQuery();
                  }
                  m_Logger.LogDebug("Saving characteristic value for group subscription.");
                }
              }

              #endregion

              scope.Complete();
            }
          }
        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception updating group subscription", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception updating group subscription", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception updating group subscription", e);
          throw new MASBasicException("Error updating group subscription");
        }
      }
    }

    [OperationCapability("View group subscriptions")]
    public void GetCharacteristicValuesForGroupSub(ref MTList<CharacteristicValue> charVals)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetCharacteristicValuesForGroupSub"))
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
                  PropertyType specType = (PropertyType)EnumHelper.GetEnumByValue(typeof(PropertyType), dataReader.GetInt32("SpecType").ToString());
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

    #region Private Members

    private void ValidateGroupSubscription(bool creating, GroupSubscription groupSubscription)
    {
      GroupSubscriptionValidator validator = new GroupSubscriptionValidator();
      List<string> validationErrors = null;
      if (!validator.Validate(groupSubscription, creating, out validationErrors))
      {
        MASBasicException err = new MASBasicException("Error validating group subscription");

        foreach (string validationError in validationErrors)
        {
          err.AddErrorMessage(validationError);
        }

        throw err;
      }
    }

    private void PopulateGroupSubscription(IMTGroupSubscription mtGroupSub,
                                           IMTProductCatalog mtProductCatalog,
                                           out GroupSubscription groupSubscription)
    {
      groupSubscription = null;
      ProductOffering productOffering = null;
      groupSubscription = new GroupSubscription();
      groupSubscription.GroupId = mtGroupSub.GroupID;
      groupSubscription.Name = mtGroupSub.Name;
      groupSubscription.Description = mtGroupSub.Description;
      groupSubscription.CorporateAccountId = mtGroupSub.CorporateAccount;
      groupSubscription.SubscriptionSpan = CastTimeSpan(mtGroupSub.EffectiveDate);
      groupSubscription.SubscriptionId = mtGroupSub.ID;
      groupSubscription.ProductOfferingId = mtGroupSub.ProductOfferingID;
      groupSubscription.ProportionalDistribution = mtGroupSub.ProportionalDistribution;
      groupSubscription.SupportsGroupOperations = mtGroupSub.SupportGroupOps;
      if (!groupSubscription.ProportionalDistribution)
      {
        groupSubscription.DiscountAccountId = mtGroupSub.DistributionAccount;
      }
      groupSubscription.Cycle = CastCycle(mtGroupSub.Cycle);


      #region Initialize product offering
      productOffering = GetProductOffering(mtGroupSub.ProductOfferingID);

      if (productOffering != null)
      {
        productOffering.HasRecurringCharges = mtGroupSub.HasRecurringCharges;
        productOffering.HasDiscounts = mtGroupSub.HasDiscounts;
        productOffering.HasPersonalRates = mtGroupSub.HasPersonalRates;

        groupSubscription.ProductOffering = productOffering;
        //groupSubscription.ProductOffering = ConfigureUsageCycleTypeForProductOffering(mtGroupSub.ProductOfferingID);
      }
      else
      {
        m_Logger.LogError(String.Format("The product offering with id '{0}' could not be found", mtGroupSub.ProductOfferingID));
        throw new MASBasicException("The product offering could not be found");
      }
      #endregion

      #region Initialize discount distribution
      IMTProductOffering mtProductOffering = mtProductCatalog.GetProductOffering(mtGroupSub.ProductOfferingID);
      MTDistributionRequirementType distributionType = mtProductOffering.GetDistributionRequirement();
      switch (distributionType)
      {
        case MTDistributionRequirementType.DISTRIBUTION_REQUIREMENT_TYPE_NONE:
          {
            groupSubscription.DiscountDistribution = DiscountDistribution.None;
            break;
          }
        case MTDistributionRequirementType.DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT:
          {
            groupSubscription.DiscountDistribution = DiscountDistribution.Account;
            break;
          }
        case MTDistributionRequirementType.DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT_OR_PROPORTIONAL:
          {
            groupSubscription.DiscountDistribution = DiscountDistribution.AccountOrProportional;
            break;
          }
        default:
          {
            m_Logger.LogError("Unknown distribution requirement");
            throw new MASBasicException("Unknown distribution requirement");
          }
      }
      #endregion
    }

    #region Private Members
    private GroupSubscription PopulateGroupSubscription(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData, IMTDataReader rdr, bool isOracle)
    {
      GroupSubscription gsub = new GroupSubscription();
      ProductOffering prodOffering = new ProductOffering();
      Type poType = prodOffering.GetType();


      string fieldName = "", propName = "";
      PropertyInfo propInfo;
      for (int i = 0; i < rdr.FieldCount; i++)
      {
        fieldName = rdr.GetName(i);

        switch (fieldName)
        {
          case "id_sub":
            if (!rdr.IsDBNull(i))
            {
              gsub.SubscriptionId = rdr.GetInt32(i);
            }
            break;

          case "id_group":
            if (!rdr.IsDBNull(i))
            {
              gsub.GroupId = rdr.GetInt32(i);
            }
            break;

          case "id_po":
            if (!rdr.IsDBNull(i))
            {
              gsub.ProductOfferingId = rdr.GetInt32(i);
            }
            break;

          case "vt_start":
            if (!rdr.IsDBNull(i))
            {
              gsub.SubscriptionSpan.StartDate = rdr.GetDateTime(i);
            }
            break;

          case "vt_end":
            if (!rdr.IsDBNull(i))
            {
              gsub.SubscriptionSpan.EndDate = rdr.GetDateTime(i);
            }
            break;

          case "usage_cycle":
            if (!rdr.IsDBNull(i))
            {
              gsub.UsageCycleId = rdr.GetInt32(i);
            }
            break;

          case "tx_name":
            gsub.Name = rdr.GetString(i);
            break;

          case "tx_desc":
            if (!rdr.IsDBNull(i))
            {
              gsub.Description = rdr.GetString(i);
            }
            break;

          case "b_proportional":
            if (!rdr.IsDBNull(i))
            {
              gsub.ProportionalDistribution = rdr.GetBoolean(i);
            }
            break;

          case "corporate_account":
            if (!rdr.IsDBNull(i))
            {
              gsub.CorporateAccountId = rdr.GetInt32(i);
            }
            break;

          case "discount_account":
            if (!gsub.ProportionalDistribution)
            {
              if (!rdr.IsDBNull(i))
              {
                gsub.DiscountAccountId = rdr.GetInt32(i);
              }
            }
            break;


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
              propInfo = poType.GetProperty(propName, BindingFlags.IgnoreCase | BindingFlags.Instance | BindingFlags.Public);

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

                    propInfo.SetValue(prodOffering, mtEnum, null);
                  }
                }
                else
                if (!rdr.IsDBNull(i))
                {
                    //ESR-5743 Get Group SubscriptionList fails when Extended PO properties contains a boolean column
                    if (isOracle &&
                        (propInfo.PropertyType == typeof (System.Boolean) ||
                            propInfo.PropertyType == typeof (bool?)))
                    {
                        var temp = rdr.GetValue(i).ToString();
                        if (temp == "Y" || temp == "1")
                        {
                            propInfo.SetValue(prodOffering, true, null);
                        }

                        if (temp == "N" || temp == "0")
                        {
                            propInfo.SetValue(prodOffering, false, null);
                        }

                    }
                    else
                        if (propInfo.PropertyType == typeof (System.Boolean) ||
                            propInfo.PropertyType == typeof (bool?))
                        {
                            var tmp = false;
                            if (System.Boolean.TryParse(rdr.GetValue(i).ToString(), out tmp))
                            {
                                propInfo.SetValue(prodOffering, rdr.GetValue(i), null);
                            }
                            else
                            {
                                var temp = rdr.GetValue(i).ToString();
                                if (temp == "Y" || temp == "1")
                                {
                                    propInfo.SetValue(prodOffering, true, null);
                                }

                                if (temp == "N" || temp == "0")
                                {
                                    propInfo.SetValue(prodOffering, false, null);
                                }

                            }
                        }
                else if (propInfo.PropertyType.FullName.Contains("Decimal"))
                {
                    propInfo.SetValue(prodOffering, rdr.GetDecimal(i), null);
                }
                else if (propInfo.PropertyType.FullName.Contains("Double"))
                {
                    propInfo.SetValue(prodOffering, rdr.GetDecimal(i), null);
                }
                else if (propInfo.PropertyType.FullName.Contains("Float"))
                {
                    propInfo.SetValue(prodOffering, rdr.GetDecimal(i), null);
                }
                else if (propInfo.PropertyType.FullName.Contains("Int64"))
                {
                    propInfo.SetValue(prodOffering, rdr.GetInt64(i), null);
                }
                else if (propInfo.PropertyType.FullName.Contains("String"))
                {
                    propInfo.SetValue(prodOffering, rdr.GetString(i), null);
                }
                else if (propInfo.PropertyType.FullName.Contains("Int32"))
                {
                    propInfo.SetValue(prodOffering, rdr.GetInt32(i), null);
                }
                else if (propInfo.PropertyType.FullName.Contains("DateTime"))
                {
                    propInfo.SetValue(prodOffering, rdr.GetDateTime(i), null);
                }
            }
              }
            }
            break;
          #endregion

        }

      }

      //gsub.Cycle = CastCycle(mtGroupSub.Cycle); usage_cycle

      #region Initialize product offering
      prodOffering = GetProductOffering(gsub.ProductOfferingId);


      if (prodOffering != null)
      {
        //prodOffering.HasRecurringCharges = mtGroupSub.HasRecurringCharges;
        //productOffering.HasDiscounts = mtGroupSub.HasDiscounts;
        //productOffering.HasPersonalRates = mtGroupSub.HasPersonalRates;

        gsub.ProductOffering = prodOffering;
      }
      else
      {
        m_Logger.LogError(String.Format("The product offering with id '{0}' could not be found", gsub.ProductOfferingId));
        throw new MASBasicException("The product offering could not be found");
      }
      #endregion

      #region Initialize discount distribution
      IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
      IMTProductOffering mtProductOffering = mtProductCatalog.GetProductOffering(gsub.ProductOfferingId);
      MTDistributionRequirementType distributionType = mtProductOffering.GetDistributionRequirement();
      switch (distributionType)
      {
        case MTDistributionRequirementType.DISTRIBUTION_REQUIREMENT_TYPE_NONE:
          {
            gsub.DiscountDistribution = DiscountDistribution.None;
            break;
          }
        case MTDistributionRequirementType.DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT:
          {
            gsub.DiscountDistribution = DiscountDistribution.Account;
            break;
          }
        case MTDistributionRequirementType.DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT_OR_PROPORTIONAL:
          {
            gsub.DiscountDistribution = DiscountDistribution.AccountOrProportional;
            break;
          }
        default:
          {
            m_Logger.LogError("Unknown distribution requirement");
            throw new MASBasicException("Unknown distribution requirement");
          }
      }
      #endregion


      return gsub;
    }
    #endregion





    private void GetDates(ProdCatTimeSpan chargeTimeSpan,
                    ProdCatTimeSpan groupSubTimeSpan,
                    out DateTime startDate,
                    out DateTime endDate)
    {
      startDate = MetraTime.Min;
      endDate = MetraTime.Max;

      if (chargeTimeSpan == null && groupSubTimeSpan == null)
      {
        return;
      }

      if (chargeTimeSpan.StartDate.HasValue)
      {
        startDate = chargeTimeSpan.StartDate.Value;
      }
      else if (groupSubTimeSpan.StartDate.HasValue)
      {
        startDate = groupSubTimeSpan.StartDate.Value;
      }

      if (chargeTimeSpan.EndDate.HasValue)
      {
        endDate = chargeTimeSpan.EndDate.Value;
      }
      else if (groupSubTimeSpan.EndDate.HasValue)
      {
        endDate = groupSubTimeSpan.EndDate.Value;
      }
    }
    #endregion

    #region Delete Group Subscription
    [OperationCapability("Update group subscriptions")]
    public void DeleteGroupSubscription(int groupSubscriptionId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteGroupSubscription"))
      {
        try
        {
          // Retrieve the existing group subscription
          MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
          mtProductCatalog.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          MTGroupSubscription mtGroupSubscription =
            mtProductCatalog.GetGroupSubscriptionByID(groupSubscriptionId);
          mtGroupSubscription.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

          if (mtGroupSubscription == null)
          {
            m_Logger.LogError("Error finding group subscription");
            throw new MASBasicException("Error finding group subscription");
          }

          mtProductCatalog.DeleteGroupSubscription(groupSubscriptionId);


        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception deleting group subscription", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception deleting group subscription", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception deleting group subscription", e);
          throw new MASBasicException("Error deleting group subscription");
        }
      }
    }

    #endregion

    public void GetMemberInfoForGroupSubscription(int groupSubscriptionId, int memberId,
                                     ref GroupSubscriptionMember memberInfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetMemberInfoForGroupSubscription"))
      {
        // Get the session context from the WCF ambient service security context
        MTAuth.IMTSessionContext sessionContext = GetSessionContext();

        string selectlist;
        string joinlist;
        var metaData = GetProductOfferingMetaData(out selectlist, out joinlist);

        try
        {
          IMTQueryAdapter qa = new MTQueryAdapter();
          qa.Init("queries\\AccHierarchies");
          qa.SetQueryTag("__FIND_GSUB_MEMBER_BY_ID_NO_DATES__");
          string txInfo = qa.GetQuery();
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(txInfo))
            {
              stmt.AddParam("id_group", MTParameterType.Integer, groupSubscriptionId);
              stmt.AddParam("id_acc", MTParameterType.Integer, memberId);
              // execute the query
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                // process the results
                while (rdr.Read())
                {
                  memberInfo = PopulateGroupSubscriptionMember(metaData, rdr, groupSubscriptionId);
                }
              }
            }
          }
        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception getting members for group subscription", masBasic);
          throw;
        }
        catch (COMException comE)
        {
          {
            m_Logger.LogException("COM Exception getting group subscription member", comE);
            throw new MASBasicException(comE.Message);
          }

        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting group subscription member", e);
          throw new MASBasicException("Error getting group subscription member");
        }
      }
    }

    [OperationCapability("View group subscriptions")]
    public void GetMembersForGroupSubscription2(int groupSubscriptionId,
                                               ref MTList<GroupSubscriptionMember> groupSubscriptionMembers)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetMembersForGroupSubscription2"))
      {
        // Get the session context from the WCF ambient service security context
        MTAuth.IMTSessionContext sessionContext = GetSessionContext();

        string selectlist;
        string joinlist;
        var metaData = GetProductOfferingMetaData(out selectlist, out joinlist);

        #region Get the list of group subscription members
        try
        {
          // open the connection
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            // Get a filter/sort statement
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\AccHierarchies", "__FIND_GSUB_MEMBERS_NO_DATE_"))
            {

              // Set the parameters
              stmt.AddParam("%%ID_GROUP%%", groupSubscriptionId);

              ApplyFilterSortCriteria<GroupSubscriptionMember>(stmt, groupSubscriptionMembers, new FilterColumnResolver(GetColumnNameFromGroupSubMemberPropertyName), metaData);

              // execute the query
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                GroupSubscriptionMember grpSubMember = null;
                // process the results
                while (rdr.Read())
                {
                  grpSubMember = PopulateGroupSubscriptionMember(metaData, rdr, groupSubscriptionId);
                  groupSubscriptionMembers.Items.Add(grpSubMember);
                  groupSubscriptionMembers.TotalRows++;

                }

                // get the total rows that would be returned without paging
                groupSubscriptionMembers.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (MASBasicException masBasic)
        {
          m_Logger.LogException("Exception getting members for group subscription", masBasic);
          throw masBasic;
        }
        catch (COMException comE)
        {
          if (comE.Message == "Unable to populate group subscription membership collection")
          {
            groupSubscriptionMembers = new MTList<GroupSubscriptionMember>();

          }
          else
          {
            m_Logger.LogException("COM Exception getting members for group subscription", comE);
            throw new MASBasicException(comE.Message);
          }

        }
        catch (Exception e)
        {
          groupSubscriptionMembers.Items.Clear();
          m_Logger.LogException("Exception getting members for group subscription", e);
          throw new MASBasicException("Error getting members for group subscription");
        }
        #endregion
      }
    }

    private string GetColumnNameFromGroupSubMemberPropertyName(string propName, ref object filterVal, object helper)
    {
      MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData = (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet)helper;

      if ((propName.IndexOf("#") > 0) && (propName.IndexOf("#") < propName.Length))
      {
        propName = propName.Substring(propName.IndexOf("#") + 1);
      }
      switch (propName)
      {

        case "AccountId":
          return "id_acc";
          break;

        case "GroupId":
          return "id_group";
          break;

        case "AccountName":
          return "acc_name";
          break;

        case "MembershipSpan_StartDate":
        case "MembershipSpan.StartDate":
        case "StartDate":
          return "vt_start";
          break;

        case "MembershipSpan_EndDate":
        case "MembershipSpan.EndDate":
        case "EndDate":
          return "vt_end";
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

      };
    }


    private GroupSubscriptionMember PopulateGroupSubscriptionMember(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaData, IMTDataReader rdr, int groupId)
    {
      GroupSubscriptionMember gsubMember = new GroupSubscriptionMember();
      gsubMember.MembershipSpan = new ProdCatTimeSpan();

      string fieldName = "", propName = "";
      for (int i = 0; i < rdr.FieldCount; i++)
      {
        fieldName = rdr.GetName(i);

        switch (fieldName)
        {
          case "id_acc":
            gsubMember.AccountId = rdr.GetInt32(i);
            break;

          case "vt_start":
            if (!rdr.IsDBNull(i))
            {
              gsubMember.MembershipSpan.StartDate = rdr.GetDateTime(i);
            }
            break;

          case "vt_end":
            if (!rdr.IsDBNull(i))
            {
              gsubMember.MembershipSpan.EndDate = rdr.GetDateTime(i);
            }
            break;

          case "acc_name":
            gsubMember.AccountName = rdr.GetString(i);
            break;

          default:
            propName = fieldName;
            break;

        }
      }
      gsubMember.GroupId = groupId;
      return gsubMember;
    }


    private void GetCorporateAccount(int accountID, DateTime effDate, out int corporateID)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
            "\\Queries\\AccHierarchies", "__GET_CORPORATE_ACCOUNT_OF_CURRENT_ACCOUNT__"))
        {
          stmt.AddParam("%%ID_ACC%%", accountID);

          stmt.AddParam("%%EFF_DATE%%", MetraTime.FormatAsODBC(effDate), true);


          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            if (reader.Read())
              corporateID = reader.GetInt32("id_ancestor");
            else
              throw new ApplicationException(string.Format("Unable to get corporate account for account {0} as of {1}", accountID, effDate));
          }
        }
      }
    }

    private ProductOffering ConfigureUsageCycleTypeForProductOffering(int productOfferingId)
    {
      ProductOffering po = GetProductOffering(productOfferingId);
      try
      {
        // open the connection
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          // Get a filter/sort statement
          using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\ProductCatalog",
                                                                       "__FIND_CONSTRAINED_CYCLE_TYPE__"))
          {

            // Set the parameters
            stmt.AddParam("%%ID_PO%%", productOfferingId);
            int usageCycleType;
            // execute the query
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              // process the results
              while (rdr.Read())
              {
                usageCycleType = rdr.GetInt32(0);
                po.UsageCycleType = usageCycleType;
              }
            }
          }
        }


        using (IMTConnection conn2 = ConnectionManager.CreateConnection())
        {
          // Get a filter/sort statement
          using (IMTFilterSortStatement stmt2 = conn2.CreateFilterSortStatement("queries\\ProductCatalog",
                                                                       "__GET_NUMBER_OF_CYCLE_RELATIVE_PI__"))
          {

            // Set the parameters
            stmt2.AddParam("%%ID_PO%%", productOfferingId);

            int discAggreSum;
            // execute the query
            using (IMTDataReader rdr2 = stmt2.ExecuteReader())
            {
              // process the results
              while (rdr2.Read())
              {
                discAggreSum = rdr2.GetInt32(0) + rdr2.GetInt32(1);
                if (discAggreSum > 0)
                {
                  po.GroupSubscriptionRequiresCycle = true;
                }
                else
                {
                  po.GroupSubscriptionRequiresCycle = false;
                }

              }
            }
          }
        }
      }
      catch (MASBasicException masBasic)
      {
        m_Logger.LogException("Exception configuring cycle for product offering", masBasic);
        throw masBasic;
      }
      catch (COMException comE)
      {
        m_Logger.LogException("COM Exception configuring cycle for product offering", comE);
        throw new MASBasicException(comE.Message);
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception configuring cycle for product offering", e);
        throw new MASBasicException("Exception configuring cycle for product offering");
      }
      return po;
    }

  }
}
