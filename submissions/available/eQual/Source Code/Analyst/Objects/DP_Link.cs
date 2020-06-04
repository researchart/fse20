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
using System.Reflection;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Interfaces;

namespace DomainPro.Analyst.Objects
{
    public class DP_Link : DP_Object
    {
        public new DP_LinkType Type
        {
            get { return type as DP_LinkType; }
            set { type = value; }
        }

        private DP_IObject role1;

        public DP_IObject Role1
        {
            get { return role1; }
            set
            {
                if (role1 == value)
                {
                    return;
                }
                DP_IObject oldObj = role1;
                role1 = value;

                if (oldObj != null)
                {
                    // Update the old object's properties
                    Type oldObjTypeInfo = oldObj.GetType();
                    PropertyInfo oldObjPropertyInfo = oldObjTypeInfo.GetProperty(Type.Name + "Link");
                    if (oldObjPropertyInfo.GetValue(oldObj, null) == this)
                    {
                        oldObjPropertyInfo.SetValue(oldObj, null, null);
                    }
                    if (oldObj.Links.ContainsKey(Id))
                    {
                        oldObj.Links.Remove(Id);
                    }

                }

                if (role1 != null)
                {
                    // Update the new object's properties
                    Type newTypeInfo = role1.GetType();
                    PropertyInfo newObjPropertyInfo = newTypeInfo.GetProperty(Type.Name + "Link");
                    if (newObjPropertyInfo.GetValue(role1, null) != this)
                    {
                        newObjPropertyInfo.SetValue(role1, this, null);
                    }
                    if (!role1.Links.ContainsKey(Id))
                    {
                        role1.Links.Add(Id, (DP_ILink)this);
                    }
                }

                // Update the subclass's property
                Type typeInfo = GetType();
                PropertyInfo propInfo = typeInfo.GetProperty(Type.Role1Attached.Name);
                if (propInfo.GetValue(this, null) != role1)
                {
                    propInfo.SetValue(this, role1, null);
                }
            }
        }

        private DP_IObject role2;

        public DP_IObject Role2
        {
            get { return role2; }
            set
            {
                if (role2 == value)
                {
                    return;
                }
                DP_IObject oldObj = role2;
                role2 = value;

                if (oldObj != null)
                {
                    // Update the old object's properties
                    Type oldObjTypeInfo = oldObj.GetType();
                    PropertyInfo oldObjPropertyInfo = oldObjTypeInfo.GetProperty(Type.Name + "Link");
                    if (oldObjPropertyInfo.GetValue(oldObj, null) == this)
                    {
                        oldObjPropertyInfo.SetValue(oldObj, null, null);
                    }
                    if (oldObj.Links.ContainsKey(Id))
                    {
                        oldObj.Links.Remove(Id);
                    }

                }

                if (role2 != null)
                {
                    // Update the new object's properties
                    Type newTypeInfo = role2.GetType();
                    PropertyInfo newObjPropertyInfo = newTypeInfo.GetProperty(Type.Name + "Link");
                    if (newObjPropertyInfo.GetValue(role2, null) != this)
                    {
                        newObjPropertyInfo.SetValue(role2, this, null);
                    }
                    if (!role2.Links.ContainsKey(Id))
                    {
                        role2.Links.Add(Id, (DP_ILink)this);
                    }
                }

                // Update the subclass's property
                Type typeInfo = GetType();
                PropertyInfo propInfo = typeInfo.GetProperty(Type.Role2Attached.Name);
                if (propInfo.GetValue(this, null) != role2)
                {
                    propInfo.SetValue(this, role2, null);
                }
            }
        }
    }
}
