CREATE TABLE IF NOT EXISTS `owned_safes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(46) DEFAULT NULL,
  `x` double DEFAULT NULL,
  `y` double DEFAULT NULL,
  `z` double DEFAULT NULL,
  `heading` double NOT NULL DEFAULT 0,
  `cracked` varchar(50) NOT NULL DEFAULT 'false',
  `access_list` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
