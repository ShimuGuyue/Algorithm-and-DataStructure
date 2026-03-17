# Trie

Trie 是一种树形数据结构，通过提取若干字符串的**公共前缀**，维护一个字典集合，也称为前缀树。

对于问题中的字符集大小 $base$，Tire 的每个节点通过 $base$ 个子节点指向字典中后续存在的字符序列。Trie 上从根结点出发一路向下，到达任意一个节点处**依次经过的字符序列**表示一个前缀。

## 插入字符串

向 Trie 中插入字符串时，遍历字符串中的每个字符，同时从根节点出发，每遍历一个字符，树上节点的位置通过对应的边下移一层，最后当字符串到达末尾时，在对应节点添加一个结束标记。

```cpp
void insert(string s)
{
    Node* node = root;
    for (char c : s)
    {
        // turn 函数用于将字符映射成base内的整数值
        int index = turn(c);
        if (node->children[index] == nullptr)
            node->children[index] = new Node;
        node = node->children[index];
    }
    // 字符串集合中可能存在重复，所以结束标记用int而非bool
    ++node->count_end;
}
```

## 检索字符串

在 Trie 中检索指定字符串时，同样从根节点出发，逐字符依次下行，若 Trie 上的边不足以走到字符串结尾，则该字符串不存在于字典中。

```cpp
int count(string s)
{
    Node* node = root;
    for (char c : s)
    {
        int index = turn(c);
        if (node->children[index] == nullptr)
            return 0;
        node = node->children[index];
    }
    return node->count_end;
}
```

## 根据前缀检索字典串

对于给定的字符串 $s$，求在字典中以其为前缀的所有字符串，这是 Trie 的最主要应用。

对于 Trie 的每个节点，额外维护一个变量 `count_pass`，用于记录有多少个字符串经过当前节点，即以当前节点表示的前缀串为前缀。插入字符时，对于字符串遍历经过的每个节点，累加其 `count_pass`。

检索前缀时，首先找到前缀串对应的节点，返回该节点的 `count_pass` 即可。若字典中无该前缀串则返回 $0$。

```cpp
int count_pre(string s)
{
    Node* node = root;
    for (char c : s)
    {
        int index = turn(c);
        if (node->children[index] == nullptr)
            return 0;
        node = node->children[index];
    }
    return node->count_pass;
}
```

若要列出所有以 $s$ 为前缀的字典串，则以 $s$ 所在节点开始向下进行 DFS 回溯，每遇到一个 `count_end` 不为 $0$ 的节点，就将其记录。

```cpp
vector<string> list_pre(string s)
{
    Node* node = root;
    for (char c : s)
    {
        int index = turn(c);
        if (node->children[index] == nullptr)
            return { };
        node = node->children[index];
    }
    vector<string> ans;
    auto dfs = [&ans, &s](this auto& dfs, Node* n) -> void
    {
        if (n->count_end > 0)
            ans.push_back(s);
        for (int index = 0; index < base; ++index)
        {
            if (n->children[index] == nullptr)
                continue;
            // deturn函数用于将base范围内整数值转换成对应的字符
            s += deturn(index);
            dfs(dfs, n->children[index]);
            s.pop_back();
        }
    }
    dfs(node);
    return ans;
}
```

## 删除字符串

需要从 Trie 中删除指定字符串时，进行插入的**反操作**。

首先在 Trie 中找到对应字符串的结束节点，若节点不存在，则直接结束删除操作。

找到结束节点后，首先将该节点的 `count_end` 减一，然后从该节点一路向上直到根节点，将路径上所有节点的 `count_pass` 减一。

当路径上某个节点的 `count_pass` 在操作之后变为 $0$，则说明该节点表示的前缀串在字典中不复存在。将该节点删除，并将父节点对应的边设为空。

```cpp
void erase(string s)
{
    Node* node = root;
    for (char c : s)
    {
        int index = turn(c);
        if (node->children[index] == nullptr)
            return;
        node = node->children[index];
    }
    if (node->count_end == 0)
        return;
    vector<Node*> nodes{ root }; // nodes储存待删除字符串上的所有节点
    vector<int> indexs; // indexs储存每个节点向下检索时的路径
    node = root;
    --root->count_pass;
    for (char c : s)
    {
        int index = turn(c);
        node = node->children[index];
        --node->count_pass;
        nodes.push_back(node);
        indexs.push_back(index);
    }
    --node->count_end;
    for (int i = nodes.size() - 1; i > 0; --i) // 根节点不能删除
    {
        // 父节点的count_pass一定大于子节点，不需要删除时直接退出
        if (nodes[i]->count_pass != 0)
            break;
        nodes[i - 1]->children[indexs[i - 1]] = nullptr;
        delete nodes[i];
    }
}
```

### 懒删除

若某些节点被实际删除，但后续仍有可能会在插入字典串时**重新创建**该节点，十分耗时。

在**空间限制充足**的情况下，可以不实际删除节点，而是在检索字符串时将 `count_pass` 为 $0$ 的节点视为和 `nullptr` 等效，从而实现**懒删除**。以便实现节点复用。

使用懒删除的操作时，需将检索字符串中判断边存在的代码由 `if (node->children[index] == nullptr)` 修改为 `if (node->children[index] == nullptr || node->children[index]->count_pass == 0)`。

>   [!Tip]
>
>   在不需要实际删除节点的情况下，用数组进行模拟比指针具有更好的缓存友好性和空间友好性，更有利于节省时空消耗。

## 模板

```cpp
class Trie
{
private:
    // static constexpr int base{ 62 };    // TODO：设置字符集大小
    struct Node
    {
        std::array<int, base> children{ };
        int count_pass{ 0 };
        int count_end{ 0 };
    };
    std::vector<Node> tree{ Node() };

public:
    Trie() = default;

public:
    void insert(const std::string& s)
    {
        int node{ 0 };
        ++tree[0].count_pass;
        for (const char c : s)
        {
            const int index{ turn(c) };
            if (tree[node].children[index] == 0)
            {
                tree[node].children[index] = tree.size();
                tree.emplace_back();
            }
            node = tree[node].children[index];
            ++tree[node].count_pass;
        }
        ++tree[node].count_end;
    }

    int count(const std::string& s) const
    {
        int node{ search(s) };
        if (node == -1)
            return 0;
        return tree[node].count_end;
    }

    int count_pre(const std::string& s) const
    {
        const int node{ search(s) };
        if (node == -1)
            return 0;
        return tree[node].count_pass;
    }

    void erase(const std::string& s)
    {
        int node{ search(s) };
        if (node == -1 || tree[node].count_end == 0)
            return;
        node = 0;
        --tree[0].count_pass;
        for (const char c : s)
        {
            int index{ turn(c) };
            node = tree[node].children[index];
            --tree[node].count_pass;
        }
        --tree[node].count_end;
    }

private:
    void init()
    {
        tree.resize(1);
    }

    int search(const std::string& s) const
    {
        int node{ 0 };
        for (const char c : s)
        {
            const int index{ turn(c) };
            if (tree[node].children[index] == 0 || tree[tree[node].children[index]].count_pass == 0)
                return -1;
            node = tree[node].children[index];
        }
        return node;
    }

private:
    static int turn(const char c)
    {
        // TODO：规定字符转换方式
        // if (std::islower(c))
        //     return 0 + c - 'a';
        // if (std::isupper(c))
        //     return 26 + c - 'A';
        // if (std::isdigit(c))
        //     return 52 + c - '0';
        return ;
    }
};
```

