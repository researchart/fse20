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
using DomainPro.Designer.Types;

namespace LanguageBuilder.MetaTypes
{

    public abstract class DP_MetaProperty : DP_Shape
    {
        protected override void SetParams()
        {
            ShapeProperties.Shape = DP_ShapeType.Rectangle;
            ShapeProperties.DefaultSize = new Size(40, 20);
            ShapeProperties.IsResizable = false;
            ShapeProperties.BorderStyle = DashStyle.Solid;
            ShapeProperties.BorderColor = Color.Empty;
            ShapeProperties.BorderWidth = 0;
            ShapeProperties.FillColor = Color.Empty;
            ShapeProperties.CornerRounding = 2;
            ShapeProperties.DockStyle = DockStyle.Left;
            ShapeProperties.Alignment = ContentAlignment.TopLeft;
            ShapeProperties.Icon = "";

            Name = "NewProperty";
            DisplayName = Name;
            ShowName = true;
            Size = ShapeProperties.DefaultSize;
            NameFont = new Font("Segoe UI", (float)7.8, FontStyle.Regular);
            
            
        }

        public DP_MetaProperty()
        {          
        }

        public DP_MetaProperty(Point startLocation) :
            base(startLocation)
        {
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);
        }
    }
}
