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
using System.Collections;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Xml.Serialization;
using DomainPro.Core.Application;
using DomainPro.Core.Types;
using DomainPro.Designer.Interfaces;

namespace DomainPro.Designer.Types
{
    public abstract class DP_Diagram : DP_AbstractStructure
    {
        [XmlIgnore]
        public new DP_ConcreteType Parent
        {
            get { return (DP_ConcreteType) parent; }
            set { parent = value; }
        }

        private bool isMainDiagram = false;

        [XmlIgnore]
        public bool IsMainDiagram
        {
            get { return isMainDiagram; }
            set { isMainDiagram = value; }
        }

        public Size Size
        {
            get
            {
                Size size = new Size(0, 0);
                foreach (DP_ConcreteType type in Types)
                {
                    if (type.Right > size.Width)
                    {
                        size.Width = type.Right;
                    }
                    if (type.Bottom > size.Height)
                    {
                        size.Height = type.Bottom;
                    }
                }
                return size;
            }
        }

        protected List<string> availableShapes = new List<string>();
        protected Point clickLocation;
        protected ComboBox shapeComboBox;

        protected List<string> availableLines = new List<string>();
        protected DomainProDesigner.DP_ConnectionSpec lineSrc;
        protected DomainProDesigner.DP_ConnectionSpec lineDest;
        protected ComboBox lineComboBox;

        // Selecting variables
        private bool selectBox = false;
        private Point selectStartPos = new Point(0, 0);
        private Point lastSelectBox = new Point(0, 0);
        private Point lastSelectMousePos = new Point(0, 0);

        // Dragging variables
        private bool startDrag = false;
        [XmlIgnore] public Point dragStartPos = new Point(0, 0);
        private Point lastDragBox = new Point(0, 0);
        private Point lastDragMousePos = new Point(0, 0);
        private Size dragBoxSize = new Size(0, 0);

        // Connecting variables
        [XmlIgnore] public bool connLine = false;
        [XmlIgnore] public Point connStartPos = new Point(0, 0);
        [XmlIgnore] public Point lastConnLine = new Point(0, 0);
        [XmlIgnore] public Point lastConnMousePos = new Point(0, 0);

        // Mouse event variables
        private DP_ConcreteType typeAtMouseLocation;

        // Convenience variables
        private DomainProDesigner app = DomainProDesigner.Instance;

        public abstract DP_Shape CreateShape(string shapeType, Point startLocation);

        public abstract DP_Line CreateLine(string lineType, DomainProDesigner.DP_ConnectionSpec src,
            DomainProDesigner.DP_ConnectionSpec dest);

        public override void Initialize(DP_AbstractSemanticType newParent)
        {
            base.Initialize(newParent);
        }

        /*
        public void MakeSubDiagram()
        {
            app.diagramWin.Controls.Remove(diagramPanel);
            app.diagramWin.diagram = null;

            
            diagramPanel.MouseDown -= SelectBoxMouseDown;
            diagramPanel.MouseDown -= DiagramPanelMouseDown;
            diagramPanel.MouseUp -= DiagramPanelMouseUp;

            if (Parent != null && Parent.GetType().IsSubclassOf(typeof(DP_Shape)))
            {
                diagramPanel.Anchor = AnchorStyles.Top | AnchorStyles.Left;
                diagramPanel.Location = Parent.Location;
                diagramPanel.Size = Parent.Size;
                //diagramPanel.BackColor = Color.Transparent;
                diagramPanel.BorderStyle = BorderStyle.None;
                diagramPanel.AutoScroll = false;

                Parent.Parent.diagramPanel.Controls.Add(diagramPanel);
                
                ((DP_Shape)Parent).resizePanel.Show();

                diagramPanel.MouseDown += Parent.TypeMouseDown;
                diagramPanel.MouseEnter += ((DP_Shape)Parent).TypeMouseEnter;
                diagramPanel.MouseLeave += ((DP_Shape)Parent).TypeMouseLeave;
                diagramPanel.MouseDown += ((DP_Shape)Parent).ShapeMouseDown;
                diagramPanel.MouseClick += Parent.TypeMouseClick;
                diagramPanel.DoubleClick += Parent.TypeDoubleClick;
                diagramPanel.MouseClick += ((DP_Shape)Parent).ShapePanelClick;
                diagramPanel.Paint += ((DP_Shape)Parent).ShapePaint;
            }

            
        }
         * */

        public void MakeMainDiagram()
        {
            app.Model.DiagramPanel.SuspendLayout();

            if (app.MainDiagram != null)
            {
                app.LastMainDiagram = app.MainDiagram;
                app.MainDiagram.IsMainDiagram = false;
                app.Model.DiagramPanel.MouseClick -= app.MainDiagram.DiagramMouseClick;
                app.Model.DiagramPanel.MouseDoubleClick -= app.MainDiagram.DiagramMouseDoubleClick;
                app.Model.DiagramPanel.MouseDown -= app.MainDiagram.DiagramMouseDown;
                app.Model.DiagramPanel.MouseUp -= app.MainDiagram.DiagramMouseUp;
                app.Model.DiagramPanel.MouseMove -= app.MainDiagram.DiagramMouseMove;

                if (app.MainDiagram.Parent != null)
                {
                    app.Model.DiagramPanel.Paint -= app.MainDiagram.Parent.TypePaint;
                }
                else
                {
                    app.Model.DiagramPanel.Paint -= app.Model.ModelPaint;
                }
            }
            else
            {
                app.LastMainDiagram = this;
            }

            IsMainDiagram = true;
            app.MainDiagram = this;
            app.Model.DiagramPanel.MouseClick += DiagramMouseClick;
            app.Model.DiagramPanel.MouseDoubleClick += DiagramMouseDoubleClick;
            app.Model.DiagramPanel.MouseDown += DiagramMouseDown;
            app.Model.DiagramPanel.MouseUp += DiagramMouseUp;
            app.Model.DiagramPanel.MouseMove += DiagramMouseMove;

            if (Parent != null)
            {
                app.Model.DiagramPanel.Paint += Parent.TypePaint;
            }
            else
            {
                app.Model.DiagramPanel.Paint += app.Model.ModelPaint;
            }

            app.Model.DiagramPanel.AutoScrollMinSize = Size;
            app.Model.DiagramPanel.ResumeLayout();
            app.Model.DiagramPanel.Refresh();
        }

        // Line and shape menus
        public void ShowShapeMenu(Point startLocation)
        {
            app.Model.DiagramPanel.Cursor = Cursors.Arrow;

            if (Parent != null)
            {
                clickLocation = PanelPointToTypeSpace(startLocation);
            }
            else
            {
                clickLocation = startLocation;
            }
            app.Selected.Clear();
            if (availableShapes.Count > 1)
            {
                shapeComboBox = new ComboBox();
                shapeComboBox.Width = 150;
                shapeComboBox.Items.AddRange(availableShapes.ToArray());
                shapeComboBox.Location = startLocation;
                shapeComboBox.SelectedIndexChanged += ShapeSelected;
                app.Model.DiagramPanel.Controls.Add(shapeComboBox);
                shapeComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
                shapeComboBox.DroppedDown = true;
            }
            else if (availableShapes.Count == 1)
            {
                DP_Shape newShape = CreateShape(availableShapes[0], clickLocation);
                app.createToolButton.Checked = false;
                if (newShape != null)
                {
                    app.Selected.Add(newShape);
                    app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
                }
            }
        }

        protected void ShapeSelected(object sender, EventArgs e)
        {
            app.Model.DiagramPanel.Controls.Remove(shapeComboBox);
            DP_Shape newShape = CreateShape(shapeComboBox.Text, clickLocation);
            app.createToolButton.Checked = false;
            if (newShape != null)
            {
                app.Selected.Add(newShape);
                app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
            }
            shapeComboBox.Dispose();
        }

        public void ShowLineMenu(DomainProDesigner.DP_ConnectionSpec newLineSrc,
            DomainProDesigner.DP_ConnectionSpec newLineDest)
        {
            app.Model.DiagramPanel.Cursor = Cursors.Arrow;

            lineSrc = newLineSrc;
            lineDest = newLineDest;
            if (availableLines.Count > 1)
            {
                lineComboBox = new ComboBox();
                lineComboBox.Items.AddRange(availableLines.ToArray());
                lineComboBox.Location = newLineDest.Attached != null
                    ? newLineDest.Attached.Parent.TypePointToPanelSpace(
                        new Point(newLineDest.Attached.Left + newLineDest.Offset.X,
                            newLineDest.Attached.Top + newLineDest.Offset.Y))
                    : newLineDest.Offset;
                lineComboBox.SelectedIndexChanged += LineSelected;
                app.Model.DiagramPanel.Controls.Add(lineComboBox);
                lineComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
                lineComboBox.DroppedDown = true;
            }
            else if (availableLines.Count == 1)
            {
                DP_Line newLine = CreateLine(availableLines[0], lineSrc, lineDest);
                app.connectToolButton.Checked = false;
                if (newLine != null)
                {
                    app.Selected.Clear();
                    app.Selected.Add(newLine);
                    app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
                }
            }
        }

        protected void LineSelected(object sender, EventArgs e)
        {
            DP_Line newLine = CreateLine(lineComboBox.Text, lineSrc, lineDest);
            app.connectToolButton.Checked = false;
            app.Model.DiagramPanel.Controls.Remove(lineComboBox);
            if (newLine != null)
            {
                app.Selected.Clear();
                app.Selected.Add(newLine);
                app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
            }
            lineComboBox.Dispose();
        }

        // Mouse event handlers
        private void DiagramMouseClick(object sender, MouseEventArgs e)
        {
            DP_ConcreteType handlingType = GetTypeAtLocation(e.Location);
            if (handlingType != null && handlingType != this.Parent)
            {
                handlingType.TypeMouseClick(sender, e);
                return;
            }

            if (app.createToolButton.Checked)
            {
                if (!selectBox)
                {
                    ShowShapeMenu(new Point(e.X, e.Y));
                }
            }
            else if (app.connectToolButton.Checked)
            {
                if (app.ConnectionStart == null)
                {
                    DomainProDesigner.DP_ConnectionSpec role = new DomainProDesigner.DP_ConnectionSpec();
                    role.Offset = PanelPointToDiagramSpace(e.Location);
                    app.ConnectionStart = role;
                    app.Model.DiagramPanel.MouseMove += DiagramPanelConnLineDrag;
                    app.Model.DiagramPanel.Paint += DiagramPanelDrawConnLine;
                }
                else
                {
                    app.Model.DiagramPanel.MouseMove -= DiagramPanelConnLineDrag;
                    app.Model.DiagramPanel.Paint -= DiagramPanelDrawConnLine;
                    DiagramPanelConnLineDrag(sender, e);
                    DomainProDesigner.DP_ConnectionSpec role = new DomainProDesigner.DP_ConnectionSpec();
                    role.Offset = PanelPointToDiagramSpace(e.Location);
                    ShowLineMenu(app.ConnectionStart, role);
                    app.ConnectionStart = null;
                    connLine = false;
                    connStartPos = new Point(0, 0);
                    lastConnLine = new Point(0, 0);
                    lastConnMousePos = new Point(0, 0);
                }
            }
        }

        private void DiagramMouseDoubleClick(object sender, MouseEventArgs e)
        {
            DP_ConcreteType handlingType = GetTypeAtLocation(e.Location);
            if (handlingType != null && handlingType != this.Parent)
            {
                handlingType.TypeMouseDoubleClick(sender, e);
                return;
            }
        }

        private void DiagramMouseDown(object sender, MouseEventArgs e)
        {
            DP_ConcreteType handlingType = GetTypeAtLocation(e.Location);
            if (handlingType != null && handlingType != this.Parent)
            {
                handlingType.TypeMouseDown(sender, e);
            }
            else
            {
                if ((Control.ModifierKeys & Keys.Control) != Keys.Control)
                {
                    app.Selected.Clear();
                }

                if (!app.connectToolButton.Checked)
                {
                    selectStartPos = PanelPointToDiagramSpace(e.Location);
                    app.Model.DiagramPanel.MouseMove += DiagramPanelSelectBoxDrag;
                    app.Model.DiagramPanel.MouseUp += DiagramPanelSelectBoxMouseUp;
                    app.Model.DiagramPanel.Paint += DiagramPanelDrawSelectBox;
                }
            }
            app.Model.DiagramPanel.Focus();
        }

        private void DiagramMouseUp(object sender, MouseEventArgs e)
        {
            DP_ConcreteType handlingType = GetTypeAtLocation(e.Location);
            if (handlingType != null && handlingType != this.Parent)
            {
                handlingType.TypeMouseUp(sender, e);
            }
            else
            {
            }

            app.Model.DiagramPanel.Focus();
        }

        private void DiagramMouseMove(object sender, MouseEventArgs e)
        {
            DP_ConcreteType handlingType = GetTypeAtLocation(e.Location);

            if (app.connectToolButton.Checked)
            {
                if (typeAtMouseLocation != handlingType)
                {
                    if (typeAtMouseLocation != null)
                    {
                        typeAtMouseLocation.TypeMouseLeave(sender, e);
                    }
                    if (handlingType != null)
                    {
                        handlingType.TypeMouseEnter(sender, e);
                    }
                    typeAtMouseLocation = handlingType;
                }
                if (typeAtMouseLocation != null)
                {
                    typeAtMouseLocation.TypeMouseMove(sender, e);
                }
                else
                {
                    app.Model.DiagramPanel.Cursor = Cursors.Arrow;
                }
            }
            else
            {
                if (typeAtMouseLocation != handlingType && handlingType != this.Parent)
                {
                    if (typeAtMouseLocation != null)
                    {
                        typeAtMouseLocation.TypeMouseLeave(sender, e);
                    }
                    if (handlingType != null)
                    {
                        handlingType.TypeMouseEnter(sender, e);
                    }
                    typeAtMouseLocation = handlingType;
                }
                if (typeAtMouseLocation != null)
                {
                    typeAtMouseLocation.TypeMouseMove(sender, e);
                }
                else
                {
                    app.Model.DiagramPanel.Cursor = Cursors.Arrow;
                }
            }
        }

        // Connection line methods
        public void DiagramPanelConnLineDrag(object sender, MouseEventArgs e)
        {
            if (!connLine)
            {
                connLine = true;
                connStartPos = PanelPointToDiagramSpace(e.Location);
                lastConnLine = PanelPointToDiagramSpace(e.Location);
            }

            /*
            startPos = app.ConnectionStart.Attached != null ?
                app.ConnectionStart.Attached.Diagram.TypePointToPanelSpace(
                    new Point(app.ConnectionStart.Attached.Location.X + app.ConnectionStart.Offset.X, app.ConnectionStart.Attached.Location.Y + app.ConnectionStart.Offset.Y)) :
                DiagramPointToPanelSpace(app.ConnectionStart.Offset);
             * */
            if (lastConnLine != connStartPos)
            {
                GraphicsPath path = new GraphicsPath();
                path.AddLine(
                    DiagramPointToPanelSpace(connStartPos),
                    DiagramPointToPanelSpace(lastConnLine));
                path.Widen(new Pen(Color.Black, 3));
                Region region = new Region(path);
                //Brush b = new SolidBrush(Color.Blue);
                //app.Model.DiagramPanel.CreateGraphics().FillRegion(b, region2);
                app.Model.DiagramPanel.Invalidate(region, false);
            }

            lastConnMousePos = PanelPointToDiagramSpace(e.Location);
            if (lastConnMousePos != connStartPos)
            {
                GraphicsPath path = new GraphicsPath();
                path.AddLine(
                    DiagramPointToPanelSpace(connStartPos).X,
                    DiagramPointToPanelSpace(connStartPos).Y,
                    DiagramPointToPanelSpace(lastConnMousePos).X,
                    DiagramPointToPanelSpace(lastConnMousePos).Y);
                path.Widen(new Pen(Color.Black, 1));
                Region region = new Region(path);
                //Brush b = new SolidBrush(Color.Red);
                //app.Model.DiagramPanel.CreateGraphics().FillRegion(b, region);
                app.Model.DiagramPanel.Invalidate(region, false);
            }

            app.Model.DiagramPanel.Update();
        }

        public void DiagramPanelDrawConnLine(object sender, PaintEventArgs e)
        {
            /*
            Point startPos = app.ConnectionStart.Attached != null ?
                app.ConnectionStart.Attached.Diagram.TypePointToPanelSpace(
                    new Point(app.ConnectionStart.Attached.Location.X + app.ConnectionStart.Offset.X, app.ConnectionStart.Attached.Location.Y + app.ConnectionStart.Offset.Y)) :
                app.ConnectionStart.Offset;
             * */

            Graphics graphics = e.Graphics;
            Pen pen = new Pen(Color.Black, 1);
            pen.DashStyle = DashStyle.Dash;
            graphics.DrawLine(
                pen,
                DiagramPointToPanelSpace(connStartPos).X,
                DiagramPointToPanelSpace(connStartPos).Y,
                DiagramPointToPanelSpace(lastConnMousePos).X,
                DiagramPointToPanelSpace(lastConnMousePos).Y);
            lastConnLine = lastConnMousePos;
        }

        // Select box methods
        public void DiagramPanelSelectBoxDrag(object sender, MouseEventArgs e)
        {
            if (!selectBox &&
                (Math.Abs(selectStartPos.X - PanelPointToDiagramSpace(e.Location).X) > app.StartSelectSize ||
                 Math.Abs(selectStartPos.Y - PanelPointToDiagramSpace(e.Location).Y) > app.StartSelectSize))
            {
                selectBox = true;
                lastSelectBox = PanelPointToDiagramSpace(e.Location);
            }

            if (selectBox)
            {
                int xDiff = PanelPointToDiagramSpace(e.Location).X - lastSelectMousePos.X > 0 ? 1 : -1;
                    //Math.Abs(e.X - lastMousePos.X) + 1;
                int yDiff = PanelPointToDiagramSpace(e.Location).Y - lastSelectMousePos.Y > 0 ? 1 : -1;
                    // Math.Abs(e.Y - lastMousePos.Y) + 1;

                Point selectStartPosPanel = DiagramPointToPanelSpace(selectStartPos);

                if (selectStartPos != lastSelectBox)
                {
                    Point lastSelectBoxPanel = DiagramPointToPanelSpace(lastSelectBox);
                    GraphicsPath path = new GraphicsPath();
                    path.AddLine(selectStartPosPanel.X, selectStartPosPanel.Y, selectStartPosPanel.X,
                        lastSelectBoxPanel.Y);
                    path.AddLine(selectStartPosPanel.X, lastSelectBoxPanel.Y, lastSelectBoxPanel.X, lastSelectBoxPanel.Y);
                    path.AddLine(lastSelectBoxPanel.X, lastSelectBoxPanel.Y, lastSelectBoxPanel.X, selectStartPosPanel.Y);
                    path.AddLine(lastSelectBoxPanel.X, selectStartPosPanel.Y, selectStartPosPanel.X,
                        selectStartPosPanel.Y);
                    /*
                    path.AddLine(selectStartPosPanel.X, lastSelectBoxPanel.Y - yDiff, selectStartPosPanel.X, e.Y);
                    path.AddLine(selectStartPosPanel.X, e.Y, e.X, e.Y);
                    path.AddLine(e.X, e.Y, e.X, selectStartPosPanel.Y);
                    path.AddLine(e.X, selectStartPosPanel.Y, lastSelectBoxPanel.X - xDiff, selectStartPosPanel.Y);
                    path.AddLine(lastSelectBoxPanel.X, selectStartPosPanel.Y, lastSelectBoxPanel.X, lastSelectBoxPanel.Y);
                    path.AddLine(lastSelectBoxPanel.X, lastSelectBoxPanel.Y, selectStartPosPanel.X, lastSelectBoxPanel.Y);
                    */
                    path.Widen(new Pen(Color.Black, 1));
                    Region region = new Region(path);
                    app.Model.DiagramPanel.Invalidate(region, false);
                }

                lastSelectMousePos = PanelPointToDiagramSpace(e.Location);

                if (selectStartPos != lastSelectMousePos)
                {
                    GraphicsPath path = new GraphicsPath();
                    path.AddLine(selectStartPosPanel.X, selectStartPosPanel.Y, selectStartPosPanel.X, e.Y);
                    path.AddLine(selectStartPosPanel.X, e.Y, e.X, e.Y);
                    path.AddLine(e.X, e.Y, e.X, selectStartPosPanel.Y);
                    path.AddLine(e.X, selectStartPosPanel.Y, selectStartPosPanel.X, selectStartPosPanel.Y);

                    path.Widen(new Pen(Color.Black, 1));
                    Region region = new Region(path);
                    app.Model.DiagramPanel.Invalidate(region, false);
                }

                app.Model.DiagramPanel.Update();
            }
        }

        public void DiagramPanelDrawSelectBox(object sender, PaintEventArgs e)
        {
            if (selectBox)
            {
                Point topLeft =
                    DiagramPointToPanelSpace(new Point(Math.Min(lastSelectMousePos.X, selectStartPos.X),
                        Math.Min(lastSelectMousePos.Y, selectStartPos.Y)));
                Point bottomRight =
                    DiagramPointToPanelSpace(new Point(Math.Max(lastSelectMousePos.X, selectStartPos.X),
                        Math.Max(lastSelectMousePos.Y, selectStartPos.Y)));

                Graphics graphics = e.Graphics;
                Pen pen = new Pen(Color.Black, 1);
                pen.DashStyle = DashStyle.Dot;
                GraphicsPath path = new GraphicsPath();
                path.AddLine(topLeft.X, topLeft.Y, topLeft.X, bottomRight.Y);
                path.AddLine(topLeft.X, bottomRight.Y, bottomRight.X, bottomRight.Y);
                path.AddLine(bottomRight.X, bottomRight.Y, bottomRight.X, topLeft.Y);
                path.AddLine(bottomRight.X, topLeft.Y, topLeft.X, topLeft.Y);
                graphics.DrawPath(pen, path);

                lastSelectBox = lastSelectMousePos;
            }
        }

        public void DiagramPanelSelectBoxMouseUp(object sender, MouseEventArgs e)
        {
            app.Model.DiagramPanel.MouseMove -= DiagramPanelSelectBoxDrag;
            app.Model.DiagramPanel.MouseUp -= DiagramPanelSelectBoxMouseUp;
            app.Model.DiagramPanel.Paint -= DiagramPanelDrawSelectBox;

            if (selectBox)
            {
                DiagramPanelSelectBoxDrag(sender, e);
                //int xDiff = e.X - lastConnMousePos.X > 0 ? 1 : -1; //Math.Abs(e.X - lastMousePos.X) + 1;
                //int yDiff = e.Y - lastConnMousePos.Y > 0 ? 1 : -1; // Math.Abs(e.Y - lastMousePos.Y) + 1;
                /*
                GraphicsPath path = new GraphicsPath();
                path.AddLine(selectStartPos.X, selectStartPos.Y, selectStartPos.X, lastSelectBox.Y);
                path.AddLine(selectStartPos.X, lastSelectBox.Y, lastSelectBox.X, lastSelectBox.Y);
                path.AddLine(lastSelectBox.X, lastSelectBox.Y, lastSelectBox.X, selectStartPos.Y);
                path.AddLine(lastSelectBox.X, selectStartPos.Y, selectStartPos.X, selectStartPos.Y);
                path.Widen(new Pen(Color.Black, 1));
                Region region = new Region(path);

                app.Model.DiagramPanel.Invalidate(region, false);
                */
                if ((Control.ModifierKeys & Keys.Control) != Keys.Control)
                {
                    app.Selected.Clear();
                }

                Rectangle selectedRectangle = new Rectangle(
                    Math.Min(e.X, DiagramPointToPanelSpace(selectStartPos).X),
                    Math.Min(e.Y, DiagramPointToPanelSpace(selectStartPos).Y),
                    Math.Abs(e.X - DiagramPointToPanelSpace(selectStartPos).X),
                    Math.Abs(e.Y - DiagramPointToPanelSpace(selectStartPos).Y));

                foreach (DP_ConcreteType type in Types)
                {
                    if (!type.Hidden && selectedRectangle.Contains(DiagramPointToPanelSpace(type.Center)))
                    {
                        app.Selected.Add(type);
                    }
                }
                selectBox = false;
                selectStartPos = new Point(0, 0);
                lastSelectMousePos = new Point(0, 0);
                lastSelectBox = new Point(0, 0);
            }
        }

        // Shape drag methods
        public void DiagramPanelShapeDrag(object sender, MouseEventArgs e)
        {
            if (!startDrag &&
                (Math.Abs(PanelPointToDiagramSpace(e.Location).X - dragStartPos.X) > app.StartDragSize ||
                 Math.Abs(PanelPointToDiagramSpace(e.Location).Y - dragStartPos.Y) > app.StartDragSize))
            {
                startDrag = true;
                dragStartPos = PanelPointToDiagramSpace(e.Location);
                lastDragBox = PanelPointToDiagramSpace(e.Location);
                dragBoxSize = new Size(
                    SelectedBottomRight().X - SelectedTopLeft().X - 1,
                    SelectedBottomRight().Y - SelectedTopLeft().Y - 1);
            }

            if (startDrag)
            {
                Point lastDragBoxPanel = DiagramPointToPanelSpace(lastDragBox);
                GraphicsPath path = new GraphicsPath();
                path.AddLine(lastDragBoxPanel.X, lastDragBoxPanel.Y, lastDragBoxPanel.X + dragBoxSize.Width,
                    lastDragBoxPanel.Y);
                path.AddLine(lastDragBoxPanel.X + dragBoxSize.Width, lastDragBoxPanel.Y,
                    lastDragBoxPanel.X + dragBoxSize.Width, lastDragBoxPanel.Y + dragBoxSize.Height);
                path.AddLine(lastDragBoxPanel.X + dragBoxSize.Width, lastDragBoxPanel.Y + dragBoxSize.Height,
                    lastDragBoxPanel.X, lastDragBoxPanel.Y + dragBoxSize.Height);
                path.AddLine(lastDragBoxPanel.X, lastDragBoxPanel.Y + dragBoxSize.Height, lastDragBoxPanel.X,
                    lastDragBoxPanel.Y);
                path.Widen(new Pen(Color.Black, 1));
                Region region = new Region(path);
                app.Model.DiagramPanel.Invalidate(region, false);

                lastDragMousePos = new Point(
                    PanelPointToDiagramSpace(e.Location).X - dragStartPos.X + SelectedTopLeft().X,
                    PanelPointToDiagramSpace(e.Location).Y - dragStartPos.Y + SelectedTopLeft().Y);

                Point dragBoxLocationPanel = DiagramPointToPanelSpace(lastDragMousePos);
                path = new GraphicsPath();
                path.AddLine(dragBoxLocationPanel.X, dragBoxLocationPanel.Y, dragBoxLocationPanel.X + dragBoxSize.Width,
                    dragBoxLocationPanel.Y);
                path.AddLine(dragBoxLocationPanel.X + dragBoxSize.Width, dragBoxLocationPanel.Y,
                    dragBoxLocationPanel.X + dragBoxSize.Width, dragBoxLocationPanel.Y + dragBoxSize.Height);
                path.AddLine(dragBoxLocationPanel.X + dragBoxSize.Width, dragBoxLocationPanel.Y + dragBoxSize.Height,
                    dragBoxLocationPanel.X, dragBoxLocationPanel.Y + dragBoxSize.Height);
                path.AddLine(dragBoxLocationPanel.X, dragBoxLocationPanel.Y + dragBoxSize.Height, dragBoxLocationPanel.X,
                    dragBoxLocationPanel.Y);
                path.Widen(new Pen(Color.Black, 1));
                region = new Region(path);
                app.Model.DiagramPanel.Invalidate(region, false);

                foreach (DP_ConcreteType type in app.Selected)
                {
                    if (type is DP_Shape)
                    {
                        DP_Shape shape = (DP_Shape) type;
                        shape.Location = new Point(
                            shape.Left + PanelPointToDiagramSpace(e.Location).X - dragStartPos.X,
                            shape.Top + PanelPointToDiagramSpace(e.Location).Y - dragStartPos.Y);
                        app.ModelState = DomainProDesigner.DP_ModelState.OpenChanged;
                    }
                }

                app.Model.DiagramPanel.Update();

                dragStartPos = PanelPointToDiagramSpace(e.Location);
            }
        }

        public void DiagramPanelDrawShapeDragBox(object sender, PaintEventArgs e)
        {
            if (startDrag)
            {
                Point dragBoxLocationPanel = DiagramPointToPanelSpace(lastDragMousePos);
                Graphics graphics = e.Graphics;
                Pen pen = new Pen(Color.Black, 1);
                pen.DashStyle = DashStyle.Solid;
                GraphicsPath path = new GraphicsPath();
                path.AddLine(dragBoxLocationPanel.X, dragBoxLocationPanel.Y, dragBoxLocationPanel.X + dragBoxSize.Width,
                    dragBoxLocationPanel.Y);
                path.AddLine(dragBoxLocationPanel.X + dragBoxSize.Width, dragBoxLocationPanel.Y,
                    dragBoxLocationPanel.X + dragBoxSize.Width, dragBoxLocationPanel.Y + dragBoxSize.Height);
                path.AddLine(dragBoxLocationPanel.X + dragBoxSize.Width, dragBoxLocationPanel.Y + dragBoxSize.Height,
                    dragBoxLocationPanel.X, dragBoxLocationPanel.Y + dragBoxSize.Height);
                path.AddLine(dragBoxLocationPanel.X, dragBoxLocationPanel.Y + dragBoxSize.Height, dragBoxLocationPanel.X,
                    dragBoxLocationPanel.Y);

                graphics.DrawPath(pen, path);
                lastDragBox = lastDragMousePos;
            }
        }

        public void DiagramPanelShapeDragBoxMouseUp(object sender, MouseEventArgs e)
        {
            app.Model.DiagramPanel.MouseMove -= DiagramPanelShapeDrag;
            app.Model.DiagramPanel.MouseUp -= DiagramPanelShapeDragBoxMouseUp;
            app.Model.DiagramPanel.Paint -= DiagramPanelDrawShapeDragBox;

            if (startDrag)
            {
                DiagramPanelShapeDrag(sender, e);
                startDrag = false;
                dragStartPos = new Point(0, 0);
                dragBoxSize = new Size(0, 0);
                lastDragBox = new Point(0, 0);
                lastDragMousePos = new Point(0, 0);
            }
        }

        // Scrollbar methods
        public void TypeLocationChanged(object sender, EventArgs e)
        {
            if (IsMainDiagram)
            {
                app.Model.DiagramPanel.AutoScrollMinSize = Size;
            }
        }

        // Utility
        public Point DiagramPointToTypeSpace(Point point)
        {
            DP_ConcreteType nextParent = Parent;
            while (nextParent != null && !nextParent.Diagram.IsMainDiagram)
            {
                point.X -= nextParent.Left;
                point.Y -= nextParent.Top;
                nextParent = nextParent.Parent.Parent;
            }

            return point;
        }

        public Point TypePointToDiagramSpace(Point point)
        {
            if (Parent != null)
            {
                DP_ConcreteType nextParent = Parent;
                while (nextParent != null && !nextParent.Diagram.IsMainDiagram)
                {
                    point.X += nextParent.Left;
                    point.Y += nextParent.Top;
                    nextParent = nextParent.Parent.Parent;
                }
            }
            return point;
        }

        public Point PanelPointToTypeSpace(Point point)
        {
            return DiagramPointToTypeSpace(PanelPointToDiagramSpace(point));
        }

        public Point TypePointToPanelSpace(Point point)
        {
            return DiagramPointToPanelSpace(TypePointToDiagramSpace(point));
        }

        public Point DiagramPointToPanelSpace(Point point)
        {
            point.X += app.Model.DiagramPanel.DisplayRectangle.Left;
            point.Y += app.Model.DiagramPanel.DisplayRectangle.Top;
            return point;
        }

        public Point PanelPointToDiagramSpace(Point point)
        {
            point.X -= app.Model.DiagramPanel.DisplayRectangle.Left;
            point.Y -= app.Model.DiagramPanel.DisplayRectangle.Top;
            return point;
        }

        private Point SelectedTopLeft()
        {
            Point topLeft = new Point(app.Model.DiagramPanel.DisplayRectangle.Width,
                app.Model.DiagramPanel.DisplayRectangle.Height);
            foreach (DP_ConcreteType type in app.Selected)
            {
                if (type is DP_Shape)
                {
                    if (TypePointToDiagramSpace(type.Location).X < topLeft.X)
                    {
                        topLeft.X = TypePointToDiagramSpace(type.Location).X;
                    }
                    if (TypePointToDiagramSpace(type.Location).Y < topLeft.Y)
                    {
                        topLeft.Y = TypePointToDiagramSpace(type.Location).Y;
                    }
                }
            }
            return topLeft;
        }

        private Point SelectedBottomRight()
        {
            Point bottomRight = new Point(0, 0);
            foreach (DP_ConcreteType type in app.Selected)
            {
                if (type is DP_Shape)
                {
                    if (TypePointToDiagramSpace(type.Location).X + type.Size.Width > bottomRight.X)
                    {
                        bottomRight.X = TypePointToDiagramSpace(type.Location).X + type.Size.Width;
                    }
                    if (TypePointToDiagramSpace(type.Location).Y + type.Size.Height > bottomRight.Y)
                    {
                        bottomRight.Y = TypePointToDiagramSpace(type.Location).Y + type.Size.Height;
                    }
                }
            }
            return bottomRight;
        }

        public DP_ConcreteType GetTypeAtLocation(Point point)
        {
            for (int i = Types.Count - 1; i >= 0; i--)
            {
                DP_ConcreteType type = (DP_ConcreteType) Types[i];
                if (type.Area.IsVisible(point))
                {
                    if (type.Diagram != null)
                    {
                        return type.Diagram.GetTypeAtLocation(point);
                    }
                    else
                    {
                        return type;
                    }
                }
            }
            return Parent;
        }

        public DP_ConcreteType GetTypeAtDropLocation(Point point, DP_ConcreteType dropped)
        {
            for (int i = Types.Count - 1; i >= 0; i--)
            {
                DP_ConcreteType type = (DP_ConcreteType) Types[i];
                if (type != dropped && type.Area.IsVisible(point))
                {
                    if (type.Diagram != null)
                    {
                        return type.Diagram.GetTypeAtDropLocation(point, dropped);
                    }
                    else
                    {
                        return type;
                    }
                }
            }
            return Parent;
        }
    }
}