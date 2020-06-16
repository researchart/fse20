using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics.Contracts;

namespace Microsoft.Boogie.Houdini
{
    class UnionFind<T>
    {
        Dictionary<T, T> parent;
        Dictionary<T, int> rank;
        public UnionFind() {
            parent = new Dictionary<T, T>();
            rank = new Dictionary<T, int>();
        }
        public bool addNode(T x) {
            if (parent.ContainsKey(x)) return false;
            else {
                parent[x] = x;
                rank[x] = 1;
                return true;
            }
        }

        public bool addNodes(IList<T> elements)
        {
            foreach (T e in elements) {
                if (!addNode(e)) return false;
            }
            return true;
        }

        public T find(T x)
        {
            //Contract.Assert(parent.ContainsKey(x));
            if (!parent.ContainsKey(x)) addNode(x);
            if (parent[x].Equals(x)) return x;
            else {
                return parent[x] = find(parent[x]);
            }
        }

        public  void union(T x, T y)
        {
            x = find(x);
            y = find(y);
            if (x.Equals(y)) return;
            if (rank[x] < rank[y])
            {
                parent[x] = y;
            }
            else {
                parent[y] = x;
                if (rank[x] == rank[y]) ++rank[x];
            }
        }

        public bool equal(T x, T y)
        {
            return find(x).Equals(find(y));
        }
    }
}
