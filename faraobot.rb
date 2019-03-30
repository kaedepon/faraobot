# coding: utf-8
require 'discordrb'
require 'date'
require 'kconv'
require 'bigdecimal'
require 'json'
require 'sequel'
require 'sqlite3'
require 'logger'
require "ostruct"

# 設定ファイル読み込み
@setting_auth = open('./settings/auth.json') do |io|
  JSON.load(io)
end
@setting_farao= open('./settings/farao.json') do |io|
  JSON.load(io)
end
@setting_tablet = open('./settings/tablet.json') do |io|
  JSON.load(io)
end

#定数の設定
#ドロップ倍率
DROPRATIO = @setting_farao['dropRatio']

#メッセージ通知チャンネル
CHANNELID = @setting_auth['bot']['channel_id']

#ドロップアイテムの絵文字コード
EMOJDROP1 = @setting_farao['drop1']['emoji']
EMOJDROP2 = @setting_farao['drop2']['emoji']
EMOJDROP3 = @setting_farao['drop3']['emoji']
EMOJDROP4 = @setting_farao['drop4']['emoji']
EMOJDROP5 = @setting_farao['drop5']['emoji']
EMOJDROP6 = @setting_farao['drop6']['emoji']
EMOJDROP7 = @setting_farao['drop7']['emoji']
EMOJDROP8 = @setting_farao['drop8']['emoji']
EMOJDROP9 = @setting_farao['drop9']['emoji']
EMOJDROPEX = @setting_farao['dropEx']['emoji']
EMOJDROPEX2 = @setting_farao['dropEx2']['emoji']
EMOJFARAO = @setting_farao['farao']['emoji']
EMOJNODROP = @setting_farao['noDrop']['emoji']

#ドロップアイテムのドロップ率
BORDERDROP1 = @setting_farao['drop1']['border']
BORDERDROP2 = @setting_farao['drop2']['border']
BORDERDROP3 = @setting_farao['drop3']['border']
BORDERDROP4 = @setting_farao['drop4']['border']
BORDERDROP5 = @setting_farao['drop5']['border']
BORDERDROP6 = @setting_farao['drop6']['border']
BORDERDROP7 = @setting_farao['drop7']['border']
BORDERDROP8 = @setting_farao['drop8']['border']
BORDERDROP9 = @setting_farao['drop9']['border']
BORDERDROPEX = @setting_farao['dropEx']['border']

#精錬成功率
SEIREN = @setting_tablet['seiren']

#ファイルパス
FILELOCK = @setting_farao['file']['lock']
FILERESULT = @setting_farao['file']['result']
FILERANK = @setting_farao['file']['rank']
FILECARD = @setting_farao['file']['card']
FILEEXP = @setting_farao['file']['exp']
FILETABLET = @setting_tablet['file']['tablet']
FILETABLIST = @setting_tablet['file']['tablist']

#ファラオ経験値
FARAOEXP = @setting_farao['exp']

#resultファイルの本日分データ初期化
@today_down = ""
@today_drop = []
@total_down = ""
@total_drop = []
@summary_day = ""

#沸き時間
faraotime = ""
now = Time.now

#Database
@db = nil

#接続先BOTの設定
bot = Discordrb::Commands::CommandBot.new \
    token: @setting_auth['bot']['token'], \
    client_id: @setting_auth['bot']['client_id'], \
    prefix: "/", \
    help_command:[:fahelp], \
    command_doesnt_exist_message:"コマンドが見つかりません。\n`/fahelp`を参照してください。"

#ドロップ判定コマンド
bot.message(containing: EMOJFARAO) do |event|
  #現在時刻を取得
  now = Time.now
  #乱数の設定
  random = Random.new

  #沸き時間が過ぎている場合ドロップ判定を行う
  if now.strftime('%Y%m%d%H%M%S').to_i >= faraotime.to_i
    #排他処理
    File.open(FILELOCK, 'w') do |lock|
      if lock.flock(File::LOCK_EX|File::LOCK_NB)
        #討伐にかかった時間を設定
        hunttime = BigDecimal((now - Time.parse(faraotime)).to_s).floor(2).to_f
        hunthour = hunttime.div(3600)
        huntmin = (hunttime.- hunthour * 3600).div(60)
        huntsec = (hunttime - hunthour * 3600 - huntmin * 60).floor
        huntmilsec = BigDecimal((hunttime - hunthour * 3600 - huntmin * 60 - huntsec).to_s).floor(2).to_f
        hunttext = ""
        if hunthour > 0
          hunttext = hunthour.to_s + "時間"
        end
        if huntmin > 0 || hunttext != ""
          hunttext = hunttext + huntmin.to_s + "分"
        end
        hunttext = hunttext + huntsec.to_s + "秒"
        hunttext = hunttext + ((huntmilsec * 100).floor).to_s
        
        #MVP文を設定
        mvp = event.user.display_name + "：おめでとうございます、MVPです！！　討伐時間：" + hunttext + "\n"
        
        #resultファイルから討伐数とドロップ数を取得
        File.open(FILERESULT, 'r') do |f1|
          @today_down = f1.gets
          @today_drop = f1.gets.split(",")
          @total_down = f1.gets
          @total_drop = f1.gets.split(",")
        end
        
        #rankファイルからランキングデータを取得
        rank = []
        File.open(FILERANK, 'r') do |f2|
          f2.each_line do |line|
            rank.push(line.toutf8)
          end
        end
        
        #ランキングデータから発言者のデータを取得
        idx = -1
        user_data = []
        user_name = event.user.display_name
        for i in 0..rank.length-1 do
          user_data = rank[i].split(",")
          if user_name == user_data[0]
            idx = i
            break
          end
        end
        
        #ランキングデータに発言者のデータが無い場合は末尾に追加
        if idx == -1
          rank.push(user_name + ",0,0,0,0,0,0,0,0,0,0")
          user_data = rank[rank.length - 1].split(",")
          idx = rank.length - 1
        end
        
        #発言者の討伐数をカウントアップ
        user_data[1] = user_data[1].to_i + 1
        
        #ドロップ判定
        rate = 10000 / DROPRATIO + 1
        drop = []
        card = ""
        dropCount = OpenStruct.new

        #壊れた錫杖
        if random.rand(rate) <= BORDERDROP1
          drop.push(EMOJDROP1)
          @today_drop[0] = @today_drop[0].to_i + 1
          @total_drop[0] = @total_drop[0].to_i + 1
          user_data[2] = user_data[2].to_i + 1
          dropCount.drop01 = 1
        end
        
        #ツタンカーメンマスク
        if random.rand(rate) <= BORDERDROP2
          if random.rand(rate) <= 50
            #５％の確率で雷管表示
            drop.push(EMOJDROPEX2)
          else
            drop.push(EMOJDROP2)
          end
          @today_drop[1] = @today_drop[1].to_i + 1
          @total_drop[1] = @total_drop[1].to_i + 1
          user_data[3] = user_data[3].to_i + 1
          dropCount.drop02 = 1
        end
        
        #ジュエルクラウン
        if random.rand(rate) <= BORDERDROP3
          drop.push(EMOJDROP3)
          @today_drop[2] = @today_drop[2].to_i + 1
          @total_drop[2] = @total_drop[2].to_i + 1
          user_data[4] = user_data[4].to_i + 1
          dropCount.drop03 = 1
        end
        
        #タブレット
        if random.rand(rate) <= BORDERDROP4
          drop.push(EMOJDROP4)
          @today_drop[3] = @today_drop[3].to_i + 1
          @total_drop[3] = @total_drop[3].to_i + 1
          user_data[5] = user_data[5].to_i + 1
          dropCount.drop04 = 1
        end
        
        #ホーリーローブ
        if random.rand(rate) <= BORDERDROP5
          drop.push(EMOJDROP5)
          @today_drop[4] = @today_drop[4].to_i + 1
          @total_drop[4] = @total_drop[4].to_i + 1
          user_data[6] = user_data[6].to_i + 1
          dropCount.drop05 = 1
        end
        
        #太陽剣
        if random.rand(rate) <= BORDERDROP6
          drop.push(EMOJDROP6)
          @today_drop[5] = @today_drop[5].to_i + 1
          @total_drop[5] = @total_drop[5].to_i + 1
          user_data[7] = user_data[7].to_i + 1
          dropCount.drop06 = 1
        end
        
        #バゼラルド
        if random.rand(rate) <= BORDERDROP7
          drop.push(EMOJDROP7)
          @today_drop[6] = @today_drop[6].to_i + 1
          @total_drop[6] = @total_drop[6].to_i + 1
          user_data[8] = user_data[8].to_i + 1
          dropCount.drop07 = 1
        end
        
        #ファラオカード
        if random.rand(rate) <= BORDERDROP8
          drop.push(EMOJDROP8)
          @today_drop[7] = @today_drop[7].to_i + 1
          @total_drop[7] = @total_drop[7].to_i + 1
          user_data[9] = user_data[9].to_i + 1
          dropCount.drop08 = 1

          #cardファイルにカードドロップ者の情報を追記
          File.open(FILECARD, 'a') do |f3|
            f3.puts(user_name + "　" + (@total_down.to_i + 1).to_s + "体目　" + now.strftime('%Y年%m月%d日 %H時%M分%S秒'))
          end
          
          #目立つようにカード画像を表示
          card = card + "\nhttp://ro.silk.to/img/card_l/4148.png"
        end
        
        #アプローズサンダル
        if random.rand(rate) <= BORDERDROP9
          drop.push(EMOJDROP9)
          @today_drop[8] = @today_drop[8].to_i + 1
          @total_drop[8] = @total_drop[8].to_i + 1
          user_data[10] = user_data[10].to_i + 1
          dropCount.drop09 = 1
        end
        
        #パサナカード（ハズレカードなので集計対象外）
        if random.rand(rate) <= BORDERDROP8
          drop.push(EMOJDROP8)
          dropCount.drop10 = 1

          #目立つようにカード画像を表示
          card = card + "\nhttp://ro.silk.to/img/card_l/4099.png"
        end
        
        #マルドゥークカード（ハズレカードなので集計対象外）
        if random.rand(rate) <= BORDERDROP8
          drop.push(EMOJDROP8)
          dropCount.drop11 = 1

          #目立つようにカード画像を表示
          card = card + "\nhttp://ro.silk.to/img/card_l/4112.png"
        end
        
        #闇リンゴ（ハズレアイテムなので集計対象外）
        if random.rand(rate) <= BORDERDROPEX
          drop.push(EMOJDROPEX)
          dropCount.drop12 = 1
        end
        
        
        #ノードロップ時の表示
        if drop.eql?('')
          drop.push(EMOJNODROP)
        end
        
        #チャンネルにドロップ判定を表示
        event.respond mvp + drop.join("") + card
        
        #resultファイルの更新
        @today_down = @today_down.to_i + 1
        @total_down = @total_down.to_i + 1
        File.open(FILERESULT, 'w') do |f1|
          f1.puts(@today_down.to_i)
          f1.puts(@today_drop.join(","))
          f1.puts(@total_down.to_i)
          f1.puts(@total_drop.join(","))
          f1.puts(@summary_day.to_i)
          f1.close
        end
        #DB登録：討伐時のドロップ情報
        db_faraohunt = @db[:faraohunt] 
        db_faraohunt.insert(
          :hunt_date => now,
          :user_id => event.user.id,
          :user_distinct => event.user.distinct,
          :user_name => event.user.display_name,
          :user_hunt_count => user_data[1].to_i ,
          :elapsed_time => hunttime,
          :drop01 => dropCount.drop01.to_i,
          :drop02 => dropCount.drop02.to_i,
          :drop03 => dropCount.drop03.to_i,
          :drop04 => dropCount.drop04.to_i,
          :drop05 => dropCount.drop05.to_i,
          :drop06 => dropCount.drop06.to_i,
          :drop07 => dropCount.drop07.to_i,
          :drop08 => dropCount.drop08.to_i,
          :drop09 => dropCount.drop09.to_i,
          :drop10 => dropCount.drop10.to_i,
          :drop11 => dropCount.drop11.to_i,
          :drop12 => dropCount.drop12.to_i,
        )

        #rankファイルの更新
        rank[idx] = user_data.join(",")
        File.open(FILERANK, 'w') do |f3|
          for i in 0..rank.length - 1 do
            f3.puts(rank[i])
          end
          f3.close
        end
        
        #次の沸き時間を設定
        now = Time.now
        sleeptime = @setting_farao['sleepBasic'] + random.rand(@setting_farao['sleepMargin'])
        
        #ロックファイルの沸き時間を更新
        faraotime_raw = (now + sleeptime)
        faraotime = faraotime_raw.strftime('%Y%m%d%H%M%S')
        lock.puts(faraotime)
        
        #ファイルロック解除
        lock.flock(File::LOCK_UN)
        
        #DB登録：ファラオの湧き時間
        db_faraotime = @db[:faraotime] 
        db_faraotime.insert(
          :spawn_date => faraotime_raw,
        )

        lock.close
      end
    end
    
    #沸き時間が経過するまでBOTをオフライン表示
    set_online(bot, false)
  end
end

#タブレット精錬コマンド
bot.message(containing: EMOJDROP4) do |event|
  #タブレットのドロップ数取得
  tabnum = 0
  File.open(FILERESULT, 'r') do |f|
    @today_down = f.gets
    @today_drop = f.gets.split(",")
    tabnum = @today_drop[3].to_i
  end
  
  #tabletファイルから精錬回数データを取得
  tabdata = []
  File.open(FILETABLET, 'r') do |f2|
    f2.each_line do |line|
      if line != ""
        tabdata.push(line.toutf8)
      end
    end
  end
  
  #今までのトータル精錬回数を取得
  tabtotal = tabdata[0].to_i
  
  #精錬回数データから発言者のデータを取得
  idx = -1
  user_data = []
  user_name = event.user.display_name
  for i in 1..tabdata.length-1 do
    user_data = tabdata[i].split(",")
    if user_name == user_data[0]
      idx = i
      break
    end
  end
  
  #精錬回数データに発言者のデータが無い場合は末尾に追加
  if idx == -1
    tabdata.push(user_name + ",0")
    user_data = tabdata[tabdata.length - 1].split(",")
    idx = tabdata.length - 1
  end
  
  #タブレットドロップ数より精錬回数が少ない場合精錬実行
  if user_data[1].to_i < tabnum
    #乱数の設定
    random = Random.new
    value = 10
    for i in 0..4 do
      if random.rand(99) <= 100 - SEIREN[i]
        value = i + 5
        break
      end
    end

    if value < 10
      msg = "クホホホホ…　+" + value.to_s + " タブレットの精錬が失敗しました。"
    else
      #tablistファイルに+10精錬成功者の情報を追記
      File.open(FILETABLIST, 'a') do |f3|
        f3.puts(user_name + "　" + (tabtotal.to_i + 1).to_s + "本目　" + now.strftime('%Y年%m月%d日 %H時%M分%S秒'))
      end
      msg = "武具が強くなって君も嬉しいだろ？　+" + value.to_s + " タブレットの精錬が成功しました。"
    end
    
    #tabletファイルの更新
    user_data[1] = user_data[1].to_i + 1
    tabdata[idx] = user_data.join(",")
    File.open(FILETABLET, 'w') do |f3|
      f3.puts((tabtotal+1).to_s)
      for i in 1..tabdata.length - 1 do
        f3.puts(tabdata[i])
      end
      f3.close
    end

    #DB登録：精錬情報
    #ユーザー別製錬回数を取得し、+1する
    db_tabletuser = @db[:tabletuser]
    ds_tabletuser = db_tabletuser.where(:user_id => event.user.id).first()
    user_refine_count = 1
    if !ds_tabletuser.nil?
      user_refine_count = ds_tabletuser[:user_refine_count].to_i + 1
    end

    db_tabletrefine = @db[:tabletrefine] 
    db_tabletrefine.insert(
      :refine_date => now,
      :user_id => event.user.id,
      :user_distinct => event.user.distinct,
      :user_name => event.user.display_name,
      :user_refine_count => user_refine_count,
      :refine_result => value.to_i,
    )

    event.respond msg
  end
end

bot.command(:faresult, description:"これまでの討伐数とドロップ数の集計を表示します。") do |event|
  event.respond get_summary() 
end

bot.command(:farank, description:"討伐数ランキングを表示します。") do |event|
  rank = []
  down = []
  user_data = []
  exp = []
  disprank = 0
  
  #rankファイルからランキングデータを取得
  File.open(FILERANK, 'r') do |f1|
    f1.each_line do |line|
      rank.push(line.toutf8)
    end
  end
  
  #ランキングデータからドロップアイテムのポイントを算出
  for i in 0..rank.length-1 do
    user_data = rank[i].split(",")
    pt = 0
    pt = pt + user_data[2].to_i * 10001 / (BORDERDROP1 + 1)
    pt = pt + user_data[3].to_i * 10001 / (BORDERDROP2 + 1)
    pt = pt + user_data[4].to_i * 10001 / (BORDERDROP3 + 1)
    pt = pt + user_data[5].to_i * 10001 / (BORDERDROP4 + 1)
    pt = pt + user_data[6].to_i * 10001 / (BORDERDROP5 + 1)
    pt = pt + user_data[7].to_i * 10001 / (BORDERDROP6 + 1)
    pt = pt + user_data[8].to_i * 10001 / (BORDERDROP7 + 1)
    pt = pt + user_data[9].to_i * 10001 / (BORDERDROP8 + 1)
    pt = pt + user_data[10].to_i * 10001 / (BORDERDROP9 + 1)
    pt = (pt * 1.8 / 100).round
    down.push(pt)
  end
  
  #経験値テーブルを取得
  File.open(FILEEXP, 'r') do |f2|
    f2.each_line do |line|
      exp.push(line.toutf8)
    end
  end
  
  #ポイントの降順で並び替える
  len = down.length
  for i in 1..len do
    for j in 1..len-i do
      if down[j-1].to_i < down[j].to_i
        temp1 = down[j]
        down[j] = down[j-1]
        down[j-1] = temp1
        
        temp2 = rank[j]
        rank[j] = rank[j-1]
        rank[j-1] = temp2
      end
    end
  end
  
  for i in 0..rank.length-1 do
    user_data = rank[i].split(",")
    if user_data[0] == event.user.display_name
      #表示を始める順位を設定
      if i < 2
        disprank = 0
      elsif i > rank.length-3
        disprank = rank.length-5
      else
        disprank = i - 2
      end
    end
  end
  
  #自分の前後2人までのランキングデータを表示
  event.respond "■討伐数ランキング\n\n"
  msg = ""
  for i in disprank..disprank+4 do
    user_data = rank[i].split(",")
    
    #Lvを算出
    for j in 0..exp.length-1 do
      exp_data = exp[j].split(",")
      if user_data[1].to_i * FARAOEXP < exp_data[1].to_i
        user_lv = exp_data[0]
        break
      end
    end
    
    msg = msg + (i + 1).to_s + "位　"
    msg = msg + user_data[0] + "　"
    msg = msg + down[i].to_s + "P　"
    msg = msg + user_lv + "　"
    msg = msg + user_data[1] + "体　"
    msg = msg + "\n　　　"
    msg = msg + EMOJDROP1 + user_data[2]
    msg = msg + EMOJDROP2 + user_data[3]
    msg = msg + EMOJDROP3 + user_data[4]
    msg = msg + EMOJDROP4 + user_data[5]
    msg = msg + EMOJDROP5 + user_data[6]
    msg = msg + EMOJDROP6 + user_data[7]
    msg = msg + EMOJDROP7 + user_data[8]
    msg = msg + EMOJDROP8 + user_data[9]
    msg = msg + EMOJDROP9 + user_data[10]
  end
  
  event.respond msg
end

bot.command(:fastatus, description:"自分の討伐数とドロップ数を表示します。") do |event|
  rank = []
  down = []
  user_data = []
  exp = []
  
  #rankファイルからランキングデータを取得
  File.open(FILERANK, 'r') do |f1|
    f1.each_line do |line|
      rank.push(line.toutf8)
    end
  end
  
  #経験値テーブルを取得
  File.open(FILEEXP, 'r') do |f2|
    f2.each_line do |line|
      exp.push(line.toutf8)
    end
  end
  
  #発言者のデータを表示
  for i in 0..rank.length-1 do
    user_data = rank[i].split(",")
    if user_data[0] == event.user.display_name
      #Lvを算出
      for j in 0..exp.length-1 do
        exp_data = exp[j].split(",")
        if user_data[1].to_i * FARAOEXP < exp_data[1].to_i
          user_lv = exp_data[0]
          break
        end
      end
      
      #ポイントを算出
      pt = 0
      pt = pt + user_data[2].to_i * 10001 / (BORDERDROP1 + 1)
      pt = pt + user_data[3].to_i * 10001 / (BORDERDROP2 + 1)
      pt = pt + user_data[4].to_i * 10001 / (BORDERDROP3 + 1)
      pt = pt + user_data[5].to_i * 10001 / (BORDERDROP4 + 1)
      pt = pt + user_data[6].to_i * 10001 / (BORDERDROP5 + 1)
      pt = pt + user_data[7].to_i * 10001 / (BORDERDROP6 + 1)
      pt = pt + user_data[8].to_i * 10001 / (BORDERDROP7 + 1)
      pt = pt + user_data[9].to_i * 10001 / (BORDERDROP8 + 1)
      pt = pt + user_data[10].to_i * 10001 / (BORDERDROP9 + 1)
      pt = (pt * 1.8 / 100).round
      
      msg = user_data[0] + "　"
      msg = msg + pt.to_s + "P　"
      msg = msg + user_lv + "　"
      msg = msg + user_data[1] + "体　"
      msg = msg + EMOJDROP1 + user_data[2]
      msg = msg + EMOJDROP2 + user_data[3]
      msg = msg + EMOJDROP3 + user_data[4]
      msg = msg + EMOJDROP4 + user_data[5]
      msg = msg + EMOJDROP5 + user_data[6]
      msg = msg + EMOJDROP6 + user_data[7]
      msg = msg + EMOJDROP7 + user_data[8]
      msg = msg + EMOJDROP8 + user_data[9]
      msg = msg + EMOJDROP9 + user_data[10]
      event.respond msg
      break
    end
  end
end

bot.command(:falist, description:"1/500の壁を越えし者達を表示します。") do |event|
  i = 1
  msg = "■1/500の壁を越えし者達\n\n"
  
  #cardファイルからカード取得者の一覧を取得し表示
  File.open(FILECARD, 'r') do |f3|
    f3.each_line do |line|
      msg = msg + i.to_s + "枚目：" + line.toutf8
      i = i + 1
    end
  end
  
  event.respond msg
end

bot.command(:tablist, description:"ホルグレンに勝利を収めし者達を表示します。") do |event|
  i = 1
  msg = "■ホルグレンに勝利を収めし者達\n\n"
  
  #tablistファイルから精錬成功者の一覧を取得し表示
  File.open(FILETABLIST, 'r') do |f3|
    f3.each_line do |line|
      msg = msg + i.to_s + "本目：" + line.toutf8
      i = i + 1
    end
  end
  
  event.respond msg
end

bot.command(:farespawn, help_available:false, description:"湧き時間の再読み込みを行います。") do |event|
  #バグ沸き時用再スリープコマンド
  #沸き時間
  faraotime = ""
  now = Time.now
  File.open(FILELOCK, 'r') do |lock|
    #ファラオの沸き時間を取得
    faraotime = lock.gets
  end

  #沸き時間まで待機
  if now.strftime('%Y%m%d%H%M%S').to_i < faraotime.to_i
    set_online(bot, false)
  else
    set_online(bot, true)
  end
end

bot.command(:fastop, help_available:false, description:"このBOTを停止させます。") do |event|
  #BOT停止用コマンド
  if event.user.display_name == "Sato"
    bot.stop
  end
end

#起動時
bot.ready do |event|

  @db = create_database()

  File.open(FILERESULT, 'r') do |f|
    @today_down = f.gets
    @today_drop = f.gets.split(",")
    @total_down = f.gets
    @total_drop = f.gets.split(",")
    @summary_day = f.gets
  end

  faraotime = ""
  now = Time.now
  File.open(FILELOCK, 'r') do |lock|
    #ファラオの沸き時間を取得
    faraotime = lock.gets
  end
  
  #沸き時間まで待機
  if now.strftime('%Y%m%d%H%M%S').to_i < faraotime.to_i
    set_online(bot, false)
  else
    File.open(FILELOCK, 'w') do |lock|
      #ロックファイルの沸き時間を更新
      lock.puts(now.strftime('%Y%m%d%H%M%S'))
      sleep(1)
    end
  end
end

#DBインスタンス生成
def create_database()
  #何かオプションを指定する場合は下記に追記する
  options = {:encoding=>"utf8"}
  
  #DBに接続
  database = Sequel.sqlite(@setting_auth['database']['path'] , options)
  if @setting_auth['database']['logging']
    database.loggers << Logger.new($stdout)
  end

  return database
end

#resultファイルから討伐数とドロップアイテム数を取得し表示
def get_summary() 
  msg=""
  File.open(FILERESULT, 'r') do |f|
    @today_down = f.gets
    @today_drop = f.gets.split(",")
    @total_down = f.gets
    @total_drop = f.gets.split(",")
    
    msg = "■討伐数\n"
    msg = msg + "本日：" + @today_down
    msg = msg + "合計：" + @total_down + "\n"
    msg = msg + "■ドロップアイテム\n"
    msg = msg + "本日："
    msg = msg + EMOJDROP1 + @today_drop[0]
    msg = msg + EMOJDROP2 + @today_drop[1]
    msg = msg + EMOJDROP3 + @today_drop[2]
    msg = msg + EMOJDROP4 + @today_drop[3]
    msg = msg + EMOJDROP5 + @today_drop[4]
    msg = msg + EMOJDROP6 + @today_drop[5]
    msg = msg + EMOJDROP7 + @today_drop[6]
    msg = msg + EMOJDROP8 + @today_drop[7]
    msg = msg + EMOJDROP9 + @today_drop[8]
    msg = msg + "合計："
    msg = msg + EMOJDROP1 + @total_drop[0]
    msg = msg + EMOJDROP2 + @total_drop[1]
    msg = msg + EMOJDROP3 + @total_drop[2]
    msg = msg + EMOJDROP4 + @total_drop[3]
    msg = msg + EMOJDROP5 + @total_drop[4]
    msg = msg + EMOJDROP6 + @total_drop[5]
    msg = msg + EMOJDROP7 + @total_drop[6]
    msg = msg + EMOJDROP8 + @total_drop[7]
    msg = msg + EMOJDROP9 + @total_drop[8]
  end
  return msg
end

#onlineかどうか
def is_online()
  return @is_online
end
#online状態の更新
def set_online(bot, value)
  @is_online = value
  if @is_online
    bot.online
    popArea = @setting_farao['location']['area']
    popDetails = @setting_farao['location']['details']
    location = ""
    if popDetails.length > 0
      random = Random.new
      location = "【#{popDetails[random.rand(popDetails.length - 1)]}】"
    end
    bot.game = "#{location}#{popArea}"
  else
    bot.invisible
    bot.game = ""
  end
end

bot.run :async

begin
  #非同期のため、イベント待機
  loop do
    sleep(0.1)
    now = Time.now

    #集計日付が変わっていれば集計値初期化
    if now.strftime('%Y%m%d').to_i > @summary_day.to_i
      #初期化前に今日の結果を通知
      msg = get_summary()
      bot.send_message(CHANNELID, msg)

      @summary_day = now.strftime('%Y%m%d').to_i
      File.open(FILERESULT, 'w') do |f|
        f.puts("0")
        f.puts("0,0,0,0,0,0,0,0,0")
        f.puts(@total_down)
        f.puts(@total_drop.join(","))
        f.puts(@summary_day)
        f.close
      end

      #精錬回数初期化
      total_tab = ""
      File.open(FILETABLET, 'r') do |f2|
        total_tab = f2.gets
      end

      File.open(FILETABLET, 'w') do |f2|
        f2.puts(total_tab)
        f2.close
      end
    end
    
    #沸き時間が過ぎている場合、オンラインにする
    if now.strftime('%Y%m%d%H%M%S').to_i >= faraotime.to_i && !is_online()
      set_online(bot, true)
    end
  end
rescue SignalException => ex
  puts "SignalException SIG#{Signal::signame(ex.signo)}(#{ex.signo})"
  sleep(1)
  @db.disconnect
  bot.stop
end