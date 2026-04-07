# 拓展域并查集

普通并查集使用一个长度为 $n$ 的数组来表示 $n$ 个点之间的集合联通关系。

拓展域并查集是在普通并查集的基础上，根据问题中**多种关系**种类的数量 $count$，将数组大小**拓展**为 $count \times n$，其中每一组长度为 $n$ 的区间分别表示一种对应关系。例如查询第 $i + k \times n$ 个位置的所属集合表示与第 $i$ 个元素的相对关系为第 $k$ 种关系的点所在的集合。

拓展域并查集的数组拓展是将原来的一个点拆分出若干个**虚拟点**，虚拟点是真实点在不同关系维度下的**投影**，仅用于指向关系，实际上还是只有 $n$ 个点。

拓展域并查集用于维护多种关系结构，又称**关系并查集**。

>   [!Tip]
>
>   拓展域并查集表示的所有关系都可以构成关系循环，可以用**带权并查集**为每个关系分别赋予 $[0, count)$ 的权值，维护相对权值时对 $count$ **取模**代替实现。

## 初始化集合

在初始化阶段，拓展域并查集的操作与普通并查集逻辑一致，但在空间跨度上有所区别。

由于数组大小被拓展为 $count \times n$，我们需要对全区间的所有节点（包括原始节点和虚拟节点）执行 `fathers[i] = i`。

对于实体区间 $[0, n)$ 而言，这一区间一般作为同类域，意义同普通并查集。当其父节点为本身时，表示自己一个人作为一个集合。

对于虚拟区间 $[n, count * n)$ 而言，每一个长度为 $n$ 的区间作为一种特定的关系域。当其父节点为本身时，表示该虚拟点对应的实点在该关系域中对应的集合暂未找到。

```cpp
void init(int n, int count)
{
    for (int i = 0; i < count * n; ++i)
    {
        fathers[i] = i;
    }
}
```

## 关系合并

对于给定关系 $<x, y, relation>$，根据问题中的关系转换逻辑推导出所有的隐含关系，然后将对应的所有节点逐一合并。

>   对于捕食中的三种关系**同类**、**食物**、**天敌**，分别对应数组的三个区间：
>
>   给定关系：$x$ 是 $y$ 的天敌。
>
>   推导关系：$y$ 是 $x$ 的食物。
>
>   合并逻辑：
>
>   ```cpp
>   merge(find(x), find(y + n * 2));
>   merge(find(y), find(x + n));
>   ```
>
>   ---
>
>   给定关系：$x$ 和 $y$ 是同类。
>
>   推导关系：$x$ 的食物和 $y$ 的食物是同类，$x$ 的天敌和 $y$ 的天敌是同类。
>
>   合并逻辑：
>
>   ```cpp
>   merge(find(x), find(y));
>   merge(find(x + n), find(y + n));
>   merge(find(x + n * 2), find(y + n * 2));
>   ```

## 关系查询

拓展域并查集由于多维度相连接，会导致集合查询得出的节点并不一定在实体域内。但关系维护问题中并不需要询问集合所属，而是询问节点关系，因此只需根据 find 函数返回的结果进行比较判断关系即可。

>   还以上述捕食关系为例：
>
>   $find(x) = find(y)$ 表示 $x$ 和 $y$ 是同类；
>
>   $find(x) = find(y + n)$ 表示 $x$ 是 $y$ 的食物；
>
>   $find(x) = find(y + n \times 2)$ 表示 $x$ 是 $y$ 的天敌……

## 模板

```cpp
class DisjointSet
{
private:
    struct Data
    {
        int father;
    };
    std::vector<Data> nodes_;

public:
    DisjointSet(const int n, const int count)
    {
        build(n, count);
    }

public:
    int find(const int x)
    {
        return nodes_[x].father == x ? x : nodes_[x].father = find(nodes_[x].father);
    }

    void merge(const int x, const int y)
    {
        const int set_x{ find(x) };
        const int set_y{ find(y) };
        if (set_x == set_y)
            return;
        nodes_[set_y].father = set_x;
    }

private:
    void build(const int n, const int count)
    {
        nodes_.assign(count * n, { });
        for (int i{ 0 }; i < count * n; ++i)
        {
            nodes_[i].father = i;
        }
    }
};
```

