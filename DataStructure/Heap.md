---
tags: ["DataStructure", "数据结构", "Heap", "堆"]
---

# 堆

堆是一种用于维护**可比较**元素的**优先顺序**（较大值优先、较小值优先等，以下内容以*较小值优先*为例）的数据结构，保证堆顶元素的优先级最高。

---

堆有多种实现方式，一般情况下为D叉堆中的**二叉堆**。

D叉堆的实现是一颗**完全D叉树**，由于其每层的节点数为以 $a_1 = 1,\ q = d$ 的等比数列，将每一层节点按顺序编号，则每个节点的子节点编号可以通过父节点编号计算得出，因此可以使用顺序表方便地进行存储。这种存储方式又称为**堆式存储**。

>   等比数列公式：$S_n = S_{n - 1} \times q + a_1$。
>
>   对于位于第 $x$ 层的第 $y$ 个节点，其节点编号为 $n = S_{x - 1} + y$，
>
>   对于其第 $i$ 个孩子节点，其节点编号为 $m = S_x + d \times (y - 1) + i$，
>
>   运算得到任意节点的**子节点**编号公式 $m = d \times (n - 1) + i + 1$，二叉堆中为 $2n$ 和 $2n + 1$。
>
>   又因为 $i \in [1,\ d] \Rightarrow \lfloor \frac{i - 1}{d} \rfloor = 0$，
>
>   运算得到任意节点的**父节点**编号公式 $n = \lfloor \frac{m - 2}{d} \rfloor + 1$，二叉堆中为 $\lfloor \frac{m}{2} \rfloor$。
>
>   ---
>
>   若实现中顺序表使用**零基索引**，则下标为 $i$ 的节点实际的编号为 $i + 1$。记 $n' = n + 1,\ m' = m + 1$，将其带入原公式，
>
>   得到**子节点**公式转化为 $m = d \times n + i$，二叉堆中为 $2n + 1$ 和 $2n + 2$；
>
>   **父节点**公式转化为 $n = \lfloor \frac{m - 1}{d} \rfloor$，二叉堆中为 $\lfloor \frac{m - 1}{2} \rfloor$。

D叉堆的实现中，对于堆中的任意节点，保证父节点优先级高于所有孩子节点，兄弟节点之间无优先级相对关系。

## 取值

优先级最高的节点位于根节点，取堆顶元素时直接返回根节点的值。

```cpp
int top()
{
    return heap[0];
}
```

## 插入 | 上浮

堆式存储中，堆的结构保持为一颗完全D叉树。因此插入数据时应在树的最深层按次序插入一个新节点，在顺序表中表现为将元素插入到末尾。

元素插入完成后，该节点与其父节点的相对关系可能并不正确，需要进行修正。

修正过程使用**上浮**操作，即当待修正节点的优先级高于父节点时，将该节点与其父节点位置交换。由于 $优先级_{待修正节点} > 优先级_{父节点} > 优先级_{兄弟节点}$，交换之后优先级关系正确。

插入操作的时间复杂度为树高，即 $O(\log_D n)$。$D$ 越大时复杂度越优。

```cpp
void slip_up(int node)
{
    while (node != 0) // 当到达根节点时停止上浮
    {
        int father = calc_father(node);
        if (!(heap[node] < heap[father])) // 当前节点优先级小于父节点时停止上浮
            break;
        swap(heap[node], heap[father]);	// 与父节点交换位置
        node = father;
    }
}
```

```cpp
void push(int data)
{
    int node = heap.size();
    heap.push_back(data);
    slip_up(node);
}
```

## 删除 | 下沉

删除堆顶元素时，保持完全D叉树结构，用最后一个节点的值覆盖将要被删除的根节点的值，然后删除最后一个节点实现删除操作。

删除完成后，根节点处的优先级顺序可能并不正确，需要进行修正。

修正过程使用**下沉**操作，即当待修正节点的孩子节点中存在某个节点的优先级更高时，将二者位置交换。由于交换后仍要保证节点优先级顺序，应从所有子节点中选择优先级最高的节点与其交换。

删除操作的时间复杂度为树高乘以子节点数量，即 $O(D\ log_D n)$，当 $D$ 在 $e$ 附近时复杂度最优，所以一般取 $2$ 或 $3$。

```cpp
void slip_down(int node)
{
    while (1)
    {
        if (calc_child(node, 1) >= heap.size()) // 到达叶子节点时停止下沉
            break;
        int child = node;
        for (int i = 1; i <= d; ++i)
        {
            if (calc_child(node, 1) >= heap.size())
                break;
            if (heap[calc_child(node, i)] < heap[child])
                child = calc_child(node, i);
        }
        if (child == node) // 优先级高于所有子节点时停止下沉
            break;
        swap(heap[node], heap[child]);
        node = child;
    }
}
```

```cpp
void pop()
{
    heap.front() = heap.back();
    heap.pop_back();
    slip_down(0);
}
```

## 模板

```cpp
class Heap
{
private:
    std::vector<int> heap_;

public:
    void push(const int data)
    {
        const int node = heap_.size();
        heap_.push_back(data);
        slip_up(node);
    }

    void pop()
    {
        heap_.front() = heap_.back();
        heap_.pop_back();
        slip_down(0);
    }

    int top() const
    {
        return heap_.front();
    }

    bool empty() const
    {
        return heap_.empty();
    }

    int size() const
    {
        return  heap_.size();
    }

private:
    void slip_up(int node)
    {
        while (node != 0)
        {
            const int father{ (node - 1) / 2 };
            if (!operate(heap_[node], heap_[father]))
                break;
            std::swap(heap_[node], heap_[father]);
            node = father;
        }
    }

    void slip_down(int node)
    {
        while (1)
        {
            if (node * 2 + 1 >= heap_.size())
                break;
            int child{ node };
            for (int i : { 1, 2 })
            {
                if (node * 2 + i >= heap_.size())
                    break;
                if (operate(heap_[node * 2 + i], heap_[child]))
                    child = node * 2 + i;
            }
            if (child == node)
                break;
            std::swap(heap_[node], heap_[child]);
            node = child;
        }
    }

private:
    static bool operate(const int a, const int b)
    {
        // TODO：定义优先顺序
        return a  b;
    }
};
```

