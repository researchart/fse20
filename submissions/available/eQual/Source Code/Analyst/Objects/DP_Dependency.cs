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
    public class DP_Dependency : DP_Object
    {
        public new DP_DependencyType Type
        {
            get { return type as DP_DependencyType; }
            set { type = value; }
        }

        private DP_IObject obj;

        public DP_IObject Object
        {
            get { return obj; }
            set
            {
                DP_IObject oldObj = obj;
                obj = value;

                if (oldObj != null)
                {
                    // Update the old object's properties
                    Type oldObjTypeInfo = oldObj.GetType();
                    PropertyInfo oldObjPropertyInfo = oldObjTypeInfo.GetProperty(Type.Name);
                    if (oldObjPropertyInfo.GetValue(oldObj, null) == this)
                    {
                        oldObjPropertyInfo.SetValue(oldObj, null, null);
                    }
                    if (oldObj.Dependencies.ContainsKey(Id))
                    {
                        oldObj.Dependencies.Remove(Id);
                    }

                }

                if (obj != null)
                {
                    // Update the new object's properties
                    Type newTypeInfo = obj.GetType();
                    PropertyInfo newObjPropertyInfo = newTypeInfo.GetProperty(Type.Name);
                    if (newObjPropertyInfo.GetValue(obj, null) != this)
                    {
                        newObjPropertyInfo.SetValue(obj, this, null);
                    }
                    if (!obj.Dependencies.ContainsKey(Id))
                    {
                        obj.Dependencies.Add(Id, (DP_IDependency)this);
                    }
                }

                // Update the subclass's property
                Type typeInfo = GetType();
                PropertyInfo propInfo = typeInfo.GetProperty(Type.Role1Attached.Name);
                if (propInfo.GetValue(this, null) != obj)
                {
                    propInfo.SetValue(this, obj, null);
                }
            }
        }

        private DP_IResource rsrc;

        public DP_IResource Resource
        {
            get { return rsrc; }
            set
            {
                DP_IObject oldRsrc = rsrc;
                rsrc = value;

                if (oldRsrc != null)
                {
                    // Update the old object's properties
                    Type oldRsrcTypeInfo = oldRsrc.GetType();
                    PropertyInfo oldRsrcFieldInfo = oldRsrcTypeInfo.GetProperty(Type.Name);
                    if (oldRsrcFieldInfo.GetValue(oldRsrc, null) == this)
                    {
                        oldRsrcFieldInfo.SetValue(oldRsrc, null, null);
                    }
                    if (oldRsrc.Dependencies.ContainsKey(Id))
                    {
                        oldRsrc.Dependencies.Remove(Id);
                    }
                }

                if (rsrc != null)
                {
                    // Update the new object's properties
                    Type newRsrcInfo = rsrc.GetType();
                    PropertyInfo newFieldInfo = newRsrcInfo.GetProperty(Type.Name);
                    if (newFieldInfo.GetValue(rsrc, null) != this)
                    {
                        newFieldInfo.SetValue(rsrc, this, null);
                    }
                    if (!rsrc.Dependencies.ContainsKey(Id))
                    {
                        rsrc.Dependencies.Add(Id, (DP_IDependency)this);
                    }
                }

                // Update the subclass's property
                Type typeInfo = GetType();
                PropertyInfo fieldInfo = typeInfo.GetProperty(Type.Role2Attached.Name);
                if (fieldInfo.GetValue(this, null) != rsrc)
                {
                    fieldInfo.SetValue(this, rsrc, null);
                }
            }
        }
    }
}
