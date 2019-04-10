CREATE TABLE `faraohunt`(
  `hunt_seq` INTEGER DEFAULT(NULL) NOT NULL PRIMARY KEY AUTOINCREMENT,
  `hunt_date` timestamp DEFAULT(NULL) NOT NULL,
  `user_id` TEXT DEFAULT(NULL) NOT NULL,
  `user_distinct` TEXT DEFAULT(NULL) NOT NULL,
  `user_name` TEXT DEFAULT(NULL) NOT NULL,
  `user_hunt_count` INTEGER DEFAULT(NULL) NOT NULL,
  `elapsed_time` REAL DEFAULT(NULL) NOT NULL,
  `drop01` INTEGER DEFAULT(0) NULL,
  `drop02` INTEGER DEFAULT(0) NULL,
  `drop03` INTEGER DEFAULT(0) NULL,
  `drop04` INTEGER DEFAULT(0) NULL,
  `drop05` INTEGER DEFAULT(0) NULL,
  `drop06` INTEGER DEFAULT(0) NULL,
  `drop07` INTEGER DEFAULT(0) NULL,
  `drop08` INTEGER DEFAULT(0) NULL,
  `drop09` INTEGER DEFAULT(0) NULL,
  `drop10` INTEGER DEFAULT(0) NULL,
  `drop11` INTEGER DEFAULT(0) NULL,
  `drop12` INTEGER DEFAULT(0) NULL,
  `drop13` INTEGER DEFAULT(0) NULL,
  `drop14` INTEGER DEFAULT(0) NULL,
  `drop15` INTEGER DEFAULT(0) NULL,
  `drop16` INTEGER DEFAULT(0) NULL,
  `drop17` INTEGER DEFAULT(0) NULL,
  `drop18` INTEGER DEFAULT(0) NULL,
  `drop19` INTEGER DEFAULT(0) NULL,
  `drop20` INTEGER DEFAULT(0) NULL
)