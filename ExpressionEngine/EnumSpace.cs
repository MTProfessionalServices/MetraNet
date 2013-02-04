using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

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
        #endregion

        public static void LoadEnumFile(Context context, string filePath, bool hasHeader)
        {
            var lines = File.ReadAllLines(filePath);
            LoadEnums(context, lines, hasHeader);
        }

        public static void LoadEnums(Context context, string[] lines, bool hasHeader)
        {
            var lineStart = hasHeader ? 1 : 0;
            for (int lineIndex = lineStart; lineIndex < lines.Length; lineIndex++)
            {
                try
                {
                    var line = lines[lineIndex];
                    var fields = line.Split(',');
                    //if (fields.Length != 2)
                    //    throw new Exception(string.Format("Expected 2 fields, found {0}", fields.Length));

                    var enumStr = fields[0];
                    var enumInt = fields[1];

                    var enumParts = enumStr.Split('/');
                    var enumValue = enumParts[enumParts.Length - 1];
                    var enumType = enumParts[enumParts.Length - 2];
                    var enumNamespace = enumStr.Substring(0, enumStr.Length - enumType.Length - enumValue.Length - 2);

                    AddEnum(context, enumNamespace, enumType, enumValue, "-1");
                }
                catch (Exception ex)
                {
                    throw new Exception(string.Format("Error parsing line #{0}   [{1}]", lineIndex, ex.Message));
                }
            }
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


        public static void AddEnum(Context context, string enumSpace, string enumType, string enumValue, string enumInt)
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

            type.AddValue(enumValue);
        }
    }
}
