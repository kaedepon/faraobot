CREATE TABLE `tabletcomplete_past`(
  `user_id` TEXT DEFAULT(NULL) NOT NULL,
  `user_distinct` TEXT DEFAULT(NULL) NOT NULL,
  `user_name` TEXT DEFAULT(NULL) NOT NULL,
  `user_refine_count` INTEGER DEFAULT(NULL) NOT NULL,
  `total_refine_count` INTEGER DEFAULT(NULL) NOT NULL,
  `refine_date` timestamp DEFAULT(NULL) NOT NULL
)
