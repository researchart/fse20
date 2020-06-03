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
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using System.Xml.Schema;
using DomainPro.Core.Types;

namespace DomainPro.Core.Application
{
    public class DP_TypeCollection<T> :
        IEnumerable
        /* IXmlSerializable */
        where T : DP_AbstractSemanticType
    {
        private class DP_TypeIdKeyCollection : KeyedCollection<Guid, T>
        {
            protected override Guid GetKeyForItem(T type)
            {
                return type.Id;
            }
        }

        private class DP_TypeNameKeyCollection : KeyedCollection<string, T>
        {
            protected override string GetKeyForItem(T type)
            {
                return type.Name;
            }

            public void ChangeKey(T type, string newName)
            {
                ChangeItemKey(type, newName);
            }
        }

        private DP_TypeIdKeyCollection idKeyCollection = new DP_TypeIdKeyCollection();

        private DP_TypeNameKeyCollection nameKeyCollection = new DP_TypeNameKeyCollection();

        private Dictionary<Type, List<T>> typeDictionary = new Dictionary<Type, List<T>>();

        // TODO
        public T this[int index]
        {
            get
            {
                return idKeyCollection.ElementAt(index);
            }
        }

        public T this[Guid id]
        {
            get
            {
                return idKeyCollection[id];
            }
        }

        public T this[string name]
        {
            get
            {
                return nameKeyCollection[name];
            }
        }

        public List<T> this[Type info]
        {
            get
            {
                if (typeDictionary.ContainsKey(info))
                {
                    return typeDictionary[info];
                }
                else
                {
                    return new List<T>();
                }
            }
        }

        public void Add(Object obj)
        {
            if (obj is T)
            {
                Add((T)obj);
            }
        }

        public void Add(T type)
        {
            if (!idKeyCollection.Contains(type.Id))
            {
                idKeyCollection.Add(type);
            }
            if (!nameKeyCollection.Contains(type.Name))
            {
                nameKeyCollection.Add(type);
            }
            if (!typeDictionary.ContainsKey(type.GetType()))
            {
                typeDictionary.Add(type.GetType(), new List<T>());
            }
            if (!typeDictionary[type.GetType()].Contains(type))
            {
                typeDictionary[type.GetType()].Add(type);
            }
        }

        public static implicit operator DP_TypeCollection<DP_AbstractSemanticType>(DP_TypeCollection<T> source)
        {
            DP_TypeCollection<DP_AbstractSemanticType> dest = new DP_TypeCollection<DP_AbstractSemanticType>();
            foreach (T type in source)
            {
                dest.Add(type);
            }
            return dest;
        }

        public static implicit operator DP_TypeCollection<T>(DP_TypeCollection<DP_AbstractSemanticType> source)
        {
            DP_TypeCollection<T> dest = new DP_TypeCollection<T>();
            foreach (DP_AbstractSemanticType type in source)
            {
                dest.Add((T)type);
            }
            return dest;
        }

        public void ChangeName(T type, string newName)
        {
            nameKeyCollection.ChangeKey(type, newName);
        }

        public void Clear()
        {
            idKeyCollection.Clear();
            nameKeyCollection.Clear();
            typeDictionary.Clear();
        }

        public bool Contains(T type)
        {
            return idKeyCollection.Contains(type) && nameKeyCollection.Contains(type) && typeDictionary[type.GetType()].Contains(type);
        }

        public bool Contains(Guid id)
        {
            return idKeyCollection.Contains(id);
        }

        public bool Contains(string name)
        {
            return nameKeyCollection.Contains(name);
        }

        public bool Contains(Type info)
        {
            return typeDictionary.ContainsKey(info);
        }

        // TODO
        public int Count
        {
            get { return idKeyCollection.Count; }
        }

        // TODO
        public IEnumerator GetEnumerator()
        {
            return idKeyCollection.GetEnumerator();
        }

        public void Remove(T type)
        {
            idKeyCollection.Remove(type);
            nameKeyCollection.Remove(type);
            typeDictionary[type.GetType()].Remove(type);
            if (typeDictionary[type.GetType()].Count == 0)
            {
                typeDictionary.Remove(type.GetType());
            }
        }

        // TODO
        public object[] ToArray()
        {
            return idKeyCollection.ToArray();
        }

        //public List<DP_AbstractSemanticType> TypesList = new List<DP_AbstractSemanticType>();

        /*
        public XmlSchema GetSchema()
        { return null; }

        public void ReadXml(System.Xml.XmlReader reader)
        {
            if (reader.IsEmptyElement)
            {
                return;
            }
            
            reader.ReadStartElement("Types");
            
            while (reader.NodeType != XmlNodeType.EndElement)
            {
                XmlSerializer typeXmlSerializer = new XmlSerializer(Type.GetType(reader.GetAttribute("type")));
                reader.ReadStartElement();
                Add((T)typeXmlSerializer.Deserialize(reader));
                reader.ReadEndElement();
            }

            reader.ReadEndElement();
        }

        public void WriteXml(System.Xml.XmlWriter writer)
        {
            foreach (DP_AbstractSemanticType type in idKeyCollection)
            {
                XmlSerializer typeXmlSerializer = new XmlSerializer(type.GetType());
                typeXmlSerializer.Serialize(writer, type);
                //writer.WriteAttributeString("type", type.GetType().AssemblyQualifiedName);
                
                //writer.WriteEndElement();
            }
        }
         * */
    }
}
