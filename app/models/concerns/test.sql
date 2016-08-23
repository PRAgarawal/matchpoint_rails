SELECT matches.*, COUNT(match_users.id) AS num_users, array_agg(match_users.user_id) AS user_ids FROM "matches"
  INNER JOIN match_users ON match_users.match_id = matches.id
  WHERE (matches.id IN (
    SELECT matches.id FROM "matches"
      INNER JOIN "courts" ON "courts"."id" = "matches"."court_id"
      INNER JOIN "match_users" ON "match_users"."match_id" = "matches"."id"
      INNER JOIN "users" ON "users"."id" = "match_users"."user_id"
        WHERE (users.id IN (2,3))
    UNION
    SELECT matches.id FROM "matches"
      INNER JOIN "courts" ON "courts"."id" = "matches"."court_id"
      INNER JOIN "match_users" ON "match_users"."match_id" = "matches"."id"
      INNER JOIN "users" ON "users"."id" = "match_users"."user_id"
        WHERE "users"."id" = 1 AND "matches"."is_friends_only" = 'f'))
  GROUP BY matches.id


SELECT matches.*, count(match_users.id) AS num_users, array_agg(match_users.user_id) AS user_ids FROM "matches"
  INNER JOIN "match_users" ON "match_users"."match_id" = "matches"."id"
  WHERE (matches.id IN (
    SELECT matches.id FROM "matches"
      INNER JOIN "courts" ON "courts"."id" = "matches"."court_id"
      INNER JOIN "match_users" ON "match_users"."match_id" = "matches"."id"
      INNER JOIN "users" ON "users"."id" = "match_users"."user_id"
        WHERE (users.id IN (2,3))
    UNION
    SELECT matches.id FROM "matches"
      INNER JOIN "courts" ON "courts"."id" = "matches"."court_id"
      INNER JOIN "match_users" ON "match_users"."match_id" = "matches"."id"
      INNER JOIN "users" ON "users"."id" = "match_users"."user_id"
        WHERE "users"."id" = 1 AND "matches"."is_friends_only" = 'f'))
    AND (1 = ANY(SELECT id FROM users WHERE users.id = match_users.user_id))
    AND (matches.match_date >= CURRENT_DATE)
GROUP BY matches.id
