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
    public class FCProductViewRepo : FrameworkComponentBase, IFrameworkComponent
    {
        public class DbProdView
        {
            public string nm_name { get; set; }
            public int id_prod_view { get; set; }
            public string nm_table_name { get; set; }
        }


        public Dictionary<string, ProductView> prodViews = new Dictionary<string, ProductView>();
        public Dictionary<string, DbProdView> dbProdViews = new Dictionary<string, DbProdView>();



        public FCProductViewRepo()
        {
            name = "ProductViewRepo";
            fullName = "Product Views";
        }

        public void Teardown()
        {
        }

        public void importFromDB()
        {
            DataContext dc = new DataContext(Framework.conn);
            List<DbProdView> pvs = dc.ExecuteQuery<DbProdView>("select id_prod_view,nm_name,nm_table_name from dbo.t_prod_view").ToList<DbProdView>();
            foreach (DbProdView pv in pvs)
            {
                dbProdViews.Add(pv.nm_name, pv);
            }

        }


        public void Bringup()
        {
            bringupState.message = "Loading...";
            // Read the database
            importFromDB();

            // Read the msixdef files from the extension directory
#if false
            {
                string dirName = PrefRepo.active.folders.extension;
                dirName += @"\config\productview\metratech.com";

                foreach (string fileName in Directory.EnumerateFiles(dirName, "*.msixdef"))
                {
                    ProductView pview = new ProductView();
                    pview.LoadFromXML(fileName);
                    int id = dbProdViews[pview.fullName].id_prod_view;
                    pview.loadFromDB(id);
                    prodViews.Add(pview.fullName, pview);
                }
            }
#endif

            bringupState.message = string.Format("Loaded {0} product views", prodViews.Count);
        }
    }


}
