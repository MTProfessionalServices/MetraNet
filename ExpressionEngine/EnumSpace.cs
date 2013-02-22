using System;
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
        public Collection<EnumCategory> EnumTypes { get; private set; }
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
            EnumTypes =  new Collection<EnumCategory>();
        }
        #endregion

        #region Methods

        public EnumCategory AddType(string name, int id, string description)
        {
            var type = new EnumCategory(this, name, id, description);
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


        public bool TryGetEnumType(string name, out EnumCategory type)
        {
            foreach (var _type in EnumTypes)
            {
                if (_type.Name.Equals(name, StringComparison.Ordinal))
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

            EnumCategory type;
            if (!space.TryGetEnumType(enumType, out type))
            {
                type = new EnumCategory(space, enumType, enumTypeId, null);
                space.EnumTypes.Add(type);
            }

            var enumValueObj = type.AddValue(enumValue, enumValueId);
            return enumValueObj;
        }
        #endregion
    }
}
