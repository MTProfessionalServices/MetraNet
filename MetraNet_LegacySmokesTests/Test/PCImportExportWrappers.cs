using System;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
using Common = MetraTech.Test.Common;

enum IMPORT_EXPORT_MODE
{
	IMPORT_EXPORT_MODE_DEFAULT_MODE = 1, // default mode
	IMPORT_EXPORT_MODE_SAFE_MODE = 2,
	IMPORT_EXPORT_MODE_OVERWRITE_MODE = 4, // Should not be implemented in 3.5
	IMPORT_EXPORT_MODE_COM_PLUS = 8,
	IMPORT_EXPORT_UNIT_TEST_ROLLBACK = 16,
	IMPORT_EXPORT_MULTI_FILE = 32,
	IMPORT_EXPORT_VERBOSE = 64,
	IMPORT_EXPORT_SKIP_INTEGRITY = 128
}



namespace MetraTech.Test
{

	/// <summary>
	/// Summary description for PCExportWrapper.
	/// </summary>
	public class PCExportWrapper
	{

		private object disp;
		private Type type;

		public PCExportWrapper()
		{
			//"MTPCImportExportExec.CExport"
			type = Type.GetTypeFromProgID("MTPCImportExportExec.CExport");
			disp = Activator.CreateInstance(type);
		}

		//Public Function ExportProductOffering
		//(ByVal strXMLFileName As String, ByVal strProductOfferingNames As String, 
		//ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean
		public void ExportProductOffering(string file, string poname)
		{
			//"MTPCImportExportExec.CExport"
			// MethodInfo myMethod = myType.GetMethod("MyMethod", BindingFlags.Public | BindingFlags.Instance,
      //      new MyBinder(), new Type[] {typeof(short), typeof(short)}, null);
			IntPtr p = Marshal.GetIDispatchForObject(disp);
			object lpDispatch = new DispatchWrapper(p); 
			ArrayList arguments = new ArrayList();
			arguments.Add(file);
			arguments.Add(poname);
			arguments.Add(IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_DEFAULT_MODE & IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_COM_PLUS);
			arguments.Add("");

			object ret = type.InvokeMember("ExportProductOffering",
				System.Reflection.BindingFlags.InvokeMethod,
				null, disp, arguments.ToArray()); 

			bool bret = System.Convert.ToBoolean(ret);
			if(bret == false)
				throw new ApplicationException("ExportProductOffering() failed!");
			return;
		}


		//booExitCode = Export.ExportProductOffering(g_objCommandLine.GetValue("-file"), g_objCommandLine.GetValue("-epo"), eMode, Command)

    // From VB code
    //booExitCode = 
    // Export.ExportGroupSubscriptions
    //  (g_objCommandLine.GetValue("-file"), 
    //   g_objCommandLine.GetValue("-corp"), 
    //   g_objCommandLine.GetValue("-corpnamespace", ""), 
    //   g_objCommandLine.GetValue("-groupsubscription"), 
    //   g_objCommandLine.GetValue("-username"), 
    //   g_objCommandLine.GetValue("-password"), 
    //   g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE), 
    //   eMode, 
    //   Command, 
    //   GetGMTDateFromCommandLine())

    // From CR 13677
    // pcimportexport -egs 
    //                -file "C:\groups.xml" 
    //                -corp "WorldTeleport_USD" 
    //                -corpNameSpace mt 
    //                -groupsubscription "*" 
    //                -username su 
    //                -password su123

    public void ExportGroupSubscription(string file, 
                                        string corporateAccountName,
                                        string corporateNamespace,
                                        string username,
                                        string password)
    {
      IntPtr p = Marshal.GetIDispatchForObject(disp);
      object lpDispatch = new DispatchWrapper(p); 
      ArrayList arguments = new ArrayList();
      arguments.Add(file);
      arguments.Add(corporateAccountName);
      arguments.Add(corporateNamespace);
      arguments.Add("*"); //-groupsubscription
      arguments.Add(username);
      arguments.Add(password);
      arguments.Add("system_user"); // default namespace
      arguments.Add(IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_DEFAULT_MODE & 
                    IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_COM_PLUS);
      arguments.Add(""); // Command
      arguments.Add(MetraTime.Now);

      object ret = type.InvokeMember("ExportGroupSubscriptions",
        System.Reflection.BindingFlags.InvokeMethod,
        null, disp, arguments.ToArray()); 

      bool bret = System.Convert.ToBoolean(ret);
      if(bret == false)
        throw new ApplicationException("ExportGroupSubscriptions() failed!");
      return;
    }
	}
	//

  //booExitCode = Export.ExportProductOffering(g_objCommandLine.GetValue("-file"), g_objCommandLine.GetValue("-epo"), eMode, Command)


	public class PCImportWrapper
	{

		private object disp;
		private Type type;

		public PCImportWrapper()
		{
			type = Type.GetTypeFromProgID("MTPCImportExportExec.CImportWriter");
			disp = Activator.CreateInstance(type);
		}

		//Public Function ImportProductOffering(ByVal strXMLFileName As String, 
		//ByVal eImportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, 
		//ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String) As Boolean
		public void ImportProductOffering(string file, string poname)
		{
			IntPtr p = Marshal.GetIDispatchForObject(disp);
			object lpDispatch = new DispatchWrapper(p); 
			ArrayList arguments = new ArrayList();
			arguments.Add(file);
			//arguments.Add(IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_DEFAULT_MODE & IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_COM_PLUS);
			arguments.Add(IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_DEFAULT_MODE | IMPORT_EXPORT_MODE.IMPORT_EXPORT_MODE_COM_PLUS);
			arguments.Add("");
			arguments.Add(Common.Utils.SUName);
			arguments.Add(Common.Utils.SUPassword);
			arguments.Add(Common.Utils.SUNamespace);

			object ret = type.InvokeMember("ImportProductOffering",
				System.Reflection.BindingFlags.InvokeMethod,
				null, disp, arguments.ToArray()); 
			bool bret = System.Convert.ToBoolean(ret);
			if(bret == false)
				throw new ApplicationException("ImportProductOffering() failed!");
			return;
		}
	}


}

