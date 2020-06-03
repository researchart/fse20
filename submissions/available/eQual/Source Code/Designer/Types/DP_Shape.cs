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
using System.Drawing.Design;
using System.Drawing.Imaging;
using System.Drawing.Text;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml.Serialization;
using System.Windows.Forms;
using System.Windows.Forms.Design;
using DomainPro.Core.Types;
using DomainPro.Designer.Controls;

namespace DomainPro.Designer.Types
{
    public abstract class DP_Shape : DP_ConcreteType
    {
        public enum DP_ShapeType
        {
            Rectangle,
            Ellipse,
            Triangle,
            Diamond,
            Icon
        };

        [TypeConverter(typeof (DP_ShapePropertiesTypeConverter))]
        public class DP_ShapeProperties
        {
            public event EventHandler PropertyChanged;

            private DP_ShapeType shape = DP_ShapeType.Rectangle;

            [DisplayName("Shape"),
             Category("Presentation"),
             DefaultValue(DP_ShapeType.Rectangle),
             Description("Sets the shape of instances of the type.")]
            public DP_ShapeType Shape
            {
                get { return shape; }
                set
                {
                    shape = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private Size defaultSize = new Size(100, 100);

            [DisplayName("Default Size"),
             Category("Presentation"),
             Description("Sets the starting size of new instances of the type.")]
            public Size DefaultSize
            {
                get { return defaultSize; }
                set { defaultSize = value; }
            }

            private bool isResizable = true;

            [DisplayName("Is Resizable?"),
             Category("Presentation"),
             DefaultValue(true),
             Description("Sets whether instances of the type are resizable.")]
            public bool IsResizable
            {
                get { return isResizable; }
                set
                {
                    isResizable = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private DashStyle borderStyle = DashStyle.Solid;

            [DisplayName("Border Style"),
             Category("Presentation"),
             DefaultValue(DashStyle.Solid),
             Description("Sets the style of the shape borders.")]
            public DashStyle BorderStyle
            {
                get { return borderStyle; }
                set
                {
                    borderStyle = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private Color borderColor = Color.Black;

            [XmlIgnore,
             DisplayName("Border Color"),
             Category("Presentation"),
             Description("Sets the color of the shape borders.")]
            public Color BorderColor
            {
                get { return borderColor; }
                set
                {
                    borderColor = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            [XmlElement("BorderColor"),
             Browsable(false)]
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

            [DisplayName("Border Width"),
             Category("Presentation"),
             DefaultValue(1),
             Description("Sets the width of the shape borders.")]
            public int BorderWidth
            {
                get { return borderWidth; }
                set
                {
                    borderWidth = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private Color fillColor = Color.Empty;

            [XmlIgnore,
             DisplayName("Fill Color"),
             Category("Presentation"),
             Description("Sets the color of the shape fill.")]
            public Color FillColor
            {
                get { return fillColor; }
                set
                {
                    fillColor = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            [XmlElement("FillColor"),
             Browsable(false)]
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

            private bool gradientFill = false;

            [DisplayName("Gradient Fill"),
             Category("Presentation"),
             DefaultValue(false),
             Description("Sets whether a gradient is used to fill the shape.")]
            public bool GradientFill
            {
                get { return gradientFill; }
                set
                {
                    gradientFill = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private Color gradientFillColor = Color.Empty;

            [XmlIgnore,
             DisplayName("Gradient Fill Color"),
             Category("Presentation"),
             Description("Sets the color of the shape gradient fill.")]
            public Color GradientFillColor
            {
                get { return gradientFillColor; }
                set
                {
                    gradientFillColor = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            [XmlElement("GradientFillColor"),
             Browsable(false)]
            public DP_Color GradientFillColorArgb
            {
                get
                {
                    DP_Color newColor = new DP_Color();
                    newColor.Argb = gradientFillColor.ToArgb();
                    return newColor;
                }
                set
                {
                    if (value.Argb == 0)
                    {
                        GradientFillColor = Color.Empty;
                    }
                    GradientFillColor = Color.FromArgb(value.Argb);
                }
            }

            private int cornerRounding = 1;

            [DisplayName("Corner Rounding"),
             Category("Presentation"),
             DefaultValue(1),
             Description("Sets the radius of rounded shape corners.")]
            public int CornerRounding
            {
                get { return cornerRounding; }
                set
                {
                    cornerRounding = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private DockStyle dockStyle = DockStyle.None;

            [DisplayName("Dock Style"),
             Category("Presentation"),
             DefaultValue(DockStyle.None),
             Description("Sets whether instances of the type are docked to the edge of their parent containers.")]
            public DockStyle DockStyle
            {
                get { return dockStyle; }
                set
                {
                    dockStyle = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private ContentAlignment alignment = ContentAlignment.TopLeft;

            [DisplayName("Alignment"),
             Category("Presentation"),
             DefaultValue(ContentAlignment.TopLeft),
             Description("Sets how instances of the type align displayed text.")]
            public ContentAlignment Alignment
            {
                get { return alignment; }
                set
                {
                    alignment = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }

            private string icon = "";

            [DisplayName("Icon"),
             Category("Presentation"),
             DefaultValue(""),
             Description("Sets the icon to display."),
             Editor(typeof (FileNameEditor), typeof (UITypeEditor))]
            public string Icon
            {
                get { return icon; }
                set
                {
                    icon = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new EventArgs());
                    }
                }
            }
        }

        public class DP_ShapePropertiesTypeConverter : TypeConverter
        {
            public override object ConvertTo(
                ITypeDescriptorContext context,
                System.Globalization.CultureInfo culture,
                object value,
                Type destinationType)
            {
                if (destinationType == typeof (string))
                {
                    DP_ShapeProperties props = (DP_ShapeProperties) value;
                    return (
                        props.Shape.ToString() + ", " +
                        props.DefaultSize.ToString() + ", " +
                        props.IsResizable.ToString() + ", " +
                        props.BorderStyle.ToString() + ", " +
                        props.BorderColor.ToString() + ", " +
                        props.BorderWidth.ToString() + ", " +
                        props.FillColor.ToString() + ", " +
                        props.CornerRounding.ToString() + ", " +
                        props.DockStyle.ToString() + ", " +
                        props.Alignment.ToString());
                }
                return base.ConvertTo(context, culture, value, destinationType);
            }

            public override PropertyDescriptorCollection GetProperties(ITypeDescriptorContext context, object value,
                Attribute[] attributes)
            {
                return TypeDescriptor.GetProperties(typeof (DP_ShapeProperties), attributes);
            }

            public override bool GetPropertiesSupported(ITypeDescriptorContext context)
            {
                return true;
            }
        }

        private DP_ShapeProperties shapeProperties = new DP_ShapeProperties();

        [DisplayName("Shape Properties"),
         Category("Instance"),
         Description("Sets the appearance of the shape of the object.")]
        public DP_ShapeProperties ShapeProperties
        {
            get { return shapeProperties; }
            set { shapeProperties = value; }
        }

        protected Point location;

        public override Point Location
        {
            get { return location; }
            set
            {
                // Record the action
                Invalidate();
                location = value;
                Invalidate();
                OnLocationChanged(new EventArgs());
            }
        }

        protected Size size;

        public override Size Size
        {
            get { return size; }
            set
            {
                Invalidate();
                size = value;
                Invalidate();
                OnSizeChanged(new EventArgs());
            }
        }

        [XmlIgnore,
         Browsable(false)]
        public override Point Center
        {
            get
            {
                return new Point(
                    Location.X + Size.Width/2,
                    Location.Y + Size.Height/2);
            }
            set
            {
                Location = new Point(
                    value.X - Size.Width/2,
                    value.Y - Size.Height/2);
                /*
                shapePanel.Location = new Point(
                    location.X + Parent.diagramPanel.DisplayRectangle.Left,
                    location.Y + Parent.diagramPanel.DisplayRectangle.Top);
                 * */
            }
        }

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
                    return new Region(new Rectangle(Parent.TypePointToPanelSpace(Location), Size));
                }
            }
        }

        protected Bitmap icon;

        private bool startResize;
        private Point resizeStartPos = new Point(0, 0);
        private Point lastResizeMousePos = new Point(0, 0);

        private enum ResizeEdges
        {
            None = 0x0,
            Left = 0x1,
            Right = 0x2,
            Top = 0x4,
            Bottom = 0x8,
        }

        private ResizeEdges resizeEdges;

        public DP_Shape()
        {
        }

        public DP_Shape(Point startLocation)
        {
            Location = startLocation;
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);

            if (ShapeProperties.Shape == DP_ShapeType.Icon && ShapeProperties.Icon != null)
            {
                if (Path.IsPathRooted(ShapeProperties.Icon))
                {
                    ShapeProperties.Icon = Path.Combine(
                        DomainProDesigner.Instance.RelativePath(
                            Path.GetDirectoryName(DomainProDesigner.Instance.Language.File),
                            Path.GetDirectoryName(ShapeProperties.Icon)),
                        Path.GetFileName(ShapeProperties.Icon));
                }

                string iconFile = Path.Combine(Path.GetDirectoryName(DomainProDesigner.Instance.Language.File),
                    ShapeProperties.Icon);

                if (File.Exists(iconFile))
                {
                    icon = new Bitmap(iconFile);
                    icon = new Bitmap(icon, size);
                }
            }

            /*
            resizePanel.Location = new Point(Right - resizer.Width, Bottom - resizer.Height);
            resizePanel.Size = new Size(resizer.Width, resizer.Height);
            resizePanel.Visible = false;
            resizePanel.Paint += ResizerPaint;
            resizePanel.MouseDown += ResizeMouseDown;
            resizePanel.MouseMove += ResizeMouseMove;
            resizePanel.MouseUp += ResizeMouseUp;
            app.Model.DiagramPanel.Controls.Add(resizePanel);
             * */

            // Property changed event
            ShapeProperties.PropertyChanged += ShapePropertyChanged;
        }

        public override void Destroy()
        {
            base.Destroy();


            for (int i = Lines.Count - 1; i >= 0; i--)
            {
                if (Lines[i].Role1Id == Id)
                {
                    Lines[i].Role1Attached = null;
                }
                else
                {
                    Lines[i].Role2Attached = null;
                }
            }
        }

        protected override void Copy(DP_ConcreteType source)
        {
            if (source is DP_Shape)
            {
                base.Copy(source);
                DP_Shape srcShape = source as DP_Shape;
                ShapeProperties.Shape = srcShape.ShapeProperties.Shape;
                ShapeProperties.DefaultSize = srcShape.ShapeProperties.DefaultSize;
                ShapeProperties.IsResizable = srcShape.ShapeProperties.IsResizable;
                ShapeProperties.BorderStyle = srcShape.ShapeProperties.BorderStyle;
                ShapeProperties.BorderColor = srcShape.ShapeProperties.BorderColor;
                ShapeProperties.BorderWidth = srcShape.ShapeProperties.BorderWidth;
                ShapeProperties.FillColor = srcShape.ShapeProperties.FillColor;
                ShapeProperties.CornerRounding = srcShape.ShapeProperties.CornerRounding;
                ShapeProperties.DockStyle = srcShape.ShapeProperties.DockStyle;
                ShapeProperties.Alignment = srcShape.ShapeProperties.Alignment;
                ShapeProperties.Icon = srcShape.ShapeProperties.Icon;
            }
        }

        public override void Invalidate()
        {
            if (Parent != null)
            {
                app.Model.DiagramPanel.Invalidate(Area);
                //resizePanel.Location = new Point(Parent.TypePointToPanelSpace(Location).X + Width - resizer.Width, Parent.TypePointToPanelSpace(Location).Y + Height - resizer.Height);
            }
        }

        public override void TypeMouseDown(object sender, MouseEventArgs e)
        {
            base.TypeMouseDown(sender, e);

            if (!app.connectToolButton.Checked)
            {
                if (app.Model.DiagramPanel.Cursor == Cursors.SizeNWSE ||
                    app.Model.DiagramPanel.Cursor == Cursors.SizeNESW ||
                    app.Model.DiagramPanel.Cursor == Cursors.SizeNS ||
                    app.Model.DiagramPanel.Cursor == Cursors.SizeWE)
                {
                    startResize = true;
                    resizeStartPos = Parent.PanelPointToDiagramSpace(e.Location);
                    lastResizeMousePos = Parent.PanelPointToDiagramSpace(e.Location);
                    app.Model.DiagramPanel.MouseMove += ResizeMouseMove;
                    app.Model.DiagramPanel.MouseUp += ResizeMouseUp;
                }
                else
                {
                    Parent.dragStartPos = Parent.PanelPointToDiagramSpace(e.Location);
                    app.Model.DiagramPanel.MouseMove += Parent.DiagramPanelShapeDrag;
                    app.Model.DiagramPanel.MouseUp += Parent.DiagramPanelShapeDragBoxMouseUp;
                    app.Model.DiagramPanel.Paint += Parent.DiagramPanelDrawShapeDragBox;
                }
            }
        }

        public override void TypeMouseClick(object sender, MouseEventArgs e)
        {
            base.TypeMouseClick(sender, e);

            if (app.createToolButton.Checked)
            {
                Diagram.ShowShapeMenu(e.Location);
            }
        }

        public override void TypeMouseMove(object sender, MouseEventArgs e)
        {
            base.TypeMouseMove(sender, e);
            if (Selected && startResize == false)
            {
                Point end1 = Parent.TypePointToPanelSpace(Location);
                Point end2 = Parent.TypePointToPanelSpace(new Point(Right, Top));
                Point end3 = Parent.TypePointToPanelSpace(new Point(Right, Bottom));
                Point end4 = Parent.TypePointToPanelSpace(new Point(Left, Bottom));

                GraphicsPath path1 = new GraphicsPath();
                path1.AddLine(end1, end2);
                path1.Widen(new Pen(Color.Black, 10));
                Region topRegion = new Region(path1);

                GraphicsPath path2 = new GraphicsPath();
                path2.AddLine(end2, end3);
                path2.Widen(new Pen(Color.Black, 10));
                Region rightRegion = new Region(path2);

                GraphicsPath path3 = new GraphicsPath();
                path3.AddLine(end3, end4);
                path3.Widen(new Pen(Color.Black, 10));
                Region bottomRegion = new Region(path3);

                GraphicsPath path4 = new GraphicsPath();
                path4.AddLine(end4, end1);
                path4.Widen(new Pen(Color.Black, 10));
                Region leftRegion = new Region(path4);

                resizeEdges = ResizeEdges.None;

                if (leftRegion.IsVisible(e.Location))
                {
                    resizeEdges = resizeEdges | ResizeEdges.Left;
                }
                else if (rightRegion.IsVisible(e.Location))
                {
                    resizeEdges = resizeEdges | ResizeEdges.Right;
                }


                if (topRegion.IsVisible(e.Location))
                {
                    resizeEdges = resizeEdges | ResizeEdges.Top;
                }
                else if (bottomRegion.IsVisible(e.Location))
                {
                    resizeEdges = resizeEdges | ResizeEdges.Bottom;
                }

                if (((resizeEdges & ResizeEdges.Left) == ResizeEdges.Left &&
                     (resizeEdges & ResizeEdges.Top) == ResizeEdges.Top) ||
                    ((resizeEdges & ResizeEdges.Right) == ResizeEdges.Right &&
                     (resizeEdges & ResizeEdges.Bottom) == ResizeEdges.Bottom))
                {
                    app.Model.DiagramPanel.Cursor = Cursors.SizeNWSE;
                }
                else if (((resizeEdges & ResizeEdges.Left) == ResizeEdges.Left &&
                          (resizeEdges & ResizeEdges.Bottom) == ResizeEdges.Bottom) ||
                         ((resizeEdges & ResizeEdges.Right) == ResizeEdges.Right &&
                          (resizeEdges & ResizeEdges.Top) == ResizeEdges.Top))
                {
                    app.Model.DiagramPanel.Cursor = Cursors.SizeNESW;
                }
                else if ((resizeEdges & ResizeEdges.Left) == ResizeEdges.Left ||
                         (resizeEdges & ResizeEdges.Right) == ResizeEdges.Right)
                {
                    app.Model.DiagramPanel.Cursor = Cursors.SizeWE;
                }
                else if ((resizeEdges & ResizeEdges.Top) == ResizeEdges.Top ||
                         (resizeEdges & ResizeEdges.Bottom) == ResizeEdges.Bottom)
                {
                    app.Model.DiagramPanel.Cursor = Cursors.SizeNS;
                }
                else
                {
                    app.Model.DiagramPanel.Cursor = Cursors.Arrow;
                }
            }
        }

        protected void ResizeMouseMove(object sender, MouseEventArgs e)
        {
            if (startResize)
            {
                //Cursor.Position = app.Model.DiagramPanel.PointToScreen(new Point(Diagram.DiagramPointToPanelSpace(resizeStartPos).X, e.Y));
                int mouseXDiff = lastResizeMousePos.X - Diagram.PanelPointToDiagramSpace(e.Location).X;
                int mouseYDiff = lastResizeMousePos.Y - Diagram.PanelPointToDiagramSpace(e.Location).Y;

                if ((resizeEdges & ResizeEdges.Left) == ResizeEdges.Left)
                {
                    Size = new Size(Width + mouseXDiff, Height);
                    Location = new Point(Left - mouseXDiff, Top);
                    foreach (DP_ConcreteType type in Diagram.Types)
                    {
                        type.Location = new Point(type.Left + mouseXDiff, type.Top);
                    }
                }
                else if ((resizeEdges & ResizeEdges.Right) == ResizeEdges.Right)
                {
                    Size = new Size(Width - mouseXDiff, Height);
                }


                if ((resizeEdges & ResizeEdges.Top) == ResizeEdges.Top)
                {
                    Size = new Size(Width, Height + mouseYDiff);
                    Location = new Point(Left, Top - mouseYDiff);
                    foreach (DP_ConcreteType type in Diagram.Types)
                    {
                        type.Location = new Point(type.Left, type.Top + mouseYDiff);
                    }
                }
                else if ((resizeEdges & ResizeEdges.Bottom) == ResizeEdges.Bottom)
                {
                    Size = new Size(Width, Height - mouseYDiff);
                }
                lastResizeMousePos = Diagram.PanelPointToDiagramSpace(e.Location);
                app.Model.DiagramPanel.Update();
            }
        }

        protected void ResizeMouseUp(object sender, MouseEventArgs e)
        {
            startResize = false;
            resizeEdges = ResizeEdges.None;
            resizeStartPos = new Point(0, 0);
            lastResizeMousePos = new Point(0, 0);
            app.Model.DiagramPanel.MouseMove -= ResizeMouseMove;
            app.Model.DiagramPanel.MouseUp -= ResizeMouseUp;
            app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
        }

        /*
        public override void TypeMouseMove(object sender, MouseEventArgs e)
        {
            Point mouseLocation = PointToClient(e.Location);
            Point snapLocation = new Point(0, 0);
            if (mouseLocation.X > 0 && mouseLocation.X < 5)
            {
                snapLocation = new Point(Left + 1, e.Y);
                //Cursor.Position = Parent.diagramPanel.PointToScreen(new Point(PointToScreen(Location).X - 2, e.Y));
            }
            if (mouseLocation.Y > 0 && mouseLocation.Y < 5)
            {
                snapLocation = new Point(e.X, Top + 1);
                //Cursor.Position = Parent.diagramPanel.PointToScreen(new Point(e.X, PointToScreen(Location).Y - 2));
            }
            if (mouseLocation.X < Width && mouseLocation.X > Width - 5)
            {
                snapLocation = new Point(Right - 1, e.Y);
                //Cursor.Position = Parent.diagramPanel.PointToScreen(new Point(PointToScreen(Location).X + Width - 2, e.Y));
            }
            if (mouseLocation.Y < Height && mouseLocation.Y > Height - 5)
            {
                snapLocation = new Point(e.X, Bottom - 1);
                //Cursor.Position = Parent.diagramPanel.PointToScreen(new Point(e.X, PointToScreen(Location).Y + Height - 2));
            }

            if (snapLocation != new Point(0, 0))
            {
                Graphics graphics = Parent.diagramPanel.CreateGraphics();
                Pen pen =  new Pen(Color.Red);
                graphics.DrawLine(pen, snapLocation.X - 5, snapLocation.Y - 5, snapLocation.X + 5, snapLocation.Y + 5);
                graphics.DrawLine(pen, snapLocation.X + 5, snapLocation.Y - 5, snapLocation.X - 5, snapLocation.Y + 5);
                graphics.Dispose();
            }
        }
         * */

        protected void ShapePropertyChanged(object sender, EventArgs e)
        {
            if (ShapeProperties.Icon != null)
            {
                if (Path.IsPathRooted(ShapeProperties.Icon))
                {
                    ShapeProperties.Icon = Path.Combine(
                        DomainProDesigner.Instance.RelativePath(
                            Path.GetDirectoryName(DomainProDesigner.Instance.Language.File),
                            Path.GetDirectoryName(ShapeProperties.Icon)),
                        Path.GetFileName(ShapeProperties.Icon));
                }

                string iconFile = Path.Combine(Path.GetDirectoryName(DomainProDesigner.Instance.Language.File),
                    ShapeProperties.Icon);

                if (File.Exists(iconFile))
                {
                    icon = new Bitmap(iconFile);
                    icon = new Bitmap(icon, size);
                }
            }

            app.Model.DiagramPanel.Invalidate(Area);
            app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
        }

        public void HighlightPaint(Graphics graphics)
        {
            /*
            Point screenLocation = Parent.TypePointToPanelSpace(Location);
            int screenLeft = screenLocation.X;
            int screenTop = screenLocation.Y;
            int screenRight = screenLocation.X + Width;
            int screenBottom = screenLocation.Y + Height;
             * */

            Pen pen = new Pen(app.SelectionColor, DomainProDesigner.Instance.SelectionBorderWidth);
            graphics.DrawRectangle(pen,
                app.SelectionBorderWidth/2,
                app.SelectionBorderWidth/2,
                Width - app.SelectionBorderWidth - 1,
                Height - app.SelectionBorderWidth - 1);

            Brush brush = new SolidBrush(app.SelectionColor);
            graphics.FillRectangle(brush, 0, 0, app.SelectionMarkerSize.Width, app.SelectionMarkerSize.Height);
            graphics.FillRectangle(brush, 0, Height/2 - app.SelectionMarkerSize.Height/2, app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);
            graphics.FillRectangle(brush, 0, Height - 1 - app.SelectionMarkerSize.Height, app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);
            graphics.FillRectangle(brush, Width/2 - app.SelectionMarkerSize.Width/2, 0, app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);
            graphics.FillRectangle(brush, Width - 1 - app.SelectionMarkerSize.Width, 0, app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);
            graphics.FillRectangle(brush, Width/2 - app.SelectionMarkerSize.Width/2,
                Height - 1 - app.SelectionMarkerSize.Height, app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);
            graphics.FillRectangle(brush, Width - 1 - app.SelectionMarkerSize.Width,
                Height - 1 - app.SelectionMarkerSize.Height, app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);
            graphics.FillRectangle(brush, Width - 1 - app.SelectionMarkerSize.Width,
                Height/2 - app.SelectionMarkerSize.Width/2, app.SelectionMarkerSize.Width,
                app.SelectionMarkerSize.Height);

            pen.Dispose();
        }

        public override void TypePaint(object sender, PaintEventArgs e)
        {
            if (Width < 1 || Height < 1 || Hidden)
            {
                return;
            }

            Size imageSize = new Size(Width, Height);
            Bitmap image = new Bitmap(imageSize.Width, imageSize.Height);
            Graphics graphics = Graphics.FromImage(image);
            graphics.SmoothingMode = SmoothingMode.HighQuality;
            graphics.TextRenderingHint = TextRenderingHint.AntiAlias;

            Rectangle bounds = new Rectangle(
                ShapeProperties.BorderWidth/2,
                ShapeProperties.BorderWidth/2,
                Width - ShapeProperties.BorderWidth,
                Height - ShapeProperties.BorderWidth);

            if (!Diagram.IsMainDiagram)
            {
                Brush fillBrush;
                if (ShapeProperties.FillColor.ToArgb() != 0)
                {
                    if (!ShapeProperties.GradientFill)
                    {
                        fillBrush = new SolidBrush(ShapeProperties.FillColor);
                    }
                    else
                    {
                        fillBrush = new LinearGradientBrush(bounds, ShapeProperties.FillColor,
                            ShapeProperties.GradientFillColor, 60);
                    }
                }
                else
                {
                    fillBrush = new SolidBrush(Color.Empty);
                }

                Pen borderPen = new Pen(ShapeProperties.BorderColor, ShapeProperties.BorderWidth);
                borderPen.DashStyle = ShapeProperties.BorderStyle;

                if (ShapeProperties.Shape == DP_ShapeType.Ellipse)
                {
                    graphics.FillEllipse(fillBrush, bounds);
                    graphics.DrawEllipse(borderPen, bounds);
                }
                else if (ShapeProperties.Shape == DP_ShapeType.Rectangle)
                {
                    DrawRectangle(graphics, borderPen, fillBrush, bounds, ShapeProperties.CornerRounding);
                }
                else if (ShapeProperties.Shape == DP_ShapeType.Triangle)
                {
                    DrawTriangle(graphics, borderPen, fillBrush, bounds, ShapeProperties.CornerRounding);
                }
                else if (ShapeProperties.Shape == DP_ShapeType.Diamond)
                {
                    DrawDiamond(graphics, borderPen, fillBrush, bounds, ShapeProperties.CornerRounding);
                }
                else if (ShapeProperties.Shape == DP_ShapeType.Icon)
                {
                    if (icon != null)
                    {
                        graphics.DrawImage(icon, 0, 0, Width, Height);
                    }
                }

                fillBrush.Dispose();
                borderPen.Dispose();

                if (ShowName)
                {
                    StringFormat format = new StringFormat();
                    if (ShapeProperties.Alignment == ContentAlignment.TopCenter ||
                        ShapeProperties.Alignment == ContentAlignment.MiddleCenter ||
                        ShapeProperties.Alignment == ContentAlignment.BottomCenter)
                    {
                        format.Alignment = StringAlignment.Center;
                    }
                    if (ShapeProperties.Alignment == ContentAlignment.TopRight ||
                        ShapeProperties.Alignment == ContentAlignment.MiddleRight ||
                        ShapeProperties.Alignment == ContentAlignment.BottomRight)
                    {
                        format.Alignment = StringAlignment.Far;
                    }
                    if (ShapeProperties.Alignment == ContentAlignment.MiddleLeft ||
                        ShapeProperties.Alignment == ContentAlignment.MiddleCenter ||
                        ShapeProperties.Alignment == ContentAlignment.MiddleRight)
                    {
                        format.LineAlignment = StringAlignment.Center;
                    }
                    if (ShapeProperties.Alignment == ContentAlignment.BottomLeft ||
                        ShapeProperties.Alignment == ContentAlignment.BottomCenter ||
                        ShapeProperties.Alignment == ContentAlignment.BottomRight)
                    {
                        format.LineAlignment = StringAlignment.Far;
                    }

                    graphics.DrawString(DisplayName, NameFont, SystemBrushes.WindowText,
                        new Rectangle(0, 0, Size.Width, Size.Height), format);
                }

                if (Highlighted)
                {
                    HighlightPaint(graphics);
                }
            }

            Rectangle panelRect = new Rectangle(Parent.TypePointToPanelSpace(Location), imageSize);
            panelRect.Intersect(e.ClipRectangle);
            Rectangle imageRect = new Rectangle(Diagram.PanelPointToTypeSpace(panelRect.Location), panelRect.Size);
            e.Graphics.DrawImage(image, panelRect, imageRect, GraphicsUnit.Pixel);

            foreach (DP_ConcreteType type in Structure.Types)
            {
                Rectangle rect = new Rectangle(e.ClipRectangle.Location, e.ClipRectangle.Size);
                if (!Diagram.IsMainDiagram)
                    rect.Intersect(new Rectangle(
                        Parent.TypePointToPanelSpace(Location).X + ShapeProperties.BorderWidth,
                        Parent.TypePointToPanelSpace(Location).Y + ShapeProperties.BorderWidth,
                        Size.Width - ShapeProperties.BorderWidth*2,
                        Size.Height - ShapeProperties.BorderWidth*2));
                if (!rect.IsEmpty)
                {
                    type.TypePaint(sender, new PaintEventArgs(e.Graphics, rect));
                }
            }
        }

        public void DrawRectangle(Graphics graphics, Pen pen, Brush brush, Rectangle rect, float radius)
        {
            if (radius < 1)
                radius = 1;
            float x = rect.Left;
            float y = rect.Top;
            float width = rect.Width;
            float height = rect.Height;
            GraphicsPath path = new GraphicsPath();
            //path.AddLine(x + radius, y, x + width - (radius * 2), y); // Line
            path.AddArc(x + width - (radius*2), y, radius*2, radius*2, 270, 90); // Corner
            //path.AddLine(x + width, y + radius, x + width, y + height - (radius * 2)); // Line
            path.AddArc(x + width - (radius*2), y + height - (radius*2), radius*2, radius*2, 0, 90); // Corner
            //path.AddLine(x + width - (radius * 2), y + height, x + radius, y + height); // Line
            path.AddArc(x, y + height - (radius*2), radius*2, radius*2, 90, 90); // Corner
            //path.AddLine(x, y + height - (radius * 2), x, y + radius); // Line
            path.AddArc(x, y, radius*2, radius*2, 180, 90); // Corner
            path.CloseFigure();
            graphics.FillPath(brush, path);
            graphics.DrawPath(pen, path);
            path.Dispose();
        }

        public void DrawTriangle(Graphics graphics, Pen pen, Brush brush, Rectangle rect, float radius)
        {
            if (radius < 1)
                radius = 1;
            float x = rect.Left;
            float y = rect.Top;
            float width = rect.Width;
            float height = rect.Height;
            float baseAngle = (float) (Math.Atan(height/(width/2))*180/Math.PI);
            float angle = (float) (2*Math.Atan((width/2)/height)*180/Math.PI);
            GraphicsPath path = new GraphicsPath();
            path.AddLine(x, y + height, x + width/2, y);
            //path.AddArc(x + width / 2 - radius, y, radius * 2, radius * 2, 270 - angle / 2, angle);
            path.AddLine(x + width/2, y, x + width, y + height);
            //path.AddArc(x + width - radius * 2, y + height - radius * 2, radius * 2, radius * 2, 45 - baseAngle / 2, baseAngle);
            path.AddLine(x + width, y + height, x, y + height);
            //path.AddArc(x, y + height - radius * 2, radius * 2, radius * 2, 135 - baseAngle / 2, baseAngle);
            path.CloseFigure();
            graphics.FillPath(brush, path);
            graphics.DrawPath(pen, path);
            path.Dispose();
        }

        public void DrawDiamond(Graphics graphics, Pen pen, Brush brush, Rectangle rect, float radius)
        {
            if (radius < 1)
                radius = 1;
            float x = rect.Left;
            float y = rect.Top;
            float width = rect.Width;
            float height = rect.Height;
            GraphicsPath path = new GraphicsPath();
            path.AddLine(x, y + height/2, x + width/2, y);
            path.AddLine(x + width/2, y, x + width, y + height/2);
            path.AddLine(x + width, y + height/2, x + width/2, y + height);
            path.AddLine(x + width/2, y + height, x, y + height/2);
            path.CloseFigure();
            graphics.FillPath(brush, path);
            graphics.DrawPath(pen, path);
            path.Dispose();
        }

        /*
        protected void ResizerPaint(object sender, PaintEventArgs e)
        {
            Graphics graphics = e.Graphics;
            graphics.DrawImage(resizer, 0, 0, resizer.Width, resizer.Height);
            resizePanel.BringToFront();
        }
         * */

        /*
        protected void ResizeMouseDown(object sender, MouseEventArgs e)
        {
            
            //resizeX = Parent.TypePointToPanelSpace(Location).X;
            //resizeY = resizePanel.Top - Parent.TypePointToPanelSpace(Location).Y;
            //resizePanel.Visible = false;
        }
         * */

        /*
        public Point GetAlignedPosition()
        {
            Point screenLocation = PointToScreen(Location);
            int screenLeft = screenLocation.X;
            int screenTop = screenLocation.Y;
            int screenRight = screenLocation.X + Width;
            int screenBottom = screenLocation.Y + Height;

            if (ShapeProperties.Alignment == ContentAlignment.TopLeft)
            {
                return new Point(
                    screenLeft,
                    screenTop);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.TopCenter)
            {
                return new Point(
                    screenLeft + Width / 2 - nameLabel.Width / 2,
                    screenTop);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.TopRight)
            {
                return new Point(
                    screenRight - nameLabel.Width,
                    screenTop);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.MiddleLeft)
            {
                return new Point(
                    screenLeft,
                    screenTop + Height / 2 - nameLabel.Height / 2);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.MiddleCenter)
            {
                return new Point(
                    screenLeft + Width / 2 - nameLabel.Width / 2,
                    screenTop + Height / 2 - nameLabel.Height / 2);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.MiddleRight)
            {
                return new Point(
                    screenRight - nameLabel.Width,
                    screenTop + Height / 2 - nameLabel.Height / 2);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.BottomLeft)
            {
                return new Point(
                    screenLeft,
                    screenBottom - nameLabel.Height);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.BottomCenter)
            {
                return new Point(
                    screenLeft + Width / 2 - nameLabel.Width / 2,
                    screenBottom - nameLabel.Height);
            }
            else if (ShapeProperties.Alignment == ContentAlignment.BottomRight)
            {
                return new Point(
                    screenRight - nameLabel.Width,
                    screenBottom - nameLabel.Height);
            }

            return screenLocation;
        }
         * */

        /*
        public override Point Location()
        {
            return new Point(
                shapePanel.Location.X + shapePanel.Width / 2,
                shapePanel.Location.Y + shapePanel.Height / 2);
        }
         * */

        /*
protected void ShapeMouseUp(object sender, MouseEventArgs e)
{
    if (startDrag)
    {
        foreach (DP_ConcreteType type in app.selected)
        {
            if (type.GetType().IsSubclassOf(typeof(DP_Shape)))
            {

                DP_Shape shape = (DP_Shape)type;
                shape.Center = new Point(
                    shape.Center.X + e.X - dragX,
                    shape.Center.Y + e.Y - dragY);

                foreach (DP_Line line in type.lines)
                {
                    line.Invalidate();
                }
            }
        }
    }
    Parent.diagramPanel.Refresh();

    nameLabel.MouseMove -= ShapeMouseMove;
    shapePanel.MouseMove -= ShapeMouseMove;
}
 * */

        /*
        protected void ShapeMouseMove(object sender, MouseEventArgs e)
        {
            if (!startDrag && (Math.Abs(e.X - dragX) > startDragSize / 4 || Math.Abs(e.Y - dragY) > startDragSize / 4))
            {
                startDrag = true;
            }

            if (startDrag)
            {
                if (e.Button == MouseButtons.Left)
                {
                    
                            if (shape.dock == DockStyle.Left)
                            {
                                type.Location = new Point(0, type.Location.Y);// size.Width / 2;
                            }
                            if (shape.dock == DockStyle.Right)
                            {
                                type.Location = new Point(type.Parent.diagramPanel.Width - type.Size.Width, type.Location.Y);// / 2;
                            }
                            if (shape.dock == DockStyle.Top)
                            {
                                type.Location = new Point(type.Location.X, 0);//size.Height / 2;
                            }
                            if (shape.dock == DockStyle.Bottom)
                            {
                                type.Location = new Point(type.Location.X, type.Parent.diagramPanel.Height - type.Size.Height);// / 2;
                            }
                            //shapePanel.Location = location;
                        
                    //Parent.diagramPanel.Update();
                }

                app.modelState = DomainProEditor.ModelState.OPEN_CHANGED;
            }
        }
*/
    }
}