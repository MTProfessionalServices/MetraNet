using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Reflection;
using System.Data;
using System.Diagnostics;


namespace BaselineGUI
{
    class CreateTableDemo
    {
        [Table(Name = "t_ldperf_a")]
        class User
        {
            [Column(IsPrimaryKey=true)]
            public int ID;

            [Column(DbType="NVarChar(20) NOT NULL")]
            public string Name;

        }


        public static void CreateTable()
        {
            var context = new DataContext(Framework.conn);
            // { Log = Console.Out };
            MetaTable metaTable = context.Mapping.GetTable(typeof(User));

            context.ExecuteCommand(string.Format("drop table {0}", metaTable.TableName));


            // Debug.Assert(metaTable != null);

            var typeName = "System.Data.Linq.SqlClient.SqlBuilder";
            var type = typeof(DataContext).Assembly.GetType(typeName);
            var bf = BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.InvokeMethod;
            string sql;
            sql = (string)type.InvokeMember("GetCreateTableCommand", bf, null, null, new[] { metaTable });
            Console.WriteLine(sql);

            context.ExecuteCommand(sql);

            Stopwatch watch = new Stopwatch();
            var foo = context.GetTable<User>();

            watch.Start();
            for (int ix = 0; ix < 1000; ix++)
            {
                User user = new User();
                user.ID = ix+10;
                user.Name = "Glenna";
              
                foo.InsertOnSubmit(user);
            }

            context.SubmitChanges();
            watch.Stop();

            Console.WriteLine("Time in msec is {0}", watch.ElapsedMilliseconds);
            //context.ExecuteCommand("insert into t_ldperf_a values({0})", user);
        }
    }
}
