using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using MetraTech.Security.Crypto;
using MetraTech.DataAccess;

namespace CCHashGenerator
{
  class Program
  {
    private static CryptoManager m_CryptoManager = new CryptoManager();

    static void Main(string[] args)
    {
      try
      {
        ConnectionInfo netMeter = new ConnectionInfo("NetMeter");
        ConnectionInfo netMeterPay = netMeter.Clone() as ConnectionInfo;

        if (ProcessArgs(netMeterPay, args))
        {

          using (IMTConnection netMeterPayConn = ConnectionManager.CreateConnection(netMeterPay))
          {
            using (IMTConnection netMeterConn = ConnectionManager.CreateConnection(netMeter))
            {
              IMTStatement netMeterPayStmt = netMeterPayConn.CreateStatement("Select id_payment_instrument, nm_account_number from t_ps_payment_instrument");

              using (IMTDataReader netMeterPayReader = netMeterPayStmt.ExecuteReader())
              {
                while(netMeterPayReader.Read())
                {
                  string instrumentId = netMeterPayReader.GetString(0);
                  string encryptedAcctNum = netMeterPayReader.GetString(1);
                  string hasedAcctNum = HashAccountNumber(DecryptString(encryptedAcctNum));

                  IMTStatement netMeterStmt = netMeterConn.CreateStatement(string.Format("Update t_payment_instrument set tx_hash = '{0}' where id_payment_instrument = '{1}'", hasedAcctNum, instrumentId));

                  netMeterStmt.ExecuteNonQuery();
                }
              }
            }
          }
        }
      }
      catch (Exception e)
      {
        Console.WriteLine("Exception caught generating hash values");
        Console.WriteLine("Message was: {0}", e.Message);
        Console.WriteLine();
        Console.WriteLine("Error occurred at:\n{0}",e.StackTrace);
        Console.WriteLine();

        Exception inner = e.InnerException;

        while (inner != null)
        {
          Console.WriteLine("Inner Exception: {0}", inner.Message);
          Console.WriteLine("Occurred at:\n{0}", inner.StackTrace);
          Console.WriteLine();

          inner = inner.InnerException;
        }
      }
    }

    private static void PrintUsage()
    {
      Console.WriteLine("CCHashGenerator Usage:");
      Console.WriteLine();
      Console.WriteLine("CCHashGenerator [-s <ServerName>] [-c <CatalogName>] [-u <username>] [-p <password] [-?]");
      Console.WriteLine();
      Console.WriteLine("-s: Specifies the MeterPay database server name");
      Console.WriteLine("-c: Specifies the MetraPay database catalog name");
      Console.WriteLine("-u: Specifies the username to use to connect to the MetraPay database" );
      Console.WriteLine("-p: Specifies the password to use to connect to the MetraPay database" );
      Console.WriteLine();
      Console.WriteLine("-?: Print this usage");
      Console.WriteLine();
      Console.WriteLine("If any argument is not specified, the current setting for the NetMeter database will be used");
    }

    private static bool ProcessArgs(ConnectionInfo connInfo, string[] args)
    {
      bool retval = true;
      for(int i = 0; i < args.Length; i++)
      {
        if (args[i].ToUpper() == "-S")
        {
          connInfo.Server = args[++i];
        }
        else if (args[i].ToUpper() == "-C")
        {
          connInfo.Catalog = args[++i];
        }
        else if (args[i].ToUpper() == "-U")
        {
          connInfo.UserName = args[++i];
        }
        else if (args[i].ToUpper() == "-P")
        {
          connInfo.Password = args[++i];
        }
        else
        {
          retval = false;
          PrintUsage();

          break;
        }
      }

      return retval;
    }

    private static string DecryptString(string encryptedString)
    {
      string decryptedString = m_CryptoManager.Decrypt(CryptKeyClass.PaymentInstrument, encryptedString);
      return decryptedString;
    }

    private static string GetMD5(string plainText)
    {
      MD5 md5Hasher = MD5.Create();
      // Convert the input string to a byte array and compute the hash.
      byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(plainText));

      // Create a new Stringbuilder to collect the bytes and create a string.
      StringBuilder builder = new StringBuilder();

      // Loop through each byte of the hashed data 
      // and format each one as a hexadecimal string.
      for (int i = 0; i < data.Length; i++)
      {
        builder.Append(data[i].ToString("x2"));
      }

      // Return the hexadecimal string.
      return builder.ToString();
    }

    private static string HashAccountNumber(string acctNum)
    {
      string md5Hash = GetMD5(acctNum);
      string saltedAcctNum = md5Hash + acctNum;

      string hashedAcctNum = m_CryptoManager.Hash(HashKeyClass.PaymentMethodHash, saltedAcctNum);

      return hashedAcctNum;
    }

  }
}
