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
using System.Drawing;
using System.Xml.Serialization;
using System.Windows.Forms;
using DomainPro.Designer.Types;

namespace LanguageBuilder.MetaTypes
{
    [XmlInclude(typeof(DP_MetamodelDiagram))]
    [XmlInclude(typeof(DP_MetaClass))]
    [XmlInclude(typeof(DP_MetaReference))]
    [XmlInclude(typeof(DP_MetaReferenceDiagram))]
    [XmlInclude(typeof(DP_MetaContainment))]
    [XmlInclude(typeof(DP_MetaContainmentDiagram))]
    [XmlInclude(typeof(DP_MetaInheritance))]
    [XmlInclude(typeof(DP_MetaInheritanceDiagram))]
    public class DP_Metamodel : DP_ModelType
    {
        public DP_Metamodel()
        {
        }

        public DP_Metamodel(string newName)
        {
            name = newName;
            Diagram = new DP_MetamodelDiagram();
            Text = new DP_Text();
        }

    }
}
