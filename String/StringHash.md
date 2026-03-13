# 字符串哈希

字符串哈希是将一个任意长度字符串**映射**成一个在固定范围内的整数哈希值，以便在 $O(1)$ 时间内完成字符串比较。

## 哈希函数

字符串哈希使用**多项式哈希取模**进行转换。

首先把字符集内的每个字符通过一定规则转换成 $base$ 范围内的唯一非零值 $v$，转换得到的值即为该字符在当前那一位的哈希值。

对长度为 $n$ 的整个字符串进行哈希映射时，将字符串看作是一个 $n$ 位的 $base$ 进制整数，然后将该整数转换为十进制，并对模数 $m$ 取模，得到最终哈希值。
$$
\begin{aligned}
&H(S)\\
&= \sum_{i = 0}^{n - 1}(V[i] \cdot base^{n - i - 1}) \pmod{m}\\
&= (V[0] \cdot base^{n - 1} + V[1] \cdot base^{n - 2} + \cdots + V[n - 1] \cdot base^0) \pmod{m}.\\
\end{aligned}
$$

## 子串哈希

对于字符串 $S$ 的子串 $S[l,\ r]$，将其看作一个独立的字符串，根据哈希函数得到其哈希值表达式。
$$
\begin{aligned}
&H(S[l,\ r])\\
&= \sum_{i = l}^{r - 1}(V[i] \cdot base^{r - i - 1}) \pmod{m}\\
&= (V[l] \cdot base^{r - l - 1} + V[l + 1] \cdot base^{r - l - 2} + \cdots + V[r] \cdot base^0) \pmod{m}.\\
\end{aligned}
$$
将 $S[0,\ l - 1]$ 和 $S[0,\ r]$ 也看作一个独立的字符串，根据哈希函数得到各自表达式。
$$
\begin{aligned}
&H(S[0,\ l - 1])\\
&= \sum_{i = 0}^{l - 2}(V[i] \cdot base^{l - i - 2}) \pmod{m}\\
&= (V[l] \cdot base^{l - 2} + V[l + 1] \cdot base^{l - 3} + \cdots + V[l - 2] \cdot base^0) \pmod{m},\\

&H(S[0,\ r])\\
&= \sum_{i = 0}^{r - 1}(V[i] \cdot base^{r - i - 1}) \pmod{m}\\
&= (V[0] \cdot base^{r - 1} + V[1] \cdot base^{r - 2} + \cdots + V[r] \cdot base^0) \pmod{m}.\\
\end{aligned}
$$
两式相减得到，
$$
\begin{aligned}
&H(S[0,\ r]) - H(S[0,\ l - 1])\\
&= (V[0] \cdot base^{r - 1} + V[1] \cdot base^{r - 2} + \cdots + V[l - 1] \cdot base^{r - l - 1}\\
&- V[0] \cdot base^{l - 2} - V[1] \cdot base^{l - 3} - \cdots - V[l - 1] \cdot base^0\\
&+ V[l] \cdot base^{r - l - 1} + V[l + 1] \cdot base^{r - l - 2} + \cdots + V[r] \cdot base^0) \pmod{m}.\\
\end{aligned}
$$
发现对于 $[0,\ l - 1]$ 部分的 $base$， $H(S[0,\ r])$ 正好比 $H(S[0, l - 1])$ 每项多 $r - l + 1$ 次幂，由此可得，
$$
\begin{aligned}
&H(S[0,\ r]) - base^{r - l + 1} \cdot H(S[0,\ l - 1])\\
&= (V[l] \cdot base^{r - l - 1} + V[l + 1] \cdot base^{r - l - 2} + \cdots + V[r] \cdot base^0) \pmod{m}.\\
\end{aligned}
$$
该表达式恰好与 $H(S[l, r])$ 相等。由此可得，
$$
H(S[l,\ r]) = (H(S[0,\ r]) - base^{r - l + 1} \cdot H(S[0,\ l - 1])) \pmod{m}.
$$
所以只需要求出字符串 $S$ 每个位置的**前缀哈希值**，就可以快速求出任意子串的哈希值。

```cpp
vector<uint64_t> build(string s)
{
    int n = s.length();
    vector<uint64_t> prehashs(n);
    // turn函数用于将字符转换成整数
    // powers数组用于储存[0, n)范围内base所有的幂次
    for (int i = 0; i < n; ++i)
    {
        // base进制左移一位
        if (i)
            prehashs[i] = (prehashs[i - 1] * base) % mod;
        // 加上最低位
        prehashs[i] = (prehashs[i] + turn(s[i])) % mod;
    }
    return prehashs;
}
```

```cpp
uint64_t get_hash(int l, int r)
{
    uint64_t prehash_l = l ? prehashs[l - 1] : 0;
    uint64_t prehash_r = prehashs[r];
    return ((prehash_r - (prehash_l * powers[r - l + 1]) % mod) % mod + mod) % mod;
}
```

>   [!Tip]
>
>   另一种哈希的方式是将 $base$ 的幂次从左到右依次从 $0$ 开始增加，这样幂次与子串的相对下标相等，逻辑更清晰。
>
>   但并不建议这种写法，因为求子串哈希值时需要将 $Hash(S[0, r])$ 除以 $r - l + 1$。同余除法运算需要额外求出 $base$ 的幂次的逆元。

## 模板

```cpp
class StringHash
{
private:
    inline static bool is_init{ false };
    // inline static int64_t maxlen_{ 1000000 };   //TODO：设置问题中字符串最大长度
    inline static constexpr int64_t base1_{ 5131111 };
    inline static constexpr int64_t base2_{ 50411513 };
    inline static constexpr int64_t mod1_{ 999999937 };
    inline static constexpr int64_t mod2_{ 2000000011 };
    inline static std::vector<int64_t> powers1_{ };
    inline static std::vector<int64_t> powers2_{ };

private:
    std::vector<int64_t> prehashs1_{ };
    std::vector<int64_t> prehashs2_{ };

public:
    StringHash() = default;

    StringHash(const std::string& s)
    {
        build(s);
    }

public:
    std::pair<int64_t, int64_t> get_hash(const int l, const int r) const
    {
        int64_t prehash1_l = l ? prehashs1_[l - 1] : 0;
        int64_t prehash2_l = l ? prehashs2_[l - 1] : 0;
        int64_t prehash1_r = prehashs1_[r];
        int64_t prehash2_r = prehashs2_[r];
        int64_t hash1{ mod1(prehash1_r - mod1(prehash1_l * powers1_[r - l + 1])) };
        int64_t hash2{ mod2(prehash2_r - mod2(prehash2_l * powers2_[r - l + 1])) };
        return {hash1, hash2};
    }

    void build(const std::string& s)
    {
        if (!is_init)
            init();
        const int n{ static_cast<int>(s.length()) };
        prehashs1_.assign(n, 0);
        prehashs2_.assign(n, 0);
        for (int i{ 0 }; i < n; ++i)
        {
            if (i)
            {
                prehashs1_[i] = mod1(prehashs1_[i - 1] * base1_);
                prehashs2_[i] = mod2(prehashs2_[i - 1] * base2_);
            }
            prehashs1_[i] = mod1(prehashs1_[i] + turn(s[i]));
            prehashs2_[i] = mod2(prehashs2_[i] + turn(s[i]));
        }
    }

    void push_back(const std::string& s)
    {
        for (const char c : s)
        {
            push_back(c);
        }
    }

    void push_back(const char c)
    {
        int i{ static_cast<int>(prehashs1_.size()) };
        prehashs1_.emplace_back();
        prehashs2_.emplace_back();
        if (i)
        {
            prehashs1_[i] = mod1(prehashs1_[i - 1] * base1_);
            prehashs2_[i] = mod2(prehashs2_[i - 1] * base2_);
        }
        prehashs1_[i] = mod1(prehashs1_[i] + turn(c));
        prehashs2_[i] = mod2(prehashs2_[i] + turn(c));
    }

public:
    static std::pair<int64_t, int64_t> get_hash(const std::string& s)
    {
        if (!is_init)
            init();
        const int n{ static_cast<int>(s.length()) };
        int64_t hash1{ 0 }, hash2{ 0 };
        for (int i{ 0 }; i < n; ++i)
        {
            if (i)
            {
                hash1 = mod1(hash1 * base1_);
                hash2 = mod2(hash2 * base2_);
            }
            hash1 = mod1(hash1 + turn(s[i]));
            hash2 = mod2(hash2 + turn(s[i]));
        }
        return {hash1, hash2};
    }

private:
    static void init()
    {
        is_init = true;
        powers1_.assign(maxlen_, 1);
        powers2_.assign(maxlen_, 1);
        for (int i{ 1 }; i < maxlen_; ++i)
        {
            powers1_[i] = mod1(powers1_[i - 1] * base1_);
            powers2_[i] = mod2(powers2_[i - 1] * base2_);
        }
    }

    static int64_t turn(const char c)
    {
        if (std::islower(c))
            return 411 + c - 'a';
        if (std::isupper(c))
            return 513 + c - 'A';
        if (std::isdigit(c))
            return 821 + c - '0';
        return 1111 + c;
    }

    static int64_t mod1(const int64_t x)
    {
        return (x % mod1_ + mod1_) % mod1_;
    }

    static int64_t mod2(const int64_t x)
    {
        return (x % mod2_ + mod2_) % mod2_;
    }
};
```

