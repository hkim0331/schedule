# 3001 for murakami, 3002 for kumasiro, 3003 for hkimura
run:
	racket schedule.rkt -p 3003

init:
	sqlite3 schedule.db < create.sql

seed: init
	sqlite3 schedule.db < seed.sql
