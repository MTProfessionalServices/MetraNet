using System;
using System.Runtime.InteropServices;

namespace MetraTech.Pipeline.PlugIns
{
	using MetraTech.Pipeline;
	using MetraTech.Interop.MTPipelineLib;

	// Exeption class used to return HRESULT codes.
	// Example: throw new PartialFailureException();
	[ComVisible(false)]
	public class PartialFailureException : COMException
	{
		public PartialFailureException() :
			base("PIPE_ERR_SUBSET_OF_BATCH_FAILED", -517996513)
		{ /* Do nothing here */ }
	}

	// Base pipeline plug-in class to be use for all managed plug-ins.
	[ComVisible(false)]
	public abstract class PipelinePlugIn : IMTPipelinePlugIn
	{
		// Must be implemented by user.
		public abstract void Configure(object systemContext, IMTConfigPropSet propSet);
		public abstract void ProcessSessions(ISessionSet sessions);
		public abstract int ProcessorInfo { get; }
		public abstract void Shutdown();

		// Private implementation
		public void ProcessSessions(IMTSessionSet sessions)
		{
			// Create a managed session set and initialize it with unmanaged wrapped set.
			ISessionSet ManagedSessionSet = SessionSet.Create(sessions);

			try 
			{
				ProcessSessions(ManagedSessionSet);
			}
			finally
			{
				//----- Dispose the object to release shared memory resources immediately.
				ManagedSessionSet.Dispose();

				//----- Important - explicitly release our reference to the object
				Marshal.ReleaseComObject(sessions);
			}
		}

        protected string GetPluginName()
        {
            return this.ToString();
        }
	}
}

//-- EOF --