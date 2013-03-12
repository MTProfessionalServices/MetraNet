using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
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
using MetraTech.ExpressionEngine.Validations;
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
        public ProductType ProductType { get; private set; }
        public bool IsMetraNet { get { return ProductType == ProductType.MetraNet; } }
        public bool IsMetanga { get { return ProductType == ProductType.Metanga; } }

        public Context MasterContext { get; set; }

        /// <summary>
        /// Contains any messages that were generated during the load (from file or database)
        /// </summary>
        public ValidationMessageCollection DeserilizationMessages { get; private set; }

        /// <summary>
        /// All expressions
        /// </summary>
        public Expression Expression { get; private set; }

        /// <summary>
        /// All EmailInstances
        /// </summary>
        public EmailInstance EmailInstance { get; private set; }

        /// <summary>
        /// All enumeration categories
        /// </summary>
        public IEnumerable<EnumCategory> EnumCategories { get { return _enumCategories.Values; } }
        private Dictionary<string, EnumCategory> _enumCategories = new Dictionary<string, EnumCategory>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// All Functions
        /// </summary>
        public IEnumerable<Function> Functions { get { return _functions.Values; } }
        private readonly Dictionary<string, Function> _functions = new Dictionary<string, Function>(StringComparer.InvariantCultureIgnoreCase);

        //PropertyBags may not have unique names across types... need to deal with that, perhaps a composite key       
        public IEnumerable<PropertyBag> PropertyBags { get { return _propertyBags.Values; } }
        private readonly Dictionary<string, PropertyBag> _propertyBags = new Dictionary<string, PropertyBag>(StringComparer.InvariantCultureIgnoreCase);

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
        /// All Namespaces
        /// </summary>
        //public IEnumerable<Namespace> EnumNamespaces { get { return _enumNamespaces; } }
        //private Dictionary<string, EnumNamespace> _enumNamespaces = new Dictionary<string, EnumNamespace>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// All expressions
        /// </summary>
        public Dictionary<string, Expression> Expressions { get { return _expressions; } }
        private Dictionary<string, Expression> _expressions = new Dictionary<string, Expression>(StringComparer.InvariantCultureIgnoreCase);

        public Dictionary<string, EmailTemplate> EmailTemplates { get { return _emailTemplates; } }
        private Dictionary<string, EmailTemplate> _emailTemplates = new Dictionary<string, EmailTemplate>(StringComparer.InvariantCultureIgnoreCase);

        public Dictionary<string, EmailInstance> EmailInstances { get { return _emailInstances; }}
        private Dictionary<string, EmailInstance> _emailInstances = new Dictionary<string, EmailInstance>(StringComparer.InvariantCultureIgnoreCase);

        public Dictionary<string, PageLayout> PageLayouts { get { return _pageLayouts; } }
        private Dictionary<string, PageLayout> _pageLayouts = new Dictionary<string, PageLayout>(StringComparer.InvariantCultureIgnoreCase);
                    
        #endregion

        #region Properties that are updated by UpdateContext()
        //These are updated by UpdateContext()

        public List<Property> AllProperties { get { return _allProperties; } }
        private List<Property> _allProperties = new List<Property>();

        public Dictionary<string, Property> UniqueProperties { get { return _uniqueProperties; } }
        private Dictionary<string, Property> _uniqueProperties = new Dictionary<string, Property>(StringComparer.InvariantCultureIgnoreCase);

        public List<EnumCategory> RelevantEnums { get { return _relevantEnums; } }
        private List<EnumCategory> _relevantEnums = new List<EnumCategory>();

        public List<string> Extensions { get { return _extensions; } }
        private List<string> _extensions = new List<string>();

        public List<string> Namespaces { get { return _namespaces; } } 
        private List<string> _namespaces = new List<string>(); 
        #endregion

        #region Constructors

        public Context(ProductType product)
        {
            ProductType = product;
            DeserilizationMessages = new ValidationMessageCollection();
        }

        public Context(Context masterContext, Expression expression)
            : this(masterContext, expression, null)
        {
        }
        public Context(Context masterContext, Expression expression, EmailInstance emailInstance)
        {
            if (masterContext == null)
                throw new ArgumentException("masterContext is null");

            MasterContext = masterContext;
            ProductType = masterContext.ProductType;
            if (expression == null)
                throw new ArgumentNullException("expression");

            Expression = expression;
            EmailInstance = emailInstance;
            
            //Add property bag types that are genericall supported by the expression
            foreach (var propertyBag in masterContext.PropertyBags)
            {
                if (Expression.Info.SupportedEntityTypes.Contains(((PropertyBagType)propertyBag.Type).Name))
                    AddPropertyBag(propertyBag);
            }

            //Add entities that are specific parameters
            foreach (var entityParameterName in Expression.EntityParameters)
            {
                var masterPropertyBag = masterContext.GetPropertyBag(entityParameterName);
                if (masterPropertyBag != null)
                {
                    var thisPropertyBag = GetPropertyBag(entityParameterName);
                    if (thisPropertyBag == null)
                        AddPropertyBag(masterPropertyBag);
                }
            }

            if (expression.Info.SupportsAqgs)
                _aqgs = masterContext.Aqgs;

            if (expression.Info.SupportsUqgs)
                _uqgs = masterContext.Uqgs;

            _enumCategories = masterContext._enumCategories;
            _functions = masterContext._functions;

            UpdateContext();
        }
        #endregion

        #region Expression Methods
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
        #endregion

        #region Property Methods
        /// <summary>
        /// Searches for a property with the specified name. If not found, null is returned. Order N search. 
        /// </summary>
        public Property GetRecursive(string name)
        {
            if (string.IsNullOrEmpty(name))
                return null;

            return _getRecursive(name, (IEnumerable<Property>)PropertyBags);
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

                    var propertyBag = MasterContext.GetPropertyBag(propertyBagTypeName);
                    if (propertyBag == null)
                        return null;

                    if (parts.Length == 2)
                        return propertyBag;

                    var remainder = name.Substring(firstName.Length + parts[1].Length + 2);
                    return _getRecursive(remainder, propertyBag.Properties);
                }
            }
            return null;
        }


        public List<Property> GetProperties(Type typeFilter, IEnumerable<PropertyBag> entities = null)
        {
            if (entities == null)
                entities = PropertyBags;

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
            foreach (var propertyBag in PropertyBags)
            {
                foreach (var property in propertyBag.Properties)
                {
                    AllProperties.Add(property);

                    Property uniqueProperty;
                    var key = property.CompatibleKey;
                    if (!UniqueProperties.TryGetValue(key, out uniqueProperty))
                        UniqueProperties.Add(key, property);

                    if (property.Type.IsEnum)
                    {
                        var enumCategory = GetEnumCategory((EnumerationType) property.Type);
                        if (enumCategory != null)
                        {
                            if (!RelevantEnums.Contains(enumCategory))
                                RelevantEnums.Add(enumCategory);
                        }
                    }
                }
            }

            _namespaces.Clear();

            //RelevantEnums.Clear();
            //foreach (var enumSpace in EnumNamespaces.Values)
            //{
            //    if (!string.IsNullOrEmpty(enumSpace.Name) && !_namespaces.Contains(enumSpace.Name))
            //        _namespaces.Add(enumSpace.Name);
            //    EnumCategories.AddRange(enumSpace.Categories);

            //}

            //Find all of the extensions and namespaces
            _extensions.Clear();
            foreach (var propertyBag in PropertyBags)
            {
                if (propertyBag is MetraNetEntityBase)
                {
                //    var propertyBag = (MetraNetPropertyBase) propertyBag;
                //    if (!_extensions.Contains(propertyBag.Extension))

                    if (!string.IsNullOrEmpty(propertyBag.Namespace) && !_namespaces.Contains(propertyBag.Name))
                        _namespaces.Add(propertyBag.Namespace);
                }          
            }
        }

        public ValidationMessageCollection Validate()
        {
            var messages = new ValidationMessageCollection();
            foreach (var propertyBag in PropertyBags)
            {
                propertyBag.Validate(true, messages, this);
            }

            //foreach (var enumNamespace in EnumNamespaces.Values)
            //{
            //    enumNamespace.Validate();
            //}
            return messages;
        }


        //public PropertyCollection GetAvailability(List<string> propertyBagTypeNames)
        //{
        //    //Let's assume that all data types match for now
        //    //Let's not worry aabout if entites aren't found

        //    var existingProperties = new Dictionary<string, int>(StringComparer.InvariantCultureIgnoreCase);
        //    var properties = new PropertyCollection(null);

        //    foreach (var propertyBag in PropertyBags.Values)
        //    {
        //        foreach (var propertyBagTypeName in propertyBagTypeNames)
        //        {
        //            var type = (PropertyBagType) propertyBag.Type;
        //            if (!type.Name.Equals(propertyBagTypeName, StringComparison.InvariantCultureIgnoreCase)
        //            continue;

        //            foreach (var property in propertyBag.Properties)
        //            {
        //                Property existingProperty;
        //                if (!existingProperties.TryGetValue(property.Name, out existingProperty))
        //                {
        //                    existingProperties.Add(property.Name, 1);
        //                    properties.Add(property);
        //                }
        //                else
        //                {
        //                    existingProperty.Value++
        //                }
            
        //    }

        //    return properties;
        //}
        #endregion

        #region PropertyBags
        public void AddPropertyBag(PropertyBag propertyBag)
        {
            if (propertyBag == null)
                throw new ArgumentNullException("propertyBag");

            if (_propertyBags.ContainsKey(propertyBag.FullName))
                throw new Exception(string.Format(CultureInfo.CurrentCulture, "Duplicate PropertyBag '{0}'", propertyBag.FullName));

            _propertyBags.Add(propertyBag.FullName, propertyBag);
        }

        public PropertyBag GetPropertyBag(string fullName)
        {
            if (string.IsNullOrEmpty(fullName))
                return null;

            PropertyBag propertyBag;
            _propertyBags.TryGetValue(fullName, out propertyBag);
            return propertyBag;
        }

        public List<PropertyBag> GetPropertyBags(string type)
        {
            var types = new List<string>();
            types.Add(type);
            return GetPropertyBags(null, types, null, null);
        }

        public List<PropertyBag> GetPropertyBags(string propertyBagNameFilter, List<string> propertyBagTypeFilter, string propertyNameFilter, Type propertyTypeFilter)
        {
            var results = new List<PropertyBag>();

            Regex entityRegex = string.IsNullOrEmpty(propertyBagNameFilter) ? null : new Regex(propertyBagNameFilter, RegexOptions.IgnoreCase);
            Regex propertyRegex = string.IsNullOrEmpty(propertyNameFilter) ? null : new Regex(propertyNameFilter, RegexOptions.IgnoreCase);

            foreach (var entity in PropertyBags)
            {
                if (entityRegex != null && !entityRegex.IsMatch(entity.Name))
                    continue;
                if (propertyBagTypeFilter != null && !propertyBagTypeFilter.Contains(PropertyBagConstants.AnyFilter) && !propertyBagTypeFilter.Contains( ((PropertyBagType)entity.Type).Name) )
                    continue;

                if (!entity.HasPropertyMatch(propertyRegex, propertyTypeFilter))
                    continue;

                results.Add(entity);
            }
            return results;
        }

        public List<string> GetPropertyBagTypes()
        {
            var types = new List<string>();
            foreach (var propertyBag in PropertyBags)
            {
                var pbType = (PropertyBagType) propertyBag.Type;
                if (!types.Contains(pbType.Name))
                    types.Add(pbType.Name);
            }
            return types;
        }
        #endregion

        #region Functions
        public Function GetFunction(string name)
        {
            if (string.IsNullOrEmpty(name))
                return null;

            Function function;
           _functions.TryGetValue(name, out function);
            return function;
        }

        public void AddFunction(Function function)
        {
            _functions.Add(function.Name, function);
        }

      

        /// <summary>
        /// Returns a unique list of function categories
        /// </summary>
        public List<string> GetFunctionCategories(bool includeAllChoice)
        {
            var categories = new List<string>();
            if (includeAllChoice)
                categories.Add(Localization.AllChoice);
            foreach (var func in Functions)
            {
                if (!categories.Contains(func.Category))
                    categories.Add(func.Category);
            }
            return categories;
        }
        #endregion

        #region Enums
   
        public void AddEnumCategory(EnumCategory enumCategory)
        {
            if (enumCategory == null)
                throw new ArgumentException("enumCategory is null");

            if (_enumCategories.ContainsKey(enumCategory.FullName))
                throw new Exception(string.Format(CultureInfo.InvariantCulture, "Duplicate EnumCategory '{0}'",enumCategory.FullName));
            
            _enumCategories.Add(enumCategory.FullName, enumCategory);
        }
        public EnumCategory GetEnumCategory(string categoryFullName)
        {
            if (string.IsNullOrEmpty(categoryFullName))
                return null;

            EnumCategory enumCategory;
            if (!_enumCategories.TryGetValue(categoryFullName, out enumCategory))
                return null;
            return enumCategory; 
        }
        public EnumCategory GetEnumCategory(EnumerationType enumerationType)
        {
            if (enumerationType == null)
                throw new ArgumentException("enumerationType is null");
            return GetEnumCategory(enumerationType.Category);
        }
        #endregion

        #region XQGs
        #endregion

        #region IO Methods

        /// <summary>
        /// Saves enums and enities to dirPath
        /// </summary>
        /// <param name="dirPath"></param>
        public void Save(string dirPath)
        {
            dirPath.EnsureDirectoryExits();

            foreach (var enumCategory in EnumCategories)
            {
                if (IsMetraNet)
                    enumCategory.SaveInExtension(dirPath);
                else
                    enumCategory.Save(Path.Combine(dirPath, "Enumerations"));
            }

            foreach (var propertyBag in PropertyBags)
            {
                if (IsMetraNet)
                    ((MetraNetEntityBase) propertyBag).SaveInExtensionsDirectory(dirPath);
                else
                    propertyBag.Save(string.Format(CultureInfo.InvariantCulture, @"{0}\PropertyBags\{1}.xml", dirPath, propertyBag.Name));
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

            context.UpdateContext();
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

            EnumCategory.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "Enumerations"), extensionDir.Name, context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "AccountViews"), "AccountView", context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "ProductViews"), "ProductView", context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "ParameterTables"), "ParameterTable", context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(configDirInfo.FullName, "ParameterTables"), "ParameterTable", context);
        }
        
        public static Context LoadMetanga(string dirPath)
        {
            var context = new Context(ProductType.Metanga);
            EnumCategory.LoadDirectoryIntoContext(Path.Combine(dirPath, "EnumCategories"), null, context);
            PropertyBagFactory.LoadDirectoryIntoContext(Path.Combine(dirPath, "PropertyBags"), null, context);
            context.LoadUnitsOfMeasure();
            return context;
        }

        public void LoadPageLayouts()
        {
            var pageLayout = new PageLayout("Sample", "Just a sample page layout.");
            PageLayouts.Add(pageLayout.Name, pageLayout);
        }

        private void LoadUnitsOfMeasure()
        {
            EnumCategory.LoadDirectoryIntoContext(@"C:\ExpressionEngine\Reference\Enumerations", null, this);
        }
        #endregion

    }
}

