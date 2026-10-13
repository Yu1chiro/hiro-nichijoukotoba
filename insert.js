(async () => {
  "use strict";

  const DECK_ID = "2";
  // Asumsi ID Day untuk Day 11 - 20 melanjutkan dari ID sebelumnya (17 - 26). Sesuaikan jika berbeda.
  const DAY_IDS = [17,18,19,20,21,22,23,24,25,26];

  // 0 = semua Day, 11-20 = Day tertentu
  const ONLY_DAY = 0;

  const MAX_CARDS = 50;

  const DELAY = 900;
  const sleep = ms => new Promise(r => setTimeout(r, ms));

  // Format:
  // kanji | furigana | arti | kalimat Jepang | hiragana lengkap | terjemahan
  const DATA = [
    // DAY 11 - 名詞（1文字）
    [
      ["柄","がら","pola; motif","この服の柄が好きです。","このふくのがらがすきです。","Saya suka pola baju ini."],
      ["帯","おび","sabuk (kimono); obi","着物の帯を締めます。","きもののおびをしめます。","Saya mengencangkan obi kimono."],
      ["黄","き","kuning","信号が黄に変わりました。","しんごうがきにかわりました。","Lampu lalu lintas berubah kuning."],
      ["表","おもて","permukaan; depan","カードの表を見てください。","かーどのおもてをみてください。","Tolong lihat bagian depan kartu."],
      ["親","おや","orang tua","親に手紙を書きました。","おやにてがみをかきました。","Saya menulis surat untuk orang tua."],
      ["貝","かい","kerang","海で貝を拾いました。","うみでかいをひろいました。","Saya memungut kerang di laut."],
      ["顔","かお","wajah","朝、顔を洗います。","あさ、かおをあらいます。","Di pagi hari, saya mencuci wajah."],
      ["傘","かさ","payung","雨が降っているので傘をさします。","あめがふっているのでかさをさします。","Karena hujan turun, saya memakai payung."],
      ["数","かず","jumlah","参加者の数を数えます。","さんかしゃのかずをかぞえます。","Saya menghitung jumlah peserta."],
      ["肩","かた","bahu","荷物が重くて肩が痛いです。","にもつがおもくてかたがいたいです。","Bahu saya sakit karena barang bawaannya berat."]
    ],

    // DAY 12 - 名詞（1文字）
    [
      ["靴","くつ","sepatu","新しい靴を買いました。","あたらしいくつをかいました。","Saya membeli sepatu baru."],
      ["首","くび","leher","寒くて首が痛くなりました。","さむくてくびがいたくなりました。","Leher saya sakit karena kedinginan."],
      ["雲","くも","awan","空に白い雲が浮かんでいます。","そらにしろいくもがうかんでいます。","Awan putih mengambang di langit."],
      ["煙","けむり","asap","火事の煙が見えます。","かじのけむりがみえます。","Terlihat asap kebakaran."],
      ["県","けん","prefektur","青森県に住んでいます。","あおもりけんにすんでいます。","Saya tinggal di prefektur Aomori."],
      ["腰","こし","pinggang","重い物を持って腰を痛めました。","おもいものを もってこしをいためました。","Pinggang saya sakit karena mengangkat barang berat."],
      ["粉","こな","bubuk; tepung","小麦粉でパンを作ります。","こむぎこでぱんをつくります。","Saya membuat roti dengan tepung terigu."],
      ["差","さ","perbedaan","二人の実力に差があります。","ふたりのじつりょくにさがあります。","Ada perbedaan pada kemampuan mereka berdua."],
      ["坂","さか","tanjakan; bukit","自転車で坂を上ります。","じてんしゃでさかをのぼります。","Saya menaiki tanjakan dengan sepeda."],
      ["桜","さくら","bunga sakura","春には桜が咲きます。","はるにはさくらがさきます。","Bunga sakura mekar di musim semi."]
    ],

    // DAY 13 - 名詞（2文字）
    [
      ["意識","いしき","kesadaran","健康を意識して生活します。","けんこうをいしきしてせいかつします。","Saya hidup dengan menyadari kesehatan."],
      ["医者","いしゃ","dokter","風邪を引いたので医者に行きます。","かぜをひいたのでいしゃにいきます。","Karena masuk angin, saya pergi ke dokter."],
      ["以上","いじょう","lebih dari; ke atas","百人以上の人が集まりました。","ひゃくにんいじょうのひとがあつまりました。","Lebih dari seratus orang berkumpul."],
      ["以前","いぜん","sebelumnya","以前、この町に住んでいました。","いぜん、このまちにすんでいました。","Sebelumnya, saya tinggal di kota ini."],
      ["位置","いち","posisi; letak","地図で現在地の位置を確認します。","ちずでげんざいちのいちをかくにんします。","Saya mengecek posisi saat ini di peta."],
      ["飲料","いんりょう","minuman","冷たい飲料を買いました。","つめたいいんりょうをかいました。","Saya membeli minuman dingin."],
      ["受付","うけつけ","resepsionis","ホテルの受付で鍵をもらいます。","ほてるのうけつけでかぎをもらいます。","Saya menerima kunci di resepsionis hotel."],
      ["運転","うんてん","mengemudi","毎日車を運転します。","まいにちくるまをうんてんします。","Saya mengemudi mobil setiap hari."],
      ["運動","うんどう","olahraga","健康のために運動をします。","けんこうのためにうんどうをします。","Saya berolahraga untuk kesehatan."],
      ["映画","えいが","film","週末に友達と映画を見ます。","しゅうまつにともだちとえいがをみます。","Saya menonton film dengan teman di akhir pekan."]
    ],

    // DAY 14 - 名詞（2文字）
    [
      ["往復","おうふく","perjalanan pulang pergi","駅まで往復で一時間かかります。","えきまでおうふくでいちじかんかかります。","Butuh satu jam perjalanan bolak-balik ke stasiun."],
      ["応募","おうぼ","pendaftaran; lamaran","新しい仕事に応募しました。","あたらしいしごとにおうぼしました。","Saya melamar pekerjaan baru."],
      ["応用","おうよう","penerapan; aplikasi","この技術はいろいろな分野に応用できます。","このぎじゅつはいろいろなぶんやにおうようできます。","Teknologi ini dapat diterapkan di berbagai bidang."],
      ["音楽","おんがく","musik","音楽を聴きながら勉強します。","おんがくをききながらべんきょうします。","Saya belajar sambil mendengarkan musik."],
      ["温泉","おんせん","sumber air panas","冬は温泉に入りたいです。","ふゆはおんせんにはいりたいです。","Saya ingin masuk ke pemandian air panas di musim dingin."],
      ["温度","おんど","suhu","部屋の温度を調節します。","へやのおんどをちょうせつします。","Saya mengatur suhu ruangan."],
      ["会議","かいぎ","rapat","午後から会議があります。","ごごからかいぎがあります。","Ada rapat mulai dari siang."],
      ["解決","かいけつ","penyelesaian","問題がやっと解決しました。","もんだいがやっとかいけつしました。","Masalah akhirnya terselesaikan."],
      ["改札","かいさつ","gerbang tiket","駅の改札で友達と待ち合わせます。","えきのかいさつでともだちとまちあわせます。","Saya janjian dengan teman di gerbang tiket stasiun."],
      ["階段","かいだん","tangga","階段を上って二階へ行きます。","かいだんをのぼってにかいへいきます。","Saya naik tangga lalu pergi ke lantai dua."]
    ],

    // DAY 15 - 名詞（2文字）
    [
      ["価格","かかく","harga","商品の価格が上がりました。","しょうひんのかかくがあがりました。","Harga barang telah naik."],
      ["科学","かがく","sains; ilmu pengetahuan","科学の進歩は素晴らしいです。","かがくのしんぽはすばらしいです。","Kemajuan ilmu pengetahuan sangat luar biasa."],
      ["家具","かぐ","furnitur","新しい部屋に家具を置きます。","あたらしいへやにかぐをおきます。","Saya meletakkan furnitur di kamar baru."],
      ["確認","かくにん","konfirmasi; pengecekan","出発前にパスポートを確認してください。","しゅっぱつまえにぱすぽーとをかくにんしてください。","Tolong periksa paspor sebelum keberangkatan."],
      ["過去","かこ","masa lalu","過去の失敗から学びます。","かこのしっぱいからまなびます。","Saya belajar dari kegagalan masa lalu."],
      ["火災","かさい","kebakaran","火災の時は落ち着いて逃げてください。","かさいのときはおちついてにげてください。","Saat kebakaran, tolong lari dengan tenang."],
      ["価値","かち","nilai","この絵には高い価値があります。","このえにはたかいかちがあります。","Lukisan ini memiliki nilai yang tinggi."],
      ["活動","かつどう","aktivitas","ボランティア活動に参加します。","ぼらんてぃあかつどうにさんかします。","Saya berpartisipasi dalam aktivitas sukarelawan."],
      ["環境","かんきょう","lingkungan","環境を守るためにリサイクルします。","かんきょうをまもるためにりさいくるします。","Saya mendaur ulang untuk melindungi lingkungan."],
      ["関係","かんけい","hubungan","二人はとてもいい関係です。","ふたりはとてもいいかんけいです。","Mereka berdua memiliki hubungan yang sangat baik."]
    ],

    // DAY 16 - 動詞（一般）
    [
      ["怒る","おこる","marah","約束を破って父が怒りました。","やくそくをやぶってちちがおこりました。","Ayah marah karena saya mengingkari janji."],
      ["急ぐ","いそぐ","bergegas; buru-buru","時間がないので急ぎましょう。","じかんがないのでいそぎましょう。","Karena tidak ada waktu, mari bergegas."],
      ["痛む","いたむ","merasa sakit","虫歯が痛みます。","むしばがいたみます。","Gigi berlubang saya sakit."],
      ["植える","うえる","menanam","庭に花の種を植えます。","にわにはなのたねをうえます。","Saya menanam biji bunga di taman."],
      ["受ける","うける","menerima; mengikuti","来月、日本語の試験を受けます。","らいげつ、にほんごのしけんをうけます。","Bulan depan, saya akan mengikuti ujian bahasa Jepang."],
      ["疑う","うたがう","meragukan; mencurigai","彼の話を疑ってしまいます。","かれのはなしをうたがってしまいます。","Saya menjadi ragu dengan ceritanya."],
      ["打つ","うつ","memukul; mengetik","パソコンで手紙を打ちます。","ぱそこんでてがみをうちます。","Saya mengetik surat di komputer."],
      ["移る","うつる","berpindah","隣の席に移りました。","となりのせきにうつりました。","Saya pindah ke kursi sebelah."],
      ["埋める","うめる","mengubur; mengisi","穴を土で埋めました。","あなをつちでうめました。","Saya menimbun lubang dengan tanah."],
      ["描く","えがく","menggambar; melukis","将来の夢を描きます。","しょうらいのゆめをえがきます。","Saya melukiskan impian masa depan."]
    ],

    // DAY 17 - 動詞（一般）
    [
      ["送る","おくる","mengirim","友達にプレゼントを送りました。","ともだちにぷれぜんとをおくりました。","Saya mengirimkan hadiah kepada teman."],
      ["遅れる","おくれる","terlambat","電車が十分遅れました。","でんしゃがじゅっぷんおくれました。","Kereta terlambat sepuluh menit."],
      ["行う","おこなう","mengadakan; melakukan","明日、テストを行います。","あした、てすとをおこないます。","Besok akan diadakan ujian."],
      ["押す","おす","menekan; mendorong","このボタンを押してください。","このぼたんをおしてください。","Tolong tekan tombol ini."],
      ["落ちる","おちる","jatuh","木からリンゴが落ちました。","きからりんごがおちました。","Apel jatuh dari pohon."],
      ["落とす","おとす","menjatuhkan","道で財布を落としました。","みちでさいふをおとしました。","Saya menjatuhkan dompet di jalan."],
      ["踊る","おどる","menari","音楽に合わせて踊ります。","おんがくにあわせておどります。","Saya menari mengikuti alunan musik."],
      ["驚く","おどろく","terkejut","突然のニュースに驚きました。","とつぜんのにゅーすにおどろきました。","Saya terkejut dengan berita yang mendadak."],
      ["覚える","おぼえる","mengingat; menghafal","毎日新しい漢字を覚えます。","まいにちあたらしいかんじをおぼえます。","Saya menghafal kanji baru setiap hari."],
      ["折る","おる","mematahkan; melipat","紙を半分に折ってください。","かみをはんぶんにおってください。","Tolong lipat kertas menjadi dua."]
    ],

    // DAY 18 - い形容詞
    [
      ["忙しい","いそがしい","sibuk","今週は仕事が忙しいです。","こんしゅうはしごとがいそがしいです。","Minggu ini pekerjaan sibuk."],
      ["痛い","いたい","sakit","頭が痛いので休みます。","あたまがいたいのでやすみます。","Karena sakit kepala, saya beristirahat."],
      ["薄い","うすい","tipis; hambar","この本はとても薄いです。","このほんはとてもうすいです。","Buku ini sangat tipis."],
      ["うらやましい","うらやましい","iri","彼の才能がうらやましいです。","かれのさいのうがうらやましいです。","Saya iri pada bakatnya."],
      ["うるさい","うるさい","berisik; rewel","外の工事がうるさいです。","そとのこうじがうるさいです。","Pekerjaan konstruksi di luar berisik."],
      ["嬉しい","うれしい","senang","プレゼントをもらって嬉しいです。","ぷれぜんとをもらってうれしいです。","Saya senang menerima hadiah."],
      ["偉い","えらい","hebat; luar biasa","彼は若いのによく働く偉い人です。","かれはわかいのによくはたらくえらいひとです。","Dia adalah orang hebat yang rajin bekerja meskipun masih muda."],
      ["美味しい","おいしい","enak","このケーキはとても美味しいです。","このけーきはとてもおいしいです。","Kue ini sangat enak."],
      ["おかしい","おかしい","aneh; lucu","彼の話はいつもおかしいです。","かれのはなしはいつもおかしいです。","Ceritanya selalu lucu/aneh."],
      ["惜しい","おしい","sayang sekali","あと少しで勝てたのに惜しいです。","あとすこしでかてたのにおしいです。","Sayang sekali padahal sedikit lagi bisa menang."]
    ],

    // DAY 19 - な形容詞
    [
      ["基本的な","きほんてきな","mendasar; pokok","基本的なルールを説明します。","きほんてきなるーるをせつめいします。","Saya akan menjelaskan aturan dasarnya."],
      ["急な","きゅうな","mendadak; curam","急な用事が入りました。","きゅうなようじがはいりました。","Ada urusan mendadak."],
      ["嫌いな","きらいな","benci; tidak suka","嫌いな食べ物はありません。","きらいなたべものはありません。","Saya tidak punya makanan yang tidak disukai."],
      ["具体的な","ぐたいてきな","konkret; spesifik","具体的な例を挙げてください。","ぐたいてきなれいをあげてください。","Tolong berikan contoh yang konkret."],
      ["元気な","げんきな","sehat; bersemangat","元気な声で挨拶します。","げんきなこえであいさつします。","Saya menyapa dengan suara yang bersemangat."],
      ["効果的な","こうかてきな","efektif","効果的な学習方法を探しています。","こうかてきながくしゅうほうほうをさがしています。","Saya mencari metode belajar yang efektif."],
      ["高価な","こうかな","mahal","高価な時計を買いました。","こうかなとけいをかいました。","Saya membeli jam tangan yang mahal."],
      ["盛んな","さかんな","populer; makmur","この町は工業が盛んです。","このまちはこうぎょうがさかんです。","Kota ini makmur dalam bidang industrinya."],
      ["様々な","さまざまな","bermacam-macam","様々な国の人が集まりました。","さまざまなくにのひとがあつまりました。","Orang dari bermacam-macam negara berkumpul."],
      ["残念な","ざんねんな","disayangkan; kecewa","試合に負けて残念な結果になりました。","しあいにまけてざんねんなけっかになりました。","Kalah dalam pertandingan dan hasilnya mengecewakan."]
    ],

    // DAY 20 - 副詞（一般）
    [
      ["あまり","あまり","tidak terlalu (dengan negatif)","私はあまりお酒を飲みません。","わたしはあまりおさけをのみません。","Saya tidak terlalu sering minum alkohol."],
      ["いくらでも","いくらでも","berapapun","時間はいくらでもあるので大丈夫です。","じかんはいくらでもあるのでだいじょうぶです。","Waktunya ada berapapun, jadi tidak apa-apa."],
      ["いつでも","いつでも","kapanpun","いつでも連絡してください。","いつでもれんらくしてください。","Hubungilah saya kapanpun."],
      ["いっぱい","いっぱい","penuh; banyak","お腹がいっぱいで食べられません。","おなかがいっぱいでたべられません。","Perut saya penuh dan tidak bisa makan lagi."],
      ["かなり","かなり","lumayan; cukup","今日のテストはかなり難しかったです。","きょうのてすとはかなりむずかしかったです。","Ujian hari ini lumayan sulit."],
      ["きちんと","きちんと","dengan rapi; pantas","靴をきちんと並べてください。","くつをきちんとならべてください。","Tolong susun sepatu dengan rapi."],
      ["きっと","きっと","pasti","明日はきっと晴れるでしょう。","あしたはきっとはれるでしょう。","Besok pasti akan cerah."],
      ["結構","けっこう","cukup; lumayan","この料理は結構美味しいです。","このりょうりはけっこうおいしいです。","Masakan ini lumayan enak."],
      ["先に","さきに","lebih dulu","お先に失礼します。","おさきにしつれいします。","Saya permisi duluan."],
      ["早速","さっそく","segera","早速、新しいパソコンを使ってみます。","さっそく、あたらしいぱそこんをつかってみます。","Saya akan segera mencoba menggunakan komputer baru ini."]
    ]
  ];

  const CATEGORIES = [
    "名詞（1文字）","名詞（1文字）","名詞（2文字）",
    "名詞（2文字）","名詞（2文字）","動詞（一般）",
    "動詞（一般）","い形容詞","な形容詞","副詞（一般）"
  ];
  const PAGES = [10,10,12,13,14,31,32,39,41,43];

  if (DATA.length !== 10 || DATA.some(day => day.length !== 10)) {
    throw new Error("Data harus 10 Day × 10 kosakata.");
  }

  if (!Number.isInteger(ONLY_DAY) || ONLY_DAY < 0 || (ONLY_DAY > 0 && (ONLY_DAY < 11 || ONLY_DAY > 20))) {
    throw new Error("ONLY_DAY harus 0 (semua), atau antara 11 dan 20.");
  }

  const CARDS = DATA.flatMap((day, di) =>
    day.map(([kanji,furigana,arti,jp,kana,translation], i) => ({
      day: di + 11,
      dayId: DAY_IDS[di],
      index: i + 1,
      kanji,furigana,arti,
      example_sentence: `${jp}${kana}`,
      sentence_translation: translation,
      notes:
        `Konteks: ${arti}. Kata 「${kanji}」 digunakan dalam kalimat contoh. ` +
        `Sumber: JLPT N3 この一冊で合格する, 文字・語彙, ` +
        `${CATEGORIES[di]}, halaman ${PAGES[di]}.`
    }))
  ).filter(card => ONLY_DAY === 0 || card.day === ONLY_DAY)
   .slice(0, MAX_CARDS);

  function setValue(el, value) {
    if (!el) throw new Error("Field tidak ditemukan.");

    const proto = el instanceof HTMLSelectElement
      ? HTMLSelectElement.prototype
      : el instanceof HTMLTextAreaElement
      ? HTMLTextAreaElement.prototype
      : HTMLInputElement.prototype;

    Object.getOwnPropertyDescriptor(proto,"value")
      .set.call(el,String(value));

    el.dispatchEvent(new Event("input",{bubbles:true}));
    el.dispatchEvent(new Event("change",{bubbles:true}));
  }

  function isVisible(el) {
    return !!(el && el.getClientRects().length);
  }

  function findOpenButton() {
    return [...document.querySelectorAll("button")]
      .find(b =>
        isVisible(b) &&
        !b.closest("#cardForm") &&
        /(add|tambah|buat|create|new).*(card|flashcard)|(card|flashcard).*(add|tambah|buat|create|new)/i
          .test(b.textContent.trim())
      );
  }

  async function getForm() {
    for (let i=0; i<40; i++) {
      const form = document.querySelector("#cardForm");
      if (isVisible(form)) return form;

      if (i===0) findOpenButton()?.click();
      await sleep(250);
    }
    throw new Error(
      "Form tidak ditemukan. Buka modal Create Flashcard terlebih dahulu."
    );
  }

  async function fillCard(form, card) {
    const deck = form.querySelector("#formDeck");
    const day = form.querySelector("#formDay");

    if (!deck || !day) {
      throw new Error("Selector #formDeck atau #formDay tidak ditemukan.");
    }

    if (deck.value !== DECK_ID) {
      setValue(deck,DECK_ID);
      await sleep(600);
    }

    // Tunggu opsi Day tersedia sesudah perubahan deck.
    for (let i=0; i<30; i++) {
      if ([...day.options].some(o => o.value === String(card.dayId))) break;
      await sleep(200);
    }

    if (![...day.options].some(o => o.value === String(card.dayId))) {
      throw new Error(`Pilihan Day ${card.day} tidak tersedia.`);
    }

    setValue(day,card.dayId);

    for (const name of [
      "kanji","furigana","arti",
      "example_sentence","sentence_translation","notes"
    ]) {
      setValue(form.elements.namedItem(name),card[name]);
    }

    // Bersihkan field sumber tambahan.
    for (const name of [
      "source_title","source_url","audio_url","timestamp_sec"
    ]) {
      const el=form.elements.namedItem(name);
      if (el) setValue(el,"");
    }
  }

  async function waitAfterSubmit(form,kanji) {
    for (let i=0;i<60;i++) {
      await sleep(250);
      if (!form.isConnected || !isVisible(form)) return true;
      if (form.elements.namedItem("kanji")?.value !== kanji) return true;
    }
    return false;
  }

  if (window.__n3ImportRunning) {
    console.warn("Import lain masih berjalan.");
    return;
  }

  window.__n3ImportRunning=true;
  let attempted=0;

  try {
    console.log(`Mulai mengirim ${CARDS.length} flashcard.`);

    for (const card of CARDS) {
      const form=await getForm();

      await fillCard(form,card);

      if (!form.checkValidity()) {
        form.reportValidity();
        throw new Error(`Validasi gagal: ${card.kanji}`);
      }

      console.log(
        `Day ${card.day} (${card.index}/10): ${card.kanji}`,
        card.example_sentence
      );

      const submit=form.querySelector('button[type="submit"]');
      if (!submit) throw new Error("Tombol submit tidak ditemukan.");

      if (typeof form.requestSubmit === "function") {
        form.requestSubmit(submit);
      } else {
        submit.click();
      }

      attempted++;

      if (!await waitAfterSubmit(form,card.kanji)) {
        throw new Error(
          `Form belum berubah setelah submit ${card.kanji}. ` +
          "Periksa apakah aplikasi sudah menyimpan kartu."
        );
      }

      await sleep(DELAY);
    }

    console.log(
      `Selesai mencoba mengirim ${attempted} kartu. ` +
      "Periksa jumlah tersimpan di aplikasi."
    );
  } catch(err) {
    console.error("IMPORT BERHENTI:",err);
    console.warn(
      `${attempted} pengiriman sudah dicoba. ` +
      "Periksa kemungkinan kartu tersimpan sebelum menjalankan ulang."
    );
  } finally {
    window.__n3ImportRunning=false;
  }
})();