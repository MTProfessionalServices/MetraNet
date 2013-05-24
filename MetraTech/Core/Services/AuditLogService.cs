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
using MetraTech.Interop.MTAuditEvents;
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
    public interface IAuditLogService
    {
        /// <summary>
        /// Insert an audit log entry into the DB.
        /// </summary>
        /// <param name="userId">ID of the user performing the insertion</param>
        /// <param name="auditEventTypeId">ID that defines the type of event being inserted</param>
        /// <param name="entityId">ID that the audit event applies to</param>
        /// <param name="entityType">Entity type that the audit event applies to</param>
        /// <param name="auditDetail">free form string that describes the audit event</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void InsertAuditLogEntry(int userId, int auditEventTypeId, int entityId, int entityType, string auditDetail);

        /// <summary>
        /// Retrieve the audit log entries associated with the specified entityId
        /// </summary>
        /// <param name="entityId">ID that determines which audit log entries will be retrieved</param>
        /// <param name="auditLogEntries">List containing the audit log entries for the specified entityId</param>
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void RetrieveAuditLogEntriesForEntity(int entityId, ref MTList<AuditLogEntry> auditLogEntries);

    }

    [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
    public class AuditLogService : CMASServiceBase, IAuditLogService
    {
        private Logger m_Logger = new Logger("[AuditLogService]");

        // Directory where AuditLog related queries exist
        private const string AUDIT_LOG_QUERY_DIR = "queries\\Audit";

        public void InsertAuditLogEntry(int userId, int auditEventTypeId, int entityId, int entityType, string auditDetail)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("InsertAuditLogEntry"))
            {
                m_Logger.LogDebug("InsertAuditLogEntry");
                try
                {
                    Auditor auditor = new Auditor();
                    auditor.FireEvent(auditEventTypeId, userId, entityType, entityId, auditDetail);
                }
                catch (Exception e)
                {
                    m_Logger.LogException("InsertAuditLogEntry failed", e);
                    throw new MASBasicException("InsertAuditLogEntry failed. " + e.Message);
                }
            }
        }

        public void RetrieveAuditLogEntriesForEntity(int entityId, ref MTList<AuditLogEntry> auditLogEntries)
        {
          using (HighResolutionTimer timer = new HighResolutionTimer("RetrieveAuditLogEntriesForEntity"))
          {
            m_Logger.LogDebug("RetrieveAuditLogEntriesForEntity");

            IMTConnection conn = null;
            MTComSmartPtr<IMTQueryAdapter> queryAdapter = null;
            IMTPreparedFilterSortStatement stmt = null;
            IMTDataReader rdr = null;

            try
            {
              conn = ConnectionManager.CreateConnection(AUDIT_LOG_QUERY_DIR, true);
              queryAdapter = new MTComSmartPtr<IMTQueryAdapter>();

              queryAdapter.Item = new MTQueryAdapterClass();
              queryAdapter.Item.Init(AUDIT_LOG_QUERY_DIR);
              queryAdapter.Item.SetQueryTag("__GET_AUDIT_LOG_FOR_ENTITY__");

              stmt = conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true));
              stmt.AddParam("entityId", MTParameterType.Integer, entityId);

              ApplyFilterSortCriteria<AuditLogEntry>(stmt, auditLogEntries,
                new FilterColumnResolver(AuditLogEntryDomainModelMemberNameToColumnName), null);

              rdr = stmt.ExecuteReader();
              while (rdr.Read())
              {
                AuditLogEntry auditLogEntry = new AuditLogEntry();

                ReadAndPopulateAuditLogEntry(rdr, ref auditLogEntry);

                auditLogEntries.Items.Add(auditLogEntry);
              }
              auditLogEntries.TotalRows = stmt.TotalRows;
            }
            catch (Exception e)
            {
              auditLogEntries.Items.Clear();
              m_Logger.LogException("RetrieveAuditLogEntriesForEntity" +
                  " failed", e);
              throw new MASBasicException("RetrieveAuditLogEntriesForEntity" +
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

        /// <summary>
        /// "rdr" is pointed at a row in vw_audit_log.  This method extracts the info in that row into
        /// the domain model AuditLogEntry object.
        /// </summary>
        /// <param name="rdr">Permits reading from a row within vw_audit_log</param>
        /// <param name="auditLogEntry">After this method is invoked, this parameter contains a filled AuditLogEntry</param>
        private void ReadAndPopulateAuditLogEntry(IMTDataReader rdr, ref AuditLogEntry auditLogEntry)
        {
          if (!rdr.IsDBNull("dt_crt"))
          {
            auditLogEntry.OccurrenceDate = rdr.GetDateTime("dt_crt");
          }
          else
          {
            throw new MASBasicException(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for dt_crt");
          }

          if (!rdr.IsDBNull("UserName"))
          {
            auditLogEntry.UserName = rdr.GetString("UserName");
          }
          else
          {
            m_Logger.LogDebug(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for UserName");
            auditLogEntry.UserName = null;
          }

          if (!rdr.IsDBNull("UserId"))
          {
            auditLogEntry.UserId = rdr.GetInt32("UserId");
          }
          else
          {
            throw new MASBasicException(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for UserId");
          }

          if (!rdr.IsDBNull("EventId"))
          {
            auditLogEntry.AuditEventTypeId = rdr.GetInt32("EventId");
          }
          else
          {
            throw new MASBasicException(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for EventId");
          }

          if (!rdr.IsDBNull("EventName"))
          {
            auditLogEntry.AuditEventType = rdr.GetString("EventName");
          }
          else
          {
            m_Logger.LogDebug(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for EventName");
            auditLogEntry.AuditEventType = "";
          }

          if (!rdr.IsDBNull("EntityName"))
          {
            auditLogEntry.EntityName = rdr.GetString("EntityName");
          }
          else
          {
            m_Logger.LogDebug(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for EntityName");
            auditLogEntry.EntityName = "";
          }

          if (!rdr.IsDBNull("EntityId"))
          {
            auditLogEntry.EntityId = rdr.GetInt32("EntityId");
          }
          else
          {
            throw new MASBasicException(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for EntityId");
          }

          if (!rdr.IsDBNull("EntityType"))
          {
            auditLogEntry.EntityType = rdr.GetInt32("EntityType");
          }
          else
          {
            throw new MASBasicException(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for EntityType");
          }

          if (!rdr.IsDBNull("Details"))
          {
            auditLogEntry.AuditDetail = rdr.GetString("Details");
          }
          else
          {
            m_Logger.LogDebug(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for Details");
            auditLogEntry.AuditDetail = "";
          }

          if (!rdr.IsDBNull("LoggedInAs"))
          {
            auditLogEntry.LoggedInAs = rdr.GetString("LoggedInAs");
          }
          else
          {
            m_Logger.LogDebug(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for LoggedInAs");
            auditLogEntry.LoggedInAs = "";
          }

          if (!rdr.IsDBNull("ApplicationName"))
          {
            auditLogEntry.ApplicationName = rdr.GetString("ApplicationName");
          }
          else
          {
            m_Logger.LogDebug(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for ApplicationName");
            auditLogEntry.ApplicationName = "";
          }

          if (!rdr.IsDBNull("id_audit"))
          {
            auditLogEntry.AuditId = rdr.GetInt32("id_audit");
          }
          else
          {
            throw new MASBasicException(
                "ReadAndPopulateAuditLogEntry" +
                ": null value for id_audit");
          }
        }

        /// <summary>
        /// This method is involved in the sorting and filtering of a list of AuditLogEntries returned to
        /// clients.  The clients should only be aware of the AuditLogEntry domain model member names.
        /// This method converts the AuditLogEntry domain model member names into the appropriate
        /// database column names.
        /// </summary>
        /// <param name="auditLogEntryDomainModelMemberName">Name of a AuditLogEntry domain model member</param>
        /// <param name="filterVal">unused</param>
        /// <param name="helper">unused</param>
        /// <returns>Column name within the table that holds AuditLogEntries </returns>
        private string AuditLogEntryDomainModelMemberNameToColumnName(string auditLogEntryDomainModelMemberName, ref object filterVal, object helper)
        {
            string columnName = null;

            switch (auditLogEntryDomainModelMemberName)
            {
                case "OccurrenceDate":
                    if (filterVal != null)
                    {
                        columnName = "info.dt_crt";
                    }
                    else
                    {
                        columnName = "dt_crt";
                    }
                    break;

                case "UserName":
                    if (filterVal != null)
                    {
                        columnName = "info.UserName";
                    }
                    else
                    {
                        columnName = "UserName";
                    }
                    break;

                case "UserId":
                    if (filterVal != null)
                    {
                        columnName = "info.UserId";
                    }
                    else
                    {
                        columnName = "UserId";
                    }
                    break;

                case "EventId":
                    if (filterVal != null)
                    {
                        columnName = "info.EventId";
                    }
                    else
                    {
                        columnName = "EventId";
                    }
                    break;

                case "AuditEventType":
                    if (filterVal != null)
                    {
                        columnName = "info.EventName";
                    }
                    else
                    {
                        columnName = "EventName";
                    }
                    break;

                case "EntityName":
                    if (filterVal != null)
                    {
                        columnName = "info.EntityName";
                    }
                    else
                    {
                        columnName = "EntityName";
                    }
                    break;

                case "EntityId":
                    if (filterVal != null)
                    {
                        columnName = "info.EntityId";
                    }
                    else
                    {
                        columnName = "EntityId";
                    }
                    break;

                case "EntityType":
                    if (filterVal != null)
                    {
                        columnName = "info.EntityType";
                    }
                    else
                    {
                        columnName = "EntityType";
                    }
                    break;

                case "AuditDetail":
                    if (filterVal != null)
                    {
                        columnName = "info.Details";
                    }
                    else
                    {
                        columnName = "Details";
                    }
                    break;

                case "LoggedInAs":
                    if (filterVal != null)
                    {
                        columnName = "info.LoggedInAs";
                    }
                    else
                    {
                        columnName = "LoggedInAs";
                    }
                    break;

                case "ApplicationName":
                    if (filterVal != null)
                    {
                        columnName = "info.ApplicationName";
                    }
                    else
                    {
                        columnName = "ApplicationName";
                    }
                    break;

                case "AuditId":
                    if (filterVal != null)
                    {
                        columnName = "info.id_audit";
                    }
                    else
                    {
                        columnName = "id_audit";
                    }
                    break;

                default:
                    throw new MASBasicException(
                        "AuditLogEntryDomainModelMemberNameToColumnName: attempt to sort on invalid field " + auditLogEntryDomainModelMemberName);
                    break;
            }

            return columnName;
        }

    }
}
