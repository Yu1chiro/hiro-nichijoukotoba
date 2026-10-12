-- Nichijou Kotoba - PostgreSQL / NeonDB schema
-- Jalankan satu kali pada SQL Editor Neon. Aman dijalankan ulang.

CREATE TABLE IF NOT EXISTS decks (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  color VARCHAR(7) NOT NULL DEFAULT '#89AED9',
  icon VARCHAR(60) NOT NULL DEFAULT 'fa-book-open',
  archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT decks_name_unique UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS flashcards (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  deck_id BIGINT NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
  kanji TEXT NOT NULL CHECK (length(trim(kanji)) > 0),
  furigana TEXT NOT NULL CHECK (length(trim(furigana)) > 0),
  arti TEXT NOT NULL CHECK (length(trim(arti)) > 0),
  example_sentence TEXT NOT NULL DEFAULT '',
  sentence_translation TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  source_url TEXT NOT NULL DEFAULT '',
  source_title TEXT NOT NULL DEFAULT '',
  audio_url TEXT NOT NULL DEFAULT '',
  timestamp_sec INTEGER CHECK (timestamp_sec IS NULL OR timestamp_sec >= 0),
  archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE flashcards ADD COLUMN IF NOT EXISTS audio_url TEXT NOT NULL DEFAULT '';
CREATE UNIQUE INDEX IF NOT EXISTS flashcards_unique_active ON flashcards
 (deck_id, lower(btrim(kanji)), lower(btrim(furigana)), lower(btrim(arti))) WHERE archived = FALSE;
CREATE INDEX IF NOT EXISTS idx_flashcards_deck ON flashcards(deck_id, id) WHERE archived = FALSE;

CREATE TABLE IF NOT EXISTS study_days (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  deck_id BIGINT NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL CHECK (day_number > 0),
  title VARCHAR(150) NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(deck_id, day_number)
);
CREATE TABLE IF NOT EXISTS study_day_cards (
  day_id BIGINT NOT NULL REFERENCES study_days(id) ON DELETE CASCADE,
  card_id BIGINT NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(day_id, card_id)
);
CREATE INDEX IF NOT EXISTS idx_day_cards ON study_day_cards(day_id, position);

CREATE TABLE IF NOT EXISTS study_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deck_id BIGINT NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
  day_id BIGINT REFERENCES study_days(id) ON DELETE SET NULL,
  mode VARCHAR(12) NOT NULL DEFAULT 'new' CHECK (mode IN ('new','review')),
  status VARCHAR(12) NOT NULL DEFAULT 'studying' CHECK (status IN ('studying','quizzing','completed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS study_session_cards (
  session_id UUID NOT NULL REFERENCES study_sessions(id) ON DELETE CASCADE,
  card_id BIGINT NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  self_rating VARCHAR(8) CHECK (self_rating IN ('again','hard','good')),
  PRIMARY KEY(session_id, card_id)
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL UNIQUE REFERENCES study_sessions(id) ON DELETE CASCADE,
  stage VARCHAR(12) NOT NULL DEFAULT 'mc' CHECK (stage IN ('mc','matching','typing','done')),
  questions JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS quiz_answers (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  stage VARCHAR(12) NOT NULL CHECK (stage IN ('mc','matching','typing')),
  item_key TEXT NOT NULL,
  card_id BIGINT NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
  user_answer TEXT NOT NULL,
  correct BOOLEAN NOT NULL,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(attempt_id, stage, item_key)
);
CREATE INDEX IF NOT EXISTS idx_quiz_answers_attempt ON quiz_answers(attempt_id, stage);

CREATE TABLE IF NOT EXISTS card_review_states (
  card_id BIGINT PRIMARY KEY REFERENCES flashcards(id) ON DELETE CASCADE,
  review_count INTEGER NOT NULL DEFAULT 0,
  success_streak INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 0,
  interval_days INTEGER NOT NULL DEFAULT 0,
  next_review_at TIMESTAMPTZ,
  last_review_at TIMESTAMPTZ,
  status VARCHAR(15) NOT NULL DEFAULT 'new'
    CHECK (status IN ('new','learning','reviewing','mastered'))
);
CREATE INDEX IF NOT EXISTS idx_due_reviews ON card_review_states(next_review_at);
CREATE TABLE IF NOT EXISTS review_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  card_id BIGINT NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
  session_id UUID REFERENCES study_sessions(id) ON DELETE SET NULL,
  quality INTEGER NOT NULL CHECK (quality BETWEEN 0 AND 5),
  interval_days INTEGER NOT NULL,
  reviewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(card_id, session_id)
);
