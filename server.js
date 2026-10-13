"use strict";
require("dotenv").config();
const express = require("express");
const path = require("path");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const cookieParser = require("cookie-parser");
const { Pool } = require("pg");

const app = express();
const PORT = Number(process.env.PORT || 3000);
const ROOT = path.join(__dirname, "public");
const SECRET = process.env.JWT_SECRET;
const PIN = process.env.ADMIN_PIN;
if (!SECRET || SECRET.length < 32 || !PIN || PIN.length < 6) {
  console.error(
    "Isi JWT_SECRET (>=32 karakter) dan ADMIN_PIN (>=6 karakter) di .env",
  );
  process.exit(1);
}
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 5,
  connectionTimeoutMillis: 10000,
});
pool.on("error", (e) =>
  console.error("Postgres idle client error:", e.message),
);
app.disable("x-powered-by");
app.use(express.json({ limit: "2mb" }));
app.use(cookieParser());
app.use((req, res, next) => {
  res.set("Cache-Control", "no-store");
  if (req.method === "GET" || req.method === "HEAD" || req.method === "OPTIONS")
    return next();
  const origin = req.get("origin");
  const host = req.get("host");
  if (origin) {
    try {
      if (new URL(origin).host !== host)
        return res.status(403).json({ error: "Origin tidak diizinkan." });
    } catch {
      return res.status(403).json({ error: "Origin tidak valid." });
    }
  }
  next();
});

function asyncRoute(fn) {
  return (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
}
function httpError(status, message) {
  const e = new Error(message);
  e.status = status;
  throw e;
}
function number(v, name) {
  const n = Number(v);
  if (!Number.isSafeInteger(n) || n < 1) httpError(400, `${name} tidak valid.`);
  return n;
}
function str(v, name, max = 500, required = true) {
  if (typeof v !== "string") {
    if (!required && v == null) return "";
    httpError(400, `${name} harus berupa teks.`);
  }
  const s = v.trim();
  if (s.length > max || (required && !s))
    httpError(400, `${name} wajib diisi (maksimal ${max} karakter).`);
  return s;
}
function hexColor(v) {
  const s = str(v ?? "#89AED9", "Warna", 7);
  if (!/^#[0-9a-fA-F]{6}$/.test(s)) httpError(400, "Warna tidak valid.");
  return s;
}
function validUrl(v) {
  const s = str(v ?? "", "URL sumber", 1000, false);
  if (!s) return "";
  try {
    const u = new URL(s);
    if (!["https:", "http:"].includes(u.protocol)) throw Error();
    return u.toString();
  } catch {
    httpError(400, "URL sumber harus http/https.");
  }
}
function normalize(v) {
  return String(v ?? "")
    .normalize("NFKC")
    .replace(/\s+/g, "")
    .toLowerCase();
}
function shuffle(array) {
  const a = [...array];
  for (let i = a.length - 1; i > 0; i--) {
    const j = crypto.randomInt(i + 1);
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}
function isPin(candidate) {
  if (typeof candidate !== "string") return false;
  const a = crypto.createHash("sha256").update(candidate).digest();
  const b = crypto.createHash("sha256").update(PIN).digest();
  return crypto.timingSafeEqual(a, b);
}
const failed = new Map();
const COOKIE = "nichijou_session";
function auth(req, res, next) {
  try {
    const data = jwt.verify(req.cookies[COOKIE] || "", SECRET, {
      algorithms: ["HS256"],
    });
    if (data.role !== "admin") throw Error();
    req.auth = data;
    next();
  } catch {
    if (req.path.startsWith("/api/"))
      return res.status(401).json({ error: "Sesi berakhir. Silakan login." });
    return res.redirect("/login");
  }
}
function csrf(req, res, next) {
  if (!req.auth || req.get("x-csrf-token") !== req.auth.csrf)
    return res
      .status(403)
      .json({ error: "Token CSRF tidak valid. Refresh halaman." });
  next();
}
const guarded = express.Router();
guarded.use(auth);
const protectedWrite = express.Router();
protectedWrite.use(auth, csrf);

app.get("/", (req, res) => res.sendFile(path.join(ROOT, "index.html")));
app.get(["/index.html"], (req, res) => res.redirect("/"));
app.get(["/login", "/login.html"], (req, res) =>
  res.sendFile(path.join(ROOT, "login.html")),
);
app.get(["/quiz", "/quiz.html"], (req, res) =>
  res.sendFile(path.join(ROOT, "quiz.html")),
);
app.get(["/dashboard", "/dashboard.html"], auth, (req, res) =>
  res.sendFile(path.join(ROOT, "dashboard.html")),
);
app.get("/favicon.ico", (req, res) => res.status(204).end());

app.post("/api/auth/login", (req, res) => {
  const ip = req.ip;
  const now = Date.now();
  const current = failed.get(ip) || { count: 0, until: now + 15 * 60 * 1000 };
  if (now > current.until) {
    current.count = 0;
    current.until = now + 15 * 60 * 1000;
  }
  if (current.count >= 8)
    return res
      .status(429)
      .json({ error: "Terlalu banyak percobaan. Tunggu 15 menit." });
  if (!isPin(req.body?.pin)) {
    current.count++;
    failed.set(ip, current);
    return res.status(401).json({ error: "PIN salah." });
  }
  failed.delete(ip);
  const csrfToken = crypto.randomBytes(24).toString("hex");
  const token = jwt.sign({ role: "admin", csrf: csrfToken }, SECRET, {
    algorithm: "HS256",
    expiresIn: "12h",
  });
  res.cookie(COOKIE, token, {
    httpOnly: true,
    sameSite: "strict",
    secure: process.env.NODE_ENV === "production",
    maxAge: 12 * 60 * 60 * 1000,
    path: "/",
  });
  res.json({ ok: true, csrfToken });
});
app.get("/api/auth/me", auth, (req, res) =>
  res.json({ authenticated: true, csrfToken: req.auth.csrf }),
);
app.post("/api/auth/logout", auth, csrf, (req, res) => {
  res.clearCookie(COOKIE, {
    httpOnly: true,
    sameSite: "strict",
    secure: process.env.NODE_ENV === "production",
    path: "/",
  });
  res.json({ ok: true });
});

function cardFields(input) {
  const rawTime = input.timestamp_sec;
  let timestamp = null;
  if (rawTime !== undefined && rawTime !== null && rawTime !== "") {
    timestamp = Number(rawTime);
    if (!Number.isSafeInteger(timestamp) || timestamp < 0 || timestamp > 864000)
      httpError(400, "Timestamp tidak valid.");
  }
  return {
    kanji: str(input.kanji, "Kanji/Kotoba", 200),
    furigana: str(input.furigana, "Furigana", 200),
    arti: str(input.arti, "Arti", 400),
    example_sentence: str(
      input.example_sentence ?? "",
      "Contoh kalimat",
      1000,
      false,
    ),
    sentence_translation: str(
      input.sentence_translation ?? "",
      "Terjemahan kalimat",
      1000,
      false,
    ),
    notes: str(input.notes ?? "", "Catatan", 1500, false),
    source_title: str(input.source_title ?? "", "Judul sumber", 200, false),
    source_url: validUrl(input.source_url),
    audio_url: validUrl(input.audio_url),
    timestamp_sec: timestamp,
  };
}
async function deckExists(deckId, client = pool) {
  const r = await client.query(
    "SELECT id FROM decks WHERE id=$1 AND archived=false",
    [deckId],
  );
  if (!r.rowCount) httpError(404, "Deck tidak ditemukan.");
}
async function dayExists(dayId, deckId, client = pool) {
  const r = await client.query(
    "SELECT id FROM study_days WHERE id=$1 AND deck_id=$2",
    [dayId, deckId],
  );
  if (!r.rowCount) httpError(404, "Day tidak ditemukan di deck tersebut.");
}

app.get(
  "/api/decks",
  asyncRoute(async (req, res) => {
    const r =
      await pool.query(`SELECT d.*, (SELECT COUNT(*)::int FROM flashcards f WHERE f.deck_id=d.id AND f.archived=false) AS card_count,
  (SELECT COUNT(*)::int FROM study_days sd WHERE sd.deck_id=d.id) AS day_count FROM decks d WHERE d.archived=false ORDER BY d.created_at DESC, d.id DESC`);
    res.json({ data: r.rows });
  }),
);
app.get(
  "/api/decks/:id/days",
  asyncRoute(async (req, res) => {
    const id = number(req.params.id, "Deck");
    await deckExists(id);
    const r = await pool.query(
      `SELECT sd.*, 
  (SELECT COUNT(*)::int FROM study_day_cards sdc JOIN flashcards f ON f.id=sdc.card_id WHERE sdc.day_id=sd.id AND f.archived=false) AS card_count,
  (SELECT COUNT(*)::int FROM study_day_cards sdc JOIN flashcards f ON f.id=sdc.card_id JOIN card_review_states crs ON crs.card_id=f.id WHERE sdc.day_id=sd.id AND f.archived=false AND crs.review_count > 0) AS studied_count
  FROM study_days sd WHERE sd.deck_id=$1 ORDER BY sd.day_number`,
      [id],
    );
    res.json({ data: r.rows });
  }),
);
app.get(
  "/api/flashcards",
  asyncRoute(async (req, res) => {
    const deckId = number(req.query.deckId, "Deck"),
      dayId = req.query.dayId ? number(req.query.dayId, "Day") : null;
    const page = Math.max(1, Math.min(100000, Number(req.query.page) || 1)),
      limit = Math.max(1, Math.min(50, Number(req.query.limit) || 10));
    const q = String(req.query.q || "").slice(0, 100);
    let join = "",
      params = [deckId],
      where = "f.deck_id=$1 AND f.archived=false";
    if (dayId) {
      params.push(dayId);
      join = "JOIN study_day_cards sdc ON sdc.card_id=f.id";
      where += ` AND sdc.day_id=$${params.length}`;
    }
    if (q) {
      params.push("%" + q + "%");
      where += ` AND (f.kanji ILIKE $${params.length} OR f.furigana ILIKE $${params.length} OR f.arti ILIKE $${params.length})`;
    }
    const count = await pool.query(
      `SELECT COUNT(*)::int AS total FROM flashcards f ${join} WHERE ${where}`,
      params,
    );
    params.push(limit, (page - 1) * limit);
    const r = await pool.query(
      `SELECT f.* FROM flashcards f ${join} WHERE ${where} ORDER BY ${dayId ? "sdc.position," : ""} f.id LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params,
    );
    res.json({ data: r.rows, total: count.rows[0].total, page, limit });
  }),
);
app.get(
  "/api/stats/overview",
  asyncRoute(async (req, res) => {
    const r = await pool.query(`SELECT
  (SELECT COUNT(*)::int FROM decks WHERE archived=false) AS decks,
  (SELECT COUNT(*)::int FROM flashcards WHERE archived=false) AS cards,
  (SELECT COUNT(*)::int FROM card_review_states s JOIN flashcards f ON f.id=s.card_id JOIN decks d ON d.id=f.deck_id WHERE f.archived=false AND d.archived=false AND s.review_count > 0) AS learned,
  (SELECT COUNT(*)::int FROM card_review_states s JOIN flashcards f ON f.id=s.card_id JOIN decks d ON d.id=f.deck_id WHERE f.archived=false AND d.archived=false AND s.status='mastered') AS mastered,
  (SELECT COUNT(*)::int FROM card_review_states s JOIN flashcards f ON f.id=s.card_id JOIN decks d ON d.id=f.deck_id WHERE f.archived=false AND d.archived=false AND s.next_review_at<=NOW()) AS due,
  (SELECT COUNT(*)::int FROM study_sessions WHERE status='completed') AS sessions`);
    res.json(r.rows[0]);
  }),
);
app.get(
  "/api/reviews/due",
  asyncRoute(async (req, res) => {
    const deckId = req.query.deckId ? number(req.query.deckId, "Deck") : null;
    const r = await pool.query(
      `SELECT f.id,f.kanji,f.furigana,f.arti,f.deck_id,s.next_review_at,s.status FROM card_review_states s
   JOIN flashcards f ON f.id=s.card_id JOIN decks d ON d.id=f.deck_id WHERE s.next_review_at<=NOW() AND f.archived=false AND d.archived=false AND ($1::bigint IS NULL OR f.deck_id=$1) ORDER BY s.next_review_at LIMIT 100`,
      [deckId],
    );
    res.json({ data: r.rows });
  }),
);

app.get(
  "/api/admin/decks",
  guarded,
  asyncRoute(async (req, res) => {
    const r = await pool.query(
      `SELECT d.*, (SELECT COUNT(*)::int FROM flashcards f WHERE f.deck_id=d.id AND f.archived=false) card_count FROM decks d ORDER BY d.id DESC`,
    );
    res.json({ data: r.rows });
  }),
);
app.post(
  "/api/admin/decks",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const { name, description, color, icon } = req.body;
    const r = await pool.query(
      "INSERT INTO decks(name,description,color,icon) VALUES($1,$2,$3,$4) RETURNING *",
      [
        str(name, "Nama deck", 120),
        str(description ?? "", "Deskripsi", 1000, false),
        hexColor(color),
        str(icon ?? "fa-book-open", "Ikon", 60),
      ],
    );
    res.status(201).json(r.rows[0]);
  }),
);
app.patch(
  "/api/admin/decks/:id",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const id = number(req.params.id, "Deck");
    const { name, description, color, icon, archived } = req.body;
    if (typeof archived !== "boolean")
      httpError(400, "Status arsip harus boolean.");
    const r = await pool.query(
      "UPDATE decks SET name=$1,description=$2,color=$3,icon=$4,archived=$5,updated_at=NOW() WHERE id=$6 RETURNING *",
      [
        str(name, "Nama deck", 120),
        str(description ?? "", "Deskripsi", 1000, false),
        hexColor(color),
        str(icon ?? "fa-book-open", "Ikon", 60),
        archived,
        id,
      ],
    );
    if (!r.rowCount) httpError(404, "Deck tidak ditemukan.");
    res.json(r.rows[0]);
  }),
);
app.delete(
  "/api/admin/decks/:id",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const permanent = req.query.permanent === "true";
    const r = await pool.query(
      permanent
        ? "DELETE FROM decks WHERE id=$1 RETURNING id"
        : "UPDATE decks SET archived=true,updated_at=NOW() WHERE id=$1 RETURNING id",
      [number(req.params.id, "Deck")],
    );
    if (!r.rowCount) httpError(404, "Deck tidak ditemukan.");
    res.json({ ok: true, permanent });
  }),
);
app.post(
  "/api/admin/days",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const deckId = number(req.body.deckId, "Deck"),
      dayNumber = number(req.body.dayNumber, "Nomor Day"),
      title = str(req.body.title ?? "", "Judul", 150, false);
    await deckExists(deckId);
    const r = await pool.query(
      "INSERT INTO study_days(deck_id,day_number,title) VALUES($1,$2,$3) RETURNING *",
      [deckId, dayNumber, title],
    );
    res.status(201).json(r.rows[0]);
  }),
);
app.patch(
  "/api/admin/days/:id",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const id = number(req.params.id, "Day"),
      dayNumber = number(req.body.dayNumber, "Nomor Day"),
      title = str(req.body.title ?? "", "Judul", 150, false);
    const r = await pool.query(
      "UPDATE study_days SET day_number=$1,title=$2 WHERE id=$3 RETURNING *",
      [dayNumber, title, id],
    );
    if (!r.rowCount) httpError(404, "Day tidak ditemukan.");
    res.json(r.rows[0]);
  }),
);
app.delete(
  "/api/admin/days/:id",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const r = await pool.query(
      "DELETE FROM study_days WHERE id=$1 RETURNING id",
      [number(req.params.id, "Day")],
    );
    if (!r.rowCount) httpError(404, "Day tidak ditemukan.");
    res.json({ ok: true });
  }),
);
app.get(
  "/api/admin/days/:id/card-ids",
  guarded,
  asyncRoute(async (req, res) => {
    const r = await pool.query(
      "SELECT card_id FROM study_day_cards WHERE day_id=$1",
      [number(req.params.id, "Day")],
    );
    res.json({ data: r.rows.map((x) => String(x.card_id)) });
  }),
);
app.post(
  "/api/admin/days/:id/cards",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const dayId = number(req.params.id, "Day"),
      cardId = number(req.body.cardId, "Flashcard");
    const found = await pool.query(
      "SELECT sd.deck_id AS deck_id,f.deck_id AS card_deck FROM study_days sd CROSS JOIN flashcards f WHERE sd.id=$1 AND f.id=$2 AND f.archived=false",
      [dayId, cardId],
    );
    if (!found.rowCount || found.rows[0].deck_id !== found.rows[0].card_deck)
      httpError(400, "Flashcard dan Day harus berasal dari deck yang sama.");
    await pool.query(
      `INSERT INTO study_day_cards(day_id,card_id,position) VALUES($1,$2,COALESCE((SELECT MAX(position)+1 FROM study_day_cards WHERE day_id=$1),1)) ON CONFLICT DO NOTHING`,
      [dayId, cardId],
    );
    res.json({ ok: true });
  }),
);
app.delete(
  "/api/admin/days/:dayId/cards/:cardId",
  protectedWrite,
  asyncRoute(async (req, res) => {
    await pool.query(
      "DELETE FROM study_day_cards WHERE day_id=$1 AND card_id=$2",
      [number(req.params.dayId, "Day"), number(req.params.cardId, "Kartu")],
    );
    res.json({ ok: true });
  }),
);
app.get(
  "/api/admin/flashcards",
  guarded,
  asyncRoute(async (req, res) => {
    const deckId = req.query.deckId ? number(req.query.deckId, "Deck") : null;
    const page = Math.max(1, Math.min(100000, Number(req.query.page) || 1)),
      limit = Math.max(1, Math.min(50, Number(req.query.limit) || 5));
    const q = String(req.query.q || "").slice(0, 100),
      archived = req.query.archived === "true",
      shadowing = req.query.shadowing === "true";
    const args = [deckId, archived, `%${q}%`];
    let where = `($1::bigint IS NULL OR f.deck_id=$1) AND f.archived=$2 AND (f.kanji ILIKE $3 OR f.furigana ILIKE $3 OR f.arti ILIKE $3)`;
    if (shadowing) where += ` AND (f.audio_url != '' OR f.source_url != '')`;

    const total = await pool.query(
      `SELECT COUNT(*)::int AS n FROM flashcards f WHERE ${where}`,
      args,
    );
    args.push(limit, (page - 1) * limit);
    const r = await pool.query(
      `SELECT f.*,d.name AS deck_name,COALESCE((SELECT json_agg(sd.id ORDER BY sd.day_number) FROM study_day_cards sdc JOIN study_days sd ON sd.id=sdc.day_id WHERE sdc.card_id=f.id),'[]'::json) AS day_ids FROM flashcards f JOIN decks d ON d.id=f.deck_id WHERE ${where} ORDER BY f.id DESC LIMIT $4 OFFSET $5`,
      args,
    );
    res.json({ data: r.rows, total: total.rows[0].n, page, limit });
  }),
);
app.post(
  "/api/admin/flashcards",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const deckId = number(req.body.deckId, "Deck"),
      c = cardFields(req.body),
      dayId = req.body.dayId ? number(req.body.dayId, "Day") : null;
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await deckExists(deckId, client);
      if (dayId) await dayExists(dayId, deckId, client);
      const r = await client.query(
        `INSERT INTO flashcards(deck_id,kanji,furigana,arti,example_sentence,sentence_translation,notes,source_title,source_url,audio_url,timestamp_sec) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING *`,
        [deckId, ...Object.values(c)],
      );
      if (dayId)
        await client.query(
          `INSERT INTO study_day_cards(day_id,card_id,position) VALUES($1,$2,COALESCE((SELECT MAX(position)+1 FROM study_day_cards WHERE day_id=$1),1)) ON CONFLICT DO NOTHING`,
          [dayId, r.rows[0].id],
        );
      await client.query("COMMIT");
      res.status(201).json(r.rows[0]);
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }),
);
app.patch(
  "/api/admin/flashcards/:id",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const id = number(req.params.id, "Flashcard"),
      c = cardFields(req.body),
      archived = req.body.archived === true;
    const r = await pool.query(
      `UPDATE flashcards SET kanji=$1,furigana=$2,arti=$3,example_sentence=$4,sentence_translation=$5,notes=$6,source_title=$7,source_url=$8,audio_url=$9,timestamp_sec=$10,archived=$11,updated_at=NOW() WHERE id=$12 RETURNING *`,
      [
        c.kanji,
        c.furigana,
        c.arti,
        c.example_sentence,
        c.sentence_translation,
        c.notes,
        c.source_title,
        c.source_url,
        c.audio_url,
        c.timestamp_sec,
        archived,
        id,
      ],
    );
    if (!r.rowCount) httpError(404, "Flashcard tidak ditemukan.");
    res.json(r.rows[0]);
  }),
);
app.delete(
  "/api/admin/flashcards/:id",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const permanent = req.query.permanent === "true";
    const r = await pool.query(
      permanent
        ? "DELETE FROM flashcards WHERE id=$1 RETURNING id"
        : "UPDATE flashcards SET archived=true,updated_at=NOW() WHERE id=$1 RETURNING id",
      [number(req.params.id, "Flashcard")],
    );
    if (!r.rowCount) httpError(404, "Flashcard tidak ditemukan.");
    res.json({ ok: true, permanent });
  }),
);
app.post(
  "/api/admin/import/preview",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const values = req.body.data;
    if (!Array.isArray(values) || !values.length || values.length > 1000)
      httpError(400, "JSON harus array berisi 1–1000 objek.");
    const valid = [],
      invalid = [],
      duplicates = [],
      seen = new Set();
    const deckId = req.body.deckId ? number(req.body.deckId, "Deck") : null,
      existing = new Set();
    if (deckId) {
      await deckExists(deckId);
      const r = await pool.query(
        "SELECT kanji,furigana,arti FROM flashcards WHERE deck_id=$1 AND archived=false",
        [deckId],
      );
      r.rows.forEach((c) =>
        existing.add([c.kanji, c.furigana, c.arti].map(normalize).join("|")),
      );
    }
    values.forEach((item, i) => {
      try {
        if (!item || typeof item !== "object" || Array.isArray(item))
          throw Error("Bukan objek JSON.");
        const c = cardFields(item),
          key = [c.kanji, c.furigana, c.arti].map(normalize).join("|");
        if (seen.has(key) || existing.has(key))
          duplicates.push({
            row: i + 1,
            reason: "Kosakata duplikat (akan dilewati).",
          });
        else valid.push({ row: i + 1, ...c });
        seen.add(key);
      } catch (e) {
        invalid.push({ row: i + 1, reason: e.message });
      }
    });
    res.json({ valid, invalid, duplicates, total: values.length });
  }),
);
app.post(
  "/api/admin/import/commit",
  protectedWrite,
  asyncRoute(async (req, res) => {
    const deckId = number(req.body.deckId, "Deck"),
      dayId = req.body.dayId ? number(req.body.dayId, "Day") : null;
    if (
      !Array.isArray(req.body.data) ||
      req.body.data.length < 1 ||
      req.body.data.length > 1000
    )
      httpError(400, "Array JSON wajib berisi 1–1000 entri.");
    const cards = req.body.data.map(cardFields),
      client = await pool.connect();
    try {
      await client.query("BEGIN");
      await deckExists(deckId, client);
      if (dayId) await dayExists(dayId, deckId, client);
      let inserted = 0,
        duplicates = 0;
      for (const c of cards) {
        const r = await client.query(
          `INSERT INTO flashcards(deck_id,kanji,furigana,arti,example_sentence,sentence_translation,notes,source_title,source_url,audio_url,timestamp_sec) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) ON CONFLICT DO NOTHING RETURNING id`,
          [deckId, ...Object.values(c)],
        );
        if (!r.rowCount) {
          duplicates++;
          continue;
        }
        inserted++;
        if (dayId)
          await client.query(
            `INSERT INTO study_day_cards(day_id,card_id,position) VALUES($1,$2,COALESCE((SELECT MAX(position)+1 FROM study_day_cards WHERE day_id=$1),1)) ON CONFLICT DO NOTHING`,
            [dayId, r.rows[0].id],
          );
      }
      await client.query("COMMIT");
      res.json({ ok: true, inserted, duplicates });
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }),
);
app.get(
  "/api/admin/export",
  guarded,
  asyncRoute(async (req, res) => {
    const deckId = req.query.deckId ? number(req.query.deckId, "Deck") : null;
    const r = await pool.query(
      `SELECT kanji,furigana,arti,example_sentence,sentence_translation,notes,source_title,source_url,audio_url,timestamp_sec FROM flashcards WHERE archived=false AND ($1::bigint IS NULL OR deck_id=$1) ORDER BY id`,
      [deckId],
    );
    res.set(
      "Content-Disposition",
      'attachment; filename="nichijou-kotoba.json"',
    );
    res.json(r.rows);
  }),
);

app.post(
  "/api/study-sessions",
  asyncRoute(async (req, res) => {
    const deckId = number(req.body.deckId, "Deck");
    await deckExists(deckId);
    const dayId = req.body.dayId ? number(req.body.dayId, "Day") : null,
      mode = req.body.mode === "review" ? "review" : "new",
      limit = Number(req.body.limit || 10);
    if (![5, 10, 15].includes(limit))
      httpError(400, "Jumlah kartu harus 5, 10, atau 15.");
    if (dayId) await dayExists(dayId, deckId);
    let sql, args;
    if (mode === "review") {
      sql = `SELECT f.id FROM card_review_states rs JOIN flashcards f ON f.id=rs.card_id WHERE f.deck_id=$1 AND f.archived=false AND rs.next_review_at<=NOW() ORDER BY rs.next_review_at LIMIT $2`;
      args = [deckId, limit];
    } else if (dayId) {
      sql = `SELECT f.id FROM study_day_cards dc JOIN flashcards f ON f.id=dc.card_id WHERE dc.day_id=$1 AND f.archived=false ORDER BY dc.position,f.id LIMIT $2`;
      args = [dayId, limit];
    } else {
      sql =
        "SELECT id FROM flashcards WHERE deck_id=$1 AND archived=false ORDER BY id LIMIT $2";
      args = [deckId, limit];
    }
    const cards = (await pool.query(sql, args)).rows;
    if (!cards.length)
      httpError(
        400,
        mode === "review"
          ? "Belum ada kartu yang jatuh tempo."
          : "Day atau deck ini belum memiliki flashcard.",
      );
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const s = await client.query(
        "INSERT INTO study_sessions(deck_id,day_id,mode) VALUES($1,$2,$3) RETURNING id",
        [deckId, dayId, mode],
      );
      for (let i = 0; i < cards.length; i++)
        await client.query(
          "INSERT INTO study_session_cards(session_id,card_id,position) VALUES($1,$2,$3)",
          [s.rows[0].id, cards[i].id, i],
        );
      await client.query("COMMIT");
      res.status(201).json({ sessionId: s.rows[0].id, count: cards.length });
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }),
);
app.get(
  "/api/study-sessions/:id",
  asyncRoute(async (req, res) => {
    const r = await pool.query(
      `SELECT s.id,s.status,s.mode,s.deck_id,s.day_id, d.name AS deck_name,
json_agg(json_build_object('id',f.id,'kanji',f.kanji,'furigana',f.furigana,'arti',f.arti,'example_sentence',f.example_sentence,
'sentence_translation',f.sentence_translation,'notes',f.notes,'source_url',f.source_url,'source_title',f.source_title,'audio_url',f.audio_url,
'timestamp_sec',f.timestamp_sec,'self_rating',sc.self_rating) ORDER BY sc.position) AS cards
FROM study_sessions s JOIN decks d ON d.id=s.deck_id JOIN study_session_cards sc ON sc.session_id=s.id JOIN flashcards f ON f.id=sc.card_id
WHERE s.id=$1 GROUP BY s.id,d.name`,
      [req.params.id],
    );
    if (!r.rowCount) httpError(404, "Sesi belajar tidak ditemukan.");
    res.json(r.rows[0]);
  }),
);
app.post(
  "/api/study-sessions/:id/rate",
  asyncRoute(async (req, res) => {
    const sessionId = req.params.id,
      cardId = number(req.body.cardId, "Kartu"),
      rating = req.body.rating;
    if (!["again", "hard", "good"].includes(rating))
      httpError(400, "Rating tidak valid.");
    const r = await pool.query(
      `UPDATE study_session_cards sc SET self_rating=$1 FROM study_sessions ss WHERE sc.session_id=ss.id AND ss.id=$2 AND ss.status='studying' AND sc.card_id=$3 RETURNING sc.card_id`,
      [rating, sessionId, cardId],
    );
    if (!r.rowCount)
      httpError(409, "Kartu tidak ditemukan atau sesi sudah ditutup.");
    res.json({ ok: true });
  }),
);

function makeQuestions(cards, other) {
  const pick = (offset) =>
    Array.from({ length: 10 }, (_, i) => cards[(i + offset) % cards.length]);
  const samples = pick(0),
    matchingSamples = pick(cards.length > 10 ? 5 : 0),
    typingSamples = pick(cards.length > 10 ? 10 : 0);

  const mc = samples.map((card, i) => {
    const testType = "furigana";
    const prompt = card.kanji;
    const seen = new Set([normalize(card[testType])]);
    const distractors = [];
    for (const x of shuffle(other)) {
      const k = normalize(x[testType]);
      if (seen.has(k)) continue;
      seen.add(k);
      distractors.push(x);
      if (distractors.length === 3) break;
    }
    const options = shuffle([card, ...distractors]);
    return {
      key: `m${i + 1}`,
      cardId: card.id,
      prompt: prompt,
      kanji: card.kanji,
      furigana: card.furigana,
      arti: card.arti,
      options: options.map((x) => ({ id: String(x.id), label: x[testType] })),
      correct: String(card.id),
    };
  });

  const matching = matchingSamples.map((card, i) => {
    const token = crypto.randomBytes(8).toString("hex");
    return {
      key: `p${i + 1}`,
      cardId: card.id,
      prompt: card.kanji,
      kanji: card.kanji,
      furigana: card.furigana,
      arti: card.arti,
      label: card.furigana, // Fokus pada cara baca
      token,
      correct: token,
      round: Math.floor(i / Math.min(5, cards.length)),
    };
  });

  const typing = typingSamples.map((card, i) => ({
    key: `t${i + 1}`,
    cardId: card.id,
    prompt: card.kanji, // Menguji kanji ke hiragana
    kanji: card.kanji,
    furigana: card.furigana,
    arti: card.arti,
    answerKanji: card.kanji,
    answerFurigana: card.furigana,
  }));
  return { mc, matching, typing };
}
app.post(
  "/api/study-sessions/:id/finish",
  asyncRoute(async (req, res) => {
    const id = req.params.id,
      client = await pool.connect();
    try {
      await client.query("BEGIN");
      const state = await client.query(
        "SELECT status,deck_id FROM study_sessions WHERE id=$1 FOR UPDATE",
        [id],
      );
      if (!state.rowCount) httpError(404, "Sesi tidak ditemukan.");
      const existing = await client.query(
        "SELECT id FROM quiz_attempts WHERE session_id=$1",
        [id],
      );
      if (existing.rowCount) {
        await client.query("COMMIT");
        return res.json({ quizReady: true, sessionId: id });
      }
      if (state.rows[0].status !== "studying")
        httpError(409, "Sesi bukan dalam mode belajar.");
      const cards = await client.query(
        `SELECT f.id,f.kanji,f.furigana,f.arti,sc.self_rating FROM study_session_cards sc JOIN flashcards f ON f.id=sc.card_id WHERE sc.session_id=$1 ORDER BY sc.position`,
        [id],
      );
      if (cards.rows.some((x) => !x.self_rating))
        httpError(400, "Verifikasi semua flashcard sebelum kuis.");
      const others = await client.query(
        "SELECT id,arti,furigana FROM flashcards WHERE deck_id=$1 AND archived=false",
        [state.rows[0].deck_id],
      );
      const questions = makeQuestions(cards.rows, others.rows);
      await client.query(
        "INSERT INTO quiz_attempts(session_id,questions) VALUES($1,$2)",
        [id, JSON.stringify(questions)],
      );
      await client.query(
        "UPDATE study_sessions SET status='quizzing' WHERE id=$1",
        [id],
      );
      await client.query("COMMIT");
      res.json({ quizReady: true, sessionId: id });
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }),
);
function publicQuiz(q, stage) {
  if (stage === "done") return [];
  return q[stage].map((x) =>
    stage === "mc"
      ? { key: x.key, prompt: x.prompt, options: x.options }
      : stage === "matching"
        ? { key: x.key, prompt: x.prompt, round: x.round }
        : { key: x.key, prompt: x.prompt },
  );
}
function publicRights(q, stage, answered) {
  if (stage !== "matching") return [];
  const done = new Set(
    answered.filter((a) => a.stage === "matching").map((a) => a.item_key),
  );
  return shuffle(
    q.matching
      .filter((x) => !done.has(x.key))
      .map((x) => ({ id: x.token, label: x.label, round: x.round })),
  );
}
app.get(
  "/api/quiz/:sessionId",
  asyncRoute(async (req, res) => {
    const r = await pool.query(
      "SELECT id,stage,questions FROM quiz_attempts WHERE session_id=$1",
      [req.params.sessionId],
    );
    if (!r.rowCount) httpError(404, "Kuis tidak ditemukan.");
    const quiz = r.rows[0];
    const a = await pool.query(
      "SELECT stage,item_key,correct,user_answer FROM quiz_answers WHERE attempt_id=$1 ORDER BY id",
      [quiz.id],
    );
    
    // Menghitung total pertanyaan untuk kalkulasi progress bar global
    const totalQuestions = (quiz.questions.mc?.length || 0) + (quiz.questions.matching?.length || 0) + (quiz.questions.typing?.length || 0);

    res.json({
      stage: quiz.stage,
      questions: publicQuiz(quiz.questions, quiz.stage),
      rights: publicRights(quiz.questions, quiz.stage, a.rows),
      answered: a.rows,
      totalQuestions,
      sessionId: req.params.sessionId,
    });
  }),
);


async function finishQuiz(client, quiz) {
  const answers = (
    await client.query(
      "SELECT card_id,stage,correct FROM quiz_answers WHERE attempt_id=$1",
      [quiz.id],
    )
  ).rows;
  const cards = (
    await client.query(
      "SELECT card_id,self_rating FROM study_session_cards WHERE session_id=$1",
      [quiz.session_id],
    )
  ).rows;
  const durations = [1, 3, 7, 14, 30, 60, 120, 240];
  for (const c of cards) {
    const a = answers.filter((x) => x.card_id === c.card_id),
      typing = a.filter((x) => x.stage === "typing");
    const accuracy = a.length
        ? a.filter((x) => x.correct).length / a.length
        : 0,
      typedOk = typing.every((x) => x.correct);
    const strong = accuracy >= 0.8 && typedOk && c.self_rating === "good",
      medium = accuracy >= 0.65 && typedOk && c.self_rating !== "again";
    const quality = strong ? 5 : medium ? 3 : accuracy >= 0.5 ? 2 : 1;
    const previous = await client.query(
      "SELECT * FROM card_review_states WHERE card_id=$1 FOR UPDATE",
      [c.card_id],
    );
    const prev = previous.rows[0];
    const witaDay = (t) =>
      Math.floor((new Date(t).getTime() + 8 * 3600000) / 86400000);
    const alreadyReviewedToday =
      Boolean(prev?.last_review_at) &&
      witaDay(prev.last_review_at) === witaDay(Date.now());
    const level = strong
      ? Math.min(8, (prev?.level || 0) + (alreadyReviewedToday ? 0 : 1))
      : medium
        ? Math.min(8, prev?.level || 0)
        : 0;
    const days = quality < 3 ? 1 : durations[Math.max(0, level - 1)] || 1;
    const streak =
      quality >= 3
        ? (prev?.success_streak || 0) + (alreadyReviewedToday ? 0 : 1)
        : 0;
    const status =
      level >= 3 && streak >= 3
        ? "mastered"
        : quality >= 3
          ? "reviewing"
          : "learning";
    await client.query(
      `INSERT INTO card_review_states(card_id,review_count,success_streak,level,interval_days,next_review_at,last_review_at,status)
 VALUES($1::bigint,1,$2::int,$3::int,$4::int,NOW()+make_interval(days => $4::int),NOW(),$5::text)
 ON CONFLICT(card_id) DO UPDATE SET review_count=card_review_states.review_count+1,success_streak=$2::int,level=$3::int,interval_days=$4::int,
 next_review_at=NOW()+make_interval(days => $4::int),last_review_at=NOW(),status=$5::text`,
      [c.card_id, streak, level, days, status],
    );
    await client.query(
      "INSERT INTO review_history(card_id,session_id,quality,interval_days) VALUES($1::bigint,$2::uuid,$3::int,$4::int) ON CONFLICT DO NOTHING",
      [c.card_id, quiz.session_id, quality, days],
    );
  }
  await client.query(
    "UPDATE quiz_attempts SET stage='done',finished_at=NOW() WHERE id=$1",
    [quiz.id],
  );
  await client.query(
    "UPDATE study_sessions SET status='completed',finished_at=NOW() WHERE id=$1",
    [quiz.session_id],
  );
}
app.post(
  "/api/quiz/:sessionId/answer",
  asyncRoute(async (req, res) => {
    const sessionId = req.params.sessionId,
      stage = req.body.stage,
      itemKey = str(req.body.itemKey, "Item", 30),
      answer = str(req.body.answer, "Jawaban", 400);
    if (!["mc", "matching", "typing"].includes(stage))
      httpError(400, "Tahap kuis tidak valid.");
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const r = await client.query(
        "SELECT * FROM quiz_attempts WHERE session_id=$1 FOR UPDATE",
        [sessionId],
      );
      if (!r.rowCount) httpError(404, "Kuis tidak ditemukan.");
      const quiz = r.rows[0];
      if (quiz.stage !== stage)
        httpError(409, "Tahap ini sudah selesai atau belum dimulai.");
      const item = quiz.questions[stage].find((x) => x.key === itemKey);
      if (!item) httpError(404, "Soal tidak ditemukan.");
      const exists = await client.query(
        "SELECT id FROM quiz_answers WHERE attempt_id=$1 AND stage=$2 AND item_key=$3",
        [quiz.id, stage, itemKey],
      );
      if (exists.rowCount) httpError(409, "Soal ini sudah dijawab.");
      
      let isCorrect;
      let expectedToken = null;
      if (stage === "typing") {
        isCorrect = [item.answerKanji, item.answerFurigana].some(
          (s) => normalize(s) === normalize(answer),
        );
      } else if (stage === "matching") {
        const chosen = quiz.questions.matching.find((x) => x.token === answer);
        isCorrect =
          !!chosen &&
          (chosen.token === item.token ||
            normalize(chosen.label) === normalize(item.label));
        expectedToken = item.token; // Digunakan frontend untuk sinkronisasi board
      } else {
        isCorrect = String(item.correct) === answer;
      }
      
      await client.query(
        "INSERT INTO quiz_answers(attempt_id,stage,item_key,card_id,user_answer,correct) VALUES($1,$2,$3,$4,$5,$6)",
        [quiz.id, stage, itemKey, item.cardId, answer, isCorrect],
      );
      const counted = await client.query(
        "SELECT COUNT(*)::int AS n FROM quiz_answers WHERE attempt_id=$1 AND stage=$2",
        [quiz.id, stage],
      );
      const finished = counted.rows[0].n >= quiz.questions[stage].length;
      let nextStage = stage;
      if (finished) {
        nextStage =
          stage === "mc"
            ? "matching"
            : stage === "matching"
              ? "typing"
              : "done";
        if (nextStage === "done") await finishQuiz(client, quiz);
        else
          await client.query("UPDATE quiz_attempts SET stage=$1 WHERE id=$2", [
            nextStage,
            quiz.id,
          ]);
      }
      await client.query("COMMIT");
      
      // Return details lengkap untuk digunakan pada popup UI
      res.json({
        correct: isCorrect,
        nextStage,
        stageFinished: finished,
        details: { kanji: item.kanji, furigana: item.furigana, arti: item.arti },
        expectedToken,
        expected: !isCorrect
          ? stage === "typing"
            ? `${item.answerKanji} / ${item.answerFurigana}`
            : stage === "mc"
              ? item.options.find((o) => o.id === item.correct)?.label
              : item.label
          : null,
      });
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }),
);
app.get(
  "/api/quiz/:sessionId/result",
  asyncRoute(async (req, res) => {
    const r = await pool.query(
      `SELECT qa.stage,qa.correct,qa.item_key,qa.user_answer,f.kanji,f.furigana,f.arti FROM quiz_answers qa JOIN quiz_attempts q ON q.id=qa.attempt_id JOIN flashcards f ON f.id=qa.card_id WHERE q.session_id=$1 ORDER BY qa.id`,
      [req.params.sessionId],
    );
    const status = await pool.query(
      "SELECT stage FROM quiz_attempts WHERE session_id=$1",
      [req.params.sessionId],
    );
    if (!status.rowCount) httpError(404, "Hasil kuis tidak ditemukan.");
    const stages = ["mc", "matching", "typing"].map((stage) => {
      const items = r.rows.filter((x) => x.stage === stage);
      return {
        stage,
        total: items.length,
        correct: items.filter((x) => x.correct).length,
      };
    });
    res.json({
      complete: status.rows[0].stage === "done",
      stages,
      wrong: r.rows.filter((x) => !x.correct),
    });
  }),
);
app.get(
  "/api/health",
  asyncRoute(async (req, res) => {
    await pool.query("SELECT 1");
    res.json({ ok: true, database: "connected" });
  }),
);
app.use((req, res) => {
  if (req.path.startsWith("/api/"))
    return res.status(404).json({ error: "Endpoint tidak ditemukan." });
  res.status(404).send("Halaman tidak ditemukan.");
});
app.use((err, req, res, next) => {
  console.error("Request failed:", err.message);
  if (res.headersSent) return next(err);
  let status = err.status || 500,
    message = status === 500 ? "Terjadi kesalahan server." : err.message;
  if (err.code === "23505") {
    status = 409;
    message =
      "Data duplikat (nama deck, nomor Day, atau flashcard sudah terdaftar).";
  }
  if (err.code === "23503") {
    status = 409;
    message = "Data masih digunakan oleh catatan lain.";
  }
  if (err.code === "22P02") {
    status = 400;
    message = "Format ID tidak valid.";
  }
  if (err instanceof SyntaxError && "body" in err) {
    status = 400;
    message = "Format JSON tidak valid.";
  }
  res.status(status).json({ error: message });
});
app.listen(PORT, () =>
  console.log(`Nichijou Kotoba aktif: http://localhost:${PORT}`),
);
