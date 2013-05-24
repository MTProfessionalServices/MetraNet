
using System;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;

/* NOTE: AS OF 3/4/2009, DO NOT USE IDGENERATORWRAPPER, USE IDGENERATOR DIRECTLY
 * THIS WILL ALLOW FOR CACHING OF BLOCKS OF IDS.  THE IDGENERATOR USES A NEW COM+
 * COMPONENT TO DO THE DB LOOKUP SEPARATELY, THIS REMOVING THE NEED TO USE IDGENERATORWRAPPER
 * /

/* Use this class and not IdGenerator directly, if you are invoking
 * IdGenerator from a serviced component. Note that transaction on
 * this object is marked as NotSupported. we need this to force COM+ to create a new
 * transaction context, when Id Generator is invoked and not use existing transaction context.
 * Otherwise CreateNonServicedConnection() method called in NextBlock of IdGenerator will fail with
 * "can not start more tranaction on thee same session".
 */
 
namespace  MetraTech.DataAccess
{
	[Guid("b466a279-5649-45c5-9484-3e318420305b")]
	[ComVisible(true)]
  [Obsolete("Use IIDGenerator directly", true)]
	public interface IIdGeneratorWrapper
	{
		int GetNextId(string aEntity);
		int GetNextId(string aEntity, int nBlockSize);
		int GetBlock(string aEntity, int nBlockSize);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Transaction(TransactionOption.NotSupported)]
	[ComVisible(true)]
	[Guid("3493e7d3-1f83-4aaf-857f-9221ff073e10")]
  [Obsolete("Use IDGenerator directly", true)]
  public class IdGeneratorWrapper : ServicedComponent, IIdGeneratorWrapper
  {
		private IdGenerator mGenerator = null;
		public IdGeneratorWrapper() {}
		public int GetNextId(string aEntity)
		{
      if (mGenerator == null || mGenerator.ColumnName != aEntity)
        mGenerator = new IdGenerator(aEntity);

      return mGenerator.NextId;
		}

		public int GetNextId(string aEntity, int nBlockSize)
		{
      if (mGenerator == null || mGenerator.ColumnName != aEntity)
        mGenerator = new IdGenerator(aEntity, nBlockSize);
      else
        mGenerator.BlockSize = nBlockSize;

			return mGenerator.NextId;
		}

		public int GetBlock(string aEntity, int nBlockSize)
		{
      if (mGenerator == null || mGenerator.ColumnName != aEntity)
        mGenerator = new IdGenerator(aEntity, nBlockSize);
      else
        mGenerator.BlockSize = nBlockSize;

			return mGenerator.GetBlock(nBlockSize);
		}
	}

	[Guid("6b809797-bf0b-48f6-9c47-262fb99f9f16")]
	[ComVisible(true)]
	public interface ILongIdGeneratorWrapper
	{
		long GetNextId(string aEntity);
		long GetNextId(string aEntity, long nBlockSize);
		long GetBlock(string aEntity, long nBlockSize);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Transaction(TransactionOption.NotSupported)]
	[ComVisible(true)]
	[Guid("125769c9-326c-4f40-adce-17906bbe3ad0")]
	public class LongIdGeneratorWrapper : ServicedComponent, ILongIdGeneratorWrapper
  {
		private LongIdGenerator mGenerator = null;
		public LongIdGeneratorWrapper() {}
		public long GetNextId(string aEntity)
		{
			if(mGenerator == null)
				mGenerator = new LongIdGenerator(aEntity);
			return mGenerator.NextId;
		}

		public long GetNextId(string aEntity, long nBlockSize)
		{
			if(mGenerator == null)
				mGenerator = new LongIdGenerator(aEntity, nBlockSize);
      else
        mGenerator.BlockSize = nBlockSize;

			return mGenerator.NextId;
		}

		public long GetBlock(string aEntity, long nBlockSize)
		{
			if(mGenerator == null)
				mGenerator = new LongIdGenerator(aEntity, nBlockSize);
      else
        mGenerator.BlockSize = nBlockSize;

			return mGenerator.GetBlock(nBlockSize);
		}
	}
}
