/**************************************************************************
* Copyright 2012 by MetraTech
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

using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Common;
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
using MetraTech.Interop.MTAuth;
using MetraTech.Debug.Diagnostics;


namespace MetraTech.Core.Services
{
  [ServiceContract()]
  public interface ITaxService
  {
    /// <summary>
    /// Retrieve a list of the BillSoftExemptions that exist in the DB.
    /// The returned BillSoftExemption objects will be completely populated.
    /// </summary>
    /// <param name="billSoftExemptions">List containing all of the billSoftExemptions in the DB</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetBillSoftExemptions(ref MTList<BillSoftExemption> billSoftExemptions);

    /// <summary>
    /// Retrieve a single billSoftExemption using the specified unique id.
    /// </summary>
    /// <param name="idTaxExemption">unique id for a billSoftExemption</param>
    /// <param name="billSoftExemption">OUT selected billSoftExemption object</param>
    /// <exception cref="System.ServiceModel.FaultException">If id does not exist in the DB</exception>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetBillSoftExemption(int idTaxExemption, out BillSoftExemption billSoftExemption);

    /// <summary>
    /// Create a brand new billSoftExemption in the DB.
    /// </summary>
    /// <param name="accountId">Account that this exemption will apply to, or the parent account in an account hierarchy</param>
    /// <param name="applyToDescendents">True if the exemption should apply to this account and it's descendents.  False if the exemption just a applies to a single account</param>
    /// <param name="billSoftExemption">brand new billSoftExemption object with only the idTaxExemption, id_ancestor, and id_acc filled in</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateBillSoftExemption(int accountId, bool applyToDescendents, out BillSoftExemption billSoftExemption);

    /// <summary>
    /// Store the contents of the specified billSoftExemption object in the DB.
    /// </summary>
    /// <param name="billSoftExemption">billSoftExemption object to be stored in the DB</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveBillSoftExemption(BillSoftExemption billSoftExemption);

    /// <summary>
    /// Delete a billSoftExemption from the DB and all of it's directives
    /// </summary>
    /// <param name="idTaxExemption">unique id for this BillSoftExemption</param>
    /// <exception cref="System.ServiceModel.FaultException">If id does not exist in the DB</exception>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteBillSoftExemption(int idTaxExemption);

    /// <summary>
    /// Retrieve a list of the BillSoftOverrides that exist in the DB.
    /// The returned BillSoftOverride objects will be completely populated.
    /// </summary>
    /// <param name="billSoftOverrides">List containing all of the billSoftOverrides in the DB</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetBillSoftOverrides(ref MTList<BillSoftOverride> billSoftOverrides);

    /// <summary>
    /// Retrieve a single billSoftOverride using the specified unique id.
    /// </summary>
    /// <param name="idTaxOverride">unique id for a billSoftOverride</param>
    /// <param name="billSoftOverride">OUT selected billSoftOverride object or NULL if it can't be found</param>
    /// <exception cref="System.ServiceModel.FaultException">If id does not exist in the DB</exception>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetBillSoftOverride(int idTaxOverride, out BillSoftOverride billSoftOverride);

    /// <summary>
    /// Create a brand new billSoftOverride in the DB.
    /// </summary>
    /// <param name="billSoftOverride">brand new billSoftOverride object with only the idTaxOverride filled</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateBillSoftOverride(int accountId, bool applyToDescendents, out BillSoftOverride billSoftOverride);

    /// <summary>
    /// Store the contents of the billSoftOverride object in the DB.
    /// </summary>
    /// <param name="billSoftOverride">billSoftOverride object to be stored in the DB</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveBillSoftOverride(BillSoftOverride billSoftOverride);

    /// <summary>
    /// Delete a billSoftOverride from the DB and all of it's directives
    /// </summary>
    /// <param name="idTaxOverride">unique id for this BillSoftOverride</param>
    /// <exception cref="System.ServiceModel.FaultException">If id does not exist in the DB</exception>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteBillSoftOverride(int idTaxOverride);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class TaxService : CMASServiceBase, ITaxService
  {
    private Logger m_Logger = new Logger("[TaxService]");

    // Directory where Tax related queries exist
    private const string TAX_QUERY_DIR = "queries\\Tax";

    #region PublicBillSoftExemption

    [OperationCapability("BillSoftViewCapability")]
    public void GetBillSoftExemptions(ref MTList<BillSoftExemption> billSoftExemptions)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetBillSoftExemptions"))
      {
        m_Logger.LogDebug("GetBillSoftExemptions");

        IMTConnection conn = null;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter = null;
        IMTPreparedFilterSortStatement stmt = null;
        IMTDataReader rdr = null;

        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__GET_BILLSOFT_EXEMPTIONS__");

          stmt = conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true));

          ApplyFilterSortCriteria<BillSoftExemption>(stmt, billSoftExemptions,
            new FilterColumnResolver(BillSoftExemptionDomainModelMemberNameToColumnName), null);

          rdr = stmt.ExecuteReader();
          while (rdr.Read())
          {
            BillSoftExemption exemption = new BillSoftExemption();

            ReadAndPopulateBillSoftExemption(rdr, ref exemption);

            billSoftExemptions.Items.Add(exemption);
          }
          billSoftExemptions.TotalRows = stmt.TotalRows;
        }
        catch (Exception e)
        {
          billSoftExemptions.Items.Clear();
          m_Logger.LogException("GetBillSoftExemptions" +
              " failed", e);
          throw new MASBasicException("GetBillSoftExemptions" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (queryAdapter != null)
          {
            queryAdapter.Dispose();
          }
          if (stmt != null)
          {
            stmt.Dispose();
          }
          if (rdr != null)
          {
            rdr.Dispose();
          }
        }
      }
    }

    [OperationCapability("BillSoftViewCapability")]
    public void GetBillSoftExemption(int uniqueId, out BillSoftExemption billSoftExemption)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetBillSoftExemption"))
      {
        m_Logger.LogDebug("GetBillSoftExemption" + " uniqueId=" + uniqueId.ToString());
        billSoftExemption = new BillSoftExemption();

        IMTConnection conn;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter;
        IMTPreparedStatement stmt;
        IMTDataReader rdr;

        bool foundBillSoftExemption = false;
        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__GET_BILLSOFT_EXEMPTION__");

          stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true));

          stmt.AddParam("uniqueId", MTParameterType.Integer, uniqueId);

          rdr = stmt.ExecuteReader();

          if (rdr.Read())
          {
            ReadAndPopulateBillSoftExemption(rdr, ref billSoftExemption);
            foundBillSoftExemption = true;
          }
        }
        catch (Exception e)
        {
          m_Logger.LogException("GetBillSoftExemption" +
              " failed", e);
          throw new MASBasicException("GetBillSoftExemption" +
              " failed. " + e.Message);
        }

        if (foundBillSoftExemption == false)
        {
          string errorMessage = String.Format("{0}: failed to retrieve BillSoftExemption with uniqueId={1}",
              "GetBillSoftExemption", uniqueId);
          throw new MASBasicException(errorMessage);
        }
      }
    }

    [OperationCapability("BillSoftManageCapability")]
    public void CreateBillSoftExemption(int accountId, bool applyToAccountAndDescendents, out BillSoftExemption billSoftExemption)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CreateBillSoftExemption"))
      {
        m_Logger.LogDebug("CreateBillSoftExemption" +
            " accountId=" + accountId.ToString() +
            ", applyToAccountAndDescendents=" + applyToAccountAndDescendents.ToString());
        IMTConnection conn = null;
        IMTCallableStatement callableStmt = null;

        try
        {
          // We use a stored procedure to insert a row into the exemption table
          // so that we can extract the unique ID after the insertion
          //
          // (Note: the uniqueId is determined by the DB because this column has the "identity" criteria)
          conn = ConnectionManager.CreateConnection();
          callableStmt = conn.CreateCallableStatement("InsertBillSoftExemption");

          if (applyToAccountAndDescendents)
          {
            callableStmt.AddParam("idAcc", MTParameterType.Integer, -1);
            callableStmt.AddParam("idAncestor", MTParameterType.Integer, accountId);
          }
          else
          {
            callableStmt.AddParam("idAcc", MTParameterType.Integer, accountId);
            callableStmt.AddParam("idAncestor", MTParameterType.Integer, -1);
          }
          callableStmt.AddOutputParam("uniqueId", MTParameterType.Integer);

          callableStmt.ExecuteNonQuery();

          int newlyAddedUniqueId = (int)callableStmt.GetOutputValue("uniqueId");

          // Now, fill the billSoftExemption object with the data that is stored in the DB
          GetBillSoftExemption(newlyAddedUniqueId, out billSoftExemption);
        }
        catch (Exception e)
        {
          m_Logger.LogException("CreateBillSoftExemption" +
              " failed", e);
          throw new MASBasicException("CreateBillSoftExemption" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (callableStmt != null)
          {
            callableStmt.Dispose();
          }
        }
      }
    }

    [OperationCapability("BillSoftManageCapability")]
    public void SaveBillSoftExemption(BillSoftExemption billSoftExemption)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveBillSoftExemption"))
      {
        m_Logger.LogDebug("SaveBillSoftExemption");

        // Make sure the billSoftExemption exists in the DB.
        try
        {
          BillSoftExemption dbBillSoftExemption;
          GetBillSoftExemption(billSoftExemption.UniqueId, out dbBillSoftExemption);
        }
        catch (Exception e)
        {
          string errorMessage = String.Format(
              "{0}: failed because the specified billSoftException with uniqueId={1} could not be retrieved from the DB",
              "SaveBillSoftExemption",
              billSoftExemption.UniqueId);
          m_Logger.LogException(errorMessage, e);
          throw new MASBasicException(errorMessage);
        }

        // Update the DB to reflect the contents of the specified billSoftExemption
        IMTConnection conn = null;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter = null;
        IMTPreparedStatement stmt = null;
        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__UPDATE_BILLSOFT_EXEMPTION__");

          stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true));

          stmt.AddParam("uniqueId", MTParameterType.Integer, billSoftExemption.UniqueId);
          if (billSoftExemption.ApplyToAccountAndDescendents == true)
          {
            stmt.AddParam("ancestorAccountId", MTParameterType.Integer, billSoftExemption.AccountId);
            stmt.AddParam("accountId", MTParameterType.Integer, -1);
          }
          else
          {
            stmt.AddParam("ancestorAccountId", MTParameterType.Integer, -1);
            stmt.AddParam("accountId", MTParameterType.Integer, billSoftExemption.AccountId);
          }
          stmt.AddParam("certificateId", MTParameterType.String, billSoftExemption.CertificateId);
          stmt.AddParam("permanentLocationCode", MTParameterType.Integer, billSoftExemption.PermanentLocationCode);
          stmt.AddParam("taxType", MTParameterType.Integer, billSoftExemption.TaxType);
          stmt.AddParam("taxLevel", MTParameterType.Integer, billSoftExemption.TaxLevel);
          stmt.AddParam("startDate", MTParameterType.DateTime, billSoftExemption.StartDate);
          stmt.AddParam("endDate", MTParameterType.DateTime, billSoftExemption.EndDate);

          stmt.ExecuteNonQuery();
        }
        catch (Exception e)
        {
          m_Logger.LogException("SaveBillSoftExemption" +
              " failed", e);
          throw new MASBasicException("SaveBillSoftExemption" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (queryAdapter != null)
          {
            queryAdapter.Dispose();
          }
          if (stmt != null)
          {
            stmt.Dispose();
          }
        }
      }
    }

    [OperationCapability("BillSoftManageCapability")]
    public void DeleteBillSoftExemption(int uniqueId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteBillSoftExemption"))
      {
        m_Logger.LogDebug("DeleteBillSoftExemption" + " uniqueId=" + uniqueId.ToString());
        // Remove the BillSoftExemption with the specified unique id from the DB
        IMTConnection conn = null;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter = null;
        IMTPreparedStatement stmt = null;
        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__DELETE_BILLSOFT_EXEMPTION__");

          stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true));
          stmt.AddParam("uniqueId", MTParameterType.Integer, uniqueId);

          stmt.ExecuteNonQuery();
        }
        catch (Exception e)
        {
          m_Logger.LogException("DeleteBillSoftExemption" +
              " failed", e);
          throw new MASBasicException("DeleteBillSoftExemption" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (queryAdapter != null)
          {
            queryAdapter.Dispose();
          }
          if (stmt != null)
          {
            stmt.Dispose();
          }
        }
      }
    }

    #endregion

    #region PublicBillSoftOverride
    [OperationCapability("BillSoftViewCapability")]
    public void GetBillSoftOverrides(ref MTList<BillSoftOverride> billSoftOverrides)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetBillSoftOverrides"))
      {
        m_Logger.LogDebug("GetBillSoftOverrides");

        IMTConnection conn = null;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter = null;
        IMTPreparedFilterSortStatement stmt = null;
        IMTDataReader rdr = null;

        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__GET_BILLSOFT_OVERRIDES__");

          stmt = conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true));

          ApplyFilterSortCriteria<BillSoftOverride>(stmt, billSoftOverrides,
            new FilterColumnResolver(BillSoftOverrideDomainModelMemberNameToColumnName), null);

          rdr = stmt.ExecuteReader();
          while (rdr.Read())
          {
            BillSoftOverride billSoftOverride = new BillSoftOverride();

            ReadAndPopulateBillSoftOverride(rdr, ref billSoftOverride);

            billSoftOverrides.Items.Add(billSoftOverride);
          }
          billSoftOverrides.TotalRows = stmt.TotalRows;
        }
        catch (Exception e)
        {
          billSoftOverrides.Items.Clear();
          m_Logger.LogException("GetBillSoftOverrides" +
              " failed", e);
          throw new MASBasicException("GetBillSoftOverrides" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (queryAdapter != null)
          {
            queryAdapter.Dispose();
          }
          if (stmt != null)
          {
            stmt.Dispose();
          }
          if (rdr != null)
          {
            rdr.Dispose();
          }
        }
      }
    }

    [OperationCapability("BillSoftViewCapability")]
    public void GetBillSoftOverride(int uniqueId, out BillSoftOverride billSoftOverride)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetBillSoftOverride"))
      {
        billSoftOverride = new BillSoftOverride();

        IMTConnection conn;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter;
        IMTPreparedStatement stmt;
        IMTDataReader rdr;

        bool foundBillSoftOverride = false;
        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__GET_BILLSOFT_OVERRIDE__");

          stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true));
          stmt.AddParam("uniqueId", MTParameterType.Integer, uniqueId);

          rdr = stmt.ExecuteReader();

          if (rdr.Read())
          {
            ReadAndPopulateBillSoftOverride(rdr, ref billSoftOverride);
            foundBillSoftOverride = true;
          }
        }
        catch (Exception e)
        {
          m_Logger.LogException("GetBillSoftOverride" +
              " failed", e);
          throw new MASBasicException("GetBillSoftOverride" +
              " failed. " + e.Message);
        }

        if (foundBillSoftOverride == false)
        {
          string errorMessage = String.Format("{0}: failed to retrieve BillSoftOverride with uniqueId={1}",
              "GetBillSoftOverride", uniqueId);
          throw new MASBasicException(errorMessage);
        }
      }
    }

    [OperationCapability("BillSoftManageCapability")]
    public void CreateBillSoftOverride(int accountId, bool applyToAccountAndDescendents, out BillSoftOverride billSoftOverride)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CreateBillSoftOverride"))
      {
        IMTConnection conn = null;
        IMTCallableStatement callableStmt = null;

        try
        {
          // We use a stored procedure to insert a row into the override table
          // so that we can extract the unique ID after the insertion
          //
          // (Note: the uniqueId is determined by the DB because this column has the "identity" criteria)
          conn = ConnectionManager.CreateConnection();
          callableStmt = conn.CreateCallableStatement("InsertBillSoftOverride");

          if (applyToAccountAndDescendents)
          {
            callableStmt.AddParam("idAcc", MTParameterType.Integer, -1);
            callableStmt.AddParam("idAncestor", MTParameterType.Integer, accountId);
          }
          else
          {
            callableStmt.AddParam("idAcc", MTParameterType.Integer, accountId);
            callableStmt.AddParam("idAncestor", MTParameterType.Integer, -1);
          }
          callableStmt.AddOutputParam("uniqueId", MTParameterType.Integer);

          callableStmt.ExecuteNonQuery();

          int newlyAddedUniqueId = (int)callableStmt.GetOutputValue("uniqueId");

          // Now, fill the billSoftOverride object with the data that is stored in the DB
          GetBillSoftOverride(newlyAddedUniqueId, out billSoftOverride);
        }
        catch (Exception e)
        {
          m_Logger.LogException("CreateBillSoftOverride" +
              " failed", e);
          throw new MASBasicException("CreateBillSoftOverride" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (callableStmt != null)
          {
            callableStmt.Dispose();
          }
        }
      }
    }

    [OperationCapability("BillSoftManageCapability")]
    public void SaveBillSoftOverride(BillSoftOverride billSoftOverride)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveBillSoftOverride"))
      {
        m_Logger.LogDebug("SaveBillSoftOverride");

        // Make sure the billSoftOverride exists in the DB.
        try
        {
          BillSoftOverride dbBillSoftOverride;
          GetBillSoftOverride(billSoftOverride.UniqueId, out dbBillSoftOverride);
        }
        catch (Exception e)
        {
          string errorMessage = String.Format(
              "{0}: failed because the specified billSoftException with uniqueId={1} could not be retrieved from the DB",
              "SaveBillSoftOverride",
              billSoftOverride.UniqueId);
          m_Logger.LogException(errorMessage, e);
          throw new MASBasicException(errorMessage);
        }

        // Update the DB to reflect the contents of the specified billSoftOverride
        IMTConnection conn = null;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter = null;
        IMTPreparedStatement stmt = null;
        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__UPDATE_BILLSOFT_OVERRIDE__");

          stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true));

          stmt.AddParam("UniqueId", MTParameterType.Integer, billSoftOverride.UniqueId);
          if (billSoftOverride.ApplyToAccountAndDescendents == true)
          {
            stmt.AddParam("ancestorAccountId", MTParameterType.Integer, billSoftOverride.AccountId);
            stmt.AddParam("accountId", MTParameterType.Integer, -1);
          }
          else
          {
            stmt.AddParam("ancestorAccountId", MTParameterType.Integer, -1);
            stmt.AddParam("accountId", MTParameterType.Integer, billSoftOverride.AccountId);
          }
          stmt.AddParam("permanentLocationCode", MTParameterType.Integer, billSoftOverride.PermanentLocationCode);
          stmt.AddParam("taxType", MTParameterType.Integer, billSoftOverride.TaxType);
          stmt.AddParam("taxLevel", MTParameterType.Integer, billSoftOverride.TaxLevel);
          stmt.AddParam("scope", MTParameterType.Integer, billSoftOverride.Scope);
          stmt.AddParam("effectiveDate", MTParameterType.DateTime, billSoftOverride.EffectiveDate);
          stmt.AddParam("exemptLevel", MTParameterType.Integer, billSoftOverride.ExemptLevel);
          stmt.AddParam("maximumBase", MTParameterType.Decimal, billSoftOverride.MaximumBase);
          stmt.AddParam("replaceTaxLevel", MTParameterType.Integer, billSoftOverride.ReplaceTaxLevel);
          stmt.AddParam("excessTaxRate", MTParameterType.Decimal, billSoftOverride.ExcessTaxRate);
          stmt.AddParam("taxRate", MTParameterType.Decimal, billSoftOverride.TaxRate);

          stmt.ExecuteNonQuery();
        }
        catch (Exception e)
        {
          m_Logger.LogException("SaveBillSoftOverride" +
              " failed", e);
          throw new MASBasicException("SaveBillSoftOverride" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (queryAdapter != null)
          {
            queryAdapter.Dispose();
          }
          if (stmt != null)
          {
            stmt.Dispose();
          }
        }
      }
    }

    [OperationCapability("BillSoftManageCapability")]
    public void DeleteBillSoftOverride(int uniqueId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteBillSoftOverride"))
      {
        // Remove the BillSoftOverride with the specified unique id from the DB
        IMTConnection conn = null;
        MTComSmartPtr<IMTQueryAdapter> queryAdapter = null;
        IMTPreparedStatement stmt = null;
        try
        {
          conn = ConnectionManager.CreateConnection(TAX_QUERY_DIR, true);
          queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(TAX_QUERY_DIR);
          queryAdapter.Item.SetQueryTag("__DELETE_BILLSOFT_OVERRIDE__");

          stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true));
          stmt.AddParam("uniqueId", MTParameterType.Integer, uniqueId);
          stmt.ExecuteNonQuery();
        }
        catch (Exception e)
        {
          m_Logger.LogException("DeleteBillSoftOverride" +
              " failed", e);
          throw new MASBasicException("DeleteBillSoftOverride" +
              " failed. " + e.Message);
        }
        finally
        {
          if (conn != null)
          {
            conn.Dispose();
          }
          if (queryAdapter != null)
          {
            queryAdapter.Dispose();
          }
          if (stmt != null)
          {
            stmt.Dispose();
          }
        }
      }
    }
    #endregion

    #region PrivateBillSoftExemption
    private void ReadAndPopulateBillSoftExemption(IMTDataReader rdr, ref BillSoftExemption exemption)
    {
      if (!rdr.IsDBNull("id_tax_exemption"))
      {
        exemption.UniqueId = rdr.GetInt32("id_tax_exemption");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for id_tax_exemption");
      }

      int idAncestor = -1;
      int idAcc = -1;
      if (!rdr.IsDBNull("id_ancestor"))
      {
        idAncestor = rdr.GetInt32("id_ancestor");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for id_ancestor");
      }

      if (!rdr.IsDBNull("id_acc"))
      {
        idAcc = rdr.GetInt32("id_acc");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for id_acc");
      }

      if ((idAncestor == -1) && (idAcc == -1))
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": both id_ancestor and id_acc are -1");
      }
      else if ((idAncestor != -1) && (idAcc != -1))
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": both id_ancestor and id_acc are NOT -1");
      }
      else if (idAncestor != -1)
      {
        exemption.AccountId = idAncestor;
        exemption.ApplyToAccountAndDescendents = true;
      }
      else
      {
        exemption.AccountId = idAcc;
        exemption.ApplyToAccountAndDescendents = false;
      }

      if (!rdr.IsDBNull("certificate_id"))
      {
        exemption.CertificateId = rdr.GetString("certificate_id");
      }
      else
      {
        m_Logger.LogDebug(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for certificate_id");
        exemption.CertificateId = null;
      }

      if (!rdr.IsDBNull("pcode"))
      {
        exemption.PermanentLocationCode = rdr.GetInt32("pcode");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for pcode");
      }

      if (!rdr.IsDBNull("tax_type"))
      {
        exemption.TaxType = rdr.GetInt32("tax_type");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for tax_type");
      }

      if (!rdr.IsDBNull("jur_level"))
      {
        exemption.TaxLevel = IntToTaxLevelEnum("jur_level", rdr.GetInt32("jur_level"));
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for jur_level");
      }

      if (!rdr.IsDBNull("start_date"))
      {
        exemption.StartDate = rdr.GetDateTime("start_date");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for start_date");
      }

      if (!rdr.IsDBNull("end_date"))
      {
        exemption.EndDate = rdr.GetDateTime("end_date");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for end_date");
      }

      if (!rdr.IsDBNull("create_date"))
      {
        exemption.CreateDate = rdr.GetDateTime("create_date");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for create_date");
      }

      if (!rdr.IsDBNull("update_date"))
      {
        exemption.UpdateDate = rdr.GetDateTime("update_date");
      }
      else
      {
        exemption.UpdateDate = null;
      }
    }

    private DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel IntToTaxLevelEnum(string columnName, int taxLevelInt)
    {
      DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel retValue;

      switch (taxLevelInt)
      {
        case 0:
          retValue = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.Federal;
          break;
        case 1:
          retValue = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.State;
          break;
        case 2:
          retValue = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County;
          break;
        case 3:
          retValue = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.Local;
          break;
        case 4:
          retValue = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.Other;
          break;
        default:
          throw new MASBasicException(
              "IntToTaxLevelEnum" +
              ": invalid value for " + columnName + "=" + taxLevelInt.ToString());
      }

      return retValue;
    }

    /// <summary>
    /// This method is involved in the sorting and filtering of a list of BillSoftExemptions returned to
    /// clients.  The clients should only be aware of the BillSoftExemption domain model member names.
    /// This method converts the BillSoftExemption's domain model member names into the appropriate
    /// database column names.
    /// </summary>
    /// <param name="domainModelMemberName">Name of a decision domain model member</param>
    /// <param name="filterVal">unused</param>
    /// <param name="helper">unused</param>
    /// <returns>Column name within the table that holds BillSoftExemptions</returns>
    private string BillSoftExemptionDomainModelMemberNameToColumnName(string domainModelMemberName, ref object filterVal, object helper)
    {
      string columnName = null;

      switch (domainModelMemberName)
      {
        case "UniqueId":
          columnName = "id_tax_exemption";
          break;

        case "CertificateId":
          columnName = "certificate_id";
          break;

        case "PermanentLocationCode":
          columnName = "pcode";
          break;

        case "TaxType":
          columnName = "tax_type";
          break;

        case "TaxLevel":
          columnName = "jur_level";
          break;

        case "StartDate":
          columnName = "start_date";
          break;

        case "EndDate":
          columnName = "end_date";
          break;

        case "CreateDate":
          columnName = "create_date";
          break;

        case "UpdateDate":
          columnName = "update_date";
          break;

        default:
          throw new MASBasicException("BillSoftExemptionDomainModelMemberNameToColumnName" +
              ": attempt to sort on invalid field " + domainModelMemberName);
          break;
      }

      return columnName;
    }
    #endregion

    #region PrivateBillSoftOverride
    private void ReadAndPopulateBillSoftOverride(IMTDataReader rdr, ref BillSoftOverride billSoftOverride)
    {
      if (!rdr.IsDBNull("id_tax_override"))
      {
        billSoftOverride.UniqueId = rdr.GetInt32("id_tax_override");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for id_tax_override");
      }

      int idAncestor = -1;
      int idAcc = -1;
      if (!rdr.IsDBNull("id_ancestor"))
      {
        idAncestor = rdr.GetInt32("id_ancestor");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for id_ancestor");
      }

      if (!rdr.IsDBNull("id_acc"))
      {
        idAcc = rdr.GetInt32("id_acc");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for id_acc");
      }

      if ((idAncestor == -1) && (idAcc == -1))
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": both id_ancestor and id_acc are -1");
      }
      else if ((idAncestor != -1) && (idAcc != -1))
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": both id_ancestor and id_acc are NOT -1");
      }
      else if (idAncestor != -1)
      {
        billSoftOverride.AccountId = idAncestor;
        billSoftOverride.ApplyToAccountAndDescendents = true;
      }
      else
      {
        billSoftOverride.AccountId = idAcc;
        billSoftOverride.ApplyToAccountAndDescendents = false;
      }

      if (!rdr.IsDBNull("pcode"))
      {
        billSoftOverride.PermanentLocationCode = rdr.GetInt32("pcode");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for pcode");
      }

      if (!rdr.IsDBNull("scope"))
      {
        billSoftOverride.Scope = IntToTaxLevelEnum("scope", rdr.GetInt32("scope"));
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for scope");
      }

      if (!rdr.IsDBNull("tax_type"))
      {
        billSoftOverride.TaxType = rdr.GetInt32("tax_type");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for tax_type");
      }

      if (!rdr.IsDBNull("jur_level"))
      {
        billSoftOverride.TaxLevel = IntToTaxLevelEnum("jur_level", rdr.GetInt32("jur_level"));
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for jur_level");
      }

      if (!rdr.IsDBNull("effectiveDate"))
      {
        billSoftOverride.EffectiveDate = rdr.GetDateTime("effectiveDate");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for effectiveDate");
      }

      if (!rdr.IsDBNull("levelExempt"))
      {
        string tmpExemptLevel = rdr.GetString("levelExempt").ToLower();
        if ((tmpExemptLevel == "1") || (tmpExemptLevel == "y") || (tmpExemptLevel == "t") || (tmpExemptLevel == "true"))
        {
          billSoftOverride.ExemptLevel = true;
        }
        else
        {
          billSoftOverride.ExemptLevel = false;
        }
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for levelExempt");
      }

      if (!rdr.IsDBNull("maximum"))
      {
        billSoftOverride.MaximumBase = rdr.GetDecimal("maximum");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for maximum");
      }

      if (!rdr.IsDBNull("replace_jur"))
      {
        string tmpReplaceTaxLevel = rdr.GetString("replace_jur").ToLower();
        if ((tmpReplaceTaxLevel == "1") || (tmpReplaceTaxLevel == "y") || (tmpReplaceTaxLevel == "t") || (tmpReplaceTaxLevel == "true"))
        {
          billSoftOverride.ReplaceTaxLevel = true;
        }
        else
        {
          billSoftOverride.ReplaceTaxLevel = false;
        }
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for replace_jur");
      }

      if (!rdr.IsDBNull("excess"))
      {
        billSoftOverride.ExcessTaxRate = rdr.GetDecimal("excess");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for excess");
      }

      if (!rdr.IsDBNull("tax_rate"))
      {
        billSoftOverride.TaxRate = rdr.GetDecimal("tax_rate");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for tax_rate");
      }

      if (!rdr.IsDBNull("create_date"))
      {
        billSoftOverride.CreateDate = rdr.GetDateTime("create_date");
      }
      else
      {
        throw new MASBasicException(
            "ReadAndPopulateBillSoftExemption" +
            ": null value for create_date");
      }

      if (!rdr.IsDBNull("update_date"))
      {
        billSoftOverride.UpdateDate = rdr.GetDateTime("update_date");
      }
      else
      {
        billSoftOverride.UpdateDate = null;
      }
    }

    /// <summary>
    /// This method is involved in the sorting and filtering of a list of BillSoftOverrides returned to
    /// clients.  The clients should only be aware of the BillSoftOverride domain model member names.
    /// This method converts the BillSoftOverride's domain model member names into the appropriate
    /// database column names.
    /// </summary>
    /// <param name="domainModelMemberName">Name of a decision domain model member</param>
    /// <param name="filterVal">unused</param>
    /// <param name="helper">unused</param>
    /// <returns>Column name within the table that holds BillSoftOverrides</returns>
    private string BillSoftOverrideDomainModelMemberNameToColumnName(string domainModelMemberName, ref object filterVal, object helper)
    {
      string columnName = null;

      switch (domainModelMemberName)
      {
        case "UniqueId":
          columnName = "id_tax_override";
          break;

        case "PermanentLocationCode":
          columnName = "pcode";
          break;

        case "Scope":
          columnName = "scope";
          break;

        case "TaxType":
          columnName = "tax_type";
          break;

        case "TaxLevel":
          columnName = "jur_level";
          break;

        case "EffectiveDate":
          columnName = "effectiveDate";
          break;

        case "ExemptLevel":
          columnName = "levelExempt";
          break;

        case "TaxRate":
          columnName = "tax_rate";
          break;

        case "MaximumBase":
          columnName = "maximum";
          break;

        case "ReplaceTaxLevel":
          columnName = "replace_jur";
          break;

        case "ExcessTaxRate":
          columnName = "excess";
          break;

        case "CreateDate":
          columnName = "create_date";
          break;

        case "UpdateDate":
          columnName = "update_date";
          break;

        default:
          throw new MASBasicException("BillSoftOverrideDomainModelMemberNameToColumnName" +
              ": attempt to sort on invalid field " + domainModelMemberName);
          break;
      }

      return columnName;
    }
    #endregion




  }
}
