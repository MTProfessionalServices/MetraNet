using System;
using System.Data.SqlClient;
using System.Data;
using System.Data.SqlTypes;

using System.Text.RegularExpressions;
using Auth.Capabilities;
using Auth.Exceptions;
using Auth.Principals;
using Auth.SecurityFramework;
using MTRULESETLib;

using System.Reflection;
using System.Collections;



namespace Auth
{
	namespace SecurityFramework
	{
		public class LoginContext
		{
			public SecurityContext login(string aAlias, string aNamespace)			
			{
				SecurityContext ctx = new SecurityContext();
				COMKIOSKLib.COMAccount a;
				try
				{
					a = new COMKIOSKLib.COMAccount();
					a.Initialize();
					a.GetAccountInfo(aAlias, aNamespace);
				}
				catch(System.Runtime.InteropServices.COMException e)
				{
					string msg = e.Message;
					return null;
				}

				ctx.Init(a.AccountID);
				return ctx;
			}

			public void logout(SecurityContext aCtx){}
		}
		public class SecurityContext
		{
			public bool CheckAccess(CompositeCapability aDemandedCap)
			{
				
				//get all principals
				ISecurityPrincipal p;
				
				System.Collections.IEnumerator it = mPrincipals.GetEnumerator();
				while(it.MoveNext())
				{
					
					try
					{
						p = (ISecurityPrincipal)it.Current;
					}
					catch(System.InvalidCastException e)
					{
						//shouldn't happen
						string msg = e.Message;
						return false;
					}
					//for each principal iterate through capabilities
					IEnumerator en = p.Capabilities;
					while(en.MoveNext())
					{
						ICapability cap = (ICapability)en.Current;
						
						if(cap.implies(aDemandedCap))
							//once we hit the first one, return immediately
							return true;
					}

				}
				return false;
			}
			
			public System.Collections.ICollection Principals
			{
				get {return mPrincipals;}
			}
			public void AddPrincipal(ISecurityPrincipal aPrincipal)
			{
				mPrincipals.Add(aPrincipal);
			}
			public void Init(int aAccountID)
			{
				
				//1. Create account principal
				Account acc = new Account();
				acc.Init(aAccountID);

				mPrincipals.Add(acc);

				//add roles that this account has
				//directly to principal collection
				IEnumerator roles = acc.Roles;
				while(roles.MoveNext())
					mPrincipals.Add(roles.Current);

				/*
				switch (aAccountID)
				{
					case 123:
						InitAccountPrincipal();		
						InitCoreFolderOwner();
						break;
					case 125:
						InitAccountPrincipal();		
						InitJuniorCSR();
						break;
					case 128:
						InitAccountPrincipal();
						InitSeniorCSR();
						break;
					default:
						//account id has no principals
						return;
				}
				*/
				return;
			}

			/*
			public void InitAccountPrincipal()
			{
				Account accpr = new Account();
				accpr.Name = "Raju";
				//part of Raju account principal
				AccountCapability ac = new AccountCapability("/metratech/engineering/core/Raju", AccessType.WRITE);

				//add AccountExtension ICapability. It will be required by MANAGE_ACCOUNT_PROPERTIES cap while setting properties
				//on the account
				AccountExtensionCapability aexc = new AccountExtensionCapability("/metratech/engineering/core/Raju", AccessType.WRITE);

				//for itself, an account will not be limited to any of the extensions: modifications
				//of propeties in all the extensions is possible
				//no extensions means "All extensions" (Is This correct?)
				//aexc0.AddExtension("metratech.com/contact");
				//aexc0.AddExtension("metratech.com/internal");

				//Account principal only has capabilities to modify itself
				accpr.AddCapability("MANAGE_ACCOUNT_HIERARCHY", ac);
				accpr.AddCapability("MANAGE_ACCOUNT_PROPERTIES", aexc);
				
				mPrincipals.Add(accpr);
			}

				


			public void InitCoreFolderOwner()
			{
				//CoreFolderOwner role description:
				//the principal with this role has an ability to manage all the account underneath
				//EXCEPT for being able to only update the properties in metratech.com/contacts extension
				//and no ICapability to issue credits

				//This role may be indirectly associated with the principal
				//by "Ownership" association between the principal and Core folder
				Role rolepr = new Role();
				rolepr.Name = "CoreFolderOwner";

				//Add two AccountCapabilities. They will be needed by MANAGE_ACCOUNT_HIERARCHY
				//Capability in the Account.Move() method
				
				

				
				AccountCapability ac = new AccountCapability("/metratech/engineering/core/*", AccessType.WRITE);

				//read all properties
				AccountExtensionCapability aexc0 = new AccountExtensionCapability("/metratech/engineering/core/*", AccessType.READ);
				
				
				//write only contact extension properties
				AccountExtensionCapability aexc1 = new AccountExtensionCapability("/metratech/engineering/core/*", AccessType.WRITE);
				aexc0.AddExtension("metratech.com/contact");
				
				rolepr.AddCapability("MANAGE_ACCOUNT_HIERARCHY", ac);
				rolepr.AddCapability("MANAGE_ACCOUNT_PROPERTIES", aexc0);
				rolepr.AddCapability("MANAGE_ACCOUNT_PROPERTIES", aexc1);

				mPrincipals.Add(rolepr);
			}
			public void InitJuniorCSR()
			{
				//JuniorCSR role description:
				//the principal with this role has an ability to manage all the accounts under Metratech
				//EXCEPT for being able to only issue credit up to 50 dollars
				//and no ICapability to issue credits

				//This role may be indirectly associated with the principal
				//by "Ownership" association between the principal and Core folder
				Role rolepr = new Role();
				rolepr.Name = "JuniorCSR";

				//Add two AccountCapabilities. They will be needed by MANAGE_ACCOUNT_HIERARCHY
				//Capability in the Account.Move() method
				
				

				
				AccountCapability ac = new AccountCapability("/metratech/*", AccessType.WRITE);

				AccountExtensionCapability aexc0 = new AccountExtensionCapability("/metratech/*", AccessType.WRITE);

				AccountNameValueCapability nvc = new AccountNameValueCapability("/metratech/*", AccessType.WRITE);

				MTSimpleCondition creditlimit = new MTSimpleCondition();
				creditlimit.PropertyName = "Amount";
				creditlimit.ValueType = PropValType.PROP_TYPE_DECIMAL;
				creditlimit.Test = "<=";
				creditlimit.Value = 50;
				nvc.AddCondition(creditlimit);
				
				rolepr.AddCapability("MANAGE_ACCOUNT_HIERARCHY", ac);
				rolepr.AddCapability("MANAGE_ACCOUNT_PROPERTIES", aexc0);
				rolepr.AddCapability("MANAGE_ACCOUNT_CREDITS", nvc);

				mPrincipals.Add(rolepr);
			}

			public void InitSeniorCSR()
			{
				//JuniorCSR role description:
				//the principal with this role is basically a super user, which can do anything

				//This role may be indirectly associated with the principal
				//by "Ownership" association between the principal and Core folder
				Role rolepr = new Role();
				rolepr.Name = "SeniorCSR";

				//Add two AccountCapabilities. They will be needed by MANAGE_ACCOUNT_HIERARCHY
				//Capability in the Account.Move() method
				SuperUserCapability suc = new SuperUserCapability();
				rolepr.AddCapability("SUPER_USER", suc);
				mPrincipals.Add(rolepr);
			}

			*/
			private System.Collections.ArrayList mPrincipals = new System.Collections.ArrayList();

			
		}

		public class SecurityPolicy
		{
			/// <summary>
			/// Grant capability to a principal. aCap object is a fully constructed concret capability with all the parameters specified
			/// </summary>
			public bool GrantCapability(ISecurityPrincipal aPrincipal, CompositeCapability aCap)
			{
				//do security check
				return aCap.Save(aPrincipal);
			}
			public void GrantRole(int aAccountID, Role aRole)
			{
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
					  NULL identity(1,1), 
					id_parent_cap_instance int NOT NULL,
					id_principal int NOT NULL,
					id_cap_class int NOT NULL
					*/
				string query = "INSERT INTO t_account_role VALUES";
				query += "(" + aAccountID + ", " + aRole.ID + ")";
				command.CommandText = query;
				command.ExecuteScalar();
			}
			public void RemoveRole(int aAccountID, Role aRole)
			{
			}
			/// <summary>
			///Revoke capability from a principal. aCap object would first need to be obtained by calling IPrincipal::GetCapabilities
			/// </summary>
			public void RevokeCapability(ISecurityPrincipal aPrincipal, CompositeCapability aCap)
			{
			}
			public IEnumerator GetCapabilities(ISecurityPrincipal aPrincipal)
			{
				return null;
			}
			public IEnumerator GetRolesByAccount(int aAccountID)
			{
				Account acc = new Account();
				acc.Init(aAccountID);
				return acc.Roles;
			}
			public IEnumerator GetRoles()
			{
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				string query = "SELECT role.id_role, role.tx_name, role.tx_desc, cap.id_cap_class, cap.id_cap_instance, capclass.tx_guid, capclass.tx_desc, capclass.tx_editor from t_role role, t_capability_instance cap, t_capability_class capclass";
				query += " WHERE cap.id_role=role.id_role and cap.id_parent_cap_instance IS NULL AND cap.id_cap_class=capclass.id_cap_class";
				command.CommandText = query;

				SqlDataReader reader = command.ExecuteReader();
				ArrayList roles = new ArrayList();
				int roleid = 0;
				bool bDiffRole = false;
				Role role = new Role();
				while(reader.Read())
				{
					if (roleid != reader.GetInt32(0))
					{
						role = new Role();
						roleid = reader.GetInt32(0);
						role.ID = roleid;
						role.Name = reader.GetString(1);
						role.Description = reader.GetString(2);
						bDiffRole = true;
					}

					int id_cap_class = reader.GetInt32(3);
					int id_cap_instance = reader.GetInt32(4);
					string guid = reader.GetString(5);
					string capdesc = reader.GetString(6);
					string capeditor = reader.GetString(7);

					//initialize capabilties and add them to Role object
					CompositeCapability cap = (CompositeCapability)System.Activator.CreateInstance(System.Type.GetType(guid));
					cap.ClassID = id_cap_class;
					cap.ID = id_cap_instance;
					cap.Description = capdesc;
					cap.Editor = capeditor;
					//load all the parameters for this principal
					cap.Load(role);
					role.AddCapability(cap);
					if(bDiffRole)
					{
						bDiffRole = false;
						roles.Add(role);
					}
				}
				return roles.GetEnumerator();
			}
			public IEnumerator GetSystemCapabilities()
			{
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				command.CommandText = "SELECT id_cap_class, tx_guid, tx_desc, tx_editor from t_capability_class";
				SqlDataReader reader = command.ExecuteReader();
				ArrayList allcaps = new ArrayList();
				while(reader.Read())
				{
					int classid = reader.GetInt32(0);
					string guid = reader.GetString(1);
					
					string desc = reader.GetString(2);
					string editor = reader.GetString(3);
					//TODO: set description
					//cap.Description
					//TODO: set editor

					CompositeCapability cap = (CompositeCapability)System.Activator.CreateInstance(System.Type.GetType(guid));
					cap.ClassID = classid;
					cap.Description = desc;
					cap.Editor = editor;
					allcaps.Add(cap);
				}
				return allcaps.GetEnumerator();
			}

			public SecurityPolicy CreateDefault(ISecurityPrincipal aPrincipal)
			{
				return new SecurityPolicy();
			}
			public SecurityPolicy CreateDefaultSystemWide()
			{
				return new SecurityPolicy();
			}

			public SecurityPolicy GetDefault(ISecurityPrincipal aPrincipal)
			{
				return new SecurityPolicy();
			}

		}
		
	}
	
	namespace Principals
	{
		public enum PrincipalType
		{
			ROLE, ACCOUNT
		}
		public abstract class ISecurityPrincipal
		{
			private ArrayList mCaps = new ArrayList();
			public IEnumerator Capabilities
			{
				get {return mCaps.GetEnumerator();}
				
			}
			public void AddCapability(ICapability aCap)
			{
				mCaps.Add(aCap);
			}
			public PrincipalType PrincipalType;

			public int ID
			{
				get{return mID;}
				set{mID  = value;}
			}
			public abstract bool Init(int aPrincipalID);
			protected virtual bool InitCapabilities(int aID)
			{
				//initialize capabilities associated with this principal
				ID = aID;
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();

				string table = PrincipalType == PrincipalType.ACCOUNT ? "t_account" : "t_role";
				string field = PrincipalType == PrincipalType.ACCOUNT ? "id_acc" : "id_role";

				string query = "SELECT cap.id_cap_class, cap.id_cap_instance, capclass.tx_guid, capclass.tx_desc, capclass.tx_editor from " + table + " principal, t_capability_instance cap, t_capability_class capclass";
				query += " WHERE cap."+field+"=principal." + field + " and cap.id_parent_cap_instance IS NULL AND cap.id_cap_class=capclass.id_cap_class";
				query += " AND principal." + field + "=" + ID;
				command.CommandText = query;

				SqlDataReader reader = command.ExecuteReader();
				while(reader.Read())
				{
					int id_cap_class = reader.GetInt32(0);
					int id_cap_instance = reader.GetInt32(1);
					string guid = reader.GetString(2);
					string capdesc = reader.GetString(3);
					string capeditor = reader.GetString(4);

					//initialize capabilties and add them to Role object
					CompositeCapability cap = (CompositeCapability)System.Activator.CreateInstance(System.Type.GetType(guid));
					cap.ClassID = id_cap_class;
					cap.ID = id_cap_instance;
					cap.Description = capdesc;
					cap.Editor = capeditor;
					//load all the parameters for this principal
					cap.Load(this);
					AddCapability(cap);
				}
				return true;

			}

			protected int mID;

		}
		public class Account : ISecurityPrincipal
		{
			public Account()
			{
				PrincipalType = PrincipalType.ACCOUNT;
				mParent = null;
			}
			public string Name 
			{
				get { return mName;}
				set
				{
					//check MANAGE_ACCOUNT_ATTRIBUTES cap
					mName = value;
					mDN = GenerateDN();
				}
			}
			public override bool Init(int aID)
			{
				ID = aID;
				if(!this.InitCapabilities(aID))
					return false;
				return InitRoles(aID);
			}
			private bool InitRoles(int aID)
			{
				//get roles associated with this account
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				string query = "SELECT t_role.id_role, tx_name, tx_desc FROM t_account_role, t_role WHERE t_account_role.id_role=t_role.id_role AND id_acc = " + ID;
				command.CommandText = query;

				SqlDataReader reader = command.ExecuteReader();
				
				while(reader.Read())
				{
					Role role = new Role();
					role = new Role();
					int roleid = reader.GetInt32(0);
					role.ID = roleid;
					role.Name = reader.GetString(1);
					role.Description = reader.GetString(2);
					role.Init(roleid);
					mRoles.Add(role);
				}
				return true;
			}			
			public IEnumerator Roles
			{
				get { return mRoles.GetEnumerator();}
			}
			public string GetDN() 
			{
				return mDN == null || mDN.Length == 0 ? GenerateDN() : mDN;
			}

			public Account GetParent() 
			{
				return mParent;
			}
			
			public bool AddChild(Account aChildAccount)
			{
				//1. I know the name and type for the required ICapability
				
				//2. Check if I can add a child to an account with distunguished name mDN?
				ManageAHCapability oRequiredCapability = new ManageAHCapability();
				//3. Give it to SecurityContext to evaluate;
				//we are checking whether we can move an account whose parent
				//is engineering/Core folder
				//Issue: Where do we check the destination?
				bool bAuthCheckSucceeded = mCtx.CheckAccess(oRequiredCapability);
				if(bAuthCheckSucceeded)
				{
					if(aChildAccount.GetParent() != this)
						return aChildAccount.SetParent(this);
					return true;
				}
				else
					return bAuthCheckSucceeded;
			}


			public bool SetParent(Account aNewParent)
			{
				//1. I know the name and type for the required ICapability
				
				ManageAHCapability oRequiredCapability = new ManageAHCapability();
				//3. Give it to SecurityContext to evaluate;
				//we are checking whether we can move an account with
				//given DN
				bool bAuthCheckSucceeded = mCtx.CheckAccess(oRequiredCapability);
				if(bAuthCheckSucceeded)
				{
					//do move here
					if(GetParent() != aNewParent)
					{
						mParent = aNewParent;
						GenerateDN();
						return aNewParent.AddChild(this);
					}
					return true;
				}
				else
					return bAuthCheckSucceeded;

			}
			private string GenerateDN()
			{
				//walk parents, generate destinguished name
				string REGEX_SEP = "/";
				mDN = "";
				Account parent = GetParent();
				mDN = parent.GetDN() + REGEX_SEP + mName;
				return mDN;
			}
			public void SetSecurityContext(SecurityContext aCtx)
			{
				mCtx = aCtx;
			}
			
			//data
			private Account mParent;
			private string mDN; //distinguished name
			private string mName; //distinguished name
			private SecurityContext mCtx = null;
			private ArrayList mRoles = new ArrayList();

			/// <summary>
			/// Issue a credit to this account
			/// </summary>
			public bool IssueCredit(decimal aAmount)
			{
				//Check for MANAGE_ACCOUNT_CREDITS ICapability
				//1. I know the name and type for the required ICapability
				IssueCreditCapability oRequiredCapability = new IssueCreditCapability();

				oRequiredCapability.AddPathParameter(this.mDN);
				oRequiredCapability.SetAccessType(AccessType.WRITE);


				//add required condition before passing it to the SecurityPolicy
				MTSimpleCondition cond = new MTSimpleCondition();
				cond.PropertyName = "Amount";
				cond.ValueType = MTRULESETLib.PropValType.PROP_TYPE_DECIMAL;
				cond.Value = aAmount;

				
				oRequiredCapability.AddCondition(cond);

				//3. Give it to SecurityContext to evaluate;
				//we are checking whether we can move an account whose parent
				//is engineering/Core folder
				bool bAuthCheckSucceeded = mCtx.CheckAccess(oRequiredCapability);
				if(bAuthCheckSucceeded)
				{
					//do issue credit here
					return true;
				}
				else
					return bAuthCheckSucceeded;

			}

		}
		public class Role : ISecurityPrincipal
		{
			public Role()
			{
				PrincipalType = PrincipalType.ROLE;
			}

			public override bool Init(int aID)
			{
				ID = aID;
				return InitCapabilities(aID);
			}
			
			public string Name
			{
				get {return mName;}
				set {mName = value;}
			}
			public string Description
			{
				get {return mDescription;}
				set {mDescription = value;}
			}
			
			private string mName = null;
			private string mDescription = null;
			public int Save()
			
			{
				//save this instance, get id and then save all children
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
				  NULL identity(1,1), 
				id_parent_cap_instance int NOT NULL,
				id_principal int NOT NULL,
				id_cap_class int NOT NULL
				*/
				string query = "INSERT INTO t_role VALUES(";
				query += "'" + Name + "', '" + Description + "')";
				command.CommandText = query;

				command.ExecuteNonQuery();

				command.CommandText = " select @@identity FROM t_role";

				object identity = command.ExecuteScalar();
				decimal id = (decimal) command.ExecuteScalar();

				ID = (int)id;
				return ID;
			}

		}
	}
	namespace Capabilities
	{
		
		public enum AccessType
		{
			READ, WRITE, READWRITE
		}
		//currently not used
		//doesn't belong here either
		public enum AccountType
		{
			SYSTEM, CSR, SUBSCRIBER
		}
		public enum AccountState
		{
			ACTIVE, CLOSED, ARCHIVED
		}
		public interface ICapability
		{
			bool implies(ICapability cap);
			bool Save(ISecurityPrincipal aPrincipal);
//			void SetPrincipal(ISecurityPrincipal aPrincipal);
			
			//int GetID();
			//void SetID(int aID);

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			//int GetParentID();
			//void SetParentID(int aID);

			//int GetClassID();
			//void SetClassID(int aClassID);

		}
		public interface IAccessTypeCapability : ICapability
		{
			AccessType GetAccessType();
			void SetAccessType(AccessType aAccessType);

			
		}
		public interface IPathCapability : ICapability
		{
			IEnumerator GetPathParameters();
			void AddPathParameter(string aPathParameter);
		}
		public interface IAccountExtensionCapability : ICapability
		{
			IEnumerator GetExtensions();
			void AddExtension(string aExtension);
		}
		public interface IConditionCapability : ICapability
		{
			IEnumerator GetConditions();
			void AddCondition(MTSimpleCondition aCondition);
		}
		public class AccessTypeCapability : IAccessTypeCapability
		{
			public AccessTypeCapability()
			{
				//unless explicetly set,
				//Accesstype is everything
				mAccessType = AccessType.READWRITE;
			}
			public AccessType GetAccessType(){return mAccessType;}
			public void SetAccessType(AccessType aAccessType){mAccessType = aAccessType;}
			public void SetPrincipal(ISecurityPrincipal aPrincipal) {mPrincipal = aPrincipal;}
			public ISecurityPrincipal GetPrincipal() {return mPrincipal;}

			public void Load(ISecurityPrincipal aPrincipal)
			{
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
				CREATE TABLE t_capability_instance (id_cap_instance int NOT 
				 NULL identity(1,1), 
				id_parent_cap_instance int NOT NULL,
				id_acc int NULL,
				id_role int NULL,
				id_cap_class int NOT NULL
				 CONSTRAINT PK_t_capability_instance PRIMARY KEY CLUSTERED(id_cap_instance), 
				-- FOREIGN KEY (id_cap_class) REFERENCES t_capability_class,
				FOREIGN KEY (id_acc) REFERENCES t_account,
				FOREIGN KEY (id_role) REFERENCES t_role,
				CHECK(id_acc IS NULL OR id_role IS NULL))
				*/
				string principal = aPrincipal.PrincipalType == Principals.PrincipalType.ACCOUNT ? "id_acc" : "id_role";
				int prid = aPrincipal.ID;
				string query = "SELECT tx_param_value FROM t_capability_instance, t_access_type_capability ";
				query += "WHERE " + principal + " = " + prid + " AND id_parent_cap_instance = " + GetParentID();
				query += " AND t_capability_instance.id_cap_instance = t_access_type_capability.id_cap_instance";
				command.CommandText = query;

				SqlDataReader reader = command.ExecuteReader();
				ArrayList allcaps = new ArrayList();
				//supposed to be only one row
				while(reader.Read())
				{
					string param = reader.GetString(0);
					this.AccessType = param == "R" ? AccessType.READ : AccessType.WRITE;
				}			
			}


			public bool Save(ISecurityPrincipal aPrincipal)
			{
				//save this instance, get id and then save all children
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
				  NULL identity(1,1), 
				id_parent_cap_instance int NOT NULL,
				id_principal int NOT NULL,
				id_cap_class int NOT NULL
				*/
				
				string principal = aPrincipal.PrincipalType == PrincipalType.ACCOUNT ? "id_acc" : "id_role";

				string query = "INSERT INTO t_capability_instance (id_parent_cap_instance," + principal + ", id_cap_class) VALUES(";
				query +=  this.mParentID + ", " + aPrincipal.ID + ", " + mClassID + ")";
				command.CommandText = query;
				command.ExecuteNonQuery();

				command.CommandText = " select @@identity FROM t_capability_instance";

				decimal id = (decimal) command.ExecuteScalar();

				string accesstype = AccessType == AccessType.READ ? "R" : "W";

				//now insert into t_access_type table
				query = "INSERT INTO t_access_type_capability (id_cap_instance, tx_param_value) VALUES(";
				query += (int)id + ", '" + accesstype + "')";
				command.CommandText = query;
				command.ExecuteNonQuery();
				return true;
				
			}

			private ISecurityPrincipal mPrincipal = null;
			
			public bool implies(ICapability aDemandedCap)
			{
				AccessTypeCapability cap;
				try
				{
					cap = (AccessTypeCapability) aDemandedCap;
					return CheckAccessType(cap);
				}
				catch (System.InvalidCastException e)
				{
					//Capability passed was of different type
					string msg  = e.Message;
					return false;
				}
			}
			public AccessType AccessType
			{
				get {return mAccessType;}
				set{mAccessType = value;}
			}
			protected AccessType mAccessType;
			private bool CheckAccessType(AccessTypeCapability cap)
			{
				return mAccessType >=  cap.AccessType;
			}
			public int GetID(){return mID;}
			public void SetID(int aID){mID = aID;}

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			public int GetParentID() {return mParentID;}
			public void SetParentID(int aID){mParentID = aID;}

			public int GetClassID(){return mClassID;}
			public void SetClassID(int aID){mClassID = aID;}

			private int mID;
			private int mParentID;
			private int mClassID;

		}
		public class PathCapability : ICapability 
		{
			public void AddPathParameter(string aPath)
			{
				mPathParameters.Add(aPath);
			}
			
			public IEnumerator PathParameters
			{
				get {return mPathParameters.GetEnumerator();}
			}
			public void SetPrincipal(ISecurityPrincipal aPrincipal) {mPrincipal = aPrincipal;}
			public ISecurityPrincipal GetPrincipal() {return mPrincipal;}

			private ISecurityPrincipal mPrincipal;

			public void Load(ISecurityPrincipal aPrincipal)
			{
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
				CREATE TABLE t_capability_instance (id_cap_instance int NOT 
				 NULL identity(1,1), 
				id_parent_cap_instance int NOT NULL,
				id_acc int NULL,
				id_role int NULL,
				id_cap_class int NOT NULL
				 CONSTRAINT PK_t_capability_instance PRIMARY KEY CLUSTERED(id_cap_instance), 
				-- FOREIGN KEY (id_cap_class) REFERENCES t_capability_class,
				FOREIGN KEY (id_acc) REFERENCES t_account,
				FOREIGN KEY (id_role) REFERENCES t_role,
				CHECK(id_acc IS NULL OR id_role IS NULL))
				*/
				string principal = aPrincipal.PrincipalType == Principals.PrincipalType.ACCOUNT ? "id_acc" : "id_role";
				int prid = aPrincipal.ID;
				string query = "SELECT tx_param_value FROM t_capability_instance, t_path_capability ";
				query += "WHERE " + principal + " = " + prid + " AND id_parent_cap_instance = " + GetParentID();
				query += " AND t_capability_instance.id_cap_instance = t_path_capability.id_cap_instance";
				command.CommandText = query;

				SqlDataReader reader = command.ExecuteReader();
				ArrayList allcaps = new ArrayList();
				//supposed to be only one row
				while(reader.Read())
				{
					string param = reader.GetString(0);
					this.AddPathParameter(param);
				}			
			}



			public bool Save(ISecurityPrincipal aPrincipal)
			
			{
				
				//save this instance, get id and then save all children
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
				  NULL identity(1,1), 
				id_parent_cap_instance int NOT NULL,
				id_principal int NOT NULL,
				id_cap_class int NOT NULL
				*/
				
				string principal = aPrincipal.PrincipalType == PrincipalType.ACCOUNT ? "id_acc" : "id_role";

				string query = "INSERT INTO t_capability_instance (id_parent_cap_instance," + principal + ", id_cap_class) VALUES(";
				query +=  mParentID + ", " + aPrincipal.ID + ", " + mClassID + ")";
				command.CommandText = query;

				command.ExecuteNonQuery();

				command.CommandText = " select @@identity FROM t_capability_instance";

				decimal id = (decimal) command.ExecuteScalar();

				//insert main instance entry, get id back and insert into parameter table
				IEnumerator en = mPathParameters.GetEnumerator();

				//insert a record for every parameter
				while(en.MoveNext())
				{
					string param = (string)en.Current;
					query = "INSERT INTO t_path_capability VALUES";
					query += "(" + (int)id + ", '"  + param + "')";
					command.CommandText = query;
					command.ExecuteNonQuery();
				}
				return true;
			}
			
			
			public bool implies(ICapability aDemandedCap)
			{
			
				PathCapability cap;
				try
				{
					cap = (PathCapability) aDemandedCap;
				}
				catch (System.InvalidCastException e)
				{
					//Capability passed was of different type
					string msg  = e.Message;
					return false;
				}
				//on demanded cap there will be probably only one path parameter
				//whereas on possessed cap there could be more then one
				IEnumerator demandedit = cap.PathParameters;
				IEnumerator ownedit = PathParameters;
				bool bMatch = true;
				while(demandedit.MoveNext())
				{
					//previous demanded parameter
					//was never matched, immediately
					//return
					if(!bMatch) return false;
					while(ownedit.MoveNext())
					{
						//if match was found, 
						//break out of the inner loop to
						//the next iteration on the demanded cap
						if(Regex.IsMatch( (string)demandedit.Current, (string)ownedit.Current, RegexOptions.IgnoreCase))
						{
							bMatch = true;
							break;
						}
						else
							bMatch = false;
						
					}
				}
				
				return bMatch;
			}
			public int GetID(){return mID;}
			public void SetID(int aID){mID = aID;}

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			public int GetParentID() {return mParentID;}
			public void SetParentID(int aID){mParentID = aID;}

			public int GetClassID(){return mClassID;}
			public void SetClassID(int aID){mClassID = aID;}

			private int mID;
			private int mParentID;
			private int mClassID;
			private ArrayList mPathParameters = new ArrayList();
		}
		public abstract class CompositeCapability : ICapability
		{
			public string Description
			{
				get {return mDescription;}
				set {mDescription = value;}
			}
			public string Editor
			{
				get {return mEditor;}
				set {mEditor = value;}
			}
			public int ClassID
			{
				get {return mClassID;}
				set {mClassID = value;}
			}
			public int ID
			{
				get {return mID;}
				set {mID = value;}
			}
			public int ParentID
			{
				get {return mParentID;}
				set {mParentID = value;}
			}
			protected string mDescription = null;
			protected string mEditor = null;
			protected int mClassID = -1;
			protected int mID = -1;
			protected int mParentID = -1;
			public abstract bool Save(ISecurityPrincipal aPrincipal);
			public abstract void Load(ISecurityPrincipal aPrincipal);
			public abstract bool implies(ICapability aCap);
		}
		public class ManageAHCapability : CompositeCapability, ICapability
		{
			private PathCapability mPathCapability = new PathCapability();
			private AccessTypeCapability mAccessTypeCapability = new AccessTypeCapability();

			//orbitrary ICapability array
			ArrayList caps = new ArrayList();

			
/*
			public void SetPrincipal(ISecurityPrincipal aPrincipal) 
			{
				mAccessTypeCapability.SetPrincipal(aPrincipal);
				mPathCapability.SetPrincipal(aPrincipal);
				
				
			}
			
			public ISecurityPrincipal GetPrincipal() 
			{
				//principal id on both contaned objects should be same
				//looks kinda ugly
				return mPathCapability.GetPrincipal();
			}
			*/

			public override void Load(ISecurityPrincipal aPrincipal)
			{
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
				CREATE TABLE t_capability_instance (id_cap_instance int NOT 
				 NULL identity(1,1), 
				id_parent_cap_instance int NOT NULL,
				id_acc int NULL,
				id_role int NULL,
				id_cap_class int NOT NULL
				 CONSTRAINT PK_t_capability_instance PRIMARY KEY CLUSTERED(id_cap_instance), 
				-- FOREIGN KEY (id_cap_class) REFERENCES t_capability_class,
				FOREIGN KEY (id_acc) REFERENCES t_account,
				FOREIGN KEY (id_role) REFERENCES t_role,
				CHECK(id_acc IS NULL OR id_role IS NULL))
				*/
				string principal = aPrincipal.PrincipalType == Principals.PrincipalType.ACCOUNT ? "id_acc" : "id_role";
				int prid = aPrincipal.ID;
				string query = "SELECT id_cap_instance FROM t_capability_instance ";
				query += "WHERE " + principal + " = " + prid + " AND id_cap_class = " + ClassID ;
				command.CommandText = query;

				//get identity back
				int id =  (int)command.ExecuteScalar();

				mAccessTypeCapability.SetParentID(id);
				mPathCapability.SetParentID(id);

				//if an instance is a part of a composite, then
				//class id will point to a composite (parent) class
				mAccessTypeCapability.SetClassID(mClassID);
				mPathCapability.SetClassID(mClassID);
				
				mAccessTypeCapability.Load(aPrincipal);
				mPathCapability.Load(aPrincipal);
			}

			public override bool Save(ISecurityPrincipal aPrincipal)
			
			{
				//save this instance, get id and then save all children
				SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
					"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
				netmeter.Open();
				SqlCommand command = netmeter.CreateCommand();
				
				/*
				  NULL identity(1,1), 
				id_parent_cap_instance int NOT NULL,
				id_principal int NOT NULL,
				id_cap_class int NOT NULL
				*/

				//temporarily get class id by doing select
				string getclass = "SELECT id_cap_class FROM t_capability_class  WHERE tx_guid='";
				getclass += this.GetType().ToString() + "'";

				command.CommandText = getclass;

				SqlDataReader reader = command.ExecuteReader();
				

				while (reader.Read())
				{
					ClassID = reader.GetInt32(0);
				}

				string principal = aPrincipal.PrincipalType == PrincipalType.ACCOUNT ? "id_acc" : "id_role";

				string query = "INSERT INTO t_capability_instance (id_parent_cap_instance," + principal + ", id_cap_class) VALUES(";
				query += "NULL, " + aPrincipal.ID + ", " + mClassID + ")";
				command.CommandText = query;

				reader.Close();
				command.ExecuteNonQuery();

				command.CommandText = " select @@identity FROM t_capability_instance";

				decimal id = (decimal) command.ExecuteScalar();


				mAccessTypeCapability.SetParentID((int)id);
				mPathCapability.SetParentID( (int)id);

				//if an instance is a part of a composite, then
				//class id will point to a composite (parent) class
				mAccessTypeCapability.SetClassID(mClassID);
				mPathCapability.SetClassID(mClassID);
				
				if(!mAccessTypeCapability.Save(aPrincipal))
					return false;
				return mPathCapability.Save(aPrincipal);
			}

			public AccessType GetAccessType()
			{
				return mAccessTypeCapability.AccessType;
			}
			public void SetAccessType(AccessType aAccessType)
			{
				mAccessTypeCapability.SetAccessType(aAccessType);
				return;
			}
			public IEnumerator GetPathParameters()
			{
				return mPathCapability.PathParameters;
			}
			public void AddPathParameter(string aParam)
			{
				mPathCapability.AddPathParameter(aParam);
			}
			public override bool implies(ICapability aDemandedCap)
			{
				//ManageAHCapability is a composite
				//of Path and AcccessType capabilities
				//implies will constit of three parts
				//1. see if demanded cap is of same type
				try
				{
					ManageAHCapability check = (ManageAHCapability)aDemandedCap;
				}
				catch(InvalidCastException)
				{
					return false;
				}

				//2. Delegate to AccessType cap to check
				//access type. Call it first because it's
				//much less expensive
				if(!mAccessTypeCapability.implies(aDemandedCap))
					return false;
				//3. Delegate to PathCapability to check
				//path
				return mPathCapability.implies(aDemandedCap);
			}

			public int GetID(){return mID;}
			public void SetID(int aID){mID = aID;}

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			public int GetParentID() {return mParentID;}
			public void SetParentID(int aID){mParentID = aID;}

			public int GetClassID(){return mClassID;}
			public void SetClassID(int aID){mClassID = aID;}

		}
		/*
		public class ManageAccountCapability : PathCapability
		{
			//currently not used
			public IEnumerator AccountTypeParameters
			{
				get {return mAccountTypes.GetEnumerator();}
			}
			//currently not used
			public void AddAccountTypeParameter(AccountType aAccountType)
			{
				return;
				//mAccountTypes.Add(aAccountType);
			}

			protected ArrayList mAccountTypes = new ArrayList();
		}
		public class ManageAccountStateCapability : ManageAccountCapability
		{
			//we probably don't need this class because
			//state is just another proeprty of the account
			//and ManageAccountProperties ICapability will take care of this one 
			//but if we do need it then add another parameter here: AccountState
		}
		*/
		public class IssueCreditCapability : CompositeCapability, ICapability
		{
			private PathCapability mPathCapability = new PathCapability();
			private AccessTypeCapability mAccessTypeCapability = new AccessTypeCapability();
			private ConditionCapability mConditionCapability = new ConditionCapability();

			public void AddCondition(MTSimpleCondition aCond)
			{
				mConditionCapability.AddCondition(aCond);
			}
			public IEnumerator GetConditions()
			{
				return mConditionCapability.GetConditions();
			}

			/*
			public void SetPrincipal(ISecurityPrincipal aPrincipal) 
			{
				mAccessTypeCapability.SetPrincipal(aPrincipal);
				mPathCapability.SetPrincipal(aPrincipal);
			}
			public ISecurityPrincipal GetPrincipal() 
			{
				//principal id on both contaned objects should be same
				//looks kinda ugly
				return mPathCapability.GetPrincipal();
			}
			*/

			public override bool Save(ISecurityPrincipal aPrincipal)
			
			{
				if(!mAccessTypeCapability.Save(aPrincipal))
					return false;
				return mPathCapability.Save(aPrincipal);
			}

			public override void Load(ISecurityPrincipal aPr)
			{}

			public AccessType GetAccessType()
			{
				return mAccessTypeCapability.AccessType;
			}
			public void SetAccessType(AccessType aAccessType)
			{
				mAccessTypeCapability.SetAccessType(aAccessType);
				return;
			}
			public IEnumerator GetPathParameters()
			{
				return mPathCapability.PathParameters;
			}
			public void AddPathParameter(string aParam)
			{
				mPathCapability.AddPathParameter(aParam);
			}
			public override bool implies(ICapability aDemandedCap)
			{
				//ManageAHCapability is a composite
				//of Path and AcccessType capabilities
				//implies will constit of two parts

				//1. Delegate to AccessType cap to check
				//access type. Call it first because it's
				//much less expensive
				if(!mAccessTypeCapability.implies(aDemandedCap))
					return false;
				//2. Delegate to PathCapability to check
				//path
				return mPathCapability.implies(aDemandedCap);
			}
			public int GetID(){return mID;}
			public void SetID(int aID){mID = aID;}

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			public int GetParentID() {return mParentID;}
			public void SetParentID(int aID){mParentID = aID;}

			public int GetClassID(){return mClassID;}
			public void SetClassID(int aID){mClassID = aID;}
		}
		public class AccountExtensionCapability : IAccountExtensionCapability
		{
	
			public IEnumerator GetExtensions(){return mExtensions.GetEnumerator();}
			
			public void SetPrincipal(ISecurityPrincipal aPrincipal) {mPrincipal = aPrincipal;}
			public ISecurityPrincipal GetPrincipal() {return mPrincipal;}

			public bool Save(ISecurityPrincipal aPrincipal)
			
			{
				if (mPrincipal == null)
					return false;
				//get id for the principal and persist the state
				//into Db
				//long id = mPrincipal.
				return true;
			}

			private ISecurityPrincipal mPrincipal = null;

			public void AddExtension(string aAccountExtension)
			{
				mExtensions.Add(aAccountExtension);
			}
			public ArrayList Extensions
			{
				get { return mExtensions;}
			}
			public bool implies(ICapability aDemandedCap)
			{
				AccountExtensionCapability cap;

				try
				{
					cap = (AccountExtensionCapability) aDemandedCap;
				}
				catch (System.InvalidCastException e)
				{
					//Capability passed was of different type
					string msg  = e.Message;
					return false;
				}
				//check if demanded extension is in the list
				//of extensions
				ArrayList vDemandedExtensions = cap.Extensions;

				IEnumerator it = mExtensions.GetEnumerator();
				while(it.MoveNext())
				{
					if(!vDemandedExtensions.Contains(it.Current))
						return false;
				}
				
				return true;
			}

			public int GetID(){return mID;}
			public void SetID(int aID){mID = aID;}

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			public int GetParentID() {return mParentID;}
			public void SetParentID(int aID){mParentID = aID;}

			public int GetClassID(){return mClassID;}
			public void SetClassID(int aID){mClassID = aID;}

			private int mID;
			private int mParentID;
			private int mClassID;

			private ArrayList mExtensions = new System.Collections.ArrayList();
		}


		public class ConditionCapability : IConditionCapability
		{
			public IEnumerator GetConditions(){return mConditions.GetEnumerator();}
			
			public void SetPrincipal(ISecurityPrincipal aPrincipal) {mPrincipal = aPrincipal;}
			public ISecurityPrincipal GetPrincipal() {return mPrincipal;}

			private ISecurityPrincipal mPrincipal;

			
			public bool Save(ISecurityPrincipal aPrincipal)
			
			{
				if (mPrincipal == null)
					return false;
				//get id for the principal and persist the state
				//into Db
				//long id = mPrincipal.
				return true;
			}
			private ArrayList mConditions = new ArrayList();
			public IEnumerator Conditions
			{
				get{return mConditions.GetEnumerator();}
			}

			public void AddCondition(MTSimpleCondition aSimpleCondition)
			{
				mConditions.Add(aSimpleCondition);
			}
			public bool implies(ICapability aDemandedCap)
			{
				ConditionCapability oDemandedCap;
				
				//2. query if at least one parameter of MANAGE_ACCOUNT_CREDITS AccountNameValueCapability 
				//that this current principal possesses match demanded
				try
				{
					oDemandedCap = (ConditionCapability) aDemandedCap;
				}
				catch(System.InvalidCastException e)
				{
					string msg = e.Message;
					return false;
				}

				//for simplicity assume that demanded cap only has one condition
				
				IEnumerator en = oDemandedCap.Conditions;
				if(!en.MoveNext())
					//no conditions demanded - error?
					return true;
				object oDemandedCondition = en.Current;
				
				//if no limitations were imposed on the principal then
				//just return true
				if(mConditions.Count == 0)
					return true;
				IEnumerator it = mConditions.GetEnumerator();

				while (it.MoveNext())
					if(DoConditionsMatch( (MTSimpleCondition)it.Current, (MTSimpleCondition)oDemandedCondition))
						//got a  hit: do we just return happy or do we check
						//for any contradictions further?
						return true;
				return false;
			}
			private bool DoConditionsMatch(MTSimpleCondition aPossessedCond, MTSimpleCondition aDemandedCond)
			{
				string strCondName = aPossessedCond.PropertyName;
				PropValType Type = aPossessedCond.ValueType;
				string strDemandedCondName = aDemandedCond.PropertyName;
				PropValType DemandedType = aDemandedCond.ValueType;
				bool bMatch = false;
				//operator
				string op = aPossessedCond.Test;

				if( (Type != DemandedType) || strCondName.CompareTo(strDemandedCondName) > 0)
					return false;

				//switch on type and do some fancy comparisons.
				//for now only numeric and '<'
				op = "<";
				decimal dPossessedValue = (decimal)aDemandedCond.Value;
				decimal dDemandedValue = (decimal)aDemandedCond.Value;

				if(op.CompareTo("<") == 0)
					bMatch = dDemandedValue < dPossessedValue;
				return bMatch;
			}
			public int GetID(){return mID;}
			public void SetID(int aID){mID = aID;}

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			public int GetParentID() {return mParentID;}
			public void SetParentID(int aID){mParentID = aID;}

			public int GetClassID(){return mClassID;}
			public void SetClassID(int aID){mClassID = aID;}

			private int mID;
			private int mParentID;
			private int mClassID;
		}
		public class AllCapability : CompositeCapability
		{
			public void SetPrincipal(ISecurityPrincipal aPrincipal) {mPrincipal = aPrincipal;}
			public ISecurityPrincipal GetPrincipal() {return mPrincipal;}

			public override bool Save(ISecurityPrincipal aPrincipal)
			{
				if (mPrincipal == null)
					return false;

				//get id for the principal and persist the state
				//into Db
				//long id = mPrincipal.
				return true;
			}

			public override void Load(ISecurityPrincipal aPrincipal)
			{
				
			}

			private ISecurityPrincipal mPrincipal = null;
			public override bool implies(ICapability aCap)
			{
				return true;
			}
			public int GetID(){return mID;}
			public void SetID(int aID){mID = aID;}

			//if capability is a part of a composite,
			//then it's an id of a composite cap
			public int GetParentID() {return mParentID;}
			public void SetParentID(int aID){mParentID = aID;}

			public int GetClassID(){return mClassID;}
			public void SetClassID(int aID){mClassID = aID;}
			
		}
	}
	namespace Exceptions 
	{
		public class AuthException : System.Exception
		{
			public AuthException(string aStr)
			{}
		}
	}

}


