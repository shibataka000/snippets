CREATE TABLE public.item
(
    id integer,
    name text NOT NULL,
    price integer,
    PRIMARY KEY (id),
    CONSTRAINT price_check_constraint CHECK (price > 0) NOT VALID
);

INSERT INTO public.item VALUES (1, 'オレンジジュース', 120);
INSERT INTO public.item VALUES (2, 'チョコ', 30);
INSERT INTO public.item VALUES (3, 'かき氷', 100);
INSERT INTO public.item VALUES (4, 'レモンティー', 300);
INSERT INTO public.item VALUES (5, 'チーズケーキ', 550);
