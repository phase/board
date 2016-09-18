# board

This is some board software written in Crystal. It was inspired by Acmlmboard
and its derivatives.

There is no name for it yet. `CryBoard` or `BoardCr` may be used.

## Installing

### MySQL

Open your MySQL shell.

```bash
$ mysql -u root -p
```

Create the database and tables.

```sql
-- Create the database and select it
create database cryboard;
use cryboard;

-- Create the tables
CREATE TABLE `users` (
  `id` int(32) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `displayname` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `powerlevel` int(1) NOT NULL DEFAULT '0',
  `sex` int(1) NOT NULL DEFAULT '2',
  `namecolor` varchar(6) DEFAULT NULL,
  `lastip` varchar(32) DEFAULT NULL,
  `ban_expire` int(32) DEFAULT '0',
  `since` int(32) NOT NULL DEFAULT '0',
  `ppp` int(3) NOT NULL DEFAULT '25',
  `tpp` int(3) NOT NULL DEFAULT '25',
  `head` text,
  `sign` text,
  `dateformat` varchar(32) DEFAULT NULL,
  `timeformat` varchar(32) DEFAULT NULL,
  `lastpost` int(32) NOT NULL DEFAULT '0',
  `lastview` int(32) NOT NULL DEFAULT '0',
  `lastforum` int(32) NOT NULL DEFAULT '0',
  `bio` text,
  `posts` int(32) NOT NULL DEFAULT '0',
  `threads` int(32) NOT NULL DEFAULT '0',
  `email` varchar(64) NOT NULL DEFAULT '',
  `homepage` varchar(64) NOT NULL DEFAULT '',
  `youtube` varchar(64) NOT NULL DEFAULT '',
  `twitter` varchar(64) NOT NULL DEFAULT '',
  `facebook` varchar(64) NOT NULL DEFAULT '',
  `homepage_name` varchar(64) NOT NULL DEFAULT '',
  `tzoff` int(2) NOT NULL DEFAULT '0',
  `realname` varchar(64) NOT NULL DEFAULT '',
  `location` varchar(64) NOT NULL DEFAULT '',
  `birthday` int(32) DEFAULT NULL,
  `theme` int(8) NOT NULL DEFAULT '1',
  `showhead` tinyint(1) NOT NULL DEFAULT '1',
  `signsep` int(3) NOT NULL DEFAULT '1',
  `icon` text,
  `spent` int(32) NOT NULL DEFAULT '0',
  `gcoins` int(32) NOT NULL DEFAULT '0',
  `gspent` int(32) NOT NULL DEFAULT '0',
  `radar_mode` int(4) NOT NULL DEFAULT '0',
  `profile_locked` tinyint(1) NOT NULL DEFAULT '0',
  `editing_locked` int(1) NOT NULL DEFAULT '0',
  `title_status` int(1) NOT NULL DEFAULT '0',
  `rankset` int(4) NOT NULL DEFAULT '1',
  `publicemail` tinyint(1) NOT NULL DEFAULT '2',
  `class` smallint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `posts` (
  `id` int(32) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `text` text NOT NULL,
  `time` int(32) NOT NULL,
  `thread` int(32) NOT NULL,
  `user` int(32) NOT NULL,
  `rev` int(4) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  `nohtml` tinyint(1) NOT NULL DEFAULT '0',
  `nosmilies` tinyint(1) NOT NULL DEFAULT '0',
  `nolayout` tinyint(1) NOT NULL DEFAULT '0',
  `lastedited` int(32) NOT NULL DEFAULT '0',
  `avatar` int(32) NOT NULL DEFAULT '0',
  `noob` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `threads` (
  `id` int(32) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `time` int(32) NOT NULL,
  `forum` int(32) NOT NULL,
  `user` int(32) NOT NULL,
  `sticky` tinyint(1) NOT NULL DEFAULT '0',
  `closed` tinyint(1) NOT NULL DEFAULT '0',
  `views` int(32) NOT NULL DEFAULT '0',
  `replies` int(32) NOT NULL DEFAULT '0',
  `icon` text,
  `ispoll` tinyint(1) NOT NULL DEFAULT '0',
  `lastpostid` int(32) DEFAULT NULL,
  `lastpostuser` int(32) DEFAULT NULL,
  `lastposttime` int(32) DEFAULT NULL,
  `noob` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `forums` (
  `id` int(32) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(256) NOT NULL,
  `title` varchar(256) NOT NULL,
  `minpower` tinyint(1) NOT NULL DEFAULT '0',
  `minpowerreply` tinyint(1) NOT NULL DEFAULT '0',
  `minpowerthread` tinyint(1) NOT NULL DEFAULT '0',
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  `threads` int(32) NOT NULL DEFAULT '0',
  `posts` int(32) NOT NULL DEFAULT '0',
  `category` int(32) NOT NULL DEFAULT '0',
  `ord` int(32) NOT NULL DEFAULT '0',
  `theme` int(32) DEFAULT NULL,
  `lastpostid` int(32) DEFAULT NULL,
  `lastpostuser` int(32) DEFAULT NULL,
  `lastposttime` int(32) DEFAULT NULL,
  `pollstyle` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `forums` (`id`, `name`, `title`, `minpower`, `minpowerreply`, `minpowerthread`, `category`, `ord`) VALUES
(1, 'General Forum', 'For everybody!', 0, 0, 0, 1, 1),
(2, 'General Staff Forum', 'Not for everybody.', 2, 2, 2, 2, 2),
(3, 'Garbage', 'The worst posts.', 0, 0, 0, 3, 99);

INSERT INTO `threads` (`id`, `name`, `title`, `time`, `forum`, `user`) VALUES
(1, 'Test Thread 1', 'Sub title thing', 0, 1, 1),
(2, 'Test Thread 2', 'another sub title', 0, 1, 1);

INSERT INTO `posts` (`text`, `time`, `thread`, `user`, `rev`) VALUES
("Woah, this is pretty cool.", 123, 1, 1, 1)
("Yeah, this is neato!", 124, 1, 1, 1)
```

## Uninstalling

```sql
-- Delete a specific table
drop table users;

-- Delete the database
drop database cryboard;
```
