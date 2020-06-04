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
using System.Drawing;
using System.Drawing.Drawing2D;
using DomainPro.Designer;
using DomainPro.Designer.Types;
using DomainPro.Designer.Controls;

namespace LanguageBuilder.MetaTypes
{
    public class DP_MetaPropertyGroupDiagram : DP_Diagram
    {
        public DP_MetaPropertyGroupDiagram()
        {
            availableShapes.Add("SimpleProperty");
            //availableShapes.Add("ComplexProperty");
        }

        public override DP_Shape CreateShape(string shapeType, Point startLocation)
        {
            if (shapeType == "SimpleProperty")
            {
                DP_SimpleMetaProperty newShape = new DP_SimpleMetaProperty(startLocation);
                newShape.Initialize(this);
                return newShape;
            }
            /*
            if (shapeType == "ComplexProperty")
            {
                DP_ComplexMetaProperty newShape = new DP_ComplexMetaProperty(startLocation);
                newShape.Initialize(this);
                return newShape;
            }
             * */

            return null;
        }

        public override DP_Line CreateLine(string lineType, DomainProDesigner.DP_ConnectionSpec src, DomainProDesigner.DP_ConnectionSpec dest)
        {
            return null;
        }
    }
}
