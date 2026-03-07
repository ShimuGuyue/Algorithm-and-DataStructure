#!/bin/bash

# 1. 切换到脚本所在目录
cd "$(dirname "$0")"

# 2. 遇到错误即停止
set -e

# 定义颜色代码
CYAN='\033[0;36m'       # 青色
GREEN='\033[0;32m'      # 绿色
RED='\033[0;31m'        # 红色
GRAY='\033[0;90m'       # 灰色
MAGENTA='\033[0;35m'    # 洋红色
NC='\033[0m'            # 重置颜色

echo -e "${GRAY}--- [子项目同步] 当前目录: $(pwd) ---${NC}"

# 3. 强制刷新子仓库远程信息
echo -e "${CYAN}正在获取远程更新 (Fetch)...${NC}"
git fetch --all --prune

# 4. 暂存本地改动
echo -e "${CYAN}正在暂存本地未提交的修改...${NC}"
git stash

# 5. 拉取最新代码
echo -e "${CYAN}正在从 origin main 分支拉取代码...${NC}"
if git pull origin main; then
    echo -e "${GREEN}子仓库代码拉取成功！${NC}"
else
    echo -e "${RED}拉取失败！请检查该目录是否为 Git 仓库或网络是否通畅。${NC}"
    exit 1
fi

# 6. 恢复本地改动
echo -e "${CYAN}正在恢复之前的本地修改...${NC}"
if [[ -n $(git stash list) ]]; then
    if git stash pop; then
        echo -e "${GREEN}本地修改已成功恢复。${NC}"
    else
        echo -e "${RED}恢复修改时发生冲突，请手动解决。${NC}"
        exit 1
    fi
else
    echo -e "${GRAY}没有需要恢复的本地修改。${NC}"
fi

echo -e "\n${MAGENTA}--- 子项目同步完成 ---${NC}"