# Traefik 服务配置文件

> 相比于传统的 `nginx` 来说，使用 `Traefik` 作为反向代理服务器具有很多的优势。（这里就不详细展开，大家可以自行搜索、对比）
>
> `Traefik` 可以很好地结合 `docker` 为我们十分便捷地提供反向代理服务。不用像 `nginx` 那样十分麻烦地配置各种内容，我们仅需将所用的服务打包为 `docker` 镜像，再添加相关的网络及标签，就完成了整个部署流程。

## 传统做法

一般来说，我们通过 `docker-compose.yml` 文件设置标签。当然，我们也可以直接使用 `docker` 终端，只不过要配置的选项太多了！

我们可以看到，需要配置的主要是六个标签，关于每个标签的具体解释或许可以查询[官方文档](https://doc.traefik.io/traefik/)，在这里简要说明这六个标签的作用：

- 设置路由 `example` 的匹配规则是访问 `example.com` （访问 `example.com` 的流量会被转发到 `example` 路由）
- 访问容器内部服务的端口号是 `80`
- 路由 `example` 的访问入口（端口）是 `websecure` （这个 `websecure` 是在 `Traefik` 中自行配置的，比如我将其设置为 `443` ）
- 路由 `example` 开启 `TLS` 服务
- 为路由 `example` 指定中间层 `example-compress`
- 中间层 `example-compress` 开启压缩功能

同时，我们还需要让容器和 `Traefik` 处于同一个网络环境内，否则 `Traefik` 也没有办法将流量转发到容器内。我们假设，在开启 `Traefik ` 服务时，把它所在的网络命名为 `traefik-global-proxy` ，那么我们就可以写出如下的配置文件：

```yaml
version: "3"
services:
    example:
        image: tajuren/example
        container_name: example
        labels: 
            - "traefik.http.routers.example.rule=Host(`example.com`)"
            - "traefik.http.services.example.loadbalancer.server.port=80"
            - "traefik.http.routers.example.entrypoints=websecure"
            - "traefik.http.routers.example.tls=true"
            - "traefik.http.routers.example.middlewares=example-compress"
            - "traefik.http.middlewares.example-compress.compress=true"
        networks: 
            - traefik-global-proxy
networks:
  traefik-global-proxy:
    external: true
```

## 环境变量

如果我们要创建多个服务时，很自然地就会想到复制粘贴 `docker-compose.yml` 文件。但是你会发现，你经常替换的其实只有固定的那么几个参数。因此，我们可以将这些参数通过环境变量的方式来读取。这不仅可以提高代码复用率，同时，在 git 仓库中也起到很好的作用，例如，在生产、测试服务器分离时，可以直接合并仓库分支，而不需要担心 `docker-compose.yml` 的问题（当然，你也可以选择分成两个不同的文件）。

```yaml
version: "3"
services:
  example:
    image: "tajuren/${SERVICE_NAME}"
    container_name: "${SERVICE_NAME}"
    labels:
      - "traefik.http.routers.${SERVICE_NAME}.rule=${HOST_ADDRESS}"
      - "traefik.http.services.${SERVICE_NAME}.loadbalancer.server.port=${PORT}"
      - "traefik.http.routers.${SERVICE_NAME}.entrypoints=websecure"
      - "traefik.http.routers.${SERVICE_NAME}.tls=true"
      - "traefik.http.routers.${SERVICE_NAME}.middlewares=${SERVICE_NAME}-compress"
      - "traefik.http.middlewares.${SERVICE_NAME}-compress.compress=true"
    networks:
      - traefik-global-proxy
networks:
  traefik-global-proxy:
    external: true
```

如果你担心实际运行时没有配置好环境变量，你也可以使用：

- `${VARIABLE:-default}` 将在没设置变量 `VARIABLE` 或其值为空时填充默认值
- `${VARIABLE-default}` 仅在没有设置变量 `VARIABLE` 时填充默认值

关于 `docker compose` 中的环境变量，可以通过查阅[官方文档](https://docs.docker.com/compose/environment-variables/)获取更多说明。

## 自制工具

有的时候，我们并不想去复制粘贴这些文件，或者，我们手头并没有一个可供复制的旧文件。此时，我们或许可以使用一个命令行工具手动地帮我们生成一个配置文件，或者在某个已经写好的 `docker-compose.yml`  中，添加 `Traefik` 所需的这些标签。

> 以上其实是给自己写的小工具硬编的应用场景，评论区有无更合理的情况x

此时，我们或许就需要一个工具，为我们生成这样的配置文件。于是乎，我们可以自己写一个！

`tygen` 应运而生！仓库地址：https://github.com/FrogDar/traefik-yaml-generator/

目前，`tygen` 包括两个命令：

- `append`： 为现有的 `docker-compose.yml` 中的服务添加 `Traefik` 所需内容
- `create`： 从零创建一个 `docker-compose.yml`，需要至少指定一个 docker compose 的服务名

同时附加 9 种可选项，可以很方便地生成各类配置文件。当然，一些很特殊的需求还是需要自己改改的，比如添加 `TLS` 的证书分发器等。

```shell
tygen create tajuren-example -a example.tajuren.cn -i tajuren/example
```

生成的 `docker-compose.yml` 如下：

```yaml
networks:
    traefik-global-proxy:
        external: true
services:
    tajuren-example:
        container_name: tajuren-example
        image: tajuren/example
        labels:
            - traefik.http.routers.tajuren-example.rule=Host(`example.tajuren.cn`)
            - traefik.http.services.tajuren-example.loadbalancer.server.port=80
            - traefik.http.routers.tajuren-example.entrypoints=websecure
            - traefik.http.routers.tajuren-example.tls=true
            - traefik.http.routers.tajuren-example.middlewares=tajuren-example-compress
            - traefik.http.middlewares.tajuren-example-compress.compress=true
        networks:
            - traefik-global-proxy
version: "3"
```

虽然说，输出的顺序是按照字母序来的（和我们平时的习惯不太一样），但并不影响机器阅读使用。可以看到还是非常方便的。

> 这个 `tygen` 某种程度上就是为了写这个博客特地写的项目。
>
> 当然，其实也是练习使用 `Go` 语言，主要用到 `github.com/spf13/cobra` 库（辅助构建终端）和 `github.com/spf13/viper ` 库（读写配置文件）。
>
> 另外也是想玩一玩 `go test --cover` 命令，目前的覆盖率达到 81.6%，还算可以。
