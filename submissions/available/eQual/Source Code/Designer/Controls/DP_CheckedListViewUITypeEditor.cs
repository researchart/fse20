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
using System.ComponentModel;
using System.Drawing.Design;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.Design;

namespace DomainPro.Designer.Controls
{
    public class DP_CheckedListViewUITypeEditor : UITypeEditor
    {
        private ListView listView = new ListView();

        public DP_CheckedListViewUITypeEditor()
        {
            listView.View = View.List;
            listView.CheckBoxes = true;
        }

        public override UITypeEditorEditStyle GetEditStyle(ITypeDescriptorContext context)
        {
            return UITypeEditorEditStyle.DropDown;
        }

        public override bool IsDropDownResizable
        {
            get { return false; }
        }

        public override object EditValue(ITypeDescriptorContext context, IServiceProvider provider, object value)
        {
            IWindowsFormsEditorService editorService =
                provider.GetService(typeof (IWindowsFormsEditorService)) as IWindowsFormsEditorService;

            if (value is List<string>)
            {
                List<string> selected = value as List<string>;

                if (editorService != null)
                {
                    editorService.DropDownControl(listView);

                    selected.Clear();
                    foreach (string s in listView.CheckedItems)
                    {
                        selected.Add(s);
                    }
                    value = selected;
                }
            }

            return value;
        }
    }
}