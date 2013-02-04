using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace MetraTech.ExpressionEngine
{
    public class Entity :IExpressionEngineTreeNode
    {
        #region Enums
        public enum EntityTypeEnum {ServiceDefinition, ProductView, ParameterTable, AccountType, AccountView, BME, Any, Metanga}
        #endregion

        #region Properties
        public string Name { get; set; }
        public EntityTypeEnum Type { get; set; }
        public PropertyCollection Properties;
        public string Description { get; set; }

        public string ToolTip
        {
            get
            {
                var tip = Type.ToString();
                if (!string.IsNullOrEmpty(Description))
                    tip += "\r\n" + Description;
                return tip;
            }
        }

        public string Image { get { return Type.ToString() + ".png"; } }
        #endregion

        #region Constructor
        public Entity(string name, EntityTypeEnum type, string description, PropertyCollection properties=null)
        {
            Name = name;
            Type = type;
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
            switch(Type)
            {
                case EntityTypeEnum.ProductView:
                    return Settings.NewSyntax? "EVENT": "USAGE";
                case EntityTypeEnum.AccountType:
                    return "ACCOUNT";
                default:
                    throw new NotImplementedException();
            }
        }
        #endregion
    }
}
