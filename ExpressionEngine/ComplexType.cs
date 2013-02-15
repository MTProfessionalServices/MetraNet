using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// Should this be a sunbclass of Property
    /// </summary>
    public class ComplexType : IProperty, IExpressionEngineTreeNode
    {
        #region Enums
        public enum ComplexTypeEnum {ServiceDefinition, ProductView, ParameterTable, AccountType, AccountView, BME, Any, Metanga}
        #endregion

        #region Properties
        public string Name { get; set; }
        public string NameLocalized;
        public bool Required { get; set; }
        public DataTypeInfo DataTypeInfo { get; set; }
        public PropertyCollection Properties;

        public ComplexType ParentEntity { get; set; }
        public string Description { get; set; }
        public Property.DirectionType Direction { get; set; }
        public string GetCompatableKey() { return string.Format("{0}|{2}", Name, DataTypeInfo.GetCompatableKey()); }

        public string DbTableName
        {
            get
            {
                switch (DataTypeInfo.ComplexType)
                {
                    case ComplexTypeEnum.AccountView:
                        return "t_av_" + Name;
                    case ComplexTypeEnum.ParameterTable:
                        return "t_av_" + Name;
                    default:
                        return Name;
                }
            }
        }

        public string ToolTip
        {
            get
            {
                var tip = DataTypeInfo.ComplexType.ToString();
                if (!string.IsNullOrEmpty(Description))
                    tip += "\r\n" + Description;
                return tip;
            }
        }

        public string Image
        {
            get
            {

                if (DataTypeInfo.ComplexType == ComplexTypeEnum.Metanga)
                {
                    if (DataTypeInfo.IsEntity)
                        return "Entity.png";
                    else
                        return "ComplextType.png";
                }

                return DataTypeInfo.ComplexType.ToString() + ".png";
            }
        }


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

        public ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages = null)
        {
            if (messages == null)
                messages = new ValidationMessageCollection();

            var prefix = string.Format(Localization.PropertyMessagePrefix, Name);

            //if (NameRegex.IsMatch(Name))
            //    messages.Error(prefix + Localization.InvalidName);

            DataTypeInfo.Validate(prefix, messages);

            foreach (var property in Properties)
            {
                property.Validate(prefixMsg, messages);
            }

            return messages;
        }
        #endregion

        #region Constructor
        public ComplexType(string name, ComplexTypeEnum type, string description, PropertyCollection properties=null)
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
            switch (DataTypeInfo.ComplexType)
            {
                case ComplexTypeEnum.ProductView:
                    return Settings.NewSyntax? "EVENT": "USAGE";
                case ComplexTypeEnum.AccountView:
                    return "ACCOUNT";
                default:
                    return String.Empty;
                    //throw new NotImplementedException();
            }
        }

        public object Clone()
        {
            var newEntity = new ComplexType(Name, DataTypeInfo.ComplexType, Description);
            newEntity.Properties = Properties.Clone();
            return newEntity;
        }

        public void Save(string filePath)
        {
            var doc = new XmlDocument();
            var entityNode = doc.AddChildNode("Entity");
            entityNode.AddChildNode("Name", Name);
            entityNode.AddChildNode("Type", DataTypeInfo.ComplexType.ToString());
            entityNode.AddChildNode("Description", Description);
            Properties.WriteXmlNode(entityNode);
            doc.SaveFormatted(filePath);
        }

        public void WriteXmlNode(XmlNode parentNode, string propertyNodeName="Property")
        {
            var propertyNode = parentNode.AddChildNode(propertyNodeName);
            propertyNode.AddChildNode("Name", Name);
            DataTypeInfo.WriteXmlNode(propertyNode);
            propertyNode.AddChildNode("Required", Required);
            propertyNode.AddChildNode("Description", Description);
        }

        #endregion

        #region Create Methods
        public static ComplexType CreateProductView(string name, string description=null)
        {
            return new ComplexType(name, ComplexTypeEnum.ProductView, description);
        }
        #endregion
    }
}
