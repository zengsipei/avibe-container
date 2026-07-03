# avibe-container

`avibe-container` 是给 avibe 封装的 AI agent 开发容器环境。它负责准备 agent 写代码所需的 Debian 开发环境、由 fnm 管理的 LTS Node/npm、Python、构建工具、常用命令行工具和 AI CLI，并把容器内的 `/root` 持久化到本机 `.root/` 目录。

avibe 通过 `vibe` 命令在后台启动；容器前台默认保留一个 shell，主要用于让 AI agent 在 `/workspace` 内写代码。

默认镜像名是 `xiao806852034/avibe-container:latest`，用于后续通过 GitHub Actions 发布到 Docker Hub。

## 使用

```bash
docker compose build
docker compose run --rm avibe
```

默认每次进入容器都会重新运行官方安装脚本，用于安装或升级 avibe；`.root/` 中的用户目录状态会持续复用。

如果想保持一个长期运行的开发容器：

```bash
docker compose up -d --build
docker compose exec avibe bash -l
```

仓库目录会挂载到容器的 `/workspace`，容器 `/root` 会挂载到本机 `.root/`。

avibe 的 UI 服务当前在容器内监听 `127.0.0.1:5123`。容器入口会启动一个本地代理，把容器网卡上的 `5123` 转发到内部 loopback，所以宿主机可以通过 `http://127.0.0.1:5123` 访问。

## 配置

复制 `.env.example` 为 `.env` 后可以调整启动行为：

```bash
cp .env.example .env
```

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `IMAGE_NAME` | `xiao806852034/avibe-container` | Docker 镜像仓库名 |
| `IMAGE_TAG` | `latest` | Docker 镜像标签 |
| `TZ` | `Asia/Shanghai` | 容器时区 |
| `AVIBE_INSTALL_URL` | `https://avibe.bot/install.sh` | avibe 安装脚本地址 |
| `AVIBE_LOG` | `/root/.avibe/avibe.log` | avibe 后台进程日志路径 |
| `AVIBE_UI_PORT` | `5123` | 容器内 avibe UI 端口 |
| `AVIBE_UI_HOST_PORT` | `5123` | 映射到宿主机的 UI 端口 |
| `AVIBE_UI_PROXY_LOG` | `/tmp/avibe-ui-proxy.log` | UI 代理日志路径 |

## 目录约定

- `Dockerfile`: 构建 avibe 开发环境。
- `compose.yaml`: 本地开发容器入口。
- `entrypoint.sh`: 容器启动时运行 avibe 官方安装脚本，后台启动 `vibe`，然后进入 shell 或执行传入命令。
- `socat`: 用于把容器网卡的 UI 端口转发到 avibe 内部监听的 `127.0.0.1:5123`。
- `fnm`: 安装在容器 `/opt/fnm`，用于安装和激活 LTS Node，避免使用 Debian 仓库里的旧版 Node。
- `.root/`: 映射到容器 `/root`，用于持久化 CLI 配置、缓存和 avibe 状态；不会提交到 Git。
- `docs/agents/`: 工程技能使用的仓库约定。
- `docs/adr/`: 架构决策记录。

## 发布镜像

GitHub Actions workflow 位于 `.github/workflows/docker-publish.yml`。它只会在推送 `v*` tag 时构建并发布 `xiao806852034/avibe-container`。

需要在 GitHub 仓库 secrets 里配置：

- `DOCKERHUB_TOKEN`: Docker Hub access token。

发布标签：

- Git tag `v1.2.3`：`1.2.3`、`latest` 和 `sha-<commit>`
