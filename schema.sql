CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE "messages1"
      (ID INTEGER PRIMARY KEY AUTOINCREMENT,
       NAME           CHAR(255)   NOT NULL,
       DESCR          CHAR(1024)  NOT NULL,
       LINK           CHAR(255)   UNIQUE ON CONFLICT IGNORE,
       SEND           INT         NOT NULL);
;
CREATE TABLE postcodes
    (ID INTEGER PRIMARY KEY AUTOINCREMENT,
     POSTCODE       INT         NOT NULL,
     WIJK           CHAR(1024)  NOT NULL,
     SUBWIJK        CHAR(1024));
CREATE TABLE messages
      (ID INTEGER PRIMARY KEY AUTOINCREMENT,
       POSTCODE       INTEGER     NOT NULL,
       NAME           CHAR(255)   NOT NULL,
       DESCR          CHAR(1024)  NOT NULL,
       LINK           CHAR(255)   UNIQUE ON CONFLICT IGNORE,
       SEND           INT         NOT NULL);
;
