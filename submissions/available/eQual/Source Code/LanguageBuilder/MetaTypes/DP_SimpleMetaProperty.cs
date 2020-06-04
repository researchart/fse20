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
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Xml.Serialization;
using System.ComponentModel;
using System.Windows.Forms;
using DomainPro.Core.Types;
using DomainPro.Designer.Types;
using DomainPro.Designer.Controls;

namespace LanguageBuilder.MetaTypes
{
    [XmlInclude(typeof(DP_SimpleMetaPropertyDiagram))]
    public class DP_SimpleMetaProperty : DP_MetaProperty
    {
        private string propertyType = "String";

        [DisplayName("Type"),
        Category("Type"),
        DefaultValue("String"),
        Description("Sets the domain of the property values.")]
        public string PropertyType
        {
            get { return propertyType; }
            set { propertyType = value; }
        }

        private string propertyDescription = "";

        [DisplayName("Description"),
        Category("Type"),
        DefaultValue(""),
        Description("Sets the description of the property.")]
        public string PropertyDescription
        {
            get { return propertyDescription; }
            set { propertyDescription = value; }
        }

        private string defaultValue = "";

        [DisplayName("Default Value"),
        Category("Type"),
        DefaultValue(""),
        Description("Sets the default value of the property.")]
        public string DefaultValue
        {
            get { return defaultValue; }
            set { defaultValue = value; }
        }

        protected override void SetParams()
        {
            ShapeProperties.Shape = DP_ShapeType.Rectangle;
            ShapeProperties.DefaultSize = new Size(80, 25);
            ShapeProperties.IsResizable = true;
            ShapeProperties.BorderStyle = DashStyle.Solid;
            ShapeProperties.BorderColor = Color.Empty;
            ShapeProperties.BorderWidth = 0;
            ShapeProperties.FillColor = Color.Empty;
            ShapeProperties.CornerRounding = 0;
            ShapeProperties.DockStyle = DockStyle.None;
            ShapeProperties.Alignment = ContentAlignment.TopCenter;
            ShapeProperties.Icon = "";

            Name = "NewProperty";
            DisplayName = Name;
            ShowName = true;
            Size = ShapeProperties.DefaultSize;
            NameFont = new Font("Segoe UI", (float)7.8, FontStyle.Regular);

            TreeNode.ImageIndex = 10;
            TreeNode.SelectedImageIndex = 10;
        }

        public DP_SimpleMetaProperty()
        {
        }

        public DP_SimpleMetaProperty(Point startLocation) :
            base(startLocation)
        {
            Diagram = new DP_SimpleMetaPropertyDiagram();
            Text = new DP_Text();
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);

            Diagram.Initialize(this);
        }

        public override DP_ConcreteType Duplicate()
        {
            DP_SimpleMetaProperty newType = new DP_SimpleMetaProperty();
            newType.Diagram = new DP_SimpleMetaPropertyDiagram();
            newType.Text = new DP_Text();
            newType.Copy(this);
            return newType;
        }
    }
}
