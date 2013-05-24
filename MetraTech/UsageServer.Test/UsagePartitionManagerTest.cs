using System;
using MetraTech.DataAccess;
using FakeItEasy;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.TestCommon;

namespace MetraTech.UsageServer.Test
{
    [TestClass]
    public class UsagePartitionManagerTest
    {
        private IPartitionConfig _fakePartitionConfig;
        private ILogger _fakeLogger;
        private IMTConnection _fakeConnection;

        /// <summary>
        /// Initialize Fake objects, that will be used in each test:
        /// IMTConnection, ILogger, IPartitionConfig
        /// </summary>
        [TestInitialize]
        public void TestInit()
        {
            _fakePartitionConfig = A.Fake<IPartitionConfig>();
            _fakeLogger = A.Fake<ILogger>();
            _fakeConnection = A.Fake<IMTConnection>();
        }
        
        #region CreateUsagePartitions method

        /// <summary>
        /// When partition is enabled CreateUsagePartitions suggests to call 3 stored procedures,
        /// that create Partition Infrastructure for Usage (t_acc_usage, t_pv_*), Tax (t_tax_details) and Meter (t_svc_* and 4 default tables) tables.
        /// </summary>
        [TestMethod, MTUnitTest]
        public void CreateUsagePartitions_PartitionEnabled_AllCreatePartitionSpWasCalled()
        {

            #region GIVEN

            const int numberOfPartitions = 10;

            // Output parameters of CreateUsagePartitions stored procedure
            const string partitionNameParam = "partition_name";
            const string dtStartParam = "dt_start";
            const string dEndParam = "dt_end";
            const string intervalStartParam = "interval_start";
            const string intervalEndParam = "interval_end";

            var fakeUsageCallableStatement = A.Fake<IMTCallableStatement>();
            var fakeTaxCallableStatement = A.Fake<IMTCallableStatement>();
            var fakeMeterCallableStatement = A.Fake<IMTCallableStatement>();
            var fakeUsageDataReader = A.Fake<IMTDataReader>();

            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(true);

            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateUsagePartitionSchemaSp))
             .Returns(fakeUsageCallableStatement);
            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateTaxPartitionSchemaSp))
             .Returns(fakeTaxCallableStatement);
            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateMeterPartitionSchemaSp))
             .Returns(fakeMeterCallableStatement);

            A.CallTo(() => fakeUsageCallableStatement.ExecuteReader()).Returns(fakeUsageDataReader);
            A.CallTo(() => fakeUsageDataReader.Read()).Returns(false);
            A.CallTo(() => fakeUsageDataReader.Read()).Returns(true).NumberOfTimes(numberOfPartitions);

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            partitionManager.CreateUsagePartitions();

            #endregion

            #region THEN

            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateUsagePartitionSchemaSp))
             .MustHaveHappened();
            A.CallTo(() => fakeUsageCallableStatement.ExecuteReader()).MustHaveHappened();
            A.CallTo(() => fakeUsageDataReader.GetString(partitionNameParam))
             .MustHaveHappened(Repeated.Exactly.Times(numberOfPartitions));
            A.CallTo(() => fakeUsageDataReader.GetDateTime(dtStartParam))
             .MustHaveHappened(Repeated.Exactly.Times(numberOfPartitions));
            A.CallTo(() => fakeUsageDataReader.GetDateTime(dEndParam))
             .MustHaveHappened(Repeated.Exactly.Times(numberOfPartitions));
            A.CallTo(() => fakeUsageDataReader.GetInt32(intervalStartParam))
             .MustHaveHappened(Repeated.Exactly.Times(numberOfPartitions));
            A.CallTo(() => fakeUsageDataReader.GetInt32(intervalEndParam))
             .MustHaveHappened(Repeated.Exactly.Times(numberOfPartitions));
            A.CallTo(() => fakeUsageDataReader.Dispose()).MustHaveHappened();
            A.CallTo(() => fakeUsageCallableStatement.Dispose()).MustHaveHappened();

            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateTaxPartitionSchemaSp))
             .MustHaveHappened();
            A.CallTo(() => fakeTaxCallableStatement.ExecuteNonQuery()).MustHaveHappened();
            A.CallTo(() => fakeTaxCallableStatement.Dispose()).MustHaveHappened();

            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateMeterPartitionSchemaSp))
             .MustHaveHappened();
            A.CallTo(() => fakeMeterCallableStatement.AddParam("current_dt", MTParameterType.DateTime, A<DateTime>._))
             .MustHaveHappened();
            A.CallTo(() => fakeMeterCallableStatement.ExecuteNonQuery()).MustHaveHappened();
            A.CallTo(() => fakeMeterCallableStatement.Dispose()).MustHaveHappened();

            A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();

            #endregion

        }

        /// <summary>
        /// When partition is disabled CreateUsagePartitions suggests to call only CreateTaxDetailPartitions SP.
        /// Non-partitioned t_tax_details will be created.
        /// </summary>
        [TestMethod, MTUnitTest]
        public void CreateUsagePartitions_PartitionDisabled_TaxCreatePartitionsSpWasCalled()
        {

            #region GIVEN

            var fakeCallableStatement = A.Fake<IMTCallableStatement>();

            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(false);
            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateTaxPartitionSchemaSp))
             .Returns(fakeCallableStatement);

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            partitionManager.CreateUsagePartitions();

            #endregion

            #region THEN

            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateTaxPartitionSchemaSp))
             .MustHaveHappened();
            A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).MustHaveHappened();
            A.CallTo(() => _fakeLogger.LogInfo(A<string>._)).MustHaveHappened();

            A.CallTo(() => fakeCallableStatement.Dispose()).MustHaveHappened();
            A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();

            #endregion

        }

        /// <summary>
        /// On calling CreateUsagePartitions SP SqlException occures.
        /// UsageServerException should be thrown.
        /// </summary>
        [TestMethod, MTUnitTest]
        [ExpectedException(typeof (UsageServerException), "UsageServerException didn't occur")]
        public void CreateUsagePartitions_SqlExceptionOnCreateUsagePartitions_UsageServerExceptionThrown()
        {

            #region GIVEN

            var fakeCallableStatement = A.Fake<IMTCallableStatement>();

            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(true);
            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateUsagePartitionSchemaSp))
             .Returns(fakeCallableStatement);
            A.CallTo(() => fakeCallableStatement.ExecuteReader()).Throws(UnitTestHelper.GetSqlException());

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            try
            {
                partitionManager.CreateUsagePartitions();
            }
            catch
            {
                A.CallTo(
                    () => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateUsagePartitionSchemaSp))
                 .MustHaveHappened();
                A.CallTo(() => fakeCallableStatement.ExecuteReader()).MustHaveHappened();

                A.CallTo(() => fakeCallableStatement.Dispose()).MustHaveHappened();
                A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();
                throw;
            }

            #endregion

            #region THEN

            // UsageServerException is expected by attribute

            #endregion

        }

        /// <summary>
        /// On calling prtn_CreateMeterPartitionSchema SP SqlException occures.
        /// UsageServerException should be thrown.
        /// </summary>
        [TestMethod, MTUnitTest]
        [ExpectedException(typeof (UsageServerException), "UsageServerException didn't occur")]
        public void CreateUsagePartitions_SqlExceptionOnCreateMeterPartitionSchema_UsageServerExceptionThrown()
        {

            #region GIVEN

            var fakeCallableStatement = A.Fake<IMTCallableStatement>();

            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(true);
            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateMeterPartitionSchemaSp))
             .Returns(fakeCallableStatement);
            A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).Throws(UnitTestHelper.GetSqlException());

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            try
            {
                partitionManager.CreateUsagePartitions();
            }
            catch
            {
                A.CallTo(
                    () => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateMeterPartitionSchemaSp))
                 .MustHaveHappened();
                A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).MustHaveHappened();

                A.CallTo(() => fakeCallableStatement.Dispose()).MustHaveHappened();
                A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();
                throw;
            }

            #endregion

            #region THEN

            // UsageServerException is expected by attribute

            #endregion

        }

        /// <summary>
        /// On calling CreateTaxDetailPartitions SP SqlException occures.
        /// UsageServerException should be thrown.
        /// </summary>
        [TestMethod, MTUnitTest]
        [ExpectedException(typeof (UsageServerException), "UsageServerException didn't occur")]
        public void CreateUsagePartitions_SqlExceptionOnCreationTaxDetails_UsageServerExceptionThrown()
        {

            #region GIVEN

            var fakeCallableStatement = A.Fake<IMTCallableStatement>();

            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateTaxPartitionSchemaSp))
             .Returns(fakeCallableStatement);
            A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).Throws(UnitTestHelper.GetSqlException());

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            try
            {
                partitionManager.CreateUsagePartitions();
            }
            catch
            {
                A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.CreateTaxPartitionSchemaSp))
                 .MustHaveHappened();
                A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).MustHaveHappened();

                A.CallTo(() => fakeCallableStatement.Dispose()).MustHaveHappened();
                A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();
                throw;
            }

            #endregion

            #region THEN

            // UsageServerException is expected by attribute

            #endregion

        }
        
        #endregion

        #region DeployAllPartitionedTables method
        
        /// <summary>
        /// When partition is enabled DeployAllPartitionedTables suggests to call 2 stored procedures.
        /// It will put under created partition schema Usage (t_acc_usage, t_pv_*) and Meter (t_svc_* and 4 default tables) tables.
        /// </summary>
        [TestMethod, MTUnitTest]
        public void DeployAllPartitionedTables_PartitionEnabled_AllDeployPartitionSpWereCalled()
        {

            #region GIVEN

            var fakeUsageCallableStatement = A.Fake<IMTCallableStatement>();
            var fakeMeterCallableStatement = A.Fake<IMTCallableStatement>();

            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(true);
            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllUsagePartitionedTablesSp))
             .Returns(fakeUsageCallableStatement);
            A.CallTo(() => _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllMeterPartitionedTablesSp))
             .Returns(fakeMeterCallableStatement);

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            partitionManager.DeployAllPartitionedTables();

            #endregion

            #region THEN

            A.CallTo(
                () => _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllUsagePartitionedTablesSp))
             .MustHaveHappened();
            A.CallTo(() => fakeUsageCallableStatement.ExecuteNonQuery()).MustHaveHappened();

            A.CallTo(
                () => _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllMeterPartitionedTablesSp))
             .MustHaveHappened();
            A.CallTo(() => fakeUsageCallableStatement.ExecuteNonQuery()).MustHaveHappened();

            A.CallTo(() => _fakeLogger.LogInfo(A<string>._)).MustHaveHappened();
            A.CallTo(() => fakeUsageCallableStatement.Dispose()).MustHaveHappened();
            A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();

            #endregion

        }
        
        /// <summary>
        /// When partition is disabled DeployAllPartitionedTables should not do anything.
        /// </summary>
        [TestMethod, MTUnitTest]
        public void DeployAllPartitionedTables_PartitionDisabled_NothingHappened()
        {

            #region GIVEN

            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(false);

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            partitionManager.DeployAllPartitionedTables();

            #endregion

            #region THEN

            A.CallTo(() => _fakeConnection.CreateCallableStatement(A<string>._)).MustNotHaveHappened();

            #endregion

        }
        
        /// <summary>
        /// On calling DeployAllPartitionedTables SP SqlException occures.
        /// UsageServerException should be thrown.
        /// </summary>
        [TestMethod, MTUnitTest]
        [ExpectedException(typeof(UsageServerException), "UsageServerException didn't occur")]
        public void DeployAllPartitionedTables_SqlExceptionOnDeployUsagePartitionedTables_UsageServerExceptionThrown()
        {

            #region GIVEN

            var fakeCallableStatement = A.Fake<IMTCallableStatement>();

            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(true);
            A.CallTo(
                () => _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllUsagePartitionedTablesSp))
             .Returns(fakeCallableStatement);
            A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).Throws(UnitTestHelper.GetSqlException());

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            try
            {
                partitionManager.DeployAllPartitionedTables();
            }
            catch
            {
                A.CallTo(
                    () =>
                    _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllUsagePartitionedTablesSp))
                 .MustHaveHappened();
                A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).MustHaveHappened();

                A.CallTo(() => fakeCallableStatement.Dispose()).MustHaveHappened();
                A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();
                throw;
            }

            #endregion

            #region THEN

            // UsageServerException is expected by attribute

            #endregion

        }

        /// <summary>
        /// On calling prtn_DeployAllMeterPartitionedTables SP SqlException occures.
        /// UsageServerException should be thrown.
        /// </summary>
        [TestMethod, MTUnitTest]
        [ExpectedException(typeof(UsageServerException), "UsageServerException didn't occur")]
        public void DeployAllPartitionedTables_SqlExceptionOnDeployMeterPartitionedTables_UsageServerExceptionThrown()
        {

            #region GIVEN

            var fakeCallableStatement = A.Fake<IMTCallableStatement>();
            
            A.CallTo(() => _fakePartitionConfig.IsPartitionEnabled).Returns(true);
            A.CallTo(
                () => _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllMeterPartitionedTablesSp))
             .Returns(fakeCallableStatement);
            A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).Throws(UnitTestHelper.GetSqlException());

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            try
            {
                partitionManager.DeployAllPartitionedTables();
            }
            catch
            {
                A.CallTo(
                    () =>
                    _fakeConnection.CreateCallableStatement(UsagePartitionManager.DeployAllMeterPartitionedTablesSp))
                 .MustHaveHappened();
                A.CallTo(() => fakeCallableStatement.ExecuteNonQuery()).MustHaveHappened();

                A.CallTo(() => fakeCallableStatement.Dispose()).MustHaveHappened();
                A.CallTo(() => _fakeConnection.Dispose()).MustHaveHappened();
                throw;
            }

            #endregion

            #region THEN

            // UsageServerException is expected by attribute

            #endregion

        }
        
        #endregion

        /// <summary>
        /// When calling Synchronize() method, Synchronize() of PartitionConfig class should be called
        /// </summary>
        [TestMethod, MTUnitTest]
        public void Synchronize_SuccessfulExecution_SyncPartitionConfigWasCalled()
        {

            #region GIVEN

            var partitionManager = new UsagePartitionManager(() => _fakeConnection, _fakePartitionConfig, _fakeLogger);

            #endregion

            #region WHEN

            partitionManager.Synchronize();

            #endregion

            #region THEN

            A.CallTo(() => _fakePartitionConfig.Synchronize()).MustHaveHappened();

            #endregion

        }

    }
}
