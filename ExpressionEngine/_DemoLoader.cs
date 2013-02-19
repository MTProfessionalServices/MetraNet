using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Text.RegularExpressions;
using CsvHelper;
using CsvHelper.Configuration;
using Metanga.Miscellaneous.MetadataExport;

namespace MetraTech.ExpressionEngine
{
    //this is a total mess that loads data into the GlobalContext.... needs to replaced with clean data loading
    public static class _DemoLoader
    {
        #region Properties
        public static string DirPath = @"C:\ExpressionEngine";
        public static string TopLevelDataDir = Path.Combine(DirPath, "Data");
        private static string DataPath;
        public static Context GlobalContext;
        #endregion

        #region General
        public static void LoadGlobalContext(Context.ProductTypeEnum product, string subDir)
        {
            GlobalContext = new Context(product);
            DataPath = Path.Combine(TopLevelDataDir, subDir);

            if (Context.ProductType == Context.ProductTypeEnum.MetraNet)
            {
                GlobalContext.AddEntity(_DemoLoader.GetCloudComputeProductView());
                GlobalContext.AddEntity(_DemoLoader.GetCorporateAccountType());
                GlobalContext.AddEntity(_DemoLoader.GetAircraftLandingProductView());
                LoadEntities(GlobalContext, ComplexType.ComplexTypeEnum.ProductView, Path.Combine(DataPath, "ProductViews.csv"));
                LoadEntities(GlobalContext, ComplexType.ComplexTypeEnum.AccountView, Path.Combine(DataPath, "AccountViews.csv"));
                LoadEntities(GlobalContext, ComplexType.ComplexTypeEnum.ServiceDefinition, Path.Combine(DataPath, "ServiceDefinitions.csv"));
                LoadXqg(GlobalContext, Expression.ExpressionTypeEnum.AQG, Path.Combine(DataPath, "AqgExpressions.csv"));
                LoadXqg(GlobalContext, Expression.ExpressionTypeEnum.UQG, Path.Combine(DataPath, "UqgExpressions.csv"));
            }
            else
            {
                LoadEntities(GlobalContext, ComplexType.ComplexTypeEnum.Metanga, Path.Combine(DataPath, "Entities.csv"));
            }

            LoadEnumFile(GlobalContext, Path.Combine(DataPath, "Enums.csv"));
            LoadFunctions();
            LoadExpressions();
            LoadEmailTemplates(GlobalContext, Path.Combine(DataPath, "EmailTemplates"));

            var uomCategory = new UnitOfMeasureCategory("DigitalInformation");
            uomCategory.AddUom("Gb");
            uomCategory.AddUom("Mb");
            uomCategory.AddUom("kb");
            GlobalContext.UoMs.Add(uomCategory.Name, uomCategory);

            uomCategory = new UnitOfMeasureCategory("Time");
            uomCategory.AddUom("Millisecond");
            uomCategory.AddUom("Second");
            uomCategory.AddUom("Minute");
            uomCategory.AddUom("Hour");
            GlobalContext.UoMs.Add(uomCategory.Name, uomCategory);
        }

        private static void _LoadSubEntities(Context context, ComplexType parentEntity, ComplexType childEntity)
        {
            foreach (IProperty property in childEntity.Properties)
            {
                if (property.DataTypeInfo.IsEntity)
                    _LoadSubEntities(context, childEntity, (ComplexType)property);
                else if (parentEntity != null)
                    parentEntity.Properties.Add(property);
            }
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
        public static ComplexType GetCloudComputeProductView()
        {
            var entity = new ComplexType("CloudCompute", ComplexType.ComplexTypeEnum.ProductView, "Models an cloud compute usage even");

            var pv = entity.Properties;

            Property property;

            //Snapshot stuff
            pv.AddInt32("NumSnapshots", "The number of snapshots taken", true);
            property = pv.AddCharge("SnapshotCharge", "The charge assoicated with snapshots", true);
            property.DataTypeInfo.UnitsProperty = "NumSnapshots";
            
            pv.AddString("DataCenter", "The data center in which the server ran", true, null, 30);
            pv.AddEnum("DataCenterCountry", "The country that the data center is located", true, "global", "countryname");
            pv.AddEnum("ChargeModel", "The charinging model used to calculate the compute charge", true, "Cloud", "ChargeModel");
            pv.AddDecimal("InstanceSize", "The size of the instance", true);
            pv.AddEnum("OS", "The Operating System (OS)", true, "Cloud", "OperatingSystem");
            
            property = pv.AddInt32("Memory", "The amount of memory", true);
            property.DataTypeInfo.UomMode = DataTypeInfo.UomModeType.Fixed;
            property.DataTypeInfo.UomQualifier = "DigitalInformation";

            pv.AddDecimal("CpuCount", "The number of million CPU cycles", true);

            property = pv.AddDecimal("Hours", "The number of hours the instance ran", true);
            property.DataTypeInfo.UomMode = DataTypeInfo.UomModeType.Fixed;
            property.DataTypeInfo.UomQualifier = "Hour";

            property = pv.AddDecimal("Duration", "The elapsed time", true);
            property.DataTypeInfo.UomMode = DataTypeInfo.UomModeType.Category;
            property.DataTypeInfo.UomQualifier = "Time";

            property = pv.AddDecimal("ScalingMetric", "The key scaling metric", true);
            property.DataTypeInfo.UomMode = DataTypeInfo.UomModeType.Property;
            property.DataTypeInfo.UomQualifier = "ScalingMetricUom";

            property = pv.AddString("ScalingMetricUom", "The UoM for the the ScalingMetric", true);

            AppendCommonPvProperties(pv);
            return entity;
        }

        public static ComplexType GetAircraftLandingProductView()
        {
            var entity = new ComplexType("AircraftLanding", ComplexType.ComplexTypeEnum.ProductView, "Models an cloud compute usage even");

            var pv = entity.Properties;
            pv.AddInt32("MTOW", "Maximum TakeOff Weight", true);
            pv.AddInt32("AircraftWeight", "The Weight of the aircraft in tons", true);
            pv.AddInt32("NumPassengers", "The Weight of the aircraft in tons", true);
            pv.AddInt32("NumTransferPassengers", "The Weight of the aircraft in tons", true);
            pv.AddInt32("NumCrew", "The Weight of the aircraft in tons", true);
            AppendCommonPvProperties(pv);

            return entity;
        }
        public static void AppendCommonZvProperties(PropertyCollection props)
        {
            props.AddInt32("AccountId", "The account associated with the event", true);
        }
        public static void AppendCommonPvProperties(PropertyCollection props)
        {
            props.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
            props.AddInt32("AccountId", "The account associated with the event", true);

            var name = Settings.NewSyntax ? "EventCharge" : "Amount";
            props.AddCharge(name, "The charge assoicated with the event which may summarize other charges within the event", true);
        }

        public static ComplexType GetCorporateAccountType()
        {
            var entity = new ComplexType("CorporateAccount", ComplexType.ComplexTypeEnum.AccountType, "Models an corporate account");

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

        #region InputsOutputs
        /// <summary>
        /// Just hardcode some things for demo purposes!
        /// </summary>
        /// <param name="exp"></param>
        public static void LoadInputsOutputs(Expression exp)
        {
            var prop = Property.CreateInteger32("USAGE.Hours");
            prop.Direction = Property.DirectionType.InOut;
            exp.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.CpuCount");
            prop.Direction = Property.DirectionType.Input;
            exp.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.Snapshots");
            prop.Direction = Property.DirectionType.Input;
            exp.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.Amount");
            prop.Direction = Property.DirectionType.Input;
            exp.Parameters.Add(prop);

            var entity = ComplexType.CreateProductView("ParameterTable.CloudRates", null);
            prop.Direction = Property.DirectionType.Input;
            exp.Parameters.Add(entity);

            prop = Property.CreateBoolean("<Result>", "The result of the boolean expression");
            prop.Direction = Property.DirectionType.Output;
            exp.Parameters.Add(prop);
        }
        #endregion

        #region File-Based Entities
        public static void LoadEntities(Context context, ComplexType.ComplexTypeEnum entityType, string filePath)
        {
            var entityList = ReadRecordsFromCsv<EntityRecord>(filePath);
            foreach (var entityRecord in entityList)
            {
                var entityParts = entityRecord.EntityName.Split('/');
                var entityNamespace = entityParts[0];
                var entityName = entityParts[1];
                var propName = entityRecord.PropertyName;
                var required = Helper.GetBool(entityRecord.IsRequired);
                var typeStr = entityRecord.PropertyType;
                var enumSpace = entityRecord.Namespace;
                var enumType = entityRecord.EnumType;

                var entityDescription = Helper.CleanUpWhiteSpace(entityRecord.EntityDescription);
                var propertyDescription = Helper.CleanUpWhiteSpace(entityRecord.PropertyDescription);

                ComplexType entity;
                if (!context.Entities.TryGetValue(entityName, out entity))
                {
                    entity = new ComplexType(entityName, entityType, entityDescription);
                    entity.DataTypeInfo.IsEntity = entityRecord.IsEntity;
                    context.Entities.Add(entity.Name, entity);

                    //Add common properties, if any
                    switch (entityType)
                    {
                        case ComplexType.ComplexTypeEnum.ProductView:
                            AppendCommonPvProperties(entity.Properties);
                            break;
                        case ComplexType.ComplexTypeEnum.AccountView:
                            AppendCommonZvProperties(entity.Properties);
                            break;
                    }
                }

                DataTypeInfo dtInfo;
                if (Context.ProductType == Context.ProductTypeEnum.MetraNet)
                {
                    var baseType = DataTypeInfo.PropertyTypeId_BaseTypeMapping[Int32.Parse(typeStr)];
                    dtInfo = new DataTypeInfo(baseType);
                }
                else
                    dtInfo = DataTypeInfo.CreateFromDataTypeString(typeStr);

                switch (dtInfo.BaseType)
                {
                    case BaseType.Enumeration:
                        dtInfo.EnumSpace = enumSpace;
                        dtInfo.EnumType = enumType;
                        break;
                    case BaseType.ComplexType:
                        dtInfo.ComplexType = entityType;
                        dtInfo.ComplexSubtype = enumType; //we overrode the column
                        break;
                }

                if (entityRecord.ListType == null)
                {
                  dtInfo.ListType = DataTypeInfo.ListTypeEnum.None;
                }
                else
                {
                  dtInfo.ListType = (DataTypeInfo.ListTypeEnum)Enum.Parse(typeof(DataTypeInfo.ListTypeEnum), entityRecord.ListType, true);
                }

                var property = new Property(propName, dtInfo, propertyDescription);
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
                try
                {
                    var entityList = csv.GetRecords<T>().ToList();
                    return entityList;
                }
                catch (CsvReaderException e)
                {
                    throw new Exception(string.Format("Error loading {0} line {1} [{2}]", filePath, e.Row, e.Message), e);
                }
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
                    try
                    {
                        id = Int32.Parse(idStr);
                    }
                    catch (FormatException)
                    {
                        id = 0;
                    }
                }

                if (string.IsNullOrWhiteSpace(spaceAndType))
                {
                    continue;
                }

                var enumParts = spaceAndType.Split('/');

                //Namespace?
                if (enumParts.Length == 1)
                    continue;

                var enumType = enumParts[enumParts.Length - 1];
                var enumNamespace = spaceAndType.Substring(0, spaceAndType.Length - enumType.Length - 1); //account for one slash

                var enumValueObj = EnumSpace.AddEnum(context, enumNamespace, enumType, -1, enumValue, id);
                enumValueObj.Description = propertyDescription;
                enumValueObj.EnumType.Description = entityDescription;
            }
        }

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

        #region Emails
        public static void LoadEmailTemplates(Context context, string dirPath)
        {
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
