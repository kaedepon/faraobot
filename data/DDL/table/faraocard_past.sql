CREATE TABLE "faraocard_past" (
	"user_id"	TEXT NOT NULL,
	"user_distinct"	TEXT NOT NULL,
	"user_name"	TEXT NOT NULL,
	"user_hunt_count"	INTEGER NOT NULL,
	"total_hunt_count"	INTEGER NOT NULL,
	"hunt_date"	DATE NOT NULL,
	PRIMARY KEY("hunt_date")
)
