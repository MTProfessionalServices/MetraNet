using MetraTech.SecurityFramework.Common.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using System.IO;
using MetraTech.SecurityFramework.Serialization.Attributes;
using System.Collections;
using System.Collections.Generic;

namespace MetraTech.SecurityFrameworkUnitTests
{


	/// <summary>
	///This is a test class for ConfigurationLoaderTest and is intended
	///to contain all ConfigurationLoaderTest Unit Tests
	///</summary>
	[TestClass()]
	public class ConfigurationLoaderTest
	{
		private class TestSerializeClass
		{
			public class TestSerialize_NestedClass
			{
				public TestSerialize_NestedClass() { }
				public TestSerialize_NestedClass(int value)
				{
					IntProperty_Nested = value;
				}

				[SerializePropertyAttribute(MappedName = "NestedProperty")]
				internal int IntProperty_Nested
				{
					get;
					set;
				}
			}

			[SerializePropertyAttribute(MappedName = "IntProperty")]
			internal int IntProperty
			{
				get;
				set;
			}

			[SerializeCollectionAttribute(DefaultType = typeof(List<TestSerialize_NestedClass>), ElementName = "Element",
				ElementType = typeof(TestSerialize_NestedClass))]
			internal IList<TestSerialize_NestedClass> CollectionProperty
			{
				get;
				set;
			}
		}

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
		//You can use the following additional attributes as you write your tests:
		//
		//Use ClassInitialize to run code before running the first test in the class
		//[ClassInitialize()]
		//public static void MyClassInitialize(TestContext testContext)
		//{
		//}
		//
		//Use ClassCleanup to run code after all tests in a class have run
		//[ClassCleanup()]
		//public static void MyClassCleanup()
		//{
		//}
		//
		//Use TestInitialize to run code before running each test
		//[TestInitialize()]
		//public void MyTestInitialize()
		//{
		//}
		//
		//Use TestCleanup to run code after each test has run
		[TestCleanup()]
		public void MyTestCleanup()
		{
			string tempFileName = UnitTestUtility.GetConfigPath(testContextInstance, @"XmlSerializerTemp_Test.xml");
			string tempFileName1 = UnitTestUtility.GetConfigPath(testContextInstance, @"\XmlSerializerTemp_Test1.xml");

			try
			{
				File.Delete(tempFileName);
			}
			finally
			{
				File.Delete(tempFileName1);
			}
		}
		//
		#endregion


		/// <summary>
		///A test for Initialize
		///</summary>
		[TestMethod()]
		public void TrueInitialize_ProcessorTest()
		{
			string pathToFile = UnitTestUtility.GetConfigPath(testContextInstance, "TrueTest_MtSfSsProcessor.xml");
			string subsystemPropertyTypeName = "MetraTech.SecurityFramework.Core.SubsystemProperties, MetraTech.SecurityFramework.Core.Common";
			string subsystemTypeName = "MetraTech.SecurityFramework.Processor, MetraTech.SecurityFramework";

			try
			{
				ISubsystem subsystem = Load(pathToFile, subsystemPropertyTypeName, subsystemTypeName);
			}
			catch (Exception e)
			{
				throw e;
			}
		}

		/// <summary>
		///A test for Initialize
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ConfigurationException))]
		public void DoubleEngineId_ProcessorTest()
		{
			string pathToFile = UnitTestUtility.GetConfigPath(testContextInstance, "DoubleEngineId_MtSfSsProcessor.xml");
			string subsystemPropertyTypeName = "MetraTech.SecurityFramework.Core.SubsystemProperties, MetraTech.SecurityFramework.Core.Common";
			string subsystemTypeName = "MetraTech.SecurityFramework.Processor, MetraTech.SecurityFramework";

			try
			{
				ISubsystem subsystem = Load(pathToFile, subsystemPropertyTypeName, subsystemTypeName);
			}
			catch (Exception e)
			{
				throw e;
			}
		}

		/// <summary>
		///A test for Initialize
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ConfigurationException))]
		public void DoubleRuleId_ProcessorTest()
		{
			string pathToFile = UnitTestUtility.GetConfigPath(testContextInstance, "DoubleRuleId_MtSfSsProcessor.xml");
			string subsystemPropertyTypeName = "MetraTech.SecurityFramework.Core.SubsystemProperties, MetraTech.SecurityFramework.Core.Common";
			string subsystemTypeName = "MetraTech.SecurityFramework.Processor, MetraTech.SecurityFramework";

			try
			{
				ISubsystem subsystem = Load(pathToFile, subsystemPropertyTypeName, subsystemTypeName);
			}
			catch (Exception e)
			{
				throw e;
			}
		}

		/// <summary>
		/// Test for Xml serializer and deserializer
		/// </summary>
		[TestMethod()]
		public void XmlSerializerTest_DeserializationAndSerializationProcess()
		{
			string sourceFileName = UnitTestUtility.GetConfigPath(testContextInstance, @"XmlSerializer_Test.xml");
			string tempFileName = UnitTestUtility.GetConfigPath(testContextInstance, @"XmlSerializerTemp_Test.xml");
			string sourceText = string.Empty;
			string serializeText = string.Empty;
			ISerializer serializer = new XmlSerializer();
			TestSerializeClass test = new TestSerializeClass();

			//Deserialize object from xml-file
			serializer.Deserialize(test, null, sourceFileName);

			File.Create(tempFileName).Close();

			//Serialize object to xml
			serializer.Serialize(test, tempFileName);

			sourceText = File.ReadAllText(sourceFileName);

			serializeText = File.ReadAllText(tempFileName);

			Assert.AreEqual(sourceText, serializeText, "Errors while XmlSerializer worked.");
		}

		/// <summary>
		/// Test for Xml serializer
		/// </summary>
		[TestMethod()]
		public void XmlSerializer_Test1()
		{
			string tempFileName = UnitTestUtility.GetConfigPath(testContextInstance, @"XmlSerializerTemp_Test1.xml");
			string serializeText = string.Empty;
			ISerializer serializer = new XmlSerializer();
			TestSerializeClass test = new TestSerializeClass();
			test.IntProperty = 1;
			test.CollectionProperty = new TestSerializeClass.TestSerialize_NestedClass[] { 
													new TestSerializeClass.TestSerialize_NestedClass(0),
													new TestSerializeClass.TestSerialize_NestedClass(1),
													new TestSerializeClass.TestSerialize_NestedClass(2)};
			
			File.Create(tempFileName).Close();

			//Serialize object to xml
			serializer.Serialize(test, tempFileName);
		}

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
