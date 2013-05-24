using System;
using System.Xml;
using System.Xml.Serialization;
using MetraTech.DataAccess;

namespace MetraTech.Accounts.Hierarchy.WebService
{
  /// <summary>
  /// Enum for the different types of items in the hierarchy.  
  /// Corporate accounts are treated like folders.
  /// </summary>
  public enum HierarchyItemType
  {
    Account = 0,
    Folder = 1
  }

  /// <summary>
  /// MAMHierarchyItem - Item type that is populated in the hierarchy control.
  /// </summary>
  public class MAMHierarchyItem
  {
    /// <summary>
    /// Name of account type
    /// </summary>
    public string AccountType = "";
 
    /// <summary>
    /// Icon to use through Icon Handler
    /// </summary>
     public string Icon = "";

    /// <summary>
    /// Whether or not current user modify this node.
    /// </summary>
    public bool CanWrite = false;
     
    /// <summary>
    /// Whether or not this node contains any direct descendants.
    /// </summary>
    public bool HasChildren = false;

    /// <summary>
    /// Account user name.
    /// </summary>
    public string LoginName = null;

    /// <summary>
    /// Account Namespace.
    /// </summary>
    public string Namespace = null;

    /// <summary>
    /// Name displayed in the hierarchy.  Comes from database view.
    /// </summary>
    public string HierarchyName = null;

    /// <summary>
    /// Account state at reference date.
    /// </summary>
    public string AccountState = null;

    /// <summary>
    /// Number of accounts this account pays for
    /// </summary>
    public long NumberOfPayees = 0;

    /// <summary>
    /// Does this account own a folder?
    /// </summary>
    public string Owner = null;

    /// <summary>
    /// Path in hierarchy to account.
    /// </summary>
    public string HierarchyPath = null;

    /// <summary>
    /// Account ID 
    /// </summary>
    public long ItemID = 0;

    /// <summary>
    /// Parent Account ID
    /// </summary>
    public long ParentItemID = 0;

    /// <summary>
    /// Type of hierarchy item: <see cref="HierarchyItemType"/>
    /// </summary>
    public HierarchyItemType ItemType = HierarchyItemType.Account;

    /// <summary>
    /// Currency associated with account
    /// </summary>
    public string Currency = null;

	public int HasLogonCapability { get; set; }

    /////////////////////////////////////////////////////////////////////////
    ///Constructors                                                       ///
    /////////////////////////////////////////////////////////////////////////
    //Constructor -- Set defaults
    public MAMHierarchyItem()
    {
      
    }

    //Constructor -- Load item from data reader
    public MAMHierarchyItem(IMTDataReader oReader)
    {
      //ID
      ItemID = long.Parse(oReader.GetValue("child_id").ToString());

      // Account Type
      AccountType = oReader.GetValue("account_type").ToString();

      // Icon
      Icon = oReader.GetValue("icon").ToString();

      //Children or connected_se then HasChildren
      if(oReader.GetValue("children").ToString().Equals("Y"))
        HasChildren = true;
      else
        HasChildren = false;

      //Login & Namespace
      LoginName = oReader.GetValue("nm_login").ToString();
      Namespace = oReader.GetValue("nm_space").ToString();

      //Hierarchy name
      HierarchyName = oReader.GetValue("hierarchyname").ToString();
      
      //Status
      AccountState = oReader.GetValue("status").ToString();

      //NumPayees
      NumberOfPayees = long.Parse(oReader.GetValue("numpayees").ToString());

      //Folder Owner
      Owner = oReader.GetValue("folder_owner").ToString();

      //Tx Path
      HierarchyPath = oReader.GetValue("tx_path").ToString();

      ParentItemID = long.Parse(oReader.GetValue("parent_id").ToString());     

      //Set the type
      if(oReader.GetValue("folder").ToString().Equals("1"))
      {
        ItemType = HierarchyItemType.Folder;
      }
      else
      {
        ItemType = HierarchyItemType.Account;
      }

      //Currency
      Currency = oReader.GetValue("Currency").ToString();            
    }
  }
}