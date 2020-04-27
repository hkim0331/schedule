run:
	racket schedule.rkt -p 3001

init:
	sqlite3 schedule.db < create.sql

seed:
	sqlite3 schedule.db < seed.sql