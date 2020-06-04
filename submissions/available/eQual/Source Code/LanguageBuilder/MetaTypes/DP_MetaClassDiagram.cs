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
using System.Xml.Serialization;
using System.Windows.Forms;
using DomainPro.Designer;
using DomainPro.Designer.Types;

namespace LanguageBuilder.MetaTypes
{
    public class DP_MetaClassDiagram : DP_Diagram
    {
        public DP_MetaClassDiagram()
        {
            availableShapes.Add("Property Group");
        }

        public override DP_Shape CreateShape(string shapeType, Point startLocation)
        {
            if (shapeType == "Property Group")
            {
                DP_MetaPropertyGroup newShape = new DP_MetaPropertyGroup(startLocation);
                newShape.Initialize(this);
                return newShape;
            }

            return null;
        }

        public override DP_Line CreateLine(string lineType, DomainProDesigner.DP_ConnectionSpec src, DomainProDesigner.DP_ConnectionSpec dest)
        {
            return null;
        }
    }
}
