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
using System.Drawing.Drawing2D;
using System.Xml.Serialization;
using System.Windows.Forms;
using DomainPro.Core.Types;

namespace DomainPro.Designer.Types
{
    public class DP_Text : DP_AbstractText
    {
        //private List<Label> labels = new List<Label>();
        private List<TabPage> pages = new List<TabPage>();

        private bool visible;

        [XmlIgnore]
        public bool Visible
        {
            get { return visible; }
            set
            {
                if (visible != value)
                {
                    if (value)
                    {
                        foreach (TabPage page in pages)
                        {
                            DomainProDesigner.Instance.DisplayTextPage(page);
                        }
                    }
                    else
                    {
                        foreach (TabPage page in pages)
                        {
                            DomainProDesigner.Instance.HideTextPage(page);
                        }
                    }
                    visible = value;
                }
            }
        }

        public void Initialize()
        {
            foreach (Instruction i in Instructions)
            {
                TabPage page = new TabPage(i.Name);
                pages.Add(page);

                RichTextBox box = new RichTextBox();
                box.Location = new Point(10, 10);
                box.Size = new Size(page.Width - 20, page.Height - 20);
                box.ShortcutsEnabled = true;
                box.AcceptsTab = true;
                box.Font = new Font(
                    FontFamily.GenericMonospace,
                    (float) 9.8,
                    FontStyle.Regular);
                box.Anchor = AnchorStyles.Bottom | AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
                box.Text = i.String;
                box.TextChanged += BoxTextChanged;
                box.Tag = i;

                page.Controls.Add(box);
            }
        }

        private void BoxTextChanged(object sender, EventArgs e)
        {
            ((Instruction) ((RichTextBox) sender).Tag).String = ((RichTextBox) sender).Text;
        }
    }
}