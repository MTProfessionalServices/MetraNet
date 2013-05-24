using System;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using System.Text;

namespace MetraTech.ActivityServices.Common
{
	/// <summary>
	/// Contains methods to work with X.509 certificates.
	/// </summary>
	public static class CertificateHelper
	{
		private const string NotFoundFormat =
			"Cannot find the X.509 certificate using the following search criteria: StoreName '{0}', StoreLocation '{1}', FindType '{2}', FindValue '{3}'.";

		/// <summary>
		/// Finds a valid X.509 certificate with the latest expiration date.
		/// </summary>
		/// <param name="storeName">Certificate store name.</param>
		/// <param name="storeLocation">Certificate store location.</param>
		/// <param name="findType">A condition to find the certificate.</param>
		/// <param name="findValue">A value to find certificate with.</param>
		/// <returns>A valid certificate.</returns>
		/// <exception cref="InvalidOperationException">If no valid certificate with the specified conditions found.</exception>
		public static X509Certificate2 FindCertificate(StoreName storeName, StoreLocation storeLocation, X509FindType findType, object findValue)
		{
			X509Store xStore = new X509Store(storeName, storeLocation);
			xStore.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);

			X509Certificate2Collection certs = xStore.Certificates.Find(findType, findValue, true);

			X509Certificate2 result;
			if (certs.Count == 0)
			{
				throw new InvalidOperationException(string.Format(NotFoundFormat, storeName, storeLocation, findType, findValue));
			}
			else
			{
				// Finf a certificate with the latest expiration date.
				result = certs[0];
				for (int i = 1; i < certs.Count; i++)
				{
					if (certs[i].NotAfter > result.NotAfter)
					{
						result = certs[i];
					}
				}
			}

			return result;
		}
	}
}
