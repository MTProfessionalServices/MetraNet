using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    public class EnumSpace : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string Description { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EnumSpace.png"; } }
        public List<EnumType> EnumTypes = new List<EnumType>();
        #endregion

        #region Constructor
        public EnumSpace(string name, string description)
        {
            Name = name;
            Description = description;
        }
        #endregion

        #region Methods

        public EnumType AddType(string name, string description)
        {
            var type = new EnumType(this, name, description);
            EnumTypes.Add(type);
            return type;
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
            var rootNode = doc.AddChildNode("EnumSpace");

            var name = Name.Replace('\\', '_');
            rootNode.AddChildNode("Name", name);
            if (name.Contains(@"\"))
                throw new Exception("found backslash");
            rootNode.AddChildNode("Description", Description);
            doc.SaveFormatted(string.Format(@"{0}\{1}.EnumSpace.xml", dirPath, name));
        }

        public bool TryGetEnumType(string name, out EnumType type)
        {
            foreach (var _type in EnumTypes)
            {
                if (_type.Name == name)
                {
                    type = _type;
                    return true;
                }
            }
            type = null;
            return false;
        }


        public static EnumValue AddEnum(Context context, string enumSpace, string enumType, string enumValue, int enumId)
        {
            EnumSpace space;
            if (!context.EnumSpaces.TryGetValue(enumSpace, out space))
            {
                space = new EnumSpace(enumSpace, null);
                context.AddEnum(space);
            }

            EnumType type;
            if (!space.TryGetEnumType(enumType, out type))
            {
                type = new EnumType(space, enumType, null);
                space.EnumTypes.Add(type);
            }

            var enumValueObj = type.AddValue(enumValue, enumId);
            return enumValueObj;
        }
        #endregion
    }
}
