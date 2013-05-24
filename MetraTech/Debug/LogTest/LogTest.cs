using System;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTHooklib;

[assembly: GuidAttribute ("150c9f5c-f3be-4f88-be60-b4496ba160dc")]

//
// Call test.vbs to reproduce leaked NTLogServer issue (CR11595)
//


namespace MetraTech.Debug.LogTest
{

	[Guid("c70e1a29-4396-4ee4-9ded-279e08cbb755")]
	[ClassInterface(ClassInterfaceType.None)]
	public class TestHook : IMTHook
	{
		public TestHook()
		{
				mLog = new Logger("[LogTestHook]");
		}


    	public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
		{
		
			string logmsg2;
			for (int j = 0; j<100; j++)
			{
				logmsg2 = "testing logging first " + j.ToString();
				mLog.LogDebug(logmsg2);
			}
			string logmsg;
			for (int i = 0; i<150; i++)
			{
				logmsg = "testing logging " + i.ToString();
				mLog.LogDebug(logmsg);
			}

			mLog.LogDebug("***********");
		}

		private MetraTech.Logger mLog;

	}
}

