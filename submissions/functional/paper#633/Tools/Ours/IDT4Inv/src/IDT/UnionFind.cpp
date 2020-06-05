#include "UnionFind.h"

int Find(int *Parent,int x)
{
	if (Parent[x] != x) Parent[x] = Find(Parent, Parent[x]);
	return(Parent[x]);
}
void Union(int *Parent, int x, int y)
{
	int u, v;
	u = Find(Parent, x);
	v = Find(Parent, y);
	if (u != v) Parent[v] = u;
}
