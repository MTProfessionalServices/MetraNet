using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq.Expressions;
using System.Runtime.InteropServices;
using System.Threading;
using System.Xml;
using NUnit.Framework;

namespace MetraTech.Pipeline.Plugins.Test
{
    using MetraTech.Test;
    using MetraTech.Interop.COMMeter;
    using Auth = MetraTech.Interop.MTAuth;
    using MetraTech.Interop.PipelineTransaction;
    using MetraTech.DataAccess;

    //
    // To run the this test fixture:
    // nunit-console /fixture:MetraTech.Pipeline.Plugins.Test.GetSubscriptionPropertiesTest /assembly:O:\debug\bin\MetraTech.Pipeline.Plugins.Test.dll
    //
  [Category("NoAutoRun")]
  [TestFixture]
    [ComVisible(false)]
    public class GetSubscriptionPropertiesTest
    {

        private const string SystemUserName = "su";
        private const string SystemUserNamePassword = "su123";

        private const string ConfigFolder = "TestConfigs";
        private const string PoName = "feat-196-plugin-07385A1E-36AD-4002-8C40-BA1DD839A034";
        private const string SubName = "sub-feat-196-plugin-07385A1E-36AD-4002-8C40-BA1DD839A034";

        #region Accounts for Subscription\GroupSubscription
        private const string UserNameForSub = "demo";
        private const string UserNamePasswordForSub = "demo123";
        private const int IdDemoAcc = 123;

        private const string UserNameForGroupSub = "corp";
        private const string UserNamePasswordForGroupSub = "corp123";
        #endregion Accounts for Subscription\GroupSubscription

        private string CreateFilePath(string nameEntity)
        {
            return Path.Combine(ConfigFolder, String.Format("{0}.xml", nameEntity));
        }

        
        private int _idPo;
        private int _idSub;

        private PluginTestLib _pluginTestLib;
        private Plugin _plugin;
        private const string extensionName = "metratech.com/Subscription";
        private const string pluginProgId = "MetraTech.Custom.Plugins.Subscription.GetSubscriptionProperties";

        public GetSubscriptionPropertiesTest() 
        {
          _pluginTestLib = new PluginTestLib(extensionName);
        }

        /// <summary>
        ///    Runs once before any of the tests are run.
        /// </summary>
        [TestFixtureSetUp]
        public void Init()
        {
            //Debugger.Launch();
            // Imports PO and PI to DB
            //TODO: Needs somehow remove created PO and PI from DB into Dispose() test method, after finishing this test
            try
            {
                CreatePO();
                CreateSubscription();

                InsertToSpecCharValueTable();
                InsertToCharValueTable(_idSub);

                //GroupSubscriptionServiceTests.
                _plugin = _pluginTestLib.CreatePlugin(pluginProgId, PluginConfig);

            }
            catch (Exception ex)
            {
                throw new Exception(String.Format("Exception was occured while initializing {0} test.", this), ex);
            }
           
        }

        private void CreatePO()
        {
            _idPo = GetPoId(PoName);
            if (_idPo < 0)
            {
                ImportPo(PoName);
                _idPo = GetPoId(PoName);

                if (_idPo == -1)
                {
                    throw new InvalidDataException(String.Format("PO with '{0}' does not find in DB.", PoName));
                }
            }
            Console.WriteLine(String.Format("[INFO] PO id = '{0}'", _idPo));
        }

        private void CreateSubscription()
        {
            _idSub = GetSubscribtionId(IdDemoAcc, PoName);
            if (_idSub < 0)
            {
                CorrectStartDataForSubscription(SubName);
                ExportSubscription(SubName);
                _idSub = GetSubscribtionId(IdDemoAcc, PoName);

                if (_idSub == -1)
                {
                    throw new InvalidDataException(
                        String.Format("Subscription for account with id = '{0}' does not find for PO with name = '{1}'.", IdDemoAcc,
                                      PoName));
                }
            }
            Console.WriteLine(String.Format("[INFO] Subscription id = '{0}' for account with id = '{1}'", _idSub, IdDemoAcc));
        }

        private void CorrectStartDataForSubscription(string subName)
        {
            XmlDocument xmlSub = new XmlDocument();
            xmlSub.Load(CreateFilePath(subName));
            XmlNode startDateNode = xmlSub.DocumentElement.SelectSingleNode(@"//property[@name='StartDate']");
            startDateNode.InnerXml = DateTime.Now.ToShortDateString();
            xmlSub.Save(CreateFilePath(subName));
        }

        /// <summary>
        ///   Runs once after all the tests are run.
        /// </summary>
        [TestFixtureTearDown]
        public void Dispose()
        {
        }

        #region Input params
        private const string IdSubscriptionParam = "IdSubscription";
        private const string IsGroupSubscriptionParam = "IsGroupSubscription";
        #endregion Input params

        #region Output params
        private const string CountRecordsParam = "CountRecords";
        #endregion Output params
        
        [Test]
        [Ignore("Failing - Ignore Test")]
        public void GetSubscriptionProperties_Negative_Positive()
        {
            int failIdSub = _idSub + 9999;
            PluginSession session1 = CreatePluginSession(failIdSub, false);
            PluginSession session2 = CreatePluginSession(_idSub, false);
            
            _plugin.ProcessSessions();

            // Negative test
            int actualCountRows = GetCountRecords(session1);
            Assert.AreEqual(0, actualCountRows,
                            String.Format("Expected='0', but Actual='{0}' subscription properties for idSub={1}",
                                          actualCountRows, failIdSub));

            // Positive test
            actualCountRows = GetCountRecords(session2);

            Assert.AreEqual(_expectedValues.Count, actualCountRows,
                           String.Format("Expected='0', but Actual='{0}' subscription properties for idSub={1}",
                                         actualCountRows, _idSub));

            for (int index = 0; index < _expectedValues.Count; index++ )
            {
                int actualSpecCharValId = ReadProcessedData(session2, index).SpecCharValId;
                Assert.AreEqual(_expectedValues[index].SpecCharValId, actualSpecCharValId,
                           String.Format("Expected SpecCharValId with id='{0}', but Actual SpecCharValId with id='{1}' subscription properties for idSub={2}",
                                         _expectedValues[index].SpecCharValId, actualSpecCharValId, _idSub));
            }
        }
       
        //TODO: Need to be create for GroupSubscription
        //[Test]
        //public void GetGroupSubscriptionProperties_Positive()
        //{
        //}

        #region Import Data to DB

        #region PCImportExport app
        /// <summary>
        /// Creates PO and PI in DB
        /// </summary>
        /// <returns>output info</returns>
        private string ImportPo(string poName)
        {
            string poFileName = CreateFilePath(poName);
            if (!File.Exists(poFileName))
            {
                throw new FileNotFoundException("Can't export PO and PI to DB by PCImportExport application. File was not found.",
                                                poFileName);
            }
            // -ipo -file "XML-File"  -username "USERNAME" -password "PASSWORD" [-namespace "NAMESPACE"]
            return RunPcimportexport(
                String.Format(
                    @"-ipo -file ""{0}"" -username {1} -password {2} -namespace system_user -skipintegrity",
                    poFileName,
                    SystemUserName,
                    SystemUserNamePassword));
        }

        /// <summary>
        /// Creates Subscription for Account in DB
        /// </summary>
        /// <returns>output info</returns>
        private string ExportSubscription(string subName)
        {   // -is -file "XML-File" -username "USERNAME" -password "PASSWORD" [-namespace "NAMESPACE"]
            return RunPcimportexport(
               String.Format(
                   @"-is -file ""{0}"" -username {1} -password {2} -namespace mt ",
                   CreateFilePath(subName),
                   UserNameForSub,
                   UserNamePasswordForSub));
        }

        /// <summary>
        /// Cretes GroupSubscription for Account in DB
        /// </summary>
        /// <returns>output info</returns>
        private string ExporttGroupSubscription(string poName)
        {   //-egs -corp "Corporation" -corpNameSpace "CorporationNameSpace" -groupsubscription "Group-Subscription-Name" -file "XML-File" -username MTUserName -password PassWord [-namespace NameSpace] [-date TimeStamp] 
            return RunPcimportexport(
               String.Format(
                   @"-egs -corp ""Corporation"" -corpNameSpace ""CorporationNameSpace"" -groupsubscription ""GroupSubName-{0}"" -file ""{1}"" -username {2} -password {3} -namespace mt",
                   poName,
                   CreateFilePath(poName),
                   SystemUserName,
                   SystemUserNamePassword));
        }

        /// <summary>
        /// Runs PcImportExport
        /// </summary>
        /// <param name="arguments">PcImportExport's arguments</param>
        /// <returns>output console</returns>
        private string RunPcimportexport(string arguments)
        {
            string output = String.Empty;
            ProcessStartInfo psi = new ProcessStartInfo("pcimportexport.exe");
            psi.RedirectStandardOutput = true;
            psi.WindowStyle = ProcessWindowStyle.Hidden;
            psi.UseShellExecute = false;
            psi.Arguments = arguments;
            Process proc = Process.Start(psi);
            System.IO.StreamReader myOutput = proc.StandardOutput;
            proc.WaitForExit(3 * 60000);

            if (proc.HasExited)
            {
                output = myOutput.ReadToEnd();
            }
            return output;
        }

        #endregion PCImportExport app

        #region Subscription Properties

        private List<SpecCharValueStruct> _specCharValues = null;
        private const string SqlCountSpecChars = @"select count(*) as count from t_spec_char_values where id_scv = {0}";
        private void InsertToSpecCharValueTable()
        {
            if (_specCharValues == null)
            {
                //creates values for t_spec_char_values
                _specCharValues = new List<SpecCharValueStruct>
                                                           {
                                                               new SpecCharValueStruct
                                                                   {
                                                                       ID = 110000,
                                                                       IsDefault = true,
                                                                       ValueID = 12000,
                                                                       Value = "Plugin_0"
                                                                   },

                                                               new SpecCharValueStruct
                                                                   {
                                                                       ID = 110001,
                                                                       IsDefault = true,
                                                                       ValueID = 120001,
                                                                       Value = "Plugin_1"
                                                                   }
                                                           };
            }
            
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\PCWS"))
            {
                foreach (SpecCharValueStruct specCharValue in _specCharValues)
                {
                    bool existsRecod = false;
                    // checks
                    using (IMTStatement stmt = conn.CreateStatement(String.Format(SqlCountSpecChars, specCharValue.ID)))
                    {
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            if (reader.Read()) existsRecod = reader.GetInt32("count") > 0;
                        }
                    }

                    if (!existsRecod)
                    {
                        // creates
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\PCWS",
                                                                                      "__ADD_SPEC_CHAR_VAL__"))
                        {

                            stmt.AddParam("%%ID_SCV%%", specCharValue.ID, true);

                            if (specCharValue.IsDefault)
                                stmt.AddParam("%%IS_DEFAULT%%", "Y", true);
                            else
                                stmt.AddParam("%%IS_DEFAULT%%", "N", true);

                            stmt.AddParam("%%N_VALUE%%", -1, true);
                            stmt.AddParam("%%NM_VALUE%%", specCharValue.Value, true);
                            stmt.ExecuteNonQuery();
                            stmt.ClearQuery();

                        }
                    }
                }
            }
        }

         // creates valuse for t_char_values
        private List<CharValueStruct> _expectedValues = null;
        private const string SqlCountCharValues = @"select count(*) as count from t_char_values where id_scv = {0}";
        private void InsertToCharValueTable(int subId)
        {
            if (_expectedValues == null)
            {
                _expectedValues = new List<CharValueStruct>
                                                           {
                                                               new CharValueStruct
                                                                   {
                                                                       SpecCharValId = _specCharValues[0].ID,
                                                                       EntityId = subId,
                                                                       Value = "Char_Value_0",
                                                                       StartDate = new DateTime(2000, 1, 31),
                                                                       EndDate = new DateTime(2000, 2, 20),
                                                                       SpecName = "Specific_Name_0",
                                                                       SpecType = 1
                                                                   },
                                                                   new CharValueStruct
                                                                   {
                                                                       SpecCharValId = _specCharValues[1].ID,
                                                                       EntityId = subId,
                                                                       Value = "Char_Value_1",
                                                                       StartDate = new DateTime(2001, 1, 31),
                                                                       EndDate = new DateTime(2001, 2, 20),
                                                                       SpecName = "Specific_Name_1",
                                                                       SpecType = 1
                                                                   }
                                                           };
            }

            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\ProductCatalog"))
            {
                    foreach (CharValueStruct cv in _expectedValues)
                    {
                         bool existsRecod = false;
                        // checks
                         using (IMTStatement stmt = conn.CreateStatement(String.Format(SqlCountCharValues, cv.SpecCharValId)))
                        {
                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                if (reader.Read()) existsRecod = reader.GetInt32("count") > 0;
                            }
                        }

                        if (!existsRecod)
                        {
                            // creates
                            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\ProductCatalog",
                                                                                          "__SAVE_CHAR_VALS_FOR_SUB__"))
                            {
                                stmt.AddParam("%%SPEC_CHAR_VAL_ID%%", cv.SpecCharValId);
                                stmt.AddParam("%%ENTITY_ID%%", cv.EntityId);
                                stmt.AddParam("%%VALUE%%", cv.Value);
                                stmt.AddParam("%%START_DATE%%", cv.StartDate);
                                stmt.AddParam("%%END_DATE%%", cv.EndDate);
                                stmt.AddParam("%%SPEC_NAME%%", cv.SpecName);
                                stmt.AddParam("%%SPEC_TYPE%%", cv.SpecType);
                                stmt.ExecuteNonQuery();
                                stmt.ClearQuery();
                            }
                        }
                    }
            }
        }

        #endregion Subscription Properties

        #endregion Import Data to DB

        private int GetPoId(string poName)
        {
            int result = -1;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\PCWS"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\PCWS",
                                                                                 "__GET_PO_HL_DETAILS__"))
                {
                    using (IMTDataReader dataReader = stmt.ExecuteReader())
                    {
                        //if there are records, create a ProductOffering object for eacg
                        while (dataReader.Read())
                        {
                            if (String.Equals(dataReader.GetString("Name"), poName))
                            {
                                result = dataReader.GetInt32("ProductOfferingId");
                                break;
                            }
                        }
                    }
                }
            }
            return result;
        }

        private int GetSubscribtionId(int idAcc, string poName)
        {
            int resultIdSub = -1;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                // Get a filter/sort statement
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"queries\ProductCatalog", "__GET_ALL_SUBSCRIPTIONS__"))
                {
                    // Set the parameters
                    stmt.AddParam("%%ID_ACC%%", idAcc);
                    stmt.AddParam("%%COLUMNS%%", String.Empty);
                    stmt.AddParam("%%JOINS%%", String.Empty);
                    // EN languge code
                    stmt.AddParam("%%ID_LANG%%", 840);

                    using (IMTDataReader dataReader = stmt.ExecuteReader())
                    {
                        //if there are records, create a ProductOffering object for eacg
                        while (dataReader.Read())
                        {
                            if (String.Equals(dataReader.GetString("po_nm_name"), poName))
                            {
                                resultIdSub = dataReader.GetInt32("id_sub");
                                break;
                            }
                        }
                    }
                }
            }

            return resultIdSub;
        }

        #region Test helper

        private PluginSession CreatePluginSession(int idSub, bool isGroupSub)
        {
            PluginSession pluginSession = null;
            pluginSession = _plugin.CreateSession();
            pluginSession.SetProperty(IdSubscriptionParam, idSub, PropertyType.Int32);
            pluginSession.SetProperty(IsGroupSubscriptionParam, isGroupSub ? "1" : "0", PropertyType.Bool);
            return pluginSession;
        }

        private int GetCountRecords(PluginSession session)
        {
            return Convert.ToInt32(session.GetProperty(CountRecordsParam, PropertyType.Int32));
        }

        private CharValueStruct ReadProcessedData(PluginSession session, int indexRow)
        {
            CharValueStruct result = new CharValueStruct();
            result.SpecCharValId = Convert.ToInt32(session.GetProperty(GetVariableName(() => result.SpecCharValId) + indexRow,
                                                       PropertyType.Int32));
            result.EntityId = Convert.ToInt32(session.GetProperty(GetVariableName(() => result.EntityId) + indexRow,
                                                      PropertyType.Int32));
            result.Value = Convert.ToString(session.GetProperty(GetVariableName(() => result.Value) + indexRow,
                                                      PropertyType.String));
            result.StartDate = Convert.ToDateTime(session.GetProperty(GetVariableName(() => result.StartDate) + indexRow,
                                                      PropertyType.DateTime));
            result.EndDate = Convert.ToDateTime(session.GetProperty(GetVariableName(() => result.EndDate) + indexRow,
                                                      PropertyType.DateTime));
            result.SpecName = Convert.ToString(session.GetProperty(GetVariableName(() => result.SpecName) + indexRow,
                                                      PropertyType.String));
            result.SpecType = Convert.ToInt32(session.GetProperty(GetVariableName(() => result.SpecType) + indexRow,
                                                      PropertyType.Int32));
            return result;
        }

        static string GetVariableName<T>(Expression<Func<T>> expression)
        {
            var body = ((MemberExpression)expression.Body);

            return body.Member.Name;
        }

        #endregion Test helper

        #region Structures for test data
        //TODO: Use these structures, because can't compile this test if use DamainModel structure
        private struct SpecCharValueStruct
        {
            public int ID;
            public bool IsDefault;
            public int ValueID;
            private string _val;
            public string Value
            {
                get { return _val; }
                set { _val = value.Length > 20 ? value.Substring(0, 20) : value; }
            }
        }

        private struct CharValueStruct
        {
            public int SpecCharValId;
            public int EntityId;

            private string _val;
            public string Value
            {
                get { return _val; }
                set { _val = value.Length > 20 ? value.Substring(0, 20) : value; }
            }

            public DateTime StartDate;
            public DateTime EndDate;

            private string _specName;
            public string SpecName
            {
                get { return _specName; }
                set { _specName = value.Length > 20 ? value.Substring(0, 20) : value; }
            }

            public int SpecType;
        }
        #endregion Structures for test data

        private const string PluginConfig =
            @"<?xml version=""1.0"" encoding=""utf-8""?>
                <xmlconfig>
                    <mtconfigdata>
                        <version ptype=""INTEGER"">1</version>
                        <processor>
                            <name>GetSubscriptionPropertiesTestInstance</name>
                            <progid>MetraTech.Custom.Plugins.Subscription.GetSubscriptionProperties</progid>
                            <description>Test for GetSubscriptionProperties plug-in</description>
                            <configdata>                
                                <PipelineBinding>
                                    <IdSubscription>IdSubscription</IdSubscription>
                                    <IsGroupSubscription>IsGroupSubscription</IsGroupSubscription>
                                    <CountRecords>CountRecords</CountRecords>
                                </PipelineBinding>
				                <GeneralConfig>
                                    <QueryPath>Queries\PCWS</QueryPath>
                                    <QueryTagForSubscription>__GET_CHAR_VALS_FOR_SUB__</QueryTagForSubscription>
                                    <QueryTagForGroupSubscription>__GET_CHAR_VALS_FOR_GROUP_SUB__</QueryTagForGroupSubscription>
                                </GeneralConfig>
                            </configdata>
                        </processor>
                    </mtconfigdata>
                </xmlconfig>";
    }
}

// EOF
