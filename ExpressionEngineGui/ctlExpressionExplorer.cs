using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    public partial class ctlExpressionExplorer : UserControl
    {
        #region Properties
        public Context Context;
        public bool IgnoreChanges = true;
        #endregion

        #region Constructor
        public ctlExpressionExplorer()
        {
            InitializeComponent();
        }
        #endregion

        #region Delegates
        public delegate void NodeDoubleClick(object obj);
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
            //cboEntityTypeFilter.DisplayMember = "FilterString";
            foreach (var type in MvcAbstraction.GetRelevantEntityTypes(Context.Expression))// Enum.GetValues(typeof(Entity.EntityTypeEnum)))
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
            foreach (var type in DataTypeInfo.AllTypes)
            {
                if (!type.IsEntity && type.BaseType != BaseType.Unknown)
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
            treExplorer.EntityTypeFilter = (Entity.EntityTypeEnum)cboEntityTypeFilter.SelectedItem;
            treExplorer.PropertyTypeFilter = (DataTypeInfo)cboPropertyTypeFilter.SelectedItem;
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

        #endregion

        #region Events

        private void cbo_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateGui();
        }

        private void treExplorer_DoubleClick(object sender, EventArgs e)
        {
            if (OnS2DoubleClick == null || treExplorer.SelectedNode == null)
                return;

            OnS2DoubleClick(treExplorer.SelectedNode.Tag);
        }

        private void mnuEnumValue_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            if (treExplorer.SelectedNode == null)
                return;
            if (!(treExplorer.SelectedNode.Tag is EnumValue))
                return;

            var enumValue = (EnumValue)treExplorer.SelectedNode.Tag;

            string text = null;
            if (e.ClickedItem.Equals(mnuInsertValue))
                text = enumValue.ToExpression;
            else
            {
                //Get the parent property
                var parentTag = treExplorer.SelectedNode.Parent.Tag;
                if (!(parentTag is Property))
                    return;

                var property = (Property)parentTag;

                if (e.ClickedItem.Equals(mnuInsertEqualitySnippet))
                    text = string.Format("{0} == {1}", property.ToExpression, enumValue.ToExpression);
                else if (e.ClickedItem.Equals(mnuInsertInequalitySnippet))
                    text = string.Format("{0} != {1}", property.ToExpression, enumValue.ToExpression);
            }

            if (OnInsertSnippet != null)
                OnInsertSnippet(text);
        }
        #endregion
    }
}
