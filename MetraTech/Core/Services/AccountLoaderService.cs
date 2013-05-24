// -----------------------------------------------------------------------
// <copyright file="AccountLoaderService.cs" company="MetraTech Corp.">
// By Victor Koshman, 20 March 2013
// </copyright>
// -----------------------------------------------------------------------

using System.Collections;
using System.Reflection;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.Common;
using System;
using System.Collections.Generic;

namespace MetraTech.Core.Services
{
  /// <summary>
  /// Base class for a service that loads accounts.
  /// </summary>
  public class AccountLoaderService : CMASServiceBase
  {
    private string mQueryPath = @"Queries\Account";
    private Hashtable mViewPropertiesMap = new Hashtable();
    protected Logger mLogger = new Logger("[AccountService]");

    [OperationCapability("Manage Account Hierarchies")]
    internal void LoadAccountBase(AccountIdentifier acct, DateTime timeStamp, out DomainModel.BaseTypes.Account account)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("LoadAccount"))
      {
        int accountId = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

        // Get account without views.
        LoadAccountInternal(accountId, timeStamp, false, out account);
      }
    }

    protected void LoadAccountInternal(int accountId, DateTime timeStamp, bool allViews, out DomainModel.BaseTypes.Account account)
    {
      // Initialize return values.
      account = null;

      try
      {
        // Need to determine the type of account to load.
        string AccountType = String.Empty;
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_ACCOUNT_TYPE_BYID__"))
          {
            stmt.AddParam("%%ACCOUNT_ID%%", accountId, true);
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              if (reader.Read())
                AccountType = reader.GetString("AccountType");
            }
          }
        }

        // Make sure we have an account type.
        if (AccountType == String.Empty)
        {
          throw new MASBasicException("Unable to determine account type for account " + accountId.ToString());
        }

        // Create instance of account type object.
        DomainModel.BaseTypes.Account acc = DomainModel.BaseTypes.Account.CreateAccount(AccountType);

        // Make sure we have an account instance.
        if (acc == null)
        {
          throw new MASBasicException("Unable to create " + AccountType + " type instance for account " + accountId.ToString());
        }

        // Load account data.
        LoadAccountData(accountId, timeStamp, allViews, ref acc);

        // Return result.
        account = acc;
      }
      catch (MASBaseException masBase)
      {
        throw masBase;
      }
      catch (Exception ex)
      {
        throw new MASBasicException(ex.Message);
      }
    }

    protected void LoadAccountData(int accountId, DateTime timeStamp, bool allViews, ref DomainModel.BaseTypes.Account acc)
    {
      // Get identity context.
      CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;
      Interop.MTYAAC.IMTSessionContext ctx = (Interop.MTYAAC.IMTSessionContext)clientIdentity.SessionContext;

      // Retrieve all account properties for specified account.
      Interop.MTYAAC.IMTAccountCatalog cat = new Interop.MTYAAC.MTAccountCatalog();
      cat.Init(ctx);

      // Get the account rowset data.
      Interop.MTYAAC.IMTSQLRowset rs = cat.FindAccountByIDAsRowset(timeStamp, accountId, null);

      // Make sure rowset is not empty.
      if (System.Convert.ToBoolean(rs.EOF) == true)
      {
        throw new MASBasicException("Failed to find account data");
      }

      // Set data to Account object based on returned rowset.
      string viewType = String.Empty;
      string className = String.Empty;
      foreach (PropertyInfo pi in acc.GetMTProperties())
      {
        // Check if this is a view.
        if (IsView(pi, out viewType, out className))
        {
          // Do we need to process views at this time?
          if (allViews == false)
            continue;

          // Load the view.
          Assembly ass = acc.GetType().Assembly;
          object views = CreateGenericObject(typeof(List<>), ass.GetType(acc.GetType().Namespace + "." + className), null);
          IList viewList = (IList)views;

          // LoadViewInternal throws an exception on failure, so assume success
          LoadViewInternal(accountId, viewType, rs, viewList);

          // Load view may have positioned our rowset cursor at the end, we need to reset
          // to make sure we pick up any remaining account properties.
          rs.MoveFirst();

          // Is the view property a list of views?
          bool isList = (pi.PropertyType == views.GetType()) ? true : false;
          if (((IList)views).Count > 0)
          {
            if (isList)
              pi.SetValue(acc, views, null);
            else
            {
              // Set only the first item from the list.
              pi.SetValue(acc, ((IList)views)[0], null);
            }
          }
        }
        else // is not a view
        {
          // Set value for other properties.
          object value;
          SetValue(acc, pi, rs, out value);
        }
      }

      /*****
       * Account objects are created with the dirty bit set on each parameter.
       * Update of each parameter also sets the dirty bit on.
       * Since we're loading the account object, it is not really changed. Therefore,
       * we need to reset the dirty flag.
       *****/
      //acc.ResetDirtyFlag();
    }

    protected void LoadViewInternal(int accountId, string viewType, Interop.MTYAAC.IMTSQLRowset rs, IList views)
    {
      // Populate the passed in list of views.
      try
      {
        // Create view for specified type.
        DomainModel.BaseTypes.View view = DomainModel.BaseTypes.View.CreateView(viewType);

        // Use passed in rowset if not null.
        bool filterOnKeys = true; //xxx false;
        if (rs == null)
        {
          // Loop through view properties and get list of columns to retrieve.
          Interop.MTYAAC.IMTCollection columns = (Interop.MTYAAC.IMTCollection)mViewPropertiesMap[viewType];
          if (columns == null)
          {
            columns = (Interop.MTYAAC.IMTCollection)new Interop.GenericCollection.MTCollectionClass();
            foreach (PropertyInfo pi in view.GetMTProperties())
              columns.Add(pi.Name);

            mViewPropertiesMap[viewType] = columns;
          }

          // Get identity context.
          CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;
          Interop.MTYAAC.IMTSessionContext ctx = (Interop.MTYAAC.IMTSessionContext)clientIdentity.SessionContext;

          // Load view information.
          Interop.MTYAAC.IMTAccountCatalog cat = new Interop.MTYAAC.MTAccountCatalog();
          cat.Init(ctx);
          Interop.MTYAAC.IMTDataFilter filter = (Interop.MTYAAC.IMTDataFilter)new Interop.Rowset.MTDataFilterClass();
          filter.Add("_AccountID", Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, accountId);
          object out1;
          rs = cat.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 0, out out1, null);
        }

        // The rowset provided by account finder may have an outer left join on all
        // account views and will result in more rows then there are views.
        // Therefore we need to filter some of the rows out.
        // Account finder will return an empty row even if there is no data for
        // the account extension.
        else filterOnKeys = true;

        // Loop through rows in rowset.
        rs.MoveFirst();
        Hashtable processedViews = new Hashtable();
        while (System.Convert.ToBoolean(rs.EOF) == false)
        {
          // Create a new view if necessary.
          if (view == null)
            view = DomainModel.BaseTypes.View.CreateView(viewType);

          // Create a hash string of all key property values for current view.
          string keyPropertyValues = String.Empty;

          // If there are any key properties then we may have more than one view.
          // If there are no key properties then THERE CAN BE ONLY ONE view.
          // If all key properties are null then the record may be skipped.
          // If there is only one view and all the property values are null
          // then skip the record.
          bool foundKeyProperties = false;
          bool anyPropertyValues = false;

          // Set data in row to view.
          foreach (PropertyInfo pi in view.GetMTProperties())
          {
            // Set value to view.
            object value = null;
            SetValue(view, pi, rs, out value);

            // Append value to key string, if it is part of key.
            if (filterOnKeys)
            {
              // Is the value null?
              bool NullValue = (value is System.DBNull) ? true : false;
              if (!NullValue)
                anyPropertyValues = true;

              if (IsPartOfKey(pi))
              {
                foundKeyProperties = true;

                if (!NullValue)
                  keyPropertyValues += value.ToString() + "|";
              }
            }
          }

          // Should we skip the view record?
          if (filterOnKeys)
          {
            if (
              // No key properties found, cannot have all null properties.
                (!anyPropertyValues &&
                 !foundKeyProperties) ||

                // Missing all key properties.
                (foundKeyProperties &&
                 keyPropertyValues == String.Empty) ||

                // Check for duplicate record using key values.
                processedViews[keyPropertyValues] != null
              )
            {
              // skip the view record
              view = null;
              rs.MoveNext();
              continue;
            }

            // Cache the key values.
            processedViews[keyPropertyValues] = true;
          }

          /*****
           * All view objects are created with the dirty bit set on each parameter.
           * Update of each parameter also sets the dirty bit on.
           * Since we're loading a view object, it is not really changed. Therefore,
           * we need to reset the dirty flag.
           *****/
          //view.ResetDirtyFlag();

          // Add view to list.
          views.Add(view);

          // Get the next row.
          view = null;
          rs.MoveNext();
        }
      }
      catch (Exception ex)
      {
        throw new MASBasicException(ex.Message);
      }
    }

    protected void SetValue(DomainModel.BaseTypes.BaseObject obj, PropertyInfo pi, Interop.MTYAAC.IMTSQLRowset rs, out object value)
    {
      // Set return value.
      value = null;

      // Check if this is a input only property.
      MTDataMemberAttribute attribute = null;
      if (GetMTDataMemberAttribute(pi, out attribute) == true)
      {
        if (attribute.IsInputOnly == true)
          return;  // Skip value.
      }

      // Get value from rowset.
      try
      {
        value = rs.get_Value(pi.Name);
      }
      catch (Exception ex)
      {
        mLogger.LogError(String.Format("Couldn't find account property [{0}] in rowset; skipping it. {1}",
                         pi.Name, ex.Message));
        return;
      }

      obj.SetValue(pi, value);
    }

    protected static bool IsView(PropertyInfo pi, out string viewType, out string className)
    {
      MTDataMemberAttribute attribute = null;
      if (GetMTDataMemberAttribute(pi, out attribute) == true)
      {
        if (!String.IsNullOrEmpty(((MTDataMemberAttribute)attribute).ViewType))
        {
          viewType = ((MTDataMemberAttribute)attribute).ViewType;
          className = ((MTDataMemberAttribute)attribute).ClassName;
          return true;
        }
      }

      viewType = String.Empty;
      className = String.Empty;
      return false;
    }

    protected static bool GetMTDataMemberAttribute(PropertyInfo pi, out MTDataMemberAttribute attribute)
    {
      object[] attributes = pi.GetCustomAttributes(typeof(MTDataMemberAttribute), true);
      if (attributes != null && attributes.Length > 0)
      {
        attribute = (MTDataMemberAttribute)attributes[0];
        return true;
      }

      attribute = null;
      return false;
    }

    protected static bool IsPartOfKey(PropertyInfo pi)
    {
      MTDataMemberAttribute attribute = null;
      if (GetMTDataMemberAttribute(pi, out attribute) == true)
        return ((MTDataMemberAttribute)attribute).IsPartOfKey;

      return false;
    }

    protected static object CreateGenericObject(Type generic, Type innerType, params object[] args)
    {
      System.Type specificType = generic.MakeGenericType(new System.Type[] { innerType });
      return Activator.CreateInstance(specificType, args);
    }
  }
}
