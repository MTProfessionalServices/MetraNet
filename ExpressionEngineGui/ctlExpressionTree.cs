using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using System.IO;
using System.Drawing;

namespace PropertyGui
{
    public class ctlExpressionTree : TreeView
    {
        #region Properties
        private Context Context;
        public static ImageList Images = new ImageList();

        public MvcAbstraction.ViewModeType ViewMode { get; set; }
        public Entity.EntityTypeEnum EntityTypeFilter { get; set; }
        public DataTypeInfo PropertyTypeFilter { get; set; }
        public string FunctionFilter { get; set; }
        public ContextMenuStrip EnumValueContextMenu { get; set; }
        #endregion

        #region Static Constructor
        static ctlExpressionTree()
        {
            var path = Path.Combine(_DemoLoader.DirPath, "Images");
            var dirInfo = new DirectoryInfo(path);
            if (!dirInfo.Exists)
                throw new Exception("Can't find " + path);

            foreach (var file in dirInfo.GetFiles("*.png"))
            {
                Images.Images.Add(file.Name, Image.FromFile(file.FullName));
            }
        }
        #endregion

        #region Constructor
        public ctlExpressionTree()
        {
            ImageList = Images;
            ShowNodeToolTips = true;
        }
        #endregion

        #region Methods
        public void Init(Context context, ContextMenuStrip enumValueMenu)
        {
            Context = context;
            EnumValueContextMenu = enumValueMenu;
        }

        public void LoadTree()
        {
            BeginUpdate();
            ShowRootLines = true;
            Scrollable = true;
            Nodes.Clear();
            switch (ViewMode)
            {
                case MvcAbstraction.ViewModeType.Entities:
                    LoadTreeEntityMode();
                    break;
                case MvcAbstraction.ViewModeType.Functions:
                    LoadTreeFunctionsMode();
                    break;
                case MvcAbstraction.ViewModeType.Properties:
                    LoadTreeProperties();
                    break;
                case MvcAbstraction.ViewModeType.Enums:
                    LoadTreeEnums(false);
                    break;
                case MvcAbstraction.ViewModeType.AQGs:
                    foreach (var aqg in Context.AQGs.Values)
                    {
                        CreateNode(aqg);
                    }
                    break;
                case MvcAbstraction.ViewModeType.UQGs:
                    foreach (var uqg in Context.UQGs.Values)
                    {
                        CreateNode(uqg);
                    }
                    break;
                case MvcAbstraction.ViewModeType.InputsOutputs:
                    foreach (var property in Context.Expression.Parameters)
                    {
                        var node = CreateNode(property);
                        node.SelectedImageKey = property.ImageDirection;
                        node.ImageKey = property.ImageDirection;
                    }
                    break;
                default:
                    throw new NotImplementedException();
            }
            Sort();
            EndUpdate();
        }

        private void LoadTreeEnums(bool showNamespace)
        {
            foreach (var enumSpace in Context.EnumSpaces.Values)
            {
                TreeNode parent = null;
                if (showNamespace)
                    parent = CreateNode(enumSpace);
                foreach (var enumType in enumSpace.EnumTypes)
                {
                    var typeNode = CreateNode(enumType, parent);
                    AddEnumValues(enumType, typeNode);
                }
            }
        }

        private void AddEnumValues(EnumType enumType, TreeNode parentNode)
        {
            foreach (var value in enumType.Values)
            {
                var node = CreateNode(value, parentNode);
                node.ContextMenuStrip = EnumValueContextMenu;
            }
        }

        private void LoadTreeProperties()
        {
            var properties = Context.GetProperties(PropertyTypeFilter);
            var existingNodes = new Dictionary<string, TreeNode>();
            foreach (var property in properties)
            {
                TreeNode propertyNode;
                if (!existingNodes.TryGetValue(property.Name, out propertyNode))
                {
                    propertyNode = CreateNode(property);
                    existingNodes.Add(property.Name, propertyNode);
                }

                //Add the entity to which it belongs
                CreateNode(property.ParentEntity, propertyNode);
            }
        }

        private void LoadTreeFunctionsMode()
        {
            foreach (var func in Context.Functions.Values)
            {
                if (FunctionFilter != "<All>" && FunctionFilter != func.Category)
                    continue;

                CreateNode(func, null);
            }
        }
        private void LoadTreeEntityMode()
        {
            var filter = new List<Entity.EntityTypeEnum>();
            filter.Add(EntityTypeFilter);
            var entities = Context.GetEntities(null, filter, null, PropertyTypeFilter);
            foreach (var entity in entities)
            {
                //Create the entity node
                var entityNode = CreateNode(entity, null);

                //Create the property nodes
                AddProperties(entityNode, entity.Properties, PropertyTypeFilter);
            }
        }

        private void LoadTreePropertyMode()
        {
        }


        public void AddProperties(TreeNode parentNode, PropertyCollection properties, DataTypeInfo filter)
        {
            foreach (var property in properties)
            {
                if (property.DataTypeInfo.IsBaseTypeFilterMatch(filter))
                    CreateNode(property, parentNode);
            }
        }

        public TreeNode CreateNode(IExpressionEngineTreeNode item, TreeNode parentNode=null)
        {
            var node = new TreeNode(item.Name);
            node.ToolTipText = item.ToolTip;
            node.SelectedImageKey = item.Image;
            node.ImageKey = item.Image;
            node.Tag = item;

            //Set the parent
            if (parentNode == null)
                Nodes.Add(node);
            else
                parentNode.Nodes.Add(node);
     
            if (item is Property)
            {
                var property = (Property)item;
                if (property.DataTypeInfo.IsEnum)
                {
                EnumType enumType;
                if (Context.TryGetEnumType(property.DataTypeInfo, out enumType))
                    AddEnumValues(enumType, node);          
                }
            }

            return node;
        }
        #endregion
    }
}
