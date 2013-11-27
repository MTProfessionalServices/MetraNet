// CORE-5922: SSL certificate name mismatch error should not be supressed. 
// Suppressing is commented out
//using System.Net;
//using System.Net.Security;
//using System.Security.Cryptography.X509Certificates;

///// <summary>
///// Handles the managing of server certificate validation
///// </summary>
//public class CertManager
//{
//  private static string ServerFQN;

//  public void EnableDeveloperCert(string serverFQN)
//  {
//    ServerFQN = serverFQN.ToUpper();

//    // validate cert by calling a function
//    ServicePointManager.ServerCertificateValidationCallback += ValidateRemoteCertificate;
//  }

//  // callback used to validate the certificate in an SSL conversation, we trust our server
//  private static bool ValidateRemoteCertificate(object sender, X509Certificate cert, X509Chain chain, SslPolicyErrors policyErrors)
//  {
//    var result = cert.Subject.ToUpper().Contains(ServerFQN);
//    return result;
//  }

//}