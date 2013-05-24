/* --------------------------------------------------------------------------------------------------------------------------------------------
' MetraTech C# System Install Check
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
'
' TEST NAME     :  System Check
' AUTHOR        :  Stephen Boyer
' CREATION_DATE :  07/30/2003
' DESCRIPTION   :Checks system for requirements to install MetraNet
' PARAMETERS   :
' --------------------------------------------------------------------------------------------------------------------------------------------
*/

using System;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using Microsoft.Win32;
//using System.Collections;
//using System.Text.RegularExpressions;
//using System.Text;

namespace MetraTech
{
	public class InstallCheck
	{
	
		public static string resp;
		public static string strY;
		public static string my_Drive;
		public static string yayOrNay;
		public static bool metraPayorNay;
		public const string my_PFPRO = ":\\MetraTech\\RMP\\Extensions\\pAymentsvr\\config\\verisign\\certs";
		public static string my_DOT_NET_PATH = ":\\WINNT\\Microsoft.NET\\Framework\\v1.1.4322;";
		public static string check_not_35_frame = ":\\WINNT\\Microsoft.NET\\Framework\\v1.0.3705;";
		public const string my_SHARED_DLLS_PATH = ":\\MetraTech\\RMP\\SharedDlls;";
		public const string my_OS_REG = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion";
		public const string my_IE_REG = "SOFTWARE\\Microsoft\\Internet Explorer";
		public const string my_OS_SP_REG = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion";
		public const string my_SQL_REG = "SOFTWARE\\Microsoft\\MSSQLServer\\Client";
		public const string my_SECURITY = "SOFTWARE\\Microsoft\\Cryptography\\Defaults\\Provider\\Microsoft Enhanced Cryptographic Provider v1.0";
		public const string my_MSMQ_REG = "SOFTWARE\\Microsoft\\MSMQ\\Setup";
		public const string my_DOT_NET_REG = "SOFTWARE\\Microsoft\\.NETFramework";

		public const string my_OS_VER = "5.0";
		public const string my_IE_VER = "6.0";
		public const string my_OS_SP_VER = "Service Pack 3";
		public const string my_SQL_VER = "8.00.760";
	
		public static string my_MT_Ver = "";
		public static string defUID ="sa";
		public static string defUPass = "";
		public static string defServer = "localhost";

		//private static RegistryKey classesRoot = null;
		//private static RegistryKey crInstaller = null;
		//private static RegistryKey crProducts = null;

		static void Main(string[] args)
		{
			//RegistrySearch registrySearch = new RegistrySearch(args);
			//registrySearch.execute();
			bool checker = true;
			bool majorChecker = true/*, minorChecker = true*/;
			/*while ( (isProductInstalled()) && (minorChecker) )
			{
				Console.Write ("\n\nMetraNet is already installed do you want to proceed? [N]");
				resp = Console.ReadLine();
				resp = resp.ToUpper();
				if ((resp == "N") || (resp == "")||(resp == "NO"))
					Environment.Exit(1); 
				else if ((resp == "Y")||(resp == "YES"))
					minorChecker = false;
				else
					Console.WriteLine("Invalid Character try again");
			}*/
			while (majorChecker)
			{
				checker = true;
				while (checker)
				{
					Console.WriteLine("\n\n\n");
					Console.WriteLine ("		Install Check\n");
					Console.Write ("On which drive do you plan to install MetraNet? [C]: ");
					my_Drive = Console.ReadLine();
					if (my_Drive == "")
					{
						my_Drive = "C";
						checker = false;
					}
					my_Drive = my_Drive.ToUpper ();
					if (my_Drive.Length == 1)
						checker = false;
					else
						Console.WriteLine("**Please just enter the letter of the dirve nothing else**");
				}
				checker = true;
				strY = "";
				Console.Write ("Do you plan to install MetraPay? (y/n) [y]: ");
				strY = Console.ReadLine();
				if ((strY == "")||(strY == "Y")||(strY == "y"))
					metraPayorNay = true;
				else
					metraPayorNay = false;
		
				Console.Write("Database server Name [localhost]: ");
				defServer = Console.ReadLine();
				if (defServer == "")
					defServer = "localhost";
				Console.Write("Database Administrator login [sa]: ");
				defUID = Console.ReadLine();
				if (defUID=="")
					defUID = "sa";
				Console.Write("Database Administrator password [blank]: ");
				defUPass = Console.ReadLine();
				Console.WriteLine("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
				Console.WriteLine("Installing MetraNet on Drive " + my_Drive + ":");
				if (metraPayorNay)
					Console.WriteLine("Installing MetraPay");
				else
					Console.WriteLine("Not Intalling MetraPay");
				Console.WriteLine("Database Server is " + defServer);
				Console.WriteLine("Database Administrator Login is " + defUID);
				if (defUPass=="")
					Console.WriteLine("Database Administrator password is Blank");
				else
					Console.WriteLine("Database Administrator password is " + defUPass);
				Console.WriteLine("");
				Console.Write("Is this correct? (y/n) [y]:");
				yayOrNay = Console.ReadLine();
				if ((yayOrNay=="")||(yayOrNay=="y")||(yayOrNay=="Y"))
					majorChecker = false; 
			}
			Console.WriteLine("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
			Console.WriteLine("--- Checking Software Versions ---");
			Console.WriteLine("");
			Console.Write("	Windows 2000... ");
			if (openAndCheck(my_OS_REG, my_OS_VER, "Windows 2000", "CurrentVersion"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	Windows 2000 does not meet requirements");
			
			Console.Write("	Service Pack... ");
			if (openAndCheck(my_OS_SP_REG, my_OS_SP_VER, "Windows 2000", "CSDVersion"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	Windows 2000 Service Pack does not meet requirements");
			
			Console.Write("	Internet Explorer... ");
			if (openAndCheck(my_IE_REG, my_IE_VER, "Internet Explorer", "Version"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	Internet Explorer does not meet requirements");
			
			Console.Write("	SQL Client");
			if (justOpen(my_SQL_REG, "SQL Server Client"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	SQL Server Client must be installed on local machine");
			
			Console.Write("	MSMQ");
			if (justOpen (my_MSMQ_REG , "MSMQ"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	NOT DETECTED******");
			
			Console.Write("	128 Bit Security");
			if (justOpen (my_SECURITY, "128 bit Security"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	NOT DETECTED******");
			
			Console.Write("	Dot Net Framework");
			if (justOpen (my_DOT_NET_REG, "Dot Net Framework"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	NOT DETECTED******");
			
			Console.WriteLine("");
			Console.WriteLine("--- Checking System Variables ---");
			Console.WriteLine("");
			if (metraPayorNay)
			{
				Console.WriteLine("	PFPRO_CERT_PATH");
				if (checkPath( my_PFPRO, "PFPRO_CERT_PATH"))
					Console.WriteLine (".....Ok");
				else
					Console.WriteLine ("\n==>	NOT DETECTED******");
			}
			
			Console.WriteLine("	PATH");
			if (checkPath(my_SHARED_DLLS_PATH, "PATH"))
				Console.WriteLine(".....Ok");
			else
				Console.WriteLine ("\n==>	NOT DETECTED******");
			
			if (checkPath(my_DOT_NET_PATH, "PATH"))
				Console.WriteLine (".....Ok");
			else
				Console.WriteLine("\n==>	NOT DETECTED******");
			
			Console.WriteLine("");
			Console.WriteLine("--- Checking SQL Database ---");
			Console.WriteLine("");
			if (!checkSqlServer(defServer, defUPass, defUID))
				Console.WriteLine("\n==>	Could not establish a connection");
			else
				Console.WriteLine("	Connection ...Ok");
			string foooo;
			Console.WriteLine("");
			Console.WriteLine("==>  Remember to check the WINNT TEMP folder, 'Everyone' Group has to be a user with Full Control");
			Console.WriteLine("Install Check is complete press Enter to quit");
			foooo = Console.ReadLine();
		}
		public static bool justOpen(string strPath, string strApp)
		{
			RegistryKey theCurrentMachine = Registry.LocalMachine;
			if (theCurrentMachine.OpenSubKey(strPath)== null)
			{
				Console.WriteLine("\n");
				Console.WriteLine("************" + strApp +  " was not detected");
				return false;
			}
			return true;
		}

		public static bool openAndCheck(string strPath, string strVer, string strApp, string strFinalFolder)
		{
			string toCheck;
			RegistryKey theCurrentMachine = Registry.LocalMachine;
			if (theCurrentMachine.OpenSubKey(strPath)== null)
			{
				Console.WriteLine("\n");
				Console.WriteLine(strApp +  " was not detected");
				return false;
			}
			RegistryKey thePath = theCurrentMachine.OpenSubKey(strPath);
			if (thePath.GetValue(strFinalFolder) == null)
			{
				Console.WriteLine("\n");
				Console.WriteLine(strApp +  " final key was not detected");
				return false;
			}
			
			toCheck = (string) thePath.GetValue(strFinalFolder);
			if (strVer != "Service Pack 3")
				Console.Write(toCheck);
			else
				Console.Write(toCheck[13]);
			return (String.Compare(toCheck, strVer) >= 0);
		}
		public static bool checkPath(string strValue, string name)
		{
			string  myPath, myPath1;
			if (System.Environment.GetEnvironmentVariable(name) == null)
			{
				Console.WriteLine("\n");
				Console.WriteLine ("************" + name + "  needs to be added as Systm Variable");
				return false;
			}
			string def_Drive = "";
			string def_notDrive = "";
			int dotNet = 0;
			if (strValue != ":\\WINNT\\Microsoft.NET\\Framework" )
				strValue = my_Drive + strValue;
			else
			{
				def_Drive = System.Environment.GetEnvironmentVariable("SystemRoot");
				def_notDrive = def_Drive + check_not_35_frame;
				def_Drive = def_Drive.Substring(0,1);
				strValue = my_Drive + strValue;
				def_notDrive = def_notDrive.ToUpper();
				myPath1 = System.Environment.GetEnvironmentVariable(name);
				myPath1 = myPath1.ToUpper();
				dotNet = myPath1.LastIndexOf (def_notDrive);
			}
			Console.Write("	   " + strValue);
			strValue = strValue.ToUpper();
			def_notDrive = def_notDrive.ToUpper();
			myPath = System.Environment.GetEnvironmentVariable(name);
			myPath = myPath.ToUpper();
			if ((myPath.LastIndexOf (strValue) < dotNet) && (myPath.LastIndexOf (strValue) >= 0))
				Console.WriteLine("\n==>	v1.1.43221 framework must come before v1.0.3705 in the PATH");
			if (myPath.LastIndexOf (strValue) >= 0)
				return true;
			return false;
		}
		public static bool checkSqlServer(string server, string adminPass, string userName)
		{
			try
			{
				string row;
				string commandString = "Select @@Version";
				string connectionStr = "server=" + server + "; uid="+ userName + "; pwd=" + adminPass + "; database=master";
				SqlConnection myConnection = new SqlConnection(connectionStr);	
				SqlCommand myCommand = new SqlCommand(commandString, myConnection);
				myConnection.Open();
				row = (string) myCommand.ExecuteScalar(); 
				myConnection.Close();
				if (row.LastIndexOf (my_SQL_VER) >= 0)
					return true;
				Console.WriteLine("\n");
				Console.WriteLine("***************SQL Server error does not contain ");
				return false;
			}
			catch (Exception)
			{
				Console.WriteLine("Check Database server/username/password and try again.");	
				return false;
			}
		}
		/*public static bool isProductInstalled()
		{
			classesRoot = Registry.ClassesRoot;
			crInstaller = classesRoot.OpenSubKey("Installer");
			crProducts = crInstaller.OpenSubKey("Products");
			string[] productsInstalled = crProducts.GetSubKeyNames();
			foreach(string productInstalled in productsInstalled)
			{
				RegistryKey product = crProducts.OpenSubKey(productInstalled);
				if ((string)product.GetValue("ProductName") == "MetraNet")
				{
					return true;
				}
			}
			return false;
		}*/
	}//class
}//namespace

