/* This utility upgrades the encryption from 5.1.1 to 6.0.1
 * 
 * Upgrading password hash from 5.1.1 MD5 hash to new HMX 256 hash
 * 
 * Decrypting credit cards encrypted with 5.1.1 standard Triple DES encryption
 * and Encrypting them using new AES 256 encryption using Metratech.Security.Crypto
 * 
 * Find all tables with encrypted fields 
 * (T_AV, P_PV and T_SVC tables, where there are fields ending with underscore)
 * and decrypt and re-encrypt data there.
*/

using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using MetraTech.Security.Crypto;
using MetraTech.DataAccess;

namespace UpgradeEncryption
{
  class Program
  {
    private static CryptoManager m_CryptoManager = new CryptoManager();
    private static MetraTech.Logger logger = new MetraTech.Logger("[UpgradeEncryption]");
    private static bool DoPassword = false;
    private static bool DoUnderscoreFields = false;
    private static bool DoCreditCard = false;


    static void Main(string[] args)
    {
      try
      {
        logger.LogInfo("Connecting to the database");
        ConnectionInfo netMeter = new ConnectionInfo("NetMeter");
        ConnectionInfo netMeterPay = netMeter.Clone() as ConnectionInfo;

        if (ProcessArgs(netMeterPay, args))
        {
          using (IMTConnection netMeterPayConn = ConnectionManager.CreateConnection(netMeterPay))
          {
            using (IMTConnection netMeterConn = ConnectionManager.CreateConnection(netMeter))
            {
              if (DoPassword) 
                UpgradePasswordEncryption(netMeterConn);
              if (DoUnderscoreFields) 
                UpgradeUnderscoreFields(netMeterConn);
              if (DoCreditCard)
                UpgradeCreditCardEncryption(netMeterConn, netMeterPayConn);
            }
          }
          logger.LogInfo("Encryption upgrade complete");
          Console.WriteLine("Encryption upgrade complete");
        }
      }
      catch (Exception e)
      {
        Console.WriteLine("Error when upgrading encryption. See mtlog for details");
        logger.LogError("Exception caught upgrading encrypted fields");
        logger.LogError("Message was: {0}", e.Message);
        logger.LogError("Error occurred at:\n{0}", e.StackTrace);

        Exception inner = e.InnerException;

        while (inner != null)
        {
          logger.LogError("Inner Exception: {0}", inner.Message);
          logger.LogError("Occurred at:\n{0}", inner.StackTrace);

          inner = inner.InnerException;
        }
      }
    }

    private static void UpgradeUnderscoreFields(IMTConnection netMeterConn)
    {
      Console.WriteLine("Upgrading encryption for fields ending with _ in all tables");
      logger.LogInfo("Upgrading encryption for fields ending with _ in all tables");
      string getFieldsListSQL;
      if (netMeterConn.ConnectionInfo.IsOracle)
      {
        getFieldsListSQL = @"select table_name, column_name 
                            from user_tab_cols tc
                            where column_name like '%\_' escape '\'
                              and (
                                  tc.table_name like 'T\_SVC\_%' escape '\' or
                                  tc.table_name like 'T\_AV\_%' escape '\' or
                                  tc.table_name like 'T\_PV\_%' escape '\'
                              )";
      }
      else
      {
        getFieldsListSQL = @"select object_name(object_id) table_name, c.name column_name
                            from sys.columns c
                            where c.name like '%\_' escape '\'
							                and (
                                  object_name(object_id) like 'T\_SVC\_%' escape '\' or
                                  object_name(object_id) like 'T\_AV\_%' escape '\' or
                                  object_name(object_id) like 'T\_PV\_%' escape '\'
                              )";
      }

      IMTStatement getFieldsListSTMT = netMeterConn.CreateStatement(getFieldsListSQL);
      using (IMTDataReader getFieldsListReader = getFieldsListSTMT.ExecuteReader())
      {
        while (getFieldsListReader.Read())
        {
          string table_name = getFieldsListReader.GetString(0);
          string column_name = getFieldsListReader.GetString(1);
          StatementBuilder builder = new StatementBuilder(table_name);
          builder.UpdateField = column_name;

          string getPrimaryKeySQL;
          if (netMeterConn.ConnectionInfo.IsOracle)
          {
            getPrimaryKeySQL = @"select cc.column_name, cc.table_name, tc.DATA_TYPE, tc.DATA_LENGTH
                                from user_cons_columns cc, 
                                  user_constraints c, 
                                  user_tab_cols tc
                                where cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
                                  and c.CONSTRAINT_TYPE = 'P'    
                                  and c.TABLE_NAME = cc.TABLE_NAME
                                  and tc.TABLE_NAME = cc.TABLE_NAME
                                  AND tc.COLUMN_NAME = cc.COLUMN_NAME
                                  and tc.TABLE_NAME = '{0}'";
          }
          else
          {
            getPrimaryKeySQL = @"select c.column_name, c.table_name, data_type, ISNULL( c.character_maximum_length, ISNULL(c.numeric_precision_radix, 0))
                                from information_schema.TABLE_CONSTRAINTS tc,
                                information_schema.CONSTRAINT_COLUMN_USAGE ccu,
                                information_schema.columns c
                                where constraint_type = 'PRIMARY KEY'
                                  and ccu.constraint_name = tc.constraint_name
                                  and c.table_name = tc.table_name
                                  and c.column_name = ccu.column_name
                                  and upper(tc.table_name) = upper('{0}')";
          }
          getPrimaryKeySQL = string.Format(getPrimaryKeySQL, table_name);
          IMTStatement getPrimaryKeySTMT = netMeterConn.CreateStatement(getPrimaryKeySQL);
          using (IMTDataReader getPrimaryKeyReader = getPrimaryKeySTMT.ExecuteReader())
          {
            while (getPrimaryKeyReader.Read())
            {
              string pkColumn = getPrimaryKeyReader.GetString(0);
              string DataType = getPrimaryKeyReader.GetString(2);
              StatementBuilder.DBField pk;
              if (netMeterConn.ConnectionInfo.IsOracle)
              {
                pk = new StatementBuilder.OracleField(pkColumn, DataType);
              }
              else
              {
                pk = new StatementBuilder.SqlField(pkColumn, DataType);
              }
              builder.AddPrimaryKeyField(pk);
            }
          }
          UpgradeUnderscoreFieldsInTable(netMeterConn, builder);
        }
      }
    }

    private static void UpgradeUnderscoreFieldsInTable(IMTConnection netMeterConn, StatementBuilder builder)
    {
      logger.LogInfo("Upgrading encryption for fields ending with _ in table " + builder.TableName);
      string selectSQL = builder.GetSelectStatement();
      IMTStatement selectSTMT = netMeterConn.CreateStatement(selectSQL);
      using (IMTDataReader selectReader = selectSTMT.ExecuteReader())
      {
        while (selectReader.Read())
        {
          try
          {
            string oldEncryptedField = selectReader.GetString(builder.UpdateField);
            foreach (string key in builder.PrimaryKey.Keys)
            {
              string value = selectReader.GetConvertedString(key);
              builder.PrimaryKey[key].Value = value;
            }
            string rawField = Decrypt511(oldEncryptedField);
            string newEncryptedField = Encrypt601(CryptKeyClass.ServiceDefProp, rawField);
            builder.UpdateFieldValue = newEncryptedField;

            string updateSQL = builder.GetUpdateStatement();
            IMTStatement updateSTMT = netMeterConn.CreateStatement(updateSQL);
            updateSTMT.ExecuteNonQuery();
          }
          catch (MetraTech.CryptoException ce)
          {
            logger.LogError("Unable to decrypt a {0} in table {1}. Possibly wrong key or data is already decrypted. {2}",
              builder.UpdateField, builder.TableName, ce.Message);
          }
        }
      }

    }

    private static string Encrypt601(CryptKeyClass keyClass,string input)
    {
//      string encryptedString = m_CryptoManager.Encrypt(CryptKeyClass.PaymentInstrument, input);
      string encryptedString = m_CryptoManager.Encrypt(keyClass, input);
      return encryptedString;
    }

    private static string Decrypt511(string input)
    {
      // calling the old 511 decryption mechanism.
      MetraTech.Crypto511.Decryptor d = new MetraTech.Crypto511.Decryptor();
      d.Initialize();
      string result = d.Decrypt(input);
      return result;
    }

    private static void UpgradeCreditCardEncryption(IMTConnection netMeterConn, IMTConnection netMeterPayConn)
    {
      Console.WriteLine("Upgrading credit card encryption for table t_ps_payment_instrument");
      logger.LogInfo("Upgrading credit card encryption for table t_ps_payment_instrument");

//      IMTStatement getCreditCardStmt = netMeterConn.CreateStatement(@"
//          select nm_lastfourdigits, nm_ccnum from gcieplik.t_ps_creditcard"
//        );

      IMTStatement getCreditCardStmt = netMeterPayConn.CreateStatement(
          @"select id_payment_instrument, nm_account_number 
            from t_ps_payment_instrument"
        );

      try
      {
        using (IMTDataReader getCreditCardReader = getCreditCardStmt.ExecuteReader())
        {
          while (getCreditCardReader.Read())
          {
            try
            {
              string id = getCreditCardReader.GetString(0);
              string oldCreditCard = getCreditCardReader.GetString(1);
              string rawCreditCard = Decrypt511(oldCreditCard);
              string newCreditCard = Encrypt601(CryptKeyClass.PaymentInstrument, rawCreditCard);

              IMTStatement setCreditCardStmt = netMeterConn.CreateStatement(
                string.Format(
                          @"update t_ps_payment_instrument
                        set nm_account_number = '{0}'
                        where id_payment_instrument = '{1}'",
                     StatementBuilder.EscapeQuotes(newCreditCard), id));

              setCreditCardStmt.ExecuteNonQuery();
            }
            catch (MetraTech.CryptoException ce)
            {
              logger.LogError("Unable to decrypt a credit card in table t_ps_payment_instrument. Possibly wrong key or data is already decrypted. {0}",
                ce.Message);
            }

          }
        }
      }
      catch (Exception )
      {
        logger.LogError("Error upgrading Credit Card encryption. If you don't have payment server installed, it is safe to ignore this error");
        throw;
      }
    }

    private static void UpgradePasswordEncryption(IMTConnection netMeterConn)
    {
      Console.WriteLine("Upgrade password Encryption in table t_user_credentials");
      logger.LogInfo("Upgrade password Encryption in table t_user_credentials");
      IMTStatement getPasswordStmt = netMeterConn.CreateStatement(@"
                select nm_login, nm_space, tx_password 
                from t_user_credentials"
        );

      using (IMTDataReader getPasswordReader = getPasswordStmt.ExecuteReader())
      {
        while (getPasswordReader.Read())
        {
          try
          {
            string UserName = getPasswordReader.GetString(0);
            string NameSpace = getPasswordReader.GetString(1);
            string md5PasswordHash = getPasswordReader.GetString(2);
            // old md5hash only is 32 bytes in length.
            if (md5PasswordHash.Length > 33) 
              throw new MetraTech.CryptoException(string.Format("The md5hash for nm_login {0} is too long", UserName));
            string newPasswordHash = HashOldPassword(md5PasswordHash, UserName, NameSpace);

            IMTStatement setNewPasswordStmt = netMeterConn.CreateStatement(
              string.Format(@"
                        Update t_user_credentials 
                        set tx_password = '{0}' 
                        where nm_login = '{1}'
                          and nm_space = '{2}'",
                   StatementBuilder.EscapeQuotes(newPasswordHash),
                   StatementBuilder.EscapeQuotes(UserName),
                   StatementBuilder.EscapeQuotes(NameSpace)));

            setNewPasswordStmt.ExecuteNonQuery();
          }
          catch (MetraTech.CryptoException ce)
          {
            logger.LogError("Unable to generate new hash. Possibly not MD5HASH is currentl in the db. {0}",
              ce.Message);
          }

        }
      }
    }

    private static void PrintUsage()
    {
      Console.WriteLine(@"UpgradeEncryption Usage:

UpgradeEncryption [-s <ServerName>] [-c <CatalogName>] [-u <username>] [-p <password] [-f <password|creditcard|underscore>] -[-?]

-s: Specifies the MeterPay database server name
-c: Specifies the MetraPay database catalog name
-u: Specifies the username to use to connect to the MetraPay database
-p: Specifies the password to use to connect to the MetraPay database
-f: Specifies the functionality to execute.
     password  : Upgrading password hash from 5.1.1 MD5 hash
                 to new HMX 256 hash
     creditcard: Decrypting credit cards encrypted with 5.1.1 standard 
                 Triple DES encryption and Encrypting them using 
                 new AES 256 encryption using Metratech.Security.Crypto
     underscore: Find all tables with encrypted fields. T_AV, P_PV and T_SVC 
                 tables, where there are fields ending with underscore, 
                 and decrypt and re-encrypt data there.

-?: Print this usage

If any argument is not specified, the current setting for the NetMeter database will be used");
    }

    private static bool ProcessArgs(ConnectionInfo connInfo, string[] args)
    {
      bool retval = true;
      for (int i = 0; i < args.Length; i++)
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
        else if (args[i].ToUpper() == "-F")
        {
          string functionality = args[++i].ToUpper();
          if (functionality == "PASSWORD") DoPassword = true;
          else if (functionality == "CREDITCARD") DoCreditCard = true;
          else if (functionality == "UNDERSCORE") DoUnderscoreFields = true;
          else
          {
            Console.WriteLine("Unknown functionality: {0}", functionality);
            retval = false;
            break;
          }
        }
        else
        {
          Console.WriteLine("Unknown parameter: {0}", args[i]);
          retval = false;
          break;
        }
      }
      if (retval)
      {
        if (!(DoUnderscoreFields || DoPassword || DoCreditCard))
        {
          Console.WriteLine("Nothing to do. No functionality specified. Use -f option to specify what to do");
          retval = false;
        }
      }
      if (!retval)
      {
        PrintUsage();
      }
      return retval;
    }

    private static string HashOldPassword(string md5Hash, string UserName, string NameSpace)
    {
      string saltedPassword = SaltPassword(md5Hash,UserName, NameSpace);
      // Run crypto hash HMAC-SHA-256
      string hashedPassword = m_CryptoManager.Hash(HashKeyClass.PasswordHash, saltedPassword);

      return hashedPassword;
    }

    private static string SaltPassword(string md5Hash, string UserName, string NameSpace)
    {
      string saltedPassword = md5Hash + UserName.ToLower() + NameSpace.ToLower();
      return saltedPassword;
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

  public class StatementBuilder
  {
    public class DBField
    {
      protected string DecodeUIDAsString(string uid)
      {
        byte[] uidBytes = System.Convert.FromBase64String(uid);
        string hexString = "";
        foreach (byte b in uidBytes)
          hexString += String.Format("{0:X2}", b);

        return hexString;
      }

      private string mFieldName;
      public string FieldName
      {
        get { return mFieldName; }
      }

      public virtual string GetFieldAsString()
      {
        return FieldName;
      }

      public virtual string GetValueAsString()
      {
        return string.Format("'{0}'", EscapeQuotes(Value));
      }

      private string mFieldType;
      public string FieldType
      {
        get { return mFieldType; }
      }

      public string Value = "";

      public DBField(string aFieldName, string aFieldType)
      {
        mFieldName = aFieldName;
        mFieldType = aFieldType;
      }
    }
    public class OracleField : DBField
    {
      public OracleField(string aFieldName, string aFieldType) : base(aFieldName, aFieldType) { }
      public override string GetFieldAsString()
      {
        //return string.Format("CAST({0} AS VARCHAR2(1000))", FieldName);
        return FieldName;
      }
      public override string GetValueAsString()
      {
        switch (FieldType)
        {
          case "RAW":
            return string.Format("'{0}'",DecodeUIDAsString(Value));
          default:
            return base.GetValueAsString();
        } 
      }
    }
    public class SqlField : DBField
    {
      public SqlField(string aFieldName, string aFieldType) : base(aFieldName, aFieldType) { }
      public override string GetFieldAsString()
      {
        //return string.Format("CAST({0} AS VARCHAR(1000))", FieldName);
        return FieldName;
      }
      public override string GetValueAsString()
      {
        switch (FieldType)
        {
          case "binary":
            return string.Format("0x{0}", DecodeUIDAsString(Value));
          default:
            return base.GetValueAsString();
        }
      }
    }


    private string tableName = "";
    public string TableName
    {
      get { return tableName; }
    }

    private string mUpdateField;
    public string UpdateField
    {
      get { return mUpdateField; }
      set { mUpdateField = value; }
    }
  
    private string mUpdateFieldValue;
    public string UpdateFieldValue
    {
      get { return mUpdateFieldValue; }
      set { mUpdateFieldValue = value; }
    }
		
    public Dictionary<string, DBField> PrimaryKey = new Dictionary<string, DBField>();

    public StatementBuilder(string aTableName)
    {
      tableName = aTableName;
    }

    public string GetSelectStatement()
    {
      string sqlTemplate = "SELECT {0} FROM {1} WHERE {2} IS NOT NULL";
      string sql = string.Format(sqlTemplate, GetSelectClause(), tableName, UpdateField);
      return sql;
    }
    public string GetUpdateStatement()
    {
      string sqlTemplate = "UPDATE {0} SET {1}='{2}' WHERE {3}";
      string sql = string.Format(sqlTemplate, tableName, UpdateField, EscapeQuotes(UpdateFieldValue), getWhereClause());
      return sql;
    }

    public static string EscapeQuotes(string str)
    {
      System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(@"'");
      return r.Replace(str, "''");
    }

    private string GetSelectClause()
    {
      string select = UpdateField;
      foreach (DBField field in PrimaryKey.Values)
      {
        select += string.Format(", {0} AS {1}", field.GetFieldAsString(), field.FieldName);
      }
      return select;
    }

    private string getWhereClause()
    {
      string where = "";
      foreach (DBField field in PrimaryKey.Values) {
        string conditionTemplate = "{0}={1}";
        string condition = string.Format(conditionTemplate, field.GetFieldAsString(), field.GetValueAsString());
        if (where != "") where += " AND ";
        where += condition;
      }
      return where;
    }
    public void AddPrimaryKeyField(DBField Field)
    {
      PrimaryKey.Add(Field.FieldName, Field);
    }
  }
}
