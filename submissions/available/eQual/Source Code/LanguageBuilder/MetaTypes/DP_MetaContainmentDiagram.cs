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
using DomainPro.Designer;
using DomainPro.Designer.Types;

namespace LanguageBuilder.MetaTypes
{
    public class DP_MetaContainmentDiagram : DP_Diagram
    {
        public DP_MetaContainmentDiagram()
        {
        }

        public override DP_Shape CreateShape(string shapeType, Point startLocation)
        {
            return null;
        }

        public override DP_Line CreateLine(string lineType, DomainProDesigner.DP_ConnectionSpec src, DomainProDesigner.DP_ConnectionSpec dest)
        {
            return null;
        }
    }
}
