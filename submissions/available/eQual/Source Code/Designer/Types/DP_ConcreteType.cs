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
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Windows.Forms;
using DomainPro.Core.Types;
using DomainPro.Designer.Controls;

namespace DomainPro.Designer.Types
{
    [XmlInclude(typeof (DP_Text))]
    public abstract class DP_ConcreteType : DP_AbstractSemanticType
    {
        public class DP_Font
        {
            private string fontFamily = "Segoe UI";

            public string FontFamily
            {
                get { return fontFamily; }
                set { fontFamily = value; }
            }

            private float size = (float) 9;

            public float Size
            {
                get { return size; }
                set { size = value; }
            }

            private FontStyle style = FontStyle.Regular;

            public FontStyle Style
            {
                get { return style; }
                set { style = value; }
            }
        }

        public class DP_Color
        {
            private int argb = 0;

            public int Argb
            {
                get { return argb; }
                set { argb = value; }
            }
        }

        private string displayName = "";

        [DisplayName("Displayed Name"),
         Category("Common"),
         DefaultValue(""),
         Description("Sets the text to be displayed for the object in models.")]
        public string DisplayName
        {
            get { return displayName; }
            set
            {
                displayName = value;
                Invalidate();
            }
        }

        /*
        private bool isRoot = false;

        [DisplayName("Is Root Type?"),
        Category("Type"),
        DefaultValue(false),
        Description("Sets whether the object can be created in the model root."),
        Browsable(false)]
        public bool IsRoot
        {
            get { return isRoot; }
            set { isRoot = value; }
        }

        private bool isAbstract = false;

        [DisplayName("Is Abstract Type?"),
        Category("Type"),
        DefaultValue(false),
        Description("Sets whether the object can be created in models."),
        Browsable(false)]
        public bool IsAbstract
        {
            get { return isAbstract; }
            set { isAbstract = value; }
        }
        */
        private bool showName = false;

        [DisplayName("Show Name?"),
         Category("Instance"),
         DefaultValue(true),
         Description("Sets whether the object's name is displayed.")]
        public bool ShowName
        {
            get { return showName; }
            set
            {
                showName = value;
                Invalidate();
            }
        }

        private Font nameFont = new Font("Segoe UI", (float) 9, FontStyle.Regular);

        [XmlIgnore,
         DisplayName("Font"),
         Category("Instance"),
         Description("Sets the name font of the object.")]
        public Font NameFont
        {
            get { return nameFont; }
            set
            {
                nameFont = value;
                Invalidate();
            }
        }

        [XmlElement("NameFont"),
         Browsable(false)]
        public DP_Font NameTextFont
        {
            get
            {
                DP_Font newFont = new DP_Font();
                newFont.FontFamily = nameFont.FontFamily.Name;
                newFont.Size = nameFont.Size;
                newFont.Style = nameFont.Style;
                return newFont;
            }
            set { NameFont = new Font(value.FontFamily, value.Size, value.Style); }
        }

        private bool hidden = false;

        [DisplayName("Hidden"),
         Category("Common"),
         DefaultValue(false),
         Description("Sets whether the object is visible in diagrams.")]
        public bool Hidden
        {
            get { return hidden; }
            set
            {
                // Need to invalidate both before and after changing the value because the Area property will be empty when the object is hidden.
                Invalidate();
                hidden = value;
                Invalidate();
            }
        }

        /*
        private string role1Name = "";

        [DisplayName("Role 1 Name"),
        Category("Common"),
        DefaultValue(""),
        Description("Indicates the name of the first role."),
        ReadOnly(true)]
        public string Role1Name
        {
            get { return role1Name; }
            set { role1Name = value; }
        }

        private string role2Name = "";

        [DisplayName("Role 2 Name"),
        Category("Common"),
        DefaultValue(""),
        Description("Indicates the name of the second role."),
        ReadOnly(true)]
        public string Role2Name
        {
            get { return role2Name; }
            set { role2Name = value; }
        }
        */

        [XmlIgnore]
        public override string Name
        {
            get { return name; }
            set
            {
                if (name == value)
                {
                    return;
                }

                // Don't overwrite the old name yet

                // Assume that if Parent != null then the type is in Parent.Types
                if (Parent != null)
                {
                    value = Parent.MakeUniqueName(value);
                    Parent.Types.ChangeName(this, value);
                }

                if (DisplayName == name)
                {
                    DisplayName = value;
                }

                TreeNode.Text = value;
                if (TreeNode.Parent != null)
                {
                    TreeNode.TreeView.BeginInvoke((MethodInvoker) delegate { TreeNode.TreeView.Sort(); });
                }

                name = value;

                // If the object is a shape, make sure it is big enough to accommodate the new name
                Size = Size;
            }
        }

        [XmlIgnore,
         DisplayName("Simulation Metatype"),
         Category("Common"),
         DefaultValue(DP_SimulationType.None),
         Description("Indicates the way the object behaves in simulation."),
         ReadOnly(true)]
        public new DP_SimulationType SimulationType
        {
            get { return base.SimulationType; }
            set
            {
                base.SimulationType = value;
                treeNode.ImageIndex = (int) SimulationType;
                treeNode.SelectedImageIndex = (int) SimulationType;
            }
        }

        [XmlIgnore,
         Browsable(false)]
        public new DP_Diagram Parent
        {
            get { return base.Parent as DP_Diagram; }
            set
            {
                if (Parent == value)
                {
                    return;
                }

                // If the parent is being switched from a previous parent
                if (Parent != null)
                {
                    Parent.Types.Remove(this);
                    LocationChanged -= Parent.TypeLocationChanged;
                    // Use the base property setter so this property setter is not called recursively
                    base.Parent = null;
                }

                // Don't set the new parent yet. We need Parent == null for the call to the Name setter

                // If the type is being created or modified in the editor (else the type is being created from XML and is already in value.Types)
                if (!value.Types.Contains(this))
                {
                    // Make sure the name is unique in the new parent.
                    Name = value.MakeUniqueName(Name);
                    value.Types.Add(this);
                }

                // Use the base property setter so this property setter is not called recursively
                base.Parent = value;
                LocationChanged += Parent.TypeLocationChanged;

                // Raise LocationChanged event so that any attached lines will be drawn correctly
                OnLocationChanged(new EventArgs());
            }
        }

        [XmlIgnore,
         Browsable(false)]
        public DP_Diagram Diagram
        {
            get { return structure as DP_Diagram; }
            set { structure = value; }
        }

        /*
        [XmlIgnore]
        [Browsable(false)]
        public new DP_Text Text
        {
            get { return base.Text as DP_Text; }
            set { base.Text = value; }
        }
         * */

        private List<DP_Line> lines = new List<DP_Line>();

        [XmlIgnore,
         Browsable(false)]
        public List<DP_Line> Lines
        {
            get { return lines; }
            set { lines = value; }
        }

        private TreeNode treeNode = new TreeNode();

        [XmlIgnore,
         Browsable(false)]
        public TreeNode TreeNode
        {
            get { return treeNode; }
        }

        protected const int startDragSize = 16;
        protected DomainProDesigner app = DomainProDesigner.Instance;

        [XmlIgnore,
         Browsable(false)]
        public abstract Region Area { get; }

        [XmlIgnore,
         Browsable(false)]
        public abstract Point Center { get; set; }

        [XmlIgnore,
         Browsable(false)]
        public int Left
        {
            get { return Location.X; }
        }

        [XmlIgnore,
         Browsable(false)]
        public int Right
        {
            get { return Left + Width; }
        }

        [XmlIgnore,
         Browsable(false)]
        public int Bottom
        {
            get { return Top + Height; }
        }

        [XmlIgnore,
         Browsable(false)]
        public int Top
        {
            get { return Location.Y; }
        }

        [XmlIgnore,
         Browsable(false)]
        public int Width
        {
            get { return Size.Width; }
        }

        [XmlIgnore,
         Browsable(false)]
        public int Height
        {
            get { return Size.Height; }
        }

        protected abstract void SetParams();

        private bool highlighted;

        [XmlIgnore,
         Browsable(false)]
        public bool Highlighted
        {
            get { return highlighted; }
            set
            {
                highlighted = value;
                Invalidate();
            }
        }

        private bool selected;

        [XmlIgnore,
         Browsable(false)]
        public bool Selected
        {
            get { return selected; }
            set
            {
                if (selected != value)
                {
                    Highlighted = value;
                    if (TreeNode.TreeView != null)
                    {
                        if (value == true)
                        {
                            if (TreeNode.TreeView.SelectedNode != TreeNode)
                            {
                                TreeNode.TreeView.SelectedNode = TreeNode;
                            }
                        }
                        else
                        {
                            if (TreeNode.TreeView.SelectedNode == TreeNode)
                            {
                                TreeNode.TreeView.SelectedNode = null;
                            }
                        }
                    }
                    ((DP_Text) Text).Visible = value;
                    selected = value;
                }
            }
        }

        public abstract void Invalidate();

        public abstract void TypePaint(object sender, PaintEventArgs e);

        public abstract DP_ConcreteType Duplicate();

        public DP_ConcreteType()
        {
            SetParams();
            TreeNode.Tag = this;
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            if (parentDiagram is DP_Diagram)
            {
                Parent = (DP_Diagram) parentDiagram;
            }

            if (Parent.Parent != null)
            {
                Parent.Parent.LocationChanged += ParentLocationChanged;
            }

            // Add the text box
            if (Text != null)
            {
                ((DP_Text) Text).Initialize();
            }

            // Add the tree node
            if (Parent.Parent != null)
            {
                Parent.Parent.treeNode.Nodes.Add(treeNode);
            }
            else
            {
                app.Model.TreeRoot.Nodes.Add(treeNode);
            }

            // Needed to check the name for uniqueness after the parent is set.
            Name = Name;
        }

        public virtual void Destroy()
        {
            if (app.Selected.Contains(this))
            {
                app.Selected.Remove(this);
            }
            treeNode.Remove();
            Parent.Types.Remove(this);
            app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
        }

        protected virtual void Copy(DP_ConcreteType source)
        {
            Name = source.Name;
            DisplayName = source.DisplayName;
            ShowName = source.ShowName;
            PresentationType = source.PresentationType;
            SimulationType = source.SimulationType;
            Size = source.Size;
            NameFont = source.NameFont;
            Location = source.Location;
            Diagram.Types = app.Model.DuplicateTypes(source.Diagram.Types);

            foreach (DP_AbstractText.Instruction i in source.Text.Instructions)
            {
                DP_AbstractText.Instruction newI = new DP_AbstractText.Instruction();
                newI.Name = i.Name;
                newI.String = i.String;
                Text.Instructions.Add(newI);
            }
        }

        protected void ParentLocationChanged(object sender, EventArgs e)
        {
            Invalidate();
            OnLocationChanged(e);
        }

        public virtual void TypeMouseClick(object sender, MouseEventArgs e)
        {
            if (app.connectToolButton.Checked)
            {
                if (app.ConnectionStart == null)
                {
                    DomainProDesigner.DP_ConnectionSpec role = new DomainProDesigner.DP_ConnectionSpec();
                    role.Attached = this;
                    role.Offset = Diagram.PanelPointToTypeSpace(e.Location);
                    app.ConnectionStart = role;

                    app.Model.DiagramPanel.MouseMove += Parent.DiagramPanelConnLineDrag;
                    app.Model.DiagramPanel.Paint += Parent.DiagramPanelDrawConnLine;
                }
                else
                {
                    DP_Diagram sourceDiagram;
                    if (app.ConnectionStart.Attached != null)
                    {
                        sourceDiagram = app.ConnectionStart.Attached.Parent;
                    }
                    else
                    {
                        sourceDiagram = app.MainDiagram;
                    }

                    app.Model.DiagramPanel.MouseMove -= sourceDiagram.DiagramPanelConnLineDrag;
                    app.Model.DiagramPanel.Paint -= sourceDiagram.DiagramPanelDrawConnLine;
                    sourceDiagram.DiagramPanelConnLineDrag(sender, e);

                    DomainProDesigner.DP_ConnectionSpec role = new DomainProDesigner.DP_ConnectionSpec();
                    role.Attached = this;
                    role.Offset = Diagram.PanelPointToTypeSpace(e.Location);

                    DP_Diagram commonParent = FindCommonParent(app.ConnectionStart.Attached);

                    if (commonParent == null)
                    {
                        app.MainDiagram.ShowLineMenu(app.ConnectionStart, role);
                    }
                    else
                    {
                        commonParent.ShowLineMenu(app.ConnectionStart, role);
                    }
                    app.ConnectionStart = null;
                    sourceDiagram.connLine = false;
                    sourceDiagram.connStartPos = new Point(0, 0);
                    sourceDiagram.lastConnLine = new Point(0, 0);
                    sourceDiagram.lastConnMousePos = new Point(0, 0);
                }
            }
            else if (app.deleteToolButton.Checked)
            {
                Destroy();
                app.deleteToolButton.Checked = false;
                app.Selected.Clear();
                return;
            }
        }

        public virtual void TypeMouseDoubleClick(object sender, MouseEventArgs e)
        {
            app.Selected.Clear();
            if (Diagram != null)
            {
                Diagram.MakeMainDiagram();
            }
        }

        public virtual void TypeMouseDown(object sender, MouseEventArgs e)
        {
            if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
            {
                if (app.Selected.Contains(this))
                {
                    app.Selected.Remove(this);
                }
                else
                {
                    app.Selected.Add(this);
                }
            }
            else
            {
                if (!app.Selected.Contains(this))
                {
                    app.Selected.Clear();
                    app.Selected.Add(this);
                }
            }
        }

        public virtual void TypeMouseUp(object sender, MouseEventArgs e)
        {
        }

        public virtual void TypeMouseEnter(object sender, EventArgs e)
        {
            if (app.connectToolButton.Checked)
            {
                Highlighted = true;
            }
        }

        public virtual void TypeMouseLeave(object sender, EventArgs e)
        {
            if (app.connectToolButton.Checked)
            {
                Highlighted = false;
            }
        }

        public virtual void TypeMouseMove(object sender, MouseEventArgs e)
        {
            if (!Selected)
            {
                app.Model.DiagramPanel.Cursor = Cursors.Arrow;
            }
        }

        /*
        public virtual void TypeNameMouseClick(object sender, MouseEventArgs e)
        {
            TypeMouseClick(sender, new MouseEventArgs(e.Button, e.Clicks, e.X + nameLabel.Location.X, e.Y + nameLabel.Location.Y, e.Delta));
        }

        public virtual void TypeNameMouseDoubleClick(object sender, MouseEventArgs e)
        {
            TypeMouseDoubleClick(sender, new MouseEventArgs(e.Button, e.Clicks, e.X + nameLabel.Location.X, e.Y + nameLabel.Location.Y, e.Delta));
        }

        public virtual void TypeNameMouseDown(object sender, MouseEventArgs e)
        {
            TypeMouseDown(sender, new MouseEventArgs(e.Button, e.Clicks, e.X + nameLabel.Location.X, e.Y + nameLabel.Location.Y, e.Delta));
        }
         * */

        private DP_Diagram FindCommonParent(DP_ConcreteType relative)
        {
            DP_ConcreteType myNextParent = this;
            while (myNextParent != null)
            {
                DP_ConcreteType yourNextParent = relative;
                while (yourNextParent != null)
                {
                    if (yourNextParent == myNextParent)
                    {
                        return myNextParent.Diagram;
                    }
                    yourNextParent = yourNextParent.Parent.Parent;
                }
                myNextParent = myNextParent.Parent.Parent;
            }
            return null;
        }

/*
        protected virtual void ShowProperties()
        {
            
            app.propertiesWin.ClearProps();



            app.propertiesWin.Controls.Add(app.propertiesWin.propTabControl);
            app.propertiesWin.Controls.Add(nameProp.propNameLabel);
            app.propertiesWin.Controls.Add(nameProp.propValBox);

            foreach (DP_Property prop in properties)
            {
                if (prop.propTab == null)
                {
                    app.propertiesWin.Controls.Add(prop.propNameLabel);

                    app.propertiesWin.Controls.Add(prop.propValBox);              
                }
            }

            foreach (TabPage propTab in propTabs)
            {
                app.propertiesWin.propTabControl.Controls.Add(propTab);
            }

            // Make sure all properties are sized correctly.
            app.propertiesWin.ResizeProps();
        }
    */

        /*
        public virtual void ShowText()
        {
            foreach (Control c in app.textWin.Controls)
            {
                c.Hide();
            }
            ((DP_Text)Text).typeTextBox.Show();
            app.textWin.ResizeTextBox();
        }
         * */


        /*
        protected DP_EnumProperty GetEnumProperty(string propName, string[] newVals, DP_PropertyTab tab)
        {
            DP_EnumProperty prop = (DP_EnumProperty)Properties.Find(
                 delegate(DP_Property p)
                 {
                     return p.Name == propName;
                 });
            if (prop == null)
            {
                prop = new DP_EnumProperty(propName, newVals);
                Properties.Add(prop);
            }
            if (tab != null)
            {
                tab.Add(prop);
            }
            prop.Initialize();
            return prop;
        }

        protected DP_TextProperty GetTextProperty(string propName, string newVal, DP_PropertyTab tab)
        {
            DP_TextProperty prop = (DP_TextProperty)Properties.Find(
                 delegate(DP_Property p)
                 {
                     return p.Name == propName;
                 });
            if (prop == null)
            {
                prop = new DP_TextProperty(propName, newVal);
                Properties.Add(prop);
            }
            if (tab != null)
            {
                tab.Add(prop);
            }
            prop.Initialize();
            return prop;
        }
         * */
    }
}