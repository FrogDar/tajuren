# Vue Router - 多页面路由

> Vue Router 是 [Vue.js](http://cn.vuejs.org/) 官方的路由管理器。它和 Vue.js 的核心深度集成，让构建单页面应用变得易如反掌。
>
> 简单来说，Vue Router 就是用来实现各个页面跳来跳去的那个小插件。
>
> Vue 2 对应的是 Vue Router 的 [v3.x](https://v3.router.vuejs.org/zh/) 版本。

## 安装

> 如果你在上一个教程已经安装过 Vue Router，那么可以直接跳过这个部分。

### 自动安装

倘若我们安装的是纯纯净净的 Vue 2，那么我们的 `src` 目录下看到的只有：`assets`、 `components`、 `App.vue`、 `main.js`  这四个文件。

此时我们可以利用 `Vue CLI` 工具，添加 `router` 这个插件。

```
vue add router
```

此时，终端报了一个大大的 `WARN`：

```
 WARN  There are uncommitted changes in the current repository, it's recommended to commit or stash them first.
? Still proceed? (y/N) 
```

这是为什么呢？[官方文档](https://v3.router.vuejs.org/zh/installation.html)是这么说的：“CLI 可以生成上述代码及两个示例路由。**它也会覆盖你的 `App.vue`**，因此请确保在项目中运行以下命令之前备份这个文件”。

而实际上，他会为我们修改许多内容，比如添加了 `views` 这个文件夹，打开 `App.vue` 和 `main.js` 都会发现他有很多的变化：其实就是将这个组件自动引入（而且是覆盖的那种）。

因此，如果你已经修改了这个文件，那么最好手动引入。当然，最好在一开始创建项目的时候就决定好要不要引入，这是最为妥当的。（能看到这个文档的人估计肯定是要引入的）

当我们选择 `y` ，也就是继续之后，Vue CLI 又询问我们：

```
? Use history mode for router? (Requires proper server setup for index fallback in production) (Y/n) 
```

在上一节中我们简单的介绍了一下什么是历史模式，什么是哈希模式。不过更具体的内容我们将展示在[后文](#历史模式)展开说明。假定你已经做出选择，自动安装的步骤就结束了。

我们看看 `src` 目录中发生了什么变化？

增加了 `router` 和 `views` 这两个文件夹，`App.vue`  和 `main.js` 也发生了不小的变化。

这下对着上一节的例子是不是又有所感触？

### 手动安装

使用包管理工具添加 `vue-router` 组件。注意，如果不标注版本的话，包管理工具会下载最新版（ v4.x ），Vue 2 对应的是 v3.x ，他们之间并不兼容。

```
yarn add vue-router@3
```

自动增加的内容，现在就由我们手工来添加！

首先是 `router` 文件夹，我们需要在 `index.js` 中创建出一个 `router` 对象。

```javascript
import Vue from 'vue'
import VueRouter from 'vue-router' 

// 明确的让 Vue 安装路由功能
Vue.use(VueRouter)

// 存放路由信息的地方
const routes = [
]

// 创建 router
const router = new VueRouter({
  mode: 'history', // 使用历史模式
  base: process.env.BASE_URL,
  routes
})

export default router
```

紧接着，要在 `main.js` 这个程序的入口中大告天下：我这个 Vue 要用这个我钦定的 router 啦~

```javascript
import router from './router'

new Vue({
  router,
  // others
}).$mount('#app')
```

接下来，我们要创建 `views` 这个文件夹，虽然它仍然是空的。

> 世上本没有视图，但随着路由的引入，组件中的一部分被特化成视图。
>
> 视图就是访问到某个路由时需要显示的那个特定的组件，我们把它特殊化，把它叫做视图。

最后，我们要在 `App.vue` 中寻找到合适的地方插入 `<router-view/>`。显然，我们加载路由之后显示的内容，就会是这个 `<router-view/>`，你把他放在哪里，路由所对应的那个组件就会在哪里显示。

## 使用

### 定义

> 其实真正 `router` 的定义，应当参见手动安装这个部分，解释了各个部分的作用。在这里，我们说的“定义”，更多是指路由的定义，或者说 `routes` 数组的定义。

#### 基本定义

众所周知，router 本质上的工作就是让 `<router-view/>` 显示当前这个 url 地址（路径）所对应的视图（组件）。因此最基本的路由在定义时应当包括 `path` 和 `component` 这两个参数。

```javascript
import HomeView from '../views/HomeView.vue'
// 存放路由信息的地方
const routes = [
  {
    path: '/Home',
    component: HomeView
  }
]
```

不过这种方式来导入有一些不好的地方：

- 开局加载所有组件，可能会使得第一次加载很慢很慢
- 你得给路由组件起名字，引入和使用分占两行不太直观

因此更推荐[懒加载](https://v3.router.vuejs.org/zh/guide/advanced/lazy-loading.html)或者说动态导入的方式进行定义：

```javascript
// 存放路由信息的地方
const routes = [
  {
    path: '/Home',
    component: () => import('../views/HomeView.vue')
  }
]
```

此外，我们还可以给当前路由定义一个名字，这有助于后续别人来操作当前这个路由。

> 如果不给路由起名字的话，要判断当前是什么路由只能看当前的路径。那如果突然有一天 `HomeView` 组件对应的路由 从 `/Home` 变成了 `/HomePage` 怎么办？全部推倒重来？划不来！

起名字的方式十分简单，在对象中传入 `name` 属性即可，例如：

 ```javascript
 // 存放路由信息的地方
 const routes = [
   {
     name: 'Home',
     path: '/Home',
     component: () => import('../views/HomeView.vue')
   }
 ]
 ```

#### 动态匹配

对于路径 `path` 我们可能希望他支持更多的操作，例如，对于路径 `users/123` 我们能不能自动把 `123` 提取出来作为参数？可以！只要我们把路径中的某一段（被 `/` 分割之后的小片段）用冒号 `:` 进行标记，那么匹配到的内容就会自动提取到路由的参数区（`params` 对象）。

| 定义路径                      | 实际路径            | 参数区（`params` 对象）                |
| ----------------------------- | ------------------- | -------------------------------------- |
| /user/:username               | /user/evan          | `{ username: 'evan' }`                 |
| /user/:username/post/:post_id | /user/evan/post/123 | `{ username: 'evan', post_id: '123' }` |

> `params` 对象应当如何使用？我们后续展开

除此之外，动态匹配甚至可以使用通配符 `*` ，通配符是不受 `/` 的影响的，并且通配符匹配的部分将自动保存到 `params` 对象的 `pathMatch` 属性中

| 定义路径 | 匹配范围                   | 实际路径      | `pathMatch`属性 |
| -------- | -------------------------- | ------------- | --------------- |
| /user-*  | 以 `/user-` 开头的任意路径 | /user-admin   | admin           |
| *        | 任意路径                   | /non-existing | /non-existing   |

需要注意的是，有些时候同一个路径可能匹配多个路由，这时候应当注意：匹配的优先级就是路由定义的顺序。也就是说，越早定义的路由，越早进行匹配。（像 `*` 这种路径肯定是直接放到最后一个去匹配 404 页面了）

更多的匹配模式可以参见[官方文档](https://v3.router.vuejs.org/zh/guide/essentials/dynamic-matching.html#%E9%AB%98%E7%BA%A7%E5%8C%B9%E9%85%8D%E6%A8%A1%E5%BC%8F)。

#### 重定向

重定向是什么？

简而言之就是当你访问 `/a` 的时候，自动就为你跳转至 `/b` ，至于 `/b` 是如何匹配的那是另外一回事。我们通过 `redirect` 属性定义重定向：

```javascript
routes: [
  { path: '/a', redirect: '/b' }
]
```

`redirect` 字段还支持通过命名路由的方式进行定义：

```javascript
routes: [
  { path: '/a', redirect: { name: 'foo' } }
]
```

甚至可以是个函数，当然返回值必须是个`字符串`或者`命名路由`。

#### 嵌套路由

有时候，我们可能希望来丶套娃。比如在 `User` 这个组件内，根据路由显示 `Profile` 组件或者 `Post` 组件，比如这样：

```
/users/123/profile                    /users/123/posts
+------------------+                  +-----------------+
| User             |                  | User            |
| +--------------+ |                  | +-------------+ |
| | Profile      | |  +------------>  | | Posts       | |
| |              | |                  | |             | |
| +--------------+ |                  | +-------------+ |
+------------------+                  +-----------------+
```

根据 `<router-view/>` 对应视图的原则，我们至少应当在 `users/:id` 所对应的视图中准备好 `<router-view/>`的坑位，等待 Vue Router 为我们填充。

既然 `<router-view/>` 里都应该套 `<router-view/>` 了，那是不是意味着 `routes` 里应该套 `routes` 了？答对 90%，错误的 10% 在于它换了一个名字，叫做 `children`。

此外，在 `children` 中定义的 `path` 需要注意：它更类似于相对路径，你不需要把路径写全。如果你想让 `/users/:id` 的本体也显示内容，请为他准备一个空的子路由（`''`）。

```javascript
const routes = [
  {
    path: '/users/:id',
    component: User,
    children: [
      {
        // 当 /users/:id 匹配成功，
        // UserHome 会被渲染在 User 的 <router-view> 中
        path: '',
        component: UserHome
      },
      {
        // 当 /users/:id/profile 匹配成功，
        // UserProfile 会被渲染在 User 的 <router-view> 中
        path: 'profile',
        component: UserProfile
      },
      {
        // 当 /users/:id/posts 匹配成功
        // UserPosts 会被渲染在 User 的 <router-view> 中
        path: 'posts',
        component: UserPosts
      }
    ]
  }
]
```

> `/` 意味着根路径，所以路径里带了 `/` 就会被认为是“绝对路径”

更多例子可参考[官方文档](https://v3.router.vuejs.org/zh/guide/essentials/nested-routes.html)。

#### 别名

别名是什么？

路由 `/a`  的别名如果是 `/b` 的话，用户去访问 `/b` 将会享受到和 `/a` 完全一样的待遇。我们通过 `alias` 属性进行设置，比如有这样一个例子：

```js
const routes = [
  {
    name: 'Home',
    path: '/Home',
    alias: '/',
    component: () => import('../views/HomeView.vue')
  }
]
```

更多高级用法可参考[官方文档](https://v3.router.vuejs.org/zh/guide/essentials/redirect-and-alias.html#%E5%88%AB%E5%90%8D)。

### 编程

经过上述定义环节，我们可以发现 Vue Router 一般认为 `route` 是路由信息， `router`  是路由器/路由管理者。因此在我们实际调用过程中，他们两个的关系有点点类似于 getter 和 setter 之间的关系。

如若你想获取当前页面的的路由信息，你可以获取 `this.$route` 对象，比如名字就是 `this.$route.name` ，路径是 `this.$route.path`，参数就是 `this.$route.params` ，请求就是 `this.$route.query` 等。

> 为什么是 `this.$route` ？
>
> 我们是在 `router/index.js` 里定义的 `router`，但是 Vue 他也为我们提供了全局的引入，将这个对象挂载在当前页面的 `$route` 和 `$router` 里。其实你也可以通过引入这个变量来对他进行操作。

如若你想编程操作路由变化的话，可以使用 `this.$router` 的方法进行变化，常用的有：`push` , `replace`，`go` 三种。

`push(location, onComplete?, onAbort?)` 是新访问一个页面，或者说在历史记录里新加一条（所以支持通过浏览器来`后退`）

`replace(location, onComplete?, onAbort?)` 是替换当前页面，或者说直接在历史记录里替换掉之前的页面（除了这一页，历史记录里的其他页都好好的）

`go(n)` 是在历史记录上前进（ n 为正数）或者后退（ n 为负数）多少步，显然 n 为 0 时就是刷新页面。

而对于 `location` 字段的定义，其实就是一个 `route` 对象。 

```javascript
// 对象
router.push({ path: 'home' })

// 命名的路由
router.push({ name: 'user', params: { userId: '123' }})

// 带查询参数，变成 /register?plan=private
router.push({ path: 'register', query: { plan: 'private' }})

// 注意：如果有 path 了， params 就不生效
router.push({ path: '/user', params: { userId: '123' }}) // -> /user
```

如果只有 `path` 字段，甚至可以直接写字符串。也就是说 `router.push({ path: 'home' })` 等价于 `router.push('home')`。

而 `onComplete` 和 `onAbort` 回调则是可选的第二个和第三个参数，分别在导航成功完成和终止的情况下调用。

### 模板

在 HTML ，或者说模板的部分中，Vue Router 也提供了小组件来方便用户调用。

| 函数写法                   | 模板写法                               |
| -------------------------- | -------------------------------------- |
| `router.push(location)`    | `<router-link :to="location">`         |
| `router.replace(location)` | `<router-link :to="location" replace>` |

`location` 的写法与函数写法完全一致，点击 `<router-link>` 的时候相当于调用了函数写法，他们的功能完全等价。

## 拓展

#### 导航守卫

当路由发生变化的时候，你可能想要跟着做出一些响应。按照已知的方法，那就是通过 `watch` 来检测 `$route` 的变化：

```javascript
const User = {
  template: '...',
  watch: {
    $route(to, from) {
      // 对路由变化作出响应...
    }
  }
}
```

但是你还有另一种选择，叫做导航守卫。比如，这里可以使用 `beforeRouteUpdate` 导航守卫：

```javascript
const User = {
  template: '...',
  beforeRouteUpdate(to, from, next) {
    // 对路由变化作出响应...
    // 不要忘记调用 next() 这样才能顺利访问下个页面
  }
}
```

既然有 `beforeRouteUpdate` 是不是就可以有其他的呢？比如导航完成先判断一下是否已经登录然后进入某个页面？有的！导航完成前对应的事件叫做 `beforeRouteEnter`，[官方文档](https://v3.router.vuejs.org/zh/guide/advanced/data-fetching.html)中给了非常详细的例子。

更多导航守卫的使用方法可以参考[官方文档](https://v3.router.vuejs.org/zh/guide/advanced/navigation-guards.html)。

#### 历史模式

Vue Router 归根到底是利用 URL 来模拟多页面，换句话说本质上你访问的一直是同一个 `index.html`  文件，是 Vue Router 在帮助你显示不同的内容。

既然如此，在原先 Vue Router 默认使用的是更容易帮助他实现的方式： 哈希模式。

哈希模式最显著的特征就是有一个 `#` （哈希值就是 URL 中从 `#` 开始到结束的部分），比如官方文档里：

```
https://v3.router.vuejs.org/zh/guide/essentials/history-mode.html#html5-history-模式
```

看起来还好？但是如果你真的启用哈希模式的话，你会发现自己的主页可能是`http://localhost:8080/#/Home`，甚至是`http://localhost:8080/test#/Home`！

总归大家会觉得哈希模式有点丑，这时候就会选择历史模式。

历史模式就是大家日常所熟知的那种格式，比如`http://localhost:8080/Home` 这样的。

在开发过程中你会发现没有什么问题，但在部署过程中就会出现一些小偏差：如果你真的访问 `your-domain.com/Home`  的话，你会发现 `404` ！为什么呢？

因为这终归是模拟，你看到的再多，实际上存在的文件只有 `index.html`，后端顺着你的 URL 去寻找 `Home.html` 的时候，自然就找不到这个文件。那应该如何解决？

告诉后端：无论你访问的是什么页面，你都给我指向到 `index.html` 。以 `nginx` 为例，那就是：

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

不过这样的话，你的 `routes` 就需要覆盖全部路径，对于你不想要的路径那就让他显示 404 页面，比如在 `routes` 里添加 `{ path: '*', component: NotFoundComponent }`。否则，不存在的页面也没有任何提示，不也很奇怪吗？

更多后端配置可参考[官方文档](https://v3.router.vuejs.org/zh/guide/essentials/history-mode.html#%E5%90%8E%E7%AB%AF%E9%85%8D%E7%BD%AE%E4%BE%8B%E5%AD%90)。
