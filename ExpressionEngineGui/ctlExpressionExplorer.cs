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
        #endregion

        #region Methods
        public void Init(Context context)
        {
            Context = context;

            IgnoreChanges = true;

            treExplorer.Init(Context);

            //Init the Mode combo
            cboMode.BeginUpdate();
            cboMode.Items.Clear();
            foreach (var item in Enum.GetValues(typeof(ctlExpressionTree.ViewModeType)))
            {
                cboMode.Items.Add(item);
            }
            cboMode.Sorted = true;
            cboMode.EndUpdate();
            cboMode.SelectedItem = ctlExpressionTree.ViewModeType.Entities;

            //Init the Entity Type Filter
            cboEntityTypeFilter.BeginUpdate();
            cboEntityTypeFilter.Items.Clear();
            cboEntityTypeFilter.DropDownStyle = ComboBoxStyle.DropDownList;
            //cboEntityTypeFilter.DisplayMember = "FilterString";
            foreach (var type in Enum.GetValues(typeof(Entity.EntityTypeEnum)))
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
            foreach (var type in BaseTypeInfo.LeafTypeFilters)
            {
                cboPropertyTypeFilter.Items.Add(new DataTypeInfo(type));
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

            treExplorer.ViewMode = (ctlExpressionTree.ViewModeType)cboMode.SelectedItem;
            treExplorer.EntityTypeFilter = (Entity.EntityTypeEnum)cboEntityTypeFilter.SelectedItem;
            treExplorer.PropertyTypeFilter = (DataTypeInfo)cboPropertyTypeFilter.SelectedItem;
            treExplorer.FunctionFilter = cboCategory.Text;
            treExplorer.LoadTree();

            panFunction.Visible = false;
            panGeneral.Visible = false;

            Control control;
            switch (treExplorer.ViewMode)
            {
                case ctlExpressionTree.ViewModeType.Entities:
                case ctlExpressionTree.ViewModeType.Properties:
                    control = panGeneral;
                    break;
                case ctlExpressionTree.ViewModeType.Functions:
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
        #endregion

        private void treExplorer_DoubleClick(object sender, EventArgs e)
        {
            if (OnS2DoubleClick == null || treExplorer.SelectedNode == null)
                return;

            OnS2DoubleClick(treExplorer.SelectedNode.Tag);
        }
    }
}
