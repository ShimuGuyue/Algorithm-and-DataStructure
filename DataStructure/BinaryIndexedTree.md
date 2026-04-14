# 树状数组

树状数组是对于**可差分**数据（相加求和、相乘求积等）在前缀和维护的基础上，将前缀和数组根据二进制的一些性质，拆分成若干段区间进行分段维护，从而实现在大量的**修改**和**查询**操作交替进行时所有操作都能在 $O(\log_2 n)$ 的时间复杂度内快速完成。

>   [!Caution]
>
>   树状数组可以实现的所有功能均可以被线段树实现，且时间复杂度相同，均为 $O(\log_2 n)$。
>
>   树状数组优势仅在于**常数更小**和**代码复杂度更低**，但**思维难度更大**。

*以下内容以相加求和为例。*

## 二进制分解

根据**二进制分解定理**，对于任意一个正整数 $n$，均可以表示为若干不同 $2$ 的非负幂次之和，即 $n = 2^{k_1} + 2^{k_2} + \cdots + 2^{k_m}$，其中 $k_1 > k_2 > \cdots > k_m \geq 0$。

树状数组即是根据该定理，将前缀数组中任意第 $i$ 个位置的前缀和根据其二进制分解后的数值拆分成若干段。其中每个段中最末尾一个位置在树状数组中的值即为该段区间内的前缀和。

根据分解定理，$i$ 位置维护的区间长度为其二进制分解后的**最小分解值**，即其二进制中最低位的 $1$ 所表示的大小（lowbit）。

查询前缀信息时，只需要将若干段 $2$ 的幂次长度的区间前缀信息进行**汇总**，即可得到结果。

>   对于 $i = 11$ 的位置，$i$ 的二进制表示为 $1011$，即 $8 + 2 + 1$。
>
>   因此将 $[1,\ 11]$ 位置的前缀分为长度分别为 $8,\ 2,\ 1$ 的三部分 $[1,\ 8],\ [9,\ 10],\ [11,\ 11]$。
>
>   三个区间的末位置二进制分别为 $1000$，$1010$ 和 $1011$，各自的 lowbit 值分别为 $8$，$2$ 和 $1$，及其各自维护的区间长度。

>   [!Tip]
>
>   由于 $0$ 的二进制中没有 $1$ 的存在，因此树状数组的下标应当从 $1$ 开始。

得益于计算机中用正数的补码表示负数的方式，`x & -x` 的计算可以快速求出一个数的 lowbit 值。

```cpp
int lowbit(int x)
{
    return x & -x;
}
```

>   [!Note]
>
>   对于任意一个正整数 $x$，若其最低位的 $1$ 在第 $b$ 位，则其二进制表示：
>
>   `......1000...0`，
>
>   其中 $0 \sim b - 1$ 位均为 $0$，第 $b$ 位为 $1$，高于 $b$ 位的数无所谓。
>
>   ---
>
>   计算机中，一个数的负数表示为 $-x = \sim x + 1$，其中 $\sim x$ 表示：
>
>   `......0111...1`，
>
>   其中 $0 \sim b - 1$ 位均为 $1$，第 $b$ 位为 $0$，高于 $b$ 位的数与 $x$ 中的数相反。
>
>   ---
>
>   对 $\sim x$ 加一，则 $0 \sim b - 1$ 位不断进位变为 $0$，第 $b$ 位变为 $1$，高于 $b$ 位的数不变，得到 $-x$ 表示：
>
>   `......1000...0`，
>
>   其中 $0 \sim b$ 位均与 $x$ 中的数相同，高于 $b$ 位的数均不同。
>
>   ---
>
>   计算 $x\ \& -x$ 得到：
>
>   `0...001000...0`，
>
>   其中只有第 $b$ 位为 $1$，其余为均为$0$。其值恰好为 $x$ 中最低位的 $1$ 表示的大小，即 $lowbit(x) = x\ \& -x$。

树状数组初始化时一般有两种方法：

1.   对每个位置分别进行单点修改操作，时间复杂度为 $O(n \log_2n)$，不需要额外空间；
1.   预处理出整个原始数组的前缀和数组，通过区间查询快速求出每个位置所维护的区间值，时间复杂度为 $O(n)$，额外空间复杂度为 $O(n)$。

## 单点修改 + 区间查询

### 区间查询

类比前缀和数组的区间查询，要查询区间 $[l,\ r]$ 内的区间汇总信息，只需要分别求出 $l - 1$ 和 $r$ 位置的前缀信息，两者运算即可得到结果。

查询 $i$ 位置的前缀信息时，将其进行二进制分解得到若干个区间，对这些区间的前缀信息进行汇总即可得到 $i$ 位置的前缀信息。

查询每个区间末尾位置时，首先对 $i$ 求 lowbit 找到最近的一段区间长度，记录其区间信息后从总长中减去，即得到前一个区间的末尾位置。重复以上操作直到区间长度归零。

```cpp
int get_pre(int n)
{
    int ans = 0;
    while (n)
    {
        // 将答案与n位置维护的区间前缀信息进行汇总
        ans = ans + tree[n];
        // 区间右端点位置前移
        n -= lowbit(n);
    }
    return ans;
}
```

```cpp
int query(int l, int r)
{
    return get_pre(r) - get_pre(l - 1);
}
```

若要进行单点查询，通常有两种操作方式。

1.   将点 $n$ 视为区间 $[n - 1,\ n]$ 进行区间查询，时间复杂度为 $O(\log_2 n)$，不需要额外空间；

     ```cpp
     int query(int n)
     {
         return query(n - 1, n);
     }
     ```

1.   额外用一个数组维护每个位置的信息，查询时直接获取，时间复杂度为 $O(1)$，额外空间复杂度为 $O(n)$。

     ```cpp
     int query(int n)
     {
         return arr[n];
     }
     ```

### 单点修改

修改某个位置的信息时，需修改所有包含该位置的区间的信息。

对于位置 $i$，已知其作为右端点维护的区间长度为 $lowbit(i)$。由于树状数组中区间长度均为 $2$ 的幂次，所以包含位置 $i$ 的最小区间长度应为 $lowbit(i) \times 2$。所以 $i$ 距离更大的一个区间右端点的距离为 $i + lowbit(i)$。

得到了寻找更大区间的公式，即可从位置 $i$ 开始，不断向右寻找父区间右端点，直到超过数组大小。

```cpp
void update(int index, int data)
{
    while (index <= n) // n为区间总长度
    {
        tree[index] += data; 
        index += lowbit(index);
    }
}
```

### 模板

```cpp
class BinaryIndexedTree
{
private:
    std::vector<int> tree_;

public:
    BinaryIndexedTree(const std::vector<int>& v)
    {
        init(v);
    }

public:
    int query(const int l, const int r) const
    {
        // TODO：规定区间值差分方式
        return get_pre(r)  get_pre(l - 1);
    }

    void update(int index, const int data)
    {
        while (index < tree_.size())
        {
            // TODO：规定单点更新方式
            tree_[index] = tree_[index]  data;
            index += lowbit(index);
        }
    }

private:
    static int lowbit(const int x)
    {
        return x & -x;
    }

private:
    void init(const std::vector<int>& v)
    {
        // TODO：规定运算单位元
        tree_.assign(v.size(), );
        for (int i{ 1 }; i < v.size(); ++i)
        {
            update(i, v[i]);
        }
    }

    int get_pre(int index) const
    {
        int ans{ 0 };
        while (index)
        {
            // TODO：规定区间值归并方式
            ans = ans  tree_[index];
            index -= lowbit(index);
        }
        return ans;
    }
};
```

## 区间修改 + 单点查询

### 区间修改

树状数组可以解决的区间修改操作，一般是区间统一加上一个相同的值。

对于这种操作，对原数组的前缀和很难进行区间维护，但由于查询操作是单点查询，那么可以维护原数组的**差分数组**的分段前缀和。

```cpp
void update(int l, int r, int data)
{
    // 维护差分，调用单点修改的更新函数
    update(l, data);
    update(r + 1, -data); // 差分数组的长度要多开一位
}
```

### 单点查询

单点查询时直接求对差分数组维护的前缀值即可。

```cpp
int query(int index)
{
    int ans = 0；
    while (index)
    {
        ans += tree_dif[index];
        index -= lowbit(idnex);
    }
    return ans;
}
```

### 模板

```cpp
struct BinaryIndexedTree
{
private:
    std::vector<int> tree_dif_;

public:
    BinaryIndexedTree(const std::vector<int>& v)
    {
        init(v);
    }

public:
    int get(int index) const
    {
        int ans{ 0 };
        while (index)
        {
            // TODO：规定区间值归并方式
            ans = ans  tree_dif_[index];
            index -= lowbit(index);
        }
        return ans;
    }

    void update(const int l, const int r, const int data)
    {
        update(l, data);
        if (r + 1 < tree_dif_.size())
            update(r + 1, -data);
    }

private:
    static int lowbit(const int x)
    {
        return x & -x;
    }

private:
    void init(const std::vector<int>& v)
    {
        // TODO：规定运算单位元
        tree_dif_.assign(v.size(), );
        for (int i{ 1 }; i < v.size(); ++i)
        {
            // 规定差分值运算方式
            update(i, v[i]  v[i - 1]);
        }
    }

    void update(int index, const int data)
    {
        while (index < tree_dif_.size())
        {
            // TODO：规定数据更新方式
            tree_dif_[index] = tree_dif_[index]  data;
            index += lowbit(index);
        }
    }
};
```

## 区间修改 + 区间查询

当对区间同时进行区间修改和区间查询操作时，维护单个的前缀差分数组不再能完成任务，但可以通过**公式转化**得到可以用树状数组维护的数据类型。

$$
\begin{aligned}
\because pre(n) &= \sum_{i = 1}^{n} a_n = a_1 + a_2 + \cdots + a_n,\\
a_n &= \sum_{i = 1}^{n} dif(n),\\
\therefore pre(n) &= \sum_{i = 1}^{n} \sum_{j = 1}^{i} dif(j) = \sum_{i = 1}^{n} dif(i) \times (n - i + 1)\\
&= (\sum_{i = 1}^{n} dif(i) \times n) + (\sum_{i = 1}^{n} dif(i) \times (i - 1)).
\end{aligned}
$$

由此变换可得，维护区间前缀和只需要额外维护一个前缀数组，查询时分别求前缀再汇总即可得到结果。

### 区间修改

根据以上公式推导，树状数组需维护两个前缀，`tree1[i]` 表示 $dif(i)$，`tree2[i]` 表示 $dif(i) \times (i - 1)$。

```cpp
void update(int index, int data)
{
    int i = index;
    while (i <= n)
    {
        tree1[i] += data;
        tree2[i] += data * (index - 1);
        i += lowbit(i);
    }
}
```

### 区间查询

区间查询依旧是分别求 $l - 1$ 和 $r$ 处的前缀值进行差分得到。

但求前缀值的逻辑需根据公式变换进行改变。

```cpp
int get(int index)
{
    int ans1 = 0, ans2 = 0;
    int i = index;
    while (i)
    {
        ans1 += tree1[i] * index;
        ans2 += tree2[i];
        i -= lowbit(i);
    }
    return ans1 - ans2;
}
```

### 模板

```cpp
class BinaryIndexedTree
{
private:
    std::vector<int> tree1; // dif(i)
    std::vector<int> tree2; // TODO：数组维护类型

public:
    BinaryIndexedTree(const std::vector<int>& v)
    {
        init(v);
    }

public:
    int query(const int l, const int r) const
    {
        return get(r) - get(l - 1);
    }

    void update(const int l, const int r, const int data)
    {
        update(l, data);
        if (r + 1 <= tree1.size())
            update(r + 1, ); // TODO：规定差分逆元
    }

private:
    static int lowbit(const int x)
    {
        return x & -x;
    }

private:
    void init(const std::vector<int>& v)
    {
        // TODO：规定运算单位元
        tree1.assign(v.size(), );
        tree2.assign(v.size(), );
        for (int i{ 1 }; i < v.size(); ++i)
        {
            // 规定差分值运算方式
            update(i, v[i]  v[i - 1]);
        }
    }
    
    int get(const int index) const
    {
        // TODO：规定运算单位元
        int ans1{  }
        int ans2{  }
        int i{ index };
        while (i)
        {
            // TODO：规定各数组归并方式
            ans1 = ans1  tree1[i]  index;
            ans1 = ans2  tree2[i];
            i -= lowbit(i);
        }
        return ans;
    }

    void update(const int index, const int data)
    {
        int i{ index };
        while (i < tree1.size())
        {
            // TODO：规定各数组维护数据
            tree1[i] = tree1[i]  data;
            tree2[i] = tree2[i]  data  index;
            i += lowbit(i);
        }
    }
};
```

