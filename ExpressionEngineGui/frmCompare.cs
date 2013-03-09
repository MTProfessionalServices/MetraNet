using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Placeholders;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using System.Linq;

namespace PropertyGui
{
    public partial class frmCompare : Form
    {
        #region Properties
        private bool IgnoreChanges = false;
        private Context Context1;
        private Context Context2;
        #endregion

        #region Constructor
        public frmCompare(Context context1, string context1Name, Context context2, string context2Name)
        {
            InitializeComponent();
            MinimizeBox = false;
            WindowState = FormWindowState.Maximized;

            Context1 = context1;
            Context2 = context2;
            txtContext1.Text = context1Name;
            txtContext2.Text = context2Name;

            treContext1.Init(Context1, null);
            treContext2.Init(Context2, null);

            Init();

            UpdateTrees();
        }
        #endregion

        #region Init Methods

        private void Init()
        {
            IgnoreChanges = true;

            //Set the view modes
            cboViewMode.BeginUpdate();
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Entities);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Enumerations);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.AQGs);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.UQGs);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Emails);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Functions);
            cboViewMode.Sorted = true;
            cboViewMode.SelectedItem = MvcAbstraction.ViewModeType.Entities;
            cboViewMode.EndUpdate();

            //Set the entity types
            cboPropertyBagFilter.Text = PropertyBagConstants.AnyFilter;

            //Init the Property Type Filter
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

            LoadFunctionCategoryFilter();
            LoadPropertyBagFilter();

            IgnoreChanges = false;
        }

        #endregion

        #region Tree Methods
        private void UpdateTrees()
        {
            UpdateTree(treContext1, Context1);
            UpdateTree(treContext2, Context2);
        }

        public void UpdateTree(ctlExpressionTree tree, Context context)
        {
            tree.ViewMode = (MvcAbstraction.ViewModeType)cboViewMode.SelectedItem;
            tree.PropertyTypeFilter = (MetraTech.ExpressionEngine.TypeSystem.Type)cboPropertyTypeFilter.SelectedItem;
            tree.FunctionFilter = cboCategory.Text;
            tree.EntityTypeFilter = PropertyBagConstants.AnyFilter;
            //tree.EntityTypeFilter = cboPropertyBagFilter.SelectedItem.ToString();

            if (context != null)
                tree.LoadTree();
        }
        #endregion

        #region Filter Functions
        public void LoadFunctionCategoryFilter()
        {
            var context = GetAnyContext();
            if (context == null)
                return;

            IgnoreChanges = true;

            //Init the Function Category Filter
            cboCategory.BeginUpdate();
            cboCategory.Items.Clear();
            cboCategory.DropDownStyle = ComboBoxStyle.DropDownList;
            cboCategory.Items.AddRange(context.GetFunctionCategories(true).ToArray());
            cboCategory.Sorted = true;
            cboCategory.EndUpdate();
            cboCategory.SelectedIndex = 0;

            IgnoreChanges = false;
        }

        public void LoadPropertyBagFilter()
        {
            IgnoreChanges = true;

            var list = new List<string>();
            if (Context1 != null)
                list.AddRange(Context1.GetPropertyBagTypes());
            if (Context2 != null)
                list.AddRange(Context2.GetPropertyBagTypes());
            list = list.Distinct().ToList();

            cboPropertyBagFilter.Items.Clear();
            cboPropertyBagFilter.Items.Add(PropertyBagConstants.AnyFilter);
            foreach (var name in list)
            {
                cboPropertyBagFilter.Items.Add(name);
            }
            cboPropertyBagFilter.Sorted = true;
            cboPropertyBagFilter.SelectedItem = cboPropertyBagFilter.Items[0];

            IgnoreChanges = false;
        }
        #endregion
        
        private Context GetAnyContext()
        {
            if (Context1 != null)
                return Context1;
            return Context2;
        }

        private void ShowExpression(ProductType productType, Expression expression, bool isPageLayout = false)
        {
            var dialog = new frmExpressionEngine();
            var context = new Context(productType, expression);
            dialog.Init(context, isPageLayout);
            dialog.ShowDialog();
        }

        #region Events
        private void settingChanged(object sender, EventArgs e)
        {
            if (!IgnoreChanges)
                UpdateTrees();
        }


        private void treContext1_NodeMouseDoubleClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            Context c1;
            if (e.Node.TreeView.Equals(treContext1))
                c1 = Context1;
            else
                c1 = Context2;
            DemoLoader.GlobalContext = c1;

            var tag = e.Node.Tag;
            if (tag is EmailInstance)
            {
                var emailInstance = (EmailInstance) tag;
                emailInstance.UpdateEntityParameters();
                var dialog = new frmExpressionEngine();
                var context = new Context(ProductType.Metanga, emailInstance.BodyExpression, emailInstance);
                dialog.Init(context, emailInstance);
                dialog.ShowDialog();
            }
            else if (tag is Aqg)
            {
                ShowExpression(c1.ProductType, ((Aqg)tag).Expression);
            }
            else if (tag is Uqg)
            {
                ShowExpression(c1.ProductType, ((Uqg)tag).Expression);
            }
        }

        #endregion
    }
}
