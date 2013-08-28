/**************************************************************************
* Copyright 2011 by MetraTech
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
using System.Runtime.InteropServices;
using MetraTech.DomainModel.Validators;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTAuth;
using System.Globalization;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
    [ServiceContract()]
    public interface IAmpService
    {

        #region DECISION
        /// <summary>
        /// Retrieve a list of the decisions that exist in the DB.
        /// The returned Decision objects will be completely populated.
        /// You should only specify a sort criteria for the following fields:
        /// <list type="bullet">
        ///       <item>
        ///           <description>Name</description>
        ///       </item>
        ///       <item>
        ///           <description>Description</description>
        ///       </item>
        ///       <item>
        ///           <description>ParameterTableName</description>
        ///       </item>
        ///       <item>
        ///           <description>IsActive</description>
        ///       </item>
        ///       <item>
        ///           <description>AccountQualificationGroup</description>
        ///       </item>
        ///       <item>
        ///           <description>UsageQualificationGroup</description>
        ///       </item>
        ///       <item>
        ///           <description>AmountChain</description>
        ///       </item>
        /// </list>
        /// </summary>
        /// <param name="decisions">List containing all of the decisions in the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If you attempt to sort by another decision attribute</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetDecisions(ref MTList<Decision> decisions);

        /// <summary>
        /// Retrieve a single decision using the specified name.
        /// </summary>
        /// <param name="name">unique name of a decision</param>
        /// <param name="decision">OUT selected decision object or NULL if it can't be found</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetDecision(string name, out Decision decision);

        /// <summary>
        /// Create a brand new decision in the DB.  The output decision
        /// will be populated with default attributes taken from the DB.
        /// This new decision, with default fields, will be persisted in the DB.
        /// </summary>
        /// <param name="name">unique name for this decision</param>
        /// <param name="description">describes what the decision does</param>
        /// <param name="parameterTableName">name of the parameter table associated with this decision</param>
        /// <param name="decision">brand new decision object containing default attributes</param>
        /// <exception cref="System.ServiceModel.FaultException">If name is not unique</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void CreateDecision(string name, string description, string parameterTableName, out Decision decision);

        /// <summary>
        /// Delete a decision from the DB and all of it's attributes
        /// </summary>
        /// <param name="name">unique name for this decision</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void DeleteDecision(string name);

        /// <summary>
        /// Create a brand new decision based on the contents of the decisionToClone.
        /// The newDecision will be persisted in the DB before this method returns.
        /// </summary>
        /// <param name="decisionToCloneName">name of the decision that is being cloned</param>
        /// <param name="newName">unique name for the new decision</param>
        /// <param name="newDescription">describes what the new decision will do</param>
        /// <param name="newDecision">brand new decision</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void CloneDecision(string decisionToCloneName, string newName, string newDescription, out Decision newDecision);

        /// <summary>
        /// Store the contents of the decision object in the DB.
        /// </summary>
        /// <param name="decision">decision object to be stored in the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If decision.name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void SaveDecision(Decision decision);

        /// <summary>
        /// Validate the specified decision and return an error string
        /// describing any problems.
        /// </summary>
        /// <param name="name">unique name of a decision</param>
        /// <param name="validationErrors">OUT output string containing descriptions of problems</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void ValidateDecision(string name, out string validationErrors);
        #endregion

        #region USAGE_QUALIFICATION_GROUP
        /// <summary>
        /// Retrieve a list of the usage qualifications that exist in the DB.
        /// The returned UsageQualificationGroup objects will be completely populated.
        /// </summary>
        /// <param name="usageQualificationGroups">List containing all of the usage qualifications in the DB</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetUsageQualificationGroups(ref MTList<UsageQualificationGroup> usageQualificationGroups);

        /// <summary>
        /// Retrieve a single usage qualification using the specified unique name.
        /// </summary>
        /// <param name="name">unique name for a usage qualification</param>
        /// <param name="usageQualification">OUT selected usage qualification object or NULL if it can't be found</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetUsageQualificationGroup(string name, out UsageQualificationGroup usageQualification);

        /// <summary>
        /// Create a brand new usage qualification in the DB.
        /// </summary>
        /// <param name="name">unique name for this usage qualification e.g. toll calls</param>
        /// <param name="description">describes what the usage qualification does e.g. eliminates local calls</param>
        /// <param name="usageQualification">brand new usage qualification object containing default attributes</param>
        /// <exception cref="System.ServiceModel.FaultException">If name is not unique</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void CreateUsageQualificationGroup(string name, string description, out UsageQualificationGroup usageQualification);

        /// <summary>
        /// Store the contents of the usage qualification object in the DB.
        /// </summary>
        /// <param name="usageQualificationGroup">usage qualification group object to be stored in the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If usageQualificationGroup.name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void SaveUsageQualificationGroup(UsageQualificationGroup usageQualificationGroup);

        /// <summary>
        /// Delete a usage qualification group from the DB and all of it's filters
        /// </summary>
        /// <param name="name">unique name for this UsageQualificationGroup</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void DeleteUsageQualificationGroup(string name);

        #endregion

        #region ACCOUNT_QUALIFICATION_GROUP
        /// <summary>
        /// Retrieve a list of the account qualification groups that exist in the DB.
        /// The returned AccountQualificationGroup objects will be completely populated.
        /// </summary>
        /// <param name="accountQualificationGroups">List containing all of the account qualification groups in the DB</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccountQualificationGroups(ref MTList<AccountQualificationGroup> accountQualificationGroups);

        /// <summary>
        /// Retrieve a single account qualification group using the specified unique name.
        /// </summary>
        /// <param name="name">unique name for a account qualification group</param>
        /// <param name="accountQualification">OUT selected account qualification group object or NULL if it can't be found</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccountQualificationGroup(string name, out AccountQualificationGroup accountQualification);

        /// <summary>
        /// Create a brand new account qualification group in the DB.
        /// </summary>
        /// <param name="name">unique name for this account qualification group e.g. toll calls</param>
        /// <param name="description">describes what the account qualification group does e.g. eliminates local calls</param>
        /// <param name="accountQualification">brand new account qualification group object containing default attributes</param>
        /// <exception cref="System.ServiceModel.FaultException">If name is not unique</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void CreateAccountQualificationGroup(string name, string description, out AccountQualificationGroup accountQualification);

        /// <summary>
        /// Store the contents of the account qualification group object in the DB.
        /// </summary>
        /// <param name="accountQualification">account qualification group object to be stored in the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void SaveAccountQualificationGroup(AccountQualificationGroup accountQualification);

        /// <summary>
        /// Delete a account qualification group from the DB and all of it's qualifications
        /// </summary>
        /// <param name="name">unique name for this AccountQualificationGroup</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void DeleteAccountQualificationGroup(string name);
        #endregion

        #region GENERATED_CHARGE
        /// <summary>
        /// Retrieve a list of the generatedCharges that exist in the DB.
        /// The returned GeneratedCharge objects will be completely populated.
        /// </summary>
        /// <param name="generatedCharges">List containing all of the generatedCharges in the DB</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetGeneratedCharges(ref MTList<GeneratedCharge> generatedCharges);

        /// <summary>
        /// Retrieve a single generatedCharge using the specified name.
        /// </summary>
        /// <param name="name">unique name for a generatedCharge</param>
        /// <param name="generatedCharge">OUT selected generatedCharge object or NULL if it can't be found</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetGeneratedCharge(string name, out GeneratedCharge generatedCharge);

        /// <summary>
        /// Create a brand new generatedCharge in the DB.
        /// </summary>
        /// <param name="genChargeName">unique name for this generatedCharge</param>
        /// <param name="description">describes what the generatedCharge does</param>
        /// <param name="productViewName">name of the product view to associate with the generatedCharge</param>
        /// <param name="amountChainName">name of the to use for the generatedCharge</param>
        /// <param name="generatedCharge">brand new generatedCharge object</param>
        /// <exception cref="System.ServiceModel.FaultException">If name is not unique</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void CreateGeneratedCharge(string genChargeName, string description, string productViewName, string amountChainName, out GeneratedCharge generatedCharge);

        /// <summary>
        /// Store the contents of the generatedCharge object in the DB.
        /// </summary>
        /// <param name="generatedCharge">generatedCharge object to be stored in the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void SaveGeneratedCharge(GeneratedCharge generatedCharge);

        /// <summary>
        /// Delete a generated charge from the DB and all of it's directives
        /// </summary>
        /// <param name="name">unique name for this GeneratedCharge</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void DeleteGeneratedCharge(string name);
        #endregion

        #region AMOUNT_CHAIN
        /// <summary>
        /// Retrieve a list of the AmountChains that exist in the DB.
        /// The returned AmountChain objects will be completely populated.
        /// </summary>
        /// <param name="amountChains">List containing all of the amountChains in the DB</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAmountChains(ref MTList<AmountChain> amountChains);

        /// <summary>
        /// Retrieve a single amountChain using the specified name.
        /// </summary>
        /// <param name="name">unique name for a amountChain</param>
        /// <param name="amountChain">OUT selected amountChain object or NULL if it can't be found</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAmountChain(string name, out AmountChain amountChain);

        /// <summary>
        /// Create a brand new amountChain in the DB.
        /// </summary>
        /// <param name="name">unique name for this amountChain</param>
        /// <param name="description">describes what the amountChain does</param>
        /// <param name="amountChain">brand new amountChain object</param>
        /// <param name="productViewName">product view associated with the amount chain</param>
        /// <param name="useTaxAdapter">True if the tax adapter should be used to recompute taxes</param>
        /// <exception cref="System.ServiceModel.FaultException">If name is not unique</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void CreateAmountChain(string name, string description,
            string productViewName, bool useTaxAdapter,
            out AmountChain amountChain);

        /// <summary>
        /// Store the contents of the amountChain object in the DB.
        /// </summary>
        /// <param name="amountChain">amountChain object to be stored in the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void SaveAmountChain(AmountChain amountChain);

        /// <summary>
        /// Delete an amount chain from the DB and all of it's fields
        /// </summary>
        /// <param name="name">unique name for this AmountChain</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void DeleteAmountChain(string name);
        #endregion

        #region PV_TO_AMOUNT_CHAIN_MAPPING
        /// <summary>
        /// Retrieve a list of the PvToAmountChainMappings that exist in the DB.
        /// The returned PvToAmountChainMapping objects will be completely populated.
        /// </summary>
        /// <param name="pvToAmountChainMappings">List containing all of the pvToAmountChainMappings in the DB</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetPvToAmountChainMappings(ref MTList<PvToAmountChainMapping> pvToAmountChainMappings);

        /// <summary>
        /// Retrieve a list of the distinct named PvToAmountChainMappings that exist in the DB.
        /// The returned PvToAmountChainMapping objects will not be completely populated.
        /// </summary>
        /// <param name="pvToAmountChainMappings">List containing all of the distinct named pvToAmountChainMappings in the DB</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetDistinctNamedPvToAmountChainMappings(ref MTList<DistinctNamedPvToAmountChainMapping> pvToAmountChainMappings);

        /// <summary>
        /// Retrieve a single PvToAmountChainMapping using the specified uniqueId.  Fully populated PvToAmountChainMapping.
        /// </summary>
        /// <param name="mappingUniqueId">unique Id for a pvToAmountChainMapping</param>
        /// <param name="pvToAmountChainMapping">OUT selected pvToAmountChainMapping object or NULL if it can't be found</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetPvToAmountChainMapping(Guid mappingUniqueId, out PvToAmountChainMapping pvToAmountChainMapping);

        /// <summary>
        /// Create a brand new pvToAmountChainMapping in the DB and return it.
        /// </summary>
        /// <param name="name">unique name for this pvToAmountChainMapping</param>
        /// <param name="description">describes what the pvToAmountChainMapping does</param>
        /// <param name="productViewName">product view name</param>
        /// <param name="amountChainUniqueId">UniqueId of the amount chain that is associated with the specified PV</param>
        /// <param name="pvToAmountChainMapping">brand new pvToAmountChainMapping object</param>
        /// <exception cref="System.ServiceModel.FaultException">If name is not unique</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void CreatePvToAmountChainMapping(string name, string description,
          string productViewName, Guid amountChainUniqueId,
          out PvToAmountChainMapping pvToAmountChainMapping);

        /// <summary>
        /// Store the contents of the pvToAmountChainMapping object in the DB.
        /// </summary>
        /// <param name="pvToAmountChainMapping">pvToAmountChainMapping object to be stored in the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void SavePvToAmountChainMapping(PvToAmountChainMapping pvToAmountChainMapping);

        /// <summary>
        /// Delete the specified PvToAmountChainMapping from the DB.
        /// </summary>
        /// <param name="mappingUniqueId">UniqueId of the pvToAmountChainMapping to be deleted from the DB</param>
        /// <exception cref="System.ServiceModel.FaultException">If name does not exist in the DB</exception>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void DeletePvToAmountChainMapping(Guid mappingUniqueId);
        #endregion

        #region OTHER_UTILITIES
        /// <summary>
        /// Retrieve all of the product view names from the DB
        /// </summary>
        /// <param name="productViewNames">list containing the names of all of the PV tables</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetProductViewNames(ref MTList<string> productViewNames);

        /// <summary>
        /// Retrieve all of the product view names from the DB along with their localized names
        /// </summary>
        /// <param name="productViewTableNames">list containing the names of all of the PV tables with localization included for each table</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetProductViewNamesWithLocalizedNames(ref MTList<ProductViewNameInstance> productViewTableNames);

        /// <summary>
        /// Retrieve the names of all of the parameter table names contained within the database.
        /// </summary>
        /// <param name="parameterTableNames">list containing the names of all of the parameter tables</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetParameterTableNames(ref MTList<string> parameterTableNames);

        /// <summary>
        /// Retrieve the id of all of a parameter table contained within the database.
        /// </summary>
        /// <param name="paramTableName">Database table name for the parameter table</param>
        /// <param name="idParamTable">id for the parameter table</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetParameterTableId(string paramTableName, ref int idParamTable);

        /// <summary>
        /// Retrieve the names of all of the parameter table names contained within the database along with their display names.
        /// </summary>
        /// <param name="parameterTableNamesWithDisplayValues">key value pair list containing the names of all of the parameter tables as the keys with each parameter table's display name as the value in the key value pair</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetParameterTableNamesWithDisplayValues(ref List<KeyValuePair<String, String>> parameterTableNamesWithDisplayValues);

        /// <summary>
        /// Retrieve all of the column names within the t_acc_usage table
        /// </summary>
        /// <param name="accUsageColumnNames">list containing the names of all of the PV tables</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccUsageColumnNames(ref MTList<string> accUsageColumnNames);

        /// <summary>
        /// Retrieve all of the column names within the specified product view table
        /// </summary>
        /// <param name="productViewTableName">name of the product view file to use in the query</param>
        /// <param name="productViewColumnNames">list containing the column names within the specified product view table</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetProductViewColumnNames(string productViewTableName,
          ref MTList<string> productViewColumnNames);

        /// <summary>
        /// Retrieve a list of the column names with their data types within the specified table.
        /// </summary>
        /// <param name="productViewTableName">name of the product view table to use in the query</param>
        /// <param name="productViewColumnNames">list containing the column names within the specified table</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetProductViewColumnNamesWithTypes(string productViewTableName,
          ref MTList<ProductViewPropertyInstance> productViewColumnNames);

        /// <summary>
        /// Retrieve a list of the column names within the specified table.
        /// </summary>
        /// <param name="tableName">name of the table to use in the query</param>
        /// <param name="tableColumnNames">list containing the column names within the specified table</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetTableColumnNames(string tableName,
          ref MTList<string> tableColumnNames);

        /// <summary>
        /// Retrieve a list of the column names within the specified table.
        /// </summary>
        /// <param name="tableName">name of the parameter table to use in the query</param>
        /// <param name="parameterTableColumnNamesWithDisplayValues">key value pair list containing the parameter table column names within the specified table as the keys with the associated display value as the value for each pair</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetParameterTableColumnNamesWithDisplayValues(string tableName,
          ref MTList<KeyValuePair<String, String>> parameterTableColumnNamesWithDisplayValues);

        /// <summary>
        /// Retrieve a list of structures that contains the product view column names
        /// and product view column name descriptions.
        /// TBD - Should return a list of structures instead of a string
        /// </summary>
        /// <param name="tableName">name of the product view file to use in the query</param>
        /// <param name="columnInfo">list containing the column names within the specified table</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetProductViewColumnNamesAndDescriptions(string tableName,
          ref MTList<string> columnInfo);

        /// <summary>
        /// Retrieve the names of the supported currencies
        /// </summary>
        /// <param name="currencyNames">list containing the supported currency names</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetCurrencyNames(ref MTList<string> currencyNames);
        #endregion

        #region AMP_COUNTER_DISPLAY
        /// <summary>
        /// Retrieve all of the decision instance information
        /// </summary>
        /// <param name="decisionInstances">list containing the decision instances</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetDecisionInstances(ref MTList<DecisionInstance> decisionInstances);
        #endregion
    }

    // good sample at CreateUsageQualificationGroup
    [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
    public class AmpService : CMASServiceBase, IAmpService
    {
        private Logger m_Logger = new Logger("[AmpService]");

        // Directory where AMP related queries exist
        private const string AMP_QUERY_DIR = "queries\\Amp";

        #region DECISION
        [OperationCapability("ManageAmpDecisions")]
        public void GetDecisions(ref MTList<Decision> decisions)
        {
            m_Logger.LogDebug("GetDecisions");
            using (HighResolutionTimer timer = new HighResolutionTimer("GetDecisions"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_DECISIONS__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<Decision>(stmt, decisions,
                                    new FilterColumnResolver(DecisionDomainModelMemberNameToColumnName), null);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int decisionNameIndex = rdr.GetOrdinal("c_decisionName");

                                        string decisionName;
                                        if (!rdr.IsDBNull(decisionNameIndex))
                                        {
                                            decisionName = rdr.GetString(decisionNameIndex);
                                        }
                                        else
                                        {
                                            throw new MASBasicException("GetDecisions: Found decision with NULL name");
                                        }

                                        Decision decision = new Decision();
                                        RetrieveAndPopulateDecision(decisionName, ref decision);
                                        decisions.Items.Add(decision);
                                    }
                                }
                                decisions.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("GetDecisions failed", e);
                    decisions.Items.Clear();
                    throw new MASBasicException("GetDecisions failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetDecision(string name, out Decision decision)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetDecision"))
            {
                m_Logger.LogDebug("GetDecision {0}", name);

                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("GetDecision: name is null or empty string");
                }

                decision = null;
                decision = new Decision();
                bool decisionExistsInDb = RetrieveAndPopulateDecision(name, ref decision);

                if (!decisionExistsInDb)
                {
                    throw new MASBasicException("GetDecision failed because " + name + " does not exist");
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void CreateDecision(string name, string description, string ptName, out Decision decision)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("CreateDecision"))
            {
                m_Logger.LogDebug("CreateDecision");
                decision = null;
                decision = new Decision();

                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("CreateDecision: name is null or empty string");
                }
                if (String.IsNullOrEmpty(ptName))
                {
                    throw new MASBasicException("CreateDecision: ptName is null or empty string");
                }

                try
                {
                    // Add a row to t_amp_decisiontype
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__CREATE_DECISION__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("decisionName", MTParameterType.String, name);
                                stmt.AddParam("decisionDescription", MTParameterType.String, description);
                                stmt.AddParam("parameterTableName", MTParameterType.String, ptName);

                                // Note: always create decisions with IsActive=false
                                stmt.AddParam("isActive", MTParameterType.Integer, 0);

                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("CreateDecision failed", e);
                    throw new MASBasicException("CreateDecision failed. " + e.Message);
                }

                // Populate the decision with default attributes
                RetrieveAndPopulateDecision(name, ref decision);
                PopulateDecisionWithDefaultAttributes(ref decision);

                // Store the newly created decision attributes in the DB.
                StoreAttributesInDb(decision);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void DeleteDecision(string name)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("DeleteDecision"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("DeleteDecision: name is null or empty string");
                }

                Decision decision = new Decision();

                bool decisionExistsInDb = RetrieveAndPopulateDecision(name, ref decision);

                if (!decisionExistsInDb)
                {
                    throw new MASBasicException("DeleteDecision failed because " + name + " does not exist");
                }

                m_Logger.LogDebug("Deleting decision name={0}, uniqueId={1}",
                    decision.Name, decision.UniqueId);

                try
                {
                    // Delete a specific decision.
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__DELETE_DECISION__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("decisionUniqueId", MTParameterType.Guid, decision.UniqueId);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("DeleteDecision failed", e);
                    throw new MASBasicException("DeleteDecision failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void CloneDecision(string decisionToCloneName, string newName, string newDescription, out Decision decision)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("CloneDecision"))
            {
                if (String.IsNullOrEmpty(newName))
                {
                    throw new MASBasicException("CloneDecision: newName is null or empty string");
                }

                if (String.IsNullOrEmpty(decisionToCloneName))
                {
                    throw new MASBasicException("CloneDecision: decisionToCloneName is null or empty string");
                }

                m_Logger.LogDebug("CloneDecision");
                decision = null;

                // Make sure the decision exists in the DB.
                Decision decisionToClone = new Decision();
                bool decisionExistsInDb = RetrieveAndPopulateDecision(decisionToCloneName, ref decisionToClone);
                if (!decisionExistsInDb)
                {
                    throw new MASBasicException("CloneDecision failed because " + decisionToCloneName + " does not exist");
                }

                // Create a brand new decision with the supplied name and description
                CreateDecision(newName, newDescription, decisionToClone.ParameterTableName,
                    out decision);

                // Store the unique id of the newly created decision in a temporary variable
                Guid decisionUniqueId = decision.UniqueId;

                // Copy all decision attributes
                decision = decisionToClone;

                // Put back the name, description, and unique id
                decision.Name = newName;
                decision.Description = newDescription;
                decision.UniqueId = decisionUniqueId;

                SaveDecision(decision);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void SaveDecision(Decision decision)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("SaveDecision"))
            {
                m_Logger.LogDebug("SaveDecision");

                // Make sure the decision exists in the DB.
                Decision dbDecision = new Decision();
                bool decisionExistsInDb = RetrieveAndPopulateDecision(decision.Name, ref dbDecision);

                if (!decisionExistsInDb)
                {
                    throw new MASBasicException("SaveDecision failed because " + decision.Name + " does not exist");
                }

                // If the client changed the description, then update the DB.
                if ((decision.Description != dbDecision.Description) || (decision.IsActive != dbDecision.IsActive))
                {
                    try
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                        {
                            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                            {
                                queryAdapter.Item = new MTQueryAdapterClass();
                                queryAdapter.Item.Init(AMP_QUERY_DIR);
                                queryAdapter.Item.SetQueryTag("__UPDATE_DECISION__");

                                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                {
                                    stmt.AddParam("uniqueId", MTParameterType.Guid, decision.UniqueId);
                                    stmt.AddParam("description", MTParameterType.String, decision.Description);
                                    stmt.AddParam("isActive", MTParameterType.Integer,
                                        (decision.IsActive.HasValue && decision.IsActive.Value) ? 1 : 0);

                                    stmt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        m_Logger.LogException("SaveDecision failed", e);
                        throw new MASBasicException("SaveDecision failed. " + e.Message);
                    }
                }

                // If any of the "OtherAttributes" have been removed, remove them from the DB.
                foreach (KeyValuePair<string, DecisionAttributeValue> pair in dbDecision.OtherAttributes)
                {
                    // Check if the pair still exists in the decision's "OtherAttributes"
                    if (!decision.OtherAttributes.ContainsKey(pair.Key))
                    {
                        // Remove the OtherAttribute from the DB for this decision
                        RemoveAttributeFromDb(decision.UniqueId, pair.Key);
                    }
                }

                // If decision attributes have changed, store the changes in the DB.
                StoreAttributesInDb(decision);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void ValidateDecision(string name, out string validationErrors)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("ValidateDecision"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("ValidateDecision: name is null or empty string");
                }

                validationErrors = null;
                validationErrors = "no validation performed";
            }
        }

        /// <summary>
        /// This method is involved in the sorting and filtering of a list of decisions returned to
        /// clients.  The clients should only be aware of the decision domain model member names.
        /// This method converts the decisions domain model member names into the appropriate
        /// database column names.
        /// </summary>
        /// <param name="decisionDomainModelMemberName">Name of a decision domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds decisions</returns>
        private string DecisionDomainModelMemberNameToColumnName(string decisionDomainModelMemberName, ref object filterVal, object helper)
        {
            string columnName = null;

            switch (decisionDomainModelMemberName)
            {
                case "Name":
                    columnName = "c_decisionName";
                    break;

                case "Description":
                    columnName = "c_decisionDescription";
                    break;

                case "UniqueId":
                    columnName = "c_decisionUniqueId";
                    break;

                case "ParameterTableName":
                    columnName = "c_parameterTable";
                    break;

                case "ParameterTableDisplayName":
                    columnName = "c_paramTableDisplayName";
                    break;

                case "IsActive":
                    columnName = "c_isActive";
                    break;

                case "AccountQualificationGroup":
                    columnName = "c_accountQualGroup";
                    break;

                case "UsageQualificationGroup":
                    columnName = "c_usageQualGroup";
                    break;

                case "AmountChain":
                    columnName = "c_pvToAmountChainMapping";
                    break;

                case "PriorityValue":
                    columnName = "c_priorityValue";
                    break;

                default:
                    throw new MASBasicException(
                        "DecisionDomainModelMemberNameToColumnName: attempt to sort on invalid field " + decisionDomainModelMemberName);
                    break;
            }

            return columnName;
        }

        //        [OperationCapability("ManageAmpDecisions")]
        public void GetDecisionInstances(ref MTList<DecisionInstance> decisionInstances)
        {
            m_Logger.LogDebug("GetDecisionInstances");
            using (HighResolutionTimer timer = new HighResolutionTimer("GetDecisionInstances"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_DECISION_INSTANCES__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<DecisionInstance>(stmt, decisionInstances,
                                    new FilterColumnResolver(DecisionInstanceDomainModelMemberNameToColumnName), null);

                                m_Logger.LogDebug("Executing SQL: " + queryAdapter.Item.GetQuery());

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        DecisionInstance decisionInstance = new DecisionInstance();
                                        RetrieveAndPopulateDecisionInstance(rdr, ref decisionInstance);
                                        decisionInstances.Items.Add(decisionInstance);
                                    }
                                }
                                decisionInstances.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("GetDecisionInstances failed", e);
                    decisionInstances.Items.Clear();
                    throw new MASBasicException("GetDecisionInstances failed. " + e.Message);
                }
            }
        }

        /// <summary>
        /// This method is involved in the sorting and filtering of a list of decision instances returned to
        /// clients.  The clients should only be aware of the decision instance domain model member names.
        /// This method converts the decision instances domain model member names into the appropriate
        /// database column names.
        /// </summary>
        /// <param name="decisionInstanceDomainModelMemberName">Name of a decision instance domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds decision instances</returns>
        private string DecisionInstanceDomainModelMemberNameToColumnName(string decisionInstanceDomainModelMemberName, ref object filterVal, object helper)
        {
            string columnName = null;

            switch (decisionInstanceDomainModelMemberName)
            {
                case "DecisionUniqueId":
                    columnName = "decision_unique_id";
                    break;

                case "AccountId":
                    columnName = "id_acc";
                    break;

                case "GroupId":
                    columnName = "id_group";
                    break;

                case "SubscriptionId":
                    columnName = "id_sub";
                    break;

                case "StartDate":
                    columnName = "start_date";
                    break;

                case "EndDate":
                    columnName = "end_date";
                    break;

                case "AccountQualificationGroup":
                    columnName = "account_qualification_group";
                    break;

                case "ProductOfferingId":
                    columnName = "id_po";
                    break;

                case "RateScheduleId":
                    columnName = "id_sched";
                    break;

                case "NOrder":
                    columnName = "n_order";
                    break;

                case "TtStartDate":
                    columnName = "tt_start";
                    break;

                case "TierColumnGroup":
                    columnName = "tier_column_group";
                    break;

                case "TierPriority":
                    columnName = "tier_priority";
                    break;

                case "TierCategory":
                    columnName = "tier_category";
                    break;

                case "TierResponsiveness":
                    columnName = "tier_responsiveness";
                    break;

                case "UsageInterval":
                    columnName = "id_usage_interval";
                    break;

                case "TierStart":
                    columnName = "tier_start";
                    break;

                case "TierEnd":
                    columnName = "tier_end";
                    break;

                case "QualifiedAmounts":
                    columnName = "qualified_amount";
                    break;

                case "QualifiedEvents":
                    columnName = "qualified_events";
                    break;

                case "QualifiedUnits":
                    columnName = "qualified_units";
                    break;

                default:
                    throw new MASBasicException(
                        "DecisionInstanceDomainModelMemberNameToColumnName: attempt to sort on invalid field " + decisionInstanceDomainModelMemberName);
                    break;
            }

            return columnName;
        }

        #endregion

        #region USAGE_QUALIFICATION
        [OperationCapability("ManageAmpDecisions")]
        public void GetUsageQualificationGroups(ref MTList<UsageQualificationGroup> usageQualificationGroups)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetUsageQualificationGroups"))
            {
                m_Logger.LogDebug("GetUsageQualificationGroups");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_USAGE_QUALIFICATION_GROUPS__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<UsageQualificationGroup>(stmt, usageQualificationGroups,
                                    new FilterColumnResolver(UqgDomainModelMemberNameToColumnName), null);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int uqgNameIndex = rdr.GetOrdinal("c_Name");
                                        int uqgDescriptionIndex = rdr.GetOrdinal("c_Description");
                                        int uqgUniqueIdIndex = rdr.GetOrdinal("c_UsageQualGroup_Id");

                                        string uqgName = null;

                                        if (!rdr.IsDBNull(uqgNameIndex))
                                        {
                                            uqgName = rdr.GetString(uqgNameIndex);
                                            UsageQualificationGroup uqg = new UsageQualificationGroup();
                                            RetrieveAndPopulateUsageQualificationGroup(uqgName, ref uqg);
                                            usageQualificationGroups.Items.Add(uqg);
                                        }
                                    }
                                }

                                usageQualificationGroups.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    usageQualificationGroups.Items.Clear();
                    m_Logger.LogException("GetUsageQualificationGroups failed", e);
                    throw new MASBasicException("GetUsageQualificationGroups failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetUsageQualificationGroup(string name, out UsageQualificationGroup usageQualificationGroup)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetUsageQualificationGroup"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("GetUsageQualificationGroup: name is null or empty string");
                }

                m_Logger.LogDebug("GetUsageQualificationGroup");
                usageQualificationGroup = null;
                usageQualificationGroup = new UsageQualificationGroup();
                bool usageQualificationGroupExistsInDb =
                    RetrieveAndPopulateUsageQualificationGroup(name, ref usageQualificationGroup);

                if (!usageQualificationGroupExistsInDb)
                {
                    throw new MASBasicException("GetUsageQualificationGroup failed because " + name + " does not exist");
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void CreateUsageQualificationGroup(string name, string description, out UsageQualificationGroup usageQualificationGroup)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("CreateUsageQualificationGroup"))
            {
                try
                {
                    if (String.IsNullOrEmpty(name))
                    {
                        m_Logger.LogError("Invalid Payment token supplied.");
                        throw new MASBasicException("CreateUsageQualificationGroup: name is null or empty string");
                    }

                    m_Logger.LogDebug("CreateUsageQualificationGroup");
                    //usageQualificationGroup = null;
                    usageQualificationGroup = new UsageQualificationGroup();

                    using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                                     new TransactionOptions(),
                                                                     EnterpriseServicesInteropOption.Full))
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR))
                        {
                            IMTQueryAdapter qa = new MTQueryAdapter();
                            qa.Init(AMP_QUERY_DIR);
                            qa.SetQueryTag("__CREATE_USAGE_QUALIFICATION_GROUP__");
                            string qStr = qa.GetQuery();

                            using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(qStr))
                            {
                                string guid = Guid.NewGuid().ToByteArray()[0].ToString();
                                //string.Format("hextoraw({0})", guid)
                                //string.Format("CONVERT(binary,{0})", guid)
                                //sys_guid
                                //prepStmt.AddParam("sys_guid", MTParameterType.String, string.Format("hextoraw({0})", "0xABCD"));
                                prepStmt.AddParam("usageQualificationGroupName", MTParameterType.String, name);
                                prepStmt.AddParam("usageQualificationGroupDescription", MTParameterType.String, description);

                                prepStmt.ExecuteNonQuery();
                            }
                        }
                        scope.Complete();
                    }
                }
                catch (MASBasicException masE)
                {
                    m_Logger.LogException("MAS Exception in CreateUsageQualificationGroup", masE);
                    throw;
                }
                catch (Exception e)
                {
                    m_Logger.LogException("Unexpected Exception in CreateUsageQualificationGroup", e);
                    throw new MASBasicException("Unhandled error in payment scheduling");
                }

                RetrieveAndPopulateUsageQualificationGroup(name, ref usageQualificationGroup);

                // The new UsageQualificationGroup has no filters
                usageQualificationGroup.UsageQualificationFilters = new List<UsageQualificationFilter>();
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void DeleteUsageQualificationGroup(string name)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("DeleteUsageQualificationGroup"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("DeleteUsageQualificationGroup: name is null or empty string");
                }

                UsageQualificationGroup uqg = new UsageQualificationGroup();

                bool uqgExistsInDb = RetrieveAndPopulateUsageQualificationGroup(name, ref uqg);

                if (!uqgExistsInDb)
                {
                    throw new MASBasicException("DeleteUsageQualificationGroup failed because " + name + " does not exist");
                }

                m_Logger.LogDebug("Deleting uqg name={0}, uniqueId={1}",
                    uqg.Name, uqg.UniqueId);

                try
                {
                    // Delete a specific uqg.
                    using (IMTConnection conn =
                        ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter =
                            new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__DELETE_USAGE_QUALIFICATION_GROUP__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("uqgUniqueId", MTParameterType.Guid, uqg.UniqueId);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("DeleteUsageQualificationGroup failed", e);
                    throw new MASBasicException("DeleteUsageQualificationGroup failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void SaveUsageQualificationGroup(UsageQualificationGroup usageQualificationGroup)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("SaveUsageQualificationGroup"))
            {
                m_Logger.LogDebug("SaveUsageQualificationGroup");

                // Make sure the usageQualificationGroup exists in the DB.
                UsageQualificationGroup dbUsageQualificationGroup = new UsageQualificationGroup();
                bool usageQualificationGroupExistsInDb = RetrieveAndPopulateUsageQualificationGroup(
                    usageQualificationGroup.Name, ref dbUsageQualificationGroup);

                if (!usageQualificationGroupExistsInDb)
                {
                    throw new MASBasicException("SaveUsageQualificationGroup failed because " + usageQualificationGroup.Name + " does not exist");
                }

                // If the client changed the description, then update the DB.
                if (usageQualificationGroup.Description != dbUsageQualificationGroup.Description)
                {
                    try
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                        {
                            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                            {
                                queryAdapter.Item = new MTQueryAdapterClass();
                                queryAdapter.Item.Init(AMP_QUERY_DIR);
                                queryAdapter.Item.SetQueryTag("__UPDATE_USAGE_QUALIFICATION_GROUP_DESCRIPTION__");

                                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                {
                                    stmt.AddParam("uniqueId", MTParameterType.Guid, usageQualificationGroup.UniqueId);
                                    stmt.AddParam("description", MTParameterType.String, usageQualificationGroup.Description);

                                    stmt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        m_Logger.LogException("SaveUsageQualificationGroup failed", e);
                        throw new MASBasicException("SaveUsageQualificationGroup failed. " + e.Message);
                    }
                }

                StoreUqgFiltersInDb(usageQualificationGroup, dbUsageQualificationGroup);
            }
        }
        #endregion

        #region ACCOUNT_QUALIFICATION
        [OperationCapability("ManageAmpDecisions")]
        public void GetAccountQualificationGroups(ref MTList<AccountQualificationGroup> accountQualificationGroups)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountQualificationGroups"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_ACCOUNT_QUALIFICATION_GROUPS__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<AccountQualificationGroup>(stmt, accountQualificationGroups,
                                    new FilterColumnResolver(UqgDomainModelMemberNameToColumnName), null);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int aqgNameIndex = rdr.GetOrdinal("c_Name");
                                        int aqgDescriptionIndex = rdr.GetOrdinal("c_Description");
                                        int aqgUniqueIdIndex = rdr.GetOrdinal("c_AccountQualGroup_Id");

                                        string aqgName = null;

                                        if (!rdr.IsDBNull(aqgNameIndex))
                                        {
                                            aqgName = rdr.GetString(aqgNameIndex);
                                            AccountQualificationGroup aqg = new AccountQualificationGroup();
                                            RetrieveAndPopulateAccountQualificationGroup(aqgName, ref aqg);
                                            accountQualificationGroups.Items.Add(aqg);
                                        }
                                    }
                                }

                                accountQualificationGroups.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    accountQualificationGroups.Items.Clear();
                    m_Logger.LogException("GetAccountQualificationGroups failed", e);
                    throw new MASBasicException("GetAccountQualificationGroups failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetAccountQualificationGroup(string name, out AccountQualificationGroup accountQualificationGroup)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountQualificationGroup"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("GetAccountQualificationGroup: name is null or empty string");
                }

                m_Logger.LogDebug("GetAccountQualificationGroup");
                accountQualificationGroup = null;
                accountQualificationGroup = new AccountQualificationGroup();
                bool accountQualificationGroupExistsInDb =
                    RetrieveAndPopulateAccountQualificationGroup(name, ref accountQualificationGroup);

                if (!accountQualificationGroupExistsInDb)
                {
                    throw new MASBasicException("GetAccountQualificationGroup failed because " + accountQualificationGroup.Name + " does not exist");
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void CreateAccountQualificationGroup(string name, string description, out AccountQualificationGroup accountQualificationGroup)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("CreateAccountQualificationGroup"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("CreateAccountQualificationGroup: name is null or empty string");
                }

                m_Logger.LogDebug("CreateAccountQualificationGroup");
                //accountQualificationGroup = null;
                accountQualificationGroup = new AccountQualificationGroup();

                try
                {
                    using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                                     new TransactionOptions(),
                                                                     EnterpriseServicesInteropOption.Full))
                    {
                        // Add a row to t_amp_accountqualgroup
                        //using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR))
                        {
                            IMTQueryAdapter qa = new MTQueryAdapter();
                            qa.Init(AMP_QUERY_DIR);
                            qa.SetQueryTag("__CREATE_ACCOUNT_QUALIFICATION_GROUP__");
                            string qStr = qa.GetQuery();

                            using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(qStr))
                            {
                                //prepStmt.AddParam("sys_guid", MTParameterType.String, string.Format("hextoraw({0})", "0xABCD"));
                                prepStmt.AddParam("accountQualificationGroupName", MTParameterType.String, name);
                                prepStmt.AddParam("accountQualificationGroupDescription", MTParameterType.String, description);

                                prepStmt.ExecuteNonQuery();
                            }
                        }
                        scope.Complete();
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("CreateAccountQualificationGroup failed", e);
                    throw new MASBasicException("CreateAccountQualificationGroup failed. " + e.Message);
                }

                RetrieveAndPopulateAccountQualificationGroup(name, ref accountQualificationGroup);

                // The new AccountQualificationGroup has no qualifications
                accountQualificationGroup.AccountQualifications = new List<AccountQualification>();
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void SaveAccountQualificationGroup(AccountQualificationGroup accountQualificationGroup)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("SaveAccountQualificationGroup"))
            {
                m_Logger.LogDebug("SaveAccountQualificationGroup");

                // Make sure the accountQualificationGroup exists in the DB.
                AccountQualificationGroup dbAccountQualificationGroup = new AccountQualificationGroup();
                bool accountQualificationGroupExistsInDb = RetrieveAndPopulateAccountQualificationGroup(
                    accountQualificationGroup.Name, ref dbAccountQualificationGroup);

                if (!accountQualificationGroupExistsInDb)
                {
                    throw new MASBasicException("SaveAccountQualificationGroup failed because " + accountQualificationGroup.Name + " does not exist");
                }

                // If the client changed the description, then update the DB.
                if (accountQualificationGroup.Description != dbAccountQualificationGroup.Description)
                {
                    try
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                        {
                            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                            {
                                queryAdapter.Item = new MTQueryAdapterClass();
                                queryAdapter.Item.Init(AMP_QUERY_DIR);
                                queryAdapter.Item.SetQueryTag("__UPDATE_ACCOUNT_QUALIFICATION_GROUP_DESCRIPTION__");

                                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                {
                                    stmt.AddParam("uniqueId", MTParameterType.Guid, accountQualificationGroup.UniqueId);
                                    stmt.AddParam("description", MTParameterType.String, accountQualificationGroup.Description);

                                    stmt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        m_Logger.LogException("SaveAccountQualificationGroup failed", e);
                        throw new MASBasicException("SaveAccountQualificationGroup failed. " + e.Message);
                    }
                }

                StoreAccountQualificationsInDb(accountQualificationGroup, dbAccountQualificationGroup);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void DeleteAccountQualificationGroup(string name)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("DeleteAccountQualificationGroup"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("DeleteAccountQualificationGroup: name is null or empty string");
                }

                AccountQualificationGroup aqg = new AccountQualificationGroup();

                bool aqgExistsInDb = RetrieveAndPopulateAccountQualificationGroup(name, ref aqg);

                if (!aqgExistsInDb)
                {
                    throw new MASBasicException("DeleteAccountQualificationGroup failed because " + name + " does not exist");
                }

                m_Logger.LogDebug("Deleting aqg name={0}, uniqueId={1}",
                    aqg.Name, aqg.UniqueId);

                try
                {
                    // Delete a specific aqg.
                    using (IMTConnection conn =
                        ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter =
                            new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__DELETE_ACCOUNT_QUALIFICATION_GROUP__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("aqgUniqueId", MTParameterType.Guid, aqg.UniqueId);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("DeleteAccountQualificationGroup failed", e);
                    throw new MASBasicException("DeleteAccountQualificationGroup failed. " + e.Message);
                }
            }
        }
        #endregion

        #region GENERATED_CHARGE
        [OperationCapability("ManageAmpDecisions")]
        public void GetGeneratedCharges(ref MTList<GeneratedCharge> generatedCharges)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetGeneratedCharges"))
            {
                m_Logger.LogDebug("GetGeneratedCharges");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_GENERATED_CHARGES__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<GeneratedCharge>(stmt, generatedCharges,
                                    new FilterColumnResolver(GcDomainModelMemberNameToColumnName), null);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int generatedChargeNameIndex = rdr.GetOrdinal("c_Name");
                                        int generatedChargeDescriptionIndex = rdr.GetOrdinal("c_Description");
                                        int generatedChargeUniqueIdIndex = rdr.GetOrdinal("c_GenCharge_Id");

                                        string generatedChargeName = null;

                                        if (!rdr.IsDBNull(generatedChargeNameIndex))
                                        {
                                            generatedChargeName = rdr.GetString(generatedChargeNameIndex);
                                            GeneratedCharge generatedCharge = new GeneratedCharge();
                                            RetrieveAndPopulateGeneratedCharge(generatedChargeName, ref generatedCharge);
                                            generatedCharges.Items.Add(generatedCharge);
                                        }
                                        else
                                        {
                                            m_Logger.LogError("found generatedCharge with NULL name");
                                            throw new MASBasicException("GetGeneratedCharges: found generatedCharge with NULL name");
                                        }
                                    }
                                }
                                generatedCharges.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    generatedCharges.Items.Clear();
                    m_Logger.LogException("GetGeneratedCharges failed", e);
                    throw new MASBasicException("GetGeneratedCharges failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetGeneratedCharge(string name, out GeneratedCharge generatedCharge)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetGeneratedCharge"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("GetGeneratedCharge: name is null or empty string");
                }

                m_Logger.LogDebug("GetGeneratedCharge");
                generatedCharge = null;
                generatedCharge = new GeneratedCharge();
                bool generatedChargeExistsInDb =
                    RetrieveAndPopulateGeneratedCharge(name, ref generatedCharge);

                if (!generatedChargeExistsInDb)
                {
                    throw new MASBasicException("GetGeneratedCharge failed because " + name + " does not exist");
                }
            }
        }


        [OperationCapability("ManageAmpDecisions")]
        public void CreateGeneratedCharge(string genChargeName, string description, string productViewName, string amountChainName, out GeneratedCharge generatedCharge)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("CreateGeneratedCharge"))
            {
                if (String.IsNullOrEmpty(genChargeName))
                {
                    throw new MASBasicException("CreateGeneratedCharge: name is null or empty string");
                }

                m_Logger.LogDebug("CreateGeneratedCharge");
                generatedCharge = null;
                generatedCharge = new GeneratedCharge();

                try
                {
                    // Add a row to t_amp_generatedcharge
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__CREATE_GENERATED_CHARGE__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("generatedChargeName", MTParameterType.String, genChargeName);
                                stmt.AddParam("generatedChargeDescription", MTParameterType.String, description);
                                stmt.AddParam("productViewName", MTParameterType.String, productViewName);
                                stmt.AddParam("amountChainName", MTParameterType.String, amountChainName);

                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("CreateGeneratedCharge failed", e);
                    throw new MASBasicException("CreateGeneratedCharge failed. " + e.Message);
                }

                RetrieveAndPopulateGeneratedCharge(genChargeName, ref generatedCharge);

                // The new GeneratedCharge has no filters
                generatedCharge.GeneratedChargeDirectives = new List<GeneratedChargeDirective>();
            }
        }


        [OperationCapability("ManageAmpDecisions")]
        public void SaveGeneratedCharge(GeneratedCharge generatedCharge)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("SaveGeneratedCharge"))
            {
                m_Logger.LogDebug("SaveGeneratedCharge");

                // Make sure the generatedCharge exists in the DB.
                GeneratedCharge dbGeneratedCharge = new GeneratedCharge();
                bool generatedChargeExistsInDb = RetrieveAndPopulateGeneratedCharge(
                    generatedCharge.Name, ref dbGeneratedCharge);

                if (!generatedChargeExistsInDb)
                {
                    throw new MASBasicException("SaveGeneratedCharge failed because " + generatedCharge.Name + " does not exist");
                }

                // If any of the high level generated charge attributes have changed,
                // then update all of them in the DB.
                if ((generatedCharge.Description != dbGeneratedCharge.Description) ||
                    (generatedCharge.AmountChainName != dbGeneratedCharge.AmountChainName) ||
                    (generatedCharge.ProductViewName != dbGeneratedCharge.ProductViewName))
                {
                    try
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                        {
                            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                            {
                                queryAdapter.Item = new MTQueryAdapterClass();
                                queryAdapter.Item.Init(AMP_QUERY_DIR);
                                queryAdapter.Item.SetQueryTag("__UPDATE_GENERATED_CHARGE__");

                                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                {
                                    stmt.AddParam("uniqueId", MTParameterType.Guid, generatedCharge.UniqueId);
                                    stmt.AddParam("description", MTParameterType.String, generatedCharge.Description);
                                    stmt.AddParam("amountChain", MTParameterType.String, generatedCharge.AmountChainName);
                                    stmt.AddParam("productViewName", MTParameterType.String, generatedCharge.ProductViewName);

                                    stmt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        m_Logger.LogException("SaveGeneratedCharge failed", e);
                        throw new MASBasicException("SaveGeneratedCharge failed. " + e.Message);
                    }
                }

                // If there are differences in the generated charge directives,
                // then update the DB appropriately
                StoreGeneratedChargeDirectivesInDb(generatedCharge, dbGeneratedCharge);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void DeleteGeneratedCharge(string name)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("DeleteGeneratedCharge"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("DeleteGeneratedCharge: name is null or empty string");
                }

                m_Logger.LogDebug("DeleteGeneratedCharge name={0}", name);
                GeneratedCharge generatedCharge = new GeneratedCharge();

                bool generatedChargeExistsInDb = RetrieveAndPopulateGeneratedCharge(name, ref generatedCharge);

                if (!generatedChargeExistsInDb)
                {
                    throw new MASBasicException("DeleteGeneratedCharge failed because " + name + " does not exist");
                }

                m_Logger.LogDebug("Deleting generatedCharge name={0}, uniqueId={1}",
                    generatedCharge.Name, generatedCharge.UniqueId);

                try
                {
                    // Delete a specific generatedCharge.
                    using (IMTConnection conn =
                        ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter =
                            new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__DELETE_GENERATED_CHARGE__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("generatedChargeUniqueId", MTParameterType.Guid, generatedCharge.UniqueId);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("DeleteGeneratedCharge failed", e);
                    throw new MASBasicException("DeleteGeneratedCharge failed. " + e.Message);
                }
            }
        }
        #endregion

        #region AMOUNT_CHAIN
        [OperationCapability("ManageAmpDecisions")]
        public void GetAmountChains(ref MTList<AmountChain> amountChains)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAmountChains"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_AMOUNT_CHAINS__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<AmountChain>(stmt, amountChains,
                                    null, null);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int amountChainNameIndex = rdr.GetOrdinal("c_Name");
                                        int amountChainDescriptionIndex = rdr.GetOrdinal("c_Description");
                                        int amountChainUniqueIdIndex = rdr.GetOrdinal("c_AmountChain_Id");

                                        string amountChainName = null;

                                        if (!rdr.IsDBNull(amountChainNameIndex))
                                        {
                                            amountChainName = rdr.GetString(amountChainNameIndex);
                                            AmountChain amountChain = new AmountChain();
                                            RetrieveAndPopulateAmountChain(amountChainName, ref amountChain);
                                            amountChains.Items.Add(amountChain);
                                        }
                                        else
                                        {
                                            m_Logger.LogError("found amountChain with NULL name");
                                            throw new MASBasicException(
                                                "GetAmountChains: found amountChain with NULL name");
                                        }
                                    }
                                }
                                amountChains.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    amountChains.Items.Clear();
                    m_Logger.LogException("GetAmountChains failed", e);
                    throw new MASBasicException("GetAmountChains failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetAmountChain(string name, out AmountChain amountChain)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAmountChain"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("GetAmountChain: name is null or empty string");
                }

                amountChain = null;
                amountChain = new AmountChain();
                bool amountChainExistsInDb =
                    RetrieveAndPopulateAmountChain(name, ref amountChain);

                if (!amountChainExistsInDb)
                {
                    throw new MASBasicException("GetAmountChain failed because " + name + " does not exist");
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void CreateAmountChain(string name, string description,
            string productViewName, bool useTaxAdapter,
            out AmountChain amountChain)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("CreateAmountChain"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("CreateAmountChain: name is null or empty string");
                }

                if (String.IsNullOrEmpty(productViewName))
                {
                    throw new MASBasicException("CreateAmountChain: productViewName is null or empty string");
                }

                m_Logger.LogDebug("CreateAmountChain");
                amountChain = null;
                amountChain = new AmountChain();

                try
                {
                    // Add a row to t_amp_amountChain
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__CREATE_AMOUNT_CHAIN__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("amountChainName", MTParameterType.String, name);
                                stmt.AddParam("amountChainDescription", MTParameterType.String, description);
                                stmt.AddParam("productViewName", MTParameterType.String, productViewName);
                                stmt.AddParam("useTaxAdapter", MTParameterType.Integer, (useTaxAdapter) ? 1 : 0);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("CreateAmountChain failed", e);
                    throw new MASBasicException("CreateAmountChain failed. " + e.Message);
                }

                RetrieveAndPopulateAmountChain(name, ref amountChain);

                // The new AmountChain has no fields
                amountChain.AmountChainFields = new List<AmountChainField>();
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void SaveAmountChain(AmountChain amountChain)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("SaveAmountChain"))
            {
                m_Logger.LogDebug("SaveAmountChain");

                // Make sure the AmountChain exists in the DB.
                AmountChain dbAmountChain = new AmountChain();
                bool amountChainExistsInDb = RetrieveAndPopulateAmountChain(
                    amountChain.Name, ref dbAmountChain);

                if (!amountChainExistsInDb)
                {
                    throw new MASBasicException("SaveAmountChain failed because " + amountChain.Name + " does not exist");
                }

                // If any of the high level generated charge attributes have changed,
                // then update all of them in the DB.
                if ((amountChain.Description != dbAmountChain.Description) ||
                    (amountChain.Name != dbAmountChain.Name) ||
                    (amountChain.ProductViewName != dbAmountChain.ProductViewName) ||
                    (amountChain.UseTaxAdapter != dbAmountChain.UseTaxAdapter))
                {
                    try
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                        {
                            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                            {
                                queryAdapter.Item = new MTQueryAdapterClass();
                                queryAdapter.Item.Init(AMP_QUERY_DIR);
                                queryAdapter.Item.SetQueryTag("__UPDATE_AMOUNT_CHAIN__");

                                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                {
                                    stmt.AddParam("amountChainName", MTParameterType.String, amountChain.Name);
                                    stmt.AddParam("amountChainDescription", MTParameterType.String, amountChain.Description);
                                    stmt.AddParam("productViewName", MTParameterType.String, amountChain.ProductViewName);
                                    stmt.AddParam("useTaxAdapter", MTParameterType.Integer,
                                        (amountChain.UseTaxAdapter.HasValue && amountChain.UseTaxAdapter.Value) ? 1 : 0);

                                    stmt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        m_Logger.LogException("SaveAmountChain failed", e);
                        throw new MASBasicException("SaveAmountChain failed. " + e.Message);
                    }
                }

                // If there are differences in the amount chain fields
                // then update the DB appropriately
                StoreAmountChainFieldsInDb(amountChain, dbAmountChain);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void DeleteAmountChain(string name)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("DeleteAmountChain"))
            {
                if (String.IsNullOrEmpty(name))
                {
                    throw new MASBasicException("DeleteAmountChain: name is null or empty string");
                }

                m_Logger.LogDebug("DeleteAmountChain name={0}", name);
                AmountChain amountChain = new AmountChain();

                bool amountChainExistsInDb = RetrieveAndPopulateAmountChain(name, ref amountChain);

                if (!amountChainExistsInDb)
                {
                    throw new MASBasicException("DeleteAmountChain failed because " + name + " does not exist");
                }

                m_Logger.LogDebug("Deleting amountChain name={0}, uniqueId={1}",
                    amountChain.Name, amountChain.UniqueId);

                try
                {
                    // Delete a specific amountChain.
                    using (IMTConnection conn =
                        ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter =
                            new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__DELETE_AMOUNT_CHAIN__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                //stmt.AddParam("amountChainUniqueId", MTParameterType.Guid, amountChain.UniqueId);
                                stmt.AddParam("amountChainName", MTParameterType.String, amountChain.Name);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("DeleteAmountChain failed", e);
                    throw new MASBasicException("DeleteAmountChain failed. " + e.Message);
                }
            }
        }
        #endregion

        #region PV_TO_AMOUNT_CHAIN_MAPPING

        /// <summary>
        /// This method is involved in the sorting and filtering of a list of PvToAmountChainMapping's returned to
        /// clients.  The clients should only be aware of the PvToAmountChainMapping domain model member names.
        /// This method converts the PvToAmountChainMapping domain model member names into the appropriate
        /// database column names.
        /// </summary>
        /// <param name="pvToAmountChainMappingDomainModelMemberName">Name of a pvToAmountChainMapping domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds decisions</returns>
        private string PvToAmountChainMappingDomainModelMemberNameToColumnName(string pvToAmountChainMappingDomainModelMemberName, ref object filterVal, object helper)
        {
            string columnName = null;

            switch (pvToAmountChainMappingDomainModelMemberName)
            {
                case "Name":
                    columnName = "c_Name";
                    break;

                case "Description":
                    columnName = "c_Description";
                    break;

                case "UniqueId":
                    columnName = "c_PvToAmountChain_Id";
                    break;

                case "ProductViewName":
                    columnName = "c_ProductViewName";
                    break;

                case "AmountChainUniqueId":
                    columnName = "c_AmountChain_Id";
                    break;

                default:
                    throw new MASBasicException(
                        "PvToAmountChainMappingDomainModelMemberNameToColumnName: attempt to sort on invalid field " + pvToAmountChainMappingDomainModelMemberName);
                    break;
            }

            return columnName;
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetPvToAmountChainMappings(ref MTList<PvToAmountChainMapping> pvToAmountChainMappings)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetPvToAmountChainMappings"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_PV_TO_AMOUNT_CHAIN_MAPPINGS__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<PvToAmountChainMapping>(stmt, pvToAmountChainMappings,
                                    new FilterColumnResolver(PvToAmountChainMappingDomainModelMemberNameToColumnName), null);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int mappingNameIndex = rdr.GetOrdinal("c_Name");
                                        int mappingDescriptionIndex = rdr.GetOrdinal("c_Description");
                                        int mappingUniqueIdIndex = rdr.GetOrdinal("c_PvToAmountChain_Id");

                                        Guid mappingUniqueId = Guid.Empty;

                                        if (!rdr.IsDBNull(mappingUniqueIdIndex))
                                        {
                                            mappingUniqueId = rdr.GetGuid(mappingUniqueIdIndex);
                                            PvToAmountChainMapping mapping = new PvToAmountChainMapping();
                                            RetrieveAndPopulatePvToAmountChainMapping(mappingUniqueId, ref mapping);
                                            pvToAmountChainMappings.Items.Add(mapping);
                                        }
                                    }
                                }

                                pvToAmountChainMappings.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("GetPvToAmountChainMappings failed", e);
                    pvToAmountChainMappings.Items.Clear();
                    throw new MASBasicException("GetPvToAmountChainMappings failed. " + e.Message);
                }
            }
        }

        /// <summary>
        /// This method is involved in the sorting and filtering of a list of DistinctNamedPvToAmountChainMapping's returned to
        /// clients.  The clients should only be aware of the DistinctNamedPvToAmountChainMapping domain model member names.
        /// This method converts the DistinctNamedPvToAmountChainMapping domain model member names into the appropriate
        /// database column names.
        /// </summary>
        /// <param name="distinctNamedPvToAmountChainMappingDomainModelMemberName">Name of a distinctNamedPvToAmountChainMapping domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds decisions</returns>
        private string DistinctNamedPvToAmountChainMappingDomainModelMemberNameToColumnName(string distinctNamedPvToAmountChainMappingDomainModelMemberName, ref object filterVal, object helper)
        {
            string columnName = null;

            switch (distinctNamedPvToAmountChainMappingDomainModelMemberName)
            {
                case "Name":
                    columnName = "c_Name";
                    break;

                case "Description":
                    columnName = "c_Description";
                    break;

                case "UniqueId":
                    columnName = "c_PvToAmountChain_Id";
                    break;

                default:
                    throw new MASBasicException(
                        "DistinctNamedPvToAmountChainMappingDomainModelMemberNameToColumnName: attempt to sort on invalid field " + distinctNamedPvToAmountChainMappingDomainModelMemberName);
                    break;
            }

            return columnName;
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetDistinctNamedPvToAmountChainMappings(ref MTList<DistinctNamedPvToAmountChainMapping> distinctNamedPvToAmountChainMappings)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetDistinctNamedPvToAmountChainMappings"))
            {
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_DISTINCT_NAMED_PV_TO_AMOUNT_CHAIN_MAPPINGS__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<DistinctNamedPvToAmountChainMapping>(stmt, distinctNamedPvToAmountChainMappings,
                                    new FilterColumnResolver(PvToAmountChainMappingDomainModelMemberNameToColumnName), null);
                                int count = 0;
                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int mappingNameIndex = rdr.GetOrdinal("c_Name");
                                        int mappingDescriptionIndex = rdr.GetOrdinal("c_Description");
                                        int mappingUniqueIdIndex = rdr.GetOrdinal("c_PvToAmountChain_Id");

                                        DistinctNamedPvToAmountChainMapping mapping = new DistinctNamedPvToAmountChainMapping();

                                        if (!rdr.IsDBNull(mappingNameIndex))
                                        {
                                            string mappingName = rdr.GetString(mappingNameIndex);
                                            mapping.Name = mappingName;
                                        }
                                        if (!rdr.IsDBNull(mappingDescriptionIndex))
                                        {
                                            string mappingDescription = rdr.GetString(mappingDescriptionIndex);
                                            mapping.Description = mappingDescription;
                                        }
                                        if (!rdr.IsDBNull(mappingUniqueIdIndex))
                                        {
                                            Guid mappingUniqueId = rdr.GetGuid(mappingUniqueIdIndex);
                                            mapping.UniqueId = mappingUniqueId;
                                            if (!String.IsNullOrEmpty(mapping.Name))
                                            {
                                                count++;
                                                distinctNamedPvToAmountChainMappings.Items.Add(mapping);
                                            }
                                        }
                                    }
                                }
                                distinctNamedPvToAmountChainMappings.TotalRows = count;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("GetDistinctNamedPvToAmountChainMappings failed", e);
                    distinctNamedPvToAmountChainMappings.Items.Clear();
                    throw new MASBasicException("GetDistinctNamedPvToAmountChainMappings failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetPvToAmountChainMapping(Guid mappingUniqueId, out PvToAmountChainMapping pvToAmountChainMapping)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetPvToAmountChainMapping"))
            {
                if (mappingUniqueId == Guid.Empty)
                {
                    throw new MASBasicException("GetPvToAmountChainMapping: mappingUniqueId is empty");
                }

                pvToAmountChainMapping = null;
                pvToAmountChainMapping = new PvToAmountChainMapping();
                bool pvToAmountChainMappingExistsInDb =
                    RetrieveAndPopulatePvToAmountChainMapping(mappingUniqueId, ref pvToAmountChainMapping);

                if (!pvToAmountChainMappingExistsInDb)
                {
                    throw new MASBasicException("GetPvToAmountChainMapping failed because " + mappingUniqueId + " does not exist");
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void CreatePvToAmountChainMapping(string mappingName, string mappingDescription,
            string productViewName, Guid amountChainUniqueId,
            out PvToAmountChainMapping pvToAmountChainMapping)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("CreatePvToAmountChainMapping"))
            {
                if (String.IsNullOrEmpty(mappingName))
                {
                    throw new MASBasicException("GetPvToAmountChainMapping: mappingName is null or empty string");
                }

                if (String.IsNullOrEmpty(productViewName))
                {
                    throw new MASBasicException("GetPvToAmountChainMapping: productViewName is null or empty string");
                }

                if (amountChainUniqueId == Guid.Empty)
                {
                    throw new MASBasicException("GetPvToAmountChainMapping: amountChainUniqueId is null or empty");
                }

                pvToAmountChainMapping = null;
                pvToAmountChainMapping = new PvToAmountChainMapping();
                try
                {
                    // Add a row to t_amp_pvtoamountchain
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__CREATE_PV_TO_AMOUNT_CHAIN_MAPPING__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("pvToAmountChainMappingName", MTParameterType.String, mappingName);
                                stmt.AddParam("pvToAmountChainMappingDescription", MTParameterType.String, mappingDescription);
                                stmt.AddParam("productViewName", MTParameterType.String, productViewName);
                                stmt.AddParam("amountChainUniqueId", MTParameterType.Guid, amountChainUniqueId);

                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("GetPvToAmountChainMapping failed", e);
                    throw new MASBasicException("GetPvToAmountChainMapping failed. " + e.Message);
                }

                RetrieveAndPopulatePvToAmountChainMapping(
                    mappingName, mappingDescription, productViewName, amountChainUniqueId,
                    ref pvToAmountChainMapping);

            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void SavePvToAmountChainMapping(PvToAmountChainMapping mapping)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("SavePvToAmountChainMapping"))
            {
                //
                // Note: Could check for changes, and only update the changed
                // items.  Instead, just overwriting the old version in the DB.
                //
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__UPDATE_PV_TO_AMOUNT_CHAIN_MAPPING__");

                            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("mappingUniqueId", MTParameterType.Guid, mapping.UniqueId);
                                stmt.AddParam("mappingName", MTParameterType.String, mapping.Name);
                                stmt.AddParam("mappingDescription", MTParameterType.String, mapping.Description);
                                stmt.AddParam("productViewName", MTParameterType.String, mapping.ProductViewName);
                                stmt.AddParam("amountChainUniqueId", MTParameterType.Guid, mapping.AmountChainUniqueId);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("SavePvToAmountChainMapping failed", e);
                    throw new MASBasicException("SavePvToAmountChainMapping failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void DeletePvToAmountChainMapping(Guid mappingUniqueId)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("DeletePvToAmountChainMapping"))
            {
                m_Logger.LogDebug("Deleting mappingUniqueId={0}",
                    mappingUniqueId);
                if (mappingUniqueId == Guid.Empty)
                {
                    throw new MASBasicException("DeletePvToAmountChainMapping: mappingUniqueId is empty");
                }

                try
                {
                    // Delete a specific mapping.
                    using (IMTConnection conn =
                        ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter =
                            new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__DELETE_PV_TO_AMOUNT_CHAIN_MAPPING__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("mappingUniqueId", MTParameterType.Guid, mappingUniqueId);
                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("DeletePvToAmountChainMapping failed", e);
                    throw new MASBasicException("DeletePvToAmountChainMapping failed. " + e.Message);
                }
            }
        }
        #endregion

        #region OTHER_UTILITIES
        [OperationCapability("ManageAmpDecisions")]
        public void GetProductViewNames(ref MTList<string> productViewTableNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetProductViewNames"))
            {
                m_Logger.LogDebug("GetProductViewTableNames");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_PRODUCT_VIEW_TABLE_NAMES__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<string>(stmt, productViewTableNames);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int pvNameIndex = rdr.GetOrdinal("name");

                                        string pvName = null;

                                        if (!rdr.IsDBNull(pvNameIndex))
                                        {
                                            pvName = rdr.GetString(pvNameIndex);
                                        }

                                        if (pvName != null)
                                        {
                                            productViewTableNames.Items.Add(pvName);
                                        }
                                    }
                                }

                                productViewTableNames.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    productViewTableNames.Items.Clear();
                    m_Logger.LogException("GetProductViewNames failed", e);
                    throw new MASBasicException("GetProductViewNames failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetProductViewNamesWithLocalizedNames(ref MTList<ProductViewNameInstance> productViewTableNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetProductViewNamesWithLocalizedNames"))
            {
                m_Logger.LogDebug("GetProductViewNamesWithLocalizedNames");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_PRODUCT_VIEW_TABLES__");

                            using (IMTPreparedFilterSortStatement stmt =
                              conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<ProductViewNameInstance>(stmt, productViewTableNames);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        var pv = new ProductViewNameInstance();

                                        int pvIdViewIndex = rdr.GetOrdinal("ID_VIEW");
                                        if (!rdr.IsDBNull(pvIdViewIndex))
                                        {
                                            pv.ID = rdr.GetInt32(pvIdViewIndex);
                                        }

                                        int pvTableNameIndex = rdr.GetOrdinal("NM_TABLE_NAME");
                                        if (!rdr.IsDBNull(pvTableNameIndex))
                                        {
                                            pv.TableName = rdr.GetString(pvTableNameIndex);
                                        }

                                        int pvNameIndex = rdr.GetOrdinal("NM_NAME");
                                        if (!rdr.IsDBNull(pvNameIndex))
                                        {
                                            pv.Name = rdr.GetString(pvNameIndex);
                                        }

                                        var localizedNames = new Dictionary<LanguageCode, string>();
                                        using (MTComSmartPtr<IMTQueryAdapter> subqueryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                                        {
                                            subqueryAdapter.Item = new MTQueryAdapterClass();
                                            subqueryAdapter.Item.Init(AMP_QUERY_DIR);
                                            subqueryAdapter.Item.SetQueryTag("__GET_DESCRIPTION_TEXT__");

                                            using (IMTPreparedFilterSortStatement subStmt =
                                              conn.CreatePreparedFilterSortStatement(subqueryAdapter.Item.GetRawSQLQuery(true)))
                                            {
                                                subStmt.AddParam("idDesc", MTParameterType.Integer, pv.ID);
                                                using (IMTDataReader subRdr = subStmt.ExecuteReader())
                                                {
                                                    while (subRdr.Read())
                                                    {
                                                        int idLangCode = 0;
                                                        string description = null;

                                                        int idLangCodeIndex = subRdr.GetOrdinal("ID_LANG_CODE");
                                                        if (!subRdr.IsDBNull(idLangCodeIndex))
                                                        {
                                                            idLangCode = subRdr.GetInt32(idLangCodeIndex);
                                                        }

                                                        int txDescIndex = subRdr.GetOrdinal("TX_DESC");
                                                        if (!subRdr.IsDBNull(txDescIndex))
                                                        {
                                                            description = subRdr.GetString(txDescIndex);
                                                        }

                                                        if (description == null) continue;
                                                        var languageCode =
                                                          (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), idLangCode.ToString());
                                                        localizedNames.Add(languageCode, description);
                                                    }
                                                }
                                            }
                                        }
                                        pv.LocalizedDisplayNames = localizedNames;
                                        productViewTableNames.Items.Add(pv);
                                    }
                                }
                                productViewTableNames.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    productViewTableNames.Items.Clear();
                    m_Logger.LogException("GetProductViewNamesWithLocalizedNames failed", e);
                    throw new MASBasicException("GetProductViewNamesWithLocalizedNames failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetParameterTableNames(ref MTList<string> parameterTableNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetParameterTableNames"))
            {
                m_Logger.LogDebug("GetParameterTableNames");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_PARAMETER_TABLE_NAMES__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<string>(stmt, parameterTableNames);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int ptNameIndex = rdr.GetOrdinal("name");

                                        string ptName = null;

                                        if (!rdr.IsDBNull(ptNameIndex))
                                        {
                                            ptName = rdr.GetString(ptNameIndex);
                                        }

                                        if (ptName != null)
                                        {
                                            parameterTableNames.Items.Add(ptName);
                                        }
                                    }
                                }

                                parameterTableNames.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    parameterTableNames.Items.Clear();
                    m_Logger.LogException("GetParameterTableNames failed", e);
                    throw new MASBasicException("GetParameterTableNames failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetParameterTableId(string paramTableName, ref int idParamTable)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetParameterTableId"))
            {
                m_Logger.LogDebug("GetParameterTableId");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_PARAMETER_TABLE_ID__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("parameterTableName", MTParameterType.String, paramTableName);
                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int idIndex = rdr.GetOrdinal("id_paramtable");

                                        if (!rdr.IsDBNull(idIndex))
                                        {
                                            idParamTable = rdr.GetInt32(idIndex);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("GetParameterTableId failed", e);
                    throw new MASBasicException("GetParameterTableId failed. " + e.Message);
                }

            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetParameterTableNamesWithDisplayValues(ref List<KeyValuePair<String, String>> parameterTableNamesWithDisplayValues)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetParameterTableNamesWithDisplayValues"))
            {
                m_Logger.LogDebug("GetParameterTableNamesWithDisplayValues");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_PARAMETER_TABLE_NAMES_WITH_DISPLAY_VALUES__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int ptTableNameIndex = rdr.GetOrdinal("nm_instance_tablename");

                                        string ptTableName = null;

                                        if (!rdr.IsDBNull(ptTableNameIndex))
                                        {
                                            ptTableName = rdr.GetString(ptTableNameIndex);
                                        }

                                        int ptNameIndex = rdr.GetOrdinal("nm_name");

                                        string ptName = null;

                                        if (!rdr.IsDBNull(ptNameIndex))
                                        {
                                            ptName = rdr.GetString(ptNameIndex);
                                        }

                                        int ptDisplayNameIndex = rdr.GetOrdinal("nm_display_name");

                                        string ptDisplayName = null;

                                        if (!rdr.IsDBNull(ptDisplayNameIndex))
                                        {
                                            ptDisplayName = rdr.GetString(ptDisplayNameIndex);
                                        }

                                        if (!String.IsNullOrEmpty(ptTableName))
                                        {
                                            if (!String.IsNullOrEmpty(ptDisplayName))
                                            {
                                                parameterTableNamesWithDisplayValues.Add(new KeyValuePair<String, String>(ptTableName,
                                                                                                                                ptDisplayName));
                                            }
                                            else if (!String.IsNullOrEmpty(ptName))
                                            {
                                                parameterTableNamesWithDisplayValues.Add(new KeyValuePair<String, String>(ptTableName,
                                                                                                                                ptName));
                                            }
                                            else
                                            {
                                                parameterTableNamesWithDisplayValues.Add(new KeyValuePair<String, String>(ptTableName,
                                                                                                                                ptTableName));
                                            }
                                        }
                                    }

                                    // Sort the list by value before returning from method
                                    // The reason to sort here instead of in query is in case some of the parameter tables returned have null or empty nm_display_name and we have to use nm_name or nm_instance_tablename instead as the value
                                    parameterTableNamesWithDisplayValues.Sort(
                                      (firstPair, nextPair) =>
                                      String.Compare(firstPair.Value, nextPair.Value, false, CultureInfo.InvariantCulture)
                                      );
                                }
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    parameterTableNamesWithDisplayValues.Clear();
                    m_Logger.LogException("GetParameterTableNamesWithDisplayValues failed", e);
                    throw new MASBasicException("GetParameterTableNamesWithDisplayValues failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetAccUsageColumnNames(ref MTList<string> accUsageColumnNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAccUsageColumnNames"))
            {
                GetTableColumnNames("t_acc_usage", ref accUsageColumnNames);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetParameterTableColumnNamesWithDisplayValues(string tableName,
          ref MTList<KeyValuePair<String, String>> parameterTableColumnNamesWithDisplayValues)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetParameterTableColumnNamesWithDisplayValues"))
            {
                m_Logger.LogDebug("GetParameterTableColumnNamesWithDisplayValues");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_PARAMETER_TABLE_COLUMN_NAMES_WITH_DISPLAY_VALUES__");

                            using (IMTPreparedStatement stmt =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("ptTableName", MTParameterType.BigInteger, tableName);
                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int ptNameIndex = rdr.GetOrdinal("nm_column_name");

                                        string ptName = null;

                                        if (!rdr.IsDBNull(ptNameIndex))
                                        {
                                            ptName = rdr.GetString(ptNameIndex);
                                        }

                                        int ptDisplayNameIndex = rdr.GetOrdinal("nm_name");

                                        string ptDisplayName = null;

                                        if (!rdr.IsDBNull(ptDisplayNameIndex))
                                        {
                                            ptDisplayName = rdr.GetString(ptDisplayNameIndex);
                                        }

                                        if (!String.IsNullOrEmpty(ptName))
                                        {
                                            parameterTableColumnNamesWithDisplayValues.Items.Add(!String.IsNullOrEmpty(ptDisplayName)
                                                                                             ? new KeyValuePair<String, String>(ptName,
                                                                                                                                ptDisplayName)
                                                                                             : new KeyValuePair<String, String>(ptName, ptName));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    parameterTableColumnNamesWithDisplayValues.Items.Clear();
                    m_Logger.LogException("GetParameterTableColumnNamesWithDisplayValues failed", e);
                    throw new MASBasicException("GetParameterTableColumnNamesWithDisplayValues failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetProductViewColumnNames(string productViewTableName,
                                              ref MTList<string> productViewColumnNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetProductViewColumnNames"))
            {
                if (String.IsNullOrEmpty(productViewTableName))
                {
                    throw new MASBasicException("GetProductViewColumnNames: productViewTableName is null or empty string");
                }

                GetTableColumnNames(productViewTableName, ref productViewColumnNames);
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetProductViewColumnNamesWithTypes(string productViewTableName,
                                                       ref MTList<ProductViewPropertyInstance> productViewColumnNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetProductViewColumnNamesWithTypes"))
            {
                if (String.IsNullOrEmpty(productViewTableName))
                {
                    throw new MASBasicException("GetProductViewColumnNamesWithTypes: productViewTableName is null or empty string");
                }

                m_Logger.LogDebug("GetProductViewColumnNamesWithTypes");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_TABLE_COLUMN_NAMES_WITH_TYPE_FROM_T_PROD_VIEW_PROP__");

                            using (IMTPreparedFilterSortStatement stmt =
                              conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<ProductViewPropertyInstance>(stmt, productViewColumnNames);

                                stmt.AddParam("tableName", MTParameterType.String, productViewTableName);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        var prop = new ProductViewPropertyInstance();

                                        int idIndex = rdr.GetOrdinal("ID");
                                        if (!rdr.IsDBNull(idIndex))
                                        {
                                            prop.ID = rdr.GetInt32(idIndex);
                                        }

                                        int nameIndex = rdr.GetOrdinal("NAME");
                                        if (!rdr.IsDBNull(nameIndex))
                                        {
                                            prop.Name = rdr.GetString(nameIndex);
                                        }

                                        int columnNameIndex = rdr.GetOrdinal("COLUMN_NAME");
                                        if (!rdr.IsDBNull(columnNameIndex))
                                        {
                                            prop.ColumnName = rdr.GetString(columnNameIndex);
                                        }

                                        int dataTypeIndex = rdr.GetOrdinal("DATA_TYPE");
                                        if (!rdr.IsDBNull(dataTypeIndex))
                                        {
                                            prop.DataType = rdr.GetString(dataTypeIndex);
                                        }

                                        int nmSpaceIndex = rdr.GetOrdinal("NM_SPACE");
                                        if (!rdr.IsDBNull(nmSpaceIndex))
                                        {
                                            prop.NmSpace = rdr.GetString(nmSpaceIndex);
                                        }

                                        int nmEnumIndex = rdr.GetOrdinal("NM_ENUM");
                                        if (!rdr.IsDBNull(nmEnumIndex))
                                        {
                                            prop.NmEnum = rdr.GetString(nmEnumIndex);
                                        }

                                        int nmEnumDataIndex = rdr.GetOrdinal("NM_ENUM_DATA");
                                        if (!rdr.IsDBNull(nmEnumDataIndex))
                                        {
                                            prop.NmEnumData = rdr.GetString(nmEnumDataIndex);
                                        }

                                        var localizedNames = new Dictionary<LanguageCode, string>();
                                        using (var subqueryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                                        {
                                            subqueryAdapter.Item = new MTQueryAdapterClass();
                                            subqueryAdapter.Item.Init(AMP_QUERY_DIR);
                                            subqueryAdapter.Item.SetQueryTag("__GET_PROD_VIEW_PROP_DESCRIPTION_TEXT__");

                                            using (IMTAdapterStatement subStmt =
                                              conn.CreateAdapterStatement(subqueryAdapter.Item.GetRawSQLQuery(true)))
                                            {
                                                subStmt.AddParam("%%nmEnumData%%", prop.NmEnumData);
                                                using (IMTDataReader subRdr = subStmt.ExecuteReader())
                                                {
                                                    while (subRdr.Read())
                                                    {
                                                        int idLangCode = 0;
                                                        string description = null;

                                                        int idLangCodeIndex = subRdr.GetOrdinal("ID_LANG_CODE");
                                                        if (!subRdr.IsDBNull(idLangCodeIndex))
                                                        {
                                                            idLangCode = subRdr.GetInt32(idLangCodeIndex);
                                                        }

                                                        int txDescIndex = subRdr.GetOrdinal("TX_DESC");
                                                        if (!subRdr.IsDBNull(txDescIndex))
                                                        {
                                                            description = subRdr.GetString(txDescIndex);
                                                        }

                                                        if (description == null) continue;
                                                        var languageCode =
                                                          (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), idLangCode.ToString());
                                                        localizedNames.Add(languageCode, description);
                                                    }
                                                }
                                            }
                                        }
                                        prop.LocalizedDisplayNames = localizedNames;
                                        productViewColumnNames.Items.Add(prop);
                                    }
                                }
                                productViewColumnNames.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    productViewColumnNames.Items.Clear();
                    m_Logger.LogException("GetProductViewColumnNamesWithTypes failed", e);
                    throw new MASBasicException("GetProductViewColumnNamesWithTypes failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetTableColumnNames(string tableName,
          ref MTList<string> tableColumnNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetTableColumnNames"))
            {
                if (String.IsNullOrEmpty(tableName))
                {
                    throw new MASBasicException("GetTableColumnNames: tableName is null or empty string");
                }

                m_Logger.LogDebug("GetTableColumnNames");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_TABLE_COLUMN_NAMES__");

                            if (!tableName.ToLower().Equals("t_acc_usage"))
                                tableColumnNames.Filters.Add(new MTFilterElement("COLUMN_NAME", MTFilterElement.OperationType.Like, "c_%"));

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<string>(stmt, tableColumnNames);

                                stmt.AddParam("tableName", MTParameterType.String, tableName);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int columnNameIndex = rdr.GetOrdinal("COLUMN_NAME");

                                        string columnName = null;

                                        if (!rdr.IsDBNull(columnNameIndex))
                                        {
                                            columnName = rdr.GetString(columnNameIndex);
                                            tableColumnNames.Items.Add(columnName);
                                        }
                                    }
                                }

                                tableColumnNames.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    tableColumnNames.Items.Clear();
                    m_Logger.LogException("GetTableColumnNames failed", e);
                    throw new MASBasicException("GetTableColumnNames failed. " + e.Message);
                }
            }
        }

        [OperationCapability("ManageAmpDecisions")]
        public void GetProductViewColumnNamesAndDescriptions(string tableName,
          ref MTList<string> columnInfo)
        {
        }


        [OperationCapability("ManageAmpDecisions")]
        public void GetCurrencyNames(ref MTList<string> currencyNames)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("GetCurrencyNames"))
            {
                m_Logger.LogDebug("GetCurrencyNames");
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__GET_SYSTEM_CURRENCIES__");

                            using (IMTPreparedFilterSortStatement stmt =
                                conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                ApplyFilterSortCriteria<string>(stmt, currencyNames);

                                using (IMTDataReader rdr = stmt.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        int currencyIndex = rdr.GetOrdinal("nm_enum_data");

                                        string currencyName = null;
                                        string shortCurrencyName = null;

                                        if (!rdr.IsDBNull(currencyIndex))
                                        {
                                            currencyName = rdr.GetString(currencyIndex);

                                            // The returned string will look like this:
                                            //      "Global/SystemCurrencies/SystemCurrencies/EUR"
                                            // The GUI is only interested in the characters
                                            // after the last "/".
                                            int lastSlash = currencyName.LastIndexOf("/");
                                            if (lastSlash != -1)
                                            {
                                                shortCurrencyName = currencyName.Substring(lastSlash + 1);
                                            }
                                        }

                                        if (shortCurrencyName != null)
                                        {
                                            currencyNames.Items.Add(shortCurrencyName);
                                        }
                                    }
                                }

                                currencyNames.TotalRows = stmt.TotalRows;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    currencyNames.Items.Clear();
                    m_Logger.LogException("GetCurrencyNames failed", e);
                    throw new MASBasicException("GetCurrencyNames failed. " + e.Message);
                }
            }
        }
        #endregion

        #region PRIVATE_DECISION_METHODS
        /// <summary>
        /// Retrieves the display name for a parameter table for a decision
        /// and fills the decision object field for that display name.
        /// </summary>
        /// <param name="decision">incipient decision object.  It has some high level
        /// fields filled in already, and this method will fill hte rest.</param>
        private void RetrieveAndPopulateParameterTableDisplayName(ref Decision decision)
        {
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_PARAMETER_TABLE_DISPLAY_NAME__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("parameterTableName", MTParameterType.String, decision.ParameterTableName);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    int displayNameIndex = rdr.GetOrdinal("DISPLAYNAME");

                                    string displayName = null;

                                    if (!rdr.IsDBNull(displayNameIndex))
                                    {
                                        displayName = rdr.GetString(displayNameIndex);
                                    }

                                    decision.ParameterTableDisplayName = displayName;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateParameterTableDisplayName failed", e);
                throw new MASBasicException("RetrieveAndPopulateParameterTableDisplayName failed. " + e.Message);
            }
        }

        /// <summary>
        /// Retrieves rows from t_amp_decisionattributes that apply to the specified decision
        /// and fills a decision object fields.
        /// </summary>
        /// <param name="decision">incipient decision object.  It has some high level
        /// fields filled in already, and this method will fill hte rest.</param>
        private void RetrieveAndPopulateDecisionAttributes(ref Decision decision)
        {
            decision.OtherAttributes = new Dictionary<string, DecisionAttributeValue>();

            //
            // ChargeCondition, ChargeValue, and ChargeColumnName are special because the DB
            // supports multiple values of ChargeCondition within the same decision, but
            // the GUI does not support multiple values.
            // So in the service, we initialize the values below, and only the
            // last value of ChargeCondition/ChargeValue/ChargeColumnName will be shown via the GUI.
            decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_NONE;
            decision.ChargeValue = null;
            decision.ChargeColumnName = null;

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_DECISION_ATTRIBUTES__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("uniqueId", MTParameterType.Guid, decision.UniqueId);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    // Each record contains the name of the attribute and either
                                    // a hard coded value for the attribute, or a column name from the
                                    // parameterTable where the value is located.
                                    int attributeNameIndex = rdr.GetOrdinal("c_AttributeName");
                                    int attributeValueIndex = rdr.GetOrdinal("c_DefaultValue");
                                    int attributeColumnNameIndex = rdr.GetOrdinal("c_ColumnName");
                                    m_Logger.LogDebug("attributeNameIndex={0}", attributeNameIndex);
                                    m_Logger.LogDebug("attributeValueIndex={0}", attributeValueIndex);
                                    m_Logger.LogDebug("attributeColumnNameIndex={0}", attributeColumnNameIndex);

                                    string attributeName = null;
                                    string attributeValue = null;
                                    string attributeColumnName = null;

                                    if (!rdr.IsDBNull(attributeNameIndex))
                                    {
                                        attributeName = rdr.GetString(attributeNameIndex);
                                        m_Logger.LogDebug("attributeName={0}", attributeName);
                                    }

                                    if (!rdr.IsDBNull(attributeValueIndex))
                                    {
                                        attributeValue = rdr.GetString(attributeValueIndex);
                                        m_Logger.LogDebug("attributeValue={0}", attributeValue);
                                    }

                                    if (!rdr.IsDBNull(attributeColumnNameIndex))
                                    {
                                        attributeColumnName = rdr.GetString(attributeColumnNameIndex);
                                        m_Logger.LogDebug("attributeColumnName={0}", attributeColumnName);
                                    }

                                    StoreAttributeInDomainModel(attributeName, attributeValue,
                                        attributeColumnName, ref decision);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateDecisionAttributes failed", e);
                throw new MASBasicException("RetrieveAndPopulateDecisionAttributes failed. " + e.Message);
            }
        }

        /// <summary>
        /// Retrieves default decision attribute values from t_amp_decisionglobal
        /// and stores them in the specified decision object.
        /// </summary>
        /// <param name="decision">incipient decision object.  It has some high level
        /// fields filled in already, and this method will fill hte rest.</param>
        private void PopulateDecisionWithDefaultAttributes(ref Decision decision)
        {
            //
            // ChargeCondition, ChargeValue, and ChargeColumnName are special because the DB
            // supports multiple values of ChargeCondition within the same decision, but
            // the GUI does not support multiple values.
            // So in the service, we initialize the values below, and only the
            // last value of ChargeCondition/ChargeValue/ChargeColumnName will be shown via the GUI.
            decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_NONE;
            decision.ChargeValue = null;
            decision.ChargeColumnName = null;

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_DEFAULT_DECISION_ATTRIBUTES__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    int nameIndex = rdr.GetOrdinal("c_Name");
                                    int defaultValueIndex = rdr.GetOrdinal("c_DefaultValue");
                                    string attributeName = null;
                                    string attributeDefaultValue = null;
                                    if (!rdr.IsDBNull(nameIndex))
                                    {
                                        attributeName = rdr.GetString(nameIndex);
                                        m_Logger.LogDebug("attributeName={0}", attributeName);
                                    }
                                    else
                                    {
                                        m_Logger.LogError("unexpected null c_Name");
                                        continue;
                                    }

                                    if (!rdr.IsDBNull(defaultValueIndex))
                                    {
                                        attributeDefaultValue = rdr.GetString(defaultValueIndex);
                                        m_Logger.LogDebug("attributeDefaultValue={0}", attributeDefaultValue);
                                    }
                                    else
                                    {
                                        m_Logger.LogDebug("null c_DefaultValue");
                                    }
                                    StoreAttributeInDomainModel(attributeName, attributeDefaultValue, null, ref decision);
                                }
                            }
                        }
                    }

                    // Note: TierOverrideName is not supported by the GUI.  For now, we store the
                    // decisionName as the value for Tier Override Name
                    StoreAttributeInDomainModel("Tier Override Name", decision.Name, null, ref decision);
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("PopulateDecisionWithDefaultAttributes failed", e);
                throw new MASBasicException("PopulateDecisionWithDefaultAttributes failed. " + e.Message);
            }
        }

        /// <summary>
        /// Each decision attribute is stored in a row in t_amp_decisionattributes.
        /// This method knows how to take the info from a row in the DB and store it in
        /// the decision domain model object.
        /// <param name="attributeName">name of the attribute to be stored</param>
        /// <param name="attributeValue">hard coded value for the specified attribute</param>
        /// <param name="attributeColumnName">column where the value for this attribute can be found</param>
        /// <param name="decision"></param>
        /// </summary>
        private void StoreAttributeInDomainModel(string attributeName, string attributeValue,
            string attributeColumnName, ref Decision decision)
        {
            if (attributeName == null)
            {
                m_Logger.LogError("StoreAttributeInDomainModel: attributeName is null");
                return;
            }

            if ((attributeValue != null) && (attributeColumnName != null))
            {
                m_Logger.LogError(
                    "StoreAttributeInDomainModel: both hard coded and column name were specified" +
                    "for parameter {0}, discarding the hard coded value {1}",
                    attributeName, attributeValue);
                attributeValue = null;
            }

            if ((attributeValue == null) && (attributeColumnName == null))
            {
                m_Logger.LogDebug(
                    "StoreAttributeInDomainModel both hard coded and column name were null " +
                    "for parameter {0}",
                    attributeName);
            }

            m_Logger.LogDebug(
                "StoreAttributeInDomainModel: attributeName={0}, attributeValue={1}",
                attributeName, attributeValue);

            if (attributeName.Equals("Tier Start"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.TierStartValue = null;
                    decision.TierStartColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.TierStartValue = Decimal.Parse(attributeValue);
                }
                else
                {
                    decision.TierStartColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Tier End"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.TierEndValue = null;
                    decision.TierEndColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.TierEndValue = Decimal.Parse(attributeValue);
                }
                else
                {
                    decision.TierEndColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Per Event Rate"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.PerEventCostValue = null;
                    decision.PerEventCostColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.PerEventCostValue = Decimal.Parse(attributeValue);
                }
                else
                {
                    decision.PerEventCostColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Tier Repetition"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.TierRepetitionValue = null;
                    decision.TierRepetitionColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.TierRepetitionValue = attributeValue;
                }
                else
                {
                    decision.TierRepetitionColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Tier Override Name"))
            {
                //
                // NOTE: THIS ATTRIBUTE IS NOT SUPPORTED BY THE GUI
                //
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.TierOverrideNameValue = null;
                    decision.TierOverrideNameColumnName = null;
                }
                else
                    if (attributeValue != null)
                    {
                        decision.TierOverrideNameValue = attributeValue;
                    }
                    else
                    {
                        decision.TierOverrideNameColumnName = attributeColumnName;
                    }
            }
            else if (attributeName.Equals("Cycle Unit Offset"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.CycleUnitsOffsetValue = null;
                    decision.CycleUnitsOffsetColumnName = null;
                }
                else
                    if (attributeValue != null)
                    {
                        decision.CycleUnitsOffsetValue = Int32.Parse(attributeValue);
                    }
                    else
                    {
                        decision.CycleUnitsOffsetColumnName = attributeColumnName;
                    }
            }
            else if (attributeName.Equals("Amount Chain Group"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.PvToAmountChainMappingColumnName = null;
                    decision.PvToAmountChainMappingValue = null;
                }
                else if (attributeValue != null)
                {
                    decision.PvToAmountChainMappingValue = attributeValue;
                }
                else
                {
                    decision.PvToAmountChainMappingColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Charge On Inbound"))
            {
                if (attributeValue != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_INBOUND;
                    decision.ChargeValue = Decimal.Parse(attributeValue);
                }
                else if (attributeColumnName != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_INBOUND;
                    decision.ChargeColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Charge Type"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_FLAT;
                }
                else if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("FLAT"))
                    {
                        decision.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_FLAT;
                    }
                    else if (attributeValue.ToUpper().Equals("PROPORTIONAL"))
                    {
                        decision.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_PROPORTIONAL;
                    }
                    else if (attributeValue.ToUpper().Equals("INVERSE_PROPORTIONAL"))
                    {
                        decision.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_INVERSE_PROPORTIONAL;
                    }
                    else if (attributeValue.ToUpper().Equals("PERCENTAGE"))
                    {
                        decision.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_PERCENTAGE;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}",
                            attributeName, attributeValue);
                    }
                }
                else
                {
                    // don't expect column name
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} should not be set via column name",
                        attributeName);
                }
            }
            else if (attributeName.Equals("Cycles"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.CyclesValue = null;
                    decision.CyclesColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.CyclesValue = Int32.Parse(attributeValue);
                }
                else
                {
                    decision.CyclesColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Tier Domain"))
            {
                if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("RATABLE"))
                    {
                        decision.IsUsageConsumed = true;
                    }
                    else if (attributeValue.ToUpper().Equals("COUNTABLE"))
                    {
                        decision.IsUsageConsumed = false;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}",
                            attributeName, attributeValue);
                    }
                }
                else
                {
                    // don't expect column name
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} should not be set via column name",
                        attributeName);
                }
            }
            else if (attributeName.Equals("Charge On Final"))
            {
                if (attributeValue != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_FINAL;
                    decision.ChargeValue = Decimal.Parse(attributeValue);
                }
                else if (attributeColumnName != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_FINAL;
                    decision.ChargeColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Charge On Every"))
            {
                if (attributeValue != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_EVERY;
                    decision.ChargeValue = Decimal.Parse(attributeValue);
                }
                else if (attributeColumnName != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_EVERY;
                    decision.ChargeColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Tier Priority"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.PriorityValue = null;
                    decision.PriorityColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.PriorityValue = Int32.Parse(attributeValue);
                }
                else
                {
                    decision.PriorityColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Charge On Outbound"))
            {
                if (attributeValue != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_OUTBOUND;
                    decision.ChargeValue = Decimal.Parse(attributeValue);
                }
                else if (attributeColumnName != null)
                {
                    decision.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_OUTBOUND;
                    decision.ChargeColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Account Qualification Group"))
            {
                if (attributeValue != null)
                {
                    decision.AccountQualificationGroup = attributeValue;
                }
                else
                {
                    // don't expect column name
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} should not be set via column name",
                        attributeName);
                }
            }
            else if (attributeName.Equals("Tier Discount"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.TierDiscountValue = null;
                    decision.TierDiscountColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.TierDiscountValue = Decimal.Parse(attributeValue);
                }
                else
                {
                    decision.TierDiscountColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Tier Unit Type"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.ItemAggregatedValue = null;
                    decision.ItemAggregatedColumnName = null;
                }
                else if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("AMOUNT"))
                    {
                        decision.ItemAggregatedValue = Decision.ItemAggregatedEnum.AGGREGATE_AMOUNT;
                    }
                    else if (attributeValue.ToUpper().Equals("EVENTS"))
                    {
                        decision.ItemAggregatedValue = Decision.ItemAggregatedEnum.AGGREGATE_USAGE_EVENTS;
                    }
                    else if (attributeValue.ToUpper().Equals("UNITS"))
                    {
                        decision.ItemAggregatedValue = Decision.ItemAggregatedEnum.AGGREGATE_UNITS_OF_USAGE;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}",
                            attributeName, attributeValue);
                    }
                }
                else
                {
                    decision.ItemAggregatedColumnName = attributeColumnName;
                }

            }
            else if (attributeName.Equals("Cycle Units Per Tier"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.CycleUnitsPerTierValue = null;
                    decision.CycleUnitsPerTierColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.CycleUnitsPerTierValue = Int32.Parse(attributeValue);
                }
                else
                {
                    decision.CycleUnitsPerTierColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Cycle Unit Type"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.CycleUnitTypeValue = null;
                    decision.CycleUnitTypeColumnName = null;
                }
                else if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("INTERVAL"))
                    {
                        decision.CycleUnitTypeValue = Decision.CycleUnitTypeEnum.CYCLE_SAME_AS_BILLING_INTERVAL;
                    }
                    else if (attributeValue.ToUpper().Equals("DAILY"))
                    {
                        decision.CycleUnitTypeValue = Decision.CycleUnitTypeEnum.CYCLE_DAILY;
                    }
                    else if (attributeValue.ToUpper().Equals("WEEKLY"))
                    {
                        decision.CycleUnitTypeValue = Decision.CycleUnitTypeEnum.CYCLE_WEEKLY;
                    }
                    else if (attributeValue.ToUpper().Equals("MONTHLY"))
                    {
                        decision.CycleUnitTypeValue = Decision.CycleUnitTypeEnum.CYCLE_MONTHLY;
                    }
                    else if (attributeValue.ToUpper().Equals("QUARTERLY"))
                    {
                        decision.CycleUnitTypeValue = Decision.CycleUnitTypeEnum.CYCLE_QUARTERLY;
                    }
                    else if (attributeValue.ToUpper().Equals("ANNUALLY"))
                    {
                        decision.CycleUnitTypeValue = Decision.CycleUnitTypeEnum.CYCLE_ANNUALLY;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}",
                            attributeName, attributeValue);
                    }
                }
                else
                {
                    // attribute is a column name
                    decision.CycleUnitTypeValue = Decision.CycleUnitTypeEnum.CYCLE_GET_FROM_PARAMETER_TABLE;
                    decision.CycleUnitTypeColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Usage Qualification Group"))
            {
                if (attributeValue != null)
                {
                    decision.UsageQualificationGroup = attributeValue;
                }
                else
                {
                    // don't expect column name
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} should not be set via column name",
                        attributeName);
                }
            }
            else if (attributeName.Equals("Generated Charge"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.GeneratedCharge = null;
                }
                else if (attributeValue != null)
                {
                    decision.GeneratedCharge = attributeValue;
                }
                else
                {
                    // don't expect column name
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} should not be set via column name",
                        attributeName);
                }
            }
            else if (attributeName.Equals("Tier Domain Impact"))
            {
                // The GUI supports only these combinations for IsUsageConsumed:
                // a. IsUsageConsumed==false <=> Tier Domain = countable, Tier Domain Impact = null  (default)
                // b. IsUsageConsumer==true  <=> Tier Domain = ratable,  Tier Domain Impact = ratable
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.IsUsageConsumed = false;
                }
                else if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("RATABLE"))
                    {
                        decision.IsUsageConsumed = true;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}",
                            attributeName, attributeValue);
                    }
                }
                else
                {
                    // don't expect column name
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} should not be set via column name",
                        attributeName);
                }
            }
            else if (attributeName.Equals("Per Unit Rate"))
            {
                if ((attributeValue == null) && (attributeColumnName == null))
                {
                    decision.PerUnitRateValue = null;
                    decision.PerUnitRateColumnName = null;
                }
                else if (attributeValue != null)
                {
                    decision.PerUnitRateValue = Decimal.Parse(attributeValue);
                }
                else
                {
                    decision.PerUnitRateColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Tier Qualified Usage"))
            {
                if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("INCREMENTAL"))
                    {
                        decision.IsBulkDecision = false;
                    }
                    else if (attributeValue.ToUpper().Equals("BULK"))
                    {
                        decision.IsBulkDecision = true;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}",
                            attributeName, attributeValue);
                        m_Logger.LogError("Setting decision.IsBulk = false");
                        decision.IsBulkDecision = false;
                    }
                }
                else
                {
                    // don't expect column name
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} should not be set via column name",
                        attributeName);
                }
            }
            else if (attributeName.Equals("Tier Proration"))
            {
                if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("NO PRORATION"))
                    {
                        decision.TierProrationValue = Decision.TierProrationEnum.PRORATE_NONE;
                    }
                    else if (attributeValue.ToUpper().Equals("PRORATE ACTIVATION"))
                    {
                        decision.TierProrationValue = Decision.TierProrationEnum.PRORATE_TIER_START;
                    }
                    else if (attributeValue.ToUpper().Equals("PRORATE TERMINATION"))
                    {
                        decision.TierProrationValue = Decision.TierProrationEnum.PRORATE_TIER_END;
                    }
                    else if (attributeValue.ToUpper().Equals("PRORATE BOTH"))
                    {
                        decision.TierProrationValue = Decision.TierProrationEnum.PRORATE_BOTH;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}",
                            attributeName, attributeValue);
                        m_Logger.LogError("Setting decision.TierProration = PRORATE_NONE");
                        decision.TierProrationValue = Decision.TierProrationEnum.PRORATE_NONE;
                    }
                }
                else
                {
                    decision.TierProrationColumnName = attributeColumnName;
                }
            }
            else if (attributeName.Equals("Is Active"))
            {
                if (attributeValue != null)
                {
                    if (attributeValue.Equals("0"))
                    {
                        decision.IsActive = false;
                    }
                    else
                    {
                        decision.IsActive = true;
                    }
                }
                else
                {
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} contains NULL value, setting IsActive to true",
                        attributeName);
                    decision.IsActive = true;
                }
            }
            else if (attributeName.Equals("Is Editable"))
            {
                if (attributeValue != null)
                {
                    if (attributeValue.Equals("0"))
                    {
                        decision.IsEditable = false;
                    }
                    else
                    {
                        decision.IsEditable = true;
                    }
                }
                else
                {
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} contains NULL value, setting IsEditable to true",
                        attributeName);
                    decision.IsEditable = true;
                }
            }
            else if (attributeName.Equals("Execution Frequency"))
            {
                if (attributeValue != null)
                {
                    if (attributeValue.ToUpper().Equals("DURING_EOP"))
                    {
                        decision.ExecutionFrequency = Decision.ExecutionFrequencyEnum.DURING_EOP;
                    }
                    else if (attributeValue.ToUpper().Equals("DURING_SCHEDULED_RUNS"))
                    {
                        decision.ExecutionFrequency = Decision.ExecutionFrequencyEnum.DURING_SCHEDULED_RUNS;
                    }
                    else if (attributeValue.ToUpper().Equals("DURING_BOTH"))
                    {
                        decision.ExecutionFrequency = Decision.ExecutionFrequencyEnum.DURING_BOTH;
                    }
                    else
                    {
                        m_Logger.LogError(
                            "StoreAttributeInDomainModel: parameter {0} contains unexpected value {1}, setting ExecutionFrequency to DURING_EOP",
                            attributeName, attributeValue);
                        decision.ExecutionFrequency = Decision.ExecutionFrequencyEnum.DURING_EOP;
                    }
                }
                else
                {
                    m_Logger.LogError(
                        "StoreAttributeInDomainModel: parameter {0} contains NULL value, setting ExecutionFrequency to DURING_EOP",
                        attributeName);
                    decision.ExecutionFrequency = Decision.ExecutionFrequencyEnum.DURING_EOP;
                }
            }
            else
            {
                m_Logger.LogDebug(
                    "StoreAttributeInDomainModel: unhandled attribute {0} being stored in OtherAttributes",
                    attributeName);
                DecisionAttributeValue decisionAttributeValue = new DecisionAttributeValue();
                decisionAttributeValue.HardCodedValue = attributeValue;
                decisionAttributeValue.ColumnName = attributeColumnName;
                decision.OtherAttributes.Add(attributeName, decisionAttributeValue);
            }
        }

        /// <summary>
        /// Update the DB with the decision attributes contained in the specified
        /// domain model object.
        /// </summary>
        /// <param name="decision">domain model object containing all of the decision attributes</param>
        private void StoreAttributesInDb(Decision decision)
        {
            StoreAttributeInDb(decision.UniqueId, "Tier Start",
                decision.TierStartValue.HasValue ? decision.TierStartValue.ToString() : null,
                decision.TierStartColumnName, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Tier End",
                decision.TierEndValue.HasValue ? decision.TierEndValue.ToString() : null,
                decision.TierEndColumnName, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Per Event Rate",
                decision.PerEventCostValue.HasValue ? decision.PerEventCostValue.ToString() : null,
                decision.PerEventCostColumnName, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Tier Repetition",
                decision.TierRepetitionValue,
                decision.TierRepetitionColumnName, decision.ParameterTableName);

            // Note: TierOverride is not supported by the GUI
            StoreAttributeInDb(decision.UniqueId, "Tier Override Name",
                decision.TierOverrideNameValue,
                decision.TierOverrideNameColumnName, decision.ParameterTableName);

            StoreAttributeInDb(decision.UniqueId, "Cycle Unit Offset",
                decision.CycleUnitsOffsetValue.HasValue ? decision.CycleUnitsOffsetValue.ToString() : null,
                decision.CycleUnitsOffsetColumnName, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Amount Chain Group",
                decision.PvToAmountChainMappingValue,
                decision.PvToAmountChainMappingColumnName, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Generated Charge",
                decision.GeneratedCharge, null, decision.ParameterTableName);
            switch (decision.ChargeCondition)
            {
                case Decision.ChargeConditionEnum.CHARGE_NONE:
                    StoreAttributeInDb(decision.UniqueId, "Charge On Inbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Outbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Every", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Final", null, null, decision.ParameterTableName);
                    break;

                case Decision.ChargeConditionEnum.CHARGE_ON_INBOUND:
                    StoreAttributeInDb(decision.UniqueId, "Charge On Inbound",
                        decision.ChargeValue.HasValue ? decision.ChargeValue.ToString() : null,
                        decision.ChargeColumnName, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Outbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Every", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Final", null, null, decision.ParameterTableName);
                    break;

                case Decision.ChargeConditionEnum.CHARGE_ON_OUTBOUND:
                    StoreAttributeInDb(decision.UniqueId, "Charge On Inbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Outbound",
                        decision.ChargeValue.HasValue ? decision.ChargeValue.ToString() : null,
                        decision.ChargeColumnName, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Every", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Final", null, null, decision.ParameterTableName);
                    break;

                case Decision.ChargeConditionEnum.CHARGE_ON_EVERY:
                    StoreAttributeInDb(decision.UniqueId, "Charge On Inbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Outbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Every",
                        decision.ChargeValue.HasValue ? decision.ChargeValue.ToString() : null,
                        decision.ChargeColumnName, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Final", null, null, decision.ParameterTableName);
                    break;

                case Decision.ChargeConditionEnum.CHARGE_ON_FINAL:
                    StoreAttributeInDb(decision.UniqueId, "Charge On Inbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Outbound", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Every", null, null, decision.ParameterTableName);
                    StoreAttributeInDb(decision.UniqueId, "Charge On Final",
                        decision.ChargeValue.HasValue ? decision.ChargeValue.ToString() : null,
                        decision.ChargeColumnName, decision.ParameterTableName);
                    break;
            }
            switch (decision.ChargeAmountType)
            {
                case Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_FLAT:
                    StoreAttributeInDb(decision.UniqueId, "Charge Type", "flat", null, decision.ParameterTableName);
                    break;

                case Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_PROPORTIONAL:
                    StoreAttributeInDb(decision.UniqueId, "Charge Type", "proportional", null, decision.ParameterTableName);
                    break;

                case Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_INVERSE_PROPORTIONAL:
                    StoreAttributeInDb(decision.UniqueId, "Charge Type", "inverse_proportional", null, decision.ParameterTableName);
                    break;

                case Decision.ChargeAmountTypeEnum.CHARGE_PERCENTAGE:
                    StoreAttributeInDb(decision.UniqueId, "Charge Type", "percentage", null, decision.ParameterTableName);
                    break;
            }
            StoreAttributeInDb(decision.UniqueId, "Cycles",
                decision.CyclesValue.HasValue ? decision.CyclesValue.ToString() : null,
                decision.CyclesColumnName, decision.ParameterTableName);

            // The GUI supports only these combinations for IsUsageConsumed:
            // a. IsUsageConsumed==false <=> Tier Domain = countable, Tier Domain Impact = null  (default)
            // b. IsUsageConsumer==true  <=> Tier Domain = ratable,  Tier Domain Impact = ratable
            if (!decision.IsUsageConsumed.HasValue)
            {
                // Since no value has been specified for this decision, we will use the default values of countable/null.
                StoreAttributeInDb(decision.UniqueId, "Tier Domain", "countable", null, decision.ParameterTableName);
                StoreAttributeInDb(decision.UniqueId, "Tier Domain Impact", null, null, decision.ParameterTableName);
            }
            else if (decision.IsUsageConsumed.Value)
            {
                StoreAttributeInDb(decision.UniqueId, "Tier Domain", "ratable", null, decision.ParameterTableName);
                StoreAttributeInDb(decision.UniqueId, "Tier Domain Impact", "ratable", null, decision.ParameterTableName);
            }
            else
            {
                StoreAttributeInDb(decision.UniqueId, "Tier Domain", "countable", null, decision.ParameterTableName);
                StoreAttributeInDb(decision.UniqueId, "Tier Domain Impact", null, null, decision.ParameterTableName);
            }
            StoreAttributeInDb(decision.UniqueId, "Tier Priority",
                decision.PriorityValue.HasValue ? decision.PriorityValue.ToString() : null,
                decision.PriorityColumnName, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Account Qualification Group",
                decision.AccountQualificationGroup, null, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Tier Discount",
                decision.TierDiscountValue.HasValue ? decision.TierDiscountValue.ToString() : null,
                decision.TierDiscountColumnName, decision.ParameterTableName);
            if (decision.ItemAggregatedValue.HasValue)
            {
                switch (decision.ItemAggregatedValue)
                {
                    case Decision.ItemAggregatedEnum.AGGREGATE_AMOUNT:
                        StoreAttributeInDb(decision.UniqueId, "Tier Unit Type", "amount", null,
                                           decision.ParameterTableName);
                        break;

                    case Decision.ItemAggregatedEnum.AGGREGATE_USAGE_EVENTS:
                        StoreAttributeInDb(decision.UniqueId, "Tier Unit Type", "events", null,
                                           decision.ParameterTableName);
                        break;

                    case Decision.ItemAggregatedEnum.AGGREGATE_UNITS_OF_USAGE:
                        StoreAttributeInDb(decision.UniqueId, "Tier Unit Type", "units", null,
                                           decision.ParameterTableName);
                        break;
                }
            }
            else
            {
                // Tier Unit Type is coming from a parameter table column
                StoreAttributeInDb(decision.UniqueId, "Tier Unit Type", null, decision.ItemAggregatedColumnName, decision.ParameterTableName);
            }
            StoreAttributeInDb(decision.UniqueId, "Cycle Units Per Tier",
                decision.CycleUnitsPerTierValue.HasValue ? decision.CycleUnitsPerTierValue.ToString() : null,
                decision.CycleUnitsPerTierColumnName, decision.ParameterTableName);
            if (decision.CycleUnitTypeValue.HasValue)
            {
              switch (decision.CycleUnitTypeValue)
              {
                case Decision.CycleUnitTypeEnum.CYCLE_SAME_AS_BILLING_INTERVAL:
                  StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", "interval", null, decision.ParameterTableName);
                  break;

                case Decision.CycleUnitTypeEnum.CYCLE_DAILY:
                  StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", "daily", null, decision.ParameterTableName);
                  break;

                case Decision.CycleUnitTypeEnum.CYCLE_WEEKLY:
                  StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", "weekly", null, decision.ParameterTableName);
                  break;

                case Decision.CycleUnitTypeEnum.CYCLE_MONTHLY:
                  StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", "monthly", null, decision.ParameterTableName);
                  break;

                case Decision.CycleUnitTypeEnum.CYCLE_QUARTERLY:
                  StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", "quarterly", null, decision.ParameterTableName);
                  break;

                case Decision.CycleUnitTypeEnum.CYCLE_ANNUALLY:
                  StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", "annually", null, decision.ParameterTableName);
                  break;
                case Decision.CycleUnitTypeEnum.CYCLE_GET_FROM_PARAMETER_TABLE:
                  StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", null, decision.CycleUnitTypeColumnName, decision.ParameterTableName);
                  break;
              }
            }
            else
            {
              // Cycle Unit Type is coming from a parameter table column
              StoreAttributeInDb(decision.UniqueId, "Cycle Unit Type", null, decision.CycleUnitTypeColumnName, decision.ParameterTableName);
            }
            StoreAttributeInDb(decision.UniqueId, "Usage Qualification Group",
                decision.UsageQualificationGroup, null, decision.ParameterTableName);
            StoreAttributeInDb(decision.UniqueId, "Per Unit Rate",
                decision.PerUnitRateValue.HasValue ? decision.PerUnitRateValue.ToString() : null,
                decision.PerUnitRateColumnName, decision.ParameterTableName);
            if (!decision.IsBulkDecision.HasValue)
            {
                StoreAttributeInDb(decision.UniqueId, "Tier Qualified Usage",
                    null, null, decision.ParameterTableName);
            }
            else if (decision.IsBulkDecision.Value)
            {
                StoreAttributeInDb(decision.UniqueId, "Tier Qualified Usage",
                    "bulk", null, decision.ParameterTableName);
            }
            else
            {
                StoreAttributeInDb(decision.UniqueId, "Tier Qualified Usage",
                    "incremental", null, decision.ParameterTableName);
            }
            if (decision.TierProrationValue != null)
            {
                switch (decision.TierProrationValue)
                {
                    case Decision.TierProrationEnum.PRORATE_NONE:
                        StoreAttributeInDb(decision.UniqueId, "Tier Proration", "no proration",
                                           null, decision.ParameterTableName);
                        break;

                    case Decision.TierProrationEnum.PRORATE_TIER_START:
                        StoreAttributeInDb(decision.UniqueId, "Tier Proration", "prorate activation",
                                           null, decision.ParameterTableName);
                        break;

                    case Decision.TierProrationEnum.PRORATE_TIER_END:
                        StoreAttributeInDb(decision.UniqueId, "Tier Proration", "prorate termination",
                                           null, decision.ParameterTableName);
                        break;

                    case Decision.TierProrationEnum.PRORATE_BOTH:
                        StoreAttributeInDb(decision.UniqueId, "Tier Proration", "prorate both",
                                           null, decision.ParameterTableName);
                        break;
                }
            }
            else
            {
                StoreAttributeInDb(decision.UniqueId, "Tier Proration", null,
                                           decision.TierRepetitionColumnName, decision.ParameterTableName);
            }
            if (!decision.IsActive.HasValue)
            {
                StoreAttributeInDb(decision.UniqueId, "Is Active",
                    null, null, decision.ParameterTableName);
            }
            else if (decision.IsActive.Value)
            {
                StoreAttributeInDb(decision.UniqueId, "Is Active",
                    "1", null, decision.ParameterTableName);
            }
            else
            {
                StoreAttributeInDb(decision.UniqueId, "Is Active",
                    "0", null, decision.ParameterTableName);
            }
            if (!decision.IsEditable.HasValue)
            {
                StoreAttributeInDb(decision.UniqueId, "Is Editable",
                    null, null, decision.ParameterTableName);
            }
            else if (decision.IsEditable.Value)
            {
                StoreAttributeInDb(decision.UniqueId, "Is Editable",
                    "1", null, decision.ParameterTableName);
            }
            else
            {
                StoreAttributeInDb(decision.UniqueId, "Is Editable",
                    "0", null, decision.ParameterTableName);
            }
            switch (decision.ExecutionFrequency)
            {
                case Decision.ExecutionFrequencyEnum.DURING_EOP:
                    StoreAttributeInDb(decision.UniqueId, "Execution Frequency", "DURING_EOP", null, decision.ParameterTableName);
                    break;

                case Decision.ExecutionFrequencyEnum.DURING_SCHEDULED_RUNS:
                    StoreAttributeInDb(decision.UniqueId, "Execution Frequency", "DURING_SCHEDULED_RUNS", null, decision.ParameterTableName);
                    break;

                case Decision.ExecutionFrequencyEnum.DURING_BOTH:
                    StoreAttributeInDb(decision.UniqueId, "Execution Frequency", "DURING_BOTH", null, decision.ParameterTableName);
                    break;
            }

            // Store all of the "OtherAttributes" in the DB
            foreach (KeyValuePair<string, DecisionAttributeValue> pair in decision.OtherAttributes)
            {
                StoreAttributeInDb(decision.UniqueId, pair.Key, pair.Value.HardCodedValue,
                    pair.Value.ColumnName, decision.ParameterTableName);
            }
        }

        private void StoreAttributeInDb(
            Guid decisionUniqueId, string attributeName,
            string attributeValue, string attributeColumnName, string parameterTableName)
        {
            m_Logger.LogDebug("Store attribute decisionUniqueId={0}, attributeName={1}, " +
                "attributeValue={2}, attributeColumnName={3}, parameterTableName={4}",
                decisionUniqueId, attributeName, attributeValue, attributeColumnName,
                parameterTableName);

            string dbAttributeValue = null;
            string dbAttributeColumnName = null;
            bool dbAttributeFound = false;
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_ATTRIBUTE__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("decisionUniqueId", MTParameterType.Guid, decisionUniqueId);
                            stmt.AddParam("attributeName", MTParameterType.String, attributeName);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    dbAttributeFound = true;
                                    int attributeColumnNameIndex = rdr.GetOrdinal("c_ColumnName");
                                    int attributeValueIndex = rdr.GetOrdinal("c_DefaultValue");

                                    if (!rdr.IsDBNull(attributeColumnNameIndex))
                                    {
                                        dbAttributeColumnName = rdr.GetString(attributeColumnNameIndex);
                                        m_Logger.LogDebug("dbAttributeColumnName={0}", dbAttributeColumnName);
                                    }

                                    if (!rdr.IsDBNull(attributeValueIndex))
                                    {
                                        dbAttributeValue = rdr.GetString(attributeValueIndex);
                                        m_Logger.LogDebug("dbAttributeValue={0}", dbAttributeValue);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("StoreAttributeInDb failed", e);
                throw new MASBasicException("StoreAttributeInDb failed. " + e.Message);
            }

            // If dbAttributeFound is true, then we should update the value in the DB if it has changed.
            // If dbAttributeFound is false, then we should add this attribute to the DB.
            if (dbAttributeFound)
            {
                if ((attributeValue == dbAttributeValue) &&
                    (attributeColumnName == dbAttributeColumnName))
                {
                    // nothing to do.  The DB matches the current decision object for this attribute
                }
                else
                {
                    // update the value for this attribute in the DB
                    try
                    {
                        using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                        {
                            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                            {
                                queryAdapter.Item = new MTQueryAdapterClass();
                                queryAdapter.Item.Init(AMP_QUERY_DIR);
                                queryAdapter.Item.SetQueryTag("__UPDATE_ATTRIBUTE__");

                                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                {
                                    stmt.AddParam("decisionUniqueId", MTParameterType.Guid, decisionUniqueId);
                                    stmt.AddParam("attributeName", MTParameterType.String, attributeName);
                                    stmt.AddParam("attributeValue", MTParameterType.String, attributeValue);
                                    stmt.AddParam("attributeColumnName", MTParameterType.String, attributeColumnName);

                                    stmt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        m_Logger.LogException("StoreAttributeInDb failed", e);
                        throw new MASBasicException("StoreAttributeInDb failed. " + e.Message);
                    }
                }
            }
            else
            {
                // create a new row for this attribute
                try
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapterClass();
                            queryAdapter.Item.Init(AMP_QUERY_DIR);
                            queryAdapter.Item.SetQueryTag("__CREATE_ATTRIBUTE__");

                            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                stmt.AddParam("decisionUniqueId", MTParameterType.Guid, decisionUniqueId);
                                stmt.AddParam("attributeName", MTParameterType.String, attributeName);
                                stmt.AddParam("attributeValue", MTParameterType.String, attributeValue);
                                stmt.AddParam("attributeColumnName", MTParameterType.String, attributeColumnName);
                                stmt.AddParam("parameterTableName", MTParameterType.String, parameterTableName);

                                stmt.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_Logger.LogException("StoreAttributeInDb failed", e);
                    throw new MASBasicException("StoreAttributeInDb failed. " + e.Message);
                }
            }
        }

        private void RemoveAttributeFromDb(Guid decisionUniqueId, string attributeName)
        {
            m_Logger.LogDebug("Remove attribute decisionUniqueId={0}, attributeName={1}",
                              decisionUniqueId, attributeName);

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__REMOVE_ATTRIBUTE__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("decisionUniqueId", MTParameterType.Guid, decisionUniqueId);
                            stmt.AddParam("attributeName", MTParameterType.String, attributeName);
                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RemoveAttributeFromDb failed", e);
                throw new MASBasicException("RemoveAttributeFromDb failed. " + e.Message);
            }
        }

        private bool RetrieveAndPopulateDecision(string decisionName, ref Decision decision)
        {
            bool decisionFoundInDb = false;
            try
            {
                // Retrieve a specific decision.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_DECISION__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("decisionName", MTParameterType.String, decisionName);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (!rdr.IsDBNull("c_DecisionType_Id"))
                                    {
                                        decision.UniqueId = rdr.GetGuid("c_DecisionType_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulateDecision: null UniqueId");
                                    }

                                    if (!rdr.IsDBNull("c_Name"))
                                    {
                                        decision.Name = rdr.GetString("c_Name");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null name");
                                        throw new MASBasicException("RetrieveAndPopulateDecision: null name");
                                    }

                                    if (!rdr.IsDBNull("c_Description"))
                                    {
                                        decision.Description = rdr.GetString("c_Description");
                                    }
                                    else
                                    {
                                        // OK to have a null description
                                    }

                                    if (!rdr.IsDBNull("c_IsActive"))
                                    {
                                        int isActive = rdr.GetInt32("c_IsActive");
                                        if (isActive == 0)
                                        {
                                            decision.IsActive = false;
                                        }
                                        else
                                        {
                                            decision.IsActive = true;
                                        }
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null IsActive");
                                        throw new MASBasicException("RetrieveAndPopulateDecision: null IsActive");
                                    }

                                    if (!rdr.IsDBNull("c_TableName"))
                                    {
                                        decision.ParameterTableName = rdr.GetString("c_TableName");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null ParameterTableName");
                                        throw new MASBasicException("RetrieveAndPopulateDecision: null ParameterTableName");
                                    }

                                    decisionFoundInDb = true;
                                }
                            }
                        }

                        if (decisionFoundInDb)
                        {
                            RetrieveAndPopulateParameterTableDisplayName(ref decision);
                            RetrieveAndPopulateDecisionAttributes(ref decision);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateDecision failed", e);
                throw new MASBasicException("RetrieveAndPopulateDecision failed. " + e.Message);
            }

            return decisionFoundInDb;
        }
        #endregion

        #region PRIVATE_USAGE_QUALIFICATION_GROUP_METHODS
        private bool RetrieveAndPopulateUsageQualificationGroup(string uqgName, ref UsageQualificationGroup uqg)
        {
            bool uqgFoundInDb = false;
            try
            {
                // Retrieve a specific uqg.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_USAGE_QUALIFICATION_GROUP__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("uqgName", MTParameterType.String, uqgName);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (!rdr.IsDBNull("c_UsageQualGroup_Id"))
                                    {
                                        uqg.UniqueId = rdr.GetGuid("c_UsageQualGroup_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulateUsageQualificationGroup: null UniqueId");
                                    }

                                    if (!rdr.IsDBNull("c_Name"))
                                    {
                                        uqg.Name = rdr.GetString("c_Name");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null Name");
                                        throw new MASBasicException("RetrieveAndPopulateUsageQualificationGroup: null name");
                                    }

                                    if (!rdr.IsDBNull("c_Description"))
                                    {
                                        uqg.Description = rdr.GetString("c_Description");
                                    }
                                    else
                                    {
                                        // OK to have NULL description
                                    }

                                    uqgFoundInDb = true;
                                }
                            }
                        }

                        if (uqgFoundInDb)
                        {
                            uqg.UsageQualificationFilters = new List<UsageQualificationFilter>();
                            RetrieveAndPopulateUqgFilters(ref uqg);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateUsageQualificationGroup failed", e);
                throw new MASBasicException("RetrieveAndPopulateUsageQualificationGroup failed. " + e.Message);
            }

            return uqgFoundInDb;
        }

        private void RetrieveAndPopulateUqgFilters(ref UsageQualificationGroup uqg)
        {
            try
            {
                // Retrieve the filters associate with a specific uqg.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_USAGE_QUALIFICATION_FILTERS__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("uqgUniqueId", MTParameterType.Guid, uqg.UniqueId);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    UsageQualificationFilter filter = new UsageQualificationFilter();

                                    if (!rdr.IsDBNull("c_Filter"))
                                    {
                                        filter.Filter = rdr.GetString("c_Filter");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null Filter");
                                        throw new MASBasicException("RetrieveAndPopulateUqgFilters: null filter");
                                    }

                                    if (!rdr.IsDBNull("c_ExecutionSequence"))
                                    {
                                        filter.Priority = rdr.GetInt32("c_ExecutionSequence");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null Priority");
                                        throw new MASBasicException("RetrieveAndPopulateUqgFilters: null Priority");
                                    }

                                    if (!rdr.IsDBNull("c_UsageQualification_Id"))
                                    {
                                        filter.UniqueId = rdr.GetGuid("c_UsageQualification_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulateUqgFilters: null UniqueId");
                                    }

                                    uqg.UsageQualificationFilters.Add(filter);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateUqgFilters failed", e);
                throw new MASBasicException("RetrieveAndPopulateUqgFilters failed. " + e.Message);
            }
        }

        // <summary>
        // If a filter exists in clientUqg, but not in dbUqg, then the filter needs to be added to the DB.
        // If a filter exists in dbUqg, but not in clientUqg, then the filter needs to be deleted from the DB.
        // If a filter exists in both and they are not identical, then the filter needs to be updated in the DB.
        // If a filter exists in both and they are identical, then no change required
        // </summary>
        // <param name="clientUqg">Usage qualification group received from the client that needs to be stored in the DB</param>
        // <param name="dbUqg">Usage qualification group that is already stored in the DB</param>
        private void StoreUqgFiltersInDb(UsageQualificationGroup clientUqg,
            UsageQualificationGroup dbUqg)
        {
            m_Logger.LogDebug("StoreUqgFiltersInDb");

            foreach (var clientUqgFilter in clientUqg.UsageQualificationFilters)
            {
                // See if the clientUqgFilter exists in the DB
                bool isClientUqgFilterInDb = false;
                foreach (var dbUqgFilter in dbUqg.UsageQualificationFilters)
                {
                    if (clientUqgFilter.UniqueId == dbUqgFilter.UniqueId)
                    {
                        isClientUqgFilterInDb = true;
                        if ((clientUqgFilter.Filter == dbUqgFilter.Filter) &&
                            (clientUqgFilter.Priority == dbUqgFilter.Priority))
                        {
                            // clientUqgFilter is identical to dbUqgFilter,
                            // so nothing to do.
                            m_Logger.LogDebug("filter already in DB, filter={0}, priority={1}",
                                clientUqgFilter.Filter, clientUqgFilter.Priority);
                        }
                        else
                        {
                            m_Logger.LogDebug("filter differs so updating DB, client filter={0}, priority={1}",
                                clientUqgFilter.Filter, clientUqgFilter.Priority);
                            m_Logger.LogDebug("filter differs so updating DB, db filter={0}, priority={1}",
                                dbUqgFilter.Filter, dbUqgFilter.Priority);
                            UpdateUqgFilter(clientUqgFilter);
                        }
                        break;
                    }
                }

                if (!isClientUqgFilterInDb)
                {
                    m_Logger.LogDebug("filter being added to DB, client filter={0}, priority={1}",
                        clientUqgFilter.Filter, clientUqgFilter.Priority);
                    AddUqgFilter(clientUqg.UniqueId, clientUqgFilter);
                }
            }

            foreach (var dbUqgFilter in dbUqg.UsageQualificationFilters)
            {
                // See if the dbUqgFilter exists in the client
                bool isDbUqgFilterInClient = false;
                foreach (var clientUqgFilter in clientUqg.UsageQualificationFilters)
                {
                    if (clientUqgFilter.UniqueId == dbUqgFilter.UniqueId)
                    {
                        isDbUqgFilterInClient = true;
                        break;
                    }
                }

                if (!isDbUqgFilterInClient)
                {
                    m_Logger.LogDebug("filter being deleted from DB, db filter={0}, priority={1}",
                        dbUqgFilter.Filter, dbUqgFilter.Priority);
                    DeleteUqgFilter(dbUqgFilter);
                }
            }
        }

        private void AddUqgFilter(Guid uqgUniqueId, UsageQualificationFilter filter)
        {
            m_Logger.LogDebug("AddUqgFilter");
            // create a new row for this filter
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__CREATE_UQG_FILTER__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("uqgUniqueId", MTParameterType.Guid, uqgUniqueId);
                            stmt.AddParam("uqgFilter", MTParameterType.String, filter.Filter);
                            stmt.AddParam("uqgFilterPriority", MTParameterType.String, filter.Priority);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("AddUqgFilter failed", e);
                throw new MASBasicException("AddUqgFilter failed. " + e.Message);
            }
        }

        private void UpdateUqgFilter(UsageQualificationFilter filter)
        {
            m_Logger.LogDebug("UpdateUqgFilter");
            // update existing row for this filter
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__UPDATE_UQG_FILTER__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("uqgFilterUniqueId", MTParameterType.Guid, filter.UniqueId);
                            stmt.AddParam("uqgFilter", MTParameterType.String, filter.Filter);
                            stmt.AddParam("uqgFilterPriority", MTParameterType.String, filter.Priority);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("UpdateUqgFilter failed", e);
                throw new MASBasicException("UpdateUqgFilter failed. " + e.Message);
            }
        }

        private void DeleteUqgFilter(UsageQualificationFilter filter)
        {
            m_Logger.LogDebug("DeleteUqgFilter");
            // delete existing row for this filter
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__DELETE_UQG_FILTER__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("uqgFilterUniqueId", MTParameterType.Guid, filter.UniqueId);
                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("DeleteUqgFilter failed", e);
                throw new MASBasicException("DeleteUqgFilter failed. " + e.Message);
            }
        }

        /// <summary>
        /// This method is involved in the sorting and filtering of a list of UsageQualificationGroups returned to
        /// clients.  The clients should only be aware of the UsageQualificationGroup domain model member names.
        /// This method converts the domain model member names into the appropriate database column names.
        /// </summary>
        /// <param name="uqgDomainModelMemberName">Name of a UsageQualificationGroup domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds UsageQualificationGroups</returns>
        private string UqgDomainModelMemberNameToColumnName(string uqgDomainModelMemberName,
            ref object filterVal, object helper)
        {
            string columnName = uqgDomainModelMemberName;

            switch (uqgDomainModelMemberName)
            {
                case "Name":
                    columnName = "c_Name";
                    break;

                case "Description":
                    columnName = "c_Description";
                    break;

                case "UniqueId":
                    columnName = "c_UsageQualGroup_Id";
                    break;
            }

            return columnName;
        }
        #endregion

        #region PRIVATE_GENERATED_CHARGE_METHODS
        // <summary>
        // If a directive exists in clientGeneratedCharge, but not in dbGeneratedCharge, 
        //      then the directive needs to be added to the DB.
        // If a directive exists in dbGeneratedCharge, but not in clientGeneratedCharge, 
        //      then the directive needs to be deleted from the DB.
        // If a directive exists in both and they are not identical, 
        //      then the directive needs to be updated in the DB.
        // If a directive exists in both and they are identical, 
        //      then no change required
        // </summary>
        // <param name="clientGeneratedCharge">GeneratedCharge received from the client 
        //      that needs to be stored in the DB</param>
        // <param name="dbGeneratedCharge">GeneratedCharge that is already 
        //      stored in the DB</param>
        private void StoreGeneratedChargeDirectivesInDb(GeneratedCharge clientGeneratedCharge,
            GeneratedCharge dbGeneratedCharge)
        {
            m_Logger.LogDebug("StoreGeneratedChargeDirectivesInDb");

            foreach (var clientGeneratedChargeDirective in clientGeneratedCharge.GeneratedChargeDirectives)
            {
                // See if the clientGeneratedChargeDirective exists in the DB
                bool isClientGeneratedChargeDirectiveInDb = false;
                foreach (var dbGeneratedChargeDirective in dbGeneratedCharge.GeneratedChargeDirectives)
                {
                    if (clientGeneratedChargeDirective.UniqueId == dbGeneratedChargeDirective.UniqueId)
                    {
                        isClientGeneratedChargeDirectiveInDb = true;
                        if ((clientGeneratedChargeDirective.Priority == dbGeneratedChargeDirective.Priority) &&
                            (clientGeneratedChargeDirective.IncludeTableName == dbGeneratedChargeDirective.IncludeTableName) &&
                            (clientGeneratedChargeDirective.SourceValue == dbGeneratedChargeDirective.SourceValue) &&
                            (clientGeneratedChargeDirective.TargetField == dbGeneratedChargeDirective.TargetField) &&
                            (clientGeneratedChargeDirective.IncludePredicate == dbGeneratedChargeDirective.IncludePredicate) &&
                            (clientGeneratedChargeDirective.IncludedFieldPrefix == dbGeneratedChargeDirective.IncludedFieldPrefix) &&
                            (clientGeneratedChargeDirective.FieldName == dbGeneratedChargeDirective.FieldName) &&
                            (clientGeneratedChargeDirective.PopulationString == dbGeneratedChargeDirective.PopulationString) &&
                            (clientGeneratedChargeDirective.MvmProcedure == dbGeneratedChargeDirective.MvmProcedure) &&
                            (clientGeneratedChargeDirective.Filter == dbGeneratedChargeDirective.Filter) &&
                            (clientGeneratedChargeDirective.DefaultValue == dbGeneratedChargeDirective.DefaultValue))
                        {
                            // clientGeneratedChargeDirective is identical to dbGeneratedChargeDirective,
                            // so nothing to do.
                            m_Logger.LogDebug("directive already in DB, no action necessary");
                        }
                        else
                        {
                            m_Logger.LogDebug("directive {0} differs so updating DB",
                                clientGeneratedChargeDirective.UniqueId);
                            UpdateGeneratedChargeDirective(clientGeneratedChargeDirective);
                        }
                        break;
                    }
                }

                if (!isClientGeneratedChargeDirectiveInDb)
                {
                    m_Logger.LogDebug("directive being added to DB");
                    AddGeneratedChargeDirective(clientGeneratedCharge.UniqueId, clientGeneratedChargeDirective);
                }
            }

            foreach (var dbGeneratedChargeDirective in dbGeneratedCharge.GeneratedChargeDirectives)
            {
                // See if the dbGeneratedChargeDirective exists in the client
                bool isDbGeneratedChargeDirectiveInClient = false;
                foreach (var clientGeneratedChargeDirective in clientGeneratedCharge.GeneratedChargeDirectives)
                {
                    if (clientGeneratedChargeDirective.UniqueId == dbGeneratedChargeDirective.UniqueId)
                    {
                        isDbGeneratedChargeDirectiveInClient = true;
                        break;
                    }
                }

                if (!isDbGeneratedChargeDirectiveInClient)
                {
                    m_Logger.LogDebug("directive {0} is being deleted from DB",
                        dbGeneratedChargeDirective.UniqueId);
                    DeleteGeneratedChargeDirective(dbGeneratedChargeDirective);
                }
            }
        }

        private void AddGeneratedChargeDirective(Guid generatedChargeUniqueId, GeneratedChargeDirective directive)
        {
            m_Logger.LogDebug("AddGeneratedChargeDirective");
            // create a new row for this directive
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__CREATE_GENERATED_CHARGE_DIRECTIVE__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("generatedChargeUniqueId", MTParameterType.Guid, generatedChargeUniqueId);

                            stmt.AddParam("priority", MTParameterType.String, directive.Priority);
                            stmt.AddParam("includeTableName", MTParameterType.String, directive.IncludeTableName);
                            stmt.AddParam("sourceValue", MTParameterType.String, directive.SourceValue);
                            stmt.AddParam("targetField", MTParameterType.String, directive.TargetField);
                            stmt.AddParam("includePredicate", MTParameterType.String, directive.IncludePredicate);
                            stmt.AddParam("includedFieldPrefix", MTParameterType.String, directive.IncludedFieldPrefix);
                            stmt.AddParam("fieldName", MTParameterType.String, directive.FieldName);
                            stmt.AddParam("populationString", MTParameterType.String, directive.PopulationString);
                            stmt.AddParam("mvmProcedure", MTParameterType.String, directive.MvmProcedure);
                            stmt.AddParam("filter", MTParameterType.String, directive.Filter);
                            stmt.AddParam("defaultValue", MTParameterType.String, directive.DefaultValue);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("AddGeneratedChargeDirective failed", e);
                throw new MASBasicException("AddGeneratedChargeDirective failed. " + e.Message);
            }
        }

        private void UpdateGeneratedChargeDirective(GeneratedChargeDirective directive)
        {
            m_Logger.LogDebug("UpdateGeneratedChargeDirective");
            // update existing row for this directive
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__UPDATE_GENERATED_CHARGE_DIRECTIVE__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("directiveUniqueId", MTParameterType.Guid, directive.UniqueId);
                            stmt.AddParam("priority", MTParameterType.String, directive.Priority);
                            stmt.AddParam("includeTableName", MTParameterType.String, directive.IncludeTableName);
                            stmt.AddParam("sourceValue", MTParameterType.String, directive.SourceValue);
                            stmt.AddParam("targetField", MTParameterType.String, directive.TargetField);
                            stmt.AddParam("includePredicate", MTParameterType.String, directive.IncludePredicate);
                            stmt.AddParam("includedFieldPrefix", MTParameterType.String, directive.IncludedFieldPrefix);
                            stmt.AddParam("fieldName", MTParameterType.String, directive.FieldName);
                            stmt.AddParam("populationString", MTParameterType.String, directive.PopulationString);
                            stmt.AddParam("mvmProcedure", MTParameterType.String, directive.MvmProcedure);
                            stmt.AddParam("filter", MTParameterType.String, directive.Filter);
                            stmt.AddParam("defaultValue", MTParameterType.String, directive.DefaultValue);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("UpdateGeneratedChargeDirective failed", e);
                throw new MASBasicException("UpdateGeneratedChargeDirective failed. " + e.Message);
            }
        }

        private void DeleteGeneratedChargeDirective(GeneratedChargeDirective directive)
        {
            m_Logger.LogDebug("DeleteGeneratedChargeDirective");
            // delete existing row for this directive
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__DELETE_GENERATED_CHARGE_DIRECTIVE__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("directiveId", MTParameterType.Guid, directive.UniqueId);
                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("DeleteGeneratedChargeDirective failed", e);
                throw new MASBasicException("DeleteGeneratedChargeDirective failed. " + e.Message);
            }
        }

        private bool RetrieveAndPopulateGeneratedCharge(string generatedChargeName, ref GeneratedCharge generatedCharge)
        {
            bool generatedChargeFoundInDb = false;
            try
            {
                // Retrieve a specific generatedCharge.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_GENERATED_CHARGE__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("generatedChargeName", MTParameterType.String, generatedChargeName);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    int uniqueIdIndex = rdr.GetOrdinal("c_GenCharge_Id");
                                    int nameIndex = rdr.GetOrdinal("c_Name");
                                    int descriptionIndex = rdr.GetOrdinal("c_Description");
                                    int amountChainNameIndex = rdr.GetOrdinal("c_AmountChain");
                                    int productViewNameIndex = rdr.GetOrdinal("c_ProductViewName");

                                    if (!rdr.IsDBNull(uniqueIdIndex))
                                    {
                                        generatedCharge.UniqueId = rdr.GetGuid("c_GenCharge_Id");
                                    }

                                    if (!rdr.IsDBNull(nameIndex))
                                    {
                                        generatedCharge.Name = rdr.GetString("c_Name");
                                    }

                                    if (!rdr.IsDBNull(descriptionIndex))
                                    {
                                        generatedCharge.Description = rdr.GetString("c_Description");
                                    }

                                    if (!rdr.IsDBNull(amountChainNameIndex))
                                    {
                                        generatedCharge.AmountChainName = rdr.GetString("c_AmountChain");
                                    }

                                    if (!rdr.IsDBNull(productViewNameIndex))
                                    {
                                        generatedCharge.ProductViewName = rdr.GetString("c_ProductViewName");
                                    }

                                    generatedChargeFoundInDb = true;
                                }
                            }
                        }

                        if (generatedChargeFoundInDb)
                        {
                            generatedCharge.GeneratedChargeDirectives = new List<GeneratedChargeDirective>();
                            RetrieveAndPopulateGeneratedChargeDirectives(ref generatedCharge);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateGeneratedCharge failed", e);
                throw new MASBasicException("RetrieveAndPopulateGeneratedCharge failed. " + e.Message);
            }

            return generatedChargeFoundInDb;
        }

        private void RetrieveAndPopulateGeneratedChargeDirectives(ref GeneratedCharge generatedCharge)
        {
            try
            {
                // Retrieve the filters associate with a specific generatedCharge.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_GENERATED_CHARGE_DIRECTIVES__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("generatedChargeUniqueId", MTParameterType.Guid, generatedCharge.UniqueId);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    GeneratedChargeDirective directive = new GeneratedChargeDirective();

                                    int uniqueIdIndex = rdr.GetOrdinal("c_Directive_Id");
                                    int priorityIndex = rdr.GetOrdinal("c_row_num");
                                    int includeTableNameIndex = rdr.GetOrdinal("c_include_table_name");
                                    int sourceValueIndex = rdr.GetOrdinal("c_source_value");
                                    int targetFieldIndex = rdr.GetOrdinal("c_target_field");
                                    int includePredicateIndex = rdr.GetOrdinal("c_include_predicate");
                                    int includedFieldPrefixIndex = rdr.GetOrdinal("c_included_field_prefix");
                                    int fieldNameIndex = rdr.GetOrdinal("c_field_name");
                                    int populationStringIndex = rdr.GetOrdinal("c_population_string");
                                    int mvmProcedureIndex = rdr.GetOrdinal("c_mvm_procedure");
                                    int filterIndex = rdr.GetOrdinal("c_filter");
                                    int defaultValueIndex = rdr.GetOrdinal("c_default_value");

                                    if (!rdr.IsDBNull(uniqueIdIndex))
                                    {
                                        directive.UniqueId = rdr.GetGuid("c_Directive_Id");
                                    }

                                    if (!rdr.IsDBNull(priorityIndex))
                                    {
                                        directive.Priority = rdr.GetInt32("c_row_num");
                                    }

                                    if (!rdr.IsDBNull(includeTableNameIndex))
                                    {
                                        directive.IncludeTableName = rdr.GetString("c_include_table_name");
                                    }

                                    if (!rdr.IsDBNull(sourceValueIndex))
                                    {
                                        directive.SourceValue = rdr.GetString("c_source_value");
                                    }

                                    if (!rdr.IsDBNull(targetFieldIndex))
                                    {
                                        directive.TargetField = rdr.GetString("c_target_field");
                                    }

                                    if (!rdr.IsDBNull(includePredicateIndex))
                                    {
                                        directive.IncludePredicate = rdr.GetString("c_include_predicate");
                                    }

                                    if (!rdr.IsDBNull(includedFieldPrefixIndex))
                                    {
                                        directive.IncludedFieldPrefix = rdr.GetString("c_included_field_prefix");
                                    }

                                    if (!rdr.IsDBNull(fieldNameIndex))
                                    {
                                        directive.FieldName = rdr.GetString("c_field_name");
                                    }

                                    if (!rdr.IsDBNull(populationStringIndex))
                                    {
                                        directive.PopulationString = rdr.GetString("c_population_string");
                                    }

                                    if (!rdr.IsDBNull(mvmProcedureIndex))
                                    {
                                        directive.MvmProcedure = rdr.GetString("c_mvm_procedure");
                                    }

                                    if (!rdr.IsDBNull(filterIndex))
                                    {
                                        directive.Filter = rdr.GetString("c_filter");
                                    }

                                    if (!rdr.IsDBNull(defaultValueIndex))
                                    {
                                        directive.DefaultValue = rdr.GetString("c_default_value");
                                    }

                                    generatedCharge.GeneratedChargeDirectives.Add(directive);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateGeneratedChargeDirectives failed", e);
                throw new MASBasicException("RetrieveAndPopulateGeneratedChargeDirectives failed. " + e.Message);
            }
        }
        /// <summary>
        /// This method is involved in the sorting and filtering of a list of GeneratedCharges returned to
        /// clients.  The clients should only be aware of the GeneratedCharge domain model member names.
        /// This method converts the domain model member names into the appropriate database column names.
        /// </summary>
        /// <param name="gcDomainModelMemberName">Name of a GeneratedCharge domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds GeneratedCharges</returns>
        private string GcDomainModelMemberNameToColumnName(string gcDomainModelMemberName,
            ref object filterVal, object helper)
        {
            string columnName = gcDomainModelMemberName;

            switch (gcDomainModelMemberName)
            {
                case "Name":
                    columnName = "c_Name";
                    break;

                case "Description":
                    columnName = "c_Description";
                    break;

                case "UniqueId":
                    columnName = "c_GenCharge_Id";
                    break;
            }

            return columnName;
        }

        #endregion

        #region PRIVATE_ACCOUNT_QUALIFICATION_METHODS
        private bool RetrieveAndPopulateAccountQualificationGroup(string aqgName, ref AccountQualificationGroup aqg)
        {
            bool aqgFoundInDb = false;
            try
            {
                // Retrieve a specific aqg.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_ACCOUNT_QUALIFICATION_GROUP__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("aqgName", MTParameterType.String, aqgName);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (!rdr.IsDBNull("c_AccountQualGroup_Id"))
                                    {
                                        aqg.UniqueId = rdr.GetGuid("c_AccountQualGroup_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulateAccountQualificationGroup: null UniqueId");
                                    }

                                    if (!rdr.IsDBNull("c_Name"))
                                    {
                                        aqg.Name = rdr.GetString("c_Name");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null Name");
                                        throw new MASBasicException("RetrieveAndPopulateAccountQualificationGroup: null name");
                                    }

                                    if (!rdr.IsDBNull("c_Description"))
                                    {
                                        aqg.Description = rdr.GetString("c_Description");
                                    }
                                    else
                                    {
                                        // OK to have NULL description
                                    }

                                    aqgFoundInDb = true;
                                }
                            }
                        }

                        if (aqgFoundInDb)
                        {
                            aqg.AccountQualifications = new List<AccountQualification>();
                            RetrieveAndPopulateAccountQualifications(ref aqg);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateAccountQualificationGroup failed", e);
                throw new MASBasicException("RetrieveAndPopulateAccountQualificationGroup failed. " + e.Message);
            }

            return aqgFoundInDb;
        }

        private void RetrieveAndPopulateAccountQualifications(ref AccountQualificationGroup aqg)
        {
            try
            {
                // Retrieve the filters/includes associated with a specific aqg.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_ACCOUNT_QUALIFICATIONS__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("aqgUniqueId", MTParameterType.Guid, aqg.UniqueId);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    AccountQualification qualification = new AccountQualification();

                                    if (!rdr.IsDBNull("c_Include"))
                                    {
                                        qualification.TableToInclude = rdr.GetString("c_Include");
                                    }

                                    if (!rdr.IsDBNull("c_Filter"))
                                    {
                                        qualification.MvmFilter = rdr.GetString("c_Filter");
                                    }

                                    if (!rdr.IsDBNull("c_Mode"))
                                    {
                                        qualification.Mode = rdr.GetInt32("c_Mode");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("RetrieveAndPopulateAccountQualifications: null value for c_Mode, ignoring");
                                    }

                                    if (!rdr.IsDBNull("c_ExecutionSequence"))
                                    {
                                        qualification.Priority = rdr.GetInt32("c_ExecutionSequence");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("RetrieveAndPopulateAccountQualifications, null Priority");
                                        throw new MASBasicException("RetrieveAndPopulateAccountQualifications failed because of null Priority");
                                    }

                                    if (!rdr.IsDBNull("c_AccountQualification_Id"))
                                    {
                                        qualification.UniqueId = rdr.GetGuid("c_AccountQualification_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("RetrieveAndPopulateAccountQualifications, null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulateAccountQualifications failed because of null UniqueId");
                                    }

                                    if (!rdr.IsDBNull("c_IncludeFilter"))
                                    {
                                        qualification.DbFilter = rdr.GetString("c_IncludeFilter");
                                    }

                                    if (!rdr.IsDBNull("c_MatchField"))
                                    {
                                        qualification.MatchField = rdr.GetString("c_MatchField");
                                    }

                                    if (!rdr.IsDBNull("c_SourceField"))
                                    {
                                        qualification.SourceField = rdr.GetString("c_SourceField");
                                    }

                                    if (!rdr.IsDBNull("c_OutputField"))
                                    {
                                        qualification.OutputField = rdr.GetString("c_OutputField");
                                    }

                                    aqg.AccountQualifications.Add(qualification);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception in RetrieveAndPopulateAccountQualifications", e);
                throw new MASBasicException("Exception in RetrieveAndPopulateAccountQualifications");
            }
        }

        // <summary>
        // If a qualification exists in clientAqg, but not in dbAqg, then the qualification needs to be added to the DB.
        // If a qualification exists in dbAqg, but not in clientAqg, then the qualification needs to be deleted from the DB.
        // If a qualification exists in both and they are not identical, then the qualification needs to be updated in the DB.
        // If a qualification exists in both and they are identical, then no change required
        // </summary>
        // <param name="clientAqg">Account qualification group received from the client that needs to be stored in the DB</param>
        // <param name="dbAqg">Account qualification group that is already stored in the DB</param>
        private void StoreAccountQualificationsInDb(AccountQualificationGroup clientAqg,
            AccountQualificationGroup dbAqg)
        {
            m_Logger.LogDebug("StoreAccountQualificationsInDb");

            foreach (var clientAccountQualification in clientAqg.AccountQualifications)
            {
                // See if the clientAccountQualification exists in the DB
                bool isClientAccountQualificationInDb = false;
                foreach (var dbAccountQualification in dbAqg.AccountQualifications)
                {
                    if (clientAccountQualification.UniqueId == dbAccountQualification.UniqueId)
                    {
                        isClientAccountQualificationInDb = true;
                        if ((clientAccountQualification.TableToInclude == dbAccountQualification.TableToInclude) &&
                            (clientAccountQualification.Priority == dbAccountQualification.Priority) &&
                            (clientAccountQualification.MvmFilter == dbAccountQualification.MvmFilter) &&
                            (clientAccountQualification.Mode == dbAccountQualification.Mode) &&
                            (clientAccountQualification.DbFilter == dbAccountQualification.DbFilter) &&
                            (clientAccountQualification.MatchField == dbAccountQualification.MatchField) &&
                            (clientAccountQualification.OutputField == dbAccountQualification.OutputField) &&
                            (clientAccountQualification.SourceField == dbAccountQualification.SourceField))
                        {
                            // clientAccountQualification is identical to dbAccountQualification,
                            // so nothing to do.
                            m_Logger.LogDebug("qualification already in DB");
                        }
                        else
                        {
                            m_Logger.LogDebug("qualification differs so updating DB");
                            UpdateAccountQualification(clientAccountQualification);
                        }
                        break;
                    }
                }

                if (!isClientAccountQualificationInDb)
                {
                    m_Logger.LogDebug("qualification being added to DB");
                    AddAccountQualification(clientAqg.UniqueId, clientAccountQualification);
                }
            }

            foreach (var dbAccountQualification in dbAqg.AccountQualifications)
            {
                // See if the dbAccountQualification exists in the client
                bool isDbAccountQualificationInClient = false;
                foreach (var clientAccountQualification in clientAqg.AccountQualifications)
                {
                    if (clientAccountQualification.UniqueId == dbAccountQualification.UniqueId)
                    {
                        isDbAccountQualificationInClient = true;
                        break;
                    }
                }

                if (!isDbAccountQualificationInClient)
                {
                    m_Logger.LogDebug("qualification being deleted from DB");
                    DeleteAccountQualification(dbAccountQualification);
                }
            }
        }

        private void AddAccountQualification(Guid aqgUniqueId, AccountQualification qualification)
        {
            m_Logger.LogDebug("AddAccountQualification");
            // create a new row for this qualification
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__CREATE_ACCOUNT_QUALIFICATION__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("aqgUniqueId", MTParameterType.Guid, aqgUniqueId);
                            stmt.AddParam("tableToInclude", MTParameterType.String, qualification.TableToInclude);
                            stmt.AddParam("mvmFilter", MTParameterType.String, qualification.MvmFilter);
                            stmt.AddParam("aqMode", MTParameterType.String, qualification.Mode);
                            stmt.AddParam("priority", MTParameterType.String, qualification.Priority);
                            stmt.AddParam("dbFilter", MTParameterType.String, qualification.DbFilter);
                            stmt.AddParam("matchField", MTParameterType.String, qualification.MatchField);
                            stmt.AddParam("outputField", MTParameterType.String, qualification.OutputField);
                            stmt.AddParam("sourceField", MTParameterType.String, qualification.SourceField);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception in AddAccountQualification", e);
                throw new MASBasicException("Exception in AddAccountQualification");
            }
        }

        private void UpdateAccountQualification(AccountQualification qualification)
        {
            m_Logger.LogDebug("UpdateAccountQualification");
            // update existing row for this qualification
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__UPDATE_ACCOUNT_QUALIFICATION__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("qualificationUniqueId", MTParameterType.Guid, qualification.UniqueId);
                            stmt.AddParam("tableToInclude", MTParameterType.String, qualification.TableToInclude);
                            stmt.AddParam("mvmFilter", MTParameterType.String, qualification.MvmFilter);
                            stmt.AddParam("aqMode", MTParameterType.String, qualification.Mode);
                            stmt.AddParam("priority", MTParameterType.String, qualification.Priority);
                            stmt.AddParam("dbFilter", MTParameterType.String, qualification.DbFilter);
                            stmt.AddParam("matchField", MTParameterType.String, qualification.MatchField);
                            stmt.AddParam("outputField", MTParameterType.String, qualification.OutputField);
                            stmt.AddParam("sourceField", MTParameterType.String, qualification.SourceField);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception in UpdateAccountQualification", e);
                throw new MASBasicException("Exception in UpdateAccountQualification");
            }
        }

        private void DeleteAccountQualification(AccountQualification qualification)
        {
            m_Logger.LogDebug("DeleteAccountQualification");
            // delete existing row for this qualification
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__DELETE_ACCOUNT_QUALIFICATION__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("qualificationUniqueId", MTParameterType.Guid, qualification.UniqueId);
                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception in DeleteAccountQualification", e);
                throw new MASBasicException("Exception in DeleteAccountQualification");
            }
        }
        /// <summary>
        /// This method is involved in the sorting and filtering of a list of AccountQualificationGroups returned to
        /// clients.  The clients should only be aware of the AccountQualificationGroup domain model member names.
        /// This method converts the domain model member names into the appropriate database column names.
        /// </summary>
        /// <param name="aqgDomainModelMemberName">Name of a AccountQualificationGroup domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds AccountQualificationGroups</returns>
        private string AqgDomainModelMemberNameToColumnName(string aqgDomainModelMemberName,
            ref object filterVal, object helper)
        {
            string columnName = aqgDomainModelMemberName;

            switch (aqgDomainModelMemberName)
            {
                case "Name":
                    columnName = "c_Name";
                    break;

                case "Description":
                    columnName = "c_Description";
                    break;

                case "UniqueId":
                    columnName = "c_AccountQualGroup_Id";
                    break;
            }

            return columnName;
        }
        #endregion

        #region PRIVATE_AMOUNT_CHAIN_METHODS
        private bool RetrieveAndPopulateAmountChain(string amountChainName, ref AmountChain amountChain)
        {
            bool amountChainFoundInDb = false;
            try
            {
                // Retrieve a specific amountChain.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_AMOUNT_CHAIN__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("amountChainName", MTParameterType.String, amountChainName);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    int uniqueIdIndex = rdr.GetOrdinal("c_AmountChain_Id");
                                    int nameIndex = rdr.GetOrdinal("c_Name");
                                    int descriptionIndex = rdr.GetOrdinal("c_Description");
                                    int productViewNameIndex = rdr.GetOrdinal("c_ProductViewName");

                                    if (!rdr.IsDBNull(uniqueIdIndex))
                                    {
                                        amountChain.UniqueId = rdr.GetGuid("c_AmountChain_Id");
                                    }

                                    if (!rdr.IsDBNull(nameIndex))
                                    {
                                        amountChain.Name = rdr.GetString("c_Name");
                                    }

                                    if (!rdr.IsDBNull(descriptionIndex))
                                    {
                                        amountChain.Description = rdr.GetString("c_Description");
                                    }

                                    if (!rdr.IsDBNull(productViewNameIndex))
                                    {
                                        amountChain.ProductViewName = rdr.GetString("c_ProductViewName");
                                    }

                                    amountChainFoundInDb = true;
                                }
                            }
                        }

                        if (amountChainFoundInDb)
                        {
                            amountChain.AmountChainFields = new List<AmountChainField>();
                            RetrieveAndPopulateAmountChainFields(ref amountChain);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulateAmountChain failed", e);
                throw new MASBasicException("RetrieveAndPopulateAmountChain failed. " + e.Message);
            }

            return amountChainFoundInDb;
        }

        // <summary>
        // If a field exists in clientAmountChain, but not in dbAmountChain, 
        //      then the field needs to be added to the DB.
        // If a field exists in dbAmountChain, but not in clientAmountChain, 
        //      then the field needs to be deleted from the DB.
        // If a field exists in both and they are not identical, 
        //      then the field needs to be updated in the DB.
        // If a field exists in both and they are identical, 
        //      then no change required
        // </summary>
        // <param name="clientAmountChain">AmountChain received from the client 
        //      that needs to be stored in the DB</param>
        // <param name="dbAmountChain">AmountChain that is already 
        //      stored in the DB</param>
        private void StoreAmountChainFieldsInDb(AmountChain clientAmountChain,
            AmountChain dbAmountChain)
        {
            m_Logger.LogDebug("StoreAmountChainFieldsInDb");
            m_Logger.LogDebug("clientAmountChain.AmountChainFields.Count={0}",
                clientAmountChain.AmountChainFields.Count);
            m_Logger.LogDebug("dbAmountChain.AmountChainFields.Count={0}",
                dbAmountChain.AmountChainFields.Count);

            foreach (var clientAmountChainField in clientAmountChain.AmountChainFields)
            {
                // See if the clientAmountChainField exists in the DB
                bool isClientAmountChainFieldInDb = false;
                foreach (var dbAmountChainField in dbAmountChain.AmountChainFields)
                {
                    if (clientAmountChainField.UniqueId == dbAmountChainField.UniqueId)
                    {
                        isClientAmountChainFieldInDb = true;
                        if ((clientAmountChainField.FieldName == dbAmountChainField.FieldName) &&
                            (clientAmountChainField.ProductViewName == dbAmountChainField.ProductViewName) &&
                            (clientAmountChainField.FieldRelationship == dbAmountChainField.FieldRelationship) &&
                            (clientAmountChainField.ContributingField == dbAmountChainField.ContributingField) &&
                            (clientAmountChainField.PercentageValue == dbAmountChainField.PercentageValue) &&
                            (clientAmountChainField.PercentageColumnName == dbAmountChainField.PercentageColumnName) &&
                            (clientAmountChainField.CurrencyValue == dbAmountChainField.CurrencyValue) &&
                            (clientAmountChainField.CurrencyColumnName == dbAmountChainField.CurrencyColumnName) &&
                            (clientAmountChainField.Modifier == dbAmountChainField.Modifier) &&
                            (clientAmountChainField.Filter == dbAmountChainField.Filter) &&
                            (clientAmountChainField.Rounding == dbAmountChainField.Rounding) &&
                            (clientAmountChainField.RoundingNumDigits == dbAmountChainField.RoundingNumDigits) &&
                            (clientAmountChainField.Priority == dbAmountChainField.Priority))
                        {
                            // clientAmountChainField is identical to dbAmountChainField,
                            // so nothing to do.
                            m_Logger.LogDebug("Field already in DB, no action necessary");
                        }
                        else
                        {
                            m_Logger.LogDebug("Field {0} differs so updating DB",
                                clientAmountChainField.UniqueId);
                            UpdateAmountChainField(clientAmountChainField);
                        }
                        break;
                    }
                }

                if (!isClientAmountChainFieldInDb)
                {
                    m_Logger.LogDebug("Field being added to DB");
                    AddAmountChainField(clientAmountChain.Name, clientAmountChainField);
                }
            }

            foreach (var dbAmountChainField in dbAmountChain.AmountChainFields)
            {
                // See if the dbAmountChainField exists in the client
                bool isDbAmountChainFieldInClient = false;
                foreach (var clientAmountChainField in clientAmountChain.AmountChainFields)
                {
                    if (clientAmountChainField.UniqueId == dbAmountChainField.UniqueId)
                    {
                        isDbAmountChainFieldInClient = true;
                        break;
                    }
                }

                if (!isDbAmountChainFieldInClient)
                {
                    m_Logger.LogDebug("Field {0} is being deleted from DB",
                        dbAmountChainField.UniqueId);
                    DeleteAmountChainField(dbAmountChainField);
                }
            }
        }

        private void AddAmountChainField(string amountChainName, AmountChainField field)
        {
            m_Logger.LogDebug("AddAmountChainField");
            // create a new row for this field
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__CREATE_AMOUNT_CHAIN_FIELD__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("AmountChainName", MTParameterType.String, amountChainName);

                            stmt.AddParam("FieldName", MTParameterType.String, field.FieldName);
                            stmt.AddParam("ProductViewName", MTParameterType.String, field.ProductViewName);
                            switch (field.FieldDirection)
                            {
                                case AmountChainField.FieldDirectionEnum.NORMALIZE:
                                    stmt.AddParam("FieldDirection", MTParameterType.String, "normalize");
                                    break;
                                case AmountChainField.FieldDirectionEnum.DENORMALIZE:
                                    stmt.AddParam("FieldDirection", MTParameterType.String, "denormalize");
                                    break;
                                case AmountChainField.FieldDirectionEnum.BOTH:
                                    stmt.AddParam("FieldDirection", MTParameterType.String, "both");
                                    break;
                            }
                            switch (field.FieldRelationship)
                            {
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_AMOUNT:
                                    stmt.AddParam("FieldType", MTParameterType.String, "amount");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_UNITS_OF_USAGE:
                                    stmt.AddParam("FieldType", MTParameterType.String, "units");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_PERCENTAGE:
                                    stmt.AddParam("FieldType", MTParameterType.String, "percentage");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_PROPORTIONAL:
                                    stmt.AddParam("FieldType", MTParameterType.String, "proportional");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_CURRENCY_CONVERSION:
                                    stmt.AddParam("FieldType", MTParameterType.String, "currency_conversion");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_DELTA:
                                    stmt.AddParam("FieldType", MTParameterType.String, "delta");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_MODIFIER:
                                    stmt.AddParam("FieldType", MTParameterType.String, "modifier");
                                    break;
                            }
                            stmt.AddParam("ContributingField", MTParameterType.String, field.ContributingField);
                            if ((field.PercentageValue == null) && (field.PercentageColumnName == null))
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String, null);
                            }
                            else if ((field.PercentageValue != null) && (field.PercentageColumnName != null))
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String,
                                    "'" + field.PercentageValue.ToString() + "'");
                            }
                            else if (field.PercentageValue != null)
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String,
                                    "'" + field.PercentageValue.ToString() + "'");
                            }
                            else
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String, field.PercentageColumnName);
                            }

                            if ((field.CurrencyValue == null) && (field.CurrencyColumnName == null))
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String, null);
                            }
                            else if ((field.CurrencyValue != null) && (field.CurrencyColumnName != null))
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String,
                                    "'" + field.CurrencyValue.ToString() + "'");
                            }
                            else if (field.CurrencyValue != null)
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String,
                                    "'" + field.CurrencyValue.ToString() + "'");
                            }
                            else
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String, field.CurrencyColumnName);
                            }
                            stmt.AddParam("Modifier", MTParameterType.String, field.Modifier);
                            stmt.AddParam("Filter", MTParameterType.String, field.Filter);
                            if (field.Rounding == AmountChain.RoundingOptionsEnum.NO_ROUNDING)
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, "noRounding");
                            }
                            else if (field.Rounding == AmountChain.RoundingOptionsEnum.ROUND_TO_CURRENCY)
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, "roundToCurrency");
                            }
                            else if (field.Rounding == AmountChain.RoundingOptionsEnum.ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS)
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, "roundToDigits");
                            }
                            else
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, null);
                            }
                            stmt.AddParam("RoundingNumDigits", MTParameterType.String, field.RoundingNumDigits);
                            stmt.AddParam("Priority", MTParameterType.Integer,
                                (field.Priority.HasValue) ? field.Priority.Value : 0);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("AddAmountChainField failed", e);
                throw new MASBasicException("AddAmountChainField failed. " + e.Message);
            }
        }

        private void UpdateAmountChainField(AmountChainField field)
        {
            m_Logger.LogDebug("UpdateAmountChainField");
            // update existing row for this field
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__UPDATE_AMOUNT_CHAIN_FIELD__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("fieldUniqueId", MTParameterType.Guid, field.UniqueId);
                            stmt.AddParam("FieldName", MTParameterType.String, field.FieldName);
                            stmt.AddParam("ProductViewName", MTParameterType.String, field.ProductViewName);
                            switch (field.FieldDirection)
                            {
                                case AmountChainField.FieldDirectionEnum.NORMALIZE:
                                    stmt.AddParam("FieldDirection", MTParameterType.String, "normalize");
                                    break;
                                case AmountChainField.FieldDirectionEnum.DENORMALIZE:
                                    stmt.AddParam("FieldDirection", MTParameterType.String, "denormalize");
                                    break;
                                case AmountChainField.FieldDirectionEnum.BOTH:
                                    stmt.AddParam("FieldDirection", MTParameterType.String, "both");
                                    break;
                            }
                            switch (field.FieldRelationship)
                            {
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_AMOUNT:
                                    stmt.AddParam("FieldType", MTParameterType.String, "amount");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_UNITS_OF_USAGE:
                                    stmt.AddParam("FieldType", MTParameterType.String, "units");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_PERCENTAGE:
                                    stmt.AddParam("FieldType", MTParameterType.String, "percentage");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_PROPORTIONAL:
                                    stmt.AddParam("FieldType", MTParameterType.String, "proportional");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_CURRENCY_CONVERSION:
                                    stmt.AddParam("FieldType", MTParameterType.String, "currency_conversion");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_DELTA:
                                    stmt.AddParam("FieldType", MTParameterType.String, "delta");
                                    break;
                                case AmountChainField.FieldRelationshipEnum.RELATIONSHIP_MODIFIER:
                                    stmt.AddParam("FieldType", MTParameterType.String, "modifier");
                                    break;
                            }
                            stmt.AddParam("ContributingField", MTParameterType.String, field.ContributingField);
                            if ((field.PercentageValue == null) && (field.PercentageColumnName == null))
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String, null);
                            }
                            else if ((field.PercentageValue != null) && (field.PercentageColumnName != null))
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String,
                                    "'" + field.PercentageValue.ToString() + "'");
                            }
                            else if (field.PercentageValue != null)
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String,
                                    "'" + field.PercentageValue.ToString() + "'");
                            }
                            else
                            {
                                stmt.AddParam("PercentageField", MTParameterType.String, field.PercentageColumnName);
                            }

                            if ((field.CurrencyValue == null) && (field.CurrencyColumnName == null))
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String, null);
                            }
                            else if ((field.CurrencyValue != null) && (field.CurrencyColumnName != null))
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String,
                                    "'" + field.CurrencyValue.ToString() + "'");
                            }
                            else if (field.CurrencyValue != null)
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String,
                                    "'" + field.CurrencyValue.ToString() + "'");
                            }
                            else
                            {
                                stmt.AddParam("CurrencyField", MTParameterType.String, field.CurrencyColumnName);
                            }
                            stmt.AddParam("Modifier", MTParameterType.String, field.Modifier);
                            stmt.AddParam("Filter", MTParameterType.String, field.Filter);
                            if (field.Rounding == AmountChain.RoundingOptionsEnum.NO_ROUNDING)
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, "noRounding");
                            }
                            else if (field.Rounding == AmountChain.RoundingOptionsEnum.ROUND_TO_CURRENCY)
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, "roundToCurrency");
                            }
                            else if (field.Rounding == AmountChain.RoundingOptionsEnum.ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS)
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, "roundToDigits");
                            }
                            else
                            {
                                stmt.AddParam("Rounding", MTParameterType.String, null);
                            }
                            stmt.AddParam("RoundingNumDigits", MTParameterType.String, field.RoundingNumDigits);
                            stmt.AddParam("Priority", MTParameterType.String, field.Priority);

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("UpdateAmountChainField failed", e);
                throw new MASBasicException("UpdateAmountChainField failed. " + e.Message);
            }
        }

        private void DeleteAmountChainField(AmountChainField field)
        {
            m_Logger.LogDebug("DeleteAmountChainField");
            // delete existing row for this field
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__DELETE_AMOUNT_CHAIN_FIELD__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("fieldId", MTParameterType.Guid, field.UniqueId);
                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("DeleteAmountChainField failed", e);
                throw new MASBasicException("DeleteAmountChainField failed. " + e.Message);
            }
        }

        #endregion

        #region PRIVATE_PV_TO_AMOUNT_CHAIN_METHODS
        private bool RetrieveAndPopulatePvToAmountChainMapping(Guid mappingUniqueId, ref PvToAmountChainMapping mapping)
        {
            bool mappingFoundInDb = false;
            try
            {
                // Retrieve a specific mapping.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_PV_TO_AMOUNT_CHAIN_MAPPING__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("mappingUniqueId", MTParameterType.Guid, mappingUniqueId);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (!rdr.IsDBNull("c_PvToAmountChain_Id"))
                                    {
                                        mapping.UniqueId = rdr.GetGuid("c_PvToAmountChain_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null UniqueId");
                                    }

                                    if (!rdr.IsDBNull("c_Name"))
                                    {
                                        mapping.Name = rdr.GetString("c_Name");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null Name");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null name");
                                    }

                                    if (!rdr.IsDBNull("c_Description"))
                                    {
                                        mapping.Description = rdr.GetString("c_Description");
                                    }
                                    else
                                    {
                                        // OK to have NULL description
                                    }

                                    if (!rdr.IsDBNull("c_ProductViewName"))
                                    {
                                        mapping.ProductViewName = rdr.GetString("c_ProductViewName");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null ProductViewName");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null ProductViewName");
                                    }

                                    if (!rdr.IsDBNull("c_AmountChain_Id"))
                                    {
                                        mapping.AmountChainUniqueId = rdr.GetGuid("c_AmountChain_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null UniqueId");
                                    }
                                    mappingFoundInDb = true;
                                }
                            }
                        }

                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulatePvToAmountChainMapping failed", e);
                throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping failed. " + e.Message);
            }

            return mappingFoundInDb;
        }

        private bool RetrieveAndPopulatePvToAmountChainMapping(
            string mappingName, string mappingDescription,
            string productViewName, Guid amountChainUniqueId,
            ref PvToAmountChainMapping mapping)
        {
            bool mappingFoundInDb = false;
            try
            {
                // Retrieve a specific mapping.
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_PV_TO_AMOUNT_CHAIN_MAPPING2__");

                        using (IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("mappingName", MTParameterType.String, mappingName);
                            stmt.AddParam("mappingDescription", MTParameterType.String, mappingDescription);
                            stmt.AddParam("productViewName", MTParameterType.String, productViewName);
                            stmt.AddParam("amountChainUniqueId", MTParameterType.Guid, amountChainUniqueId);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (!rdr.IsDBNull("c_PvToAmountChain_Id"))
                                    {
                                        mapping.UniqueId = rdr.GetGuid("c_PvToAmountChain_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null UniqueId");
                                    }

                                    if (!rdr.IsDBNull("c_Name"))
                                    {
                                        mapping.Name = rdr.GetString("c_Name");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null Name");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null name");
                                    }

                                    if (!rdr.IsDBNull("c_Description"))
                                    {
                                        mapping.Description = rdr.GetString("c_Description");
                                    }
                                    else
                                    {
                                        // OK to have NULL description
                                    }

                                    if (!rdr.IsDBNull("c_ProductViewName"))
                                    {
                                        mapping.ProductViewName = rdr.GetString("c_ProductViewName");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null ProductViewName");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null ProductViewName");
                                    }

                                    if (!rdr.IsDBNull("c_AmountChain_Id"))
                                    {
                                        mapping.AmountChainUniqueId = rdr.GetGuid("c_AmountChain_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping: null UniqueId");
                                    }
                                    mappingFoundInDb = true;
                                }
                            }
                        }

                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("RetrieveAndPopulatePvToAmountChainMapping failed", e);
                throw new MASBasicException("RetrieveAndPopulatePvToAmountChainMapping failed. " + e.Message);
            }

            return mappingFoundInDb;
        }

        private void RetrieveAndPopulateAmountChainFields(ref AmountChain amountChain)
        {
            try
            {
                // Retrieve the info stored in the DB associated with this amount chain
                // Note: The amount chain might have some null values during 
                // construction.  If they remain null, the validator will catch the problems
                // e.g. null ProductViewName
                using (IMTConnection conn = ConnectionManager.CreateConnection(AMP_QUERY_DIR, true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapterClass();
                        queryAdapter.Item.Init(AMP_QUERY_DIR);
                        queryAdapter.Item.SetQueryTag("__GET_AMOUNT_CHAIN_FIELDS__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            stmt.AddParam("amountChainName", MTParameterType.String, amountChain.Name);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    AmountChainField amountChainField = new AmountChainField();

                                    if (!rdr.IsDBNull("c_AmountChainField_Id"))
                                    {
                                        amountChainField.UniqueId = rdr.GetGuid("c_AmountChainField_Id");
                                    }
                                    else
                                    {
                                        m_Logger.LogError("null UniqueId");
                                        throw new MASBasicException("RetrieveAndPopulateAmountChainFields: null UniqueId");
                                    }


                                    if (!rdr.IsDBNull("c_FieldName"))
                                    {
                                        amountChainField.FieldName = rdr.GetString("c_FieldName");
                                    }
                                    else
                                    {
                                        throw new MASBasicException("RetrieveAndPopulateAmountChainFields: null value for c_FieldName");
                                    }

                                    if (!rdr.IsDBNull("c_ProductViewName"))
                                    {
                                        amountChainField.ProductViewName = rdr.GetString("c_ProductViewName");
                                    }
                                    else
                                    {
                                        // ok to have null ProductViewName
                                        amountChainField.ProductViewName = null;
                                    }

                                    if (!rdr.IsDBNull("c_CurrencyField"))
                                    {
                                        string currency = rdr.GetString("c_CurrencyField");
                                        // If the value of currency is surrounded by quotes,
                                        // then the value is a scalar e.g. "USD".
                                        // Otherwise, the value refers to a column in the PV.
                                        if (currency.StartsWith("'") && currency.EndsWith("'"))
                                        {
                                            amountChainField.CurrencyValue = currency.Substring(1, currency.Length - 2);
                                            amountChainField.CurrencyColumnName = null;
                                        }
                                        else
                                        {
                                            amountChainField.CurrencyColumnName = currency;
                                            amountChainField.CurrencyValue = null;
                                        }

                                    }
                                    else
                                    {
                                        // ok to have null Currency
                                        amountChainField.CurrencyColumnName = null;
                                        amountChainField.CurrencyValue = null;
                                    }

                                    if (!rdr.IsDBNull("c_FieldType"))
                                    {
                                        string fieldRelationship = rdr.GetString("c_FieldType").ToUpper();
                                        if (fieldRelationship == "PERCENTAGE")
                                        {
                                            amountChainField.FieldRelationship =
                                                AmountChainField.FieldRelationshipEnum.RELATIONSHIP_PERCENTAGE;
                                        }
                                        else if (fieldRelationship == "PROPORTIONAL")
                                        {
                                            amountChainField.FieldRelationship =
                                                AmountChainField.FieldRelationshipEnum.RELATIONSHIP_PROPORTIONAL;
                                        }
                                        else if (fieldRelationship == "CURRENCY_CONVERSION")
                                        {
                                            amountChainField.FieldRelationship =
                                                AmountChainField.FieldRelationshipEnum.RELATIONSHIP_CURRENCY_CONVERSION;
                                        }
                                        else if (fieldRelationship == "DELTA")
                                        {
                                            amountChainField.FieldRelationship =
                                                AmountChainField.FieldRelationshipEnum.RELATIONSHIP_DELTA;
                                        }
                                        else if (fieldRelationship == "MODIFIER")
                                        {
                                            amountChainField.FieldRelationship =
                                                AmountChainField.FieldRelationshipEnum.RELATIONSHIP_MODIFIER;
                                        }
                                        else if (fieldRelationship == "UNITS")
                                        {
                                            amountChainField.FieldRelationship =
                                                AmountChainField.FieldRelationshipEnum.RELATIONSHIP_UNITS_OF_USAGE;
                                        }
                                        else if (fieldRelationship == "AMOUNT")
                                        {
                                            amountChainField.FieldRelationship =
                                                AmountChainField.FieldRelationshipEnum.RELATIONSHIP_AMOUNT;
                                        }
                                        else
                                        {
                                            throw new MASBasicException("RetrieveAndPopulateAmountChainFields: invalid c_FieldType value " + fieldRelationship);
                                        }
                                    }
                                    else
                                    {
                                        throw new MASBasicException("RetrieveAndPopulateAmountChainFields: null value for c_FieldRelationship");
                                    }

                                    if (!rdr.IsDBNull("c_Filter"))
                                    {
                                        amountChainField.Filter = rdr.GetString("c_Filter");
                                    }
                                    else
                                    {
                                        // ok to have null Filter
                                        amountChainField.Filter = null;
                                    }

                                    if (!rdr.IsDBNull("c_ContributingField"))
                                    {
                                        amountChainField.ContributingField = rdr.GetString("c_ContributingField");
                                    }
                                    else
                                    {
                                        // ok to have null ContributingField
                                        amountChainField.ContributingField = null;
                                    }

                                    if (!rdr.IsDBNull("c_PercentageField"))
                                    {
                                        string percentage = rdr.GetString("c_PercentageField");
                                        // If the value of percentage is surrounded by quotes,
                                        // then the value is a scalar e.g. "0.02".
                                        // Otherwise, the value refers to a column in the PV.
                                        if (percentage.StartsWith("'") && percentage.EndsWith("'"))
                                        {
                                            amountChainField.PercentageValue =
                                                Decimal.Parse(percentage.Substring(1, percentage.Length - 2));
                                            amountChainField.PercentageColumnName = null;
                                        }
                                        else
                                        {
                                            amountChainField.PercentageColumnName = percentage;
                                            amountChainField.PercentageValue = null;
                                        }

                                    }
                                    else
                                    {
                                        // ok to have null Percentage
                                        amountChainField.PercentageColumnName = null;
                                        amountChainField.PercentageValue = null;
                                    }

                                    if (!rdr.IsDBNull("c_Modifier"))
                                    {
                                        amountChainField.Modifier = rdr.GetString("c_Modifier");
                                    }
                                    else
                                    {
                                        // ok to have null Modifier
                                        amountChainField.Modifier = null;
                                    }

                                    if (!rdr.IsDBNull("c_Rounding"))
                                    {
                                        string rounding = rdr.GetString("c_Rounding").ToUpper();
                                        if (rounding == "NOROUNDING")
                                        {
                                            amountChainField.Rounding = AmountChain.RoundingOptionsEnum.NO_ROUNDING;
                                        }
                                        else if (rounding == "ROUNDTOCURRENCY")
                                        {
                                            amountChainField.Rounding = AmountChain.RoundingOptionsEnum.ROUND_TO_CURRENCY;
                                        }
                                        else if (rounding == "ROUNDTODIGITS")
                                        {
                                            amountChainField.Rounding = AmountChain.RoundingOptionsEnum.ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS;
                                        }
                                        else
                                        {
                                            throw new MASBasicException("RetrieveAndPopulateAmountChainFields: invalid value in c_Rounding " + rounding);
                                        }
                                    }
                                    else
                                    {
                                        // ok to have null Rounding
                                        amountChainField.Rounding = null;
                                    }

                                    if (!rdr.IsDBNull("c_RoundingNumDigits"))
                                    {
                                        amountChainField.RoundingNumDigits = rdr.GetInt32("c_RoundingNumDigits");
                                    }
                                    else
                                    {
                                        // ok to have null RoundingNumDigits
                                        amountChainField.RoundingNumDigits = null;
                                    }

                                    if (!rdr.IsDBNull("c_Priority"))
                                    {
                                        amountChainField.Priority = rdr.GetInt32("c_Priority");
                                    }
                                    else
                                    {
                                        // ok to have null Priority
                                        amountChainField.Priority = null;
                                    }

                                    amountChain.AmountChainFields.Add(amountChainField);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception in RetrieveAndPopulateAmountChainFields", e);
                throw new MASBasicException("RetrieveAndPopulateAmountChainFields failed. " + e.Message);
            }
        }

        /// <summary>
        /// This method is involved in the sorting and filtering of a list of PvToAmountChainMappings returned to
        /// clients.  The clients should only be aware of the PvToAmountChainMapping domain model member names.
        /// This method converts the domain model member names into the appropriate database column names.
        /// </summary>
        /// <param name="acgDomainModelMemberName">Name of a PvToAmountChainMapping domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds PvToAmountChainMappings</returns>
        private string AcgDomainModelMemberNameToColumnName(string acgDomainModelMemberName,
            ref object filterVal, object helper)
        {
            string columnName = acgDomainModelMemberName;

            switch (acgDomainModelMemberName)
            {
                case "Name":
                    columnName = "c_Name";
                    break;

                case "Description":
                    columnName = "c_Description";
                    break;

                case "UniqueId":
                    columnName = "c_PvToAmountChain_Id";
                    break;
            }

            return columnName;
        }
        #endregion

        #region PRIVATE_DECISION_INSTANCE_METHODS
        private Dictionary<string, string[]> _headers = new Dictionary<string, string[]>();
        private string[] GetHeaderValues(string id)
        {
            if (_headers.ContainsKey(id))
            {
                return _headers[id];
            }
            else
            {
                lock (_headers)
                {
                    if (_headers.ContainsKey(id))
                    {
                        return _headers[id];
                    }
                    string[] list = new string[0];
                    using (var conn = ConnectionManager.CreateConnection())
                    {
                        using (var stmt = conn.CreateAdapterStatement(AMP_QUERY_DIR, "__GET_DECISION_MVM_FORMAT__"))
                        {
                            stmt.AddParam("%%FORMAT_ID%%", id);
                            using (var rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    string a1 = string.Empty;
                                    if (!rdr.IsDBNull("format_string1"))
                                    {
                                        a1 = rdr.GetString("format_string1");
                                    }
                                    string a2 = string.Empty;
                                    if (!rdr.IsDBNull("format_string2"))
                                    {
                                        a2 = rdr.GetString("format_string2");
                                    }
                                    string a3 = string.Empty;
                                    if (!rdr.IsDBNull("format_string3"))
                                    {
                                        a3 = rdr.GetString("format_string3");
                                    }
                                    string a4 = string.Empty;
                                    if (!rdr.IsDBNull("format_string4"))
                                    {
                                        a4 = rdr.GetString("format_string4");
                                    }
                                    string a5 = string.Empty;
                                    if (!rdr.IsDBNull("format_string5"))
                                    {
                                        a5 = rdr.GetString("format_string5");
                                    }
                                    string a = a1 + a2 + a3 + a4 + a5;
                                    list = a.Split(',');
                                }
                            }
                        }
                    }
                    _headers[id] = list;
                    return list;
                }
            }
        }
        private void RetrieveAndPopulateDecisionInstance(IMTDataReader reader, ref DecisionInstance decisionInstance)
        {
            for (var i = 0; i < reader.FieldCount; i++)
            {
                var name = reader.GetName(i);
                switch (name)
                {
                    case "id_acc":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.AccountId = reader.GetInt32(i);
                        }
                        else
                        {
                            m_Logger.LogError("null " + name);
                            throw new MASBasicException("RetrieveAndPopulateDecision: null " + name);
                        }
                        break;
                    case "id_group":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.GroupId = reader.GetInt32(i);
                        }
                        break;
                    case "id_sub":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.SubscriptionId = reader.GetInt32(i);
                        }
                        break;
                    case "start_date":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.StartDate = reader.GetDateTime(i);
                        }
                        break;
                    case "end_date":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.EndDate = reader.GetDateTime(i);
                        }
                        break;
                    case "id_po":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.ProductOfferingId = reader.GetInt32(i);
                        }
                        break;
                    case "id_sched":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.RateScheduleId = reader.GetInt32(i);
                        }
                        break;
                    case "n_order":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.NOrder = reader.GetInt32(i);
                        }
                        break;
                    case "tt_start":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.TtStartDate = reader.GetDateTime(i);
                        }
                        break;
                    case "account_qualification_group":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.AccountQualificationGroup = reader.GetString(i);
                        }
                        break;
                    case "tier_column_group":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.TierColumnGroup = reader.GetString(i);
                        }
                        break;
                    case "tier_priority":
                        if (!reader.IsDBNull(i))
                        {
                            object pval = reader.GetDecimal(i);
                            if (pval != null)
                            {
                                decisionInstance.TierPriority = pval.ToString();
                            }
                        }
                        break;
                    case "tier_category":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.TierCategory = reader.GetString(i);
                        }
                        break;
                    case "tier_responsiveness":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.TierResponsiveness = reader.GetString(i);
                        }
                        break;
                    case "decision_unique_id":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.DecisionUniqueId = reader.GetString(i);
                        }
                        break;
                    case "decision_object_id":
                        if (decisionInstance.OtherDecisionAttributes == null)
                        {
                            decisionInstance.OtherDecisionAttributes = new Dictionary<string, string>();
                        }
                        if (!reader.IsDBNull(i))
                        {
                            string[] values = reader.GetString(i).Split(new string[1] { "<|" }, StringSplitOptions.None);
                            if (values.Length > 1)
                            {
                                string[] names = GetHeaderValues(values[0]);
                                if (names.Length != (values.Length - 1))
                                {
                                    m_Logger.LogError("format does not match value for object id");
                                    throw new MASBasicException("RetrieveAndPopulateDecision: format does not match value for object id");
                                }
                                for (int j = 0; j < names.Length; j++)
                                {
                                    decisionInstance.OtherDecisionAttributes[names[j]] = values[j + 1];
                                }
                            }
                        }
                        break;
                    case "id_usage_interval":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.UsageInterval = reader.GetInt32(i);
                        }
                        break;
                    case "qualified_events":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.QualifiedEvents = reader.GetDecimal(i);
                        }
                        break;
                    case "qualified_units":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.QualifiedUnits = reader.GetDecimal(i);
                        }
                        break;
                    case "qualified_amount":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.QualifiedAmounts = reader.GetDecimal(i);
                        }
                        break;
                    case "tier_start":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.TierStart = reader.GetDecimal(i);
                        }
                        break;
                    case "tier_end":
                        if (!reader.IsDBNull(i))
                        {
                            decisionInstance.TierEnd = reader.GetDecimal(i);
                        }
                        break;
                    default:
                        if (decisionInstance.OtherInstanceValues == null)
                        {
                            decisionInstance.OtherInstanceValues = new Dictionary<string, string>();
                        }
                        if (!reader.IsDBNull(i))
                        {
                            object value = reader.GetValue(i);
                            if (value != null)
                            {
                                decisionInstance.OtherInstanceValues[name] = value.ToString();
                            }
                        }
                        break;
                }
            }
        }
        #endregion
    }
}
