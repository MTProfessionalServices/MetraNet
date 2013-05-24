using System;
using System.Runtime.InteropServices;

[assembly: GuidAttribute("E5B87A2E-FB2F-48a2-8126-3079D3100925")]
namespace MetraTech.Test.PlugIns
{
	using MetraTech.Pipeline;
	using MetraTech.Pipeline.PlugIns;
	using MetraTech.Interop.MTPipelineLib;

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("72B3AF98-027C-4dcf-BC67-4C48600A9DAB")]
	public class SimpleTestPlugin : PipelinePlugIn 
	{
		public override void Configure(object systemContext, IMTConfigPropSet propSet)
		{
			// Initialize totals.
//			mlBoolTotal = 0;
//			mlIntTotal = 0;
//			mlStringTotal = 0;
//			mdDecimalTotal = 0;
//			mdDoubleTotal = 0;

			// Get interfaces
			mLogger = new Logger((MetraTech.Interop.SysContext.IMTLog) systemContext);
			mNameID = (IMTNameID) systemContext;
			
			// Get property iD's
			mlBoolProp = mNameID.GetNameID("boolVal");
			mlIntProp = mNameID.GetNameID("intVal");
			mlStringProp = mNameID.GetNameID("strVal");
			mlDecimalProp = mNameID.GetNameID("decValue");
			mlDoubleProp = mNameID.GetNameID("dVal");

			mLogger.LogDebug("SimpleTestPlugin plug-in starting");
		}

		public override void ProcessSessions(ISessionSet sessions)
		{
			try 
			{
				foreach(ISession sess in sessions)
				{
					try
					{
/* xxx This will always throw an exception unless the right data is metered.
						mlBoolTotal += (sess.GetBooleanProperty(mlBoolProp) == true ? 1 : 0);
						mlIntTotal += sess.GetIntegerProperty(mlIntProp);

						string strValue = sess.GetStringProperty(mlStringProp);
						mlStringTotal += strValue[0];
						mdDoubleTotal += sess.GetDoubleProperty(mlDoubleProp);

						mdDecimalTotal += (decimal) sess.GetDecimalProperty(mlDecimalProp);
*/						
					}
					catch(Exception ex)
					{
						mLogger.LogError(ex.Message);
						throw;
					}
					finally
					{
						// Dispose the object to release shared memory resources immediately.
						sess.Dispose();
					}
				}
			}
			catch(Exception ex)
			{
				mLogger.LogError(ex.Message);
				throw;
			}
		}

		public override int ProcessorInfo
		{
			get
			{
				int E_NOTIMPL = -2147467263; //0x80004001
				mLogger.LogDebug("SimpleTestPlugin::ProcessorInfo not implemented");
				return E_NOTIMPL;
			}
		}

		public override void Shutdown()
		{
			/* Nothing to do here. */
		}

		private Logger mLogger;
		private IMTNameID mNameID;

		// Property ID's
		private int mlBoolProp;
		private int mlIntProp;
		private int mlStringProp;
		private int mlDecimalProp;
		private int mlDoubleProp;

		// Totals for each property
//		private long mlBoolTotal;
//		private long mlIntTotal;
//		private long mlStringTotal;
//		private decimal mdDecimalTotal;
//		private double mdDoubleTotal;
	}
}

//-- EOF --