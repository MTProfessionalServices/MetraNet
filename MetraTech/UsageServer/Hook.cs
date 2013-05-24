namespace MetraTech.UsageServer
{
	using System.Runtime.InteropServices;

	using MetraTech.Interop.MTHooklib;
	using Auth = MetraTech.Interop.MTAuth;


	/// <summary>
	/// Configuration hook used by MPM
	/// <summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("dd71bcb2-a651-4984-846c-c6c5089446b8")]
	public class Hook : IMTSecuredHook
	{
		public void Execute(IMTSessionContext context, object var, ref int val)
		{
			Client client = new Client();
			client.SessionContext = (Auth.IMTSessionContext) context;
      // update config files with information from the database first
      // don't want to override what is in the database already.
      client.SynchronizeConfigFile(); 
      client.Synchronize();
		}
	}
}
