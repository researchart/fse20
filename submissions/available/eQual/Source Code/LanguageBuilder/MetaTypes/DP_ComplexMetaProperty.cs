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
using DomainPro.Core.Types;
using DomainPro.Designer.Types;

namespace LanguageBuilder.MetaTypes
{
    public class DP_ComplexMetaProperty : DP_MetaProperty
    {
        public DP_ComplexMetaProperty()
        {          
        }

        public DP_ComplexMetaProperty(Point startLocation) :
            base(startLocation)
        {
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);
        }

        public override DP_ConcreteType Duplicate()
        {
            DP_ComplexMetaProperty newType = new DP_ComplexMetaProperty();
            newType.name = name;
            return newType;
        }

        /*
        public override DP_Line CreateLine(string lineType, DP_ConcreteType dest)
        {
            DP_Line line = base.CreateLine(lineType, dest);
            if (line == null)
            {
                return null;
            }
            else
            {
                return line;
            }
        }
         * */
    }
}
