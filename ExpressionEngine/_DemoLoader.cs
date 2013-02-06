using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;

namespace MetraTech.ExpressionEngine
{
    //this is a total mess that loads data into the GlobalContext.... needs to replaced with clean data loading
    public static class _DemoLoader
    {
        #region Properties
        public static string DirPath = @"C:\ExpressionEngine";
        public static string DataPath = Path.Combine(DirPath, "Data");
        public static Context GlobalContext;
        #endregion

        #region Constructor
        public static void LoadGlobalContext()
        {
            GlobalContext = new Context();

            GlobalContext.AddEntity(_DemoLoader.GetCloudComputeProductView());
            GlobalContext.AddEntity(_DemoLoader.GetCorporateAccountType());
            GlobalContext.AddEntity(_DemoLoader.GetAircraftLandingProductView());

            LoadEntities(GlobalContext, Entity.EntityTypeEnum.ProductView, Path.Combine(DataPath, "ProductViews.csv"));
            LoadEntities(GlobalContext, Entity.EntityTypeEnum.AccountView, Path.Combine(DataPath, "AccountViews.csv"));
            LoadEnumFile(GlobalContext, Path.Combine(DataPath, "Enums.csv"));
            LoadFunctions();
            LoadXqg(GlobalContext, Expression.ExpressionTypeEnum.AQG, Path.Combine(DataPath, "AqgExpressions.csv"));
            LoadXqg(GlobalContext, Expression.ExpressionTypeEnum.UQG, Path.Combine(DataPath, "UqgExpressions.csv"));
        }
        #endregion

        #region Manual Entities
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
        #endregion

        #region File-Based Entities
        public static void LoadEntities(Context context, Entity.EntityTypeEnum entityType, string filePath)
        {
            var lines = File.ReadAllLines(filePath);
            for (int index = 1; index < lines.Length; index++)
            {
                try
                {
                    var parts = lines[index].Split(',');
                    var pvName = parts[0].Split('/')[1];
                    var propName = parts[1];
                    var required = Helper.GetBool(parts[2]);
                    var type = Int32.Parse(parts[3]);
                    var enumSpace = parts[4];
                    var enumType = parts[5];

                    Entity entity;
                    if (!context.Entities.TryGetValue(pvName, out entity))
                    {
                        entity = new Entity(pvName, entityType, null);
                        context.Entities.Add(entity.Name, entity);
                    }

                    var dataType = DataTypeInfo.PropertyTypeId_BaseTypeMapping[type];
                    var dt =  new DataTypeInfo(dataType);
                    var property = new Property(propName, dt, null);
                    property.Required = required;
                    if (dt.IsEnum)
                    {
                        dt.EnumSpace = enumSpace;
                        dt.EnumType = enumType;
                    }
                    entity.Properties.Add(property);
                }
                catch (Exception ex)
                {
                    throw new Exception(string.Format("Error loading PV, line {0} [{1}]", index, ex.Message));
                }
            }
        }
        #endregion

        #region Enums
        public static void LoadEnumFile(Context context, string filePath)
        {
            var lines = File.ReadAllLines(filePath);
            int skipped = 0;
            for (int lineIndex = 1; lineIndex < lines.Length; lineIndex++)
            {
                try
                {
                    var line = lines[lineIndex];
                    var fields = line.Split(',');

                    if (fields.Length > 3)
                    {
                        skipped++;
                        continue;
                    }

                    var enumValue = fields[0];
                    var spaceAndType = fields[1];
                    var id = Int32.Parse(fields[2]);

                    if (string.IsNullOrWhiteSpace(spaceAndType))
                    {
                        skipped++;
                        continue;
                    }

                    var enumParts = spaceAndType.Split('/');

                    //Namespace?
                    if (enumParts.Length == 1)
                        continue;

                    var enumType = enumParts[enumParts.Length - 1];
                    var enumNamespace = spaceAndType.Substring(0, spaceAndType.Length - enumType.Length - 1); //account for one slash

                    EnumSpace.AddEnum(context, enumNamespace, enumType, enumValue, id);
                }
                catch (Exception ex)
                {
                    throw new Exception(string.Format("Error parsing line #{0}   [{1}]", lineIndex, ex.Message));
                }
            }
        }
        //public static void LoadEnums()
        //{
        //    var global = new EnumSpace("Global", null);
        //    var country = global.AddType("Country", null);
        //    country.AddValue("US");
        //    country.AddValue("Germany");
        //    GlobalContext.AddEnum(global);
        //}
        #endregion

        #region XQGs

        public static void LoadXqg(Context context, Expression.ExpressionTypeEnum type, string filePath)
        {
            var lines = File.ReadAllLines(filePath);
            for (int index = 1; index < lines.Length; index++)
            {
                    var cols = lines[index].Split(',');
                var name = cols[0];
                var expression = cols[1];
                var description = string.Empty;
                switch (type)
                {
                    case Expression.ExpressionTypeEnum.AQG:
                        var aqg = new AQG(name, description, expression);
                        context.AQGs.Add(aqg.Name, aqg);
                        break;
                    case Expression.ExpressionTypeEnum.UQG:
                        var uqg = new UQG(name, description, expression);
                        context.UQGs.Add(uqg.Name, uqg);
                        break;
                    default:
                        throw new NotImplementedException();
                }
            }
        }
        #endregion

        #region Functions
        public static void LoadFunctions()
        {
            _DemoLoader.GlobalContext.Functions.Clear();
            var dirInfo = new DirectoryInfo(Path.Combine(DirPath, "Functions"));
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var func = Function.CreateFunctionFromFile(file.FullName);
                GlobalContext.Functions.Add(func.Name, func);
            }
        }
        #endregion
    }
}
