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
using System.Windows.Forms;
using DomainPro.Designer;
using DomainPro.Designer.Types;

namespace LanguageBuilder.MetaTypes
{
    public class DP_MetamodelDiagram : DP_Diagram
    {
        public DP_MetamodelDiagram()
        {
            availableShapes.Add("Class");

            availableLines.Add("Reference");
            availableLines.Add("Containment");
            availableLines.Add("Inheritance");
        }

        public override DP_Shape CreateShape(string shapeType, Point startLocation)
        {
            if (shapeType == "Class")
            {
                DP_MetaClass newShape = new DP_MetaClass(startLocation);
                newShape.Initialize(this);
                return newShape;
            }
            return null;
        }

        public override DP_Line CreateLine(string lineType, DomainProDesigner.DP_ConnectionSpec src, DomainProDesigner.DP_ConnectionSpec dest)
        {
            if (lineType == "Reference")
            {
                if (DP_MetaReference.ValidRoles(src.Attached, dest.Attached))
                {
                    DP_MetaReference newLine = new DP_MetaReference(src, dest);
                    newLine.Initialize(this);
                    return newLine;
                }
            }
            if (lineType == "Containment")
            {
                if (DP_MetaContainment.ValidRoles(src.Attached, dest.Attached))
                {
                    DP_MetaContainment newLine = new DP_MetaContainment(src, dest);
                    newLine.Initialize(this);
                    return newLine;
                }
            }
            if (lineType == "Inheritance")
            {
                if (DP_MetaInheritance.ValidRoles(src.Attached, dest.Attached))
                {
                    DP_MetaInheritance newLine = new DP_MetaInheritance(src, dest);
                    newLine.Initialize(this);
                    return newLine;
                }
            }
            return null;
        }
    }
}
