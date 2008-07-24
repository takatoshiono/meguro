CREATE TABLE `job_man` (
  `uniqueid` char(32) NOT NULL,
  `jobid` bigint(20) unsigned NOT NULL,
  `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`uniqueid`),
  UNIQUE KEY `uniqueid` (`uniqueid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table kml (
    id int not null auto_increment,
    title varchar(64) not null,
    kml text not null,
    created_at datetime not null,
    primary key(id)
) engine=innodb default charset=utf8;

