using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.EnterpriseServices;


namespace MetraTech.Auth.Capabilities
{
  using RS=MetraTech.Interop.Rowset;
  using MetraTech;
  using MetraTech.Interop.MTAuth;
  //using MetraTech.Interop.MTAuthCapabilities;



	/// <summary>
  /// ManageOwnedAccounts guards business operations of managing 
  /// accounts owned by sales force member and his/her subordinates.
  /// This capability grants an ability to manage accounts (read or write), which are owned
  /// by SFH member directly or by his hierarchical subordinates. We use PathCapability to specify the level
  /// of granted management - just this member; member and direct subordinates; member and all subordinates.
  /// This capability is TIME SENSITIVE, because account ownership is time sensitive. We always use MetraTime.Now
  /// when checking this capability
  /// </summary>
  /// 
  [Guid("5730d547-8c2c-485d-bfac-91996a0a4989")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ManageOwnedAccounts : MTCompositeCapability, IMTCompositeCapability
  {
      public ManageOwnedAccounts()
      {
      }
    
    public override bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
    {

      int ActorAccount = (this).ActorAccountID;
      if(ActorAccount < 0)
        throw new CapabilityException("Actor Account Property is not initialized. Perhaps you are calling Implies() on the capability object instead of calling CheckAccess() on SecurityContext");
			//CR 12577
			if(string.Compare(aCap.CapabilityType.ProgID, "Metratech.MTViewOnlineBillCapability", true) == 0)
			{
				return true;
			}
			
      //if passed in capability is ManageAccountHieararchy then
      // we will return false in case of coarse check (coarse check = personalization, and we don't
      //want SFH members to browse subscriber hierarchy)
      //In case of parameterized check, we want to check whether the actor OWNS this account.
      //Basically, what we are saying is: If this person OWNs the account and he/she also has a capability
      //to manage owned accounts, then he should be able to Manage this account in the hierararchy
      if(string.Compare(aCap.CapabilityType.ProgID, "MetraTech.MTManageAHCapability", true) == 0)
      {
        //never imply Coarse MTManageAHCapability. Out intention is to only imply MTManageAHCapability
        //in case of "umbrella" check. If we DID imply coarse MTManageAHCapability, this would mean
        // that a Sales Force member would be able to browse Account Hierarchy, which is wrong.
        if(aCheckParams == false) return false;

        string leaf = aCap.GetAtomicPathCapability().GetParameter().LeafNode;
        //if leaf node is empty, this means that some kind of recursive
        //check is being performed (on a directory: e.g. '/123/125/*', '/', '/-')
        //We don't want to imply that
        if (leaf.Length == 0)
          return false;
        int owned_id_acc = -1;
        try
        {
          owned_id_acc = System.Convert.ToInt32(leaf);
          Debug.Assert(owned_id_acc > 0);
        }
        catch(Exception)
        {
          //Weird. Account ID is not numeric. Maybe this is
          //done from smoke tests (some of them use names).
          return false;
        }
        MTHierarchyPathWildCard wc = MTHierarchyPathWildCard.SINGLE;
        
        return new AuthCheckReader().CanManageOwnedAccount(owned_id_acc, wc, (this).ActorAccountID);      
      }

      //basic check will perform path capability "snapshot" check and access level check
      bool bBasicCheckPassed = base.Implies(aCap, aCheckParams);

      
      //If we got here, it means that aCap is of ManageOwnedAccounts type

      if(bBasicCheckPassed == false) return false;
      //don't go any further during coarse check
      if(aCheckParams == false) return true;

      //once we are done with snapshot (non time sensitive) check, we need to
      //select this membership record based on MetraTime.Now timestamp.
      //The record may not be returned if: 1) Hierarchical relationship between one and one's subordinate account
      //does not exist 2) ownership relationship does not exists
      //If the record is returned, then we need to match num_generations agains the capability "depth" indicator.
      //AUTH_ACCESS_DENIED is returned if either empty rowset is returned OR the depth (wildcard) is "current" and num_generations
      // is greater than 0, OR if the wildcard is "-" (direct descendents only) and num_generations is greater than 1
      else
      {
        Debug.Assert(aCap is ManageOwnedAccounts);
        int owned_id_acc = -1;
        string leaf = aCap.GetAtomicPathCapability().GetParameter().LeafNode;
        
        //if leaf is empty, then we are not asked to
        //check the capability for a particular account
        //most likely it is  personalization check
        if(leaf.Length == 0)
          return true;
        
        try
        {
          owned_id_acc = System.Convert.ToInt32(leaf);
          Debug.Assert(owned_id_acc > 0);
        }
        catch(Exception)
        {
          throw;
        }
        MTHierarchyPathWildCard wc = aCap.GetAtomicPathCapability().GetParameter().WildCard;
        
        return new AuthCheckReader().CanManageOwnedAccount(owned_id_acc, wc, ActorAccount);
      }
    }
  }

  /// <summary>
  /// ManageSalesForceHierarchy guards business operations of managing 
  /// SFH accounts
  /// </summary>
  /// 
  [Guid("0269b139-98b4-42e6-82ba-c5a390b94f1e")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ManageSalesForceHierarchy : MTCompositeCapability, IMTCompositeCapability
  {
    public override bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
    {
      //if passed in capability is ManageAccountHieararchy then
      //we will return true only in case of coarse check (coarse check = personalization)
      //We are saying that if a SFH member has a capability to Manage Sales Force Hieararchy 
      //(this means that he can manage ownerships), then he should be able to browse the entire
      //subscriber hierarchy
      if(aCheckParams == false && string.Compare(aCap.CapabilityType.ProgID, "MetraTech.MTManageAHCapability", true) == 0)
      {
        return true;
      }
      else
        return base.Implies(aCap, aCheckParams);
    }

    
  }

  [Guid("3656f4a1-97b6-4950-8ee9-d3bbf7396e30")]
  public interface IAuthCheckReader
  {
    bool CanManageOwnedAccount(int OwnedAccount, MTHierarchyPathWildCard wildcard, int ActorAccount);
  }

  [Guid("2594eab6-41ee-4e67-8ec8-591e44903a81")]
  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
  public class AuthCheckReader : ServicedComponent, IAuthCheckReader
  {
    public AuthCheckReader(){}
    
    public bool CanManageOwnedAccount(int OwnedAccount, MTHierarchyPathWildCard wildcard, int ActorAccount)
    {
      if(ActorAccount < 0)
        throw new CapabilityException("Actor Account Property is not initialized. Perhaps you are calling Implies() on the capability object instead of calling CheckAccess() on SecurityContext");
      int owner_id_acc = ActorAccount;
      int owned_id_acc = OwnedAccount;
      int score;

      if (wildcard == MTHierarchyPathWildCard.SINGLE)
          score = 1;
      else if (wildcard == MTHierarchyPathWildCard.DIRECT_DESCENDENTS)
          score = 2;
      else if (wildcard == MTHierarchyPathWildCard.RECURSIVE)
          score = 1000000;
      else
          throw new ApplicationException(String.Format("Invalid setting {0} for path", wildcard.ToString())); 
      IMTSQLRowset rowset = (IMTSQLRowset)new RS.MTSQLRowset();
      rowset.Init(@"Queries\AccHierarchies");
      rowset.SetQueryTag("__AUTHCHECK_GET_OWNERSHIP_RECORD__");
      rowset.AddParam("%%ID_OWNER%%", owner_id_acc, false);
      rowset.AddParam("%%ID_OWNED%%", owned_id_acc, false); 
      rowset.AddParam("%%VIEW_CONSTRAINT%%", score, false);
      rowset.AddParam("%%MAX_DATE%%", MetraTime.Max, false);
      rowset.ExecuteDisconnected();
      int numrecords = rowset.RecordCount;
      //this rowset can return 0 records if neither the actor nor actor's incumbent folders own this account,
      //1, or 2 (if both the actor and the incumbent folder owns this account)
      Debug.Assert(numrecords < 3);
      return numrecords > 0;
    }
    
  }

  [Guid("83bd6133-ffc0-4c0e-a45e-19b58e31cb09")]
  [ClassInterface(ClassInterfaceType.None)]
  public class CapabilityException : ApplicationException
  {
    public CapabilityException(string msg) : base(msg){}
  }
}
