using System.Diagnostics;
using MetraTech.DataAccess;

using System.Runtime.InteropServices;

[assembly: GuidAttribute("c4962277-9545-467e-b068-4cf3a2e301db")]

namespace MetraTech.DataAccess.DMO
{
  using System;
  using System.Data;

	// NOTE: to generate sqldmodotnet.dll, use this command line
	// tlbimp /keycontainer:MetraTech sqldmo.dll /out:sqldmodotnet.dll

	using sqldmodotnet;

	[Guid("a0fff9ee-deb8-4eee-8afe-f5452935996f")]
  public interface ISQLManager
  {
		void BackupNetMeter(string backupDir, string backupName);
		void RestoreNetMeter(string saName, string saPassword,
												 string backupDir, string backupName,
												 bool shutdown);
	}

  [ClassInterface(ClassInterfaceType.None)]
	[Guid("fb15e2d3-319d-4664-82ee-2f942872092f")]
	public class SQLManager : ISQLManager
	{
		public void BackupNetMeter(string backupDir, string backupName)
		{
			SQLServer srv = new SQLServer();
			srv.LoginTimeout = 15;
			ConnectionInfo info = ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database");

			srv.Connect(info.Server, info.UserName, info.Password);
			try
			{

				Backup backup = new Backup();
				backup.Action = SQLDMO_BACKUP_TYPE.SQLDMOBackup_Database;
				backup.Database = info.Catalog;

			//BackupDevice device = new BackupDevice();
				backup.Files = backupDir + "\\" + info.Catalog + "_" + backupName + ".bak";
				backup.Initialize = true;
				backup.BackupSetName = info.Catalog + "_Full";
				backup.BackupSetDescription = "Full backup of NetMeter database";

				backup.SQLBackup(srv);
			}
			finally
			{
				srv.DisConnect();
			}
		}

		public void Restart(string saName, string saPassword)
		{
			SQLServer srv = new SQLServer();
			srv.LoginTimeout = 15;
			ConnectionInfo info = ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database");

			srv.Connect(info.Server, saName, saPassword);

			srv.DisConnect();
			srv.Stop();

			SQLDMO_SVCSTATUS_TYPE status;
			int count = 0;
			while (true)
			{
				status = srv.Status;
				if (status == SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Stopped)
					break;
				System.Threading.Thread.Sleep(1 * 1000);
				count++;
				if (count == 60)
					throw new DataAccessException("Unable to stop SQLServer");
			}

			srv.Start(true, info.Server, saName, saPassword);

			count = 0;
			while (true)
			{
				status = srv.Status;
				if (status == SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Running)
					break;
				System.Threading.Thread.Sleep(1 * 1000);
				count++;
				if (count == 60)
					throw new DataAccessException("Unable to start SQLServer");
			}
		}

		public void RestoreNetMeter(string saName, string saPassword,
																string backupDir, string backupName,
																bool shutdown)
		{
			if (shutdown)
				Restart(saName, saPassword);

			SQLServer srv = new SQLServer();
			srv.LoginTimeout = 15;
			ConnectionInfo info = ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database");

			srv.Connect(info.Server, saName, saPassword);

			try
			{
				Restore restore = new Restore();
				restore.Action = SQLDMO_RESTORE_TYPE.SQLDMORestore_Database;
				restore.Database = info.Catalog;
				restore.ReplaceDatabase = true;

				restore.Files = backupDir + "\\" + info.Catalog + "_" + backupName + ".bak";
				restore.SQLRestore(srv);
			}
			finally
			{
				srv.DisConnect();
			}

			// finally, make nmdbo the owner again.  we have to log in as sa to do this
			ConnectionInfo saLogin = (ConnectionInfo) info.Clone();
			saLogin.UserName = saName;
			saLogin.Password = saPassword;

            using (IMTConnection conn = ConnectionManager.CreateConnection(saLogin))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("sp_changedbowner"))
                {
                    stmt.AddParam("loginname", MTParameterType.String, info.UserName);
                    stmt.ExecuteNonQuery();
                }
            }
		}
	}

	
}
