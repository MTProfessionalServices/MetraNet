using System;
using System.Runtime.InteropServices;
using MetraTech.Interop.Rowset;

[assembly: Guid("a08c7f01-f93e-49b8-838f-7487f448df83")]

namespace MetraTech.Pipeline.Batch
{
	[Guid("47cc3f44-f024-4447-87d0-0dd38466a473")]
  public interface IBatchManager
	{
		IMTRowSet GetBatches();
	}

	/// <summary>
	/// Summary description for BatchManager.  Primarily used to get back a
	/// list of batches for the MOM GUI.
	/// </summary>
	/// 
  [Guid("1411B520-26EB-312F-A039-A02764720A13")]
  [ClassInterface(ClassInterfaceType.None)]
	public class BatchManager : IBatchManager
	{
		public BatchManager()
		{
			mLogger = new Logger("[BatchManager]");
		}

	  public IMTRowSet GetBatches()
		{
			IMTSQLRowset rowset = new MTSQLRowset();
			rowset.Init("\\Queries\\MTBatch");
			rowset.SetQueryTag("__GET_ALL_BATCHES__");
			rowset.ExecuteDisconnected();
			return rowset;
		}

		private Logger mLogger;
	}
}

