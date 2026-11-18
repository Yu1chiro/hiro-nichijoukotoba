--
-- PostgreSQL database dump
--

\restrict KNHDnJgXUrrXpgBvzlLFpF4QyXETTev6pASmPl5vMJep4V3JiwIpI2IjHDYnJw9

-- Dumped from database version 18.7 (a21afb5)
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: card_review_states; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.card_review_states (
    card_id bigint NOT NULL,
    review_count integer DEFAULT 0 NOT NULL,
    success_streak integer DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    interval_days integer DEFAULT 0 NOT NULL,
    next_review_at timestamp with time zone,
    last_review_at timestamp with time zone,
    status character varying(15) DEFAULT 'new'::character varying NOT NULL,
    CONSTRAINT card_review_states_status_check CHECK (((status)::text = ANY ((ARRAY['new'::character varying, 'learning'::character varying, 'reviewing'::character varying, 'mastered'::character varying])::text[])))
);


ALTER TABLE public.card_review_states OWNER TO neondb_owner;

--
-- Name: decks; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.decks (
    id bigint NOT NULL,
    name character varying(120) NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    color character varying(7) DEFAULT '#89AED9'::character varying NOT NULL,
    icon character varying(60) DEFAULT 'fa-book-open'::character varying NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.decks OWNER TO neondb_owner;

--
-- Name: decks_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

ALTER TABLE public.decks ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.decks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: flashcards; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.flashcards (
    id bigint NOT NULL,
    deck_id bigint NOT NULL,
    kanji text NOT NULL,
    furigana text NOT NULL,
    arti text NOT NULL,
    example_sentence text DEFAULT ''::text NOT NULL,
    sentence_translation text DEFAULT ''::text NOT NULL,
    notes text DEFAULT ''::text NOT NULL,
    source_url text DEFAULT ''::text NOT NULL,
    source_title text DEFAULT ''::text NOT NULL,
    audio_url text DEFAULT ''::text NOT NULL,
    timestamp_sec integer,
    archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT flashcards_arti_check CHECK ((length(TRIM(BOTH FROM arti)) > 0)),
    CONSTRAINT flashcards_furigana_check CHECK ((length(TRIM(BOTH FROM furigana)) > 0)),
    CONSTRAINT flashcards_kanji_check CHECK ((length(TRIM(BOTH FROM kanji)) > 0)),
    CONSTRAINT flashcards_timestamp_sec_check CHECK (((timestamp_sec IS NULL) OR (timestamp_sec >= 0)))
);


ALTER TABLE public.flashcards OWNER TO neondb_owner;

--
-- Name: flashcards_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

ALTER TABLE public.flashcards ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.flashcards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: quiz_answers; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.quiz_answers (
    id bigint NOT NULL,
    attempt_id uuid NOT NULL,
    stage character varying(12) NOT NULL,
    item_key text NOT NULL,
    card_id bigint NOT NULL,
    user_answer text NOT NULL,
    correct boolean NOT NULL,
    answered_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT quiz_answers_stage_check CHECK (((stage)::text = ANY ((ARRAY['mc'::character varying, 'matching'::character varying, 'typing'::character varying])::text[])))
);


ALTER TABLE public.quiz_answers OWNER TO neondb_owner;

--
-- Name: quiz_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

ALTER TABLE public.quiz_answers ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.quiz_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: quiz_attempts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.quiz_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    stage character varying(12) DEFAULT 'mc'::character varying NOT NULL,
    questions jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    CONSTRAINT quiz_attempts_stage_check CHECK (((stage)::text = ANY ((ARRAY['mc'::character varying, 'matching'::character varying, 'typing'::character varying, 'done'::character varying])::text[])))
);


ALTER TABLE public.quiz_attempts OWNER TO neondb_owner;

--
-- Name: review_history; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.review_history (
    id bigint NOT NULL,
    card_id bigint NOT NULL,
    session_id uuid,
    quality integer NOT NULL,
    interval_days integer NOT NULL,
    reviewed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT review_history_quality_check CHECK (((quality >= 0) AND (quality <= 5)))
);


ALTER TABLE public.review_history OWNER TO neondb_owner;

--
-- Name: review_history_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

ALTER TABLE public.review_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.review_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: study_day_cards; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.study_day_cards (
    day_id bigint NOT NULL,
    card_id bigint NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.study_day_cards OWNER TO neondb_owner;

--
-- Name: study_days; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.study_days (
    id bigint NOT NULL,
    deck_id bigint NOT NULL,
    day_number integer NOT NULL,
    title character varying(150) DEFAULT ''::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT study_days_day_number_check CHECK ((day_number > 0))
);


ALTER TABLE public.study_days OWNER TO neondb_owner;

--
-- Name: study_days_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

ALTER TABLE public.study_days ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.study_days_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: study_session_cards; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.study_session_cards (
    session_id uuid NOT NULL,
    card_id bigint NOT NULL,
    "position" integer NOT NULL,
    self_rating character varying(8),
    CONSTRAINT study_session_cards_self_rating_check CHECK (((self_rating)::text = ANY ((ARRAY['again'::character varying, 'hard'::character varying, 'good'::character varying])::text[])))
);


ALTER TABLE public.study_session_cards OWNER TO neondb_owner;

--
-- Name: study_sessions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.study_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deck_id bigint NOT NULL,
    day_id bigint,
    mode character varying(12) DEFAULT 'new'::character varying NOT NULL,
    status character varying(12) DEFAULT 'studying'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    CONSTRAINT study_sessions_mode_check CHECK (((mode)::text = ANY ((ARRAY['new'::character varying, 'review'::character varying])::text[]))),
    CONSTRAINT study_sessions_status_check CHECK (((status)::text = ANY ((ARRAY['studying'::character varying, 'quizzing'::character varying, 'completed'::character varying])::text[])))
);


ALTER TABLE public.study_sessions OWNER TO neondb_owner;

--
-- Data for Name: card_review_states; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.card_review_states (card_id, review_count, success_streak, level, interval_days, next_review_at, last_review_at, status) FROM stdin;
1	1	0	0	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	learning
2	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
3	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
4	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
5	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
6	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
7	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
8	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
9	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
10	1	1	1	1	2026-10-13 16:30:07.461977+00	2026-10-12 16:30:07.461977+00	reviewing
363	3	1	1	1	2026-11-08 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	reviewing
364	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
369	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
366	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
367	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
368	3	3	2	3	2026-11-10 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	reviewing
365	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
370	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
371	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
362	3	3	3	7	2026-11-14 14:29:57.256053+00	2026-11-07 14:29:57.256053+00	mastered
382	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
383	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
384	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
385	2	0	0	1	2026-11-08 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	learning
386	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
387	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
388	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
389	2	1	1	1	2026-11-08 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
390	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
391	2	2	2	3	2026-11-10 14:32:15.560783+00	2026-11-07 14:32:15.560783+00	reviewing
192	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
191	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
193	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
194	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
195	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
196	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
197	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
198	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
199	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
200	1	1	1	1	2026-11-13 05:01:07.223462+00	2026-11-12 05:01:07.223462+00	reviewing
161	3	3	3	7	2026-11-20 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	mastered
162	3	3	3	7	2026-11-20 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	mastered
163	3	0	0	1	2026-11-14 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	learning
164	3	0	0	1	2026-11-14 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	learning
165	3	3	3	7	2026-11-20 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	mastered
166	3	3	3	7	2026-11-20 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	mastered
167	3	3	3	7	2026-11-20 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	mastered
168	3	3	3	7	2026-11-20 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	mastered
169	3	3	3	7	2026-11-20 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	mastered
178	3	3	2	3	2026-11-16 09:46:00.455858+00	2026-11-13 09:46:00.455858+00	reviewing
170	2	2	2	3	2026-10-23 04:54:16.136925+00	2026-10-20 04:54:16.136925+00	reviewing
159	3	3	2	3	2026-10-23 04:56:33.956829+00	2026-10-20 04:56:33.956829+00	reviewing
160	3	3	2	3	2026-10-23 04:56:33.956829+00	2026-10-20 04:56:33.956829+00	reviewing
171	2	2	2	3	2026-10-23 04:56:33.956829+00	2026-10-20 04:56:33.956829+00	reviewing
173	2	2	2	3	2026-10-23 04:56:33.956829+00	2026-10-20 04:56:33.956829+00	reviewing
174	2	2	2	3	2026-10-23 04:56:33.956829+00	2026-10-20 04:56:33.956829+00	reviewing
175	2	2	2	3	2026-10-23 04:56:33.956829+00	2026-10-20 04:56:33.956829+00	reviewing
177	2	2	2	3	2026-10-23 04:56:33.956829+00	2026-10-20 04:56:33.956829+00	reviewing
179	2	2	2	3	2026-10-23 04:59:09.971248+00	2026-10-20 04:59:09.971248+00	reviewing
180	2	2	2	3	2026-10-23 04:59:09.971248+00	2026-10-20 04:59:09.971248+00	reviewing
181	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
182	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
183	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
184	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
185	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
186	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
187	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
188	3	3	3	7	2026-11-04 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	mastered
189	2	2	2	3	2026-10-31 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	reviewing
190	2	2	2	3	2026-10-31 12:11:29.218395+00	2026-10-28 12:11:29.218395+00	reviewing
392	1	1	0	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	reviewing
393	1	1	1	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	reviewing
394	1	0	0	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	learning
395	1	0	0	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	learning
396	1	0	0	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	learning
397	1	0	0	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	learning
398	1	1	1	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	reviewing
399	1	1	1	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	reviewing
400	1	1	0	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	reviewing
401	1	1	1	1	2026-10-29 12:18:11.192272+00	2026-10-28 12:18:11.192272+00	reviewing
373	2	1	1	1	2026-11-08 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
374	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
375	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
376	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
377	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
378	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
379	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
380	2	0	0	1	2026-11-08 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	learning
381	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
372	2	2	2	3	2026-11-10 14:26:47.967982+00	2026-11-07 14:26:47.967982+00	reviewing
201	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
202	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
203	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
204	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
205	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
206	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
207	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
208	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
209	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
210	1	1	1	1	2026-11-13 05:04:19.285918+00	2026-11-12 05:04:19.285918+00	reviewing
151	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
152	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
153	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
154	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
155	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
156	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
157	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
158	3	3	3	7	2026-11-19 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	mastered
172	3	3	2	3	2026-11-15 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	reviewing
176	3	3	2	3	2026-11-15 05:06:48.269581+00	2026-11-12 05:06:48.269581+00	reviewing
211	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
212	1	1	0	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
213	1	0	0	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	learning
214	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
215	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
216	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
217	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
218	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
219	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
220	1	1	1	1	2026-11-14 09:30:13.40632+00	2026-11-13 09:30:13.40632+00	reviewing
221	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
222	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
223	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
224	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
225	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
226	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
227	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
228	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
229	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
230	1	1	1	1	2026-11-14 09:32:48.504999+00	2026-11-13 09:32:48.504999+00	reviewing
231	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
232	1	1	0	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
233	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
234	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
235	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
236	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
237	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
238	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
239	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
240	1	1	1	1	2026-11-14 09:37:04.096508+00	2026-11-13 09:37:04.096508+00	reviewing
\.


--
-- Data for Name: decks; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.decks (id, name, description, color, icon, archived, created_at, updated_at) FROM stdin;
1	日本のコトバンク	Japan's New Banknotes | 日本の新紙幣💴 | Japanese Listening Podcast #3	#89aed9	fa-book-open	f	2026-10-12 12:38:48.053944+00	2026-10-12 17:13:07.394058+00
2	N3 日本の森・文字語彙	文字語彙 N3  能力試験	#07df6f	fa-book-open	f	2026-10-12 18:02:08.170908+00	2026-10-13 06:06:30.327018+00
3	漢字総まとめ・N3	Vocalbullary Kanji Clustering Method	#ab01e9	fa-book-open	f	2026-10-13 13:03:15.680838+00	2026-10-13 13:03:15.680838+00
4	文字語彙・ログ	能力試験	#d3b23c	fa-book-open	f	2026-11-09 09:24:39.242615+00	2026-11-09 09:24:44.840454+00
\.


--
-- Data for Name: flashcards; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.flashcards (id, deck_id, kanji, furigana, arti, example_sentence, sentence_translation, notes, source_url, source_title, audio_url, timestamp_sec, archived, created_at, updated_at) FROM stdin;
226	2	熱い	あつい	panas (benda)	このお茶は熱いです。このおちゃはあついです。	Teh ini panas.	Konteks: panas (benda). Kata 「熱い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:41.847167+00	2026-10-13 06:13:41.847167+00
12	1	計画	けいかく	Rencana/proyek	計画を立てます。	Saya menyusun rencana.	「計画」 berarti rencana atau proyek yang disusun untuk mencapai tujuan tertentu. Kata ini sering dipakai untuk rencana kerja, perjalanan, atau studi, dan berkolokasi dengan 計画を立てる dan 計画を進める。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:54:44.674298+00
15	1	描く	えがく	Menggambar	絵を描きます。	Saya menggambar.	「描く」 berarti menggambar atau melukis, juga bisa berarti menggambarkan sesuatu dengan kata-kata. Kata ini dipakai untuk karya seni maupun deskripsi, dan berkolokasi dengan 絵を描く dan 夢を描く。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:55:50.902937+00
1	1	お越しくださり	おこしくださり	Hadir	本日はお越しくださり、ありがとうございます。	Terima kasih telah berkenan hadir pada hari ini.	Bentuk お越しくださり umum digunakan untuk menyambut tamu atau mengucapkan terima kasih secara formal.		Japanese Podcast with Hana — Episode 3		\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:22:15.567081+00
2	1	個人的な	こじんてきな	Perorangan/Pribadi	個人的な意見ですが、新しい紙幣のデザインが好きです	Ini pendapat pribadi saya, tetapi saya suka desain uang kertas yang baru.	Frasa 個人的には juga sering digunakan dengan makna "secara pribadi, menurut saya".				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:25:46.417398+00
3	1	様々な	さまざまな	bermacam-macam	日本の紙幣には、様々なモデルがあります。	Pada uang kertas Jepang terdapat berbagai macam model.	Digunakan sebagai bermacam-macam				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:27:48.682347+00
4	1	梅雨	つゆ	Musim hujan	日本では梅雨の時期に雨がよく降ります。	Di Jepang, hujan sering turun selama musim hujan.	梅雨 merujuk pada musim hujan khas Asia Timur, terutama sekitar awal musim panas, bukan sekadar hari ketika turun hujan.				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:28:47.999657+00
19	1	関わる	かかわる	Berkaitan/Terlibat/Berhubungan	仕事に関わります。	Saya terlibat dalam pekerjaan itu.	「関わる」 berarti berkaitan, terlibat, atau berhubungan dengan sesuatu. Kata ini dipakai untuk hubungan seseorang dengan suatu kegiatan, masalah, atau orang lain, dan berkolokasi dengan 〜に関わる。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:57:12.795286+00
6	1	晴天	せいてん	Langit cerah/Cerah	今日は晴天なので、散歩に行きたいです。	Karena cuaca hari ini cerah, saya ingin pergi berjalan-jalan.	晴天 biasanya digunakan untuk menggambarkan kondisi cuaca cerah dan langit yang relatif bebas awan.				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:30:03.42238+00
9	1	現在	げんざい	Masa kini/sekarang	現在、日本では新しい紙幣が使われています。	げんざい、にほんではあたらしいしへいがつかわれています。Saat ini, uang kertas baru digunakan di Jepang.	現在 lebih formal daripada 今（いま）dan sering dijumpai dalam berita atau presentasi.				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:53:39.707335+00
7	1	録音している	ろくおんしている	Perekaman/Merekam	今、日本語のポッドキャストを録音しています。	Sekarang saya sedang merekam podcast bahasa Jepang.	録音する berarti merekam audio. Pola ～ている menunjukkan kegiatan yang sedang berlangsung dalam kalimat ini.				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:31:11.634479+00
8	1	紙幣	しへい	Uang kertas	日本では新しい紙幣が発行されました。	にほんではあたらしいしへいがはっこうされました。Uang kertas baru telah diterbitkan di Jepang.	紙幣 berarti uang kertas, sedangkan 硬貨（こうか）berarti uang logam. Dalam percakapan sehari-hari, ～円札（えんさつ）juga digunakan.				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:52:46.634513+00
22	1	企業	きぎょう	Perusahaan/Bisnis/Kooperasi	企業で働きます。	Saya bekerja di perusahaan.	「企業」 berarti perusahaan atau bisnis. Kata ini dipakai untuk organisasi yang bergerak di bidang usaha, dan berkolokasi dengan 企業で働く dan 企業を設立する。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 08:58:14.021598+00
26	1	映る	うつる	Tercermin/Terbayang	写真に映ります。	Saya terlihat di foto.	「映る」 berarti tercermin, terlihat, atau terproyeksikan, misalnya pada foto, cermin, atau layar. Kata ini dipakai untuk bayangan atau gambar yang muncul di suatu permukaan, dan berkolokasi dengan 写真に映る dan 鏡に映る。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 08:59:39.335857+00
29	1	背景	はいけい	Latar Belakang	写真の背景がきれいです。	Latar belakang foto itu indah.	「背景」 berarti latar belakang, baik latar suatu peristiwa, gambar, maupun situasi. Kata ini dipakai untuk menjelaskan konteks di balik sesuatu, dan berkolokasi dengan 背景がきれい dan 背景を知る。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 09:00:42.125974+00
33	1	観察	かんさつ	Pengamatan/Observasi	観察をします。	Saya melakukan pengamatan.	「観察」 berarti pengamatan atau observasi. Kata ini dipakai untuk memperhatikan sesuatu dengan saksama, baik dalam penelitian maupun kehidupan sehari-hari, dan berkolokasi dengan 観察する dan 観察を続ける。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:02:11.065666+00
36	1	発行	はっこう	Penerbitan/Terbitan	雑誌を発行します。	Saya menerbitkan majalah.	「発行」 berarti penerbitan atau terbitan. Kata ini dipakai untuk menerbitkan buku, majalah, atau surat kabar, dan berkolokasi dengan 雑誌を発行する dan 本を発行する。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:03:30.262049+00
39	1	生涯	しょうがい	Seumur Hidup/Riwayat Hidup	生涯学び続けます。	Saya akan terus belajar seumur hidup.	「生涯」 berarti seumur hidup atau riwayat hidup. Kata ini dipakai untuk sesuatu yang berlangsung sepanjang hidup seseorang, dan berkolokasi dengan 生涯をかける dan 生涯の仕事。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:04:42.17605+00
42	1	印刷	いんさつ	Percetakan/Cetak	本を印刷します。	Saya mencetak buku.	「印刷」 berarti percetakan atau mencetak. Kata ini dipakai untuk mencetak buku, dokumen, atau gambar, dan berkolokasi dengan 本を印刷する dan 印刷する機械。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:05:51.555654+00
45	1	傾ける	かたむける	Memiringkan/Membuang	頭を傾けます。	Saya memiringkan kepala.	「傾ける」 berarti memiringkan atau menuangkan. Kata ini dipakai untuk memiringkan kepala, gelas, atau benda lain, dan berkolokasi dengan 頭を傾ける dan コップを傾ける。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:07:13.897908+00
48	1	歴史的	れきしてき	Sejarah/Historis	歴史的な建物です。	Ini adalah bangunan bersejarah.	「歴史的」 berarti bersejarah atau historis. Kata ini dipakai untuk sesuatu yang berkaitan dengan sejarah atau memiliki nilai sejarah, dan berkolokasi dengan 歴史的な建物 dan 歴史的な出来事。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:08:17.992962+00
10	1	使用されている	しようされている	Penggunaan/Menggunakan	この技術は紙幣の印刷に使用されています。	このぎじゅつはしへいのいんさつにしようされています。Teknologi ini digunakan dalam pencetakan uang kertas.	Bentuk pasif dari 使用する. Pola ～されている menunjukkan kondisi penggunaan yang berlangsung atau masih berlaku.				\N	f	2026-10-12 13:22:48.902597+00	2026-10-12 17:54:22.710046+00
151	2	間	あいだ	antara; selama	休みの間、家にいました。やすみのあいだ、いえにいました。	Selama liburan, saya berada di rumah.	Konteks: antara; selama. Kata 「間」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:48.759079+00	2026-10-13 06:11:48.759079+00
152	2	青	あお	biru	青が一番好きな色です。あおがいちばんすきないろです。	Biru adalah warna favorit saya.	Konteks: biru. Kata 「青」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:50.162163+00	2026-10-13 06:11:50.162163+00
153	2	味	あじ	rasa	この料理は味がいいです。このりょうりはあじがいいです。	Masakan ini rasanya enak.	Konteks: rasa. Kata 「味」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:51.595699+00	2026-10-13 06:11:51.595699+00
154	2	穴	あな	lubang	靴下に穴が開いています。くつしたにあながあいています。	Ada lubang pada kaus kaki.	Konteks: lubang. Kata 「穴」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:53.024582+00	2026-10-13 06:11:53.024582+00
155	2	油	あぶら	minyak	料理に油を使います。りょうりにあぶらをつかいます。	Saya menggunakan minyak untuk memasak.	Konteks: minyak. Kata 「油」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:54.4612+00	2026-10-13 06:11:54.4612+00
156	2	案	あん	usulan; ide	新しい案を考えました。あたらしいあんをかんがえました。	Saya memikirkan usulan baru.	Konteks: usulan; ide. Kata 「案」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:55.880069+00	2026-10-13 06:11:55.880069+00
157	2	胃	い	lambung	胃が痛いので病院へ行きます。いがいたいのでびょういんへいきます。	Karena lambung saya sakit, saya pergi ke rumah sakit.	Konteks: lambung. Kata 「胃」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:57.305466+00	2026-10-13 06:11:57.305466+00
158	2	家	いえ	rumah	私の家は駅の近くです。わたしのいえはえきのちかくです。	Rumah saya dekat stasiun.	Konteks: rumah. Kata 「家」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:11:58.719398+00	2026-10-13 06:11:58.719398+00
159	2	息	いき	napas	ゆっくり息をしてください。ゆっくりいきをしてください。	Bernapaslah perlahan.	Konteks: napas. Kata 「息」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:00.168238+00	2026-10-13 06:12:00.168238+00
160	2	池	いけ	kolam	公園の池に魚がいます。こうえんのいけにさかながいます。	Ada ikan di kolam taman.	Konteks: kolam. Kata 「池」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:01.603092+00	2026-10-13 06:12:01.603092+00
161	2	糸	いと	benang	赤い糸を使って縫います。あかいいとをつかってぬいます。	Saya menjahit menggunakan benang merah.	Konteks: benang. Kata 「糸」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:03.051636+00	2026-10-13 06:12:03.051636+00
162	2	芋	いも	umbi; kentang	秋には焼き芋を食べます。あきにはやきいもをたべます。	Pada musim gugur saya makan ubi panggang.	Konteks: umbi; kentang. Kata 「芋」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:04.492351+00	2026-10-13 06:12:04.492351+00
163	2	歌	うた	lagu	この歌をよく聞きます。このうたをよくききます。	Saya sering mendengarkan lagu ini.	Konteks: lagu. Kata 「歌」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:07.285728+00	2026-10-13 06:12:07.285728+00
164	2	内	うち	bagian dalam	建物の内には入れません。たてもののうちにははいれません。	Tidak boleh masuk ke bagian dalam bangunan.	Konteks: bagian dalam. Kata 「内」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:10.317131+00	2026-10-13 06:12:10.317131+00
165	2	器	うつわ	wadah; mangkuk	この器に料理を入れます。このうつわにりょうりをいれます。	Saya memasukkan makanan ke wadah ini.	Konteks: wadah; mangkuk. Kata 「器」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:13.265468+00	2026-10-13 06:12:13.265468+00
166	2	腕	うで	lengan	運動した後、腕が痛くなりました。うんどうしたあと、うでがいたくなりました。	Setelah berolahraga, lengan saya sakit.	Konteks: lengan. Kata 「腕」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:15.473928+00	2026-10-13 06:12:15.473928+00
167	2	絵	え	gambar; lukisan	妹は絵を描くのが好きです。いもうとはえをかくのがすきです。	Adik perempuan saya suka menggambar.	Konteks: gambar; lukisan. Kata 「絵」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:16.882618+00	2026-10-13 06:12:16.882618+00
168	2	枝	えだ	ranting; cabang pohon	風で木の枝が折れました。かぜできのえだがおれました。	Ranting pohon patah karena angin.	Konteks: ranting; cabang pohon. Kata 「枝」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:18.315864+00	2026-10-13 06:12:18.315864+00
169	2	奥	おく	bagian dalam; belakang	部屋の奥に机があります。へやのおくにつくえがあります。	Ada meja di bagian belakang kamar.	Konteks: bagian dalam; belakang. Kata 「奥」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:19.750462+00	2026-10-13 06:12:19.750462+00
225	2	暑い	あつい	panas (cuaca)	今日はとても暑いです。きょうはとてもあついです。	Hari ini sangat panas.	Konteks: panas (cuaca). Kata 「暑い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:40.419205+00	2026-10-13 06:13:40.419205+00
170	2	音	おと	bunyi; suara	外から大きな音が聞こえます。そとからおおきなおとがきこえます。	Terdengar suara keras dari luar.	Konteks: bunyi; suara. Kata 「音」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:12:21.199179+00	2026-10-13 06:12:21.199179+00
171	2	合図	あいず	isyarat; tanda	先生が合図を出しました。せんせいがあいずをだしました。	Guru memberikan isyarat.	Konteks: isyarat; tanda. Kata 「合図」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:22.607612+00	2026-10-13 06:12:22.607612+00
172	2	相手	あいて	lawan; pasangan; pihak lain	相手の話をよく聞きます。あいてのはなしをよくききます。	Saya mendengarkan perkataan lawan bicara dengan baik.	Konteks: lawan; pasangan; pihak lain. Kata 「相手」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:24.042135+00	2026-10-13 06:12:24.042135+00
173	2	青空	あおぞら	langit biru	今日は青空が広がっています。きょうはあおぞらがひろがっています。	Hari ini langit biru terbentang luas.	Konteks: langit biru. Kata 「青空」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:25.492777+00	2026-10-13 06:12:25.492777+00
174	2	安心	あんしん	rasa lega; ketenangan	無事だと聞いて安心しました。ぶじだときいてあんしんしました。	Saya lega setelah mendengar bahwa semuanya selamat.	Konteks: rasa lega; ketenangan. Kata 「安心」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:26.914177+00	2026-10-13 06:12:26.914177+00
175	2	案内	あんない	panduan; mengantar	駅まで友達を案内します。えきまでともだちをあんないします。	Saya mengantar teman menuju stasiun.	Konteks: panduan; mengantar. Kata 「案内」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:28.355862+00	2026-10-13 06:12:28.355862+00
176	2	以下	いか	di bawah; tidak lebih dari	参加者は十人以下です。さんかしゃはじゅうにんいかです。	Pesertanya tidak lebih dari sepuluh orang.	Konteks: di bawah; tidak lebih dari. Kata 「以下」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:30.03457+00	2026-10-13 06:12:30.03457+00
177	2	以外	いがい	selain; kecuali	日曜日以外は働いています。にちようびいがいははたらいています。	Saya bekerja setiap hari kecuali Minggu.	Konteks: selain; kecuali. Kata 「以外」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:31.465987+00	2026-10-13 06:12:31.465987+00
178	2	意見	いけん	pendapat	会議で自分の意見を言いました。かいぎでじぶんのいけんをいいました。	Saya menyampaikan pendapat dalam rapat.	Konteks: pendapat. Kata 「意見」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:32.902792+00	2026-10-13 06:12:32.902792+00
179	2	以降	いこう	sejak; setelah	来月以降に始めます。らいげついこうにはじめます。	Saya akan memulainya bulan depan atau setelahnya.	Konteks: sejak; setelah. Kata 「以降」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:34.396647+00	2026-10-13 06:12:34.396647+00
180	2	維持	いじ	mempertahankan; pemeliharaan	健康を維持することが大切です。けんこうをいじすることがたいせつです。	Menjaga kesehatan itu penting.	Konteks: mempertahankan; pemeliharaan. Kata 「維持」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:35.785205+00	2026-10-13 06:12:35.785205+00
181	2	一緒	いっしょ	bersama	友達と一緒に勉強します。ともだちといっしょにべんきょうします。	Saya belajar bersama teman.	Konteks: bersama. Kata 「一緒」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:37.223837+00	2026-10-13 06:12:37.223837+00
182	2	一般	いっぱん	umum; masyarakat umum	これは一般の人も参加できます。これはいっぱんのひともさんかできます。	Masyarakat umum juga dapat berpartisipasi.	Konteks: umum; masyarakat umum. Kata 「一般」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:38.659796+00	2026-10-13 06:12:38.659796+00
183	2	移動	いどう	perpindahan; bergerak	電車で移動します。でんしゃでいどうします。	Saya berpindah tempat menggunakan kereta.	Konteks: perpindahan; bergerak. Kata 「移動」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:40.096914+00	2026-10-13 06:12:40.096914+00
184	2	以内	いない	dalam batas; tidak lebih dari	十分以内に戻ります。じゅっぷんいないにもどります。	Saya kembali dalam sepuluh menit.	Konteks: dalam batas; tidak lebih dari. Kata 「以内」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:41.522517+00	2026-10-13 06:12:41.522517+00
185	2	田舎	いなか	desa; pedesaan	祖父は田舎に住んでいます。そふはいなかにすんでいます。	Kakek saya tinggal di desa.	Konteks: desa; pedesaan. Kata 「田舎」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:42.965785+00	2026-10-13 06:12:42.965785+00
186	2	居間	いま	ruang keluarga	家族は居間でテレビを見ています。かぞくはいまでてれびをみています。	Keluarga sedang menonton televisi di ruang keluarga.	Konteks: ruang keluarga. Kata 「居間」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:44.389879+00	2026-10-13 06:12:44.389879+00
187	2	意味	いみ	arti; makna	この言葉の意味を教えてください。このことばのいみをおしえてください。	Tolong beri tahu arti kata ini.	Konteks: arti; makna. Kata 「意味」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:45.817289+00	2026-10-13 06:12:45.817289+00
188	2	印刷	いんさつ	mencetak; pencetakan	資料を印刷してください。しりょうをいんさつしてください。	Tolong cetak dokumennya.	Konteks: mencetak; pencetakan. Kata 「印刷」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:47.254796+00	2026-10-13 06:12:47.254796+00
189	2	印象	いんしょう	kesan	彼の第一印象はよかったです。かれのだいいちいんしょうはよかったです。	Kesan pertama saya terhadapnya baik.	Konteks: kesan. Kata 「印象」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:48.699248+00	2026-10-13 06:12:48.699248+00
190	2	飲食	いんしょく	makan dan minum	ここでは飲食が禁止されています。ここではいんしょくがきんしされています。	Makan dan minum dilarang di sini.	Konteks: makan dan minum. Kata 「飲食」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:12:50.117156+00	2026-10-13 06:12:50.117156+00
191	2	影響	えいきょう	pengaruh; dampak	台風は交通に影響を与えました。たいふうはこうつうにえいきょうをあたえました。	Topan memberikan dampak pada transportasi.	Konteks: pengaruh; dampak. Kata 「影響」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:12:51.555586+00	2026-10-13 06:12:51.555586+00
192	2	営業	えいぎょう	operasional usaha; bisnis	この店は夜十時まで営業しています。このみせはよるじゅうじまでえいぎょうしています。	Toko ini beroperasi sampai pukul sepuluh malam.	Konteks: operasional usaha; bisnis. Kata 「営業」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:12:52.991416+00	2026-10-13 06:12:52.991416+00
193	2	栄養	えいよう	nutrisi; gizi	栄養のある食事を食べましょう。えいようのあるしょくじをたべましょう。	Mari makan makanan yang bergizi.	Konteks: nutrisi; gizi. Kata 「栄養」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:12:54.454211+00	2026-10-13 06:12:54.454211+00
194	2	笑顔	えがお	senyuman	彼女はいつも笑顔です。かのじょはいつもえがおです。	Dia selalu tersenyum.	Konteks: senyuman. Kata 「笑顔」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:12:55.867962+00	2026-10-13 06:12:55.867962+00
195	2	駅前	えきまえ	depan stasiun	駅前に新しい店ができました。えきまえにあたらしいみせができました。	Ada toko baru di depan stasiun.	Konteks: depan stasiun. Kata 「駅前」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:12:57.303846+00	2026-10-13 06:12:57.303846+00
196	2	延期	えんき	penundaan	雨で試合が延期になりました。あめでしあいがえんきになりました。	Pertandingan ditunda karena hujan.	Konteks: penundaan. Kata 「延期」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:12:58.740069+00	2026-10-13 06:12:58.740069+00
197	2	演奏	えんそう	pertunjukan musik; memainkan alat musik	彼はピアノを演奏します。かれはぴあのをえんそうします。	Dia memainkan piano.	Konteks: pertunjukan musik; memainkan alat musik. Kata 「演奏」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:13:00.177645+00	2026-10-13 06:13:00.177645+00
198	2	遠慮	えんりょ	sungkan; menahan diri	遠慮しないで食べてください。えんりょしないでたべてください。	Silakan makan tanpa sungkan.	Konteks: sungkan; menahan diri. Kata 「遠慮」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:13:01.611697+00	2026-10-13 06:13:01.611697+00
199	2	応援	おうえん	dukungan; menyemangati	友達の試合を応援しました。ともだちのしあいをおうえんしました。	Saya menyemangati teman dalam pertandingan.	Konteks: dukungan; menyemangati. Kata 「応援」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:13:03.0534+00	2026-10-13 06:13:03.0534+00
200	2	横断	おうだん	menyeberang; melintasi	道路を横断するときは気を付けてください。どうろをおうだんするときはきをつけてください。	Berhati-hatilah ketika menyeberang jalan.	Konteks: menyeberang; melintasi. Kata 「横断」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:13:04.559086+00	2026-10-13 06:13:04.559086+00
13	1	雑学	ざつがく	Pengetahuan/wawasan	雑学を学びます。	Saya mempelajari pengetahuan umum.	「雑学」 berarti pengetahuan umum atau wawasan tentang berbagai hal yang tidak terkait satu bidang tertentu. Kata ini sering dipakai untuk trivia atau pengetahuan yang dibagikan dalam percakapan santai.				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:55:08.070827+00
202	2	飽きる	あきる	bosan	同じ料理を毎日食べると飽きます。おなじりょうりをまいにちたべるとあきます。	Jika makan masakan yang sama setiap hari, kita akan bosan.	Konteks: bosan. Kata 「飽きる」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:07.371943+00	2026-10-13 06:13:07.371943+00
203	2	空く	あく	kosong; tersedia	午後なら時間が空いています。ごごならじかんがあいています。	Kalau sore, saya punya waktu luang.	Konteks: kosong; tersedia. Kata 「空く」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:08.827688+00	2026-10-13 06:13:08.827688+00
204	2	空ける	あける	mengosongkan; memberi ruang	明日の午後は時間を空けておきます。あしたのごごはじかんをあけておきます。	Saya akan meluangkan waktu besok sore.	Konteks: mengosongkan; memberi ruang. Kata 「空ける」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:10.255621+00	2026-10-13 06:13:10.255621+00
205	2	預ける	あずける	menitipkan	荷物をホテルに預けました。にもつをほてるにあずけました。	Saya menitipkan barang di hotel.	Konteks: menitipkan. Kata 「預ける」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:11.688768+00	2026-10-13 06:13:11.688768+00
206	2	与える	あたえる	memberikan; menyebabkan	先生は学生に助言を与えました。せんせいはがくせいにじょげんをあたえました。	Guru memberikan nasihat kepada murid.	Konteks: memberikan; menyebabkan. Kata 「与える」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:13.120633+00	2026-10-13 06:13:13.120633+00
207	2	温める	あたためる	menghangatkan	電子レンジでご飯を温めます。でんしれんじでごはんをあたためます。	Saya menghangatkan nasi dengan microwave.	Konteks: menghangatkan. Kata 「温める」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:14.564346+00	2026-10-13 06:13:14.564346+00
208	2	謝る	あやまる	meminta maaf	遅刻したので先生に謝りました。ちこくしたのでせんせいにあやまりました。	Karena terlambat, saya meminta maaf kepada guru.	Konteks: meminta maaf. Kata 「謝る」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:16.001181+00	2026-10-13 06:13:16.001181+00
209	2	表す	あらわす	mengungkapkan; menyatakan	言葉で感謝の気持ちを表します。ことばでかんしゃのきもちをあらわします。	Saya mengungkapkan rasa terima kasih dengan kata-kata.	Konteks: mengungkapkan; menyatakan. Kata 「表す」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:17.456038+00	2026-10-13 06:13:17.456038+00
210	2	慌てる	あわてる	panik; tergesa-gesa	慌てないで落ち着いてください。あわてないでおちついてください。	Jangan panik, tenangkan diri.	Konteks: panik; tergesa-gesa. Kata 「慌てる」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:18.902988+00	2026-10-13 06:13:18.902988+00
211	2	選ぶ	えらぶ	memilih	好きな色を選んでください。すきないろをえらんでください。	Silakan pilih warna yang disukai.	Konteks: memilih. Kata 「選ぶ」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:20.320259+00	2026-10-13 06:13:20.320259+00
212	2	隠す	かくす	menyembunyikan	大切な物を箱の中に隠しました。たいせつなものをはこのなかにかくしました。	Saya menyembunyikan barang penting di dalam kotak.	Konteks: menyembunyikan. Kata 「隠す」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:21.751541+00	2026-10-13 06:13:21.751541+00
213	2	飾る	かざる	menghias; memajang	部屋に花を飾りました。へやにはなをかざりました。	Saya menghias kamar dengan bunga.	Konteks: menghias; memajang. Kata 「飾る」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:23.206415+00	2026-10-13 06:13:23.206415+00
214	2	貸す	かす	meminjamkan	友達に本を貸しました。ともだちにほんをかしました。	Saya meminjamkan buku kepada teman.	Konteks: meminjamkan. Kata 「貸す」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:24.635764+00	2026-10-13 06:13:24.635764+00
215	2	稼ぐ	かせぐ	menghasilkan uang	アルバイトでお金を稼ぎます。あるばいとでおかねをかせぎます。	Saya menghasilkan uang dari kerja paruh waktu.	Konteks: menghasilkan uang. Kata 「稼ぐ」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:26.058745+00	2026-10-13 06:13:26.058745+00
216	2	片付ける	かたづける	membereskan; merapikan	使った物を片付けてください。つかったものをかたづけてください。	Tolong rapikan barang yang sudah digunakan.	Konteks: membereskan; merapikan. Kata 「片付ける」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:27.507964+00	2026-10-13 06:13:27.507964+00
217	2	勝つ	かつ	menang	私たちのチームが試合に勝ちました。わたしたちのちーむがしあいにかちました。	Tim kami memenangkan pertandingan.	Konteks: menang. Kata 「勝つ」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:28.935623+00	2026-10-13 06:13:28.935623+00
218	2	借りる	かりる	meminjam	図書館で本を借りました。としょかんでほんをかりました。	Saya meminjam buku di perpustakaan.	Konteks: meminjam. Kata 「借りる」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:30.371164+00	2026-10-13 06:13:30.371164+00
219	2	乾く	かわく	menjadi kering	洗濯物がよく乾きました。せんたくものがよくかわきました。	Cucian sudah kering dengan baik.	Konteks: menjadi kering. Kata 「乾く」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:31.809957+00	2026-10-13 06:13:31.809957+00
220	2	変わる	かわる	berubah	季節が変わりました。きせつがかわりました。	Musim telah berubah.	Konteks: berubah. Kata 「変わる」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:13:33.237293+00	2026-10-13 06:13:33.237293+00
221	2	明るい	あかるい	terang; ceria	この部屋はとても明るいです。このへやはとてもあかるいです。	Kamar ini sangat terang.	Konteks: terang; ceria. Kata 「明るい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:34.674614+00	2026-10-13 06:13:34.674614+00
222	2	浅い	あさい	dangkal	この川は浅いです。このかわはあさいです。	Sungai ini dangkal.	Konteks: dangkal. Kata 「浅い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:36.10985+00	2026-10-13 06:13:36.10985+00
223	2	暖かい	あたたかい	hangat (cuaca; udara)	今日は暖かいですね。きょうはあたたかいですね。	Hari ini hangat, ya.	Konteks: hangat (cuaca; udara). Kata 「暖かい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:37.545533+00	2026-10-13 06:13:37.545533+00
224	2	新しい	あたらしい	baru	新しいかばんを買いました。あたらしいかばんをかいました。	Saya membeli tas baru.	Konteks: baru. Kata 「新しい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:38.973908+00	2026-10-13 06:13:38.973908+00
526	4	専門店	せんもんてん	Toko khusus	この専門店で本を買います。 このせんもんてんでほんをかいます。	Saya membeli buku di toko khusus ini.	💡 Konteks Penggunaan:\n専門店 dipakai untuk toko yang menjual barang tertentu, seperti toko buku, toko alat musik, atau toko makanan khas.\n\n📝 Catatan:\nKata 「専門店」 berkolokasi dengan 専門店で買う、専門店に行く dan 専門店ならでは; frasa 専門店ならでは berarti khas toko khusus.\nKata 「専門店」 digunakan dalam contoh kalimat: "この専門店で本を買います。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:36:08.371383+00
539	4	到着	とうちゃく	Kedatangan	電車が到着しました。 でんしゃがとうちゃくしました。	Kereta telah tiba.	💡 Konteks Penggunaan:\n到着 dipakai untuk kedatangan, seperti kedatangan kereta, pesawat, atau seseorang di suatu tempat.\n\n📝 Catatan:\nKata 「到着」 berkolokasi dengan 到着する、到着時間 dan 到着予定; kata 到着予定 berarti jadwal kedatangan.\nKata 「到着」 digunakan dalam contoh kalimat: "電車が到着しました。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:41:09.300162+00
227	2	厚い	あつい	tebal	この本はとても厚いです。このほんはとてもあついです。	Buku ini sangat tebal.	Konteks: tebal. Kata 「厚い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:43.290685+00	2026-10-13 06:13:43.290685+00
228	2	危ない	あぶない	berbahaya	そこは危ないので行かないでください。そこはあぶないのでいかないでください。	Tempat itu berbahaya, jadi jangan pergi ke sana.	Konteks: berbahaya. Kata 「危ない」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:44.724065+00	2026-10-13 06:13:44.724065+00
229	2	甘い	あまい	manis	このケーキは甘いです。このけーきはあまいです。	Kue ini manis.	Konteks: manis. Kata 「甘い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:46.155146+00	2026-10-13 06:13:46.155146+00
230	2	美しい	うつくしい	indah; cantik	山の景色が美しいです。やまのけしきがうつくしいです。	Pemandangan gunung itu indah.	Konteks: indah; cantik. Kata 「美しい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:13:47.588314+00	2026-10-13 06:13:47.588314+00
231	2	安全な	あんぜんな	aman	ここは安全な場所です。ここはあんぜんなばしょです。	Ini adalah tempat yang aman.	Konteks: aman. Kata 「安全な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:49.035597+00	2026-10-13 06:13:49.035597+00
232	2	意外な	いがいな	tidak terduga	意外な結果になりました。いがいなけっかになりました。	Hasilnya ternyata tidak terduga.	Konteks: tidak terduga. Kata 「意外な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:50.452021+00	2026-10-13 06:13:50.452021+00
233	2	一般的な	いっぱんてきな	umum; lazim	これは一般的な方法です。これはいっぱんてきなほうほうです。	Ini adalah metode yang umum.	Konteks: umum; lazim. Kata 「一般的な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:51.904291+00	2026-10-13 06:13:51.904291+00
234	2	嫌な	いやな	tidak menyenangkan	今日は嫌なことがありました。きょうはいやなことがありました。	Hari ini ada kejadian yang tidak menyenangkan.	Konteks: tidak menyenangkan. Kata 「嫌な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:53.341289+00	2026-10-13 06:13:53.341289+00
235	2	確実な	かくじつな	pasti; dapat diandalkan	確実な情報を確認してください。かくじつなじょうほうをかくにんしてください。	Tolong pastikan informasi yang dapat diandalkan.	Konteks: pasti; dapat diandalkan. Kata 「確実な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:54.786443+00	2026-10-13 06:13:54.786443+00
236	2	活動的な	かつどうてきな	aktif	彼は活動的な人です。かれはかつどうてきなひとです。	Dia adalah orang yang aktif.	Konteks: aktif. Kata 「活動的な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:56.212576+00	2026-10-13 06:13:56.212576+00
237	2	可能な	かのうな	memungkinkan; bisa dilakukan	可能な方法を考えましょう。かのうなほうほうをかんがえましょう。	Mari pikirkan metode yang memungkinkan.	Konteks: memungkinkan; bisa dilakukan. Kata 「可能な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:57.649514+00	2026-10-13 06:13:57.649514+00
238	2	簡単な	かんたんな	mudah; sederhana	これは簡単な問題です。これはかんたんなもんだいです。	Ini adalah soal yang mudah.	Konteks: mudah; sederhana. Kata 「簡単な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:13:59.089928+00	2026-10-13 06:13:59.089928+00
239	2	危険な	きけんな	berbahaya	危険な場所に入らないでください。きけんなばしょにはいらないでください。	Jangan masuk ke tempat yang berbahaya.	Konteks: berbahaya. Kata 「危険な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:14:00.520209+00	2026-10-13 06:14:00.520209+00
240	2	健康な	けんこうな	sehat	健康な生活を送りたいです。けんこうなせいかつをおくりたいです。	Saya ingin menjalani kehidupan yang sehat.	Konteks: sehat. Kata 「健康な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:14:01.994781+00	2026-10-13 06:14:01.994781+00
241	2	相変わらず	あいかわらず	seperti biasa; tetap sama	彼は相変わらず元気です。かれはあいかわらずげんきです。	Dia tetap sehat dan bersemangat seperti biasanya.	Konteks: seperti biasa; tetap sama. Kata 「相変わらず」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:03.654512+00	2026-10-13 06:14:03.654512+00
242	2	一応	いちおう	untuk sementara; sekadarnya	一応、先生に確認しました。いちおう、せんせいにかくにんしました。	Untuk berjaga-jaga, saya sudah memastikannya kepada guru.	Konteks: untuk sementara; sekadarnya. Kata 「一応」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:05.090073+00	2026-10-13 06:14:05.090073+00
243	2	一度に	いちどに	sekaligus	一度に全部食べないでください。いちどにぜんぶたべないでください。	Jangan makan semuanya sekaligus.	Konteks: sekaligus. Kata 「一度に」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:06.524756+00	2026-10-13 06:14:06.524756+00
244	2	今にも	いまにも	sebentar lagi; tampaknya akan segera	今にも雨が降りそうです。いまにもあめがふりそうです。	Sepertinya hujan akan segera turun.	Konteks: sebentar lagi; tampaknya akan segera. Kata 「今にも」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:07.96869+00	2026-10-13 06:14:07.96869+00
245	2	主に	おもに	terutama	この店では主に野菜を売っています。このみせではおもにやさいをうっています。	Toko ini terutama menjual sayuran.	Konteks: terutama. Kata 「主に」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:09.439747+00	2026-10-13 06:14:09.439747+00
246	2	必ず	かならず	pasti; tanpa gagal	明日は必ず来てください。あしたはかならずきてください。	Besok pastikan datang.	Konteks: pasti; tanpa gagal. Kata 「必ず」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:10.868081+00	2026-10-13 06:14:10.868081+00
247	2	偶然	ぐうぜん	secara kebetulan	駅で偶然友達に会いました。えきでぐうぜんともだちにあいました。	Saya kebetulan bertemu teman di stasiun.	Konteks: secara kebetulan. Kata 「偶然」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:12.275396+00	2026-10-13 06:14:12.275396+00
248	2	結局	けっきょく	akhirnya; pada akhirnya	結局、家に帰ることにしました。けっきょく、いえにかえることにしました。	Akhirnya, saya memutuskan pulang.	Konteks: akhirnya; pada akhirnya. Kata 「結局」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:13.696991+00	2026-10-13 06:14:13.696991+00
249	2	決して	けっして	sama sekali tidak (dengan bentuk negatif)	このことは決して忘れません。このことはけっしてわすれません。	Saya tidak akan pernah melupakan hal ini.	Konteks: sama sekali tidak (dengan bentuk negatif). Kata 「決して」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:15.142607+00	2026-10-13 06:14:15.142607+00
250	2	次第に	しだいに	secara bertahap	日本語が次第に分かるようになりました。にほんごがしだいにわかるようになりました。	Sedikit demi sedikit saya mulai memahami bahasa Jepang.	Konteks: secara bertahap. Kata 「次第に」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:14:16.604042+00	2026-10-13 06:14:16.604042+00
27	1	回転	かいてん	Rotasi/Perputaran	地球は回転します。	Bumi berputar.	「回転」 berarti rotasi atau perputaran. Kata ini dipakai untuk gerakan memutar benda atau mesin, dan berkolokasi dengan 回転する dan 回転する方向。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 09:00:03.244698+00
262	2	柄	がら	pola; motif	この服の柄が好きです。このふくのがらがすきです。	Saya suka pola baju ini.	Konteks: pola; motif. Kata 「柄」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:29.520008+00	2026-10-13 06:36:29.520008+00
263	2	帯	おび	sabuk (kimono); obi	着物の帯を締めます。きもののおびをしめます。	Saya mengencangkan obi kimono.	Konteks: sabuk (kimono); obi. Kata 「帯」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:30.915215+00	2026-10-13 06:36:30.915215+00
264	2	黄	き	kuning	信号が黄に変わりました。しんごうがきにかわりました。	Lampu lalu lintas berubah kuning.	Konteks: kuning. Kata 「黄」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:32.350337+00	2026-10-13 06:36:32.350337+00
265	2	表	おもて	permukaan; depan	カードの表を見てください。かーどのおもてをみてください。	Tolong lihat bagian depan kartu.	Konteks: permukaan; depan. Kata 「表」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:33.788157+00	2026-10-13 06:36:33.788157+00
266	2	親	おや	orang tua	親に手紙を書きました。おやにてがみをかきました。	Saya menulis surat untuk orang tua.	Konteks: orang tua. Kata 「親」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:35.202126+00	2026-10-13 06:36:35.202126+00
267	2	貝	かい	kerang	海で貝を拾いました。うみでかいをひろいました。	Saya memungut kerang di laut.	Konteks: kerang. Kata 「貝」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:36.658013+00	2026-10-13 06:36:36.658013+00
268	2	顔	かお	wajah	朝、顔を洗います。あさ、かおをあらいます。	Di pagi hari, saya mencuci wajah.	Konteks: wajah. Kata 「顔」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:38.117091+00	2026-10-13 06:36:38.117091+00
269	2	傘	かさ	payung	雨が降っているので傘をさします。あめがふっているのでかさをさします。	Karena hujan turun, saya memakai payung.	Konteks: payung. Kata 「傘」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:39.508335+00	2026-10-13 06:36:39.508335+00
270	2	数	かず	jumlah	参加者の数を数えます。さんかしゃのかずをかぞえます。	Saya menghitung jumlah peserta.	Konteks: jumlah. Kata 「数」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:40.958928+00	2026-10-13 06:36:40.958928+00
271	2	肩	かた	bahu	荷物が重くて肩が痛いです。にもつがおもくてかたがいたいです。	Bahu saya sakit karena barang bawaannya berat.	Konteks: bahu. Kata 「肩」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:42.381262+00	2026-10-13 06:36:42.381262+00
272	2	靴	くつ	sepatu	新しい靴を買いました。あたらしいくつをかいました。	Saya membeli sepatu baru.	Konteks: sepatu. Kata 「靴」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:43.827378+00	2026-10-13 06:36:43.827378+00
273	2	首	くび	leher	寒くて首が痛くなりました。さむくてくびがいたくなりました。	Leher saya sakit karena kedinginan.	Konteks: leher. Kata 「首」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:45.263817+00	2026-10-13 06:36:45.263817+00
274	2	雲	くも	awan	空に白い雲が浮かんでいます。そらにしろいくもがうかんでいます。	Awan putih mengambang di langit.	Konteks: awan. Kata 「雲」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:46.683912+00	2026-10-13 06:36:46.683912+00
275	2	煙	けむり	asap	火事の煙が見えます。かじのけむりがみえます。	Terlihat asap kebakaran.	Konteks: asap. Kata 「煙」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:48.12662+00	2026-10-13 06:36:48.12662+00
276	2	県	けん	prefektur	青森県に住んでいます。あおもりけんにすんでいます。	Saya tinggal di prefektur Aomori.	Konteks: prefektur. Kata 「県」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:49.570732+00	2026-10-13 06:36:49.570732+00
277	2	腰	こし	pinggang	重い物を持って腰を痛めました。おもいものを もってこしをいためました。	Pinggang saya sakit karena mengangkat barang berat.	Konteks: pinggang. Kata 「腰」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:51.010897+00	2026-10-13 06:36:51.010897+00
278	2	粉	こな	bubuk; tepung	小麦粉でパンを作ります。こむぎこでぱんをつくります。	Saya membuat roti dengan tepung terigu.	Konteks: bubuk; tepung. Kata 「粉」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:52.459758+00	2026-10-13 06:36:52.459758+00
279	2	差	さ	perbedaan	二人の実力に差があります。ふたりのじつりょくにさがあります。	Ada perbedaan pada kemampuan mereka berdua.	Konteks: perbedaan. Kata 「差」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:53.886729+00	2026-10-13 06:36:53.886729+00
280	2	坂	さか	tanjakan; bukit	自転車で坂を上ります。じてんしゃでさかをのぼります。	Saya menaiki tanjakan dengan sepeda.	Konteks: tanjakan; bukit. Kata 「坂」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:55.318785+00	2026-10-13 06:36:55.318785+00
281	2	桜	さくら	bunga sakura	春には桜が咲きます。はるにはさくらがさきます。	Bunga sakura mekar di musim semi.	Konteks: bunga sakura. Kata 「桜」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（1文字）, halaman 10.				\N	f	2026-10-13 06:36:56.747665+00	2026-10-13 06:36:56.747665+00
282	2	意識	いしき	kesadaran	健康を意識して生活します。けんこうをいしきしてせいかつします。	Saya hidup dengan menyadari kesehatan.	Konteks: kesadaran. Kata 「意識」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:36:58.182022+00	2026-10-13 06:36:58.182022+00
283	2	医者	いしゃ	dokter	風邪を引いたので医者に行きます。かぜをひいたのでいしゃにいきます。	Karena masuk angin, saya pergi ke dokter.	Konteks: dokter. Kata 「医者」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:36:59.617481+00	2026-10-13 06:36:59.617481+00
284	2	以上	いじょう	lebih dari; ke atas	百人以上の人が集まりました。ひゃくにんいじょうのひとがあつまりました。	Lebih dari seratus orang berkumpul.	Konteks: lebih dari; ke atas. Kata 「以上」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:01.046943+00	2026-10-13 06:37:01.046943+00
285	2	以前	いぜん	sebelumnya	以前、この町に住んでいました。いぜん、このまちにすんでいました。	Sebelumnya, saya tinggal di kota ini.	Konteks: sebelumnya. Kata 「以前」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:02.473024+00	2026-10-13 06:37:02.473024+00
286	2	位置	いち	posisi; letak	地図で現在地の位置を確認します。ちずでげんざいちのいちをかくにんします。	Saya mengecek posisi saat ini di peta.	Konteks: posisi; letak. Kata 「位置」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:03.907656+00	2026-10-13 06:37:03.907656+00
287	2	飲料	いんりょう	minuman	冷たい飲料を買いました。つめたいいんりょうをかいました。	Saya membeli minuman dingin.	Konteks: minuman. Kata 「飲料」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:05.339069+00	2026-10-13 06:37:05.339069+00
288	2	受付	うけつけ	resepsionis	ホテルの受付で鍵をもらいます。ほてるのうけつけでかぎをもらいます。	Saya menerima kunci di resepsionis hotel.	Konteks: resepsionis. Kata 「受付」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:06.78196+00	2026-10-13 06:37:06.78196+00
289	2	運転	うんてん	mengemudi	毎日車を運転します。まいにちくるまをうんてんします。	Saya mengemudi mobil setiap hari.	Konteks: mengemudi. Kata 「運転」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:08.215755+00	2026-10-13 06:37:08.215755+00
290	2	運動	うんどう	olahraga	健康のために運動をします。けんこうのためにうんどうをします。	Saya berolahraga untuk kesehatan.	Konteks: olahraga. Kata 「運動」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:09.643572+00	2026-10-13 06:37:09.643572+00
291	2	映画	えいが	film	週末に友達と映画を見ます。しゅうまつにともだちとえいがをみます。	Saya menonton film dengan teman di akhir pekan.	Konteks: film. Kata 「映画」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 12.				\N	f	2026-10-13 06:37:11.069224+00	2026-10-13 06:37:11.069224+00
292	2	往復	おうふく	perjalanan pulang pergi	駅まで往復で一時間かかります。えきまでおうふくでいちじかんかかります。	Butuh satu jam perjalanan bolak-balik ke stasiun.	Konteks: perjalanan pulang pergi. Kata 「往復」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:12.501761+00	2026-10-13 06:37:12.501761+00
293	2	応募	おうぼ	pendaftaran; lamaran	新しい仕事に応募しました。あたらしいしごとにおうぼしました。	Saya melamar pekerjaan baru.	Konteks: pendaftaran; lamaran. Kata 「応募」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:13.945258+00	2026-10-13 06:37:13.945258+00
294	2	応用	おうよう	penerapan; aplikasi	この技術はいろいろな分野に応用できます。このぎじゅつはいろいろなぶんやにおうようできます。	Teknologi ini dapat diterapkan di berbagai bidang.	Konteks: penerapan; aplikasi. Kata 「応用」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:15.368515+00	2026-10-13 06:37:15.368515+00
295	2	音楽	おんがく	musik	音楽を聴きながら勉強します。おんがくをききながらべんきょうします。	Saya belajar sambil mendengarkan musik.	Konteks: musik. Kata 「音楽」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:16.793849+00	2026-10-13 06:37:16.793849+00
14	1	存在	そんざい	Keberadaan	問題は存在します。	Masalah itu ada.	「存在」 berarti keberadaan atau adanya sesuatu. Kata ini dipakai dalam konteks formal atau tulisan, misalnya keberadaan suatu masalah, benda, atau makhluk, dan berkolokasi dengan 存在する。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:55:28.794398+00
296	2	温泉	おんせん	sumber air panas	冬は温泉に入りたいです。ふゆはおんせんにはいりたいです。	Saya ingin masuk ke pemandian air panas di musim dingin.	Konteks: sumber air panas. Kata 「温泉」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:18.226435+00	2026-10-13 06:37:18.226435+00
297	2	温度	おんど	suhu	部屋の温度を調節します。へやのおんどをちょうせつします。	Saya mengatur suhu ruangan.	Konteks: suhu. Kata 「温度」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:19.663539+00	2026-10-13 06:37:19.663539+00
298	2	会議	かいぎ	rapat	午後から会議があります。ごごからかいぎがあります。	Ada rapat mulai dari siang.	Konteks: rapat. Kata 「会議」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:21.100011+00	2026-10-13 06:37:21.100011+00
299	2	解決	かいけつ	penyelesaian	問題がやっと解決しました。もんだいがやっとかいけつしました。	Masalah akhirnya terselesaikan.	Konteks: penyelesaian. Kata 「解決」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:22.525033+00	2026-10-13 06:37:22.525033+00
300	2	改札	かいさつ	gerbang tiket	駅の改札で友達と待ち合わせます。えきのかいさつでともだちとまちあわせます。	Saya janjian dengan teman di gerbang tiket stasiun.	Konteks: gerbang tiket. Kata 「改札」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:23.961178+00	2026-10-13 06:37:23.961178+00
301	2	階段	かいだん	tangga	階段を上って二階へ行きます。かいだんをのぼってにかいへいきます。	Saya naik tangga lalu pergi ke lantai dua.	Konteks: tangga. Kata 「階段」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 13.				\N	f	2026-10-13 06:37:25.407952+00	2026-10-13 06:37:25.407952+00
302	2	価格	かかく	harga	商品の価格が上がりました。しょうひんのかかくがあがりました。	Harga barang telah naik.	Konteks: harga. Kata 「価格」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:26.828916+00	2026-10-13 06:37:26.828916+00
303	2	科学	かがく	sains; ilmu pengetahuan	科学の進歩は素晴らしいです。かがくのしんぽはすばらしいです。	Kemajuan ilmu pengetahuan sangat luar biasa.	Konteks: sains; ilmu pengetahuan. Kata 「科学」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:28.460905+00	2026-10-13 06:37:28.460905+00
304	2	家具	かぐ	furnitur	新しい部屋に家具を置きます。あたらしいへやにかぐをおきます。	Saya meletakkan furnitur di kamar baru.	Konteks: furnitur. Kata 「家具」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:30.166368+00	2026-10-13 06:37:30.166368+00
305	2	確認	かくにん	konfirmasi; pengecekan	出発前にパスポートを確認してください。しゅっぱつまえにぱすぽーとをかくにんしてください。	Tolong periksa paspor sebelum keberangkatan.	Konteks: konfirmasi; pengecekan. Kata 「確認」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:31.602307+00	2026-10-13 06:37:31.602307+00
306	2	過去	かこ	masa lalu	過去の失敗から学びます。かこのしっぱいからまなびます。	Saya belajar dari kegagalan masa lalu.	Konteks: masa lalu. Kata 「過去」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:33.038696+00	2026-10-13 06:37:33.038696+00
307	2	火災	かさい	kebakaran	火災の時は落ち着いて逃げてください。かさいのときはおちついてにげてください。	Saat kebakaran, tolong lari dengan tenang.	Konteks: kebakaran. Kata 「火災」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:34.46785+00	2026-10-13 06:37:34.46785+00
308	2	価値	かち	nilai	この絵には高い価値があります。このえにはたかいかちがあります。	Lukisan ini memiliki nilai yang tinggi.	Konteks: nilai. Kata 「価値」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:35.911264+00	2026-10-13 06:37:35.911264+00
309	2	活動	かつどう	aktivitas	ボランティア活動に参加します。ぼらんてぃあかつどうにさんかします。	Saya berpartisipasi dalam aktivitas sukarelawan.	Konteks: aktivitas. Kata 「活動」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:37.343816+00	2026-10-13 06:37:37.343816+00
310	2	環境	かんきょう	lingkungan	環境を守るためにリサイクルします。かんきょうをまもるためにりさいくるします。	Saya mendaur ulang untuk melindungi lingkungan.	Konteks: lingkungan. Kata 「環境」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:38.77861+00	2026-10-13 06:37:38.77861+00
311	2	関係	かんけい	hubungan	二人はとてもいい関係です。ふたりはとてもいいかんけいです。	Mereka berdua memiliki hubungan yang sangat baik.	Konteks: hubungan. Kata 「関係」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 名詞（2文字）, halaman 14.				\N	f	2026-10-13 06:37:40.226607+00	2026-10-13 06:37:40.226607+00
312	2	怒る	おこる	marah	約束を破って父が怒りました。やくそくをやぶってちちがおこりました。	Ayah marah karena saya mengingkari janji.	Konteks: marah. Kata 「怒る」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:41.662572+00	2026-10-13 06:37:41.662572+00
313	2	急ぐ	いそぐ	bergegas; buru-buru	時間がないので急ぎましょう。じかんがないのでいそぎましょう。	Karena tidak ada waktu, mari bergegas.	Konteks: bergegas; buru-buru. Kata 「急ぐ」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:43.093642+00	2026-10-13 06:37:43.093642+00
314	2	痛む	いたむ	merasa sakit	虫歯が痛みます。むしばがいたみます。	Gigi berlubang saya sakit.	Konteks: merasa sakit. Kata 「痛む」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:44.53015+00	2026-10-13 06:37:44.53015+00
315	2	植える	うえる	menanam	庭に花の種を植えます。にわにはなのたねをうえます。	Saya menanam biji bunga di taman.	Konteks: menanam. Kata 「植える」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:45.968662+00	2026-10-13 06:37:45.968662+00
316	2	受ける	うける	menerima; mengikuti	来月、日本語の試験を受けます。らいげつ、にほんごのしけんをうけます。	Bulan depan, saya akan mengikuti ujian bahasa Jepang.	Konteks: menerima; mengikuti. Kata 「受ける」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:47.392641+00	2026-10-13 06:37:47.392641+00
317	2	疑う	うたがう	meragukan; mencurigai	彼の話を疑ってしまいます。かれのはなしをうたがってしまいます。	Saya menjadi ragu dengan ceritanya.	Konteks: meragukan; mencurigai. Kata 「疑う」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:48.839325+00	2026-10-13 06:37:48.839325+00
318	2	打つ	うつ	memukul; mengetik	パソコンで手紙を打ちます。ぱそこんでてがみをうちます。	Saya mengetik surat di komputer.	Konteks: memukul; mengetik. Kata 「打つ」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:50.289127+00	2026-10-13 06:37:50.289127+00
319	2	移る	うつる	berpindah	隣の席に移りました。となりのせきにうつりました。	Saya pindah ke kursi sebelah.	Konteks: berpindah. Kata 「移る」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:51.723756+00	2026-10-13 06:37:51.723756+00
320	2	埋める	うめる	mengubur; mengisi	穴を土で埋めました。あなをつちでうめました。	Saya menimbun lubang dengan tanah.	Konteks: mengubur; mengisi. Kata 「埋める」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:53.150747+00	2026-10-13 06:37:53.150747+00
321	2	描く	えがく	menggambar; melukis	将来の夢を描きます。しょうらいのゆめをえがきます。	Saya melukiskan impian masa depan.	Konteks: menggambar; melukis. Kata 「描く」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:37:54.595449+00	2026-10-13 06:37:54.595449+00
322	2	送る	おくる	mengirim	友達にプレゼントを送りました。ともだちにぷれぜんとをおくりました。	Saya mengirimkan hadiah kepada teman.	Konteks: mengirim. Kata 「送る」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:37:56.021681+00	2026-10-13 06:37:56.021681+00
323	2	遅れる	おくれる	terlambat	電車が十分遅れました。でんしゃがじゅっぷんおくれました。	Kereta terlambat sepuluh menit.	Konteks: terlambat. Kata 「遅れる」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:37:57.478052+00	2026-10-13 06:37:57.478052+00
324	2	行う	おこなう	mengadakan; melakukan	明日、テストを行います。あした、てすとをおこないます。	Besok akan diadakan ujian.	Konteks: mengadakan; melakukan. Kata 「行う」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:37:58.907902+00	2026-10-13 06:37:58.907902+00
325	2	押す	おす	menekan; mendorong	このボタンを押してください。このぼたんをおしてください。	Tolong tekan tombol ini.	Konteks: menekan; mendorong. Kata 「押す」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:38:00.338297+00	2026-10-13 06:38:00.338297+00
326	2	落ちる	おちる	jatuh	木からリンゴが落ちました。きからりんごがおちました。	Apel jatuh dari pohon.	Konteks: jatuh. Kata 「落ちる」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:38:01.758684+00	2026-10-13 06:38:01.758684+00
327	2	落とす	おとす	menjatuhkan	道で財布を落としました。みちでさいふをおとしました。	Saya menjatuhkan dompet di jalan.	Konteks: menjatuhkan. Kata 「落とす」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:38:03.226204+00	2026-10-13 06:38:03.226204+00
328	2	踊る	おどる	menari	音楽に合わせて踊ります。おんがくにあわせておどります。	Saya menari mengikuti alunan musik.	Konteks: menari. Kata 「踊る」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:38:04.623957+00	2026-10-13 06:38:04.623957+00
329	2	驚く	おどろく	terkejut	突然のニュースに驚きました。とつぜんのにゅーすにおどろきました。	Saya terkejut dengan berita yang mendadak.	Konteks: terkejut. Kata 「驚く」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:38:06.058038+00	2026-10-13 06:38:06.058038+00
330	2	覚える	おぼえる	mengingat; menghafal	毎日新しい漢字を覚えます。まいにちあたらしいかんじをおぼえます。	Saya menghafal kanji baru setiap hari.	Konteks: mengingat; menghafal. Kata 「覚える」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:38:07.484947+00	2026-10-13 06:38:07.484947+00
331	2	折る	おる	mematahkan; melipat	紙を半分に折ってください。かみをはんぶんにおってください。	Tolong lipat kertas menjadi dua.	Konteks: mematahkan; melipat. Kata 「折る」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 32.				\N	f	2026-10-13 06:38:08.913862+00	2026-10-13 06:38:08.913862+00
332	2	忙しい	いそがしい	sibuk	今週は仕事が忙しいです。こんしゅうはしごとがいそがしいです。	Minggu ini pekerjaan sibuk.	Konteks: sibuk. Kata 「忙しい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:10.351217+00	2026-10-13 06:38:10.351217+00
333	2	痛い	いたい	sakit	頭が痛いので休みます。あたまがいたいのでやすみます。	Karena sakit kepala, saya beristirahat.	Konteks: sakit. Kata 「痛い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:11.812446+00	2026-10-13 06:38:11.812446+00
334	2	薄い	うすい	tipis; hambar	この本はとても薄いです。このほんはとてもうすいです。	Buku ini sangat tipis.	Konteks: tipis; hambar. Kata 「薄い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:13.246741+00	2026-10-13 06:38:13.246741+00
335	2	うらやましい	うらやましい	iri	彼の才能がうらやましいです。かれのさいのうがうらやましいです。	Saya iri pada bakatnya.	Konteks: iri. Kata 「うらやましい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:14.67143+00	2026-10-13 06:38:14.67143+00
336	2	うるさい	うるさい	berisik; rewel	外の工事がうるさいです。そとのこうじがうるさいです。	Pekerjaan konstruksi di luar berisik.	Konteks: berisik; rewel. Kata 「うるさい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:16.100139+00	2026-10-13 06:38:16.100139+00
337	2	嬉しい	うれしい	senang	プレゼントをもらって嬉しいです。ぷれぜんとをもらってうれしいです。	Saya senang menerima hadiah.	Konteks: senang. Kata 「嬉しい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:17.523791+00	2026-10-13 06:38:17.523791+00
338	2	偉い	えらい	hebat; luar biasa	彼は若いのによく働く偉い人です。かれはわかいのによくはたらくえらいひとです。	Dia adalah orang hebat yang rajin bekerja meskipun masih muda.	Konteks: hebat; luar biasa. Kata 「偉い」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:18.969334+00	2026-10-13 06:38:18.969334+00
339	2	美味しい	おいしい	enak	このケーキはとても美味しいです。このけーきはとてもおいしいです。	Kue ini sangat enak.	Konteks: enak. Kata 「美味しい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:20.404959+00	2026-10-13 06:38:20.404959+00
340	2	おかしい	おかしい	aneh; lucu	彼の話はいつもおかしいです。かれのはなしはいつもおかしいです。	Ceritanya selalu lucu/aneh.	Konteks: aneh; lucu. Kata 「おかしい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:21.852685+00	2026-10-13 06:38:21.852685+00
341	2	惜しい	おしい	sayang sekali	あと少しで勝てたのに惜しいです。あとすこしでかてたのにおしいです。	Sayang sekali padahal sedikit lagi bisa menang.	Konteks: sayang sekali. Kata 「惜しい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, い形容詞, halaman 39.				\N	f	2026-10-13 06:38:23.283744+00	2026-10-13 06:38:23.283744+00
342	2	基本的な	きほんてきな	mendasar; pokok	基本的なルールを説明します。きほんてきなるーるをせつめいします。	Saya akan menjelaskan aturan dasarnya.	Konteks: mendasar; pokok. Kata 「基本的な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:24.724274+00	2026-10-13 06:38:24.724274+00
343	2	急な	きゅうな	mendadak; curam	急な用事が入りました。きゅうなようじがはいりました。	Ada urusan mendadak.	Konteks: mendadak; curam. Kata 「急な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:26.131072+00	2026-10-13 06:38:26.131072+00
344	2	嫌いな	きらいな	benci; tidak suka	嫌いな食べ物はありません。きらいなたべものはありません。	Saya tidak punya makanan yang tidak disukai.	Konteks: benci; tidak suka. Kata 「嫌いな」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:27.549181+00	2026-10-13 06:38:27.549181+00
345	2	具体的な	ぐたいてきな	konkret; spesifik	具体的な例を挙げてください。ぐたいてきなれいをあげてください。	Tolong berikan contoh yang konkret.	Konteks: konkret; spesifik. Kata 「具体的な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:29.183611+00	2026-10-13 06:38:29.183611+00
346	2	元気な	げんきな	sehat; bersemangat	元気な声で挨拶します。げんきなこえであいさつします。	Saya menyapa dengan suara yang bersemangat.	Konteks: sehat; bersemangat. Kata 「元気な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:30.619356+00	2026-10-13 06:38:30.619356+00
347	2	効果的な	こうかてきな	efektif	効果的な学習方法を探しています。こうかてきながくしゅうほうほうをさがしています。	Saya mencari metode belajar yang efektif.	Konteks: efektif. Kata 「効果的な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:32.055625+00	2026-10-13 06:38:32.055625+00
348	2	高価な	こうかな	mahal	高価な時計を買いました。こうかなとけいをかいました。	Saya membeli jam tangan yang mahal.	Konteks: mahal. Kata 「高価な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:33.484265+00	2026-10-13 06:38:33.484265+00
349	2	盛んな	さかんな	populer; makmur	この町は工業が盛んです。このまちはこうぎょうがさかんです。	Kota ini makmur dalam bidang industrinya.	Konteks: populer; makmur. Kata 「盛んな」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:34.919467+00	2026-10-13 06:38:34.919467+00
350	2	様々な	さまざまな	bermacam-macam	様々な国の人が集まりました。さまざまなくにのひとがあつまりました。	Orang dari bermacam-macam negara berkumpul.	Konteks: bermacam-macam. Kata 「様々な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:36.350252+00	2026-10-13 06:38:36.350252+00
351	2	残念な	ざんねんな	disayangkan; kecewa	試合に負けて残念な結果になりました。しあいにまけてざんねんなけっかになりました。	Kalah dalam pertandingan dan hasilnya mengecewakan.	Konteks: disayangkan; kecewa. Kata 「残念な」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, な形容詞, halaman 41.				\N	f	2026-10-13 06:38:37.77449+00	2026-10-13 06:38:37.77449+00
352	2	あまり	あまり	tidak terlalu (dengan negatif)	私はあまりお酒を飲みません。わたしはあまりおさけをのみません。	Saya tidak terlalu sering minum alkohol.	Konteks: tidak terlalu (dengan negatif). Kata 「あまり」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:39.216172+00	2026-10-13 06:38:39.216172+00
353	2	いくらでも	いくらでも	berapapun	時間はいくらでもあるので大丈夫です。じかんはいくらでもあるのでだいじょうぶです。	Waktunya ada berapapun, jadi tidak apa-apa.	Konteks: berapapun. Kata 「いくらでも」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:40.639485+00	2026-10-13 06:38:40.639485+00
354	2	いつでも	いつでも	kapanpun	いつでも連絡してください。いつでもれんらくしてください。	Hubungilah saya kapanpun.	Konteks: kapanpun. Kata 「いつでも」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:42.078926+00	2026-10-13 06:38:42.078926+00
355	2	いっぱい	いっぱい	penuh; banyak	お腹がいっぱいで食べられません。おなかがいっぱいでたべられません。	Perut saya penuh dan tidak bisa makan lagi.	Konteks: penuh; banyak. Kata 「いっぱい」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:43.503935+00	2026-10-13 06:38:43.503935+00
356	2	かなり	かなり	lumayan; cukup	今日のテストはかなり難しかったです。きょうのてすとはかなりむずかしかったです。	Ujian hari ini lumayan sulit.	Konteks: lumayan; cukup. Kata 「かなり」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:44.94285+00	2026-10-13 06:38:44.94285+00
357	2	きちんと	きちんと	dengan rapi; pantas	靴をきちんと並べてください。くつをきちんとならべてください。	Tolong susun sepatu dengan rapi.	Konteks: dengan rapi; pantas. Kata 「きちんと」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:46.384663+00	2026-10-13 06:38:46.384663+00
358	2	きっと	きっと	pasti	明日はきっと晴れるでしょう。あしたはきっとはれるでしょう。	Besok pasti akan cerah.	Konteks: pasti. Kata 「きっと」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:47.835519+00	2026-10-13 06:38:47.835519+00
359	2	結構	けっこう	cukup; lumayan	この料理は結構美味しいです。このりょうりはけっこうおいしいです。	Masakan ini lumayan enak.	Konteks: cukup; lumayan. Kata 「結構」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:49.256778+00	2026-10-13 06:38:49.256778+00
360	2	先に	さきに	lebih dulu	お先に失礼します。おさきにしつれいします。	Saya permisi duluan.	Konteks: lebih dulu. Kata 「先に」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:50.695261+00	2026-10-13 06:38:50.695261+00
361	2	早速	さっそく	segera	早速、新しいパソコンを使ってみます。さっそく、あたらしいぱそこんをつかってみます。	Saya akan segera mencoba menggunakan komputer baru ini.	Konteks: segera. Kata 「早速」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 副詞（一般）, halaman 43.				\N	f	2026-10-13 06:38:52.128011+00	2026-10-13 06:38:52.128011+00
362	3	駐車場	ちゅうしゃじょう	tempat parkir	車を駐車場に止めます。くるまをちゅうしゃじょうにとめます。	Saya memarkir mobil di tempat parkir.	💡 Konteks Penggunaan:\nDigunakan pada papan tanda atau area khusus untuk memarkir kendaraan.\n\n📝 Catatan:\nKata 「駐車場」 digunakan dalam contoh kalimat: "車を駐車場に止めます。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:15.863689+00	2026-10-13 13:08:15.863689+00
363	3	駐車	ちゅうしゃ	parkir	ここは駐車禁止です。ここはちゅうしゃきんしです。	Dilarang parkir di sini.	💡 Konteks Penggunaan:\nMerujuk pada aktivitas memarkirkan kendaraan, sering muncul di rambu peringatan jalan.\n\n📝 Catatan:\nKata 「駐車」 digunakan dalam contoh kalimat: "ここは駐車禁止です。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:17.47952+00	2026-10-13 13:08:17.47952+00
364	3	満車	まんしゃ	parkir penuh	駐車場は満車です。ちゅうしゃじょうはまんしゃです。	Tempat parkir penuh.	💡 Konteks Penggunaan:\nMuncul pada rambu digital/papan di depan area parkir untuk menandakan kapasitas sudah maksimal.\n\n📝 Catatan:\nKata 「満車」 digunakan dalam contoh kalimat: "駐車場は満車です。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:18.906739+00	2026-10-13 13:08:18.906739+00
365	3	号車	ごうしゃ	gerbong nomor ~	私の席は３号車にあります。わたしのせきはさんごうしゃにあります。	Kursi saya ada di gerbong nomor 3.	💡 Konteks Penggunaan:\nPenanda lokasi blok tempat duduk di dalam rangkaian angkutan massal seperti Shinkansen atau kereta api.\n\n📝 Catatan:\nKata 「号車」 digunakan dalam contoh kalimat: "私の席は３号車にあります。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:20.58988+00	2026-10-13 13:08:20.58988+00
366	3	満員	まんいん	penuh orang	電車は満員でした。でんしゃはまんいんでした。	Keretanya penuh dengan orang.	💡 Konteks Penggunaan:\nMenggambarkan situasi di mana kendaraan umum atau ruangan sudah terisi penuh sesak oleh orang.\n\n📝 Catatan:\nKata 「満員」 digunakan dalam contoh kalimat: "電車は満員でした。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:22.025222+00	2026-10-13 13:08:22.025222+00
367	3	不満な	ふまんな	tidak puas	彼は今の仕事に不満を持っています。かれはいまのしごとにふまんをもっています。	Dia merasa tidak puas dengan pekerjaannya saat ini.	💡 Konteks Penggunaan:\nMengekspresikan perasaan tidak suka, tidak setuju, atau tidak menerima suatu keadaan.\n\n📝 Catatan:\nKata 「不満な」 digunakan dalam contoh kalimat: "彼は今の仕事に不満を持っています。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:23.462509+00	2026-10-13 13:08:23.462509+00
368	3	飛行場	ひこうじょう	lapangan terbang / bandara	この近くに小さな飛行場があります。このちかくにちいさなひこうじょうがあります。	Ada lapangan terbang kecil di dekat sini.	💡 Konteks Penggunaan:\nMerujuk pada area pendaratan pesawat (umumnya skalanya lebih kecil, domestik, atau non-komersial).\n\n📝 Catatan:\nKata 「飛行場」 digunakan dalam contoh kalimat: "この近くに小さな飛行場があります。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:24.898207+00	2026-10-13 13:08:24.898207+00
369	3	飛ぶ	とぶ	terbang	空を鳥が飛んでいます。そらをとりがとんでいます。	Burung sedang terbang di langit.	💡 Konteks Penggunaan:\nAksi pergerakan makhluk hidup atau benda bermesin di udara, kiasan untuk sesuatu yang bergerak cepat.\n\n📝 Catatan:\nKata 「飛ぶ」 digunakan dalam contoh kalimat: "空を鳥が飛んでいます。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:26.326372+00	2026-10-13 13:08:26.326372+00
370	3	階	かい	lantai	私の部屋は３階にあります。わたしのへやはさんがいにあります。	Kamar saya ada di lantai 3.	💡 Konteks Penggunaan:\nSatuan penanda letak ketinggian struktural/tingkat di dalam sebuah bangunan atau gedung komersial.\n\n📝 Catatan:\nKata 「階」 digunakan dalam contoh kalimat: "私の部屋は３階にあります。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:28.010064+00	2026-10-13 13:08:28.010064+00
16	1	作品	さくひん	Karya/Ciptaan	作品を作ります。	Saya membuat karya.	「作品」 berarti karya atau ciptaan, misalnya karya seni, sastra, atau film. Kata ini dipakai untuk hasil karya seseorang, dan berkolokasi dengan 作品を作る dan 作品を発表する。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:56:11.538696+00
371	3	階段	かいだん	tangga	階段を上って二階に行きます。かいだんをのぼってにかいへいきます。	Naik tangga menuju lantai 2.	💡 Konteks Penggunaan:\nFasilitas pijakan berundak untuk penghubung fisik antar lantai, baik di dalam gedung rumah, atau fasilitas publik.\n\n📝 Catatan:\nKata 「階段」 digunakan dalam contoh kalimat: "階段を上って二階に行きます。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 車・満・飛・階).				\N	f	2026-10-13 13:08:29.704506+00	2026-10-13 13:08:29.704506+00
372	3	無休	むきゅう	tidak ada hari libur	この店は年中無休です。このみせはねんじゅうむきゅうです。	Toko ini buka sepanjang tahun tanpa libur.	💡 Konteks Penggunaan:\nDigunakan sebagai penanda waktu operasional toko atau fasilitas yang buka setiap hari.\n\n📝 Catatan:\nKata 「無休」 digunakan dalam contoh kalimat: "この店は年中無休です。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:31.143122+00	2026-10-13 13:08:31.143122+00
373	3	無料	むりょう	gratis	このパンフレットは無料です。このぱんふれっとはむりょうです。	Brosur ini gratis.	💡 Konteks Penggunaan:\nMenandakan layanan, tiket, atau fasilitas yang tidak memungut biaya dari pengunjung.\n\n📝 Catatan:\nKata 「無料」 digunakan dalam contoh kalimat: "このパンフレットは無料です。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:33.113346+00	2026-10-13 13:08:33.113346+00
374	3	無理な	むりな	mustahil / dipaksakan	無理なスケジュールは立てないでください。むりなすけじゅーるはたてないでください。	Tolong jangan membuat jadwal yang dipaksakan.	💡 Konteks Penggunaan:\nDigunakan saat suatu kondisi tidak masuk akal, melampaui batas kemampuan, atau terlalu membebani.\n\n📝 Catatan:\nKata 「無理な」 digunakan dalam contoh kalimat: "無理なスケジュールは立てないでください。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:35.303235+00	2026-10-13 13:08:35.303235+00
375	3	無い	ない	tidak ada	お金が無いので買えません。おかねがないのでかえません。	Saya tidak bisa membeli karena tidak ada uang.	💡 Konteks Penggunaan:\nMenyatakan ketiadaan suatu benda, sifat, atau keadaan secara tegas.\n\n📝 Catatan:\nKata 「無い」 digunakan dalam contoh kalimat: "お金が無いので買えません。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:37.006114+00	2026-10-13 13:08:37.006114+00
376	3	無断	むだん	tanpa izin	無断で休まないでください。むだんでやすまないでください。	Tolong jangan libur tanpa izin.	💡 Konteks Penggunaan:\nDigunakan dalam konteks aturan dan kedisiplinan agar tidak melakukan sesuatu tanpa melapor sebelumnya.\n\n📝 Catatan:\nKata 「無断」 digunakan dalam contoh kalimat: "無断で休まないでください。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:38.433341+00	2026-10-13 13:08:38.433341+00
377	3	断水	だんすい	pemutusan air / mati air	明日は工事のため断水します。あしたはこうじのためだんすいします。	Besok air akan mati karena ada perbaikan.	💡 Konteks Penggunaan:\nSering muncul pada papan pengumuman apartemen/kota mengenai terhentinya pasokan air sementara.\n\n📝 Catatan:\nKata 「断水」 digunakan dalam contoh kalimat: "明日は工事のため断水します。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:39.870655+00	2026-10-13 13:08:39.870655+00
378	3	断る	ことわる	menolak	彼の誘いを断りました。かれのさそいをことわりました。	Saya menolak ajakannya.	💡 Konteks Penggunaan:\nTindakan verbal atau tertulis untuk tidak menerima tawaran, undangan, atau permintaan orang lain.\n\n📝 Catatan:\nKata 「断る」 digunakan dalam contoh kalimat: "彼の誘いを断りました。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:41.509246+00	2026-10-13 13:08:41.509246+00
379	3	横断	おうだん	penyeberangan	通りを横断するときは気をつけてください。とおりをおうだんするときはきをつけてください。	Harap berhati-hati saat menyeberang jalan.	💡 Konteks Penggunaan:\nDigunakan untuk aksi menyeberangi jalan raya, benua, atau area luas dari satu sisi ke sisi lain.\n\n📝 Catatan:\nKata 「横断」 digunakan dalam contoh kalimat: "通りを横断するときは気をつけてください。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:43.724916+00	2026-10-13 13:08:43.724916+00
380	3	横断歩道	おうだんほどう	zebra cross	横断歩道を渡りましょう。おうだんほどうをわたりましょう。	Mari menyeberang di zebra cross.	💡 Konteks Penggunaan:\nIstilah lalu lintas resmi untuk area bercat garis putih tempat pejalan kaki menyeberang jalan.\n\n📝 Catatan:\nKata 「横断歩道」 digunakan dalam contoh kalimat: "横断歩道を渡りましょう。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:45.159583+00	2026-10-13 13:08:45.159583+00
381	3	横	よこ	samping	銀行の横にコンビニがあります。ぎんこうのよこにこんびにがあります。	Ada minimarket di samping bank.	💡 Konteks Penggunaan:\nMenunjukkan posisi spasial atau letak persis di sebelah kanan/kiri dari suatu objek.\n\n📝 Catatan:\nKata 「横」 digunakan dalam contoh kalimat: "銀行の横にコンビニがあります。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 無・断・横).				\N	f	2026-10-13 13:08:46.586557+00	2026-10-13 13:08:46.586557+00
382	3	押す	おす	menekan	ドアを開けるにはこのボタンを押します。どあをあけるにはこのぼたんをおします。	Tekan tombol ini untuk membuka pintu.	💡 Konteks Penggunaan:\nInstruksi fisik langsung untuk mendorong pintu, menekan bel, tuts, atau tombol elektronik.\n\n📝 Catatan:\nKata 「押す」 digunakan dalam contoh kalimat: "ドアを開けるにはこのボタンを押します。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:48.014927+00	2026-10-13 13:08:48.014927+00
383	3	押し入れ	おしいれ	lemari dinding bergaya Jepang	布団を押し入れにしまいます。ふとんをおしいれにしまいます。	Saya menyimpan kasur futon di lemari dinding.	💡 Konteks Penggunaan:\nRuang penyimpanan arsitektur tradisional Jepang yang berada di balik pintu geser (fusuma).\n\n📝 Catatan:\nKata 「押し入れ」 digunakan dalam contoh kalimat: "布団を押し入れにしまいます。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:49.696717+00	2026-10-13 13:08:49.696717+00
384	3	押さえる	おさえる	menahan / menekan	ドアが閉まらないように押さえてください。どあがしまらないようにおさえてください。	Tolong tahan pintunya agar tidak tertutup.	💡 Konteks Penggunaan:\nInstruksi untuk memegang atau menahan sesuatu secara fisik agar tidak bergerak, terbang, atau tertutup.\n\n📝 Catatan:\nKata 「押さえる」 digunakan dalam contoh kalimat: "ドアが閉まらないように押さえてください。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:51.123+00	2026-10-13 13:08:51.123+00
385	3	押しボタン式	おしぼたんしき	tipe tombol tekan	あの信号は押しボタン式です。あのしんごうはおしぼたんしきです。	Lampu lalu lintas itu menggunakan sistem tombol tekan.	💡 Konteks Penggunaan:\nSering tertulis pada lampu lalu lintas penyeberangan atau mesin yang beroperasi dengan input manual ditekan.\n\n📝 Catatan:\nKata 「押しボタン式」 digunakan dalam contoh kalimat: "あの信号は押しボタン式です。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:52.808019+00	2026-10-13 13:08:52.808019+00
386	3	数式	すうしき	rumus matematika	この数式を解いてください。このすうしきをといてください。	Tolong pecahkan rumus matematika ini.	💡 Konteks Penggunaan:\nIstilah akademis yang merujuk pada persamaan, kalkulasi, atau deretan angka dan simbol matematika.\n\n📝 Catatan:\nKata 「数式」 digunakan dalam contoh kalimat: "この数式を解いてください。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:54.241689+00	2026-10-13 13:08:54.241689+00
387	3	入学式	にゅうがくしき	upacara masuk sekolah	明日は大学の入学式です。あしたはだいがくのにゅうがくしきです。	Besok adalah upacara penerimaan mahasiswa di universitas.	💡 Konteks Penggunaan:\nMenyatakan acara seremonial formal tahunan di instansi pendidikan Jepang untuk menyambut siswa baru.\n\n📝 Catatan:\nKata 「入学式」 digunakan dalam contoh kalimat: "明日は大学の入学式です。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:55.679727+00	2026-10-13 13:08:55.679727+00
388	3	方向	ほうこう	arah	駅はどの方向ですか。えきはどのほうこうですか。	Stasiun ada di arah mana?	💡 Konteks Penggunaan:\nDigunakan dalam petunjuk jalan, navigasi peta, atau pedoman ke mana seseorang harus bergerak.\n\n📝 Catatan:\nKata 「方向」 digunakan dalam contoh kalimat: "駅はどの方向ですか。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:57.103188+00	2026-10-13 13:08:57.103188+00
389	3	向かう	むかう	menuju	今から駅に向かいます。いまからえきにむかいます。	Saya menuju stasiun dari sekarang.	💡 Konteks Penggunaan:\nMerujuk pada aksi fisik bergerak atau berangkat mengarah ke suatu tempat tujuan.\n\n📝 Catatan:\nKata 「向かう」 digunakan dalam contoh kalimat: "今から駅に向かいます。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:58.539852+00	2026-10-13 13:08:58.539852+00
390	3	向き	むき	cocok untuk / menghadap	この本は子供向きです。このほんはこどもむきです。	Buku ini cocok untuk anak-anak.	💡 Konteks Penggunaan:\nMenunjukkan kecocokan suatu objek untuk target tertentu, atau arah hadap suatu bangunan.\n\n📝 Catatan:\nKata 「向き」 digunakan dalam contoh kalimat: "この本は子供向きです。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:08:59.976034+00	2026-10-13 13:08:59.976034+00
391	3	箱	はこ	kotak	この箱の中に何が入っていますか。このはこのなかになにがはいっていますか。	Apa yang ada di dalam kotak ini?	💡 Konteks Penggunaan:\nWadah fisik berongga untuk menyimpan/mengemas barang (sering digabung kata lain seperti tempat sampah/kotak surat).\n\n📝 Catatan:\nKata 「箱」 digunakan dalam contoh kalimat: "この箱の中に何が入っていますか。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 押・式・向・箱).				\N	f	2026-10-13 13:09:01.406893+00	2026-10-13 13:09:01.406893+00
392	3	自信	じしん	kepercayaan diri	試験に合格する自信があります。しけんにごうかくするじしんがあります。	Saya punya kepercayaan diri untuk lulus ujian.	💡 Konteks Penggunaan:\nMenggambarkan keadaan psikologis di mana seseorang merasa yakin terhadap kemampuan dan keputusannya sendiri.\n\n📝 Catatan:\nKata 「自信」 digunakan dalam contoh kalimat: "試験に合格する自信があります。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:02.845434+00	2026-10-13 13:09:02.845434+00
393	3	信じる	しんじる	percaya	彼の言葉を信じます。かれのことばをしんじます。	Saya percaya pada perkataannya.	💡 Konteks Penggunaan:\nTindakan meyakini ucapan orang lain, suatu agama, kebenaran informasi, atau harapan tertentu.\n\n📝 Catatan:\nKata 「信じる」 digunakan dalam contoh kalimat: "彼の言葉を信じます。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:04.531411+00	2026-10-13 13:09:04.531411+00
394	3	信用	しんよう	kepercayaan	彼は誰からも信用されています。かれはだれからもしんようされています。	Dia dipercaya oleh siapa pun.	💡 Konteks Penggunaan:\nTingkat kepercayaan publik, reputasi, atau rekam jejak yang diberikan orang/bank kepada seseorang atau perusahaan.\n\n📝 Catatan:\nKata 「信用」 digunakan dalam contoh kalimat: "彼は誰からも信用されています。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:05.977512+00	2026-10-13 13:09:05.977512+00
395	3	信号	しんごう	lampu lalu lintas	信号が赤に変わりました。しんごうがあかにかわりました。	Lampu lalu lintas berubah menjadi merah.	💡 Konteks Penggunaan:\nMerujuk pada rambu elektronik di persimpangan jalan atau sinyal peringatan dalam telekomunikasi.\n\n📝 Catatan:\nKata 「信号」 digunakan dalam contoh kalimat: "信号が赤に変わりました。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:07.651223+00	2026-10-13 13:09:07.651223+00
396	3	送信	そうしん	mengirim pesan/data	メールを作成して送信します。めーるをさくせいしてそうしんします。	Saya menulis email lalu mengirimkannya.	💡 Konteks Penggunaan:\nAktivitas menekan tombol kirim untuk mentransfer data elektronik seperti email, chat, atau file.\n\n📝 Catatan:\nKata 「送信」 digunakan dalam contoh kalimat: "メールを作成して送信します。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:09.330753+00	2026-10-13 13:09:09.330753+00
397	3	関心	かんしん	minat / ketertarikan	私は日本の文化に関心があります。わたしはにほんのぶんかにかんしんがあります。	Saya memiliki ketertarikan pada budaya Jepang.	💡 Konteks Penggunaan:\nMenyatakan perasaan tertarik atau rasa ingin tahu yang besar terhadap suatu topik/bidang.\n\n📝 Catatan:\nKata 「関心」 digunakan dalam contoh kalimat: "私は日本の文化に関心があります。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:10.768893+00	2026-10-13 13:09:10.768893+00
398	3	関する	かんする	mengenai / berhubungan dengan	この問題に関する情報を集めています。このもんだいにかんするじょうほうをあつめています。	Saya sedang mengumpulkan informasi mengenai masalah ini.	💡 Konteks Penggunaan:\nKata hubung formal yang sering dipakai dalam laporan/berita untuk merujuk pada suatu subjek.\n\n📝 Catatan:\nKata 「関する」 digunakan dalam contoh kalimat: "この問題に関する情報を集めています。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:12.199323+00	2026-10-13 13:09:12.199323+00
399	3	関係	かんけい	hubungan	二人の関係はとても良いです。ふたりのかんけいはとてもよいです。	Hubungan mereka berdua sangat baik.	💡 Konteks Penggunaan:\nMenggambarkan ikatan, relasi antar manusia, atau keterkaitan sebab-akibat antara dua hal.\n\n📝 Catatan:\nKata 「関係」 digunakan dalam contoh kalimat: "二人の関係はとても良いです。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:13.633136+00	2026-10-13 13:09:13.633136+00
400	3	係	かかり	orang yang bertanggung jawab	イベントの係の人に聞いてください。いべんとのかかりのひとにきいてください。	Tolong tanyakan kepada orang yang bertanggung jawab atas acara tersebut.	💡 Konteks Penggunaan:\nMerujuk pada staf spesifik atau panitia yang diberi tugas mengurus suatu area atau acara.\n\n📝 Catatan:\nKata 「係」 digunakan dalam contoh kalimat: "イベントの係の人に聞いてください。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:15.862109+00	2026-10-13 13:09:15.862109+00
401	3	禁止	きんし	larangan	ここはタバコを吸うのが禁止されています。ここはたばこをすうのがきんしされています。	Dilarang merokok di sini.	💡 Konteks Penggunaan:\nDigunakan pada peraturan tertulis atau rambu peringatan keras di area publik.\n\n📝 Catatan:\nKata 「禁止」 digunakan dalam contoh kalimat: "ここはタバコを吸うのが禁止されています。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 信・関・係・禁).				\N	f	2026-10-13 13:09:17.54908+00	2026-10-13 13:09:17.54908+00
402	3	正確な	せいかくな	akurat / tepat	この時計は正確です。このとけいはせいかくです。	Jam ini akurat.	💡 Konteks Penggunaan:\nMenjelaskan kondisi yang sangat presisi, tepat sasaran, dan tanpa kesalahan (umumnya untuk jam, alat ukur, atau data).\n\n📝 Catatan:\nKata 「正確な」 digunakan dalam contoh kalimat: "この時計は正確です。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:19.247327+00	2026-10-13 13:09:19.247327+00
403	3	確かな	たしかな	pasti / tentu	それは確かな情報ですか。それはたしかなじょうほうですか。	Apakah itu informasi yang pasti?	💡 Konteks Penggunaan:\nMengindikasikan kepastian, validitas, atau keandalan tingkat tinggi dari sebuah fakta/benda.\n\n📝 Catatan:\nKata 「確かな」 digunakan dalam contoh kalimat: "それは確かな情報ですか。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:20.757436+00	2026-10-13 13:09:20.757436+00
404	3	確かめる	たしかめる	memastikan	出発前に時間を確かめます。しゅっぱつまえにじかんをたしかめます。	Saya memastikan waktu sebelum berangkat.	💡 Konteks Penggunaan:\nTindakan aktif mengecek ulang sesuatu secara visual atau fisik agar tidak terjadi kesalahan/kelupaan.\n\n📝 Catatan:\nKata 「確かめる」 digunakan dalam contoh kalimat: "出発前に時間を確かめます。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:22.358278+00	2026-10-13 13:09:22.358278+00
405	3	確認	かくにん	konfirmasi / pengecekan	予約の確認をお願いします。よやくのかくにんをおねがいします。	Tolong konfirmasi reservasinya.	💡 Konteks Penggunaan:\nProses administratif atau formal untuk memvalidasi reservasi, mengecek kebenaran dokumen, dan prosedur resmi.\n\n📝 Catatan:\nKata 「確認」 digunakan dalam contoh kalimat: "予約の確認をお願いします。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:23.788854+00	2026-10-13 13:09:23.788854+00
406	3	認める	みとめる	mengakui / menyetujui	彼は自分の間違いを認めました。かれはじぶんのまちがいをみとめました。	Dia mengakui kesalahannya sendiri.	💡 Konteks Penggunaan:\nSikap menyadari dan menerima fakta (seperti kesalahan), menyetujui sebuah usulan, atau memvalidasi status seseorang.\n\n📝 Catatan:\nKata 「認める」 digunakan dalam contoh kalimat: "彼は自分の間違いを認めました。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:25.221673+00	2026-10-13 13:09:25.221673+00
407	3	非常	ひじょう	darurat	非常の場合は、このボタンを押してください。ひじょうのばあいは、このぼたんをおしてください。	Dalam keadaan darurat, tolong tekan tombol ini.	💡 Konteks Penggunaan:\nMenandakan situasi bahaya, krisis, atau insiden tak terduga yang membutuhkan tindakan ekstra cepat/perhatian khusus.\n\n📝 Catatan:\nKata 「非常」 digunakan dalam contoh kalimat: "非常の場合は、このボタンを押してください。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:26.657506+00	2026-10-13 13:09:26.657506+00
408	3	非常口	ひじょうぐち	pintu darurat	非常口はあちらです。ひじょうぐちはあちらです。	Pintu darurat ada di sebelah sana.	💡 Konteks Penggunaan:\nSering tertulis pada papan tanda evakuasi bercahaya hijau di dalam gedung atau angkutan umum untuk jalur penyelamatan.\n\n📝 Catatan:\nKata 「非常口」 digunakan dalam contoh kalimat: "非常口はあちらです。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:28.369622+00	2026-10-13 13:09:28.369622+00
409	3	非常に	ひじょうに	sangat	今年の夏は非常に暑いです。ことしのなつはひじょうにあついです。	Musim panas tahun ini sangat panas.	💡 Konteks Penggunaan:\nKata keterangan formal/tertulis yang digunakan untuk menekankan sifat atau keadaan secara ekstrem (jauh di atas rata-rata).\n\n📝 Catatan:\nKata 「非常に」 digunakan dalam contoh kalimat: "今年の夏は非常に暑いです。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:30.044959+00	2026-10-13 13:09:30.044959+00
410	3	日常	にちじょう	sehari-hari	日常の生活を大切にしたいです。にちじょうのせいかつをたいせつにしたいです。	Saya ingin menghargai kehidupan sehari-hari.	💡 Konteks Penggunaan:\nMenggambarkan rutinitas standar, kegiatan harian, atau situasi normal yang biasa dilewati tanpa ada hal yang spesial.\n\n📝 Catatan:\nKata 「日常」 digunakan dalam contoh kalimat: "日常の生活を大切にしたいです。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:31.708417+00	2026-10-13 13:09:31.708417+00
411	3	正常な	せいじょうな	normal	機械は正常に動いています。きかいはせいじょうにうごいています。	Mesinnya beroperasi dengan normal.	💡 Konteks Penggunaan:\nMenggambarkan kondisi di mana sistem, mesin, organ tubuh, atau situasi berjalan optimal sesuai desain semestinya.\n\n📝 Catatan:\nKata 「正常な」 digunakan dalam contoh kalimat: "機械は正常に動いています。"\n\n📚 Sumber: Soumatome Kanji N3 (Metode Klastering: Klaster 確・認・常・非).				\N	f	2026-10-13 13:09:33.609974+00	2026-10-13 13:09:33.609974+00
540	4	訪問	ほうもん	Kunjungan	友達の家を訪問します。 ともだちのいえをほうもんします。	Saya mengunjungi rumah teman.	💡 Konteks Penggunaan:\n訪問 dipakai untuk kunjungan, baik ke rumah seseorang, ke perusahaan, maupun ke tempat wisata.\n\n📝 Catatan:\nKata 「訪問」 berkolokasi dengan 訪問する、訪問先 dan 訪問販売; kata 訪問販売 berarti penjualan dari pintu ke pintu.\nKata 「訪問」 digunakan dalam contoh kalimat: "友達の家を訪問します。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:41:31.873004+00
528	4	面倒	めんどう	Merepotkan / Ribet	面倒な手続きです。 めんどうなてつづきです。	Ini adalah prosedur yang merepotkan.	💡 Konteks Penggunaan:\n面倒 dipakai untuk sesuatu yang merepotkan atau ribet, seperti prosedur, pekerjaan rumah, atau urusan yang rumit.\n\n📝 Catatan:\nKata 「面倒」 berkolokasi dengan 面倒な〜、面倒くさい dan 面倒を見る; frasa 面倒を見る berarti mengurus seseorang.\nKata 「面倒」 digunakan dalam contoh kalimat: "面倒な手続きです。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:36:57.046278+00
530	4	慣れる	なれる	Terbiasa	新しい生活に慣れました。 あたらしいせいかつになれました。	Saya sudah terbiasa dengan kehidupan baru.	💡 Konteks Penggunaan:\n慣れる dipakai untuk menjadi terbiasa dengan suatu hal, seperti kehidupan baru, pekerjaan, atau lingkungan.\n\n📝 Catatan:\nKata 「慣れる」 adalah kata kerja golongan 2, berkolokasi dengan 〜に慣れる、慣れない dan 慣れてきた; frasa 慣れてきた berarti mulai terbiasa.\nKata 「慣れる」 digunakan dalam contoh kalimat: "新しい生活に慣れました。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:37:43.250424+00
533	4	きつい	きつい	Ketat / Sempit	この靴はきついです。 このくつはきついです。	Sepatu ini sempit.	💡 Konteks Penggunaan:\nきつい dipakai untuk sesuatu yang ketat atau sempit, seperti pakaian dan sepatu, juga untuk pekerjaan yang berat dan jadwal yang padat.\n\n📝 Catatan:\nKata 「きつい」 adalah i-adjective, berkolokasi dengan きつい仕事、靴がきつい dan きついスケジュール; lawan katanya adalah ゆるい.\nKata 「きつい」 digunakan dalam contoh kalimat: "この靴はきついです。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:38:49.596287+00
535	4	溢れる	あふれる	Meluap / Tumpah	コップから水が溢れました。 コップからみずがあふれました。	Air meluap dari gelas.	💡 Konteks Penggunaan:\n溢れる dipakai untuk cairan yang meluap atau tumpah, juga untuk perasaan yang meluap, seperti kegembiraan.\n\n📝 Catatan:\nKata 「溢れる」 adalah kata kerja golongan 2, berkolokasi dengan 水が溢れる、涙が溢れる dan 溢れ出す; frasa 涙が溢れる berarti air mata meluap.\nKata 「溢れる」 digunakan dalam contoh kalimat: "コップから水が溢れました。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:39:33.617268+00
536	4	追いつく	おいつく	Menyusul / Mengejar	友達に追いつきます。 ともだちにおいつきます。	Saya menyusul teman saya.	💡 Konteks Penggunaan:\n追いつく dipakai untuk menyusul atau mengejar seseorang yang berada di depan, baik secara fisik maupun dalam kemampuan.\n\n📝 Catatan:\nKata 「追いつく」 adalah kata kerja golongan 1, berkolokasi dengan 〜に追いつく、追いついた dan 追いつけない; frasa 追いつけない berarti tidak bisa menyusul.\nKata 「追いつく」 digunakan dalam contoh kalimat: "友達に追いつきます。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:39:56.029495+00
537	4	必ずしも	かならずしも	Tidak selalu / Belum tentu	必ずしも正しいとは限りません。 かならずしもただしいとはかぎりません。	Belum tentu selalu benar.	💡 Konteks Penggunaan:\n必ずしも dipakai untuk menyatakan bahwa sesuatu tidak selalu demikian, sering dipakai dalam kalimat negatif.\n\n📝 Catatan:\nKata 「必ずしも」 berkolokasi dengan 必ずしも〜ない dan 必ずしもそうではない; pola ini selalu diikuti bentuk negatif.\nKata 「必ずしも」 digunakan dalam contoh kalimat: "必ずしも正しいとは限りません。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:40:19.575737+00
541	4	手帳	てちょう	Buku Agenda / Catatan	手帳に予定を書きます。 てちょうによていをかきます。	Saya menulis jadwal di buku agenda.	💡 Konteks Penggunaan:\n手帳 dipakai untuk buku agenda atau catatan, sering dipakai untuk menulis jadwal, rencana, atau catatan harian.\n\n📝 Catatan:\nKata 「手帳」 berkolokasi dengan 手帳に書く、手帳を見る dan 手帳を忘れる; kata 手帳型 berarti model buku agenda.\nKata 「手帳」 digunakan dalam contoh kalimat: "手帳に予定を書きます。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:41:54.785997+00
542	4	表紙	ひょうし	Sampul (buku/majalah)	本の表紙がきれいです。 ほんのひょうしがきれいです。	Sampul buku itu indah.	💡 Konteks Penggunaan:\n表紙 dipakai untuk sampul buku atau majalah, sering dipakai untuk desain, gambar, atau judul di sampul.\n\n📝 Catatan:\nKata 「表紙」 berkolokasi dengan 表紙を飾る、表紙がきれいだ dan 表紙のデザイン; kata 裏表紙 berarti sampul belakang.\nKata 「表紙」 digunakan dalam contoh kalimat: "本の表紙がきれいです。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:42:18.045897+00
544	4	派手	はで	Mencolok / Berwarna-warni	派手な服を着ています。 はでなふくをきています。	Dia memakai pakaian yang mencolok.	💡 Konteks Penggunaan:\n派手 dipakai untuk sesuatu yang mencolok atau berwarna-warni, seperti pakaian, desain, atau penampilan.\n\n📝 Catatan:\nKata 「派手」 adalah na-adjective, berkolokasi dengan 派手な〜、派手な色 dan 派手にする; lawan katanya adalah 地味.\nKata 「派手」 digunakan dalam contoh kalimat: "派手な服を着ています。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:43:05.353163+00
545	4	落ち着く	おちつく	Tenang / Menjadi stabil	心が落ち着きます。 こころがおちつきます。	Hati saya menjadi tenang.	💡 Konteks Penggunaan:\n落ち着く dipakai untuk menjadi tenang atau stabil, baik perasaan, suasana, maupun situasi setelah tegang.\n\n📝 Catatan:\nKata 「落ち着く」 adalah kata kerja golongan 1, berkolokasi dengan 心が落ち着く、落ち着いて dan 落ち着いた; frasa 落ち着いて berarti dengan tenang.\nKata 「落ち着く」 digunakan dalam contoh kalimat: "心が落ち着きます。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:43:28.651252+00
546	4	応援	おうえん	Dukungan / Sorakan	友達を応援します。 ともだちをおうえんします。	Saya mendukung teman saya.	💡 Konteks Penggunaan:\n応援 dipakai untuk dukungan atau sorakan, baik untuk teman, tim olahraga, maupun seseorang yang berjuang.\n\n📝 Catatan:\nKata 「応援」 berkolokasi dengan 応援する、応援団 dan 応援歌; kata 応援団 berarti tim pendukung.\nKata 「応援」 digunakan dalam contoh kalimat: "友達を応援します。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:43:52.992913+00
547	4	慰める	なぐさめる	Menghibur	友達を慰めます。 ともだちをなぐさめます。	Saya menghibur teman saya.	💡 Konteks Penggunaan:\n慰める dipakai untuk menghibur seseorang yang sedang sedih atau kecewa, dalam percakapan yang hangat dan penuh perhatian.\n\n📝 Catatan:\nKata 「慰める」 adalah kata kerja golongan 2, berkolokasi dengan 〜を慰める、慰めの言葉 dan 慰めになる; kata 慰め berarti penghiburan.\nKata 「慰める」 digunakan dalam contoh kalimat: "友達を慰めます。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:44:18.589338+00
549	4	野菜	やさい	Sayuran	毎日野菜を食べます。 まいにちやさいをたべます。	Saya makan sayuran setiap hari.	💡 Konteks Penggunaan:\n野菜 dipakai untuk sayuran, baik yang dimasak maupun yang dimakan mentah, dalam percakapan sehari-hari dan resep.\n\n📝 Catatan:\nKata 「野菜」 berkolokasi dengan 野菜を食べる、野菜を切る dan 野菜不足; kata 野菜不足 berarti kekurangan sayuran.\nKata 「野菜」 digunakan dalam contoh kalimat: "毎日野菜を食べます。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:45:26.706148+00
527	4	苦手	にがて	Tidak pandai / Lemah dalam	私は数学が苦手です。 わたしはすうがくがにがてです。	Saya tidak pandai matematika.	💡 Konteks Penggunaan:\n苦手 dipakai untuk hal yang tidak dikuasai atau tidak disukai, sering dipakai untuk mata pelajaran, makanan, atau kegiatan.\n\n📝 Catatan:\nKata 「苦手」 berkolokasi dengan 「〜が苦手です」 dan 「苦手な〜」; lawan katanya adalah 得意.\nKata 「苦手」 digunakan dalam contoh kalimat: "私は数学が苦手です。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:36:34.056275+00
532	4	故障	こしょう	Kerusakan / Gangguan	車が故障しました。 くるまがこしょうしました。	Mobilnya rusak.	💡 Konteks Penggunaan:\n故障 dipakai untuk kerusakan mesin atau peralatan, sering dipakai untuk kendaraan, alat elektronik, dan perangkat.\n\n📝 Catatan:\nKata 「故障」 berkolokasi dengan 故障する、故障が多い dan 故障中; kata 故障中 berarti sedang rusak.\nKata 「故障」 digunakan dalam contoh kalimat: "車が故障しました。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:38:25.0795+00
538	4	暗証番号	あんしょうばんごう	PIN / Nomor sandi	暗証番号を忘れてしまいました。 あんしょうばんごうをわすれてしまいました。	Saya lupa nomor PIN saya.	💡 Konteks Penggunaan:\n暗証番号 dipakai untuk nomor sandi atau PIN, seperti PIN bank, PIN kartu kredit, atau kode kunci pintu.\n\n📝 Catatan:\nKata 「暗証番号」 berkolokasi dengan 暗証番号を忘れる、暗証番号を入力する dan 暗証番号を変更する; kata 暗証 berarti rahasia atau sandi.\nKata 「暗証番号」 digunakan dalam contoh kalimat: "暗証番号を忘れてしまいました。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:40:45.547261+00
543	4	影響	えいきょう	Pengaruh / Dampak	天気が仕事に影響します。 てんきがしごとにえいきょうします。	Cuaca memengaruhi pekerjaan.	💡 Konteks Penggunaan:\n影響 dipakai untuk pengaruh atau dampak, baik dari cuaca, ekonomi, maupun orang lain terhadap suatu hal.\n\n📝 Catatan:\nKata 「影響」 berkolokasi dengan 影響する、影響を受ける dan 影響を与える; frasa 影響を受ける berarti menerima pengaruh.\nKata 「影響」 digunakan dalam contoh kalimat: "天気が仕事に影響します。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:42:41.783242+00
548	4	失敗	しっぱい	Kegagalan	試験に失敗しました。 しけんにしっぱいしました。	Saya gagal dalam ujian.	💡 Konteks Penggunaan:\n失敗 dipakai untuk kegagalan, seperti gagal dalam ujian, pekerjaan, atau usaha, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「失敗」 berkolokasi dengan 失敗する、失敗を恐れる dan 失敗から学ぶ; frasa 失敗から学ぶ berarti belajar dari kegagalan.\nKata 「失敗」 digunakan dalam contoh kalimat: "試験に失敗しました。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:44:42.310084+00
488	4	想像	そうぞう	Imajinasi / Membayangkan	未来を想像します。 みらいをそうぞうします。	Saya membayangkan masa depan.	💡 Konteks Penggunaan:\n想像 dipakai saat membayangkan sesuatu yang belum terjadi atau tidak ada di hadapan, baik masa depan maupun situasi khayalan.\n\n📝 Catatan:\nKata 「想像」 berkolokasi dengan 想像する、想像以上 dan 想像もつかない; bentuk potensialnya adalah 想像できます.\nKata 「想像」 digunakan dalam contoh kalimat: "未来を想像します。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:22:15.717937+00
494	4	疑う	うたがう	Mencurigai / Meragukan	彼の話を疑います。 かれのはなしをうたがいます。	Saya meragukan ceritanya.	💡 Konteks Penggunaan:\n疑う dipakai saat merasa ragu atau curiga terhadap kebenaran ucapan atau tindakan seseorang.\n\n📝 Catatan:\nKata 「疑う」 adalah kata kerja golongan 1, berkolokasi dengan 〜を疑う dan 疑い深い; bentuk pasifnya adalah 疑われる.\nKata 「疑う」 digunakan dalam contoh kalimat: "彼の話を疑います。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:24:17.467228+00
499	4	帰宅	きたく	Pulang ke rumah	仕事が終わって帰宅します。 しごとがおわってきたくします。	Saya pulang ke rumah setelah pekerjaan selesai.	💡 Konteks Penggunaan:\n帰宅 dipakai untuk pulang ke rumah, biasanya setelah bekerja atau bersekolah, dalam percakapan sehari-hari maupun berita.\n\n📝 Catatan:\nKata 「帰宅」 berkolokasi dengan 帰宅する、帰宅時間 dan 帰宅途中; kata 帰る lebih umum, sedangkan 帰宅 lebih formal.\nKata 「帰宅」 digunakan dalam contoh kalimat: "仕事が終わって帰宅します。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:26:09.441023+00
505	4	制限	せいげん	Batasan / Limit	参加人数に制限があります。 さんかにんずうにせいげんがあります。	Jumlah peserta dibatasi.	💡 Konteks Penggunaan:\n制限 dipakai untuk batasan atau larangan, baik dalam aturan, kapasitas, maupun penggunaan suatu fasilitas.\n\n📝 Catatan:\nKata 「制限」 berkolokasi dengan 制限する、制限がある dan 制限を設ける; kata 制限速度 berarti batas kecepatan.\nKata 「制限」 digunakan dalam contoh kalimat: "参加人数に制限があります。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:28:19.06272+00
510	4	原料	げんりょう	Bahan baku	この薬の原料は植物です。 このくすりのげんりょうはしょくぶつです。	Bahan baku obat ini adalah tumbuhan.	💡 Konteks Penggunaan:\n原料 dipakai untuk bahan dasar atau bahan baku dalam produksi, baik obat, makanan, maupun barang industri.\n\n📝 Catatan:\nKata 「原料」 berkolokasi dengan 原料を使う、原料を集める dan 原料不足; kata 原料不足 berarti kekurangan bahan baku.\nKata 「原料」 digunakan dalam contoh kalimat: "この薬の原料は植物です。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:30:03.37523+00
516	4	距離	きょり	Jarak	家から駅までの距離は近いです。 いえからえきまでのきょりはちかいです。	Jarak dari rumah ke stasiun dekat.	💡 Konteks Penggunaan:\n距離 dipakai untuk jarak fisik antara dua tempat, juga untuk jarak emosional dalam hubungan antarmanusia.\n\n📝 Catatan:\nKata 「距離」 berkolokasi dengan 距離が近い、距離を置く dan 距離を縮める; frasa 距離を置く berarti menjaga jarak.\nKata 「距離」 digunakan dalam contoh kalimat: "家から駅までの距離は近いです。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:32:14.474993+00
521	4	割引	わりびき	Diskon / Potongan harga	この店は割引をしています。 このみせはわりびきをしています。	Toko ini sedang mengadakan diskon.	💡 Konteks Penggunaan:\n割引 dipakai untuk potongan harga atau diskon, sering dipakai dalam promosi toko dan penjualan.\n\n📝 Catatan:\nKata 「割引」 berkolokasi dengan 割引する、割引セール dan 割引券; kata 割引券 berarti kupon diskon.\nKata 「割引」 digunakan dalam contoh kalimat: "この店は割引をしています。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:34:12.407493+00
201	2	諦める	あきらめる	menyerah	最後まであきらめないでください。さいごまであきらめないでください。	Jangan menyerah sampai akhir.	Konteks: menyerah. Kata 「あきらめる」 digunakan dalam kalimat contoh. Sumber: JLPT N3 この一冊で合格する, 文字・語彙, 動詞（一般）, halaman 31.				\N	f	2026-10-13 06:13:05.936438+00	2026-11-09 14:00:23.689013+00
5	1	時期	じき	Periode/Musim	この時期は雨の日が多いです。	Pada periode ini, hari-hari hujan cukup banyak.	Berbeda dari 時間（じかん）yang menunjukkan waktu atau durasi, 時期 menekankan periode tertentu.				\N	f	2026-10-12 13:22:48.902597+00	2026-11-09 14:01:12.021001+00
581	4	預かる	あずかる	Menyimpan / Menerima titipan	鍵を預かります。かぎをあずかります。	Saya menitipkan kunci.	💡 Konteks Penggunaan:\n預かる berarti menerima dan menjaga sesuatu yang dititipkan orang lain, misalnya kunci atau barang berharga, lalu mengembalikannya.\n\n📝 Catatan:\nKata 「預かる」 digunakan dalam contoh kalimat: "鍵を預かります。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:25:40.901586+00
580	4	挨拶	あいさつ	Salam / Menyapa	朝、先生に挨拶をします。あさ、せんせいにあいさつをします。	Di pagi hari, saya menyapa guru.	💡 Konteks Penggunaan:\n挨拶 dipakai saat menyapa atau memberi salam, misalnya di pagi hari, saat bertemu guru, atau di tempat kerja.\n\n📝 Catatan:\nKata 「挨拶」 digunakan dalam contoh kalimat: "朝、先生に挨拶をします。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:26:32.144106+00
579	4	苦しい	くるしい	Sulit / Menyakitkan / Berat	熱があって体が苦しいです。ねつがあってからだがくるしいです。	Badan saya terasa berat karena demam.	💡 Konteks Penggunaan:\n苦しい dipakai untuk rasa sakit atau berat secara fisik, misalnya saat sakit, serta perasaan tertekan atau sulit.\n\n📝 Catatan:\nKata 「苦しい」 digunakan dalam contoh kalimat: "熱があって体が苦しいです。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:26:54.984372+00
578	4	驚く	おどろく	Terkejut	突然の音に驚きました。とつぜんのおとにおどろきました。	Saya terkejut oleh suara yang tiba-tiba.	💡 Konteks Penggunaan:\n驚く dipakai saat terkejut karena hal yang tidak diduga, misalnya suara keras yang tiba-tiba atau kabar mengejutkan.\n\n📝 Catatan:\nKata 「驚く」 digunakan dalam contoh kalimat: "突然の音に驚きました。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:27:15.386897+00
577	4	誘う	さそう	Mengajak / Merayu	友達を映画に誘います。ともだちをえいがにさそいます。	Saya mengajak teman menonton film.	💡 Konteks Penggunaan:\n誘う dipakai untuk mengajak seseorang melakukan sesuatu bersama, misalnya menonton film, makan, atau bermain.\n\n📝 Catatan:\nKata 「誘う」 digunakan dalam contoh kalimat: "友達を映画に誘います。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:27:40.131249+00
576	4	渋滞	じゅうたい	Kemacetan	朝は道路が渋滞します。あさはどうろがじゅうたいします。	Di pagi hari, jalan macet.	💡 Konteks Penggunaan:\n渋滞 dipakai untuk kemacetan lalu lintas, biasanya di jalan raya pada jam sibuk pagi atau sore hari.\n\n📝 Catatan:\nKata 「渋滞」 digunakan dalam contoh kalimat: "朝は道路が渋滞します。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:28:04.392417+00
575	4	新鮮	しんせん	Segar	新鮮な野菜を食べます。しんせんなやさいをたべます。	Saya makan sayuran segar.	💡 Konteks Penggunaan:\n新鮮 dipakai untuk makanan segar yang baru dipanen atau ditangkap, juga untuk udara yang segar.\n\n📝 Catatan:\nKata 「新鮮」 digunakan dalam contoh kalimat: "新鮮な野菜を食べます。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:28:27.65855+00
574	4	迷子	まいご	Anak hilang / Tersesat	子供がデパートで迷子になりました。こどもがでぱーとでまいごになりました。	Anak itu tersesat di pusat perbelanjaan.	💡 Konteks Penggunaan:\n迷子 dipakai untuk anak yang tersesat atau terpisah dari orang tua di tempat ramai seperti pusat perbelanjaan atau stasiun.\n\n📝 Catatan:\nKata 「迷子」 digunakan dalam contoh kalimat: "子供がデパートで迷子になりました。"\n\n📚 Sumber: 文字語彙・ログ				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 07:28:57.099151+00
482	4	塩	しお	Garam	料理に塩を少し入れます。 りょうりにしおをすこしいれます。	Saya menambahkan sedikit garam ke dalam masakan.	💡 Konteks Penggunaan:\n塩 dipakai untuk garam dapur dan bumbu masakan sehari-hari, juga dalam ungkapan tentang rasa asin.\n\n📝 Catatan:\nKata 「塩」 sering muncul bersama kata kerja 入れる dan 振る, serta dalam frasa 塩加減 yang berarti kadar garam yang pas.\nKata 「塩」 digunakan dalam contoh kalimat: "料理に塩を少し入れます。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:18:59.30992+00
557	4	申し込む	もうしこむ	Mendaftar / Memesan	講座に申し込みます。 こうざにもうしこみます。	Saya mendaftar kursus.	💡 Konteks Penggunaan:\n申し込む dipakai untuk mendaftar atau memesan, seperti kursus, hotel, atau lomba, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「申し込む」 adalah kata kerja golongan 1, berkolokasi dengan 〜に申し込む、申し込み書 dan 申し込み期限; kata 申し込み berarti pendaftaran.\nKata 「申し込む」 digunakan dalam contoh kalimat: "講座に申し込みます。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:48:18.176049+00
562	4	材料	ざいりょう	Bahan / Material	材料を用意します。 ざいりょうをよういします。	Saya menyiapkan bahan-bahannya.	💡 Konteks Penggunaan:\n材料 dipakai untuk bahan atau material, baik bahan masakan maupun bahan pembuatan sesuatu, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「材料」 berkolokasi dengan 材料を用意する、材料を買う dan 材料費; kata 材料費 berarti biaya bahan.\nKata 「材料」 digunakan dalam contoh kalimat: "材料を用意します。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:50:02.965026+00
568	4	楽しみ	たのしみ	Kesenangan / Sesuatu yang dinanti	旅行が楽しみです。 りょこうがたのしみです。	Saya menantikan perjalanan itu.	💡 Konteks Penggunaan:\n楽しみ dipakai untuk sesuatu yang dinantikan dengan senang hati, seperti perjalanan, acara, atau pertemuan.\n\n📝 Catatan:\nKata 「楽しみ」 berkolokasi dengan 〜が楽しみです、楽しみにする dan 楽しみが増えます; frasa 楽しみにする berarti sangat menantikan.\nKata 「楽しみ」 digunakan dalam contoh kalimat: "旅行が楽しみです。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:52:09.372301+00
573	4	講演会	こうえんかい	Ceramah / Seminar	講演会に参加します。 こうえんかいにさんかします。	Saya menghadiri seminar.	💡 Konteks Penggunaan:\n講演会 dipakai untuk ceramah atau seminar, baik di kampus, perusahaan, maupun acara umum.\n\n📝 Catatan:\nKata 「講演会」 berkolokasi dengan 講演会に参加する、講演会を聞く dan 講演会場; kata 講演会場 berarti tempat seminar.\nKata 「講演会」 digunakan dalam contoh kalimat: "講演会に参加します。"				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 08:53:54.314446+00
483	4	命令	めいれい	Perintah	上司の命令に従います。 じょうしのめいれいにしたがいます。	Saya mengikuti perintah atasan.	💡 Konteks Penggunaan:\n命令 dipakai untuk perintah resmi dari atasan, guru, atau orang yang berwenang, sering dalam konteks pekerjaan dan organisasi.\n\n📝 Catatan:\nKata 「命令」 berkolokasi dengan kata kerja 従う dan 下す, serta frasa 命令を出す.\nKata 「命令」 digunakan dalam contoh kalimat: "上司の命令に従います。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:20:01.168382+00
484	4	機械	きかい	Mesin	機械は正常に動いています。 きかいはせいじょうにうごいています。	Mesin itu berfungsi dengan normal.	💡 Konteks Penggunaan:\n機械 dipakai untuk mesin dan perangkat mekanis, dari mesin pabrik sampai peralatan rumah tangga.\n\n📝 Catatan:\nKata 「機械」 berkolokasi dengan 動く、止まる、修理する, serta frasa 機械が壊れる yang berarti mesin rusak.\nKata 「機械」 digunakan dalam contoh kalimat: "機械は正常に動いています。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:20:24.749521+00
485	4	休日	きゅうじつ	Hari libur	休日は家でのんびり過ごします。 きゅうじつはいえでのんびりすごします。	Pada hari libur, saya bersantai di rumah.	💡 Konteks Penggunaan:\n休日 dipakai untuk hari libur, baik akhir pekan maupun hari libur nasional, saat tidak bekerja atau bersekolah.\n\n📝 Catatan:\nKata 「休日」 sering muncul dalam frasa 休日に dan 休日を過ごす; untuk hari libur nasional digunakan kata 祝日.\nKata 「休日」 digunakan dalam contoh kalimat: "休日は家でのんびり過ごします。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:21:15.079948+00
486	4	得意	とくい	Pandai / Ahli	私は英語が得意です。 わたしはえいごがとくいです。	Saya pandai berbahasa Inggris.	💡 Konteks Penggunaan:\n得意 dipakai untuk hal yang dikuasai atau menjadi kelebihan seseorang, sering dipakai untuk mata pelajaran, olahraga, atau keterampilan.\n\n📝 Catatan:\nKata 「得意」 berkolokasi dengan bentuk 「〜が得意です」 dan 「得意な〜」; lawan katanya adalah 苦手.\nKata 「得意」 digunakan dalam contoh kalimat: "私は英語が得意です。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:21:34.778628+00
487	4	複雑	ふくざつ	Rumit / Kompleks	この問題は複雑です。 このもんだいはふくざつです。	Masalah ini rumit.	💡 Konteks Penggunaan:\n複雑 dipakai untuk hal yang rumit dan sulit dipahami, seperti masalah, hubungan, atau sistem yang memiliki banyak bagian.\n\n📝 Catatan:\nKata 「複雑」 berkolokasi dengan frasa 複雑になる dan 複雑な問題; lawan katanya adalah 単純.\nKata 「複雑」 digunakan dalam contoh kalimat: "この問題は複雑です。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:21:57.925247+00
489	4	確認	かくにん	Konfirmasi / Pengecekan	予約を確認します。 よやくをかくにんします。	Saya memeriksa reservasi.	💡 Konteks Penggunaan:\n確認 dipakai saat memeriksa atau memastikan sesuatu, seperti jadwal, reservasi, atau kebenaran informasi.\n\n📝 Catatan:\nKata 「確認」 berkolokasi dengan 確認する、確認を取る dan 確認が必要です; bentuk sopannya adalah ご確認ください.\nKata 「確認」 digunakan dalam contoh kalimat: "予約を確認します。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:22:37.087519+00
490	4	経営	けいえい	Manajemen / Mengelola	彼は会社を経営しています。 かれはかいしゃをけいえいしています。	Dia mengelola perusahaan.	💡 Konteks Penggunaan:\n経営 dipakai untuk pengelolaan perusahaan atau organisasi, termasuk manajemen keuangan dan strategi usaha.\n\n📝 Catatan:\nKata 「経営」 berkolokasi dengan 経営する、経営が苦しい dan 経営者; 経営者 berarti pemilik atau pengelola perusahaan.\nKata 「経営」 digunakan dalam contoh kalimat: "彼は会社を経営しています。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:22:56.656077+00
491	4	資源	しげん	Sumber daya	日本は資源が少ない国です。 にほんはしげんがすくないくにです。	Jepang adalah negara yang miskin sumber daya.	💡 Konteks Penggunaan:\n資源 dipakai untuk sumber daya alam atau sumber daya manusia, sering dalam konteks ekonomi, energi, dan lingkungan.\n\n📝 Catatan:\nKata 「資源」 berkolokasi dengan 資源が豊かだ、天然資源 dan 資源を守る; bentuk jamaknya tidak berubah.\nKata 「資源」 digunakan dalam contoh kalimat: "日本は資源が少ない国です。"				\N	f	2026-11-09 09:52:27.726044+00	2026-11-14 08:23:18.800554+00
492	4	恋しい	こいしい	Merindukan	故郷が恋しいです。 ふるさとがこいしいです。	Saya merindukan kampung halaman.	💡 Konteks Penggunaan:\n恋しい dipakai untuk kerinduan yang mendalam, biasanya untuk kampung halaman, orang tercinta, atau masa lalu.\n\n📝 Catatan:\nKata 「恋しい」 adalah bentuk i-adjective, berkolokasi dengan 故郷が恋しい dan 恋しい人; lawan konteksnya adalah 懐かしい yang lebih menekankan nostalgia.\nKata 「恋しい」 digunakan dalam contoh kalimat: "故郷が恋しいです。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:23:37.797967+00
493	4	部分	ぶぶん	Bagian	この部分を直してください。 このぶぶんをなおしてください。	Tolong perbaiki bagian ini.	💡 Konteks Penggunaan:\n部分 dipakai untuk menyebut sebagian dari keseluruhan, baik bagian benda, tubuh, maupun bagian dari suatu teks atau pekerjaan.\n\n📝 Catatan:\nKata 「部分」 berkolokasi dengan 一部分、部分的に dan 部分を直す; bentuk adverbialnya adalah 部分的に yang berarti sebagian.\nKata 「部分」 digunakan dalam contoh kalimat: "この部分を直してください。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:23:58.42296+00
495	4	疲れ	つかれ	Kelelahan / Capek	疲れがたまっています。 つかれがたまっています。	Kelelahan saya menumpuk.	💡 Konteks Penggunaan:\n疲れ dipakai untuk rasa lelah yang menumpuk setelah bekerja atau beraktivitas, sering dipakai untuk kondisi fisik maupun mental.\n\n📝 Catatan:\nKata 「疲れ」 adalah bentuk nomina dari 疲れる, berkolokasi dengan 疲れがたまる、疲れを取る dan 疲れが出る.\nKata 「疲れ」 digunakan dalam contoh kalimat: "疲れがたまっています。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:24:41.504234+00
496	4	泣く	なく	Menangis	映画を見て泣きました。 えいがをみて泣きました。	Saya menangis setelah menonton film.	💡 Konteks Penggunaan:\n泣く dipakai untuk menangis, baik karena sedih maupun terharu, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「泣く」 adalah kata kerja golongan 1, berkolokasi dengan 声を出して泣く dan 泣き出す; bentuk sopannya adalah 泣きます.\nKata 「泣く」 digunakan dalam contoh kalimat: "映画を見て泣きました。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:25:01.219957+00
497	4	当たる	あたる	Mengenai / Menabrak	宝くじが当たりました。 たからくじがあたりました。	Saya memenangkan lotre.	💡 Konteks Penggunaan:\n当たる dipakai untuk sesuatu yang mengenai sasaran, seperti lotre yang menang, ramalan yang tepat, atau benda yang menabrak.\n\n📝 Catatan:\nKata 「当たる」 adalah kata kerja golongan 1, berkolokasi dengan 宝くじが当たる、予想が当たる dan 壁に当たる; bentuk potensialnya adalah 当たれる.\nKata 「当たる」 digunakan dalam contoh kalimat: "宝くじが当たりました。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:25:24.560276+00
498	4	右折	うせつ	Belok Kanan	次の信号を右折します。 つぎのしんごうをうせつします。	Saya akan belok kanan di lampu lalu lintas berikutnya.	💡 Konteks Penggunaan:\n右折 dipakai untuk belok kanan saat berkendara atau berjalan, sering dipakai bersama rambu dan petunjuk arah.\n\n📝 Catatan:\nKata 「右折」 berkolokasi dengan 右折する、右折禁止 dan 右折レーン; lawan katanya adalah 左折.\nKata 「右折」 digunakan dalam contoh kalimat: "次の信号を右折します。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:25:46.65794+00
500	4	観察	かんさつ	Pengamatan	鳥を観察します。 とりをかんさつします。	Saya mengamati burung.	💡 Konteks Penggunaan:\n観察 dipakai untuk mengamati dengan saksama, baik hewan, tumbuhan, maupun perubahan dalam percakapan sehari-hari dan penelitian.\n\n📝 Catatan:\nKata 「観察」 berkolokasi dengan 観察する、観察力 dan 観察記録; kata 観察力 berarti kemampuan mengamati.\nKata 「観察」 digunakan dalam contoh kalimat: "鳥を観察します。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:26:28.705803+00
501	4	期待	きたい	Harapan / Ekspektasi	彼の活躍を期待しています。 かれのかつやくをきたいしています。	Saya mengharapkan penampilannya yang gemilang.	💡 Konteks Penggunaan:\n期待 dipakai untuk harapan terhadap seseorang atau sesuatu, baik dalam pekerjaan, olahraga, maupun kehidupan sehari-hari.\n\n📝 Catatan:\nKata 「期待」 berkolokasi dengan 期待する、期待に応える dan 期待外れ; kata 期待外れ berarti di luar harapan.\nKata 「期待」 digunakan dalam contoh kalimat: "彼の活躍を期待しています。"				\N	f	2026-11-09 09:52:58.521929+00	2026-11-14 08:26:49.49924+00
502	4	知り合う	しりあう	Berkenalan	彼女と知り合いました。 かのじょとしりあいました。	Saya berkenalan dengan dia (perempuan).	💡 Konteks Penggunaan:\n知り合う dipakai saat pertama kali berkenalan dengan seseorang, dalam percakapan sehari-hari maupun situasi formal.\n\n📝 Catatan:\nKata 「知り合う」 berkolokasi dengan 〜と知り合う dan 知り合いになる; kata 知り合い berarti kenalan.\nKata 「知り合う」 digunakan dalam contoh kalimat: "彼女と知り合いました。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:27:14.8247+00
503	4	待ち合わせる	まちあわせる	Janji bertemu	駅で待ち合わせます。 えきでまちあわせます。	Saya janji bertemu di stasiun.	💡 Konteks Penggunaan:\n待ち合わせる dipakai saat membuat janji bertemu di suatu tempat dan waktu, sering dalam percakapan dan pesan sehari-hari.\n\n📝 Catatan:\nKata 「待ち合わせる」 berkolokasi dengan 〜で待ち合わせる dan 待ち合わせ場所; kata 待ち合わせ berarti janji bertemu.\nKata 「待ち合わせる」 digunakan dalam contoh kalimat: "駅で待ち合わせます。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:27:33.893643+00
504	4	付き合う	つきあう	Bergaul / Menemani	友達とよく付き合います。 ともだちとよくつきあいます。	Saya sering bergaul dengan teman.	💡 Konteks Penggunaan:\n付き合う dipakai untuk bergaul atau menghabiskan waktu bersama seseorang, juga untuk berpacaran dalam konteks hubungan.\n\n📝 Catatan:\nKata 「付き合う」 berkolokasi dengan 〜と付き合う dan 付き合い; kata 付き合い berarti pergaulan atau hubungan sosial.\nKata 「付き合う」 digunakan dalam contoh kalimat: "友達とよく付き合います。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:27:55.254898+00
506	4	意外に	いがいに	Di luar dugaan	意外に早く終わりました。 いがいに早くおわりました。	Di luar dugaan, pekerjaan itu selesai cepat.	💡 Konteks Penggunaan:\n意外に dipakai untuk sesuatu yang terjadi di luar dugaan, sering dipakai untuk hasil, kecepatan, atau kesan yang mengejutkan.\n\n📝 Catatan:\nKata 「意外に」 berkolokasi dengan 意外に早い、意外に簡単 dan 意外な結果; kata 意外 berarti tidak terduga.\nKata 「意外に」 digunakan dalam contoh kalimat: "意外に早く終わりました。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:28:41.114824+00
507	4	商売	しょうばい	Bisnis / Dagang	父は商売をしています。 ちちはしょうばいをしています。	Ayah saya berbisnis.	💡 Konteks Penggunaan:\n商売 dipakai untuk usaha dagang atau bisnis, sering dipakai untuk toko dan pekerjaan perdagangan sehari-hari.\n\n📝 Catatan:\nKata 「商売」 berkolokasi dengan 商売をする、商売が繁盛する dan 商売敵; kata 商売繁盛 berarti usaha yang laris.\nKata 「商売」 digunakan dalam contoh kalimat: "父は商売をしています。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:29:01.996201+00
508	4	会計	かいけい	Akuntansi / Pembayaran	会計をお願いします。 かいけいをおねがいします。	Tolong, saya minta struk pembayaran.	💡 Konteks Penggunaan:\n会計 dipakai untuk pembayaran di kasir, juga untuk akuntansi dalam konteks bisnis dan keuangan.\n\n📝 Catatan:\nKata 「会計」 berkolokasi dengan 会計をする、会計を済ませる dan お会計; frasa 会計をお願いします dipakai saat meminta bon.\nKata 「会計」 digunakan dalam contoh kalimat: "会計をお願いします。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:29:21.684625+00
509	4	貿易	ぼうえき	Perdagangan Internasional	日本は貿易が盛んです。 にほんはぼうえきがさかんです。	Perdagangan internasional Jepang sangat aktif.	💡 Konteks Penggunaan:\n貿易 dipakai untuk perdagangan antarnegara, sering dipakai dalam berita ekonomi dan pembahasan bisnis internasional.\n\n📝 Catatan:\nKata 「貿易」 berkolokasi dengan 貿易をする、貿易が盛んだ dan 貿易会社; kata 貿易会社 berarti perusahaan perdagangan.\nKata 「貿易」 digunakan dalam contoh kalimat: "日本は貿易が盛んです。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:29:42.449303+00
511	4	栄養	えいよう	Nutrisi / Gizi	野菜から栄養を取ります。 やさいからえいようをとります。	Saya mendapatkan nutrisi dari sayuran.	💡 Konteks Penggunaan:\n栄養 dipakai untuk zat gizi dalam makanan, juga untuk nutrisi yang dibutuhkan tubuh.\n\n📝 Catatan:\nKata 「栄養」 berkolokasi dengan 栄養を取る、栄養が足りない dan 栄養バランス; kata 栄養バランス berarti keseimbangan gizi.\nKata 「栄養」 digunakan dalam contoh kalimat: "野菜から栄養を取ります。"				\N	f	2026-11-09 09:53:29.384927+00	2026-11-14 08:30:25.696298+00
512	4	基礎	きそ	Dasar / Fondasi	基礎をしっかり学びます。 きそをしっかりまなびます。	Saya mempelajari dasar-dasarnya dengan sungguh-sungguh.	💡 Konteks Penggunaan:\n基礎 dipakai untuk dasar atau fondasi dalam belajar, olahraga, maupun bangunan, sering dalam konteks pendidikan.\n\n📝 Catatan:\nKata 「基礎」 berkolokasi dengan 基礎を学ぶ、基礎が大切だ dan 基礎知識; kata 基礎知識 berarti pengetahuan dasar.\nKata 「基礎」 digunakan dalam contoh kalimat: "基礎をしっかり学びます。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:30:48.235432+00
513	4	団体	だんたい	Kelompok / Rombongan	団体で旅行に行きます。 だんたいでりょこうにいきます。	Kami pergi berwisata dalam rombongan.	💡 Konteks Penggunaan:\n団体 dipakai untuk kelompok atau rombongan yang terorganisasi, seperti rombongan wisata, organisasi, atau tim.\n\n📝 Catatan:\nKata 「団体」 berkolokasi dengan 団体旅行、団体で dan 団体行動; kata 団体旅行 berarti wisata rombongan.\nKata 「団体」 digunakan dalam contoh kalimat: "団体で旅行に行きます。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:31:09.75297+00
514	4	退屈	たいくつ	Bosan	退屈な授業でした。 たいくつなじゅぎょうでした。	Itu adalah pelajaran yang membosankan.	💡 Konteks Penggunaan:\n退屈 dipakai untuk sesuatu yang membosankan, seperti pelajaran, film, atau waktu luang yang monoton.\n\n📝 Catatan:\nKata 「退屈」 berkolokasi dengan 退屈な〜、退屈する dan 退屈しのぎ; kata 退屈しのぎ berarti pengisi waktu saat bosan.\nKata 「退屈」 digunakan dalam contoh kalimat: "退屈な授業でした。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:31:31.822789+00
515	4	多少	たしょう	Sedikit banyak	多少の違いがあります。 たしょうのちがいがあります。	Ada sedikit perbedaan.	💡 Konteks Penggunaan:\n多少 dipakai untuk jumlah atau tingkat yang sedikit, sering dipakai untuk perbedaan, perubahan, atau jumlah yang tidak besar.\n\n📝 Catatan:\nKata 「多少」 berkolokasi dengan 多少の〜、多少は dan 多少なりとも; kata 多少なりとも berarti sedikit banyak.\nKata 「多少」 digunakan dalam contoh kalimat: "多少の違いがあります。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:31:51.725101+00
517	4	活動	かつどう	Aktivitas / Kegiatan	ボランティア活動に参加します。 ボランティアかつどうにさんかします。	Saya mengikuti kegiatan sukarela.	💡 Konteks Penggunaan:\n活動 dipakai untuk aktivitas atau kegiatan, baik dalam organisasi, sekolah, maupun kehidupan sehari-hari.\n\n📝 Catatan:\nKata 「活動」 berkolokasi dengan 活動する、活動に参加する dan 活動的; kata 活動的 berarti aktif.\nKata 「活動」 digunakan dalam contoh kalimat: "ボランティア活動に参加します。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:32:35.565245+00
518	4	盛ん	さかん	Populer / Ramai / Makmur	桜が盛んに咲いています。 さくらがさかんにさいています。	Bunga sakura sedang mekar lebat-lebatnya.	💡 Konteks Penggunaan:\n盛ん dipakai untuk sesuatu yang sedang ramai, makmur, atau berlangsung dengan giat, seperti festival, bisnis, atau bunga yang mekar.\n\n📝 Catatan:\nKata 「盛ん」 adalah na-adjective, berkolokasi dengan 盛んに〜、盛んな〜 dan 盛んになる; bentuk adverbialnya adalah 盛んに.\nKata 「盛ん」 digunakan dalam contoh kalimat: "桜が盛んに咲いています。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:33:02.596982+00
519	4	区別	くべつ	Perbedaan / Membedakan	両者の区別がつきません。 りょうしゃのくべつがつきません。	Saya tidak bisa membedakan keduanya.	💡 Konteks Penggunaan:\n区別 dipakai untuk membedakan dua hal atau lebih, sering dipakai untuk perbedaan antara konsep, benda, atau kategori.\n\n📝 Catatan:\nKata 「区別」 berkolokasi dengan 区別する、区別がつく dan 区別がつかない; frasa 区別がつかない berarti tidak bisa dibedakan.\nKata 「区別」 digunakan dalam contoh kalimat: "両者の区別がつきません。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:33:26.756984+00
520	4	過ごす	すごす	Menghabiskan (waktu)	休日は家で過ごします。 きゅうじつはいえですごします。	Pada hari libur, saya menghabiskan waktu di rumah.	💡 Konteks Penggunaan:\n過ごす dipakai untuk menghabiskan waktu, baik di rumah, di luar, maupun bersama seseorang, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「過ごす」 berkolokasi dengan 〜を過ごす、休日を過ごす dan 時間を過ごす; bentuk sopannya adalah 過ごします.\nKata 「過ごす」 digunakan dalam contoh kalimat: "休日は家で過ごします。"				\N	f	2026-11-09 09:54:02.781553+00	2026-11-14 08:33:50.452891+00
522	4	早起き	はやおき	Bangun pagi	明日は早起きします。 あしたははやおきします。	Besok saya akan bangun pagi.	💡 Konteks Penggunaan:\n早起き dipakai untuk bangun pagi, sering dipakai untuk kebiasaan, rencana, atau jadwal keesokan hari.\n\n📝 Catatan:\nKata 「早起き」 berkolokasi dengan 早起きする、早起きが苦手 dan 早起きは三文の徳; pepatah 早起きは三文の徳 berarti bangun pagi membawa keberuntungan.\nKata 「早起き」 digunakan dalam contoh kalimat: "明日は早起きします。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:34:37.074601+00
523	4	弁当	べんとう	Bekal makanan	母が弁当を作ってくれました。 ははがべんとうをつくってくれました。	Ibu membuatkan bekal untuk saya.	💡 Konteks Penggunaan:\n弁当 dipakai untuk bekal makanan, baik yang dibuat di rumah maupun yang dibeli di toko, sering dipakai untuk makan siang.\n\n📝 Catatan:\nKata 「弁当」 berkolokasi dengan 弁当を作る、弁当を持っていく dan 弁当箱; kata 弁当箱 berarti kotak bekal.\nKata 「弁当」 digunakan dalam contoh kalimat: "母が弁当を作ってくれました。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:34:59.471187+00
524	4	健康	けんこう	Kesehatan	健康のために毎日歩きます。 けんこうのためにまいにちあるきます。	Saya berjalan kaki setiap hari demi kesehatan.	💡 Konteks Penggunaan:\n健康 dipakai untuk kesehatan tubuh dan pikiran, sering dipakai dalam konteks gaya hidup, makanan, dan olahraga.\n\n📝 Catatan:\nKata 「健康」 berkolokasi dengan 健康にいい、健康を保つ dan 健康診断; kata 健康診断 berarti pemeriksaan kesehatan.\nKata 「健康」 digunakan dalam contoh kalimat: "健康のために毎日歩きます。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:35:23.728448+00
525	4	資料	しりょう	Materi / Dokumen	会議の資料を読みます。 かいぎのしりょうをよみます。	Saya membaca materi rapat.	💡 Konteks Penggunaan:\n資料 dipakai untuk dokumen atau materi, baik untuk rapat, penelitian, maupun pelajaran, dalam konteks formal dan sehari-hari.\n\n📝 Catatan:\nKata 「資料」 berkolokasi dengan 資料を読む、資料を集める dan 資料を配る; kata 資料集 berarti kumpulan materi.\nKata 「資料」 digunakan dalam contoh kalimat: "会議の資料を読みます。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:35:44.650711+00
529	4	諦める	あきらめる	Menyerah	夢を諦めません。 ゆめをあきらめません。	Saya tidak akan menyerah pada impian saya.	💡 Konteks Penggunaan:\n諦める dipakai saat menyerah atau melepaskan sesuatu, seperti impian, harapan, atau usaha yang sulit.\n\n📝 Catatan:\nKata 「諦める」 adalah kata kerja golongan 2, berkolokasi dengan 〜を諦める、諦めがつく dan 諦めないで; frasa 諦めないで berarti jangan menyerah.\nKata 「諦める」 digunakan dalam contoh kalimat: "夢を諦めません。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:37:19.013815+00
531	4	片付く	かたづく	Rapi / Beres	部屋が片付きました。 へやがかたづきました。	Kamar sudah rapi.	💡 Konteks Penggunaan:\n片付く dipakai untuk sesuatu yang menjadi rapi atau beres, sering dipakai untuk kamar, meja, atau pekerjaan yang selesai.\n\n📝 Catatan:\nKata 「片付く」 adalah kata kerja intransitif golongan 1, berkolokasi dengan 部屋が片付く dan 片付いた; bentuk transitifnya adalah 片付ける.\nKata 「片付く」 digunakan dalam contoh kalimat: "部屋が片付きました。"				\N	f	2026-11-09 09:54:33.553826+00	2026-11-14 08:38:03.977276+00
534	4	ゆるい	ゆるい	Longgar	このズボンはゆるいです。 このズボンはゆるいです。	Celana ini longgar.	💡 Konteks Penggunaan:\nゆるい dipakai untuk sesuatu yang longgar, seperti pakaian dan sepatu, juga untuk aturan atau jadwal yang tidak ketat.\n\n📝 Catatan:\nKata 「ゆるい」 adalah i-adjective, berkolokasi dengan ゆるいズボン、ゆるい靴 dan ゆるいルール; lawan katanya adalah きつい.\nKata 「ゆるい」 digunakan dalam contoh kalimat: "このズボンはゆるいです。"				\N	f	2026-11-09 09:55:13.666324+00	2026-11-14 08:39:11.074242+00
550	4	土地	とち	Tanah / Lahan	この土地は広いです。 このとちはひろいです。	Tanah ini luas.	💡 Konteks Penggunaan:\n土地 dipakai untuk tanah atau lahan, baik sebagai tempat tinggal, ladang, maupun properti, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「土地」 berkolokasi dengan 土地を買う、土地が広い dan 土地建物; kata 土地建物 berarti tanah dan bangunan.\nKata 「土地」 digunakan dalam contoh kalimat: "この土地は広いです。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:45:48.335817+00
551	4	機会	きかい	Kesempatan	いい機会が来ました。 いいきかいがきました。	Kesempatan bagus telah datang.	💡 Konteks Penggunaan:\n機会 dipakai untuk kesempatan atau peluang, baik dalam pekerjaan, belajar, maupun momen penting dalam hidup.\n\n📝 Catatan:\nKata 「機会」 berkolokasi dengan 機会がある、機会を得る dan 機会を逃す; frasa 機会を逃す berarti melewatkan kesempatan.\nKata 「機会」 digunakan dalam contoh kalimat: "いい機会が来ました。"				\N	f	2026-11-09 09:55:55.842678+00	2026-11-14 08:46:10.604601+00
552	4	共同	きょうどう	Bersama / Kolaborasi	共同でプロジェクトを進めます。 きょうどうでプロジェクトをすすめます。	Kami mengerjakan proyek bersama-sama.	💡 Konteks Penggunaan:\n共同 dipakai untuk sesuatu yang dilakukan bersama, seperti pekerjaan proyek, penulisan, atau penyewaan rumah.\n\n📝 Catatan:\nKata 「共同」 berkolokasi dengan 共同で、共同作業 dan 共同生活; kata 共同生活 berarti hidup bersama.\nKata 「共同」 digunakan dalam contoh kalimat: "共同でプロジェクトを進めます。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:46:30.365344+00
553	4	交流	こうりゅう	Interaksi / Pertukaran	日本の学生と交流します。 にほんのがくせいとこうりゅうします。	Saya berinteraksi dengan siswa-siswa Jepang.	💡 Konteks Penggunaan:\n交流 dipakai untuk interaksi atau pertukaran dengan orang, budaya, atau negara lain, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「交流」 berkolokasi dengan 交流する、交流会 dan 国際交流; kata 国際交流 berarti pertukaran internasional.\nKata 「交流」 digunakan dalam contoh kalimat: "日本の学生と交流します。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:46:55.899081+00
554	4	将来	しょうらい	Masa depan	将来は先生になりたいです。 しょうらいはせんせいになりたいです。	Di masa depan, saya ingin menjadi guru.	💡 Konteks Penggunaan:\n将来 dipakai untuk masa depan, baik untuk rencana karier, cita-cita, maupun kehidupan yang akan datang.\n\n📝 Catatan:\nKata 「将来」 berkolokasi dengan 将来の夢、将来は〜になりたい dan 将来性; kata 将来の夢 berarti cita-cita masa depan.\nKata 「将来」 digunakan dalam contoh kalimat: "将来は先生になりたいです。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:47:19.129222+00
555	4	汗	あせ	Keringat	汗が出ました。 あせがでました。	Saya berkeringat.	💡 Konteks Penggunaan:\n汗 dipakai untuk keringat, baik saat berolahraga, cuaca panas, maupun gugup, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「汗」 berkolokasi dengan 汗が出る、汗をかく dan 汗を拭く; frasa 汗をかく berarti berkeringat.\nKata 「汗」 digunakan dalam contoh kalimat: "汗が出ました。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:47:36.701803+00
556	4	料金	りょうきん	Biaya / Tarif	この料金は高いです。 このりょうきんはたかいです。	Biaya ini mahal.	💡 Konteks Penggunaan:\n料金 dipakai untuk biaya atau tarif layanan, seperti tiket, penginapan, atau transportasi, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「料金」 berkolokasi dengan 料金が高い、料金を払う dan 料金表; kata 料金表 berarti daftar tarif.\nKata 「料金」 digunakan dalam contoh kalimat: "この料金は高いです。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:47:58.231074+00
558	4	自宅	じたく	Rumah sendiri	自宅で勉強をします。 じたくでべんきょうをします。	Saya belajar di rumah.	💡 Konteks Penggunaan:\n自宅 dipakai untuk rumah sendiri, baik sebagai tempat tinggal maupun tempat bekerja atau belajar.\n\n📝 Catatan:\nKata 「自宅」 berkolokasi dengan 自宅で、自宅勤務 dan 自宅に帰る; kata 自宅勤務 berarti bekerja dari rumah.\nKata 「自宅」 digunakan dalam contoh kalimat: "自宅で勉強をします。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:48:38.399221+00
559	4	届ける	とどける	Mengantarkan	荷物を届けます。 にもつをとどけます。	Saya mengantarkan paket.	💡 Konteks Penggunaan:\n届ける dipakai untuk mengantarkan barang atau menyampaikan sesuatu kepada seseorang, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「届ける」 adalah kata kerja golongan 2, berkolokasi dengan 荷物を届ける、届け先 dan 届ける先; kata 届け先 berarti alamat tujuan.\nKata 「届ける」 digunakan dalam contoh kalimat: "荷物を届けます。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:48:58.070385+00
560	4	営業	えいぎょう	Operasional (usaha) / Penjualan	営業は9時からです。 えいぎょうは9じからです。	Jam operasional mulai pukul 9.	💡 Konteks Penggunaan:\n営業 dipakai untuk jam operasional atau kegiatan penjualan sebuah usaha, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「営業」 berkolokasi dengan 営業時間、営業中 dan 営業日; kata 営業時間 berarti jam operasional.\nKata 「営業」 digunakan dalam contoh kalimat: "営業は9時からです。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:49:16.652744+00
561	4	祝日	しゅくじつ	Hari libur nasional	明日は祝日です。 あすはしゅくじつです。	Besok adalah hari libur nasional.	💡 Konteks Penggunaan:\n祝日 dipakai untuk hari libur nasional, seperti Tahun Baru, Hari Anak, atau hari peringatan resmi di Jepang.\n\n📝 Catatan:\nKata 「祝日」 berkolokasi dengan 祝日は〜です、祝日に〜する dan 祝日出勤; kata 祝日出勤 berarti masuk kerja di hari libur.\nKata 「祝日」 digunakan dalam contoh kalimat: "明日は祝日です。"				\N	f	2026-11-09 09:56:50.303285+00	2026-11-14 08:49:35.953369+00
563	4	種類	しゅるい	Jenis / Macam	いろいろな種類があります。 いろいろなしゅるいがあります。	Ada berbagai macam jenis.	💡 Konteks Penggunaan:\n種類 dipakai untuk jenis atau macam, baik barang, makanan, maupun hal lainnya, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「種類」 berkolokasi dengan 種類がある、いろいろな種類 dan 種類が多い; frasa いろいろな種類 berarti berbagai macam jenis.\nKata 「種類」 digunakan dalam contoh kalimat: "いろいろな種類があります。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:50:22.277181+00
564	4	自由	じゆう	Bebas / Kebebasan	自由に生きたいです。 じゆうにいきたいです。	Saya ingin hidup bebas.	💡 Konteks Penggunaan:\n自由 dipakai untuk bebas atau kebebasan, baik dalam memilih, hidup, maupun berpendapat, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「自由」 berkolokasi dengan 自由に、自由な時間 dan 自由を失う; frasa 自由な時間 berarti waktu luang yang bebas.\nKata 「自由」 digunakan dalam contoh kalimat: "自由に生きたいです。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:50:44.583162+00
11	1	ご紹介します	ごしょうかいします	Memperkenalkan	この方をご紹介します。	Saya memperkenalkan orang ini.	「ご紹介します」 adalah ungkapan sopan untuk memperkenalkan seseorang kepada orang lain. Ungkapan ini biasa dipakai di awal pertemuan formal, biasanya diikuti nama orang yang diperkenalkan.				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:54:24.975777+00
565	4	実際	じっさい	Kenyataan / Praktiknya	実際は忙しいです。 じっさいはいそがしいです。	Pada kenyataannya, saya sibuk.	💡 Konteks Penggunaan:\n実際 dipakai untuk menjelaskan kenyataan yang berbeda dari perkiraan atau rumor, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「実際」 berkolokasi dengan 実は、実際には dan 実際的; kata 実際的 berarti praktis atau realistis.\nKata 「実際」 digunakan dalam contoh kalimat: "実際は忙しいです。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:51:06.331371+00
566	4	練習	れんしゅう	Latihan	毎日日本語を練習します。 まいにちにほんごをれんしゅうします。	Saya berlatih bahasa Jepang setiap hari.	💡 Konteks Penggunaan:\n練習 dipakai untuk latihan, baik olahraga, musik, maupun belajar bahasa, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「練習」 berkolokasi dengan 練習する、練習を重ねる dan 練習試合; kata 練習試合 berarti pertandingan latihan.\nKata 「練習」 digunakan dalam contoh kalimat: "毎日日本語を練習します。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:51:29.192926+00
567	4	上手	じょうず	Pandai / Mahir	彼は日本語が上手です。 かれはにほんごがじょうずです。	Dia pandai berbahasa Jepang.	💡 Konteks Penggunaan:\n上手 dipakai untuk memuji keterampilan seseorang, baik dalam bahasa, olahraga, maupun seni, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「上手」 berkolokasi dengan 〜が上手です、〜が上手になる dan 上手下手; kata 上手下手 berarti bagus-buruknya.\nKata 「上手」 digunakan dalam contoh kalimat: "彼は日本語が上手です。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:51:49.750117+00
569	4	平気	へいき	Tidak apa-apa / Tenang	平気ですよ。 へいきですよ。	Tidak apa-apa.	💡 Konteks Penggunaan:\n平気 dipakai untuk mengatakan tidak apa-apa atau tidak ada masalah, baik saat ditanya kabar maupun ketika ditawari sesuatu.\n\n📝 Catatan:\nKata 「平気」 berkolokasi dengan 平気です、平気で〜する dan 平気な顔; kata 平気な顔 berarti wajah tanpa beban.\nKata 「平気」 digunakan dalam contoh kalimat: "平気ですよ。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:52:31.534441+00
570	4	文句	もんく	Keluhan / Komplain	文句を言います。 もんくをいいます。	Saya mengeluh.	💡 Konteks Penggunaan:\n文句 dipakai untuk keluhan atau komplain, baik tentang makanan, layanan, maupun situasi yang tidak menyenangkan.\n\n📝 Catatan:\nKata 「文句」 berkolokasi dengan 文句を言う、文句が多い dan 文句なし; frasa 文句なし berarti tanpa cela atau sempurna.\nKata 「文句」 digunakan dalam contoh kalimat: "文句を言います。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:52:53.038667+00
571	4	単純	たんじゅん	Sederhana / Simpel	問題は単純です。 もんだいはたんじゅんです。	Soal itu sederhana.	💡 Konteks Penggunaan:\n単純 dipakai untuk sesuatu yang sederhana atau tidak rumit, baik soal, cara kerja, maupun sifat seseorang.\n\n📝 Catatan:\nKata 「単純」 berkolokasi dengan 単純です、単純な問題 dan 単純化; kata 単純化 berarti penyederhanaan.\nKata 「単純」 digunakan dalam contoh kalimat: "問題は単純です。"				\N	f	2026-11-09 09:58:03.330467+00	2026-11-14 08:53:15.381028+00
572	4	台所	だいどころ	Dapur	台所で料理をします。 だいどころでりょうりをします。	Saya memasak di dapur.	💡 Konteks Penggunaan:\n台所 dipakai untuk dapur, tempat memasak dan menyiapkan makanan, dalam percakapan sehari-hari.\n\n📝 Catatan:\nKata 「台所」 berkolokasi dengan 台所で、台所用品 dan 台所に立つ; frasa 台所に立つ berarti memasak di dapur.\nKata 「台所」 digunakan dalam contoh kalimat: "台所で料理をします。"				\N	f	2026-11-09 09:59:14.307811+00	2026-11-14 08:53:33.913207+00
17	1	次回	じかい	Selanjutnya/Lain kali	次回は一緒に行きましょう。	Lain kali, mari pergi bersama.	「次回」 berarti kesempatan berikutnya atau lain kali. Kata ini sering dipakai untuk menunda sesuatu ke pertemuan atau kesempatan berikutnya, dan berkolokasi dengan 次回に dan 次回は。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:56:32.799742+00
18	1	機能	きのう	Fungsi/Kemampuan	機能を使います。	Saya menggunakan fungsi ini.	「機能」 berarti fungsi atau kemampuan suatu alat, sistem, atau tubuh. Kata ini sering dipakai untuk menjelaskan cara kerja suatu perangkat atau aplikasi, dan berkolokasi dengan 機能を使う dan 機能を持つ。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:56:52.809529+00
20	1	価値	かち	Harga/Nilai/Manfaat	価値があります。	Hal itu bernilai.	「価値」 berarti nilai, harga, atau manfaat sesuatu. Kata ini dipakai untuk menilai pentingnya suatu benda, pekerjaan, atau pengalaman, dan berkolokasi dengan 価値がある dan 価値を認める。				\N	f	2026-10-12 13:24:22.729924+00	2026-11-14 08:57:34.903249+00
21	1	機会	きかい	Kesempatan/Peluang	機会があります。	Ada kesempatan.	「機会」 berarti kesempatan atau peluang. Kata ini dipakai untuk momen yang tepat untuk melakukan sesuatu, dan berkolokasi dengan 機会がある dan 機会を逃す。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 08:57:54.440874+00
23	1	種類	しゅるい	Jenis/Tipe	種類があります。	Ada berbagai jenis.	「種類」 berarti jenis atau tipe. Kata ini dipakai untuk mengelompokkan benda atau hal berdasarkan ciri-cirinya, dan berkolokasi dengan 種類がある dan いろいろな種類。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 08:58:33.025089+00
24	1	人物	じんぶつ	Tokoh/Figur	この人は有名な人物です。	Orang ini adalah tokoh terkenal.	「人物」 berarti tokoh atau figur, biasanya seseorang yang terkenal atau penting dalam bidang tertentu. Kata ini dipakai dalam konteks sejarah, seni, atau berita, dan berkolokasi dengan 有名な人物 dan 歴史上の人物。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 08:58:57.676324+00
25	1	特徴	とくちょう	Fitur/Karakteristik	特徴があります。	Hal itu memiliki ciri khas.	「特徴」 berarti ciri khas, fitur, atau karakteristik yang membedakan sesuatu dari yang lain. Kata ini dipakai untuk menjelaskan keunikan benda, orang, atau tempat, dan berkolokasi dengan 特徴がある dan 特徴的な。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 08:59:17.417605+00
28	1	訪れる	おとずれる	Mengunjungi/Berkunjung	京都を訪れます。	Saya mengunjungi Kyoto.	「訪れる」 berarti mengunjungi atau berkunjung, biasanya ke tempat yang terkenal atau seseorang yang dihormati. Kata ini lebih formal daripada 行く dan berkolokasi dengan 〜を訪れる。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 09:00:21.947125+00
30	1	学習	がくしゅう	Pembelajar	日本語を学習します。	Saya mempelajari bahasa Jepang.	「学習」 berarti pembelajaran atau studi, biasanya untuk ilmu pengetahuan atau bahasa. Kata ini lebih formal daripada 勉強 dan berkolokasi dengan 日本語を学習する dan 学習を始める。				\N	f	2026-10-12 13:25:06.180703+00	2026-11-14 09:01:03.937289+00
31	1	捧げる	ささげる	Menyerahkan/Mempersembahkan/Mendedikasikan	花を捧げます。	Saya mempersembahkan bunga.	「捧げる」 berarti mempersembahkan, menyerahkan, atau mendedikasikan sesuatu, biasanya dengan rasa hormat atau pengabdian. Kata ini dipakai untuk persembahan bunga, doa, atau hidup, dan berkolokasi dengan 花を捧げる dan 命を捧げる。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:01:25.34899+00
32	1	一般的に	いっぱんてきに	Secara umum	一般的に知られています。	Hal itu dikenal secara umum.	「一般的に」 berarti secara umum atau pada umumnya. Kata ini dipakai untuk menyatakan sesuatu yang berlaku bagi kebanyakan orang atau situasi, dan berkolokasi dengan 一般的に〜です dan 一般的な。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:01:48.763163+00
34	1	傾向	けいこう	Kecenderungan/Tren	増加の傾向があります。	Ada kecenderungan meningkat.	「傾向」 berarti kecenderungan atau tren. Kata ini dipakai untuk arah perubahan atau pola yang terlihat dalam suatu hal, dan berkolokasi dengan 傾向がある dan 傾向が見られる。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:02:30.915054+00
35	1	取り上げる	とりあげる	Mengangkat/Mengambil	問題を取り上げます。	Saya mengangkat masalah itu.	「取り上げる」 berarti mengangkat, mengambil, atau membahas suatu hal. Kata ini dipakai untuk mengangkat topik atau mengambil benda, dan berkolokasi dengan 問題を取り上げる dan 取り上げる話題。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:02:51.786587+00
37	1	じっくり	じっくり	Dengan hati-hati/Seksama	じっくり考えます。	Saya berpikir dengan saksama.	「じっくり」 berarti dengan hati-hati, saksama, atau perlahan-lahan. Kata ini dipakai untuk melakukan sesuatu tanpa terburu-buru, dan berkolokasi dengan じっくり考える dan じっくり読む。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:03:58.067602+00
38	1	向上	こうじょう	Peningkatan/Perbaikan	技術が向上します。	Teknologi meningkat.	「向上」 berarti peningkatan atau perbaikan. Kata ini dipakai untuk peningkatan kemampuan, teknologi, atau kualitas, dan berkolokasi dengan 技術が向上する dan 向上を目指す。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:04:21.413132+00
40	1	防止	ぼうし	Pencegahan/Mencegah	事故を防止します。	Saya mencegah kecelakaan.	「防止」 berarti pencegahan atau mencegah. Kata ini dipakai untuk mencegah terjadinya hal yang tidak diinginkan, dan berkolokasi dengan 事故を防止する dan 防止策。				\N	f	2026-10-12 13:25:40.310031+00	2026-11-14 09:05:05.938707+00
41	1	世界的	せかいてき	Mendunia	世界的に有名です。	Hal itu terkenal di seluruh dunia.	「世界的」 berarti mendunia atau berskala dunia. Kata ini dipakai untuk sesuatu yang dikenal atau berlaku di seluruh dunia, dan berkolokasi dengan 世界的に有名 dan 世界的な。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:05:30.479884+00
43	1	医学	いがく	Kedokteran	医学を学びます。	Saya mempelajari kedokteran.	「医学」 berarti ilmu kedokteran. Kata ini dipakai untuk bidang ilmu yang mempelajari kesehatan dan pengobatan, dan berkolokasi dengan 医学を学ぶ dan 医学の進歩。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:06:23.780123+00
44	1	偽造	ぎぞう	Pemalsuan/Palsu	書類を偽造します。	Saya memalsukan dokumen.	「偽造」 berarti pemalsuan atau membuat sesuatu yang palsu. Kata ini dipakai untuk dokumen, uang, atau karya yang dipalsukan, dan berkolokasi dengan 偽造する dan 偽造品。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:06:43.700149+00
46	1	設立	せつりつ	Pendirian/Pembentukan Perusahaan	会社を設立します。	Saya mendirikan perusahaan.	「設立」 berarti pendirian atau pembentukan. Kata ini dipakai untuk mendirikan perusahaan, organisasi, atau lembaga, dan berkolokasi dengan 会社を設立する dan 設立する年。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:07:34.521774+00
47	1	高額	こうがく	Mahal/Berharga/Tinggi	高額な商品です。	Produk ini mahal.	「高額」 berarti jumlah yang tinggi atau mahal. Kata ini dipakai untuk harga, biaya, atau nilai yang besar, dan berkolokasi dengan 高額な商品 dan 高額の費用。				\N	f	2026-10-12 13:26:10.9557+00	2026-11-14 09:07:54.946164+00
\.


--
-- Data for Name: quiz_answers; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.quiz_answers (id, attempt_id, stage, item_key, card_id, user_answer, correct, answered_at) FROM stdin;
1	a4533626-27f9-4c07-a695-8f0e71af06d5	mc	m1	1	1	t	2026-10-12 15:43:20.329832+00
2	a4533626-27f9-4c07-a695-8f0e71af06d5	mc	m2	2	2	t	2026-10-12 15:43:28.993696+00
3	a4533626-27f9-4c07-a695-8f0e71af06d5	mc	m3	3	3	t	2026-10-12 15:43:33.455127+00
4	a4533626-27f9-4c07-a695-8f0e71af06d5	mc	m4	4	4	t	2026-10-12 15:44:13.877133+00
5	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m1	1	1	t	2026-10-12 15:52:25.893103+00
6	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m2	2	2	t	2026-10-12 15:52:28.722595+00
7	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m3	3	3	t	2026-10-12 15:52:31.763459+00
8	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m4	4	4	t	2026-10-12 15:52:36.026365+00
9	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m5	5	5	t	2026-10-12 15:52:57.210874+00
10	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m6	6	6	t	2026-10-12 15:53:05.293593+00
11	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m7	7	7	t	2026-10-12 15:53:12.213799+00
12	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m8	8	8	t	2026-10-12 15:53:28.36452+00
13	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m9	9	9	t	2026-10-12 15:53:34.586944+00
14	3bef8659-a952-4de3-81c9-d4d214c57fff	mc	m10	10	10	t	2026-10-12 15:53:37.108566+00
15	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p1	1	1	t	2026-10-12 15:53:43.518534+00
16	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p5	5	5	t	2026-10-12 15:53:53.100885+00
17	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p3	3	3	t	2026-10-12 15:53:55.212725+00
18	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p4	4	4	t	2026-10-12 15:53:57.917271+00
19	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p2	2	2	t	2026-10-12 15:53:59.748133+00
20	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p6	6	6	t	2026-10-12 15:54:04.593448+00
21	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p8	8	8	t	2026-10-12 15:54:07.591024+00
22	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p7	7	7	t	2026-10-12 15:54:11.118412+00
23	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p10	10	10	t	2026-10-12 15:54:13.229035+00
24	3bef8659-a952-4de3-81c9-d4d214c57fff	matching	p9	9	9	t	2026-10-12 15:54:14.772276+00
25	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t1	1	お越しください	f	2026-10-12 15:54:44.223722+00
26	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t2	2	個人的な	t	2026-10-12 15:54:55.694907+00
27	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t3	3	ざまざま	t	2026-10-12 15:55:04.454652+00
28	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t4	4	梅雨	t	2026-10-12 15:55:17.114371+00
29	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t5	5	時期	t	2026-10-12 15:55:29.43151+00
30	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t6	6	晴天	t	2026-10-12 15:55:34.516364+00
31	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t7	7	録音している	t	2026-10-12 15:55:41.805447+00
32	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t8	8	紙幣	t	2026-10-12 15:55:45.894883+00
33	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t9	9	現在	t	2026-10-12 15:55:50.940327+00
41	3bef8659-a952-4de3-81c9-d4d214c57fff	typing	t10	10	使用されている	t	2026-10-12 16:30:07.461977+00
57	f8504241-362f-4694-8c2b-e4574dccd347	mc	m1	151	151	t	2026-10-13 07:00:46.417615+00
58	f8504241-362f-4694-8c2b-e4574dccd347	mc	m2	152	152	t	2026-10-13 07:00:50.517156+00
59	f8504241-362f-4694-8c2b-e4574dccd347	mc	m3	153	153	t	2026-10-13 07:00:53.032653+00
60	f8504241-362f-4694-8c2b-e4574dccd347	mc	m4	154	154	t	2026-10-13 07:01:02.492812+00
61	f8504241-362f-4694-8c2b-e4574dccd347	mc	m5	155	155	t	2026-10-13 07:01:07.145993+00
62	f8504241-362f-4694-8c2b-e4574dccd347	mc	m6	156	156	t	2026-10-13 07:01:14.669762+00
63	f8504241-362f-4694-8c2b-e4574dccd347	mc	m7	157	157	t	2026-10-13 07:01:17.678622+00
64	f8504241-362f-4694-8c2b-e4574dccd347	mc	m8	158	158	t	2026-10-13 07:01:20.497272+00
65	f8504241-362f-4694-8c2b-e4574dccd347	mc	m9	159	159	t	2026-10-13 07:01:22.832014+00
66	f8504241-362f-4694-8c2b-e4574dccd347	mc	m10	160	195	f	2026-10-13 07:01:23.945528+00
67	f8504241-362f-4694-8c2b-e4574dccd347	matching	p3	153	a4e812b6b850badd	t	2026-10-13 07:01:29.251895+00
68	f8504241-362f-4694-8c2b-e4574dccd347	matching	p2	152	b0d3423cad2781df	t	2026-10-13 07:01:30.994746+00
69	f8504241-362f-4694-8c2b-e4574dccd347	matching	p1	151	ffc19223835ede9a	t	2026-10-13 07:01:33.986865+00
70	f8504241-362f-4694-8c2b-e4574dccd347	matching	p4	154	dc391dc13d3cb7c8	t	2026-10-13 07:01:37.383141+00
71	f8504241-362f-4694-8c2b-e4574dccd347	matching	p5	155	807b8ad646a0735e	t	2026-10-13 07:01:38.260032+00
72	f8504241-362f-4694-8c2b-e4574dccd347	matching	p6	156	6c423bd9f279f437	t	2026-10-13 07:01:40.171965+00
73	f8504241-362f-4694-8c2b-e4574dccd347	matching	p8	158	8a2b29665906afaf	t	2026-10-13 07:01:42.783133+00
74	f8504241-362f-4694-8c2b-e4574dccd347	matching	p10	160	e26f84a3f12b640f	t	2026-10-13 07:01:45.054255+00
75	f8504241-362f-4694-8c2b-e4574dccd347	matching	p7	157	35f81e97de9de169	t	2026-10-13 07:01:46.380891+00
76	f8504241-362f-4694-8c2b-e4574dccd347	matching	p9	159	ac905ca5ec53d596	t	2026-10-13 07:01:47.408088+00
77	f8504241-362f-4694-8c2b-e4574dccd347	typing	t1	151	間	t	2026-10-13 07:01:56.299227+00
78	f8504241-362f-4694-8c2b-e4574dccd347	typing	t2	152	青	t	2026-10-13 07:02:01.803857+00
79	f8504241-362f-4694-8c2b-e4574dccd347	typing	t3	153	味	t	2026-10-13 07:02:05.537572+00
80	f8504241-362f-4694-8c2b-e4574dccd347	typing	t4	154	穴	t	2026-10-13 07:02:10.15946+00
81	f8504241-362f-4694-8c2b-e4574dccd347	typing	t5	155	油	t	2026-10-13 07:02:13.691637+00
82	f8504241-362f-4694-8c2b-e4574dccd347	typing	t6	156	案	t	2026-10-13 07:02:19.328824+00
83	f8504241-362f-4694-8c2b-e4574dccd347	typing	t7	157	胃	t	2026-10-13 07:02:25.726787+00
84	f8504241-362f-4694-8c2b-e4574dccd347	typing	t8	158	家	t	2026-10-13 07:02:29.126722+00
85	f8504241-362f-4694-8c2b-e4574dccd347	typing	t9	159	息	t	2026-10-13 07:02:45.844505+00
86	f8504241-362f-4694-8c2b-e4574dccd347	typing	t10	160	池	t	2026-10-13 07:02:57.863833+00
87	7fa28812-3d9a-42d0-96b2-45937d41ee2b	mc	m1	161	161	t	2026-10-13 09:32:52.368487+00
88	7fa28812-3d9a-42d0-96b2-45937d41ee2b	mc	m2	162	162	t	2026-10-13 09:32:55.625412+00
89	7fa28812-3d9a-42d0-96b2-45937d41ee2b	mc	m3	163	163	t	2026-10-13 09:32:59.127236+00
90	7fa28812-3d9a-42d0-96b2-45937d41ee2b	mc	m4	164	164	t	2026-10-13 09:33:16.633508+00
91	7fa28812-3d9a-42d0-96b2-45937d41ee2b	mc	m5	165	165	t	2026-10-13 09:33:21.015575+00
92	7fa28812-3d9a-42d0-96b2-45937d41ee2b	mc	m6	166	166	t	2026-10-13 09:33:48.012516+00
93	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m1	161	161	t	2026-10-13 11:58:54.887731+00
94	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m2	162	162	t	2026-10-13 11:59:10.656573+00
95	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m3	163	163	t	2026-10-13 11:59:16.167466+00
96	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m4	164	164	t	2026-10-13 11:59:21.125757+00
97	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m5	165	165	t	2026-10-13 11:59:25.752167+00
98	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m6	166	166	t	2026-10-13 11:59:33.815349+00
99	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m7	167	167	t	2026-10-13 12:00:59.199356+00
100	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m8	168	168	t	2026-10-13 12:01:04.248228+00
101	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m9	169	169	t	2026-10-13 12:01:08.086669+00
102	727e615a-e453-4ddf-ba00-cf35d1753baf	mc	m10	170	170	t	2026-10-13 12:01:13.171207+00
103	727e615a-e453-4ddf-ba00-cf35d1753baf	matching	p1	161	ab6a96055a7a880c	t	2026-10-13 12:01:22.018194+00
104	8273b687-b156-442a-8833-e14ebd9974d9	mc	m1	161	161	t	2026-10-13 12:02:11.518961+00
105	8273b687-b156-442a-8833-e14ebd9974d9	mc	m2	162	162	t	2026-10-13 12:02:14.381691+00
106	8273b687-b156-442a-8833-e14ebd9974d9	mc	m3	163	163	t	2026-10-13 12:02:19.764799+00
107	8273b687-b156-442a-8833-e14ebd9974d9	mc	m4	164	164	t	2026-10-13 12:02:34.308695+00
108	8273b687-b156-442a-8833-e14ebd9974d9	mc	m5	165	165	t	2026-10-13 12:02:38.295361+00
109	8273b687-b156-442a-8833-e14ebd9974d9	mc	m6	166	166	t	2026-10-13 12:02:41.007584+00
110	8273b687-b156-442a-8833-e14ebd9974d9	mc	m7	167	167	t	2026-10-13 12:02:43.385958+00
111	8273b687-b156-442a-8833-e14ebd9974d9	mc	m8	168	168	t	2026-10-13 12:02:47.072393+00
112	8273b687-b156-442a-8833-e14ebd9974d9	mc	m9	169	169	t	2026-10-13 12:02:49.898679+00
113	8273b687-b156-442a-8833-e14ebd9974d9	mc	m10	170	170	t	2026-10-13 12:02:52.140216+00
114	8273b687-b156-442a-8833-e14ebd9974d9	matching	p1	161	1fbe7f17bb2c8af3	t	2026-10-13 12:02:55.45396+00
115	8273b687-b156-442a-8833-e14ebd9974d9	matching	p2	162	a2580ee098bf7709	t	2026-10-13 12:02:57.743408+00
116	8273b687-b156-442a-8833-e14ebd9974d9	matching	p4	164	cb0c45c6a8ce52bc	t	2026-10-13 12:02:59.678416+00
117	8273b687-b156-442a-8833-e14ebd9974d9	matching	p3	163	f920fac9d2a2abc1	t	2026-10-13 12:03:01.947708+00
118	8273b687-b156-442a-8833-e14ebd9974d9	matching	p5	165	1c133754f8846ac1	t	2026-10-13 12:03:04.420877+00
119	8273b687-b156-442a-8833-e14ebd9974d9	matching	p6	166	c2843b3d1d68e073	t	2026-10-13 12:03:13.078036+00
120	8273b687-b156-442a-8833-e14ebd9974d9	matching	p7	167	75c1d52e82022aff	t	2026-10-13 12:03:15.824303+00
121	8273b687-b156-442a-8833-e14ebd9974d9	matching	p8	168	0e6fe24e314ae5c9	t	2026-10-13 12:03:18.89407+00
122	8273b687-b156-442a-8833-e14ebd9974d9	matching	p10	170	d0c0edd8c96f1b2d	t	2026-10-13 12:03:21.309756+00
123	8273b687-b156-442a-8833-e14ebd9974d9	matching	p9	169	50cc235230493f21	t	2026-10-13 12:03:23.785272+00
124	8273b687-b156-442a-8833-e14ebd9974d9	typing	t1	161	いと	t	2026-10-13 12:03:32.817799+00
125	8273b687-b156-442a-8833-e14ebd9974d9	typing	t2	162	いも	t	2026-10-13 12:03:37.728748+00
126	8273b687-b156-442a-8833-e14ebd9974d9	typing	t3	163	うた	t	2026-10-13 12:03:41.384435+00
127	8273b687-b156-442a-8833-e14ebd9974d9	typing	t4	164	うち	t	2026-10-13 12:03:47.831428+00
128	8273b687-b156-442a-8833-e14ebd9974d9	typing	t5	165	うつわ	t	2026-10-13 12:06:01.894805+00
129	8273b687-b156-442a-8833-e14ebd9974d9	typing	t6	166	うで	t	2026-10-13 12:06:04.907724+00
130	8273b687-b156-442a-8833-e14ebd9974d9	typing	t7	167	え	t	2026-10-13 12:06:07.354364+00
131	8273b687-b156-442a-8833-e14ebd9974d9	typing	t8	168	えだ	t	2026-10-13 12:06:10.209476+00
132	8273b687-b156-442a-8833-e14ebd9974d9	typing	t9	169	おく	t	2026-10-13 12:06:13.324989+00
133	8273b687-b156-442a-8833-e14ebd9974d9	typing	t10	170	おと	t	2026-10-13 12:06:16.056811+00
134	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m1	151	151	t	2026-10-16 04:00:53.336627+00
135	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m2	152	152	t	2026-10-16 04:00:56.137763+00
136	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m3	153	153	t	2026-10-16 04:00:59.33483+00
137	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m4	154	154	t	2026-10-16 04:01:02.502197+00
138	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m5	155	155	t	2026-10-16 04:01:05.281201+00
139	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m6	156	156	t	2026-10-16 04:01:07.87691+00
140	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m7	157	157	t	2026-10-16 04:01:11.073372+00
141	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m8	158	158	t	2026-10-16 04:01:13.48338+00
142	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m9	159	159	t	2026-10-16 04:01:16.535436+00
143	d0a14f66-757b-4ea0-b26c-0a71826512b8	mc	m10	160	160	t	2026-10-16 04:01:20.291902+00
144	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p1	151	d16add5dc51783dc	t	2026-10-16 04:01:25.320234+00
145	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p5	155	17180efc61aba922	t	2026-10-16 04:01:27.797916+00
146	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p3	153	0a4b3d2aaf469cd1	t	2026-10-16 04:01:31.354174+00
147	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p2	152	ff611319d6df64e9	t	2026-10-16 04:01:33.919223+00
148	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p4	154	53de35c5a31d389a	t	2026-10-16 04:01:35.986088+00
149	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p6	156	371e7dcea06a00a2	t	2026-10-16 04:01:38.711154+00
150	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p8	158	928e902129426ff7	t	2026-10-16 04:01:41.240747+00
151	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p9	159	2dbf87cb28d71fbd	f	2026-10-16 04:01:43.532986+00
152	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p7	157	2dbf87cb28d71fbd	t	2026-10-16 04:01:45.953231+00
153	d0a14f66-757b-4ea0-b26c-0a71826512b8	matching	p10	160	df04a7a535bdd3a5	t	2026-10-16 04:01:47.814777+00
154	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t1	151	あいだ	t	2026-10-16 04:01:55.145689+00
155	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t2	152	あお	t	2026-10-16 04:01:58.336909+00
156	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t3	153	あじ	t	2026-10-16 04:02:03.148928+00
157	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t4	154	あな	t	2026-10-16 04:02:06.433443+00
158	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t5	155	あぶら	t	2026-10-16 04:02:10.204758+00
159	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t6	156	あん	t	2026-10-16 04:02:13.72199+00
160	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t7	157	い	t	2026-10-16 04:02:16.864939+00
161	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t8	158	いえ	t	2026-10-16 04:02:19.873193+00
162	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t9	159	いき	t	2026-10-16 04:02:23.571376+00
163	d0a14f66-757b-4ea0-b26c-0a71826512b8	typing	t10	160	いけ	t	2026-10-16 04:02:27.041618+00
164	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m1	171	171	t	2026-10-16 04:04:05.697056+00
165	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m2	172	172	t	2026-10-16 04:04:08.132842+00
166	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m3	173	173	t	2026-10-16 04:04:11.404428+00
167	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m4	174	174	t	2026-10-16 04:04:13.958873+00
168	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m5	175	175	t	2026-10-16 04:04:16.98129+00
169	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m6	176	176	t	2026-10-16 04:04:21.025326+00
170	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m7	177	177	t	2026-10-16 04:04:25.655886+00
171	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m8	178	178	t	2026-10-16 04:04:28.514025+00
172	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m9	179	179	t	2026-10-16 04:04:30.926518+00
173	4be6596a-97ef-4b6d-9311-27de83cda7ab	mc	m10	180	180	t	2026-10-16 04:04:33.419633+00
174	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p1	171	7fb60fea2b0c709c	t	2026-10-16 04:04:36.291814+00
175	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p2	172	8fc0787a4d162977	t	2026-10-16 04:04:39.153757+00
176	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p3	173	6c330e4c4df08845	t	2026-10-16 04:04:41.848518+00
177	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p4	174	81c65b57519b2195	t	2026-10-16 04:04:45.203687+00
178	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p5	175	331e4ab2847e8055	t	2026-10-16 04:04:47.342162+00
179	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p6	176	f07c547afedb55c0	t	2026-10-16 04:04:54.856775+00
180	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p9	179	045b75038eef4ee6	t	2026-10-16 04:04:57.7221+00
181	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p7	177	4799a0fb11d05743	t	2026-10-16 04:05:00.619455+00
182	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p8	178	3f5b2845c45c8594	f	2026-10-16 04:05:02.535342+00
183	4be6596a-97ef-4b6d-9311-27de83cda7ab	matching	p10	180	3f5b2845c45c8594	t	2026-10-16 04:05:04.679321+00
184	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t1	171	あいず	t	2026-10-16 04:05:10.533807+00
185	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t2	172	あいて	t	2026-10-16 04:05:13.866758+00
186	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t3	173	あおぞら	t	2026-10-16 04:05:17.305199+00
187	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t4	174	あんしん	t	2026-10-16 04:05:21.106311+00
188	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t5	175	あんない	t	2026-10-16 04:05:26.157372+00
189	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t6	176	いか	t	2026-10-16 04:05:29.866947+00
190	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t7	177	いがい	t	2026-10-16 04:05:33.650924+00
191	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t8	178	いけん	t	2026-10-16 04:05:37.111026+00
192	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t9	179	いこう	t	2026-10-16 04:05:41.132844+00
193	4be6596a-97ef-4b6d-9311-27de83cda7ab	typing	t10	180	いじ	t	2026-10-16 04:05:44.557376+00
194	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m1	362	362	t	2026-10-16 04:06:29.212554+00
195	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m2	363	363	t	2026-10-16 04:06:35.041849+00
196	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m3	364	364	t	2026-10-16 04:06:38.810684+00
197	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m4	365	365	t	2026-10-16 04:06:41.219806+00
198	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m5	366	366	t	2026-10-16 04:06:44.612967+00
199	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m6	367	367	t	2026-10-16 04:06:47.263497+00
200	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m7	368	368	t	2026-10-16 04:06:50.879955+00
201	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m8	369	369	t	2026-10-16 04:06:53.765261+00
202	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m9	370	370	t	2026-10-16 04:06:56.434469+00
203	81785e68-1ebf-418f-952d-c0fb6c78f634	mc	m10	371	371	t	2026-10-16 04:06:59.326441+00
204	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p1	362	0d3929b3effd347d	t	2026-10-16 04:07:04.139248+00
205	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p3	364	3affb20342fe0040	t	2026-10-16 04:07:08.026854+00
206	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p2	363	819ba09408ab1b94	t	2026-10-16 04:07:10.660358+00
207	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p4	365	95919ab7a228223d	t	2026-10-16 04:07:13.075858+00
208	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p5	366	675ba12d7fd9fd5a	t	2026-10-16 04:07:14.985677+00
209	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p6	367	67c8bd84535d7478	t	2026-10-16 04:07:18.410647+00
210	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p7	368	1f50fb77899949f8	t	2026-10-16 04:07:20.350286+00
211	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p8	369	00e491e85b82595b	t	2026-10-16 04:07:23.198319+00
212	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p9	370	2c2d0e94832b3e5e	t	2026-10-16 04:07:25.152389+00
213	81785e68-1ebf-418f-952d-c0fb6c78f634	matching	p10	371	a0a1728572808e73	t	2026-10-16 04:07:27.60968+00
214	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t1	362	ちゅうしゃじょう	t	2026-10-16 04:07:36.701619+00
215	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t2	363	ちゅうしゃ	t	2026-10-16 04:07:53.137216+00
216	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t3	364	まんしゃ	t	2026-10-16 04:07:58.449553+00
217	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t4	365	ごうしゃ	t	2026-10-16 04:08:04.234686+00
218	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t5	366	まんいん	t	2026-10-16 04:08:09.305571+00
219	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t6	367	ふまんな	t	2026-10-16 04:08:15.097719+00
220	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t7	368	ひこうじょう	t	2026-10-16 04:08:22.825541+00
221	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t8	369	とぶ	t	2026-10-16 04:08:27.184379+00
222	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t9	370	かい	t	2026-10-16 04:08:30.81174+00
223	81785e68-1ebf-418f-952d-c0fb6c78f634	typing	t10	371	かいだん	t	2026-10-16 04:08:36.594114+00
224	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m1	181	181	t	2026-10-16 08:05:25.178868+00
225	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m2	182	182	t	2026-10-16 08:05:28.150142+00
226	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m3	183	183	t	2026-10-16 08:05:30.499037+00
227	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m4	184	184	t	2026-10-16 08:05:32.916103+00
228	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m5	185	185	t	2026-10-16 08:05:39.788054+00
229	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m6	186	186	t	2026-10-16 08:05:56.043272+00
230	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m7	187	187	t	2026-10-16 08:05:58.976209+00
231	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m8	188	188	t	2026-10-16 08:06:02.853658+00
232	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m9	189	189	t	2026-10-16 08:06:05.437713+00
233	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	mc	m10	190	190	t	2026-10-16 08:06:08.199618+00
234	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p1	181	0555e723fd484824	t	2026-10-16 08:06:11.245126+00
235	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p3	183	0de78b78048fe656	t	2026-10-16 08:06:13.651614+00
236	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p2	182	90a5af0d3491ed46	t	2026-10-16 08:06:16.633176+00
237	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p4	184	254c7c8ac6d8ea7f	t	2026-10-16 08:06:18.612559+00
238	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p5	185	ba0b61248d64c346	t	2026-10-16 08:06:20.520632+00
239	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p6	186	353c4e976db8e9bd	t	2026-10-16 08:06:29.062331+00
240	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p7	187	a1ee5c4e74651c8d	t	2026-10-16 08:06:41.294021+00
241	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p8	188	f246f1c39e7a2ba8	t	2026-10-16 08:06:44.237817+00
242	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p9	189	2691f0fcff552728	t	2026-10-16 08:06:47.15882+00
243	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	matching	p10	190	559230a539fa41f3	t	2026-10-16 08:06:53.308757+00
244	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t1	181	いっしょ	t	2026-10-16 08:07:03.781195+00
245	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t2	182	いっぱん	t	2026-10-16 08:07:08.815029+00
246	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t3	183	いどう	t	2026-10-16 08:07:13.515191+00
247	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t4	184	いない	t	2026-10-16 08:07:17.74291+00
248	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t5	185	いなか	t	2026-10-16 08:07:23.2456+00
249	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t6	186	いま	t	2026-10-16 08:07:27.206292+00
250	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t7	187	いみ	t	2026-10-16 08:07:31.579495+00
251	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t8	188	いんさつ	t	2026-10-16 08:07:37.208952+00
252	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t9	189	いんしょう	t	2026-10-16 08:07:42.701179+00
253	5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	typing	t10	190	いんしょく	t	2026-10-16 08:07:48.057347+00
254	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m1	11	11	t	2026-10-19 15:55:54.186952+00
255	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m2	12	12	t	2026-10-19 15:55:57.320842+00
256	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m3	13	13	t	2026-10-19 15:56:03.463643+00
257	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m4	14	14	t	2026-10-19 15:56:08.155852+00
258	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m5	15	15	t	2026-10-19 15:56:12.123397+00
259	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m6	16	16	t	2026-10-19 15:56:14.414909+00
260	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m7	17	17	t	2026-10-19 15:56:19.79478+00
261	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m8	18	41	f	2026-10-19 15:56:28.261657+00
262	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m9	19	19	t	2026-10-19 15:56:35.214244+00
263	ea1ee799-2d40-4383-aeff-cd4cae085afc	mc	m10	20	20	t	2026-10-19 15:56:44.734403+00
264	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p1	11	0de9c6a3c7dcafae	t	2026-10-19 15:56:58.081642+00
265	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p2	12	e5215d2f05521ccd	t	2026-10-19 15:57:01.724264+00
266	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p3	13	3489bd519c45ca81	t	2026-10-19 15:57:04.559729+00
267	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p4	14	e4e4595d7540d0b5	t	2026-10-19 15:57:06.811766+00
268	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p5	15	385b3c07b171025a	t	2026-10-19 15:57:08.539822+00
269	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p6	16	9108b4128ccd8fb2	t	2026-10-19 15:57:14.232224+00
270	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p8	18	2a5c2d5588e398ff	t	2026-10-19 15:57:17.124177+00
271	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p7	17	0ca1d8660fbb94ec	t	2026-10-19 15:57:19.765461+00
272	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p9	19	2d7fd4b030c7d22b	t	2026-10-19 15:57:21.921762+00
273	ea1ee799-2d40-4383-aeff-cd4cae085afc	matching	p10	20	ca818cbb626fd394	t	2026-10-19 15:57:23.674813+00
274	ea1ee799-2d40-4383-aeff-cd4cae085afc	typing	t1	11	ごしょかいします	f	2026-10-19 15:57:50.257744+00
275	ea1ee799-2d40-4383-aeff-cd4cae085afc	typing	t2	12	けいかく	t	2026-10-19 15:57:55.17687+00
276	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m1	372	372	t	2026-10-20 04:47:20.053058+00
277	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m2	373	373	t	2026-10-20 04:47:23.520878+00
278	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m3	374	374	t	2026-10-20 04:47:26.323903+00
279	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m4	375	375	t	2026-10-20 04:47:28.451878+00
280	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m5	376	376	t	2026-10-20 04:47:31.754924+00
281	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m6	377	377	t	2026-10-20 04:47:34.085079+00
282	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m7	378	378	t	2026-10-20 04:47:36.223796+00
283	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m8	379	379	t	2026-10-20 04:47:40.034773+00
284	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m9	380	380	t	2026-10-20 04:47:42.399743+00
285	10e7b391-e181-44f0-9f5b-8caf40628db8	mc	m10	381	381	t	2026-10-20 04:47:44.477795+00
286	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p1	372	6cf3d9eef4635b65	t	2026-10-20 04:47:47.078222+00
287	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p2	373	6fa19b132b82db60	t	2026-10-20 04:47:48.816687+00
288	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p3	374	4828901aab395e17	t	2026-10-20 04:47:50.917426+00
289	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p4	375	c81cbce0537198de	t	2026-10-20 04:47:52.518337+00
290	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p5	376	7ec085f58987dacf	t	2026-10-20 04:47:54.214509+00
291	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p6	377	64bbb8ed4246e796	t	2026-10-20 04:47:57.100738+00
292	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p7	378	c84bb05748236712	t	2026-10-20 04:47:59.893817+00
293	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p8	379	67f60955fdd44986	t	2026-10-20 04:48:01.941637+00
294	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p9	380	5262624b8fe204a7	t	2026-10-20 04:48:03.879535+00
295	10e7b391-e181-44f0-9f5b-8caf40628db8	matching	p10	381	7fe46d27000a4740	t	2026-10-20 04:48:05.711465+00
296	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t1	372	むきゅう	t	2026-10-20 04:48:29.049385+00
297	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t2	373	むだんn	f	2026-10-20 04:48:33.607561+00
298	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t3	374	むりな	t	2026-10-20 04:48:37.271724+00
299	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t4	375	ない	t	2026-10-20 04:48:40.120992+00
300	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t5	376	むだん	t	2026-10-20 04:48:51.809709+00
301	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t6	377	だんすい	t	2026-10-20 04:48:55.72048+00
302	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t7	378	ことわる	t	2026-10-20 04:48:59.705451+00
303	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t8	379	おうだん	t	2026-10-20 04:49:03.587139+00
304	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t9	380	おうだんほどう	t	2026-10-20 04:49:14.883743+00
305	10e7b391-e181-44f0-9f5b-8caf40628db8	typing	t10	381	よこ	t	2026-10-20 04:49:21.660966+00
306	9977e60c-7e0f-443d-8833-3b031180384a	mc	m1	362	362	t	2026-10-20 04:49:52.307255+00
307	9977e60c-7e0f-443d-8833-3b031180384a	mc	m2	363	363	t	2026-10-20 04:49:55.389102+00
308	9977e60c-7e0f-443d-8833-3b031180384a	mc	m3	364	364	t	2026-10-20 04:49:58.156642+00
309	9977e60c-7e0f-443d-8833-3b031180384a	mc	m4	365	365	t	2026-10-20 04:50:00.22175+00
310	9977e60c-7e0f-443d-8833-3b031180384a	mc	m5	366	366	t	2026-10-20 04:50:02.358952+00
311	9977e60c-7e0f-443d-8833-3b031180384a	mc	m6	367	367	t	2026-10-20 04:50:04.675956+00
312	9977e60c-7e0f-443d-8833-3b031180384a	mc	m7	368	368	t	2026-10-20 04:50:08.486428+00
313	9977e60c-7e0f-443d-8833-3b031180384a	mc	m8	369	369	t	2026-10-20 04:50:11.091978+00
314	9977e60c-7e0f-443d-8833-3b031180384a	mc	m9	370	370	t	2026-10-20 04:50:15.638579+00
315	9977e60c-7e0f-443d-8833-3b031180384a	mc	m10	371	371	t	2026-10-20 04:50:23.405329+00
316	9977e60c-7e0f-443d-8833-3b031180384a	matching	p1	362	b8fef03f3e0084b8	t	2026-10-20 04:50:27.585493+00
317	9977e60c-7e0f-443d-8833-3b031180384a	matching	p2	363	bb9c7f4e6592a50a	f	2026-10-20 04:50:29.877798+00
318	9977e60c-7e0f-443d-8833-3b031180384a	matching	p3	364	bb9c7f4e6592a50a	t	2026-10-20 04:50:33.653788+00
319	9977e60c-7e0f-443d-8833-3b031180384a	matching	p4	365	f074da063d226d1e	t	2026-10-20 04:50:35.783807+00
320	9977e60c-7e0f-443d-8833-3b031180384a	matching	p5	366	65f715594b05df88	t	2026-10-20 04:50:37.438775+00
321	9977e60c-7e0f-443d-8833-3b031180384a	matching	p6	367	cda9b1e2a4419351	t	2026-10-20 04:50:39.975176+00
322	9977e60c-7e0f-443d-8833-3b031180384a	matching	p7	368	73f2a3125c24485e	t	2026-10-20 04:50:42.687901+00
323	9977e60c-7e0f-443d-8833-3b031180384a	matching	p8	369	fd1a09409a3664be	t	2026-10-20 04:50:46.086487+00
324	9977e60c-7e0f-443d-8833-3b031180384a	matching	p9	370	8703e4743df3e3d6	t	2026-10-20 04:50:48.509679+00
325	9977e60c-7e0f-443d-8833-3b031180384a	matching	p10	371	c38daba05063db58	t	2026-10-20 04:50:50.197834+00
326	9977e60c-7e0f-443d-8833-3b031180384a	typing	t1	362	ちゅうしゃじょう	t	2026-10-20 04:50:59.607591+00
327	9977e60c-7e0f-443d-8833-3b031180384a	typing	t2	363	まんしゃ	f	2026-10-20 04:51:04.952403+00
328	9977e60c-7e0f-443d-8833-3b031180384a	typing	t3	364	まんしゃ	t	2026-10-20 04:51:10.086565+00
329	9977e60c-7e0f-443d-8833-3b031180384a	typing	t4	365	ごうしゃ	t	2026-10-20 04:51:14.150946+00
330	9977e60c-7e0f-443d-8833-3b031180384a	typing	t5	366	まんいん	t	2026-10-20 04:51:18.181425+00
331	9977e60c-7e0f-443d-8833-3b031180384a	typing	t6	367	ふまんな	t	2026-10-20 04:51:23.325027+00
332	9977e60c-7e0f-443d-8833-3b031180384a	typing	t7	368	ひこうじょう	t	2026-10-20 04:51:32.451856+00
333	9977e60c-7e0f-443d-8833-3b031180384a	typing	t8	369	とぶ	t	2026-10-20 04:51:35.736083+00
334	9977e60c-7e0f-443d-8833-3b031180384a	typing	t9	370	かい	t	2026-10-20 04:51:38.984219+00
335	9977e60c-7e0f-443d-8833-3b031180384a	typing	t10	371	かいだん	t	2026-10-20 04:51:43.2102+00
336	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m1	161	161	t	2026-10-20 04:52:48.628671+00
337	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m2	162	162	t	2026-10-20 04:52:51.44719+00
338	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m3	163	163	t	2026-10-20 04:52:53.918528+00
339	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m4	164	164	t	2026-10-20 04:52:56.454025+00
340	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m5	165	165	t	2026-10-20 04:52:58.823032+00
341	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m6	166	166	t	2026-10-20 04:53:01.013993+00
342	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m7	167	167	t	2026-10-20 04:53:03.321691+00
343	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m8	168	168	t	2026-10-20 04:53:08.306985+00
344	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m9	169	169	t	2026-10-20 04:53:10.711741+00
345	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	mc	m10	170	170	t	2026-10-20 04:53:13.211921+00
346	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p1	161	d2e15c86efc591e5	t	2026-10-20 04:53:20.131233+00
347	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p2	162	35bb1506663d044f	t	2026-10-20 04:53:22.44482+00
348	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p3	163	2b6b546b0e943b30	t	2026-10-20 04:53:24.530452+00
349	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p4	164	e8ca3d1dc60a49c3	t	2026-10-20 04:53:26.402057+00
350	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p5	165	8381a9f639e2e35a	t	2026-10-20 04:53:28.0025+00
351	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p6	166	34d208901986f9ba	t	2026-10-20 04:53:30.548795+00
352	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p7	167	381eb7cd3834b1de	t	2026-10-20 04:53:32.763014+00
353	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p9	169	6735834ddbfd9ddb	t	2026-10-20 04:53:34.409268+00
354	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p8	168	cd222641f449fb71	t	2026-10-20 04:53:36.258435+00
355	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	matching	p10	170	fbb6f4453aa223ca	t	2026-10-20 04:53:38.025219+00
356	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t1	161	いと	t	2026-10-20 04:53:43.58895+00
357	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t2	162	いも	t	2026-10-20 04:53:47.167252+00
358	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t3	163	うた	t	2026-10-20 04:53:50.036044+00
359	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t4	164	うち	t	2026-10-20 04:53:56.411754+00
360	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t5	165	うつわ	t	2026-10-20 04:54:01.383524+00
361	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t6	166	うで	t	2026-10-20 04:54:04.259799+00
362	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t7	167	え	t	2026-10-20 04:54:06.679627+00
363	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t8	168	えだ	t	2026-10-20 04:54:10.159166+00
364	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t9	169	おく	t	2026-10-20 04:54:13.250813+00
365	e5b66a3f-92e6-4b53-93c1-ec60f0226d04	typing	t10	170	おと	t	2026-10-20 04:54:16.136925+00
366	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m1	159	159	t	2026-10-20 04:55:12.212699+00
367	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m2	160	160	t	2026-10-20 04:55:14.8192+00
368	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m3	171	171	t	2026-10-20 04:55:16.844229+00
369	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m4	172	172	t	2026-10-20 04:55:19.082039+00
370	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m5	173	173	t	2026-10-20 04:55:21.938296+00
371	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m6	174	174	t	2026-10-20 04:55:24.571564+00
372	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m7	175	175	t	2026-10-20 04:55:28.303481+00
373	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m8	176	176	t	2026-10-20 04:55:30.855786+00
374	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m9	177	177	t	2026-10-20 04:55:34.248455+00
375	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	mc	m10	178	178	t	2026-10-20 04:55:37.315481+00
376	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p1	159	ead630ca65afa2f9	t	2026-10-20 04:55:41.772469+00
377	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p2	160	7d05500d8f74274b	t	2026-10-20 04:55:44.512675+00
378	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p3	171	189af5ff6f2154f3	t	2026-10-20 04:55:46.707888+00
379	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p4	172	d4228e0c2303db59	t	2026-10-20 04:55:48.846867+00
380	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p5	173	c561f0dc88d54bbd	t	2026-10-20 04:55:50.845978+00
381	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p6	174	6d412e90d38b4089	t	2026-10-20 04:55:53.413726+00
382	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p7	175	390e6bb169715a42	t	2026-10-20 04:55:55.402902+00
383	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p8	176	fcc9fca186bcddb6	t	2026-10-20 04:55:57.525165+00
384	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p9	177	71797bdad47ebab3	t	2026-10-20 04:55:59.917642+00
385	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	matching	p10	178	2e89c6b107277730	t	2026-10-20 04:56:01.681243+00
386	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t1	159	いき	t	2026-10-20 04:56:05.306604+00
387	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t2	160	いけ	t	2026-10-20 04:56:08.08446+00
388	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t3	171	あいず	t	2026-10-20 04:56:11.611309+00
389	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t4	172	あいて	t	2026-10-20 04:56:14.379194+00
390	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t5	173	あおぞら	t	2026-10-20 04:56:18.463324+00
391	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t6	174	あんしん	t	2026-10-20 04:56:21.86355+00
392	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t7	175	あんない	t	2026-10-20 04:56:25.311941+00
393	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t8	176	いか	t	2026-10-20 04:56:28.209167+00
394	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t9	177	いがい	t	2026-10-20 04:56:31.015301+00
395	91a6e2b7-b04b-4118-a874-e91a6fa5ff94	typing	t10	178	いけん	t	2026-10-20 04:56:33.956829+00
396	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m1	179	179	t	2026-10-20 04:57:43.85857+00
397	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m2	180	180	t	2026-10-20 04:57:46.037818+00
398	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m3	181	181	t	2026-10-20 04:57:48.777965+00
399	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m4	182	182	t	2026-10-20 04:57:50.90831+00
400	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m5	183	183	t	2026-10-20 04:57:53.386802+00
401	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m6	184	184	t	2026-10-20 04:57:55.389999+00
402	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m7	185	185	t	2026-10-20 04:57:57.747677+00
403	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m8	186	186	t	2026-10-20 04:58:00.030259+00
404	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m9	187	187	t	2026-10-20 04:58:02.188961+00
405	c30510a9-fe54-4417-9889-e548f5360b2f	mc	m10	188	188	t	2026-10-20 04:58:04.495414+00
406	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p1	179	e28f0b534d9b9ea3	t	2026-10-20 04:58:07.567464+00
407	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p2	180	5ad84c40c085ced9	t	2026-10-20 04:58:09.781896+00
408	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p3	181	97242277977783fc	t	2026-10-20 04:58:11.694893+00
409	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p4	182	934bb42a6dc59f08	t	2026-10-20 04:58:13.615236+00
410	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p5	183	ea75031caca411d4	t	2026-10-20 04:58:15.159883+00
411	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p6	184	99fd05c543f0ffed	t	2026-10-20 04:58:18.704787+00
412	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p7	185	f007d7350d0c1f63	t	2026-10-20 04:58:21.156545+00
413	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p8	186	45cdcb0d483db08f	t	2026-10-20 04:58:23.479583+00
414	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p9	187	2c9d9bf688b1e90b	t	2026-10-20 04:58:25.464018+00
415	c30510a9-fe54-4417-9889-e548f5360b2f	matching	p10	188	642682c4e1994b98	t	2026-10-20 04:58:27.149483+00
416	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t1	179	いこう	t	2026-10-20 04:58:31.630571+00
417	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t2	180	いじ	t	2026-10-20 04:58:34.434212+00
418	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t3	181	いっしょ	t	2026-10-20 04:58:37.797334+00
419	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t4	182	いっぱん	t	2026-10-20 04:58:41.581912+00
420	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t5	183	いどう	t	2026-10-20 04:58:44.488593+00
421	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t6	184	いない	t	2026-10-20 04:58:47.451489+00
422	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t7	185	いなか	t	2026-10-20 04:58:58.842827+00
423	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t8	186	いま	t	2026-10-20 04:59:01.663834+00
424	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t9	187	いみ	t	2026-10-20 04:59:04.601356+00
425	c30510a9-fe54-4417-9889-e548f5360b2f	typing	t10	188	いんさつ	t	2026-10-20 04:59:09.971248+00
426	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m1	382	382	t	2026-10-28 11:10:06.645454+00
427	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m2	383	383	t	2026-10-28 11:10:09.468923+00
428	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m3	384	384	t	2026-10-28 11:10:12.766376+00
429	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m4	385	385	t	2026-10-28 11:10:15.571693+00
430	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m5	386	386	t	2026-10-28 11:10:20.668328+00
431	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m6	387	387	t	2026-10-28 11:10:23.229977+00
432	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m7	388	388	t	2026-10-28 11:10:26.659614+00
433	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m8	389	389	t	2026-10-28 11:10:29.715782+00
434	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m9	390	390	t	2026-10-28 11:10:35.605836+00
435	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	mc	m10	391	391	t	2026-10-28 11:10:37.907456+00
436	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p1	382	dde093a14ad51d4b	t	2026-10-28 11:10:42.643401+00
437	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p2	383	f3e66b3c8656c729	t	2026-10-28 11:10:46.30422+00
438	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p3	384	f4f747cab7a3b98a	t	2026-10-28 11:10:49.803209+00
439	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p4	385	42dd827e8738279d	t	2026-10-28 11:10:57.134237+00
440	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p5	386	9744efac19522976	t	2026-10-28 11:11:00.225877+00
441	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p6	387	ca3f38fe788454f2	t	2026-10-28 11:11:08.013724+00
442	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p7	388	e61f5ad635297fd2	t	2026-10-28 11:11:12.0661+00
443	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p8	389	2c13c675be0aac95	t	2026-10-28 11:11:28.856637+00
444	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p9	390	cc0b55d91a582944	t	2026-10-28 11:11:31.6332+00
445	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	matching	p10	391	2210303a30f96a36	t	2026-10-28 11:11:33.468964+00
446	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t1	382	おす	t	2026-10-28 11:11:40.128035+00
447	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t2	383	おしいれ	t	2026-10-28 11:11:44.238479+00
448	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t3	384	おさえる	t	2026-10-28 11:11:55.789012+00
449	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t4	385	おしぼたんしき	t	2026-10-28 11:12:08.925623+00
450	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t5	386	すうしき	t	2026-10-28 11:12:13.680697+00
451	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t6	387	にゅうがくしき	t	2026-10-28 11:12:19.650781+00
452	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t7	388	ほうこう	t	2026-10-28 11:12:27.659438+00
453	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t8	389	むぁう	f	2026-10-28 11:12:31.505315+00
454	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t9	390	むき	t	2026-10-28 11:12:35.571358+00
455	d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	typing	t10	391	はこ	t	2026-10-28 11:12:42.16773+00
456	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m1	181	181	t	2026-10-28 12:08:42.068162+00
457	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m2	182	182	t	2026-10-28 12:08:45.482985+00
458	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m3	183	183	t	2026-10-28 12:08:48.272098+00
459	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m4	184	184	t	2026-10-28 12:08:51.639788+00
460	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m5	185	185	t	2026-10-28 12:08:53.986676+00
461	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m6	186	186	t	2026-10-28 12:09:00.317373+00
462	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m7	187	187	t	2026-10-28 12:09:03.220868+00
463	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m8	188	188	t	2026-10-28 12:09:05.878768+00
464	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m9	189	189	t	2026-10-28 12:09:08.789875+00
465	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	mc	m10	190	190	t	2026-10-28 12:09:12.519144+00
466	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p1	181	2c37bf22ff9690e3	t	2026-10-28 12:09:15.658603+00
467	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p4	184	18a928f0fcfe3790	t	2026-10-28 12:09:19.035233+00
468	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p5	185	d0c1384417171ef8	t	2026-10-28 12:09:21.449721+00
469	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p3	183	58a1e644673384d2	t	2026-10-28 12:09:23.67563+00
470	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p2	182	23f50fdd82653e5c	t	2026-10-28 12:09:25.507871+00
471	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p6	186	857e8634b9226357	t	2026-10-28 12:09:28.530198+00
472	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p7	187	20306e766f629339	t	2026-10-28 12:09:30.566291+00
473	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p9	189	249470e7e4556005	t	2026-10-28 12:09:33.568863+00
474	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p8	188	de6b0d9cbc254ce3	t	2026-10-28 12:09:35.927887+00
475	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	matching	p10	190	ff277bcebb75e883	t	2026-10-28 12:09:37.829677+00
476	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t1	181	いっしょ	t	2026-10-28 12:10:06.240354+00
477	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t2	182	いっぱん	t	2026-10-28 12:10:20.958457+00
478	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t3	183	いどう	t	2026-10-28 12:10:28.49214+00
479	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t4	184	いない	t	2026-10-28 12:10:34.249895+00
480	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t5	185	いなか	t	2026-10-28 12:10:38.877793+00
481	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t6	186	いま	t	2026-10-28 12:10:52.880793+00
482	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t7	187	いみ	t	2026-10-28 12:10:58.981806+00
483	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t8	188	いんさつ	t	2026-10-28 12:11:06.930655+00
484	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t9	189	いんしょう	t	2026-10-28 12:11:13.598843+00
485	8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	typing	t10	190	いんしょく	t	2026-10-28 12:11:29.218395+00
486	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m1	392	392	t	2026-10-28 12:13:26.590405+00
487	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m2	393	393	t	2026-10-28 12:13:38.143989+00
488	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m3	394	394	t	2026-10-28 12:13:41.903439+00
489	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m4	395	395	t	2026-10-28 12:13:45.119855+00
490	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m5	396	396	t	2026-10-28 12:13:49.194814+00
491	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m6	397	397	t	2026-10-28 12:13:56.522781+00
492	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m7	398	398	t	2026-10-28 12:14:02.647969+00
493	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m8	399	399	t	2026-10-28 12:14:05.275376+00
494	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m9	400	396	f	2026-10-28 12:14:08.759595+00
495	f85ac244-fb75-4266-bcd1-f640485383f5	mc	m10	401	401	t	2026-10-28 12:14:14.021637+00
496	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p1	392	65b408655104e8db	f	2026-10-28 12:14:25.582306+00
497	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p2	393	61471704c5b54948	t	2026-10-28 12:14:33.663352+00
498	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p3	394	bdb81ac725a085c8	t	2026-10-28 12:14:40.404367+00
499	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p4	395	762c5ce81f110b51	t	2026-10-28 12:14:43.021352+00
500	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p5	396	65b408655104e8db	t	2026-10-28 12:14:44.621449+00
501	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p6	397	a4b47b343b3a2529	t	2026-10-28 12:14:50.989275+00
502	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p7	398	12e085084c17e0c4	t	2026-10-28 12:14:55.672252+00
503	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p8	399	118b1d432bf1e32e	t	2026-10-28 12:15:03.997234+00
504	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p9	400	52f5cb484ad1f160	t	2026-10-28 12:15:07.974134+00
505	f85ac244-fb75-4266-bcd1-f640485383f5	matching	p10	401	9e224520eff30e7e	t	2026-10-28 12:15:09.737612+00
506	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t1	392	じしん	t	2026-10-28 12:15:27.110755+00
507	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t2	393	しんじる	t	2026-10-28 12:15:37.336644+00
508	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t3	394	しん	f	2026-10-28 12:16:00.367454+00
509	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t4	395	しんご	f	2026-10-28 12:16:12.274684+00
510	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t5	396	あ	f	2026-10-28 12:16:49.559382+00
511	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t6	397	k	f	2026-10-28 12:17:00.704894+00
512	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t7	398	かんする	t	2026-10-28 12:17:08.976491+00
513	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t8	399	かんけい	t	2026-10-28 12:17:57.239491+00
514	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t9	400	かかり	t	2026-10-28 12:18:05.019292+00
515	f85ac244-fb75-4266-bcd1-f640485383f5	typing	t10	401	きんし	t	2026-10-28 12:18:11.192272+00
516	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m1	373	373	t	2026-11-07 14:25:09.379212+00
517	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m2	374	374	t	2026-11-07 14:25:12.207434+00
518	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m3	375	375	t	2026-11-07 14:25:15.284796+00
519	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m4	376	376	t	2026-11-07 14:25:18.000745+00
520	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m5	377	377	t	2026-11-07 14:25:20.793014+00
521	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m6	378	378	t	2026-11-07 14:25:23.10349+00
522	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m7	379	379	t	2026-11-07 14:25:25.462896+00
523	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m8	380	380	t	2026-11-07 14:25:27.875277+00
524	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m9	381	381	t	2026-11-07 14:25:29.872983+00
525	d4484e9e-ed96-4a36-903c-4855ae84b9a6	mc	m10	372	372	t	2026-11-07 14:25:33.313573+00
526	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p1	373	f5089174845886a5	t	2026-11-07 14:25:36.943731+00
527	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p2	374	8ae113e155bb9e3a	t	2026-11-07 14:25:39.563829+00
528	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p3	375	50f447b7d9bae862	t	2026-11-07 14:25:41.302607+00
529	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p4	376	973af942ee12173e	t	2026-11-07 14:25:43.299353+00
530	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p5	377	3934d9e7d45de66a	t	2026-11-07 14:25:44.885355+00
531	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p6	378	f7007dbbffa02f9c	t	2026-11-07 14:25:46.951364+00
532	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p7	379	224c1468f7a2935e	t	2026-11-07 14:25:48.708728+00
533	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p8	380	a5bfb76b615bf228	t	2026-11-07 14:25:50.301252+00
534	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p9	381	451e80a5a5078c0c	t	2026-11-07 14:25:52.350088+00
535	d4484e9e-ed96-4a36-903c-4855ae84b9a6	matching	p10	372	bf8dcc6b5673f3f2	t	2026-11-07 14:25:53.904654+00
536	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t1	373	むりょう	t	2026-11-07 14:26:05.058182+00
537	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t2	374	むりな	t	2026-11-07 14:26:09.042354+00
538	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t3	375	ない	t	2026-11-07 14:26:12.0508+00
539	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t4	376	むだん	t	2026-11-07 14:26:16.415457+00
540	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t5	377	だんすい	t	2026-11-07 14:26:20.45937+00
541	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t6	378	ことわる	t	2026-11-07 14:26:24.266487+00
542	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t7	379	おうだん	t	2026-11-07 14:26:27.831523+00
543	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t8	380	おうだんほうどう	f	2026-11-07 14:26:33.334779+00
544	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t9	381	よこ	t	2026-11-07 14:26:40.010484+00
545	d4484e9e-ed96-4a36-903c-4855ae84b9a6	typing	t10	372	むきゅう	t	2026-11-07 14:26:47.967982+00
546	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m1	363	363	t	2026-11-07 14:27:18.713459+00
547	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m2	364	364	t	2026-11-07 14:27:26.814935+00
548	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m3	369	369	t	2026-11-07 14:27:29.576755+00
549	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m4	366	366	t	2026-11-07 14:27:32.187855+00
550	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m5	367	367	t	2026-11-07 14:27:35.970656+00
551	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m6	368	368	t	2026-11-07 14:27:39.342863+00
552	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m7	365	365	t	2026-11-07 14:27:41.781809+00
553	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m8	370	370	t	2026-11-07 14:27:43.749762+00
554	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m9	371	371	t	2026-11-07 14:27:46.826127+00
555	b97b95b6-4f85-44ee-b886-d47fc9089d68	mc	m10	362	362	t	2026-11-07 14:27:49.07635+00
556	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p1	363	86caa497428178c8	t	2026-11-07 14:27:53.891683+00
557	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p2	364	12978ccedbe5daba	t	2026-11-07 14:27:57.531624+00
558	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p3	369	6312df95ee6528c2	t	2026-11-07 14:27:59.558031+00
559	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p4	366	ccde07434197a0d0	t	2026-11-07 14:28:34.571873+00
560	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p5	367	b2e0c6c91fd1535d	t	2026-11-07 14:28:36.474721+00
561	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p6	368	4dd8cbc8fd35635e	f	2026-11-07 14:28:39.077964+00
562	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p7	365	c2ae321b3f40f668	t	2026-11-07 14:28:43.12237+00
563	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p8	370	88560e8686f5e792	t	2026-11-07 14:28:45.127055+00
564	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p9	371	c79942214f467962	t	2026-11-07 14:28:47.360024+00
565	b97b95b6-4f85-44ee-b886-d47fc9089d68	matching	p10	362	4dd8cbc8fd35635e	t	2026-11-07 14:28:48.9024+00
566	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t1	363	ちゅうしゃ	t	2026-11-07 14:28:57.226749+00
567	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t2	364	まんしゃ	t	2026-11-07 14:29:05.529897+00
568	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t3	369	とぶ	t	2026-11-07 14:29:08.727254+00
569	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t4	366	まんいん	t	2026-11-07 14:29:13.070539+00
570	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t5	367	ふまんな	t	2026-11-07 14:29:17.211227+00
571	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t6	368	ひこうじょう	t	2026-11-07 14:29:22.62674+00
572	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t7	365	ごうしゃ	t	2026-11-07 14:29:26.547739+00
573	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t8	370	かい	t	2026-11-07 14:29:29.521432+00
574	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t9	371	かいだん	t	2026-11-07 14:29:33.342031+00
575	b97b95b6-4f85-44ee-b886-d47fc9089d68	typing	t10	362	ちゅうしゃじょう	t	2026-11-07 14:29:57.256053+00
576	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m1	382	382	t	2026-11-07 14:30:27.516777+00
577	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m2	383	383	t	2026-11-07 14:30:31.73816+00
578	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m3	384	384	t	2026-11-07 14:30:34.025073+00
579	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m4	385	385	t	2026-11-07 14:30:36.161339+00
580	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m5	386	386	t	2026-11-07 14:30:38.596502+00
581	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m6	387	387	t	2026-11-07 14:30:40.492017+00
582	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m7	388	388	t	2026-11-07 14:30:44.164615+00
583	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m8	389	389	t	2026-11-07 14:30:46.265601+00
584	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m9	390	390	t	2026-11-07 14:30:48.432677+00
585	3a90c644-b5bf-4ec0-8295-d80e5b652486	mc	m10	391	391	t	2026-11-07 14:30:51.541792+00
586	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p1	382	2a52fef5dd55b87a	t	2026-11-07 14:30:54.440593+00
587	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p2	383	06efce85bdf1db26	t	2026-11-07 14:30:57.349455+00
588	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p3	384	8b7e9599ec535356	t	2026-11-07 14:30:59.499108+00
589	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p4	385	984e5187a183de19	t	2026-11-07 14:31:02.622976+00
590	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p5	386	e61f44c34bba22e5	t	2026-11-07 14:31:04.737341+00
591	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p6	387	e318c5d855e32ec0	t	2026-11-07 14:31:07.65163+00
592	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p7	388	df3ff36a5ac5490e	t	2026-11-07 14:31:09.49241+00
593	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p8	389	b73fd600b1432dee	t	2026-11-07 14:31:12.661432+00
594	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p9	390	0aac2aa191963f80	t	2026-11-07 14:31:14.471093+00
595	3a90c644-b5bf-4ec0-8295-d80e5b652486	matching	p10	391	68eb6b714b1cfdda	t	2026-11-07 14:31:16.106703+00
596	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t1	382	おす	t	2026-11-07 14:31:20.483629+00
597	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t2	383	おしいれ	t	2026-11-07 14:31:24.698716+00
598	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t3	384	おさえる	t	2026-11-07 14:31:28.527783+00
599	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t4	385	おしボタンしき	f	2026-11-07 14:31:47.634494+00
600	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t5	386	すうしき	t	2026-11-07 14:31:53.355419+00
601	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t6	387	にゅうがくしき	t	2026-11-07 14:32:01.366477+00
602	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t7	388	ほうこう	t	2026-11-07 14:32:05.232771+00
603	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t8	389	むかう	t	2026-11-07 14:32:08.994907+00
604	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t9	390	むき	t	2026-11-07 14:32:12.219654+00
605	3a90c644-b5bf-4ec0-8295-d80e5b652486	typing	t10	391	はこ	t	2026-11-07 14:32:15.560783+00
606	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m1	392	392	t	2026-11-08 12:58:44.845867+00
607	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m2	393	393	t	2026-11-08 12:58:47.987502+00
608	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m3	394	394	t	2026-11-08 12:58:51.494913+00
609	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m4	395	395	t	2026-11-08 12:58:55.537619+00
610	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m5	396	396	t	2026-11-08 12:58:57.876752+00
611	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m6	397	397	t	2026-11-08 12:59:00.236988+00
612	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m7	398	398	t	2026-11-08 12:59:02.557239+00
613	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m8	399	399	t	2026-11-08 12:59:05.731588+00
614	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m9	400	400	t	2026-11-08 12:59:08.124292+00
615	bf900f1f-c6b9-4780-afc7-6faccbe593ed	mc	m10	401	401	t	2026-11-08 12:59:10.680836+00
616	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p1	392	42a9cb0194d92a14	t	2026-11-08 12:59:14.207+00
617	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p2	393	fbaf7d4e6d41b363	t	2026-11-08 12:59:18.23373+00
618	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p3	394	12a8d1deb79386e2	t	2026-11-08 12:59:21.255772+00
619	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p4	395	1dc4ae56c6e54f95	t	2026-11-08 12:59:23.819475+00
620	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p5	396	499b796c42a71723	t	2026-11-08 12:59:25.603846+00
621	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p6	397	322b3cac67ab182f	t	2026-11-08 12:59:28.618878+00
622	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p7	398	cb5454652b42fe8b	t	2026-11-08 12:59:31.67997+00
623	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p8	399	a371fee8dfa074e1	t	2026-11-08 12:59:44.805207+00
624	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p10	401	0c16b080b2bd591b	t	2026-11-08 12:59:49.062678+00
625	bf900f1f-c6b9-4780-afc7-6faccbe593ed	matching	p9	400	8aee500eb36741fe	t	2026-11-08 12:59:51.411218+00
626	bf900f1f-c6b9-4780-afc7-6faccbe593ed	typing	t1	392	じしん	t	2026-11-08 13:02:45.543857+00
627	bf900f1f-c6b9-4780-afc7-6faccbe593ed	typing	t2	393	しんじる	t	2026-11-08 13:02:48.869942+00
628	bf900f1f-c6b9-4780-afc7-6faccbe593ed	typing	t3	394	しんよう	t	2026-11-08 13:02:54.398626+00
629	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m1	482	482	t	2026-11-09 10:00:50.838033+00
630	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m2	483	483	t	2026-11-09 10:00:52.90864+00
631	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m3	484	484	t	2026-11-09 10:00:55.92976+00
632	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m4	485	485	t	2026-11-09 10:00:58.483278+00
633	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m5	486	486	t	2026-11-09 10:01:00.404701+00
634	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m6	487	487	t	2026-11-09 10:01:02.693446+00
635	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m7	488	488	t	2026-11-09 10:01:04.895256+00
636	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m8	489	489	t	2026-11-09 10:01:08.59536+00
637	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m9	490	490	t	2026-11-09 10:01:12.036089+00
638	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	mc	m10	491	491	t	2026-11-09 10:01:15.980115+00
639	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p1	482	3212d3a9f44f5f73	t	2026-11-09 10:01:18.561923+00
640	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p2	483	8cc40dd6c0ca2904	t	2026-11-09 10:01:21.571697+00
641	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p3	484	6d44179956ac57be	t	2026-11-09 10:01:25.073097+00
642	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p5	486	51962156961e233a	t	2026-11-09 10:01:46.386989+00
643	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p4	485	09ccf0120e384921	t	2026-11-09 10:01:48.505841+00
644	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p6	487	58c1aa93e42de754	t	2026-11-09 10:01:53.347012+00
645	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p7	488	256ffae2cdbb2466	t	2026-11-09 10:01:56.145204+00
646	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p8	489	b689ea04774ead0b	t	2026-11-09 10:01:58.568771+00
647	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p9	490	01fdfde11f4d1e76	t	2026-11-09 10:02:04.63586+00
648	e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	matching	p10	491	f55405eea759a97f	t	2026-11-09 10:02:06.501627+00
649	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m1	191	191	t	2026-11-12 04:59:06.604553+00
650	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m2	192	192	t	2026-11-12 04:59:09.705787+00
651	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m3	193	193	t	2026-11-12 04:59:12.621722+00
652	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m4	194	194	t	2026-11-12 04:59:16.946012+00
653	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m5	195	195	t	2026-11-12 04:59:19.441174+00
654	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m6	196	196	t	2026-11-12 04:59:22.37629+00
655	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m7	197	197	t	2026-11-12 04:59:25.770046+00
656	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m8	198	198	t	2026-11-12 04:59:30.960079+00
657	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m9	199	199	t	2026-11-12 04:59:34.242023+00
658	69a560c5-540e-4812-8dfe-0f802ec6b2a9	mc	m10	200	200	t	2026-11-12 04:59:37.056279+00
659	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p1	191	5a90e96e22ff4ad9	t	2026-11-12 04:59:40.580521+00
660	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p2	192	2f4e1d5cf021f3ce	t	2026-11-12 04:59:44.406659+00
661	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p3	193	188897b5f1fa165e	t	2026-11-12 04:59:46.820837+00
662	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p4	194	9132b66ce9bc12c8	t	2026-11-12 04:59:48.965955+00
663	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p5	195	79bb2d5707621131	t	2026-11-12 04:59:50.761395+00
664	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p6	196	08b195f2e2b4eee5	t	2026-11-12 04:59:53.617227+00
665	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p7	197	fc6cfae2c04e90d8	t	2026-11-12 04:59:57.258529+00
666	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p8	198	7e5e9c22a6801f50	t	2026-11-12 05:00:00.236676+00
667	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p9	199	b38ed172ca0a2226	t	2026-11-12 05:00:06.033737+00
668	69a560c5-540e-4812-8dfe-0f802ec6b2a9	matching	p10	200	f9060b3ba5a003da	t	2026-11-12 05:00:07.881535+00
669	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t1	191	えいきょう	t	2026-11-12 05:00:18.264489+00
670	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t2	192	えいぎょう	t	2026-11-12 05:00:24.126109+00
671	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t3	193	えいよう	t	2026-11-12 05:00:29.954926+00
672	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t4	194	えがお	t	2026-11-12 05:00:33.459786+00
673	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t5	195	えきまえ	t	2026-11-12 05:00:37.017063+00
674	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t6	196	えんき	t	2026-11-12 05:00:42.283292+00
675	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t7	197	えんそう	t	2026-11-12 05:00:47.981448+00
676	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t8	198	えんりょ	t	2026-11-12 05:00:59.867304+00
677	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t9	199	おうえん	t	2026-11-12 05:01:03.850205+00
678	69a560c5-540e-4812-8dfe-0f802ec6b2a9	typing	t10	200	おうだん	t	2026-11-12 05:01:07.223462+00
679	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m1	201	201	t	2026-11-12 05:02:30.287074+00
680	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m2	202	202	t	2026-11-12 05:02:33.439788+00
681	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m3	203	203	t	2026-11-12 05:02:36.090222+00
682	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m4	204	204	t	2026-11-12 05:02:39.067371+00
683	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m5	205	205	t	2026-11-12 05:02:48.518709+00
684	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m6	206	206	t	2026-11-12 05:02:51.127802+00
685	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m7	207	207	t	2026-11-12 05:02:54.089982+00
686	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m8	208	208	t	2026-11-12 05:02:57.405126+00
687	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m9	209	209	t	2026-11-12 05:02:59.79293+00
688	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	mc	m10	210	210	t	2026-11-12 05:03:02.747629+00
689	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p1	201	01234c5f44d0b0ee	t	2026-11-12 05:03:05.79356+00
690	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p2	202	3bdab0b5f730c6e7	t	2026-11-12 05:03:10.975127+00
691	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p4	204	58237a47a459d399	t	2026-11-12 05:03:14.686102+00
692	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p5	205	39c1284e457ea265	t	2026-11-12 05:03:16.969908+00
693	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p3	203	cb1253d877ed643f	t	2026-11-12 05:03:18.827684+00
694	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p6	206	07beaf3ff889cbac	t	2026-11-12 05:03:21.135328+00
695	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p7	207	df4e648685850220	t	2026-11-12 05:03:24.406654+00
696	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p8	208	d870bfa134c7d445	t	2026-11-12 05:03:26.910245+00
697	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p9	209	4c2c1b98f645950b	t	2026-11-12 05:03:29.131533+00
698	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	matching	p10	210	780096fcba9a1c7e	t	2026-11-12 05:03:31.258939+00
699	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t1	201	あきらめる	t	2026-11-12 05:03:39.775238+00
700	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t2	202	あきる	t	2026-11-12 05:03:43.735995+00
701	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t3	203	あく	t	2026-11-12 05:03:46.987075+00
702	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t4	204	あける	t	2026-11-12 05:03:51.334996+00
703	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t5	205	あずける	t	2026-11-12 05:03:55.168139+00
704	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t6	206	あたえる	t	2026-11-12 05:03:58.811163+00
705	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t7	207	あたためる	t	2026-11-12 05:04:05.535343+00
706	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t8	208	あやまる	t	2026-11-12 05:04:09.615668+00
707	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t9	209	あらわす	t	2026-11-12 05:04:13.765742+00
708	6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	typing	t10	210	あわてる	t	2026-11-12 05:04:19.285918+00
709	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m1	151	151	t	2026-11-12 05:05:16.765512+00
710	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m2	152	152	t	2026-11-12 05:05:18.983916+00
711	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m3	153	153	t	2026-11-12 05:05:21.849492+00
712	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m4	154	154	t	2026-11-12 05:05:24.074482+00
713	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m5	155	155	t	2026-11-12 05:05:26.298067+00
714	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m6	156	156	t	2026-11-12 05:05:28.457615+00
715	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m7	157	157	t	2026-11-12 05:05:30.381457+00
716	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m8	158	158	t	2026-11-12 05:05:32.476337+00
717	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m9	172	172	t	2026-11-12 05:05:34.574548+00
718	489faedb-58ee-4de6-be02-9c5ae873c518	mc	m10	176	176	t	2026-11-12 05:05:37.128568+00
719	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p1	151	7d23dbec2565b7eb	t	2026-11-12 05:05:39.805014+00
720	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p2	152	f75190c2b2994b9d	t	2026-11-12 05:05:48.010655+00
721	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p3	153	6d8348fabe12fede	t	2026-11-12 05:05:49.880772+00
722	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p4	154	70758ea328570f92	t	2026-11-12 05:05:51.658953+00
723	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p5	155	7f535f7ed04d3e8f	t	2026-11-12 05:05:53.484636+00
724	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p6	156	f414cdeb507317c9	t	2026-11-12 05:05:56.858619+00
725	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p7	157	0d3877aae77a4bd7	t	2026-11-12 05:06:04.716246+00
726	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p8	158	dfbf82ba06c40966	t	2026-11-12 05:06:07.141127+00
727	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p9	172	16e6302fa876d417	t	2026-11-12 05:06:09.212215+00
728	489faedb-58ee-4de6-be02-9c5ae873c518	matching	p10	176	b46b2b94e2a9ce44	t	2026-11-12 05:06:11.147607+00
729	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t1	151	あいだ	t	2026-11-12 05:06:19.939389+00
730	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t2	152	あお	t	2026-11-12 05:06:23.018671+00
731	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t3	153	あじ	t	2026-11-12 05:06:26.497437+00
732	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t4	154	あな	t	2026-11-12 05:06:29.348272+00
733	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t5	155	あぶら	t	2026-11-12 05:06:32.513679+00
734	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t6	156	あん	t	2026-11-12 05:06:36.486435+00
735	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t7	157	い	t	2026-11-12 05:06:39.31226+00
736	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t8	158	いえ	t	2026-11-12 05:06:42.02424+00
737	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t9	172	あいて	t	2026-11-12 05:06:45.133857+00
738	489faedb-58ee-4de6-be02-9c5ae873c518	typing	t10	176	いか	t	2026-11-12 05:06:48.269581+00
739	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m1	211	211	t	2026-11-13 09:28:23.511995+00
740	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m2	212	212	t	2026-11-13 09:28:26.942745+00
741	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m3	213	213	t	2026-11-13 09:28:29.864634+00
742	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m4	214	214	t	2026-11-13 09:28:33.511054+00
743	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m5	215	215	t	2026-11-13 09:28:36.01038+00
744	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m6	216	216	t	2026-11-13 09:28:40.666307+00
745	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m7	217	217	t	2026-11-13 09:28:43.026994+00
746	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m8	218	218	t	2026-11-13 09:28:45.765157+00
747	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m9	219	219	t	2026-11-13 09:28:48.634647+00
748	131d3183-49af-47fe-9ffc-5c0c656b3f60	mc	m10	220	220	t	2026-11-13 09:28:51.139836+00
749	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p1	211	1eff38fab91f09e1	t	2026-11-13 09:28:53.982415+00
750	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p2	212	fbe0cba1db275f7c	f	2026-11-13 09:28:55.97019+00
751	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p3	213	0308ac104e480f48	t	2026-11-13 09:28:59.153314+00
752	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p4	214	fbe0cba1db275f7c	t	2026-11-13 09:29:01.56149+00
753	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p5	215	aa935f25baf7b584	t	2026-11-13 09:29:03.601552+00
754	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p6	216	dfdf5ca5e6c6164a	t	2026-11-13 09:29:06.504861+00
755	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p7	217	41d5bff73e6f383c	t	2026-11-13 09:29:09.106821+00
756	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p8	218	8d2ec7d50d6efd6b	t	2026-11-13 09:29:12.012613+00
757	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p9	219	adfd88c92c039b02	t	2026-11-13 09:29:13.875422+00
758	131d3183-49af-47fe-9ffc-5c0c656b3f60	matching	p10	220	cdb13d1327ab178d	t	2026-11-13 09:29:15.949033+00
759	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t1	211	えらぶ	t	2026-11-13 09:29:23.77885+00
760	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t2	212	かくす	t	2026-11-13 09:29:27.801335+00
761	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t3	213	かざる	t	2026-11-13 09:29:40.313249+00
762	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t4	214	かす	t	2026-11-13 09:29:44.269127+00
763	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t5	215	かせぐ	t	2026-11-13 09:29:48.583343+00
764	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t6	216	かたづける	t	2026-11-13 09:29:55.884581+00
765	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t7	217	かつ	t	2026-11-13 09:30:00.988945+00
766	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t8	218	かりる	t	2026-11-13 09:30:05.334922+00
767	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t9	219	かわく	t	2026-11-13 09:30:09.460021+00
768	131d3183-49af-47fe-9ffc-5c0c656b3f60	typing	t10	220	かわる	t	2026-11-13 09:30:13.40632+00
769	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m1	221	221	t	2026-11-13 09:30:56.101916+00
770	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m2	222	222	t	2026-11-13 09:31:04.689674+00
771	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m3	223	223	t	2026-11-13 09:31:07.302394+00
772	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m4	224	224	t	2026-11-13 09:31:09.861199+00
773	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m5	225	225	t	2026-11-13 09:31:12.416741+00
774	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m6	226	226	t	2026-11-13 09:31:16.223668+00
775	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m7	227	227	t	2026-11-13 09:31:23.93307+00
776	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m8	228	228	t	2026-11-13 09:31:26.632733+00
777	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m9	229	229	t	2026-11-13 09:31:29.576935+00
778	ea60b922-b97d-48cb-9cea-c39093e4d99b	mc	m10	230	230	t	2026-11-13 09:31:32.314081+00
779	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p1	221	bde7fa3205442431	t	2026-11-13 09:31:35.510718+00
780	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p2	222	4af913ef1cbe3fc1	t	2026-11-13 09:31:38.514459+00
781	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p3	223	557e4b079318c7e9	t	2026-11-13 09:31:41.612141+00
782	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p4	224	c2ae0db2de4f3ee4	t	2026-11-13 09:31:43.913182+00
783	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p5	225	0f7e734fc9244ebf	t	2026-11-13 09:31:45.95651+00
784	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p6	226	3cbdfe59e15aa9cd	t	2026-11-13 09:31:51.080791+00
785	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p7	227	3cbdfe59e15aa9cd	t	2026-11-13 09:31:53.935368+00
786	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p8	228	24645f1568769074	t	2026-11-13 09:31:56.53889+00
787	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p9	229	fcd886bba4fab167	t	2026-11-13 09:31:58.966122+00
788	ea60b922-b97d-48cb-9cea-c39093e4d99b	matching	p10	230	045eaf25a062b19e	t	2026-11-13 09:32:00.769131+00
789	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t1	221	あかるい	t	2026-11-13 09:32:06.19614+00
790	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t2	222	あさい	t	2026-11-13 09:32:10.211514+00
791	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t3	223	あたたかい	t	2026-11-13 09:32:14.9472+00
792	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t4	224	あたらしい	t	2026-11-13 09:32:18.872224+00
793	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t5	225	あつい	t	2026-11-13 09:32:23.350726+00
794	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t6	226	あつい	t	2026-11-13 09:32:27.542896+00
795	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t7	227	あつい	t	2026-11-13 09:32:31.425507+00
796	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t8	228	あぶない	t	2026-11-13 09:32:35.916587+00
797	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t9	229	あまい	t	2026-11-13 09:32:39.562428+00
798	ea60b922-b97d-48cb-9cea-c39093e4d99b	typing	t10	230	うつくしい	t	2026-11-13 09:32:48.504999+00
799	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m1	231	231	t	2026-11-13 09:34:03.812988+00
800	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m2	232	232	t	2026-11-13 09:34:06.204772+00
801	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m3	233	233	t	2026-11-13 09:34:08.53892+00
802	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m4	234	234	t	2026-11-13 09:34:15.423621+00
803	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m5	235	235	t	2026-11-13 09:34:19.245761+00
804	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m6	236	236	t	2026-11-13 09:34:22.246637+00
805	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m7	237	237	t	2026-11-13 09:34:25.761546+00
806	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m8	238	238	t	2026-11-13 09:34:30.155057+00
807	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m9	239	239	t	2026-11-13 09:34:33.178328+00
808	d5c5521c-758c-4366-9da2-c8538cd8c284	mc	m10	240	240	t	2026-11-13 09:34:36.660576+00
809	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p1	231	fba5c7c2e851ffa1	t	2026-11-13 09:35:16.763391+00
810	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p2	232	07759f3ca08dfab2	t	2026-11-13 09:35:19.345901+00
811	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p3	233	b4dd84fd7788f7b1	t	2026-11-13 09:35:21.199046+00
812	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p4	234	cda2acf2a7a03019	t	2026-11-13 09:35:22.980204+00
813	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p5	235	f3841bce374672f7	t	2026-11-13 09:35:24.89874+00
814	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p6	236	59d18049c148e253	t	2026-11-13 09:35:27.806081+00
815	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p7	237	271a386e06f9f6d6	t	2026-11-13 09:35:29.694033+00
816	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p8	238	1295814bbcff69e6	t	2026-11-13 09:35:31.621556+00
817	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p9	239	862bb6d90ad21eed	t	2026-11-13 09:35:33.533852+00
818	d5c5521c-758c-4366-9da2-c8538cd8c284	matching	p10	240	ebd3406437609673	t	2026-11-13 09:35:35.234775+00
819	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t1	231	あんぜんな	t	2026-11-13 09:35:45.5636+00
820	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t2	232	いがいな	t	2026-11-13 09:35:49.945035+00
821	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t3	233	いっぱんてきな	t	2026-11-13 09:35:57.180423+00
822	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t4	234	いやな	t	2026-11-13 09:36:01.140467+00
823	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t5	235	かくじつな	t	2026-11-13 09:36:06.330794+00
824	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t6	236	かつどうてきな	t	2026-11-13 09:36:19.466685+00
825	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t7	237	かのうな	t	2026-11-13 09:36:40.342172+00
826	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t8	238	かんたんな	t	2026-11-13 09:36:48.68308+00
827	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t9	239	きけんな	t	2026-11-13 09:36:53.602811+00
828	d5c5521c-758c-4366-9da2-c8538cd8c284	typing	t10	240	けんこうな	t	2026-11-13 09:37:04.096508+00
829	3e31c386-3387-4337-b29d-b7e3997de737	mc	m1	178	178	t	2026-11-13 09:43:31.090239+00
830	3e31c386-3387-4337-b29d-b7e3997de737	mc	m2	161	161	t	2026-11-13 09:43:34.617273+00
831	3e31c386-3387-4337-b29d-b7e3997de737	mc	m3	162	162	t	2026-11-13 09:43:38.039102+00
832	3e31c386-3387-4337-b29d-b7e3997de737	mc	m4	163	163	t	2026-11-13 09:43:40.361104+00
833	3e31c386-3387-4337-b29d-b7e3997de737	mc	m5	164	164	t	2026-11-13 09:43:43.65084+00
834	3e31c386-3387-4337-b29d-b7e3997de737	mc	m6	165	165	t	2026-11-13 09:43:46.640277+00
835	3e31c386-3387-4337-b29d-b7e3997de737	mc	m7	166	166	t	2026-11-13 09:43:49.16703+00
836	3e31c386-3387-4337-b29d-b7e3997de737	mc	m8	167	167	t	2026-11-13 09:43:51.926099+00
837	3e31c386-3387-4337-b29d-b7e3997de737	mc	m9	168	168	t	2026-11-13 09:43:54.308285+00
838	3e31c386-3387-4337-b29d-b7e3997de737	mc	m10	169	169	t	2026-11-13 09:43:56.734552+00
839	3e31c386-3387-4337-b29d-b7e3997de737	matching	p1	178	ac43d6dafc4f4f71	t	2026-11-13 09:44:00.669903+00
840	3e31c386-3387-4337-b29d-b7e3997de737	matching	p2	161	2ea05dd7b52400ca	t	2026-11-13 09:44:06.783172+00
841	3e31c386-3387-4337-b29d-b7e3997de737	matching	p3	162	edc8da3b94e27e55	t	2026-11-13 09:44:09.386112+00
842	3e31c386-3387-4337-b29d-b7e3997de737	matching	p4	163	10ce60b338b2f7c8	t	2026-11-13 09:44:12.056529+00
843	3e31c386-3387-4337-b29d-b7e3997de737	matching	p5	164	8a8a8505d0bf9b10	t	2026-11-13 09:44:15.67689+00
844	3e31c386-3387-4337-b29d-b7e3997de737	matching	p6	165	338dc4e52a0e4bff	t	2026-11-13 09:45:01.343324+00
845	3e31c386-3387-4337-b29d-b7e3997de737	matching	p7	166	4c9906a4ababb06b	t	2026-11-13 09:45:04.008515+00
846	3e31c386-3387-4337-b29d-b7e3997de737	matching	p8	167	d7a9121870908d55	t	2026-11-13 09:45:05.904596+00
847	3e31c386-3387-4337-b29d-b7e3997de737	matching	p9	168	e750d45086beafe2	t	2026-11-13 09:45:09.16155+00
848	3e31c386-3387-4337-b29d-b7e3997de737	matching	p10	169	3c10af97b6e11b89	t	2026-11-13 09:45:11.471727+00
849	3e31c386-3387-4337-b29d-b7e3997de737	typing	t1	178	いけん	t	2026-11-13 09:45:20.76582+00
850	3e31c386-3387-4337-b29d-b7e3997de737	typing	t2	161	いと	t	2026-11-13 09:45:25.789921+00
851	3e31c386-3387-4337-b29d-b7e3997de737	typing	t3	162	いも	t	2026-11-13 09:45:30.520187+00
852	3e31c386-3387-4337-b29d-b7e3997de737	typing	t4	163	うや	f	2026-11-13 09:45:33.614436+00
853	3e31c386-3387-4337-b29d-b7e3997de737	typing	t5	164	うcじ	f	2026-11-13 09:45:38.307617+00
854	3e31c386-3387-4337-b29d-b7e3997de737	typing	t6	165	うつわ	t	2026-11-13 09:45:46.467145+00
855	3e31c386-3387-4337-b29d-b7e3997de737	typing	t7	166	うで	t	2026-11-13 09:45:51.339278+00
856	3e31c386-3387-4337-b29d-b7e3997de737	typing	t8	167	え	t	2026-11-13 09:45:53.991776+00
857	3e31c386-3387-4337-b29d-b7e3997de737	typing	t9	168	えだ	t	2026-11-13 09:45:57.145467+00
858	3e31c386-3387-4337-b29d-b7e3997de737	typing	t10	169	おく	t	2026-11-13 09:46:00.455858+00
\.


--
-- Data for Name: quiz_attempts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.quiz_attempts (id, session_id, stage, questions, created_at, finished_at) FROM stdin;
a4533626-27f9-4c07-a695-8f0e71af06d5	197f51be-3ad7-45b1-ae08-b06471729629	mc	{"mc": [{"key": "m1", "cardId": "1", "prompt": "お越しくださり", "correct": "1", "options": [{"id": "1", "label": "Hadir"}, {"id": "48", "label": "Sejarah/Historis"}, {"id": "33", "label": "Pengamatan/Observasi"}, {"id": "43", "label": "Kedokteran"}]}, {"key": "m2", "cardId": "2", "prompt": "個人的な", "correct": "2", "options": [{"id": "7", "label": "Perekaman/Merekam"}, {"id": "2", "label": "Perorangan/Pribadi"}, {"id": "9", "label": "Masa kini/sekarang"}, {"id": "39", "label": "Seumur Hidup/Riwayat Hidup"}]}, {"key": "m3", "cardId": "3", "prompt": "ざまざま", "correct": "3", "options": [{"id": "1", "label": "Hadir"}, {"id": "3", "label": "bermacam-macam"}, {"id": "45", "label": "Memiringkan/Membuang"}, {"id": "46", "label": "Pendirian/Pembentukan Perusahaan"}]}, {"key": "m4", "cardId": "4", "prompt": "梅雨", "correct": "4", "options": [{"id": "6", "label": "Langit cerah/Cerah"}, {"id": "13", "label": "Pengetahuan/wawasan"}, {"id": "4", "label": "Musim hujan"}, {"id": "40", "label": "Pencegahan/Mencegah"}]}, {"key": "m5", "cardId": "5", "prompt": "時期", "correct": "5", "options": [{"id": "2", "label": "Perorangan/Pribadi"}, {"id": "47", "label": "Mahal/Berharga/Tinggi"}, {"id": "5", "label": "晴天"}, {"id": "10", "label": "Penggunaan/Menggunakan"}]}, {"key": "m6", "cardId": "6", "prompt": "晴天", "correct": "6", "options": [{"id": "40", "label": "Pencegahan/Mencegah"}, {"id": "6", "label": "Langit cerah/Cerah"}, {"id": "18", "label": "Fungsi/Kemampuan"}, {"id": "43", "label": "Kedokteran"}]}, {"key": "m7", "cardId": "7", "prompt": "録音している", "correct": "7", "options": [{"id": "38", "label": "Peningkatan/Perbaikan"}, {"id": "11", "label": "Memperkenalkan"}, {"id": "7", "label": "Perekaman/Merekam"}, {"id": "5", "label": "晴天"}]}, {"key": "m8", "cardId": "8", "prompt": "紙幣", "correct": "8", "options": [{"id": "8", "label": "Uang kertas"}, {"id": "29", "label": "Latar Belakang"}, {"id": "25", "label": "Fitur/Karakteristik"}, {"id": "13", "label": "Pengetahuan/wawasan"}]}, {"key": "m9", "cardId": "9", "prompt": "現在", "correct": "9", "options": [{"id": "38", "label": "Peningkatan/Perbaikan"}, {"id": "2", "label": "Perorangan/Pribadi"}, {"id": "9", "label": "Masa kini/sekarang"}, {"id": "23", "label": "Jenis/Tipe"}]}, {"key": "m10", "cardId": "10", "prompt": "使用されている", "correct": "10", "options": [{"id": "3", "label": "bermacam-macam"}, {"id": "10", "label": "Penggunaan/Menggunakan"}, {"id": "14", "label": "Keberadaan"}, {"id": "20", "label": "Harga/Nilai/Manfaat"}]}], "typing": [{"key": "t1", "cardId": "1", "prompt": "Hadir", "answerKanji": "お越しくださり", "answerFurigana": "おこしくださり"}, {"key": "t2", "cardId": "2", "prompt": "Perorangan/Pribadi", "answerKanji": "個人的な", "answerFurigana": "こじんてきな"}, {"key": "t3", "cardId": "3", "prompt": "bermacam-macam", "answerKanji": "ざまざま", "answerFurigana": "ざまざま"}, {"key": "t4", "cardId": "4", "prompt": "Musim hujan", "answerKanji": "梅雨", "answerFurigana": "つゆ"}, {"key": "t5", "cardId": "5", "prompt": "晴天", "answerKanji": "時期", "answerFurigana": "Periode/Musim"}, {"key": "t6", "cardId": "6", "prompt": "Langit cerah/Cerah", "answerKanji": "晴天", "answerFurigana": "せいてん"}, {"key": "t7", "cardId": "7", "prompt": "Perekaman/Merekam", "answerKanji": "録音している", "answerFurigana": "ろくおんしている"}, {"key": "t8", "cardId": "8", "prompt": "Uang kertas", "answerKanji": "紙幣", "answerFurigana": "しへい"}, {"key": "t9", "cardId": "9", "prompt": "Masa kini/sekarang", "answerKanji": "現在", "answerFurigana": "げんざい"}, {"key": "t10", "cardId": "10", "prompt": "Penggunaan/Menggunakan", "answerKanji": "使用されている", "answerFurigana": "しようされている"}], "matching": [{"key": "p1", "label": "Hadir", "round": 0, "cardId": "1", "prompt": "お越しくださり", "correct": "1", "furigana": "おこしくださり"}, {"key": "p2", "label": "Perorangan/Pribadi", "round": 0, "cardId": "2", "prompt": "個人的な", "correct": "2", "furigana": "こじんてきな"}, {"key": "p3", "label": "bermacam-macam", "round": 0, "cardId": "3", "prompt": "ざまざま", "correct": "3", "furigana": "ざまざま"}, {"key": "p4", "label": "Musim hujan", "round": 0, "cardId": "4", "prompt": "梅雨", "correct": "4", "furigana": "つゆ"}, {"key": "p5", "label": "晴天", "round": 0, "cardId": "5", "prompt": "時期", "correct": "5", "furigana": "Periode/Musim"}, {"key": "p6", "label": "Langit cerah/Cerah", "round": 1, "cardId": "6", "prompt": "晴天", "correct": "6", "furigana": "せいてん"}, {"key": "p7", "label": "Perekaman/Merekam", "round": 1, "cardId": "7", "prompt": "録音している", "correct": "7", "furigana": "ろくおんしている"}, {"key": "p8", "label": "Uang kertas", "round": 1, "cardId": "8", "prompt": "紙幣", "correct": "8", "furigana": "しへい"}, {"key": "p9", "label": "Masa kini/sekarang", "round": 1, "cardId": "9", "prompt": "現在", "correct": "9", "furigana": "げんざい"}, {"key": "p10", "label": "Penggunaan/Menggunakan", "round": 1, "cardId": "10", "prompt": "使用されている", "correct": "10", "furigana": "しようされている"}]}	2026-10-12 15:43:14.491323+00	\N
3bef8659-a952-4de3-81c9-d4d214c57fff	bcc78f19-d73c-4652-b699-cf99eb58dc17	done	{"mc": [{"key": "m1", "cardId": "1", "prompt": "お越しくださり", "correct": "1", "options": [{"id": "36", "label": "Penerbitan/Terbitan"}, {"id": "31", "label": "Menyerahkan/Mempersembahkan/Mendedikasikan"}, {"id": "9", "label": "Masa kini/sekarang"}, {"id": "1", "label": "Hadir"}]}, {"key": "m2", "cardId": "2", "prompt": "個人的な", "correct": "2", "options": [{"id": "18", "label": "Fungsi/Kemampuan"}, {"id": "4", "label": "Musim hujan"}, {"id": "2", "label": "Perorangan/Pribadi"}, {"id": "38", "label": "Peningkatan/Perbaikan"}]}, {"key": "m3", "cardId": "3", "prompt": "ざまざま", "correct": "3", "options": [{"id": "32", "label": "Secara umum"}, {"id": "3", "label": "bermacam-macam"}, {"id": "1", "label": "Hadir"}, {"id": "30", "label": "Pembelajar"}]}, {"key": "m4", "cardId": "4", "prompt": "梅雨", "correct": "4", "options": [{"id": "39", "label": "Seumur Hidup/Riwayat Hidup"}, {"id": "13", "label": "Pengetahuan/wawasan"}, {"id": "26", "label": "Tercermin/Terbayang"}, {"id": "4", "label": "Musim hujan"}]}, {"key": "m5", "cardId": "5", "prompt": "時期", "correct": "5", "options": [{"id": "12", "label": "Rencana/proyek"}, {"id": "48", "label": "Sejarah/Historis"}, {"id": "11", "label": "Memperkenalkan"}, {"id": "5", "label": "晴天"}]}, {"key": "m6", "cardId": "6", "prompt": "晴天", "correct": "6", "options": [{"id": "4", "label": "Musim hujan"}, {"id": "31", "label": "Menyerahkan/Mempersembahkan/Mendedikasikan"}, {"id": "6", "label": "Langit cerah/Cerah"}, {"id": "28", "label": "Mengunjungi/Berkunjung"}]}, {"key": "m7", "cardId": "7", "prompt": "録音している", "correct": "7", "options": [{"id": "7", "label": "Perekaman/Merekam"}, {"id": "1", "label": "Hadir"}, {"id": "44", "label": "Pemalsuan/Palsu"}, {"id": "17", "label": "Selanjutnya/Lain kali"}]}, {"key": "m8", "cardId": "8", "prompt": "紙幣", "correct": "8", "options": [{"id": "8", "label": "Uang kertas"}, {"id": "21", "label": "Kesempatan/Peluang"}, {"id": "35", "label": "Mengangkat/Mengambil"}, {"id": "10", "label": "Penggunaan/Menggunakan"}]}, {"key": "m9", "cardId": "9", "prompt": "現在", "correct": "9", "options": [{"id": "42", "label": "Percetakan/Cetak"}, {"id": "9", "label": "Masa kini/sekarang"}, {"id": "14", "label": "Keberadaan"}, {"id": "27", "label": "Rotasi/Perputaran"}]}, {"key": "m10", "cardId": "10", "prompt": "使用されている", "correct": "10", "options": [{"id": "10", "label": "Penggunaan/Menggunakan"}, {"id": "33", "label": "Pengamatan/Observasi"}, {"id": "36", "label": "Penerbitan/Terbitan"}, {"id": "41", "label": "Mendunia"}]}], "typing": [{"key": "t1", "cardId": "1", "prompt": "Hadir", "answerKanji": "お越しくださり", "answerFurigana": "おこしくださり"}, {"key": "t2", "cardId": "2", "prompt": "Perorangan/Pribadi", "answerKanji": "個人的な", "answerFurigana": "こじんてきな"}, {"key": "t3", "cardId": "3", "prompt": "bermacam-macam", "answerKanji": "ざまざま", "answerFurigana": "ざまざま"}, {"key": "t4", "cardId": "4", "prompt": "Musim hujan", "answerKanji": "梅雨", "answerFurigana": "つゆ"}, {"key": "t5", "cardId": "5", "prompt": "晴天", "answerKanji": "時期", "answerFurigana": "Periode/Musim"}, {"key": "t6", "cardId": "6", "prompt": "Langit cerah/Cerah", "answerKanji": "晴天", "answerFurigana": "せいてん"}, {"key": "t7", "cardId": "7", "prompt": "Perekaman/Merekam", "answerKanji": "録音している", "answerFurigana": "ろくおんしている"}, {"key": "t8", "cardId": "8", "prompt": "Uang kertas", "answerKanji": "紙幣", "answerFurigana": "しへい"}, {"key": "t9", "cardId": "9", "prompt": "Masa kini/sekarang", "answerKanji": "現在", "answerFurigana": "げんざい"}, {"key": "t10", "cardId": "10", "prompt": "Penggunaan/Menggunakan", "answerKanji": "使用されている", "answerFurigana": "しようされている"}], "matching": [{"key": "p1", "label": "Hadir", "round": 0, "cardId": "1", "prompt": "お越しくださり", "correct": "1", "furigana": "おこしくださり"}, {"key": "p2", "label": "Perorangan/Pribadi", "round": 0, "cardId": "2", "prompt": "個人的な", "correct": "2", "furigana": "こじんてきな"}, {"key": "p3", "label": "bermacam-macam", "round": 0, "cardId": "3", "prompt": "ざまざま", "correct": "3", "furigana": "ざまざま"}, {"key": "p4", "label": "Musim hujan", "round": 0, "cardId": "4", "prompt": "梅雨", "correct": "4", "furigana": "つゆ"}, {"key": "p5", "label": "晴天", "round": 0, "cardId": "5", "prompt": "時期", "correct": "5", "furigana": "Periode/Musim"}, {"key": "p6", "label": "Langit cerah/Cerah", "round": 1, "cardId": "6", "prompt": "晴天", "correct": "6", "furigana": "せいてん"}, {"key": "p7", "label": "Perekaman/Merekam", "round": 1, "cardId": "7", "prompt": "録音している", "correct": "7", "furigana": "ろくおんしている"}, {"key": "p8", "label": "Uang kertas", "round": 1, "cardId": "8", "prompt": "紙幣", "correct": "8", "furigana": "しへい"}, {"key": "p9", "label": "Masa kini/sekarang", "round": 1, "cardId": "9", "prompt": "現在", "correct": "9", "furigana": "げんざい"}, {"key": "p10", "label": "Penggunaan/Menggunakan", "round": 1, "cardId": "10", "prompt": "使用されている", "correct": "10", "furigana": "しようされている"}]}	2026-10-12 15:52:22.574489+00	2026-10-12 16:30:07.461977+00
4b09f081-fe37-466c-b30f-a44609691471	5ee37a7e-8eb0-401e-99a0-67ed25363f49	matching	{"mc": [{"key": "m1", "cardId": "49", "prompt": "間", "correct": "49", "options": [{"id": "58", "label": "kolam"}, {"id": "49", "label": "antara; selama"}, {"id": "75", "label": "selain; kecuali"}, {"id": "118", "label": "berubah"}]}, {"key": "m2", "cardId": "50", "prompt": "青", "correct": "50", "options": [{"id": "77", "label": "sejak; setelah"}, {"id": "50", "label": "biru"}, {"id": "92", "label": "wajah tersenyum; senyuman"}, {"id": "104", "label": "memberikan; menyebabkan"}]}, {"key": "m3", "cardId": "51", "prompt": "味", "correct": "51", "options": [{"id": "73", "label": "panduan; petunjuk"}, {"id": "83", "label": "pedesaan; kampung halaman"}, {"id": "124", "label": "panas (benda)"}, {"id": "51", "label": "rasa"}]}, {"key": "m4", "cardId": "52", "prompt": "穴 (Bacaan Furigana)", "correct": "52", "options": [{"id": "52", "label": "あな"}, {"id": "82", "label": "いない"}, {"id": "58", "label": "いけ"}, {"id": "127", "label": "あまい"}]}, {"key": "m5", "cardId": "53", "prompt": "油 (Bacaan Furigana)", "correct": "53", "options": [{"id": "85", "label": "いみ"}, {"id": "147", "label": "けっして"}, {"id": "141", "label": "いちどに"}, {"id": "53", "label": "あぶら"}]}, {"key": "m6", "cardId": "54", "prompt": "案 (Bacaan Furigana)", "correct": "54", "options": [{"id": "145", "label": "ぐうぜん"}, {"id": "125", "label": "あつい"}, {"id": "141", "label": "いちどに"}, {"id": "54", "label": "あん"}]}, {"key": "m7", "cardId": "55", "prompt": "胃 (Bacaan Furigana)", "correct": "55", "options": [{"id": "55", "label": "い"}, {"id": "64", "label": "うで"}, {"id": "54", "label": "あん"}, {"id": "53", "label": "あぶら"}]}, {"key": "m8", "cardId": "56", "prompt": "家 (Bacaan Furigana)", "correct": "56", "options": [{"id": "109", "label": "えらぶ"}, {"id": "102", "label": "あける"}, {"id": "56", "label": "いえ"}, {"id": "126", "label": "あぶない"}]}, {"key": "m9", "cardId": "57", "prompt": "息", "correct": "57", "options": [{"id": "96", "label": "sungkan; menahan diri"}, {"id": "86", "label": "pencetakan; mencetak"}, {"id": "57", "label": "napas"}, {"id": "49", "label": "antara; selama"}]}, {"key": "m10", "cardId": "58", "prompt": "池", "correct": "58", "options": [{"id": "117", "label": "menjadi kering"}, {"id": "100", "label": "bosan"}, {"id": "123", "label": "panas (cuaca)"}, {"id": "58", "label": "kolam"}]}], "typing": [{"key": "t1", "cardId": "49", "prompt": "antara; selama", "answerKanji": "間", "answerFurigana": "あいだ"}, {"key": "t2", "cardId": "50", "prompt": "biru", "answerKanji": "青", "answerFurigana": "あお"}, {"key": "t3", "cardId": "51", "prompt": "rasa", "answerKanji": "味", "answerFurigana": "あじ"}, {"key": "t4", "cardId": "52", "prompt": "lubang", "answerKanji": "穴", "answerFurigana": "あな"}, {"key": "t5", "cardId": "53", "prompt": "minyak", "answerKanji": "油", "answerFurigana": "あぶら"}, {"key": "t6", "cardId": "54", "prompt": "usulan; ide", "answerKanji": "案", "answerFurigana": "あん"}, {"key": "t7", "cardId": "55", "prompt": "lambung", "answerKanji": "胃", "answerFurigana": "い"}, {"key": "t8", "cardId": "56", "prompt": "rumah", "answerKanji": "家", "answerFurigana": "いえ"}, {"key": "t9", "cardId": "57", "prompt": "napas", "answerKanji": "息", "answerFurigana": "いき"}, {"key": "t10", "cardId": "58", "prompt": "kolam", "answerKanji": "池", "answerFurigana": "いけ"}], "matching": [{"key": "p1", "label": "antara; selama", "round": 0, "token": "d0bd5344549c6050", "cardId": "49", "prompt": "間", "correct": "d0bd5344549c6050", "furigana": "あいだ"}, {"key": "p2", "label": "biru", "round": 0, "token": "789c797d08996a7d", "cardId": "50", "prompt": "青", "correct": "789c797d08996a7d", "furigana": "あお"}, {"key": "p3", "label": "rasa", "round": 0, "token": "903ca2b2941fde18", "cardId": "51", "prompt": "味", "correct": "903ca2b2941fde18", "furigana": "あじ"}, {"key": "p4", "label": "lubang", "round": 0, "token": "82062c901e866a74", "cardId": "52", "prompt": "穴", "correct": "82062c901e866a74", "furigana": "あな"}, {"key": "p5", "label": "minyak", "round": 0, "token": "265de600465b685d", "cardId": "53", "prompt": "油", "correct": "265de600465b685d", "furigana": "あぶら"}, {"key": "p6", "label": "usulan; ide", "round": 1, "token": "70dcfdb79c5e306a", "cardId": "54", "prompt": "案", "correct": "70dcfdb79c5e306a", "furigana": "あん"}, {"key": "p7", "label": "lambung", "round": 1, "token": "848d40ec59c3bc80", "cardId": "55", "prompt": "胃", "correct": "848d40ec59c3bc80", "furigana": "い"}, {"key": "p8", "label": "rumah", "round": 1, "token": "e1901e6b559c6dbb", "cardId": "56", "prompt": "家", "correct": "e1901e6b559c6dbb", "furigana": "いえ"}, {"key": "p9", "label": "napas", "round": 1, "token": "b2960e09c7e34ead", "cardId": "57", "prompt": "息", "correct": "b2960e09c7e34ead", "furigana": "いき"}, {"key": "p10", "label": "kolam", "round": 1, "token": "9fb397f71bcf69cd", "cardId": "58", "prompt": "池", "correct": "9fb397f71bcf69cd", "furigana": "いけ"}]}	2026-10-12 19:40:48.402785+00	\N
f8504241-362f-4694-8c2b-e4574dccd347	08da729b-56ba-4afe-b789-a67e45636a6c	done	{"mc": [{"key": "m1", "cardId": "151", "prompt": "間", "correct": "151", "options": [{"id": "344", "label": "benci; tidak suka"}, {"id": "192", "label": "operasional usaha; bisnis"}, {"id": "151", "label": "antara; selama"}, {"id": "299", "label": "penyelesaian"}]}, {"key": "m2", "cardId": "152", "prompt": "青", "correct": "152", "options": [{"id": "186", "label": "ruang keluarga"}, {"id": "183", "label": "perpindahan; bergerak"}, {"id": "152", "label": "biru"}, {"id": "343", "label": "mendadak; curam"}]}, {"key": "m3", "cardId": "153", "prompt": "味", "correct": "153", "options": [{"id": "227", "label": "tebal"}, {"id": "319", "label": "berpindah"}, {"id": "192", "label": "operasional usaha; bisnis"}, {"id": "153", "label": "rasa"}]}, {"key": "m4", "cardId": "154", "prompt": "穴", "correct": "154", "options": [{"id": "194", "label": "senyuman"}, {"id": "188", "label": "mencetak; pencetakan"}, {"id": "250", "label": "secara bertahap"}, {"id": "154", "label": "lubang"}]}, {"key": "m5", "cardId": "155", "prompt": "油 (Bacaan Furigana)", "correct": "155", "options": [{"id": "247", "label": "ぐうぜん"}, {"id": "155", "label": "あぶら"}, {"id": "195", "label": "えきまえ"}, {"id": "336", "label": "うるさい"}]}, {"key": "m6", "cardId": "156", "prompt": "案", "correct": "156", "options": [{"id": "243", "label": "sekaligus"}, {"id": "156", "label": "usulan; ide"}, {"id": "163", "label": "lagu"}, {"id": "221", "label": "terang; ceria"}]}, {"key": "m7", "cardId": "157", "prompt": "胃", "correct": "157", "options": [{"id": "310", "label": "lingkungan"}, {"id": "316", "label": "menerima; mengikuti"}, {"id": "157", "label": "lambung"}, {"id": "210", "label": "panik; tergesa-gesa"}]}, {"key": "m8", "cardId": "158", "prompt": "家 (Bacaan Furigana)", "correct": "158", "options": [{"id": "235", "label": "かくじつな"}, {"id": "214", "label": "かす"}, {"id": "158", "label": "いえ"}, {"id": "324", "label": "おこなう"}]}, {"key": "m9", "cardId": "159", "prompt": "息", "correct": "159", "options": [{"id": "159", "label": "napas"}, {"id": "317", "label": "meragukan; mencurigai"}, {"id": "288", "label": "resepsionis"}, {"id": "304", "label": "furnitur"}]}, {"key": "m10", "cardId": "160", "prompt": "池", "correct": "160", "options": [{"id": "315", "label": "menanam"}, {"id": "195", "label": "depan stasiun"}, {"id": "343", "label": "mendadak; curam"}, {"id": "160", "label": "kolam"}]}], "typing": [{"key": "t1", "cardId": "151", "prompt": "antara; selama", "answerKanji": "間", "answerFurigana": "あいだ"}, {"key": "t2", "cardId": "152", "prompt": "biru", "answerKanji": "青", "answerFurigana": "あお"}, {"key": "t3", "cardId": "153", "prompt": "rasa", "answerKanji": "味", "answerFurigana": "あじ"}, {"key": "t4", "cardId": "154", "prompt": "lubang", "answerKanji": "穴", "answerFurigana": "あな"}, {"key": "t5", "cardId": "155", "prompt": "minyak", "answerKanji": "油", "answerFurigana": "あぶら"}, {"key": "t6", "cardId": "156", "prompt": "usulan; ide", "answerKanji": "案", "answerFurigana": "あん"}, {"key": "t7", "cardId": "157", "prompt": "lambung", "answerKanji": "胃", "answerFurigana": "い"}, {"key": "t8", "cardId": "158", "prompt": "rumah", "answerKanji": "家", "answerFurigana": "いえ"}, {"key": "t9", "cardId": "159", "prompt": "napas", "answerKanji": "息", "answerFurigana": "いき"}, {"key": "t10", "cardId": "160", "prompt": "kolam", "answerKanji": "池", "answerFurigana": "いけ"}], "matching": [{"key": "p1", "label": "antara; selama", "round": 0, "token": "ffc19223835ede9a", "cardId": "151", "prompt": "間", "correct": "ffc19223835ede9a", "furigana": "あいだ"}, {"key": "p2", "label": "biru", "round": 0, "token": "b0d3423cad2781df", "cardId": "152", "prompt": "青", "correct": "b0d3423cad2781df", "furigana": "あお"}, {"key": "p3", "label": "rasa", "round": 0, "token": "a4e812b6b850badd", "cardId": "153", "prompt": "味", "correct": "a4e812b6b850badd", "furigana": "あじ"}, {"key": "p4", "label": "lubang", "round": 0, "token": "dc391dc13d3cb7c8", "cardId": "154", "prompt": "穴", "correct": "dc391dc13d3cb7c8", "furigana": "あな"}, {"key": "p5", "label": "minyak", "round": 0, "token": "807b8ad646a0735e", "cardId": "155", "prompt": "油", "correct": "807b8ad646a0735e", "furigana": "あぶら"}, {"key": "p6", "label": "usulan; ide", "round": 1, "token": "6c423bd9f279f437", "cardId": "156", "prompt": "案", "correct": "6c423bd9f279f437", "furigana": "あん"}, {"key": "p7", "label": "lambung", "round": 1, "token": "35f81e97de9de169", "cardId": "157", "prompt": "胃", "correct": "35f81e97de9de169", "furigana": "い"}, {"key": "p8", "label": "rumah", "round": 1, "token": "8a2b29665906afaf", "cardId": "158", "prompt": "家", "correct": "8a2b29665906afaf", "furigana": "いえ"}, {"key": "p9", "label": "napas", "round": 1, "token": "ac905ca5ec53d596", "cardId": "159", "prompt": "息", "correct": "ac905ca5ec53d596", "furigana": "いき"}, {"key": "p10", "label": "kolam", "round": 1, "token": "e26f84a3f12b640f", "cardId": "160", "prompt": "池", "correct": "e26f84a3f12b640f", "furigana": "いけ"}]}	2026-10-13 07:00:40.551509+00	2026-10-13 07:02:57.863833+00
7fa28812-3d9a-42d0-96b2-45937d41ee2b	9e8d8865-ca0c-4720-92ed-c388966c4b9b	mc	{"mc": [{"key": "m1", "cardId": "161", "prompt": "糸", "correct": "161", "options": [{"id": "262", "label": "pola; motif"}, {"id": "173", "label": "langit biru"}, {"id": "161", "label": "benang"}, {"id": "207", "label": "menghangatkan"}]}, {"key": "m2", "cardId": "162", "prompt": "芋", "correct": "162", "options": [{"id": "236", "label": "aktif"}, {"id": "162", "label": "umbi; kentang"}, {"id": "295", "label": "musik"}, {"id": "271", "label": "bahu"}]}, {"key": "m3", "cardId": "163", "prompt": "歌 (Bacaan Furigana)", "correct": "163", "options": [{"id": "226", "label": "あつい"}, {"id": "323", "label": "おくれる"}, {"id": "268", "label": "かお"}, {"id": "163", "label": "うた"}]}, {"key": "m4", "cardId": "164", "prompt": "内", "correct": "164", "options": [{"id": "288", "label": "resepsionis"}, {"id": "164", "label": "bagian dalam"}, {"id": "187", "label": "arti; makna"}, {"id": "247", "label": "secara kebetulan"}]}, {"key": "m5", "cardId": "165", "prompt": "器 (Bacaan Furigana)", "correct": "165", "options": [{"id": "281", "label": "さくら"}, {"id": "165", "label": "うつわ"}, {"id": "203", "label": "あく"}, {"id": "169", "label": "おく"}]}, {"key": "m6", "cardId": "166", "prompt": "腕", "correct": "166", "options": [{"id": "166", "label": "lengan"}, {"id": "264", "label": "kuning"}, {"id": "179", "label": "sejak; setelah"}, {"id": "239", "label": "berbahaya"}]}, {"key": "m7", "cardId": "167", "prompt": "絵", "correct": "167", "options": [{"id": "307", "label": "kebakaran"}, {"id": "209", "label": "mengungkapkan; menyatakan"}, {"id": "318", "label": "memukul; mengetik"}, {"id": "167", "label": "gambar; lukisan"}]}, {"key": "m8", "cardId": "168", "prompt": "枝 (Bacaan Furigana)", "correct": "168", "options": [{"id": "236", "label": "かつどうてきな"}, {"id": "298", "label": "かいぎ"}, {"id": "168", "label": "えだ"}, {"id": "161", "label": "いと"}]}, {"key": "m9", "cardId": "169", "prompt": "奥 (Bacaan Furigana)", "correct": "169", "options": [{"id": "188", "label": "いんさつ"}, {"id": "310", "label": "かんきょう"}, {"id": "169", "label": "おく"}, {"id": "186", "label": "いま"}]}, {"key": "m10", "cardId": "170", "prompt": "音", "correct": "170", "options": [{"id": "265", "label": "permukaan; depan"}, {"id": "170", "label": "bunyi; suara"}, {"id": "301", "label": "tangga"}, {"id": "297", "label": "suhu"}]}], "typing": [{"key": "t1", "cardId": "161", "prompt": "benang", "answerKanji": "糸", "answerFurigana": "いと"}, {"key": "t2", "cardId": "162", "prompt": "umbi; kentang", "answerKanji": "芋", "answerFurigana": "いも"}, {"key": "t3", "cardId": "163", "prompt": "lagu", "answerKanji": "歌", "answerFurigana": "うた"}, {"key": "t4", "cardId": "164", "prompt": "bagian dalam", "answerKanji": "内", "answerFurigana": "うち"}, {"key": "t5", "cardId": "165", "prompt": "wadah; mangkuk", "answerKanji": "器", "answerFurigana": "うつわ"}, {"key": "t6", "cardId": "166", "prompt": "lengan", "answerKanji": "腕", "answerFurigana": "うで"}, {"key": "t7", "cardId": "167", "prompt": "gambar; lukisan", "answerKanji": "絵", "answerFurigana": "え"}, {"key": "t8", "cardId": "168", "prompt": "ranting; cabang pohon", "answerKanji": "枝", "answerFurigana": "えだ"}, {"key": "t9", "cardId": "169", "prompt": "bagian dalam; belakang", "answerKanji": "奥", "answerFurigana": "おく"}, {"key": "t10", "cardId": "170", "prompt": "bunyi; suara", "answerKanji": "音", "answerFurigana": "おと"}], "matching": [{"key": "p1", "label": "benang", "round": 0, "token": "2ad823bd3e9690b3", "cardId": "161", "prompt": "糸", "correct": "2ad823bd3e9690b3", "furigana": "いと"}, {"key": "p2", "label": "umbi; kentang", "round": 0, "token": "7367837ddb91c569", "cardId": "162", "prompt": "芋", "correct": "7367837ddb91c569", "furigana": "いも"}, {"key": "p3", "label": "lagu", "round": 0, "token": "0daa4cb3a394224a", "cardId": "163", "prompt": "歌", "correct": "0daa4cb3a394224a", "furigana": "うた"}, {"key": "p4", "label": "bagian dalam", "round": 0, "token": "c4dd95ee9b011af4", "cardId": "164", "prompt": "内", "correct": "c4dd95ee9b011af4", "furigana": "うち"}, {"key": "p5", "label": "wadah; mangkuk", "round": 0, "token": "bd72d1cbac84b628", "cardId": "165", "prompt": "器", "correct": "bd72d1cbac84b628", "furigana": "うつわ"}, {"key": "p6", "label": "lengan", "round": 1, "token": "7023ecbf1b879d6f", "cardId": "166", "prompt": "腕", "correct": "7023ecbf1b879d6f", "furigana": "うで"}, {"key": "p7", "label": "gambar; lukisan", "round": 1, "token": "d21b6c8270cfe8b1", "cardId": "167", "prompt": "絵", "correct": "d21b6c8270cfe8b1", "furigana": "え"}, {"key": "p8", "label": "ranting; cabang pohon", "round": 1, "token": "5a1e4de9c8f7327b", "cardId": "168", "prompt": "枝", "correct": "5a1e4de9c8f7327b", "furigana": "えだ"}, {"key": "p9", "label": "bagian dalam; belakang", "round": 1, "token": "f72f6bf3550eca8d", "cardId": "169", "prompt": "奥", "correct": "f72f6bf3550eca8d", "furigana": "おく"}, {"key": "p10", "label": "bunyi; suara", "round": 1, "token": "777aa085008be6ca", "cardId": "170", "prompt": "音", "correct": "777aa085008be6ca", "furigana": "おと"}]}	2026-10-13 09:32:48.716701+00	\N
727e615a-e453-4ddf-ba00-cf35d1753baf	591eeb16-4f2a-4681-ae0d-a418d0d5f264	matching	{"mc": [{"key": "m1", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "correct": "161", "options": [{"id": "322", "label": "おくる"}, {"id": "170", "label": "おと"}, {"id": "161", "label": "いと"}, {"id": "335", "label": "うらやましい"}], "furigana": "いと"}, {"key": "m2", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "correct": "162", "options": [{"id": "285", "label": "いぜん"}, {"id": "157", "label": "い"}, {"id": "162", "label": "いも"}, {"id": "327", "label": "おとす"}], "furigana": "いも"}, {"key": "m3", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "correct": "163", "options": [{"id": "360", "label": "さきに"}, {"id": "163", "label": "うた"}, {"id": "320", "label": "うめる"}, {"id": "236", "label": "かつどうてきな"}], "furigana": "うた"}, {"key": "m4", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "correct": "164", "options": [{"id": "304", "label": "かぐ"}, {"id": "164", "label": "うち"}, {"id": "325", "label": "おす"}, {"id": "317", "label": "うたがう"}], "furigana": "うち"}, {"key": "m5", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "correct": "165", "options": [{"id": "203", "label": "あく"}, {"id": "213", "label": "かざる"}, {"id": "289", "label": "うんてん"}, {"id": "165", "label": "うつわ"}], "furigana": "うつわ"}, {"key": "m6", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "correct": "166", "options": [{"id": "304", "label": "かぐ"}, {"id": "338", "label": "えらい"}, {"id": "166", "label": "うで"}, {"id": "161", "label": "いと"}], "furigana": "うで"}, {"key": "m7", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "correct": "167", "options": [{"id": "189", "label": "いんしょう"}, {"id": "167", "label": "え"}, {"id": "306", "label": "かこ"}, {"id": "265", "label": "おもて"}], "furigana": "え"}, {"key": "m8", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "correct": "168", "options": [{"id": "160", "label": "いけ"}, {"id": "301", "label": "かいだん"}, {"id": "225", "label": "あつい"}, {"id": "168", "label": "えだ"}], "furigana": "えだ"}, {"key": "m9", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "correct": "169", "options": [{"id": "337", "label": "うれしい"}, {"id": "284", "label": "いじょう"}, {"id": "302", "label": "かかく"}, {"id": "169", "label": "おく"}], "furigana": "おく"}, {"key": "m10", "arti": "bunyi; suara", "kanji": "音", "cardId": "170", "prompt": "音", "correct": "170", "options": [{"id": "327", "label": "おとす"}, {"id": "179", "label": "いこう"}, {"id": "170", "label": "おと"}, {"id": "299", "label": "かいけつ"}], "furigana": "おと"}], "typing": [{"key": "t1", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "furigana": "いと", "answerKanji": "糸", "answerFurigana": "いと"}, {"key": "t2", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "furigana": "いも", "answerKanji": "芋", "answerFurigana": "いも"}, {"key": "t3", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "furigana": "うた", "answerKanji": "歌", "answerFurigana": "うた"}, {"key": "t4", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "furigana": "うち", "answerKanji": "内", "answerFurigana": "うち"}, {"key": "t5", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "furigana": "うつわ", "answerKanji": "器", "answerFurigana": "うつわ"}, {"key": "t6", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "furigana": "うで", "answerKanji": "腕", "answerFurigana": "うで"}, {"key": "t7", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "furigana": "え", "answerKanji": "絵", "answerFurigana": "え"}, {"key": "t8", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "furigana": "えだ", "answerKanji": "枝", "answerFurigana": "えだ"}, {"key": "t9", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "furigana": "おく", "answerKanji": "奥", "answerFurigana": "おく"}, {"key": "t10", "arti": "bunyi; suara", "kanji": "音", "cardId": "170", "prompt": "音", "furigana": "おと", "answerKanji": "音", "answerFurigana": "おと"}], "matching": [{"key": "p1", "arti": "benang", "kanji": "糸", "label": "いと", "round": 0, "token": "ab6a96055a7a880c", "cardId": "161", "prompt": "糸", "correct": "ab6a96055a7a880c", "furigana": "いと"}, {"key": "p2", "arti": "umbi; kentang", "kanji": "芋", "label": "いも", "round": 0, "token": "5c9312084aa786a4", "cardId": "162", "prompt": "芋", "correct": "5c9312084aa786a4", "furigana": "いも"}, {"key": "p3", "arti": "lagu", "kanji": "歌", "label": "うた", "round": 0, "token": "7eac3c6ce256e144", "cardId": "163", "prompt": "歌", "correct": "7eac3c6ce256e144", "furigana": "うた"}, {"key": "p4", "arti": "bagian dalam", "kanji": "内", "label": "うち", "round": 0, "token": "e0070a4cfafbc4a6", "cardId": "164", "prompt": "内", "correct": "e0070a4cfafbc4a6", "furigana": "うち"}, {"key": "p5", "arti": "wadah; mangkuk", "kanji": "器", "label": "うつわ", "round": 0, "token": "4fae000d0d159b5d", "cardId": "165", "prompt": "器", "correct": "4fae000d0d159b5d", "furigana": "うつわ"}, {"key": "p6", "arti": "lengan", "kanji": "腕", "label": "うで", "round": 1, "token": "858a2b0371e00d17", "cardId": "166", "prompt": "腕", "correct": "858a2b0371e00d17", "furigana": "うで"}, {"key": "p7", "arti": "gambar; lukisan", "kanji": "絵", "label": "え", "round": 1, "token": "9ceeffeea303bf9e", "cardId": "167", "prompt": "絵", "correct": "9ceeffeea303bf9e", "furigana": "え"}, {"key": "p8", "arti": "ranting; cabang pohon", "kanji": "枝", "label": "えだ", "round": 1, "token": "0c27072f232c57f8", "cardId": "168", "prompt": "枝", "correct": "0c27072f232c57f8", "furigana": "えだ"}, {"key": "p9", "arti": "bagian dalam; belakang", "kanji": "奥", "label": "おく", "round": 1, "token": "db9369c260efb795", "cardId": "169", "prompt": "奥", "correct": "db9369c260efb795", "furigana": "おく"}, {"key": "p10", "arti": "bunyi; suara", "kanji": "音", "label": "おと", "round": 1, "token": "137911d6488bf41d", "cardId": "170", "prompt": "音", "correct": "137911d6488bf41d", "furigana": "おと"}]}	2026-10-13 11:58:43.022202+00	\N
8273b687-b156-442a-8833-e14ebd9974d9	b7fb903d-d960-449c-9147-b67233808680	done	{"mc": [{"key": "m1", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "correct": "161", "options": [{"id": "213", "label": "かざる"}, {"id": "161", "label": "いと"}, {"id": "220", "label": "かわる"}, {"id": "243", "label": "いちどに"}], "furigana": "いと"}, {"key": "m2", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "correct": "162", "options": [{"id": "269", "label": "かさ"}, {"id": "300", "label": "かいさつ"}, {"id": "162", "label": "いも"}, {"id": "170", "label": "おと"}], "furigana": "いも"}, {"key": "m3", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "correct": "163", "options": [{"id": "163", "label": "うた"}, {"id": "172", "label": "あいて"}, {"id": "356", "label": "かなり"}, {"id": "360", "label": "さきに"}], "furigana": "うた"}, {"key": "m4", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "correct": "164", "options": [{"id": "349", "label": "さかんな"}, {"id": "273", "label": "くび"}, {"id": "164", "label": "うち"}, {"id": "155", "label": "あぶら"}], "furigana": "うち"}, {"key": "m5", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "correct": "165", "options": [{"id": "215", "label": "かせぐ"}, {"id": "165", "label": "うつわ"}, {"id": "353", "label": "いくらでも"}, {"id": "190", "label": "いんしょく"}], "furigana": "うつわ"}, {"key": "m6", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "correct": "166", "options": [{"id": "228", "label": "あぶない"}, {"id": "191", "label": "えいきょう"}, {"id": "166", "label": "うで"}, {"id": "340", "label": "おかしい"}], "furigana": "うで"}, {"key": "m7", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "correct": "167", "options": [{"id": "167", "label": "え"}, {"id": "355", "label": "いっぱい"}, {"id": "360", "label": "さきに"}, {"id": "203", "label": "あく"}], "furigana": "え"}, {"key": "m8", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "correct": "168", "options": [{"id": "242", "label": "いちおう"}, {"id": "168", "label": "えだ"}, {"id": "267", "label": "かい"}, {"id": "197", "label": "えんそう"}], "furigana": "えだ"}, {"key": "m9", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "correct": "169", "options": [{"id": "226", "label": "あつい"}, {"id": "169", "label": "おく"}, {"id": "248", "label": "けっきょく"}, {"id": "269", "label": "かさ"}], "furigana": "おく"}, {"key": "m10", "arti": "bunyi; suara", "kanji": "音", "cardId": "170", "prompt": "音", "correct": "170", "options": [{"id": "225", "label": "あつい"}, {"id": "210", "label": "あわてる"}, {"id": "170", "label": "おと"}, {"id": "358", "label": "きっと"}], "furigana": "おと"}], "typing": [{"key": "t1", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "furigana": "いと", "answerKanji": "糸", "answerFurigana": "いと"}, {"key": "t2", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "furigana": "いも", "answerKanji": "芋", "answerFurigana": "いも"}, {"key": "t3", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "furigana": "うた", "answerKanji": "歌", "answerFurigana": "うた"}, {"key": "t4", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "furigana": "うち", "answerKanji": "内", "answerFurigana": "うち"}, {"key": "t5", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "furigana": "うつわ", "answerKanji": "器", "answerFurigana": "うつわ"}, {"key": "t6", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "furigana": "うで", "answerKanji": "腕", "answerFurigana": "うで"}, {"key": "t7", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "furigana": "え", "answerKanji": "絵", "answerFurigana": "え"}, {"key": "t8", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "furigana": "えだ", "answerKanji": "枝", "answerFurigana": "えだ"}, {"key": "t9", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "furigana": "おく", "answerKanji": "奥", "answerFurigana": "おく"}, {"key": "t10", "arti": "bunyi; suara", "kanji": "音", "cardId": "170", "prompt": "音", "furigana": "おと", "answerKanji": "音", "answerFurigana": "おと"}], "matching": [{"key": "p1", "arti": "benang", "kanji": "糸", "label": "いと", "round": 0, "token": "1fbe7f17bb2c8af3", "cardId": "161", "prompt": "糸", "correct": "1fbe7f17bb2c8af3", "furigana": "いと"}, {"key": "p2", "arti": "umbi; kentang", "kanji": "芋", "label": "いも", "round": 0, "token": "a2580ee098bf7709", "cardId": "162", "prompt": "芋", "correct": "a2580ee098bf7709", "furigana": "いも"}, {"key": "p3", "arti": "lagu", "kanji": "歌", "label": "うた", "round": 0, "token": "f920fac9d2a2abc1", "cardId": "163", "prompt": "歌", "correct": "f920fac9d2a2abc1", "furigana": "うた"}, {"key": "p4", "arti": "bagian dalam", "kanji": "内", "label": "うち", "round": 0, "token": "cb0c45c6a8ce52bc", "cardId": "164", "prompt": "内", "correct": "cb0c45c6a8ce52bc", "furigana": "うち"}, {"key": "p5", "arti": "wadah; mangkuk", "kanji": "器", "label": "うつわ", "round": 0, "token": "1c133754f8846ac1", "cardId": "165", "prompt": "器", "correct": "1c133754f8846ac1", "furigana": "うつわ"}, {"key": "p6", "arti": "lengan", "kanji": "腕", "label": "うで", "round": 1, "token": "c2843b3d1d68e073", "cardId": "166", "prompt": "腕", "correct": "c2843b3d1d68e073", "furigana": "うで"}, {"key": "p7", "arti": "gambar; lukisan", "kanji": "絵", "label": "え", "round": 1, "token": "75c1d52e82022aff", "cardId": "167", "prompt": "絵", "correct": "75c1d52e82022aff", "furigana": "え"}, {"key": "p8", "arti": "ranting; cabang pohon", "kanji": "枝", "label": "えだ", "round": 1, "token": "0e6fe24e314ae5c9", "cardId": "168", "prompt": "枝", "correct": "0e6fe24e314ae5c9", "furigana": "えだ"}, {"key": "p9", "arti": "bagian dalam; belakang", "kanji": "奥", "label": "おく", "round": 1, "token": "50cc235230493f21", "cardId": "169", "prompt": "奥", "correct": "50cc235230493f21", "furigana": "おく"}, {"key": "p10", "arti": "bunyi; suara", "kanji": "音", "label": "おと", "round": 1, "token": "d0c0edd8c96f1b2d", "cardId": "170", "prompt": "音", "correct": "d0c0edd8c96f1b2d", "furigana": "おと"}]}	2026-10-13 12:02:08.64486+00	2026-10-13 12:06:16.056811+00
d0a14f66-757b-4ea0-b26c-0a71826512b8	225e59f2-ffa1-49ea-8942-481123901337	done	{"mc": [{"key": "m1", "arti": "antara; selama", "kanji": "間", "cardId": "151", "prompt": "間", "correct": "151", "options": [{"id": "237", "label": "かのうな"}, {"id": "323", "label": "おくれる"}, {"id": "264", "label": "き"}, {"id": "151", "label": "あいだ"}], "furigana": "あいだ"}, {"key": "m2", "arti": "biru", "kanji": "青", "cardId": "152", "prompt": "青", "correct": "152", "options": [{"id": "152", "label": "あお"}, {"id": "350", "label": "さまざまな"}, {"id": "296", "label": "おんせん"}, {"id": "169", "label": "おく"}], "furigana": "あお"}, {"key": "m3", "arti": "rasa", "kanji": "味", "cardId": "153", "prompt": "味", "correct": "153", "options": [{"id": "153", "label": "あじ"}, {"id": "197", "label": "えんそう"}, {"id": "220", "label": "かわる"}, {"id": "160", "label": "いけ"}], "furigana": "あじ"}, {"key": "m4", "arti": "lubang", "kanji": "穴", "cardId": "154", "prompt": "穴", "correct": "154", "options": [{"id": "243", "label": "いちどに"}, {"id": "233", "label": "いっぱんてきな"}, {"id": "154", "label": "あな"}, {"id": "340", "label": "おかしい"}], "furigana": "あな"}, {"key": "m5", "arti": "minyak", "kanji": "油", "cardId": "155", "prompt": "油", "correct": "155", "options": [{"id": "282", "label": "いしき"}, {"id": "304", "label": "かぐ"}, {"id": "245", "label": "おもに"}, {"id": "155", "label": "あぶら"}], "furigana": "あぶら"}, {"key": "m6", "arti": "usulan; ide", "kanji": "案", "cardId": "156", "prompt": "案", "correct": "156", "options": [{"id": "301", "label": "かいだん"}, {"id": "227", "label": "あつい"}, {"id": "296", "label": "おんせん"}, {"id": "156", "label": "あん"}], "furigana": "あん"}, {"key": "m7", "arti": "lambung", "kanji": "胃", "cardId": "157", "prompt": "胃", "correct": "157", "options": [{"id": "242", "label": "いちおう"}, {"id": "293", "label": "おうぼ"}, {"id": "157", "label": "い"}, {"id": "196", "label": "えんき"}], "furigana": "い"}, {"key": "m8", "arti": "rumah", "kanji": "家", "cardId": "158", "prompt": "家", "correct": "158", "options": [{"id": "199", "label": "おうえん"}, {"id": "353", "label": "いくらでも"}, {"id": "158", "label": "いえ"}, {"id": "273", "label": "くび"}], "furigana": "いえ"}, {"key": "m9", "arti": "napas", "kanji": "息", "cardId": "159", "prompt": "息", "correct": "159", "options": [{"id": "159", "label": "いき"}, {"id": "266", "label": "おや"}, {"id": "186", "label": "いま"}, {"id": "339", "label": "おいしい"}], "furigana": "いき"}, {"key": "m10", "arti": "kolam", "kanji": "池", "cardId": "160", "prompt": "池", "correct": "160", "options": [{"id": "160", "label": "いけ"}, {"id": "354", "label": "いつでも"}, {"id": "276", "label": "けん"}, {"id": "346", "label": "げんきな"}], "furigana": "いけ"}], "typing": [{"key": "t1", "arti": "antara; selama", "kanji": "間", "cardId": "151", "prompt": "間", "furigana": "あいだ", "answerKanji": "間", "answerFurigana": "あいだ"}, {"key": "t2", "arti": "biru", "kanji": "青", "cardId": "152", "prompt": "青", "furigana": "あお", "answerKanji": "青", "answerFurigana": "あお"}, {"key": "t3", "arti": "rasa", "kanji": "味", "cardId": "153", "prompt": "味", "furigana": "あじ", "answerKanji": "味", "answerFurigana": "あじ"}, {"key": "t4", "arti": "lubang", "kanji": "穴", "cardId": "154", "prompt": "穴", "furigana": "あな", "answerKanji": "穴", "answerFurigana": "あな"}, {"key": "t5", "arti": "minyak", "kanji": "油", "cardId": "155", "prompt": "油", "furigana": "あぶら", "answerKanji": "油", "answerFurigana": "あぶら"}, {"key": "t6", "arti": "usulan; ide", "kanji": "案", "cardId": "156", "prompt": "案", "furigana": "あん", "answerKanji": "案", "answerFurigana": "あん"}, {"key": "t7", "arti": "lambung", "kanji": "胃", "cardId": "157", "prompt": "胃", "furigana": "い", "answerKanji": "胃", "answerFurigana": "い"}, {"key": "t8", "arti": "rumah", "kanji": "家", "cardId": "158", "prompt": "家", "furigana": "いえ", "answerKanji": "家", "answerFurigana": "いえ"}, {"key": "t9", "arti": "napas", "kanji": "息", "cardId": "159", "prompt": "息", "furigana": "いき", "answerKanji": "息", "answerFurigana": "いき"}, {"key": "t10", "arti": "kolam", "kanji": "池", "cardId": "160", "prompt": "池", "furigana": "いけ", "answerKanji": "池", "answerFurigana": "いけ"}], "matching": [{"key": "p1", "arti": "antara; selama", "kanji": "間", "label": "あいだ", "round": 0, "token": "d16add5dc51783dc", "cardId": "151", "prompt": "間", "correct": "d16add5dc51783dc", "furigana": "あいだ"}, {"key": "p2", "arti": "biru", "kanji": "青", "label": "あお", "round": 0, "token": "ff611319d6df64e9", "cardId": "152", "prompt": "青", "correct": "ff611319d6df64e9", "furigana": "あお"}, {"key": "p3", "arti": "rasa", "kanji": "味", "label": "あじ", "round": 0, "token": "0a4b3d2aaf469cd1", "cardId": "153", "prompt": "味", "correct": "0a4b3d2aaf469cd1", "furigana": "あじ"}, {"key": "p4", "arti": "lubang", "kanji": "穴", "label": "あな", "round": 0, "token": "53de35c5a31d389a", "cardId": "154", "prompt": "穴", "correct": "53de35c5a31d389a", "furigana": "あな"}, {"key": "p5", "arti": "minyak", "kanji": "油", "label": "あぶら", "round": 0, "token": "17180efc61aba922", "cardId": "155", "prompt": "油", "correct": "17180efc61aba922", "furigana": "あぶら"}, {"key": "p6", "arti": "usulan; ide", "kanji": "案", "label": "あん", "round": 1, "token": "371e7dcea06a00a2", "cardId": "156", "prompt": "案", "correct": "371e7dcea06a00a2", "furigana": "あん"}, {"key": "p7", "arti": "lambung", "kanji": "胃", "label": "い", "round": 1, "token": "2dbf87cb28d71fbd", "cardId": "157", "prompt": "胃", "correct": "2dbf87cb28d71fbd", "furigana": "い"}, {"key": "p8", "arti": "rumah", "kanji": "家", "label": "いえ", "round": 1, "token": "928e902129426ff7", "cardId": "158", "prompt": "家", "correct": "928e902129426ff7", "furigana": "いえ"}, {"key": "p9", "arti": "napas", "kanji": "息", "label": "いき", "round": 1, "token": "65ca11bcc74e7b95", "cardId": "159", "prompt": "息", "correct": "65ca11bcc74e7b95", "furigana": "いき"}, {"key": "p10", "arti": "kolam", "kanji": "池", "label": "いけ", "round": 1, "token": "df04a7a535bdd3a5", "cardId": "160", "prompt": "池", "correct": "df04a7a535bdd3a5", "furigana": "いけ"}]}	2026-10-16 04:00:50.027645+00	2026-10-16 04:02:27.041618+00
81785e68-1ebf-418f-952d-c0fb6c78f634	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	done	{"mc": [{"key": "m1", "arti": "tempat parkir", "kanji": "駐車場", "cardId": "362", "prompt": "駐車場", "correct": "362", "options": [{"id": "372", "label": "むきゅう"}, {"id": "362", "label": "ちゅうしゃじょう"}, {"id": "384", "label": "おさえる"}, {"id": "403", "label": "たしかな"}], "furigana": "ちゅうしゃじょう"}, {"key": "m2", "arti": "parkir", "kanji": "駐車", "cardId": "363", "prompt": "駐車", "correct": "363", "options": [{"id": "381", "label": "よこ"}, {"id": "368", "label": "ひこうじょう"}, {"id": "363", "label": "ちゅうしゃ"}, {"id": "367", "label": "ふまんな"}], "furigana": "ちゅうしゃ"}, {"key": "m3", "arti": "parkir penuh", "kanji": "満車", "cardId": "364", "prompt": "満車", "correct": "364", "options": [{"id": "396", "label": "そうしん"}, {"id": "364", "label": "まんしゃ"}, {"id": "393", "label": "しんじる"}, {"id": "384", "label": "おさえる"}], "furigana": "まんしゃ"}, {"key": "m4", "arti": "gerbong nomor ~", "kanji": "号車", "cardId": "365", "prompt": "号車", "correct": "365", "options": [{"id": "400", "label": "かかり"}, {"id": "406", "label": "みとめる"}, {"id": "365", "label": "ごうしゃ"}, {"id": "407", "label": "ひじょう"}], "furigana": "ごうしゃ"}, {"key": "m5", "arti": "penuh orang", "kanji": "満員", "cardId": "366", "prompt": "満員", "correct": "366", "options": [{"id": "367", "label": "ふまんな"}, {"id": "380", "label": "おうだんほどう"}, {"id": "384", "label": "おさえる"}, {"id": "366", "label": "まんいん"}], "furigana": "まんいん"}, {"key": "m6", "arti": "tidak puas", "kanji": "不満な", "cardId": "367", "prompt": "不満な", "correct": "367", "options": [{"id": "411", "label": "せいじょうな"}, {"id": "369", "label": "とぶ"}, {"id": "389", "label": "むかう"}, {"id": "367", "label": "ふまんな"}], "furigana": "ふまんな"}, {"key": "m7", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "cardId": "368", "prompt": "飛行場", "correct": "368", "options": [{"id": "368", "label": "ひこうじょう"}, {"id": "409", "label": "ひじょうに"}, {"id": "404", "label": "たしかめる"}, {"id": "407", "label": "ひじょう"}], "furigana": "ひこうじょう"}, {"key": "m8", "arti": "terbang", "kanji": "飛ぶ", "cardId": "369", "prompt": "飛ぶ", "correct": "369", "options": [{"id": "369", "label": "とぶ"}, {"id": "381", "label": "よこ"}, {"id": "406", "label": "みとめる"}, {"id": "373", "label": "むりょう"}], "furigana": "とぶ"}, {"key": "m9", "arti": "lantai", "kanji": "階", "cardId": "370", "prompt": "階", "correct": "370", "options": [{"id": "379", "label": "おうだん"}, {"id": "381", "label": "よこ"}, {"id": "370", "label": "かい"}, {"id": "399", "label": "かんけい"}], "furigana": "かい"}, {"key": "m10", "arti": "tangga", "kanji": "階段", "cardId": "371", "prompt": "階段", "correct": "371", "options": [{"id": "406", "label": "みとめる"}, {"id": "396", "label": "そうしん"}, {"id": "381", "label": "よこ"}, {"id": "371", "label": "かいだん"}], "furigana": "かいだん"}], "typing": [{"key": "t1", "arti": "tempat parkir", "kanji": "駐車場", "cardId": "362", "prompt": "駐車場", "furigana": "ちゅうしゃじょう", "answerKanji": "駐車場", "answerFurigana": "ちゅうしゃじょう"}, {"key": "t2", "arti": "parkir", "kanji": "駐車", "cardId": "363", "prompt": "駐車", "furigana": "ちゅうしゃ", "answerKanji": "駐車", "answerFurigana": "ちゅうしゃ"}, {"key": "t3", "arti": "parkir penuh", "kanji": "満車", "cardId": "364", "prompt": "満車", "furigana": "まんしゃ", "answerKanji": "満車", "answerFurigana": "まんしゃ"}, {"key": "t4", "arti": "gerbong nomor ~", "kanji": "号車", "cardId": "365", "prompt": "号車", "furigana": "ごうしゃ", "answerKanji": "号車", "answerFurigana": "ごうしゃ"}, {"key": "t5", "arti": "penuh orang", "kanji": "満員", "cardId": "366", "prompt": "満員", "furigana": "まんいん", "answerKanji": "満員", "answerFurigana": "まんいん"}, {"key": "t6", "arti": "tidak puas", "kanji": "不満な", "cardId": "367", "prompt": "不満な", "furigana": "ふまんな", "answerKanji": "不満な", "answerFurigana": "ふまんな"}, {"key": "t7", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "cardId": "368", "prompt": "飛行場", "furigana": "ひこうじょう", "answerKanji": "飛行場", "answerFurigana": "ひこうじょう"}, {"key": "t8", "arti": "terbang", "kanji": "飛ぶ", "cardId": "369", "prompt": "飛ぶ", "furigana": "とぶ", "answerKanji": "飛ぶ", "answerFurigana": "とぶ"}, {"key": "t9", "arti": "lantai", "kanji": "階", "cardId": "370", "prompt": "階", "furigana": "かい", "answerKanji": "階", "answerFurigana": "かい"}, {"key": "t10", "arti": "tangga", "kanji": "階段", "cardId": "371", "prompt": "階段", "furigana": "かいだん", "answerKanji": "階段", "answerFurigana": "かいだん"}], "matching": [{"key": "p1", "arti": "tempat parkir", "kanji": "駐車場", "label": "ちゅうしゃじょう", "round": 0, "token": "0d3929b3effd347d", "cardId": "362", "prompt": "駐車場", "correct": "0d3929b3effd347d", "furigana": "ちゅうしゃじょう"}, {"key": "p2", "arti": "parkir", "kanji": "駐車", "label": "ちゅうしゃ", "round": 0, "token": "819ba09408ab1b94", "cardId": "363", "prompt": "駐車", "correct": "819ba09408ab1b94", "furigana": "ちゅうしゃ"}, {"key": "p3", "arti": "parkir penuh", "kanji": "満車", "label": "まんしゃ", "round": 0, "token": "3affb20342fe0040", "cardId": "364", "prompt": "満車", "correct": "3affb20342fe0040", "furigana": "まんしゃ"}, {"key": "p4", "arti": "gerbong nomor ~", "kanji": "号車", "label": "ごうしゃ", "round": 0, "token": "95919ab7a228223d", "cardId": "365", "prompt": "号車", "correct": "95919ab7a228223d", "furigana": "ごうしゃ"}, {"key": "p5", "arti": "penuh orang", "kanji": "満員", "label": "まんいん", "round": 0, "token": "675ba12d7fd9fd5a", "cardId": "366", "prompt": "満員", "correct": "675ba12d7fd9fd5a", "furigana": "まんいん"}, {"key": "p6", "arti": "tidak puas", "kanji": "不満な", "label": "ふまんな", "round": 1, "token": "67c8bd84535d7478", "cardId": "367", "prompt": "不満な", "correct": "67c8bd84535d7478", "furigana": "ふまんな"}, {"key": "p7", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "label": "ひこうじょう", "round": 1, "token": "1f50fb77899949f8", "cardId": "368", "prompt": "飛行場", "correct": "1f50fb77899949f8", "furigana": "ひこうじょう"}, {"key": "p8", "arti": "terbang", "kanji": "飛ぶ", "label": "とぶ", "round": 1, "token": "00e491e85b82595b", "cardId": "369", "prompt": "飛ぶ", "correct": "00e491e85b82595b", "furigana": "とぶ"}, {"key": "p9", "arti": "lantai", "kanji": "階", "label": "かい", "round": 1, "token": "2c2d0e94832b3e5e", "cardId": "370", "prompt": "階", "correct": "2c2d0e94832b3e5e", "furigana": "かい"}, {"key": "p10", "arti": "tangga", "kanji": "階段", "label": "かいだん", "round": 1, "token": "a0a1728572808e73", "cardId": "371", "prompt": "階段", "correct": "a0a1728572808e73", "furigana": "かいだん"}]}	2026-10-16 04:06:26.731771+00	2026-10-16 04:08:36.594114+00
4be6596a-97ef-4b6d-9311-27de83cda7ab	ea03fa6b-5d25-41ac-9548-d9610018bbb3	done	{"mc": [{"key": "m1", "arti": "isyarat; tanda", "kanji": "合図", "cardId": "171", "prompt": "合図", "correct": "171", "options": [{"id": "218", "label": "かりる"}, {"id": "171", "label": "あいず"}, {"id": "328", "label": "おどる"}, {"id": "234", "label": "いやな"}], "furigana": "あいず"}, {"key": "m2", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "cardId": "172", "prompt": "相手", "correct": "172", "options": [{"id": "344", "label": "きらいな"}, {"id": "172", "label": "あいて"}, {"id": "311", "label": "かんけい"}, {"id": "171", "label": "あいず"}], "furigana": "あいて"}, {"key": "m3", "arti": "langit biru", "kanji": "青空", "cardId": "173", "prompt": "青空", "correct": "173", "options": [{"id": "209", "label": "あらわす"}, {"id": "191", "label": "えいきょう"}, {"id": "265", "label": "おもて"}, {"id": "173", "label": "あおぞら"}], "furigana": "あおぞら"}, {"key": "m4", "arti": "rasa lega; ketenangan", "kanji": "安心", "cardId": "174", "prompt": "安心", "correct": "174", "options": [{"id": "277", "label": "こし"}, {"id": "356", "label": "かなり"}, {"id": "323", "label": "おくれる"}, {"id": "174", "label": "あんしん"}], "furigana": "あんしん"}, {"key": "m5", "arti": "panduan; mengantar", "kanji": "案内", "cardId": "175", "prompt": "案内", "correct": "175", "options": [{"id": "175", "label": "あんない"}, {"id": "207", "label": "あたためる"}, {"id": "216", "label": "かたづける"}, {"id": "323", "label": "おくれる"}], "furigana": "あんない"}, {"key": "m6", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "cardId": "176", "prompt": "以下", "correct": "176", "options": [{"id": "176", "label": "いか"}, {"id": "265", "label": "おもて"}, {"id": "282", "label": "いしき"}, {"id": "316", "label": "うける"}], "furigana": "いか"}, {"key": "m7", "arti": "selain; kecuali", "kanji": "以外", "cardId": "177", "prompt": "以外", "correct": "177", "options": [{"id": "235", "label": "かくじつな"}, {"id": "177", "label": "いがい"}, {"id": "283", "label": "いしゃ"}, {"id": "344", "label": "きらいな"}], "furigana": "いがい"}, {"key": "m8", "arti": "pendapat", "kanji": "意見", "cardId": "178", "prompt": "意見", "correct": "178", "options": [{"id": "204", "label": "あける"}, {"id": "276", "label": "けん"}, {"id": "178", "label": "いけん"}, {"id": "294", "label": "おうよう"}], "furigana": "いけん"}, {"key": "m9", "arti": "sejak; setelah", "kanji": "以降", "cardId": "179", "prompt": "以降", "correct": "179", "options": [{"id": "175", "label": "あんない"}, {"id": "303", "label": "かがく"}, {"id": "179", "label": "いこう"}, {"id": "306", "label": "かこ"}], "furigana": "いこう"}, {"key": "m10", "arti": "mempertahankan; pemeliharaan", "kanji": "維持", "cardId": "180", "prompt": "維持", "correct": "180", "options": [{"id": "180", "label": "いじ"}, {"id": "238", "label": "かんたんな"}, {"id": "181", "label": "いっしょ"}, {"id": "162", "label": "いも"}], "furigana": "いじ"}], "typing": [{"key": "t1", "arti": "isyarat; tanda", "kanji": "合図", "cardId": "171", "prompt": "合図", "furigana": "あいず", "answerKanji": "合図", "answerFurigana": "あいず"}, {"key": "t2", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "cardId": "172", "prompt": "相手", "furigana": "あいて", "answerKanji": "相手", "answerFurigana": "あいて"}, {"key": "t3", "arti": "langit biru", "kanji": "青空", "cardId": "173", "prompt": "青空", "furigana": "あおぞら", "answerKanji": "青空", "answerFurigana": "あおぞら"}, {"key": "t4", "arti": "rasa lega; ketenangan", "kanji": "安心", "cardId": "174", "prompt": "安心", "furigana": "あんしん", "answerKanji": "安心", "answerFurigana": "あんしん"}, {"key": "t5", "arti": "panduan; mengantar", "kanji": "案内", "cardId": "175", "prompt": "案内", "furigana": "あんない", "answerKanji": "案内", "answerFurigana": "あんない"}, {"key": "t6", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "cardId": "176", "prompt": "以下", "furigana": "いか", "answerKanji": "以下", "answerFurigana": "いか"}, {"key": "t7", "arti": "selain; kecuali", "kanji": "以外", "cardId": "177", "prompt": "以外", "furigana": "いがい", "answerKanji": "以外", "answerFurigana": "いがい"}, {"key": "t8", "arti": "pendapat", "kanji": "意見", "cardId": "178", "prompt": "意見", "furigana": "いけん", "answerKanji": "意見", "answerFurigana": "いけん"}, {"key": "t9", "arti": "sejak; setelah", "kanji": "以降", "cardId": "179", "prompt": "以降", "furigana": "いこう", "answerKanji": "以降", "answerFurigana": "いこう"}, {"key": "t10", "arti": "mempertahankan; pemeliharaan", "kanji": "維持", "cardId": "180", "prompt": "維持", "furigana": "いじ", "answerKanji": "維持", "answerFurigana": "いじ"}], "matching": [{"key": "p1", "arti": "isyarat; tanda", "kanji": "合図", "label": "あいず", "round": 0, "token": "7fb60fea2b0c709c", "cardId": "171", "prompt": "合図", "correct": "7fb60fea2b0c709c", "furigana": "あいず"}, {"key": "p2", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "label": "あいて", "round": 0, "token": "8fc0787a4d162977", "cardId": "172", "prompt": "相手", "correct": "8fc0787a4d162977", "furigana": "あいて"}, {"key": "p3", "arti": "langit biru", "kanji": "青空", "label": "あおぞら", "round": 0, "token": "6c330e4c4df08845", "cardId": "173", "prompt": "青空", "correct": "6c330e4c4df08845", "furigana": "あおぞら"}, {"key": "p4", "arti": "rasa lega; ketenangan", "kanji": "安心", "label": "あんしん", "round": 0, "token": "81c65b57519b2195", "cardId": "174", "prompt": "安心", "correct": "81c65b57519b2195", "furigana": "あんしん"}, {"key": "p5", "arti": "panduan; mengantar", "kanji": "案内", "label": "あんない", "round": 0, "token": "331e4ab2847e8055", "cardId": "175", "prompt": "案内", "correct": "331e4ab2847e8055", "furigana": "あんない"}, {"key": "p6", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "label": "いか", "round": 1, "token": "f07c547afedb55c0", "cardId": "176", "prompt": "以下", "correct": "f07c547afedb55c0", "furigana": "いか"}, {"key": "p7", "arti": "selain; kecuali", "kanji": "以外", "label": "いがい", "round": 1, "token": "4799a0fb11d05743", "cardId": "177", "prompt": "以外", "correct": "4799a0fb11d05743", "furigana": "いがい"}, {"key": "p8", "arti": "pendapat", "kanji": "意見", "label": "いけん", "round": 1, "token": "f45e2c2895d33a06", "cardId": "178", "prompt": "意見", "correct": "f45e2c2895d33a06", "furigana": "いけん"}, {"key": "p9", "arti": "sejak; setelah", "kanji": "以降", "label": "いこう", "round": 1, "token": "045b75038eef4ee6", "cardId": "179", "prompt": "以降", "correct": "045b75038eef4ee6", "furigana": "いこう"}, {"key": "p10", "arti": "mempertahankan; pemeliharaan", "kanji": "維持", "label": "いじ", "round": 1, "token": "3f5b2845c45c8594", "cardId": "180", "prompt": "維持", "correct": "3f5b2845c45c8594", "furigana": "いじ"}]}	2026-10-16 04:04:02.955475+00	2026-10-16 04:05:44.557376+00
5ea3ae86-b916-4e11-bef3-6c9bbe14daa8	9bc23800-737c-425d-b4a2-67681636e9d5	done	{"mc": [{"key": "m1", "arti": "bersama", "kanji": "一緒", "cardId": "181", "prompt": "一緒", "correct": "181", "options": [{"id": "181", "label": "いっしょ"}, {"id": "321", "label": "えがく"}, {"id": "316", "label": "うける"}, {"id": "195", "label": "えきまえ"}], "furigana": "いっしょ"}, {"key": "m2", "arti": "umum; masyarakat umum", "kanji": "一般", "cardId": "182", "prompt": "一般", "correct": "182", "options": [{"id": "224", "label": "あたらしい"}, {"id": "182", "label": "いっぱん"}, {"id": "159", "label": "いき"}, {"id": "324", "label": "おこなう"}], "furigana": "いっぱん"}, {"key": "m3", "arti": "perpindahan; bergerak", "kanji": "移動", "cardId": "183", "prompt": "移動", "correct": "183", "options": [{"id": "183", "label": "いどう"}, {"id": "326", "label": "おちる"}, {"id": "217", "label": "かつ"}, {"id": "321", "label": "えがく"}], "furigana": "いどう"}, {"key": "m4", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "cardId": "184", "prompt": "以内", "correct": "184", "options": [{"id": "198", "label": "えんりょ"}, {"id": "184", "label": "いない"}, {"id": "327", "label": "おとす"}, {"id": "225", "label": "あつい"}], "furigana": "いない"}, {"key": "m5", "arti": "desa; pedesaan", "kanji": "田舎", "cardId": "185", "prompt": "田舎", "correct": "185", "options": [{"id": "185", "label": "いなか"}, {"id": "159", "label": "いき"}, {"id": "214", "label": "かす"}, {"id": "302", "label": "かかく"}], "furigana": "いなか"}, {"key": "m6", "arti": "ruang keluarga", "kanji": "居間", "cardId": "186", "prompt": "居間", "correct": "186", "options": [{"id": "242", "label": "いちおう"}, {"id": "351", "label": "ざんねんな"}, {"id": "186", "label": "いま"}, {"id": "329", "label": "おどろく"}], "furigana": "いま"}, {"key": "m7", "arti": "arti; makna", "kanji": "意味", "cardId": "187", "prompt": "意味", "correct": "187", "options": [{"id": "203", "label": "あく"}, {"id": "324", "label": "おこなう"}, {"id": "230", "label": "うつくしい"}, {"id": "187", "label": "いみ"}], "furigana": "いみ"}, {"key": "m8", "arti": "mencetak; pencetakan", "kanji": "印刷", "cardId": "188", "prompt": "印刷", "correct": "188", "options": [{"id": "277", "label": "こし"}, {"id": "182", "label": "いっぱん"}, {"id": "311", "label": "かんけい"}, {"id": "188", "label": "いんさつ"}], "furigana": "いんさつ"}, {"key": "m9", "arti": "kesan", "kanji": "印象", "cardId": "189", "prompt": "印象", "correct": "189", "options": [{"id": "309", "label": "かつどう"}, {"id": "249", "label": "けっして"}, {"id": "189", "label": "いんしょう"}, {"id": "212", "label": "かくす"}], "furigana": "いんしょう"}, {"key": "m10", "arti": "makan dan minum", "kanji": "飲食", "cardId": "190", "prompt": "飲食", "correct": "190", "options": [{"id": "325", "label": "おす"}, {"id": "190", "label": "いんしょく"}, {"id": "359", "label": "けっこう"}, {"id": "332", "label": "いそがしい"}], "furigana": "いんしょく"}], "typing": [{"key": "t1", "arti": "bersama", "kanji": "一緒", "cardId": "181", "prompt": "一緒", "furigana": "いっしょ", "answerKanji": "一緒", "answerFurigana": "いっしょ"}, {"key": "t2", "arti": "umum; masyarakat umum", "kanji": "一般", "cardId": "182", "prompt": "一般", "furigana": "いっぱん", "answerKanji": "一般", "answerFurigana": "いっぱん"}, {"key": "t3", "arti": "perpindahan; bergerak", "kanji": "移動", "cardId": "183", "prompt": "移動", "furigana": "いどう", "answerKanji": "移動", "answerFurigana": "いどう"}, {"key": "t4", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "cardId": "184", "prompt": "以内", "furigana": "いない", "answerKanji": "以内", "answerFurigana": "いない"}, {"key": "t5", "arti": "desa; pedesaan", "kanji": "田舎", "cardId": "185", "prompt": "田舎", "furigana": "いなか", "answerKanji": "田舎", "answerFurigana": "いなか"}, {"key": "t6", "arti": "ruang keluarga", "kanji": "居間", "cardId": "186", "prompt": "居間", "furigana": "いま", "answerKanji": "居間", "answerFurigana": "いま"}, {"key": "t7", "arti": "arti; makna", "kanji": "意味", "cardId": "187", "prompt": "意味", "furigana": "いみ", "answerKanji": "意味", "answerFurigana": "いみ"}, {"key": "t8", "arti": "mencetak; pencetakan", "kanji": "印刷", "cardId": "188", "prompt": "印刷", "furigana": "いんさつ", "answerKanji": "印刷", "answerFurigana": "いんさつ"}, {"key": "t9", "arti": "kesan", "kanji": "印象", "cardId": "189", "prompt": "印象", "furigana": "いんしょう", "answerKanji": "印象", "answerFurigana": "いんしょう"}, {"key": "t10", "arti": "makan dan minum", "kanji": "飲食", "cardId": "190", "prompt": "飲食", "furigana": "いんしょく", "answerKanji": "飲食", "answerFurigana": "いんしょく"}], "matching": [{"key": "p1", "arti": "bersama", "kanji": "一緒", "label": "いっしょ", "round": 0, "token": "0555e723fd484824", "cardId": "181", "prompt": "一緒", "correct": "0555e723fd484824", "furigana": "いっしょ"}, {"key": "p2", "arti": "umum; masyarakat umum", "kanji": "一般", "label": "いっぱん", "round": 0, "token": "90a5af0d3491ed46", "cardId": "182", "prompt": "一般", "correct": "90a5af0d3491ed46", "furigana": "いっぱん"}, {"key": "p3", "arti": "perpindahan; bergerak", "kanji": "移動", "label": "いどう", "round": 0, "token": "0de78b78048fe656", "cardId": "183", "prompt": "移動", "correct": "0de78b78048fe656", "furigana": "いどう"}, {"key": "p4", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "label": "いない", "round": 0, "token": "254c7c8ac6d8ea7f", "cardId": "184", "prompt": "以内", "correct": "254c7c8ac6d8ea7f", "furigana": "いない"}, {"key": "p5", "arti": "desa; pedesaan", "kanji": "田舎", "label": "いなか", "round": 0, "token": "ba0b61248d64c346", "cardId": "185", "prompt": "田舎", "correct": "ba0b61248d64c346", "furigana": "いなか"}, {"key": "p6", "arti": "ruang keluarga", "kanji": "居間", "label": "いま", "round": 1, "token": "353c4e976db8e9bd", "cardId": "186", "prompt": "居間", "correct": "353c4e976db8e9bd", "furigana": "いま"}, {"key": "p7", "arti": "arti; makna", "kanji": "意味", "label": "いみ", "round": 1, "token": "a1ee5c4e74651c8d", "cardId": "187", "prompt": "意味", "correct": "a1ee5c4e74651c8d", "furigana": "いみ"}, {"key": "p8", "arti": "mencetak; pencetakan", "kanji": "印刷", "label": "いんさつ", "round": 1, "token": "f246f1c39e7a2ba8", "cardId": "188", "prompt": "印刷", "correct": "f246f1c39e7a2ba8", "furigana": "いんさつ"}, {"key": "p9", "arti": "kesan", "kanji": "印象", "label": "いんしょう", "round": 1, "token": "2691f0fcff552728", "cardId": "189", "prompt": "印象", "correct": "2691f0fcff552728", "furigana": "いんしょう"}, {"key": "p10", "arti": "makan dan minum", "kanji": "飲食", "label": "いんしょく", "round": 1, "token": "559230a539fa41f3", "cardId": "190", "prompt": "飲食", "correct": "559230a539fa41f3", "furigana": "いんしょく"}]}	2026-10-16 08:05:21.655147+00	2026-10-16 08:07:48.057347+00
ea1ee799-2d40-4383-aeff-cd4cae085afc	ea3fb395-52dc-465d-abd5-95fb969a2ed4	typing	{"mc": [{"key": "m1", "arti": "Memperkenalkan", "kanji": "ご紹介します", "cardId": "11", "prompt": "ご紹介します", "correct": "11", "options": [{"id": "34", "label": "けいこう"}, {"id": "15", "label": "えがく"}, {"id": "11", "label": "ごしょうかいします"}, {"id": "20", "label": "かち"}], "furigana": "ごしょうかいします"}, {"key": "m2", "arti": "Rencana/proyek", "kanji": "計画", "cardId": "12", "prompt": "計画", "correct": "12", "options": [{"id": "12", "label": "けいかく"}, {"id": "33", "label": "かんさつ"}, {"id": "26", "label": "うつる"}, {"id": "13", "label": "ざつがく"}], "furigana": "けいかく"}, {"key": "m3", "arti": "Pengetahuan/wawasan", "kanji": "雑学", "cardId": "13", "prompt": "雑学", "correct": "13", "options": [{"id": "13", "label": "ざつがく"}, {"id": "33", "label": "かんさつ"}, {"id": "18", "label": "きのう"}, {"id": "36", "label": "はっこう"}], "furigana": "ざつがく"}, {"key": "m4", "arti": "Keberadaan", "kanji": "存在", "cardId": "14", "prompt": "存在", "correct": "14", "options": [{"id": "25", "label": "とくちょう"}, {"id": "42", "label": "いんさつ"}, {"id": "14", "label": "そんざい"}, {"id": "2", "label": "こじんてきな"}], "furigana": "そんざい"}, {"key": "m5", "arti": "Menggambar", "kanji": "描く", "cardId": "15", "prompt": "描く", "correct": "15", "options": [{"id": "14", "label": "そんざい"}, {"id": "15", "label": "えがく"}, {"id": "32", "label": "いっぱんてきに"}, {"id": "18", "label": "きのう"}], "furigana": "えがく"}, {"key": "m6", "arti": "Karya/Ciptaan", "kanji": "作品", "cardId": "16", "prompt": "作品", "correct": "16", "options": [{"id": "35", "label": "とりあげる"}, {"id": "16", "label": "さくひん"}, {"id": "28", "label": "おとずれる"}, {"id": "8", "label": "しへい"}], "furigana": "さくひん"}, {"key": "m7", "arti": "Selanjutnya/Lain kali", "kanji": "次回", "cardId": "17", "prompt": "次回", "correct": "17", "options": [{"id": "17", "label": "じかい"}, {"id": "5", "label": "Periode/Musim"}, {"id": "4", "label": "つゆ"}, {"id": "31", "label": "ささげる"}], "furigana": "じかい"}, {"key": "m8", "arti": "Fungsi/Kemampuan", "kanji": "機能", "cardId": "18", "prompt": "機能", "correct": "18", "options": [{"id": "18", "label": "きのう"}, {"id": "41", "label": "せかいてき"}, {"id": "26", "label": "うつる"}, {"id": "12", "label": "けいかく"}], "furigana": "きのう"}, {"key": "m9", "arti": "Berkaitan/Terlibat/Berhubungan", "kanji": "関わる", "cardId": "19", "prompt": "関わる", "correct": "19", "options": [{"id": "5", "label": "Periode/Musim"}, {"id": "7", "label": "ろくおんしている"}, {"id": "19", "label": "かかわる"}, {"id": "8", "label": "しへい"}], "furigana": "かかわる"}, {"key": "m10", "arti": "Harga/Nilai/Manfaat", "kanji": "価値", "cardId": "20", "prompt": "価値", "correct": "20", "options": [{"id": "36", "label": "はっこう"}, {"id": "38", "label": "こうじょう"}, {"id": "20", "label": "かち"}, {"id": "14", "label": "そんざい"}], "furigana": "かち"}], "typing": [{"key": "t1", "arti": "Memperkenalkan", "kanji": "ご紹介します", "cardId": "11", "prompt": "ご紹介します", "furigana": "ごしょうかいします", "answerKanji": "ご紹介します", "answerFurigana": "ごしょうかいします"}, {"key": "t2", "arti": "Rencana/proyek", "kanji": "計画", "cardId": "12", "prompt": "計画", "furigana": "けいかく", "answerKanji": "計画", "answerFurigana": "けいかく"}, {"key": "t3", "arti": "Pengetahuan/wawasan", "kanji": "雑学", "cardId": "13", "prompt": "雑学", "furigana": "ざつがく", "answerKanji": "雑学", "answerFurigana": "ざつがく"}, {"key": "t4", "arti": "Keberadaan", "kanji": "存在", "cardId": "14", "prompt": "存在", "furigana": "そんざい", "answerKanji": "存在", "answerFurigana": "そんざい"}, {"key": "t5", "arti": "Menggambar", "kanji": "描く", "cardId": "15", "prompt": "描く", "furigana": "えがく", "answerKanji": "描く", "answerFurigana": "えがく"}, {"key": "t6", "arti": "Karya/Ciptaan", "kanji": "作品", "cardId": "16", "prompt": "作品", "furigana": "さくひん", "answerKanji": "作品", "answerFurigana": "さくひん"}, {"key": "t7", "arti": "Selanjutnya/Lain kali", "kanji": "次回", "cardId": "17", "prompt": "次回", "furigana": "じかい", "answerKanji": "次回", "answerFurigana": "じかい"}, {"key": "t8", "arti": "Fungsi/Kemampuan", "kanji": "機能", "cardId": "18", "prompt": "機能", "furigana": "きのう", "answerKanji": "機能", "answerFurigana": "きのう"}, {"key": "t9", "arti": "Berkaitan/Terlibat/Berhubungan", "kanji": "関わる", "cardId": "19", "prompt": "関わる", "furigana": "かかわる", "answerKanji": "関わる", "answerFurigana": "かかわる"}, {"key": "t10", "arti": "Harga/Nilai/Manfaat", "kanji": "価値", "cardId": "20", "prompt": "価値", "furigana": "かち", "answerKanji": "価値", "answerFurigana": "かち"}], "matching": [{"key": "p1", "arti": "Memperkenalkan", "kanji": "ご紹介します", "label": "ごしょうかいします", "round": 0, "token": "0de9c6a3c7dcafae", "cardId": "11", "prompt": "ご紹介します", "correct": "0de9c6a3c7dcafae", "furigana": "ごしょうかいします"}, {"key": "p2", "arti": "Rencana/proyek", "kanji": "計画", "label": "けいかく", "round": 0, "token": "e5215d2f05521ccd", "cardId": "12", "prompt": "計画", "correct": "e5215d2f05521ccd", "furigana": "けいかく"}, {"key": "p3", "arti": "Pengetahuan/wawasan", "kanji": "雑学", "label": "ざつがく", "round": 0, "token": "3489bd519c45ca81", "cardId": "13", "prompt": "雑学", "correct": "3489bd519c45ca81", "furigana": "ざつがく"}, {"key": "p4", "arti": "Keberadaan", "kanji": "存在", "label": "そんざい", "round": 0, "token": "e4e4595d7540d0b5", "cardId": "14", "prompt": "存在", "correct": "e4e4595d7540d0b5", "furigana": "そんざい"}, {"key": "p5", "arti": "Menggambar", "kanji": "描く", "label": "えがく", "round": 0, "token": "385b3c07b171025a", "cardId": "15", "prompt": "描く", "correct": "385b3c07b171025a", "furigana": "えがく"}, {"key": "p6", "arti": "Karya/Ciptaan", "kanji": "作品", "label": "さくひん", "round": 1, "token": "9108b4128ccd8fb2", "cardId": "16", "prompt": "作品", "correct": "9108b4128ccd8fb2", "furigana": "さくひん"}, {"key": "p7", "arti": "Selanjutnya/Lain kali", "kanji": "次回", "label": "じかい", "round": 1, "token": "0ca1d8660fbb94ec", "cardId": "17", "prompt": "次回", "correct": "0ca1d8660fbb94ec", "furigana": "じかい"}, {"key": "p8", "arti": "Fungsi/Kemampuan", "kanji": "機能", "label": "きのう", "round": 1, "token": "2a5c2d5588e398ff", "cardId": "18", "prompt": "機能", "correct": "2a5c2d5588e398ff", "furigana": "きのう"}, {"key": "p9", "arti": "Berkaitan/Terlibat/Berhubungan", "kanji": "関わる", "label": "かかわる", "round": 1, "token": "2d7fd4b030c7d22b", "cardId": "19", "prompt": "関わる", "correct": "2d7fd4b030c7d22b", "furigana": "かかわる"}, {"key": "p10", "arti": "Harga/Nilai/Manfaat", "kanji": "価値", "label": "かち", "round": 1, "token": "ca818cbb626fd394", "cardId": "20", "prompt": "価値", "correct": "ca818cbb626fd394", "furigana": "かち"}]}	2026-10-19 15:55:43.509475+00	\N
10e7b391-e181-44f0-9f5b-8caf40628db8	e0c4ceab-eafd-44fc-b659-7088435ec643	done	{"mc": [{"key": "m1", "arti": "tidak ada hari libur", "kanji": "無休", "cardId": "372", "prompt": "無休", "correct": "372", "options": [{"id": "371", "label": "かいだん"}, {"id": "372", "label": "むきゅう"}, {"id": "382", "label": "おす"}, {"id": "381", "label": "よこ"}], "furigana": "むきゅう"}, {"key": "m2", "arti": "gratis", "kanji": "無料", "cardId": "373", "prompt": "無料", "correct": "373", "options": [{"id": "406", "label": "みとめる"}, {"id": "373", "label": "むりょう"}, {"id": "377", "label": "だんすい"}, {"id": "385", "label": "おしぼたんしき"}], "furigana": "むりょう"}, {"key": "m3", "arti": "mustahil / dipaksakan", "kanji": "無理な", "cardId": "374", "prompt": "無理な", "correct": "374", "options": [{"id": "368", "label": "ひこうじょう"}, {"id": "374", "label": "むりな"}, {"id": "373", "label": "むりょう"}, {"id": "408", "label": "ひじょうぐち"}], "furigana": "むりな"}, {"key": "m4", "arti": "tidak ada", "kanji": "無い", "cardId": "375", "prompt": "無い", "correct": "375", "options": [{"id": "375", "label": "ない"}, {"id": "396", "label": "そうしん"}, {"id": "364", "label": "まんしゃ"}, {"id": "372", "label": "むきゅう"}], "furigana": "ない"}, {"key": "m5", "arti": "tanpa izin", "kanji": "無断", "cardId": "376", "prompt": "無断", "correct": "376", "options": [{"id": "376", "label": "むだん"}, {"id": "390", "label": "むき"}, {"id": "388", "label": "ほうこう"}, {"id": "383", "label": "おしいれ"}], "furigana": "むだん"}, {"key": "m6", "arti": "pemutusan air / mati air", "kanji": "断水", "cardId": "377", "prompt": "断水", "correct": "377", "options": [{"id": "377", "label": "だんすい"}, {"id": "392", "label": "じしん"}, {"id": "363", "label": "ちゅうしゃ"}, {"id": "383", "label": "おしいれ"}], "furigana": "だんすい"}, {"key": "m7", "arti": "menolak", "kanji": "断る", "cardId": "378", "prompt": "断る", "correct": "378", "options": [{"id": "378", "label": "ことわる"}, {"id": "372", "label": "むきゅう"}, {"id": "376", "label": "むだん"}, {"id": "381", "label": "よこ"}], "furigana": "ことわる"}, {"key": "m8", "arti": "penyeberangan", "kanji": "横断", "cardId": "379", "prompt": "横断", "correct": "379", "options": [{"id": "377", "label": "だんすい"}, {"id": "400", "label": "かかり"}, {"id": "379", "label": "おうだん"}, {"id": "390", "label": "むき"}], "furigana": "おうだん"}, {"key": "m9", "arti": "zebra cross", "kanji": "横断歩道", "cardId": "380", "prompt": "横断歩道", "correct": "380", "options": [{"id": "375", "label": "ない"}, {"id": "395", "label": "しんごう"}, {"id": "380", "label": "おうだんほどう"}, {"id": "409", "label": "ひじょうに"}], "furigana": "おうだんほどう"}, {"key": "m10", "arti": "samping", "kanji": "横", "cardId": "381", "prompt": "横", "correct": "381", "options": [{"id": "381", "label": "よこ"}, {"id": "390", "label": "むき"}, {"id": "386", "label": "すうしき"}, {"id": "391", "label": "はこ"}], "furigana": "よこ"}], "typing": [{"key": "t1", "arti": "tidak ada hari libur", "kanji": "無休", "cardId": "372", "prompt": "無休", "furigana": "むきゅう", "answerKanji": "無休", "answerFurigana": "むきゅう"}, {"key": "t2", "arti": "gratis", "kanji": "無料", "cardId": "373", "prompt": "無料", "furigana": "むりょう", "answerKanji": "無料", "answerFurigana": "むりょう"}, {"key": "t3", "arti": "mustahil / dipaksakan", "kanji": "無理な", "cardId": "374", "prompt": "無理な", "furigana": "むりな", "answerKanji": "無理な", "answerFurigana": "むりな"}, {"key": "t4", "arti": "tidak ada", "kanji": "無い", "cardId": "375", "prompt": "無い", "furigana": "ない", "answerKanji": "無い", "answerFurigana": "ない"}, {"key": "t5", "arti": "tanpa izin", "kanji": "無断", "cardId": "376", "prompt": "無断", "furigana": "むだん", "answerKanji": "無断", "answerFurigana": "むだん"}, {"key": "t6", "arti": "pemutusan air / mati air", "kanji": "断水", "cardId": "377", "prompt": "断水", "furigana": "だんすい", "answerKanji": "断水", "answerFurigana": "だんすい"}, {"key": "t7", "arti": "menolak", "kanji": "断る", "cardId": "378", "prompt": "断る", "furigana": "ことわる", "answerKanji": "断る", "answerFurigana": "ことわる"}, {"key": "t8", "arti": "penyeberangan", "kanji": "横断", "cardId": "379", "prompt": "横断", "furigana": "おうだん", "answerKanji": "横断", "answerFurigana": "おうだん"}, {"key": "t9", "arti": "zebra cross", "kanji": "横断歩道", "cardId": "380", "prompt": "横断歩道", "furigana": "おうだんほどう", "answerKanji": "横断歩道", "answerFurigana": "おうだんほどう"}, {"key": "t10", "arti": "samping", "kanji": "横", "cardId": "381", "prompt": "横", "furigana": "よこ", "answerKanji": "横", "answerFurigana": "よこ"}], "matching": [{"key": "p1", "arti": "tidak ada hari libur", "kanji": "無休", "label": "むきゅう", "round": 0, "token": "6cf3d9eef4635b65", "cardId": "372", "prompt": "無休", "correct": "6cf3d9eef4635b65", "furigana": "むきゅう"}, {"key": "p2", "arti": "gratis", "kanji": "無料", "label": "むりょう", "round": 0, "token": "6fa19b132b82db60", "cardId": "373", "prompt": "無料", "correct": "6fa19b132b82db60", "furigana": "むりょう"}, {"key": "p3", "arti": "mustahil / dipaksakan", "kanji": "無理な", "label": "むりな", "round": 0, "token": "4828901aab395e17", "cardId": "374", "prompt": "無理な", "correct": "4828901aab395e17", "furigana": "むりな"}, {"key": "p4", "arti": "tidak ada", "kanji": "無い", "label": "ない", "round": 0, "token": "c81cbce0537198de", "cardId": "375", "prompt": "無い", "correct": "c81cbce0537198de", "furigana": "ない"}, {"key": "p5", "arti": "tanpa izin", "kanji": "無断", "label": "むだん", "round": 0, "token": "7ec085f58987dacf", "cardId": "376", "prompt": "無断", "correct": "7ec085f58987dacf", "furigana": "むだん"}, {"key": "p6", "arti": "pemutusan air / mati air", "kanji": "断水", "label": "だんすい", "round": 1, "token": "64bbb8ed4246e796", "cardId": "377", "prompt": "断水", "correct": "64bbb8ed4246e796", "furigana": "だんすい"}, {"key": "p7", "arti": "menolak", "kanji": "断る", "label": "ことわる", "round": 1, "token": "c84bb05748236712", "cardId": "378", "prompt": "断る", "correct": "c84bb05748236712", "furigana": "ことわる"}, {"key": "p8", "arti": "penyeberangan", "kanji": "横断", "label": "おうだん", "round": 1, "token": "67f60955fdd44986", "cardId": "379", "prompt": "横断", "correct": "67f60955fdd44986", "furigana": "おうだん"}, {"key": "p9", "arti": "zebra cross", "kanji": "横断歩道", "label": "おうだんほどう", "round": 1, "token": "5262624b8fe204a7", "cardId": "380", "prompt": "横断歩道", "correct": "5262624b8fe204a7", "furigana": "おうだんほどう"}, {"key": "p10", "arti": "samping", "kanji": "横", "label": "よこ", "round": 1, "token": "7fe46d27000a4740", "cardId": "381", "prompt": "横", "correct": "7fe46d27000a4740", "furigana": "よこ"}]}	2026-10-20 04:47:17.464078+00	2026-10-20 04:49:21.660966+00
e5b66a3f-92e6-4b53-93c1-ec60f0226d04	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	done	{"mc": [{"key": "m1", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "correct": "161", "options": [{"id": "295", "label": "おんがく"}, {"id": "161", "label": "いと"}, {"id": "262", "label": "がら"}, {"id": "285", "label": "いぜん"}], "furigana": "いと"}, {"key": "m2", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "correct": "162", "options": [{"id": "188", "label": "いんさつ"}, {"id": "162", "label": "いも"}, {"id": "226", "label": "あつい"}, {"id": "330", "label": "おぼえる"}], "furigana": "いも"}, {"key": "m3", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "correct": "163", "options": [{"id": "168", "label": "えだ"}, {"id": "163", "label": "うた"}, {"id": "247", "label": "ぐうぜん"}, {"id": "361", "label": "さっそく"}], "furigana": "うた"}, {"key": "m4", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "correct": "164", "options": [{"id": "333", "label": "いたい"}, {"id": "164", "label": "うち"}, {"id": "221", "label": "あかるい"}, {"id": "239", "label": "きけんな"}], "furigana": "うち"}, {"key": "m5", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "correct": "165", "options": [{"id": "171", "label": "あいず"}, {"id": "269", "label": "かさ"}, {"id": "165", "label": "うつわ"}, {"id": "339", "label": "おいしい"}], "furigana": "うつわ"}, {"key": "m6", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "correct": "166", "options": [{"id": "316", "label": "うける"}, {"id": "166", "label": "うで"}, {"id": "189", "label": "いんしょう"}, {"id": "308", "label": "かち"}], "furigana": "うで"}, {"key": "m7", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "correct": "167", "options": [{"id": "297", "label": "おんど"}, {"id": "301", "label": "かいだん"}, {"id": "204", "label": "あける"}, {"id": "167", "label": "え"}], "furigana": "え"}, {"key": "m8", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "correct": "168", "options": [{"id": "166", "label": "うで"}, {"id": "266", "label": "おや"}, {"id": "343", "label": "きゅうな"}, {"id": "168", "label": "えだ"}], "furigana": "えだ"}, {"key": "m9", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "correct": "169", "options": [{"id": "184", "label": "いない"}, {"id": "283", "label": "いしゃ"}, {"id": "324", "label": "おこなう"}, {"id": "169", "label": "おく"}], "furigana": "おく"}, {"key": "m10", "arti": "bunyi; suara", "kanji": "音", "cardId": "170", "prompt": "音", "correct": "170", "options": [{"id": "182", "label": "いっぱん"}, {"id": "303", "label": "かがく"}, {"id": "270", "label": "かず"}, {"id": "170", "label": "おと"}], "furigana": "おと"}], "typing": [{"key": "t1", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "furigana": "いと", "answerKanji": "糸", "answerFurigana": "いと"}, {"key": "t2", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "furigana": "いも", "answerKanji": "芋", "answerFurigana": "いも"}, {"key": "t3", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "furigana": "うた", "answerKanji": "歌", "answerFurigana": "うた"}, {"key": "t4", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "furigana": "うち", "answerKanji": "内", "answerFurigana": "うち"}, {"key": "t5", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "furigana": "うつわ", "answerKanji": "器", "answerFurigana": "うつわ"}, {"key": "t6", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "furigana": "うで", "answerKanji": "腕", "answerFurigana": "うで"}, {"key": "t7", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "furigana": "え", "answerKanji": "絵", "answerFurigana": "え"}, {"key": "t8", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "furigana": "えだ", "answerKanji": "枝", "answerFurigana": "えだ"}, {"key": "t9", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "furigana": "おく", "answerKanji": "奥", "answerFurigana": "おく"}, {"key": "t10", "arti": "bunyi; suara", "kanji": "音", "cardId": "170", "prompt": "音", "furigana": "おと", "answerKanji": "音", "answerFurigana": "おと"}], "matching": [{"key": "p1", "arti": "benang", "kanji": "糸", "label": "いと", "round": 0, "token": "d2e15c86efc591e5", "cardId": "161", "prompt": "糸", "correct": "d2e15c86efc591e5", "furigana": "いと"}, {"key": "p2", "arti": "umbi; kentang", "kanji": "芋", "label": "いも", "round": 0, "token": "35bb1506663d044f", "cardId": "162", "prompt": "芋", "correct": "35bb1506663d044f", "furigana": "いも"}, {"key": "p3", "arti": "lagu", "kanji": "歌", "label": "うた", "round": 0, "token": "2b6b546b0e943b30", "cardId": "163", "prompt": "歌", "correct": "2b6b546b0e943b30", "furigana": "うた"}, {"key": "p4", "arti": "bagian dalam", "kanji": "内", "label": "うち", "round": 0, "token": "e8ca3d1dc60a49c3", "cardId": "164", "prompt": "内", "correct": "e8ca3d1dc60a49c3", "furigana": "うち"}, {"key": "p5", "arti": "wadah; mangkuk", "kanji": "器", "label": "うつわ", "round": 0, "token": "8381a9f639e2e35a", "cardId": "165", "prompt": "器", "correct": "8381a9f639e2e35a", "furigana": "うつわ"}, {"key": "p6", "arti": "lengan", "kanji": "腕", "label": "うで", "round": 1, "token": "34d208901986f9ba", "cardId": "166", "prompt": "腕", "correct": "34d208901986f9ba", "furigana": "うで"}, {"key": "p7", "arti": "gambar; lukisan", "kanji": "絵", "label": "え", "round": 1, "token": "381eb7cd3834b1de", "cardId": "167", "prompt": "絵", "correct": "381eb7cd3834b1de", "furigana": "え"}, {"key": "p8", "arti": "ranting; cabang pohon", "kanji": "枝", "label": "えだ", "round": 1, "token": "cd222641f449fb71", "cardId": "168", "prompt": "枝", "correct": "cd222641f449fb71", "furigana": "えだ"}, {"key": "p9", "arti": "bagian dalam; belakang", "kanji": "奥", "label": "おく", "round": 1, "token": "6735834ddbfd9ddb", "cardId": "169", "prompt": "奥", "correct": "6735834ddbfd9ddb", "furigana": "おく"}, {"key": "p10", "arti": "bunyi; suara", "kanji": "音", "label": "おと", "round": 1, "token": "fbb6f4453aa223ca", "cardId": "170", "prompt": "音", "correct": "fbb6f4453aa223ca", "furigana": "おと"}]}	2026-10-20 04:52:46.436336+00	2026-10-20 04:54:16.136925+00
9977e60c-7e0f-443d-8833-3b031180384a	dc219d6a-e80c-4c67-9b3f-211c4df9883d	done	{"mc": [{"key": "m1", "arti": "tempat parkir", "kanji": "駐車場", "cardId": "362", "prompt": "駐車場", "correct": "362", "options": [{"id": "379", "label": "おうだん"}, {"id": "385", "label": "おしぼたんしき"}, {"id": "374", "label": "むりな"}, {"id": "362", "label": "ちゅうしゃじょう"}], "furigana": "ちゅうしゃじょう"}, {"key": "m2", "arti": "parkir", "kanji": "駐車", "cardId": "363", "prompt": "駐車", "correct": "363", "options": [{"id": "363", "label": "ちゅうしゃ"}, {"id": "375", "label": "ない"}, {"id": "400", "label": "かかり"}, {"id": "381", "label": "よこ"}], "furigana": "ちゅうしゃ"}, {"key": "m3", "arti": "parkir penuh", "kanji": "満車", "cardId": "364", "prompt": "満車", "correct": "364", "options": [{"id": "364", "label": "まんしゃ"}, {"id": "377", "label": "だんすい"}, {"id": "378", "label": "ことわる"}, {"id": "393", "label": "しんじる"}], "furigana": "まんしゃ"}, {"key": "m4", "arti": "gerbong nomor ~", "kanji": "号車", "cardId": "365", "prompt": "号車", "correct": "365", "options": [{"id": "365", "label": "ごうしゃ"}, {"id": "409", "label": "ひじょうに"}, {"id": "371", "label": "かいだん"}, {"id": "396", "label": "そうしん"}], "furigana": "ごうしゃ"}, {"key": "m5", "arti": "penuh orang", "kanji": "満員", "cardId": "366", "prompt": "満員", "correct": "366", "options": [{"id": "366", "label": "まんいん"}, {"id": "409", "label": "ひじょうに"}, {"id": "397", "label": "かんしん"}, {"id": "400", "label": "かかり"}], "furigana": "まんいん"}, {"key": "m6", "arti": "tidak puas", "kanji": "不満な", "cardId": "367", "prompt": "不満な", "correct": "367", "options": [{"id": "382", "label": "おす"}, {"id": "367", "label": "ふまんな"}, {"id": "408", "label": "ひじょうぐち"}, {"id": "388", "label": "ほうこう"}], "furigana": "ふまんな"}, {"key": "m7", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "cardId": "368", "prompt": "飛行場", "correct": "368", "options": [{"id": "374", "label": "むりな"}, {"id": "370", "label": "かい"}, {"id": "368", "label": "ひこうじょう"}, {"id": "392", "label": "じしん"}], "furigana": "ひこうじょう"}, {"key": "m8", "arti": "terbang", "kanji": "飛ぶ", "cardId": "369", "prompt": "飛ぶ", "correct": "369", "options": [{"id": "387", "label": "にゅうがくしき"}, {"id": "363", "label": "ちゅうしゃ"}, {"id": "369", "label": "とぶ"}, {"id": "380", "label": "おうだんほどう"}], "furigana": "とぶ"}, {"key": "m9", "arti": "lantai", "kanji": "階", "cardId": "370", "prompt": "階", "correct": "370", "options": [{"id": "374", "label": "むりな"}, {"id": "366", "label": "まんいん"}, {"id": "370", "label": "かい"}, {"id": "377", "label": "だんすい"}], "furigana": "かい"}, {"key": "m10", "arti": "tangga", "kanji": "階段", "cardId": "371", "prompt": "階段", "correct": "371", "options": [{"id": "371", "label": "かいだん"}, {"id": "378", "label": "ことわる"}, {"id": "405", "label": "かくにん"}, {"id": "393", "label": "しんじる"}], "furigana": "かいだん"}], "typing": [{"key": "t1", "arti": "tempat parkir", "kanji": "駐車場", "cardId": "362", "prompt": "駐車場", "furigana": "ちゅうしゃじょう", "answerKanji": "駐車場", "answerFurigana": "ちゅうしゃじょう"}, {"key": "t2", "arti": "parkir", "kanji": "駐車", "cardId": "363", "prompt": "駐車", "furigana": "ちゅうしゃ", "answerKanji": "駐車", "answerFurigana": "ちゅうしゃ"}, {"key": "t3", "arti": "parkir penuh", "kanji": "満車", "cardId": "364", "prompt": "満車", "furigana": "まんしゃ", "answerKanji": "満車", "answerFurigana": "まんしゃ"}, {"key": "t4", "arti": "gerbong nomor ~", "kanji": "号車", "cardId": "365", "prompt": "号車", "furigana": "ごうしゃ", "answerKanji": "号車", "answerFurigana": "ごうしゃ"}, {"key": "t5", "arti": "penuh orang", "kanji": "満員", "cardId": "366", "prompt": "満員", "furigana": "まんいん", "answerKanji": "満員", "answerFurigana": "まんいん"}, {"key": "t6", "arti": "tidak puas", "kanji": "不満な", "cardId": "367", "prompt": "不満な", "furigana": "ふまんな", "answerKanji": "不満な", "answerFurigana": "ふまんな"}, {"key": "t7", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "cardId": "368", "prompt": "飛行場", "furigana": "ひこうじょう", "answerKanji": "飛行場", "answerFurigana": "ひこうじょう"}, {"key": "t8", "arti": "terbang", "kanji": "飛ぶ", "cardId": "369", "prompt": "飛ぶ", "furigana": "とぶ", "answerKanji": "飛ぶ", "answerFurigana": "とぶ"}, {"key": "t9", "arti": "lantai", "kanji": "階", "cardId": "370", "prompt": "階", "furigana": "かい", "answerKanji": "階", "answerFurigana": "かい"}, {"key": "t10", "arti": "tangga", "kanji": "階段", "cardId": "371", "prompt": "階段", "furigana": "かいだん", "answerKanji": "階段", "answerFurigana": "かいだん"}], "matching": [{"key": "p1", "arti": "tempat parkir", "kanji": "駐車場", "label": "ちゅうしゃじょう", "round": 0, "token": "b8fef03f3e0084b8", "cardId": "362", "prompt": "駐車場", "correct": "b8fef03f3e0084b8", "furigana": "ちゅうしゃじょう"}, {"key": "p2", "arti": "parkir", "kanji": "駐車", "label": "ちゅうしゃ", "round": 0, "token": "66c1661a0ad07e12", "cardId": "363", "prompt": "駐車", "correct": "66c1661a0ad07e12", "furigana": "ちゅうしゃ"}, {"key": "p3", "arti": "parkir penuh", "kanji": "満車", "label": "まんしゃ", "round": 0, "token": "bb9c7f4e6592a50a", "cardId": "364", "prompt": "満車", "correct": "bb9c7f4e6592a50a", "furigana": "まんしゃ"}, {"key": "p4", "arti": "gerbong nomor ~", "kanji": "号車", "label": "ごうしゃ", "round": 0, "token": "f074da063d226d1e", "cardId": "365", "prompt": "号車", "correct": "f074da063d226d1e", "furigana": "ごうしゃ"}, {"key": "p5", "arti": "penuh orang", "kanji": "満員", "label": "まんいん", "round": 0, "token": "65f715594b05df88", "cardId": "366", "prompt": "満員", "correct": "65f715594b05df88", "furigana": "まんいん"}, {"key": "p6", "arti": "tidak puas", "kanji": "不満な", "label": "ふまんな", "round": 1, "token": "cda9b1e2a4419351", "cardId": "367", "prompt": "不満な", "correct": "cda9b1e2a4419351", "furigana": "ふまんな"}, {"key": "p7", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "label": "ひこうじょう", "round": 1, "token": "73f2a3125c24485e", "cardId": "368", "prompt": "飛行場", "correct": "73f2a3125c24485e", "furigana": "ひこうじょう"}, {"key": "p8", "arti": "terbang", "kanji": "飛ぶ", "label": "とぶ", "round": 1, "token": "fd1a09409a3664be", "cardId": "369", "prompt": "飛ぶ", "correct": "fd1a09409a3664be", "furigana": "とぶ"}, {"key": "p9", "arti": "lantai", "kanji": "階", "label": "かい", "round": 1, "token": "8703e4743df3e3d6", "cardId": "370", "prompt": "階", "correct": "8703e4743df3e3d6", "furigana": "かい"}, {"key": "p10", "arti": "tangga", "kanji": "階段", "label": "かいだん", "round": 1, "token": "c38daba05063db58", "cardId": "371", "prompt": "階段", "correct": "c38daba05063db58", "furigana": "かいだん"}]}	2026-10-20 04:49:49.359558+00	2026-10-20 04:51:43.2102+00
91a6e2b7-b04b-4118-a874-e91a6fa5ff94	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	done	{"mc": [{"key": "m1", "arti": "napas", "kanji": "息", "cardId": "159", "prompt": "息", "correct": "159", "options": [{"id": "264", "label": "き"}, {"id": "168", "label": "えだ"}, {"id": "159", "label": "いき"}, {"id": "234", "label": "いやな"}], "furigana": "いき"}, {"key": "m2", "arti": "kolam", "kanji": "池", "cardId": "160", "prompt": "池", "correct": "160", "options": [{"id": "165", "label": "うつわ"}, {"id": "335", "label": "うらやましい"}, {"id": "291", "label": "えいが"}, {"id": "160", "label": "いけ"}], "furigana": "いけ"}, {"key": "m3", "arti": "isyarat; tanda", "kanji": "合図", "cardId": "171", "prompt": "合図", "correct": "171", "options": [{"id": "171", "label": "あいず"}, {"id": "330", "label": "おぼえる"}, {"id": "221", "label": "あかるい"}, {"id": "163", "label": "うた"}], "furigana": "あいず"}, {"key": "m4", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "cardId": "172", "prompt": "相手", "correct": "172", "options": [{"id": "293", "label": "おうぼ"}, {"id": "325", "label": "おす"}, {"id": "233", "label": "いっぱんてきな"}, {"id": "172", "label": "あいて"}], "furigana": "あいて"}, {"key": "m5", "arti": "langit biru", "kanji": "青空", "cardId": "173", "prompt": "青空", "correct": "173", "options": [{"id": "320", "label": "うめる"}, {"id": "173", "label": "あおぞら"}, {"id": "311", "label": "かんけい"}, {"id": "289", "label": "うんてん"}], "furigana": "あおぞら"}, {"key": "m6", "arti": "rasa lega; ketenangan", "kanji": "安心", "cardId": "174", "prompt": "安心", "correct": "174", "options": [{"id": "174", "label": "あんしん"}, {"id": "175", "label": "あんない"}, {"id": "214", "label": "かす"}, {"id": "331", "label": "おる"}], "furigana": "あんしん"}, {"key": "m7", "arti": "panduan; mengantar", "kanji": "案内", "cardId": "175", "prompt": "案内", "correct": "175", "options": [{"id": "339", "label": "おいしい"}, {"id": "235", "label": "かくじつな"}, {"id": "178", "label": "いけん"}, {"id": "175", "label": "あんない"}], "furigana": "あんない"}, {"key": "m8", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "cardId": "176", "prompt": "以下", "correct": "176", "options": [{"id": "311", "label": "かんけい"}, {"id": "220", "label": "かわる"}, {"id": "176", "label": "いか"}, {"id": "218", "label": "かりる"}], "furigana": "いか"}, {"key": "m9", "arti": "selain; kecuali", "kanji": "以外", "cardId": "177", "prompt": "以外", "correct": "177", "options": [{"id": "177", "label": "いがい"}, {"id": "315", "label": "うえる"}, {"id": "172", "label": "あいて"}, {"id": "326", "label": "おちる"}], "furigana": "いがい"}, {"key": "m10", "arti": "pendapat", "kanji": "意見", "cardId": "178", "prompt": "意見", "correct": "178", "options": [{"id": "323", "label": "おくれる"}, {"id": "314", "label": "いたむ"}, {"id": "152", "label": "あお"}, {"id": "178", "label": "いけん"}], "furigana": "いけん"}], "typing": [{"key": "t1", "arti": "napas", "kanji": "息", "cardId": "159", "prompt": "息", "furigana": "いき", "answerKanji": "息", "answerFurigana": "いき"}, {"key": "t2", "arti": "kolam", "kanji": "池", "cardId": "160", "prompt": "池", "furigana": "いけ", "answerKanji": "池", "answerFurigana": "いけ"}, {"key": "t3", "arti": "isyarat; tanda", "kanji": "合図", "cardId": "171", "prompt": "合図", "furigana": "あいず", "answerKanji": "合図", "answerFurigana": "あいず"}, {"key": "t4", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "cardId": "172", "prompt": "相手", "furigana": "あいて", "answerKanji": "相手", "answerFurigana": "あいて"}, {"key": "t5", "arti": "langit biru", "kanji": "青空", "cardId": "173", "prompt": "青空", "furigana": "あおぞら", "answerKanji": "青空", "answerFurigana": "あおぞら"}, {"key": "t6", "arti": "rasa lega; ketenangan", "kanji": "安心", "cardId": "174", "prompt": "安心", "furigana": "あんしん", "answerKanji": "安心", "answerFurigana": "あんしん"}, {"key": "t7", "arti": "panduan; mengantar", "kanji": "案内", "cardId": "175", "prompt": "案内", "furigana": "あんない", "answerKanji": "案内", "answerFurigana": "あんない"}, {"key": "t8", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "cardId": "176", "prompt": "以下", "furigana": "いか", "answerKanji": "以下", "answerFurigana": "いか"}, {"key": "t9", "arti": "selain; kecuali", "kanji": "以外", "cardId": "177", "prompt": "以外", "furigana": "いがい", "answerKanji": "以外", "answerFurigana": "いがい"}, {"key": "t10", "arti": "pendapat", "kanji": "意見", "cardId": "178", "prompt": "意見", "furigana": "いけん", "answerKanji": "意見", "answerFurigana": "いけん"}], "matching": [{"key": "p1", "arti": "napas", "kanji": "息", "label": "いき", "round": 0, "token": "ead630ca65afa2f9", "cardId": "159", "prompt": "息", "correct": "ead630ca65afa2f9", "furigana": "いき"}, {"key": "p2", "arti": "kolam", "kanji": "池", "label": "いけ", "round": 0, "token": "7d05500d8f74274b", "cardId": "160", "prompt": "池", "correct": "7d05500d8f74274b", "furigana": "いけ"}, {"key": "p3", "arti": "isyarat; tanda", "kanji": "合図", "label": "あいず", "round": 0, "token": "189af5ff6f2154f3", "cardId": "171", "prompt": "合図", "correct": "189af5ff6f2154f3", "furigana": "あいず"}, {"key": "p4", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "label": "あいて", "round": 0, "token": "d4228e0c2303db59", "cardId": "172", "prompt": "相手", "correct": "d4228e0c2303db59", "furigana": "あいて"}, {"key": "p5", "arti": "langit biru", "kanji": "青空", "label": "あおぞら", "round": 0, "token": "c561f0dc88d54bbd", "cardId": "173", "prompt": "青空", "correct": "c561f0dc88d54bbd", "furigana": "あおぞら"}, {"key": "p6", "arti": "rasa lega; ketenangan", "kanji": "安心", "label": "あんしん", "round": 1, "token": "6d412e90d38b4089", "cardId": "174", "prompt": "安心", "correct": "6d412e90d38b4089", "furigana": "あんしん"}, {"key": "p7", "arti": "panduan; mengantar", "kanji": "案内", "label": "あんない", "round": 1, "token": "390e6bb169715a42", "cardId": "175", "prompt": "案内", "correct": "390e6bb169715a42", "furigana": "あんない"}, {"key": "p8", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "label": "いか", "round": 1, "token": "fcc9fca186bcddb6", "cardId": "176", "prompt": "以下", "correct": "fcc9fca186bcddb6", "furigana": "いか"}, {"key": "p9", "arti": "selain; kecuali", "kanji": "以外", "label": "いがい", "round": 1, "token": "71797bdad47ebab3", "cardId": "177", "prompt": "以外", "correct": "71797bdad47ebab3", "furigana": "いがい"}, {"key": "p10", "arti": "pendapat", "kanji": "意見", "label": "いけん", "round": 1, "token": "2e89c6b107277730", "cardId": "178", "prompt": "意見", "correct": "2e89c6b107277730", "furigana": "いけん"}]}	2026-10-20 04:55:09.034676+00	2026-10-20 04:56:33.956829+00
c30510a9-fe54-4417-9889-e548f5360b2f	15159fd6-75bb-407b-bdef-f007c759306b	done	{"mc": [{"key": "m1", "arti": "sejak; setelah", "kanji": "以降", "cardId": "179", "prompt": "以降", "correct": "179", "options": [{"id": "331", "label": "おる"}, {"id": "332", "label": "いそがしい"}, {"id": "342", "label": "きほんてきな"}, {"id": "179", "label": "いこう"}], "furigana": "いこう"}, {"key": "m2", "arti": "mempertahankan; pemeliharaan", "kanji": "維持", "cardId": "180", "prompt": "維持", "correct": "180", "options": [{"id": "271", "label": "かた"}, {"id": "180", "label": "いじ"}, {"id": "310", "label": "かんきょう"}, {"id": "151", "label": "あいだ"}], "furigana": "いじ"}, {"key": "m3", "arti": "bersama", "kanji": "一緒", "cardId": "181", "prompt": "一緒", "correct": "181", "options": [{"id": "268", "label": "かお"}, {"id": "178", "label": "いけん"}, {"id": "181", "label": "いっしょ"}, {"id": "233", "label": "いっぱんてきな"}], "furigana": "いっしょ"}, {"key": "m4", "arti": "umum; masyarakat umum", "kanji": "一般", "cardId": "182", "prompt": "一般", "correct": "182", "options": [{"id": "182", "label": "いっぱん"}, {"id": "281", "label": "さくら"}, {"id": "314", "label": "いたむ"}, {"id": "320", "label": "うめる"}], "furigana": "いっぱん"}, {"key": "m5", "arti": "perpindahan; bergerak", "kanji": "移動", "cardId": "183", "prompt": "移動", "correct": "183", "options": [{"id": "334", "label": "うすい"}, {"id": "294", "label": "おうよう"}, {"id": "183", "label": "いどう"}, {"id": "299", "label": "かいけつ"}], "furigana": "いどう"}, {"key": "m6", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "cardId": "184", "prompt": "以内", "correct": "184", "options": [{"id": "184", "label": "いない"}, {"id": "236", "label": "かつどうてきな"}, {"id": "307", "label": "かさい"}, {"id": "262", "label": "がら"}], "furigana": "いない"}, {"key": "m7", "arti": "desa; pedesaan", "kanji": "田舎", "cardId": "185", "prompt": "田舎", "correct": "185", "options": [{"id": "262", "label": "がら"}, {"id": "272", "label": "くつ"}, {"id": "358", "label": "きっと"}, {"id": "185", "label": "いなか"}], "furigana": "いなか"}, {"key": "m8", "arti": "ruang keluarga", "kanji": "居間", "cardId": "186", "prompt": "居間", "correct": "186", "options": [{"id": "332", "label": "いそがしい"}, {"id": "186", "label": "いま"}, {"id": "318", "label": "うつ"}, {"id": "169", "label": "おく"}], "furigana": "いま"}, {"key": "m9", "arti": "arti; makna", "kanji": "意味", "cardId": "187", "prompt": "意味", "correct": "187", "options": [{"id": "169", "label": "おく"}, {"id": "187", "label": "いみ"}, {"id": "290", "label": "うんどう"}, {"id": "247", "label": "ぐうぜん"}], "furigana": "いみ"}, {"key": "m10", "arti": "mencetak; pencetakan", "kanji": "印刷", "cardId": "188", "prompt": "印刷", "correct": "188", "options": [{"id": "228", "label": "あぶない"}, {"id": "188", "label": "いんさつ"}, {"id": "197", "label": "えんそう"}, {"id": "161", "label": "いと"}], "furigana": "いんさつ"}], "typing": [{"key": "t1", "arti": "sejak; setelah", "kanji": "以降", "cardId": "179", "prompt": "以降", "furigana": "いこう", "answerKanji": "以降", "answerFurigana": "いこう"}, {"key": "t2", "arti": "mempertahankan; pemeliharaan", "kanji": "維持", "cardId": "180", "prompt": "維持", "furigana": "いじ", "answerKanji": "維持", "answerFurigana": "いじ"}, {"key": "t3", "arti": "bersama", "kanji": "一緒", "cardId": "181", "prompt": "一緒", "furigana": "いっしょ", "answerKanji": "一緒", "answerFurigana": "いっしょ"}, {"key": "t4", "arti": "umum; masyarakat umum", "kanji": "一般", "cardId": "182", "prompt": "一般", "furigana": "いっぱん", "answerKanji": "一般", "answerFurigana": "いっぱん"}, {"key": "t5", "arti": "perpindahan; bergerak", "kanji": "移動", "cardId": "183", "prompt": "移動", "furigana": "いどう", "answerKanji": "移動", "answerFurigana": "いどう"}, {"key": "t6", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "cardId": "184", "prompt": "以内", "furigana": "いない", "answerKanji": "以内", "answerFurigana": "いない"}, {"key": "t7", "arti": "desa; pedesaan", "kanji": "田舎", "cardId": "185", "prompt": "田舎", "furigana": "いなか", "answerKanji": "田舎", "answerFurigana": "いなか"}, {"key": "t8", "arti": "ruang keluarga", "kanji": "居間", "cardId": "186", "prompt": "居間", "furigana": "いま", "answerKanji": "居間", "answerFurigana": "いま"}, {"key": "t9", "arti": "arti; makna", "kanji": "意味", "cardId": "187", "prompt": "意味", "furigana": "いみ", "answerKanji": "意味", "answerFurigana": "いみ"}, {"key": "t10", "arti": "mencetak; pencetakan", "kanji": "印刷", "cardId": "188", "prompt": "印刷", "furigana": "いんさつ", "answerKanji": "印刷", "answerFurigana": "いんさつ"}], "matching": [{"key": "p1", "arti": "sejak; setelah", "kanji": "以降", "label": "いこう", "round": 0, "token": "e28f0b534d9b9ea3", "cardId": "179", "prompt": "以降", "correct": "e28f0b534d9b9ea3", "furigana": "いこう"}, {"key": "p2", "arti": "mempertahankan; pemeliharaan", "kanji": "維持", "label": "いじ", "round": 0, "token": "5ad84c40c085ced9", "cardId": "180", "prompt": "維持", "correct": "5ad84c40c085ced9", "furigana": "いじ"}, {"key": "p3", "arti": "bersama", "kanji": "一緒", "label": "いっしょ", "round": 0, "token": "97242277977783fc", "cardId": "181", "prompt": "一緒", "correct": "97242277977783fc", "furigana": "いっしょ"}, {"key": "p4", "arti": "umum; masyarakat umum", "kanji": "一般", "label": "いっぱん", "round": 0, "token": "934bb42a6dc59f08", "cardId": "182", "prompt": "一般", "correct": "934bb42a6dc59f08", "furigana": "いっぱん"}, {"key": "p5", "arti": "perpindahan; bergerak", "kanji": "移動", "label": "いどう", "round": 0, "token": "ea75031caca411d4", "cardId": "183", "prompt": "移動", "correct": "ea75031caca411d4", "furigana": "いどう"}, {"key": "p6", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "label": "いない", "round": 1, "token": "99fd05c543f0ffed", "cardId": "184", "prompt": "以内", "correct": "99fd05c543f0ffed", "furigana": "いない"}, {"key": "p7", "arti": "desa; pedesaan", "kanji": "田舎", "label": "いなか", "round": 1, "token": "f007d7350d0c1f63", "cardId": "185", "prompt": "田舎", "correct": "f007d7350d0c1f63", "furigana": "いなか"}, {"key": "p8", "arti": "ruang keluarga", "kanji": "居間", "label": "いま", "round": 1, "token": "45cdcb0d483db08f", "cardId": "186", "prompt": "居間", "correct": "45cdcb0d483db08f", "furigana": "いま"}, {"key": "p9", "arti": "arti; makna", "kanji": "意味", "label": "いみ", "round": 1, "token": "2c9d9bf688b1e90b", "cardId": "187", "prompt": "意味", "correct": "2c9d9bf688b1e90b", "furigana": "いみ"}, {"key": "p10", "arti": "mencetak; pencetakan", "kanji": "印刷", "label": "いんさつ", "round": 1, "token": "642682c4e1994b98", "cardId": "188", "prompt": "印刷", "correct": "642682c4e1994b98", "furigana": "いんさつ"}]}	2026-10-20 04:57:40.965679+00	2026-10-20 04:59:09.971248+00
d7f71f5b-e222-44f0-9b73-e8db54c2ffe1	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	done	{"mc": [{"key": "m1", "arti": "menekan", "kanji": "押す", "cardId": "382", "prompt": "押す", "correct": "382", "options": [{"id": "403", "label": "たしかな"}, {"id": "367", "label": "ふまんな"}, {"id": "382", "label": "おす"}, {"id": "404", "label": "たしかめる"}], "furigana": "おす"}, {"key": "m2", "arti": "lemari dinding bergaya Jepang", "kanji": "押し入れ", "cardId": "383", "prompt": "押し入れ", "correct": "383", "options": [{"id": "383", "label": "おしいれ"}, {"id": "375", "label": "ない"}, {"id": "381", "label": "よこ"}, {"id": "389", "label": "むかう"}], "furigana": "おしいれ"}, {"key": "m3", "arti": "menahan / menekan", "kanji": "押さえる", "cardId": "384", "prompt": "押さえる", "correct": "384", "options": [{"id": "401", "label": "きんし"}, {"id": "369", "label": "とぶ"}, {"id": "362", "label": "ちゅうしゃじょう"}, {"id": "384", "label": "おさえる"}], "furigana": "おさえる"}, {"key": "m4", "arti": "tipe tombol tekan", "kanji": "押しボタン式", "cardId": "385", "prompt": "押しボタン式", "correct": "385", "options": [{"id": "389", "label": "むかう"}, {"id": "406", "label": "みとめる"}, {"id": "385", "label": "おしぼたんしき"}, {"id": "395", "label": "しんごう"}], "furigana": "おしぼたんしき"}, {"key": "m5", "arti": "rumus matematika", "kanji": "数式", "cardId": "386", "prompt": "数式", "correct": "386", "options": [{"id": "408", "label": "ひじょうぐち"}, {"id": "386", "label": "すうしき"}, {"id": "381", "label": "よこ"}, {"id": "365", "label": "ごうしゃ"}], "furigana": "すうしき"}, {"key": "m6", "arti": "upacara masuk sekolah", "kanji": "入学式", "cardId": "387", "prompt": "入学式", "correct": "387", "options": [{"id": "387", "label": "にゅうがくしき"}, {"id": "389", "label": "むかう"}, {"id": "386", "label": "すうしき"}, {"id": "375", "label": "ない"}], "furigana": "にゅうがくしき"}, {"key": "m7", "arti": "arah", "kanji": "方向", "cardId": "388", "prompt": "方向", "correct": "388", "options": [{"id": "395", "label": "しんごう"}, {"id": "385", "label": "おしぼたんしき"}, {"id": "384", "label": "おさえる"}, {"id": "388", "label": "ほうこう"}], "furigana": "ほうこう"}, {"key": "m8", "arti": "menuju", "kanji": "向かう", "cardId": "389", "prompt": "向かう", "correct": "389", "options": [{"id": "389", "label": "むかう"}, {"id": "375", "label": "ない"}, {"id": "387", "label": "にゅうがくしき"}, {"id": "400", "label": "かかり"}], "furigana": "むかう"}, {"key": "m9", "arti": "cocok untuk / menghadap", "kanji": "向き", "cardId": "390", "prompt": "向き", "correct": "390", "options": [{"id": "388", "label": "ほうこう"}, {"id": "377", "label": "だんすい"}, {"id": "390", "label": "むき"}, {"id": "403", "label": "たしかな"}], "furigana": "むき"}, {"key": "m10", "arti": "kotak", "kanji": "箱", "cardId": "391", "prompt": "箱", "correct": "391", "options": [{"id": "374", "label": "むりな"}, {"id": "403", "label": "たしかな"}, {"id": "391", "label": "はこ"}, {"id": "378", "label": "ことわる"}], "furigana": "はこ"}], "typing": [{"key": "t1", "arti": "menekan", "kanji": "押す", "cardId": "382", "prompt": "押す", "furigana": "おす", "answerKanji": "押す", "answerFurigana": "おす"}, {"key": "t2", "arti": "lemari dinding bergaya Jepang", "kanji": "押し入れ", "cardId": "383", "prompt": "押し入れ", "furigana": "おしいれ", "answerKanji": "押し入れ", "answerFurigana": "おしいれ"}, {"key": "t3", "arti": "menahan / menekan", "kanji": "押さえる", "cardId": "384", "prompt": "押さえる", "furigana": "おさえる", "answerKanji": "押さえる", "answerFurigana": "おさえる"}, {"key": "t4", "arti": "tipe tombol tekan", "kanji": "押しボタン式", "cardId": "385", "prompt": "押しボタン式", "furigana": "おしぼたんしき", "answerKanji": "押しボタン式", "answerFurigana": "おしぼたんしき"}, {"key": "t5", "arti": "rumus matematika", "kanji": "数式", "cardId": "386", "prompt": "数式", "furigana": "すうしき", "answerKanji": "数式", "answerFurigana": "すうしき"}, {"key": "t6", "arti": "upacara masuk sekolah", "kanji": "入学式", "cardId": "387", "prompt": "入学式", "furigana": "にゅうがくしき", "answerKanji": "入学式", "answerFurigana": "にゅうがくしき"}, {"key": "t7", "arti": "arah", "kanji": "方向", "cardId": "388", "prompt": "方向", "furigana": "ほうこう", "answerKanji": "方向", "answerFurigana": "ほうこう"}, {"key": "t8", "arti": "menuju", "kanji": "向かう", "cardId": "389", "prompt": "向かう", "furigana": "むかう", "answerKanji": "向かう", "answerFurigana": "むかう"}, {"key": "t9", "arti": "cocok untuk / menghadap", "kanji": "向き", "cardId": "390", "prompt": "向き", "furigana": "むき", "answerKanji": "向き", "answerFurigana": "むき"}, {"key": "t10", "arti": "kotak", "kanji": "箱", "cardId": "391", "prompt": "箱", "furigana": "はこ", "answerKanji": "箱", "answerFurigana": "はこ"}], "matching": [{"key": "p1", "arti": "menekan", "kanji": "押す", "label": "おす", "round": 0, "token": "dde093a14ad51d4b", "cardId": "382", "prompt": "押す", "correct": "dde093a14ad51d4b", "furigana": "おす"}, {"key": "p2", "arti": "lemari dinding bergaya Jepang", "kanji": "押し入れ", "label": "おしいれ", "round": 0, "token": "f3e66b3c8656c729", "cardId": "383", "prompt": "押し入れ", "correct": "f3e66b3c8656c729", "furigana": "おしいれ"}, {"key": "p3", "arti": "menahan / menekan", "kanji": "押さえる", "label": "おさえる", "round": 0, "token": "f4f747cab7a3b98a", "cardId": "384", "prompt": "押さえる", "correct": "f4f747cab7a3b98a", "furigana": "おさえる"}, {"key": "p4", "arti": "tipe tombol tekan", "kanji": "押しボタン式", "label": "おしぼたんしき", "round": 0, "token": "42dd827e8738279d", "cardId": "385", "prompt": "押しボタン式", "correct": "42dd827e8738279d", "furigana": "おしぼたんしき"}, {"key": "p5", "arti": "rumus matematika", "kanji": "数式", "label": "すうしき", "round": 0, "token": "9744efac19522976", "cardId": "386", "prompt": "数式", "correct": "9744efac19522976", "furigana": "すうしき"}, {"key": "p6", "arti": "upacara masuk sekolah", "kanji": "入学式", "label": "にゅうがくしき", "round": 1, "token": "ca3f38fe788454f2", "cardId": "387", "prompt": "入学式", "correct": "ca3f38fe788454f2", "furigana": "にゅうがくしき"}, {"key": "p7", "arti": "arah", "kanji": "方向", "label": "ほうこう", "round": 1, "token": "e61f5ad635297fd2", "cardId": "388", "prompt": "方向", "correct": "e61f5ad635297fd2", "furigana": "ほうこう"}, {"key": "p8", "arti": "menuju", "kanji": "向かう", "label": "むかう", "round": 1, "token": "2c13c675be0aac95", "cardId": "389", "prompt": "向かう", "correct": "2c13c675be0aac95", "furigana": "むかう"}, {"key": "p9", "arti": "cocok untuk / menghadap", "kanji": "向き", "label": "むき", "round": 1, "token": "cc0b55d91a582944", "cardId": "390", "prompt": "向き", "correct": "cc0b55d91a582944", "furigana": "むき"}, {"key": "p10", "arti": "kotak", "kanji": "箱", "label": "はこ", "round": 1, "token": "2210303a30f96a36", "cardId": "391", "prompt": "箱", "correct": "2210303a30f96a36", "furigana": "はこ"}]}	2026-10-28 11:09:58.254009+00	2026-10-28 11:12:42.16773+00
8b4867bc-a0e2-4c2a-9ade-d973ebfb5348	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	done	{"mc": [{"key": "m1", "arti": "bersama", "kanji": "一緒", "cardId": "181", "prompt": "一緒", "correct": "181", "options": [{"id": "188", "label": "いんさつ"}, {"id": "342", "label": "きほんてきな"}, {"id": "181", "label": "いっしょ"}, {"id": "325", "label": "おす"}], "furigana": "いっしょ"}, {"key": "m2", "arti": "umum; masyarakat umum", "kanji": "一般", "cardId": "182", "prompt": "一般", "correct": "182", "options": [{"id": "182", "label": "いっぱん"}, {"id": "185", "label": "いなか"}, {"id": "236", "label": "かつどうてきな"}, {"id": "320", "label": "うめる"}], "furigana": "いっぱん"}, {"key": "m3", "arti": "perpindahan; bergerak", "kanji": "移動", "cardId": "183", "prompt": "移動", "correct": "183", "options": [{"id": "233", "label": "いっぱんてきな"}, {"id": "247", "label": "ぐうぜん"}, {"id": "183", "label": "いどう"}, {"id": "166", "label": "うで"}], "furigana": "いどう"}, {"key": "m4", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "cardId": "184", "prompt": "以内", "correct": "184", "options": [{"id": "318", "label": "うつ"}, {"id": "302", "label": "かかく"}, {"id": "184", "label": "いない"}, {"id": "263", "label": "おび"}], "furigana": "いない"}, {"key": "m5", "arti": "desa; pedesaan", "kanji": "田舎", "cardId": "185", "prompt": "田舎", "correct": "185", "options": [{"id": "335", "label": "うらやましい"}, {"id": "185", "label": "いなか"}, {"id": "263", "label": "おび"}, {"id": "280", "label": "さか"}], "furigana": "いなか"}, {"key": "m6", "arti": "ruang keluarga", "kanji": "居間", "cardId": "186", "prompt": "居間", "correct": "186", "options": [{"id": "327", "label": "おとす"}, {"id": "209", "label": "あらわす"}, {"id": "186", "label": "いま"}, {"id": "271", "label": "かた"}], "furigana": "いま"}, {"key": "m7", "arti": "arti; makna", "kanji": "意味", "cardId": "187", "prompt": "意味", "correct": "187", "options": [{"id": "323", "label": "おくれる"}, {"id": "184", "label": "いない"}, {"id": "187", "label": "いみ"}, {"id": "285", "label": "いぜん"}], "furigana": "いみ"}, {"key": "m8", "arti": "mencetak; pencetakan", "kanji": "印刷", "cardId": "188", "prompt": "印刷", "correct": "188", "options": [{"id": "204", "label": "あける"}, {"id": "349", "label": "さかんな"}, {"id": "188", "label": "いんさつ"}, {"id": "237", "label": "かのうな"}], "furigana": "いんさつ"}, {"key": "m9", "arti": "kesan", "kanji": "印象", "cardId": "189", "prompt": "印象", "correct": "189", "options": [{"id": "207", "label": "あたためる"}, {"id": "168", "label": "えだ"}, {"id": "189", "label": "いんしょう"}, {"id": "326", "label": "おちる"}], "furigana": "いんしょう"}, {"key": "m10", "arti": "makan dan minum", "kanji": "飲食", "cardId": "190", "prompt": "飲食", "correct": "190", "options": [{"id": "288", "label": "うけつけ"}, {"id": "303", "label": "かがく"}, {"id": "190", "label": "いんしょく"}, {"id": "203", "label": "あく"}], "furigana": "いんしょく"}], "typing": [{"key": "t1", "arti": "bersama", "kanji": "一緒", "cardId": "181", "prompt": "一緒", "furigana": "いっしょ", "answerKanji": "一緒", "answerFurigana": "いっしょ"}, {"key": "t2", "arti": "umum; masyarakat umum", "kanji": "一般", "cardId": "182", "prompt": "一般", "furigana": "いっぱん", "answerKanji": "一般", "answerFurigana": "いっぱん"}, {"key": "t3", "arti": "perpindahan; bergerak", "kanji": "移動", "cardId": "183", "prompt": "移動", "furigana": "いどう", "answerKanji": "移動", "answerFurigana": "いどう"}, {"key": "t4", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "cardId": "184", "prompt": "以内", "furigana": "いない", "answerKanji": "以内", "answerFurigana": "いない"}, {"key": "t5", "arti": "desa; pedesaan", "kanji": "田舎", "cardId": "185", "prompt": "田舎", "furigana": "いなか", "answerKanji": "田舎", "answerFurigana": "いなか"}, {"key": "t6", "arti": "ruang keluarga", "kanji": "居間", "cardId": "186", "prompt": "居間", "furigana": "いま", "answerKanji": "居間", "answerFurigana": "いま"}, {"key": "t7", "arti": "arti; makna", "kanji": "意味", "cardId": "187", "prompt": "意味", "furigana": "いみ", "answerKanji": "意味", "answerFurigana": "いみ"}, {"key": "t8", "arti": "mencetak; pencetakan", "kanji": "印刷", "cardId": "188", "prompt": "印刷", "furigana": "いんさつ", "answerKanji": "印刷", "answerFurigana": "いんさつ"}, {"key": "t9", "arti": "kesan", "kanji": "印象", "cardId": "189", "prompt": "印象", "furigana": "いんしょう", "answerKanji": "印象", "answerFurigana": "いんしょう"}, {"key": "t10", "arti": "makan dan minum", "kanji": "飲食", "cardId": "190", "prompt": "飲食", "furigana": "いんしょく", "answerKanji": "飲食", "answerFurigana": "いんしょく"}], "matching": [{"key": "p1", "arti": "bersama", "kanji": "一緒", "label": "いっしょ", "round": 0, "token": "2c37bf22ff9690e3", "cardId": "181", "prompt": "一緒", "correct": "2c37bf22ff9690e3", "furigana": "いっしょ"}, {"key": "p2", "arti": "umum; masyarakat umum", "kanji": "一般", "label": "いっぱん", "round": 0, "token": "23f50fdd82653e5c", "cardId": "182", "prompt": "一般", "correct": "23f50fdd82653e5c", "furigana": "いっぱん"}, {"key": "p3", "arti": "perpindahan; bergerak", "kanji": "移動", "label": "いどう", "round": 0, "token": "58a1e644673384d2", "cardId": "183", "prompt": "移動", "correct": "58a1e644673384d2", "furigana": "いどう"}, {"key": "p4", "arti": "dalam batas; tidak lebih dari", "kanji": "以内", "label": "いない", "round": 0, "token": "18a928f0fcfe3790", "cardId": "184", "prompt": "以内", "correct": "18a928f0fcfe3790", "furigana": "いない"}, {"key": "p5", "arti": "desa; pedesaan", "kanji": "田舎", "label": "いなか", "round": 0, "token": "d0c1384417171ef8", "cardId": "185", "prompt": "田舎", "correct": "d0c1384417171ef8", "furigana": "いなか"}, {"key": "p6", "arti": "ruang keluarga", "kanji": "居間", "label": "いま", "round": 1, "token": "857e8634b9226357", "cardId": "186", "prompt": "居間", "correct": "857e8634b9226357", "furigana": "いま"}, {"key": "p7", "arti": "arti; makna", "kanji": "意味", "label": "いみ", "round": 1, "token": "20306e766f629339", "cardId": "187", "prompt": "意味", "correct": "20306e766f629339", "furigana": "いみ"}, {"key": "p8", "arti": "mencetak; pencetakan", "kanji": "印刷", "label": "いんさつ", "round": 1, "token": "de6b0d9cbc254ce3", "cardId": "188", "prompt": "印刷", "correct": "de6b0d9cbc254ce3", "furigana": "いんさつ"}, {"key": "p9", "arti": "kesan", "kanji": "印象", "label": "いんしょう", "round": 1, "token": "249470e7e4556005", "cardId": "189", "prompt": "印象", "correct": "249470e7e4556005", "furigana": "いんしょう"}, {"key": "p10", "arti": "makan dan minum", "kanji": "飲食", "label": "いんしょく", "round": 1, "token": "ff277bcebb75e883", "cardId": "190", "prompt": "飲食", "correct": "ff277bcebb75e883", "furigana": "いんしょく"}]}	2026-10-28 12:08:38.733107+00	2026-10-28 12:11:29.218395+00
f85ac244-fb75-4266-bcd1-f640485383f5	31aee3c9-d101-456c-82f0-0d0063777d02	done	{"mc": [{"key": "m1", "arti": "kepercayaan diri", "kanji": "自信", "cardId": "392", "prompt": "自信", "correct": "392", "options": [{"id": "378", "label": "ことわる"}, {"id": "392", "label": "じしん"}, {"id": "385", "label": "おしぼたんしき"}, {"id": "398", "label": "かんする"}], "furigana": "じしん"}, {"key": "m2", "arti": "percaya", "kanji": "信じる", "cardId": "393", "prompt": "信じる", "correct": "393", "options": [{"id": "393", "label": "しんじる"}, {"id": "386", "label": "すうしき"}, {"id": "397", "label": "かんしん"}, {"id": "400", "label": "かかり"}], "furigana": "しんじる"}, {"key": "m3", "arti": "kepercayaan", "kanji": "信用", "cardId": "394", "prompt": "信用", "correct": "394", "options": [{"id": "394", "label": "しんよう"}, {"id": "398", "label": "かんする"}, {"id": "409", "label": "ひじょうに"}, {"id": "388", "label": "ほうこう"}], "furigana": "しんよう"}, {"key": "m4", "arti": "lampu lalu lintas", "kanji": "信号", "cardId": "395", "prompt": "信号", "correct": "395", "options": [{"id": "369", "label": "とぶ"}, {"id": "401", "label": "きんし"}, {"id": "395", "label": "しんごう"}, {"id": "407", "label": "ひじょう"}], "furigana": "しんごう"}, {"key": "m5", "arti": "mengirim pesan/data", "kanji": "送信", "cardId": "396", "prompt": "送信", "correct": "396", "options": [{"id": "396", "label": "そうしん"}, {"id": "369", "label": "とぶ"}, {"id": "410", "label": "にちじょう"}, {"id": "365", "label": "ごうしゃ"}], "furigana": "そうしん"}, {"key": "m6", "arti": "minat / ketertarikan", "kanji": "関心", "cardId": "397", "prompt": "関心", "correct": "397", "options": [{"id": "374", "label": "むりな"}, {"id": "366", "label": "まんいん"}, {"id": "406", "label": "みとめる"}, {"id": "397", "label": "かんしん"}], "furigana": "かんしん"}, {"key": "m7", "arti": "mengenai / berhubungan dengan", "kanji": "関する", "cardId": "398", "prompt": "関する", "correct": "398", "options": [{"id": "398", "label": "かんする"}, {"id": "402", "label": "せいかくな"}, {"id": "390", "label": "むき"}, {"id": "375", "label": "ない"}], "furigana": "かんする"}, {"key": "m8", "arti": "hubungan", "kanji": "関係", "cardId": "399", "prompt": "関係", "correct": "399", "options": [{"id": "399", "label": "かんけい"}, {"id": "398", "label": "かんする"}, {"id": "390", "label": "むき"}, {"id": "369", "label": "とぶ"}], "furigana": "かんけい"}, {"key": "m9", "arti": "orang yang bertanggung jawab", "kanji": "係", "cardId": "400", "prompt": "係", "correct": "400", "options": [{"id": "377", "label": "だんすい"}, {"id": "407", "label": "ひじょう"}, {"id": "396", "label": "そうしん"}, {"id": "400", "label": "かかり"}], "furigana": "かかり"}, {"key": "m10", "arti": "larangan", "kanji": "禁止", "cardId": "401", "prompt": "禁止", "correct": "401", "options": [{"id": "401", "label": "きんし"}, {"id": "409", "label": "ひじょうに"}, {"id": "392", "label": "じしん"}, {"id": "365", "label": "ごうしゃ"}], "furigana": "きんし"}], "typing": [{"key": "t1", "arti": "kepercayaan diri", "kanji": "自信", "cardId": "392", "prompt": "自信", "furigana": "じしん", "answerKanji": "自信", "answerFurigana": "じしん"}, {"key": "t2", "arti": "percaya", "kanji": "信じる", "cardId": "393", "prompt": "信じる", "furigana": "しんじる", "answerKanji": "信じる", "answerFurigana": "しんじる"}, {"key": "t3", "arti": "kepercayaan", "kanji": "信用", "cardId": "394", "prompt": "信用", "furigana": "しんよう", "answerKanji": "信用", "answerFurigana": "しんよう"}, {"key": "t4", "arti": "lampu lalu lintas", "kanji": "信号", "cardId": "395", "prompt": "信号", "furigana": "しんごう", "answerKanji": "信号", "answerFurigana": "しんごう"}, {"key": "t5", "arti": "mengirim pesan/data", "kanji": "送信", "cardId": "396", "prompt": "送信", "furigana": "そうしん", "answerKanji": "送信", "answerFurigana": "そうしん"}, {"key": "t6", "arti": "minat / ketertarikan", "kanji": "関心", "cardId": "397", "prompt": "関心", "furigana": "かんしん", "answerKanji": "関心", "answerFurigana": "かんしん"}, {"key": "t7", "arti": "mengenai / berhubungan dengan", "kanji": "関する", "cardId": "398", "prompt": "関する", "furigana": "かんする", "answerKanji": "関する", "answerFurigana": "かんする"}, {"key": "t8", "arti": "hubungan", "kanji": "関係", "cardId": "399", "prompt": "関係", "furigana": "かんけい", "answerKanji": "関係", "answerFurigana": "かんけい"}, {"key": "t9", "arti": "orang yang bertanggung jawab", "kanji": "係", "cardId": "400", "prompt": "係", "furigana": "かかり", "answerKanji": "係", "answerFurigana": "かかり"}, {"key": "t10", "arti": "larangan", "kanji": "禁止", "cardId": "401", "prompt": "禁止", "furigana": "きんし", "answerKanji": "禁止", "answerFurigana": "きんし"}], "matching": [{"key": "p1", "arti": "kepercayaan diri", "kanji": "自信", "label": "じしん", "round": 0, "token": "4a507ae00f8fa4c3", "cardId": "392", "prompt": "自信", "correct": "4a507ae00f8fa4c3", "furigana": "じしん"}, {"key": "p2", "arti": "percaya", "kanji": "信じる", "label": "しんじる", "round": 0, "token": "61471704c5b54948", "cardId": "393", "prompt": "信じる", "correct": "61471704c5b54948", "furigana": "しんじる"}, {"key": "p3", "arti": "kepercayaan", "kanji": "信用", "label": "しんよう", "round": 0, "token": "bdb81ac725a085c8", "cardId": "394", "prompt": "信用", "correct": "bdb81ac725a085c8", "furigana": "しんよう"}, {"key": "p4", "arti": "lampu lalu lintas", "kanji": "信号", "label": "しんごう", "round": 0, "token": "762c5ce81f110b51", "cardId": "395", "prompt": "信号", "correct": "762c5ce81f110b51", "furigana": "しんごう"}, {"key": "p5", "arti": "mengirim pesan/data", "kanji": "送信", "label": "そうしん", "round": 0, "token": "65b408655104e8db", "cardId": "396", "prompt": "送信", "correct": "65b408655104e8db", "furigana": "そうしん"}, {"key": "p6", "arti": "minat / ketertarikan", "kanji": "関心", "label": "かんしん", "round": 1, "token": "a4b47b343b3a2529", "cardId": "397", "prompt": "関心", "correct": "a4b47b343b3a2529", "furigana": "かんしん"}, {"key": "p7", "arti": "mengenai / berhubungan dengan", "kanji": "関する", "label": "かんする", "round": 1, "token": "12e085084c17e0c4", "cardId": "398", "prompt": "関する", "correct": "12e085084c17e0c4", "furigana": "かんする"}, {"key": "p8", "arti": "hubungan", "kanji": "関係", "label": "かんけい", "round": 1, "token": "118b1d432bf1e32e", "cardId": "399", "prompt": "関係", "correct": "118b1d432bf1e32e", "furigana": "かんけい"}, {"key": "p9", "arti": "orang yang bertanggung jawab", "kanji": "係", "label": "かかり", "round": 1, "token": "52f5cb484ad1f160", "cardId": "400", "prompt": "係", "correct": "52f5cb484ad1f160", "furigana": "かかり"}, {"key": "p10", "arti": "larangan", "kanji": "禁止", "label": "きんし", "round": 1, "token": "9e224520eff30e7e", "cardId": "401", "prompt": "禁止", "correct": "9e224520eff30e7e", "furigana": "きんし"}]}	2026-10-28 12:13:17.791626+00	2026-10-28 12:18:11.192272+00
d4484e9e-ed96-4a36-903c-4855ae84b9a6	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	done	{"mc": [{"key": "m1", "arti": "gratis", "kanji": "無料", "cardId": "373", "prompt": "無料", "correct": "373", "options": [{"id": "387", "label": "にゅうがくしき"}, {"id": "373", "label": "むりょう"}, {"id": "385", "label": "おしぼたんしき"}, {"id": "367", "label": "ふまんな"}], "furigana": "むりょう"}, {"key": "m2", "arti": "mustahil / dipaksakan", "kanji": "無理な", "cardId": "374", "prompt": "無理な", "correct": "374", "options": [{"id": "374", "label": "むりな"}, {"id": "392", "label": "じしん"}, {"id": "398", "label": "かんする"}, {"id": "364", "label": "まんしゃ"}], "furigana": "むりな"}, {"key": "m3", "arti": "tidak ada", "kanji": "無い", "cardId": "375", "prompt": "無い", "correct": "375", "options": [{"id": "398", "label": "かんする"}, {"id": "379", "label": "おうだん"}, {"id": "370", "label": "かい"}, {"id": "375", "label": "ない"}], "furigana": "ない"}, {"key": "m4", "arti": "tanpa izin", "kanji": "無断", "cardId": "376", "prompt": "無断", "correct": "376", "options": [{"id": "376", "label": "むだん"}, {"id": "377", "label": "だんすい"}, {"id": "411", "label": "せいじょうな"}, {"id": "386", "label": "すうしき"}], "furigana": "むだん"}, {"key": "m5", "arti": "pemutusan air / mati air", "kanji": "断水", "cardId": "377", "prompt": "断水", "correct": "377", "options": [{"id": "375", "label": "ない"}, {"id": "400", "label": "かかり"}, {"id": "389", "label": "むかう"}, {"id": "377", "label": "だんすい"}], "furigana": "だんすい"}, {"key": "m6", "arti": "menolak", "kanji": "断る", "cardId": "378", "prompt": "断る", "correct": "378", "options": [{"id": "371", "label": "かいだん"}, {"id": "392", "label": "じしん"}, {"id": "367", "label": "ふまんな"}, {"id": "378", "label": "ことわる"}], "furigana": "ことわる"}, {"key": "m7", "arti": "penyeberangan", "kanji": "横断", "cardId": "379", "prompt": "横断", "correct": "379", "options": [{"id": "362", "label": "ちゅうしゃじょう"}, {"id": "368", "label": "ひこうじょう"}, {"id": "379", "label": "おうだん"}, {"id": "364", "label": "まんしゃ"}], "furigana": "おうだん"}, {"key": "m8", "arti": "zebra cross", "kanji": "横断歩道", "cardId": "380", "prompt": "横断歩道", "correct": "380", "options": [{"id": "392", "label": "じしん"}, {"id": "406", "label": "みとめる"}, {"id": "380", "label": "おうだんほどう"}, {"id": "368", "label": "ひこうじょう"}], "furigana": "おうだんほどう"}, {"key": "m9", "arti": "samping", "kanji": "横", "cardId": "381", "prompt": "横", "correct": "381", "options": [{"id": "381", "label": "よこ"}, {"id": "368", "label": "ひこうじょう"}, {"id": "400", "label": "かかり"}, {"id": "410", "label": "にちじょう"}], "furigana": "よこ"}, {"key": "m10", "arti": "tidak ada hari libur", "kanji": "無休", "cardId": "372", "prompt": "無休", "correct": "372", "options": [{"id": "396", "label": "そうしん"}, {"id": "372", "label": "むきゅう"}, {"id": "399", "label": "かんけい"}, {"id": "367", "label": "ふまんな"}], "furigana": "むきゅう"}], "typing": [{"key": "t1", "arti": "gratis", "kanji": "無料", "cardId": "373", "prompt": "無料", "furigana": "むりょう", "answerKanji": "無料", "answerFurigana": "むりょう"}, {"key": "t2", "arti": "mustahil / dipaksakan", "kanji": "無理な", "cardId": "374", "prompt": "無理な", "furigana": "むりな", "answerKanji": "無理な", "answerFurigana": "むりな"}, {"key": "t3", "arti": "tidak ada", "kanji": "無い", "cardId": "375", "prompt": "無い", "furigana": "ない", "answerKanji": "無い", "answerFurigana": "ない"}, {"key": "t4", "arti": "tanpa izin", "kanji": "無断", "cardId": "376", "prompt": "無断", "furigana": "むだん", "answerKanji": "無断", "answerFurigana": "むだん"}, {"key": "t5", "arti": "pemutusan air / mati air", "kanji": "断水", "cardId": "377", "prompt": "断水", "furigana": "だんすい", "answerKanji": "断水", "answerFurigana": "だんすい"}, {"key": "t6", "arti": "menolak", "kanji": "断る", "cardId": "378", "prompt": "断る", "furigana": "ことわる", "answerKanji": "断る", "answerFurigana": "ことわる"}, {"key": "t7", "arti": "penyeberangan", "kanji": "横断", "cardId": "379", "prompt": "横断", "furigana": "おうだん", "answerKanji": "横断", "answerFurigana": "おうだん"}, {"key": "t8", "arti": "zebra cross", "kanji": "横断歩道", "cardId": "380", "prompt": "横断歩道", "furigana": "おうだんほどう", "answerKanji": "横断歩道", "answerFurigana": "おうだんほどう"}, {"key": "t9", "arti": "samping", "kanji": "横", "cardId": "381", "prompt": "横", "furigana": "よこ", "answerKanji": "横", "answerFurigana": "よこ"}, {"key": "t10", "arti": "tidak ada hari libur", "kanji": "無休", "cardId": "372", "prompt": "無休", "furigana": "むきゅう", "answerKanji": "無休", "answerFurigana": "むきゅう"}], "matching": [{"key": "p1", "arti": "gratis", "kanji": "無料", "label": "むりょう", "round": 0, "token": "f5089174845886a5", "cardId": "373", "prompt": "無料", "correct": "f5089174845886a5", "furigana": "むりょう"}, {"key": "p2", "arti": "mustahil / dipaksakan", "kanji": "無理な", "label": "むりな", "round": 0, "token": "8ae113e155bb9e3a", "cardId": "374", "prompt": "無理な", "correct": "8ae113e155bb9e3a", "furigana": "むりな"}, {"key": "p3", "arti": "tidak ada", "kanji": "無い", "label": "ない", "round": 0, "token": "50f447b7d9bae862", "cardId": "375", "prompt": "無い", "correct": "50f447b7d9bae862", "furigana": "ない"}, {"key": "p4", "arti": "tanpa izin", "kanji": "無断", "label": "むだん", "round": 0, "token": "973af942ee12173e", "cardId": "376", "prompt": "無断", "correct": "973af942ee12173e", "furigana": "むだん"}, {"key": "p5", "arti": "pemutusan air / mati air", "kanji": "断水", "label": "だんすい", "round": 0, "token": "3934d9e7d45de66a", "cardId": "377", "prompt": "断水", "correct": "3934d9e7d45de66a", "furigana": "だんすい"}, {"key": "p6", "arti": "menolak", "kanji": "断る", "label": "ことわる", "round": 1, "token": "f7007dbbffa02f9c", "cardId": "378", "prompt": "断る", "correct": "f7007dbbffa02f9c", "furigana": "ことわる"}, {"key": "p7", "arti": "penyeberangan", "kanji": "横断", "label": "おうだん", "round": 1, "token": "224c1468f7a2935e", "cardId": "379", "prompt": "横断", "correct": "224c1468f7a2935e", "furigana": "おうだん"}, {"key": "p8", "arti": "zebra cross", "kanji": "横断歩道", "label": "おうだんほどう", "round": 1, "token": "a5bfb76b615bf228", "cardId": "380", "prompt": "横断歩道", "correct": "a5bfb76b615bf228", "furigana": "おうだんほどう"}, {"key": "p9", "arti": "samping", "kanji": "横", "label": "よこ", "round": 1, "token": "451e80a5a5078c0c", "cardId": "381", "prompt": "横", "correct": "451e80a5a5078c0c", "furigana": "よこ"}, {"key": "p10", "arti": "tidak ada hari libur", "kanji": "無休", "label": "むきゅう", "round": 1, "token": "bf8dcc6b5673f3f2", "cardId": "372", "prompt": "無休", "correct": "bf8dcc6b5673f3f2", "furigana": "むきゅう"}]}	2026-11-07 14:25:07.307095+00	2026-11-07 14:26:47.967982+00
b97b95b6-4f85-44ee-b886-d47fc9089d68	fa5a2807-b42d-4946-91b3-8ac41b4be778	done	{"mc": [{"key": "m1", "arti": "parkir", "kanji": "駐車", "cardId": "363", "prompt": "駐車", "correct": "363", "options": [{"id": "400", "label": "かかり"}, {"id": "408", "label": "ひじょうぐち"}, {"id": "363", "label": "ちゅうしゃ"}, {"id": "373", "label": "むりょう"}], "furigana": "ちゅうしゃ"}, {"key": "m2", "arti": "parkir penuh", "kanji": "満車", "cardId": "364", "prompt": "満車", "correct": "364", "options": [{"id": "383", "label": "おしいれ"}, {"id": "364", "label": "まんしゃ"}, {"id": "367", "label": "ふまんな"}, {"id": "389", "label": "むかう"}], "furigana": "まんしゃ"}, {"key": "m3", "arti": "terbang", "kanji": "飛ぶ", "cardId": "369", "prompt": "飛ぶ", "correct": "369", "options": [{"id": "398", "label": "かんする"}, {"id": "362", "label": "ちゅうしゃじょう"}, {"id": "379", "label": "おうだん"}, {"id": "369", "label": "とぶ"}], "furigana": "とぶ"}, {"key": "m4", "arti": "penuh orang", "kanji": "満員", "cardId": "366", "prompt": "満員", "correct": "366", "options": [{"id": "388", "label": "ほうこう"}, {"id": "380", "label": "おうだんほどう"}, {"id": "393", "label": "しんじる"}, {"id": "366", "label": "まんいん"}], "furigana": "まんいん"}, {"key": "m5", "arti": "tidak puas", "kanji": "不満な", "cardId": "367", "prompt": "不満な", "correct": "367", "options": [{"id": "376", "label": "むだん"}, {"id": "367", "label": "ふまんな"}, {"id": "393", "label": "しんじる"}, {"id": "409", "label": "ひじょうに"}], "furigana": "ふまんな"}, {"key": "m6", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "cardId": "368", "prompt": "飛行場", "correct": "368", "options": [{"id": "397", "label": "かんしん"}, {"id": "368", "label": "ひこうじょう"}, {"id": "380", "label": "おうだんほどう"}, {"id": "385", "label": "おしぼたんしき"}], "furigana": "ひこうじょう"}, {"key": "m7", "arti": "gerbong nomor ~", "kanji": "号車", "cardId": "365", "prompt": "号車", "correct": "365", "options": [{"id": "373", "label": "むりょう"}, {"id": "377", "label": "だんすい"}, {"id": "365", "label": "ごうしゃ"}, {"id": "368", "label": "ひこうじょう"}], "furigana": "ごうしゃ"}, {"key": "m8", "arti": "lantai", "kanji": "階", "cardId": "370", "prompt": "階", "correct": "370", "options": [{"id": "370", "label": "かい"}, {"id": "405", "label": "かくにん"}, {"id": "402", "label": "せいかくな"}, {"id": "364", "label": "まんしゃ"}], "furigana": "かい"}, {"key": "m9", "arti": "tangga", "kanji": "階段", "cardId": "371", "prompt": "階段", "correct": "371", "options": [{"id": "401", "label": "きんし"}, {"id": "380", "label": "おうだんほどう"}, {"id": "365", "label": "ごうしゃ"}, {"id": "371", "label": "かいだん"}], "furigana": "かいだん"}, {"key": "m10", "arti": "tempat parkir", "kanji": "駐車場", "cardId": "362", "prompt": "駐車場", "correct": "362", "options": [{"id": "388", "label": "ほうこう"}, {"id": "362", "label": "ちゅうしゃじょう"}, {"id": "405", "label": "かくにん"}, {"id": "390", "label": "むき"}], "furigana": "ちゅうしゃじょう"}], "typing": [{"key": "t1", "arti": "parkir", "kanji": "駐車", "cardId": "363", "prompt": "駐車", "furigana": "ちゅうしゃ", "answerKanji": "駐車", "answerFurigana": "ちゅうしゃ"}, {"key": "t2", "arti": "parkir penuh", "kanji": "満車", "cardId": "364", "prompt": "満車", "furigana": "まんしゃ", "answerKanji": "満車", "answerFurigana": "まんしゃ"}, {"key": "t3", "arti": "terbang", "kanji": "飛ぶ", "cardId": "369", "prompt": "飛ぶ", "furigana": "とぶ", "answerKanji": "飛ぶ", "answerFurigana": "とぶ"}, {"key": "t4", "arti": "penuh orang", "kanji": "満員", "cardId": "366", "prompt": "満員", "furigana": "まんいん", "answerKanji": "満員", "answerFurigana": "まんいん"}, {"key": "t5", "arti": "tidak puas", "kanji": "不満な", "cardId": "367", "prompt": "不満な", "furigana": "ふまんな", "answerKanji": "不満な", "answerFurigana": "ふまんな"}, {"key": "t6", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "cardId": "368", "prompt": "飛行場", "furigana": "ひこうじょう", "answerKanji": "飛行場", "answerFurigana": "ひこうじょう"}, {"key": "t7", "arti": "gerbong nomor ~", "kanji": "号車", "cardId": "365", "prompt": "号車", "furigana": "ごうしゃ", "answerKanji": "号車", "answerFurigana": "ごうしゃ"}, {"key": "t8", "arti": "lantai", "kanji": "階", "cardId": "370", "prompt": "階", "furigana": "かい", "answerKanji": "階", "answerFurigana": "かい"}, {"key": "t9", "arti": "tangga", "kanji": "階段", "cardId": "371", "prompt": "階段", "furigana": "かいだん", "answerKanji": "階段", "answerFurigana": "かいだん"}, {"key": "t10", "arti": "tempat parkir", "kanji": "駐車場", "cardId": "362", "prompt": "駐車場", "furigana": "ちゅうしゃじょう", "answerKanji": "駐車場", "answerFurigana": "ちゅうしゃじょう"}], "matching": [{"key": "p1", "arti": "parkir", "kanji": "駐車", "label": "ちゅうしゃ", "round": 0, "token": "86caa497428178c8", "cardId": "363", "prompt": "駐車", "correct": "86caa497428178c8", "furigana": "ちゅうしゃ"}, {"key": "p2", "arti": "parkir penuh", "kanji": "満車", "label": "まんしゃ", "round": 0, "token": "12978ccedbe5daba", "cardId": "364", "prompt": "満車", "correct": "12978ccedbe5daba", "furigana": "まんしゃ"}, {"key": "p3", "arti": "terbang", "kanji": "飛ぶ", "label": "とぶ", "round": 0, "token": "6312df95ee6528c2", "cardId": "369", "prompt": "飛ぶ", "correct": "6312df95ee6528c2", "furigana": "とぶ"}, {"key": "p4", "arti": "penuh orang", "kanji": "満員", "label": "まんいん", "round": 0, "token": "ccde07434197a0d0", "cardId": "366", "prompt": "満員", "correct": "ccde07434197a0d0", "furigana": "まんいん"}, {"key": "p5", "arti": "tidak puas", "kanji": "不満な", "label": "ふまんな", "round": 0, "token": "b2e0c6c91fd1535d", "cardId": "367", "prompt": "不満な", "correct": "b2e0c6c91fd1535d", "furigana": "ふまんな"}, {"key": "p6", "arti": "lapangan terbang / bandara", "kanji": "飛行場", "label": "ひこうじょう", "round": 1, "token": "5acf645bb6997283", "cardId": "368", "prompt": "飛行場", "correct": "5acf645bb6997283", "furigana": "ひこうじょう"}, {"key": "p7", "arti": "gerbong nomor ~", "kanji": "号車", "label": "ごうしゃ", "round": 1, "token": "c2ae321b3f40f668", "cardId": "365", "prompt": "号車", "correct": "c2ae321b3f40f668", "furigana": "ごうしゃ"}, {"key": "p8", "arti": "lantai", "kanji": "階", "label": "かい", "round": 1, "token": "88560e8686f5e792", "cardId": "370", "prompt": "階", "correct": "88560e8686f5e792", "furigana": "かい"}, {"key": "p9", "arti": "tangga", "kanji": "階段", "label": "かいだん", "round": 1, "token": "c79942214f467962", "cardId": "371", "prompt": "階段", "correct": "c79942214f467962", "furigana": "かいだん"}, {"key": "p10", "arti": "tempat parkir", "kanji": "駐車場", "label": "ちゅうしゃじょう", "round": 1, "token": "4dd8cbc8fd35635e", "cardId": "362", "prompt": "駐車場", "correct": "4dd8cbc8fd35635e", "furigana": "ちゅうしゃじょう"}]}	2026-11-07 14:27:15.728172+00	2026-11-07 14:29:57.256053+00
3a90c644-b5bf-4ec0-8295-d80e5b652486	5c969fdd-acc6-4935-a45b-78feb35fd488	done	{"mc": [{"key": "m1", "arti": "menekan", "kanji": "押す", "cardId": "382", "prompt": "押す", "correct": "382", "options": [{"id": "381", "label": "よこ"}, {"id": "386", "label": "すうしき"}, {"id": "382", "label": "おす"}, {"id": "407", "label": "ひじょう"}], "furigana": "おす"}, {"key": "m2", "arti": "lemari dinding bergaya Jepang", "kanji": "押し入れ", "cardId": "383", "prompt": "押し入れ", "correct": "383", "options": [{"id": "383", "label": "おしいれ"}, {"id": "378", "label": "ことわる"}, {"id": "411", "label": "せいじょうな"}, {"id": "401", "label": "きんし"}], "furigana": "おしいれ"}, {"key": "m3", "arti": "menahan / menekan", "kanji": "押さえる", "cardId": "384", "prompt": "押さえる", "correct": "384", "options": [{"id": "382", "label": "おす"}, {"id": "384", "label": "おさえる"}, {"id": "386", "label": "すうしき"}, {"id": "379", "label": "おうだん"}], "furigana": "おさえる"}, {"key": "m4", "arti": "tipe tombol tekan", "kanji": "押しボタン式", "cardId": "385", "prompt": "押しボタン式", "correct": "385", "options": [{"id": "385", "label": "おしぼたんしき"}, {"id": "394", "label": "しんよう"}, {"id": "365", "label": "ごうしゃ"}, {"id": "387", "label": "にゅうがくしき"}], "furigana": "おしぼたんしき"}, {"key": "m5", "arti": "rumus matematika", "kanji": "数式", "cardId": "386", "prompt": "数式", "correct": "386", "options": [{"id": "364", "label": "まんしゃ"}, {"id": "386", "label": "すうしき"}, {"id": "387", "label": "にゅうがくしき"}, {"id": "401", "label": "きんし"}], "furigana": "すうしき"}, {"key": "m6", "arti": "upacara masuk sekolah", "kanji": "入学式", "cardId": "387", "prompt": "入学式", "correct": "387", "options": [{"id": "387", "label": "にゅうがくしき"}, {"id": "394", "label": "しんよう"}, {"id": "393", "label": "しんじる"}, {"id": "383", "label": "おしいれ"}], "furigana": "にゅうがくしき"}, {"key": "m7", "arti": "arah", "kanji": "方向", "cardId": "388", "prompt": "方向", "correct": "388", "options": [{"id": "363", "label": "ちゅうしゃ"}, {"id": "395", "label": "しんごう"}, {"id": "388", "label": "ほうこう"}, {"id": "386", "label": "すうしき"}], "furigana": "ほうこう"}, {"key": "m8", "arti": "menuju", "kanji": "向かう", "cardId": "389", "prompt": "向かう", "correct": "389", "options": [{"id": "373", "label": "むりょう"}, {"id": "404", "label": "たしかめる"}, {"id": "389", "label": "むかう"}, {"id": "402", "label": "せいかくな"}], "furigana": "むかう"}, {"key": "m9", "arti": "cocok untuk / menghadap", "kanji": "向き", "cardId": "390", "prompt": "向き", "correct": "390", "options": [{"id": "390", "label": "むき"}, {"id": "377", "label": "だんすい"}, {"id": "399", "label": "かんけい"}, {"id": "391", "label": "はこ"}], "furigana": "むき"}, {"key": "m10", "arti": "kotak", "kanji": "箱", "cardId": "391", "prompt": "箱", "correct": "391", "options": [{"id": "391", "label": "はこ"}, {"id": "362", "label": "ちゅうしゃじょう"}, {"id": "374", "label": "むりな"}, {"id": "403", "label": "たしかな"}], "furigana": "はこ"}], "typing": [{"key": "t1", "arti": "menekan", "kanji": "押す", "cardId": "382", "prompt": "押す", "furigana": "おす", "answerKanji": "押す", "answerFurigana": "おす"}, {"key": "t2", "arti": "lemari dinding bergaya Jepang", "kanji": "押し入れ", "cardId": "383", "prompt": "押し入れ", "furigana": "おしいれ", "answerKanji": "押し入れ", "answerFurigana": "おしいれ"}, {"key": "t3", "arti": "menahan / menekan", "kanji": "押さえる", "cardId": "384", "prompt": "押さえる", "furigana": "おさえる", "answerKanji": "押さえる", "answerFurigana": "おさえる"}, {"key": "t4", "arti": "tipe tombol tekan", "kanji": "押しボタン式", "cardId": "385", "prompt": "押しボタン式", "furigana": "おしぼたんしき", "answerKanji": "押しボタン式", "answerFurigana": "おしぼたんしき"}, {"key": "t5", "arti": "rumus matematika", "kanji": "数式", "cardId": "386", "prompt": "数式", "furigana": "すうしき", "answerKanji": "数式", "answerFurigana": "すうしき"}, {"key": "t6", "arti": "upacara masuk sekolah", "kanji": "入学式", "cardId": "387", "prompt": "入学式", "furigana": "にゅうがくしき", "answerKanji": "入学式", "answerFurigana": "にゅうがくしき"}, {"key": "t7", "arti": "arah", "kanji": "方向", "cardId": "388", "prompt": "方向", "furigana": "ほうこう", "answerKanji": "方向", "answerFurigana": "ほうこう"}, {"key": "t8", "arti": "menuju", "kanji": "向かう", "cardId": "389", "prompt": "向かう", "furigana": "むかう", "answerKanji": "向かう", "answerFurigana": "むかう"}, {"key": "t9", "arti": "cocok untuk / menghadap", "kanji": "向き", "cardId": "390", "prompt": "向き", "furigana": "むき", "answerKanji": "向き", "answerFurigana": "むき"}, {"key": "t10", "arti": "kotak", "kanji": "箱", "cardId": "391", "prompt": "箱", "furigana": "はこ", "answerKanji": "箱", "answerFurigana": "はこ"}], "matching": [{"key": "p1", "arti": "menekan", "kanji": "押す", "label": "おす", "round": 0, "token": "2a52fef5dd55b87a", "cardId": "382", "prompt": "押す", "correct": "2a52fef5dd55b87a", "furigana": "おす"}, {"key": "p2", "arti": "lemari dinding bergaya Jepang", "kanji": "押し入れ", "label": "おしいれ", "round": 0, "token": "06efce85bdf1db26", "cardId": "383", "prompt": "押し入れ", "correct": "06efce85bdf1db26", "furigana": "おしいれ"}, {"key": "p3", "arti": "menahan / menekan", "kanji": "押さえる", "label": "おさえる", "round": 0, "token": "8b7e9599ec535356", "cardId": "384", "prompt": "押さえる", "correct": "8b7e9599ec535356", "furigana": "おさえる"}, {"key": "p4", "arti": "tipe tombol tekan", "kanji": "押しボタン式", "label": "おしぼたんしき", "round": 0, "token": "984e5187a183de19", "cardId": "385", "prompt": "押しボタン式", "correct": "984e5187a183de19", "furigana": "おしぼたんしき"}, {"key": "p5", "arti": "rumus matematika", "kanji": "数式", "label": "すうしき", "round": 0, "token": "e61f44c34bba22e5", "cardId": "386", "prompt": "数式", "correct": "e61f44c34bba22e5", "furigana": "すうしき"}, {"key": "p6", "arti": "upacara masuk sekolah", "kanji": "入学式", "label": "にゅうがくしき", "round": 1, "token": "e318c5d855e32ec0", "cardId": "387", "prompt": "入学式", "correct": "e318c5d855e32ec0", "furigana": "にゅうがくしき"}, {"key": "p7", "arti": "arah", "kanji": "方向", "label": "ほうこう", "round": 1, "token": "df3ff36a5ac5490e", "cardId": "388", "prompt": "方向", "correct": "df3ff36a5ac5490e", "furigana": "ほうこう"}, {"key": "p8", "arti": "menuju", "kanji": "向かう", "label": "むかう", "round": 1, "token": "b73fd600b1432dee", "cardId": "389", "prompt": "向かう", "correct": "b73fd600b1432dee", "furigana": "むかう"}, {"key": "p9", "arti": "cocok untuk / menghadap", "kanji": "向き", "label": "むき", "round": 1, "token": "0aac2aa191963f80", "cardId": "390", "prompt": "向き", "correct": "0aac2aa191963f80", "furigana": "むき"}, {"key": "p10", "arti": "kotak", "kanji": "箱", "label": "はこ", "round": 1, "token": "68eb6b714b1cfdda", "cardId": "391", "prompt": "箱", "correct": "68eb6b714b1cfdda", "furigana": "はこ"}]}	2026-11-07 14:30:24.76792+00	2026-11-07 14:32:15.560783+00
bf900f1f-c6b9-4780-afc7-6faccbe593ed	9543c75b-2a7c-41eb-8f4c-f917b466b5f6	typing	{"mc": [{"key": "m1", "arti": "kepercayaan diri", "kanji": "自信", "cardId": "392", "prompt": "自信", "correct": "392", "options": [{"id": "392", "label": "じしん"}, {"id": "376", "label": "むだん"}, {"id": "369", "label": "とぶ"}, {"id": "409", "label": "ひじょうに"}], "furigana": "じしん"}, {"key": "m2", "arti": "percaya", "kanji": "信じる", "cardId": "393", "prompt": "信じる", "correct": "393", "options": [{"id": "371", "label": "かいだん"}, {"id": "365", "label": "ごうしゃ"}, {"id": "381", "label": "よこ"}, {"id": "393", "label": "しんじる"}], "furigana": "しんじる"}, {"key": "m3", "arti": "kepercayaan", "kanji": "信用", "cardId": "394", "prompt": "信用", "correct": "394", "options": [{"id": "364", "label": "まんしゃ"}, {"id": "401", "label": "きんし"}, {"id": "372", "label": "むきゅう"}, {"id": "394", "label": "しんよう"}], "furigana": "しんよう"}, {"key": "m4", "arti": "lampu lalu lintas", "kanji": "信号", "cardId": "395", "prompt": "信号", "correct": "395", "options": [{"id": "409", "label": "ひじょうに"}, {"id": "371", "label": "かいだん"}, {"id": "410", "label": "にちじょう"}, {"id": "395", "label": "しんごう"}], "furigana": "しんごう"}, {"key": "m5", "arti": "mengirim pesan/data", "kanji": "送信", "cardId": "396", "prompt": "送信", "correct": "396", "options": [{"id": "406", "label": "みとめる"}, {"id": "386", "label": "すうしき"}, {"id": "370", "label": "かい"}, {"id": "396", "label": "そうしん"}], "furigana": "そうしん"}, {"key": "m6", "arti": "minat / ketertarikan", "kanji": "関心", "cardId": "397", "prompt": "関心", "correct": "397", "options": [{"id": "409", "label": "ひじょうに"}, {"id": "397", "label": "かんしん"}, {"id": "364", "label": "まんしゃ"}, {"id": "373", "label": "むりょう"}], "furigana": "かんしん"}, {"key": "m7", "arti": "mengenai / berhubungan dengan", "kanji": "関する", "cardId": "398", "prompt": "関する", "correct": "398", "options": [{"id": "372", "label": "むきゅう"}, {"id": "410", "label": "にちじょう"}, {"id": "398", "label": "かんする"}, {"id": "406", "label": "みとめる"}], "furigana": "かんする"}, {"key": "m8", "arti": "hubungan", "kanji": "関係", "cardId": "399", "prompt": "関係", "correct": "399", "options": [{"id": "368", "label": "ひこうじょう"}, {"id": "398", "label": "かんする"}, {"id": "399", "label": "かんけい"}, {"id": "391", "label": "はこ"}], "furigana": "かんけい"}, {"key": "m9", "arti": "orang yang bertanggung jawab", "kanji": "係", "cardId": "400", "prompt": "係", "correct": "400", "options": [{"id": "401", "label": "きんし"}, {"id": "397", "label": "かんしん"}, {"id": "367", "label": "ふまんな"}, {"id": "400", "label": "かかり"}], "furigana": "かかり"}, {"key": "m10", "arti": "larangan", "kanji": "禁止", "cardId": "401", "prompt": "禁止", "correct": "401", "options": [{"id": "394", "label": "しんよう"}, {"id": "391", "label": "はこ"}, {"id": "365", "label": "ごうしゃ"}, {"id": "401", "label": "きんし"}], "furigana": "きんし"}], "typing": [{"key": "t1", "arti": "kepercayaan diri", "kanji": "自信", "cardId": "392", "prompt": "自信", "furigana": "じしん", "answerKanji": "自信", "answerFurigana": "じしん"}, {"key": "t2", "arti": "percaya", "kanji": "信じる", "cardId": "393", "prompt": "信じる", "furigana": "しんじる", "answerKanji": "信じる", "answerFurigana": "しんじる"}, {"key": "t3", "arti": "kepercayaan", "kanji": "信用", "cardId": "394", "prompt": "信用", "furigana": "しんよう", "answerKanji": "信用", "answerFurigana": "しんよう"}, {"key": "t4", "arti": "lampu lalu lintas", "kanji": "信号", "cardId": "395", "prompt": "信号", "furigana": "しんごう", "answerKanji": "信号", "answerFurigana": "しんごう"}, {"key": "t5", "arti": "mengirim pesan/data", "kanji": "送信", "cardId": "396", "prompt": "送信", "furigana": "そうしん", "answerKanji": "送信", "answerFurigana": "そうしん"}, {"key": "t6", "arti": "minat / ketertarikan", "kanji": "関心", "cardId": "397", "prompt": "関心", "furigana": "かんしん", "answerKanji": "関心", "answerFurigana": "かんしん"}, {"key": "t7", "arti": "mengenai / berhubungan dengan", "kanji": "関する", "cardId": "398", "prompt": "関する", "furigana": "かんする", "answerKanji": "関する", "answerFurigana": "かんする"}, {"key": "t8", "arti": "hubungan", "kanji": "関係", "cardId": "399", "prompt": "関係", "furigana": "かんけい", "answerKanji": "関係", "answerFurigana": "かんけい"}, {"key": "t9", "arti": "orang yang bertanggung jawab", "kanji": "係", "cardId": "400", "prompt": "係", "furigana": "かかり", "answerKanji": "係", "answerFurigana": "かかり"}, {"key": "t10", "arti": "larangan", "kanji": "禁止", "cardId": "401", "prompt": "禁止", "furigana": "きんし", "answerKanji": "禁止", "answerFurigana": "きんし"}], "matching": [{"key": "p1", "arti": "kepercayaan diri", "kanji": "自信", "label": "じしん", "round": 0, "token": "42a9cb0194d92a14", "cardId": "392", "prompt": "自信", "correct": "42a9cb0194d92a14", "furigana": "じしん"}, {"key": "p2", "arti": "percaya", "kanji": "信じる", "label": "しんじる", "round": 0, "token": "fbaf7d4e6d41b363", "cardId": "393", "prompt": "信じる", "correct": "fbaf7d4e6d41b363", "furigana": "しんじる"}, {"key": "p3", "arti": "kepercayaan", "kanji": "信用", "label": "しんよう", "round": 0, "token": "12a8d1deb79386e2", "cardId": "394", "prompt": "信用", "correct": "12a8d1deb79386e2", "furigana": "しんよう"}, {"key": "p4", "arti": "lampu lalu lintas", "kanji": "信号", "label": "しんごう", "round": 0, "token": "1dc4ae56c6e54f95", "cardId": "395", "prompt": "信号", "correct": "1dc4ae56c6e54f95", "furigana": "しんごう"}, {"key": "p5", "arti": "mengirim pesan/data", "kanji": "送信", "label": "そうしん", "round": 0, "token": "499b796c42a71723", "cardId": "396", "prompt": "送信", "correct": "499b796c42a71723", "furigana": "そうしん"}, {"key": "p6", "arti": "minat / ketertarikan", "kanji": "関心", "label": "かんしん", "round": 1, "token": "322b3cac67ab182f", "cardId": "397", "prompt": "関心", "correct": "322b3cac67ab182f", "furigana": "かんしん"}, {"key": "p7", "arti": "mengenai / berhubungan dengan", "kanji": "関する", "label": "かんする", "round": 1, "token": "cb5454652b42fe8b", "cardId": "398", "prompt": "関する", "correct": "cb5454652b42fe8b", "furigana": "かんする"}, {"key": "p8", "arti": "hubungan", "kanji": "関係", "label": "かんけい", "round": 1, "token": "a371fee8dfa074e1", "cardId": "399", "prompt": "関係", "correct": "a371fee8dfa074e1", "furigana": "かんけい"}, {"key": "p9", "arti": "orang yang bertanggung jawab", "kanji": "係", "label": "かかり", "round": 1, "token": "8aee500eb36741fe", "cardId": "400", "prompt": "係", "correct": "8aee500eb36741fe", "furigana": "かかり"}, {"key": "p10", "arti": "larangan", "kanji": "禁止", "label": "きんし", "round": 1, "token": "0c16b080b2bd591b", "cardId": "401", "prompt": "禁止", "correct": "0c16b080b2bd591b", "furigana": "きんし"}]}	2026-11-08 12:58:42.611172+00	\N
e0fc5389-61e6-425b-a2b0-5ef9e01f93c9	61873ad8-02ce-46c9-b781-f2735620661c	typing	{"mc": [{"key": "m1", "arti": "Garam", "kanji": "塩", "cardId": "482", "prompt": "塩", "correct": "482", "options": [{"id": "529", "label": "あきらめる"}, {"id": "564", "label": "じゆう"}, {"id": "484", "label": "きかい"}, {"id": "482", "label": "しお"}], "furigana": "しお"}, {"key": "m2", "arti": "Perintah", "kanji": "命令", "cardId": "483", "prompt": "命令", "correct": "483", "options": [{"id": "483", "label": "めいれい"}, {"id": "489", "label": "かくにん"}, {"id": "537", "label": "かならずしも"}, {"id": "485", "label": "きゅうじつ"}], "furigana": "めいれい"}, {"key": "m3", "arti": "Mesin", "kanji": "機械", "cardId": "484", "prompt": "機械", "correct": "484", "options": [{"id": "484", "label": "きかい"}, {"id": "580", "label": "あいさつ"}, {"id": "540", "label": "ほうもん"}, {"id": "498", "label": "うせつ"}], "furigana": "きかい"}, {"key": "m4", "arti": "Hari libur", "kanji": "休日", "cardId": "485", "prompt": "休日", "correct": "485", "options": [{"id": "485", "label": "きゅうじつ"}, {"id": "524", "label": "けんこう"}, {"id": "578", "label": "おどろく"}, {"id": "549", "label": "やさい"}], "furigana": "きゅうじつ"}, {"key": "m5", "arti": "Pandai / Ahli", "kanji": "得意", "cardId": "486", "prompt": "得意", "correct": "486", "options": [{"id": "486", "label": "とくい"}, {"id": "489", "label": "かくにん"}, {"id": "510", "label": "げんりょう"}, {"id": "507", "label": "しょうばい"}], "furigana": "とくい"}, {"key": "m6", "arti": "Rumit / Kompleks", "kanji": "複雑", "cardId": "487", "prompt": "複雑", "correct": "487", "options": [{"id": "501", "label": "きたい"}, {"id": "509", "label": "ぼうえき"}, {"id": "487", "label": "ふくざつ"}, {"id": "534", "label": "ゆるい"}], "furigana": "ふくざつ"}, {"key": "m7", "arti": "Imajinasi / Membayangkan", "kanji": "想像", "cardId": "488", "prompt": "想像", "correct": "488", "options": [{"id": "488", "label": "そうぞう"}, {"id": "508", "label": "かいけい"}, {"id": "501", "label": "きたい"}, {"id": "531", "label": "かたづく"}], "furigana": "そうぞう"}, {"key": "m8", "arti": "Konfirmasi / Pengecekan", "kanji": "確認", "cardId": "489", "prompt": "確認", "correct": "489", "options": [{"id": "531", "label": "かたづく"}, {"id": "489", "label": "かくにん"}, {"id": "546", "label": "おうえん"}, {"id": "524", "label": "けんこう"}], "furigana": "かくにん"}, {"key": "m9", "arti": "Manajemen / Mengelola", "kanji": "経営", "cardId": "490", "prompt": "経営", "correct": "490", "options": [{"id": "487", "label": "ふくざつ"}, {"id": "554", "label": "しょうらい"}, {"id": "523", "label": "べんとう"}, {"id": "490", "label": "けいえい"}], "furigana": "けいえい"}, {"key": "m10", "arti": "Sumber daya", "kanji": "資源", "cardId": "491", "prompt": "資源", "correct": "491", "options": [{"id": "554", "label": "しょうらい"}, {"id": "543", "label": "えいきょう"}, {"id": "491", "label": "しげん"}, {"id": "555", "label": "あせ"}], "furigana": "しげん"}], "typing": [{"key": "t1", "arti": "Garam", "kanji": "塩", "cardId": "482", "prompt": "塩", "furigana": "しお", "answerKanji": "塩", "answerFurigana": "しお"}, {"key": "t2", "arti": "Perintah", "kanji": "命令", "cardId": "483", "prompt": "命令", "furigana": "めいれい", "answerKanji": "命令", "answerFurigana": "めいれい"}, {"key": "t3", "arti": "Mesin", "kanji": "機械", "cardId": "484", "prompt": "機械", "furigana": "きかい", "answerKanji": "機械", "answerFurigana": "きかい"}, {"key": "t4", "arti": "Hari libur", "kanji": "休日", "cardId": "485", "prompt": "休日", "furigana": "きゅうじつ", "answerKanji": "休日", "answerFurigana": "きゅうじつ"}, {"key": "t5", "arti": "Pandai / Ahli", "kanji": "得意", "cardId": "486", "prompt": "得意", "furigana": "とくい", "answerKanji": "得意", "answerFurigana": "とくい"}, {"key": "t6", "arti": "Rumit / Kompleks", "kanji": "複雑", "cardId": "487", "prompt": "複雑", "furigana": "ふくざつ", "answerKanji": "複雑", "answerFurigana": "ふくざつ"}, {"key": "t7", "arti": "Imajinasi / Membayangkan", "kanji": "想像", "cardId": "488", "prompt": "想像", "furigana": "そうぞう", "answerKanji": "想像", "answerFurigana": "そうぞう"}, {"key": "t8", "arti": "Konfirmasi / Pengecekan", "kanji": "確認", "cardId": "489", "prompt": "確認", "furigana": "かくにん", "answerKanji": "確認", "answerFurigana": "かくにん"}, {"key": "t9", "arti": "Manajemen / Mengelola", "kanji": "経営", "cardId": "490", "prompt": "経営", "furigana": "けいえい", "answerKanji": "経営", "answerFurigana": "けいえい"}, {"key": "t10", "arti": "Sumber daya", "kanji": "資源", "cardId": "491", "prompt": "資源", "furigana": "しげん", "answerKanji": "資源", "answerFurigana": "しげん"}], "matching": [{"key": "p1", "arti": "Garam", "kanji": "塩", "label": "しお", "round": 0, "token": "3212d3a9f44f5f73", "cardId": "482", "prompt": "塩", "correct": "3212d3a9f44f5f73", "furigana": "しお"}, {"key": "p2", "arti": "Perintah", "kanji": "命令", "label": "めいれい", "round": 0, "token": "8cc40dd6c0ca2904", "cardId": "483", "prompt": "命令", "correct": "8cc40dd6c0ca2904", "furigana": "めいれい"}, {"key": "p3", "arti": "Mesin", "kanji": "機械", "label": "きかい", "round": 0, "token": "6d44179956ac57be", "cardId": "484", "prompt": "機械", "correct": "6d44179956ac57be", "furigana": "きかい"}, {"key": "p4", "arti": "Hari libur", "kanji": "休日", "label": "きゅうじつ", "round": 0, "token": "09ccf0120e384921", "cardId": "485", "prompt": "休日", "correct": "09ccf0120e384921", "furigana": "きゅうじつ"}, {"key": "p5", "arti": "Pandai / Ahli", "kanji": "得意", "label": "とくい", "round": 0, "token": "51962156961e233a", "cardId": "486", "prompt": "得意", "correct": "51962156961e233a", "furigana": "とくい"}, {"key": "p6", "arti": "Rumit / Kompleks", "kanji": "複雑", "label": "ふくざつ", "round": 1, "token": "58c1aa93e42de754", "cardId": "487", "prompt": "複雑", "correct": "58c1aa93e42de754", "furigana": "ふくざつ"}, {"key": "p7", "arti": "Imajinasi / Membayangkan", "kanji": "想像", "label": "そうぞう", "round": 1, "token": "256ffae2cdbb2466", "cardId": "488", "prompt": "想像", "correct": "256ffae2cdbb2466", "furigana": "そうぞう"}, {"key": "p8", "arti": "Konfirmasi / Pengecekan", "kanji": "確認", "label": "かくにん", "round": 1, "token": "b689ea04774ead0b", "cardId": "489", "prompt": "確認", "correct": "b689ea04774ead0b", "furigana": "かくにん"}, {"key": "p9", "arti": "Manajemen / Mengelola", "kanji": "経営", "label": "けいえい", "round": 1, "token": "01fdfde11f4d1e76", "cardId": "490", "prompt": "経営", "correct": "01fdfde11f4d1e76", "furigana": "けいえい"}, {"key": "p10", "arti": "Sumber daya", "kanji": "資源", "label": "しげん", "round": 1, "token": "f55405eea759a97f", "cardId": "491", "prompt": "資源", "correct": "f55405eea759a97f", "furigana": "しげん"}]}	2026-11-09 10:00:48.364151+00	\N
69a560c5-540e-4812-8dfe-0f802ec6b2a9	f90229e5-807a-4964-b64c-c54c48debd34	done	{"mc": [{"key": "m1", "arti": "pengaruh; dampak", "kanji": "影響", "cardId": "191", "prompt": "影響", "correct": "191", "options": [{"id": "191", "label": "えいきょう"}, {"id": "345", "label": "ぐたいてきな"}, {"id": "355", "label": "いっぱい"}, {"id": "267", "label": "かい"}], "furigana": "えいきょう"}, {"key": "m2", "arti": "operasional usaha; bisnis", "kanji": "営業", "cardId": "192", "prompt": "営業", "correct": "192", "options": [{"id": "284", "label": "いじょう"}, {"id": "355", "label": "いっぱい"}, {"id": "351", "label": "ざんねんな"}, {"id": "192", "label": "えいぎょう"}], "furigana": "えいぎょう"}, {"key": "m3", "arti": "nutrisi; gizi", "kanji": "栄養", "cardId": "193", "prompt": "栄養", "correct": "193", "options": [{"id": "193", "label": "えいよう"}, {"id": "342", "label": "きほんてきな"}, {"id": "344", "label": "きらいな"}, {"id": "288", "label": "うけつけ"}], "furigana": "えいよう"}, {"key": "m4", "arti": "senyuman", "kanji": "笑顔", "cardId": "194", "prompt": "笑顔", "correct": "194", "options": [{"id": "270", "label": "かず"}, {"id": "345", "label": "ぐたいてきな"}, {"id": "266", "label": "おや"}, {"id": "194", "label": "えがお"}], "furigana": "えがお"}, {"key": "m5", "arti": "depan stasiun", "kanji": "駅前", "cardId": "195", "prompt": "駅前", "correct": "195", "options": [{"id": "204", "label": "あける"}, {"id": "360", "label": "さきに"}, {"id": "195", "label": "えきまえ"}, {"id": "177", "label": "いがい"}], "furigana": "えきまえ"}, {"key": "m6", "arti": "penundaan", "kanji": "延期", "cardId": "196", "prompt": "延期", "correct": "196", "options": [{"id": "196", "label": "えんき"}, {"id": "176", "label": "いか"}, {"id": "275", "label": "けむり"}, {"id": "180", "label": "いじ"}], "furigana": "えんき"}, {"key": "m7", "arti": "pertunjukan musik; memainkan alat musik", "kanji": "演奏", "cardId": "197", "prompt": "演奏", "correct": "197", "options": [{"id": "322", "label": "おくる"}, {"id": "197", "label": "えんそう"}, {"id": "295", "label": "おんがく"}, {"id": "188", "label": "いんさつ"}], "furigana": "えんそう"}, {"key": "m8", "arti": "sungkan; menahan diri", "kanji": "遠慮", "cardId": "198", "prompt": "遠慮", "correct": "198", "options": [{"id": "198", "label": "えんりょ"}, {"id": "312", "label": "おこる"}, {"id": "341", "label": "おしい"}, {"id": "278", "label": "こな"}], "furigana": "えんりょ"}, {"key": "m9", "arti": "dukungan; menyemangati", "kanji": "応援", "cardId": "199", "prompt": "応援", "correct": "199", "options": [{"id": "199", "label": "おうえん"}, {"id": "224", "label": "あたらしい"}, {"id": "245", "label": "おもに"}, {"id": "343", "label": "きゅうな"}], "furigana": "おうえん"}, {"key": "m10", "arti": "menyeberang; melintasi", "kanji": "横断", "cardId": "200", "prompt": "横断", "correct": "200", "options": [{"id": "279", "label": "さ"}, {"id": "326", "label": "おちる"}, {"id": "281", "label": "さくら"}, {"id": "200", "label": "おうだん"}], "furigana": "おうだん"}], "typing": [{"key": "t1", "arti": "pengaruh; dampak", "kanji": "影響", "cardId": "191", "prompt": "影響", "furigana": "えいきょう", "answerKanji": "影響", "answerFurigana": "えいきょう"}, {"key": "t2", "arti": "operasional usaha; bisnis", "kanji": "営業", "cardId": "192", "prompt": "営業", "furigana": "えいぎょう", "answerKanji": "営業", "answerFurigana": "えいぎょう"}, {"key": "t3", "arti": "nutrisi; gizi", "kanji": "栄養", "cardId": "193", "prompt": "栄養", "furigana": "えいよう", "answerKanji": "栄養", "answerFurigana": "えいよう"}, {"key": "t4", "arti": "senyuman", "kanji": "笑顔", "cardId": "194", "prompt": "笑顔", "furigana": "えがお", "answerKanji": "笑顔", "answerFurigana": "えがお"}, {"key": "t5", "arti": "depan stasiun", "kanji": "駅前", "cardId": "195", "prompt": "駅前", "furigana": "えきまえ", "answerKanji": "駅前", "answerFurigana": "えきまえ"}, {"key": "t6", "arti": "penundaan", "kanji": "延期", "cardId": "196", "prompt": "延期", "furigana": "えんき", "answerKanji": "延期", "answerFurigana": "えんき"}, {"key": "t7", "arti": "pertunjukan musik; memainkan alat musik", "kanji": "演奏", "cardId": "197", "prompt": "演奏", "furigana": "えんそう", "answerKanji": "演奏", "answerFurigana": "えんそう"}, {"key": "t8", "arti": "sungkan; menahan diri", "kanji": "遠慮", "cardId": "198", "prompt": "遠慮", "furigana": "えんりょ", "answerKanji": "遠慮", "answerFurigana": "えんりょ"}, {"key": "t9", "arti": "dukungan; menyemangati", "kanji": "応援", "cardId": "199", "prompt": "応援", "furigana": "おうえん", "answerKanji": "応援", "answerFurigana": "おうえん"}, {"key": "t10", "arti": "menyeberang; melintasi", "kanji": "横断", "cardId": "200", "prompt": "横断", "furigana": "おうだん", "answerKanji": "横断", "answerFurigana": "おうだん"}], "matching": [{"key": "p1", "arti": "pengaruh; dampak", "kanji": "影響", "label": "えいきょう", "round": 0, "token": "5a90e96e22ff4ad9", "cardId": "191", "prompt": "影響", "correct": "5a90e96e22ff4ad9", "furigana": "えいきょう"}, {"key": "p2", "arti": "operasional usaha; bisnis", "kanji": "営業", "label": "えいぎょう", "round": 0, "token": "2f4e1d5cf021f3ce", "cardId": "192", "prompt": "営業", "correct": "2f4e1d5cf021f3ce", "furigana": "えいぎょう"}, {"key": "p3", "arti": "nutrisi; gizi", "kanji": "栄養", "label": "えいよう", "round": 0, "token": "188897b5f1fa165e", "cardId": "193", "prompt": "栄養", "correct": "188897b5f1fa165e", "furigana": "えいよう"}, {"key": "p4", "arti": "senyuman", "kanji": "笑顔", "label": "えがお", "round": 0, "token": "9132b66ce9bc12c8", "cardId": "194", "prompt": "笑顔", "correct": "9132b66ce9bc12c8", "furigana": "えがお"}, {"key": "p5", "arti": "depan stasiun", "kanji": "駅前", "label": "えきまえ", "round": 0, "token": "79bb2d5707621131", "cardId": "195", "prompt": "駅前", "correct": "79bb2d5707621131", "furigana": "えきまえ"}, {"key": "p6", "arti": "penundaan", "kanji": "延期", "label": "えんき", "round": 1, "token": "08b195f2e2b4eee5", "cardId": "196", "prompt": "延期", "correct": "08b195f2e2b4eee5", "furigana": "えんき"}, {"key": "p7", "arti": "pertunjukan musik; memainkan alat musik", "kanji": "演奏", "label": "えんそう", "round": 1, "token": "fc6cfae2c04e90d8", "cardId": "197", "prompt": "演奏", "correct": "fc6cfae2c04e90d8", "furigana": "えんそう"}, {"key": "p8", "arti": "sungkan; menahan diri", "kanji": "遠慮", "label": "えんりょ", "round": 1, "token": "7e5e9c22a6801f50", "cardId": "198", "prompt": "遠慮", "correct": "7e5e9c22a6801f50", "furigana": "えんりょ"}, {"key": "p9", "arti": "dukungan; menyemangati", "kanji": "応援", "label": "おうえん", "round": 1, "token": "b38ed172ca0a2226", "cardId": "199", "prompt": "応援", "correct": "b38ed172ca0a2226", "furigana": "おうえん"}, {"key": "p10", "arti": "menyeberang; melintasi", "kanji": "横断", "label": "おうだん", "round": 1, "token": "f9060b3ba5a003da", "cardId": "200", "prompt": "横断", "correct": "f9060b3ba5a003da", "furigana": "おうだん"}]}	2026-11-12 04:59:01.30968+00	2026-11-12 05:01:07.223462+00
6fd3a7bb-c0bd-44f5-be13-71ff42bd0fb5	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	done	{"mc": [{"key": "m1", "arti": "menyerah", "kanji": "諦める", "cardId": "201", "prompt": "諦める", "correct": "201", "options": [{"id": "360", "label": "さきに"}, {"id": "217", "label": "かつ"}, {"id": "327", "label": "おとす"}, {"id": "201", "label": "あきらめる"}], "furigana": "あきらめる"}, {"key": "m2", "arti": "bosan", "kanji": "飽きる", "cardId": "202", "prompt": "飽きる", "correct": "202", "options": [{"id": "218", "label": "かりる"}, {"id": "262", "label": "がら"}, {"id": "200", "label": "おうだん"}, {"id": "202", "label": "あきる"}], "furigana": "あきる"}, {"key": "m3", "arti": "kosong; tersedia", "kanji": "空く", "cardId": "203", "prompt": "空く", "correct": "203", "options": [{"id": "269", "label": "かさ"}, {"id": "152", "label": "あお"}, {"id": "203", "label": "あく"}, {"id": "316", "label": "うける"}], "furigana": "あく"}, {"key": "m4", "arti": "mengosongkan; memberi ruang", "kanji": "空ける", "cardId": "204", "prompt": "空ける", "correct": "204", "options": [{"id": "249", "label": "けっして"}, {"id": "298", "label": "かいぎ"}, {"id": "171", "label": "あいず"}, {"id": "204", "label": "あける"}], "furigana": "あける"}, {"key": "m5", "arti": "menitipkan", "kanji": "預ける", "cardId": "205", "prompt": "預ける", "correct": "205", "options": [{"id": "314", "label": "いたむ"}, {"id": "181", "label": "いっしょ"}, {"id": "205", "label": "あずける"}, {"id": "327", "label": "おとす"}], "furigana": "あずける"}, {"key": "m6", "arti": "memberikan; menyebabkan", "kanji": "与える", "cardId": "206", "prompt": "与える", "correct": "206", "options": [{"id": "282", "label": "いしき"}, {"id": "281", "label": "さくら"}, {"id": "206", "label": "あたえる"}, {"id": "162", "label": "いも"}], "furigana": "あたえる"}, {"key": "m7", "arti": "menghangatkan", "kanji": "温める", "cardId": "207", "prompt": "温める", "correct": "207", "options": [{"id": "207", "label": "あたためる"}, {"id": "341", "label": "おしい"}, {"id": "210", "label": "あわてる"}, {"id": "352", "label": "あまり"}], "furigana": "あたためる"}, {"key": "m8", "arti": "meminta maaf", "kanji": "謝る", "cardId": "208", "prompt": "謝る", "correct": "208", "options": [{"id": "208", "label": "あやまる"}, {"id": "197", "label": "えんそう"}, {"id": "191", "label": "えいきょう"}, {"id": "225", "label": "あつい"}], "furigana": "あやまる"}, {"key": "m9", "arti": "mengungkapkan; menyatakan", "kanji": "表す", "cardId": "209", "prompt": "表す", "correct": "209", "options": [{"id": "236", "label": "かつどうてきな"}, {"id": "268", "label": "かお"}, {"id": "209", "label": "あらわす"}, {"id": "242", "label": "いちおう"}], "furigana": "あらわす"}, {"key": "m10", "arti": "panik; tergesa-gesa", "kanji": "慌てる", "cardId": "210", "prompt": "慌てる", "correct": "210", "options": [{"id": "238", "label": "かんたんな"}, {"id": "210", "label": "あわてる"}, {"id": "339", "label": "おいしい"}, {"id": "186", "label": "いま"}], "furigana": "あわてる"}], "typing": [{"key": "t1", "arti": "menyerah", "kanji": "諦める", "cardId": "201", "prompt": "諦める", "furigana": "あきらめる", "answerKanji": "諦める", "answerFurigana": "あきらめる"}, {"key": "t2", "arti": "bosan", "kanji": "飽きる", "cardId": "202", "prompt": "飽きる", "furigana": "あきる", "answerKanji": "飽きる", "answerFurigana": "あきる"}, {"key": "t3", "arti": "kosong; tersedia", "kanji": "空く", "cardId": "203", "prompt": "空く", "furigana": "あく", "answerKanji": "空く", "answerFurigana": "あく"}, {"key": "t4", "arti": "mengosongkan; memberi ruang", "kanji": "空ける", "cardId": "204", "prompt": "空ける", "furigana": "あける", "answerKanji": "空ける", "answerFurigana": "あける"}, {"key": "t5", "arti": "menitipkan", "kanji": "預ける", "cardId": "205", "prompt": "預ける", "furigana": "あずける", "answerKanji": "預ける", "answerFurigana": "あずける"}, {"key": "t6", "arti": "memberikan; menyebabkan", "kanji": "与える", "cardId": "206", "prompt": "与える", "furigana": "あたえる", "answerKanji": "与える", "answerFurigana": "あたえる"}, {"key": "t7", "arti": "menghangatkan", "kanji": "温める", "cardId": "207", "prompt": "温める", "furigana": "あたためる", "answerKanji": "温める", "answerFurigana": "あたためる"}, {"key": "t8", "arti": "meminta maaf", "kanji": "謝る", "cardId": "208", "prompt": "謝る", "furigana": "あやまる", "answerKanji": "謝る", "answerFurigana": "あやまる"}, {"key": "t9", "arti": "mengungkapkan; menyatakan", "kanji": "表す", "cardId": "209", "prompt": "表す", "furigana": "あらわす", "answerKanji": "表す", "answerFurigana": "あらわす"}, {"key": "t10", "arti": "panik; tergesa-gesa", "kanji": "慌てる", "cardId": "210", "prompt": "慌てる", "furigana": "あわてる", "answerKanji": "慌てる", "answerFurigana": "あわてる"}], "matching": [{"key": "p1", "arti": "menyerah", "kanji": "諦める", "label": "あきらめる", "round": 0, "token": "01234c5f44d0b0ee", "cardId": "201", "prompt": "諦める", "correct": "01234c5f44d0b0ee", "furigana": "あきらめる"}, {"key": "p2", "arti": "bosan", "kanji": "飽きる", "label": "あきる", "round": 0, "token": "3bdab0b5f730c6e7", "cardId": "202", "prompt": "飽きる", "correct": "3bdab0b5f730c6e7", "furigana": "あきる"}, {"key": "p3", "arti": "kosong; tersedia", "kanji": "空く", "label": "あく", "round": 0, "token": "cb1253d877ed643f", "cardId": "203", "prompt": "空く", "correct": "cb1253d877ed643f", "furigana": "あく"}, {"key": "p4", "arti": "mengosongkan; memberi ruang", "kanji": "空ける", "label": "あける", "round": 0, "token": "58237a47a459d399", "cardId": "204", "prompt": "空ける", "correct": "58237a47a459d399", "furigana": "あける"}, {"key": "p5", "arti": "menitipkan", "kanji": "預ける", "label": "あずける", "round": 0, "token": "39c1284e457ea265", "cardId": "205", "prompt": "預ける", "correct": "39c1284e457ea265", "furigana": "あずける"}, {"key": "p6", "arti": "memberikan; menyebabkan", "kanji": "与える", "label": "あたえる", "round": 1, "token": "07beaf3ff889cbac", "cardId": "206", "prompt": "与える", "correct": "07beaf3ff889cbac", "furigana": "あたえる"}, {"key": "p7", "arti": "menghangatkan", "kanji": "温める", "label": "あたためる", "round": 1, "token": "df4e648685850220", "cardId": "207", "prompt": "温める", "correct": "df4e648685850220", "furigana": "あたためる"}, {"key": "p8", "arti": "meminta maaf", "kanji": "謝る", "label": "あやまる", "round": 1, "token": "d870bfa134c7d445", "cardId": "208", "prompt": "謝る", "correct": "d870bfa134c7d445", "furigana": "あやまる"}, {"key": "p9", "arti": "mengungkapkan; menyatakan", "kanji": "表す", "label": "あらわす", "round": 1, "token": "4c2c1b98f645950b", "cardId": "209", "prompt": "表す", "correct": "4c2c1b98f645950b", "furigana": "あらわす"}, {"key": "p10", "arti": "panik; tergesa-gesa", "kanji": "慌てる", "label": "あわてる", "round": 1, "token": "780096fcba9a1c7e", "cardId": "210", "prompt": "慌てる", "correct": "780096fcba9a1c7e", "furigana": "あわてる"}]}	2026-11-12 05:02:27.296745+00	2026-11-12 05:04:19.285918+00
131d3183-49af-47fe-9ffc-5c0c656b3f60	682f2896-13e8-4d34-acd4-93cdbb0367c7	done	{"mc": [{"key": "m1", "arti": "memilih", "kanji": "選ぶ", "cardId": "211", "prompt": "選ぶ", "correct": "211", "options": [{"id": "164", "label": "うち"}, {"id": "211", "label": "えらぶ"}, {"id": "308", "label": "かち"}, {"id": "241", "label": "あいかわらず"}], "furigana": "えらぶ"}, {"key": "m2", "arti": "menyembunyikan", "kanji": "隠す", "cardId": "212", "prompt": "隠す", "correct": "212", "options": [{"id": "361", "label": "さっそく"}, {"id": "195", "label": "えきまえ"}, {"id": "211", "label": "えらぶ"}, {"id": "212", "label": "かくす"}], "furigana": "かくす"}, {"key": "m3", "arti": "menghias; memajang", "kanji": "飾る", "cardId": "213", "prompt": "飾る", "correct": "213", "options": [{"id": "213", "label": "かざる"}, {"id": "231", "label": "あんぜんな"}, {"id": "302", "label": "かかく"}, {"id": "155", "label": "あぶら"}], "furigana": "かざる"}, {"key": "m4", "arti": "meminjamkan", "kanji": "貸す", "cardId": "214", "prompt": "貸す", "correct": "214", "options": [{"id": "226", "label": "あつい"}, {"id": "214", "label": "かす"}, {"id": "217", "label": "かつ"}, {"id": "356", "label": "かなり"}], "furigana": "かす"}, {"key": "m5", "arti": "menghasilkan uang", "kanji": "稼ぐ", "cardId": "215", "prompt": "稼ぐ", "correct": "215", "options": [{"id": "215", "label": "かせぐ"}, {"id": "361", "label": "さっそく"}, {"id": "327", "label": "おとす"}, {"id": "197", "label": "えんそう"}], "furigana": "かせぐ"}, {"key": "m6", "arti": "membereskan; merapikan", "kanji": "片付ける", "cardId": "216", "prompt": "片付ける", "correct": "216", "options": [{"id": "156", "label": "あん"}, {"id": "192", "label": "えいぎょう"}, {"id": "262", "label": "がら"}, {"id": "216", "label": "かたづける"}], "furigana": "かたづける"}, {"key": "m7", "arti": "menang", "kanji": "勝つ", "cardId": "217", "prompt": "勝つ", "correct": "217", "options": [{"id": "182", "label": "いっぱん"}, {"id": "217", "label": "かつ"}, {"id": "174", "label": "あんしん"}, {"id": "216", "label": "かたづける"}], "furigana": "かつ"}, {"key": "m8", "arti": "meminjam", "kanji": "借りる", "cardId": "218", "prompt": "借りる", "correct": "218", "options": [{"id": "218", "label": "かりる"}, {"id": "349", "label": "さかんな"}, {"id": "342", "label": "きほんてきな"}, {"id": "199", "label": "おうえん"}], "furigana": "かりる"}, {"key": "m9", "arti": "menjadi kering", "kanji": "乾く", "cardId": "219", "prompt": "乾く", "correct": "219", "options": [{"id": "224", "label": "あたらしい"}, {"id": "269", "label": "かさ"}, {"id": "310", "label": "かんきょう"}, {"id": "219", "label": "かわく"}], "furigana": "かわく"}, {"key": "m10", "arti": "berubah", "kanji": "変わる", "cardId": "220", "prompt": "変わる", "correct": "220", "options": [{"id": "160", "label": "いけ"}, {"id": "165", "label": "うつわ"}, {"id": "230", "label": "うつくしい"}, {"id": "220", "label": "かわる"}], "furigana": "かわる"}], "typing": [{"key": "t1", "arti": "memilih", "kanji": "選ぶ", "cardId": "211", "prompt": "選ぶ", "furigana": "えらぶ", "answerKanji": "選ぶ", "answerFurigana": "えらぶ"}, {"key": "t2", "arti": "menyembunyikan", "kanji": "隠す", "cardId": "212", "prompt": "隠す", "furigana": "かくす", "answerKanji": "隠す", "answerFurigana": "かくす"}, {"key": "t3", "arti": "menghias; memajang", "kanji": "飾る", "cardId": "213", "prompt": "飾る", "furigana": "かざる", "answerKanji": "飾る", "answerFurigana": "かざる"}, {"key": "t4", "arti": "meminjamkan", "kanji": "貸す", "cardId": "214", "prompt": "貸す", "furigana": "かす", "answerKanji": "貸す", "answerFurigana": "かす"}, {"key": "t5", "arti": "menghasilkan uang", "kanji": "稼ぐ", "cardId": "215", "prompt": "稼ぐ", "furigana": "かせぐ", "answerKanji": "稼ぐ", "answerFurigana": "かせぐ"}, {"key": "t6", "arti": "membereskan; merapikan", "kanji": "片付ける", "cardId": "216", "prompt": "片付ける", "furigana": "かたづける", "answerKanji": "片付ける", "answerFurigana": "かたづける"}, {"key": "t7", "arti": "menang", "kanji": "勝つ", "cardId": "217", "prompt": "勝つ", "furigana": "かつ", "answerKanji": "勝つ", "answerFurigana": "かつ"}, {"key": "t8", "arti": "meminjam", "kanji": "借りる", "cardId": "218", "prompt": "借りる", "furigana": "かりる", "answerKanji": "借りる", "answerFurigana": "かりる"}, {"key": "t9", "arti": "menjadi kering", "kanji": "乾く", "cardId": "219", "prompt": "乾く", "furigana": "かわく", "answerKanji": "乾く", "answerFurigana": "かわく"}, {"key": "t10", "arti": "berubah", "kanji": "変わる", "cardId": "220", "prompt": "変わる", "furigana": "かわる", "answerKanji": "変わる", "answerFurigana": "かわる"}], "matching": [{"key": "p1", "arti": "memilih", "kanji": "選ぶ", "label": "えらぶ", "round": 0, "token": "1eff38fab91f09e1", "cardId": "211", "prompt": "選ぶ", "correct": "1eff38fab91f09e1", "furigana": "えらぶ"}, {"key": "p2", "arti": "menyembunyikan", "kanji": "隠す", "label": "かくす", "round": 0, "token": "98777e6e1f1bed5d", "cardId": "212", "prompt": "隠す", "correct": "98777e6e1f1bed5d", "furigana": "かくす"}, {"key": "p3", "arti": "menghias; memajang", "kanji": "飾る", "label": "かざる", "round": 0, "token": "0308ac104e480f48", "cardId": "213", "prompt": "飾る", "correct": "0308ac104e480f48", "furigana": "かざる"}, {"key": "p4", "arti": "meminjamkan", "kanji": "貸す", "label": "かす", "round": 0, "token": "fbe0cba1db275f7c", "cardId": "214", "prompt": "貸す", "correct": "fbe0cba1db275f7c", "furigana": "かす"}, {"key": "p5", "arti": "menghasilkan uang", "kanji": "稼ぐ", "label": "かせぐ", "round": 0, "token": "aa935f25baf7b584", "cardId": "215", "prompt": "稼ぐ", "correct": "aa935f25baf7b584", "furigana": "かせぐ"}, {"key": "p6", "arti": "membereskan; merapikan", "kanji": "片付ける", "label": "かたづける", "round": 1, "token": "dfdf5ca5e6c6164a", "cardId": "216", "prompt": "片付ける", "correct": "dfdf5ca5e6c6164a", "furigana": "かたづける"}, {"key": "p7", "arti": "menang", "kanji": "勝つ", "label": "かつ", "round": 1, "token": "41d5bff73e6f383c", "cardId": "217", "prompt": "勝つ", "correct": "41d5bff73e6f383c", "furigana": "かつ"}, {"key": "p8", "arti": "meminjam", "kanji": "借りる", "label": "かりる", "round": 1, "token": "8d2ec7d50d6efd6b", "cardId": "218", "prompt": "借りる", "correct": "8d2ec7d50d6efd6b", "furigana": "かりる"}, {"key": "p9", "arti": "menjadi kering", "kanji": "乾く", "label": "かわく", "round": 1, "token": "adfd88c92c039b02", "cardId": "219", "prompt": "乾く", "correct": "adfd88c92c039b02", "furigana": "かわく"}, {"key": "p10", "arti": "berubah", "kanji": "変わる", "label": "かわる", "round": 1, "token": "cdb13d1327ab178d", "cardId": "220", "prompt": "変わる", "correct": "cdb13d1327ab178d", "furigana": "かわる"}]}	2026-11-13 09:28:21.242897+00	2026-11-13 09:30:13.40632+00
489faedb-58ee-4de6-be02-9c5ae873c518	bee0b6e7-cbaf-42bc-8732-88543f67970c	done	{"mc": [{"key": "m1", "arti": "antara; selama", "kanji": "間", "cardId": "151", "prompt": "間", "correct": "151", "options": [{"id": "151", "label": "あいだ"}, {"id": "181", "label": "いっしょ"}, {"id": "162", "label": "いも"}, {"id": "264", "label": "き"}], "furigana": "あいだ"}, {"key": "m2", "arti": "biru", "kanji": "青", "cardId": "152", "prompt": "青", "correct": "152", "options": [{"id": "221", "label": "あかるい"}, {"id": "216", "label": "かたづける"}, {"id": "152", "label": "あお"}, {"id": "179", "label": "いこう"}], "furigana": "あお"}, {"key": "m3", "arti": "rasa", "kanji": "味", "cardId": "153", "prompt": "味", "correct": "153", "options": [{"id": "279", "label": "さ"}, {"id": "339", "label": "おいしい"}, {"id": "243", "label": "いちどに"}, {"id": "153", "label": "あじ"}], "furigana": "あじ"}, {"key": "m4", "arti": "lubang", "kanji": "穴", "cardId": "154", "prompt": "穴", "correct": "154", "options": [{"id": "222", "label": "あさい"}, {"id": "154", "label": "あな"}, {"id": "231", "label": "あんぜんな"}, {"id": "349", "label": "さかんな"}], "furigana": "あな"}, {"key": "m5", "arti": "minyak", "kanji": "油", "cardId": "155", "prompt": "油", "correct": "155", "options": [{"id": "155", "label": "あぶら"}, {"id": "288", "label": "うけつけ"}, {"id": "240", "label": "けんこうな"}, {"id": "180", "label": "いじ"}], "furigana": "あぶら"}, {"key": "m6", "arti": "usulan; ide", "kanji": "案", "cardId": "156", "prompt": "案", "correct": "156", "options": [{"id": "321", "label": "えがく"}, {"id": "156", "label": "あん"}, {"id": "193", "label": "えいよう"}, {"id": "346", "label": "げんきな"}], "furigana": "あん"}, {"key": "m7", "arti": "lambung", "kanji": "胃", "cardId": "157", "prompt": "胃", "correct": "157", "options": [{"id": "320", "label": "うめる"}, {"id": "157", "label": "い"}, {"id": "208", "label": "あやまる"}, {"id": "322", "label": "おくる"}], "furigana": "い"}, {"key": "m8", "arti": "rumah", "kanji": "家", "cardId": "158", "prompt": "家", "correct": "158", "options": [{"id": "292", "label": "おうふく"}, {"id": "158", "label": "いえ"}, {"id": "222", "label": "あさい"}, {"id": "209", "label": "あらわす"}], "furigana": "いえ"}, {"key": "m9", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "cardId": "172", "prompt": "相手", "correct": "172", "options": [{"id": "351", "label": "ざんねんな"}, {"id": "172", "label": "あいて"}, {"id": "299", "label": "かいけつ"}, {"id": "222", "label": "あさい"}], "furigana": "あいて"}, {"key": "m10", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "cardId": "176", "prompt": "以下", "correct": "176", "options": [{"id": "294", "label": "おうよう"}, {"id": "246", "label": "かならず"}, {"id": "176", "label": "いか"}, {"id": "230", "label": "うつくしい"}], "furigana": "いか"}], "typing": [{"key": "t1", "arti": "antara; selama", "kanji": "間", "cardId": "151", "prompt": "間", "furigana": "あいだ", "answerKanji": "間", "answerFurigana": "あいだ"}, {"key": "t2", "arti": "biru", "kanji": "青", "cardId": "152", "prompt": "青", "furigana": "あお", "answerKanji": "青", "answerFurigana": "あお"}, {"key": "t3", "arti": "rasa", "kanji": "味", "cardId": "153", "prompt": "味", "furigana": "あじ", "answerKanji": "味", "answerFurigana": "あじ"}, {"key": "t4", "arti": "lubang", "kanji": "穴", "cardId": "154", "prompt": "穴", "furigana": "あな", "answerKanji": "穴", "answerFurigana": "あな"}, {"key": "t5", "arti": "minyak", "kanji": "油", "cardId": "155", "prompt": "油", "furigana": "あぶら", "answerKanji": "油", "answerFurigana": "あぶら"}, {"key": "t6", "arti": "usulan; ide", "kanji": "案", "cardId": "156", "prompt": "案", "furigana": "あん", "answerKanji": "案", "answerFurigana": "あん"}, {"key": "t7", "arti": "lambung", "kanji": "胃", "cardId": "157", "prompt": "胃", "furigana": "い", "answerKanji": "胃", "answerFurigana": "い"}, {"key": "t8", "arti": "rumah", "kanji": "家", "cardId": "158", "prompt": "家", "furigana": "いえ", "answerKanji": "家", "answerFurigana": "いえ"}, {"key": "t9", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "cardId": "172", "prompt": "相手", "furigana": "あいて", "answerKanji": "相手", "answerFurigana": "あいて"}, {"key": "t10", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "cardId": "176", "prompt": "以下", "furigana": "いか", "answerKanji": "以下", "answerFurigana": "いか"}], "matching": [{"key": "p1", "arti": "antara; selama", "kanji": "間", "label": "あいだ", "round": 0, "token": "7d23dbec2565b7eb", "cardId": "151", "prompt": "間", "correct": "7d23dbec2565b7eb", "furigana": "あいだ"}, {"key": "p2", "arti": "biru", "kanji": "青", "label": "あお", "round": 0, "token": "f75190c2b2994b9d", "cardId": "152", "prompt": "青", "correct": "f75190c2b2994b9d", "furigana": "あお"}, {"key": "p3", "arti": "rasa", "kanji": "味", "label": "あじ", "round": 0, "token": "6d8348fabe12fede", "cardId": "153", "prompt": "味", "correct": "6d8348fabe12fede", "furigana": "あじ"}, {"key": "p4", "arti": "lubang", "kanji": "穴", "label": "あな", "round": 0, "token": "70758ea328570f92", "cardId": "154", "prompt": "穴", "correct": "70758ea328570f92", "furigana": "あな"}, {"key": "p5", "arti": "minyak", "kanji": "油", "label": "あぶら", "round": 0, "token": "7f535f7ed04d3e8f", "cardId": "155", "prompt": "油", "correct": "7f535f7ed04d3e8f", "furigana": "あぶら"}, {"key": "p6", "arti": "usulan; ide", "kanji": "案", "label": "あん", "round": 1, "token": "f414cdeb507317c9", "cardId": "156", "prompt": "案", "correct": "f414cdeb507317c9", "furigana": "あん"}, {"key": "p7", "arti": "lambung", "kanji": "胃", "label": "い", "round": 1, "token": "0d3877aae77a4bd7", "cardId": "157", "prompt": "胃", "correct": "0d3877aae77a4bd7", "furigana": "い"}, {"key": "p8", "arti": "rumah", "kanji": "家", "label": "いえ", "round": 1, "token": "dfbf82ba06c40966", "cardId": "158", "prompt": "家", "correct": "dfbf82ba06c40966", "furigana": "いえ"}, {"key": "p9", "arti": "lawan; pasangan; pihak lain", "kanji": "相手", "label": "あいて", "round": 1, "token": "16e6302fa876d417", "cardId": "172", "prompt": "相手", "correct": "16e6302fa876d417", "furigana": "あいて"}, {"key": "p10", "arti": "di bawah; tidak lebih dari", "kanji": "以下", "label": "いか", "round": 1, "token": "b46b2b94e2a9ce44", "cardId": "176", "prompt": "以下", "correct": "b46b2b94e2a9ce44", "furigana": "いか"}]}	2026-11-12 05:05:14.843076+00	2026-11-12 05:06:48.269581+00
ea60b922-b97d-48cb-9cea-c39093e4d99b	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	done	{"mc": [{"key": "m1", "arti": "terang; ceria", "kanji": "明るい", "cardId": "221", "prompt": "明るい", "correct": "221", "options": [{"id": "154", "label": "あな"}, {"id": "174", "label": "あんしん"}, {"id": "346", "label": "げんきな"}, {"id": "221", "label": "あかるい"}], "furigana": "あかるい"}, {"key": "m2", "arti": "dangkal", "kanji": "浅い", "cardId": "222", "prompt": "浅い", "correct": "222", "options": [{"id": "273", "label": "くび"}, {"id": "222", "label": "あさい"}, {"id": "215", "label": "かせぐ"}, {"id": "318", "label": "うつ"}], "furigana": "あさい"}, {"key": "m3", "arti": "hangat (cuaca; udara)", "kanji": "暖かい", "cardId": "223", "prompt": "暖かい", "correct": "223", "options": [{"id": "227", "label": "あつい"}, {"id": "223", "label": "あたたかい"}, {"id": "152", "label": "あお"}, {"id": "220", "label": "かわる"}], "furigana": "あたたかい"}, {"key": "m4", "arti": "baru", "kanji": "新しい", "cardId": "224", "prompt": "新しい", "correct": "224", "options": [{"id": "195", "label": "えきまえ"}, {"id": "224", "label": "あたらしい"}, {"id": "269", "label": "かさ"}, {"id": "205", "label": "あずける"}], "furigana": "あたらしい"}, {"key": "m5", "arti": "panas (cuaca)", "kanji": "暑い", "cardId": "225", "prompt": "暑い", "correct": "225", "options": [{"id": "346", "label": "げんきな"}, {"id": "201", "label": "あきらめる"}, {"id": "158", "label": "いえ"}, {"id": "225", "label": "あつい"}], "furigana": "あつい"}, {"key": "m6", "arti": "panas (benda)", "kanji": "熱い", "cardId": "226", "prompt": "熱い", "correct": "226", "options": [{"id": "226", "label": "あつい"}, {"id": "302", "label": "かかく"}, {"id": "217", "label": "かつ"}, {"id": "264", "label": "き"}], "furigana": "あつい"}, {"key": "m7", "arti": "tebal", "kanji": "厚い", "cardId": "227", "prompt": "厚い", "correct": "227", "options": [{"id": "311", "label": "かんけい"}, {"id": "227", "label": "あつい"}, {"id": "234", "label": "いやな"}, {"id": "224", "label": "あたらしい"}], "furigana": "あつい"}, {"key": "m8", "arti": "berbahaya", "kanji": "危ない", "cardId": "228", "prompt": "危ない", "correct": "228", "options": [{"id": "271", "label": "かた"}, {"id": "266", "label": "おや"}, {"id": "347", "label": "こうかてきな"}, {"id": "228", "label": "あぶない"}], "furigana": "あぶない"}, {"key": "m9", "arti": "manis", "kanji": "甘い", "cardId": "229", "prompt": "甘い", "correct": "229", "options": [{"id": "181", "label": "いっしょ"}, {"id": "249", "label": "けっして"}, {"id": "229", "label": "あまい"}, {"id": "165", "label": "うつわ"}], "furigana": "あまい"}, {"key": "m10", "arti": "indah; cantik", "kanji": "美しい", "cardId": "230", "prompt": "美しい", "correct": "230", "options": [{"id": "349", "label": "さかんな"}, {"id": "245", "label": "おもに"}, {"id": "189", "label": "いんしょう"}, {"id": "230", "label": "うつくしい"}], "furigana": "うつくしい"}], "typing": [{"key": "t1", "arti": "terang; ceria", "kanji": "明るい", "cardId": "221", "prompt": "明るい", "furigana": "あかるい", "answerKanji": "明るい", "answerFurigana": "あかるい"}, {"key": "t2", "arti": "dangkal", "kanji": "浅い", "cardId": "222", "prompt": "浅い", "furigana": "あさい", "answerKanji": "浅い", "answerFurigana": "あさい"}, {"key": "t3", "arti": "hangat (cuaca; udara)", "kanji": "暖かい", "cardId": "223", "prompt": "暖かい", "furigana": "あたたかい", "answerKanji": "暖かい", "answerFurigana": "あたたかい"}, {"key": "t4", "arti": "baru", "kanji": "新しい", "cardId": "224", "prompt": "新しい", "furigana": "あたらしい", "answerKanji": "新しい", "answerFurigana": "あたらしい"}, {"key": "t5", "arti": "panas (cuaca)", "kanji": "暑い", "cardId": "225", "prompt": "暑い", "furigana": "あつい", "answerKanji": "暑い", "answerFurigana": "あつい"}, {"key": "t6", "arti": "panas (benda)", "kanji": "熱い", "cardId": "226", "prompt": "熱い", "furigana": "あつい", "answerKanji": "熱い", "answerFurigana": "あつい"}, {"key": "t7", "arti": "tebal", "kanji": "厚い", "cardId": "227", "prompt": "厚い", "furigana": "あつい", "answerKanji": "厚い", "answerFurigana": "あつい"}, {"key": "t8", "arti": "berbahaya", "kanji": "危ない", "cardId": "228", "prompt": "危ない", "furigana": "あぶない", "answerKanji": "危ない", "answerFurigana": "あぶない"}, {"key": "t9", "arti": "manis", "kanji": "甘い", "cardId": "229", "prompt": "甘い", "furigana": "あまい", "answerKanji": "甘い", "answerFurigana": "あまい"}, {"key": "t10", "arti": "indah; cantik", "kanji": "美しい", "cardId": "230", "prompt": "美しい", "furigana": "うつくしい", "answerKanji": "美しい", "answerFurigana": "うつくしい"}], "matching": [{"key": "p1", "arti": "terang; ceria", "kanji": "明るい", "label": "あかるい", "round": 0, "token": "bde7fa3205442431", "cardId": "221", "prompt": "明るい", "correct": "bde7fa3205442431", "furigana": "あかるい"}, {"key": "p2", "arti": "dangkal", "kanji": "浅い", "label": "あさい", "round": 0, "token": "4af913ef1cbe3fc1", "cardId": "222", "prompt": "浅い", "correct": "4af913ef1cbe3fc1", "furigana": "あさい"}, {"key": "p3", "arti": "hangat (cuaca; udara)", "kanji": "暖かい", "label": "あたたかい", "round": 0, "token": "557e4b079318c7e9", "cardId": "223", "prompt": "暖かい", "correct": "557e4b079318c7e9", "furigana": "あたたかい"}, {"key": "p4", "arti": "baru", "kanji": "新しい", "label": "あたらしい", "round": 0, "token": "c2ae0db2de4f3ee4", "cardId": "224", "prompt": "新しい", "correct": "c2ae0db2de4f3ee4", "furigana": "あたらしい"}, {"key": "p5", "arti": "panas (cuaca)", "kanji": "暑い", "label": "あつい", "round": 0, "token": "0f7e734fc9244ebf", "cardId": "225", "prompt": "暑い", "correct": "0f7e734fc9244ebf", "furigana": "あつい"}, {"key": "p6", "arti": "panas (benda)", "kanji": "熱い", "label": "あつい", "round": 1, "token": "921da8fb364dfbd0", "cardId": "226", "prompt": "熱い", "correct": "921da8fb364dfbd0", "furigana": "あつい"}, {"key": "p7", "arti": "tebal", "kanji": "厚い", "label": "あつい", "round": 1, "token": "3cbdfe59e15aa9cd", "cardId": "227", "prompt": "厚い", "correct": "3cbdfe59e15aa9cd", "furigana": "あつい"}, {"key": "p8", "arti": "berbahaya", "kanji": "危ない", "label": "あぶない", "round": 1, "token": "24645f1568769074", "cardId": "228", "prompt": "危ない", "correct": "24645f1568769074", "furigana": "あぶない"}, {"key": "p9", "arti": "manis", "kanji": "甘い", "label": "あまい", "round": 1, "token": "fcd886bba4fab167", "cardId": "229", "prompt": "甘い", "correct": "fcd886bba4fab167", "furigana": "あまい"}, {"key": "p10", "arti": "indah; cantik", "kanji": "美しい", "label": "うつくしい", "round": 1, "token": "045eaf25a062b19e", "cardId": "230", "prompt": "美しい", "correct": "045eaf25a062b19e", "furigana": "うつくしい"}]}	2026-11-13 09:30:52.892158+00	2026-11-13 09:32:48.504999+00
d5c5521c-758c-4366-9da2-c8538cd8c284	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	done	{"mc": [{"key": "m1", "arti": "aman", "kanji": "安全な", "cardId": "231", "prompt": "安全な", "correct": "231", "options": [{"id": "206", "label": "あたえる"}, {"id": "312", "label": "おこる"}, {"id": "295", "label": "おんがく"}, {"id": "231", "label": "あんぜんな"}], "furigana": "あんぜんな"}, {"key": "m2", "arti": "tidak terduga", "kanji": "意外な", "cardId": "232", "prompt": "意外な", "correct": "232", "options": [{"id": "285", "label": "いぜん"}, {"id": "232", "label": "いがいな"}, {"id": "266", "label": "おや"}, {"id": "282", "label": "いしき"}], "furigana": "いがいな"}, {"key": "m3", "arti": "umum; lazim", "kanji": "一般的な", "cardId": "233", "prompt": "一般的な", "correct": "233", "options": [{"id": "233", "label": "いっぱんてきな"}, {"id": "349", "label": "さかんな"}, {"id": "334", "label": "うすい"}, {"id": "338", "label": "えらい"}], "furigana": "いっぱんてきな"}, {"key": "m4", "arti": "tidak menyenangkan", "kanji": "嫌な", "cardId": "234", "prompt": "嫌な", "correct": "234", "options": [{"id": "334", "label": "うすい"}, {"id": "234", "label": "いやな"}, {"id": "241", "label": "あいかわらず"}, {"id": "157", "label": "い"}], "furigana": "いやな"}, {"key": "m5", "arti": "pasti; dapat diandalkan", "kanji": "確実な", "cardId": "235", "prompt": "確実な", "correct": "235", "options": [{"id": "341", "label": "おしい"}, {"id": "240", "label": "けんこうな"}, {"id": "203", "label": "あく"}, {"id": "235", "label": "かくじつな"}], "furigana": "かくじつな"}, {"key": "m6", "arti": "aktif", "kanji": "活動的な", "cardId": "236", "prompt": "活動的な", "correct": "236", "options": [{"id": "174", "label": "あんしん"}, {"id": "151", "label": "あいだ"}, {"id": "270", "label": "かず"}, {"id": "236", "label": "かつどうてきな"}], "furigana": "かつどうてきな"}, {"key": "m7", "arti": "memungkinkan; bisa dilakukan", "kanji": "可能な", "cardId": "237", "prompt": "可能な", "correct": "237", "options": [{"id": "269", "label": "かさ"}, {"id": "361", "label": "さっそく"}, {"id": "237", "label": "かのうな"}, {"id": "334", "label": "うすい"}], "furigana": "かのうな"}, {"key": "m8", "arti": "mudah; sederhana", "kanji": "簡単な", "cardId": "238", "prompt": "簡単な", "correct": "238", "options": [{"id": "327", "label": "おとす"}, {"id": "339", "label": "おいしい"}, {"id": "238", "label": "かんたんな"}, {"id": "265", "label": "おもて"}], "furigana": "かんたんな"}, {"key": "m9", "arti": "berbahaya", "kanji": "危険な", "cardId": "239", "prompt": "危険な", "correct": "239", "options": [{"id": "177", "label": "いがい"}, {"id": "204", "label": "あける"}, {"id": "194", "label": "えがお"}, {"id": "239", "label": "きけんな"}], "furigana": "きけんな"}, {"key": "m10", "arti": "sehat", "kanji": "健康な", "cardId": "240", "prompt": "健康な", "correct": "240", "options": [{"id": "240", "label": "けんこうな"}, {"id": "176", "label": "いか"}, {"id": "345", "label": "ぐたいてきな"}, {"id": "295", "label": "おんがく"}], "furigana": "けんこうな"}], "typing": [{"key": "t1", "arti": "aman", "kanji": "安全な", "cardId": "231", "prompt": "安全な", "furigana": "あんぜんな", "answerKanji": "安全な", "answerFurigana": "あんぜんな"}, {"key": "t2", "arti": "tidak terduga", "kanji": "意外な", "cardId": "232", "prompt": "意外な", "furigana": "いがいな", "answerKanji": "意外な", "answerFurigana": "いがいな"}, {"key": "t3", "arti": "umum; lazim", "kanji": "一般的な", "cardId": "233", "prompt": "一般的な", "furigana": "いっぱんてきな", "answerKanji": "一般的な", "answerFurigana": "いっぱんてきな"}, {"key": "t4", "arti": "tidak menyenangkan", "kanji": "嫌な", "cardId": "234", "prompt": "嫌な", "furigana": "いやな", "answerKanji": "嫌な", "answerFurigana": "いやな"}, {"key": "t5", "arti": "pasti; dapat diandalkan", "kanji": "確実な", "cardId": "235", "prompt": "確実な", "furigana": "かくじつな", "answerKanji": "確実な", "answerFurigana": "かくじつな"}, {"key": "t6", "arti": "aktif", "kanji": "活動的な", "cardId": "236", "prompt": "活動的な", "furigana": "かつどうてきな", "answerKanji": "活動的な", "answerFurigana": "かつどうてきな"}, {"key": "t7", "arti": "memungkinkan; bisa dilakukan", "kanji": "可能な", "cardId": "237", "prompt": "可能な", "furigana": "かのうな", "answerKanji": "可能な", "answerFurigana": "かのうな"}, {"key": "t8", "arti": "mudah; sederhana", "kanji": "簡単な", "cardId": "238", "prompt": "簡単な", "furigana": "かんたんな", "answerKanji": "簡単な", "answerFurigana": "かんたんな"}, {"key": "t9", "arti": "berbahaya", "kanji": "危険な", "cardId": "239", "prompt": "危険な", "furigana": "きけんな", "answerKanji": "危険な", "answerFurigana": "きけんな"}, {"key": "t10", "arti": "sehat", "kanji": "健康な", "cardId": "240", "prompt": "健康な", "furigana": "けんこうな", "answerKanji": "健康な", "answerFurigana": "けんこうな"}], "matching": [{"key": "p1", "arti": "aman", "kanji": "安全な", "label": "あんぜんな", "round": 0, "token": "fba5c7c2e851ffa1", "cardId": "231", "prompt": "安全な", "correct": "fba5c7c2e851ffa1", "furigana": "あんぜんな"}, {"key": "p2", "arti": "tidak terduga", "kanji": "意外な", "label": "いがいな", "round": 0, "token": "07759f3ca08dfab2", "cardId": "232", "prompt": "意外な", "correct": "07759f3ca08dfab2", "furigana": "いがいな"}, {"key": "p3", "arti": "umum; lazim", "kanji": "一般的な", "label": "いっぱんてきな", "round": 0, "token": "b4dd84fd7788f7b1", "cardId": "233", "prompt": "一般的な", "correct": "b4dd84fd7788f7b1", "furigana": "いっぱんてきな"}, {"key": "p4", "arti": "tidak menyenangkan", "kanji": "嫌な", "label": "いやな", "round": 0, "token": "cda2acf2a7a03019", "cardId": "234", "prompt": "嫌な", "correct": "cda2acf2a7a03019", "furigana": "いやな"}, {"key": "p5", "arti": "pasti; dapat diandalkan", "kanji": "確実な", "label": "かくじつな", "round": 0, "token": "f3841bce374672f7", "cardId": "235", "prompt": "確実な", "correct": "f3841bce374672f7", "furigana": "かくじつな"}, {"key": "p6", "arti": "aktif", "kanji": "活動的な", "label": "かつどうてきな", "round": 1, "token": "59d18049c148e253", "cardId": "236", "prompt": "活動的な", "correct": "59d18049c148e253", "furigana": "かつどうてきな"}, {"key": "p7", "arti": "memungkinkan; bisa dilakukan", "kanji": "可能な", "label": "かのうな", "round": 1, "token": "271a386e06f9f6d6", "cardId": "237", "prompt": "可能な", "correct": "271a386e06f9f6d6", "furigana": "かのうな"}, {"key": "p8", "arti": "mudah; sederhana", "kanji": "簡単な", "label": "かんたんな", "round": 1, "token": "1295814bbcff69e6", "cardId": "238", "prompt": "簡単な", "correct": "1295814bbcff69e6", "furigana": "かんたんな"}, {"key": "p9", "arti": "berbahaya", "kanji": "危険な", "label": "きけんな", "round": 1, "token": "862bb6d90ad21eed", "cardId": "239", "prompt": "危険な", "correct": "862bb6d90ad21eed", "furigana": "きけんな"}, {"key": "p10", "arti": "sehat", "kanji": "健康な", "label": "けんこうな", "round": 1, "token": "ebd3406437609673", "cardId": "240", "prompt": "健康な", "correct": "ebd3406437609673", "furigana": "けんこうな"}]}	2026-11-13 09:34:00.330522+00	2026-11-13 09:37:04.096508+00
3e31c386-3387-4337-b29d-b7e3997de737	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	done	{"mc": [{"key": "m1", "arti": "pendapat", "kanji": "意見", "cardId": "178", "prompt": "意見", "correct": "178", "options": [{"id": "178", "label": "いけん"}, {"id": "239", "label": "きけんな"}, {"id": "359", "label": "けっこう"}, {"id": "195", "label": "えきまえ"}], "furigana": "いけん"}, {"key": "m2", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "correct": "161", "options": [{"id": "250", "label": "しだいに"}, {"id": "233", "label": "いっぱんてきな"}, {"id": "161", "label": "いと"}, {"id": "245", "label": "おもに"}], "furigana": "いと"}, {"key": "m3", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "correct": "162", "options": [{"id": "162", "label": "いも"}, {"id": "237", "label": "かのうな"}, {"id": "353", "label": "いくらでも"}, {"id": "341", "label": "おしい"}], "furigana": "いも"}, {"key": "m4", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "correct": "163", "options": [{"id": "201", "label": "あきらめる"}, {"id": "163", "label": "うた"}, {"id": "193", "label": "えいよう"}, {"id": "320", "label": "うめる"}], "furigana": "うた"}, {"key": "m5", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "correct": "164", "options": [{"id": "303", "label": "かがく"}, {"id": "283", "label": "いしゃ"}, {"id": "354", "label": "いつでも"}, {"id": "164", "label": "うち"}], "furigana": "うち"}, {"key": "m6", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "correct": "165", "options": [{"id": "158", "label": "いえ"}, {"id": "278", "label": "こな"}, {"id": "250", "label": "しだいに"}, {"id": "165", "label": "うつわ"}], "furigana": "うつわ"}, {"key": "m7", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "correct": "166", "options": [{"id": "157", "label": "い"}, {"id": "166", "label": "うで"}, {"id": "170", "label": "おと"}, {"id": "310", "label": "かんきょう"}], "furigana": "うで"}, {"key": "m8", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "correct": "167", "options": [{"id": "296", "label": "おんせん"}, {"id": "332", "label": "いそがしい"}, {"id": "167", "label": "え"}, {"id": "289", "label": "うんてん"}], "furigana": "え"}, {"key": "m9", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "correct": "168", "options": [{"id": "320", "label": "うめる"}, {"id": "359", "label": "けっこう"}, {"id": "168", "label": "えだ"}, {"id": "177", "label": "いがい"}], "furigana": "えだ"}, {"key": "m10", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "correct": "169", "options": [{"id": "188", "label": "いんさつ"}, {"id": "281", "label": "さくら"}, {"id": "169", "label": "おく"}, {"id": "204", "label": "あける"}], "furigana": "おく"}], "typing": [{"key": "t1", "arti": "pendapat", "kanji": "意見", "cardId": "178", "prompt": "意見", "furigana": "いけん", "answerKanji": "意見", "answerFurigana": "いけん"}, {"key": "t2", "arti": "benang", "kanji": "糸", "cardId": "161", "prompt": "糸", "furigana": "いと", "answerKanji": "糸", "answerFurigana": "いと"}, {"key": "t3", "arti": "umbi; kentang", "kanji": "芋", "cardId": "162", "prompt": "芋", "furigana": "いも", "answerKanji": "芋", "answerFurigana": "いも"}, {"key": "t4", "arti": "lagu", "kanji": "歌", "cardId": "163", "prompt": "歌", "furigana": "うた", "answerKanji": "歌", "answerFurigana": "うた"}, {"key": "t5", "arti": "bagian dalam", "kanji": "内", "cardId": "164", "prompt": "内", "furigana": "うち", "answerKanji": "内", "answerFurigana": "うち"}, {"key": "t6", "arti": "wadah; mangkuk", "kanji": "器", "cardId": "165", "prompt": "器", "furigana": "うつわ", "answerKanji": "器", "answerFurigana": "うつわ"}, {"key": "t7", "arti": "lengan", "kanji": "腕", "cardId": "166", "prompt": "腕", "furigana": "うで", "answerKanji": "腕", "answerFurigana": "うで"}, {"key": "t8", "arti": "gambar; lukisan", "kanji": "絵", "cardId": "167", "prompt": "絵", "furigana": "え", "answerKanji": "絵", "answerFurigana": "え"}, {"key": "t9", "arti": "ranting; cabang pohon", "kanji": "枝", "cardId": "168", "prompt": "枝", "furigana": "えだ", "answerKanji": "枝", "answerFurigana": "えだ"}, {"key": "t10", "arti": "bagian dalam; belakang", "kanji": "奥", "cardId": "169", "prompt": "奥", "furigana": "おく", "answerKanji": "奥", "answerFurigana": "おく"}], "matching": [{"key": "p1", "arti": "pendapat", "kanji": "意見", "label": "いけん", "round": 0, "token": "ac43d6dafc4f4f71", "cardId": "178", "prompt": "意見", "correct": "ac43d6dafc4f4f71", "furigana": "いけん"}, {"key": "p2", "arti": "benang", "kanji": "糸", "label": "いと", "round": 0, "token": "2ea05dd7b52400ca", "cardId": "161", "prompt": "糸", "correct": "2ea05dd7b52400ca", "furigana": "いと"}, {"key": "p3", "arti": "umbi; kentang", "kanji": "芋", "label": "いも", "round": 0, "token": "edc8da3b94e27e55", "cardId": "162", "prompt": "芋", "correct": "edc8da3b94e27e55", "furigana": "いも"}, {"key": "p4", "arti": "lagu", "kanji": "歌", "label": "うた", "round": 0, "token": "10ce60b338b2f7c8", "cardId": "163", "prompt": "歌", "correct": "10ce60b338b2f7c8", "furigana": "うた"}, {"key": "p5", "arti": "bagian dalam", "kanji": "内", "label": "うち", "round": 0, "token": "8a8a8505d0bf9b10", "cardId": "164", "prompt": "内", "correct": "8a8a8505d0bf9b10", "furigana": "うち"}, {"key": "p6", "arti": "wadah; mangkuk", "kanji": "器", "label": "うつわ", "round": 1, "token": "338dc4e52a0e4bff", "cardId": "165", "prompt": "器", "correct": "338dc4e52a0e4bff", "furigana": "うつわ"}, {"key": "p7", "arti": "lengan", "kanji": "腕", "label": "うで", "round": 1, "token": "4c9906a4ababb06b", "cardId": "166", "prompt": "腕", "correct": "4c9906a4ababb06b", "furigana": "うで"}, {"key": "p8", "arti": "gambar; lukisan", "kanji": "絵", "label": "え", "round": 1, "token": "d7a9121870908d55", "cardId": "167", "prompt": "絵", "correct": "d7a9121870908d55", "furigana": "え"}, {"key": "p9", "arti": "ranting; cabang pohon", "kanji": "枝", "label": "えだ", "round": 1, "token": "e750d45086beafe2", "cardId": "168", "prompt": "枝", "correct": "e750d45086beafe2", "furigana": "えだ"}, {"key": "p10", "arti": "bagian dalam; belakang", "kanji": "奥", "label": "おく", "round": 1, "token": "3c10af97b6e11b89", "cardId": "169", "prompt": "奥", "correct": "3c10af97b6e11b89", "furigana": "おく"}]}	2026-11-13 09:43:27.395935+00	2026-11-13 09:46:00.455858+00
\.


--
-- Data for Name: review_history; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.review_history (id, card_id, session_id, quality, interval_days, reviewed_at) FROM stdin;
1	1	bcc78f19-d73c-4652-b699-cf99eb58dc17	2	1	2026-10-12 16:30:07.461977+00
2	2	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
3	3	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
4	4	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
5	5	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
6	6	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
7	7	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
8	8	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
9	9	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
10	10	bcc78f19-d73c-4652-b699-cf99eb58dc17	5	1	2026-10-12 16:30:07.461977+00
11	151	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
12	152	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
13	153	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
14	154	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
15	155	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
16	156	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
17	157	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
18	158	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
19	159	08da729b-56ba-4afe-b789-a67e45636a6c	5	1	2026-10-13 07:02:57.863833+00
20	160	08da729b-56ba-4afe-b789-a67e45636a6c	3	1	2026-10-13 07:02:57.863833+00
21	161	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
22	162	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
23	163	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
24	164	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
25	165	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
26	166	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
27	167	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
28	168	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
29	169	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
30	170	b7fb903d-d960-449c-9147-b67233808680	5	1	2026-10-13 12:06:16.056811+00
31	151	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
32	152	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
33	153	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
34	154	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
35	155	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
36	156	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
37	157	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
38	158	225e59f2-ffa1-49ea-8942-481123901337	5	3	2026-10-16 04:02:27.041618+00
39	159	225e59f2-ffa1-49ea-8942-481123901337	3	1	2026-10-16 04:02:27.041618+00
40	160	225e59f2-ffa1-49ea-8942-481123901337	5	1	2026-10-16 04:02:27.041618+00
41	171	ea03fa6b-5d25-41ac-9548-d9610018bbb3	5	1	2026-10-16 04:05:44.557376+00
42	172	ea03fa6b-5d25-41ac-9548-d9610018bbb3	3	1	2026-10-16 04:05:44.557376+00
43	173	ea03fa6b-5d25-41ac-9548-d9610018bbb3	5	1	2026-10-16 04:05:44.557376+00
44	174	ea03fa6b-5d25-41ac-9548-d9610018bbb3	5	1	2026-10-16 04:05:44.557376+00
45	175	ea03fa6b-5d25-41ac-9548-d9610018bbb3	5	1	2026-10-16 04:05:44.557376+00
46	176	ea03fa6b-5d25-41ac-9548-d9610018bbb3	3	1	2026-10-16 04:05:44.557376+00
47	177	ea03fa6b-5d25-41ac-9548-d9610018bbb3	5	1	2026-10-16 04:05:44.557376+00
48	178	ea03fa6b-5d25-41ac-9548-d9610018bbb3	3	1	2026-10-16 04:05:44.557376+00
49	179	ea03fa6b-5d25-41ac-9548-d9610018bbb3	5	1	2026-10-16 04:05:44.557376+00
50	180	ea03fa6b-5d25-41ac-9548-d9610018bbb3	5	1	2026-10-16 04:05:44.557376+00
51	362	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
52	363	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
53	364	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
54	365	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
55	366	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
56	367	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
57	368	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
58	369	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
59	370	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
60	371	4419ce06-845c-4d10-8c23-6e6b5f71b9c0	5	1	2026-10-16 04:08:36.594114+00
61	181	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
62	182	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
63	183	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
64	184	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
65	185	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
66	186	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
67	187	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
68	188	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
69	189	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
70	190	9bc23800-737c-425d-b4a2-67681636e9d5	5	1	2026-10-16 08:07:48.057347+00
71	372	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
72	373	e0c4ceab-eafd-44fc-b659-7088435ec643	2	1	2026-10-20 04:49:21.660966+00
73	374	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
74	375	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
75	376	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
76	377	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
77	378	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
78	379	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
79	380	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
80	381	e0c4ceab-eafd-44fc-b659-7088435ec643	5	1	2026-10-20 04:49:21.660966+00
81	362	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
82	363	dc219d6a-e80c-4c67-9b3f-211c4df9883d	1	1	2026-10-20 04:51:43.2102+00
83	364	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
84	365	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
85	366	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
86	367	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
87	368	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
88	369	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
89	370	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
90	371	dc219d6a-e80c-4c67-9b3f-211c4df9883d	5	3	2026-10-20 04:51:43.2102+00
91	161	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
92	162	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
93	163	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
94	164	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
95	165	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
96	166	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
97	167	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
98	168	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
99	169	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
100	170	94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	5	3	2026-10-20 04:54:16.136925+00
101	159	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	3	2026-10-20 04:56:33.956829+00
102	160	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	3	2026-10-20 04:56:33.956829+00
103	171	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	3	2026-10-20 04:56:33.956829+00
104	172	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	1	2026-10-20 04:56:33.956829+00
105	173	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	3	2026-10-20 04:56:33.956829+00
106	174	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	3	2026-10-20 04:56:33.956829+00
107	175	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	3	2026-10-20 04:56:33.956829+00
108	176	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	1	2026-10-20 04:56:33.956829+00
109	177	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	3	2026-10-20 04:56:33.956829+00
110	178	65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	5	1	2026-10-20 04:56:33.956829+00
111	181	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
112	182	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
113	183	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
114	184	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
115	185	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
116	179	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
117	180	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
118	186	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
119	187	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
120	188	15159fd6-75bb-407b-bdef-f007c759306b	5	3	2026-10-20 04:59:09.971248+00
121	382	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
122	383	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
123	384	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
124	385	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
125	386	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
126	387	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
127	388	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
128	389	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	2	1	2026-10-28 11:12:42.16773+00
129	390	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
130	391	a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	5	1	2026-10-28 11:12:42.16773+00
131	181	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
132	182	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
133	183	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
134	184	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
135	185	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
136	186	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
137	187	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
138	188	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	7	2026-10-28 12:11:29.218395+00
139	189	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	3	2026-10-28 12:11:29.218395+00
140	190	8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	5	3	2026-10-28 12:11:29.218395+00
141	392	31aee3c9-d101-456c-82f0-0d0063777d02	3	1	2026-10-28 12:18:11.192272+00
142	393	31aee3c9-d101-456c-82f0-0d0063777d02	5	1	2026-10-28 12:18:11.192272+00
143	394	31aee3c9-d101-456c-82f0-0d0063777d02	2	1	2026-10-28 12:18:11.192272+00
144	395	31aee3c9-d101-456c-82f0-0d0063777d02	2	1	2026-10-28 12:18:11.192272+00
145	396	31aee3c9-d101-456c-82f0-0d0063777d02	2	1	2026-10-28 12:18:11.192272+00
146	397	31aee3c9-d101-456c-82f0-0d0063777d02	2	1	2026-10-28 12:18:11.192272+00
147	398	31aee3c9-d101-456c-82f0-0d0063777d02	5	1	2026-10-28 12:18:11.192272+00
148	399	31aee3c9-d101-456c-82f0-0d0063777d02	5	1	2026-10-28 12:18:11.192272+00
149	400	31aee3c9-d101-456c-82f0-0d0063777d02	3	1	2026-10-28 12:18:11.192272+00
150	401	31aee3c9-d101-456c-82f0-0d0063777d02	5	1	2026-10-28 12:18:11.192272+00
151	373	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	1	2026-11-07 14:26:47.967982+00
152	374	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
153	375	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
154	376	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
155	377	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
156	378	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
157	379	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
158	380	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	2	1	2026-11-07 14:26:47.967982+00
159	381	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
160	372	6bde9a3f-64c0-4eb5-b976-4cc8834a5357	5	3	2026-11-07 14:26:47.967982+00
161	363	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	1	2026-11-07 14:29:57.256053+00
162	364	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
163	369	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
164	366	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
165	367	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
166	368	fa5a2807-b42d-4946-91b3-8ac41b4be778	3	3	2026-11-07 14:29:57.256053+00
167	365	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
168	370	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
169	371	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
170	362	fa5a2807-b42d-4946-91b3-8ac41b4be778	5	7	2026-11-07 14:29:57.256053+00
171	382	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
172	383	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
173	384	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
174	385	5c969fdd-acc6-4935-a45b-78feb35fd488	2	1	2026-11-07 14:32:15.560783+00
175	386	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
176	387	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
177	388	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
178	389	5c969fdd-acc6-4935-a45b-78feb35fd488	5	1	2026-11-07 14:32:15.560783+00
179	390	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
180	391	5c969fdd-acc6-4935-a45b-78feb35fd488	5	3	2026-11-07 14:32:15.560783+00
181	192	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
182	191	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
183	193	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
184	194	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
185	195	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
186	196	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
187	197	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
188	198	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
189	199	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
190	200	f90229e5-807a-4964-b64c-c54c48debd34	5	1	2026-11-12 05:01:07.223462+00
191	201	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
192	202	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
193	203	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
194	204	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
195	205	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
196	206	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
197	207	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
198	208	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
199	209	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
200	210	6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	5	1	2026-11-12 05:04:19.285918+00
201	151	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
202	152	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
203	153	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
204	154	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
205	155	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
206	156	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
207	157	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
208	158	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	7	2026-11-12 05:06:48.269581+00
209	172	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	3	2026-11-12 05:06:48.269581+00
210	176	bee0b6e7-cbaf-42bc-8732-88543f67970c	5	3	2026-11-12 05:06:48.269581+00
211	211	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
212	212	682f2896-13e8-4d34-acd4-93cdbb0367c7	3	1	2026-11-13 09:30:13.40632+00
213	213	682f2896-13e8-4d34-acd4-93cdbb0367c7	2	1	2026-11-13 09:30:13.40632+00
214	214	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
215	215	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
216	216	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
217	217	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
218	218	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
219	219	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
220	220	682f2896-13e8-4d34-acd4-93cdbb0367c7	5	1	2026-11-13 09:30:13.40632+00
221	221	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
222	222	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
223	223	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
224	224	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
225	225	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
226	226	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
227	227	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
228	228	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
229	229	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
230	230	89bbaf16-027b-4bc6-a480-8aad66bb5e3f	5	1	2026-11-13 09:32:48.504999+00
231	231	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
232	232	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	3	1	2026-11-13 09:37:04.096508+00
233	233	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
234	234	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
235	235	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
236	236	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
237	237	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
238	238	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
239	239	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
240	240	cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	5	1	2026-11-13 09:37:04.096508+00
241	161	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	7	2026-11-13 09:46:00.455858+00
242	162	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	7	2026-11-13 09:46:00.455858+00
243	163	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	2	1	2026-11-13 09:46:00.455858+00
244	164	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	2	1	2026-11-13 09:46:00.455858+00
245	165	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	7	2026-11-13 09:46:00.455858+00
246	166	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	7	2026-11-13 09:46:00.455858+00
247	167	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	7	2026-11-13 09:46:00.455858+00
248	168	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	7	2026-11-13 09:46:00.455858+00
249	169	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	7	2026-11-13 09:46:00.455858+00
250	178	103a6dfa-d97c-418d-a7cc-d0f9167b4a80	5	3	2026-11-13 09:46:00.455858+00
\.


--
-- Data for Name: study_day_cards; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.study_day_cards (day_id, card_id, "position") FROM stdin;
1	1	1
1	2	2
1	3	3
1	4	4
1	5	5
1	6	6
1	7	7
1	8	8
1	9	9
1	10	10
2	11	1
2	12	2
2	13	3
2	14	4
2	15	5
2	16	6
2	17	7
2	18	8
2	19	9
2	20	10
3	21	1
3	22	2
3	23	3
3	24	4
3	25	5
3	26	6
3	27	7
3	28	8
3	29	9
3	30	10
4	31	1
4	32	2
4	33	3
4	34	4
4	35	5
4	36	6
4	37	7
4	38	8
4	39	9
4	40	10
5	41	1
5	42	2
5	43	3
5	44	4
5	45	5
5	46	6
5	47	7
5	48	8
7	151	1
7	152	2
7	153	3
7	154	4
7	155	5
7	156	6
7	157	7
7	158	8
7	159	9
7	160	10
8	161	1
8	162	2
8	163	3
8	164	4
8	165	5
8	166	6
8	167	7
8	168	8
8	169	9
8	170	10
9	171	1
9	172	2
9	173	3
9	174	4
9	175	5
9	176	6
9	177	7
9	178	8
9	179	9
9	180	10
10	181	1
10	182	2
10	183	3
10	184	4
10	185	5
10	186	6
10	187	7
10	188	8
10	189	9
10	190	10
11	191	1
11	192	2
11	193	3
11	194	4
11	195	5
11	196	6
11	197	7
11	198	8
11	199	9
11	200	10
12	201	1
12	202	2
12	203	3
12	204	4
12	205	5
12	206	6
12	207	7
12	208	8
12	209	9
12	210	10
13	211	1
13	212	2
13	213	3
13	214	4
13	215	5
13	216	6
13	217	7
13	218	8
13	219	9
13	220	10
14	221	1
14	222	2
14	223	3
14	224	4
14	225	5
14	226	6
14	227	7
14	228	8
14	229	9
14	230	10
15	231	1
15	232	2
15	233	3
15	234	4
15	235	5
15	236	6
15	237	7
15	238	8
15	239	9
15	240	10
16	241	1
16	242	2
16	243	3
16	244	4
16	245	5
16	246	6
16	247	7
16	248	8
16	249	9
16	250	10
17	262	1
17	263	2
17	264	3
17	265	4
17	266	5
17	267	6
17	268	7
17	269	8
17	270	9
17	271	10
18	272	1
18	273	2
18	274	3
18	275	4
18	276	5
18	277	6
18	278	7
18	279	8
18	280	9
18	281	10
19	282	1
19	283	2
19	284	3
19	285	4
19	286	5
19	287	6
19	288	7
19	289	8
19	290	9
19	291	10
20	292	1
20	293	2
20	294	3
20	295	4
20	296	5
20	297	6
20	298	7
20	299	8
20	300	9
20	301	10
21	302	1
21	303	2
21	304	3
21	305	4
21	306	5
21	307	6
21	308	7
21	309	8
21	310	9
21	311	10
22	312	1
22	313	2
22	314	3
22	315	4
22	316	5
22	317	6
22	318	7
22	319	8
22	320	9
22	321	10
23	322	1
23	323	2
23	324	3
23	325	4
23	326	5
23	327	6
23	328	7
23	329	8
23	330	9
23	331	10
24	332	1
24	333	2
24	334	3
24	335	4
24	336	5
24	337	6
24	338	7
24	339	8
24	340	9
24	341	10
25	342	1
25	343	2
25	344	3
25	345	4
25	346	5
25	347	6
25	348	7
25	349	8
25	350	9
25	351	10
26	352	1
26	353	2
26	354	3
26	355	4
26	356	5
26	357	6
26	358	7
26	359	8
26	360	9
26	361	10
27	362	1
27	363	2
27	364	3
27	365	4
27	366	5
27	367	6
27	368	7
27	369	8
27	370	9
27	371	10
28	372	1
28	373	2
28	374	3
28	375	4
28	376	5
28	377	6
28	378	7
28	379	8
28	380	9
28	381	10
29	382	1
29	383	2
29	384	3
29	385	4
29	386	5
29	387	6
29	388	7
29	389	8
29	390	9
29	391	10
30	392	1
30	393	2
30	394	3
30	395	4
30	396	5
30	397	6
30	398	7
30	399	8
30	400	9
30	401	10
31	402	1
31	403	2
31	404	3
31	405	4
31	406	5
31	407	6
31	408	7
31	409	8
31	410	9
31	411	10
37	482	1
37	483	2
37	484	3
37	485	4
37	486	5
37	487	6
37	488	7
37	489	8
37	490	9
37	491	10
38	492	1
38	493	2
38	494	3
38	495	4
38	496	5
38	497	6
38	498	7
38	499	8
38	500	9
38	501	10
39	502	1
39	503	2
39	504	3
39	505	4
39	506	5
39	507	6
39	508	7
39	509	8
39	510	9
39	511	10
40	512	1
40	513	2
40	514	3
40	515	4
40	516	5
40	517	6
40	518	7
40	519	8
40	520	9
40	521	10
41	522	1
41	523	2
41	524	3
41	525	4
41	526	5
41	527	6
41	528	7
41	529	8
41	530	9
41	531	10
42	532	1
42	533	2
42	534	3
42	535	4
42	536	5
42	537	6
42	538	7
42	539	8
42	540	9
42	541	10
43	542	1
43	543	2
43	544	3
43	545	4
43	546	5
43	547	6
43	548	7
43	549	8
43	550	9
43	551	10
44	552	1
44	553	2
44	554	3
44	555	4
44	556	5
44	557	6
44	558	7
44	559	8
44	560	9
44	561	10
45	562	1
45	563	2
45	564	3
45	565	4
45	566	5
45	567	6
45	568	7
45	569	8
45	570	9
45	571	10
46	572	1
46	573	2
46	574	3
46	575	4
46	576	5
46	577	6
46	578	7
46	579	8
46	580	9
46	581	10
\.


--
-- Data for Name: study_days; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.study_days (id, deck_id, day_number, title, created_at) FROM stdin;
1	1	1	日常生活	2026-10-12 12:39:55.176268+00
2	1	2	日常生活	2026-10-12 13:23:11.865283+00
3	1	3	日常生活	2026-10-12 13:23:18.368292+00
4	1	4	日常生活	2026-10-12 13:23:23.721099+00
5	1	5	日常生活	2026-10-12 13:23:36.391079+00
6	1	6	日常生活	2026-10-12 13:23:46.236388+00
7	2	1	文字語彙	2026-10-12 18:32:33.835671+00
8	2	2	文字語彙	2026-10-12 18:32:40.140328+00
9	2	3	文字語彙	2026-10-12 18:32:49.568695+00
10	2	4	文字語彙	2026-10-12 18:32:53.266451+00
11	2	5	文字語彙	2026-10-12 18:32:56.515841+00
12	2	6	文字語彙	2026-10-12 18:33:00.140054+00
13	2	7	文字語彙	2026-10-12 18:33:03.590405+00
14	2	8	文字語彙	2026-10-12 18:33:07.262645+00
15	2	9	文字語彙	2026-10-12 18:33:10.616649+00
16	2	10	文字語彙	2026-10-12 18:33:14.212147+00
17	2	11	文字語彙	2026-10-13 06:26:58.674118+00
18	2	12	文字語彙	2026-10-13 06:27:02.023444+00
19	2	13	文字語彙	2026-10-13 06:27:05.995683+00
20	2	14	文字語彙	2026-10-13 06:27:09.863019+00
21	2	15	文字語彙	2026-10-13 06:27:13.520084+00
22	2	16	文字語彙	2026-10-13 06:27:16.768304+00
23	2	17	文字語彙	2026-10-13 06:27:20.396796+00
24	2	18	文字語彙	2026-10-13 06:27:23.808328+00
25	2	19	文字語彙	2026-10-13 06:27:27.513063+00
26	2	20	文字語彙	2026-10-13 06:27:31.013893+00
27	3	1	漢字	2026-10-13 13:03:39.854144+00
28	3	2	漢字	2026-10-13 13:03:45.4229+00
29	3	3	漢字	2026-10-13 13:03:50.046113+00
30	3	4	漢字	2026-10-13 13:03:58.737915+00
31	3	5	漢字	2026-10-13 13:04:27.513649+00
32	3	6	漢字	2026-10-13 13:04:36.028221+00
33	3	7	漢字	2026-10-13 13:04:44.219946+00
34	3	8	漢字	2026-10-13 13:04:47.426876+00
35	3	9	漢字	2026-10-13 13:04:53.53617+00
36	3	10	漢字	2026-10-13 13:04:59.613048+00
37	4	1	文字語彙・言葉	2026-11-09 09:25:36.513877+00
38	4	2	文字語彙・言葉	2026-11-09 09:25:44.376069+00
39	4	3	文字語彙・言葉	2026-11-09 09:25:54.723798+00
40	4	4	文字語彙・言葉	2026-11-09 09:26:09.561716+00
41	4	5	文字語彙・言葉	2026-11-09 09:26:15.893725+00
42	4	6	文字語彙・言葉	2026-11-09 09:26:30.924103+00
43	4	7	文字語彙・言葉	2026-11-09 09:26:46.153516+00
44	4	8	文字語彙・言葉	2026-11-09 09:26:56.138739+00
45	4	9	文字語彙・言葉	2026-11-09 09:27:01.553876+00
46	4	10	文字語彙・言葉	2026-11-09 09:45:07.898115+00
\.


--
-- Data for Name: study_session_cards; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.study_session_cards (session_id, card_id, "position", self_rating) FROM stdin;
2d15b9b6-9019-49dc-9985-d03a9e05a812	2	1	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	3	2	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	4	3	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	5	4	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	6	5	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	7	6	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	8	7	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	9	8	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	10	9	\N
2d15b9b6-9019-49dc-9985-d03a9e05a812	1	0	good
197f51be-3ad7-45b1-ae08-b06471729629	1	0	good
197f51be-3ad7-45b1-ae08-b06471729629	2	1	good
197f51be-3ad7-45b1-ae08-b06471729629	3	2	good
197f51be-3ad7-45b1-ae08-b06471729629	4	3	good
197f51be-3ad7-45b1-ae08-b06471729629	5	4	good
197f51be-3ad7-45b1-ae08-b06471729629	6	5	good
197f51be-3ad7-45b1-ae08-b06471729629	7	6	good
197f51be-3ad7-45b1-ae08-b06471729629	8	7	hard
197f51be-3ad7-45b1-ae08-b06471729629	9	8	good
197f51be-3ad7-45b1-ae08-b06471729629	10	9	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	1	0	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	2	1	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	3	2	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	4	3	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	5	4	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	6	5	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	7	6	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	8	7	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	9	8	good
bcc78f19-d73c-4652-b699-cf99eb58dc17	10	9	good
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	1	0	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	2	1	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	3	2	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	4	3	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	5	4	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	6	5	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	7	6	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	8	7	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	9	8	\N
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	10	9	\N
18c34842-7c12-448c-899c-819ad55221ac	17	6	\N
18c34842-7c12-448c-899c-819ad55221ac	18	7	\N
18c34842-7c12-448c-899c-819ad55221ac	19	8	\N
18c34842-7c12-448c-899c-819ad55221ac	20	9	\N
18c34842-7c12-448c-899c-819ad55221ac	11	0	good
18c34842-7c12-448c-899c-819ad55221ac	12	1	good
18c34842-7c12-448c-899c-819ad55221ac	13	2	good
18c34842-7c12-448c-899c-819ad55221ac	14	3	good
18c34842-7c12-448c-899c-819ad55221ac	15	4	good
18c34842-7c12-448c-899c-819ad55221ac	16	5	good
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	8	7	\N
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	9	8	\N
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	10	9	\N
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	1	0	good
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	2	1	good
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	3	2	good
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	4	3	good
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	5	4	good
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	6	5	good
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	7	6	good
d77ab905-ca1b-4d52-8de3-d6e84a826736	151	0	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	152	1	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	153	2	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	154	3	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	155	4	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	156	5	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	157	6	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	158	7	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	159	8	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	160	9	\N
08da729b-56ba-4afe-b789-a67e45636a6c	151	0	good
08da729b-56ba-4afe-b789-a67e45636a6c	152	1	good
08da729b-56ba-4afe-b789-a67e45636a6c	153	2	good
08da729b-56ba-4afe-b789-a67e45636a6c	154	3	good
08da729b-56ba-4afe-b789-a67e45636a6c	155	4	good
08da729b-56ba-4afe-b789-a67e45636a6c	156	5	good
08da729b-56ba-4afe-b789-a67e45636a6c	157	6	good
08da729b-56ba-4afe-b789-a67e45636a6c	158	7	good
08da729b-56ba-4afe-b789-a67e45636a6c	159	8	good
08da729b-56ba-4afe-b789-a67e45636a6c	160	9	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	161	0	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	162	1	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	163	2	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	164	3	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	165	4	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	166	5	hard
9e8d8865-ca0c-4720-92ed-c388966c4b9b	167	6	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	168	7	again
9e8d8865-ca0c-4720-92ed-c388966c4b9b	169	8	good
9e8d8865-ca0c-4720-92ed-c388966c4b9b	170	9	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	161	0	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	162	1	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	163	2	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	164	3	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	165	4	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	166	5	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	167	6	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	168	7	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	169	8	good
591eeb16-4f2a-4681-ae0d-a418d0d5f264	170	9	good
b7fb903d-d960-449c-9147-b67233808680	161	0	good
b7fb903d-d960-449c-9147-b67233808680	162	1	good
b7fb903d-d960-449c-9147-b67233808680	163	2	good
b7fb903d-d960-449c-9147-b67233808680	164	3	good
b7fb903d-d960-449c-9147-b67233808680	165	4	good
b7fb903d-d960-449c-9147-b67233808680	166	5	good
b7fb903d-d960-449c-9147-b67233808680	167	6	good
b7fb903d-d960-449c-9147-b67233808680	168	7	good
b7fb903d-d960-449c-9147-b67233808680	169	8	good
b7fb903d-d960-449c-9147-b67233808680	170	9	good
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	151	0	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	152	1	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	153	2	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	154	3	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	155	4	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	156	5	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	157	6	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	158	7	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	159	8	\N
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	160	9	\N
225e59f2-ffa1-49ea-8942-481123901337	151	0	good
225e59f2-ffa1-49ea-8942-481123901337	152	1	good
225e59f2-ffa1-49ea-8942-481123901337	153	2	good
225e59f2-ffa1-49ea-8942-481123901337	154	3	good
225e59f2-ffa1-49ea-8942-481123901337	155	4	good
225e59f2-ffa1-49ea-8942-481123901337	156	5	good
225e59f2-ffa1-49ea-8942-481123901337	157	6	good
225e59f2-ffa1-49ea-8942-481123901337	158	7	good
225e59f2-ffa1-49ea-8942-481123901337	159	8	good
225e59f2-ffa1-49ea-8942-481123901337	160	9	good
bfab1741-b59b-4dc0-a279-547dc8633a49	171	0	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	172	1	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	173	2	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	174	3	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	175	4	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	176	5	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	177	6	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	178	7	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	179	8	\N
bfab1741-b59b-4dc0-a279-547dc8633a49	180	9	\N
ea03fa6b-5d25-41ac-9548-d9610018bbb3	171	0	good
ea03fa6b-5d25-41ac-9548-d9610018bbb3	172	1	hard
ea03fa6b-5d25-41ac-9548-d9610018bbb3	173	2	good
ea03fa6b-5d25-41ac-9548-d9610018bbb3	174	3	good
ea03fa6b-5d25-41ac-9548-d9610018bbb3	175	4	good
ea03fa6b-5d25-41ac-9548-d9610018bbb3	176	5	hard
ea03fa6b-5d25-41ac-9548-d9610018bbb3	177	6	good
ea03fa6b-5d25-41ac-9548-d9610018bbb3	178	7	good
ea03fa6b-5d25-41ac-9548-d9610018bbb3	179	8	good
ea03fa6b-5d25-41ac-9548-d9610018bbb3	180	9	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	362	0	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	363	1	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	364	2	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	365	3	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	366	4	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	367	5	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	368	6	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	369	7	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	370	8	good
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	371	9	good
5e20be5f-e8b4-4ab8-badc-2a178a52f607	181	0	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	182	1	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	183	2	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	184	3	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	185	4	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	186	5	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	187	6	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	188	7	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	189	8	\N
5e20be5f-e8b4-4ab8-badc-2a178a52f607	190	9	\N
9bc23800-737c-425d-b4a2-67681636e9d5	181	0	good
9bc23800-737c-425d-b4a2-67681636e9d5	182	1	good
9bc23800-737c-425d-b4a2-67681636e9d5	183	2	good
9bc23800-737c-425d-b4a2-67681636e9d5	184	3	good
9bc23800-737c-425d-b4a2-67681636e9d5	185	4	good
9bc23800-737c-425d-b4a2-67681636e9d5	186	5	good
9bc23800-737c-425d-b4a2-67681636e9d5	187	6	good
9bc23800-737c-425d-b4a2-67681636e9d5	188	7	good
9bc23800-737c-425d-b4a2-67681636e9d5	189	8	good
9bc23800-737c-425d-b4a2-67681636e9d5	190	9	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	11	0	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	12	1	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	13	2	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	14	3	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	15	4	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	16	5	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	17	6	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	18	7	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	19	8	good
ea3fb395-52dc-465d-abd5-95fb969a2ed4	20	9	good
e0c4ceab-eafd-44fc-b659-7088435ec643	372	0	good
e0c4ceab-eafd-44fc-b659-7088435ec643	373	1	good
e0c4ceab-eafd-44fc-b659-7088435ec643	374	2	good
e0c4ceab-eafd-44fc-b659-7088435ec643	375	3	good
e0c4ceab-eafd-44fc-b659-7088435ec643	376	4	good
e0c4ceab-eafd-44fc-b659-7088435ec643	377	5	good
e0c4ceab-eafd-44fc-b659-7088435ec643	378	6	good
e0c4ceab-eafd-44fc-b659-7088435ec643	379	7	good
e0c4ceab-eafd-44fc-b659-7088435ec643	380	8	good
e0c4ceab-eafd-44fc-b659-7088435ec643	381	9	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	362	0	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	363	1	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	364	2	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	365	3	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	366	4	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	367	5	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	368	6	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	369	7	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	370	8	good
dc219d6a-e80c-4c67-9b3f-211c4df9883d	371	9	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	161	0	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	162	1	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	163	2	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	164	3	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	165	4	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	166	5	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	167	6	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	168	7	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	169	8	good
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	170	9	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	159	0	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	160	1	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	171	2	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	172	3	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	173	4	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	174	5	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	175	6	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	176	7	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	177	8	good
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	178	9	good
15159fd6-75bb-407b-bdef-f007c759306b	181	2	good
15159fd6-75bb-407b-bdef-f007c759306b	182	3	good
15159fd6-75bb-407b-bdef-f007c759306b	183	4	good
15159fd6-75bb-407b-bdef-f007c759306b	184	5	good
15159fd6-75bb-407b-bdef-f007c759306b	185	6	good
15159fd6-75bb-407b-bdef-f007c759306b	179	0	good
15159fd6-75bb-407b-bdef-f007c759306b	180	1	good
15159fd6-75bb-407b-bdef-f007c759306b	186	7	good
15159fd6-75bb-407b-bdef-f007c759306b	187	8	good
15159fd6-75bb-407b-bdef-f007c759306b	188	9	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	382	0	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	383	1	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	384	2	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	385	3	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	386	4	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	387	5	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	388	6	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	389	7	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	390	8	good
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	391	9	good
191f91bc-ee2e-4912-8525-a4fcf2310fa3	198	7	\N
191f91bc-ee2e-4912-8525-a4fcf2310fa3	199	8	\N
191f91bc-ee2e-4912-8525-a4fcf2310fa3	200	9	\N
191f91bc-ee2e-4912-8525-a4fcf2310fa3	191	0	good
191f91bc-ee2e-4912-8525-a4fcf2310fa3	192	1	good
191f91bc-ee2e-4912-8525-a4fcf2310fa3	193	2	good
191f91bc-ee2e-4912-8525-a4fcf2310fa3	194	3	good
191f91bc-ee2e-4912-8525-a4fcf2310fa3	195	4	good
191f91bc-ee2e-4912-8525-a4fcf2310fa3	196	5	good
191f91bc-ee2e-4912-8525-a4fcf2310fa3	197	6	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	181	0	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	182	1	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	183	2	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	184	3	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	185	4	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	186	5	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	187	6	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	188	7	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	189	8	good
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	190	9	good
7d041b9a-b922-4b54-a6ef-3a0485439846	191	0	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	192	1	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	193	2	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	194	3	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	195	4	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	196	5	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	197	6	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	198	7	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	199	8	\N
7d041b9a-b922-4b54-a6ef-3a0485439846	200	9	\N
31aee3c9-d101-456c-82f0-0d0063777d02	392	0	good
31aee3c9-d101-456c-82f0-0d0063777d02	393	1	good
31aee3c9-d101-456c-82f0-0d0063777d02	394	2	good
31aee3c9-d101-456c-82f0-0d0063777d02	395	3	good
31aee3c9-d101-456c-82f0-0d0063777d02	396	4	good
31aee3c9-d101-456c-82f0-0d0063777d02	397	5	good
31aee3c9-d101-456c-82f0-0d0063777d02	398	6	good
31aee3c9-d101-456c-82f0-0d0063777d02	399	7	good
31aee3c9-d101-456c-82f0-0d0063777d02	400	8	good
31aee3c9-d101-456c-82f0-0d0063777d02	401	9	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	373	0	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	374	1	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	375	2	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	376	3	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	377	4	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	378	5	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	379	6	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	380	7	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	381	8	good
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	372	9	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	363	0	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	364	1	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	369	2	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	366	3	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	367	4	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	368	5	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	365	6	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	370	7	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	371	8	good
fa5a2807-b42d-4946-91b3-8ac41b4be778	362	9	good
5c969fdd-acc6-4935-a45b-78feb35fd488	382	0	good
5c969fdd-acc6-4935-a45b-78feb35fd488	383	1	good
5c969fdd-acc6-4935-a45b-78feb35fd488	384	2	good
5c969fdd-acc6-4935-a45b-78feb35fd488	385	3	good
5c969fdd-acc6-4935-a45b-78feb35fd488	386	4	good
5c969fdd-acc6-4935-a45b-78feb35fd488	387	5	good
5c969fdd-acc6-4935-a45b-78feb35fd488	388	6	good
5c969fdd-acc6-4935-a45b-78feb35fd488	389	7	good
5c969fdd-acc6-4935-a45b-78feb35fd488	390	8	good
5c969fdd-acc6-4935-a45b-78feb35fd488	391	9	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	392	0	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	393	1	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	394	2	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	395	3	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	396	4	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	397	5	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	398	6	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	399	7	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	400	8	good
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	401	9	good
61873ad8-02ce-46c9-b781-f2735620661c	482	0	good
61873ad8-02ce-46c9-b781-f2735620661c	483	1	good
61873ad8-02ce-46c9-b781-f2735620661c	484	2	good
61873ad8-02ce-46c9-b781-f2735620661c	485	3	good
61873ad8-02ce-46c9-b781-f2735620661c	486	4	good
61873ad8-02ce-46c9-b781-f2735620661c	487	5	good
61873ad8-02ce-46c9-b781-f2735620661c	488	6	good
61873ad8-02ce-46c9-b781-f2735620661c	489	7	good
61873ad8-02ce-46c9-b781-f2735620661c	490	8	good
61873ad8-02ce-46c9-b781-f2735620661c	491	9	again
98928966-a021-4edb-ad5a-062847c349f2	191	0	\N
98928966-a021-4edb-ad5a-062847c349f2	192	1	\N
98928966-a021-4edb-ad5a-062847c349f2	193	2	\N
98928966-a021-4edb-ad5a-062847c349f2	194	3	\N
98928966-a021-4edb-ad5a-062847c349f2	195	4	\N
98928966-a021-4edb-ad5a-062847c349f2	196	5	\N
98928966-a021-4edb-ad5a-062847c349f2	197	6	\N
98928966-a021-4edb-ad5a-062847c349f2	198	7	\N
98928966-a021-4edb-ad5a-062847c349f2	199	8	\N
98928966-a021-4edb-ad5a-062847c349f2	200	9	\N
f90229e5-807a-4964-b64c-c54c48debd34	192	1	good
f90229e5-807a-4964-b64c-c54c48debd34	191	0	good
f90229e5-807a-4964-b64c-c54c48debd34	193	2	good
f90229e5-807a-4964-b64c-c54c48debd34	194	3	good
f90229e5-807a-4964-b64c-c54c48debd34	195	4	good
f90229e5-807a-4964-b64c-c54c48debd34	196	5	good
f90229e5-807a-4964-b64c-c54c48debd34	197	6	good
f90229e5-807a-4964-b64c-c54c48debd34	198	7	good
f90229e5-807a-4964-b64c-c54c48debd34	199	8	good
f90229e5-807a-4964-b64c-c54c48debd34	200	9	good
701ad056-7340-4277-a658-3acf9a5c0487	201	0	\N
701ad056-7340-4277-a658-3acf9a5c0487	202	1	\N
701ad056-7340-4277-a658-3acf9a5c0487	203	2	\N
701ad056-7340-4277-a658-3acf9a5c0487	204	3	\N
701ad056-7340-4277-a658-3acf9a5c0487	205	4	\N
701ad056-7340-4277-a658-3acf9a5c0487	206	5	\N
701ad056-7340-4277-a658-3acf9a5c0487	207	6	\N
701ad056-7340-4277-a658-3acf9a5c0487	208	7	\N
701ad056-7340-4277-a658-3acf9a5c0487	209	8	\N
701ad056-7340-4277-a658-3acf9a5c0487	210	9	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	201	0	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	202	1	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	203	2	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	204	3	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	205	4	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	206	5	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	207	6	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	208	7	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	209	8	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	210	9	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	202	1	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	203	2	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	204	3	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	205	4	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	206	5	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	207	6	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	208	7	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	209	8	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	210	9	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	201	0	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	201	0	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	202	1	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	203	2	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	204	3	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	205	4	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	206	5	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	207	6	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	208	7	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	209	8	good
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	210	9	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	151	0	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	152	1	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	153	2	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	154	3	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	155	4	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	156	5	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	157	6	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	158	7	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	172	8	good
bee0b6e7-cbaf-42bc-8732-88543f67970c	176	9	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	211	0	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	212	1	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	213	2	again
682f2896-13e8-4d34-acd4-93cdbb0367c7	214	3	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	215	4	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	216	5	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	217	6	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	218	7	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	219	8	good
682f2896-13e8-4d34-acd4-93cdbb0367c7	220	9	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	221	0	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	222	1	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	223	2	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	224	3	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	225	4	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	226	5	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	227	6	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	228	7	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	229	8	good
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	230	9	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	231	0	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	232	1	hard
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	233	2	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	234	3	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	235	4	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	236	5	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	237	6	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	238	7	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	239	8	good
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	240	9	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	178	0	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	161	1	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	162	2	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	163	3	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	164	4	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	165	5	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	166	6	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	167	7	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	168	8	good
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	169	9	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	250	9	\N
d4b6b750-d121-4d85-b630-2455c5f3a7c6	241	0	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	242	1	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	243	2	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	244	3	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	245	4	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	246	5	again
d4b6b750-d121-4d85-b630-2455c5f3a7c6	247	6	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	248	7	good
d4b6b750-d121-4d85-b630-2455c5f3a7c6	249	8	good
\.


--
-- Data for Name: study_sessions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.study_sessions (id, deck_id, day_id, mode, status, created_at, finished_at) FROM stdin;
2d15b9b6-9019-49dc-9985-d03a9e05a812	1	1	new	studying	2026-10-12 13:26:39.0321+00	\N
197f51be-3ad7-45b1-ae08-b06471729629	1	1	new	quizzing	2026-10-12 15:41:45.08537+00	\N
bcc78f19-d73c-4652-b699-cf99eb58dc17	1	1	new	completed	2026-10-12 15:51:49.032123+00	2026-10-12 16:30:07.461977+00
b0d14222-9bd6-4772-8f40-3f9fec2ce03e	1	1	new	studying	2026-10-12 16:32:15.216105+00	\N
18c34842-7c12-448c-899c-819ad55221ac	1	2	new	studying	2026-10-12 17:11:49.724848+00	\N
d7ef0efd-2050-49b1-a06c-b0f6c8209dc8	1	1	new	studying	2026-10-12 17:46:12.386631+00	\N
5ee37a7e-8eb0-401e-99a0-67ed25363f49	2	7	new	quizzing	2026-10-12 19:39:28.35634+00	\N
d77ab905-ca1b-4d52-8de3-d6e84a826736	2	7	new	studying	2026-10-13 06:53:34.784329+00	\N
08da729b-56ba-4afe-b789-a67e45636a6c	2	7	new	completed	2026-10-13 06:59:27.040768+00	2026-10-13 07:02:57.863833+00
9e8d8865-ca0c-4720-92ed-c388966c4b9b	2	8	new	quizzing	2026-10-13 09:30:48.482897+00	\N
591eeb16-4f2a-4681-ae0d-a418d0d5f264	2	8	new	quizzing	2026-10-13 11:58:32.464592+00	\N
bee0b6e7-cbaf-42bc-8732-88543f67970c	2	\N	review	completed	2026-11-12 05:04:47.331485+00	2026-11-12 05:06:48.269581+00
b7fb903d-d960-449c-9147-b67233808680	2	8	new	completed	2026-10-13 12:01:57.00595+00	2026-10-13 12:06:16.056811+00
1b6a9d5c-e9a8-4b02-abdf-7b81f5f19f2b	2	7	new	studying	2026-10-13 12:23:32.929695+00	\N
225e59f2-ffa1-49ea-8942-481123901337	2	\N	review	completed	2026-10-16 04:00:22.684196+00	2026-10-16 04:02:27.041618+00
bfab1741-b59b-4dc0-a279-547dc8633a49	2	9	new	studying	2026-10-16 04:02:46.954438+00	\N
ea03fa6b-5d25-41ac-9548-d9610018bbb3	2	9	new	completed	2026-10-16 04:03:26.395962+00	2026-10-16 04:05:44.557376+00
682f2896-13e8-4d34-acd4-93cdbb0367c7	2	13	new	completed	2026-11-13 09:27:51.611745+00	2026-11-13 09:30:13.40632+00
4419ce06-845c-4d10-8c23-6e6b5f71b9c0	3	27	new	completed	2026-10-16 04:05:56.889573+00	2026-10-16 04:08:36.594114+00
5e20be5f-e8b4-4ab8-badc-2a178a52f607	2	10	new	studying	2026-10-16 08:02:20.536886+00	\N
9bc23800-737c-425d-b4a2-67681636e9d5	2	10	new	completed	2026-10-16 08:04:50.704831+00	2026-10-16 08:07:48.057347+00
ea3fb395-52dc-465d-abd5-95fb969a2ed4	1	2	new	quizzing	2026-10-19 15:55:10.743761+00	\N
e0c4ceab-eafd-44fc-b659-7088435ec643	3	28	new	completed	2026-10-20 04:46:50.038188+00	2026-10-20 04:49:21.660966+00
89bbaf16-027b-4bc6-a480-8aad66bb5e3f	2	14	new	completed	2026-11-13 09:30:29.049595+00	2026-11-13 09:32:48.504999+00
dc219d6a-e80c-4c67-9b3f-211c4df9883d	3	\N	review	completed	2026-10-20 04:49:29.473136+00	2026-10-20 04:51:43.2102+00
94f56e2f-7e29-4f5f-bdb0-0a756804ef7f	2	\N	review	completed	2026-10-20 04:52:08.984676+00	2026-10-20 04:54:16.136925+00
65b574ee-4f5d-4d74-95ec-8ac6c48ea7be	2	\N	review	completed	2026-10-20 04:54:38.688975+00	2026-10-20 04:56:33.956829+00
cd7d7fe9-8b61-4dbf-a6a3-dccfbdc8548c	2	15	new	completed	2026-11-13 09:32:57.941354+00	2026-11-13 09:37:04.096508+00
15159fd6-75bb-407b-bdef-f007c759306b	2	\N	review	completed	2026-10-20 04:57:08.646216+00	2026-10-20 04:59:09.971248+00
a0e5b3e8-c624-4fef-a5a6-fda1a8a9059f	3	29	new	completed	2026-10-28 11:09:07.963116+00	2026-10-28 11:12:42.16773+00
191f91bc-ee2e-4912-8525-a4fcf2310fa3	2	11	new	studying	2026-10-28 11:13:01.187442+00	\N
8ae9376e-5a7e-410c-aaec-15a8b6f19bdc	2	10	new	completed	2026-10-28 12:08:13.377085+00	2026-10-28 12:11:29.218395+00
7d041b9a-b922-4b54-a6ef-3a0485439846	2	11	new	studying	2026-10-28 12:11:45.828782+00	\N
103a6dfa-d97c-418d-a7cc-d0f9167b4a80	2	\N	review	completed	2026-11-13 09:42:50.125134+00	2026-11-13 09:46:00.455858+00
31aee3c9-d101-456c-82f0-0d0063777d02	3	30	new	completed	2026-10-28 12:12:20.413095+00	2026-10-28 12:18:11.192272+00
d4b6b750-d121-4d85-b630-2455c5f3a7c6	2	16	new	studying	2026-11-13 09:46:49.955864+00	\N
6bde9a3f-64c0-4eb5-b976-4cc8834a5357	3	\N	review	completed	2026-11-07 14:24:54.037509+00	2026-11-07 14:26:47.967982+00
fa5a2807-b42d-4946-91b3-8ac41b4be778	3	\N	review	completed	2026-11-07 14:27:00.067776+00	2026-11-07 14:29:57.256053+00
5c969fdd-acc6-4935-a45b-78feb35fd488	3	\N	review	completed	2026-11-07 14:30:10.375009+00	2026-11-07 14:32:15.560783+00
9543c75b-2a7c-41eb-8f4c-f917b466b5f6	3	\N	review	quizzing	2026-11-08 12:57:52.492012+00	\N
61873ad8-02ce-46c9-b781-f2735620661c	4	37	new	quizzing	2026-11-09 10:00:15.356036+00	\N
98928966-a021-4edb-ad5a-062847c349f2	2	11	new	studying	2026-11-12 04:55:34.712757+00	\N
f90229e5-807a-4964-b64c-c54c48debd34	2	11	new	completed	2026-11-12 04:58:03.441572+00	2026-11-12 05:01:07.223462+00
701ad056-7340-4277-a658-3acf9a5c0487	2	12	new	studying	2026-11-12 05:01:21.501505+00	\N
9bc367a7-b8a4-4240-bd45-1deeb272fc50	2	12	new	studying	2026-11-12 05:01:26.355748+00	\N
01d33d47-0860-48ea-8df7-9cebd96874ce	2	12	new	studying	2026-11-12 05:01:30.336658+00	\N
6a8c3db1-6a93-4694-b8a0-c5ebd86ba848	2	12	new	completed	2026-11-12 05:01:33.877919+00	2026-11-12 05:04:19.285918+00
\.


--
-- Name: decks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.decks_id_seq', 4, true);


--
-- Name: flashcards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.flashcards_id_seq', 581, true);


--
-- Name: quiz_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.quiz_answers_id_seq', 858, true);


--
-- Name: review_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.review_history_id_seq', 250, true);


--
-- Name: study_days_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.study_days_id_seq', 46, true);


--
-- Name: card_review_states card_review_states_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.card_review_states
    ADD CONSTRAINT card_review_states_pkey PRIMARY KEY (card_id);


--
-- Name: decks decks_name_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT decks_name_unique UNIQUE (name);


--
-- Name: decks decks_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT decks_pkey PRIMARY KEY (id);


--
-- Name: flashcards flashcards_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.flashcards
    ADD CONSTRAINT flashcards_pkey PRIMARY KEY (id);


--
-- Name: quiz_answers quiz_answers_attempt_id_stage_item_key_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.quiz_answers
    ADD CONSTRAINT quiz_answers_attempt_id_stage_item_key_key UNIQUE (attempt_id, stage, item_key);


--
-- Name: quiz_answers quiz_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.quiz_answers
    ADD CONSTRAINT quiz_answers_pkey PRIMARY KEY (id);


--
-- Name: quiz_attempts quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_pkey PRIMARY KEY (id);


--
-- Name: quiz_attempts quiz_attempts_session_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_session_id_key UNIQUE (session_id);


--
-- Name: review_history review_history_card_id_session_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.review_history
    ADD CONSTRAINT review_history_card_id_session_id_key UNIQUE (card_id, session_id);


--
-- Name: review_history review_history_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.review_history
    ADD CONSTRAINT review_history_pkey PRIMARY KEY (id);


--
-- Name: study_day_cards study_day_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_day_cards
    ADD CONSTRAINT study_day_cards_pkey PRIMARY KEY (day_id, card_id);


--
-- Name: study_days study_days_deck_id_day_number_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_days
    ADD CONSTRAINT study_days_deck_id_day_number_key UNIQUE (deck_id, day_number);


--
-- Name: study_days study_days_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_days
    ADD CONSTRAINT study_days_pkey PRIMARY KEY (id);


--
-- Name: study_session_cards study_session_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_session_cards
    ADD CONSTRAINT study_session_cards_pkey PRIMARY KEY (session_id, card_id);


--
-- Name: study_sessions study_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_sessions
    ADD CONSTRAINT study_sessions_pkey PRIMARY KEY (id);


--
-- Name: flashcards_unique_active; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX flashcards_unique_active ON public.flashcards USING btree (deck_id, lower(btrim(kanji)), lower(btrim(furigana)), lower(btrim(arti))) WHERE (archived = false);


--
-- Name: idx_day_cards; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_day_cards ON public.study_day_cards USING btree (day_id, "position");


--
-- Name: idx_due_reviews; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_due_reviews ON public.card_review_states USING btree (next_review_at);


--
-- Name: idx_flashcards_deck; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_flashcards_deck ON public.flashcards USING btree (deck_id, id) WHERE (archived = false);


--
-- Name: idx_quiz_answers_attempt; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_quiz_answers_attempt ON public.quiz_answers USING btree (attempt_id, stage);


--
-- Name: card_review_states card_review_states_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.card_review_states
    ADD CONSTRAINT card_review_states_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.flashcards(id) ON DELETE CASCADE;


--
-- Name: flashcards flashcards_deck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.flashcards
    ADD CONSTRAINT flashcards_deck_id_fkey FOREIGN KEY (deck_id) REFERENCES public.decks(id) ON DELETE CASCADE;


--
-- Name: quiz_answers quiz_answers_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.quiz_answers
    ADD CONSTRAINT quiz_answers_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.quiz_attempts(id) ON DELETE CASCADE;


--
-- Name: quiz_answers quiz_answers_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.quiz_answers
    ADD CONSTRAINT quiz_answers_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.flashcards(id) ON DELETE CASCADE;


--
-- Name: quiz_attempts quiz_attempts_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.study_sessions(id) ON DELETE CASCADE;


--
-- Name: review_history review_history_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.review_history
    ADD CONSTRAINT review_history_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.flashcards(id) ON DELETE CASCADE;


--
-- Name: review_history review_history_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.review_history
    ADD CONSTRAINT review_history_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.study_sessions(id) ON DELETE SET NULL;


--
-- Name: study_day_cards study_day_cards_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_day_cards
    ADD CONSTRAINT study_day_cards_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.flashcards(id) ON DELETE CASCADE;


--
-- Name: study_day_cards study_day_cards_day_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_day_cards
    ADD CONSTRAINT study_day_cards_day_id_fkey FOREIGN KEY (day_id) REFERENCES public.study_days(id) ON DELETE CASCADE;


--
-- Name: study_days study_days_deck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_days
    ADD CONSTRAINT study_days_deck_id_fkey FOREIGN KEY (deck_id) REFERENCES public.decks(id) ON DELETE CASCADE;


--
-- Name: study_session_cards study_session_cards_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_session_cards
    ADD CONSTRAINT study_session_cards_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.flashcards(id) ON DELETE CASCADE;


--
-- Name: study_session_cards study_session_cards_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_session_cards
    ADD CONSTRAINT study_session_cards_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.study_sessions(id) ON DELETE CASCADE;


--
-- Name: study_sessions study_sessions_day_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_sessions
    ADD CONSTRAINT study_sessions_day_id_fkey FOREIGN KEY (day_id) REFERENCES public.study_days(id) ON DELETE SET NULL;


--
-- Name: study_sessions study_sessions_deck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.study_sessions
    ADD CONSTRAINT study_sessions_deck_id_fkey FOREIGN KEY (deck_id) REFERENCES public.decks(id) ON DELETE CASCADE;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT SELECT,INSERT,DELETE,TRUNCATE,MAINTAIN,UPDATE ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

\unrestrict KNHDnJgXUrrXpgBvzlLFpF4QyXETTev6pASmPl5vMJep4V3JiwIpI2IjHDYnJw9

