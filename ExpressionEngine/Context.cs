using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
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
    /// <summary>
    /// Provides a "context" to the editor so that it knows what's available to the user. A global context is stored in _DemoLoader.GlobalContext.
    /// "sub copies" are created for eachinteractive context.entered a more restricted context. Since the sub copies only have refences (and keys), 
    /// a lot of space isn't consumed.
    /// 
    /// This class has been thrown together to prototype ideas and to support the GUI prototype. That said, I believe the general concept has merit.
    /// 
    /// </summary>
    public class Context
    {
        #region Properties
        public static ProductType ProductType { get; private set; }
        public static bool IsMetraNet { get { return ProductType == ProductType.MetraNet; } }
        public static bool IsMetanga { get { return ProductType == ProductType.Metanga; } }

        /// <summary>
        /// All expressions
        /// </summary>
        public Expression Expression { get; private set; }

        /// <summary>
        /// All EmailInstances
        /// </summary>
        public EmailInstance EmailInstance { get; private set; }

        /// <summary>
        /// All Functions
        /// </summary>
        public Dictionary<string, Function> Functions { get { return _functions; } }
        private readonly Dictionary<string, Function> _functions = new Dictionary<string, Function>(StringComparer.InvariantCultureIgnoreCase);

        //Entities may not have unique names across types... need to deal with that, perhaps a composite key
        public Dictionary<string, PropertyBag> Entities { get { return _entities; } }
        private readonly Dictionary<string, PropertyBag> _entities = new Dictionary<string, PropertyBag>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// All Account Qualification Groups
        /// </summary>
        public Dictionary<string, Aqg> Aqgs { get { return _aqgs; } }
        private Dictionary<string, Aqg> _aqgs = new Dictionary<string, Aqg>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// All UsageQualificationGroups
        /// </summary>
        public Dictionary<string, Uqg> Uqgs { get { return _uqgs; } }
        private Dictionary<string, Uqg> _uqgs = new Dictionary<string, Uqg>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// All EnumerationNamespaces
        /// </summary>
        public Dictionary<string, EnumNamespace> EnumNamespaces { get { return _enumNamespaces; } }
        private Dictionary<string, EnumNamespace> _enumNamespaces = new Dictionary<string, EnumNamespace>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// All expressions
        /// </summary>
        public Dictionary<string, Expression> Expressions { get { return _expressions; } }
        private Dictionary<string, Expression> _expressions = new Dictionary<string, Expression>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// All units of measure
        /// </summary>
        public Dictionary<string, UnitOfMeasureCategory> UnitOfMeasures { get { return _unitOfMeasures; } }
        private Dictionary<string, UnitOfMeasureCategory> _unitOfMeasures = new Dictionary<string, UnitOfMeasureCategory>(StringComparer.InvariantCultureIgnoreCase);

        public Dictionary<string, EmailTemplate> EmailTemplates { get { return _emailTemplates; } }
        private Dictionary<string, EmailTemplate> _emailTemplates = new Dictionary<string, EmailTemplate>(StringComparer.InvariantCultureIgnoreCase);

        public Dictionary<string, EmailInstance> EmailInstances { get { return _emailInstances; }}
        private Dictionary<string, EmailInstance> _emailInstances = new Dictionary<string, EmailInstance>(StringComparer.InvariantCultureIgnoreCase);
        #endregion

        #region Properties that are updated by UpdateContext()
        //These are updated by UpdateContext()
        public List<EnumCategory> EnumCategories { get { return _enumCategories; } }
        private List<EnumCategory> _enumCategories = new List<EnumCategory>();


        public List<Property> AllProperties { get { return _allProperties; } }
        private List<Property> _allProperties = new List<Property>();

        public Dictionary<string, Property> UniqueProperties { get { return _uniqueProperties; } }
        private Dictionary<string, Property> _uniqueProperties = new Dictionary<string, Property>(StringComparer.InvariantCultureIgnoreCase);

        public List<EnumCategory> RelevantEnums { get { return _relevantEnums; } }
        private List<EnumCategory> _relevantEnums = new List<EnumCategory>();
        #endregion

        #region Constructors

        public Context(ProductType product)
        {
            ProductType = product;
        }

        public Context(Expression expression)
            : this(expression, null)
        {
        }
        public Context(Expression expression, EmailInstance emailInstance)
        {
            if (expression == null)
                throw new ArgumentNullException("expression");

            Expression = expression;
            EmailInstance = emailInstance;

            foreach (var entity in DemoLoader.GlobalContext.Entities.Values)
            {
                if (Expression.Info.SupportedEntityTypes.Contains(((PropertyBagType)entity.Type).Name))
                    Entities.Add(entity.Name, entity);
            }

            foreach (var entityParameterName in Expression.EntityParameters)
            {
                PropertyBag propertyBag;
                if (DemoLoader.GlobalContext.Entities.TryGetValue(entityParameterName, out propertyBag))
                {
                    if (!Entities.ContainsKey(propertyBag.Name))
                        Entities.Add(propertyBag.Name, propertyBag);
                }
            }

            if (expression.Info.SupportsAqgs)
                _aqgs = DemoLoader.GlobalContext.Aqgs;

            if (expression.Info.SupportsUqgs)
                _uqgs = DemoLoader.GlobalContext.Uqgs;

            _enumNamespaces = DemoLoader.GlobalContext.EnumNamespaces;
            _functions = DemoLoader.GlobalContext.Functions;
            _unitOfMeasures = DemoLoader.GlobalContext.UnitOfMeasures;

            UpdateContext();
        }
        #endregion

        public ExpressionParseResults GetExpressionParseResults()
        {
            ExpressionParseResults results;
            if (Expression.Type == ExpressionType.Email)
                results = EmailInstance.Parse();
            else
                results = Expression.Parse();

            results.BindResultsToContext(this);
            return results;
        }

        /// <summary>
        /// Searches for a property with the specified name. If not found, null is returned. Order N search. 
        /// </summary>
        public Property GetRecursive(string name)
        {
            if (string.IsNullOrEmpty(name))
                return null;

            return _getRecursive(name, (IEnumerable<Property>)Entities.Values);
        }

        private Property _getRecursive(string name, IEnumerable<Property> properties)
        {
            if (name == null)
                throw new ArgumentException("name==null");
            if (name == null || properties == null)
                throw new ArgumentException("properties==null");

            var parts = name.Split('.');
            var firstName = parts[0];

            foreach (var property in properties)
            {
                if (firstName == property.Name)
                {
                    //If the length is one, then we're at the leaf!
                    if (parts.Length == 1)
                        return property;

                    //We're not there yet, it should be ComplexType

                    if (property.Type.BaseType != BaseType.PropertyBag)
                        return null;

                    //Get the complex property
                    var secondProperty = ((PropertyBag)property).Properties.Get(parts[1]);
                    if (secondProperty == null)
                        return null;

                    if (secondProperty.Type.BaseType != BaseType.PropertyBag && parts.Length == 2)
                        return secondProperty;

                    //var secondName = parts[1];
                    var propertyBagTypeName = ((PropertyBagType)secondProperty.Type).Name;
                    if (propertyBagTypeName == null)
                        return null;

                    PropertyBag complexType;
                    if (!DemoLoader.GlobalContext.Entities.TryGetValue(propertyBagTypeName, out complexType))
                        return null;

                    if (parts.Length == 2)
                        return complexType;

                    var remainder = name.Substring(firstName.Length + parts[1].Length + 2);
                    return _getRecursive(remainder, complexType.Properties);
                }
            }
            return null;
        }

        #region Property Methods

        public List<Property> GetProperties(Type typeFilter, IEnumerable<PropertyBag> entities = null)
        {
            if (entities == null)
                entities = Entities.Values;

            var results = new List<Property>();
            foreach (var entity in entities)
            {
                foreach (var property in entity.Properties)
                {
                    if (property.Type.IsBaseTypeFilterMatch(typeFilter))
                        results.Add(property);
                }
            }
            return results;
        }

        public List<Property> GetProperties(Type dtInfo, MatchType minimumMatchLevel, bool uniqueProperties)
        {
            var properties = new List<Property>();
            IEnumerable<Property> list;

            if (uniqueProperties)
                list = UniqueProperties.Values;
            else
                list = AllProperties;

            foreach (var property in list)
            {
                if (property.Type.IsMatch(dtInfo, minimumMatchLevel))
                    properties.Add(property);
            }
            return properties;
        }

        public bool TryGetPropertyFromAllProperties(string name, out Property result)
        {
            foreach (var property in AllProperties)
            {
                if (property.Name == name)
                {
                    result = property;
                    return true;
                }
            }
            result = null;
            return false;
        }

        #endregion

        #region Methods

        public void UpdateContext()
        {
            AllProperties.Clear();
            UniqueProperties.Clear();
            RelevantEnums.Clear();
            foreach (var entity in Entities.Values)
            {
                foreach (var property in entity.Properties)
                {
                    AllProperties.Add(property);

                    Property uniqueProperty;
                    var key = property.CompatibleKey;
                    if (!UniqueProperties.TryGetValue(key, out uniqueProperty))
                        UniqueProperties.Add(key, property);

                    if (property.Type.IsEnum)
                    {
                        EnumCategory enumType;
                        if (TryGetEnumType((EnumerationType)property.Type, out enumType))
                        {
                            if (!RelevantEnums.Contains(enumType))
                                RelevantEnums.Add(enumType);
                        }
                    }
                }
            }

            EnumCategories.Clear();
            RelevantEnums.Clear();
            foreach (var enumSpace in EnumNamespaces.Values)
            {
                EnumCategories.AddRange(enumSpace.Categories);
            }
        }

        #endregion

        #region Entities
        public void AddEntity(PropertyBag entity)
        {
            if (entity == null)
                throw new ArgumentNullException("entity");

            Entities.Add(entity.Name, entity);
        }

        public List<PropertyBag> GetEntities(string type)
        {
            var types = new List<string>();
            types.Add(type);
            return GetEntities(null, types, null, null);
        }

        public List<PropertyBag> GetEntities(string entityNameFilter, List<string> entityTypeFilter, string propertyNameFilter, Type propertyTypeFilter)
        {
            var results = new List<PropertyBag>();

            Regex entityRegex = string.IsNullOrEmpty(entityNameFilter) ? null : new Regex(entityNameFilter, RegexOptions.IgnoreCase);
            Regex propertyRegex = string.IsNullOrEmpty(propertyNameFilter) ? null : new Regex(propertyNameFilter, RegexOptions.IgnoreCase);

            foreach (var entity in Entities.Values)
            {
                if (entityRegex != null && !entityRegex.IsMatch(entity.Name))
                    continue;
                if (entityTypeFilter != null && !entityTypeFilter.Contains(PropertyBagConstants.AnyFilter) && !entityTypeFilter.Contains( ((PropertyBagType)entity.Type).Name) )
                    continue;

                if (!entity.HasPropertyMatch(propertyRegex, propertyTypeFilter))
                    continue;

                results.Add(entity);
            }
            return results;
        }
        #endregion

        #region Functions
        public Function TryGetFunction(string name)
        {
            Function func;
            Functions.TryGetValue(name, out func);
            return func;
        }
        public Function AddFunction(string name, string category, string description)
        {
            var function = new Function(name, category, description);
            Functions.Add(function.Name, function);
            return function;
        }

        /// <summary>
        /// Returns a unique list of function categories
        /// </summary>
        public List<string> GetFunctionCategories(bool includeAllChoice)
        {
            var categories = new List<string>();
            if (includeAllChoice)
                categories.Add(Localization.AllChoice);
            foreach (var func in Functions.Values)
            {
                if (!categories.Contains(func.Category))
                    categories.Add(func.Category);
            }
            return categories;
        }
        #endregion

        #region Enums

        public void AddEnum(EnumNamespace enumSpace)
        {
            if (enumSpace == null)
                throw new ArgumentNullException("enumSpace");

            EnumNamespaces.Add(enumSpace.Name, enumSpace);
        }

        public bool TryGetEnumType(EnumerationType enumerationType, out EnumCategory enumCategory)
        {
            if (enumerationType == null)
                throw new ArgumentNullException("enumerationType");

            EnumNamespace enumNamespace;
            if (!EnumNamespaces.TryGetValue(enumerationType.Namespace, out enumNamespace))
            {
                enumCategory = null;
                return false;
            }

            if (!enumNamespace.TryGetEnumType(enumerationType.Category, out enumCategory))
            {
                enumCategory = null;
                return false;
            }

            return true;
        }
        #endregion

        #region IO Methods

        /// <summary>
        /// This is used to test things and for prototype assumes MetraNet mode... not applicable in real world
        /// </summary>
        /// <param name="dirPath"></param>
        public void Save(string dirPath)
        {
            dirPath.EnsureDirectoryExits();

            foreach (var enumNamespace in EnumNamespaces.Values)
            {
                enumNamespace.Extension = "Scott";
                enumNamespace.SaveInExtension(dirPath);
            }

            foreach (var propertyBag in Entities.Values)
            {
                var pb = (MetraNetEntityBase) propertyBag;
                pb.Extension = "Scott";
                pb.SaveInExtensionsDirectory(dirPath);
            }

        }

        public static Context LoadExtensions(string extensionsDir)
        {
            var dirInfo = new DirectoryInfo(extensionsDir);
            if (!dirInfo.Exists)
                throw new ArgumentException("extensionsDir doesn't exist: " + extensionsDir);

            var context = new Context(ProductType.MetraNet);
            foreach (var extensionDirInfo in dirInfo.GetDirectories())
            {
                LoadExtension(context, extensionDirInfo);
            }
            context.LoadUnitsOfMeasure();
            return context;
        }

        public static void LoadExtension(Context context, DirectoryInfo extensionDir)
        {
            if (extensionDir == null)
                throw new ArgumentException("extensionDir");
            if (!extensionDir.Exists)
                throw new ArgumentException("extensionDir doesn't exist: " + extensionDir);

            var configDirInfo = new DirectoryInfo(Path.Combine(extensionDir.FullName, "Config"));
            if (!configDirInfo.Exists)
                return;

            EnumNamespace.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "Enumerations"), extensionDir.Name, context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "AccountViews"), "AccountView", context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "ProductViews"), "ProductView", context);
        }
        
        public static Context LoadMetanga(string dirPath)
        {
            var context = new Context(ProductType.Metanga);
            EnumNamespace.LoadDirectoryIntoContext(Path.Combine(dirPath, "EnumCategories"), null, context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(dirPath, "PropertyBags"), null, context);
            context.LoadUnitsOfMeasure();
            return context;
        }

        private void LoadUnitsOfMeasure()
        {
            EnumNamespace.LoadDirectoryIntoContext(@"C:\ExpressionEngine\Reference\Enumerations", null, this);
        }
        #endregion

    }
}
