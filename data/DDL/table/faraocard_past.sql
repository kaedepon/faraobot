CREATE TABLE `faraocard_past`(
  `user_id` TEXT DEFAULT(NULL) NOT NULL,
  `user_distinct` TEXT DEFAULT(NULL) NOT NULL,
  `user_name` TEXT DEFAULT(NULL) NOT NULL,
  `user_hunt_count` INTEGER DEFAULT(NULL) NOT NULL,
  `total_hunt_count` INTEGER DEFAULT(NULL) NOT NULL,
  `hunt_date` timestamp DEFAULT(NULL) NOT NULL PRIMARY KEY
)
