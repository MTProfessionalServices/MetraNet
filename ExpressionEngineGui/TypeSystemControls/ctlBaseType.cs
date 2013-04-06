using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using PropertyGui.Compoenents;

namespace PropertyGui.TypeSystemControls
{
    public partial class ctlBaseType : UserControl
    {
        #region Properties
        protected Property Property;
        protected Context Context;
        public PropertyCreated OnPropertyCreated;
        #endregion

        #region Constructor
        public ctlBaseType()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods

        public virtual void Init(Property property, Context context)
        {
            if (property == null)
                throw new ArgumentException("property is null");
            if (context == null)
                throw new ArgumentException("context is null");
            Property = property;
            Context = context;
        }

        public virtual void SyncToForm()
        {
            throw new NotImplementedException();
        }

        public virtual void SyncToObject()
        {
            throw new NotImplementedException();
        }
        #endregion

        #region Events
        public void PropertyCreated(Property property)
        {
            if (OnPropertyCreated != null)
                OnPropertyCreated(property);
        }

        #endregion

    }
}
