using System.Runtime.InteropServices;
[assembly: Guid("951ef717-a77a-4a84-bacc-0046063b7e81")]

namespace MetraTech.Debug.Transaction
{
	using System;
	using System.EnterpriseServices;
	using MetraTech.Interop.PipelineTransaction;


  [Guid("23287903-6077-413d-b215-10b7fd69d78d")]
	public interface IGetTransactionInfo
	{
		String GetTransactionID();
	}

	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("f397a271-8d5d-4c20-9232-75b4071ad911")]
	public class GetTransactionInfo : ServicedComponent, IGetTransactionInfo
	{
		[AutoComplete]
		public String GetTransactionID()
		{
			if (ContextUtil.IsInTransaction)
			{
				return ContextUtil.TransactionId.ToString();
			}
			else
			{
				return "LocalTransaction";
			}
		}

		public GetTransactionInfo()
		{
		}
	}

	[Guid("762101ab-c3d7-423a-a3a6-3e2f5a697a0e")]
	public interface ITransactionDebug
	{
		String GetTransactionID(IMTTransaction trans);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("7b4fffa3-063d-435f-bd56-16663b20013e")]
	public class TransactionDebug : ITransactionDebug
	{
		public TransactionDebug()
		{
		}

		public String GetTransactionID(IMTTransaction trans)
		{
			try
			{
				GetTransactionInfo info = (GetTransactionInfo) BYOT.CreateWithTransaction(trans.GetTransaction(), typeof(GetTransactionInfo));
				return info.GetTransactionID();
			}
			catch(Exception e)
			{
				return e.ToString();
			}
		}
	}
}
