#!/bin/bash

export TZ="Asia/Shanghai"
export LC_COLLATE=C
#切换到当前脚本目录
cd `dirname $0`

#设置出现错误继续执行后续命令
set +e
#删除旧的重新创建
rm README.md && touch README.md

#写入标题目录
echo -e "# 服务状态\n" | tee -a README.md >/dev/null 2>&1
echo -e "![](https://pgy.us.kg/?id=svg)![](http://s4.serv00.com:8828/?id=svg)![](https://pgy.us.kg/?id=ua)<p><img src="http://ip.cnqq.cloudns.ch/" width="400" onerror=\"this.style.display='none';\"></p>\n | tee -a README.md >/dev/null 2>&1
# 查找当前目录下是否有 .txt 文件
txt_files=$(ls *.txt 2>/dev/null)
# 如果没有 .txt 文件，输出 "no" 并退出
if [ -z "$txt_files" ]; then
  echo "" | tee -a README.md 
  echo "**⚠️ 当前目录未发现记录服务的 \`.txt\` 文件，请按以下格式创建以 \`服务名称.txt\` 的文件**" | tee -a README.md
  echo -e "\n\`\`\`sh" | tee -a README.md
  echo "# 下面六个是按空格进行分割的,每个选项内不能出现空格，脚本会排除#开头和空白行，协议支持 tcp ws wss http https" | tee -a README.md
  echo -e "# ①服务名称 ②协议 ③服务器地址 ④端口(可留空)  ⑤备注信息(可留空)  ⑥IPV4/IPV6(可留空) \n " | tee -a README.md
  echo "测试名 tcp 120.12.12.12 11010 广东阿里云  ipv4 " | tee -a README.md
  echo -e "\`\`\`\n效果如下:\n" | tee -a README.md
  echo "|服务名称|协议|服务器地址|端口|备注信息|IPV4/IPV6|**状态**|历史状态|" |tee -a README.md
  echo "|--|--|--|--|--|--|--|--|" |tee -a README.md 
  echo "|测试名|tcp|120.12.12.12|11010|广东阿里云|ipv4|正常✅|🟩(100%)|" |tee -a README.md 
  exit 1
fi
echo -e "<details> <summary>目录</summary>\n" | tee -a README.md >/dev/null 2>&1
# 遍历当前目录下所有 .txt 后缀文件设置标题目录
for filename in *.txt; do
  base_filename=$(basename "$filename" .txt)
  echo -e "- [$base_filename](#$base_filename)\n" |tee -a README.md >/dev/null 2>&1
done
echo -e "</details>\n" | tee -a README.md >/dev/null 2>&1

# 遍历当前目录下所有 .txt 后缀文件设置服务标题
for filename in *.txt; do
  base_filename=$(basename "$filename" .txt)
  echo -e "-----\n" | tee -a README.md >/dev/null 2>&1
  echo -e "## $base_filename \n" | tee -a README.md >/dev/null 2>&1
  echo -e "> 更新时间：**$(date '+%Y年%m月%d日 %H:%M:%S')**\n" | tee -a README.md >/dev/null 2>&1
  echo "<details> <summary>点击查看</summary>" | tee -a README.md >/dev/null 2>&1
  echo "" | tee -a README.md >/dev/null 2>&1
  echo "|服务名称|协议|服务器地址|端口|备注信息|IPV4/IPV6|**状态**|历史状态|" |tee -a README.md >/dev/null 2>&1
  echo "|--|--|--|--|--|--|--|--|" |tee -a README.md >/dev/null 2>&1

  # 读取 .txt 文件并遍历每一行
  awk '{print $0}' $filename | while IFS=' ' read -r name protocol address port region ipv; do
    # 排除以 # 开头的行和空行
    if [[ -z "$name" || "$name" =~ ^# ]]; then
      continue  # 如果是空行或以 # 开头的行，跳过当前循环
    fi
    # 判断 $4 是否是端口（检查是否为纯数字且范围在 1-65535）
    if [[ ! "$port" =~ ^[0-9]+$ || "$port" -lt 1 || "$port" -gt 65535 ]]; then
      ipv="$region"    # 将 $5 的值赋给 $6
      region="$port"   # 将 $4 的值赋给 $5
      port=""          # 将 $5 清空
    fi
    # 判断是否需要填充地区信息
    if [[ -z "$ipv" && "$region" =~ ^(V4|v4|IPv4|v4/v6|ipv4|ipv4/ipv6|v6|IPv6|ipv6|v4/v6|ipv4/v6)$ ]]; then
      # 如果 $6 为空且 $5 中包含 IPV4/IPV6 标识，认为备注信息为空
      ipv="$region"   # 将 $5 的值赋给 $6，即标识 IP 类型
      region=""       # 将备注信息清空
    fi
          # 判断协议类型
          if [[ "$protocol" == "HTTP" || "$protocol" == "http" || "$protocol" == "HTTPS" || "$protocol" == "https" ]]; then
              # 测试 HTTP/HTTPS 连接是否正常
              if [[ "$port" != "" ]]; then
                  # 如果有端口号，则添加端口
                  response_code=$(curl -Lks -w "%{http_code}" -o /dev/null "$protocol://$address:$port")
                  name="[$name](${protocol}://${address}:${port})"
              else
                  # 没有端口号，直接使用默认端口
                  response_code=$(curl -Lks -w "%{http_code}" -o /dev/null "$protocol://$address")
                  name="[$name](${protocol}://${address})"
              fi
        
              if [[ "$response_code" -eq 200 ]]; then
                  status="正常✅"
              else
                  status="离线❌"
              fi
          elif [[ "$protocol" == "TCP" || "$protocol" == "tcp" || "$protocol" == "ws" || "$protocol" == "WS" || "$protocol" == "WSS" || "$protocol" == "wss" ]]; then
              # TCP协议
              #如果是嵌入式设备 如路由器 nc是阉割版的 改用 socat 命令 ：socat -v TCP4:"$address:$port,connect-timeout=3" /dev/null &>/dev/null
              nc -v -w 3 -z "$address" "$port" &>/dev/null
              if [[ $? -eq 0 ]]; then
                  status="正常✅"
              else
                  status="离线❌"
              fi
          else
              status="未知⚠️"
          fi

          # 更新历史记录文件
          [ ! -d "history/${base_filename}" ] && mkdir -p history/${base_filename}
          history_file="history/${base_filename}/${protocol}-${address}-${port}.txt"
	        history_f="/tmp/${protocol}-${address}-${port}.txt"
          [ ! -f "$history_file" ] && touch "$history_file"
          echo "$(date '+%Y年%m月%d日 %H:%M:%S')： $status" >> "$history_file"
          # 获取文件行数
	        line_count=$(wc -l < "$history_file")
          if [ "$line_count" -gt 100 ]; then
    	        # 如果文件行数大于 100，则只保留最近 100 行
    		      tail -n 100 "$history_file" > "$history_file.temp" && mv "$history_file.temp" "$history_file"
	        fi
	        if [ "$line_count" -gt 10 ]; then
    	        # 取最近 10 行计算
    		      tail -n 10 "$history_file" > "$history_f"
              # 生成历史状态显示
              history_status=$(tail -n 10 "$history_f" | awk '{if($3=="正常✅") printf "🟩"; else if($3=="未知⚠️") printf "🟨"; else printf "🟥"}')
          else
              # 生成历史状态显示
              history_status=$(tail -n "$line_count" "$history_file" | awk '{if($3=="正常✅") printf "🟩"; else if($3=="未知⚠️") printf "🟨"; else printf "🟥"}')
	        fi

          green_count=$(echo "$history_status" | grep -o "🟩" | wc -l)
          total_count=$(echo "$history_status" | wc -c)
	        total_count=$((total_count / 4))
          percentage=$((green_count * 100 / total_count))

          if [[ "$status" = "正常✅" || "$status" = "未知⚠️" ]] ; then
			if [[ "$protocol" = "http" || "$protocol" = "https" || "$protocol" = "HTTP" || "$protocol" = "HTTPS" ]] ; then
				status="[$status](https://urlscan.io/liveshot/?width=1024&height=768&url=$URL)"
		fi
            echo "|$name|$protocol|$address|$port|$region|$ipv|$status|[${history_status}]($history_file) $percentage%|" |tee -a README.md >/dev/null 2>&1
          else 
            echo "|$name|<span style="color:red">$protocol</span>|<span style="color:red">$address</span>|<span style="color:red">$port</span>|<span style="color:red">$region</span>|<span style="color:red">$ipv</span>|<span style="color:red">离线</span>❌|[${history_status}]($history_file) <span style="color:red">$percentage%</span>|" | tee -a README.md >/dev/null 2>&1
          fi
          done
    echo -e "</details>\n" | tee -a README.md >/dev/null 2>&1
done

echo "执行完成"
