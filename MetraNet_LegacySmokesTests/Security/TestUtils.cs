using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.Interop.RCD;
using MetraTech.SecurityFramework;
using MetraTech.Security.Crypto;

namespace MetraTech.Security.Test
{
	/// <summary>
	/// Contains utility methods for unit tests.
	/// </summary>
	public static class TestUtils
	{
		/// <summary>
		/// Initializes the Security Framework.
		/// </summary>
		public static void InitSecurityFramework()
		{
			using (MTComSmartPtr<IMTRcd> rcd = new MTComSmartPtr<IMTRcd>())
			{
				rcd.Item = new MTRcdClass();
				rcd.Item.Init();

				string path = Path.Combine(rcd.Item.ConfigDir, @"Security\Validation\TestConfigs\MtSfConfigurationLoader.xml");

				//Initialize with the Security Framework properties
				SecurityKernel.Initialize(new MetraTech.SecurityFramework.Serialization.XmlSerializer(), path);
				//Start the Security Kernel
				SecurityKernel.Start();
				
				// Reconfigure RSA with hard-coded values to run on test environment without RSA configuration.
				SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsIdentityGroup = "MTDev";
				SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsCertificatePwd = new CertificatePassword() { Password = "dsg20056", Encrypted = false };
				SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KMSKeyClasses =
					new Crypto.KMSKeyClass[] {
						new KMSKeyClass(){ Id="PaymentInstrument", Name = "CreditCardNumber"},
						new KMSKeyClass(){ Id="DatabasePassword", Name = "CreditCardNumber"},
						new KMSKeyClass(){ Id="ServiceDefProp", Name = "CreditCardNumber"},
						new KMSKeyClass(){ Id="QueryString", Name = "CreditCardNumber"},
						new KMSKeyClass(){ Id="PasswordHash", Name = "PasswordHash"},
						new KMSKeyClass(){ Id="PaymentMethodHash", Name = "PaymentInstHash"},
						new KMSKeyClass(){ Id="WorldPayPassword", Name = "CreditCardNumber"}
					};

				//// Reconfigure RSA with hard-coded values to run on test environment without RSA configuration.
				//if (SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig == null)
				//{
				//    SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig = new RSAConfig();
				//}

				//SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsIdentityGroup = "MTDev";
				//SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsCertificatePwd = new CertificatePassword() { Password = "dsg20056", Encrypted = false };
				//SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KMSKeyClasses =
				//    new Crypto.KMSKeyClass[] {
				//        new KMSKeyClass(){ Id="PaymentInstrument", Name = "CreditCardNumber"},
				//        new KMSKeyClass(){ Id="DatabasePassword", Name = "CreditCardNumber"},
				//        new KMSKeyClass(){ Id="ServiceDefProp", Name = "CreditCardNumber"},
				//        new KMSKeyClass(){ Id="QueryString", Name = "CreditCardNumber"},
				//        new KMSKeyClass(){ Id="PasswordHash", Name = "PasswordHash"},
				//        new KMSKeyClass(){ Id="PaymentMethodHash", Name = "PaymentInstHash"}  };

				// TODO: figure out the way to have test configuration for RSA
			}
		}

		/// <summary>
		/// Deinitializes the security framework.
		/// </summary>
		public static void StopSecurityFramework()
		{
			SecurityKernel.Stop();
			SecurityKernel.Shutdown();
		}
	}
}
