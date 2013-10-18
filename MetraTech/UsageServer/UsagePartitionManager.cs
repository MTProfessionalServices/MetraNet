
namespace MetraTech.UsageServer
{
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using System.Data.SqlClient;
    using MetraTech;
    using DataAccess;

    /// <summary>
    /// UsagePartitionManager (UPM) - Manages creation of usage partitions.
    /// </summary>
    [ComVisible(false)] // Not yet.
    public class UsagePartitionManager
    {
        // Names of stored procedures for creation partition schema and applying it on tables
        public const string CreateTaxPartitionsSp = "prtn_create_tax_partitions";
        public const string CreateUsagePartitionsSp = "prtn_create_usage_partitions";
        public const string CreateMeterPartitionsSp = "prtn_create_meter_partitions";
        public const string DeployAllUsagePartitionedTablesSp = "prtn_deploy_all_usage_tables";
        public const string DeployAllMeterPartitionedTablesSp = "prtn_deploy_all_meter_tables";

        private readonly ILogger _logger;
        private readonly IPartitionConfig _partitionConfig;
        private readonly CreateConnectionDelegate _createConnectionDelegate;

        public delegate IMTConnection CreateConnectionDelegate();

        #region Constructors

        /// <summary>
        /// Constructor with default initialization
        /// </summary>
        public UsagePartitionManager()
            : this(ConnectionManager.CreateConnection, new PartitionConfig(), new Logger("[PartitionMgr]"))
        {
        }

        public UsagePartitionManager(CreateConnectionDelegate createConnDelegate, IPartitionConfig partitionConfig,
                                     ILogger logger)
        {
            _logger = logger;
            _partitionConfig = partitionConfig;
            _createConnectionDelegate = createConnDelegate;
        }

        #endregion

        /// <summary>
        /// Synchronizes the database partition settings in the usageserver.xml file
        /// </summary>
        public void Synchronize()
        {
            _partitionConfig.Synchronize();
        }

        /// <summary>
        /// Calls the stored procedure that creates partitions databases based 
        /// on current active and unassiged intervals.
        /// </summary>
        public void CreateUsagePartitions()
        {
            using (var conn = _createConnectionDelegate())
            {
                if (_partitionConfig.IsPartitionEnabled)
                {
                    CreateUsagePartition(conn);
                    CreateMeterPartition(conn);
                }

                // either partition or non-partition 't_tax_details' will be created
                CreateTaxDetailPartitions(conn);
            }
        }

        /// <summary>
        /// Calls the stored procedure that depolys partitioned tables to 
        /// parition databases.
        /// </summary>
        public void DeployAllPartitionedTables()
        {
            if (_partitionConfig.IsPartitionEnabled)
            {
                using (var conn = _createConnectionDelegate())
                {
                    DeployAllUsagePartitonedTables(conn);
                    DeployAllMeterPartitonedTables(conn);
                }
            }
        }

        #region Private Methods

        private void CreateTaxDetailPartitions(IMTConnection conn)
        {
            LogInfo("Creating tax detail partitions...");
            try
            {
                using (var stmt = conn.CreateCallableStatement(CreateTaxPartitionsSp))
                {
                    stmt.ExecuteNonQuery();
                }
            }
            catch (SqlException e)
            {
                throw new UsageServerException("Could not create all tax detail partitions.", e);
            }
        }

        private void CreateUsagePartition(IMTConnection conn)
        {
            try
            {
                var pl = new List<PartitionInfo>();
                LogInfo("Creating usage partitions...");

                using (var stmt = conn.CreateCallableStatement(CreateUsagePartitionsSp))
                {
                    using (var rdr = stmt.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var pi = new PartitionInfo
                                {
                                    Name = rdr.GetString("partition_name"),
                                    StartDate = rdr.GetDateTime("dt_start"),
                                    EndDate = rdr.GetDateTime("dt_end"),
                                    IntervalStart = rdr.GetInt32("interval_start"),
                                    IntervalEnd = rdr.GetInt32("interval_end")
                                };
                            _logger.LogDebug("pi.Name={0}, pi.StartDate={1}, pi.EndDate={2}, pi.IntervalStart={3}",
                                             pi.Name, pi.StartDate, pi.EndDate, pi.IntervalStart);

                            pl.Add(pi);
                        }
                    }
                }

                ShowPartitionInfo(pl);
            }
            catch (SqlException e)
            {
                throw new UsageServerException("Could not create all usage partitions.", e);
            }
        }

        private void CreateMeterPartition(IMTConnection conn)
        {
            LogInfo("Creating meter partitions...");
            try
            {
                using (var stmt = conn.CreateCallableStatement(CreateMeterPartitionsSp))
                {
                    stmt.ExecuteNonQuery();
                }
            }
            catch (SqlException e)
            {
                throw new UsageServerException("Could not create all meter partitions.", e);
            }
        }

        private void DeployAllUsagePartitonedTables(IMTConnection conn)
        {
            LogInfo("Deploying usage partitioned tables...");
            try
            {
                using (var stmt = conn.CreateCallableStatement(DeployAllUsagePartitionedTablesSp))
                {
                    stmt.ExecuteNonQuery();
                }
            }
            catch (SqlException e)
            {
                throw new UsageServerException("Could not deploy all usage partitioned tables.", e);
            }
        }

        private void DeployAllMeterPartitonedTables(IMTConnection conn)
        {
            LogInfo("Deploying meter partitioned tables...");
            try
            {
                using (var stmt = conn.CreateCallableStatement(DeployAllMeterPartitionedTablesSp))
                {
                    stmt.ExecuteNonQuery();
                }
            }
            catch (SqlException e)
            {
                throw new UsageServerException("Could not deploy all meter partitioned tables.", e);
            }
        }

        private void LogInfo(string msg)
        {
            _logger.LogInfo(msg);
            Console.WriteLine(msg);
        }

        /// <summary>
        /// Displays partition info on the console.
        /// </summary>
        /// <param name="pl"></param>
        private void ShowPartitionInfo(ICollection<PartitionInfo> pl)
        {
            _logger.LogInfo("{0} partitions were created.", pl.Count);

            if (pl.Count < 1)
                return;

            const string dateFormat = "MM/dd/yyyy";
            _logger.LogInfo(" Partition Name         Start Date   End Date  Interval Start   Interval End");
            _logger.LogInfo(" --------------------|------------|----------|---------------|--------------");

            foreach (PartitionInfo pi in pl)
            {
                _logger.LogInfo(" {0,-20} {1,11} {2,11} {3,15} {4,14}", pi.Name,
                                pi.StartDate.ToString(dateFormat), pi.EndDate.ToString(dateFormat),
                                pi.IntervalStart, pi.IntervalEnd);
            }
            _logger.LogInfo(" The default partition was adjusted to account for new regular partitions.");
        }

        #endregion
    }
}
