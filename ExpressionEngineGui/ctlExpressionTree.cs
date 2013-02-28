using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using System.IO;
using System.Drawing;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace PropertyGui
{
    public class ctlExpressionTree : TreeView
    {
        #region Constants
        private const string PropertyListPlaceHolder = "PropertyListPlaceHoder";
        #endregion

        #region Properties
        private Context Context;
        public static ImageList Images = new ImageList();

        public MvcAbstraction.ViewModeType ViewMode { get; set; }
        public string EntityTypeFilter { get; set; }
        public Type PropertyTypeFilter { get; set; }
        public string FunctionFilter { get; set; }
        public ContextMenuStrip EnumValueContextMenu { get; set; }

        private TreeNode PropertyListPlaceHolderNode;
        #endregion

        #region Static Constructor
        static ctlExpressionTree()
        {
            var path = Path.Combine(DemoLoader.DirPath, "Images");
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
            PathSeparator = ".";

            PropertyListPlaceHolderNode = new TreeNode("ProperyListPlaceHolderNode");
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
                    foreach (var aqg in Context.Aqgs.Values)
                    {
                        CreateNode(aqg);
                    }
                    break;
                case MvcAbstraction.ViewModeType.UQGs:
                    foreach (var uqg in Context.Uqgs.Values)
                    {
                        CreateNode(uqg);
                    }
                    break;
                case MvcAbstraction.ViewModeType.InputsOutputs:
                    LoadInputsOutputs();
                    break;
                case MvcAbstraction.ViewModeType.UoMs:
                    foreach (var uomCategory in Context.UnitOfMeasures.Values)
                    {
                        var uomCategoryNode = CreateNode(uomCategory);
                        foreach (var uom in uomCategory.Items)
                        {
                            CreateNode(uom, uomCategoryNode);
                        }
                    }
                    break;
                default:
                    throw new NotImplementedException();
            }
            Sort();

            if (Nodes.Count == 1)
                Nodes[0].Expand();

            EndUpdate();
        }

        private void LoadInputsOutputs()
        {
            var results = Context.GetExpressionParseResults();
            foreach (var property in results.Parameters)
            {
                var node = CreateNode(property);
                node.SelectedImageKey = property.ImageDirection;
                node.ImageKey = property.ImageDirection;
            }
        }

        private void LoadTreeEnums(bool showNamespace)
        {
            foreach (var enumSpace in Context.EnumNamespaces.Values)
            {
                TreeNode parent = null;
                if (showNamespace)
                    parent = CreateNode(enumSpace);
                foreach (var enumType in enumSpace.Categories)
                {
                    var typeNode = CreateNode(enumType, parent);
                    AddEnumValues(enumType, typeNode);
                }
            }
        }

        private void AddEnumValues(EnumCategory enumType, TreeNode parentNode)
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
            var filter = new List<string>();
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


        public void AddProperties(TreeNode parentNode, PropertyCollection properties, Type filter=null)
        {
            foreach (var property in properties)
            {
                if (filter == null || property.Type.IsBaseTypeFilterMatch(filter))
                {
                    var node = CreateNode(property, parentNode);

                    if (property.Type.IsComplexType)// && node.Level > 1)
                    {
                        node.Nodes.Add(new TreeNode(PropertyListPlaceHolder));
                    }
                }
            }
        }

        public TreeNode CreateNode(IExpressionEngineTreeNode item, TreeNode parentNode=null)
        {
            var node = new TreeNode(item.TreeNodeLabel);
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
                
                //If it's an enum, append all of the values
                if (property.Type.IsEnum)
                {
                    EnumCategory enumType;
                    if (Context.TryGetEnumType((EnumerationType)property.Type, out enumType))
                        AddEnumValues(enumType, node);          
                }

                //Append Units link, if any
                var unitsProperty = property.GetUnitsProperty();
                if (unitsProperty != null)
                {
                    var linkNode = new TreeNode(string.Format("Units Property Link: {0}", unitsProperty.Name));
                    linkNode.ToolTipText = "";
                    linkNode.SelectedImageKey = "Link.png";
                    linkNode.ImageKey = "Link.png";
                    node.Nodes.Add(linkNode);
                }

                //Append UoM link, if any
                var uomProperty = property.GetUnitOfMeasureProperty();
                if (uomProperty != null)
                {
                    var linkNode = new TreeNode(string.Format("UoM Property Link: {0}", uomProperty.Name));
                    linkNode.ToolTipText = "";
                    linkNode.SelectedImageKey = "Link.png";
                    linkNode.ImageKey = "Link.png";
                    node.Nodes.Add(linkNode);
                }
            }
        
            return node;
        }


        protected override void OnBeforeExpand(TreeViewCancelEventArgs e)
        {
            base.OnBeforeExpand(e);

            if (e.Action != TreeViewAction.Expand)
                return;

            var node = e.Node;
            if (node.Nodes.Count == 1 && node.Nodes[0].Text == PropertyListPlaceHolder)
            {
                node.Nodes.Clear();
                var property = (Property) node.Tag;
                var propertyBagTypeName = ((PropertyBagType) property.Type).Name;
                PropertyBag propertyBag;
                if (!DemoLoader.GlobalContext.Entities.TryGetValue(propertyBagTypeName, out propertyBag))
                    return;
                AddProperties(node, propertyBag.Properties);
            }
        }

        #endregion
    }
}
