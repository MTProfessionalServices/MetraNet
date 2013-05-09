using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Xml;
using System.IO;
using System;
using System.Linq;
using System.Text;
using System.Data.Linq;
using System.Data.Linq.Mapping;


namespace BaselineGUI
{
    public class FCSvcDefRepo : FrameworkComponentBase, IFrameworkComponent
    {
        public class DbSvcDef
        {
            public string nm_service_def { get; set; }
            public int id_service_def { get; set; }
        }


        public Dictionary<string, ServiceDefn> svcDefs = new Dictionary<string, ServiceDefn>();
        public Dictionary<string, DbSvcDef> dbSvcDefs = new Dictionary<string, DbSvcDef>();



        public FCSvcDefRepo()
        {
            name = "SvcDefRepo";
            fullName = "Service Definitions";
        }


        public void Bringup()
        {
            // Read the database
            bringupState.message = "Loading from DB";
            importFromDB();

            // Read the msixdef files from the extension directory
            bringupState.message = "Loading from extension folder";

            if (true)
            {
                string dirName = PrefRepo.active.folders.extension;
                dirName += @"\config\service\metratech.com";

                foreach (string fileName in Directory.EnumerateFiles(dirName, "*.msixdef"))
                {
                    ServiceDefn sdef = new ServiceDefn();
                    sdef.LoadFromXML(fileName);
                    int id = dbSvcDefs[sdef.fullName].id_service_def;
                    sdef.loadFromDB(id);
                    svcDefs.Add(sdef.fullName, sdef);
                }
            }
            bringupState.message = string.Format("Found {0} Service Definitions", svcDefs.Count);
        }

        public void importFromDB()
        {
            DataContext dc = new DataContext(Framework.conn);
            List<DbSvcDef> svcs = dc.ExecuteQuery<DbSvcDef>("select nm_service_def,id_service_def from dbo.t_service_def_log").ToList<DbSvcDef>();
            foreach (DbSvcDef svc in svcs)
            {
                dbSvcDefs.Add(svc.nm_service_def, svc);
            }

        }

        public void Teardown()
        {
        }

    }


}
