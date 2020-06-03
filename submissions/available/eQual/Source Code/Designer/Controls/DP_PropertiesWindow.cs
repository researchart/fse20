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
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace DomainPro.Designer.Controls
{
    public partial class DP_PropertiesWindow : Form
    {
        public DP_PropertiesWindow()
        {
            InitializeComponent();

            //this.Paint += PropertiesWindowPaint;
        }

        //public void ClearProps()
        //{
        /*
            while (Controls.Count > 0)
            {
                Controls.Remove(Controls[0]);
            }
             * */

        //Controls.Clear();
        //propTabControl.Controls.Clear();

        /*
            foreach (TabPage tab in propTabControl.Controls)
            {
                tab.Hide();
            }
             * */

        //}

        /*
        public void ResizeProps()
        {

            propTabControl.Size = new Size(Width - 42, Height - 88);

            foreach (Control c in Controls)
            {
                if (c.GetType() == typeof(TabControl))
                {
                    if (propTabControl.TabPages.Count > 0)
                    {
                        propTabControl.ItemSize = new Size((int)Math.Ceiling((propTabControl.Width - 6) / (float)propTabControl.TabPages.Count), 21);
                    }
                }
                else
                {
                    int newWidth = (this.Width - 50) / 2;
                    c.Width = newWidth;
                    if (c.Location.X > newWidth / 2)
                    {
                        c.Location = new Point(newWidth + 20, c.Location.Y);
                    }
                    else
                    {
                        c.Location = new Point(10, c.Location.Y);
                    }
                }
            }
        }

        protected override void OnSizeChanged(EventArgs e)
        {
            base.OnSizeChanged(e);

            ResizeProps();
        }
         * */

        /*
        protected void PropertiesWindowPaint(object sender, PaintEventArgs e)
        {

        }
         * */
    }
}