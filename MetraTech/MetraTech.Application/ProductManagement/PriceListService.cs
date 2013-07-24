using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.Domain;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.Interop.MTAuth;

namespace MetraTech.Application.ProductManagement
{
  internal class RateScheduleHolder : BaseRateSchedule
  {
    // Only need this class so that can use BaseRateSchedule properties while having it still be abstract
  }

  /// <summary>
  /// Provides top level logic to manage price lists
  /// </summary>
  public static class PriceListService
  {
    public const string PCWS_QUERY_FOLDER = @"queries\PCWS";
    private const int RATE_SCHEDULE_KIND = 130;

    /// <summary>
    /// Keeps ICB prices in the database for a specified subscription
    /// </summary>
    /// <param name="subId">subscription id</param>
    /// <param name="piInstanceID">priceable item instance id</param>
    /// <param name="paramTableID">parameter table id</param>
    /// <param name="rscheds">rate schedules to save</param>
    /// <param name="logger">MetraNet logger</param>
    /// <param name="sessionContext">current session context</param>
    public static void SaveRateSchedulesForSubscription(int subId, PCIdentifier piInstanceID, PCIdentifier paramTableID,
                                                         List<BaseRateSchedule> rscheds, Logger logger, IMTSessionContext sessionContext)
    {
      try
      {
        #region Resolve identifiers

        int instanceId = PCIdentifierResolver.ResolvePIInstanceBySub(subId, piInstanceID, false);

        int ptId = -1;

        if (paramTableID.ID.HasValue)
        {
          if (CacheManager.ParamTableIdToNameMap.ContainsKey(paramTableID.ID.Value))
          {
            ptId = CacheManager.ParamTableIdToNameMap[paramTableID.ID.Value].ID;
          }
        }
        else if (!string.IsNullOrEmpty(paramTableID.Name))
        {
          if (CacheManager.ParamTableNameToIdMap.ContainsKey(paramTableID.Name.ToUpper()))
          {
            ptId = CacheManager.ParamTableNameToIdMap[paramTableID.Name.ToUpper()].ID;
          }
        }

        if (instanceId == -1)
          throw new MASBasicException(String.Format(
            "Invalid Priceable Item Instance specified for subscription {0}.", subId));

        if (ptId == -1)
          throw new MASBasicException(String.Format("Invalid Parameter Table ID specified for subscription {0}.",
                                                    subId));

        logger.LogDebug("Saving rate schedules for parameter table {0}, pi instance {1}, and subscription {2}", ptId,
                        instanceId, subId);

        #endregion

        #region Save ICB

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          int pricelistId;

          using (var stmt = conn.CreateCallableStatement("GetICBMappingForSub"))
          {
            stmt.AddParam("id_paramtable", MTParameterType.Integer, ptId);
            stmt.AddParam("id_pi_instance", MTParameterType.Integer, instanceId);
            stmt.AddParam("id_sub", MTParameterType.Integer, subId);
            stmt.AddParam("p_systemdate", MTParameterType.DateTime, MetraTime.Now);
            stmt.AddOutputParam("status", MTParameterType.Integer);
            stmt.AddOutputParam("id_pricelist", MTParameterType.Integer);

            stmt.ExecuteNonQuery();

            var status = (int) stmt.GetOutputValue("status");

            if (status == -10)
            {
              throw new MASBasicException(
                "ICB rates are not allowed for this parameter table on this product offering");
            }

            pricelistId = (int) stmt.GetOutputValue("id_pricelist");
          }

          if (pricelistId == -1)
          {
            throw new MASBasicException("Unable to get ICB pricelist for subscription");
          }

          int templateId = -1;

          using (
            IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER,
                                                                   "__GET_TEMPLATE_FOR_INSTANCE__"))
          {
            stmt.AddParam("%%ID_PI%%", instanceId);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              if (rdr.Read())
              {
                templateId = rdr.GetInt32(0);
              }
            }
          }

          if (templateId == -1)
          {
            throw new MASBasicException("Unable to locate template ID for priceable item instance");
          }

          UpsertRateSchedulesForPricelist(pricelistId, PriceListTypes.ICB_SUB, templateId, ptId, rscheds, logger,
                                          sessionContext);
        }

        #endregion
      }
      catch (MASBasicException masE)
      {
        logger.LogException("MAS Exception caught saving rate schedules for ICB", masE);

        throw;
      }
      catch (Exception e)
      {
        logger.LogException("Unknown error caught saving rate schedules for subscription", e);

        throw new MASBasicException(
          "Unexpected error saving rate schedules for subscription.  Please ask system administrator to review server logs");
      }
    }

    /// <summary>
    /// Keeps rate schedules in the database for a specified price list
    /// </summary>
    /// <param name="pricelistId">price list id</param>
    /// <param name="plType">price list type</param>
    /// <param name="templateId">tamplate id</param>
    /// <param name="paramTableId">param table id</param>
    /// <param name="rateSchedules">rate schedules to save</param>
    /// <param name="logger">MetraNet logger</param>
    /// <param name="sessionContext">current session context</param>
    public static void UpsertRateSchedulesForPricelist(int pricelistId,
                                                       PriceListTypes plType,
                                                       int templateId,
                                                       int paramTableId,
                                                       IList rateSchedules, Logger logger,
                                                       IMTSessionContext sessionContext)
    {
      var existingSchedules = new Dictionary<int, RateScheduleHolder>();
      var startDt = Domain.DataAccess.DatabaseUtils.FormatValueForDB(MetraTime.Now);
      var endDt = Domain.DataAccess.DatabaseUtils.FormatValueForDB(MetraTime.Max);
      var paramTableTableName = CacheManager.ParamTableIdToNameMap[paramTableId].TableName;
      var paramTableName = CacheManager.ParamTableIdToNameMap[paramTableId].Name;
      string details;
      int auditID;

      if (rateSchedules != null && rateSchedules.Count > 0)
      {
        #region Load existing rate schedules

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__LOAD_RATESCHEDS_FOR_PT__")
            )
          {
            stmt.AddParam("%%PRICELIST_ID%%", pricelistId);
            stmt.AddParam("%%PT_ID%%", paramTableId);
            stmt.AddParam("%%PI_TEMPL_ID%%", templateId);

            if (!conn.ConnectionInfo.IsOracle)
            {
              stmt.AddParam("%%UPDLOCK%%", "with(updlock)");
            }
            else
            {
              stmt.AddParam("%%UPDLOCK%%", "");
            }

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                RateScheduleHolder holder = new RateScheduleHolder();

                holder.ID = rdr.GetInt32("ID");
                holder.EffectiveDate = EffectiveDateUtils.GetEffectiveDate(rdr, "Effective");

                if (!rdr.IsDBNull("Description"))
                {
                  holder.Description = rdr.GetString("Description");
                }

                existingSchedules.Add(holder.ID.Value, holder);
              }
            }
          }
        }

        #endregion

        #region Merge Existing RateSchedule info

        foreach (BaseRateSchedule brs in rateSchedules)
        {
          if (brs.ID.HasValue && existingSchedules.ContainsKey(brs.ID.Value))
          {
            RateScheduleHolder holder = existingSchedules[brs.ID.Value];

            if (!brs.IsDescriptionDirty)
            {
              brs.Description = holder.Description;
            }

            if (!brs.IsEffectiveDateDirty)
            {
              brs.EffectiveDate = holder.EffectiveDate;
            }
          }
          else if (brs.ID.HasValue)
          {
            throw new MASBasicException(string.Format("Unable to locate rate schedule with ID {0}", brs.ID.Value));
          }
        }

        #endregion

        foreach (BaseRateSchedule brs in rateSchedules)
        {
          if (brs.ID.HasValue)
          {
            #region Update Rate Schedule

            #region Update Effective Dates

            if (brs.IsEffectiveDateDirty)
            {
              EffectiveDateUtils.UpdateEffectiveDate(brs.EffectiveDate);
            }

            #endregion

            #region Update Base Props

            if (brs.Description != null)
            {
              BasePropsUtils.UpdateBaseProps(sessionContext, brs.Description, true, "", false, brs.ID.Value);
            }
            else
            {
              BasePropsUtils.UpdateBaseProps(sessionContext, "", true, "", false, brs.ID.Value);
            }

            #endregion

            #region Set end date on existing Rate Entries

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (
                IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER,
                                                                       "__SET_ENDDATE_FOR_CURRENT_RATES_PCWS__"))
              {
                stmt.AddParam("%%TABLE_NAME%%", paramTableTableName);
                stmt.AddParam("%%ID_SCHED%%", brs.ID.Value);
                stmt.AddParam("%%TT_START%%", startDt, true);

                stmt.ExecuteNonQuery();
              }
            }

            #endregion

            #region Add audit entry

            AuditManager.MTAuditEvents eventType = 0;
            switch (plType)
            {
              case PriceListTypes.DEFAULT:
                eventType = AuditManager.MTAuditEvents.AUDITEVENT_RS_UPDATE;
                break;
              case PriceListTypes.ICB_SUB:
                eventType = AuditManager.MTAuditEvents.AUDITEVENT_ICB_UPDATE;
                break;
              case PriceListTypes.ICB_GSUB:
                eventType = AuditManager.MTAuditEvents.AUDITEVENT_GROUP_ICB_UPDATE;
                break;
            }

            details = string.Format("Price List: {0}, Price List Id: {1}, ParamTable: {2}, Rate Schedule Id: {3}", "", 0,
                                    paramTableName, brs.ID.Value);
            AuditManager.FireEvent(
              (int) eventType,
              sessionContext.AccountID,
              (int) AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
              brs.ID.Value,
              details);

            #endregion

            #endregion

            // Remove from existing schedules so that it doesn't get deleted below
            existingSchedules.Remove(brs.ID.Value);
          }
          else
          {
            #region Add new Rate Schedule

            #region Create Effective Date

            if (brs.EffectiveDate == null)
            {
              var timeSpan = new ProdCatTimeSpan();
              brs.EffectiveDate = timeSpan;
              brs.EffectiveDate.TimeSpanId = EffectiveDateUtils.CreateEffectiveDate(sessionContext, timeSpan);
            }
            else
              brs.EffectiveDate.TimeSpanId = EffectiveDateUtils.CreateEffectiveDate(sessionContext, brs.EffectiveDate);

            #endregion

            #region Create Base Props

            if (brs.Description != null)
              brs.ID = BasePropsUtils.CreateBaseProps(sessionContext, "", brs.Description, "", RATE_SCHEDULE_KIND);
            else
              brs.ID = BasePropsUtils.CreateBaseProps(sessionContext, "", "", "", RATE_SCHEDULE_KIND);

            #endregion

            #region Insert RateSchedule record

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (
                IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__ADD_RSCHED_PCWS__"))
              {
                adapterStmt.AddParam("%%ID_SCHED%%", brs.ID.Value);
                adapterStmt.AddParam("%%ID_PT%%", paramTableId);
                adapterStmt.AddParam("%%ID_EFFDATE%%", brs.EffectiveDate.TimeSpanId.Value);
                adapterStmt.AddParam("%%PRICELIST_ID%%", pricelistId);
                adapterStmt.AddParam("%%ID_TMPL%%", templateId);
                adapterStmt.AddParam("%%SYS_DATE%%", MetraTime.Now);

                adapterStmt.ExecuteNonQuery();
              }
            }

            #endregion

            #region Add audit entry

            AuditManager.MTAuditEvents eventType = 0;
            switch (plType)
            {
              case PriceListTypes.DEFAULT:
                eventType = AuditManager.MTAuditEvents.AUDITEVENT_RS_CREATE;
                break;
              case PriceListTypes.ICB_SUB:
                eventType = AuditManager.MTAuditEvents.AUDITEVENT_ICB_CREATE;
                break;
              case PriceListTypes.ICB_GSUB:
                eventType = AuditManager.MTAuditEvents.AUDITEVENT_GROUP_ICB_CREATE;
                break;
            }

            details = string.Format("Price List: {0}, Price List Id: {1}, ParamTable: {2}, Rate Schedule Id: {3}", "", 0,
                                    paramTableName, brs.ID.Value);
            AuditManager.FireEvent(
              (int) eventType,
              sessionContext.AccountID,
              (int) AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
              brs.ID.Value,
              details);

            #endregion

            #endregion
          }

          // Save rules

          #region Add audit entry

          details = string.Format("Price List: {0}, Price List Id: {1}, ParamTable: {2}, Rate Schedule Id: {3}", "", 0,
                                  paramTableName, brs.ID.Value);
          auditID = AuditManager.FireEvent(
            (int) AuditManager.MTAuditEvents.AUDITEVENT_RS_RULE_UPDATE,
            sessionContext.AccountID,
            (int) AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
            brs.ID.Value,
            details);

          #endregion

          #region Insert rate entries

          var rateEntriesProp = brs.GetProperty("RateEntries");
          var rateEntriesList = rateEntriesProp.GetValue(brs, null) as IList;

          string columns;
          string insertValues;
          var entryIndex = 0;
          List<PropertyInfo> rateEntryProperties;

          if (rateEntriesList != null && rateEntriesList.Count > 0)
          {
            var sortedEntries = new SortedList<int, object>();

            foreach (RateEntry entry in rateEntriesList)
            {
              sortedEntries.Add(entry.Index, entry);
            }

            string queryBatch = "Begin\n";
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (
                IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_RATE_PCWS__")
                )
              {

                rateEntryProperties = ((BaseObject) rateEntriesList[0]).GetMTProperties();
                foreach (object rateEntry in sortedEntries.Values)
                {
                  columns = "";
                  insertValues = "";

                  foreach (PropertyInfo rateEntryProp in rateEntryProperties)
                  {
                    object[] rateEntryAttribs = rateEntryProp.GetCustomAttributes(
                      typeof (MTRateEntryMetadataAttribute), false);
                    if (rateEntryAttribs.Length > 0)
                    {
                      object value = rateEntryProp.GetValue(rateEntry, null);
                      string valueForDB = Domain.DataAccess.DatabaseUtils.FormatValueForDB(value);

                      object[] deAttribs = rateEntryProp.GetCustomAttributes(typeof (MTDataMemberAttribute), false);

                      if (deAttribs.HasValue() &&
                          ((MTDataMemberAttribute) deAttribs[0]).IsRequired &&
                          (valueForDB == null || valueForDB.Equals("NULL", StringComparison.OrdinalIgnoreCase)))
                      {
                        logger.LogError(string.Format("Requied Field  - {0} - not set in rate entry object",
                                                      ((MTRateEntryMetadataAttribute) rateEntryAttribs[0]).ColumnName));
                        throw new MASBasicException(string.Format(
                          "Requied Field  - {0} - not set in rate entry object",
                          ((MTRateEntryMetadataAttribute) rateEntryAttribs[0]).ColumnName));
                      }
                      columns += string.Format("c_{0}, ",
                                               ((MTRateEntryMetadataAttribute) rateEntryAttribs[0]).ColumnName);


                      insertValues += string.Format("{0}, ", Domain.DataAccess.DatabaseUtils.FormatValueForDB(value));
                    }
                  }

                  adapterStmt.AddParam("%%TABLE_NAME%%", paramTableTableName);
                  adapterStmt.AddParam("%%ID_SCHED%%", brs.ID.GetValueOrDefault());
                  adapterStmt.AddParam("%%TT_START%%", startDt, true);
                  adapterStmt.AddParam("%%TT_END%%", endDt, true);
                  adapterStmt.AddParam("%%ID_AUDIT%%", auditID);
                  adapterStmt.AddParam("%%COLUMNS%%", columns.Remove(columns.LastIndexOf(',')), true);

                  adapterStmt.AddParam("%%ORDER%%", entryIndex++);
                  adapterStmt.AddParam("%%VALUES%%", insertValues.Remove(insertValues.LastIndexOf(',')), true);

                  queryBatch += string.Format("{0};\n", adapterStmt.Query);

                  adapterStmt.ClearQuery();
                }
              }
            }

            queryBatch += "\nEnd;";

            try
            {
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTStatement stmt = conn.CreateStatement(queryBatch))
                {
                  stmt.ExecuteNonQuery();
                }
              }
            }
            catch (Exception e)
            {
              logger.LogException("Error inserting rate entries", e);
              throw new MASBasicException("Error inserting rate entries");
            }
          }

          #endregion

          #region Insert Default Rate Entry

          columns = "";
          insertValues = "";

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (var adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_RATE_PCWS__"))
            {

              var defaultRateEntryProp = brs.GetProperty("DefaultRateEntry");
              var defaultRateEntry = defaultRateEntryProp.GetValue(brs, null);

              if (defaultRateEntry != null)
              {
                rateEntryProperties = ((BaseObject) defaultRateEntry).GetMTProperties();
                foreach (var rateEntryProp in rateEntryProperties)
                {
                  object[] rateEntryAttribs = rateEntryProp.GetCustomAttributes(typeof (MTRateEntryMetadataAttribute),
                                                                                false);

                  if (rateEntryAttribs.Length > 0)
                  {
                    columns += string.Format("c_{0}, ", ((MTRateEntryMetadataAttribute) rateEntryAttribs[0]).ColumnName);

                    var value = rateEntryProp.GetValue(defaultRateEntry, null);
                    insertValues += string.Format("{0}, ", Domain.DataAccess.DatabaseUtils.FormatValueForDB(value));
                  }
                }

                adapterStmt.AddParam("%%TABLE_NAME%%", paramTableTableName);
                adapterStmt.AddParam("%%ID_SCHED%%", brs.ID.GetValueOrDefault());
                adapterStmt.AddParam("%%TT_START%%", startDt, true);
                adapterStmt.AddParam("%%TT_END%%", endDt, true);
                adapterStmt.AddParam("%%ID_AUDIT%%", auditID);
                adapterStmt.AddParam("%%COLUMNS%%", columns.Remove(columns.LastIndexOf(',')), true);

                adapterStmt.AddParam("%%ORDER%%", entryIndex);
                adapterStmt.AddParam("%%VALUES%%", insertValues.Remove(insertValues.LastIndexOf(',')), true);

                try
                {
                  adapterStmt.ExecuteNonQuery();
                }
                catch (Exception e)
                {
                  logger.LogException("Error inserting default rate entry", e);
                  throw new MASBasicException("Error inserting default rate entry");
                }
              }
            }
          }

          #endregion

        }

        #region Delete any existing RateSchedules not in submitted collection

        foreach (int rsID in existingSchedules.Keys)
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("DeleteRateSchedule"))
            {
              stmt.AddParam("schedId", MTParameterType.Integer, rsID);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              stmt.ExecuteNonQuery();
            }
          }

          details = string.Format("Rate Schedule Id: {0}", rsID);
          AuditManager.FireEvent(
            (int) AuditManager.MTAuditEvents.AUDITEVENT_RS_DELETE,
            sessionContext.AccountID,
            (int) AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
            -1,
            details);
        }

        #endregion
      }
      else
      {
        #region Delete all RateSchedules on pricelist for parameter table

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("DeleteRateSchedules"))
          {
            callableStmt.AddParam("plId", MTParameterType.Integer, pricelistId);
            callableStmt.AddParam("piTemp", MTParameterType.Integer, templateId);
            callableStmt.AddParam("ptId", MTParameterType.Integer, paramTableId);
            callableStmt.AddOutputParam("status", MTParameterType.Integer);
            callableStmt.ExecuteNonQuery();
          }
        }

        #endregion
      }
    }
  }
}
