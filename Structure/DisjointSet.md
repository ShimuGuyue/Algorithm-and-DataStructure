# 并查集

并查集是一种用于处理**不交集集合合并与查询**的数据结构，常用于连通性判定等问题。

并查集的核心原理是通过一棵以根节点为代表的**树形结构**来维护集合划分，每个集合用一棵树表示，树的根节点即该集合的代表元素。

初始化时，每个节点单独在一个集合，其树的根节点为其本身。

## 查询集合所属

查询某个节点所在集合时，首先判断该节点是否为所在集合的根节点，如果不是，持续向上搜索祖先节点直至**根节点**处，返回根节点编号。	

```cpp
int find(int x)
{
    while (fathers[x] != x)
    {
        x = fathers[x];
    }
    return x;
}
```

### 路径压缩

查找过程可进行路径压缩处理，即将查找路径上所有节点都直接连接到集合根节点上，后续查找速度会更快。

>   [!WARNING]
>
>   路径压缩会**破坏树的结构**，在需要严格保持合并顺序的场景下不能使用，例如可撤销并查集。

```cpp
int find(x)
{
    int root = x;
    while (fathers[root] != root)
    {
        root = fathers[root];
    }
    while (fathers[x] != root)
    {
        int father = fathers[x];
        fathers[x] = root;
        x = father;
    }
    return root;
}
```

### 递归简化代码

当路径压缩和按秩合并（集合合并的优化）同时使用时，每次查询集合时的查询次数不超过 $5$，可以采用递归写法简化代码。

相较于循环写法，递归写法更简便，且在递归层数很小的情况下一般不会有过度消耗时间或者栈溢出的风险。

>   当两种优化策略**同时使用**时，集合形成的树结构非常接近扁平的链表结构，树的高度增长非常缓慢。根据 Tarjan 的分析，若有 $n$ 个元素，每次 `find` 操作的均摊时间复杂度为 $O(\alpha(n))$，其中 $\alpha(n)$ 是反阿克曼函数，增长极其缓慢，在实际问题中可视为一个不超过 $5$ 的常数。

```cpp
int find(x)
{
    return fathers[x] == x ? x : fathers[x] = find(fathers[x]);
}
```

## 合并不同集合

将两个节点所在集合进行合并时，首先找到各自集合的根节点，然后将其中一棵树挂载到另一颗树的根节点下即可。

```cpp
void merge(int x, int y)
{
    int set_x = find(x);
    int set_y = find(y);
    fatehers[set_x] = set_y;
}
```

### 按秩合并

若使用以上朴素合并方式，随合并次数的增加，可能会使得树的重心朝一个方向偏移，导致树高增加。

为了让树尽可能保持平衡，可以采用按秩（即树高）合并的方式，每次合并时将高度较小的树挂载到高度较高的那颗下，以尽可能减缓树高的增长速度。

在不使用路径压缩的情况下，仅按秩合并会是树高不会超过为 $n \log_2 n$，因此查询的时间复杂度为 $n \log_2 n$。

在使用路径压缩的情况下，树的扁平化程度较高，一般并不需要按秩合并进行额外优化。

>   [!Warning]
>
>   对于需要严格控制树节点上下级关系的场景，按秩合并无法使用。

```cpp
int merge(int x, int y)
{
    int set_x = find(x);
    int set_y = find(y);
    if (ranks[set_x] < ranks[set_y])
    {
        fathers[set_x] = set_y;
    }
    else
    {
        fatherx[set_y] = set_x;
        if (ranks[set_x] == ranks[set_y])
            ++ranks[set_x]; // 两集合树高一致时，被选作根节点的树高加一
    }
}
```

## 维护集合大小

维护所有集合的大小时，可以额外记录一个数组 `sizes` 表示每个节点作为根节点时该集合的大小。查询节点所在集合大小时，先找到根节点，再返回维护的数据即可。

集合合并时，只需把两个集合大小之和赋值给新的根节点即可。

## 维护集合数量

维护集合数量时，可以初始记录一个 `count` 为所有节点的数量，每次进行集合合并时，集合数减一，查询时直接返回即可。

## 模板

```cpp
class DisjointSet
{
private:
    struct Data
    {
        int father;
        int size;
    };
    std::vector<Data> nodes_;

    int count_;

public:
    DisjointSet(const int n)
    {
        build(n);
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
        nodes_[set_x].size += nodes_[set_y].size;
        --count_;
    }

    int count() const
    {
        return count_;
    }

    int get_size(const int x)
    {
        return nodes_[find(x)].size;
    }

private:
    void build(const int n)
    {
        count_ = n;

        nodes_.assign(n, { });
        for (int i{ 0 }; i < n; ++i)
        {
            nodes_[i].father = i;
            nodes_[i].size = 1;
        }
    }
};
```

# 带权并查集

带权并查集是对并查集的扩展，在维护节点间集合关系的同时，也维护任意所给出**点对之间的相对权值**。具体表现为每个节点额外维护一个元素 `dist` 表示其相对于父节点的权值。

初始时，各节点父节点为本身，权值应初始化为权值关系的**单位元**。

>   对于任意运算关系 $*$，若 $a * e = a$，则称 $e$ 为该运算关系的单位元。

## 路径压缩修正权值

带权并查集使用路径压缩查询所属集合时，父节点信息发生改变，应通过权值运算，将路径上点的权值更新为相对于根节点的权值。

更新到节点 $a$ 时，设其父节点为 $b$，$a$ 相对于 $b$ 的权值为 `dists[a]`；$b$ 的父节点为 $root$，$b$ 相对于 $root$ 的权值为更新后的 `dists[b]`。因此将 $a$ 挂载到 $root$ 节点下后，`dists[a]` 应更新为 `operate(dists[a], dists[b])`，其中 $operate$ 表示权值运算规则。

```cpp
int find(int x)
{
    if (fathers[x] == x)
        return x;
    // 路径压缩会导致找不到原父节点，需拷贝备份
    int father = fathers[x];
    fathers[x] = find(fathers[x]);
    // operater规定运算规则
    dists[x] = operate(dists[x], dists[father]);
    return nodes_[x].father;
}
```

## 带权合并集合

带权合并集合时，给出一个三元组 $<x,\ y,\ dist>$ 表示 $y$ 相对于 $x$ 的权值为 $dist$。

若 $x$ 和 $y$ 合并前已经同属于一个集合，首先根据集合中**已记录的权值**求出该两点之间相对权值，与当前合并所给权值作比较。若二者相等，则无需多余合并；否则表示该权值与集合信息相矛盾，返回错误码。

若 $x$ 和 $y$ 分属于两个不同集合，则将 $root_y$ 挂载到 $root_x$ 节点下方，根据已记录的权值求出 $x$ 和 $y$ 分别相对于其根节点的距离，再与所给的 $dist$ 进行计算得出 $root_y$ 相对于 $root_x$ 的权值。

```cpp
bool merge(int x, int y, int dist)
{
    int set_x = find(x);
    int set_y = find(y);
    // 假设使用路径压缩
    // inv_operate规定逆运算规则
    if (set_x == set_y)
        return dist == inv_operate(dists[y], dists[x]);
    fathers[set_y] = set_x;
    dists[set_y] = inv_operate(operate(dists[x], dist), dists[y]);
    return true;
}
```

## 询问相对权值

给出任意两点询问其相对权值，首先判断两点是否所属同一集合再计算权值。

若两点分属不同集合，说明该两点权值关系尚不明确，返回错误码。

若两点同属于一个集合，则根据 $x$ 和 $y$ 分别相对于 $root$ 的权值计算出两点间相对权值。

```cpp
pair<bool, int> query(int x, int y)
{
    int set_x = find(x);
    int set_y = find(y);
    if (set_x != set_y)
        return {false, 0};
    int dist = inv_operate(dists[y], dists[x]);
    return {true, dist};
}
```

## 模板

```cpp
class DisjointSet
{
private:
    int64_t unit_;

    struct Data
    {
        int father;
        int64_t dist;
    };
    std::vector<Data> nodes_;

public:
    DisjointSet(const int n)
    {
        build(n);
    }

public:
    int find(const int x)
    {
        if (nodes_[x].father == x)
            return x;
        const int father{ nodes_[x].father };
        nodes_[x].father = find(nodes_[x].father);
        nodes_[x].dist = operate(nodes_[x].dist, nodes_[father].dist);
        return nodes_[x].father;
    }

    bool merge(const int x, const int y, const int64_t dist)
    {
        const int root_x{ find(x) };
        const int root_y{ find(y) };
        if (root_x == root_y)
            return dist == inv_operate(nodes_[y].dist, nodes_[x].dist);
        nodes_[root_y].father = root_x;
        nodes_[root_y].dist = inv_operate(operate( nodes_[x].dist, dist), nodes_[y].dist);
        return true;
    }

    std::pair<bool, int64_t> query(const int x, const int y)
    {
        const int root_x{ find(x) };
        const int root_y{ find(y) };
        if (root_x != root_y)
            return {false, unit_};
        const int64_t dist{ inv_operate(nodes_[y].dist, nodes_[x].dist) };
        return {true, dist};
    }

private:
    void build(const int n)
    {
        set_unit();

        nodes_.assign(n, { });
        for (int i{ 0 }; i < n; ++i)
        {
            nodes_[i].father = i;
            nodes_[i].dist = unit_;
        }
    }

    void set_unit()
    {
        // TODO: 规定运算单位元
        unit_ = ;
    }

private:
    static int64_t operate(const int64_t dist1, const int64_t dist2)
    {
        // TODO: 规定运算运算方式
        return dist1  dist2;
    }

    static int64_t inv_operate(const int64_t dist1, const int64_t dist2)
    {
        // TODO: 规定运算逆运算方式
        return dist1  dist2;
    }
};
```

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

拓展域并查集由于多维度相连接，会导致集合查询得出的节点并不一定在实体域内。但关系维护问题中并不需要询问集合所属，而是询问节点关系，因此只需根据 `find` 函数返回的结果进行比较判断关系即可。

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

