using System.Runtime.InteropServices;

//[assembly: System.EnterpriseServices.ApplicationName("MetraNet")]

namespace MetraTech.Accounts.PlugIns
{
	using MetraTech;
	using MetraTech.Xml;
	using MetraTech.Pipeline;
	using MetraTech.DataAccess;
	using PC = MetraTech.Interop.MTProductCatalog;
	using MetraTech.Interop.MTPipelineLib;
 
	using YAAC = MetraTech.Interop.MTYAAC;
  using MetraTech.Accounts.Type;
  using MetraTech.Interop.IMTAccountType;

	using System;
	using System.Collections;
	using System.Diagnostics;
	using System.Text;
	using System.EnterpriseServices;

	
	[Guid("4fcc1ca4-4a13-4ebd-a731-7e91f08b13bd")]
	public class NonBatchApplyTemplateProperties : IMTPipelinePlugIn
	{
		public NonBatchApplyTemplateProperties()
		{
			// have to tell the base class that we implement the interface
			//PlugIn = this;
		}

		public void Configure(object systemContext, 
			MetraTech.Interop.MTPipelineLib.IMTConfigPropSet propSet)
		{
			mInterfaces = new Interfaces();
			mInterfaces.ProdCat = new PC.MTProductCatalogClass();
			mInterfaces.EnumConfig = (IEnumConfig)systemContext;
			mInterfaces.Logger = new Logger((MetraTech.Interop.SysContext.IMTLog) systemContext);
      mInterfaces.Logger.LogError("This plugin is deprecated, batch version should be used ('MetraPipeline.ApplyTemplateProperties')");
			Debug.Assert(mInterfaces.EnumConfig != null);
			
			mInterfaces.NameID = (IMTNameID) systemContext;
			
			mProps = new PipelinePropIDs();
			mProps.mlOperationID = mInterfaces.NameID.GetNameID("operation");
			mProps.mlAccountIDID = mInterfaces.NameID.GetNameID("_AccountID");
			mProps.mlAccountStartDateID = mInterfaces.NameID.GetNameID("accountstartdate");
			mProps.mlAccountEndDateID = mInterfaces.NameID.GetNameID("accountenddate");
			mProps.mlAncestorAccountIDID = mInterfaces.NameID.GetNameID("ancestorAccountID");
			mProps.mlAccountTypeID = mInterfaces.NameID.GetNameID("AccountType");
			mProps.mlUserNameID = mInterfaces.NameID.GetNameID("username");
			mProps.mlNameSpaceID = mInterfaces.NameID.GetNameID("name_space");
			mProps.mlCorporateAccountIDID = mInterfaces.NameID.GetNameID("CorporateAccountID");
			mProps.mlOldAncestorAccountIDID = mInterfaces.NameID.GetNameID("OldAncestorAccountID");
		}

		void IMTPipelinePlugIn.Shutdown()
		{ }

		void IMTPipelinePlugIn.ProcessSessions(IMTSessionSet sessions)
		{
			IEnumerator enumerator = sessions.GetEnumerator();

			try
			{
				while (enumerator.MoveNext())
				{
					IMTSession session = (IMTSession) enumerator.Current;
						MetraTech.Interop.MTPipelineLib.IMTTransaction transaction = session.GetTransaction(false);

					int serviceDefID = session.ServiceID;
					if(mInterfaces.ServiceDefinition == null || serviceDefID != mServiceDefID)
					{
						mServiceDefID = serviceDefID;
						string serviceName = mInterfaces.NameID.GetName(serviceDefID);
						mInterfaces.ServiceDefinition =  mServiceDefs.GetServiceDefinition(serviceName);
					}

          string accountTypeName = (string)session.GetStringProperty(mProps.mlAccountTypeID);
          int accountTypeID = mAccountTypes.GetAccountType(accountTypeName).ID;
					AccountPropertyWriter writer = null;
					if(transaction == null)
						writer = new AccountPropertyWriter();
					else
						writer = (AccountPropertyWriter)BYOT.CreateWithTransaction
							(transaction.GetTransaction(), typeof(AccountPropertyWriter));
					writer.SetProperties(session, mProps, mInterfaces, accountTypeID);
				}
			}
			catch(Exception ex)
			{
				mInterfaces.Logger.LogError(ex.Message);
				throw;
			}
			finally
			{
				// important - explicitly release our reference to the object
				ICustomAdapter adapter = (ICustomAdapter)enumerator;
				Marshal.ReleaseComObject(adapter.GetUnderlyingObject());
				Marshal.ReleaseComObject(sessions);
			}
		}
		public int ProcessorInfo
		{
			get
			{
				int E_NOTIMPL = -2147467263; //0x80004001
				throw new COMException("not implemented", E_NOTIMPL);
			}
		}

		private PipelinePropIDs mProps;
		private Interfaces mInterfaces;
		private ServiceDefinitionCollection mServiceDefs = new ServiceDefinitionCollection();
		private int mServiceDefID;
    private AccountTypeCollection mAccountTypes = new AccountTypeCollection();

		// list of existing account properties in the template
		private ArrayList mListProperties = new ArrayList();
	}

	[Guid("058804ca-f703-4b5e-a3c0-5240f9e4a91e")]
	[ComVisible(true)]
	public interface IAccountPropertyWriter
	{
	}

	[Guid("ed3925d3-da36-4d28-b94c-9cef22761fc4")]
	[ComVisible(true)]
	public interface ITemplateSubscriptionWriter
	{
	}

	[Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("19d9dafa-5a70-4842-a787-55a91de055ed")]
	public class AccountPropertyWriter : ServicedComponent//, IAccountPropertyWriter
	{
		public AccountPropertyWriter()
		{ 
		}

		[AutoComplete]
		internal void InitializeTemplateDate(ref DateTime effDate,
			IMTSession aSession, PipelinePropIDs ids, Interfaces interfaces, bool abNewAccount)
		{
			if(abNewAccount)
			{
				if(aSession.PropertyExists(ids.mlAccountStartDateID, MTSessionPropType.SESS_PROP_TYPE_DATE))
					effDate = (DateTime)aSession.GetOLEDateProperty(ids.mlAccountStartDateID);
				else
				{
					effDate = MetraTime.Now.Date;
				}
			}
				//in case of account updates we need to look at hierarchy start and end dates
			else
			{
				if(aSession.PropertyExists(ids.mlHierarchyStartDateID, MTSessionPropType.SESS_PROP_TYPE_DATE))
					effDate = (DateTime)aSession.GetOLEDateProperty(ids.mlHierarchyStartDateID);
				else
				{
					effDate = MetraTime.Now.Date;
				}
			}
		}

		internal bool PropertyExists(IMTSession session, int ID, PC.IMTPropertyMetaData propMeta)
		{
			bool bExists = false;

			switch (propMeta.DataType)
			{
				case PC.PropValType.PROP_TYPE_INTEGER:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_LONG);
					break;
				case PC.PropValType.PROP_TYPE_BIGINTEGER:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_LONGLONG);
					break;
				case PC.PropValType.PROP_TYPE_DOUBLE:
				case PC.PropValType.PROP_TYPE_DECIMAL:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_DECIMAL);
					break;
				case PC.PropValType.PROP_TYPE_STRING:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_STRING);
					break;
				case PC.PropValType.PROP_TYPE_DATETIME:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_STRING);
					break;
				case PC.PropValType.PROP_TYPE_TIME:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_TIME);
					break;
				case PC.PropValType.PROP_TYPE_BOOLEAN:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_BOOL);
					break;
				case PC.PropValType.PROP_TYPE_ENUM:
					bExists = session.PropertyExists(ID, MTSessionPropType.SESS_PROP_TYPE_ENUM);
					break;
			}
			return bExists;

		}

		internal void SetPipelineProperty(IMTSession session, Interfaces interfaces, PC.IMTPropertyMetaData propMeta, int ID, object value)
		{
			
			switch (propMeta.DataType)
			{
				case PC.PropValType.PROP_TYPE_INTEGER:
					session.SetLongProperty(ID, Convert.ToInt32(value));
					return;
				case PC.PropValType.PROP_TYPE_BIGINTEGER:
					session.SetLongLongProperty(ID, Convert.ToInt64(value));
					return;
				case PC.PropValType.PROP_TYPE_DOUBLE:
				case PC.PropValType.PROP_TYPE_DECIMAL:
					session.SetDecimalProperty(ID, Convert.ToDecimal(value));
					return;
				case PC.PropValType.PROP_TYPE_STRING:
					session.SetBSTRProperty(ID, (string)value);
					return;
				case PC.PropValType.PROP_TYPE_DATETIME:
					session.SetOLEDateProperty(ID, Convert.ToDateTime(value));
					return;
				case PC.PropValType.PROP_TYPE_TIME:
					session.SetTimeProperty(ID, Convert.ToInt32(value));
					return;
				case PC.PropValType.PROP_TYPE_BOOLEAN:
					session.SetBoolProperty(ID, Convert.ToBoolean(value));
					return;
				case PC.PropValType.PROP_TYPE_ENUM:
				{
					session.SetEnumProperty(ID, (int)value);
					return;
				}
					
			}

		}


		[AutoComplete]
		internal void SetProperties(IMTSession session, PipelinePropIDs ids, Interfaces interfaces, int accountTypeID)
		{
			int lAccountID = session.GetLongProperty(ids.mlAccountIDID);
			int lAccountAncestorID = session.GetLongProperty(ids.mlAncestorAccountIDID);
			int lCorporateAccountID = session.GetLongProperty(ids.mlCorporateAccountIDID);
			string sAccountName = session.GetStringProperty(ids.mlUserNameID);
			string sAccountNameSpace = session.GetStringProperty(ids.mlNameSpaceID);
					
			//do nothing if this account is not a subscriber
			int lAccountType = session.GetEnumProperty(ids.mlAccountTypeID);
			string sAccountType = interfaces.EnumConfig.GetEnumeratorByID(lAccountType);
					
			if (string.Compare(sAccountType, "CORESUBSCRIBER", true) != 0)
			{
				interfaces.Logger.LogDebug(string.Format("Account {0} is not a subscriber, nothing to do", lAccountID));
				return;
			}

			if(lAccountAncestorID == 1)
			{
				interfaces.Logger.LogDebug(string.Format("Account {0} is topmost (corporate), nothing to do", lAccountID));
				return;
			}

			MetraTech.Interop.MTPipelineLib.IMTSessionContext ctx = session.SessionContext;
								
			//See if it's a new account or update
			int lOpID = session.GetEnumProperty(ids.mlOperationID);
			int lOp = System.Convert.ToInt32(interfaces.EnumConfig.GetEnumeratorValueByID(lOpID));
			bool bNewAccount = (lOp == 0);
			DateTime effDate = DateTime.MinValue;
			this.InitializeTemplateDate(ref effDate, session, ids, interfaces, bNewAccount);

			//if this is an account update operation, make sure that
			//ancestor changed. Otherwise, don't do anything
			int lOldAncestorAccountID = -1;
			if(!bNewAccount)
			{
				lOldAncestorAccountID = session.GetLongProperty(ids.mlOldAncestorAccountIDID);
				int lNewAncestorAccountID = session.GetLongProperty(ids.mlAncestorAccountIDID);
				if(lOldAncestorAccountID == lNewAncestorAccountID)
				{
					interfaces.Logger.LogDebug(@"Account ancestor did not change in this update session," +
						"account template properties will not be re-applied");
					return;
				}
			}
						
			interfaces.Logger.LogDebug (string.Format(
				"Looking up account template for account {0}/{1} ({2})", 
				sAccountName, 
				sAccountNameSpace, 
				lAccountID));

			YAAC.IMTAccountTemplate template = new YAAC.MTAccountTemplateClass();
			template.Initialize((YAAC.IMTSessionContext)ctx, lAccountAncestorID, lCorporateAccountID, accountTypeID, effDate);
			if(template.TemplateAccountID < 1)
			{
				interfaces.Logger.LogDebug (string.Format(
					"None of the ancestors for account {0}/{1} ({2}) have templates, nothing to do", 
					sAccountName, 
					sAccountNameSpace, 
					lAccountID));
				return;
			}
			else
			{
				interfaces.Logger.LogDebug (string.Format(
					"Closest ancestor with template for account {0}/{1}({2}) is {3}/{4}({5})", 
					sAccountName, 
					sAccountNameSpace, 
					lAccountID, 
					template.TemplateAccountName, 
					template.TemplateAccountNameSpace, 
					template.TemplateAccountID));
			}

			//if it's account move operation, then make sure that old and new ancestor don't have the same
			//'templated' ancestor as the new ancestor, otherwise it's a NOP
			if(!bNewAccount)
			{
				YAAC.IMTAccountTemplate newTemplate = new YAAC.MTAccountTemplateClass();
				newTemplate.Initialize((YAAC.IMTSessionContext)ctx, lOldAncestorAccountID, lCorporateAccountID, accountTypeID, effDate);
				if(newTemplate.TemplateAccountID == template.TemplateAccountID)
				{
					interfaces.Logger.LogDebug (string.Format(
						"Both new and old ancestor for account {0}/{1}({2}) share " +
						"template associated with {3}/{4}({5}), template properties will not be re-applied.", 
						sAccountName, 
						sAccountNameSpace, 
						lAccountID, 
						template.TemplateAccountName, 
						template.TemplateAccountNameSpace, 
						template.TemplateAccountID));
					return;
				}

					
			}

				
			YAAC.IMTAccountTemplateProperties props = template.Properties;
			if(props == null) 
				return;
			foreach(YAAC.IMTAccountTemplateProperty prop in props)
			{
				interfaces.Logger.LogDebug (string.Format("Name = {0}, Value = {1}", prop.Name, prop.Value));

				//for all template properties
				//see if it's in session
				string name = prop.Name;
				object value = prop.Value;

				//get prop meta data for this property
				PC.IMTPropertyMetaData propMeta = (PC.IMTPropertyMetaData)interfaces.ServiceDefinition[name];
				if(propMeta != null)
				{
					if(PropertyExists(session, interfaces.NameID.GetNameID(name), propMeta) == false)
						SetPipelineProperty(session, interfaces, propMeta, interfaces.NameID.GetNameID(name), value);
				}

			}
		
		
		}
	}
}
