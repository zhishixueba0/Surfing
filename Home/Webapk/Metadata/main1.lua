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
function openSurfingTile(activityName)
    local targetPkg = "com.surfing.tile"
    local targetAct = targetPkg .. ".ui." .. activityName

    local intent = Intent()
    intent.setClassName(targetPkg, targetAct)
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    local ok = pcall(function()
        activity.startActivity(intent)
    end)  
    if not ok then
        Toast.makeText(activity,
            "当前组件未安装\n群组内测中...",
            Toast.LENGTH_SHORT).show()
    end
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
                
                local themedContext, DLG_BG_COLOR, DLG_TEXT_COLOR, DLG_MESSAGE_COLOR, BTN_COLOR = getDialogThemeContext()
                local function dp2px(dp) return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, activity.getResources().getDisplayMetrics()) end

                menu.add("外部打开").onMenuItemClick = function()
                    local currentUrl = webView.getUrl()
                    if currentUrl and currentUrl:match("^https?://") then
                        local intent = Intent(Intent.ACTION_VIEW, Uri.parse(currentUrl))
                        local ok, err = pcall(function()
                            activity.startActivity(intent)
                        end)
                        if not ok then
                            Toast.makeText(activity, "Error：" .. tostring(err), Toast.LENGTH_LONG).show()
                        end
                    else
                        Toast.makeText(activity, "当前URL无效或非HTTP/HTTPS协议", Toast.LENGTH_SHORT).show()
                    end
                end

                menu.add("网络过滤").onMenuItemClick = function()
                    openSurfingTile("NetworkFilterActivity")
                end           
                menu.add("应用过滤").onMenuItemClick = function()
                    openSurfingTile("AppFilterActivity")
                end             
                menu.add("配置覆写").onMenuItemClick = function()
                    openSurfingTile("ClashConfigActivity")
                end
                menu.add("磁贴设置").onMenuItemClick = function()
                    openSurfingTile("ApiSettingsActivity")
                end

                menu.add("主页设置").onMenuItemClick = function()
                    local customLayout = LinearLayout(themedContext)
                    customLayout.setOrientation(LinearLayout.VERTICAL)
                    customLayout.setPadding(dp2px(20), dp2px(20), dp2px(20), dp2px(0))
                    
                    local titleTV = TextView(themedContext)
                    titleTV.setText("设置URL")
                    titleTV.setTextSize(20)
                    titleTV.setTextColor(DLG_TEXT_COLOR)
                    titleTV.setTypeface(nil, Typeface.BOLD)
                    customLayout.addView(titleTV)
                    
                    local messageTV = TextView(themedContext)
                    messageTV.setText("请输入要设置默认访问的链接：")
                    messageTV.setTextSize(16)
                    messageTV.setTextColor(DLG_MESSAGE_COLOR)
                    messageTV.setPadding(0, dp2px(15), 0, dp2px(10))
                    customLayout.addView(messageTV)
                    
                    local INPUT_BG_COLOR = isCurrentThemeDark() and 0xFF3D3D3D or 0xFFF0F0F0
                    
                    local inputBg = GradientDrawable()
                    inputBg.setColor(INPUT_BG_COLOR)
                    inputBg.setCornerRadius(dp2px(8))
                    
                    local input = EditText(themedContext)
                    input.setHint("http:// 或 https:// 开头...")
                    input.setTextColor(DLG_TEXT_COLOR)
                    input.setHintTextColor(DLG_MESSAGE_COLOR)
                    input.setSingleLine(true)
                    input.setPadding(dp2px(10), dp2px(10), dp2px(10), dp2px(10)) 
                    input.setBackground(inputBg)
                    
                    local inputContainer = LinearLayout(themedContext)
                    inputContainer.setPadding(0, dp2px(5), 0, dp2px(20))
                    inputContainer.addView(input, LinearLayout.LayoutParams(-1, -2))
                    customLayout.addView(inputContainer)
                    
                    local builder = AlertDialog.Builder(themedContext)
                        .setView(customLayout)
                        .setPositiveButton("确定", function()
                            local url = input.getText().toString()
                            if url ~= "" and string.match(url, "^https?://[%w%._%-]+[%w%._%/?&%=%-]*") then
                                defaultUrl = url
                                webView.loadUrl(defaultUrl)
                                saveDefaultUrl(defaultUrl)
                            else
                                local errorLayout = LinearLayout(themedContext)
                                errorLayout.setOrientation(LinearLayout.VERTICAL)
                                errorLayout.setPadding(dp2px(20), dp2px(20), dp2px(20), dp2px(0))
                                
                                local errTitle = TextView(themedContext)
                                errTitle.setText("错误")
                                errTitle.setTextSize(20)
                                errTitle.setTextColor(DLG_TEXT_COLOR)
                                errTitle.setTypeface(nil, Typeface.BOLD)
                                errorLayout.addView(errTitle)
                                
                                local errMsg = TextView(themedContext)
                                errMsg.setText("请输入有效的URL链接！")
                                errMsg.setTextSize(16)
                                errMsg.setTextColor(DLG_MESSAGE_COLOR)
                                errMsg.setPadding(0, dp2px(15), 0, dp2px(10))
                                errorLayout.addView(errMsg)
                                
                                local errorDialog = AlertDialog.Builder(themedContext)
                                    .setView(errorLayout)
                                    .setPositiveButton("确定", nil)
                                    .setCancelable(false)
                                local dialog = errorDialog.create()
                                dialog.show()

                                local window = dialog.getWindow()
                                local bg = GradientDrawable()
                                bg.setColor(DLG_BG_COLOR)
                                bg.setCornerRadius(dp2px(15))
                                window.setBackgroundDrawable(bg)
                                dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(BTN_COLOR)
                            end
                        end)
                        .setNegativeButton("取消", nil)
                        .setCancelable(false)
                        
                    local dialog = builder.create()
                    dialog.show()

                    local window = dialog.getWindow()
                    local bg = GradientDrawable()
                    bg.setColor(DLG_BG_COLOR)
                    bg.setCornerRadius(dp2px(15))
                    window.setBackgroundDrawable(bg)
                    
                    dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(BTN_COLOR)
                    dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(BTN_COLOR)
                end

                menu.add("图床 URL").onMenuItemClick = function()
                    local intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://pomf2.lain.la/"))
                    activity.startActivity(intent)
                    return true
                end

                local function showVersionInfo(updateTime)
                    local themedContext, DLG_BG_COLOR, DLG_TEXT_COLOR, DLG_MESSAGE_COLOR, BTN_COLOR = getDialogThemeContext() 

                    local ViewGroup = import "android.view.ViewGroup"
                    local TypedValue = import "android.util.TypedValue"

                    local function dp2px(dp)
                        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, activity.getResources().getDisplayMetrics())
                    end
                    
                    local layout = LinearLayout(themedContext)
                    layout.setOrientation(1)
                    layout.setPadding(dp2px(20), dp2px(10), dp2px(20), dp2px(10)) 
                
                    local function addStyledText(text, size, color, bold)
                        local tv = TextView(themedContext)
                        tv.setText(text)
                        tv.setTextSize(size)
                        tv.setTextColor(color)
                        tv.setTextIsSelectable(false)
                        if bold then tv.setTypeface(nil, Typeface.BOLD) end
                        layout.addView(tv)
                        return tv
                    end
                
                    addStyledText("Metadate", 18, DLG_TEXT_COLOR, true)
                    addStyledText("Latestreleases " .. version, 15, DLG_MESSAGE_COLOR)
                    addStyledText("Timestamp: " .. updateTime, 14, DLG_MESSAGE_COLOR)
                    addStyledText("\n更新日志:", 16, DLG_TEXT_COLOR, true)
                
                    local LOG_BG_COLOR = isCurrentThemeDark() and 0xFF222222 or 0xFFF8F8F8
                    
                    local logArea = LinearLayout(themedContext)
                    logArea.setOrientation(1)
                    
                    local logAreaBg = GradientDrawable()
                    logAreaBg.setColor(LOG_BG_COLOR)
                    logAreaBg.setCornerRadius(dp2px(8))
                    logArea.setBackground(logAreaBg)
                    logArea.setPadding(dp2px(10), dp2px(10), dp2px(10), dp2px(10)) 
                    
                    local logContainerParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp2px(220))
                    logContainerParams.setMargins(0, dp2px(10), 0, dp2px(10))
                    logArea.setLayoutParams(logContainerParams)

                    local scrollView = ScrollView(themedContext)
                    scrollView.setScrollbarFadingEnabled(false)
                    scrollView.setScrollBarStyle(View.SCROLLBARS_OUTSIDE_INSET)
                    
                    local logText = TextView(themedContext)
                    logText.setText(updateLog)
                    logText.setTextSize(13)
                    logText.setTextColor(DLG_MESSAGE_COLOR)
                    logText.setLineSpacing(1.5, 1)
                    logText.setTextIsSelectable(true)
                    
                    scrollView.addView(logText)
                    logArea.addView(scrollView)
                    layout.addView(logArea)
                
                    local builder = AlertDialog.Builder(themedContext)
                    builder.setView(layout)
                    builder.setNegativeButton("GitHub", nil)
                    builder.setPositiveButton("Telegram", nil)
                    builder.setNeutralButton("取消", nil)
                    builder.setCancelable(false)
                    local dialog = builder.show()
                    
                    local window = dialog.getWindow()
                    local bg = GradientDrawable()
                    bg.setColor(DLG_BG_COLOR)
                    bg.setCornerRadius(dp2px(15))
                    window.setBackgroundDrawable(bg)
                    window.getDecorView().setPadding(dp2px(10), dp2px(10), dp2px(10), dp2px(10))

                    dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setAllCaps(false)
                    dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(BTN_COLOR)
                    dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setOnClickListener(View.OnClickListener{
                        onClick = function()
                            activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/GitMetaio/Surfing")))
                        end
                    })
                
                    dialog.getButton(AlertDialog.BUTTON_POSITIVE).setAllCaps(false)
                    dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(BTN_COLOR)
                    dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(View.OnClickListener{
                        onClick = function()
                            activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://t.me/+vvlXyWYl6HowMTBl")))
                        end
                    })
                
                    dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setAllCaps(false)
                    dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setTextColor(BTN_COLOR)

                    addStyledText("\nAPI ip.sb", 14, DLG_MESSAGE_COLOR)
                    local timezoneTv = addStyledText("获取中...", 14, DLG_MESSAGE_COLOR)
                    local ispTv = addStyledText("获取中...", 14, DLG_MESSAGE_COLOR)
                    local asnTv = addStyledText("ASN: 正在检测...", 14, DLG_MESSAGE_COLOR)
                    local ipv4Tv = addStyledText("IPv4: 正在检测...", 14, DLG_MESSAGE_COLOR)
                    local ipv6Tv = addStyledText("IPv6: 正在检测...", 14, DLG_MESSAGE_COLOR)
                    
                    Http.get("https://api-ipv4.ip.sb/geoip", nil, "UTF-8", headers, function(code, content)
                        if code == 200 and content then
                            local ok, obj = pcall(function() return JSONObject(content) end)
                            if ok then
                                local tz = obj.optString("timezone", "")
                                if tz ~= "" then timezoneTv.setText(tz) else timezoneTv.setText("获取失败...") end
                                local isp = obj.optString("isp", "")
                                if isp ~= "" then ispTv.setText(isp) else ispTv.setText("获取失败...") end
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
                    addStyledText("\n@Surfing WebApp 2023.", 14, DLG_MESSAGE_COLOR)
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

                menu.add("更新 View").onMenuItemClick = function()
                    activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.webview")))
                end

                menu.add("版本信息").onMenuItemClick = function()
                    if isNetworkAvailable() then
                        getLastCommitTime()
                    else
                        Toast.makeText(activity, "当前网络不可用！", 0).show()
                    end
                end

                menu.add("更多选项").onMenuItemClick = function()
                    local subPop = PopupMenu(activity, more)
                    local subMenu = subPop.Menu
                    
                    subMenu.add("清除数据").onMenuItemClick = function()
                        local dataPop = PopupMenu(activity, more)
                        local dataMenu = dataPop.Menu
                        
                        dataMenu.add("清除程序数据").onMenuItemClick = function()
                            local customLayout = LinearLayout(themedContext)
                            customLayout.setOrientation(LinearLayout.VERTICAL)
                            customLayout.setPadding(dp2px(20), dp2px(20), dp2px(20), dp2px(0))
                            
                            local titleTV = TextView(themedContext)
                            titleTV.setText("注意")
                            titleTV.setTextSize(20)
                            titleTV.setTextColor(DLG_TEXT_COLOR)
                            titleTV.setTypeface(nil, Typeface.BOLD)
                            customLayout.addView(titleTV)
                            
                            local messageTV = TextView(themedContext)
                            messageTV.setText("此操作会清除自身全部数据并退出！")
                            messageTV.setTextSize(16)
                            messageTV.setTextColor(DLG_MESSAGE_COLOR)
                            messageTV.setPadding(0, dp2px(15), 0, dp2px(10))
                            customLayout.addView(messageTV)
                    
                            local builder = AlertDialog.Builder(themedContext)
                                .setView(customLayout)
                                .setPositiveButton("确定", function()
                                    activity.finish()
                                    os.execute("pm clear " .. activity.getPackageName())
                                end)
                                .setNegativeButton("取消", nil)
                                .setCancelable(false)
                    
                            local dialog = builder.create()
                            dialog.show()
                    
                            local window = dialog.getWindow()
                            local bg = GradientDrawable()
                            bg.setColor(DLG_BG_COLOR)
                            bg.setCornerRadius(dp2px(15))
                            window.setBackgroundDrawable(bg)
                    
                            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(BTN_COLOR)
                            dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(BTN_COLOR)
                        end

                        dataMenu.add("清除网站数据").onMenuItemClick = function()
                            local currentUrl = webView.getUrl() or ""
                            local currentOrigin = currentUrl:match("^(https?://[^\n/]+)") or "未知网站"
                            
                            local customLayout = LinearLayout(themedContext)
                            customLayout.setOrientation(LinearLayout.VERTICAL)
                            customLayout.setPadding(dp2px(20), dp2px(20), dp2px(20), dp2px(0))
                            
                            local titleTV = TextView(themedContext)
                            titleTV.setText("清除当前网站数据")
                            titleTV.setTextSize(20)
                            titleTV.setTextColor(DLG_TEXT_COLOR)
                            titleTV.setTypeface(nil, Typeface.BOLD)
                            customLayout.addView(titleTV)
                            
                            local messageTV = TextView(themedContext)
                            messageTV.setText(
                                "确定要清除 [" .. currentOrigin .. "] 的以下数据吗？\n\n" ..
                                "1. 当前网站的缓存文件\n" ..
                                "2. 当前网站的本地存储 (Local Storage)\n\n" ..
                                "注意：Cookie 不会被清除"
                            )
                            messageTV.setTextSize(16)
                            messageTV.setTextColor(DLG_MESSAGE_COLOR)
                            messageTV.setPadding(0, dp2px(15), 0, dp2px(10))
                            customLayout.addView(messageTV)
                        
                            local builder = AlertDialog.Builder(themedContext)
                                .setView(customLayout)
                                .setPositiveButton("确定", function()
                                    webView.clearCache(true) 
                                    
                                    local jsToClearStorage = "localStorage.clear();"
                                    
                                    if webView.evaluateJavascript then
                                        webView.evaluateJavascript(jsToClearStorage, nil)
                                    else
                                        webView.loadUrl("javascript:" .. jsToClearStorage)
                                    end
                                    
                                    webView.reload()
                                    
                                    Toast.makeText(activity, "清除完毕", Toast.LENGTH_LONG).show()
                                end)
                                .setNegativeButton("取消", nil)
                                .setCancelable(false) 
                        
                            local dialog = builder.create()
                            dialog.show()
                            
                            dialog.setCanceledOnTouchOutside(false)
                        
                            local window = dialog.getWindow()
                            local bg = GradientDrawable()
                            bg.setColor(DLG_BG_COLOR)
                            bg.setCornerRadius(dp2px(15))
                            window.setBackgroundDrawable(bg)
                        
                            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(BTN_COLOR)
                            dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(BTN_COLOR)
                        end
                        dataPop.show()
                    end

                    subMenu.add("切换面板").onMenuItemClick = function()
                        local panelPop = PopupMenu(activity, more)
                        local panelMenu = panelPop.Menu
                        panelMenu.add("Meta").onMenuItemClick = function()
                            local url = "https://metacubex.github.io/metacubexd/#/proxies"
                            webView.loadUrl(url)
                            defaultUrl = url
                            saveDefaultUrl(url)
                        end
                        panelMenu.add("Yacd").onMenuItemClick = function()
                            local url = "https://yacd.metacubex.one/#/proxies"
                            webView.loadUrl(url)
                            defaultUrl = url
                            saveDefaultUrl(url)
                        end
                        panelMenu.add("Zash").onMenuItemClick = function()
                            local url = "https://board.zash.run.place/#/proxies"
                            webView.loadUrl(url)
                            defaultUrl = url
                            saveDefaultUrl(url)
                        end
                        panelMenu.add("Local（本地端口）").onMenuItemClick = function()
                            local url = "http://127.0.0.1:9090/ui/#/proxies"
                            webView.loadUrl(url)
                            defaultUrl = url
                            saveDefaultUrl(url)
                        end
                        panelPop.show()
                    end

                    subMenu.add("IP 属性").onMenuItemClick = function()
                        local ipPop = PopupMenu(activity, more)
                        local ipMenu = ipPop.Menu
                        ipMenu.add("IPw.cn").onMenuItemClick = function()
                            webView.loadUrl("https://ipw.cn/")
                        end
                        ipMenu.add("纯IPv6测试").onMenuItemClick = function()
                            webView.loadUrl("https://ipv6.test-ipv6.com/")
                        end
                        ipMenu.add("网站延迟").onMenuItemClick = function()
                            webView.loadUrl("https://ip.skk.moe/simple")
                        end
                        ipMenu.add("DNS泄露测试 (browserscan)").onMenuItemClick = function()
                            webView.loadUrl("https://www.browserscan.net/zh/dns-leak")
                        end
                        ipMenu.add("DNS泄露测试 (Surfshark)").onMenuItemClick = function()
                            webView.loadUrl("https://surfshark.com/zh/dns-leak-test")
                        end
                        ipPop.show()
                    end

                    subMenu.add("广告拦截测试").onMenuItemClick = function()
                        webView.loadUrl("https://paileactivist.github.io/toolz/adblock.html")
                    end

                    subPop.show()
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

SURFING_QUOTES = {
  "听见你笑是我最大的幸福。",
  "晚安，做个好梦。",
  "每个清晨都和你说早安。",
  "遇见你，是我最美的运气。",
  "有我在，冬天也暖。",
  "牵着手就不怕冷了。",
  "记得多喝水，别忘了保暖。",
  "愿你被世界温柔以待。",
  "早安，亲爱的！",
  "喜欢你，小暖暖 ❤️ 春暖花开。",
  "冬日的阳光也温暖不了我的心，除了你。",
  "愿你在寒冷里拥有温暖的拥抱。",
  "每一片雪花都是我对你的思念。",
  "愿你的笑容，像冬日的阳光一样灿烂。",
  "不管天气多冷，我的心永远为你而暖。",
  "冬天的夜晚，记得给自己一个热茶和温柔。",
  "愿你被世界温柔以待，也温柔待自己。",
  "每一个平凡的日子，因为有你而闪光。",
  "愿你在这个冬天，收获小小的幸福感。",
  "陪伴是最长情的告白，即使在寒冷的冬天。",
  "愿你眼中有光，心中有暖，笑容常在。",
  "冬天再长，也挡不住温暖的心意。",
  "雪花落下的地方，也有我悄悄的祝福。",
  "愿你的日子如暖阳般温暖，充满希望。",
  "寒冷的冬天，有人陪伴就是最好的礼物。",
  "心里有你，四季皆暖。",
  "愿你每天醒来，都能感受到温暖的阳光。",
  "不惧风雪，因为有你在我心里。",
  "愿你的笑容，驱散所有寒意。",
  "在冬日里，我只希望你幸福安康。",
  "每一刻思念，都化作冬天的暖流。",
  "愿你像冬日里的火焰，温暖自己也温暖他人。",
  "在寒冷的日子里，记得给自己一个温柔的拥抱。",
  "愿你抱着温暖入梦，醒来依然心安。",
  "祝你心情像雪后的阳光，明亮又温暖。",
  "冬天的夜很长，但愿你永远不孤单。",
  "愿平安喜乐，伴随你整个冬天。",
  "温暖从心开始，你就是我的温暖源泉。",
  "即使寒风凛冽，也挡不住我们的心意。",
  "愿你在这个冬天，感受到满满的爱意。",
  "冬天的寒冷，也比不上你给我的温暖。",
  "愿你每一天，都被小确幸包围。",
  "寒冷的季节，也挡不住幸福的到来。",
  "愿你心怀暖意，生活甜美如初。",
  "愿你手心有温度，岁月静好如常。",
  "有我在，你不会觉得冷。",
  "冬天虽然冷，但思念让心暖。",
  "愿你冬日安康，每天都笑颜如花。",
  "风雪再大，也不及我的祝福温暖。",
  "愿你所有的期待，都像雪花般纯洁美好。",
  "冬天的雪，是我寄给你的思念。",
  "温暖自己，才能温暖别人。",
  "愿你拥有足够的热茶和甜甜的微笑。",
  "愿每一次呼吸，都带着冬日的温暖。",
  "愿你在这个冬天被爱包围。",
  "冬天的寒冷，也阻挡不了心中的阳光。",
  "愿你的人生如冬日暖阳，光亮而温暖。",
  "在冷风中，你永远不孤单。",
  "愿你遇见的每个人，都温柔待你。",
  "寒冷时刻，也请记得温暖自己的心。",
  "冬日里，愿幸福围绕你。",
  "即便天寒地冻，心中仍有阳光。",
  "冬天不孤单，因为有温暖的人和事。",
  "雪落无声，却带着我的祝福。",
  "愿你每天都能遇到小确幸。",
  "寒风中，你的笑容是最暖的阳光。",
  "冬天里，有人牵手就是最好的幸福。",
  "愿你的生活像暖炉，温暖且美好。",
  "愿你心底常驻温柔与欢喜。",
  "寒冬也挡不住你的光芒。",
  "冬日的风雪，也吹不散我的祝福。",
  "愿你心中有暖，眼中有光。",
  "冬天的夜，再长也不及我们的思念长。",
  "愿你每天都充满小小的幸福。",
  "愿你的冬日，像暖茶一样温柔。",
  "冬天的阳光，温暖如你。",
  "愿你心中有光，脚下有路。",
  "寒冷不及思念的温度。",
  "愿你的微笑驱散冬天的寒意。",
  "冬日的夜晚，愿你梦中温暖如春。",
  "寒风中，愿你平安喜乐。",
  "冬天虽冷，愿心里有暖。",
  "每一片雪花都是我对你的祝福。",
  "愿你遇见的温暖，比寒冷多一倍。",
  "冬天再冷，也挡不住快乐的心。",
  "愿你生活像暖阳，温柔且明亮。",
  "冬日里，愿你拥有快乐和希望。",
  "寒冬中的你，依旧美丽动人。",
  "冬天有你，便是春天。",
  "愿你每一天都充满爱与笑容。",
  "冬日的早晨，有温暖的阳光和你的笑容。",
  "寒冷的季节，也挡不住我们的温暖牵挂。",
  "愿你冬天的心情，如春天般明媚。",
  "愿你手中有温茶，心中有温暖。",
  "寒风中，愿你安然无恙。",
  "冬天虽冷，但愿你被幸福包围。",
  "愿你在每一个冬天都笑得灿烂。",
  "寒冬里，温暖自己也温暖他人。",
  "愿你冬日的每一刻都被幸福填满。",
  "雪花飘落，愿你的心如雪般纯净。",
  "冬天的夜，愿你梦里温暖。",
  "寒冷的冬天，也有爱和温暖陪伴。",
  "冬日的晨光，愿你心怀希望。",
  "寒风刺骨，愿你心里依旧温暖。",
  "愿你在冬天里，心中有暖，眼中有光。",
  "冬天不冷，因为爱温暖着你。",
  "寒冬里的祝福，如春风般温柔。",
  "愿你被爱围绕，冬天也温暖如春。",
  "冬日的雪，是我悄悄的思念。",
  "愿你每一天，都能感受到温暖和爱。",
  "寒冬里，愿你笑容常驻心间。",
  "冬天虽然冷，但有祝福陪伴就温暖。",
  "愿你在寒冷的冬日，找到属于自己的温暖。",
  "愿你生活如冬日阳光，明亮而温柔。",
  "寒冷的日子里，也愿你心中充满暖意。"
}