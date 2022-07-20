---
title: "[CSP202009-3]点亮数字人生"
date: 2022-04-22T00:00:00+08:00
summary: "力求通过一道模拟题的讲解与分析，让大家能更好地编写模拟类型的OJ题目。"
tags: [CSP,题解]
---
# `[CSP202009-3]` `[模拟]` 点亮数字人生

> 力求通过一道模拟题的讲解与分析，让大家能更好地编写模拟类型的OJ题目。
>
> 或者说，模拟的本质就是将逻辑思路翻译成程序代码，这个过程或许有一些小技巧。

## 方法概论

依我拙见，面对模拟时，怎么样才能保证自己的代码又快又好地实现的秘诀就在这句打油诗上：

**先搭骨架后填充，及时测试及时修。**

其实也很直白，就是两点：

1. 先起框架梳理逻辑，随后逐个完善具体的函数内容
2. 及时进行单元测试，每一步都是对的，整个程序自然也就是对的

框架的划分，某种角度上说是最为重要的。太细，那么框架就太”流水“，和直接上手写没什么区别；太粗，那么框架就等于什么都没说，不过好在我们还可以继续细化，无伤大雅。

所以某种程度上来说，框架宁可粗一点，之后可以慢慢细化，到一定程度了就可以对这个“原子”进行单元测试，检验单单这个部分的代码写的对不对了。

比如说一个程序，看到是多组数据，然后就不假思索打下：

```cpp
#include <bits/stdc++.h>
using namespace std;
void work() {}
int main() {
    int T;
    cin >> T;
    while (T--) work();
    return 0;
}
```

至少我们这下只需要思考单次输入该怎么办了。

而对于 `work()` 函数，最基本的划分又有三段：输入，处理，输出。

而接下来怎么拆分比较合适呢？有一个原则是：你能直接想到的就是当前要考虑的。

换句话说，在当前这个环境下，你最表层、最直接考虑的问题是现在要做的，对于这个问题的进一步展开，就交由下一步的具体细化来做。就比如，我们现在要读入一个矩阵我可能就会这么写：

```cpp
int m,n;
cin>>m>>n;
Matrix matrix(m,n);
```

然后在构造函数里面写读入x

或者是多加一个  `matrix.in();` 来读入数据，至于矩阵具体怎么读，不是现在的我要考虑的事情。

有人可能会问，这不是和直接写感觉差不多么？

确实是差不多，但是一来结构化，省点代码（如果输入多个矩阵呢？），而来这是这个例子简单，但是积少成多，一层一层拆解才能让原本庞大而又复杂的体系变得每个单元都十分简单。

按照前面说的 `先搭骨架后填充，及时测试及时修。` 的逻辑，就是先写上这么一个框架（概要设计），然后再去具体实现矩阵的输入（详细设计及编码），然后输入完就及时输出看自己有没有写错（单元测试），除非非常地有自信。

光讲方法论还是非常抽象的，来看看具体的例子吧：

## 题目描述

给定 $m$ 个输入和 $n$ 个门电路组成的组合逻辑电路，同时给定 $Q$ 组数据，对于输入中的 $Q$  个问题，你需要按照输入顺序输出每一个问题的答案：

- 如果你检测到电路中存在组合环路，则请输出一行，内容是 `LOOP`，无需输出其他任何内容。

- 如果电路可以正常工作，则请输出 $S$ 行，每一行包含 $s_i$ 个用**空格分隔**的数字（可能为 `0` 或 `1`），依次表示“输出描述”中要求的各个器件的运算结果。

## 解题步骤

首先看到这是一个多组数据的题目，我们可以把框架先安排着：

```cpp
#include <bits/stdc++.h>
using namespace std;

// 单组数据的相关操作
void work() {}

// 程序入口
int main() {
    int Q;
    cin >> Q;
    while (Q--) work();
    return 0;
}
```

经过“无脑”框架之后，我们可以小小动动脑袋想一想怎么解决输入问题。

一个良好的输入是非常重要的，有可能后面代码调错调了半天，才发现是输入出了偏差。

此外，决定输入的时候也意味着程序的基本框架。

比如，经过我们的观察，在这道题目里很重要的对象是门电路组件，那我就可以建立一个类，叫做 `Component` 用以存储，并且实现输入输出函数。在实现 `Component` 的输入过程中，我们又发现 `I1`、`O2` 一类的端口信息，在这里我考虑用类 `L` 来解决，当然，你也可以直接在 `Component` 类里解决。

**及时检查中间结果**

当我们准备好这样一个十分重要的 `Component` 类之后，我们就及时地开始单元测试，即输出一下当前读入的信息。

```cpp
#include <bits/stdc++.h>
using namespace std;

// 输入信号
class L {
   private:
    char type;
    int port;

   public:
    void in() { cin >> type >> port; }
    void out() { cout << type << port; }
};

// 组件
class Component {
   private:
    string func;
    vector<L> l;

   public:
    void in() {
        int k;
        cin >> func >> k;
        for (int i = 0; i < k; i++) {
            l.push_back({});
            l.back().in();
        }
    }
    void out() {
        cout << func << " " << l.size();
        for (auto i : l) {
            putchar(' ');
            i.out();
        }
        putchar('\n');
    }
};

// 单组数据的相关操作
void work() {
    vector<Component> c;
    int n, m;
    cin >> m >> n;
    for (int i = 0; i < n; i++) {
        c.push_back({});
        c.back().in();
    }
    for (auto i : c) i.out();
}

// 程序入口
int main() {
    int Q;
    cin >> Q;
    while (Q--) work();
    return 0;
}
```

感觉和方法论不太一样？其实关键在于你要保证：

- 你要实现的代码是框架里**自上而下**实现的（除非这个部分十分的简单）
- 每次实现代码之后就**立即**进行测试

或者说，搭建框架和实现框架里的函数是两个线程，线程之间顺序可以乱，但是线程内的顺序是一致的。最终达到的效果是：从读入开始做一步看一步，实现到哪里，哪里就是对的。

随后可以把整个骨架都搭建起来，把后续的输入和输出的架构都定好：

- 第一部分的输入
- 第二部分的输入
- 判断是否存在环
- 输出没有环的情况

在此过程中仍然要及时跑一跑代码（进行测试），比如输出一些变量看看情况，或者是做一些校验。

```cpp
/**
 * @brief 检查组件之间是否存在有环
 * 
 * @param c 组件数组的引用
 * @return true 有环
 * @return false 无环
 */
bool check_loop(vector<Component>& c) {}

/**
 * @brief 根据组件、当前输入判断输出情况
 *
 * @param c 组件信息
 * @param input 外部输入信号量
 * @param output 待输出组件的序号
 */
void calc(vector<Component> c, const vector<int>& input,
          const vector<int>& output) {}

// 单组数据的相关操作
void work() {
    // 第一部分输入
    int m = read();
    int n = read();
    vector<Component> c;
    for (int i = 0; i < n; i++) {
        c.push_back({});
        c.back().in();
    }

    // 第二部分输入
    int T = read();
    vector<vector<int>> input;
    vector<vector<int>> output;
    for (int count = 0; count < T; count++) {
        input.push_back({});
        for (int i = 0; i < m; i++) input.back().push_back(read());
    }
    for (int count = 0; count < T; count++) {
        output.push_back({});
        int s = read();
        for (int i = 0; i < s; i++) output.back().push_back(read());
    }

    // 输出
    if (check_loop(c))
        printf("LOOP\n");
    else
        for (int i = 0; i < T; i++) calc(c, input[i], output[i]);
}
```

我们设计了 `check_loop()`  和 `calc()` 两个函数，这个是我们在构建框架的时候自然而然、最直接想到的。至于具体怎么判断环，具体怎么计算输出结果，可以暂放，不要想那么多！（想得多，小脑袋就乱了）

> 这里想到一个经典的亲和数的习题。
>
> 一对正整数，彼此的约数之和（本身除外）等于对方称之为亲和数。
>
> 很多人在写的过程中团成了一个大函数，还容易错，但是倘若先不想那么多呢？
>
> ```cpp
> for (int i = 1; i < 1000; i++) {
>     int sum = sum_of_factors(i);
>     if (i < sum && sum_of_factors(sum) == i) printf("%d %d\n", i, sum);
> }
> ```
>
> 然后我们再慢慢考虑如何求解约数和，这样拆解问题显然会大大降低编码难度。

现在开始具体实现：如何判断组件之间是否存在有环？一个显然的思路：拓扑排序。

当然你也可能想到其他的判断方法，这都不影响我们要实现的这部分内容。

在写的过程中，我们发现可能需要修改其他的内容，比如类。有一个原则是：**只增不减**。因为已经写完的部分是确保正确的，你要修改也得测试他的正确性；而我们新需要的功能，一般来说都可以通过新实现的函数来完成。

为了方便后续的更多操作，数组下标最好是从1开始变为从0开始，即我在需要获得私有属性 `port`  的值，在写 `getPort()` 的时候，返回值应该是 `port-1`。即：

```cpp
// 输入信号
class L {
   private:
    char type;
    int port;

   public:
    void in() {
        cin >> type >> port;
    }
    void out() { cout << type << port; }
    char getType() { return type; }
    int getPort() { return port - 1; }
};
```

不过为了方便（毕竟只是一个 OJ 题），我们稍作小小的变化，直接修改访问修饰符，并且直接修改存储的 port 的值。两种写法实现的功能是相一致的。

```cpp
// 输入信号
class L {
   public:
    char type;
    int port;

   public:
    void in() {
        cin >> type >> port;
        port--;
    }
    void out() { cout << type << port + 1; }
};


/**
 * @brief 检查组件之间是否存在有环
 * 判断思路：拓扑排序
 * @param c 组件数组
 * @return true 有环
 * @return false 无环
 */
bool check_loop(vector<Component> c) {
    vector<vector<int>> a(c.size());
    vector<int> degree(c.size());
    for (int i = 0; i < c.size(); i++)
        for (auto L : c[i].l)
            if (L.type == 'O') {
                a[L.port].push_back(i);
                degree[i]++;
            }
    queue<int> q;
    for (int i = 0; i < c.size(); i++)
        if (degree[i] == 0) q.push(i);
    int cnt = 0;
    while (q.size()) {
        int u = q.front();
        for (auto v : a[u]) {
            degree[v]--;
            if (degree[v] == 0) q.push(v);
        }
        q.pop();
        cnt++;
    }
    return cnt != c.size();
}
```

写完之后及时测试！刚好，两个样例一个有环，一个无环。如果提供的样例不足够支撑我们自己的测试，那我们就自己造几组测试数据来检测一下。

```
1
2 6
NOR 2 O4 I2
AND 2 O4 O6
XOR 2 O5 O1
NOT 1 O6
NAND 2 O2 O2
AND 2 I1 O3
2
0 0
1 0
3 2 3 4
6 1 2 3 4 5 6
LOOP
```

最后我们只剩下 `calc()` 函数嗷嗷待哺。因为我们使用了 `Component` 类，因此很显然会想到如果每个组件有一个求值函数  `calculate()` 那么输出又变得简单了，直接调用即可！

在这个过程中我们看到了 全局变量 与 局部变量 之间的争夺。如果用全局变量会大大简化代码，但是破坏代码的可复用性不说也需要特别注意数据清除（因为函数要多次调用）；直接使用局部变量（传递参数）则会让函数调用变得十分麻烦，影响视觉美感。

如何选择全在于你，毕竟这这是一道小小 OJ 题，差别并不大。下面以传参方法作为演示：

```cpp
/**
 * @brief 根据组件、当前输入判断输出情况
 *
 * @param c 组件信息
 * @param input 外部输入信号量
 * @param output 待输出组件的序号
 */
void calc(vector<Component> c, const vector<int>& input,
          const vector<int>& output) {
    for (auto i : output) {
        printf("%d ", c[i - 1].calculate(c, input));
    }
    putchar('\n');
}
```

这下我们需要思考的就是如何计算一个组件的输出结果。其实十分自然：

1. 计算每个输入的信号量
2. 根据逻辑来计算最后的输出

计算每个输入的信号量，对于输入信号量，我们直接从 `input` 里获取，对于组件的输出，因为我们有了 `calculate()` 函数，所以我们直接调用即可。

根据信号量数组和逻辑计算输出，也是单独的一个模块，可以独立也可以接着往下写，一样取决于你。

最后增添一个记忆化，保存一下计算后的输出结果，减少重复计算。

```cpp
// 输入信号
class L {
   public:
    char type;
    int port;

   public:
    void in() {
        cin >> type >> port;
        port--;
    }
    void out() { cout << type << port + 1; }
};

// 组件
class Component {
   private:
    int ans = -1;

   public:
    string func;
    vector<L> l;

   public:
    void in() {
        int k;
        cin >> func >> k;
        for (int i = 0; i < k; i++) {
            l.push_back({});
            l.back().in();
        }
    }
    void out() {
        cout << func << " " << l.size();
        for (auto i : l) {
            putchar(' ');
            i.out();
        }
        putchar('\n');
    }
    int calculate(vector<Component>& c, const vector<int>& input) {
        // 记忆化
        if (ans != -1) return ans;

        // 计算每个要用到的输入
        vector<int> tmp;
        for (auto L : l) {
            if (L.type == 'I')
                tmp.push_back(input[L.port]);
            else
                tmp.push_back(c[L.port].calculate(c, input));
        }

        // 根据逻辑功能计算输出
        if (func == "NOT")
            ans = !tmp[0];
        else if (func == "AND" || func == "NAND") {
            ans = 1;
            for (auto i : tmp) ans &= i;
            if (func[0] == 'N') ans = !ans;
        } else if (func == "OR" || func == "NOR") {
            ans = 0;
            for (auto i : tmp) ans |= i;
            if (func[0] == 'N') ans = !ans;
        } else if (func == "XOR") {
            ans = 0;
            for (auto i : tmp) ans ^= i;
        }
        return ans;
    }
};
```

总览全局，我们把代码框架的方方面面都填充完成。最后我们再来最后的集成测试，发现很顺利地通过了。有没有一种可能，这就是能够 AC 的代码呢？我们提交，果然成功。

完整的代码如下：

```cpp
#include <bits/stdc++.h>
using namespace std;

int read() {
    int f = 1, s = 0;
    char c = getchar();
    for (; c < '0' || c > '9'; c = getchar())
        if (c == '-') f = -1;
    for (; c >= '0' && c <= '9'; c = getchar()) s = s * 10 + c - '0';
    return f * s;
}

// 输入信号
class L {
   public:
    char type;
    int port;

   public:
    void in() {
        cin >> type >> port;
        port--;
    }
    void out() { cout << type << port + 1; }
};

// 组件
class Component {
   private:
    int ans = -1;

   public:
    string func;
    vector<L> l;

   public:
    void in() {
        int k;
        cin >> func >> k;
        for (int i = 0; i < k; i++) {
            l.push_back({});
            l.back().in();
        }
    }
    void out() {
        cout << func << " " << l.size();
        for (auto i : l) {
            putchar(' ');
            i.out();
        }
        putchar('\n');
    }
    int calculate(vector<Component>& c, const vector<int>& input) {
        // 记忆化
        if (ans != -1) return ans;

        // 计算每个要用到的输入
        vector<int> tmp;
        for (auto L : l) {
            if (L.type == 'I')
                tmp.push_back(input[L.port]);
            else
                tmp.push_back(c[L.port].calculate(c, input));
        }

        // 根据逻辑功能计算输出
        if (func == "NOT")
            ans = !tmp[0];
        else if (func == "AND" || func == "NAND") {
            ans = 1;
            for (auto i : tmp) ans &= i;
            if (func[0] == 'N') ans = !ans;
        } else if (func == "OR" || func == "NOR") {
            ans = 0;
            for (auto i : tmp) ans |= i;
            if (func[0] == 'N') ans = !ans;
        } else if (func == "XOR") {
            ans = 0;
            for (auto i : tmp) ans ^= i;
        }
        return ans;
    }
};

/**
 * @brief 检查组件之间是否存在有环
 * 判断思路：拓扑排序
 * @param c 组件数组
 * @return true 有环
 * @return false 无环
 */
bool check_loop(vector<Component> c) {
    vector<vector<int>> a(c.size());
    vector<int> degree(c.size());
    for (int i = 0; i < c.size(); i++)
        for (auto L : c[i].l)
            if (L.type == 'O') {
                a[L.port].push_back(i);
                degree[i]++;
            }
    queue<int> q;
    for (int i = 0; i < c.size(); i++)
        if (degree[i] == 0) q.push(i);
    int cnt = 0;
    while (q.size()) {
        int u = q.front();
        for (auto v : a[u]) {
            degree[v]--;
            if (degree[v] == 0) q.push(v);
        }
        q.pop();
        cnt++;
    }
    return cnt != c.size();
}

/**
 * @brief 根据组件、当前输入判断输出情况
 *
 * @param c 组件信息
 * @param input 外部输入信号量
 * @param output 待输出组件的序号
 */
void calc(vector<Component> c, const vector<int>& input,
          const vector<int>& output) {
    for (auto i : output) {
        printf("%d ", c[i - 1].calculate(c, input));
    }
    putchar('\n');
}

// 单组数据的相关操作
void work() {
    // 第一部分输入
    int m = read();
    int n = read();
    vector<Component> c;
    for (int i = 0; i < n; i++) {
        c.push_back({});
        c.back().in();
    }

    // 第二部分输入
    int T = read();
    vector<vector<int>> input;
    vector<vector<int>> output;
    for (int count = 0; count < T; count++) {
        input.push_back({});
        for (int i = 0; i < m; i++) input.back().push_back(read());
    }
    for (int count = 0; count < T; count++) {
        output.push_back({});
        int s = read();
        for (int i = 0; i < s; i++) output.back().push_back(read());
    }

    // 输出
    if (check_loop(c))
        printf("LOOP\n");
    else
        for (int i = 0; i < T; i++) calc(c, input[i], output[i]);
}

// 程序入口
int main() {
    int Q;
    cin >> Q;
    while (Q--) work();
    return 0;
}
```

通过拆解的方式，化繁为简，能够大大减小代码实现的难度，而又提高代码准确性。不仅仅是对于模拟，其实所有的编码都可以按照这种模式来实现。

如果有去网上搜索本题的其他题解的话，你甚至会发现，170行的代码并不算长（而且我们还可以删除很多”无用代码“）。所以快来动动小手试一试这种方法吧~

