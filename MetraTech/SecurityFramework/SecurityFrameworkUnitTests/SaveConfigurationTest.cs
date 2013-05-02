using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Common.Configuration.Logger;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.Encryptor;
using MetraTech.SecurityFramework.Serialization;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests
{

	public class TestEngine : EncryptorEngineBase
	{
		public TestEngine() : base(EncryptorEngineCategory.KeySetup) { }

		public TestEngine(EncryptorEngineCategory category):base(category)
		{
			this.Id = Guid.NewGuid().ToString();
		}

		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			return null;
		}
	}

	[TestClass()]
	public class SaveConfigurationTest
	{
		private TestContext testContextInstance;

		/// <summary>
		///Gets or sets the test context which provides
		///information about and functionality for the current test run.
		///</summary>
		public TestContext TestContext
		{
			get
			{
				return testContextInstance;
			}
			set
			{
				testContextInstance = value;
			}
		}

		#region Additional test attributes
		//
		// You can use the following additional attributes as you write your tests:
		//
		// Use ClassInitialize to run code before running the first test in the class
		[ClassInitialize()]
		public static void SecurityKernelInitialize(TestContext testContext)
		{
			UnitTestUtility.InitFrameworkConfiguration(testContext);
		}

		// Use ClassCleanup to run code after all tests in a class have run
		[ClassCleanup()]
		public static void SecurityKernelClassCleanup()
		{
			UnitTestUtility.CleanupFrameworkConfiguration();
		}
		//
		// Use TestInitialize to run code before running each test 
		[TestInitialize()]
		public void SecurityKernelAllTetsInitialize()
		{
			Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
		}
		//
		// Use TestCleanup to run code after each test has run
		// [TestCleanup()]
		// public void MyTestCleanup() { }
		//
		#endregion


		/// <summary>
		///A test for Initialize
		///</summary>
		/*[TestMethod()]
		public void ChangeConfigurationEncryptor_TestPosistive()
		{
			SubsystemBase encryptor = ((SubsystemBase)SecurityKernel.Encryptor);
			TestEngine newEngine = new TestEngine(EncryptorEngineCategory.KeySetup);
			string idNewEngine = newEngine.Id;
			try
			{
				encryptor.ControlApi.AddEngine(newEngine);
				string pathToFile = UnitTestUtility.GetConfigPath(testContextInstance, "SaveConfiguration_Validator_Changed.xml");
				string subsystemPropertyTypeName = "MetraTech.SecurityFramework.EncryptorProperties, MetraTech.SecurityFramework";
				string subsystemTypeName = "MetraTech.SecurityFramework.Encryptor, MetraTech.SecurityFramework";

				IConfigurationLogger subsystemProps = encryptor.GetConfiguration();

				ISerializer serializer = new XmlSerializer();
				serializer.Serialize(subsystemProps, pathToFile);

				SubsystemBase changedEncryptor =  ((SubsystemBase)Load(pathToFile, subsystemPropertyTypeName, subsystemTypeName));
				IEngine changedEngine = changedEncryptor.Api.GetEngine(idNewEngine);
				Assert.IsNotNull(changedEngine);
			}
			finally
			{
				encryptor.ControlApi.RemoveEngine(idNewEngine); 
			}
		}*/


		private ISubsystem Load(string pathToFile, string subsystemPropertyTypeName, string subsystemTypeName)
		{
			ISubsystem ret = null;
			try
			{
				ISerializer serializer = new XmlSerializer();
				Type propsType = Type.GetType(subsystemPropertyTypeName);
				if (propsType == null)
				{
					ConfigurationException exc = new ConfigurationException(string.Format("Not found or not specified the type of subsystem: {0}", propsType.ToString()));
					throw exc;
				}

				object props = serializer.Deserialize(propsType, null, pathToFile);


				Type subsystemType = Type.GetType(subsystemTypeName);
				object subsystem = subsystemType.InvokeMember(subsystemTypeName, System.Reflection.BindingFlags.CreateInstance, null, null, null);

				((ISubsystemInitialize)subsystem).Initialize(((MetraTech.SecurityFramework.Core.SubsystemProperties)props));
				ret = ((ISubsystem)subsystem);
			}
			catch (Exception e)
			{
				throw e;
			}
			return ret;
		}
	}
}
