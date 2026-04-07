# Manacher

Manacher 算法通过遍历字符串的每个位置，利用**已求得的回文串信息**求得新回文中心的初始半径然后向外拓展，在线性时间内求出字符串的所有回文子串。

## 回文信息

**回文中心**：回文串的对称点。奇长度回文串回文中心为最中间一个字符，偶长度回文串回文中心为最中间两个字符之间。

**回文半径**：从回文中心开始到回文串两端点的字符个数，等于回文串长度的一半（上取整）。

可以用回文中心和回文半径组成的二元组来表示一个回文串。

>   [!Note]
>
>   **回文半径的单调性**：将一个回文串的回文半径减一，相当于同时删去首位字符，结果依然是回文串。
>
>   以一个回文串的回文中心作为中心，小于等于回文半径的任意正整数长度为回文半径的字串都是回文串。

>   [!Note]
>
>   **回文串和 border 的联系：**对于一个回文串，其回文前/后缀等价于 border。

## 预处理

由于偶长度回文串的回文中心不在字符位置上，为了将奇偶回文串的处理方式统一起来，可以将字符串 $S$ 的每两个字符之间以及开头结尾处插入各一个特殊字符 `#`，得到奇数长度的 $S^{\#}$。

经过预处理之后，所有的回文串都变成奇数长度，且首尾均为 `#`。

>   [!tip]
>
>   转换之后的回文子串的回文半径减一等于转换前回文串的长度。

```cpp
string turn(string s)
{
    string ans;
    ans += '#';
    for (char c : s)
    {
        ans += c;
        ans += '#';
    }
    return ans;
}
```

## 最右回文串的维护

Manacher 的核心思想是不断维护字符串中的**最右回文子串**，通过该回文串的回文信息快速求解更右侧的回文串。

从左到右遍历每个位置，记录各位置的**最大回文半径**，同时维护已求得的**最右回文串** $P$ 的回文中心 $p$ 及其左右端点 $l,\ r$（或长度 $len$）。

对于每个位置 $i$，当 $i$ 在 $P$ 的**内部**时，根据 $P$ 的回文性，可以求出 $i$ 关于 $p$ 对称的位置 $j = 2p - i$。由于 $len_j$ 已求得，根据 $P$ 的回文性，$len_i$ 可以**继承** $len_j$ 在 $P$ 范围内部分的长度，根据 $len_j$ 是否超出了 $P$ 的范围，再分两种情况讨论。

+   当 $l_j > l$ 时，由于 $P$ 的回文性，可以确定 $len_i$ 等于 $len_j$，且不能再继续拓展。由 $l_j > l$ 可得，$r_i < r$，此时最右回文串没有发生变化。
+   当 $l_j <= l$ 时，$len_i$ 首先根据 $P$ 的回文性继承 $len_j$ 在 $P$ 内部的长度 $p - l_j + 1$，然后继续向两侧暴力**拓展**，求得回文半径 $len_i$。拓展后的回文串右端点一定大于等于 $r$，若右端点在 $r$ 右侧，更新最右回文串。

当 $i$ 在 $P$ 的**右侧**时，最右回文串无法为求解当前位置回文半径提供信息，因此需要将当前位置**更新**为新的最右回文串。从当前位置开始向两侧暴力地进行拓展，求得回文半径 $len_i$，由于此时以 $i$ 为中心的回文串右端点一定在 $r$ 的右侧，将最右回文串更新为 $p = i,\ l = i - len_i + 1,\ r = i + len_i - 1$。

一次遍历过后即可找出所有位置作为回文中心时的最大回文半径，根据回文半径的单调性即可求出所有回文串。

```cpp
vector<int> manacher(string s)
{
    int n = s.size();
    vector<int> lens(n);

    // 初始时最右回文串还未出现，r 应小于 0
    int l = -1, r = -1, p = -1;

    for (int i = 0; i < n; ++i)
    {
        if (i <= r)
        {
            int j = p - (i - p);
            if (j - (lens[j] - 1) > l)
            {
                // 完全在范围内直接继承
                lens[i] = lens[j];
            }
            else
            {
                // 不完全在范围内从已知安全长度开始拓展
                int len = j - l + 1;
                while (i - len >= 0 && i + len < n)
                {
                    if (s[i - len] != s[i + len])
                        break;
                    ++len;
                }
                lens[i] = len;
                if (i + lens[i] - 1 > r)
                {
                    l = i - lens[i] + 1;
                    r = i + lens[i] - 1;
                    p = i;
                }
            }
        }
        else
        {
            int len = 0;
            while (i - len >= 0 && i + len < n)
            {
                if (s[i - len] != s[i + len])
                    break;
                ++len;
            }
            lens[i] = len;
            if (i + lens[i] - 1 > r)
            {
                l = i - lens[i] + 1;
                r = i + lens[i] - 1;
                p = i;
            }
        }
    }
    return lens;
}
```

## 模板

```cpp
class Manacher
{
public:
    static std::string turn(const std::string& s)
    {
        std::string ans;
        ans += '#';
        for (const char c : s)
        {
            ans += c;
            ans += '#';
        }
        return ans;
    }

    static std::vector<int> calc(const std::string& s)
    {
        const int n{ static_cast<int>(s.size()) };
        std::vector<int> lens(n);

        int p{ -1 }, r{ -1 };
        for (int i{ 0 }; i < n; ++i)
        {
            const int j{ p - (i - p) };
            int len{ i <= r ? std::min(lens[j], r - i + 1) : 1 };
            // 不管是否继承都可以尝试匹配
            while (i - len >= 0 && i + len < n)
            {
                if (s[i - len] != s[i + len])
                    break;
                ++len;
            }
            lens[i] = len;

            if (i + len - 1 > r)
            {
                p = i;
                r = i + len - 1;
            }
        }
        return lens;
    }
};
```

