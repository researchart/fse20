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
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml.Serialization;
using DomainPro.Core.Types;
using DomainPro.Analyst.Interfaces;

namespace DomainPro.Analyst.Types
{
    public class DP_DataType : DP_ConcreteType
    {
        //[XmlIgnore]
        //public DP_TextProperty TypeProp;

        private string implementationType;

        [DisplayName("Implementation Type"),
        Category("Simulation"),
        DefaultValue(""),
        Description("Indicates the type of implementation object used to store the data."),
        ReadOnly(true)]
        public string ImplementationType
        {
            get { return implementationType; }
            set { implementationType = value; }
        }

        private string initialValue;

        [DisplayName("Initial Value"),
        Category("Simulation"),
        DefaultValue(""),
        Description("Indicates the initial value of the data."),
        ReadOnly(true)]
        public string InitialValue
        {
            get { return initialValue; }
            set { initialValue = value; }
        }

        /*
        private DP_IDataDef dataDef;

        [XmlIgnore]
        private DP_IDataDef DataDef
        {
            get
            {
                if (dataDef == null)
                {
                    string fullName = Name;

                    //DP_ConcreteType nextParent = Parent.Parent;

                    //while (nextParent != null)
                    //{
                    //    fullName = nextParent.Name + "." + fullName;
                    //    nextParent = nextParent.Parent.Parent;
                    //}

                    fullName = app.Model.Name + "." + fullName;

                    dataDef = (DP_IDataDef)app.ModelAssembly.CreateInstance(fullName);

                    if (dataDef != null)
                    {
                        dataDef.Data = this;
                        dataDef.Initialize();
                    }
                }
                return dataDef;
            }
        }
         * */

        public override void Initialize(DP_AbstractStructure parentStructure)
        {
            base.Initialize(parentStructure);

            /*
            TypeProp = (DP_TextProperty)Properties.Find(
                 delegate(DP_Property p)
                 {
                     return p.Name == "Type";
                 });
            TypeProp.IsSemantic = true;
             * */

            /*
            if (TypeProp.Value == "int")
            {
                val = assembly.CreateInstance("System.Int32");
            }
            else if (TypeProp.Value == "string")
            {
                val = assembly.CreateInstance("System.String");
            }
            else if (TypeProp.Value == "float")
            {
                val = assembly.CreateInstance("System.Double");
            }
            else if (TypeProp.Value == "double")
            {
                val = assembly.CreateInstance("System.Double");
            }
            else
            {
                
            }
             * */
        }

        /*
        public object Value
        {
            get
            {
                if (DataDef != null)
                {
                    return DataDef.Value;
                }
                else
                {
                    return null;
                }
            }
            set
            {
                if (DataDef != null)
                {
                    DataDef.Value = value;
                }
            }
        }
         * */
    }
}
