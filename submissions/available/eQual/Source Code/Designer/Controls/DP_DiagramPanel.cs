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
using System.IO;
using System.Text;
using System.Drawing;
using System.Windows.Forms;
using DomainPro.Core.Application;
using DomainPro.Designer.Types;

namespace DomainPro.Designer.Controls
{
    public class DP_DiagramPanel : Panel
    {
        private DP_TypeCollection<DP_ConcreteType> clipboard = new DP_TypeCollection<DP_ConcreteType>();
        private DP_Diagram copyParent;

        private Dictionary<DP_ConcreteType, DP_ConcreteType> parentDict =
            new Dictionary<DP_ConcreteType, DP_ConcreteType>();

        public DP_DiagramPanel()
        {
            try
            {
                SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
                SetStyle(ControlStyles.UserPaint, true);
                SetStyle(ControlStyles.AllPaintingInWmPaint, true);
                Top = 12;
                Left = 12;
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Bottom | AnchorStyles.Right;
                BorderStyle = BorderStyle.FixedSingle;
                BackColor = Color.White;
                AutoScroll = true;
                ResizeRedraw = true;
                BackgroundImage =
                    Image.FromFile(Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"),
                        "Graphics\\Grid.png"));
            }
            catch (Exception e)
            {
                DialogResult result = MessageBox.Show(
                    "Unable to create main diagram panel.\n\n" +
                    "Exception: " +
                    e.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
                return;
            }
        }

        protected override void OnScroll(ScrollEventArgs se)
        {
            base.OnScroll(se);
            Invalidate();
        }

        protected override void OnResize(EventArgs eventargs)
        {
            base.OnResize(eventargs);
            Refresh();
        }

        // Causes the window to process arrow keys as regular input keys rather than as special keys
        protected override bool IsInputKey(Keys key)
        {
            if (key == Keys.Left ||
                key == Keys.Right ||
                key == Keys.Up ||
                key == Keys.Down ||
                key == Keys.Delete ||
                key == Keys.Back ||
                key == Keys.C ||
                key == Keys.V)
            {
                return true;
            }
            else
            {
                return base.IsInputKey(key);
            }
        }

        // Panels do not raise any key press events, so these events must be handled here
        protected override void OnKeyDown(KeyEventArgs e)
        {
            base.OnKeyDown(e);

            if (!e.Handled)
            {
                if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
                {
                    switch (e.KeyCode)
                    {
                        case Keys.C:
                            Copy();
                            break;
                        case Keys.V:
                            Paste();
                            break;
                    }
                }
                else
                {
                    switch (e.KeyCode)
                    {
                        case Keys.Delete:
                        case Keys.Back:
                            for (int i = DomainProDesigner.Instance.Selected.Count - 1; i >= 0; i--)
                            {
                                DomainProDesigner.Instance.Selected[i].Destroy();
                            }
                            DomainProDesigner.Instance.Selected.Clear();
                            e.Handled = true;
                            break;
                        case Keys.Left:
                            foreach (DP_ConcreteType type in DomainProDesigner.Instance.Selected)
                            {
                                type.Location = new Point(type.Location.X - 1, type.Location.Y);
                            }
                            e.Handled = true;
                            break;
                        case Keys.Right:
                            foreach (DP_ConcreteType type in DomainProDesigner.Instance.Selected)
                            {
                                type.Location = new Point(type.Location.X + 1, type.Location.Y);
                            }
                            e.Handled = true;
                            break;
                        case Keys.Up:
                            foreach (DP_ConcreteType type in DomainProDesigner.Instance.Selected)
                            {
                                type.Location = new Point(type.Location.X, type.Location.Y - 1);
                            }
                            e.Handled = true;
                            break;
                        case Keys.Down:
                            foreach (DP_ConcreteType type in DomainProDesigner.Instance.Selected)
                            {
                                type.Location = new Point(type.Location.X, type.Location.Y + 1);
                            }
                            e.Handled = true;
                            break;
                    }
                }
            }
        }

        public void Copy()
        {
            copyParent = DomainProDesigner.Instance.MainDiagram;
            DP_TypeCollection<DP_ConcreteType> topLevelSelected = new DP_TypeCollection<DP_ConcreteType>();
            foreach (DP_ConcreteType type in DomainProDesigner.Instance.Selected)
            {
                if (copyParent.Types.Contains(type))
                {
                    topLevelSelected.Add(type);
                }
            }
            try
            {
                clipboard = DomainProDesigner.Instance.Model.DuplicateTypes(topLevelSelected);
            }
            catch (Exception e)
            {
                DialogResult result = MessageBox.Show(
                    "Unable to perform copy operation.\n\n" +
                    "Exception: " +
                    e.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
            }
        }

        public void Paste()
        {
            if (copyParent == null)
            {
                return;
            }

            if (copyParent.GetType() == DomainProDesigner.Instance.MainDiagram.GetType() ||
                copyParent.GetType().IsSubclassOf(DomainProDesigner.Instance.MainDiagram.GetType()))
            {
                DomainProDesigner.Instance.Model.TreeRoot.TreeView.BeginUpdate();
                DomainProDesigner.Instance.Model.DiagramPanel.SuspendLayout();
                try
                {
                    DP_TypeCollection<DP_ConcreteType> newTypes =
                        DomainProDesigner.Instance.Model.DuplicateTypes(clipboard);
                    DomainProDesigner.Instance.Selected.Clear();
                    foreach (DP_ConcreteType type in newTypes)
                    {
                        if (type is DP_Shape)
                        {
                            type.Location = new Point(type.Left + 20, type.Top + 20);
                        }

                        type.Initialize(DomainProDesigner.Instance.MainDiagram);
                        DomainProDesigner.Instance.Selected.Add(type);
                    }
                }
                catch (Exception e)
                {
                    DialogResult result = MessageBox.Show(
                        "Unable to perform paste operation.\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                }
                DomainProDesigner.Instance.Model.TreeRoot.TreeView.EndUpdate();
                DomainProDesigner.Instance.Model.DiagramPanel.ResumeLayout();
                DomainProDesigner.Instance.Model.DiagramPanel.Refresh();
            }
        }
    }
}