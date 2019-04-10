CREATE TABLE `tabletrefine`(
  `refine_seq` INTEGER DEFAULT(NULL) NOT NULL PRIMARY KEY AUTOINCREMENT,
  `refine_date` timestamp DEFAULT(NULL) NOT NULL,
  `user_id` TEXT DEFAULT(NULL) NOT NULL,
  `user_distinct` TEXT DEFAULT(NULL) NOT NULL,
  `user_name` TEXT DEFAULT(NULL) NOT NULL,
  `user_refine_count` INTEGER DEFAULT(NULL) NOT NULL,
  `refine_result` INTEGER DEFAULT(NULL) NOT NULL
)
