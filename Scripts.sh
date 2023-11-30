#!/system/bin/sh
MODDIR=${0%/*}
# 此脚本将在设备启动时执行

##############
# 基础设置
##############

# 设置开机后需要设置的DPI
TARGET_DPI=480

##############
# 进阶设置
##############

# 检查 DPI 是否与目标值匹配
check_dpi() {
    dpi_output=$(wm density)
    PHYSICAL_DPI=$(echo "$dpi_output" | grep 'Physical density:' | awk '{print $3}' | tr -dc '0-9')
    OVERRIDE_DPI=$(echo "$dpi_output" | grep 'Override density:' | awk '{print $3}' | tr -dc '0-9')
    [ -z "$OVERRIDE_DPI" ] && OVERRIDE_DPI=$PHYSICAL_DPI
    [ "$OVERRIDE_DPI" -ne "$TARGET_DPI" ]
}

# 检查系统是否已启动和屏幕是否已解锁
check_status() {
    dumpsys_output=$(dumpsys window policy)
    system_ready=$(echo "$dumpsys_output" | grep "systemIsReady=true")
    screen_unlocked=$(echo "$dumpsys_output" | grep "mIsShowing=false")
    [ -n "$system_ready" ] && [ -n "$screen_unlocked" ]
}

# 设置 DPI 为设定值
set_dpi() {
    wm density $TARGET_DPI
}

# 初始化
already_set_dpi=1
count=0

while true; do
    if check_status; then
        if check_dpi; then
            set_dpi
            already_set_dpi=0
            count=0
        elif [ $already_set_dpi -eq 0 ]; then
            count=$((count + 1))
            if [ $count -ge 600 ]; then
                break
            fi
            sleep 1
        fi
    elif ! check_status && ! check_dpi && [ $already_set_dpi -eq 1 ]; then
        continue
    fi
done
