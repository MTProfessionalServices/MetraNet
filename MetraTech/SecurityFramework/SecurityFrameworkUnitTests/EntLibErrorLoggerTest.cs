using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.Common.Logging;
using MetraTech.SecurityFramework.Core.Common.Logging.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests
{


	/// <summary>
	///This is a test class for EntLibErrorLoggerTest and is intended
	///to contain all EntLibErrorLoggerTest Unit Tests
	///</summary>
	[TestClass()]
	public class EntLibErrorLoggerTest
	{


		private TestContext testContextInstance;
		private const string _pathToLogFormat = "C:\\Temp\\SecurityFramework\\unittest_trace_{0}.log";

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
		//[TestCleanup()]
		//public void MyTestCleanup()
		//{
		//}
		//
		#endregion

		#region Constructor tests

		/// <summary>
		///A test for Initialize with prover arguments.
		///</summary>
		[TestMethod()]
		public void ConstructorTest_Positive()
		{
			IErrorLogger target = CreateLogger();

			Assert.IsNotNull(target, "Object reference expected but null found.");
		}

		#endregion

		#region Initialize tests

		/// <summary>
		///A test for Initialize with proper arguments.
		///</summary>
		[TestMethod()]
		public void InitializeTest_Positive()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration();

			target.Initialize(configuration);
		}

		/// <summary>
		///A test for Initialize with null configuration value.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ArgumentNullException))]
		public void InitializeTest_NullConfiguration()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = null;

			target.Initialize(configuration);
		}

		/// <summary>
		///A test for Initialize with null configuration value.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ArgumentException))]
		public void InitializeTest_NullExceptionPolicy()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration();
			configuration.ExceptionPolicyConfiguration = null;

			target.Initialize(configuration);
		}

		/// <summary>
		///A test for Initialize with invalid configuration.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ConfigurationException))]
		public void InitializeTest_InvalidFormatterName()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration();
			configuration.Listeners[0].Formatter += "1";

			target.Initialize(configuration);
		}

		/// <summary>
		///A test for Initialize with invalid configuration.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ConfigurationException))]
		public void InitializeTest_InvalidListenerType()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration();
			configuration.Listeners[0].ListenerDataType += "1";

			target.Initialize(configuration);
		}

		/// <summary>
		///A test for Initialize with invalid configuration.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ConfigurationException))]
		public void InitializeTest_InvalidFormatterType()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration();
			configuration.Formatters[0].TypeName += "1";

			target.Initialize(configuration);
		}

		#endregion

		#region Log tests

		/// <summary>
		///A test for Log with proper arguments.
		///</summary>
		[TestMethod()]
		public void LogTest_Positive()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration();
			target.Initialize(configuration);
			Exception ex = new Exception("Test message: LogTest_Positive");
			bool expected = true;
			bool actual;
			actual = target.Log(ex);

			Assert.AreEqual(expected, actual);
		}

		/// <summary>
		///A test for Log with null ex.
		///</summary>
		[TestMethod()]
		[ExpectedException(typeof(ArgumentNullException))]
		public void LogTest_NullEx()
		{
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration();
			target.Initialize(configuration);
			Exception ex = null;

			target.Log(ex);
		}

		/// <summary>
		///A test for LogDebug with proper arguments.
		///</summary>
		[TestMethod()]
		public void LogTest_DebugWithTagName()
		{
			string logPath;
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration(out logPath);
			target.Initialize(configuration);
			string tag = MetraTech.SecurityFramework.Common.Constants.Properties.SubsystemName;
			string msg = string.Format("LogTest_DebugWithTagName_{0}", Guid.NewGuid());
			target.LogDebug(tag, msg);
			Assert.IsTrue(CheckLogContains(logPath,msg));
		}

		/// <summary>
		///A test for LogDebug with proper arguments.
		///</summary>
		[TestMethod()]
		public void LogTest_DebugWithoutTagName()
		{
			string logPath;
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration(out logPath);
			target.Initialize(configuration);
			string msg = string.Format("LogTest_DebugWithoutTagName_{0}", Guid.NewGuid());
			target.LogDebug(msg);
			Assert.IsTrue(CheckLogContains(logPath, msg));
		}

		/// <summary>
		///A test for LogInfo with proper arguments.
		///</summary>
		[TestMethod()]
		public void LogTest_InfoWithoutTagName()
		{
			string logPath;
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration(out logPath);
			target.Initialize(configuration);
			string msg = string.Format("LogTest_InfoWithoutTagName_{0}", Guid.NewGuid());
			target.LogInfo(msg);
			Assert.IsTrue(CheckLogContains(logPath, msg));
		}

		/// <summary>
		///A test for LogInfo with proper arguments.
		///</summary>
		[TestMethod()]
		public void LogTest_InfoWithTagName()
		{
			string logPath;
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration(out logPath);
			target.Initialize(configuration);
			string tag = MetraTech.SecurityFramework.Common.Constants.Properties.SubsystemName;
			string msg = string.Format("LogTest_InfoWithTagName_{0}", Guid.NewGuid());
			target.LogInfo(tag, msg);
			Assert.IsTrue(CheckLogContains(logPath, msg));
		}

		/// <summary>
		///A test for LogWarning with proper arguments.
		///</summary>
		[TestMethod()]
		public void LogTest_WarningWithoutTagName()
		{
			string logPath;
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration(out logPath);
			target.Initialize(configuration);
			string msg = string.Format("LogTest_WarningWithoutTagName_{0}", Guid.NewGuid());
			target.LogWarning(msg);
			Assert.IsTrue(CheckLogContains(logPath, msg));
		}

		/// <summary>
		///A test for LogInfo with proper arguments.
		///</summary>
		[TestMethod()]
		public void LogTest_WarningWithTagName()
		{
			string logPath;
			IErrorLogger target = CreateLogger();
			LoggingConfiguration configuration = CreateLoggingConfiguration(out logPath);
			target.Initialize(configuration);
			string tag = MetraTech.SecurityFramework.Common.Constants.Properties.SubsystemName;
			string msg = string.Format("LogTest_WarningWithTagName_{0}", Guid.NewGuid());
			target.LogWarning(tag, msg);
			Assert.IsTrue(CheckLogContains(logPath, msg));
		}

		#endregion

		#region Private Methods

		private LoggingConfiguration CreateLoggingConfiguration()
		{
			LoggingConfiguration result = new LoggingConfiguration();

			result.DefaultCategory = "General";

			result.Formatters =
				new List<LogFormatterConfiguration>()
                {
                    new LogFormatterConfiguration()
                    {
                        Name = "Text Formatter",
                        TypeName = "Microsoft.Practices.EnterpriseLibrary.Logging.Formatters.TextFormatter, Microsoft.Practices.EnterpriseLibrary.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                        Template = "Timestamp: {timestamp}{newline}\nMessage: {message}{newline}\nCategory: {category}{newline}\nPriority: {priority}{newline}\nEventId: {eventid}{newline}\nSeverity: {severity}{newline}\nTitle:{title}{newline}\nMachine: {localMachine}{newline}\nApp Domain: {localAppDomain}{newline}\nProcessId: {localProcessId}{newline}\nProcess Name: {localProcessName}{newline}\nThread Name: {threadName}{newline}\nWin32 ThreadId:{win32ThreadId}{newline}\nExtended Properties: {dictionary({key} - {value}{newline})}"
                    }
                }.ToArray();

			result.Listeners =
				new List<TraceListenerConfiguration>()
                {
                    new FlatFileTraceListenerConfiguration()
                    {
                        TypeName = "Microsoft.Practices.EnterpriseLibrary.Logging.TraceListeners.FlatFileTraceListener, Microsoft.Practices.EnterpriseLibrary.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                        Name = "FlatFileTraceListener",
                        ListenerDataType = "Microsoft.Practices.EnterpriseLibrary.Logging.Configuration.FlatFileTraceListenerData, Microsoft.Practices.EnterpriseLibrary.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                        FileName = "C:\\Temp\\SecurityFramework\\unittest_trace.log",
                        Formatter = "Text Formatter",
                        TraceOutputOptions = "DateTime, Timestamp, ProcessId",
                        Filter = SourceLevels.Verbose
                    },
					new MetraTech.SecurityFramework.Core.Common.Logging.Configuration.TraceListenerConfiguration()
					{
						Name = "MetraTechLogTraceListener",
						ListenerDataType = "MetraTech.SecurityFramework.MTLogging.Configuration.MetraTechLogTraceListenerData, MetraTech.SecurityFramework.MTLogging",
						Filter = SourceLevels.Verbose
					}
                }.ToArray();

			result.CategorySources =
				new List<EventCategorySourceConfiguration>()
                {
                    new EventCategorySourceConfiguration()
                    {
                        CategoryName = "General",
                        SwitchValue = SourceLevels.All,
                        Listeners = new List<string>() { "FlatFileTraceListener", "MetraTechLogTraceListener" }.ToArray()
                    }
                }.ToArray();

			result.Errors =
				new EventCategorySourceConfiguration()
				{
					CategoryName = "Logging Errors & Warnings",
					SwitchValue = SourceLevels.All,
					Listeners = new List<string>() { "FlatFileTraceListener", "MetraTechLogTraceListener" }.ToArray()
				};

			List<ExceptionTypeConfiguration> exceptionTypes =
				new List<ExceptionTypeConfiguration>()
                {
                    new ExceptionTypeConfiguration()
                    {
                        Name = "All Exceptions",
                        PostHandlingAction = Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.PostHandlingAction.NotifyRethrow,
                        TypeName = "System.Exception, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089",
                        ExceptionHandlers =
                            new List<ExceptionHandlerConfiguration>()
                            {
                                new ExceptionHandlerConfiguration()
                                {
                                    LogCategory = "General",
                                    Name ="Logging Exception Handler",
                                    EventId = 100,
                                    Severity = TraceEventType.Error,
                                    Priority = 0,
                                    Title = "Enterprise Library Exception Handling",
                                    TypeName = "Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Logging.LoggingExceptionHandler, Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                                    FormatterType = "Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.TextExceptionFormatter, Microsoft.Practices.EnterpriseLibrary.ExceptionHandling"
                                }
                            }.ToArray()
                    }
                };

			result.ExceptionPolicyConfiguration =
				new ExceptionPolicyConfiguration()
				{
					PolicyName = "securityFrameworkLog",
					ExceptionTypes = exceptionTypes.ToArray()
				};

			return result;
		}

		/// <summary>
		/// Would be generated log file with unique name
		/// </summary>
		/// <param name="pathToLog">Path to the generated log file</param>
		/// <returns></returns>
		private LoggingConfiguration CreateLoggingConfiguration(out string pathToLog)
		{
			pathToLog = string.Format(_pathToLogFormat, Guid.NewGuid());
			LoggingConfiguration result = new LoggingConfiguration();

			result.DefaultCategory = "General";

			result.Formatters =
				new List<LogFormatterConfiguration>()
                {
                    new LogFormatterConfiguration()
                    {
                        Name = "Text Formatter",
                        TypeName = "Microsoft.Practices.EnterpriseLibrary.Logging.Formatters.TextFormatter, Microsoft.Practices.EnterpriseLibrary.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                        Template = "Timestamp: {timestamp}{newline}\nMessage: {message}{newline}\nCategory: {category}{newline}\nPriority: {priority}{newline}\nEventId: {eventid}{newline}\nSeverity: {severity}{newline}\nTitle:{title}{newline}\nMachine: {localMachine}{newline}\nApp Domain: {localAppDomain}{newline}\nProcessId: {localProcessId}{newline}\nProcess Name: {localProcessName}{newline}\nThread Name: {threadName}{newline}\nWin32 ThreadId:{win32ThreadId}{newline}\nExtended Properties: {dictionary({key} - {value}{newline})}"
                    }
                }.ToArray();

			result.Listeners =
				new List<TraceListenerConfiguration>()
                {
                    new FlatFileTraceListenerConfiguration()
                    {
                        TypeName = "Microsoft.Practices.EnterpriseLibrary.Logging.TraceListeners.FlatFileTraceListener, Microsoft.Practices.EnterpriseLibrary.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                        Name = "FlatFileTraceListener",
                        ListenerDataType = "Microsoft.Practices.EnterpriseLibrary.Logging.Configuration.FlatFileTraceListenerData, Microsoft.Practices.EnterpriseLibrary.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                        FileName = pathToLog,
                        Formatter = "Text Formatter",
                        TraceOutputOptions = "DateTime, Timestamp, ProcessId",
                        Filter = SourceLevels.Verbose
                    },
					new MetraTech.SecurityFramework.Core.Common.Logging.Configuration.TraceListenerConfiguration()
					{
						Name = "MetraTechLogTraceListener",
						ListenerDataType = "MetraTech.SecurityFramework.MTLogging.Configuration.MetraTechLogTraceListenerData, MetraTech.SecurityFramework.MTLogging",
						Filter = SourceLevels.Verbose
					}
                }.ToArray();

			result.CategorySources =
				new List<EventCategorySourceConfiguration>()
                {
                    new EventCategorySourceConfiguration()
                    {
                        CategoryName = "General",
                        SwitchValue = SourceLevels.All,
                        Listeners = new List<string>() { "FlatFileTraceListener", "MetraTechLogTraceListener" }.ToArray()
                    }
                }.ToArray();

			result.Errors =
				new EventCategorySourceConfiguration()
				{
					CategoryName = "Logging Errors & Warnings",
					SwitchValue = SourceLevels.All,
					Listeners = new List<string>() { "FlatFileTraceListener", "MetraTechLogTraceListener" }.ToArray()
				};

			List<ExceptionTypeConfiguration> exceptionTypes =
				new List<ExceptionTypeConfiguration>()
                {
                    new ExceptionTypeConfiguration()
                    {
                        Name = "All Exceptions",
                        PostHandlingAction = Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.PostHandlingAction.NotifyRethrow,
                        TypeName = "System.Exception, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089",
                        ExceptionHandlers =
                            new List<ExceptionHandlerConfiguration>()
                            {
                                new ExceptionHandlerConfiguration()
                                {
                                    LogCategory = "General",
                                    Name ="Logging Exception Handler",
                                    EventId = 100,
                                    Severity = TraceEventType.Error,
                                    Priority = 0,
                                    Title = "Enterprise Library Exception Handling",
                                    TypeName = "Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Logging.LoggingExceptionHandler, Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Logging, Version=5.0.414.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35",
                                    FormatterType = "Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.TextExceptionFormatter, Microsoft.Practices.EnterpriseLibrary.ExceptionHandling"
                                }
                            }.ToArray()
                    }
                };

			result.ExceptionPolicyConfiguration =
				new ExceptionPolicyConfiguration()
				{
					PolicyName = "securityFrameworkLog",
					ExceptionTypes = exceptionTypes.ToArray()
				};

			return result;
		}

		private IErrorLogger CreateLogger()
		{
			Type loggerType = Type.GetType("MetraTech.SecurityFramework.Core.Common.Logging.EntLibErrorLogger, MetraTech.SecurityFramework.Core.Common", true);
			IErrorLogger result = Activator.CreateInstance(loggerType) as IErrorLogger;

			return result;
		}

		/// <summary>
		/// Checks the string existance in the Log file
		/// </summary>
		/// <param name="pathToLog">Path to the log file</param>
		/// <param name="stringToCheck">String that would be checked</param>
		/// <returns>true if the string exists in the Log</returns>
		private bool CheckLogContains(string pathToLog, string stringToCheck)
		{
			bool ret = false;
			if (System.IO.File.Exists(pathToLog))
			{
				var newPath = pathToLog + "1";

				System.IO.File.Copy(pathToLog, newPath);
				using (var reader = new System.IO.StreamReader(newPath))
				{
					ret = reader.ReadToEnd().Contains(stringToCheck);
				}
				try
				{
					System.IO.File.Delete(newPath);
				}
				catch (Exception)
				{

				}
			}
			return ret;
		} 

		#endregion
	}
}