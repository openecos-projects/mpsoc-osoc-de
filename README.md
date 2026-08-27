# mpsoc-osoc

这是 `mpsoc-osoc` 的开发者和维护者仓库。它提供固定地址、固定总线的 SoC
模板，以及由 CI 自动生成的用户发行环境。

用户发行包的规范说明位于 `dev/user-kit/README.md`，英文版本位于
`dev/user-kit/README.en.md`。这两份文件会覆盖到 CI 生成的 `user-kit` 分支，
因此主仓库 README 只描述开发、集成和发布流程。

## 仓库结构

```text
rtl/                 fixed SoC, MCU, reference CPU, and IP RTL
sim/                 Verilator harness and fast simulation models
prog/                fixed regression image and CPU-ID patch script
user-cores/          local user cores and slot manifest
scripts/             slot assembly and User Kit export tools
dev/user-kit/        user README and Makefile templates
dev/user-kit.json    User Kit files, trees, and override rules
.github/workflows/   CI checks, export, and user-kit publication
build/               local generated files; never commit these
```

固定顶层模块是 `asicTopYSYXstageDE`，源文件为
`rtl/soc/asicTopYSYXstageDE.v`。顶层模块名不通过额外的元数据文件配置。

## 开发者检查

在仓库根目录执行：

```sh
make check
make lint
make sim CPU_ID=0
make trace CPU_ID=0
make export-user-kit
make clean
```

`make check` 验证 32 个 core 槽位、用户清单、Verilator 和固定 `.bin` 镜像。
`make lint` 检查组装后的仿真设计。完整仿真单独保留，因为参考镜像可能需要
较多周期才能结束。

本地 `make export-user-kit` 只用于检查导出内容。正式用户发行包由
`.github/workflows/user-kit.yml` 生成，不应手工提交 `build/user-kit`。

## 用户 core 集成

`user-cores/cores.list` 的格式是：

```text
<slot> <module-name> <source-relative-to-user-cores>
```

例如：

```text
0 UserCore0 core0/top.sv
```

每个槽位登记一个顶层源文件；多文件处理器通过顶层文件包含其他源文件。
槽位必须从 0 开始连续编号，未登记槽位保留参考 NPC。

`scripts/assemble-cores.py` 只在 `build/generated/` 中生成文件，不会修改仓库
中的 SoC 顶层，并且会将用户 core 源文件加入生成的 Verilator filelist。

## User Kit 发布

发布清单为 `dev/user-kit.json`。其中：

- `files` 指定需要复制的单个文件；
- `trees` 指定固定 RTL 目录；
- `exclude` 指定不应进入发行包的路径；
- `overrides` 将用户版 README 和 Makefile 覆盖到发行包根目录。

CI 的 `export-and-test` job 会先运行源仓库检查，再导出 User Kit，并在导出
目录中重新运行 `make check`、`make lint` 和 `make clean`。只有 `main` 分支
推送在这些步骤全部通过后，`publish` job 才会强制更新 `user-kit` 分支。

用户发行分支只包含用户需要的固定 RTL、仿真环境、core 模板、固定镜像、用户
Makefile 和双语 README，不包含 `dev/`、维护者导出脚本、构建产物、版本文件或
顶层名称文件。

## 集成约束

- 不要修改 `rtl/soc/asicTopYSYXstageDE.v`、MCU、RCU、总线、外设或地址译码。
- 不要修改 `prog/change-cpuid.sh`；回归固定使用发布包提供的 `.bin` 镜像。
- 当前版本固定按 50 MHz 配置收束，`soc_pkg` 自定义地址空间留待后续版本。
- 用户 core 的简单总线时序和功能正确性由提交方负责。
