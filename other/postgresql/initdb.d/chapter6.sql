CREATE TABLE users (
    user_id serial PRIMARY KEY,
    user_name varchar(32) NOT NULL CHECK (user_name ~ '^[\w\-]{5,32}$' AND user_name !~ '^\d+$'),
    user_pw_hash text NOT NULL,
    email text NOT NULL,
    description text,
    created_ad timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_ad timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX users_user_name_lower_key on users (lower(user_name));
CREATE UNIQUE INDEX users_email_lower_key on users (lower(user_name));

CREATE TABLE posts (
    post_id bigserial PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    post varchar(140) NOT NULL,
    created_ad timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE follows (
    user_id integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    followed_user_id integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_ad timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, followed_user_id)
);

CREATE TABLE comments (
    comment_id bigserial PRIMARY KEY,
    post_id bigint NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
    user_id integer NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    parent_comment_id bigint REFERENCES comments(comment_id) ON DELETE CASCADE,
    comment varchar(140),
    created_ad timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);
