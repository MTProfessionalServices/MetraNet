using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;


namespace BaselineGUI
{
    public class DbAccount
    {
        //DataTable t_account;
        //DataTable t_account_ancestor;
        //DataTable t_account_mapper;
        //DataTable t_account_state;
        //DataTable t_account_state_history;
        //DataTable t_acc_usage_cycle;
        //DataTable t_acc_usage_interval;
        //DataTable t_dm_account;
        //DataTable t_dm_account_ancestor;

        TSTextBox text;

        public DbAccount()
        {
            text = new TSTextBox(UserInterface.formMain, UserInterface.formMain.TextBoxGenerateStatus);

            // Okay, let's use the stored procedure
            SqlCommand cmd = new SqlCommand("dbo.AddNewAccount", Framework.conn);
            cmd.CommandType = CommandType.StoredProcedure;
            //SqlParameter tvparam = cmd.Parameters.AddWithValue("@dt", tvp);


            // cmd.ExecuteNonQuery();
        }


    }
}
