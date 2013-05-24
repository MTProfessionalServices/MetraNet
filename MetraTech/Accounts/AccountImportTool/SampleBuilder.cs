using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Xml.Serialization;
using System.Runtime.Serialization;
using MetraTech;
using MetraTech.DataAccess;
using MetraTech.DomainModel;
using MetraTech.Performance;
using MetraTech.Interop.MTServerAccess;
using MetraTech.ActivityServices.Common;

using System.Reflection;
using System.IO;
using System.Text.RegularExpressions;
using System.Xml;

/// Creates an example xml file that can be used as a
/// model to create an account.  A web service is used
/// to get the domain model for the account to base
/// the xml on.

namespace MetraTech.Accounts.AccountImportTool
{
  class SampleBuilder
  {
    /// <summary>
    /// Create an example xml file that can be used as a model
    /// to create an account.
    /// </summary>
    /// <returns></returns>
    public static void MakeSample(string username, 
                                  string password,
                                  int accountID,
                                  string fullFilename)
    {
      AccountIdentifier acct = new AccountIdentifier(accountID);
      System.DateTime timestamp = System.DateTime.Now;
      MetraTech.DomainModel.BaseTypes.Account domainModelOfAccount;

      // Given the account ID, create the domain model representation.
      LoadAccountWithViews(acct, timestamp, username, password, out domainModelOfAccount);

      // Write out the XML representation of the domain model.
      WriteXmlFile(domainModelOfAccount, fullFilename);
    }

    /// <summary>
    /// Get the domain model representation of an account
    /// be using a web service.
    /// </summary>
    /// <param name="accountID">the account ID.</param>
    /// <param name="timeStamp">the time at which the account existed (typically now)</param>
    /// <param name="username">credentials for accessing server</param>
    /// <param name="password">credentials for accesing server</param>
    /// <param name="accDomainModel"></param>
    private static void LoadAccountWithViews(AccountIdentifier accountID, 
                                             System.DateTime timeStamp,
                                             string username,
                                             string password,
                                             out MetraTech.DomainModel.BaseTypes.Account accDomainModel)
    {
      accDomainModel = null;
      MetraTech.Core.Services.ClientProxies.AccountServiceClient client = null;
      try
      {
        client = new MetraTech.Core.Services.ClientProxies.AccountServiceClient("WSHttpBinding" + "_IAccountService");
        client.ClientCredentials.UserName.UserName = username;
        client.ClientCredentials.UserName.Password = password;

        client.LoadAccountWithViews(accountID, timeStamp, out accDomainModel);
      }
      catch (Exception e)
      {
        m_logger.LogFatal("Failed to find account: " + accountID.AccountID);
        Console.WriteLine("Failed to find account: " + accountID.AccountID + 
                          "Exception: " + e.Message);
      }
    }

    /// <summary>
    /// Given the domain model for an account, write it out to
    /// the given file name.  The written xml is altered so that
    /// it can serve as an example of the format needed by the
    /// accountImportTool.
    /// </summary>
    /// <param name="accDomainModel">holds domain model for account</param>
    /// <param name="fullFilename">where we should write the xml.  will be created if 
    ///                            doesn't exist.
    /// </param>
    private static void WriteXmlFile(MetraTech.DomainModel.BaseTypes.Account accDomainModel, 
                                     string fullFilename)
    {
      // Make sure we were given an account.
      if (accDomainModel == null)
      {
        return;
      }

      FileStream dcWriter = new FileStream(fullFilename, FileMode.Create);
      try
      {
        DataContractSerializer ser = new DataContractSerializer(typeof(MetraTech.DomainModel.BaseTypes.Account));
        ser.WriteObject(dcWriter, accDomainModel);
      }
      catch (Exception e)
      {
        Console.WriteLine("Encountered an error attempting to write xml: " + e.Message);
        m_logger.LogFatal("Encountered an error attempting to write xml: " + e.Message);
      }

      finally 
      { 
        dcWriter.Close(); 
      }

      TailorXmlNodes(fullFilename);
    }

    /// <summary>
    /// We need to tailor the xml nodes that the accountImportTool user
    /// is going to see and potentially use.  
    /// We are making these changes so that resulting xml is 
    /// something that can be used to help form the xml needed to
    /// create an account.  The changed xml is written to the given 
    /// file.
    /// 
    /// Changes:
    ///           remove all nodes referring to "Dirty"
    ///           remove node _AccountID
    ///           remove node AncestorAccount
    ///           remove node AncestorAccountID
    ///           remove node AncestorAccountNS
    ///           add node for Password_
    /// </summary>
    /// <param name="fullFilename">contains xml to tailor. Results are
    ///                            written back to this file.
    /// </param>
    private static void TailorXmlNodes(string fullFilename)
    {
      XmlDocument xmlDocument = new XmlDocument();
      xmlDocument.Load(fullFilename);

      // Remove all nodes referring to Dirty.
      // Remove _AccountID and Ancestor nodes
      XmlNodeList aElements = xmlDocument.SelectNodes("//*");
      foreach (XmlNode node in aElements)
      {
        if (node.ParentNode == null)
        {
          continue;
        }

        if (node.Name.Contains("Dirty") ||
            node.Name.Equals("_AccountID") ||
            node.Name.Equals("AncestorAccount") ||
            node.Name.Equals("AncestorAccountID") ||
            node.Name.Equals("AncestorAccountNS"))
        {
          node.ParentNode.RemoveChild(node);
        }
      }

      // Add a node for password.
      XmlNodeList bElements = xmlDocument.SelectNodes("//*");
      foreach (XmlNode node in bElements)
      {
        if (node.ParentNode == null)
        {
          continue;
        }

        if (node.Name.Equals("Name_Space"))
        {
          XmlElement elem = xmlDocument.CreateElement("Password_",  
                                                      xmlDocument.DocumentElement.NamespaceURI);
          elem.InnerText = "REPLACE_THIS";
          node.ParentNode.InsertAfter(elem, node);
          break;
        }
      }

      FileStream stream = new FileStream(fullFilename, FileMode.Truncate);
      xmlDocument.Save(stream);
      stream.Close();
    }

    private static Logger m_logger = new Logger("[AccountImportTool]");
  }
}
