using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Security.Cryptography;

using NUnit.Framework;
using MetraTech.Security;
using MetraTech.Security.Crypto;
using MetraTech.Security.DPAPI;

///nunit-console.exe /fixture:MetraTech.Security.Test.TestCryptoSetup /assembly:O:\debug\bin\MetraTech.Security.Test.dll
namespace MetraTech.Security.Test
{
	[TestFixture]
  [Category("NoAutoRun")]
  public class TestCryptoSetup
	{

		/// <summary>
		///    Runs once before any of the tests are run.
		/// </summary>
		[TestFixtureSetUp]
		public void Init()
		{
			TestUtils.InitSecurityFramework();
			// Backup RMP\config\security\sessionkeys.xml
			sessionKeyConfig = MSSessionKeyConfig.GetInstance();
			if (File.Exists(sessionKeyConfig.KeyFile))
			{
				sessionKeyBackupFile = sessionKeyConfig.KeyFile + ".bak";
				if (File.Exists(sessionKeyBackupFile))
				{
					File.Delete(sessionKeyBackupFile);
				}

				File.Move(sessionKeyConfig.KeyFile, sessionKeyBackupFile);
			}
		}

		/// <summary>
		///   Runs once after all the tests are run.
		/// </summary>
		[TestFixtureTearDown]
		public void Dispose()
		{
			// Restore RMP\config\security\sessionkeys.xml
			if (!String.IsNullOrEmpty(sessionKeyBackupFile))
			{
				if (File.Exists(sessionKeyConfig.KeyFile))
				{
					File.Delete(sessionKeyConfig.KeyFile);
				}

				File.Copy(sessionKeyBackupFile, sessionKeyConfig.KeyFile);
				File.Delete(sessionKeyBackupFile);
			}

			TestUtils.StopSecurityFramework();
		}

		/// <summary>
		/// TestCreateSessionKeys
		/// </summary>
		[Test]
		[Category("TestCreateSessionKeysWithDefaultPassword")]
    public void T01TestCreateSessionKeysWithDefaultPassword()
		{
			TestSessionKeys(null);
		}

		/// <summary>
		/// TestCreateSessionKeys
		/// </summary>
		[Test]
		[Category("TestCreateSessionKeys")]
    public void T02TestSessionKeysWithPassword()
		{
			TestSessionKeys("some password with funny characters !@#$%^&*()_+=:\"{}[]/?.,><");
		}

		/// <summary>
		/// TestCreateKey
		/// </summary>
		[Test]
		[Category("TestCreateKey")]
    public void T03TestCreateKey()
		{
			// Create new session keys for the 'DatabasePassword' key class
			MSCryptoManager cryptoManager = new MSCryptoManager();
			string password = "pa$$w0rd";
			cryptoManager.CreateKey(CryptKeyClass.DatabasePassword.ToString(), password);

			// Check that one key got created for DatabasePassword with the given password.
			MSSessionKeyConfig keyConfig = MSSessionKeyConfig.GetInstance();
			keyConfig.Initialize();

			KeyClass keyClass = keyConfig.GetKeyClass(CryptKeyClass.DatabasePassword.ToString());
			Assert.AreEqual(1, keyClass.Keys.Length);
			Key key = keyClass.Keys[0];
			Assert.IsNotNull(key);
			Assert.IsTrue(key.IsCurrent);
			Assert.IsNotNull(key.Id);
			Assert.IsNotNull(key.IV);
			Assert.IsNotNull(key.Value);
			Assert.IsNotNull(key.Secret);
			Assert.AreEqual(password, DPAPIWrapper.Decrypt(key.Secret.Text));
		}

		/// <summary>
		/// TestCreateKey
		/// </summary>
		[Test]
		[Category("TestAddKey")]
    public void T04TestAddKey()
		{
			// Create new session keys for the 'DatabasePassword' key class
			MSCryptoManager cryptoManager = new MSCryptoManager();
			string password = "pa$$w0rd";
			Guid id = Guid.NewGuid();
			cryptoManager.AddKey(CryptKeyClass.DatabasePassword.ToString(), password, id, true);

			// Check that one key got created for DatabasePassword with the given password.
			MSSessionKeyConfig keyConfig = MSSessionKeyConfig.GetInstance();
			keyConfig.Initialize();

			KeyClass keyClass = keyConfig.GetKeyClass(CryptKeyClass.DatabasePassword.ToString());
			Key key = keyClass.GetKey(id);
			Assert.IsNotNull(key);
			Assert.IsTrue(key.IsCurrent);
			Assert.IsNotNull(key.Id);
			Assert.AreEqual(key.Id.ToString(), id.ToString());
			Assert.IsNotNull(key.IV);
			Assert.IsNotNull(key.Value);
			Assert.IsNotNull(key.Secret);
			Assert.AreEqual(password, DPAPIWrapper.Decrypt(key.Secret.Text));
		}

		/// <summary>
		/// TestCreateKey
		/// </summary>
		[Test]
		[Category("TestMakeKeyCurrent")]
    public void T05TestMakeKeyCurrent()
		{
			// Create new session keys for the 'DatabasePassword' key class
			MSCryptoManager cryptoManager = new MSCryptoManager();
			string password = "pa$$w0rd";
			Guid id = Guid.NewGuid();
			cryptoManager.AddKey(CryptKeyClass.DatabasePassword.ToString(), password, id, false);

			// Check that one key got created for DatabasePassword with the given password.
			MSSessionKeyConfig keyConfig = MSSessionKeyConfig.GetInstance();
			keyConfig.Initialize();

			KeyClass keyClass = keyConfig.GetKeyClass(CryptKeyClass.DatabasePassword.ToString());
			Key key = keyClass.GetKey(id);
			Assert.IsNotNull(key);
			Assert.IsFalse(key.IsCurrent);
			Assert.IsNotNull(key.Id);
			Assert.AreEqual(key.Id.ToString(), id.ToString());
			Assert.IsNotNull(key.IV);
			Assert.IsNotNull(key.Value);
			Assert.IsNotNull(key.Secret);
			Assert.AreEqual(password, DPAPIWrapper.Decrypt(key.Secret.Text));

			cryptoManager.MakeKeyCurrent(id);
			keyConfig.Initialize();
			keyClass = keyConfig.GetKeyClass(CryptKeyClass.DatabasePassword.ToString());

			key = keyClass.GetKey(id);
			Assert.IsNotNull(key);
			Assert.IsTrue(key.IsCurrent);
			Assert.IsNotNull(key.Id);
			Assert.IsNotNull(key.IV);
			Assert.IsNotNull(key.Value);
			Assert.IsNotNull(key.Secret);
			Assert.AreEqual(password, DPAPIWrapper.Decrypt(key.Secret.Text));

			foreach (Key key1 in keyClass.Keys)
			{
				if (key1.Id.Equals(id))
				{
					Assert.IsTrue(key1.IsCurrent);
				}
				else
				{
					Assert.IsFalse(key1.IsCurrent);
				}
			}
		}

		/// <summary>
		/// TestEncryptDecryptWithCustomKey
		/// </summary>
		[Test]
		[Category("TestEncryptDecryptWithCustomKey")]
    public void T06TestEncryptDecryptWithCustomKey()
		{
			// Create new session keys for the 'DatabasePassword' key class
			MSCryptoManager cryptoManager = new MSCryptoManager();
			string password = "mtkey";
			cryptoManager.CreateSessionKeys(password);

			string cipherText = cryptoManager.Encrypt(CryptKeyClass.DatabasePassword, "abcde");
			string plainText = cryptoManager.Decrypt(CryptKeyClass.DatabasePassword, cipherText);
			Assert.AreEqual("abcde", plainText);
		}


		#region Private Methods
		private void TestSessionKeys(string password)
		{
			// Create new session keys
			MSCryptoManager cryptoManager = new MSCryptoManager();
			cryptoManager.CreateSessionKeys(password);

			// Check that one key got created for each key class with the hardcoded guid.
			MSSessionKeyConfig keyConfig = MSSessionKeyConfig.GetInstance();
			keyConfig.Initialize();

			string error;
			Assert.IsTrue(keyConfig.IsValid(out error));

			Dictionary<string, string> expectedKeyIds = MSCryptoManager.GetKeyIds();
			Dictionary<string, string> keyIds = new Dictionary<string, string>();

			// Store the generated key classes
			Key key = null;
			string secret = null;

			foreach (KeyClass keyClass in keyConfig.KeyClasses)
			{
				Assert.IsNotNull(keyClass.Keys);
				Assert.AreEqual(1, keyClass.Keys.Length);
				key = keyClass.Keys[0];
				keyIds.Add(key.Id.ToString(), null);

				// Check that the key secret can be decrypted and matches the key class name
				secret = DPAPIWrapper.Decrypt(key.Secret.Text);
				if (password == null)
				{
					Assert.AreEqual(keyClass.Name, secret);
				}
				else
				{
					Assert.AreEqual(password, secret);
				}
			}

			// Check that the keys match
			foreach (string keyId in expectedKeyIds.Values)
			{
				Assert.IsTrue(keyIds.ContainsKey(keyId));
			}
		}
		#endregion

		#region Data
		private string sessionKeyBackupFile;
		MSSessionKeyConfig sessionKeyConfig;
		#endregion
	}
}
