---
title: "Istio 网关路由去除前缀"
date: 2022-05-25T00:00:00+08:00
summary: "现有若干服务，需要将符合某个特定前缀的路由指向特定的服务并将该前缀去除。"
tags: [cloud,kubernetes,istio]
---
# Istio 网关路由去除前缀

## 需求

现有若干服务，需要将符合某个特定前缀的路由指向特定的服务**并将该前缀去除**。

具体来看，我希望达到：

| 原路由     | 映射后 |
| ---------- | ------ |
| /users     | /      |
| /users/*** | /***   |

## 困难

很显然我们应该在一个 `VirtualService` 的配置中重点关注他的：

- `match`：匹配什么样的路由
- `rewrite`：以什么样的规则来重写

### 尝试1

```yaml
- match:
    - uri:
        prefix: /users/
  rewrite:
    uri: /
```

采用这种方法的问题是：无法正确处理`/users`，因为根本不会被匹配到！

### 尝试2

```yaml
- match:
    - uri:
        prefix: /users
  rewrite:
    uri: /
```

采用这种方法对 `/users` 倒是非常友好，但是问题就出现在了 `/users/***` 上。

按照这个规则，`/users/***` 会被匹配走 `/users` 并把这个部分替换成 `/`，于是恭喜你得到了 `//***`。那么这样一个路由能被正常请求么？不行！

### 尝试3

这时候就要开始借鉴先人的智慧了，有没有什么已知的解决方案？网上说可以这么做：

> 该思路应当是来源于多替换了一个`/` 所以想直接把他去掉。
>
> 但是如果你直接把 `rewrite` 中的 `uri` 字段替换成 `""` 的话，甚至过不了 Istio 的“编译”

```yaml
- match:
    - uri:
        prefix: /users
  rewrite:
    uri: " "
```

但是很遗憾，现实告诉我们这样不可以。（具体是什么错误有些遗忘，欢迎评论区补充x）

### 尝试4

查询 Istio 的[官方文档](https://istio.io/latest/docs/reference/config/networking/virtual-service/#StringMatch)，其实可以看到官方提供的匹配方式其实有 `exact` 、`prefix` 和 `exact` 三种。既然 `prefix` 不行的话，能不能试一试其他的方案？

比如说结合网上资料搞的小正则：

```yaml
- match:
    - uri:
        regex: "/users(/.*)?"
  rewrite:
    uri: /
```

但是似乎 `/users/***` 的 *** 会被丢掉的样子。

## 解决

在上网寻找解决方案的过程中，也刷到了[仓库的 issue 帖](https://github.com/istio/istio/issues/8076)。可以说提出 issue 的人想要解决的问题和我是一模一样的。甚至这个 issue 从2018年8月21日提出至今仍然是打开的状态，令人十分意外。同时上方我的各种尝试在 issue 中也是有人给出的。

Issue 中有人给出了我知道一定可以但我就不想那么做的方案：拆成两条匹配规则。但是由于我还有其他的配置，比如跨域政策等等，我可能并不想直接复制一遍，太不优雅了。

不过，在浏览帖子的时候注意到了一种写法：

```yaml
- match:
    - uri:
        prefix: "/api"
    - uri:
        prefix: "/api/"
  rewrite:
      uri: /
```

! 这个 `match` 他是个数组，完全可以写多个条件。（这 yaml 文件中的 `-` 总是这么不经意的就被人所忽视）。但是他的这种写法并不优雅，因为他写的是 `prefix: "/api"`，这就会导致比如 `/api-test` 之类的接口也会被匹配到，于是我自己改成了：

```yaml
- match:
    - uri:
        prefix: /users/
    - uri:
        exact: /users
  rewrite:
    uri: /
```

果然也在下面的其他人的回帖中看到类似的方案。

不过，这或许是一种妥协方案，外网群众称之为 `workaround`。毕竟从工具角度来说，其实应该更让用户符合直觉一些？（或许也是 issue 还没关掉的原因）。否则的话，从严谨角度来看，当前这样的方案确实更严谨，更符合逻辑上的思考。