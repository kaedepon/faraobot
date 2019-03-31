CREATE TABLE "tabletrefine" (
	"refine_seq"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"refine_date"	DATE NOT NULL,
	"user_id"	TEXT NOT NULL,
	"user_distinct"	TEXT NOT NULL,
	"user_name"	TEXT NOT NULL,
	"user_refine_count"	INTEGER NOT NULL,
	"refine_result"	INTEGER NOT NULL
)
