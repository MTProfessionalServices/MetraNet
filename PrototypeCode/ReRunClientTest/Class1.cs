using System;

namespace ReRunClientTest
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class Class1
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			localhost.Service service = new localhost.Service();
			int id = service.Setup("test", null);
			//
			// TODO: Add code to start application here
			//
		}
	}
}
