local hotupdate = "true"
_G.Remotehotupdate = hotupdate
if _G.Remotehotupdate == "false" then
    return _G.Remotehotupdate
end

function isNetworkAvailable()
    local connectivityManager = activity.getSystemService(Context.CONNECTIVITY_SERVICE)
    local activeNetwork = connectivityManager.getActiveNetworkInfo()
    return activeNetwork ~= nil and activeNetwork.isConnected()
end

Http.get(url1 .. "?t=" .. os.time(), nil, "UTF-8", headers, function(code, content)
    if code == 200 and content then
        version = content:match("推送版本号:%s*(.-)\n") or "未知"
        updateLog = content:match("更新内容：%s*(.-)\n?}%s*") or "获取失败..."
    end
end)

Http.get(url2 .. "?t=" .. os.time(), nil, "UTF-8", headers, function(code, content)
    if code == 200 and content then
        local pushNotification = content:match("推送通知:%s*(.-)\n") or "关"
        local menuTitle = content:match("菜单标题:%s*(.-)\n") or "信息通知"

        more.onClick = function()
            local pop = PopupMenu(activity, more)
            local menu = pop.Menu

            menu.add("清除数据").onMenuItemClick = function()
                local builder = AlertDialog.Builder(activity)
                builder.setTitle("注意")
                builder.setMessage("此操作会清除自身全部数据并退出！")
                builder.setPositiveButton("确定", function()
                    activity.finish()
                    if activity.getPackageName() ~= "net.fusionapp" then
                        os.execute("pm clear " .. activity.getPackageName())
                    end
                end)
                builder.setNegativeButton("取消", nil)
                builder.setCancelable(false)
                builder.show()
            end

            menu.add("应用过滤").onMenuItemClick = function()
                local targetPkg = " "
                local targetAct = " "
                local intent = Intent()
                intent.setClassName(targetPkg, targetAct)
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                local ok, err = pcall(function()
                    activity.startActivity(intent)
                end)
                if not ok then
                    local errorDialog = AlertDialog.Builder(activity)
                    errorDialog.setTitle("还没写好:)")
                    --errorDialog.setMessage("请检查目标应用是否已安装！\n\n错误详情: " .. tostring(err))
                    errorDialog.setPositiveButton("确定", nil)
                    errorDialog.setCancelable(false)
                    errorDialog.show()
                end
            end
            
            menu.add("磁贴设置").onMenuItemClick = function()
                local targetPkg = " "
                local targetAct = " "
                local intent = Intent()
                intent.setClassName(targetPkg, targetAct)
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                local ok, err = pcall(function()
                    activity.startActivity(intent)
                end)
                if not ok then
                    local errorDialog = AlertDialog.Builder(activity)
                    errorDialog.setTitle("还没写好:)")
                    --errorDialog.setMessage("请检查目标应用是否已安装！\n\n错误详情: " .. tostring(err))
                    errorDialog.setPositiveButton("确定", nil)
                    errorDialog.setCancelable(false)
                    errorDialog.show()
                end
            end

            menu.add("设置 URL").onMenuItemClick = function()
                local builder = AlertDialog.Builder(activity)
                builder.setTitle("设置URL")
                builder.setMessage("请输入要设置默认访问的链接：")
                local input = EditText(activity)
                input.setHint("http:// 或 https:// 开头...")
                builder.setView(input)
                builder.setPositiveButton("确定", function()
                    local url = input.getText().toString()
                    if url ~= "" and string.match(url, "^https?://[%w%._%-]+[%w%._%/?&%=%-]*") then
                        defaultUrl = url
                        webView.loadUrl(defaultUrl)
                        saveDefaultUrl(defaultUrl)
                    else
                        local errorDialog = AlertDialog.Builder(activity)
                        errorDialog.setTitle("错误")
                        errorDialog.setMessage("请输入有效的URL链接！")
                        errorDialog.setPositiveButton("确定", nil)
                        errorDialog.setCancelable(false)
                        errorDialog.show()
                    end
                end)
                builder.setNegativeButton("取消", nil)
                builder.setCancelable(false)
                builder.show()
            end

            menu.add("Ad 拦截测试").onMenuItemClick = function()
                webView.loadUrl("https://paileactivist.github.io/toolz/adblock.html")
            end

            menu.add("背景图床 URL").onMenuItemClick = function()
                local intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://pomf2.lain.la/"))
                activity.startActivity(intent)
                return true
            end

            menu.add("IP 检查").onMenuItemClick = function()
                local subPop = PopupMenu(activity, more)
                local subMenu = subPop.Menu
                subMenu.add("IPw.cn").onMenuItemClick = function()
                    webView.loadUrl("https://ipw.cn/")
                end
                subMenu.add("纯IPv6测试").onMenuItemClick = function()
                    webView.loadUrl("https://ipv6.test-ipv6.com/")
                end
                subMenu.add("网站延迟").onMenuItemClick = function()
                    webView.loadUrl("https://ip.skk.moe/simple")
                end
                subMenu.add("DNS泄露测试 (browserscan)").onMenuItemClick = function()
                    webView.loadUrl("https://www.browserscan.net/zh/dns-leak")
                end
                subMenu.add("DNS泄露测试 (Surfshark)").onMenuItemClick = function()
                    webView.loadUrl("https://surfshark.com/zh/dns-leak-test")
                end
                subPop.show()
            end

            menu.add("切换面板").onMenuItemClick = function()
                local subPop = PopupMenu(activity, more)
                local subMenu = subPop.Menu
                subMenu.add("Meta").onMenuItemClick = function()
                    local url = "https://metacubex.github.io/metacubexd/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(url)
                end
                subMenu.add("Yacd").onMenuItemClick = function()
                    local url = "https://yacd.mereith.com/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(url)
                end
                subMenu.add("Zash").onMenuItemClick = function()
                    local url = "https://board.zash.run.place/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(url)
                end
                subMenu.add("Local（本地端口）").onMenuItemClick = function()
                    local url = "http://127.0.0.1:9090/ui/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(url)
                end
                subPop.show()
            end

            local JSONObject = luajava.bindClass("org.json.JSONObject")

            local function showVersionInfo(updateTime)
                local layout = LinearLayout(activity)
                layout.setOrientation(1)
                layout.setPadding(60, 10, 60, 10)

                local function addStyledText(text, size, color, bold)
                    local tv = TextView(activity)
                    tv.setText(text)
                    tv.setTextSize(size)
                    tv.setTextColor(color)
                    tv.setTextIsSelectable(false)
                    if bold then tv.setTypeface(nil, Typeface.BOLD) end
                    layout.addView(tv)
                    return tv
                end

                addStyledText("Metadate", 18, 0xFF000000, true)
                addStyledText("Latestreleases " .. version, 15, 0xFF222222)
                addStyledText("Timestamp: " .. updateTime, 14, 0xFF444444)
                addStyledText("\n更新日志:", 16, 0xFF000000, true)

                local scrollView = ScrollView(activity)
                scrollView.setScrollbarFadingEnabled(false)
                scrollView.setScrollBarStyle(View.SCROLLBARS_OUTSIDE_INSET)
                scrollView.setPadding(20, 5, 20, 5)

                local logText = TextView(activity)
                logText.setText(updateLog)
                logText.setTextSize(13)
                logText.setTextColor(0xFF888888)
                logText.setPadding(0, 10, 0, 10)
                logText.setLineSpacing(1.5, 1)
                logText.setTextIsSelectable(true)
                scrollView.addView(logText)

                local dp = activity.getResources().getDisplayMetrics().density
                local layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, math.floor(200 * dp + 0.5))
                scrollView.setLayoutParams(layoutParams)
                layout.addView(scrollView)

                local builder = AlertDialog.Builder(activity)
                builder.setView(layout)
                builder.setNegativeButton("GitHub", nil)
                builder.setPositiveButton("Telegram", nil)
                builder.setNeutralButton("取消", nil)
                builder.setCancelable(false)
                local dialog = builder.show()

                dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setAllCaps(false)
                dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setOnClickListener(View.OnClickListener{
                    onClick = function()
                        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/GitMetaio/Surfing")))
                    end
                })

                dialog.getButton(AlertDialog.BUTTON_POSITIVE).setAllCaps(false)
                dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(View.OnClickListener{
                    onClick = function()
                        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://t.me/+vvlXyWYl6HowMTBl")))
                    end
                })

                dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setAllCaps(false)

                addStyledText("\nAPI ip.sb", 14, 0xFF444444)
                local timezoneTv = addStyledText("获取中...", 14, 0xFF444444)
                local ispTv = addStyledText("获取中...", 14, 0xFF444444)
                local asnTv = addStyledText("ASN: 正在检测...", 14, 0xFF444444)
                local ipv4Tv = addStyledText("IPv4: 正在检测...", 14, 0xFF444444)
                local ipv6Tv = addStyledText("IPv6: 正在检测...", 14, 0xFF444444)
                
                Http.get("https://api-ipv4.ip.sb/geoip", nil, "UTF-8", headers, function(code, content)
                    if code == 200 and content then
                        local ok, obj = pcall(function() return JSONObject(content) end)
                        if ok then
                            local tz = obj.optString("timezone", "")
                            if tz ~= "" then
                                timezoneTv.setText(tz)
                            else
                                timezoneTv.setText("获取失败...")
                            end
                
                            local isp = obj.optString("isp", "")
                            if isp ~= "" then
                                ispTv.setText(isp)
                            else
                                ispTv.setText("获取失败...")
                            end
                
                            asnTv.setText("ASN: " .. obj.optInt("asn", 0))
                            ipv4Tv.setText("IPv4: " .. obj.optString("ip", "获取失败..."))
                        else
                            timezoneTv.setText("获取失败...")
                            ispTv.setText("获取失败..." )
                            asnTv.setText("ASN: 获取失败...")
                            ipv4Tv.setText("IPv4: 获取失败...")
                        end
                    else
                        timezoneTv.setText("获取失败...")
                        ispTv.setText("获取失败...")
                        asnTv.setText("ASN: 获取失败...")
                        ipv4Tv.setText("IPv4: 获取失败...")
                    end
                end)
                
                Http.get("https://api-ipv6.ip.sb/geoip", nil, "UTF-8", headers, function(code, content)
                    local ipV6Text = "IPv6: 当前节点不支持..."
                    if code == 200 and content and content:match("%S") then
                        local ok, objV6 = pcall(function() return JSONObject(content) end)
                        if ok then
                            local ip = objV6.optString("ip", "")
                            if ip ~= "" then ipV6Text = "IPv6: " .. ip end
                        end
                    end
                    ipv6Tv.setText(ipV6Text)
                end)
                
                addStyledText("\n@Surfing WebApp 2023.", 14, 0xFF444444)
            end

            local function getLastCommitTime()
                Http.get(url .. "?t=" .. os.time(), nil, "UTF-8", headers, function(code, content)
                    if code == 200 and content then
                        local commitDate = content:match('"date"%s*:%s*"([^"]+)"')
                        if commitDate then
                            commitDate = commitDate:gsub("T", " "):gsub("Z", "")
                            local timestamp = os.time({
                                year = tonumber(commitDate:sub(1, 4)),
                                month = tonumber(commitDate:sub(6, 7)),
                                day = tonumber(commitDate:sub(9, 10)),
                                hour = tonumber(commitDate:sub(12, 13)),
                                min = tonumber(commitDate:sub(15, 16)),
                                sec = tonumber(commitDate:sub(18, 19))
                            }) + 8 * 3600
                            showVersionInfo(os.date("%Y-%m-%d %H:%M:%S", timestamp))
                        else
                            showVersionInfo("获取失败！")
                        end
                    else
                        showVersionInfo("获取失败，错误码：" .. tostring(code))
                    end
                end)
            end

            menu.add("元数据").onMenuItemClick = function()
                if isNetworkAvailable() then
                    getLastCommitTime()
                else
                    Toast.makeText(activity, "当前网络不可用！", 0).show()
                end
            end

            menu.add("更新 WebView").onMenuItemClick = function()
                activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.webview")))
            end

            menu.add("点我闪退(Exit)").onMenuItemClick = function()
                activity.finish()
                os.exit(0)
            end

            if pushNotification == "开" then
                menu.add(menuTitle).onMenuItemClick = function()
                    Toast.makeText(activity, "正在拉取中...", Toast.LENGTH_SHORT).show()
                    Handler().postDelayed(function()
                        loadInfo(content)
                    end, 2700)
                end
            end

            pop.show()
        end
    end
end)

return _G.Remotehotupdate