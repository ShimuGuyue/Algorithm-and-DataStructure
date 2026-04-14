---
tags: ["Graph", "图", "BipartiteGraph", "二分图"]
---

# 二分图染色

二分图染色是通过 DFS/BFS 对节点染色的操作，判断给定的图是否是二分图的方法。

进行染色操作时，以任意一点为起始点，将其标记为颜色 $A$ 或 $B$，然后从该点开始不断扩展，将每个节点的相邻节点染成另一种颜色。

若染色过程中发生冲突，即两个相邻节点的颜色相同，则说明该图不是二分图。否则该图是二分图。

>   [!Note]
>
>   根据二分图相邻节点颜色不同的性质可知，当图中存在**长度为奇数的环**时，一定会发生冲突；若图中只存在偶数长度的环或者不存在环时，一定不会发生冲突。
>
>   图中不存在奇数环和图是二分图互为**充要条件**。

## 模板

```cpp
bool judge_bipartiteGraph(const std::vector<std::vector<int>>& edges)
{
    const int n{ static_cast<int>(edges.size()) };
    std::vector<int> colors(n);
    std::queue<int> q;
    for (int i{ 0 }; i < n; ++i)
    {
        if (colors[i])
            continue;
        colors[i] = 1;
        q.push(i);
        while (!q.empty())
        {
            const int u{ q.front() };
            q.pop();
            for (const int v : edges[u])
            {
                if (colors[v] == colors[u])
                    return false;
                if (colors[v] == 0)
                {
                    colors[v] = colors[u] == 1 ? 2 : 1;
                    q.push(v);
                }
            }
        }
    }
    return true;
}
```

