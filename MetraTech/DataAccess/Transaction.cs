using System;
using System.Diagnostics;
using System.EnterpriseServices;

using MetraTech.Interop.PipelineTransaction;

namespace MetraTech.TransactionServices
{
	/// <remarks>
	/// Class that can create new MetraTech transaction or
	/// retrieve a MetraTech transaction representing the
	/// current COM+/.NET transaction.
	/// </remarks>
	class MTTransactionDispenser
	{
		public static IMTTransaction CreateNew()
		{
			IMTTransaction txn;
			txn = (IMTTransaction) new CMTTransaction();

			return txn;
		}

		public static IMTTransaction CurrentTransaction
		{
			get
			{
				object currentTxn = ContextUtil.Transaction;
				
				IMTTransaction txn;
				txn = (IMTTransaction) new CMTTransaction();
				// false means we're not the owner
				txn.SetTransaction(txn, false);
				return txn;
			}
		}
	}

	/// <remarks>
	/// Class that can connect .NET/COM+ transaction context with
	/// a MetraTech transaction object
	/// </remarks>
	class MTTransactionConnector
	{
		public static object CreateWithMTTransaction(IMTTransaction txn, Type t)
		{
			return BYOT.CreateWithTransaction(txn.GetTransaction(), t);
		}
	}

}


