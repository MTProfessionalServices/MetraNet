using System.Runtime.InteropServices;

[assembly: GuidAttribute("735540A7-5AB8-4d53-AA0D-BB801F027831")]

namespace MetraTech.Accounts.Type
{
  using System;
  using System.Collections;
  using System.EnterpriseServices;
  using System.Runtime.InteropServices;

  using MetraTech;
  using MetraTech.Collections;
  using MetraTech.DataAccess;
  using MetraTech.Interop.MTProductCatalog;
  using MetraTech.Pipeline;
  //using MTAccountType = MetraTech.Interop.IMTAccountType;
	using MetraTech.Interop.IMTAccountType;
  using MTCollection = MetraTech.Interop.GenericCollection;
  using Rowset = MetraTech.Interop.Rowset;

	[Guid("52a43d0b-5b96-480f-aa96-1d8a5b4e85df")]
	public interface IAccountTypeManager
	{
		IMTAccountType GetAccountTypeByName(IMTSessionContext ctx, string name);
		IMTAccountType GetAccountTypeByID(IMTSessionContext ctx, int id);
	}
 
  [ComVisible(true)]
  [Guid("dd0d9d89-4c65-4009-8ac6-8525faeff204")]
  public class AccountTypeManager : IAccountTypeManager
  {
    
    private Logger mLogger;

    public AccountTypeManager()
    {
      mLogger = new Logger("[AccountType]");
    }

		
		public IMTAccountType GetAccountTypeByName(IMTSessionContext ctx, string AccountTypeName)
		{
			return AccountTypeCache.GetInstance().GetAccountTypeByName(AccountTypeName);
		}

		public IMTAccountType GetAccountTypeByID(IMTSessionContext ctx, int id)
		{
			return AccountTypeCache.GetInstance().GetAccountTypeByID(id);
		}
  }

	[ComVisible(false)]
	public class AccountTypeCache
	{
		private ArrayList mAccountTypes;
		
		private static AccountTypeCache mInstance = null;

		private AccountTypeCache()
		{
			mAccountTypes = new ArrayList();
		}


		public static AccountTypeCache GetInstance()
		{
			//double checked locking
			if(mInstance == null)
			{
				lock(typeof(AccountTypeCache))
				{
					if(mInstance == null)
						mInstance =  new AccountTypeCache();
				}
			}
			return mInstance;
		}

		public IMTAccountType GetAccountTypeByName(string AccountTypeName)
		{
			IMTAccountType outat = null;
			foreach(IMTAccountType at in mAccountTypes)
			{
				if(string.Compare(AccountTypeName, at.Name, true) == 0)
				{
					outat = at;
				}
			}

			if(outat == null)
			{
				lock(typeof(AccountTypeCache))
				{
					IMTAccountType acctype = new AccountType();
					acctype.InitializeByName(AccountTypeName);
					mAccountTypes.Add(acctype);
					outat = acctype;
				}
			}

			return outat;


		}
		public IMTAccountType GetAccountTypeByID(int id)
		{
			IMTAccountType outat = null;
			foreach(IMTAccountType at in mAccountTypes)
			{
				if(id == at.ID)
				{
					outat = at;
				}
			}

			if(outat == null)
			{
				lock(typeof(AccountTypeCache))
				{
					IMTAccountType acctype = new AccountType();
					acctype.InitializeByID(id);
					mAccountTypes.Add(acctype);
					outat = acctype;
				}
			}

			return outat;


		}
	}
}


