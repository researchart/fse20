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
using System.IO;
using System.Xml.Serialization;
using DomainPro.Core.Types;
using DomainPro.Core.Interfaces;
using DomainPro.Designer.Types;
using DomainPro.Designer.Interfaces;
using LanguageBuilder.MetaTypes;

namespace LanguageBuilder.Factories
{
    public class DP_MetamodelFactory : DP_IModelFactory
    {
        public DP_AbstractModelType CreateModel()
        {
            return new DP_Metamodel("NewMetamodel");
        }

        public void SaveModel(DP_AbstractModelType model, string path)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(DP_Metamodel));
            TextWriter textWriter = new StreamWriter(path);
            serializer.Serialize(textWriter, model);
            textWriter.Close();
        }

        public DP_AbstractModelType LoadModel(string path)
        {
            XmlSerializer deserializer = new XmlSerializer(typeof(DP_Metamodel));
            TextReader textReader = new StreamReader(path);
            DP_Metamodel model = (DP_Metamodel)deserializer.Deserialize(textReader);
            textReader.Close();
            return model;
        }
    }
}
