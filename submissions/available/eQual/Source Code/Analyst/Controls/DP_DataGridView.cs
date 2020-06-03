/*
Copyright 2013 George Edwards

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License. 
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Windows.Forms;
using System.ComponentModel;

namespace DomainPro.Analyst.Controls
{
    public class DP_DataGridView : DataGridView
    {
        
        public DP_DataGridView()
        {
            Location = new Point(590, 10);
            Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            ReadOnly = true;
            ShowEditingIcon = false;
            AllowUserToAddRows = false;
            SelectionMode = DataGridViewSelectionMode.CellSelect;
            RowHeadersVisible = false;
        }

        
    }
}
