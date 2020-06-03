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
using DomainPro.Designer.Types;
using DomainPro.Designer.Controls;


namespace LanguageBuilder.MetaTypes
{
    [XmlInclude(typeof(DP_MetaClassDiagram)),
    XmlInclude(typeof(DP_MetaPropertyGroup)),
    XmlRoot(ElementName="Type")]
    public class DP_MetaClass : DP_Shape
    {
        private bool instanceIsRoot = false;

        [DisplayName("Is Root Type?"),
        Category("Type"),
        DefaultValue(false),
        Description("Sets whether instances of the type can be created in the root diagram.")]
        public bool InstanceIsRoot
        {
            get { return instanceIsRoot; }
            set { instanceIsRoot = value; }
        }

        private bool instanceIsAbstract = false;

        [DisplayName("Is Abstract Type?"),
        Category("Type"),
        DefaultValue(false),
        Description("Sets whether the type can be instantiated in models.")]
        public bool InstanceIsAbstract
        {
            get { return instanceIsAbstract; }
            set { instanceIsAbstract = value; }
        }

        private bool instanceHidden = false;

        [DisplayName("Hidden"),
        Category("Type"),
        DefaultValue(false),
        Description("Sets whether the type is visible in diagrams.")]
        public bool InstanceHidden
        {
            get { return instanceHidden; }
            set { instanceHidden = value; }
        }

        private string instanceRole1Name = "";

        [DisplayName("Role 1 Name"),
        Category("Type"),
        DefaultValue(""),
        Description("Indicates the name of the first role.")]
        public string InstanceRole1Name
        {
            get { return instanceRole1Name; }
            set { instanceRole1Name = value; }
        }

        private string instanceRole2Name = "";

        [DisplayName("Role 2 Name"),
        Category("Type"),
        DefaultValue(""),
        Description("Indicates the name of the second role.")]
        public string InstanceRole2Name
        {
            get { return instanceRole2Name; }
            set { instanceRole2Name = value; }
        }

        private DP_PresentationType instancePresentationType = DP_PresentationType.Shape;

        [DisplayName("Presentation Type"),
        Category("Presentation"),
        DefaultValue(DP_PresentationType.Shape),
        Description("Sets the way instances of the type are displayed.")]
        public DP_PresentationType InstancePresentationType
        {
            get { return instancePresentationType; }
            set { instancePresentationType = value; }
        }

        private bool instanceShowName = true;

        [DisplayName("Show Name?"),
        Category("Presentation"),
        DefaultValue(true),
        Description("Sets whether instances of the type display their names.")]
        public bool InstanceShowName
        {
            get { return instanceShowName; }
            set { instanceShowName = value; }
        }

        private Font instanceNameFont = new Font("Segoe UI", (float)9, FontStyle.Regular);

        [XmlIgnore,
        DisplayName("Font"),
        Category("Presentation"),
        Description("Sets the name font of instances of the type.")]
        public Font InstanceNameFont
        {
            get { return instanceNameFont; }
            set { instanceNameFont = value; }
        }

        [Browsable(false)]
        public DP_Font InstanceNameTextFont
        {
            get
            {
                DP_Font newFont = new DP_Font();
                newFont.FontFamily = instanceNameFont.FontFamily.Name;
                newFont.Size = instanceNameFont.Size;
                newFont.Style = instanceNameFont.Style;
                return newFont;
            }
            set
            {
                instanceNameFont = new Font(value.FontFamily, value.Size, value.Style);
            }
        }

        private DP_Shape.DP_ShapeProperties instanceShapeProperties = new DP_Shape.DP_ShapeProperties();

        [DisplayName("Shape Properties"),
        Category("Presentation"),
        Description("Sets the shape properties for instances of the type.")]
        public DP_Shape.DP_ShapeProperties InstanceShapeProperties
        {
            get { return instanceShapeProperties; }
            set { instanceShapeProperties = value; }
        }

        private DP_Line.DP_LineProperties instanceLineProperties = new DP_Line.DP_LineProperties();

        [DisplayName("Line Properties"),
        Category("Presentation"),
        Description("Sets the line properties for instances of the type.")]
        public DP_Line.DP_LineProperties InstanceLineProperties
        {
            get { return instanceLineProperties; }
            set { instanceLineProperties = value; }
        }

        private DP_SimulationType instanceSimulationType = DP_SimulationType.Component;

        [DisplayName("Simulation Type"),
        Category("Simulation"),
        DefaultValue(DP_SimulationType.Component),
        Description("Sets the way instances of the type behave in simulation.")]
        public DP_SimulationType InstanceSimulationType
        {
            get { return instanceSimulationType; }
            set
            {
                instanceSimulationType = value;
                TreeNode.ImageIndex = (int)InstanceSimulationType;
                TreeNode.SelectedImageIndex = (int)InstanceSimulationType;
            }
        }

        protected override void SetParams()
        {
            ShapeProperties.Shape = DP_ShapeType.Rectangle;
            ShapeProperties.DefaultSize = new Size(100, 60);
            ShapeProperties.IsResizable = true;
            ShapeProperties.BorderStyle = DashStyle.Solid;
            ShapeProperties.BorderColor = Color.Black;
            ShapeProperties.BorderWidth = 2;
            ShapeProperties.FillColor = Color.White;
            ShapeProperties.GradientFill = true;
            ShapeProperties.GradientFillColor = Color.LightGray;
            ShapeProperties.CornerRounding = 10;
            ShapeProperties.DockStyle = DockStyle.None;
            ShapeProperties.Alignment = ContentAlignment.TopCenter;
            ShapeProperties.Icon = "";

            Name = "NewClass";
            DisplayName = Name;
            ShowName = true;
            Size = ShapeProperties.DefaultSize;
            NameFont = new Font("Segoe UI", (float)9, FontStyle.Bold);

            TreeNode.ImageIndex = (int)InstanceSimulationType;
            TreeNode.SelectedImageIndex = (int)InstanceSimulationType;
        }

        public DP_MetaClass()
        {
        }

        public DP_MetaClass(Point startLocation) :
            base(startLocation)
        {
            Diagram = new DP_MetaClassDiagram();
            Text = new DP_Text();
            InstanceLineProperties.Role1 = new DP_Line.DP_RoleProperties();
            InstanceLineProperties.Role2 = new DP_Line.DP_RoleProperties();
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);

            Diagram.Initialize(this);  

        }

        public override DP_ConcreteType Duplicate()
        {
            DP_MetaClass newType = new DP_MetaClass();
            newType.Diagram = new DP_MetaClassDiagram();
            newType.Text = new DP_Text();
            newType.Copy(this);
            return newType;
        }
    }
}
