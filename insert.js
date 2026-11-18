(async () => {
  const DECK_ID = 3; // 漢字総まとめ・N3

  const batches = [
    {
      dayNumber: 11,
      title: "漢字",
      cards: [
        {
          kanji: "道路",
          furigana: "どうろ",
          arti: "Jalan raya, jalan umum",
          example_sentence: "雨(あめ)の夜(よる)は道路(どうろ)がすべりやすいので運転(うんてん)に気(き)をつけてください。",
          sentence_translation: "Pada malam yang hujan jalan raya mudah licin, jadi harap berhati-hati saat mengemudi.",
          notes: "Gabungan 道 (jalan) dan 路 (rute/jalur). Merujuk pada jalan raya yang dibangun untuk lalu lintas kendaraan dan pejalan kaki (misalnya 高速道路 / jalan tol)."
        },
        {
          kanji: "線路",
          furigana: "せんろ",
          arti: "Rel kereta api, jalur kereta",
          example_sentence: "線路(せんろ)の中(なか)に荷物(にもつ)を落(お)としたときは、すぐ駅員(えきいん)に知(し)らせてください。",
          sentence_translation: "Jika menjatuhkan barang ke dalam rel kereta, segera beri tahu petugas stasiun.",
          notes: "Gabungan 線 (garis/jalur) dan 路 (jalan). Khusus merujuk pada lintasan rel kereta api beserta bantalan jalurnya."
        },
        {
          kanji: "停車",
          furigana: "ていしゃ",
          arti: "Berhenti (untuk kendaraan, kereta, bus)",
          example_sentence: "この新幹線(しんかんせん)は名古屋(なごや)と京都(きょうと)に停車(ていしゃ)します。",
          sentence_translation: "Shinkansen ini berhenti di Nagoya dan Kyoto.",
          notes: "Gabungan 停 (berhenti sementara) dan 車 (kendaraan). Dipakai untuk pemberhentian sementara kereta api di stasiun atau bus/mobil di tepi jalan."
        },
        {
          kanji: "バス停",
          furigana: "バスてい",
          arti: "Halte bus",
          example_sentence: "駅前(えきまえ)のバス停(てい)で大学(だいがく)行(ゆ)きのバスを十分(じゅっぷん)ほど待(ま)ちました。",
          sentence_translation: "Saya menunggu bus tujuan universitas sekitar 10 menit di halte bus depan stasiun.",
          notes: "Singkatan dari バス停留所 (バスていりゅうじょ). Merujuk pada titik pemberhentian bus beserta papan jadwalnya di pinggir jalan."
        },
        {
          kanji: "整理",
          furigana: "せいり",
          arti: "Merapikan, menyusun, menata secara teratur",
          example_sentence: "週末(しゅうまつ)に机(つくえ)の上(うえ)の書類(しょるい)をきれい整理(せいり)しました。",
          sentence_translation: "Pada akhir pekan saya merapikan dokumen-dokumen di atas meja dengan rapi.",
          notes: "Gabungan 整 (menata/rapi) dan 理 (aturan/logika). Digunakan untuk merapikan barang, mengurutkan data/dokumen, hingga mengatur alur antrean."
        },
        {
          kanji: "整理券",
          furigana: "せいりけん",
          arti: "Tiket nomor antrean / karcis nomor naik bus",
          example_sentence: "バスに乗(の)るときは、ドアの横(よこ)から整理券(せいりけん)を1枚(いちまい)取(と)ってください。",
          sentence_translation: "Saat naik bus, silakan ambil 1 lembar karcis nomor dari samping pintu.",
          notes: "Gabungan 整理 (pengaturan urutan) dan 券 (kupon/karcis). Dipakai pada bus lokal Jepang untuk menandai halte awal naik penumpang, serta di bank atau klinik sebagai nomor antrean."
        },
        {
          kanji: "駐車券",
          furigana: "ちゅうしゃけん",
          arti: "Karcis parkir",
          example_sentence: "買(か)い物(もの)をした店(みせ)のレジで駐車券(ちゅうしゃけん)を見(み)せると二時間(にじかん)無料(むりょう)になります。",
          sentence_translation: "Jika menunjukkan karcis parkir di kasir toko tempat berbelanja, parkir menjadi gratis selama 2 jam.",
          notes: "Gabungan 駐車 (parkir) dan 券 (tiket/karcis). Karcis yang keluar dari mesin gerbang masuk area parkir berbayar di Jepang."
        },
        {
          kanji: "乗車券",
          furigana: "じょうしゃけん",
          arti: "Tiket naik kereta/bus (tiket dasar perjalanan)",
          example_sentence: "自動(じどう)券売機(けんばいき)で東京(とうきょう)までの乗車券(じょうしゃけん)を買(か)いました。",
          sentence_translation: "Saya membeli tiket perjalanan sampai Tokyo di mesin penjual tiket otomatis.",
          notes: "Gabungan 乗車 (naik kendaraan) dan 券 (tiket). Istilah resmi untuk tiket dasar kereta api (di luar biaya tambahan kereta ekspres/特急券)."
        },
        {
          kanji: "回数券",
          furigana: "かいすうけん",
          arti: "Tiket kupon (bundel tiket untuk beberapa kali pemakaian)",
          example_sentence: "よくこの路線(ろせん)を使(つか)うので、回数券(かいすうけん)を買(か)ったほうが得(とく)です。",
          sentence_translation: "Karena sering menggunakan jalur ini, lebih untung membeli tiket kupon.",
          notes: "Gabungan 回数 (jumlah kali) dan 券 (tiket). Paket tiket berisi beberapa lembar (biasanya 11 lembar seharga 10 perjalanan) untuk kereta, bus, tol, atau pemandian umum."
        },
        {
          kanji: "現金",
          furigana: "げんきん",
          arti: "Uang tunai",
          example_sentence: "このラーメン屋(や)はクレジットカードが使(つか)えないので、現金(げんきん)で払(はら)います。",
          sentence_translation: "Kedai ramen ini tidak bisa memakai kartu kredit, jadi saya membayar dengan uang tunai.",
          notes: "Gabungan 現 (nyata/sekarang) dan 金 (uang/logam). Merujuk pada uang kertas dan koin fisik (lawan dari pembayaran nontunai/キャッシュレス)."
        }
      ]
    },
    {
      dayNumber: 12,
      title: "漢字",
      cards: [
        {
          kanji: "表現",
          furigana: "ひょうげん",
          arti: "Ekspresi, ungkapan, penyampaian",
          example_sentence: "日本語(にほんご)の微妙(びみょう)な気持(きも)ちを表現(ひょうげん)するのは難(むずか)しいです。",
          sentence_translation: "Mengungkapkan perasaan yang bernuansa halus dalam bahasa Jepang itu sulit.",
          notes: "Gabungan 表 (tampak di luar) dan 現 (muncul). Digunakan untuk ungkapan bahasa, ekspresi wajah, maupun penyampaian ide dalam seni dan tulisan."
        },
        {
          kanji: "現れる",
          furigana: "あらわれる",
          arti: "Muncul, tampak, menampakkan diri",
          example_sentence: "雲(くも)が消(き)えて、きれいな富士山(ふじさん)が姿(すがた)を現(あらわ)しました。",
          sentence_translation: "Awan menghilang, dan Gunung Fuji yang indah menampakkan wujudnya.",
          notes: "Kata kerja intransitif (自動詞) dari kanji 現. Dipakai ketika sesuatu atau seseorang yang sebelumnya tersembunyi menjadi terlihat atau muncul."
        },
        {
          kanji: "両親",
          furigana: "りょうしん",
          arti: "Kedua orang tua (ayah dan ibu)",
          example_sentence: "夏休(なつやす)みに国(くに)へ帰(かえ)って、久(ひさ)しぶりに両親(りょうしん)に会(あ)うつもりです。",
          sentence_translation: "Pada liburan musim panas saya berencana pulang ke negara asal dan bertemu kedua orang tua setelah sekian lama.",
          notes: "Gabungan 両 (keduanya) dan 親 (orang tua). Dipakai untuk menyebut ayah dan ibu sekaligus (untuk orang tua orang lain gunakan ご両親)."
        },
        {
          kanji: "〜両",
          furigana: "りょう",
          arti: "Gerbong kereta (satuan hitung gerbong)",
          example_sentence: "この電車(でんしゃ)は十両(じゅうりょう)編成(へんせい)で、前(まえ)の二両(にりょう)が指定席(していせき)です。",
          sentence_translation: "Kereta ini terdiri dari rangkaian 10 gerbong, dan 2 gerbong paling depan adalah kursi reservasi.",
          notes: "Kanji 両 berfungsi sebagai kata bantu bilangan (josuushi) khusus untuk menghitung jumlah gerbong kereta api atau unit kendaraan rel."
        },
        {
          kanji: "取り替える",
          furigana: "とりかえる",
          arti: "Mengganti, menukar (dengan yang baru)",
          example_sentence: "時計(とけい)の電池(でんち)が切(き)れたので、新(あたら)しいものに取(と)り替(か)えました。",
          sentence_translation: "Karena baterai jam tangan habis, saya menggantinya dengan yang baru.",
          notes: "Gabungan 取る (mengambil) dan 替える (mengganti). Dipakai saat mengganti komponen lama/rusak dengan pengganti yang baru (baterai, lampu, ban, seprai)."
        },
        {
          kanji: "両替",
          furigana: "りょうがえ",
          arti: "Penukaran uang (uang receh atau mata uang asing)",
          example_sentence: "空港(くうこう)の銀行(ぎんこう)でドルを日本円(にほんえん)に両替(りょうがえ)しました。",
          sentence_translation: "Saya menukarkan dolar ke yen Jepang di bank bandara.",
          notes: "Gabungan 両 (kedua belah pihak) dan 替 (menukar, meluluh menjadi がえ). Merujuk pada penukaran mata uang asing maupun pemecahan uang kertas besar ke koin/receh di mesin bus."
        },
        {
          kanji: "着替える",
          furigana: "きがえる",
          arti: "Berganti pakaian",
          example_sentence: "家(いえ)に帰(かえ)ったら、すぐ部屋着(へやぎ)に着替(きが)えてリラックスします。",
          sentence_translation: "Begitu pulang ke rumah, saya langsung berganti ke pakaian rumah dan bersantai.",
          notes: "Gabungan 着る (memakai baju) dan 替える (mengganti). Khusus digunakan untuk mengganti pakaian yang sedang dikenakan."
        },
        {
          kanji: "優先席",
          furigana: "ゆうせんせき",
          arti: "Kursi prioritas",
          example_sentence: "優先席(ゆうせんせき)の付近(ふきん)では、混雑時(こんざつじ)には携帯電話(けいたいでんわ)の電源(でんげん)をお切(き)りください。",
          sentence_translation: "Di sekitar kursi prioritas, harap matikan daya ponsel saat kereta sedang padat.",
          notes: "Gabungan 優先 (prioritas/diutamakan) dan 席 (tempat duduk). Kursi khusus di kereta dan bus Jepang untuk lansia, ibu hamil, penyandang disabilitas, dan orang sakit."
        },
        {
          kanji: "女優",
          furigana: "じょゆう",
          arti: "Aktris, pemeran wanita",
          example_sentence: "彼女(かのじょ)は日本(にほん)で最も(もっとも)人気(にんき)のある若手(わかて)女優(じょゆう)の一人(ひとり)です。",
          sentence_translation: "Dia adalah salah satu aktris muda paling populer di Jepang.",
          notes: "Gabungan 女 (wanita) dan 優 (pemeran/unggul). Merujuk pada pemeran wanita di film, drama televisi, maupun teater (untuk aktor pria/umum: 俳優 / はいゆう)."
        },
        {
          kanji: "優しい",
          furigana: "やさしい",
          arti: "Baik hati, lembut, ramah",
          example_sentence: "道(みち)に迷(まよ)っていたとき、優(やさ)しい駅員(えきいん)さんが丁寧(ていねい)に教(おし)えてくれました。",
          sentence_translation: "Ketika tersesat di jalan, petugas stasiun yang baik hati memberi tahu saya dengan sopan.",
          notes: "Kata sifat-i dengan kanji 優 untuk menggambarkan sifat penyayang, lembut, dan penuh perhatian terhadap orang lain (berbeda dengan 易しい yang berarti mudah/gampang)."
        }
      ]
    },
    {
      dayNumber: 13,
      title: "漢字",
      cards: [
        {
          kanji: "座席",
          furigana: "ざせき",
          arti: "Tempat duduk, kursi penumpang",
          example_sentence: "飛行機(ひこうき)に乗(の)ったら、まず自分(じぶん)の座席(ざせき)番号(ばんごう)を確認(かくにん)します。",
          sentence_translation: "Setelah naik pesawat, pertama-tama periksa nomor tempat duduk sendiri.",
          notes: "Gabungan 座 (duduk) dan 席 (kursi). Merujuk pada kursi penumpang pada kendaraan umum (kereta, bus, pesawat) maupun kursi penonton di teater/stadion."
        },
        {
          kanji: "正座",
          furigana: "せいざ",
          arti: "Duduk bersimpuh (gaya duduk formal tradisional Jepang)",
          example_sentence: "畳(たたみ)の上(うえ)で長時間(ちょうじかん)正座(せいざ)をしていたので、足(あし)がしびれました。",
          sentence_translation: "Karena duduk bersimpuh dalam waktu lama di atas tatami, kaki saya kesemutan.",
          notes: "Gabungan 正 (benar/lurus) dan 座 (duduk). Posisi duduk berlutut dengan punggung tegak di atas lantai tatami pada upacara minum teh, bela diri, atau acara formal Jepang."
        },
        {
          kanji: "座る",
          furigana: "すわる",
          arti: "Duduk",
          example_sentence: "どうぞこちらのいすにお座(すわ)りください。",
          sentence_translation: "Silakan duduk di kursi sebelah sini.",
          notes: "Kata kerja intransitif (自動詞) dasar dari kanji 座. Dapat digunakan baik untuk duduk di kursi (いすに座る) maupun duduk di lantai/tatami (床に座る)."
        },
        {
          kanji: "降車口",
          furigana: "こうしゃぐち",
          arti: "Pintu turun penumpang (pada bus atau kereta)",
          example_sentence: "バスが完全(かんぜん)に止(と)まってから降車口(こうしゃぐち)へお進(すす)みください。",
          sentence_translation: "Setelah bus berhenti sepenuhnya, silakan maju menuju pintu turun.",
          notes: "Gabungan 降車 (turun kendaraan) dan 口 (pintu/mulut, meluluh menjadi ぐち). Umum tertera pada petunjuk di dalam bus kota Jepang (lawan kata: 乗車口 / pintu naik)."
        },
        {
          kanji: "以降",
          furigana: "いこう",
          arti: "Sejak ~, setelah ~, dan seterusnya",
          example_sentence: "来月(らいげつ)一日(ついたち)以降(いこう)、この施設(しせつ)の利用(りよう)料金(りようりょうきん)が変(か)わります。",
          sentence_translation: "Terhitung sejak tanggal 1 bulan depan, tarif penggunaan fasilitas ini akan berubah.",
          notes: "Gabungan 以 (batas titik) dan 降 (turun/berikutnya). Menunjukkan rentang waktu mulai dari titik tertentu ke masa depan, mencakup titik waktu tersebut."
        },
        {
          kanji: "降りる",
          furigana: "おりる",
          arti: "Turun (dari kendaraan, tangga, gunung)",
          example_sentence: "次(つぎ)のバス停(てい)で降(お)りますので、ブザーを押(お)してください。",
          sentence_translation: "Karena saya akan turun di halte berikutnya, tolong tekan belnya.",
          notes: "Bacaan kun'yomi dari kanji 降 untuk subjek manusia/hewan yang bergerak turun dari transportasi (電車を降りる), tangga (階段を降りる), atau gunung."
        },
        {
          kanji: "降る",
          furigana: "ふる",
          arti: "Turun (hujan, salju, hujan es)",
          example_sentence: "天気(てんき)予報(よほう)によると、夕方(ゆうがた)から強(つよ)い雨(あめ)が降(ふ)るそうです。",
          sentence_translation: "Menurut prakiraan cuaca, katanya mulai sore akan turun hujan deras.",
          notes: "Bacaan kun'yomi dari kanji 降 khusus untuk fenomena alam yang jatuh dari langit seperti hujan (雨が降る) dan salju (雪が降る)."
        },
        {
          kanji: "準備",
          furigana: "じゅんび",
          arti: "Persiapan",
          example_sentence: "明日(あした)の試験(しけん)に向(む)けて、しっかり準備(じゅんび)をしておきます。",
          sentence_translation: "Saya melakukan persiapan dengan matang untuk menghadapi ujian besok.",
          notes: "Gabungan 準 (standar/menyiapkan) dan 備 (melengkapi). Dipakai secara luas untuk persiapan acara, perjalanan, pelajaran, maupun papan tanda toko ('準備中' = sedang persiapan/belum buka)."
        },
        {
          kanji: "備える",
          furigana: "そなえる",
          arti: "Mempersiapkan, berjaga-jaga, melengkapi",
          example_sentence: "地震(じしん)や台風(たいふう)に備(そな)えて、水(みず)や非常食(ひじょうしょく)を用意(ようい)しています。",
          sentence_translation: "Untuk berjaga-jaga menghadapi gempa dan topan, saya menyiapkan air dan makanan darurat.",
          notes: "Kata kerja transitif (他動詞) dari kanji 備. Sering dipakai dengan partikel に (〜に備える) dalam konteks kesiapsiagaan bencana atau antisipasi masa depan."
        },
        {
          kanji: "営業",
          furigana: "えいぎょう",
          arti: "Operasional bisnis, buka usaha, pemasaran/sales",
          example_sentence: "このスーパーは朝(あさ)九時(くじ)から夜(よる)十時(じゅうじ)まで営業(えいぎょう)しています。",
          sentence_translation: "Supermarket ini buka beroperasi dari jam 9 pagi sampai jam 10 malam.",
          notes: "Gabungan 営 (menjalankan) dan 業 (usaha/pekerjaan). Bisa berarti jam buka operasional toko/restoran ('営業中' = sedang buka) maupun divisi sales perusahaan."
        }
      ]
    },
    {
      dayNumber: 14,
      title: "漢字",
      cards: [
        {
          kanji: "開閉",
          furigana: "かいへい",
          arti: "Buka dan tutup (pintu, gerbang, katup)",
          example_sentence: "ドアの開閉(かいへい)の際(さい)は、手(て)をはさまれないようご注意ください。",
          sentence_translation: "Saat pintu membuka dan menutup, harap berhati-hati agar tangan tidak terjepit.",
          notes: "Gabungan 開 (buka) dan 閉 (tutup). Istilah resmi pada pengumuman kereta, lift, dan pintu otomatis untuk mekanisme membuka dan menutup."
        },
        {
          kanji: "閉じる",
          furigana: "とじる",
          arti: "Menutup (buku, mata, layar, toko)",
          example_sentence: "先生(せんせい)の指示(しじ)で、みんな教科書(きょうかしょ)を閉(と)じてテストを始(はじ)めました。",
          sentence_translation: "Atas instruksi guru, semuanya menutup buku pelajaran dan memulai tes.",
          notes: "Kata kerja dari kanji 閉 yang digunakan untuk menutup benda berlembar/berlipat (buku, mata, payung, jendela aplikasi) atau mengakhiri acara."
        },
        {
          kanji: "閉店",
          furigana: "へいてん",
          arti: "Tutup toko (berakhirnya jam buka atau penutupan usaha)",
          example_sentence: "本日(ほんじつ)は夜(よる)八時(はちじ)をもちまして閉店(へいてん)いたしました。",
          sentence_translation: "Untuk hari ini toko telah tutup pada pukul 8 malam.",
          notes: "Gabungan 閉 (tutup) dan 店 (toko). Digunakan untuk pengumuman berakhirnya jam operasional harian toko maupun penutupan permanen (lawan kata: 開店)."
        },
        {
          kanji: "閉まる",
          furigana: "しまる",
          arti: "Tertutup (pintu, toko, jendela)",
          example_sentence: "ドアが閉(し)まりますので、駆(か)け込(こ)み乗車(じょうしゃ)はおやめください。",
          sentence_translation: "Karena pintu akan tertutup, mohon jangan berlari menerobos masuk kereta.",
          notes: "Kata kerja intransitif (自動詞) dari kanji 閉 (pasangannya adalah 閉める / menutup). Sangat sering terdengar dalam pengumuman stasiun dan kereta di Jepang."
        },
        {
          kanji: "案内",
          furigana: "あんない",
          arti: "Panduan, informasi, pengantaran",
          example_sentence: "駅(えき)の案内所(あんないじょ)で観光(かんこう)マップをもらいました。",
          sentence_translation: "Saya mendapatkan peta wisata di pusat informasi stasiun.",
          notes: "Gabungan 案 (rencana/meja) dan 内 (dalam). Dipakai baik untuk memberikan petunjuk informasi (案内板 = papan petunjuk) maupun mengantar tamu berkeliling (町を案内する)."
        },
        {
          kanji: "案",
          furigana: "あん",
          arti: "Usulan, rancangan, ide, draf",
          example_sentence: "新(あたら)しいプロジェクトについて、みんなに自分(じぶん)の案(あん)を提案(ていあん)しました。",
          sentence_translation: "Mengenai proyek baru, saya mengusulkan rancangan ide saya kepada semua orang.",
          notes: "Kanji tunggal 案 merujuk pada konsep, gagasan, draf rencana, atau proposal yang diajukan untuk didiskusikan."
        },
        {
          kanji: "家内",
          furigana: "かない",
          arti: "Istri (merujuk pada istri sendiri kepada orang luar)",
          example_sentence: "来週(らいしゅう)のパーティーには家内(かない)も一緒(いっしょ)に連れて(つれて)行(い)きます。",
          sentence_translation: "Pada pesta minggu depan saya juga akan mengajak istri saya ikut serta.",
          notes: "Gabungan 家 (rumah) dan 内 (dalam). Istilah rendah hati (kenjougo) untuk menyebut istri sendiri saat berbicara dengan orang di luar keluarga (untuk istri orang lain: 奥さん)."
        },
        {
          kanji: "以内",
          furigana: "いない",
          arti: "Dalam batas ~, tidak lebih dari ~",
          example_sentence: "駅(えき)から歩(ある)いて十分(じゅっぷん)以内(いない)のアパートを探(さが)しています。",
          sentence_translation: "Saya sedang mencari apartemen dalam jarak 10 menit jalan kaki dari stasiun.",
          notes: "Gabungan 以 (batas) dan 内 (dalam). Menyatakan batas maksimal waktu, jarak, jumlah, atau biaya yang tidak melampaui angka yang disebutkan."
        },
        {
          kanji: "内側",
          furigana: "うちがわ",
          arti: "Bagian dalam, sisi dalam",
          example_sentence: "電車(でんしゃ)が通過(つうか)しますので、黄色(きいろ)い点字(てんじ)ブロックの内側(うちがわ)にお下(さ)がりください。",
          sentence_translation: "Karena kereta akan melintas, silakan mundur ke sisi dalam blok kuning tunanetra.",
          notes: "Gabungan 内 (dalam) dan 側 (sisi, meluluh menjadi がわ). Menunjukkan area bagian dalam dari garis batas, ruangan, pakaian, atau wadah (lawan kata: 外側)."
        },
        {
          kanji: "国内",
          furigana: "こくない",
          arti: "Dalam negeri, domestik",
          example_sentence: "今年(ことし)の夏(なつ)は海外(かいがい)ではなく、国内(こくない)を旅行(りょこう)する予定(よてい)です。",
          sentence_translation: "Musim panas tahun ini saya berencana berwisata di dalam negeri, bukan ke luar negeri.",
          notes: "Gabungan 国 (negara) dan 内 (dalam). Dipakai untuk segala hal yang berada atau berlangsung di dalam wilayah satu negara (lawan kata: 国外 / 海外)."
        }
      ]
    },
    {
      dayNumber: 15,
      title: "漢字",
      cards: [
        {
          kanji: "予定",
          furigana: "よてい",
          arti: "Rencana, jadwal",
          example_sentence: "日曜日(にちようび)は友達(ともだち)と映画(えいが)を見(み)に行(い)く予定(よてい)です。",
          sentence_translation: "Pada hari Minggu saya berencana pergi menonton film bersama teman.",
          notes: "Gabungan 予 (sebelumnya) dan 定 (ditetapkan). Digunakan baik untuk rencana pribadi maupun jadwal resmi acara, keberangkatan, atau penyelesaian proyek."
        },
        {
          kanji: "予習",
          furigana: "よしゅう",
          arti: "Belajar persiapan sebelum pelajaran (pre-study)",
          example_sentence: "明日(あした)の授業(じゅぎょう)で習(なら)う漢字(かんじ)を前(まえ)もって予習(よしゅう)しておきます。",
          sentence_translation: "Saya mempelajari terlebih dahulu kanji yang akan dipelajari pada kelas besok.",
          notes: "Gabungan 予 (sebelumnya) dan 習 (belajar/berlatih). Aktivitas membaca atau menyiapkan materi sebelum kelas dimulai (lawan kata: 復習 / mengulang pelajaran)."
        },
        {
          kanji: "予約",
          furigana: "よやく",
          arti: "Reservasi, pemesanan terlebih dahulu",
          example_sentence: "人気(にんき)のレストランなので、前日(ぜんじつ)までに電話(でんわ)で予約(よやく)したほうがいいです。",
          sentence_translation: "Karena ini restoran populer, sebaiknya memesan lewat telepon paling lambat sehari sebelumnya.",
          notes: "Gabungan 予 (sebelumnya) dan 約 (janji). Dipakai untuk pemesanan restoran, hotel, tiket, dokter/klinik, maupun pre-order buku/barang."
        },
        {
          kanji: "約〜",
          furigana: "やく",
          arti: "Kira-kira ~, sekitar ~",
          example_sentence: "家(いえ)から会社(かいしゃ)まで電車(でんしゃ)で約(やく)四十五分(よんじゅうごふん)かかります。",
          sentence_translation: "Dari rumah ke perusahaan memakan waktu sekitar 45 menit dengan kereta.",
          notes: "Awalan 約 (やく) diletakkan langsung di depan angka/satuan untuk menyatakan perkiraan atau estimasi yang mendekati nilai sebenarnya."
        },
        {
          kanji: "禁煙",
          furigana: "きんえん",
          arti: "Dilarang merokok, bebas asap rokok",
          example_sentence: "このレストランは全席(ぜんせき)禁煙(きんえん)となっております。",
          sentence_translation: "Restoran ini memberlakukan larangan merokok di seluruh kursi.",
          notes: "Gabungan 禁 (larangan) dan 煙 (asap/rokok). Sangat umum ditemukan pada papan tanda stasiun, restoran, hotel, dan ruang publik di Jepang (lawan kata: 喫煙 / せつえん)."
        },
        {
          kanji: "煙",
          furigana: "けむり",
          arti: "Asap",
          example_sentence: "台所(だいどころ)から黒(くろ)い煙(けむり)が出(で)ているので、すぐ見(み)に行(い)きました。",
          sentence_translation: "Karena keluar asap hitam dari dapur, saya segera pergi melihatnya.",
          notes: "Bacaan kun'yomi dari kanji 煙. Merujuk pada asap dari api, masakan yang gosong, rokok, maupun cerobong pabrik."
        },
        {
          kanji: "本当",
          furigana: "ほんとう",
          arti: "Sebenarnya, sungguh, kebenaran",
          example_sentence: "彼(かれ)が日本(にほん)の会社(かいしゃ)に就職(しゅうしょく)したというのは本当(ほんとう)ですか。",
          sentence_translation: "Apakah benar bahwa dia diterima bekerja di perusahaan Jepang?",
          notes: "Gabungan 本 (asal/asli) dan 当 (tepat/kena). Dipakai sebagai kata benda ('kebenaran') maupun kata keterangan 本当に ('sungguh / benar-benar')."
        },
        {
          kanji: "当〜",
          furigana: "とう",
          arti: "~ ini (awalan formal untuk menunjuk pihak/waktu bersangkutan)",
          example_sentence: "当店(とうてん)をご利(り)用(よう)いただき、誠(まこと)にありがとうございます。",
          sentence_translation: "Terima kasih banyak telah menggunakan toko kami ini.",
          notes: "Awalan formal 当 (とう) yang ditempelkan di depan kata benda seperti 当店 (toko ini), 当日 (hari H), 当駅 (stasiun ini), atau 当社 (perusahaan kami)."
        },
        {
          kanji: "当たる",
          furigana: "あたる",
          arti: "Mengenai sasaran, menang undian, tersorot",
          example_sentence: "宝くじ(たからくじ)で一等(いっとう)が当(あ)たって、とても驚(おどろ)きました。",
          sentence_translation: "Saya sangat terkejut karena memenangkan hadiah utama lotre.",
          notes: "Kata kerja intransitif (自動詞) dari kanji 当. Memiliki beberapa konteks pemakaian: bola mengenai benda, tebakan benar, menang undian/hadiah, atau terkena sinar matahari (日が当たる)."
        },
        {
          kanji: "当たり前",
          furigana: "あたりまえ",
          arti: "Wajar, lumrah, sudah sewajarnya",
          example_sentence: "約束(やくそく)の時間(じかん)を守(まも)るのは社会人(しゃかいじん)として当(あ)たり前(まえ)のことです。",
          sentence_translation: "Menepati waktu janji adalah hal yang sudah sewajarnya sebagai anggota masyarakat/pekerja.",
          notes: "Kata sifat-na (当たり前な / 当たり前の) yang bermakna sesuatu yang sudah semestinya terjadi atau dianggap norma umum oleh semua orang."
        }
      ]
    }
  ];

  function showSuccessLabel(summaryText) {
    if (typeof toast === "function") toast(summaryText);
    const old = document.getElementById("insert-status-badge");
    if (old) old.remove();

    const badge = document.createElement("div");
    badge.id = "insert-status-badge";
    badge.style.cssText =
      "position:fixed;bottom:24px;right:24px;z-index:99999;background:#16a34a;color:#fff;padding:14px 20px;border-radius:16px;font:700 14px/1.4 Inter,sans-serif;box-shadow:0 12px 30px rgba(22,163,74,.35);display:flex;align-items:center;gap:10px;";
    badge.innerHTML = `<span style="background:#fff;color:#16a34a;padding:2px 8px;border-radius:8px;font-size:11px;font-weight:900;">INSERT BERHASIL</span><span>${summaryText}</span>`;
    document.body.appendChild(badge);
    setTimeout(() => badge.remove(), 6000);
  }

  try {
    const meRes = await fetch("/api/auth/me");
    if (!meRes.ok) throw new Error("Sesi berakhir, silakan login ulang.");
    const { csrfToken } = await meRes.json();

    // Ambil daftar Day yang sudah ada pada deck 漢字総まとめ・N3
    const daysRes = await fetch(`/api/decks/${DECK_ID}/days`);
    if (!daysRes.ok) throw new Error("Gagal memuat daftar Day.");
    const existingDays = (await daysRes.json()).data || [];
    const dayMap = new Map(existingDays.map((d) => [Number(d.day_number), Number(d.id)]));

    const report = [];
    let totalInserted = 0;

    for (const batch of batches) {
      let dayId = dayMap.get(batch.dayNumber);

      // Jika Day 11–15 belum dibuat di Dashboard, buat otomatis terlebih dahulu
      if (!dayId) {
        const createDayRes = await fetch("/api/admin/days", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-csrf-token": csrfToken
          },
          body: JSON.stringify({
            deckId: DECK_ID,
            dayNumber: batch.dayNumber,
            title: batch.title
          })
        });
        const createdDay = await createDayRes.json();
        if (!createDayRes.ok) {
          throw new Error(`Gagal membuat Day ${batch.dayNumber}: ${createdDay.error}`);
        }
        dayId = Number(createdDay.id);
      }

      const res = await fetch("/api/admin/import/commit", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-csrf-token": csrfToken
        },
        body: JSON.stringify({
          deckId: DECK_ID,
          dayId,
          data: batch.cards
        })
      });

      const result = await res.json();
      if (!res.ok) {
        throw new Error(`Day ${batch.dayNumber}: ${result.error || res.statusText}`);
      }

      totalInserted += result.inserted;
      report.push({
        Day: `Day ${batch.dayNumber} | ${batch.title}`,
        DayID: dayId,
        Status: "✅ BERHASIL",
        Baru: result.inserted,
        Duplikat: result.duplicates
      });
    }

    console.log(
      "%c INSERT BERHASIL %c " + `${totalInserted} kartu (Day 11–15) tersimpan ke database`,
      "background:#16a34a;color:#fff;font-weight:800;padding:4px 8px;border-radius:6px;",
      "color:#16a34a;font-weight:700;"
    );
    console.table(report);
    showSuccessLabel(`${totalInserted} kartu baru (Day 11–15) berhasil dimasukkan!`);

    if (typeof closeModal === "function") closeModal();
    if (typeof refreshDecks === "function") await refreshDecks();
    if (typeof loadStats === "function") await loadStats();
    if (typeof loadCards === "function") await loadCards(1);
    if (typeof loadDayManager === "function") await loadDayManager();
  } catch (err) {
    console.error(
      "%c INSERT GAGAL %c " + err.message,
      "background:#dc2626;color:#fff;font-weight:800;padding:4px 8px;border-radius:6px;",
      "color:#dc2626;font-weight:700;"
    );
  }
})();