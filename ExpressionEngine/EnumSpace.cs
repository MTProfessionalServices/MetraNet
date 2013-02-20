using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine
{
    [DataContract]
    public class EnumSpace : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The name of the Enumeration namespace. Used to prevent naming collisions
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        /// <summary>
        /// The description the user enters
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// The data enumerated typs
        /// </summary>
        [DataMember]
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
                return string.Format(CultureInfo.InvariantCulture, "Enum.{0}", Name);
            }
        }

        public void Save(string dirPath)
        {
            new NotImplementedException();
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
