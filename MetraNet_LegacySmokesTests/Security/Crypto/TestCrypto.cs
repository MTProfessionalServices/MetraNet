using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using MetraTech.Interop.RCD;
using MetraTech.Security.Crypto;
using MetraTech.Security.DPAPI;
using MetraTech.SecurityFramework;
using NUnit.Framework;


///nunit-console.exe /fixture:MetraTech.Security.Test.TestCrypto /assembly:O:\debug\bin\MetraTech.Security.Test.dll
namespace MetraTech.Security.Test
{
	[TestFixture]
  [Category("NoAutoRun")]
  public class TestCrypto
	{

		/// <summary>
		///    Runs once before any of the tests are run.
		/// </summary>
		[TestFixtureSetUp]
		public void Init()
		{
			//System.Threading.Thread.Sleep(30000);
			rcd = new MTRcdClass();
			mtSecurityFile = Path.Combine(rcd.ConfigDir, @"security\mtsecurity.xml");
			keyCfgFile = Path.Combine(rcd.ConfigDir, @"security\key.cfg");
			sessionKeysFile = Path.Combine(rcd.ConfigDir, @"security\sessionkeys.xml");

			Assert.IsTrue(File.Exists(sessionKeysFile), "Unable to find sessionkeys.xml");
			
			BackupFiles();
			GenerateConfigFilesForRsa();
			try
			{
				TestUtils.InitSecurityFramework();
				rsaCryptoManager = new RSACryptoManager();
				msCryptoManager = new MSCryptoManager();
			}
			catch (Exception)
			{
				RestoreFiles();
				throw;
			}
		}

		/// <summary>
		///   Runs once after all the tests are run.
		/// </summary>
		[TestFixtureTearDown]
		public void Dispose()
		{
			RestoreFiles();
			TestUtils.StopSecurityFramework();
		}

		#region DPAPI & Key Generation
		/// <summary>
		///   TestDPAPI
		/// </summary>
		[Test]
		[Category("TestDPAPI")]
		public void TestDPAPI()
		{
			string encryptedText = DPAPIWrapper.Encrypt(plainText);
			string decryptedText = DPAPIWrapper.Decrypt(encryptedText);

			Assert.AreEqual(plainText, decryptedText);
		}

		/// <summary>
		/// TestKeyGenerator
		/// </summary>
		[Test]
		[Category("TestKeyGenerator")]
		public void TestKeyGenerator()
		{
			string key1, iv1, key2, iv2;
			KeyGenerator.CreateKey(plainText, out key1, out iv1);
			KeyGenerator.CreateKey(plainText, out key2, out iv2);

			Assert.AreEqual(key1, key2, "Keys don't match");
			Assert.AreEqual(iv1, iv2, "Ivs don't match");
		}

		/// <summary>
		/// TestSessionKeyGeneration
		/// </summary>
		[Test]
		[Category("TestSessionKeyGeneration")]
		public void TestSessionKeyGeneration()
		{
			CryptoInstall cryptoInstall = new CryptoInstall();
			object[] mtKeyClassNames = cryptoInstall.KeyClassNames;
			object[] keys = new object[mtKeyClassNames.Length];

			for (int i = 0; i < mtKeyClassNames.Length; i++)
			{
				keys[i] = mtKeyClassNames[i] + "_key";
			}

			cryptoInstall.GenerateSessionKeys(mtKeyClassNames, keys, false);

			MSCryptoConfig msCryptoConfig = MSCryptoConfig.GetInstance();
			Assert.IsNotNull(msCryptoConfig.SessionKeyConfig);

			for (int i = 0; i < mtKeyClassNames.Length; i++)
			{
				string keyClassName = (string)mtKeyClassNames[i];

				KeyClass keyClass = msCryptoConfig.SessionKeyConfig.GetKeyClass(keyClassName);
				Assert.IsNotNull(keyClass);
				Key key = keyClass.GetCurrentKey();
				Assert.IsNotNull(key);
				Assert.AreEqual(keyClassName + "_key", DPAPIWrapper.Decrypt(key.Secret.Text));
			}
		}

		/// <summary>
		///   TestUpdateKMSConfig
		/// </summary>
		[Test]
		[Category("TestUpdateKMSConfig")]
		public void TestUpdateKMSConfig()
		{
			try
			{
				CryptoInstall cryptoInstall = new CryptoInstall();

				string kmsServer = "engdemo-1";
				string clientCert = Path.Combine(rcd.ConfigDir, @"security\client1.pfx");
				string clientPwd = "dsg20056";
				object[] mtKeyClassNames = new object[6];

				mtKeyClassNames[0] = "PaymentInstrument";
				mtKeyClassNames[1] = "DatabasePassword";
				mtKeyClassNames[2] = "ServiceDefProp";
				mtKeyClassNames[3] = "QueryString";
				mtKeyClassNames[4] = "PasswordHash";
				mtKeyClassNames[5] = "PaymentMethodHash";

				object[] rsaKeyClassNames = new object[6];
				rsaKeyClassNames[0] = "Microsoft_PaymentInstrument";
				rsaKeyClassNames[1] = "Microsoft_DatabasePassword";
				rsaKeyClassNames[2] = "Microsoft_ServiceDefProp";
				rsaKeyClassNames[3] = "Microsoft_QueryString";
				rsaKeyClassNames[4] = "Microsoft_PasswordHash";
				rsaKeyClassNames[5] = "Microsoft_PaymentMethodHash";

				cryptoInstall.UpdateKMSConfig(kmsServer, clientCert, clientPwd, mtKeyClassNames, rsaKeyClassNames, "ticketingKey", false);
				RSAConfig rsaConfig = CryptoConfig.GetInstance().RSAConfig;
				Assert.AreEqual(clientPwd, DPAPIWrapper.Decrypt(rsaConfig.KmsCertificatePwd.Password));

				int i = 0;
				foreach (KMSKeyClass kmsKeyClass in rsaConfig.KMSKeyClasses)
				{
					string origKmsKeyClass = (string)rsaKeyClassNames[i];
					Assert.IsTrue(String.Equals(origKmsKeyClass, kmsKeyClass.Name));
					i++;
				}

				// Check key.cfg
				bool foundClientCert = false;
				bool foundKMSServer = false;

				string[] keyCfgLines = File.ReadAllLines(rsaConfig.KmsClientConfigFile);
				foreach (string keyCfgLine in keyCfgLines)
				{
					if (keyCfgLine.StartsWith("kms.sslPKCS12File"))
					{
						string[] parts = keyCfgLine.Split(new string[] { "=" }, StringSplitOptions.RemoveEmptyEntries);
						Assert.AreEqual(clientCert, parts[1].Trim());
						foundClientCert = true;
					}

					if (keyCfgLine.StartsWith("kms.address"))
					{
						string[] parts = keyCfgLine.Split(new string[] { "=" }, StringSplitOptions.RemoveEmptyEntries);
						Assert.AreEqual(kmsServer, parts[1].Trim());
						foundKMSServer = true;
					}
				}

				Assert.IsTrue(foundClientCert);
				Assert.IsTrue(foundKMSServer);

				// Check sessionkeys.xml 
				MSCryptoConfig msCryptoConfig = MSCryptoConfig.GetInstance();
				Assert.IsNotNull(msCryptoConfig.SessionKeyConfig);

				Key key = null;
				for (i = 0; i < mtKeyClassNames.Length; i++)
				{
					string keyClassName = (string)mtKeyClassNames[i];
					KeyClass keyClass = msCryptoConfig.SessionKeyConfig.GetKeyClass(keyClassName);
					Assert.IsNotNull(keyClass);
					key = keyClass.GetCurrentKey();
					Assert.IsNotNull(key);
					Assert.AreEqual(keyClassName, DPAPIWrapper.Decrypt(key.Secret.Text));
				}

				KeyClass ticketingKeyClass = msCryptoConfig.SessionKeyConfig.GetKeyClass(CryptKeyClass.Ticketing.ToString());
				Assert.IsNotNull(ticketingKeyClass);
				key = ticketingKeyClass.GetCurrentKey();
				Assert.IsNotNull(key);
				Assert.AreEqual("ticketingKey", DPAPIWrapper.Decrypt(key.Secret.Text));
			}
			finally
			{
				// Preventing crushes in subsequent tests due to this one changes mtsecurity.xml config file.
				GenerateConfigFilesForRsa();
			}
		}

		#endregion

		#region Test RSA
		/// <summary>
		/// TestRSAEncryptDecrypt
		/// </summary>
		[Test]
		[Category("TestRSAEncryptDecrypt")]
		public void TestRSAEncryptDecrypt()
		{
			try
			{
				TestEncryptDecrypt(rsaCryptoManager);
			}
			catch (Exception e)
			{
				logger.LogException("TestRSAEncryptDecrypt failed", e);
				Assert.Fail("TestRSAEncryptDecrypt failed");
			}
		}

		/// <summary>
		/// TestRSAHash
		/// </summary>
		[Test]
		[Category("TestRSAHash")]
		public void TestRSAHash()
		{
			try
			{
				TestHash(rsaCryptoManager);
			}
			catch (Exception e)
			{
				logger.LogException("TestRSAHash failed", e);
				Assert.Fail("TestRSAHash failed");
			}
		}

		/// <summary>
		///   TestRSAHashWithKey
		/// </summary>
		[Test]
		[Category("TestRSAHashWithKey")]
		public void TestRSAHashWithKey()
		{
			try
			{
				TestHashWithKey(rsaCryptoManager);
			}
			catch (Exception e)
			{
				logger.LogException("TestRSAHashWithKey failed", e);
				Assert.Fail("TestRSAHashWithKey failed");
			}

		}

		/// <summary>
		///   TestRSACompareHash
		/// </summary>
		[Test]
		[Category("TestRSACompareHash")]
		public void TestRSACompareHash()
		{
			try
			{
				TestCompareHash(rsaCryptoManager);
			}
			catch (Exception e)
			{
				logger.LogException("TestRSACompareHash failed", e);
				Assert.Fail("TestRSACompareHash failed");
			}
		}

		/// <summary>
		///   TestRSAParseKeyFromHash
		/// </summary>
		[Test]
		[Category("TestRSAParseKeyFromHash")]
		public void TestRSAParseKeyFromHash()
		{
			try
			{
				TestParseKeyFromHash(rsaCryptoManager);
			}
			catch (Exception e)
			{
				logger.LogException("TestRSAParseKeyFromHash failed", e);
				Assert.Fail("TestRSAParseKeyFromHash failed");
			}
		}

		#endregion

		#region Test MS
		/// <summary>
		/// TestMSEncryptDecrypt
		/// </summary>
		[Test]
		[Category("TestMSEncryptDecrypt")]
		public void TestMSEncryptDecrypt()
		{
			TestEncryptDecrypt(msCryptoManager);
		}

		/// <summary>
		/// TestMSHash
		/// </summary>
		[Test]
		[Category("TestMSHash")]
		public void TestMSHash()
		{
			TestHash(msCryptoManager);
		}

		/// <summary>
		///   TestMSHashWithKey
		/// </summary>
		[Test]
		[Category("TestMSHashWithKey")]
		public void TestMSHashWithKey()
		{
			TestHashWithKey(msCryptoManager);
		}

		/// <summary>
		///   TestMSCompareHash
		/// </summary>
		[Test]
		[Category("TestMSCompareHash")]
		public void TestMSCompareHash()
		{
			TestCompareHash(msCryptoManager);
		}

		/// <summary>
		///   TestMSParseKeyFromHash
		/// </summary>
		[Test]
		[Category("TestMSParseKeyFromHash")]
		public void TestMSParseKeyFromHash()
		{
			TestParseKeyFromHash(msCryptoManager);
		}

		#endregion

		#region Private Methods
		private void GenerateConfigFilesForRsa()
		{
			// Generate mtsecurity.xml
			CryptoConfig cryptoConfig = CryptoConfig.GetInstance();
			cryptoConfig.CryptoTypeName = "MetraTech.Security.Crypto.RSACryptoManager";

			RSAConfig rsaConfig = new RSAConfig();
			cryptoConfig.RSAConfig = rsaConfig;

			rsaConfig.KmsClientConfigFile = Path.Combine(rcd.ConfigDir, @"security\key.cfg");
			Assert.IsTrue(File.Exists(rsaConfig.KmsClientConfigFile), "Unable to find key.cfg");
			rsaConfig.KmsCertificatePwd = new CertificatePassword();
			rsaConfig.KmsCertificatePwd.Password = "dsg20056";

			KMSKeyClass[] kmsKeyClasses = new KMSKeyClass[6];
			rsaConfig.KMSKeyClasses = kmsKeyClasses;

			KMSKeyClass paymentInstrument = new KMSKeyClass();
			paymentInstrument.Id = CryptKeyClass.PaymentInstrument.ToString();
			paymentInstrument.Name = "CreditCardNumber";
			kmsKeyClasses[0] = paymentInstrument;

			KMSKeyClass databasePassword = new KMSKeyClass();
			databasePassword.Id = CryptKeyClass.DatabasePassword.ToString();
			databasePassword.Name = "CreditCardNumber";
			kmsKeyClasses[1] = databasePassword;

			KMSKeyClass serviceDefProp = new KMSKeyClass();
			serviceDefProp.Id = CryptKeyClass.ServiceDefProp.ToString();
			serviceDefProp.Name = "CreditCardNumber";
			kmsKeyClasses[2] = serviceDefProp;

			KMSKeyClass queryString = new KMSKeyClass();
			queryString.Id = CryptKeyClass.QueryString.ToString();
			queryString.Name = "CreditCardNumber";
			kmsKeyClasses[3] = queryString;

			KMSKeyClass passwordHash = new KMSKeyClass();
			passwordHash.Id = HashKeyClass.PasswordHash.ToString();
			passwordHash.Name = "PasswordHash";
			kmsKeyClasses[4] = passwordHash;

			KMSKeyClass paymentMethodHash = new KMSKeyClass();
			paymentMethodHash.Id = HashKeyClass.PaymentMethodHash.ToString();
			paymentMethodHash.Name = "PaymentInstHash";
			kmsKeyClasses[5] = paymentMethodHash;

			cryptoConfig.Write();
		}

		private void TestEncryptDecrypt(ICryptoManager cryptoManager)
		{
			CryptoParameters parameters1 = new CryptoParameters();
			parameters1.CryptoMan = cryptoManager;

			Thread t1 = new Thread(TestEncryptDecryptThread);
			t1.Start(parameters1);

			Thread t2 = new Thread(TestEncryptDecryptThread);
			t2.Start(parameters1);

			t1.Join();
			t2.Join();
		}

		internal class CryptoParameters
		{
			public ICryptoManager CryptoMan;
		}

		private void TestEncryptDecryptThread(object parameters)
		{
			ICryptoManager cryptoManger = ((CryptoParameters)parameters).CryptoMan as ICryptoManager;
			for (int i = 0; i < 100; i++)
			{
				string cipherText = cryptoManger.Encrypt(CryptKeyClass.PaymentInstrument, plainText);
				string decryptedText = cryptoManger.Decrypt(CryptKeyClass.PaymentInstrument, cipherText);
				Assert.AreEqual(plainText, decryptedText, "Decrypted string does not match original string");
			}
		}

		private void TestHash(ICryptoManager cryptoManager)
		{
			string hash = cryptoManager.Hash(HashKeyClass.PasswordHash, plainText);
			string newHash = cryptoManager.Hash(HashKeyClass.PasswordHash, plainText);
			Assert.AreEqual(hash, newHash, "Hash does not match");
		}

		private void TestHashWithKey(ICryptoManager cryptoManager)
		{
			string hash = cryptoManager.Hash(HashKeyClass.PasswordHash, plainText);
			string key = cryptoManager.ParseKeyFromHash(hash);
			Assert.IsNotNull(key);

			string newHash = cryptoManager.HashWithKey(HashKeyClass.PasswordHash, key, plainText);
			Assert.AreEqual(hash, newHash, "Hash does not match");
		}

		private void TestCompareHash(ICryptoManager cryptoManager)
		{
			string hash = cryptoManager.Hash(HashKeyClass.PasswordHash, plainText);
			bool areEqual = cryptoManager.CompareHash(HashKeyClass.PasswordHash, hash, plainText);
			Assert.IsTrue(areEqual, "Hash does not match");
		}

		private void TestParseKeyFromHash(ICryptoManager cryptoManager)
		{
			string hash = cryptoManager.Hash(HashKeyClass.PasswordHash, plainText);
			string key = cryptoManager.ParseKeyFromHash(hash);
			string newHash = cryptoManager.HashWithKey(HashKeyClass.PasswordHash, key, plainText);
			string newKey = cryptoManager.ParseKeyFromHash(newHash);

			Assert.AreEqual(key, newKey, "Hash keys don't match");
		}

		private void BackupFiles()
		{
			File.Copy(mtSecurityFile, mtSecurityFile + ".original", true);
			File.Copy(keyCfgFile, keyCfgFile + ".original", true);
			File.Copy(sessionKeysFile, sessionKeysFile + ".original", true);
		}

		private void RestoreFiles()
		{
			if (File.Exists(mtSecurityFile + ".original"))
			{
				File.Copy(mtSecurityFile + ".original", mtSecurityFile, true);
				File.Delete(mtSecurityFile + ".original");
			}

			if (File.Exists(keyCfgFile + ".original"))
			{
				File.Copy(keyCfgFile + ".original", keyCfgFile, true);
				File.Delete(keyCfgFile + ".original");
			}

			if (File.Exists(sessionKeysFile + ".original"))
			{
				File.Copy(sessionKeysFile + ".original", sessionKeysFile, true);
				File.Delete(sessionKeysFile + ".original");
			}
		}

		#endregion

		#region Data
		private const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
		private RSACryptoManager rsaCryptoManager;
		private MSCryptoManager msCryptoManager;
		private string mtSecurityFile;
		private string keyCfgFile;
		private string sessionKeysFile;
		private IMTRcd rcd;

		public static readonly Logger logger = new Logger("[MetraTech.Security.TestCrypto]");

		#endregion
	}
}
