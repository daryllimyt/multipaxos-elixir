 # Daryl Lim (dyl17) and Marian Lukac (ml11018)

SERVERS  = 5
CLIENTS  = 5
CONFIG   = normal_load
DEBUG    = 0
MAX_TIME = 20000

START    = Multipaxos.start
HOST	:= 127.0.0.1

# --------------------------------------------------------------------

TIME    := $(shell date +%H:%M:%S)
SECS    := $(shell date +%S)
COOKIE  := $(shell echo $$PPID)

NODE_SUFFIX := ${SECS}_${LOGNAME}@${HOST}

ELIXIR  := elixir --no-halt --cookie ${COOKIE} --name
MIX 	:= -S mix run -e ${START} \
	${NODE_SUFFIX} ${MAX_TIME} ${DEBUG} ${SERVERS} ${CLIENTS} ${CONFIG}

# --------------------------------------------------------------------

run cluster: compile
	@ ${ELIXIR} server1_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server2_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server3_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server4_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server5_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server6_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server7_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server8_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server9_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server10_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server11_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server12_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server13_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server14_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server15_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server16_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server17_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server18_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server19_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server20_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server21_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server22_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server23_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server24_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server25_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server26_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server27_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server28_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server29_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server30_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server31_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server32_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server33_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server34_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server35_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server36_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server37_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server38_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server39_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} server40_${NODE_SUFFIX} ${MIX} cluster_wait &

	@ ${ELIXIR} client1_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} client2_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} client3_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} client4_${NODE_SUFFIX} ${MIX} cluster_wait &
	@ ${ELIXIR} client5_${NODE_SUFFIX} ${MIX} cluster_wait &
	@sleep 3
	@ ${ELIXIR} multipaxos_${NODE_SUFFIX} ${MIX} cluster_start

compile:
	mix compile

clean:
	mix clean
	@rm -f erl_crash.dump

ps:
	@echo ------------------------------------------------------------
	epmd -names

