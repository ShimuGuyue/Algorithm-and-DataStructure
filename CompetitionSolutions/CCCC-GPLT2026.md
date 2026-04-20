# CCCC-GPLT2026

补题链接：https://pintia.cn/problem-sets/994805046380707840

个人评价：L1 和 L2 很简单，全做完拿满分用了不到一个小时，这次没有什么毒瘤题；L3-1 的模拟题目读题用了半个多小时，实现起来倒是不难；后两题难度大跳越，知识点没有学到，拼劲全力无法战胜。

## L1-1 一行代码

签到题。

输出一行内容。直接复制并输出即可。

```cpp
void solve()
{
    std::cout << "Building the Future, One Line of Code at a Time.\n";
}
```

## L2-2 要刷多少题

签到题。

输出 $n \times 15$。

```cpp
void solve()
{
    int n;
    std::cin >> n;
    std::cout << n * 15 << '\n';
}
```

## L1-3 就挺突然的

分支语句语法题。

由 $B - A$ 得到寿命，判断在 $[-\infty,\ 0], [1, 250], [251, +\infty]$ 的哪个范围内。

```cpp
void solve()
{
    int a, b;
    std::cin >> a >> b;
    int dif{ b - a };
    std::cout << dif << '\n';
    if (dif > 250)
        std::cout << "jiu ting tu ran de...\n";
    else if (dif <= 0)
        std::cout << "hai sheng ma?\n";
    else
        std::cout << "nin tai cong ming le!\n";
}
```

## L1-4 普及赛排名

循环语句语法题。

统计 $n$ 个数中所有小于 $1700$ 的数的个数。

```cpp
void solve()
{
    int n;
    std::cin >> n;
    int ans{ 0 };
    while (n--)
    {
        int a;
        std::cin >> a;
        if (a < 1700)
            ++ans;
    }
    std::cout << ans << '\n';
}
```

## L1-5 做什么都被骂怎么办

$n$ 组数据 `编号 记录`，统计所有编号满足其所有的记录均为 $0$。将编号升序输出，没有则输出 `NONE`。

先用 set 存储所有拥有记录为 $0$ 的编号，再将拥有记录为 $1$ 的编号从中移除。

```cpp
void solve()
{
    int n;
    std::cin >> n;
    std::vector<std::pair<int, int>> as(n);
    for (auto& [a, b] : as)
    {
        std::cin >> a >> b;
    }

    std::set<int> ans;
    for (auto [a, b] : as)
    {
        if (b == 0)
            ans.insert(a);
    }
    for (auto [a, b] : as)
    {
        if (b == 1)
            ans.erase(a);
    }

    int m{ int(ans.size()) };
    if (m == 0)
    {
        std::cout << "NONE\n";
        return 0;
    }
    for (int a : ans)
    {
        std::cout << a;
        if (--m)
            std::cout << ' ';
    }
    std::cout << '\n';
}
```

## L1-6 钓鱼佬专用挪车电话

$11$ 个字符串，依次输出每个串的长度。注意**空串**的读入。

```cpp
void solve()
{
    for (int i{ 0 }; i < 11; ++i)
    {
        std::string s;
        std::getline(std::cin, s);
        std::cout << s.length();
    }
    std::cout << '\n';
}
```

## L1-7 网络流量监测

对于给定 $n$ 个数，完成两项需求：

1.   最大值、最小值和平均值（下取整）。
1.   将超过平均值的二倍的数的编号升序输出，没有则输出 `Normal`。

```cpp
void solve()
{
    int n;
    std::cin >> n;
    std::vector<int> as(n + 1);
    for (int i{ 1 }; i <= n; ++i)
    {
        std::cin >> as[i];
    }

    int max{ *std::max_element(as.begin() + 1, as.end()) };
    int min{ *std::min_element(as.begin() + 1, as.end()) };
    int sum{ std::accumulate(as.begin() + 1, as.end(), 0) };
    int ave{ sum / n };
    std::cout << max << ' ' << min << ' ' << ave << '\n';

    bool find{ false };
    for (int i{ 1 }; i <= n; ++i)
    {
        if (as[i] > ave * 2)
        {
            if (find)
                std::cout << ' ';
            find = true;
            std::cout << i;
        }
    }
    if (!find)
        std::cout << "Normal";
    std::cout << '\n';
}
```

## L1-8 智慧文本编辑器

对于给定字符串 $S$ 进行三种操作：

1.   查找字符串 $S1$ 在 $S$ 中的前三次出现位置。没有出现输出 `-1`，不足三次全部输出。

     直接调用库函数 `string::find`。

1.   在 $S$ 的第 $p$ 个位置插入字符串 $S2$，输出修改后的 $S$。

     直接调用库函数 `string::insert`。

1.   将 $S$ 的 $[l,\ r]$ 区间进行反转，输出修改后的 $S$。

     直接调用库函数 `reverse`。

```cpp
void solve()
{
    int n;
    std::cin >> n;
    std::string s;
    std::cin >> s;
    while (n--)
    {
        int op;
        std::cin >> op;
        if (op == 1)
        {
            std::string t;
            std::cin >> t;
            std::vector<int> ans;
            int index{ 0 };
            for (int i{ 0 }; i < 3; ++i)
            {
                if (s.find(t, index) == std::string::npos)
                    break;
                ans.push_back(s.find(t, index));
                index = s.find(t, index) + 1;
            }
            if (ans.empty())
            {
                std::cout << -1 << '\n';
                continue;
            }
            for (int i{ 0 }; i < ans.size(); ++i)
            {
                if (i)
                    std::cout << ' ';
                std::cout << ans[i];
            }
            std::cout << '\n';
        }
        else if (op == 2)
        {
            int p;
            std::string t;
            std::cin >> p >> t;
            s.insert(p, t);
            std::cout << s << '\n';
        }
        else if (op == 3)
        {
            int l, r;
            std::cin >> l >> r;
            std::reverse(s.begin() + l, s.begin() + r + 1);
            std::cout << s << '\n';
        }
    }
}
```

## L2-1 姥姥改作业

栈模板题。

给定 $n$ 个数和混乱值 $t$，对于所有数，如果小于等于 $t$，将其编号添加到答案序列，否则放入栈中。

一轮操作结束后，将 $t$ 重新赋值为栈中所有数的平均值（下取整），依次从栈顶取出数进行以上操作。重复该操作直到所有数都被处理。输出处理顺序。

```cpp
void solve()
{
    int n, t;
    std::cin >> n >> t;
    std::vector<std::pair<int, int>> as(n + 1);
    for (int i{ 1 }; i <= n; ++i)
    {
        std::cin >> as[i].first;
        as[i].second = i;
    }

    std::vector<int> ans;
    std::stack<std::pair<int, int>> k;
    for (int i{ 1 }; i <= n; ++i)
    {
        auto [a, index]{ as[i] };
        if (a > t)
            k.push({a, index});
        else
            ans.push_back(index);
    }

    while (!k.empty())
    {
        auto temp{ k };
        int sum{ 0 };
        while (!temp.empty())
        {
            sum += temp.top().first;
            temp.pop();
        }
        t = sum / k.size();

        std::stack<std::pair<int, int>> kk;
        while (!k.empty())
        {
            auto [a, index]{ k.top() };
            k.pop();
            if (a > t)
                kk.push({a, index});
            else
                ans.push_back(index);
        }
        k = kk;
    }

    for (int i{ 0 }; i < n; ++i)
    {
        if (i)
            std::cout << ' ';
        std::cout << ans[i];
    }
    std::cout << '\n';
}
```

## L2-2 超参数搜索

二分模板题。

对于给定 $n$ 个数，完成两项需求。

1.   按升序顺序输出所有最大值的编号。

1.   给出 $m$ 个查询，找到大于 $x$ 的数的最小值的最小下标，不存在输出 $0$。

     用 map 记录所有数的最小下标，二分查找第一个大于 $x$ 的数。

```cpp
void solve()
{
    int n;
    std::cin >> n;
    std::vector<int> as(n + 1);
    for (int i{ 1 }; i <= n; ++i)
    {
        std::cin >> as[i];
    }

    int max{ *std::max_element(as.begin() + 1, as.end()) };
    bool find{ false };
    for (int i{ 1 }; i <= n; ++i)
    {
        if (as[i] != max)
            continue;
        if (find)
            std::cout << ' ';
        find = true;
        std::cout << i;
    }
    std::cout << '\n';

    std::map<int, int> flags;
    for (int i{ 1 }; i <= n; ++i)
    {
        if (!flags.count(as[i]))
            flags[as[i]] = i;
    }

    int m;
    std::cin >> m;
    while (m--)
    {
        int x;
        std::cin >> x;
        int ans{ 0 };
        auto it{ flags.upper_bound(x) };
        if (it != flags.end())
            ans = it->second;
        std::cout << ans << '\n';
    }
}
```

## L2-3 森林藏宝图

树上 DFS 模板题。

给出一棵以 $0$ 为根的树，对于从根节点出发到达每个叶子节点的简单路径，找到每条路径上经过的最小值的最大值。

对于找到的最大最小值，对于每条路径，若路径上最小值等于答案值，记录其叶子节点。将记录的叶子节点升序输出。

```cpp
void solve()
{
    int n;
    std::cin >> n;
    std::vector<std::vector<std::pair<int, int>>> graph(n);
    for (int i{ 1 }; i < n; ++i)
    {
        int j, s;
        std::cin >> j >> s;
        graph[j].push_back({i, s});
    }

    int max{ -1 };
    std::vector<int> ans;
    auto dfs = [&graph, &max, &ans](auto&& dfs, int u, int min) -> void
    {
        if (graph[u].empty())
        {
            if (min > max)
                ans.clear();
            if (min >= max)
            {
                max = min;
                ans.push_back(u);
            }
            return;
        }
        for (auto [v, w] : graph[u])
        {
            dfs(dfs, v, std::min(min, w));
        }
    };
    dfs(dfs, 0, 1000);
    std::cout << max << '\n';
    std::sort(ans.begin(), ans.end());
    for (int i{ 0 }; i < ans.size(); ++i)
    {
        if (i)
            std::cout << ' ';
        std::cout << ans[i];
    }
    std::cout << '\n';
}
```

## L2-4 大语言模型的推理

图上 DFS 模板题。

给定一张带权有向图。给定 $k$ 次查询，从节点 $x$ 出发，每次走向边权最大且目标编号最小的节点，每个节点只能走一次。输出行走顺序。

```cpp
void solve()
{
    int n, m;
    std::cin >> n >> m;
    std::vector<std::vector<std::pair<int, int>>> graph(n + 1);
    while (m--)
    {
        int u, v, p;
        std::cin >> u >> v >> p;
        graph[u].push_back({v, p});
    }

    std::vector<bool> visited(n + 1);
    auto dfs = [&graph, &visited](auto&& dfs, int u)
    {
        int max{ 0 };
        int target;
        for (auto [v, p] : graph[u])
        {
            if (visited[v])
                continue;
            if (p > max)
            {
                max = p;
                target = v;
            }
            else if (p == max)
            {
                target = std::min(target, v);
            }
        }
        if (max == 0)
            return;
        std::cout << "->" << target;
        visited[target] = true;
        dfs(dfs, target);
    };

    int k;
    std::cin >> k;
    while (k--)
    {
        visited.assign(n + 1, false);
        int x;
        std::cin >> x;
        std::cout << x;
        visited[x] = true;
        dfs(dfs, x);
        std::cout << '\n';
    }
}
```

## L3-1 门诊预约排队系统

贪心+模拟。

给定 $n$ 个患者的信息 `到达时间，预约时间，ID，年龄`。按规则输出每个患者的就诊时间。

$80$ 岁以上老人有特别优先权，因此按年龄大小维护两个等待集合。

从 $1$ 到 $n$ 枚举时间，若当前时间有人到达，全部加入等待集合，然后选择就诊患者：

+   等待集合均为空，进入到下一时间；
+   若当前时间的预约患者在等待，选择该患者；
+   若有没到预约时间的患者在等待，选择到达时间最早的患者，优先查看老人集合。

```cpp
void solve()
{
    int time1;
    int time2;
    std::string id;
    int age;

    bool operator<(const Data& o) const
    {
        return time2 < o.time2;
    }
};

int main()
{
    int n;
    std::cin >> n;
    std::vector<Data> datas(n);
    for (auto& [t1, t2, id, age] : datas)
    {
        std::cin >> t1 >> t2 >> id >> age;
    }

    int index{ 0 };

    std::set<Data> t1;
    std::set<Data> t2;
    int time{ 1 };
    while (1)
    {
        if (index == n && t1.empty() && t2.empty())
            break;
        while (index < n && datas[index].time1 <= time)
        {
            auto& d{ datas[index] };
            if (d.age < 80)
                t1.insert(d);
            else
                t2.insert(d);
            ++index;
        }
        Data flag{0, time, "", 0};
        if (t1.count(flag))
        {
            std::cout << time << ' ' << t1.find(flag)->id << '\n';
            t1.erase(flag);
        }
        else if (t2.count(flag))
        {
            std::cout << time << ' ' << t2.find(flag)->id << '\n';
            t2.erase(flag);
        }
        else if (!t2.empty())
        {
            std::cout << time << ' ' << t2.begin()->id << '\n';
            t2.erase(t2.begin());
        }
        else if (!t1.empty())
        {
            std::cout << time << ' ' << t1.begin()->id << '\n';
            t1.erase(t1.begin());
        }
        ++time;
    }
}
```

## 未解决：L3-2，L3-3

