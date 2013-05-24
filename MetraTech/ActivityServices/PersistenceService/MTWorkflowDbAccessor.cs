using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Workflow.Runtime;
using System.Workflow.Runtime.Hosting;

using MetraTech;
using MetraTech.DataAccess;
using QueryAdapter = MetraTech.Interop.QueryAdapter;
using System.Transactions;

namespace MetraTech.ActivityServices.PersistenceService
{
    internal class MTWorkflowDbAccessor : IDisposable
    {
        private Logger m_Logger = new Logger("[MTWorkflowDBAccessor]");

        /// <summary>
        /// 
        /// </summary>
        public MTWorkflowDbAccessor()
        {
        }

        ~MTWorkflowDbAccessor()
        {
            Dispose();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="item"></param>
        /// <param name="trans"></param>
        /// <param name="ownerId"></param>
        /// <param name="ownedUntil"></param>
        public void InsertInstanceState(PendingWorkItem item, Transaction trans, Guid ownerId, DateTime ownedUntil)
        {
            m_Logger.LogDebug("InsertInstanceState: {0}", item.InstanceId.ToString());

            using (TransactionScope scope = new TransactionScope(trans))
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WorkflowInsertInstanceState"))
                    {

                        callStmt.AddParam("id_instance", MTParameterType.String, item.InstanceId.ToString());
                        callStmt.AddParam("state", MTParameterType.Blob, item.SerializedActivity);
                        callStmt.AddParam("n_status", MTParameterType.Integer, item.Status);
                      callStmt.AddParam("n_unlocked", MTParameterType.Integer, (item.Unlocked ? 1 : 0));
                        callStmt.AddParam("n_blocked", MTParameterType.Integer, item.Blocked);
                        callStmt.AddParam("tx_info", MTParameterType.String, item.Info);

                        //ServiceInstanceId
                        if (ownerId == Guid.Empty)
                        {
                            callStmt.AddParam("id_owner", MTParameterType.String, null);
                        }
                        else
                        {
                            callStmt.AddParam("id_owner", MTParameterType.String, ownerId.ToString());
                        }

                        //Config OwnerShip Timeout.
                        if (ownedUntil == DateTime.MaxValue)
                        {
                            callStmt.AddParam("dt_ownedUntil", MTParameterType.DateTime, MetraTime.Max);
                        }
                        else
                        {
                            callStmt.AddParam("dt_ownedUntil", MTParameterType.DateTime, ownedUntil);
                        }

                        if (item.NextTimer != DateTime.MaxValue)
                        {
                            callStmt.AddParam("dt_nextTimer", MTParameterType.DateTime, item.NextTimer);
                        }
                        else
                        {
                            callStmt.AddParam("dt_nextTimer", MTParameterType.DateTime, MetraTime.Max);
                        }

                        callStmt.AddOutputParam("result", MTParameterType.Integer);
                        callStmt.AddOutputParam("currentOwnerId", MTParameterType.String, 36);

                        callStmt.ExecuteNonQuery();

                        CheckOwnershipResult(callStmt);
                    }
                }

                scope.Complete();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="callStmt"></param>
        private void CheckOwnershipResult(IMTCallableStatement callStmt)
        {
            try
            {

                int result = Int32.Parse(callStmt.GetOutputValue("result").ToString());

                if (result == -2)
                {
                    Guid currentOwnerId = new Guid(callStmt.GetOutputValue("currentOwnerId").ToString());

                    if (currentOwnerId == Guid.Empty)
                        throw new WorkflowOwnershipException(WorkflowEnvironment.WorkflowInstanceId);
                }
            }
            catch (Exception E)
            {
                m_Logger.LogException("Exception in CheckOwnershipResult", E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        internal IEnumerable<IDbPersistenceWorkflowInstanceDescription> RetrieveAllInstanceDescriptions()
        {
            try
            {
                List<IDbPersistenceWorkflowInstanceDescription> instanceDescriptions = null;
         
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WFRetAllInstanceDescriptions"))
                    {

                        using (IMTDataReader reader = callStmt.ExecuteReader())
                        {
                            instanceDescriptions = new List<IDbPersistenceWorkflowInstanceDescription>();
                            while (reader.Read())
                            {
                                instanceDescriptions.Add(new MTDbPersistenceWorkflowInstanceDescription(
                                                             new Guid(reader.GetString("id_instance")),
                                                             reader.GetString("tx_info"),
                                                             (WorkflowStatus)reader.GetInt32("n_status"),
                                                             reader.GetDateTime("dt_nextTimer"),
                                                             reader.GetBoolean("n_blocked")
                                                             ));
                            }
                        }
                    }
                }
                return instanceDescriptions;
            }
            catch (Exception E)
            {
                m_Logger.LogException("Exception in RetrieveAllInstanceDescriptions", E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="instanceId"></param>
        /// <param name="ownerId"></param>
        /// <param name="timeout"></param>
        /// <returns></returns>
        public byte[] RetrieveInstanceState(Guid instanceId, Guid ownerId, DateTime timeout)
        {
            try
            {
                byte[] guidBuffer = default(byte[]);
                int result;

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WorkflowRetrieveInstanceState"))
                    {

                        callStmt.AddParam("id_instance", MTParameterType.String, instanceId.ToString());

                        if (ownerId == Guid.Empty)
                            callStmt.AddParam("id_owner", MTParameterType.String, null);
                        else
                            callStmt.AddParam("id_owner", MTParameterType.String, ownerId.ToString());

                        //Config OwnerShip Timeout.
                        if (timeout == DateTime.MaxValue)
                        {
                            callStmt.AddParam("dt_ownedUntil", MTParameterType.DateTime, MetraTime.Max);
                        }
                        else
                        {
                            callStmt.AddParam("dt_ownedUntil", MTParameterType.DateTime, timeout);
                        }

                        callStmt.AddOutputParam("result", MTParameterType.Integer);
                        callStmt.AddOutputParam("currentOwnerId", MTParameterType.String, 36);

                        using (IMTDataReader reader = callStmt.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                guidBuffer = reader.GetBytes("state");
                            }
                            else
                            {
                                result = reader.GetInt32("result");
                                if (result > 0)
                                    throw new RetrieveStateFromDBException(
                                        string.Format("RetrieveStateFromDB Failed to read results {1}, @result == {0}",
                                                      new object[] { result, instanceId }));
                            }
                        }
                    }
                }

                return guidBuffer;
            }
            catch (Exception E)
            {
                m_Logger.LogException(string.Format("Exception in RetrieveInstanceState for instance {0}", instanceId.ToString()), E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="scopeId"></param>
        /// <returns></returns>
        public byte[] RetrieveCompletedScope(Guid scopeId)
        {
            m_Logger.LogDebug("RetrieveCompletedScope" + scopeId.ToString());

            try
            {
                byte[] guidBuffer = null;
                int result;

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WorkflowRetrieveCompletedScope"))
                    {

                        callStmt.AddParam("id_completedScope", MTParameterType.String, scopeId.ToString());

                        callStmt.AddOutputParam("result", MTParameterType.Integer);

                        using (IMTDataReader reader = callStmt.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                guidBuffer = reader.GetBytes("state");
                            }
                            else
                            {
                                result = reader.GetInt32("result");
                                if (result > 0)
                                    throw new RetrieveStateFromDBException(
                                        string.Format("RetrieveStateFromDB Failed to read results {1}, @result == {0}",
                                                      new object[] { result, WorkflowEnvironment.WorkflowInstanceId }));
                            }
                        }
                    }
                }

                return guidBuffer;
            }
            catch (Exception E)
            {
                m_Logger.LogException(string.Format("Exception in RetrieveCompletedScope for scopeId {0}", scopeId.ToString()), E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="instanceId"></param>
        /// <param name="trans"></param>
        /// <param name="ownerId"></param>
        public void ActivationComplete(Guid instanceId, Transaction trans, Guid ownerId)
        {
            m_Logger.LogDebug("ActivationComplete" + instanceId.ToString());

            try
            {
                using (TransactionScope scope = new TransactionScope(trans))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WorkflowUnlockInstanceState"))
                        {
                            callStmt.AddParam("id_instance", MTParameterType.String, instanceId.ToString());
                            callStmt.AddParam("id_owner", MTParameterType.String, ownerId.ToString());

                            callStmt.ExecuteNonQuery();
                        }
                    }
                    scope.Complete();
                }
            }
            catch (Exception E)
            {
                m_Logger.LogException(string.Format("Exception in ActivationComplete for instance {0}", instanceId.ToString()), E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="instanceId"></param>
        /// <param name="trans"></param>
        /// <param name="scopeId"></param>
        /// <param name="state"></param>
        public void InsertCompletedScope(Guid instanceId, Transaction trans, Guid scopeId, byte[] state)
        {
            m_Logger.LogDebug("InsertCompletedScope" + instanceId.ToString());

            try
            {
                using (TransactionScope scope = new TransactionScope(trans))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WorkflowInsertCompletedScope"))
                        {

                            callStmt.AddParam("id_instance", MTParameterType.String, instanceId.ToString());
                            callStmt.AddParam("id_completedScope", MTParameterType.String, scopeId.ToString());
                            callStmt.AddParam("state", MTParameterType.Blob, state);

                            callStmt.ExecuteNonQuery();
                        }
                    }
                    scope.Complete();
                }
            }
            catch (Exception E)
            {
                m_Logger.LogException(string.Format("Exception in InsertCompletedScope for instance {0}", instanceId.ToString()), E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ownerId"></param>
        /// <param name="ownedUntil"></param>
        /// <returns></returns>
        public IList<Guid> RetrieveExpiredTimerIds(Guid ownerId, DateTime ownedUntil)
        {
            m_Logger.LogDebug("RetrieveExpiredTimerIds" + ownerId.ToString());

            try
            {
                IList<Guid> expired = new List<Guid>();

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WFRetrieveExpiredTimerIds"))
                    {

                        callStmt.AddParam("id_owner", MTParameterType.String, ownerId.ToString());
                        callStmt.AddParam("dt_ownedUntil", MTParameterType.DateTime, ownedUntil);
                        callStmt.AddParam("now", MTParameterType.DateTime, DateTime.UtcNow);

                        using (IMTDataReader reader = callStmt.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                expired.Add(new Guid(reader.GetString("id_instance")));
                            }
                        }
                    }
                }

                return expired;
            }
            catch (Exception E)
            {
                m_Logger.LogException("Exception in RetrieveExpiredTimerIds", E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ownerId"></param>
        /// <param name="ownedUntil"></param>
        /// <returns></returns>
        public IList<Guid> RetrieveNonblockingInstanceStateIds(Guid ownerId, DateTime ownedUntil)
        {
            m_Logger.LogDebug("RetrieveNonblockingInstanceStateIds" + ownerId.ToString());

            try
            {
                IList<Guid> expired = new List<Guid>();

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WFRetNonblockInstanceStateIds"))
                    {

                        callStmt.AddParam("id_owner", MTParameterType.String, ownerId.ToString());
                        callStmt.AddParam("dt_ownedUntil", MTParameterType.DateTime, ownedUntil);
                        callStmt.AddParam("now", MTParameterType.DateTime, DateTime.UtcNow);

                        using (IMTDataReader reader = callStmt.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                expired.Add(new Guid(reader.GetString("id_instance")));
                            }
                        }
                    }
                }

                return expired;
            }
            catch (Exception E)
            {
                m_Logger.LogException("Exception in RetrieveNonBlockingInstanceStateIds", E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ownerId"></param>
        /// <param name="ownedUntil"></param>
        /// <param name="instanceId"></param>
        /// <returns></returns>
        public bool TryRetrieveANonblockingInstanceStateId(Guid ownerId, DateTime ownedUntil, out Guid instanceId)
        {
            m_Logger.LogDebug("TryRetrieveANonblockingInstanceStateId" + ownerId.ToString());

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callStmt = conn.CreateCallableStatement("WFRetNonblockInstanceStateId"))
                    {

                        callStmt.AddParam("id_owner", MTParameterType.String, ownerId.ToString());
                        callStmt.AddParam("dt_ownedUntil", MTParameterType.DateTime, ownedUntil);

                        callStmt.AddOutputParam("id_instance", MTParameterType.String, 36);
                        callStmt.AddOutputParam("found", MTParameterType.Integer);

                        callStmt.ExecuteNonQuery();

                        int found = Int32.Parse(callStmt.GetOutputValue("found").ToString());

                        if (found == 1)
                        {
                            instanceId = new Guid(((string)callStmt.GetOutputValue("id_instance")));
                            return true;
                        }

                        instanceId = default(Guid);
                    }
                }

                return false;
            }
            catch (Exception E)
            {
                m_Logger.LogException("Exception in TryRetrieveANonBlockingInstanceStateid", E);
                throw E;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public void Dispose()
        {
            GC.SuppressFinalize(this);
        }
    }
}