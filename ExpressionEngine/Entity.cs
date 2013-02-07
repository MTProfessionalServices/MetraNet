using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// Should this be a sunbclass of Property
    /// </summary>
    public class Entity : IProperty, IExpressionEngineTreeNode
    {
        #region Enums
        public enum EntityTypeEnum {ServiceDefinition, ProductView, ParameterTable, AccountType, AccountView, BME, Any, Metanga}
        #endregion

        #region Properties
        public string Name { get; set; }
        public string NameLocalized;
        public DataTypeInfo DataTypeInfo { get; set; }
        public PropertyCollection Properties;
        public string Description { get; set; }
        public Property.DirectionType Direction { get; set; }
        public string GetCompatableKey() { return string.Format("{0}|{2}", Name, DataTypeInfo.GetCompatableKey()); }

        public string ToolTip
        {
            get
            {
                var tip = DataTypeInfo.EntityType.ToString();
                if (!string.IsNullOrEmpty(Description))
                    tip += "\r\n" + Description;
                return tip;
            }
        }

        public string Image { get { return DataTypeInfo.EntityType.ToString() + ".png"; } }

        public string ImageDirection
        {
            get
            {
                switch (Direction)
                {
                    case Property.DirectionType.InOut:
                        return "EntityInOut.png";
                    case Property.DirectionType.Input:
                        return "EntityInput.png";
                    case Property.DirectionType.Output:
                        return "EntityOutput.png";
                }
                throw new NotImplementedException();
            }
        }
        #endregion

        #region Constructor
        public Entity(string name, EntityTypeEnum type, string description, PropertyCollection properties=null)
        {
            Name = name;
            DataTypeInfo = DataTypeInfo.CreateEntity(type);
            Description = description;
            if (properties != null)
                Properties = properties;
            else
                Properties = new PropertyCollection(this);
        }
        #endregion

        #region Methods
        public bool HasPropertyMatch(Regex nameFilter, DataTypeInfo typeFilter)
        {
            foreach (var property in Properties)
            {
                if (nameFilter != null && !nameFilter.IsMatch(property.Name))
                    continue;
                if (!property.DataTypeInfo.IsBaseTypeFilterMatch(typeFilter))
                    continue;
                return true;
            }
            return false;
        }

        public string ToExpression
        {
            get
            {
                return string.Format("{0}.{1}", GetPrefix(), Name);
            }
        }

        public string GetPrefix()
        {
            switch (DataTypeInfo.EntityType)
            {
                case EntityTypeEnum.ProductView:
                    return Settings.NewSyntax? "EVENT": "USAGE";
                case EntityTypeEnum.AccountView:
                    return "ACCOUNT";
                default:
                    throw new NotImplementedException();
            }
        }
        #endregion

        #region Create Methods
        public static Entity CreateProductView(string name, string description=null)
        {
            return new Entity(name, EntityTypeEnum.ProductView, description);
        }
        #endregion
    }
}
