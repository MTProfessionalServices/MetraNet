using System;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTHooklib;
using MetraTech.Interop.MTHookHandler;
using MetraTech.Interop.MTAuth;


namespace MetraTech.Debug.LogTest2
{


	/*
Dim objLoginContext, objSessionContext
Set objLoginContext = CreateObject("Metratech.MTLoginContext")
Set objSessionContext = objLoginContext.Login("su", "system_user", "su123")

'On Error Resume Next

set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
aHookHandler.SessionContext = objSessionContext
wscript.echo "doing!"
call aHookHandler.RunHookWithProgid("MetraTech.Debug.LogTest.TestHook","")
	*/


	public class Test
	{
		public static void Main(string [] args)
		{
			//			IMTLoginContext loginContext = new MTLoginContextClass();
			//			loginContext.Login("su", "system_user", "su123");

			IMTHookHandler handler = new MTHookHandlerClass();
			int x = 0; // what is this for?

			handler.RunHookWithProgid("MetraTech.Debug.LogTest.TestHook", null, ref x);
		}

	}

}

