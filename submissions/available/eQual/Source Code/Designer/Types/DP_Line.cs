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
using System.Drawing.Drawing2D;
using System.Drawing.Design;
using System.Drawing.Text;
using System.Linq;
using System.Text;
using System.IO;
using System.Windows.Forms;
using System.Windows.Forms.Design;
using System.Xml.Serialization;
using DomainPro.Core.Types;
using DomainPro.Designer.Controls;

namespace DomainPro.Designer.Types
{
    public abstract class DP_Line : DP_ConcreteType
    {
        public enum DP_LineForm
        {
            Line,
            Arc
        };

        [TypeConverter(typeof (DP_LinePropertiesTypeConverter))]
        public class DP_LineProperties
        {
            public event EventHandler PropertyChanged;

            private DP_LineForm form = DP_LineForm.Line;

            [DisplayNameAttribute("Form"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(DP_LineForm.Line),
             DescriptionAttribute("Sets the line form of instances of the type.")]
            public DP_LineForm Form
            {
                get { return form; }
                set
                {
                    if (form != value)
                    {
                        form = value;
                        if (PropertyChanged != null)
                        {
                            PropertyChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private int lineWidth = 1;

            [DisplayNameAttribute("Line Width"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(1),
             DescriptionAttribute("Sets the width of the line.")]
            public int LineWidth
            {
                get { return lineWidth; }
                set
                {
                    if (lineWidth != value)
                    {
                        lineWidth = value;
                        if (PropertyChanged != null)
                        {
                            PropertyChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private DashStyle borderStyle = DashStyle.Solid;

            [DisplayNameAttribute("Border Style"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(DashStyle.Solid),
             DescriptionAttribute("Sets the style of the shape borders.")]
            public DashStyle BorderStyle
            {
                get { return borderStyle; }
                set
                {
                    if (borderStyle != value)
                    {
                        borderStyle = value;
                        if (PropertyChanged != null)
                        {
                            PropertyChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private Color borderColor = Color.Black;

            [XmlIgnore,
             DisplayNameAttribute("Border Color"),
             CategoryAttribute("Presentation"),
             DescriptionAttribute("Sets the color of the shape borders.")]
            public Color BorderColor
            {
                get { return borderColor; }
                set
                {
                    if (borderColor != value)
                    {
                        borderColor = value;
                        if (PropertyChanged != null)
                        {
                            PropertyChanged(this, new EventArgs());
                        }
                    }
                }
            }

            [XmlElement("BorderColor"),
             BrowsableAttribute(false)]
            public DP_Color BorderColorArgb
            {
                get
                {
                    DP_Color newColor = new DP_Color();
                    newColor.Argb = borderColor.ToArgb();
                    return newColor;
                }
                set
                {
                    if (value.Argb == 0)
                    {
                        BorderColor = Color.Empty;
                    }
                    BorderColor = Color.FromArgb(value.Argb);
                }
            }

            private int borderWidth = 1;

            [DisplayNameAttribute("Border Width"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(1),
             DescriptionAttribute("Sets the width of the shape borders.")]
            public int BorderWidth
            {
                get { return borderWidth; }
                set
                {
                    if (borderWidth != value)
                    {
                        borderWidth = value;
                        if (PropertyChanged != null)
                        {
                            PropertyChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private DashStyle fillStyle = DashStyle.Solid;

            [DisplayNameAttribute("Fill Style"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(DashStyle.Solid),
             DescriptionAttribute("Sets the fill style of the line.")]
            public DashStyle FillStyle
            {
                get { return fillStyle; }
                set
                {
                    if (fillStyle != value)
                    {
                        fillStyle = value;
                        if (PropertyChanged != null)
                        {
                            PropertyChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private Color fillColor = Color.Empty;

            [XmlIgnore,
             DisplayNameAttribute("Fill Color"),
             CategoryAttribute("Presentation"),
             DescriptionAttribute("Sets the color of the shape fill.")]
            public Color FillColor
            {
                get { return fillColor; }
                set
                {
                    if (fillColor != value)
                    {
                        fillColor = value;
                        if (PropertyChanged != null)
                        {
                            PropertyChanged(this, new EventArgs());
                        }
                    }
                }
            }

            [XmlElement("FillColor"),
             BrowsableAttribute(false)]
            public DP_Color FillColorArgb
            {
                get
                {
                    DP_Color newColor = new DP_Color();
                    newColor.Argb = fillColor.ToArgb();
                    return newColor;
                }
                set
                {
                    if (value.Argb == 0)
                    {
                        FillColor = Color.Empty;
                    }
                    FillColor = Color.FromArgb(value.Argb);
                }
            }

            private DP_RoleProperties role1 = new DP_Line.DP_RoleProperties();

            public DP_RoleProperties Role1
            {
                get { return role1; }
                set { role1 = value; }
            }

            private DP_RoleProperties role2 = new DP_Line.DP_RoleProperties();

            public DP_RoleProperties Role2
            {
                get { return role2; }
                set { role2 = value; }
            }
        }

        public class DP_LinePropertiesTypeConverter : TypeConverter
        {
            public override object ConvertTo(
                ITypeDescriptorContext context,
                System.Globalization.CultureInfo culture,
                object value,
                Type destinationType)
            {
                if (destinationType == typeof (string))
                {
                    DP_LineProperties props = (DP_LineProperties) value;
                    return (
                        props.Form.ToString() + ", " +
                        props.LineWidth.ToString() + ", " +
                        props.BorderStyle.ToString() + ", " +
                        props.BorderColor.ToString() + ", " +
                        props.BorderWidth.ToString() + ", " +
                        props.FillStyle.ToString() + ", " +
                        props.FillColor.ToString());
                }
                return base.ConvertTo(context, culture, value, destinationType);
            }

            public override PropertyDescriptorCollection GetProperties(ITypeDescriptorContext context, object value,
                Attribute[] attributes)
            {
                return TypeDescriptor.GetProperties(typeof (DP_LineProperties), attributes);
            }

            public override bool GetPropertiesSupported(ITypeDescriptorContext context)
            {
                return true;
            }
        }

        [TypeConverter(typeof (DP_RolePropertiesTypeConverter))]
        public class DP_RoleProperties
        {
            public event EventHandler DisplayedNameChanged;
            public event EventHandler NameVisibleChanged;
            public event EventHandler FontChanged;
            public event EventHandler IconChanged;
            public event EventHandler OffsetChanged;

            private string displayedName = "";

            [DisplayNameAttribute("Displayed Role Name"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(""),
             DescriptionAttribute("Sets the text displayed for the role.")]
            public string DisplayedName
            {
                get { return displayedName; }
                set
                {
                    if (displayedName != value)
                    {
                        displayedName = value;
                        if (DisplayedNameChanged != null)
                        {
                            DisplayedNameChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private bool nameVisible = true;

            [DisplayNameAttribute("Show Role Name?"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(true),
             DescriptionAttribute("Sets whether the name of the role is visible.")]
            public bool NameVisible
            {
                get { return nameVisible; }
                set
                {
                    if (nameVisible != value)
                    {
                        nameVisible = value;
                        if (NameVisibleChanged != null)
                        {
                            NameVisibleChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private Font font = new Font("Segoe UI", (float) 9, FontStyle.Regular);

            [XmlIgnore,
             DisplayNameAttribute("Role Font"),
             CategoryAttribute("Presentation"),
             DescriptionAttribute("Sets the font of the role name.")]
            public Font Font
            {
                get { return font; }
                set
                {
                    if (font != value)
                    {
                        font = value;
                        if (FontChanged != null)
                        {
                            FontChanged(this, new EventArgs());
                        }
                    }
                }
            }

            [XmlElement("Font"),
             BrowsableAttribute(false)]
            public DP_Font TextFont
            {
                get
                {
                    DP_Font newFont = new DP_Font();
                    newFont.FontFamily = font.FontFamily.Name;
                    newFont.Size = font.Size;
                    newFont.Style = font.Style;
                    return newFont;
                }
                set { Font = new Font(value.FontFamily, value.Size, value.Style); }
            }

            private string icon = "";

            [DisplayNameAttribute("Icon"),
             CategoryAttribute("Presentation"),
             DefaultValueAttribute(""),
             DescriptionAttribute("Sets the icon to display at the role end."),
             Editor(typeof (FileNameEditor), typeof (UITypeEditor))]
            public string Icon
            {
                get { return icon; }
                set
                {
                    if (icon != value)
                    {
                        icon = value;

                        if (IconChanged != null)
                        {
                            IconChanged(this, new EventArgs());
                        }
                    }
                }
            }

            private Point offset = new Point(0, 0);

            [BrowsableAttribute(false)]
            public Point Offset
            {
                get { return offset; }
                set
                {
                    if (offset != value)
                    {
                        offset = value;
                        if (OffsetChanged != null)
                        {
                            OffsetChanged(this, new EventArgs());
                        }
                    }
                }
            }
        }

        public class DP_RolePropertiesTypeConverter : TypeConverter
        {
            public override object ConvertTo(
                ITypeDescriptorContext context,
                System.Globalization.CultureInfo culture,
                object value,
                Type destinationType)
            {
                if (destinationType == typeof (string))
                {
                    DP_RoleProperties props = (DP_RoleProperties) value;
                    return (
                        props.NameVisible.ToString() + ", " +
                        props.Font.ToString() + ", " +
                        props.Icon.ToString() + ", " +
                        props.Offset.ToString());
                }
                return base.ConvertTo(context, culture, value, destinationType);
            }

            public override PropertyDescriptorCollection GetProperties(ITypeDescriptorContext context, object value,
                Attribute[] attributes)
            {
                return TypeDescriptor.GetProperties(typeof (DP_RoleProperties), attributes);
            }

            public override bool GetPropertiesSupported(ITypeDescriptorContext context)
            {
                return true;
            }
        }

        private DP_LineProperties lineProperties = new DP_LineProperties();

        [DisplayNameAttribute("Line Properties"),
         CategoryAttribute("Instance"),
         DescriptionAttribute("Sets the appearance of the line.")]
        public DP_LineProperties LineProperties
        {
            get { return lineProperties; }
            set
            {
                lineProperties = value;
                role1.RoleProperties = lineProperties.Role1;
                role2.RoleProperties = lineProperties.Role2;
            }
        }

        public override Point Location
        {
            get
            {
                if (Parent != null)
                {
                    return
                        Parent.PanelPointToTypeSpace(new Point(Math.Min(role1.ScreenEnd.X, role2.ScreenEnd.X),
                            Math.Min(role1.ScreenEnd.Y, role2.ScreenEnd.Y)));
                }
                else
                {
                    return new Point(Math.Min(role1.End.X, role2.End.X), Math.Min(role1.End.Y, role2.End.Y));
                }
            }
            set { }
        }

        public override Size Size
        {
            get
            {
                return new Size(Math.Abs(role1.ScreenEnd.X - role2.ScreenEnd.X),
                    Math.Abs(role1.ScreenEnd.Y - role2.ScreenEnd.Y));
            }
            set { }
        }

        [XmlIgnore,
         BrowsableAttribute(false)]
        public override Point Center
        {
            get
            {
                return new Point(
                    (role1.ScreenEnd.X + role2.ScreenEnd.X)/2,
                    (role1.ScreenEnd.Y + role2.ScreenEnd.Y)/2);
            }
            set { }
        }

        [XmlIgnore,
         BrowsableAttribute(false)]
        public override Region Area
        {
            get
            {
                if (Hidden)
                {
                    Region r = new Region();
                    r.MakeEmpty();
                    return r;
                }
                else
                {
                    return ComputeBounds(role1.ScreenEnd, role2.ScreenEnd);
                }
            }
        }

        private Guid role1Id = Guid.Empty;

        [BrowsableAttribute(false)]
        public Guid Role1Id
        {
            get { return role1Id; }
            set { role1Id = value; }
        }

        private Guid role2Id = Guid.Empty;

        [BrowsableAttribute(false)]
        public Guid Role2Id
        {
            get { return role2Id; }
            set { role2Id = value; }
        }

        [XmlIgnore,
         BrowsableAttribute(false)]
        public DP_ConcreteType Role1Attached
        {
            get { return role1.Attached; }
            set
            {
                if (role1.Attached != null)
                {
                    role1.Attached.Lines.Remove(this);
                    role1.Attached.LocationChanged -= EndpointChanged;
                    role1.Attached.SizeChanged -= AttachedSizeChanged;
                    if (value == null && Parent != null)
                    {
                        role1.RoleProperties.Offset = Parent.PanelPointToDiagramSpace(role1.ScreenEnd);
                    }
                }

                if (value != null)
                {
                    role1.Attached = value;
                    Role1Id = role1.Attached.Id;
                    role1.Attached.Lines.Add(this);
                    role1.Attached.LocationChanged += EndpointChanged;
                    role1.Attached.SizeChanged += AttachedSizeChanged;
                }
                else
                {
                    role1.Attached = null;
                    Role1Id = Guid.Empty;
                }

                EndpointChanged(this, new EventArgs());
            }
        }

        [XmlIgnore,
         BrowsableAttribute(false)]
        public DP_ConcreteType Role2Attached
        {
            get { return role2.Attached; }
            set
            {
                if (role2.Attached != null)
                {
                    role2.Attached.Lines.Remove(this);
                    role2.Attached.LocationChanged -= EndpointChanged;
                    role2.Attached.SizeChanged -= AttachedSizeChanged;
                    if (value == null && Parent != null)
                    {
                        role2.RoleProperties.Offset = Parent.PanelPointToDiagramSpace(role2.ScreenEnd);
                    }
                }

                if (value != null)
                {
                    role2.Attached = value;
                    Role2Id = role2.Attached.Id;
                    role2.Attached.Lines.Add(this);
                    role2.Attached.LocationChanged += EndpointChanged;
                    role2.Attached.SizeChanged += AttachedSizeChanged;
                }
                else
                {
                    role2.Attached = null;
                    Role2Id = Guid.Empty;
                }

                EndpointChanged(this, new EventArgs());
            }
        }

        private DP_Role role1 = new DP_Role();
        private DP_Role role2 = new DP_Role();

        protected string role1Name;
        protected string role2Name;

        private float angle;
        private Point lastEndpoint1;
        private Point lastEndpoint2;
        private Size nameSize;

        private bool roleDragStarted = false;
        private Point roleDragStartPoint = new Point(0, 0);
        private DP_Role draggedRole = null;
        private DP_ConcreteType typeAtMouseLocation;

        public DP_Line()
        {
        }

        public DP_Line(DomainProDesigner.DP_ConnectionSpec newRole1, DomainProDesigner.DP_ConnectionSpec newRole2)
        {
            if (newRole1.Attached != null)
            {
                Role1Id = newRole1.Attached.Id;
            }
            role1.RoleProperties = LineProperties.Role1;
            role1.RoleProperties.Offset = newRole1.Offset;
            if (newRole2.Attached != null)
            {
                Role2Id = newRole2.Attached.Id;
            }
            role2.RoleProperties = LineProperties.Role2;
            role2.RoleProperties.Offset = newRole2.Offset;
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);

            if (Role1Attached == null && Role1Id != Guid.Empty)
            {
                Role1Attached = ((DP_ConcreteType) app.Model.FindTypeById(Role1Id));
            }
            if (Role2Attached == null && Role2Id != Guid.Empty)
            {
                Role2Attached = ((DP_ConcreteType) app.Model.FindTypeById(Role2Id));
            }

            app.Model.DiagramPanel.Controls.Add(role1.Label);
            app.Model.DiagramPanel.Controls.Add(role2.Label);

            // Property changed events
            LineProperties.PropertyChanged += LinePropertyChanged;
            role1.EndChanged += EndpointChanged;
            role2.EndChanged += EndpointChanged;

            EndpointChanged(this, new EventArgs());
        }

        public override void Destroy()
        {
            base.Destroy();

            Role1Attached = null;
            Role2Attached = null;

            app.Model.DiagramPanel.Controls.Remove(role1.Label);
            role1.Label.Dispose();
            app.Model.DiagramPanel.Controls.Remove(role2.Label);
            role2.Label.Dispose();

            app.Model.DiagramPanel.Invalidate(false);
        }

        protected override void Copy(DP_ConcreteType source)
        {
            if (source is DP_Line)
            {
                base.Copy(source);
                DP_Line srcLine = source as DP_Line;
                LineProperties.Form = srcLine.LineProperties.Form;
                LineProperties.LineWidth = srcLine.LineProperties.LineWidth;
                LineProperties.BorderStyle = srcLine.LineProperties.BorderStyle;
                LineProperties.BorderColor = srcLine.LineProperties.BorderColor;
                LineProperties.BorderWidth = srcLine.LineProperties.BorderWidth;
                LineProperties.FillStyle = srcLine.LineProperties.FillStyle;
                LineProperties.FillColor = srcLine.LineProperties.FillColor;
                LineProperties.Role1.NameVisible = srcLine.LineProperties.Role1.NameVisible;
                LineProperties.Role1.Font = srcLine.LineProperties.Role1.Font;
                LineProperties.Role1.Offset = srcLine.LineProperties.Role1.Offset;
                LineProperties.Role1.Icon = srcLine.LineProperties.Role1.Icon;
                LineProperties.Role2.NameVisible = srcLine.LineProperties.Role2.NameVisible;
                LineProperties.Role2.Font = srcLine.LineProperties.Role2.Font;
                LineProperties.Role2.Offset = srcLine.LineProperties.Role2.Offset;
                LineProperties.Role2.Icon = srcLine.LineProperties.Role2.Icon;
                role1.RoleProperties = LineProperties.Role1;
                role2.RoleProperties = LineProperties.Role2;
            }
        }

        public override void TypeMouseDown(object sender, MouseEventArgs e)
        {
            base.TypeMouseDown(sender, e);

            if (!app.connectToolButton.Checked)
            {
                Rectangle role1Rect = new Rectangle(
                    role1.ScreenEnd.X - role1.Size.Width/2, role1.ScreenEnd.Y - role1.Size.Height/2,
                    role1.Size.Width, role1.Size.Height);
                Rectangle role2Rect = new Rectangle(
                    role2.ScreenEnd.X - role2.Size.Width/2, role2.ScreenEnd.Y - role2.Size.Height/2,
                    role2.Size.Width, role2.Size.Height);
                if (role1Rect.Contains(e.Location))
                {
                    roleDragStartPoint = e.Location;
                    draggedRole = role1;
                    app.Model.DiagramPanel.MouseMove += LineRoleDrag;
                    app.Model.DiagramPanel.MouseUp += LineRoleDragMouseUp;
                }
                else if (role2Rect.Contains(e.Location))
                {
                    roleDragStartPoint = e.Location;
                    draggedRole = role2;
                    app.Model.DiagramPanel.MouseMove += LineRoleDrag;
                    app.Model.DiagramPanel.MouseUp += LineRoleDragMouseUp;
                }
            }
        }

        private void LineRoleDrag(object sender, MouseEventArgs e)
        {
            if (!roleDragStarted &&
                (Math.Abs(e.X - roleDragStartPoint.X) > app.StartDragSize ||
                 Math.Abs(e.Y - roleDragStartPoint.Y) > app.StartDragSize))
            {
                roleDragStarted = true;
                if (draggedRole.Attached != null)
                {
                    if (draggedRole == role1)
                    {
                        Role1Attached = null;
                    }
                    else if (draggedRole == role2)
                    {
                        Role2Attached = null;
                    }
                }
                app.Model.DiagramPanel.MouseMove -= Parent.DiagramPanelSelectBoxDrag;
                app.Model.DiagramPanel.MouseUp -= Parent.DiagramPanelSelectBoxMouseUp;
            }

            if (roleDragStarted)
            {
                DP_ConcreteType dropTarget;
                if (draggedRole == role1)
                {
                    dropTarget = Parent.GetTypeAtDropLocation(role1.ScreenEnd, this);
                }
                else
                {
                    dropTarget = Parent.GetTypeAtDropLocation(role2.ScreenEnd, this);
                }
                if (typeAtMouseLocation != dropTarget)
                {
                    if (typeAtMouseLocation != null)
                    {
                        typeAtMouseLocation.Highlighted = false;
                    }
                    if (dropTarget != null)
                    {
                        dropTarget.Highlighted = true;
                    }
                    typeAtMouseLocation = dropTarget;
                }

                draggedRole.RoleProperties.Offset = Parent.PanelPointToDiagramSpace(e.Location);

                app.Model.DiagramPanel.Update();
                app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
            }
        }

        private void LineRoleDragMouseUp(object sender, MouseEventArgs e)
        {
            app.Model.DiagramPanel.MouseMove -= LineRoleDrag;
            app.Model.DiagramPanel.MouseUp -= LineRoleDragMouseUp;

            LineRoleDrag(sender, e);

            if (roleDragStarted)
            {
                DP_ConcreteType dropTarget = Parent.GetTypeAtDropLocation(draggedRole.ScreenEnd, this);
                if (dropTarget != null && dropTarget != Parent.Parent)
                {
                    dropTarget.Highlighted = false;
                    draggedRole.RoleProperties.Offset = dropTarget.Diagram.PanelPointToTypeSpace(e.Location);
                    if (draggedRole == role1)
                    {
                        Role1Attached = dropTarget;
                    }
                    else if (draggedRole == role2)
                    {
                        Role2Attached = dropTarget;
                    }
                }

                roleDragStarted = false;
                draggedRole = null;
                typeAtMouseLocation = null;
            }
        }

        protected void LinePropertyChanged(object sender, EventArgs e)
        {
            Invalidate();
        }

        public override void TypePaint(object sender, PaintEventArgs e)
        {
            if (role1.ScreenEnd == role2.ScreenEnd || Hidden)
            {
                return;
            }

            lastEndpoint1 = role1.ScreenEnd;
            lastEndpoint2 = role2.ScreenEnd;

            int role1MaxDim = Math.Max(role1.Size.Width, role1.Size.Height);
            int role2MaxDim = Math.Max(role2.Size.Width, role2.Size.Height);
            int margin = Math.Max(
                Math.Max(LineProperties.LineWidth/2 + LineProperties.BorderWidth + app.SelectionBorderWidth,
                    nameSize.Width),
                Math.Max(role1MaxDim, role2MaxDim));

            Bitmap image = new Bitmap(
                Width + margin*2,
                Height + margin*2);
            Graphics graphics = Graphics.FromImage(image);
            graphics.SmoothingMode = SmoothingMode.HighQuality;
            graphics.TextRenderingHint = TextRenderingHint.AntiAlias;

            Point role1End = new Point(Diagram.PanelPointToTypeSpace(role1.ScreenEnd).X + margin,
                Diagram.PanelPointToTypeSpace(role1.ScreenEnd).Y + margin);
            Point role2End = new Point(Diagram.PanelPointToTypeSpace(role2.ScreenEnd).X + margin,
                Diagram.PanelPointToTypeSpace(role2.ScreenEnd).Y + margin);

            LinePaint(graphics, role1End, role2End, margin);

            IconPaint(graphics, role1End, role2End, margin);

            if (Highlighted)
            {
                HighlightPaint(graphics, role1End, role2End, margin);
            }

            if (ShowName)
            {
                NamePaint(graphics, role1End, role2End, margin);
            }

            Rectangle panelRect = new Rectangle(
                new Point(Parent.TypePointToPanelSpace(Location).X - margin,
                    Parent.TypePointToPanelSpace(Location).Y - margin), image.Size);
            panelRect.Intersect(e.ClipRectangle);
            Rectangle imageRect = new Rectangle(
                new Point(Diagram.PanelPointToTypeSpace(panelRect.Location).X + margin,
                    Diagram.PanelPointToTypeSpace(panelRect.Location).Y + margin), panelRect.Size);
            e.Graphics.DrawImage(image, panelRect, imageRect, GraphicsUnit.Pixel);

            if (Diagram.IsMainDiagram)
            {
                foreach (DP_ConcreteType type in Structure.Types)
                {
                    if (!e.ClipRectangle.IsEmpty)
                    {
                        type.TypePaint(sender, new PaintEventArgs(e.Graphics, e.ClipRectangle));
                    }
                }
            }
        }

        private void LinePaint(Graphics graphics, Point role1End, Point role2End, int margin)
        {
            if (role1.Icon != null)
            {
                role1End.X +=
                    (int) Math.Round((role1.Icon.Width/2 - LineProperties.BorderWidth)*Math.Cos(angle/180*Math.PI));
                role1End.Y +=
                    (int) Math.Round((role1.Icon.Width/2 - LineProperties.BorderWidth)*Math.Sin(angle/180*Math.PI));
            }

            if (role2.Icon != null)
            {
                role2End.X -=
                    (int) Math.Round((role2.Icon.Width/2 - LineProperties.BorderWidth)*Math.Cos(angle/180*Math.PI));
                role2End.Y -=
                    (int) Math.Round((role2.Icon.Width/2 - LineProperties.BorderWidth)*Math.Sin(angle/180*Math.PI));
            }

            Pen fillPen = new Pen(LineProperties.FillColor, LineProperties.LineWidth);
            fillPen.DashStyle = LineProperties.FillStyle;

            graphics.DrawLine(
                fillPen,
                role1End,
                role2End);
            fillPen.Dispose();

            if (LineProperties.BorderWidth != 0)
            {
                Pen borderPen = new Pen(LineProperties.BorderColor, LineProperties.BorderWidth);
                borderPen.DashStyle = LineProperties.BorderStyle;

                GraphicsPath path2 = new GraphicsPath();
                if (role1End != role2End)
                {
                    path2.AddLine(role1End, role2End);
                    path2.Widen(new Pen(Color.Black, LineProperties.LineWidth));
                }

                graphics.DrawPath(borderPen, path2);

                borderPen.Dispose();
            }
        }

        private void IconPaint(Graphics graphics, Point role1End, Point role2End, int margin)
        {
            if (role1.Icon != null)
            {
                Bitmap displayIcon = role1.Icon;
                float rotateAngle = angle + 180;
                displayIcon = rotateCenter(displayIcon, rotateAngle);
                Point iconPos = new Point(role1End.X - displayIcon.Width/2, role1End.Y - displayIcon.Height/2);
                graphics.DrawImage(displayIcon, iconPos);
            }

            if (role2.Icon != null)
            {
                Bitmap displayIcon = role2.Icon;
                float rotateAngle = angle;
                displayIcon = rotateCenter(displayIcon, rotateAngle);
                Point iconPos = new Point(role2End.X - displayIcon.Width/2, role2End.Y - displayIcon.Height/2);
                graphics.DrawImage(displayIcon, iconPos);
            }
        }

        private void HighlightPaint(Graphics graphics, Point role1End, Point role2End, int margin)
        {
            Pen pen = new Pen(app.SelectionColor, app.SelectionBorderWidth);
            GraphicsPath path = new GraphicsPath();
            path.AddLine(role1End, role2End);
            if (role1End != role2End)
            {
                path.Widen(new Pen(Color.Empty, LineProperties.LineWidth + LineProperties.BorderWidth + 1));
                graphics.DrawPath(pen, path);
            }
            Brush brush = new SolidBrush(app.SelectionColor);
            graphics.FillRectangle(
                brush,
                role1End.X - app.SelectionMarkerSize.Width/2,
                role1End.Y - app.SelectionMarkerSize.Height/2,
                app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);
            graphics.FillRectangle(
                brush,
                role2End.X - app.SelectionMarkerSize.Width/2,
                role2End.Y - app.SelectionMarkerSize.Height/2,
                app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);

            pen.Dispose();
        }

        private void NamePaint(Graphics graphics, Point role1End, Point role2End, int margin)
        {
            StringFormat format = new StringFormat();
            format.LineAlignment = StringAlignment.Center;
            format.Alignment = StringAlignment.Center;
            nameSize = graphics.MeasureString(DisplayName, NameFont).ToSize();
            graphics.DrawString(
                DisplayName,
                NameFont,
                SystemBrushes.WindowText,
                new Point((role1End.X + role2End.X)/2, (role1End.Y + role2End.Y)/2),
                format);
        }

        private Region ComputeBounds(Point end1, Point end2)
        {
            // Create path which contains wide line
            GraphicsPath path = new GraphicsPath();
            Region region;
            if (end1 != end2)
            {
                float xDiff = end1.X - end2.X;
                float yDiff = end1.Y - end2.Y;
                float length = (float) Math.Sqrt(Math.Pow(xDiff, 2) + Math.Pow(yDiff, 2));
                if (yDiff == 0)
                    yDiff = 0.1F;
                float radians = (float) (Math.Asin(yDiff/length));
                int xSign = xDiff > 0 ? -1 : 1;
                int ySign = 1; //yDiff > 0 ? 1 : -1;

                end1.X -= (int) (Math.Floor((LineProperties.BorderWidth*2 + 1)*Math.Cos(radians))*xSign);
                end1.Y += (int) (Math.Floor((LineProperties.BorderWidth*2 + 1)*Math.Sin(radians))*ySign);

                end2.X += (int) (Math.Floor((LineProperties.BorderWidth*2 + 1)*Math.Cos(radians))*xSign);
                end2.Y -= (int) (Math.Floor((LineProperties.BorderWidth*2 + 1)*Math.Sin(radians))*ySign);

                path.AddLine(end1, end2);

                path.Widen(new Pen(Color.Black,
                    LineProperties.LineWidth + LineProperties.BorderWidth*2 + app.SelectionBorderWidth*2 + 1));

                // Create region from the path
                region = new Region(path);

                // Add the name to the region
                region.Union(new Rectangle((end1.X + end2.X)/2 - nameSize.Width/2,
                    (end1.Y + end2.Y)/2 - nameSize.Height/2, nameSize.Width, nameSize.Height));

                // Add areas around ends to the region
                region.Union(new Rectangle(
                    role1.ScreenEnd.X - DomainProDesigner.Instance.LineEndSize/2,
                    role1.ScreenEnd.Y - DomainProDesigner.Instance.LineEndSize/2,
                    DomainProDesigner.Instance.LineEndSize, DomainProDesigner.Instance.LineEndSize));

                region.Union(new Rectangle(
                    role2.ScreenEnd.X - DomainProDesigner.Instance.LineEndSize/2,
                    role2.ScreenEnd.Y - DomainProDesigner.Instance.LineEndSize/2,
                    DomainProDesigner.Instance.LineEndSize, DomainProDesigner.Instance.LineEndSize));
            }
            else
            {
                region = new Region();
                region.MakeEmpty();
            }

            /*
            Size end1RectSize = new Size(
                Math.Max(LineProperties.LineWidth, Math.Max(role1.Size.Width, role1.Size.Height)) + 1,
                Math.Max(LineProperties.LineWidth, Math.Max(role1.Size.Width, role1.Size.Height)) + 1);
            Size end2RectSize = new Size(
                Math.Max(LineProperties.LineWidth, Math.Max(role2.Size.Width, role2.Size.Height)) + 1,
                Math.Max(LineProperties.LineWidth, Math.Max(role2.Size.Width, role2.Size.Height)) + 1);
             * */
            /*
            Rectangle end1Rect = new Rectangle(
                end1.X - (LineProperties.LineWidth / 2 + LineProperties.BorderWidth),
                end1.Y - (LineProperties.LineWidth / 2 + LineProperties.BorderWidth),
                LineProperties.LineWidth + 2 * LineProperties.BorderWidth,
                LineProperties.LineWidth + 2 * LineProperties.BorderWidth);
            Rectangle end2Rect = new Rectangle(
                end2.X - (LineProperties.LineWidth / 2 + LineProperties.BorderWidth),
                end2.Y - (LineProperties.LineWidth / 2 + LineProperties.BorderWidth),
                LineProperties.LineWidth + 2 * LineProperties.BorderWidth,
                LineProperties.LineWidth + 2 * LineProperties.BorderWidth);
            region.Union(end1Rect);
            region.Union(end2Rect);
             * */
            return region;
        }

        public override void Invalidate()
        {
            if (Parent == null)
            {
                return;
            }
            app.Model.DiagramPanel.Invalidate(Area, false);
            app.Model.DiagramPanel.Invalidate(ComputeBounds(lastEndpoint1, lastEndpoint2), false);

            app.Model.DiagramPanel.Invalidate(
                new Rectangle(
                    lastEndpoint1.X - app.SelectionMarkerSize.Width/2 - 1,
                    lastEndpoint1.Y - app.SelectionMarkerSize.Height/2 - 1,
                    app.SelectionMarkerSize.Width + 2,
                    app.SelectionMarkerSize.Height + 2));
            app.Model.DiagramPanel.Invalidate(
                new Rectangle(
                    lastEndpoint2.X - app.SelectionMarkerSize.Width/2 - 1,
                    lastEndpoint2.Y - app.SelectionMarkerSize.Height/2 - 1,
                    app.SelectionMarkerSize.Width + 2,
                    app.SelectionMarkerSize.Height + 2));

            /*
            Parent.diagramPanel.Invalidate(
                new Rectangle(
                    Role1.Endpoint.X - app.SelectionMarkerSize.Width / 2, Role1.Endpoint.Y, 17, 17));
            Parent.diagramPanel.Invalidate(new Rectangle(Role2.Endpoint.X - app.SelectionMarkerSize, Role2.Endpoint.Y, 17, 17));
            */
            /*
            Brush brush = new SolidBrush(Color.Red);
            Graphics g = Parent.diagramPanel.CreateGraphics();
            g.FillRectangle(brush, new Rectangle(lastEndpoint1.X - 7, lastEndpoint1.Y, 17, 17));
            g.FillRectangle(brush, new Rectangle(lastEndpoint2.X - 7, lastEndpoint2.Y, 17, 17));
            g.FillRectangle(brush, new Rectangle(Role1.Endpoint.X - 7, Role1.Endpoint.Y, 17, 17));
            g.FillRectangle(brush, new Rectangle(Role2.Endpoint.X - 7, Role2.Endpoint.Y, 17, 17));
            */
            /*
            Parent.diagramPanel.Invalidate(
                new Rectangle(lastEndpoint1.X - 2, lastEndpoint1.Y - 2, Role1.EndPanel.Width + 4, Role1.EndPanel.Height + 4));
            Parent.diagramPanel.Invalidate(
                new Rectangle(lastEndpoint2.X - 2, lastEndpoint2.Y - 2, Role2.EndPanel.Width + 4, Role2.EndPanel.Height + 4));

            Parent.diagramPanel.Invalidate(
                new Rectangle(Role1.EndPanel.Left - 2, Role1.EndPanel.Top - 2, Role1.EndPanel.Width + 4, Role1.EndPanel.Height + 4));
            Parent.diagramPanel.Invalidate(
                new Rectangle(Role2.EndPanel.Left - 2, Role2.EndPanel.Top - 2, Role2.EndPanel.Width + 4, Role2.EndPanel.Height + 4));
             * */

            if (role1.Icon != null)
            {
                int maxDimension = Math.Max(role1.Icon.Width, role1.Icon.Height);
                Rectangle rect1 = new Rectangle(
                    role1.ScreenEnd.X - maxDimension,
                    role1.ScreenEnd.Y - maxDimension,
                    maxDimension*2,
                    maxDimension*2);
                app.Model.DiagramPanel.Invalidate(rect1);
                Rectangle rect2 = new Rectangle(
                    lastEndpoint1.X - maxDimension,
                    lastEndpoint1.Y - maxDimension,
                    maxDimension*2,
                    maxDimension*2);
                app.Model.DiagramPanel.Invalidate(rect2);
                //Graphics g = Parent.diagramPanel.CreateGraphics();
                //Brush b1 = new SolidBrush(Color.Red);
                //g.FillRectangle(b1, rect1);
                //g.FillRectangle(b1, rect2);
            }
            if (role2.Icon != null)
            {
                int maxDimension = Math.Max(role2.Icon.Width, role2.Icon.Height);
                Rectangle rect1 = new Rectangle(
                    role2.ScreenEnd.X - maxDimension,
                    role2.ScreenEnd.Y - maxDimension,
                    maxDimension*2,
                    maxDimension*2);
                app.Model.DiagramPanel.Invalidate(rect1);
                Rectangle rect2 = new Rectangle(
                    lastEndpoint2.X - maxDimension,
                    lastEndpoint2.Y - maxDimension,
                    maxDimension*2,
                    maxDimension*2);
                app.Model.DiagramPanel.Invalidate(rect2);
                //Graphics g = Parent.diagramPanel.CreateGraphics();
                //Brush b1 = new SolidBrush(Color.Red);
                //g.FillRectangle(b1, rect1);
                //g.FillRectangle(b1, rect2);
            }
        }

        private void EndpointChanged(object sender, EventArgs e)
        {
            float xDiff = role1.ScreenEnd.X - role2.ScreenEnd.X;
            float yDiff = role1.ScreenEnd.Y - role2.ScreenEnd.Y;
            float length = (float) Math.Sqrt(Math.Pow(xDiff, 2) + Math.Pow(yDiff, 2));

            if (xDiff == 0)
                xDiff = 0.1F;
            if (yDiff == 0)
                yDiff = 0.1F;

            float slope = Math.Abs(yDiff/xDiff);
            angle = (float) (Math.Asin(yDiff/length)*180/Math.PI);

            if (xDiff < 0)
            {
                angle = angle*-1;
            }
            else
            {
                angle += 180;
            }
            Invalidate();
            OnLocationChanged(new EventArgs());
        }

        private void AttachedSizeChanged(object sender, EventArgs e)
        {
            if ((role1.Snapped & DP_Role.SnappedEdges.Center) == DP_Role.SnappedEdges.Center)
            {
                role1.RoleProperties.Offset = new Point(role1.Attached.Width/2, role1.Attached.Height/2);
            }

            if ((role1.Snapped & DP_Role.SnappedEdges.Left) == DP_Role.SnappedEdges.Left)
            {
                role1.RoleProperties.Offset = new Point(0, role1.RoleProperties.Offset.Y);
            }
            else if ((role1.Snapped & DP_Role.SnappedEdges.Right) == DP_Role.SnappedEdges.Right)
            {
                role1.RoleProperties.Offset = new Point(role1.Attached.Width, role1.RoleProperties.Offset.Y);
            }

            if ((role1.Snapped & DP_Role.SnappedEdges.Top) == DP_Role.SnappedEdges.Top)
            {
                role1.RoleProperties.Offset = new Point(role1.RoleProperties.Offset.X, 0);
            }
            else if ((role1.Snapped & DP_Role.SnappedEdges.Bottom) == DP_Role.SnappedEdges.Bottom)
            {
                role1.RoleProperties.Offset = new Point(role1.RoleProperties.Offset.X, role1.Attached.Height);
            }

            if ((role2.Snapped & DP_Role.SnappedEdges.Center) == DP_Role.SnappedEdges.Center)
            {
                role2.RoleProperties.Offset = new Point(role2.Attached.Width/2, role2.Attached.Height/2);
            }

            if ((role2.Snapped & DP_Role.SnappedEdges.Left) == DP_Role.SnappedEdges.Left)
            {
                role2.RoleProperties.Offset = new Point(0, role2.RoleProperties.Offset.Y);
            }
            else if ((role2.Snapped & DP_Role.SnappedEdges.Right) == DP_Role.SnappedEdges.Right)
            {
                role2.RoleProperties.Offset = new Point(role2.Attached.Width, role2.RoleProperties.Offset.Y);
            }

            if ((role2.Snapped & DP_Role.SnappedEdges.Top) == DP_Role.SnappedEdges.Top)
            {
                role2.RoleProperties.Offset = new Point(role2.RoleProperties.Offset.X, 0);
            }
            else if ((role2.Snapped & DP_Role.SnappedEdges.Bottom) == DP_Role.SnappedEdges.Bottom)
            {
                role2.RoleProperties.Offset = new Point(role2.RoleProperties.Offset.X, role2.Attached.Height);
            }
        }

        public static bool ValidRoles(DP_ConcreteType newSource, DP_ConcreteType newDest)
        {
            return false;
        }

        /*
        protected void RoleMouseMove(object sender, MouseEventArgs e)
        {
            if (Math.Abs(e.X - Parent.dragStart.X) > startDragSize || Math.Abs(e.Y - Parent.dragStart.Y) > startDragSize)
            {
                foreach (DP_ConcreteType type in parent.Types)
                {
                    if (type.Diagram != null)
                    {
                        type.nameLabel.AllowDrop = true;
                        type.nameLabel.DragDrop += RoleDragDrop;
                    }
                }

                Parent.diagramPanel.AllowDrop = true;
                Parent.diagramPanel.DragDrop += RoleDragDrop;
                Parent.diagramPanel.DragOver += RoleDiagramDragOver;

                DragDropEffects dropEffect = Parent.diagramPanel.DoDragDrop(sender, DragDropEffects.All);

                ((Control)sender).MouseMove -= RoleMouseMove;
            }
        }
         * */

        /*
protected void RoleMouseDown(object sender, MouseEventArgs e)
{

if (app.deleteToolButton.Checked)
{
    Destroy();
    return;
}


((Control)sender).MouseMove += RoleMouseMove;
}
         *              * */

        /*
        protected void RoleDiagramDragDrop(object sender, DragEventArgs e)
        {
            if (e.Data.GetData(typeof(Label)) == Role1.EndpointLabel || e.Data.GetData(typeof(Panel)) == Role1.IconPanel)
            {
                DetachRole1();
            }
            else if (e.Data.GetData(typeof(Label)) == Role2.EndpointLabel || e.Data.GetData(typeof(Panel)) == Role2.IconPanel)
            {
                DetachRole2();
            }

            foreach (DP_ConcreteType type in app.diagramWin.diagram.types)
            {
                type.nameLabel.AllowDrop = false;
                type.nameLabel.DragDrop -= RoleTypeDragDrop;
            }

            parent.diagramPanel.AllowDrop = false;
            parent.diagramPanel.DragDrop -= RoleDiagramDragDrop;

            parent.diagramPanel.Invalidate();
        }
         * */
        /*
protected void RoleDragDrop(object sender, DragEventArgs e)
{

if (e.Data.GetData(typeof(Label)) == Role1.EndpointLabel || e.Data.GetData(typeof(Panel)) == Role1.EndPanel)
{
    DetachRole1();
    if (((Label)sender).Parent != null)
    {
        DP_ConcreteType newEndpoint = ((DP_Diagram)sender).Parent;
        if (newEndpoint != null)
        {
            AttachRole1(newEndpoint);
            newEndpoint.Unhighlight();
        }
    }
}
else if (e.Data.GetData(typeof(Label)) == Role2.EndpointLabel || e.Data.GetData(typeof(Panel)) == Role2.EndPanel)
{
    DetachRole2();
    if (((DP_Diagram)sender).Parent != null)
    {
        DP_ConcreteType newEndpoint = ((DP_Diagram)sender).Parent;
        if (newEndpoint != null)
        {      
            AttachRole2(newEndpoint);
            newEndpoint.Unhighlight();
        }
    }
}  

foreach (DP_ConcreteType type in app.diagramWin.diagram.Types)
{
    type.nameLabel.AllowDrop = false;
    type.nameLabel.DragDrop -= RoleDragDrop;
}

Parent.diagramPanel.AllowDrop = false;
Parent.diagramPanel.DragDrop -= RoleDragDrop;

EndpointChanged(null, null);
Parent.diagramPanel.Invalidate(false);

Select();
app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
            
}
* */

        /*
        protected void RoleDiagramDragOver(object sender, DragEventArgs e)
        {
            Point location = Parent.diagramPanel.PointToClient(new Point(e.X, e.Y));
            location = new Point(
                location.X - Parent.dragStart.X,
                location.Y - Parent.dragStart.Y);
            if (e.Data.GetData(typeof(Label)) == Role1.Label)
            {
                //Role1.Endpoint = location;
                Invalidate();
                /*
                Role1.EndpointLabel.Location = new Point(
                    location.X + 30,
                    location.Y + 30);
                Role1.EndPanel.Location = new Point(
                    location.X + 10,
                    location.Y + 10);
            }
            else if (e.Data.GetData(typeof(Label)) == Role2.Label)
            {
                //Role2.Endpoint = location;
                Invalidate();
                /*
                Role2.EndpointLabel.Location = new Point(
                    location.X + 30,
                    location.Y + 30);
                Role2.EndPanel.Location = new Point(
                    location.X + 10,
                    location.Y + 10);
            }

            //EndpointChanged(null, null);
            //parent.diagramPanel.Refresh();
            e.Effect = DragDropEffects.Move;
        }
         * */

        // Web code

        public static Bitmap rotateCenter(Bitmap bmpSrc, float theta)
        {
            Matrix mRotate = new Matrix();
            mRotate.Translate(bmpSrc.Width/-2, bmpSrc.Height/-2, MatrixOrder.Append);
            mRotate.RotateAt(theta, new Point(0, 0), MatrixOrder.Append);
            using (GraphicsPath gp = new GraphicsPath())
            {
                // transform image points by rotation matrix
                gp.AddPolygon(new Point[] {new Point(0, 0), new Point(bmpSrc.Width, 0), new Point(0, bmpSrc.Height)});
                gp.Transform(mRotate);
                PointF[] pts = gp.PathPoints;

                // create destination bitmap sized to contain rotated source image
                Rectangle bbox = boundingBox(bmpSrc, mRotate);
                Bitmap bmpDest = new Bitmap(bbox.Width, bbox.Height);

                using (Graphics gDest = Graphics.FromImage(bmpDest))
                {
                    // draw source into dest
                    Matrix mDest = new Matrix();
                    mDest.Translate(bmpDest.Width/2, bmpDest.Height/2, MatrixOrder.Append);
                    gDest.Transform = mDest;
                    gDest.DrawImage(bmpSrc, pts);
                    //gDest.DrawRectangle(Pens.Red, bbox);
                    //drawAxes(gDest, Color.Red, 0, 0, 1, 100, "");
                    return bmpDest;
                }
            }
        }

        private static Rectangle boundingBox(Image img, Matrix matrix)
        {
            GraphicsUnit gu = new GraphicsUnit();
            Rectangle rImg = Rectangle.Round(img.GetBounds(ref gu));

            // Transform the four points of the image, to get the resized bounding box.
            Point topLeft = new Point(rImg.Left, rImg.Top);
            Point topRight = new Point(rImg.Right, rImg.Top);
            Point bottomRight = new Point(rImg.Right, rImg.Bottom);
            Point bottomLeft = new Point(rImg.Left, rImg.Bottom);
            Point[] points = new Point[] {topLeft, topRight, bottomRight, bottomLeft};
            GraphicsPath gp = new GraphicsPath(
                points,
                new byte[]
                {
                    (byte) PathPointType.Start, (byte) PathPointType.Line, (byte) PathPointType.Line,
                    (byte) PathPointType.Line
                });
            gp.Transform(matrix);
            return Rectangle.Round(gp.GetBounds());
        }
    }
}