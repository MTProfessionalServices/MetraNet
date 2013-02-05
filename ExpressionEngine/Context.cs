using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.IO;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// Provides a "context" to the editor so that it knows what's available to the user. A global context is stored in _DemoLoader.GlobalContext.
    /// "sub copies" are created for eachinteractive context.entered a more restricted context. Since the sub copies only have refences (and keys), 
    /// a lot of space isn't consumed.
    /// 
    /// This class has been thrown together to prototype ideas and to support the fat GUI prototype. That said, I believe the general concept has merit.
    /// 
    /// </summary>
    public class Context
    {
        #region Properties
        public readonly Expression Expression;
        public Dictionary<string, Function> Functions = new Dictionary<string, Function>();
        public Dictionary<string, Entity> Entities = new Dictionary<string, Entity>();
        public Dictionary<string, AQG> AQGs = new Dictionary<string, AQG>();
        public Dictionary<string, UQG> UQGs = new Dictionary<string, UQG>();
        public Dictionary<string, Property> Interactions = new Dictionary<string, Property>();
        public Dictionary<string, EnumSpace> EnumSpaces = new Dictionary<string, EnumSpace>();

        //These are updated by UpdateContext()
        public List<EnumType> EnumTypes = new List<EnumType>();
        public List<Property> AllProperties = new List<Property>();
        public Dictionary<string, Property> UniqueProperties = new Dictionary<string, Property>();
        public List<EnumType> RelevantEnums = new List<EnumType>();
        #endregion

        #region Constructors

        public Context()
        {
        }

        public Context(Expression expression)
        {
            Expression = expression;

            foreach (var entity in _DemoLoader.GlobalContext.Entities.Values)
            {
                if (Expression.Info.SupportedEntityTypes.Contains(entity.Type))
                    Entities.Add(entity.Name, entity);
            }

            if (expression.Info.SupportsAqgs)
                AQGs = _DemoLoader.GlobalContext.AQGs;

            if (expression.Info.SupportsUqgs)
                UQGs = _DemoLoader.GlobalContext.UQGs;

            EnumSpaces = _DemoLoader.GlobalContext.EnumSpaces;
            Functions = _DemoLoader.GlobalContext.Functions;

            UpdateContext();
        }
        #endregion

        #region Property Methods

        public List<Property> GetProperties(DataTypeInfo typeFilter, IEnumerable<Entity> entities=null)
        {
            if (entities == null)
                entities = Entities.Values;

            var results = new List<Property>();
            foreach (var entity in entities)
            {
                foreach (var property in entity.Properties)
                {
                    if (property.DataTypeInfo.IsBaseTypeFilterMatch(typeFilter))
                        results.Add(property);
                }
            }
            return results;
        }

        public List<Property> GetProperties(DataTypeInfo dtInfo, DataTypeInfo.MatchType minimumMatchLevel, bool uniqueProperties)
        {
            var properties = new List<Property>();
            IEnumerable<Property> list;

            if (uniqueProperties)
                list = UniqueProperties.Values;
            else
                list = AllProperties;

            foreach (var property in list)
            {
                if (property.DataTypeInfo.IsMatch(dtInfo, minimumMatchLevel))
                    properties.Add(property);
            }
            return properties;
        }

        public bool TryGetPropertyFromAllProperties(string name, out Property result)
        {
            foreach (var property in AllProperties)
            {
                if (property.ToExpression == name)
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
                    var key = property.GetCompatableKey();
                    if (!UniqueProperties.TryGetValue(key, out uniqueProperty))
                        UniqueProperties.Add(key, property);

                    if (property.DataTypeInfo.IsEnum)
                    {
                        EnumType enumType;
                        if (TryGetEnumType(property.DataTypeInfo, out enumType))
                        {
                            if (!RelevantEnums.Contains(enumType))
                                RelevantEnums.Add(enumType);
                        }
                    }
                }
            }

            EnumTypes.Clear();
            RelevantEnums.Clear();
            foreach (var enumSpace in EnumSpaces.Values)
            {
                EnumTypes.AddRange(enumSpace.EnumTypes);
            }
        }
        #endregion

        #region Interactions
        public void AddInteraction(string name, string description, Property.DirectionType direction)
        {
            var prop = new Property(name, new DataTypeInfo(BaseType.Decimal), description);
            prop.Direction = direction;
            Interactions.Add(prop.Name, prop);
        }
        #endregion

        #region Entities
        public void AddEntity(Entity entity)
        {
            Entities.Add(entity.Name, entity);
        }

        public List<Entity> GetEntities(string entityNameFilter, List<Entity.EntityTypeEnum> entityTypeFilter, string propertyNameFilter, DataTypeInfo propertyTypeFilter)
        {
            var results = new List<Entity>();

            Regex entityRegex = string.IsNullOrEmpty(entityNameFilter) ? null : new Regex(entityNameFilter, RegexOptions.IgnoreCase);
            Regex propertyRegex = string.IsNullOrEmpty(propertyNameFilter) ? null : new Regex(propertyNameFilter, RegexOptions.IgnoreCase);

            foreach (var entity in Entities.Values)
            {
                if (entityRegex != null && !entityRegex.IsMatch(entity.Name))
                    continue;
                if (entityTypeFilter != null && !entityTypeFilter.Contains(entity.Type))
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

        public void AddEnum(EnumSpace enumSpace)
        {
            EnumSpaces.Add(enumSpace.Name, enumSpace);
        }

        public bool TryGetEnumType(DataTypeInfo dataType, out EnumType enumType)
        {
            EnumSpace space;
            if (!EnumSpaces.TryGetValue(dataType.EnumSpace, out space))
            {
                enumType = null;
                return false;
            }

            if (!space.TryGetEnumType(dataType.EnumType, out enumType))
            {
                enumType = null;
                return false;
            }

            return true;
        }
        #endregion

    }
}
