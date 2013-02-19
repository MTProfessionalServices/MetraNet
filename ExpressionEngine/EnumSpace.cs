using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;
using System.Collections.ObjectModel;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    public class EnumSpace : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string Description { get; set; }

        public Collection<EnumType> EnumTypes { get; private set; }
        #endregion

        #region GUI Helper Properties (move in future)
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EnumSpace.png"; } }
        #endregion

        #region Constructor
        public EnumSpace(string name, string description)
        {
            Name = name;
            Description = description;
            EnumTypes =  new Collection<EnumType>();
        }
        #endregion

        #region Methods

        public EnumType AddType(string name, int id, string description)
        {
            var type = new EnumType(this, name, id, description);
            EnumTypes.Add(type);
            return type;
        }
        public string ToExpressionSnippet
        {
            get
            {
                throw new NotImplementedException("not ready yet");
            }
        }

        public void Save(string dirPath)
        {
            var doc = new XmlDocument();
            var rootNode = doc.AddChildNode("EnumSpace");

            var name = Name.Replace('\\', '_');
            rootNode.AddChildNode("Name", name);
            rootNode.AddChildNode("Description", Description);
            doc.SaveFormatted(string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.EnumSpace.xml", dirPath, name));
        }

        public bool TryGetEnumType(string name, out EnumType type)
        {
            foreach (var _type in EnumTypes)
            {
                if (_type.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase))
                {
                    type = _type;
                    return true;
                }
            }
            type = null;
            return false;
        }


        public static EnumValue AddEnum(Context context, string enumSpace, string enumType, int enumTypeId,  string enumValue, int enumValueId)
        {
            if (context == null)
                throw new ArgumentNullException("context");

            EnumSpace space;
            if (!context.EnumSpaces.TryGetValue(enumSpace, out space))
            {
                space = new EnumSpace(enumSpace, null);
                context.AddEnum(space);
            }

            EnumType type;
            if (!space.TryGetEnumType(enumType, out type))
            {
                type = new EnumType(space, enumType, enumTypeId, null);
                space.EnumTypes.Add(type);
            }

            var enumValueObj = type.AddValue(enumValue, enumValueId);
            return enumValueObj;
        }
        #endregion
    }
}
