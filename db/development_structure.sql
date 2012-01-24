CREATE TABLE "collectors" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" varchar(255), "user_name" varchar(255), "full_name" varchar(255), "auth_token" varchar(255), "created_at" datetime, "updated_at" datetime, "last_login" datetime, "collection_synced" boolean DEFAULT 'f');
CREATE TABLE "delayed_jobs" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "priority" integer DEFAULT 0, "attempts" integer DEFAULT 0, "handler" text, "last_error" text, "run_at" datetime, "locked_at" datetime, "failed_at" datetime, "locked_by" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "flickr_streams" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" varchar(255), "last_sync" datetime, "created_at" datetime, "updated_at" datetime, "type" varchar(255), "username" varchar(255), "collector_id" integer, "collecting" boolean DEFAULT 'f');
CREATE TABLE "monthly_scores" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "month" integer, "year" integer, "score" float DEFAULT 0, "num_of_pics" integer DEFAULT 0, "flickr_stream_id" integer, "flickr_stream_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "pictures" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "url" varchar(255), "created_at" datetime, "updated_at" datetime, "date_upload" datetime, "pic_info_dump" text, "viewed" boolean DEFAULT 'f', "owner_name" varchar(255), "stream_rating" float, "rating" integer DEFAULT 0, "collector_id" integer, "faved_at" datetime, "no_longer_valid" boolean, "description" text);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "syncages" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "picture_id" integer, "flickr_stream_id" integer, "flickr_stream_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE INDEX "delayed_jobs_priority" ON "delayed_jobs" ("priority", "run_at");
CREATE UNIQUE INDEX "index_collectors_on_user_id" ON "collectors" ("user_id");
CREATE INDEX "index_flickr_streams_on_collector_id" ON "flickr_streams" ("collector_id");
CREATE INDEX "index_pictures_on_collector_id" ON "pictures" ("collector_id");
CREATE INDEX "index_pictures_on_date_upload" ON "pictures" ("date_upload");
CREATE INDEX "index_pictures_on_stream_rating" ON "pictures" ("stream_rating");
CREATE INDEX "index_pictures_on_url" ON "pictures" ("url");
CREATE INDEX "index_pictures_on_viewed" ON "pictures" ("viewed");
CREATE INDEX "index_syncages_on_flickr_stream_id" ON "syncages" ("flickr_stream_id");
CREATE INDEX "index_syncages_on_picture_id" ON "syncages" ("picture_id");
CREATE INDEX "index_syncages_on_picture_id_and_flickr_stream_id" ON "syncages" ("picture_id", "flickr_stream_id");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20110225024612');

INSERT INTO schema_migrations (version) VALUES ('20110226060241');

INSERT INTO schema_migrations (version) VALUES ('20110226221309');

INSERT INTO schema_migrations (version) VALUES ('20110227031541');

INSERT INTO schema_migrations (version) VALUES ('20110228040558');

INSERT INTO schema_migrations (version) VALUES ('20110301014445');

INSERT INTO schema_migrations (version) VALUES ('20110301043936');

INSERT INTO schema_migrations (version) VALUES ('20110303055610');

INSERT INTO schema_migrations (version) VALUES ('20110303235140');

INSERT INTO schema_migrations (version) VALUES ('20110305010643');

INSERT INTO schema_migrations (version) VALUES ('20110322004852');

INSERT INTO schema_migrations (version) VALUES ('20110323002535');

INSERT INTO schema_migrations (version) VALUES ('20110323004903');

INSERT INTO schema_migrations (version) VALUES ('20110326164354');

INSERT INTO schema_migrations (version) VALUES ('20110327033018');

INSERT INTO schema_migrations (version) VALUES ('20110327052803');

INSERT INTO schema_migrations (version) VALUES ('20110408234122');

INSERT INTO schema_migrations (version) VALUES ('20110409145418');

INSERT INTO schema_migrations (version) VALUES ('20110413004902');

INSERT INTO schema_migrations (version) VALUES ('20110413011845');

INSERT INTO schema_migrations (version) VALUES ('20110413020417');

INSERT INTO schema_migrations (version) VALUES ('20110428011151');

INSERT INTO schema_migrations (version) VALUES ('20110428021146');

INSERT INTO schema_migrations (version) VALUES ('20110724185443');

INSERT INTO schema_migrations (version) VALUES ('20110730132423');

INSERT INTO schema_migrations (version) VALUES ('20110811211434');

INSERT INTO schema_migrations (version) VALUES ('20110813213251');

INSERT INTO schema_migrations (version) VALUES ('20110820042648');

INSERT INTO schema_migrations (version) VALUES ('20110828011824');

INSERT INTO schema_migrations (version) VALUES ('20110918025317');

INSERT INTO schema_migrations (version) VALUES ('20111006024816');

INSERT INTO schema_migrations (version) VALUES ('20111016183937');

INSERT INTO schema_migrations (version) VALUES ('20111108002519');

INSERT INTO schema_migrations (version) VALUES ('20111108002647');

INSERT INTO schema_migrations (version) VALUES ('20120124195930');