using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Threading;

using MetraTech;
using MetraTech.Interop.MTAuth;
using MetraTech.OnlineBill;

namespace MetraTech.UI.Common
{
  /// <summary>
  ///   The UIManager lives on MTPage as "UI" and is accessable in every page.  It
  ///   holds information about the currently logged in User, Subscriber, and hosts
  ///   the PageNavManager that is used to fire events that cause page transistions.
  /// </summary>
  [Serializable]
  public class UIManager
  {
    /// <summary>
    /// Currently logged in user
    /// </summary>
    private UserData mUser = new UserData();
    public UserData User
    {
      get { return mUser; }
      set { mUser = value; }
    }

    /// <summary>
    /// Currently selected subscriber
    /// </summary>
    private ActiveSubscriber mSubscriber = new ActiveSubscriber();
    public ActiveSubscriber Subscriber
    {
      get { return mSubscriber; }
      set { mSubscriber = value; }
    }

    /// <summary>
    /// Dictionary for configuration settings
    /// </summary>
    //private DictionaryManager mDictionaryManager = new DictionaryManager(Thread.CurrentThread.CurrentUICulture.Name);
    private DictionaryManager mDictionaryManager = new DictionaryManager("en-US");  // We don't have localized dictionaries, we use resources for localized terms
    public DictionaryManager DictionaryManager
    {
      get { return mDictionaryManager; }
      set { mDictionaryManager = value; }
    }

    /// <summary>
    /// Return the current logged in user's SessionContext
    /// </summary>
    public IMTSessionContext SessionContext
    {
      get { return User.SessionContext; }
      set { User.SessionContext = value; }
    }

    public UIManager()
    {
    }
 
    /// <summary>
    /// CoarseCheckCapability based on logged in user's security context
    /// </summary>
    /// <param name="cap">Capability to check</param>
    /// <returns>true / false</returns>
    public bool CoarseCheckCapability(string cap)
    {
      IMTSecurity security = new MTSecurityClass();
      IMTCompositeCapability requiredCap = security.GetCapabilityTypeByName(cap).CreateInstance();
      return SessionContext.SecurityContext.CoarseHasAccess(requiredCap);
    }

    /// <summary>
    /// Serializes the specified data, and returns a string
    /// that can later be deserialized.
    /// </summary>
    /// <param name="data">The data to serialize.</param>
    /// <returns>The data serialized to a URL encoded string.</returns>
    public string Encode(object data)
    {
      if (data == null)
      {
        throw new ArgumentNullException("data");
  }

      BinaryFormatter formatter = new BinaryFormatter();
      byte[] dataBytes;

      // Serialize the data to a byte array. 
      using (MemoryStream stream = new MemoryStream())
      {
        formatter.Serialize(stream, data);
        dataBytes = stream.ToArray();
}

      // Encrypt
      var encrypt = new QueryStringEncrypt();
      string s = encrypt.EncryptString(Encoding.UTF8.GetString(dataBytes));
      return s;
    }

    /// <summary>
    /// Deserializes the specified value.
    /// </summary>
    /// <param name="value">The URL encoded string representing
    /// the object return value.</param>
    /// <returns>The object that was initially serialized
    /// using the <see cref="Encode"/> method.</returns>
    public object Decode(string value)
    {
      if (value == null)
      {
        throw new ArgumentNullException("value");
      }

      // Decrypt string
      var encrypt = new QueryStringEncrypt();
      string s = encrypt.DecryptString(value);
      byte[] b = Encoding.UTF8.GetBytes(s);


      // Reinstantiate the object instance. 
      BinaryFormatter formatter = new BinaryFormatter();
      object deserialized;

      using (MemoryStream stream = new MemoryStream(b))
      {
        deserialized = formatter.Deserialize(stream);
      }

      return deserialized;
    }
  }
}
