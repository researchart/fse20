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
using System.Windows.Forms;
using System.Xml.Serialization;
using System.Drawing;
using System.Drawing.Drawing2D;
using DomainPro.Core.Types;
using DomainPro.Designer.Types;
using DomainPro.Designer.Controls;


namespace LanguageBuilder.MetaTypes
{
    [XmlInclude(typeof(DP_MetaPropertyGroupDiagram))]
    [XmlInclude(typeof(DP_MetaProperty))]
    [XmlInclude(typeof(DP_SimpleMetaProperty))]
    [XmlInclude(typeof(DP_ComplexMetaProperty))]
    public class DP_MetaPropertyGroup : DP_Shape
    {
        protected override void SetParams()
        {
            ShapeProperties.Shape = DP_ShapeType.Ellipse;
            ShapeProperties.DefaultSize = new Size(80, 40);
            ShapeProperties.IsResizable = true;
            ShapeProperties.BorderStyle = DashStyle.Dash;
            ShapeProperties.BorderColor = Color.Black;
            ShapeProperties.BorderWidth = 1;
            ShapeProperties.FillColor = Color.Empty;
            ShapeProperties.CornerRounding = 0;
            ShapeProperties.DockStyle = DockStyle.None;
            ShapeProperties.Alignment = ContentAlignment.MiddleCenter;
            ShapeProperties.Icon = "";

            Name = "NewPropertyGroup";
            DisplayName = Name;
            ShowName = true;
            Size = ShapeProperties.DefaultSize;
            NameFont = new Font("Segoe UI", (float)7.8, FontStyle.Bold);

            TreeNode.ImageIndex = 9;
            TreeNode.SelectedImageIndex = 9;
        }

        public DP_MetaPropertyGroup()
        {          
        }

        public DP_MetaPropertyGroup(Point startLocation) :
            base(startLocation)
        {
            Diagram = new DP_MetaPropertyGroupDiagram();
            Text = new DP_Text();
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);

            Diagram.Initialize(this);
        }

        public override DP_ConcreteType Duplicate()
        {
            DP_MetaPropertyGroup newType = new DP_MetaPropertyGroup();
            newType.Diagram = new DP_MetaPropertyGroupDiagram();
            newType.Text = new DP_Text();
            newType.Copy(this);
            return newType;
        }
    }


}
