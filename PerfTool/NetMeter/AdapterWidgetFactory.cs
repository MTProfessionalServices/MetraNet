using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Data.SqlClient;
using System.IO;
using System.Xml;
using Lexicons;

namespace NetMeterObj
{
    public static class AdapterWidgetFactory
    {
        public static Dictionary<string, AdapterWidget> widgets = new Dictionary<string, AdapterWidget>();

        public static AdapterWidget create(string tableName)
        {
            AdapterWidget widget = new AdapterWidget();
            widget.tableName = tableName;
            widgets.Add(tableName, widget);
            return widget;
        }

        public static AdapterWidget find(string key)
        {
            return widgets[key];
        }

        public static void buildWidgets(SqlConnection conn)
        {
            foreach (var kvp in widgets)
            {
                kvp.Value.build(conn);
            }
        }

        public static AdapterWidget byObjectId(Int32 objectId)
        {
            foreach (var kvp in widgets)
            {
                AdapterWidget aw = kvp.Value;
                if (aw.objectId == objectId)
                    return aw;
            }
            return null;
        }

    }
}
