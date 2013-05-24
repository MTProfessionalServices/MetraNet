using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MTAuth = MetraTech.Interop.MTAuth;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTServerAccess;
using MetraTech.DomainModel.BaseTypes;
using System.Workflow.ComponentModel;
using System.Activities;
using MetraTech.DataAccess;
using MetraTech.Interop.QueryAdapter;
using System.ComponentModel;


namespace MetraTech.Core.Activities
{

    public class ApplyRoleMembershipActivity : System.Workflow.ComponentModel.Activity
    {
        #region Inputs and Outputs

        #region InAccount Dependency Property
        public Account InAccount
        {
            get { return (Account)GetValue(InAccountProperty); }
            set { SetValue(InAccountProperty, value); }
        }

        // Using a DependencyProperty as the backing store for InAccount.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty InAccountProperty =
            DependencyProperty.Register("InAccount", typeof(Account), typeof(ApplyRoleMembershipActivity));

        #endregion

        #region Roles Dependency Property

        private static Dictionary<String, Dictionary<String, int>> mValidatedInstances = new Dictionary<String, Dictionary<String, int>>(StringComparer.InvariantCultureIgnoreCase);
        private static Logger logger = new Logger("[ApplyRoleMembershipActivity]");

        public String[] Roles
        {
            get { return (String[])GetValue(RolesProperty); }
            set { SetValue(RolesProperty, value); }
        }

        // Using a DependencyProperty as the backing store for Roles.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty RolesProperty =
            DependencyProperty.Register("Roles", typeof(String[]), typeof(ApplyRoleMembershipActivity));


        #endregion

        #endregion

        protected static MTAuth.IMTSessionContext mSecurityContext = null;
        protected static MTAuth.IMTSessionContext SecurityContext
        {
            get
            {
                if (mSecurityContext == null)
                {
                    MTAuth.IMTLoginContext loginContext = new MTAuth.MTLoginContextClass();
                    IMTServerAccessDataSet sa = new MTServerAccessDataSet();
                    sa.Initialize();
                    IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
                    string suName = accessData.UserName;
                    string suPassword = accessData.Password;
                    mSecurityContext = loginContext.Login(suName, "system_user", suPassword);
                }

                return mSecurityContext;
            }
        }

        protected override void Initialize(IServiceProvider provider)
        {
            if (Roles == null || Roles.Length == 0)
            {
                throw new ApplicationException("No roles have been specified");
            }

            if (!mValidatedInstances.ContainsKey(this.Name))
            {
                Dictionary<string, int> roleIds = new Dictionary<string, int>(StringComparer.InvariantCultureIgnoreCase);

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapter();
                        queryAdapter.Item.Init(@"Queries\AccountCreation");
                        queryAdapter.Item.SetQueryTag("__VALIDATE_ROLES__");

                        using (IMTPreparedStatement prepStatement = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            foreach (string role in Roles)
                            {
                                prepStatement.AddParam("RoleName", MTParameterType.String, role);

                                using (IMTDataReader reader = prepStatement.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        if (reader.GetString(1) == "N")
                                        {
                                            logger.LogWarning("Role {0} cannot be assigned to subscriber accounts", role);
                                        }

                                        if (reader.GetString(2) == "N")
                                        {
                                            logger.LogWarning("Role {0} can be assigned only to subscriber accounts", role);
                                        }

                                        roleIds[role] = reader.GetInt32(0);
                                    }
                                    else
                                    {
                                        throw new ApplicationException(string.Format("Role {0} does not exist", role));
                                    }
                                }

                                prepStatement.ClearParams();
                            }
                        }
                    }
                }

                mValidatedInstances[this.Name] = roleIds;
            }
        }

        // If your activity returns a value, derive from CodeActivity<TResult>
        // and return the value from the Execute method.
        protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
        {
            if (InAccount == null)
            {
                throw new ApplicationException("InAccount has not been set");
            }

            if (!InAccount._AccountID.HasValue)
            {
                throw new ApplicationException("InAccount does not have an account identifier specified");
            }

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                int status;
                foreach (string role in Roles)
                {
                    using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("AddMemberToRole"))
                    {
                        callableStmt.AddParam("aRoleID", MTParameterType.Integer, mValidatedInstances[this.Name][role]);
                        callableStmt.AddParam("aAccountID", MTParameterType.Integer, InAccount._AccountID.Value);
                        callableStmt.AddOutputParam("status", MTParameterType.Integer);

                        callableStmt.ExecuteNonQuery();

                        status = (int)callableStmt.GetOutputValue("status");

                        switch (status)
                        {
                            case 1:
                                // This is the success case, so do nothing.
                                break;

                            case -492896228:
                                throw new ApplicationException(string.Format("The role {0} is not assignable to subscriber accounts", role));

                            case -492896227:
                                throw new ApplicationException(string.Format("The role {0} is not assignable to system accounts", role));

                            default:
                                throw new ApplicationException(string.Format("Unknown error returned from AddMemberToRole: {0}", status));
                        }
                    }
                }
            }

            return ActivityExecutionStatus.Closed;
        }
    }
}