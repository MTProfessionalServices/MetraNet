using System.Runtime.InteropServices;
using System.Threading;

[assembly: GuidAttribute("b6ac76f7-dd18-4580-9538-715c46bb64ff")]

namespace MetraTech.OnlineBill.TestSecurity
{
	using System;
	using System.Collections;

	using NUnit.Framework;
	using MetraTech.Test;

  using MetraTech.OnlineBill;

  /// <summary>
  ///   Unit Tests for MetraTech.OnlineBill.
  ///   
  ///   To run the this test fixture:
  ///    nunit-console /fixture:MetraTech.OnlineBill.TestSecurity.SmokeTest /assembly:O:\debug\bin\MetraTech.OnlineBill.TestSecurity.dll
  ///
  ///    Or to just run security piece:
  ///    nunit-console /fixture:MetraTech.OnlineBill.TestSecurity.SmokeTest /include:Security /assembly:O:\debug\bin\MetraTech.OnlineBill.TestSecurity.dll
  ///
  ///    Or to just run multibyte encrypte/decrypt piece:
  ///    nunit-console /fixture:MetraTech.OnlineBill.TestSecurity.SmokeTest /include:multibyte /assembly:O:\debug\bin\MetraTech.OnlineBill.TestSecurity.dll
  /// </summary>
	[TestFixture]
	public class SmokeTest
	{

    [Test]
    [Category("multibyte")]
    public void TestEncrypMultiBytet()
    {
      const string testMultiByteString = "<Hello 日本語  World =>";
      TestLibrary.Trace("Test Value = " + testMultiByteString);

      // without seed
      QueryStringEncrypt security1 = new QueryStringEncrypt();
      string encrypted1 = security1.EncryptString(testMultiByteString);
      string decrypted1 = security1.DecryptString(encrypted1);

      TestLibrary.Trace("Encrypted = " + encrypted1);
      TestLibrary.Trace("Decrypted = " + decrypted1);

      // make sure we get our string back on decrypt and from the cache on second try
      Assert.IsTrue(decrypted1 == testMultiByteString);
      decrypted1 = security1.DecryptString(encrypted1);
      Assert.IsTrue(decrypted1 == testMultiByteString);
    }


    [Test]
    [Category("Security")]
    public void TestEncrypt()
    {
      // without seed
      QueryStringEncrypt security1 = new QueryStringEncrypt();

      string encrypted1 = security1.EncryptString("<Hello + World =>");
      string decrypted1 = security1.DecryptString(encrypted1);

      TestLibrary.Trace(encrypted1);
      TestLibrary.Trace(decrypted1);

      // make sure we get our string back on decrypt and from the cache on second try
      Assert.IsTrue(decrypted1 == "<Hello + World =>");
      decrypted1 = security1.DecryptString(encrypted1);
      Assert.IsTrue(decrypted1 == "<Hello + World =>");

      // with seed
      for (int j = 0; j < 10; j++)
      {
        Thread t = new Thread(new ThreadStart(ThreadProc));
        t.Start();
        Thread.Sleep(0);

        for (int i = 0; i < 10; i++)
        {
          QueryStringEncrypt security = new QueryStringEncrypt();
          security.Seed = "123";
          string encrypted = security.EncryptString("<Hello + World =>" + i.ToString());
          string decrypted = security.DecryptString(encrypted);

          TestLibrary.Trace(encrypted);
          TestLibrary.Trace(decrypted);

          // make sure we get our string back on decrypt and from the cache on second try
          Assert.IsTrue(decrypted == "<Hello + World =>" + i.ToString());
          decrypted = security.DecryptString(encrypted);
          Assert.IsTrue(decrypted == "<Hello + World =>" + i.ToString());

          // make sure we have no bad characters in our Hex encoding
          int index = encrypted.IndexOf("<");
          Assert.IsTrue(index < 0);
          index = encrypted.IndexOf("%");
          Assert.IsTrue(index < 0);
          index = encrypted.IndexOf(" ");
          Assert.IsTrue(index < 0);
          index = encrypted.IndexOf("=");
          Assert.IsTrue(index < 0);
        }

        t.Join();
      }
    }

    public static void ThreadProc()
    {
      for (int i = 0; i < 10; i++)
      {
        TestLibrary.Trace("ThreadProc: {0}", i);

        QueryStringEncrypt security = new QueryStringEncrypt();
        security.Seed = "123";
        string encrypted = security.EncryptString("<Inside + Thread =>" + System.Threading.Thread.CurrentThread.ManagedThreadId.ToString());
        string decrypted = security.DecryptString(encrypted);

        TestLibrary.Trace(encrypted);
        TestLibrary.Trace(decrypted);

        // Yield the rest of the time slice.
        Thread.Sleep(0);
      }
    }

    [Test]
    [Ignore]
    [Category("WatchFire")]
    public void TestWatchFire()
    {
      Util util = new Util();
      string p = @"c:\tools\PsExec\PsExec.exe";
      string args = "\\\\bldvmserv -i -u Administrator -p MetraTech1 \"c:\\program files\\watchfire\\appscan\\appScancmd.exe\" exec /b \"c:\\Program Files\\Watchfire\\AppScan\\Scans\\MetraView.scan\" /d \"c:\\Program Files\\Watchfire\\AppScan\\Scans\\newScan.scan\" /rf \"c:\\program files\\Watchfire\\AppScan\\Scans\\results " + String.Format("{0:YYYYMMdd}", System.DateTime.Now) + ".rtf\" /rt rtf /v true";

      bool res = util.RunProcess(p, args);
      Assert.IsTrue(res);
    }

	}
}
