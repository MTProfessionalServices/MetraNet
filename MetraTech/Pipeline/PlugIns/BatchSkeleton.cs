using System.Runtime.InteropServices;

[assembly: GuidAttribute("bbd2650f-0e3e-488f-aae1-0eb45d0a0f7c")]

namespace MetraTech.Pipeline.PlugIns
{
	using MetraTech;
	using MetraTech.DataAccess;

	using MetraTech.Interop.MTPipelineLib;

	using System.Diagnostics;

	[Guid("57128134-01f0-49c2-b088-19534822f0ab")]
	public interface IBatchPlugIn
	{
		void Configure(Logger logger,
									 IMTConfigPropSet propSet,
									 IMTNameID nameID,
									 IMTSystemContext sysContext);

    void Shutdown();

    void ProcessSessions(IMTSessionSet sessions);

		void InitializeDatabase();

		void ShutdownDatabase();
	}

	[ComVisible(false)]
	public class BatchSkeleton : IMTPipelinePlugIn
	{
		public BatchSkeleton()
		{
		}
	
		public void Configure(object systemContext,
													IMTConfigPropSet propSet)
		{
			mLogger = new Logger((MetraTech.Interop.SysContext.IMTLog) systemContext);
			mLogger.LogDebug("BatchUpdate plug-in starting");

			IMTNameID nameID = (IMTNameID) systemContext;
			IMTSystemContext sysContext = (IMTSystemContext) systemContext;

			mPlugIn.Configure(mLogger, propSet, nameID, sysContext);

			mPlugIn.InitializeDatabase();
			mDatabaseInitialized = true;
		}

    public void Shutdown()
		{
			mPlugIn.ShutdownDatabase();
			mPlugIn.Shutdown();
			mLogger = null;
		}

    public int ProcessorInfo
		{
			get
			{
				int e_notimpl = -2147467263; //0x80004001
				throw new COMException("not implemented", e_notimpl);
			}
		}

    public void ProcessSessions(IMTSessionSet sessions)
		{
			try
			{
				for (int i = 0; i < 3 && !mDatabaseInitialized; i++)
				{
					try
					{
						mPlugIn.ShutdownDatabase();
						mPlugIn.InitializeDatabase();

						mDatabaseInitialized = true;
					}
					catch (System.Exception err)
					{
						mLogger.LogError("Unable to initialize database on attempt {0}", i);
						mLogger.LogError(err.ToString());

						if (i == 2)
							throw;							// didn't work - fail the set
					}
				}

				Debug.Assert(mDatabaseInitialized);

				bool processSuccess = false;

				for (int i = 0;
						 i == 0
							 || (mSafeToRetry && i < 3 && !processSuccess);
						 i++)
				{
					try
					{
						// process sessions
						mPlugIn.ProcessSessions(sessions);

						processSuccess = true;
					}
					catch (System.Exception err)
					{
						mLogger.LogError("Unable to process sessions on attempt {0}", i);
						mLogger.LogError(err.ToString());

						if (i == 2 || !mSafeToRetry)
							throw;							// didn't work - fail the set

						mPlugIn.ShutdownDatabase();
						mPlugIn.InitializeDatabase();
					}
				}

				Debug.Assert(processSuccess);
			}
			finally
			{
				Marshal.ReleaseComObject(sessions);
			}
		}

		public bool SafeToRetry
		{
			get
			{
				return mSafeToRetry;
			}
			set
			{
				mSafeToRetry = value;
			}
		}

		public IBatchPlugIn PlugIn
		{
			set
			{
				mPlugIn = value;
			}
		}

		private IBatchPlugIn mPlugIn;

		protected Logger mLogger;

		private bool mDatabaseInitialized = false;
		private bool mSafeToRetry = true;
	}
}
