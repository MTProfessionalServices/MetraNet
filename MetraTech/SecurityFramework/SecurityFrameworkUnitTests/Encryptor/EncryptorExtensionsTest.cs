using System.Collections.Generic;
using System.Threading;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace MetraTech.SecurityFrameworkUnitTests
{
	/// <summary>
	///This is a test class for EncryptorExtensionsTest and is intended
	///to contain all EncryptorExtensionsTest Unit Tests
	///</summary>
	[TestClass()]
	public class EncryptorExtensionsTest
	{
		private static readonly string[] KeyClassNamesRsa = new string[]
		                                                 	{
		                                                 		"PaymentInstrument",
		                                                 		"DatabasePassword",
		                                                 		"ServiceDefProp",
		                                                 		"QueryString"
		                                                 	};
		private static readonly string[] KeyClassNamesAes = new string[]
		                                                 	{
		                                                 		"PaymentInstrument",
		                                                 		"DatabasePassword",
		                                                 		"ServiceDefProp",
		                                                 		"Ticketing",
		                                                 		"QueryString"
		                                                 	};
		private static readonly string[] HashKeyClassesRsa = new string[]
		                                                 	{
																												"PasswordHash",
																												"PaymentMethodHash"
		                                                 	};
		private static readonly string[] HashKeyClassesSha = new string[]
		                                                 	{
																												"PasswordHash",
																												"PaymentMethodHash"
		                                                 	};

		private TestContext testContextInstance;

		/// <summary>
		///Gets or sets the test context which provides
		///information about and functionality for the current test run.
		///</summary>
		public TestContext TestContext
		{
			get { return testContextInstance; }
			set { testContextInstance = value; }
		}

		#region Additional test attributes

		// 
		//You can use the following additional attributes as you write your tests:
		//
		//Use ClassInitialize to run code before running the first test in the class
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

		#region Tests for ProtectData method

		/// <summary>
		///A test for ProtectData
		///</summary>
		[TestMethod()]
		public void ProtectDataTest()
		{
			string input = "Input Dat a";
			string actual = input.ProtectData();

			// Check the output length
			Assert.IsFalse(string.IsNullOrEmpty(actual), "Non-empty output expected but empty found.");
			Assert.AreEqual(0, actual.Length % 4, "Output length is invalid");
		}

		#endregion

		#region Tests for UnprotectData method

		/// <summary>
		///A test for UnprotectData
		///</summary>
		[TestMethod()]
		public void UnprotectDataTest()
		{
			string input = "Input Dat a";
			string expected = input;
			string intermediate = input.ProtectData();

			string actual = intermediate.UnprotectData();

			// Check the output length
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		#endregion

		#region Tests for MS encryption/decryption

		/// <summary>
		///A test for symmetryc AES Encryption/Decryption
		///</summary>
		[TestMethod()]
		public void AesEncryptDecryptTest()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var keyClassName in KeyClassNamesAes)
			{
				EncryptDecryptAes(plainText, keyClassName);
			}
		}

		/// <summary>
		/// Tests Sha 512 Hashing: the same text should have the same hash
		/// </summary>
		[TestMethod()]
		public void HashShaTest_Positive()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesSha)
			{
				string hash = plainText.HashSha(hashKeyClass);
				string newHash = plainText.HashSha(hashKeyClass);
				Assert.AreEqual(hash, newHash, "Hash does not match");
			}
		}

		/// <summary>
		/// Tests Sha Hashing: different text should have different hash
		/// </summary>
		[TestMethod()]
		public void HashShaTest_DifferentTexts()
		{
			const string plainText1 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			const string plainText2 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon";
			foreach (var hashKeyClass in HashKeyClassesSha)
			{
				string hash = plainText1.HashSha(hashKeyClass);
				string newHash = plainText2.HashSha(hashKeyClass);
				Assert.AreNotEqual(hash, newHash, "Hashes matched");
			}
		}

		/// <summary>
		/// Tests Sha Hashing with key
		/// </summary>
		[TestMethod()]
		public void HashShaWithKeyTest()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesSha)
			{
				string hash = plainText.HashSha(hashKeyClass);
				string key = hash.ParseKeyFromHashSha256();
				Assert.IsNotNull(key);
				string newHash = plainText.HashSha(hashKeyClass, key);
				Assert.AreEqual(hash, newHash, "Hash does not match");
			}
		}

		/// <summary>
		/// Tests Comparation of Sha Hash: the same text should have the same hash
		/// </summary>
		[TestMethod()]
		public void CompareHashShaTest_Positive()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesSha)
			{
				string hash = plainText.HashSha(hashKeyClass);
				bool areEqual = plainText.CompareWithHashSha(hashKeyClass, hash);
				Assert.IsTrue(areEqual, "Hash does not match");
			}
		}

		/// <summary>
		/// Tests Comparation of Sha Hash: different text should have different hash
		/// </summary>
		[TestMethod()]
		public void CompareHashShaTest_Negative()
		{
			const string plainText1 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			const string plainText2 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon";
			foreach (var hashKeyClass in HashKeyClassesSha)
			{
				string hash = plainText1.HashSha(hashKeyClass);
				bool areEqual = plainText2.CompareWithHashSha(hashKeyClass, hash);
				Assert.IsFalse(areEqual, "Hashes matched");
			}
		}

		/// <summary>
		/// Tests key parsing from Sha Hash
		/// </summary>
		[TestMethod()]
		public void ParseKeyFromHashShaTest()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesSha)
			{
				string hash = plainText.HashSha(hashKeyClass);
				string key = hash.ParseKeyFromHashSha256();
				string hash2 = plainText.HashSha(hashKeyClass);
				string key2 = hash2.ParseKeyFromHashSha256();
				Assert.AreEqual(key, key2, "Keys do not match");
			}
		}

		#endregion

		#region Tests for RSA encryption/decryption

		/// <summary>
		///A test for RSA Encryption/Decryption 
		///</summary>
		[TestMethod()]
		public void RsaEncryptDecryptTest()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var keyClassName in KeyClassNamesRsa)
			{
				EncryptDecryptRsa(plainText, keyClassName);
			}
		}

		/// <summary>
		/// Tests RSA Hashing: the same text should have the same hash
		/// </summary>
		[TestMethod()]
		public void HashRsaTest_Positive()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesRsa)
			{
				string hash = plainText.HashRsa(hashKeyClass);
				string newHash = plainText.HashRsa(hashKeyClass);
				Assert.AreEqual(hash, newHash, "Hash does not match");
			}
		}

		/// <summary>
		/// Tests Rsa Hashing: different text should have different hash
		/// </summary>
		[TestMethod()]
		public void HashRsaTest_DifferentTexts()
		{
			const string plainText1 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			const string plainText2 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon";
			foreach (var hashKeyClass in HashKeyClassesRsa)
			{
				string hash = plainText1.HashRsa(hashKeyClass);
				string newHash = plainText2.HashRsa(hashKeyClass);
				Assert.AreNotEqual(hash, newHash, "Hashes matched");
			}
		}

		/// <summary>
		/// Tests RSA Hashing with key
		/// </summary>
		[TestMethod()]
		public void HashRsaWithKeyTest()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesRsa)
			{
				string hash = plainText.HashRsa(hashKeyClass);
				string key = hash.ParseKeyFromHashRsa();
				Assert.IsNotNull(key);
				string newHash = plainText.HashRsa(hashKeyClass, key);
				Assert.AreEqual(hash, newHash, "Hash does not match");
			}
		}

		/// <summary>
		/// Tests Comparation of RSA Hash on the same text
		/// </summary>
		[TestMethod()]
		public void CompareHashRsaTest_Positive()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesRsa)
			{
				string hash = plainText.HashRsa(hashKeyClass);
				bool areEqual = plainText.CompareHashRsa(hashKeyClass, hash);
				Assert.IsTrue(areEqual, "Hash does not match");
			}
		}

		/// <summary>
		/// Tests Comparation of RSA Hash: different text should have different hash
		/// </summary>
		[TestMethod()]
		public void CompareHashRsaTest_Negative()
		{
			const string plainText1 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			const string plainText2 = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon";
			foreach (var hashKeyClass in HashKeyClassesRsa)
			{
				string hash = plainText1.HashRsa(hashKeyClass);
				bool areEqual = plainText2.CompareHashRsa(hashKeyClass, hash);
				Assert.IsFalse(areEqual, "Hash match");
			}
		}

		/// <summary>
		/// Tests key parsing from RSA Hash on the same text
		/// </summary>
		[TestMethod()]
		public void ParseKeyFromHashRsaTest()
		{
			const string plainText = "日本語 The old brown fox jumped over the #$%^()&#@,.:\"//\'|}{[]?_-* moon!";
			foreach (var hashKeyClass in HashKeyClassesRsa)
			{
				string hash = plainText.HashRsa(hashKeyClass);
				string key = hash.ParseKeyFromHashRsa();
				string hash2 = plainText.HashRsa(hashKeyClass);
				string key2 = hash2.ParseKeyFromHashRsa();
				Assert.AreEqual(key, key2, "Keys do not match");
			}
		}

		#endregion

		#region Private Methods

		private void EncryptDecryptRsa(string plainText, string keyClassName)
		{
			string cipherText = plainText.EncryptRsa(keyClassName);
			string decryptedText = cipherText.DecryptRsa(keyClassName);
			LoggingHelper.LogDebug("TestEncryptDecryptRsa", string.Format("Encryption with {0} class/n, Plain text: {1}, Decrypted text: {2}", keyClassName, plainText, decryptedText));
			Assert.AreEqual(plainText, decryptedText, "Decrypted string does not match original string");
		}

		private void EncryptDecryptAes(string plainText, string keyClassName)
		{
			string cipherText = plainText.EncryptAes(keyClassName);
			string decryptedText = cipherText.DecryptAes(keyClassName);
			LoggingHelper.LogDebug("TestEncryptDecryptAes", string.Format("Encryption with {0} class/n, Plain text: {1}, Decrypted text: {2}", keyClassName, plainText, decryptedText));
			Assert.AreEqual(plainText, decryptedText, "Decrypted string does not match original string");
		}

		#endregion
	}
}
