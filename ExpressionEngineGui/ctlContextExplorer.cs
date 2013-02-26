using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Placeholders;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace PropertyGui
{
    public partial class ctlContextExplorer : UserControl
    {
        #region Properties
        public Context Context;
        public bool IgnoreChanges = true;
        #endregion

        #region Constructor
        public ctlContextExplorer()
        {
            InitializeComponent();
        }
        #endregion

        #region Delegates
        public delegate void NodeDoubleClick(object obj, string value);
        public NodeDoubleClick OnS2DoubleClick;

        public delegate void InsertSnippet(string snippet);
        public InsertSnippet OnInsertSnippet;
        #endregion

        #region Methods
        public void Init(Context context)
        {
            Context = context;

            IgnoreChanges = true;

            treExplorer.Init(Context, null);//mnuEnumValue);

            //Init the Mode combo
            cboMode.BeginUpdate();
            cboMode.Items.Clear();
            foreach (var viewMode in MvcAbstraction.GetRelevantViewModes(Context.Expression))
            {
                cboMode.Items.Add(viewMode);
            }
            cboMode.Sorted = true;
            cboMode.EndUpdate();
            cboMode.SelectedItem = MvcAbstraction.ViewModeType.Entities;

            //Init the Entity Type Filter
            cboEntityTypeFilter.BeginUpdate();
            cboEntityTypeFilter.Items.Clear();
            cboEntityTypeFilter.DropDownStyle = ComboBoxStyle.DropDownList;
            foreach (var type in MvcAbstraction.GetRelevantEntityTypes(Context.ProductType, Context.Expression))
            {
                cboEntityTypeFilter.Items.Add(type);
            }
            cboEntityTypeFilter.Sorted = true;
            cboEntityTypeFilter.EndUpdate();
            cboEntityTypeFilter.SelectedIndex = 0;

            //Init the Property Type Filter
            #region PropertyTypeFilter
            cboPropertyTypeFilter.BeginUpdate();
            cboPropertyTypeFilter.Items.Clear();
            cboPropertyTypeFilter.DropDownStyle = ComboBoxStyle.DropDownList;
            cboPropertyTypeFilter.DisplayMember = "FilterString";
            foreach (var type in TypeHelper.AllTypes)
            {
                if (!type.IsComplexType && type.BaseType != BaseType.Unknown)
                    cboPropertyTypeFilter.Items.Add(type.Copy());
            }
            cboPropertyTypeFilter.Sorted = true;
            cboPropertyTypeFilter.EndUpdate();
            cboPropertyTypeFilter.SelectedIndex = 0;
            #endregion

            //Init the Function Category Filter
            cboCategory.BeginUpdate();
            cboCategory.Items.Clear();
            cboCategory.DropDownStyle = ComboBoxStyle.DropDownList;
            cboCategory.Items.AddRange(Context.GetFunctionCategories(true).ToArray());
            cboCategory.Sorted = true;
            cboCategory.EndUpdate();
            cboCategory.SelectedIndex = 0;

            InitPanel(panFunction);
            
            IgnoreChanges = false;
            UpdateGui();
        }

        private void InitPanel(Panel panel)
        {
            panel.Left = panGeneral.Left;
            panel.Top = panGeneral.Top;
            panel.Width = panGeneral.Width;
        }

        private void UpdateGui()
        {
            if (IgnoreChanges)
                return;

            treExplorer.ViewMode = (MvcAbstraction.ViewModeType)cboMode.SelectedItem;
            treExplorer.EntityTypeFilter = (ComplexType)cboEntityTypeFilter.SelectedItem;
            treExplorer.PropertyTypeFilter = (Type)cboPropertyTypeFilter.SelectedItem;
            treExplorer.FunctionFilter = cboCategory.Text;
            treExplorer.LoadTree();

            panFunction.Visible = false;
            panGeneral.Visible = false;

            Control control;
            switch (treExplorer.ViewMode)
            {
                case MvcAbstraction.ViewModeType.Entities:
                case MvcAbstraction.ViewModeType.Properties:
                    control = panGeneral;
                    break;
                case MvcAbstraction.ViewModeType.Functions:
                    control = panFunction;
                    break;   
                default:
                    control = cboMode;
                    break;
            }
            if (control is Panel)
                control.Visible = true;
            treExplorer.Top = control.Bottom + 5;
        }

        private string GetExpressionPath(TreeNode node)
        {
            if (node.Tag is Aqg || node.Tag is Uqg || node.Tag is EnumValue)
                return ((IExpressionEngineTreeNode)node.Tag).ToExpressionSnippet;

            if (!(node.Tag is Property))
                return string.Empty;

            var property = (Property)node.Tag;
            var columnPrefix = UserSettings.NewSyntax ? string.Empty : "c_";

            switch (Context.Expression.Type)
            {
                case ExpressionType.Aqg:
                    return string.Format("ACCOUNT.{0}{1}", columnPrefix, property.Name);
                case ExpressionType.Uqg:
                    var binder = UserSettings.NewSyntax ? "EVENT" : "USAGE";
                    return string.Format("{0}.{1}{2}", binder, columnPrefix, property.Name);
                default:
                    return node.FullPath;
            }
        }
        #endregion

        #region ComboBox Events

        private void cbo_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateGui();
        }


        #endregion

        #region Tree Events
        private void treExplorer_DoubleClick(object sender, EventArgs e)
        {
            if (OnS2DoubleClick == null || treExplorer.SelectedNode == null)
                return;

            string value = GetExpressionPath(treExplorer.SelectedNode);

            OnS2DoubleClick(treExplorer.SelectedNode.Tag, value);
        }

        #endregion

        #region Context Menu Events

        private void mnuEnumValue_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            if (treExplorer.SelectedNode == null)
                return;
            if (!(treExplorer.SelectedNode.Tag is EnumValue))
                return;

            var enumValue = (EnumValue)treExplorer.SelectedNode.Tag;

            string text = null;
            if (e.ClickedItem.Equals(mnuInsertValue))
                text = enumValue.ToExpressionSnippet;
            else
            {
                //Get the parent property
                var parentTag = treExplorer.SelectedNode.Parent.Tag;
                if (!(parentTag is Property))
                    return;

                var property = (Property)parentTag;
                var path = GetExpressionPath(treExplorer.SelectedNode.Parent);

                if (e.ClickedItem.Equals(mnuInsertEqualitySnippet))
                    text = string.Format("{0} {1} {2}", path, UserSettings.DefaultEqualityOperator, enumValue.ToExpressionSnippet);
                else if (e.ClickedItem.Equals(mnuInsertInequalitySnippet))
                    text = string.Format("{0} {1} {2}", path, UserSettings.DefaultInequalityOperator, enumValue.ToExpressionSnippet);
            }

            if (OnInsertSnippet != null)
                OnInsertSnippet(text);
        }
        #endregion
    }
}
