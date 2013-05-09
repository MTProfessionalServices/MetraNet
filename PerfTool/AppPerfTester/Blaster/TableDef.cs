using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI.Blaster
{
    public class TableDef
    {
        public string Name
        {
            get { return _Name; }
            set { _Name = value; }
        }
        private string _Name;

        public List<RowSpec> RowData
        {
            get { return _RowData; }
            set { _RowData = value; }
        }
        private List<RowSpec> _RowData;

        public List<RowSpecA> RowDataA
        {
            get { return _RowDataA; }
            set { _RowDataA = value; }
        }
        private List<RowSpecA> _RowDataA;

        public List<String> TableCreationSql
        {
            get { return _TableCreationSql; }
            set { _TableCreationSql = value; }
        }
        private List<String> _TableCreationSql;

    }

	
}
