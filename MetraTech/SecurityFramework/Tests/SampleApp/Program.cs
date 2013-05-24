/**************************************************************************
* Copyright 1997-2010 by MetraTech
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
* Authors: 
*
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Detector;
using MetraTech.SecurityFramework.Core.Detector.Engine;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;
using MetraTech.SecurityFramework.Core.Validator;
//using MetraTech.SecurityFrameworkUnitTests;
using MetraTech.Security.Crypto;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;

namespace SampleApp
{
	class SecurityPolicyActionHandler : ISecurityPolicyActionHandler
	{
		public void Register()
		{
			//SecurityKernel.SecurityMonitor.ControlApi.AddPolicyActionHandler("MyApp", SecurityPolicyActionType.All,this);
		}

		public void Handle(PolicyAction policyAction, ISecurityEvent securityEvent)
		{
		}
	}

	class Program
	{
		static void Main(string[] args)
		{
			//PerformanceMonitor.CheckCounters();
			//string toSerialize = "(?:&#\\d{2,4};){7,}";
			//ConfigurationLoaderForTesting conf = new ConfigurationLoaderForTesting();
			//conf.WriteDataToXml<string>(toSerialize, "toSerialize.xml");

			//SimpleXssDetectorPropertiesConfigured props = new SimpleXssDetectorPropertiesConfigured();
			//ConfigurationLoaderForTesting conf = new ConfigurationLoaderForTesting();
			//conf.WriteDataToXml<GenericSimpleXssDetectorProperties<PatternWeight>>(props.DetectionParams, "SimpleXssDetectorProperties.xml");

			Console.WriteLine("==================================================");
			Console.WriteLine("Sample Security Framework test application started");
			Console.WriteLine("==================================================\n\n");

			try
			{
				string sfPropsStoreLocation = Directory.GetCurrentDirectory() + @"\MtSfConfigurationLoader.xml";
				ISerializer serializer = new XmlSerializer();
				SecurityKernel.Initialize(serializer, sfPropsStoreLocation);

				TestGetPIInstace();

				//TestOrmReference();
				//TestOrmObject();
				
				//TestDefaultXssInjectionDetector();

				//TestDefaultSqlInjectionDetectorWithDataSet();
				//TestDefaultSqlInjectionDetector();
				//TestDefaultBadDetectors();
				//TestDefaultEncoders();
				//TestDefaultIntValidatorsWithExtensions();
				//TestDefaultIntValidatorsWithExtensionsAsBasicInt();
				//TestUserAndDefaultIntValidators();

				SecurityKernel.Stop();
				SecurityKernel.Shutdown();

				//Console.ReadLine();
			}
			catch (SubsystemAccessException x)
			{
				Console.WriteLine(x.Message);
			}
			catch (SubsystemApiAccessException x)
			{
				Console.WriteLine(x.Message);
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}

			Console.WriteLine("\n\n===============================================");
			Console.WriteLine("Sample Security Framework test application done");
			Console.WriteLine("===============================================");
			Console.WriteLine("Press any key to exit...");
			Console.ReadKey();
		}

		public static void TestGetPIInstace()
		{
			ProductOfferingServiceClient client1 = new ProductOfferingServiceClient("NetTcpBinding_IProductOfferingService");
			client1.ClientCredentials.UserName.UserName = "su";
			client1.ClientCredentials.UserName.Password = "su123";
			PCIdentifier POIndent = new PCIdentifier("ESRTest");
			PCIdentifier PIIdent = new PCIdentifier("SetupCharge");
			BasePriceableItemInstance baseInstance = null;

			client1.GetPIInstanceForPO(POIndent, PIIdent, out baseInstance);
			NonRecurringChargePIInstance nrcInstance = baseInstance as NonRecurringChargePIInstance;

			Console.WriteLine(nrcInstance.Name);
			Console.WriteLine(string.Format("Number of schedules: {0}", ((MetraTech.DomainModel.ProductCatalog.Flat_Rate_Non_Recurring_ChargePIInstance)(nrcInstance)).Metratech_com_nonrecurringcharge_RateSchedules.Count));
		} 

		private static void TestOrmReference()
		{
			ApiInput input = new ApiInput("54DDB15A-715F-4D2E-9084-2B550E86892E");
			string output = SF.FromTokenDynamic(input.ToString());
		}

		private static void TestOrmObject()
		{
			ApiInput input = new ApiInput("C:\\dev\\Current\\RMP\\ExtensionS\\Account\\Config\\GridLayouts\\AccountListLayoutTemplate.xml");
			string output = SF.ToTokenDynamic(input.ToString());
		}

		private static void TestDefaultSqlInjectionDetector()
		{
			try
			{
				string testInputParam = "500' OR 1=1--";

				testInputParam.DetectSql();

				Console.WriteLine(string.Format("SQL injections not found in: {0}", testInputParam));
			}
			catch (DetectorInputDataException x)
			{
				Console.WriteLine("SQL injection found. Engine ID - " + x.Message);
				x.Report();
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}
		}

		private static void TestDefaultBadDetectors()
		{
			try
			{
				string testInputParam = "500' OR 1=1--";

				testInputParam.DetectBad();

				Console.WriteLine(string.Format("Bad data not found in: {0}", testInputParam));
			}
			catch (DetectorInputDataException x)
			{
				Console.WriteLine("Bad data found. Engine ID - " + x.Message);
				x.Report();
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}
		}

		private static void TestDefaultEncoders()
		{
			try
			{
				string testInputParam = "<script>alert('hi')</script>";
				string encodedInputParam;

				Console.WriteLine("Input param for encoding: " + testInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForUrl();
				Console.WriteLine("Input param encoded for URL: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForHtml();
				Console.WriteLine("Input param encoded for HTML: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForHtmlAttribute();
				Console.WriteLine("Input param encoded for HTML attribute: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForCss();
				Console.WriteLine("Input param encoded for CSS: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForJavaScript();
				Console.WriteLine("Input param encoded for JavaScript: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForXml();
				Console.WriteLine("Input param encoded for XML: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForXmlAttribute();
				Console.WriteLine("Input param encoded for XML attribute: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForVbScript();
				Console.WriteLine("Input param encoded for VbScript: " + encodedInputParam + '\n');

				encodedInputParam = testInputParam.EncodeForLdap();
				Console.WriteLine("Input param encoded for Ldap: " + encodedInputParam + '\n');
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}
		}

		private static void TestUserAndDefaultIntValidators()
		{
			try
			{
				string idEngine = SecurityKernel.Validator.ControlApi.GenerateIdEngine();

				//MyIntValidatorEngine myIntValidatorEngine = new MyIntValidatorEngine();
				//myIntValidatorEngine.Initialize(idEngine, "");

				//SecurityKernel.Validator.ControlApi.AddEngine(myIntValidatorEngine);

				//string defaultId = ValidatorEngineCategory.BasicInt + ".Default";
				ApiOutput oResult = SecurityKernel.Validator.Api.Execute(idEngine, new ApiInput("5"));

				Console.WriteLine(string.Format("Valid value: {0}", oResult.OfType<int>()));

				if (SecurityKernel.Validator.Api.HasEngine(idEngine))
				{
					IEngine validatorEngine = SecurityKernel.Validator.Api.GetEngine(idEngine);

					oResult = validatorEngine.Execute(new ApiInput("100"));
					Console.WriteLine(string.Format("Valid value: {0}", oResult.OfType<int>()));
				}
			}
			catch (ValidatorInputDataException x)
			{
				Console.WriteLine("Invalid input data found. Engine ID - " + x.Message);
				x.Report();
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}
		}

		private static void TestDefaultIntValidatorsWithExtensions()
		{
			string defaultEngineId = ValidatorEngineCategory.BasicInt + ".Default";

			try
			{
				string testInputParam = "500";

				int myValue = (int)testInputParam.ValidateWithEngine(defaultEngineId);

				Console.WriteLine(string.Format("Input value is: {0}", myValue));
			}
			catch (ValidatorInputDataException x)
			{
				Console.WriteLine("Invalid input data found. Engine ID - " + x.Message);
				x.Report();
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}
		}

		private static void TestDefaultIntValidatorsWithExtensionsAsBasicInt()
		{
			try
			{
				string testInputParam = "500' OR 1=1--";

				int myValue = testInputParam.ValidateAsBasicInt();

				Console.WriteLine(string.Format("Input value is: {0}", myValue));
			}
			catch (ValidatorInputDataException x)
			{
				Console.WriteLine("Invalid input data found. Engine ID - " + x.Message);
				x.Report();
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}
		}

		private static void TestDefaultSqlInjectionDetectorWithDataSet()
		{
			string goodData = "500";

			int max = mSqlInjections.Length;
			for (int i = 0; i < max; i++)
			{
				string testInputParam = goodData + mSqlInjections[i];

				try
				{
					testInputParam.DetectSql();

					Console.WriteLine(string.Format("SQL injections not found in [idx:{0}]: {1}", i, testInputParam));
				}
				catch (DetectorInputDataException x)
				{
					Console.WriteLine(string.Format("SQL injection found [idx:{0}]. Engine ID - {1}: {2}", i, x.Message, testInputParam));
					x.Report();
				}
				catch (Exception x)
				{
					Console.WriteLine(x.Message);
				}
			}
		}

		private static void TestDefaultXssInjectionDetector()
		{
			try
			{
				string testInputParam = "<SCRIPT>alert('hi')</script>";

				testInputParam.DetectXss();


				Console.WriteLine(string.Format("XSS injections not found in: {0}", testInputParam));
			}
			catch (DetectorInputDataException x)
			{
				Console.WriteLine("XSS injection found. Engine ID - " + x.Message);
				x.Report();
			}
			catch (Exception x)
			{
				Console.WriteLine(x.Message);
			}
		}

		static private string[] mSqlInjections =
        {
            @"' or 1=1--", 
            @"' or/**/1=1--", 
            @"'/**/or/**/1=1--", 
            @"'/* random */or/* junk */3=3--", 
            @"' or 7=7 or 'x'='y", 
            @"' or 'b'='b", 
            @"' or '1'='1'--",
            @"' or a=a--",
            @"' or 'a'='a",
            @"' or 0=0 --",
            @"' or '1'='1'--",
            @"'exec master..xp_cmdshell 'nslookup www.google.com'--",
            @"';DROP TABLE users; SELECT * FROM userinfo WHERE 't' = 't",
            @"' AND dummy_fake_table = '1",
            @"' AND ASCII(LOWER(SUBSTRING((SELECT TOP 1 name FROM sysobjects WHERE xtype='U'), 1, 1))) > 116",
            @"' UNION ALL SELECT 1,2,3,4,5,6,name FROM sysObjects WHERE xtype = 'U' --",
            @"' UNION/* */ALL SELECT 1,2,3,4,5,6,name FROM sysObjects WHERE xtype = 'U' --",
            @"' SELECT/*comment separator*/password/**/FROM/**/Members",
            @"' SELECT * FROM Members; DROP TABLE Members--",
            @"' DROP table dummytable;--", 
            @"' DROP/*fillter comment*/table/*x*/dummytable",  
            @"' DROP/*fillter comment*/TabLe dummytable",
            @"' IF (1=1) SELECT 'true' ELSE SELECT 'false'",
            @"' if ((select user) = 'sa' OR (select user) = 'dbo') select 1 else select 1/0",
            @"' SELECT CHAR(0x66)",
            @"' SELECT login + '-' + password FROM members ",
            @"' SELECT CHAR(75)+CHAR(76)+CHAR(77)",
            @"' SELECT CHAR(64)",
            @"' UNION SELECT 1, 'anotheruser', 'doesnt matter', 1--",
            @"' HAVING 1=1 --",
            @"' ORDER BY 1--",
            @"' ORDER BY 2--",
            @"'; insert into users values( 1, 'BadUser', 'goodpass', 9 )--",
            @"' EXEC master.dbo.xp_cmdshell 'cmd.exe dir c:'",
            @"' exec master..xp_cmdshell 'dir'", 
            @"' exec xp_regread HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Services\lanmanserver\parameters', 'nullsessionshares'",
            @"';shutdown --",
            @"';waitfor delay '0:0:10'--",
            @"' PRINT @@variable",
            @"'; PRINT @@variable",
            @"'; exec master..xp_cmdshell",
            @"'; exec xp_regread",
            @"'exec master..xp_cmdshell 'nslookup www.google.com'--"
        };
	}



	class MyIntValidatorEngine : ValidatorEngineBase
	{

		internal MyIntValidatorEngine()
			: base(ValidatorEngineCategory.BasicInt) { }

		public Type ResultType
		{
			get { return typeof(int); }
		}

		protected override ApiOutput ValidateInternal(ApiInput input)
		{
			object result = null;

			int var;
			if (!int.TryParse(input.ToString(), out var))
				throw new ValidatorInputDataException(ExceptionId.Validator.InputValueIsNotInteger, ValidatorEngineCategory.BasicInt, "MyIntValidatorEngine", input.ToString(), "Input value is not integer.");

			if ((var < 10) || (var > 1000))
				throw new ValidatorInputDataException(ExceptionId.Validator.InputIntegerNotInRange, ValidatorEngineCategory.BasicInt, "MyIntValidatorEngine", input.ToString(), "Input integer is not in range.");

			result = var;

			return new ApiOutput(result);
		}
	}
}
