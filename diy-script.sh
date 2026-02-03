#!/bin/bash

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-vsftpd
rm -rf feeds/luci/applications/luci-app-filetransfer

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
# git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
git clone --depth=1 -b main https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale
# git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/luci-app-serverchan
# git clone --depth=1 https://github.com/ilxp/luci-app-ikoolproxy package/luci-app-ikoolproxy
# git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
# git clone --depth=1 https://github.com/destan19/OpenAppFilter package/OpenAppFilter
# git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata
# git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser luci-app-ssr-mudb-server
# git_sparse_clone openwrt-23.05 https://github.com/immortalwrt/luci applications/luci-app-eqos
# git_sparse_clone master https://github.com/syb999/openwrt-19.07.1 package/network/services/msd_lite

# 科学上网插件
git clone --depth=1 https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/luci-app-passwall
# git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/luci-app-passwall2
# git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

# rtp2httpd (IPTV 组播转 HTTP)
git clone --depth=1 https://github.com/stackia/rtp2httpd package/rtp2httpd

# SmartDNS
# git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# MosDNS
# git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

# Alist
# git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# iStore
# git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
# git_sparse_clone main https://github.com/linkease/istore luci

# 修改默认IP
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
# date_version=$(date +"%y.%m.%d")
# orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
# sed -i "s/${orig_version}/R${date_version} by emxiong/g" package/lean/default-settings/files/zzz-default-settings

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 启用 rtp2httpd (如果配置中未启用)
grep -q 'CONFIG_PACKAGE_luci-app-rtp2httpd=y' .config || echo 'CONFIG_PACKAGE_luci-app-rtp2httpd=y' >> .config

# ============================================
# 修正 opkg 源版本号 (LEDE 实际基于 OpenWrt 23.05 分支)
# 并清理不存在的第三方源
# ============================================
# 修改 version.mk 中的默认版本号为 23.05.6
sed -i 's/VERSION_NUMBER:=$(if $(VERSION_NUMBER),$(VERSION_NUMBER),24.10.3)/VERSION_NUMBER:=$(if $(VERSION_NUMBER),$(VERSION_NUMBER),23.05.6)/g' include/version.mk
sed -i 's|VERSION_REPO:=$(if $(VERSION_REPO),$(VERSION_REPO),https://downloads.openwrt.org/releases/24.10.3)|VERSION_REPO:=$(if $(VERSION_REPO),$(VERSION_REPO),https://downloads.openwrt.org/releases/23.05.6)|g' include/version.mk

# 同时修正 zzz-default-settings 中过时的 luci 版本号
sed -i "s|releases/18.06.9|releases/23.05.6|g" package/lean/default-settings/files/zzz-default-settings

# ============================================
# 修复 jdcloud_re-sp-01b 缺少 uimage-lzma-loader 导致无法生成 sysupgrade.bin
# 参考: lenovo_newifi-d1 等同类 MT7621 设备均包含此模板
# ============================================
sed -i '/define Device\/jdcloud_re-sp-01b/,/endef/{
  s/$(Device\/dsa-migration)/$(Device\/dsa-migration)\n  $(Device\/uimage-lzma-loader)/
}' target/linux/ramips/image/mt7621.mk

mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-clean-opkg-feeds << 'EOFSCRIPT'
#!/bin/sh
# 移除腾讯镜像中不存在的第三方源 (这些包已编译进固件)
sed -i '/kenzo/d' /etc/opkg/distfeeds.conf 2>/dev/null
sed -i '/small/d' /etc/opkg/distfeeds.conf 2>/dev/null
sed -i '/helloworld/d' /etc/opkg/distfeeds.conf 2>/dev/null
exit 0
EOFSCRIPT
chmod +x files/etc/uci-defaults/99-clean-opkg-feeds
