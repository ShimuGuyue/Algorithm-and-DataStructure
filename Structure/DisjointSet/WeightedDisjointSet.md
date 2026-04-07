# 带权并查集

带权并查集是对并查集的扩展，在维护节点间集合关系的同时，也维护任意所给出**点对之间的相对权值**。具体表现为每个节点额外维护一个元素 `dist` 表示其相对于父节点的权值。

初始时，各节点父节点为本身，权值应初始化为权值关系的**单位元**。

*以下内容以整数加减为例。*

## 路径压缩修正权值

带权并查集使用路径压缩查询所属集合时，父节点信息发生改变，应通过权值运算，将路径上点的权值更新为相对于根节点的权值。

更新到节点 $a$ 时，设其父节点为 $b$，$a$ 相对于 $b$ 的权值为 `dists[a]`；$b$ 的父节点为 $root$，$b$ 相对于 $root$ 的权值为更新后的 `dists[b]`。因此将 $a$ 挂载到 $root$ 节点下后，`dists[a]` 应更新为 `dists[a] + dists[b]`。

```cpp
int find(int x)
{
    if (fathers[x] == x)
        return x;
    // 路径压缩会导致找不到原父节点，需拷贝备份
    int father = fathers[x];
    fathers[x] = find(fathers[x]);
    // 更新节点权值
    dists[x] = dists[x] + dists[father]);
    return fathers[x];
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
    if (set_x == set_y)
        return dist == dists[y] - dists[x];
    fathers[set_y] = set_x;
    dists[set_y] = dists[x] + dist - dists[y];
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
    int dist = dists[y] - dists[x];
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
