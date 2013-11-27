using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using System.Data.Linq;
using System.Data.SqlClient;
using System.IO;
using System.CodeDom;

namespace Linqify
{
    public class NetMeterBuilder
    {
        Schemas schemas = new Schemas();

        public List<ObjectIndex> indices = new List<ObjectIndex>();

        public void buildNetMeter(StringBuilder sb)
        {
            NetMeterCodeDom.workOnClass("NetMeterObj");

            sb.AppendLine("  public partial class NetMeterObj");
            sb.AppendLine("  {");

            // Class variables
            foreach (string tableName in Config.getTableNames())
            {
                string className = schemas.getClassName(tableName);
                sb.AppendFormat("    public static List<{0}> {0}List;", className);
                sb.AppendLine();
                NetMeterCodeDom.addInMemoryList(className);
            }

            // Indices
            sb.AppendLine();
            foreach (ObjectIndex idx in indices)
            {
                idx.declare(sb);
            }


            //List loaders
            sb.AppendLine();
            NetMeterCodeDom.workOnMethod("loadLists");
            NetMeterCodeDom.addParameter("DataContext", "dc");

            sb.AppendLine("    public void loadLists(DataContext dc)");
            sb.AppendLine("    {");
            foreach (string tableName in Config.getTableNames())
            {
                string className = schemas.getClassName(tableName);
                sb.AppendFormat("      {0}List = load<{0}>(dc, \"{1}\");", className, tableName);
                sb.AppendLine();

                NetMeterCodeDom.addListLoad(className, tableName);
            }
            // Indices
            sb.AppendLine();
            foreach (ObjectIndex idx in indices)
            {
                idx.construct(sb);
                NetMeterCodeDom.addField_index(idx);
            }
            sb.AppendLine("    }");


            NetMeterCodeDom.workOnMethod("createAdapterWidgets");

            sb.AppendLine("    public void createAdapterWidgets()");
            sb.AppendLine("    {");
            foreach (string tableName in Config.getTableNames())
            {
                string className = schemas.getClassName(tableName);
                sb.AppendFormat("     {0}.adapterWidget = AdapterWidgetFactory.create(\"{1}\");", className, tableName);
                sb.AppendLine();
                NetMeterCodeDom.addCreateAdapterWidget(className, tableName);
            }
            sb.AppendLine("    }");


            sb.AppendLine("  }"); // end class
        }


 


        public void addIndices()
        {
            indices.Clear();

            indices.Add(new ObjectIndex("t_acc_usage_cycle", true, "id_acc"));

            indices.Add(new ObjectIndex("t_account", true, "id_acc"));
            indices.Add(new ObjectIndex("t_account_state", true, "id_acc"));
            indices.Add(new ObjectIndex("t_account_state_history", false, "id_acc"));


            indices.Add(new ObjectIndex("t_account_ancestor", false, "id_ancestor"));
            indices.Add(new ObjectIndex("t_account_ancestor", false, "id_descendent"));

            indices.Add(new ObjectIndex("t_dm_account", false, "id_acc"));
            indices.Add(new ObjectIndex("t_dm_account_ancestor", false, "id_dm_ancestor"));
            indices.Add(new ObjectIndex("t_dm_account_ancestor", false, "id_dm_descendent"));

            indices.Add(new ObjectIndex("t_account_mapper", false, "id_acc"));
            indices.Add(new ObjectIndex("t_account_mapper", true, "nm_login", "nm_space"));

            indices.Add(new ObjectIndex("t_user_credentials", true, "nm_login", "nm_space"));

            indices.Add(new ObjectIndex("t_account_type", true, "id_type"));
            indices.Add(new ObjectIndex("t_account_type", true, "name"));

            indices.Add(new ObjectIndex("t_role", true, "id_role"));
            indices.Add(new ObjectIndex("t_role", true, "tx_name"));

            indices.Add(new ObjectIndex("t_principal_policy", false, "id_acc"));
            indices.Add(new ObjectIndex("t_capability_instance", false, "id_policy"));

            indices.Add(new ObjectIndex("t_usage_cycle", true, "id_usage_cycle"));
            indices.Add(new ObjectIndex("t_usage_interval", false, "id_usage_cycle"));

            indices.Add(new ObjectIndex("t_prod_view", true, "id_prod_view"));
            indices.Add(new ObjectIndex("t_prod_view", true, "nm_name"));

            indices.Add(new ObjectIndex("t_sub", false, "id_acc"));
        }


        public StringBuilder buildFile()
        {
            foreach (string tableName in Config.getTableNames())
            {
                schemas.readTable(tableName);
            }

            addIndices();

            foreach (var idx in indices)
            {
                idx.deriveFields(schemas);
            }

            StringBuilder sb = new StringBuilder();

            foreach (string s in Config.getUsings())
            {
                sb.AppendLine(string.Format("using {0};", s));
            }

            sb.AppendLine();
            sb.AppendLine();

            sb.AppendLine("namespace NetMeterObj");
            sb.AppendLine("{");

            buildNetMeter(sb);

            foreach (string tableName in Config.getTableNames())
            {
                schemas.processTable(sb, tableName);
            }
            sb.AppendLine("}");

            return sb;
        }



    }
}
