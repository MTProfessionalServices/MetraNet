using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    public class EnumType : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly EnumSpace Parent;
        public string Name { get; set; }
        public string Description { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EnumType.png"; } }
        public List<EnumValue> Values = new List<EnumValue>();
        #endregion

        #region Constructor
        public EnumType(EnumSpace parent, string name, string description)
        {
            Parent = parent;
            Name = name;
            Description = description;
        }
        #endregion

        #region Methods
        public EnumValue AddValue(string value, int id)
        {
            var enumValue = new EnumValue(this, value, id);
            Values.Add(enumValue);
            return enumValue;
        }

        public string ToExpression
        {
            get
            {
                throw new NotImplementedException();
            }
        }

        public void Save(string dirPath)
        {
            var doc = new XmlDocument();
            var rootNode = doc.AddChildNode("EnumType");
            rootNode.AddChildNode("Name", Name);
            rootNode.AddChildNode("EnumSpace", Parent.Name);
            rootNode.AddChildNode("Description", Description);
            var valuesNode = rootNode.AddChildNode("Values");
            foreach (var value in Values)
            {
                value.WriteXmlNode(valuesNode);
            }
            var enumSpace = Parent.Name.Replace('\\', '_');
            var name = Name.Replace('\\', '_');
            if (enumSpace.Contains(@"\") || name.Contains(@"\"))
                throw new Exception("found backslash");
            doc.SaveFormatted(string.Format(@"{0}\{1}.{2}.EnumType.xml", dirPath, enumSpace, name));
        }
        #endregion
    }
}
