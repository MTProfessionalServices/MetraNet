using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;

namespace MetraTech.ExpressionEngine
{
    public static class _DemoLoader
    {
        public static string DirPath = @"C:\ExpressionEngine";
        public static Context GlobalContext;

        #region Constructor
        static _DemoLoader()
        {

            GlobalContext.AddFunction("Min", "Math", "Returns the minumum value");
            GlobalContext.AddFunction("Max", "Math", "Returns the maximum value");
            var func = GlobalContext.AddFunction("DateAdd", "DateTime", "Adds the spcified unit of time");
            func.FixedParameters.AddDateTime("Timestamp", "When it happened", true);
            func.FixedParameters.AddInt32("Quantity", "How much", true);
            func.FixedParameters.AddEnum("Country", "Where it happened", true, "Global", "Country");
            GlobalContext.AddFunction("DateDiff", "DateTime", "Subtracts the specified unit of time");
            GlobalContext.AddFunction("In", "Logic", "Determines if an enum value is within a specified list");

            GlobalContext.AddEntity(_DemoLoader.GetCloudComputeProductView());
            GlobalContext.AddEntity(_DemoLoader.GetCorporateAccountType());
            GlobalContext.AddEntity(_DemoLoader.GetAircraftLandingProductView());

            GlobalContext.AddInteraction("ComputeHours", "Number of compute hours", Property.DirectionType.InOut);
            GlobalContext.AddInteraction("UnitRate", "The unit rate", Property.DirectionType.Input);
            GlobalContext.AddInteraction("CpuCycles", "The number of CPU cylces", Property.DirectionType.Input);
            GlobalContext.AddInteraction("ComputeHourCharge", "The charge associated with computing", Property.DirectionType.Output);

            LoadEnums();

            //LoadXqgs("");
        }
        #endregion

        public static void LoadEnums()
        {
            var global = new EnumSpace("Global", null);
            var country = global.AddType("Country", null);
            country.AddValue("US");
            country.AddValue("Germany");
            GlobalContext.AddEnum(global);
        }

        #region XQGs
        public static void LoadXqgs(string filePath)
        {
            var dataSet = new DataSet();
            var table = dataSet.Tables.Add();
            table.Columns.Add("Type", typeof(string));
            table.Columns.Add("Name", typeof(string));
            table.Columns.Add("Description", typeof(string));
            table.Columns.Add("Expression", typeof(string));

            var rows = File.ReadAllLines(filePath);
            for (int index = 1; index < rows.Length; index++)
            {
                var columns = rows[index].Split(',');
                var type = columns[0];
                var name = columns[1];
                var description = columns[2];
                var expression = columns[3];
                table.Rows.Add(type, name, description, expression);
            }
        }

        public static void LoadXqgs(DataTable table)
        {
            foreach (DataRow row in table.Rows)
            {
                if (row.Field<string>("Type") == "AQG")
                {
                    var aqg = AQG.CreateFromDataRow(row);
                    GlobalContext.AQGs.Add(aqg.Name, aqg);
                }
                else
                {
                    var uqg = UQG.CreateFromDataRow(row);
                    GlobalContext.UQGs.Add(uqg.Name, uqg);
                }
            }
        }
        #endregion


        public static Entity GetCloudComputeProductView()
        {
            var entity = new Entity("CloudCompute", Entity.EntityTypeEnum.ProductView, "Models an cloud compute usage even");

            var pv = entity.Properties;
            pv.AddInt32("NumSnapshots", "The number of snapshots taken", true);
            pv.AddString("DataCenter", "The data center in which the server ran", true, null, 30);
            pv.AddEnum("DataCenterCountry", "The country that the data center is located", true, "Global", "Country");
            pv.AddEnum("ChargeModel", "The charinging model used to calculate the compute charge", true, "Cloud", "ChargeModel");
            pv.AddDecimal("InstanceSize", "The size of the instance", true);
            pv.AddEnum("OS", "The Operating System (OS)", true, "Cloud", "OperatingSystem");
            pv.AddInt32("Memory", "The amont of memoery", true);
            pv.AddDecimal("CpuCount", "The number of million CPU cycles", true);
            pv.AddDecimal("Hours", "The number of hours the instance ran", true);
            AppendCommonPvProperties(pv);
            return entity;
        }

        public static Entity GetAircraftLandingProductView()
        {
            var entity = new Entity("AircraftLanding", Entity.EntityTypeEnum.ProductView, "Models an cloud compute usage even");

            var pv = entity.Properties;
            pv.AddInt32("MTOW", "Maximum TakeOff Weight", true);
            pv.AddInt32("AircraftWeight", "The Weight of the aircraft in tons", true);
            pv.AddInt32("NumPassengers", "The Weight of the aircraft in tons", true);
            pv.AddInt32("NumTransferPassengers", "The Weight of the aircraft in tons", true);
            pv.AddInt32("NumCrew", "The Weight of the aircraft in tons", true);
            AppendCommonPvProperties(pv);

            return entity;
        }
        public static void AppendCommonPvProperties(PropertyCollection props)
        {
            props.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
            props.AddInt32("AccountId", "The account associated with the event", true);
            props.AddCharge("EventCharge", "The charge assoicated with the event which may summarize other charges within the event", true);
        }

        public static Entity GetCorporateAccountType()
        {
            var entity = new Entity("CorporateAccount", Entity.EntityTypeEnum.AccountType, "Models an corporate account");

            var pv = entity.Properties;
            pv.AddString("FirstName", "The data center in which the server ran", true, null, 30);
            pv.AddString("MiddleName", "The data center in which the server ran", true, null, 30);
            pv.AddString("LastName", "The data center in which the server ran", true, null, 30);
            pv.AddString("City", "The data center in which the server ran", true, null, 30);
            pv.AddString("State", "The data center in which the server ran", true, null, 30);
            pv.AddString("ZipCode", "The data center in which the server ran", true, null, 30);
            pv.AddEnum("Country", "The Operating System (OS)", true, "Global", "Country");

            return entity;
        }

        public static void LoadEnums(Context context)
        {
            EnumSpace.LoadEnumFile(context, Path.Combine(DirPath, @"Data\Enums.csv"), true);
        }

        public static void LoadXqgs(Context context)
        {
            var path = Path.Combine(DirPath, @"Data\XQGs.csv");
            var lines = File.ReadAllLines(path);
            foreach (var line in lines)
            {
                var parts = line.Split(',');
                var type = parts[0];
                var name = parts[1];
                var description = parts[2];
                var expression = parts[3];

                switch (type.ToLower())
                {
                    case "aqg":
                        var aqg = new AQG(name, description, expression);
                        context.AQGs.Add(aqg.Name, aqg);
                        break;
                    case "uqg":
                        var uqg = new UQG(name, description, expression);
                        context.UQGs.Add(uqg.Name, uqg);
                        break;
                    default:
                        throw new Exception(string.Format("Bad XQG [{0}]", line));
                }
            }
        }
    }
}
