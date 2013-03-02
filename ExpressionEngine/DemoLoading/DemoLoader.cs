using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using CsvHelper;
using CsvHelper.Configuration;
using Metanga.Miscellaneous.MetadataExport;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Placeholders;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;


namespace MetraTech.ExpressionEngine
{
    //this is a total mess that loads data into the GlobalContext.... needs to replaced with clean data loading
    public static class DemoLoader
    {
        #region Properties
        public const string DirPath = @"C:\ExpressionEngine";
        public static string TopLevelDataDir = Path.Combine(DirPath, "Data");
        private static string DataPath;
        public static Context GlobalContext { get; private set; }
        #endregion

        #region General
        public static void LoadGlobalContext(ProductType product, string subDir)
        {
            GlobalContext = new Context(product);
            DataPath = Path.Combine(TopLevelDataDir, subDir);

            if (Context.ProductType == ProductType.MetraNet)
            {
                GlobalContext = Context.LoadExtensions(Path.Combine(DataPath, "Extensions"));

                //AddCloudComputeProductView();
                //GlobalContext.AddEntity(DemoLoader.GetCorporateAccountType());
                //AddAircraftLandingProductView();
                LoadXqg(GlobalContext, ExpressionType.Aqg, Path.Combine(DataPath, "AqgExpressions.csv"));
                LoadXqg(GlobalContext, ExpressionType.Uqg, Path.Combine(DataPath, "UqgExpressions.csv"));
            }
            else
            {
                //LoadEntities(GlobalContext, null, Path.Combine(DataPath, "Entities.csv"));
                //LoadEnumFile(GlobalContext, Path.Combine(DataPath, "Enums.csv"));
                GlobalContext = Context.LoadMetanga(DataPath);
            }


            LoadFunctions();
            LoadExpressions();
            LoadEmailTemplates(GlobalContext, Path.Combine(DataPath, "EmailTemplates"));
            LoadEmailInstances(GlobalContext, Path.Combine(DataPath, "EmailInstances"));

            //var uomCategory = new UnitOfMeasureCategory("DigitalInformation");
            //uomCategory.AddUnitOfMeasure("Gb", false);
            //uomCategory.AddUnitOfMeasure("Mb", false);
            //uomCategory.AddUnitOfMeasure("kb", false);
            //GlobalContext.UnitOfMeasures.Add(uomCategory.Name, uomCategory);

            //uomCategory = new UnitOfMeasureCategory("Time");
            //uomCategory.AddUnitOfMeasure("Millisecond", false);
            //uomCategory.AddUnitOfMeasure("Second", false);
            //uomCategory.AddUnitOfMeasure("Minute", false);
            //uomCategory.AddUnitOfMeasure("Hour", false);
            //GlobalContext.UnitOfMeasures.Add(uomCategory.Name, uomCategory);
        }

        #endregion

        #region Expressions
        public static void LoadExpressions()
        {
            var dirInfo = new DirectoryInfo(Path.Combine(DataPath, "Expressions"));
            if (!dirInfo.Exists)
                return;

            foreach (var fileInfo in dirInfo.GetFiles("*.xml"))
            {
                var exp = Expression.CreateFromFile(fileInfo.FullName);
                GlobalContext.Expressions.Add(exp.Name, exp);
            }
        }
        #endregion

        #region Manual Entities
        public static void AddCloudComputeProductView()
        {
            var entity = PropertyBagFactory.CreateProductViewEntity("CloudCompute", "Models an cloud compute usage even");

            var pv = entity.Properties;

            Property property;

            //Snapshot stuff
            pv.AddInteger32("NumSnapshots", "The number of snapshots taken", true);
            var charge = pv.AddCharge("SnapshotCharge", "The charge assoicated with snapshots", true);
            //((MoneyType)charge.Type).UnitsProperty = "NumSnapshots";

            pv.AddString("DataCenter", "The data center in which the server ran", true, null, 30);
            pv.AddEnum("DataCenterCountry", "The country that the data center is located", true, "global", "countryname");
            pv.AddEnum("ChargeModel", "The charinging model used to calculate the compute charge", true, "Cloud", "ChargeModel");
            pv.AddDecimal("InstanceSize", "The size of the instance", true);
            pv.AddEnum("OS", "The Operating System (OS)", true, "Cloud", "OperatingSystem");

            var memory = pv.AddInteger32("Memory", "The amount of memory", true);
            ((NumberType)memory.Type).UnitOfMeasureMode =  UnitOfMeasureMode.Fixed;
            ((NumberType)memory.Type).UnitOfMeasureQualifier = "DigitalInformation";

            pv.AddDecimal("CpuCount", "The number of million CPU cycles", true);

            property = pv.AddDecimal("Hours", "The number of hours the instance ran", true);
            ((NumberType)property.Type).UnitOfMeasureMode = UnitOfMeasureMode.Fixed;
            ((NumberType)property.Type).UnitOfMeasureQualifier = "Hour";

            property = pv.AddDecimal("Duration", "The elapsed time", true);
            ((NumberType)property.Type).UnitOfMeasureMode = UnitOfMeasureMode.Category;
            ((NumberType)property.Type).UnitOfMeasureQualifier = "Time";

            property = pv.AddDecimal("ScalingMetric", "The key scaling metric", true);
            ((NumberType)property.Type).UnitOfMeasureMode = UnitOfMeasureMode.Property;
            ((NumberType)property.Type).UnitOfMeasureQualifier = "ScalingMetricUom";

            property = pv.AddString("ScalingMetricUom", "The UoM for the the ScalingMetric", true);

            GlobalContext.AddEntity(entity);
        }

        public static void AddAircraftLandingProductView()
        {
            var entity = PropertyBagFactory.CreateProductViewEntity("AircraftLanding", "Models an cloud compute usage even");

            var pv = entity.Properties;
            pv.AddInteger32("MTOW", "Maximum TakeOff Weight", true);
            pv.AddInteger32("AircraftWeight", "The Weight of the aircraft in tons", true);
            pv.AddInteger32("NumPassengers", "The Weight of the aircraft in tons", true);
            pv.AddInteger32("NumTransferPassengers", "The Weight of the aircraft in tons", true);
            pv.AddInteger32("NumCrew", "The Weight of the aircraft in tons", true);

            GlobalContext.AddEntity(entity);
        }


        public static AccountViewEntity GetCorporateAccountType()
        {
            var entity = PropertyBagFactory.CreateAccountViewEntity("CorporateAccount", "Models an corporate account");

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
        public static void LoadEntities(Context context, string propertyBagTypeName, string filePath)
        {
            if (context == null)
                throw new ArgumentException("context");

            var entityList = ReadRecordsFromCsv<EntityRecord>(filePath);
            foreach (var entityRecord in entityList)
            {
                var entityParts = entityRecord.EntityName.Split('/');
                //var entityNamespace = entityParts[0];
                var entityName = entityParts[1];
                var propName = entityRecord.PropertyName;
                var required = TypeHelper.GetBoolean(entityRecord.IsRequired);
                var typeStr = entityRecord.PropertyType;
                var enumSpace = entityRecord.Namespace;
                var enumType = entityRecord.EnumType;

                var entityDescription = Helper.CleanUpWhiteSpace(entityRecord.EntityDescription);
                var propertyDescription = Helper.CleanUpWhiteSpace(entityRecord.PropertyDescription);

                PropertyBag entity;
                if (!context.Entities.TryGetValue(entityName, out entity))
                {
                    if (Context.ProductType == ProductType.MetraNet)
                        entity = PropertyBagFactory.Create(propertyBagTypeName, entityName, entityDescription);
                    else
                    {
                        //Current CSV doesn't have enough info, they assume all entities aren't expandable
                        var propertyBagMode = entityRecord.IsEntity
                                                  ? PropertyBagMode.Entity
                                                  : PropertyBagMode.PropertyBag;
                        entity = new PropertyBag(entityName, propertyBagTypeName, propertyBagMode, entityDescription);
                    }
                    context.Entities.Add(entity.Name, entity);
                }

                Type type;
                if (Context.ProductType == ProductType.MetraNet)
                {
                    type = TypeFactory.Create(Int32.Parse(typeStr, NumberStyles.Integer));
                }
                else
                    type = TypeFactory.Create(typeStr);

                switch (type.BaseType)
                {
                    case BaseType.Enumeration:
                        var _enumType = (EnumerationType)type;
                        _enumType.Namespace = enumSpace;
                        _enumType.Category = enumType;
                        break;
                    case BaseType.PropertyBag:
                        var propertyBagType = (PropertyBagType)type;
                        propertyBagType.Name = enumType; //we overrode the column
                        break;
                }

                if (entityRecord.ListType == null)
                {
                    type.ListType = ListType.None;
                }
                else
                {
                    type.ListType = (ListType)Enum.Parse(typeof(ListType), entityRecord.ListType, true);
                }

                var property = new Property(propName, type, true, propertyDescription);
                property.Required = required;
                entity.Properties.Add(property);
            }
        }

        private static IEnumerable<T> ReadRecordsFromCsv<T>(string filePath) where T : class
        {
            var configuration = new CsvConfiguration
                                    {
                                        IsStrictMode = false,
                                        HasHeaderRecord = true
                                    };
            using (var streamReader = new StreamReader(filePath))
            {
                var csv = new CsvReader(streamReader, configuration);
                var entityList = csv.GetRecords<T>().ToList();
                return entityList;
            }
        }

        #endregion

        #region Enums
        public static void LoadEnumFile(Context context, string filePath)
        {
            var enumList = ReadRecordsFromCsv<EnumRecord>(filePath);

            foreach (var enumRecord in enumList)
            {
                var enumValue = enumRecord.EnumValue;
                var spaceAndType = enumRecord.Namespace;
                var idStr = enumRecord.EnumDataId;

                var entityDescription = Helper.CleanUpWhiteSpace(enumRecord.EnumDescription);
                var propertyDescription = Helper.CleanUpWhiteSpace(enumRecord.ValueDescription);

                int id;
                if (string.IsNullOrEmpty(idStr))
                    id = 0;
                else
                {
                    if (!Int32.TryParse(idStr, out id))
                        id = 0;
                }

                if (string.IsNullOrWhiteSpace(spaceAndType))
                {
                    continue;
                }

                var enumParts = spaceAndType.Split('/');

                //EnumNamespace?
                if (enumParts.Length == 1)
                    continue;

                var enumType = enumParts[enumParts.Length - 1];
                var enumNamespace = spaceAndType.Substring(0, spaceAndType.Length - enumType.Length - 1); //account for one slash

                var enumValueObj = EnumNamespace.AddEnum(context, enumNamespace, enumType, -1, enumValue, id);
                enumValueObj.Description = propertyDescription;
                enumValueObj.EnumType.Description = entityDescription;
            }
        }

        #endregion

        #region XQGs

        public static void LoadXqg(Context context, ExpressionType type, string filePath)
        {
            if (context == null)
                throw new ArgumentException("context");

            if (!File.Exists(filePath))
                return;

            var lines = File.ReadAllLines(filePath);
            for (int index = 1; index < lines.Length; index++)
            {
                var cols = lines[index].Split(',');
                var name = cols[0];
                var expression = cols[1];
                var description = string.Empty;
                switch (type)
                {
                    case ExpressionType.Aqg:
                        var aqg = new Aqg(name, description, expression);
                        context.Aqgs.Add(aqg.Name, aqg);
                        break;
                    case ExpressionType.Uqg:
                        var uqg = new Uqg(name, description, expression);
                        context.Uqgs.Add(uqg.Name, uqg);
                        break;
                    default:
                        throw new NotImplementedException();
                }
            }
        }
        #endregion

        #region Emails
        public static void LoadEmailInstances(Context context, string dirPath)
        {
            if (context == null)
                throw new ArgumentException("context");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return;
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var emailInstance = EmailInstance.CreateFromFile(file.FullName);
                context.EmailInstances.Add(emailInstance.Name, emailInstance);
            }
        }
        public static void LoadEmailTemplates(Context context, string dirPath)
        {
            if (context == null)
                throw new ArgumentNullException("context");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return;
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var emailTemplate = EmailTemplate.CreateFromFile(file.FullName);
                context.EmailTemplates.Add(emailTemplate.Name, emailTemplate);
            }
        }
        #endregion

        #region Functions
        public static void LoadFunctions()
        {
            DemoLoader.GlobalContext.Functions.Clear();
            var dirInfo = new DirectoryInfo(Path.Combine(DirPath, @"Reference\Functions"));
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var func = Function.CreateFromFile(file.FullName);
                GlobalContext.Functions.Add(func.Name, func);
            }
        }
        #endregion
    }
}
