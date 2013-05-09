using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security;
using System.Security.Cryptography;
using System.Xml;

namespace FakeSecurity
{
    public class Key
    {
        public Guid Id;
        public byte[] cryptoKey;
        public byte[] iv;

        public void SetFromPassphrase(string passphrase)
        {
            byte[] salt = new byte[] { 0, 1, 2, 3, 4, 5, 6, 7 };
            Rfc2898DeriveBytes pwdGen = new Rfc2898DeriveBytes(passphrase, salt, 1000);

            // Generate a 32 byte (256 bit) key from the password
            cryptoKey = pwdGen.GetBytes(32);

            // Generate a 32 byte (256 bit) IV from the password hash
            iv = pwdGen.GetBytes(32);
        }
    }

    public class FakeSecurity
    {
        // We need this instantiated to enable access to the key store
        // private CryptoManager crypto = new CryptoManager();

        Key theKey;

        public FakeSecurity(string passphrase)
        {
            // We need the GUID from the session key file
            theKey = getSessionKey();
            theKey.SetFromPassphrase(passphrase);
        }

      public void setPassphrase(string passphrase)
      {
        theKey.SetFromPassphrase(passphrase);
      }

      public string HashNewPassword(string plainTextPassword, string UserName, string Name_Space)
        {
            string saltedPassword = SaltPassword(plainTextPassword, UserName, Name_Space);
            string hashedPassword = HashWithKey(theKey, saltedPassword);
            return hashedPassword;
        }

        private Key getSessionKey()
        {
            //string path = @"c:\MetraTech\RMP\config\security\sessionkeys.xml";
			string path = string.Format(@"{0}\config\security\sessionkeys.xml", 
				Environment.GetEnvironmentVariable("MTRMP"));
			
            XmlDocument doc = new XmlDocument();
            doc.Load(path);
            XmlNode n = doc.SelectSingleNode("//keyData/keyClass[@name='PasswordHash']/key[@current='true']");
            // Console.WriteLine("xml: {0}", n.InnerText);
            Key key = new Key();
            key.Id = new Guid(n.SelectSingleNode("id").InnerText);
            //key.Value = n.SelectSingleNode("value").InnerText;
            return key;
        }

        /// <summary>
        ///  Prepare plain text password for hash
        ///  Run MD5 Hash on clear text password
        ///  Append username and namespace as salt
        /// </summary>
        /// <param name="plainTextPassword"></param>
        /// <returns></returns>
        private string SaltPassword(string plainTextPassword, string UserName, string Name_Space)
        {
            string md5Hash = GetMD5(plainTextPassword);
            string saltedPassword = md5Hash + UserName.ToLower() + Name_Space.ToLower();
            return saltedPassword;
        }


        private string HashWithKey(Key key, string plainText)
        {
            try
            {
                byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);
                string hashedString = null;
                using (HMACSHA512 hmac = new HMACSHA512(key.cryptoKey))
                {
                    byte[] hash = hmac.ComputeHash(plainTextBytes);
                    hashedString = key.Id.ToString() + Convert.ToBase64String(hash);
                }

                return hashedString;
            }
            catch
            {
            }
            return "";
        }


        /// <summary>
        ///   GetMD5
        /// </summary>
        /// <param name="plainText"></param>
        /// <returns></returns>
        private string GetMD5(string plainText)
        {
            using (MD5 md5Hasher = MD5.Create())
            {
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
        }




     }



    class Program
    {
        static void Main(string[] args)
        {
            FakeSecurity fs = new FakeSecurity("mtkey");
            string nameSpace = "mt";
            string userName;

            userName = "chook";
            Console.WriteLine(userName);
            string hs = fs.HashNewPassword("MetraTech1", userName, nameSpace);
            Console.WriteLine("{0}", hs);
            hs = fs.HashNewPassword("123", userName, nameSpace);
            Console.WriteLine("{0}", hs);

            userName = "dhook";
            Console.WriteLine(userName);
            hs = fs.HashNewPassword("MetraTech1", userName, nameSpace);
            Console.WriteLine("{0}", hs);
            hs = fs.HashNewPassword("123", userName, nameSpace);
            Console.WriteLine("{0}", hs);

            userName = "AABabcock";
            Console.WriteLine(userName);
            hs = fs.HashNewPassword("MetraTech1", userName, nameSpace);
            Console.WriteLine("{0}", hs);
            hs = fs.HashNewPassword("123", userName, nameSpace);
            Console.WriteLine("{0}", hs);

            Console.ReadKey();
        }

    }

}
