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
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using DomainPro.Core.Application;
using DomainPro.Core.Types;
using DomainPro.Designer.Types;

namespace DomainPro.Designer.Controls
{
    public partial class DP_DiagramWindow : Form
    {
        // Copy/paste variables
        //DP_TypeCollection<DP_ConcreteType> clipboard = new DP_TypeCollection<DP_ConcreteType>();
        //DP_Diagram copyParent;
        //Dictionary<DP_ConcreteType, DP_ConcreteType> parentDict = new Dictionary<DP_ConcreteType, DP_ConcreteType>();

        public DP_DiagramWindow()
        {
            InitializeComponent();
        }

        public void Add(DP_ModelType model)
        {
            model.DiagramPanel.Size = new Size(ClientSize.Width - 24, ClientSize.Height - 24);
            Controls.Add(model.DiagramPanel);
        }
    }
}