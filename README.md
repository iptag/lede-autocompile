# OpenWrt 自动编译

基于 GitHub Actions 的 OpenWrt 固件自动编译项目，支持多设备。

## 支持设备

| 设备 | 配置文件 | 工作流 | 说明 |
|------|----------|--------|------|
| x86_64 | `configs/x86_64.config` | `build_lede_2.yml` | 软路由/虚拟机 |
| 京东云 RE-SP-01B | `configs/jdcloud-re-sp-01b.config` | `build-jdcloud.yml` | MT7621 / 32MB Flash / 512MB RAM |

## 默认配置

- **源码**: [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- **默认 IP**: `192.168.123.1`
- **默认密码**: `password`

## 使用方法

1. Fork 本仓库
2. 进入 Actions 页面，选择对应设备的工作流
3. 点击 `Run workflow` 开始编译
4. 编译完成后在 Releases 页面下载固件

## 京东云 RE-SP-01B 说明

### 硬件规格
- SoC: MT7621AT (双核 880MHz)
- RAM: 512MB
- Flash: 32MB
- 内置 eMMC: 64GB
- USB: 2.0

### 刷机方法
1. 先刷入 Breed 引导程序
2. 固件文件选择 `*-sysupgrade.bin`
3. eMMC 存储需刷机后手动挂载

### 软件包配置
针对 32MB Flash 优化，默认启用：
- LuCI 管理界面
- Passwall
- UPnP / WoL
- Samba4
- 自动重启

## 自定义编译

修改 `configs/` 目录下对应的配置文件：
- `x86_64.config` / `pkg.config` - x86 设备
- `jdcloud-re-sp-01b.config` / `jdcloud-pkg.config` - 京东云设备

## 致谢

- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [Openwrt-Passwall](https://github.com/Openwrt-Passwall)

## License

[MIT](LICENSE)
